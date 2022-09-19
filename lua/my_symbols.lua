local logger = require("tools/logger")
local rime_api_helper = require("tools/rime_api_helper")

local tag_name = "symbals" -- 标签名

local pattern =  "^/[0-9a-zA-Z]+$"

local symbols_map = nil -- 配置字符映射
local function init_symbols_map(env)
  local config = env.engine.schema.config
  symbols_map = symbols_map or rime_api_helper:get_config_item_value(config, "punctuator/symbols")
end

-- ============================================================================= segmentor

local segmentor = {}

function segmentor.init(env)
  init_symbols_map(env)
end

function segmentor.func(segmentation, env)
  -- 是否有数据
  if(not symbols_map) then return true end

  local input_active = segmentation.input
  local pos_comfirm = segmentation:get_confirmed_position() -- 下标0开始
  local input_waiting = string.sub(input_active, pos_comfirm+1)
  local pos_start, pos_end = string.find(input_waiting, pattern) -- 下标1开始
  -- 是否匹配 pattern
  if(not pos_start) then return true end

  local input_match = string.sub(input_waiting, pos_start, pos_end)
  local symbol_list = symbols_map[input_match]
  -- 是否在 map 中有值
  if(not symbol_list) then return true end

  local seg = Segment(pos_start-1, pos_end) -- 下标0开始
  seg.tags =  Set({tag_name})
  segmentation:add_segment(seg)
  return true
end

-- ============================================================================= translator

local translator = {}

function translator.init(env)
  init_symbols_map(env)
end

function translator.func(input, seg, env)
  -- 是否有数据
  if(not symbols_map) then return end
  -- 是否有 tag: symbols
  if(not seg:has_tag(tag_name)) then return end

  local pos_start = seg._start
  local pos_end = seg._end
  local input_active = string.sub(input, pos_start+1, pos_end) -- 下标9开始
  local symbol_list = symbols_map[input_active]
  if(not symbol_list) then return end

  for index, value in pairs(symbol_list) do
    yield(Candidate(tag_name, pos_start, pos_end, value, ""))
  end
end

return {
  translator = translator,
  segmentor = segmentor
}