
local logger = require("tools/logger")
local rime_api_helper = require("tools/rime_api_helper")
local string_helper = require("tools/string_helper")

local prompt_map_notifier_id = 0

-- ----------------
-- processor
-- ----------------

local processor = {}

function processor.init(env)
  local context = env.engine.context
  prompt_map_notifier_id = prompt_map_notifier_id + 1
  env.prompt_map_notifier_id = prompt_map_notifier_id
  rime_api_helper:add_prompt_map_notifier(context, env.prompt_map_notifier_id, function(ctx)
    -- 展示
    local prompt_map = rime_api_helper:get_prompt_map()
    -- 修改 prompt
    local prompt_arr = {}
    for key, msg in pairs(prompt_map) do
      table.insert(prompt_arr, msg)
    end
    local composition = ctx.composition
    if(not composition:empty()) then
      -- 获得 Segment 对象
      local segment = composition:back()
      segment.prompt = table.concat(prompt_arr, " ")
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