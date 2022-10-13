local logger = require("tools/logger")
local rime_api_helper = require("tools/rime_api_helper")
local string_helper = require("tools/string_helper")
local table_helper = require("tools/table_helper")
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
  function tags:empty()
    return #self == 0
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
  text = string_helper.replace(text, "'", " ", true) -- ji'suan => ji suan
  local arr = string_syllabify.syllabify(text, true)
  local flag = true
  for i,t in pairs(arr) do
    if(t == text) then
      flag = false
      break
    end
  end
  if(flag) then
    table.insert(arr, text)
  end
  return arr
end

local function is_english(text)
  return string_helper.is_ascii_visible_string(text)
end

local function to_english(text)
  text = string_helper.replace(text, " ", "", true)
  text = string_helper.replace(text, "-", "", true)
  return text
end

local function split_last_cand(ctx, script_text)
  local cand = ctx:get_selected_candidate()
  if(cand and cand.preedit) then
    local preedit = cand.preedit
    if(preedit and #preedit>0) then
      local _s, _e = string.find(script_text, preedit, 1, true)
      if(_e == #script_text) then
        script_text = string.sub(script_text, 1, _s-1) .. " " .. preedit
      end
    end
  end
  return script_text
end

-- 输入进入用户字典
function translator.init(env)
  local context = env.engine.context
  local config = env.engine.schema.config
  env.initial_quality = config:get_string(env.name_space .."/initial_quality") or 0
  env.excluded_tags = rime_api_helper:get_config_item_value(config, env.name_space .."/excluded_tags") or {}
  env.mem = Memory(env.engine,env.engine.schema)  --  ns= "translator"
  env.notifiers = {
    context.commit_notifier:connect(function(ctx)
      local tags = get_tags(env)
      if(tags:empty() or tags:include_one(env.excluded_tags)) then -- 不记录
        return
      end
      local commit_text = ctx:get_commit_text()
      if(commit_text) then
        local e = DictEntry()
        e.text = commit_text
        -- e.weight = 10
        local script_text = ctx:get_script_text()
        local syllabify_text_list = nil
        if(is_english(commit_text)) then
          -- english
          syllabify_text_list = {
            script_text,
            commit_text,
            to_english(commit_text),
            to_english(script_text),
          }
          syllabify_text_list = table_helper.arr_remove_duplication(syllabify_text_list)
        else
          -- others
          syllabify_text_list = get_syllabify_text_list(split_last_cand(ctx, script_text), env)
        end
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
  local context = env.engine.context
  local segmentation = context.composition:toSegmentation()
  local confirmed_pos = segmentation and segmentation:get_confirmed_position()
  local input_activing = string.sub(context.input, confirmed_pos+1)
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
        (remaining_code_length * -0.3) + 
        (0.1 * entry.commit_count)
      yield(cand)
    end
  end
end

return {
  translator = translator
}
