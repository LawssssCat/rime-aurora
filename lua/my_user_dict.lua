local logger = require("tools/logger")
local rime_api_helper = require("tools/rime_api_helper")
local string_helper = require("tools/string_helper")
local table_helper = require("tools/table_helper")
local string_syllabify = require("tools/string_syllabify")
local LinkedList = require("tools/collection/linked_list")

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

local function split_by_syllabify(text, env)
  text = string_helper.replace(text, "'", " ", true) -- ji'suan => ji suan
  local arr = string_syllabify.syllabify(text, true)
  -- insert script text
  local text_script = text
  table.insert(arr, text_script)
  -- insert no blank text ( use: emoji easy_en )
  local text_no_blank = string_helper.replace(text, " ", "", true)
  table.insert(arr, text_no_blank)
  -- remove duplicate
  arr = table_helper.arr_remove_duplication(arr)
  return arr
end

--[[
  script_text "ni haoma"
  cand.preedit "ma"
  =>
  return "ni hao ma"
]]
local function split_last_cand(ctx, script_text)
  script_text = script_text or ""
  local cand = ctx:get_selected_candidate()
  if(cand and cand.preedit) then
    local preedit = cand.preedit
    if(preedit and #preedit>0) then
      local _s, _e = string.find(script_text, preedit, 1, true)
      if(_e == #script_text) then
        script_text = string.sub(script_text, 1, _s-1) .. " " .. preedit
      end
    end
    local comment = cand.comment 
    if(comment and #comment>0) then -- ~o others...........
      local remain = string.match(comment, "^~(%g+)[ ]*") -- ~o => o
      if(remain) then
        script_text  = script_text .. remain
      end
    end
  end
  return script_text
end

local function get_syllabify_text_list(commit_text, script_text, ctx, env)
  local syllabify_text_list = split_by_syllabify(split_last_cand(ctx, script_text), env) or {}
  return syllabify_text_list
end

local function is_need_show(text, entry)
  -- 你、ni、
  local remaining_code_length	= entry.remaining_code_length	
  if(remaining_code_length == 0) then
    return true
  end
  local comment = entry.comment
  if(not comment) then
    return true
  end
  -- 你、n、~i
  -- 你好、ni h、~ao
  if(string.match(comment, "^~%g+$")) then
    return true
  end
  -- 你好、ni、~ hao
  -- if(string.match(comment, "^~ %g+$")) then -- 预测候选词
  --   return true
  -- end
  return false
end

local function adjust_syllabify(syllabify_list, commit_text, env)
  local words = string_helper.split(commit_text, "")
  -- 排除长度不一致的
  if(#syllabify_list > 0) then
    local patterns = {}
    for i = 1,#words do
      table.insert(patterns, "%g+") -- 非空格
    end
    local pattern = "^"..table.concat(patterns, " ").."$" -- "^%g+ %g+ ...... %g+$"
    local index = 1
    while(index <= #syllabify_list) do
      local w = syllabify_list[index]
      if(not string.match(w, pattern)) then
        table.remove(syllabify_list, index)
      else
        index = index + 1
      end
    end
  end
end

local function calc_quality(entry, env)
  local remaining_code_length = entry.remaining_code_length or 0
  local quality = env.initial_quality + math.exp(entry.weight) -- 计算权重
  if(remaining_code_length>0) then
    local exp_count = math.exp(entry.commit_count / 100)
    exp_count = exp_count>1 and exp_count or 1
    quality = quality + (-1 / exp_count)
  else
    quality = quality + (entry.commit_count / 100)
  end
  return quality
end

-- -----------------------
-- handlers
-- 外部注册的处理器
-- -----------------------

-- comment handlers
-- 处理 注释
local comment_handlers = {
  function(entry)
    return false
  end
}
local function comment_handlers_add(func)
  local t = type(func)
  if(t=="function") then
    table.insert(comment_handlers, func)
  else
    logger.error("fail to add comment_handlers func for error type of args#1 \""..t.."\".")
  end
end

-- syllabify handlers
-- 处理 分词
local syllabify_handlers = LinkedList()
syllabify_handlers:add(function(commit_text, script_text, ctx, env) -- others 默认处理
  -- others
  local syllabify_text_list = get_syllabify_text_list(commit_text, script_text, ctx, env)
  adjust_syllabify(syllabify_text_list, commit_text, env)
  return true, syllabify_text_list
end)
local function syllabify_handlers_add(func)
  local t = type(func)
  if(t=="function") then
    syllabify_handlers:add_at(1, func)
  else
    logger.error("fail to add syllabify_handlers func for error type of args#1 \""..t.."\".")
  end
end

-- =============================================== translator

local mem = nil

local translator = {}

-- 输入进入用户字典
function translator.init(env)
  local context = env.engine.context
  local config = env.engine.schema.config
  env.initial_quality = config:get_string(env.name_space .."/initial_quality") or 0
  env.excluded_tags = rime_api_helper:get_config_item_value(config, env.name_space .."/excluded_tags") or {}
  env.mem = mem or (function()
    mem = Memory(env.engine, env.engine.schema)
    return mem
  end)()
  env.notifiers = {
    context.commit_notifier:connect(function(ctx)
      local tags = get_tags(env)
      if(tags:empty() or tags:include_one(env.excluded_tags)) then -- 不记录
        return
      end
      local commit_text = ctx:get_commit_text()
      if(not commit_text) then
        return
      end
      -- 构建
      local e = DictEntry()
      e.text = commit_text
      -- e.weight = 10
      local script_text = ctx:get_script_text()
      -- 分词
      local syllabify_text_list = nil
      for iter in syllabify_handlers:iter() do
        local handler = iter.value
        local flag,  res_2 = handler(commit_text, script_text, ctx, env)
        if(flag) then
          syllabify_text_list = res_2
          break
        end
      end
      -- 存词
      for i, text in pairs(syllabify_text_list) do
        e.custom_code = text
        env.mem:update_userdict(e,1,"") -- do nothing to userdict
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
  local syllabify_text_list = split_by_syllabify(input_activing, env) or {}
  -- 查库
  local cand_list = LinkedList()
  local mem = env.mem
  for i, text in pairs(syllabify_text_list) do
    mem:user_lookup(text, true)
    for entry in mem:iter_user() do
      if(is_need_show(text, entry)) then
        local phrase = Phrase(mem, "my_user_dict", seg._start, seg._end, entry)
        phrase.quality = calc_quality(entry, env)
        for i, h in pairs(comment_handlers) do
          local flag, comment = h(entry)
          if(flag) then
            phrase.comment = phrase.comment .. " " .. comment
            break
          end
        end
        cand_list:add(phrase:toCandidate())
        -- yield(cand)
      end
    end
  end
  -- 排序
  cand_list:sort(function(a,b) return a.quality>b.quality end)
  -- yield
  for iter in cand_list:iter() do
    local cand = iter.value
    yield(cand)
  end
end

return {
  translator = translator,
  comment_handlers_add = comment_handlers_add,
  syllabify_handlers_add = syllabify_handlers_add,
  -- 暂时没必要开放
  -- get_syllabify_text_list = get_syllabify_text_list,
  -- adjust_syllabify = adjust_syllabify,
}
