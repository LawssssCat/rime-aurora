local logger = require("tools/logger")
local rime_api_helper = require("tools/rime_api_helper")

local segmentor = {}

function segmentor.init(env)
  local config = env.engine.schema.config
  env.pattern_map = rime_api_helper:get_config_item_value(config, "recognizer/patterns")
end

function segmentor.func(segmentation, env)
  if(env.pattern_map) then
    local input_active = segmentation.input
    local pos_comfirm = segmentation:get_confirmed_position() -- 下标0开始
    local input_waiting = string.sub(input_active, pos_comfirm+1)
    for key, pattern in pairs(env.pattern_map) do
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
  segmentor = segmentor
}