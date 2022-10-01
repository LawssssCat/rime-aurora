local logger = require("tools/logger")
local rime_api_helper = require("tools/rime_api_helper")
local string_helper = require("tools/string_helper")
local string_syllabify = require("tools/string_syllabify")

local translator = {}

local function get_tags(env)
  local composition =  env.engine.context.composition
  local segment = not composition:empty() and composition:back()
  local tags = {}
  if(segment) then
    for tag in pairs(segment.tags) do
      table.insert(tags, tag)
    end
  end
  function tags:include(tag)
    for i, t in pairs(self) do
      if(tag == t) then
        return true
      end
    end
    return false
  end
  function tags:include_one(arr)
    for i, tag in pairs(arr) do
      if(self:include(tag)) then
        return true
      end
    end
    return false
  end
  return tags
end

local function get_syllabify_text_list(text, env)
  local tags = get_tags(env)
  if(tags:include_one(env.excluded_syllabify_tags)) then
    return {text}
  else
    return string_syllabify.syllabify(text, true)
  end
end

-- 输入进入用户字典
function translator.init(env)
  local context = env.engine.context
  local config = env.engine.schema.config
  env.initial_quality = config:get_string(env.name_space .."/initial_quality") or 0
  env.excluded_syllabify_tags = rime_api_helper:get_config_item_value(config, env.name_space .."/excluded_syllabify_tags") or {}
  env.mem = Memory(env.engine,env.engine.schema)  --  ns= "translator"
  env.notifiers = {
    context.commit_notifier:connect(function(ctx)
      local commit_text = ctx:get_commit_text()
      if(commit_text) then
        local e = DictEntry()
        e.text = commit_text
        -- e.weight = 10
        local script_text = ctx:get_script_text()
        local syllabify_text_list = get_syllabify_text_list(script_text, env)
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
  local syllabify_text_list = get_syllabify_text_list(input_activing, env)
  -- 查库
  local mem = env.mem
  for i, text in pairs(syllabify_text_list) do
    mem:user_lookup(text, true)
    for entry in mem:iter_user() do
      local remaining_code_length = entry.remaining_code_length or 0
      local phrase = Phrase(mem, "my_user_dict", seg._start, seg._end, entry)
      local cand = phrase:toCandidate()
      cand.quality = math.exp(entry.weight) + -- 计算权重
        env.initial_quality + 
        (remaining_code_length * -0.2) + 
        (0.2 * entry.commit_count)
      yield(cand)
    end
  end
end

return {
  translator = translator
}
