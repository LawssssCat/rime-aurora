
local logger = require("tools/logger")
local string_helper = require("tools/string_helper")
local rime_api_helper = require("tools/rime_api_helper")
local CycleList = require("tools/collection/cycle_list")
local LinkedList = require("tools/collection/linked_list")

-- ============================================================= translator

local translator = {}

local history_list = CycleList(20)

function translator.init(env)
  local config = env.engine.schema.config
  local history_num_max = rime_api_helper:get_config_item_value(config, env.name_space .. "/history_num_max")
  history_list:set_max_size(history_num_max)
  env.notifier_commit_history = env.engine.context.commit_notifier:connect(function(ctx)
    local cand = ctx:get_selected_candidate()
    if(cand)
    then
      history_list:add({
        text = cand.text,
        quality = string.format("%0.4f", cand.quality),
        comment = cand.comment,
        preedit = cand.preedit,
        type = cand.type,
        dynamic_type = cand:get_dynamic_type()
      })
    end
  end)
end

function translator.fini(env)
  env.notifier_commit_history:disconnect()
end

function translator.func(input, seg, env)
  if(seg:has_tag("history")) then
    local temp = LinkedList()
    for iter in history_list:iter() do
      temp:add_at(1, iter.value)
    end
    for iter in temp:iter() do
      local item = iter.value
      local text = item.text
      local comment = string_helper.format("（💬:\"{preedit}\",✍🏻️:{dynamic_type}-{type},🏆:{quality}）", item)
      local cand = Candidate("history", seg.start, seg._end, text, comment)
      -- cand.quality = -199
      yield(cand)
    end
  end
end

return {
  translator = translator
}