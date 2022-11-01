local logger = require("tools/logger")
local rime_api_helper = require("tools/rime_api_helper")
local string_helper = require("tools/string_helper")

local tag_name = "punct"

local option_name = "full_shape"

local segmentor = {}

function segmentor.init(env)
  local context = env.engine.context
  local config = env.engine.schema.config
  local func_01 = function(ctx)
    local current_punctuator_map = nil
    if(ctx:get_option(option_name)) then
      -- full_shape
      env.full_shape_map = env.full_shape_map or rime_api_helper:get_config_item_value(config, "punctuator/full_shape")
      current_punctuator_map = env.full_shape_map
    else
      -- half_shape
      env.half_shape_map = env.half_shape_map or rime_api_helper:get_config_item_value(config, "punctuator/half_shape")
      current_punctuator_map = env.half_shape_map
    end
    env.current_punctuator_map = current_punctuator_map
  end
  func_01(context)
  env.notifier_option_full_shape = context.option_update_notifier:connect(function(ctx, name) -- 监听选项
    if(name == option_name) then
      func_01(ctx)
    end
  end)
end

function segmentor.fini(env)
  env.notifier_option_full_shape:disconnect()
end

function segmentor.func(segmentation, env)
  local current_punctuator_map = env.current_punctuator_map
  if(not current_punctuator_map) then return true end
  local input_active = segmentation.input
  -- 是否有输入
  if(not input_active or #input_active < 1) then
    return true
  end
  local pos = #input_active
  local c = string.sub(input_active, pos)
  -- 是否是（可见）ascii
  if(not string_helper.is_ascii_visible(c)) then
    return true
  end
  -- 转换
  local key = current_punctuator_map[c]
  -- 是否在 map 有值
  if(not key) then
    return true
  end
  local seg = Segment(pos-1, pos)
  seg.tags =  Set({tag_name})
  segmentation:add_segment(seg)
  return true
end

return {
  segmentor = segmentor
}