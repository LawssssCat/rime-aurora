
local logger = require("tools/logger")
local rime_api_helper = require("tools/rime_api_helper")
local string_helper = require("tools/string_helper")

local prompt_map_notifier_id = 0

local function sort(prompt_map, order_arr)
  local result = {}
  local used = {}
  for i,name in pairs(order_arr) do
    local msg = prompt_map[name]
    if(msg) then
      table.insert(result, msg)
      used[name] = true
    end
  end
  for name, msg in pairs(prompt_map) do
    if(not used[name]) then
      table.insert(result, msg)
    end
  end
  return result
end

-- ----------------
-- processor
-- ----------------

local processor = {}

function processor.init(env)
  local context = env.engine.context
  local config = env.engine.schema.config
  local config_order = rime_api_helper:get_config_item_value(config, env.name_space .. "/order") or {}
  prompt_map_notifier_id = prompt_map_notifier_id + 1 -- 环境编号
  env.prompt_map_notifier_id = prompt_map_notifier_id
  -- 展示
  rime_api_helper:add_prompt_map_notifier(context, env.prompt_map_notifier_id, function(ctx)
    -- 展示信息
    local prompt_map = rime_api_helper:get_prompt_map()
    -- 排序
    local prompt_arr = sort(prompt_map, config_order)
    local composition = ctx.composition
    if(not composition:empty()) then
      local segment = composition:back()
      segment.prompt = table.concat(prompt_arr, " ") -- 调用 api
    end
  end)
end

function processor.fini(env)
  local context = env.engine.context
  rime_api_helper:remove_prompt_map_notifier(context, env.prompt_map_notifier_id)
end

function processor.func(key, env)
  return rime_api_helper.processor_return_kNoop
end

return {
  processor=processor,
}