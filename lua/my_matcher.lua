local logger = require("tools/logger")
local rime_api_helper = require("tools/rime_api_helper")

local segmentor = {}

function segmentor.init(env)
  local config = env.engine.schema.config
  env.pattern_map = rime_api_helper:get_config_map(config, "recognizer/patterns")
end

function segmentor.func(segmentation, env)
  if(env.pattern_map) then
    local input_active = segmentation.input
    local pos_comfirm = segmentation:get_confirmed_position() -- 下标0开始
    local input_waiting = string.sub(input_active, pos_comfirm+1)
    for key, pattern in pairs(env.pattern_map) do
      local str = string.match(input_waiting, pattern)
      if(str) then
        local seg = Segment(pos_comfirm, pos_comfirm+#str)
        seg.tags =  Set({key})
        segmentation:add_segment(seg)
      end
      -- local seg = Segment(start_pos, start_pos + segmentation.input:len())
  --   seg.tags =  Set({"qqq", "abc"})
  --   seg.prompt="(ssssssss)"
  --   -- logger.warn(seg:has_finished_composition())
  --   -- logger.warn(seg:get_prompt())
  --   segmentation:add_segment(seg)
    end
  end
  return true -- 永远放行
end

return {
  segmentor = segmentor
}