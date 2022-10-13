local logger = require("tools/logger")
local rime_api_helper = require("tools/rime_api_helper")
local string_helper = require("tools/string_helper")
local ptry = require("tools/ptry")

local function string_stack(str) -- version => {"v", "ve", "ver", "vers", "versi", "versio", "version"}
  local t = ""
  local t_list = {}
  for i, v in pairs(string_helper.split(str, "")) do 
    t = t..v
    table.insert(t_list, t)
  end
  return t_list
end

--[[
  扩展正则语法：
  1. s{hi}?j{ian}? => s(h|hi)?j(i|ia|ian)?
]]
local function expand_pattern(pattern)
  local f = function(k) return string.match(k, "{[%w%s_-]+}%?") end -- aa{abc}?cc => {abc}?
  local fi = function(k) return string.match(k, "{(.*)}%?") end -- {abc}? => abc
  local fie = function(k) -- abc => a|ab|abc
    local stack_list = string_stack(k)
    return string_helper.join(stack_list, "|")
  end
  local p = f(pattern)
  while(p) do
    local pi = fi(p)
    local pie = "(" .. fie(pi) .. ")?"
    pattern = string_helper.replace(pattern, p, pie, true)
    p = f(pattern)
  end
  return pattern
end

-- ----------------------------------
-- 环境
-- ----------------------------------

local pattern_map = nil -- 正则匹配表达式

local pattern_map_init = function(env)
  return pattern_map or 
  (function()
    local config = env.engine.schema.config
    pattern_map = rime_api_helper:get_config_item_value(config, "recognizer/patterns")
    for key, pattern in pairs(pattern_map) do
      ptry(function()
        pattern_map[key] = expand_pattern(pattern)
      end)
      ._catch(function(err)
        logger.error(key, pattern, err)
      end)
    end
    return pattern_map
  end)()
end

-- ====================================== processor

local processor = {}

function processor.func(key, env)
  local pattern_map = pattern_map_init(env)
  if(not pattern_map or key:ctrl() or key:alt() or key:release()) 
  then
    return rime_api_helper.processor_return_kNoop
  end
  local code = key.keycode
  if(string_helper.is_ascii_visible_code(code)) then
    local ch = utf8.char(code)
    local context = env.engine.context
    local segmentation = context.composition:toSegmentation()
    local confirmed_pos = segmentation and segmentation:get_confirmed_position() or 0
    local input = (context.input or "") .. ch
    local input_waiting = string.sub(input, confirmed_pos+1)
    for tag, pattern in pairs(pattern_map) do
      if(rime_api_helper:regex_match(input_waiting, pattern)) then
        context:push_input(ch)
        return rime_api_helper.processor_return_kAccepted
      end
    end
  end
  return rime_api_helper.processor_return_kNoop
end

-- ====================================== segmentor

local segmentor = {}

function segmentor.func(segmentation, env)
  local pattern_map = pattern_map_init(env)
  if(pattern_map) then
    local input_active = segmentation.input
    local pos_comfirm = segmentation:get_confirmed_position() -- 下标0开始
    local input_waiting = string.sub(input_active, pos_comfirm+1)
    for key, pattern in pairs(pattern_map) do
      local match = rime_api_helper:regex_match(input_waiting, pattern)
      if(match) then
        local match_str = match[1]
        local _start, _end = string.find(input_waiting, match_str, 1, true)
        local seg = Segment(_start-1, _end)
        seg.tags =  Set({key})
        segmentation:add_segment(seg)
      end
    end
  end
  return true -- 永远放行
end

return {
  segmentor = segmentor,
  processor = processor
}