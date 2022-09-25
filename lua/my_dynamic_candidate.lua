local logger = require("tools/logger")
local rime_api_helper = require("tools/rime_api_helper")
local string_helper = require("tools/string_helper")
local ptry = require("tools/ptry")

-- ----------------------------------------
-- 本地方法
-- ----------------------------------------

local function string_stack(str) -- version => {"v", "ve", "ver", "vers", "versi", "versio", "version"}
  local t = ""
  local t_list = {}
  for i, v in pairs(string_helper.split(str, "")) do 
    t = t..v
    table.insert(t_list, t)
  end
  return t_list
end

local function adapte_pattern_item(perfix, key) -- s{hi}?j{ian}? => s(h|hi)?j(i|ia|ian)?
  local perfix = perfix or ""
  local adapted_key = key
  local f = function(k) return string.match(k, "{[%w%s_-]+}%?") end -- aa{abc}?cc => {abc}?
  local fi = function(k) return string.match(k, "{(.*)}%?") end -- {abc}? => abc
  local fie = function(k) -- abc => a|ab|abc
    local stack_list = string_stack(k)
    return string_helper.join(stack_list, "|")
  end
  local p = f(adapted_key)
  while(p) do
    local pi = fi(p)
    local pie = "(" .. fie(pi) .. ")?"
    adapted_key = string_helper.replace(adapted_key, p, pie, true)
    p = f(adapted_key)
  end
  return "^" .. perfix .. adapted_key .. "$"
end

-- ----------------------------------------
-- 环境
-- ----------------------------------------

local tagname_prefix = "dy_cand_"
local pattern_list = nil
local pattern_list_init = function(env)
  local config = env.engine.schema.config
  local config_perfix = rime_api_helper:get_config_item_value(config, "my_dynamic_candidate/prefix") or ""
  local config_patterns = rime_api_helper:get_config_item_value(config, "my_dynamic_candidate/patterns") or {}
  local result_list = {}
  for i, p in pairs(config_patterns) do
    p.key = adapte_pattern_item(config_perfix, p.key)
    table.insert(result_list, p)
  end
  return result_list
end

-- ----------------------------------------
-- 组件
-- ----------------------------------------

-- ====================================================== processor

local processor = {}

function processor.init(env)
  pattern_list = pattern_list or pattern_list_init(env)
end

function processor.func(key, env)
  if(not pattern_list or #pattern_list == 0 or
    key:ctrl() or key:alt() or key:release()) 
  then
    return rime_api_helper.processor_return_kNoop
  end
  local code = key.keycode
  if(string_helper.is_ascii_visible(code)) then
    local ch = utf8.char(code)
    local context = env.engine.context
    local segmentation = context.composition:toSegmentation()
    local confirmed_pos = segmentation and segmentation:get_confirmed_position() or 0
    local input = context.input .. ch
    if(input and #input > 0) then
      local input_waiting = string.sub(input, confirmed_pos+1)
      for i, pattern_item in pairs(pattern_list) do
        local key = pattern_item.key
        if(rime_api_helper:regex_match(input_waiting, key)) then
          context:push_input(ch)
          return rime_api_helper.processor_return_kAccepted
        end
      end
    end
  end
  return rime_api_helper.processor_return_kNoop
end

-- ====================================================== segmentor

local segmentor = {}

function segmentor.func(env)
  pattern_list = pattern_list or pattern_list_init(env)
end

function segmentor.func(segmentation, env)
  if(not pattern_list or #pattern_list == 0) then
    return true
  end
  local context = env.engine.context
  local confirmed_pos = segmentation and segmentation:get_confirmed_position() or 0
  local input = context.input
  if(not input or #input < 1) then
    return true
  end
  local input_waiting = string.sub(input, confirmed_pos+1)
  for i, pattern_item in pairs(pattern_list) do
    local key = pattern_item.key
    local match = rime_api_helper:regex_match(input_waiting, key)
    if(match) then
      local match_str = match[1]
      local _start, _end = string.find(input_waiting, match_str, 1, true)
      local seg = Segment(_start-1, _end)
      local tagname = tagname_prefix .. tostring(i)
      seg.tags =  Set({tagname})
      segmentation:add_segment(seg)
    end
  end
  return true
end

-- ====================================================== translator

local translator = {}

function translator.init(env)
  env.status_map = {}
end

function translator.fini(env)
  for tag, status in pairs(env.status_map) do
    local module_name = status.module_name
    local fini_name = status.fini_name
    if(fini_name) then
      ptry(function()
        local module = require(module_name)
        local fini = module[fini_name]
        fini(env)
      end)
      ._catch(function()
        logger.error("fail to run translator \"fini\":", module_name)
      end)
    end
  end
  env.status_map = nil
end

function translator.func(input, seg, env)
  if(not pattern_list or #pattern_list == 0) then
    return
  end
  for tag, _ in pairs(seg.tags) do
    local pattern = "^" .. tagname_prefix .. "(%d+)$"
    local match = tonumber(string.match(tag, pattern))
    if(match and #pattern_list >= match) then
      local pattern_item = pattern_list[match]
      local module_name = pattern_item.module
      local init_name = pattern_item.init
      local func_name = pattern_item.func
      local fini_name = pattern_item.fini
      ptry(function()
        local module = require(module_name)
        local init = module[init_name]
        local func = module[func_name]
        local status = env.status_map[tag] or {
          module_name = module_name
        }
        if(init_name and status.init_run ~= true) then
          init(env)
          status.init_run = true
        end
        func(input, seg, env)
        if(fini_name) then
          status.fini_name = fini_name
        end
        env.status_map[tag] = status
      end)
      ._catch(function(err)
        logger.error("fail to run translator \"func\":", tag, _, pattern_item, err)
      end)
    end
  end
end

return {
  segmentor = segmentor,
  translator = translator,
  processor = processor
}