local logger = require("tools/logger")
local rime_api_helper = require("tools/rime_api_helper")
local string_helper = require("tools/string_helper")
local string_syllabify = require("tools/string_syllabify")

local translator = {}

-- 输入进入用户字典
function translator.init(env)
  local context = env.engine.context
  local config = env.engine.schema.config
  env.initial_quality = config:get_string(env.name_space .."/initial_quality") or 0
  env.mem = Memory(env.engine,env.engine.schema)  --  ns= "translator"
  env.notifiers = {
    context.commit_notifier:connect(function(ctx)
      local commit_text = ctx:get_commit_text()
      if(commit_text) then
        local e = DictEntry()
        e.text = commit_text
        -- e.weight = 10
        local script_text = ctx:get_script_text()
        local syllabify_text_list = string_syllabify.syllabify(script_text, true)
        for i, text in pairs(syllabify_text_list) do
          e.custom_code = text
          env.mem:update_userdict(e,1,"") -- do nothing to userdict
        end
      end
    end),
  }
end

function translator.fini(env)
  for i, n in pairs(env.notifiers) do
    n:disconnect()
  end
end

function translator.func(input, seg, env)
  local input_activing = string.sub(input, seg._start+1, seg._end)
  -- 分词
  local syllabify_text_list = string_syllabify.syllabify(input_activing, true)
  -- 查库
  local mem = env.mem
  for i, text in pairs(syllabify_text_list) do
    mem:user_lookup(text, true)
    for entry in mem:iter_user() do
      local incomplete = entry.remaining_code_length~=0
      local phrase = Phrase(mem, "my_user_dict", seg._start, seg._end, entry)
      local cand = phrase:toCandidate()
      cand.quality = math.exp(entry.weight) + -- 计算权重
        env.initial_quality + 
        (incomplete and -1 or 0) + 
        (0.1 * entry.commit_count)
      -- logger.warn("=========", entry.text, entry.weight, cand.quality)
      yield(cand)
    end
  end
end

return {
  translator = translator
}
