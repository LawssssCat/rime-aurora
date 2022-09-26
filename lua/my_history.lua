
local logger = require("tools/logger")
local string_helper = require("tools/string_helper")
local CycleList = require("tools/collection/cycle_list")
local LinkedList = require("tools/collection/linked_list")

-- ============================================================= translator

local translator = {}

local history_list = CycleList(20)

function translator.history_init(env)
  local item_config = env.item_config
  local history_num_max = item_config and item_config.history_num_max or history_num_max
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

function translator.history_fini(env)
  env.notifier_commit_history:disconnect()
end

function translator.history_handle(input, seg, env)
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

return translator