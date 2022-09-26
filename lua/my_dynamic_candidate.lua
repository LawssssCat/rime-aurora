local logger = require("tools/logger")
local rime_api_helper = require("tools/rime_api_helper")
local string_helper = require("tools/string_helper")
local ptry = require("tools/ptry")
local LinkedList = require("tools/collection/linked_list")

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
-- 组件
-- ----------------------------------------

-- ====================================================== processor

local processor = {}

local tagname_prefix = "dy_cand_"

local pattern_list = nil

local function pattern_list_init(env)
  local config = env.engine.schema.config
  local config_perfix = rime_api_helper:get_config_item_value(config, "my_dynamic_candidate/prefix") or ""
  local config_patterns = rime_api_helper:get_config_item_value(config, "my_dynamic_candidate/patterns") or {}
  -- 全局配置
  local pattern_list = {}
  for i, p in pairs(config_patterns) do
    p.key = adapte_pattern_item(config_perfix, p.key)
    table.insert(pattern_list, p)
  end
  return pattern_list
end

local function get_pattern_item_by_tag(tag)
  local pattern = "^" .. tagname_prefix .. "(%d+)$"
  local match = tonumber(string.match(tag, pattern))
  if(match and #pattern_list >= match) then
    local pattern_item = pattern_list[match] -- 配置：处理单元信息ℹ
    return pattern_item
  end
  return nil
end

function processor.init(env)
  pattern_list = pattern_list or pattern_list_init(env)
end

function processor.fini()
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
    logger.warn("empty pattern list?")
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

local function get_item_env_map_key(item)
  local module_name = item.module
  local func_name = item.func
  local key = module_name .. "." .. func_name
  return key
end

function translator.init(env)
  pattern_list = pattern_list or pattern_list_init(env)
  -- 初始化 item_env_map
  local item_env_map = {} -- <module_name.func_name, {item_env}>
  -- 执行 init
  for index, item in pairs(pattern_list) do
    local key = get_item_env_map_key(item)
    local item_env = {
      engine = env.engine,
      item_config = item
    }
    local module_name = item.module
    local init_name = item.init
    if(init_name) then
      ptry(function()
        local module = require(module_name)
        local init = module[init_name]
        init(item_env)
      end)
      ._catch(function(err)
        logger.error("fail item \"init\".", key, item, err)
      end)
    end
    item_env_map[key] = item_env
  end
  env.item_env_map = item_env_map
end

function translator.fini(env)
  if(not pattern_list or #pattern_list == 0) then
    logger.warn("empty pattern list?")
    return
  end
  local item_env_map = env.item_env_map

  -- 执行 fini
  for index, item in pairs(pattern_list) do
    local key = get_item_env_map_key(item)
    local item_env = item_env_map[key]
    item_env.engine = env.engine
    local module_name = item.module
    local fini_name = item.fini
    if(fini_name) then
      ptry(function()
        local module = require(module_name)
        local fini = module[fini_name]
        fini(item_env)
      end)
      ._catch(function(err)
        logger.error("fail item \"fini\".", key, item, err)
      end)
    end
    item_env_map[key] = item_env
  end
end

function translator.func(input, seg, env)
  if(not pattern_list or #pattern_list == 0) then
    return
  end
  local item_env_map = env.item_env_map

  for tag, _ in pairs(seg.tags) do
    local pattern_item = get_pattern_item_by_tag(tag)
    if(pattern_item) then
      local key = get_item_env_map_key(pattern_item)
      local item_env = item_env_map[key]
      item_env.engine = env.engine
      local module_name = pattern_item.module
      local func_name = pattern_item.func
      ptry(function()
        local module = require(module_name)
        local func = module[func_name]
        func(input, seg, item_env)
      end)
      ._catch(function(err)
        logger.error("fail item \"func\":", tag, _, pattern_item, err)
      end)
      item_env_map[key] = item_env
    end
  end
end

return {
  segmentor = segmentor,
  translator = translator,
  processor = processor
}