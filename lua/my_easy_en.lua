local logger = require("tools/logger")
local rime_api_helper = require("tools/rime_api_helper")
local string_helper = require("tools/string_helper")
local table_helper = require("tools/table_helper")
local Object = require("tools/classic")
local my_user_dict = require("my_user_dict")
local comment_handlers_add = my_user_dict.comment_handlers_add
local syllabify_handlers_add = my_user_dict.syllabify_handlers_add

local option_name = "ascii_mode"

local cand_type = "easy_en"

-- =================================== methods

local function get_comment(text, env)
  local text_comment = env.db_rev:lookup(text) or ""
  local text_comment_preedit = env.format:apply(text_comment) or ""
  return text_comment_preedit
end

local function is_english(text)
  return string_helper.is_ascii_visible_string(text)
end

local function to_english(text)
  text = string_helper.replace(text, " ", "", true)
  text = string_helper.replace(text, "-", "", true)
  return text
end

-- =================================== Handlers => 输入（input） 生成 候选词（candidate）

--[[
  handler: 【默认】 翻译英文
]]
local EasyHandler = Object:extend()
function EasyHandler:new(input_waiting, seg, env)
  self.env = env
  self.input_waiting = input_waiting
  self.seg = seg
end
function EasyHandler:yield()
  local input_waiting = self.input_waiting
  local seg = self.seg
  local env = self.env
  local mem = env.db_mem
  if(not self:load()) then return end
  for entry in mem:iter_dict() do
    if(self:is_yield(entry)) then
      -- text
      local text = self:get_candidate_text(entry)
      -- comment
      local text_comment_preedit = get_comment(entry.text, env)
      -- candidate
      local cand = Candidate(cand_type, seg.start, seg._end, text, entry.comment.." "..text_comment_preedit)
      cand.quality = env.config_initial_quality
      -- yield
      yield(cand)
    end
  end
end
function EasyHandler:load()
  local env = self.env
  local mem = env.db_mem
  local pattern = self:get_pattern()
  return mem:dict_lookup(pattern, env.config_enable_completion, 0);
end
function EasyHandler:is_yield(entry) return true end
function EasyHandler:get_pattern()
  local pattern = self.pattern
  if(not pattern) then
    local input_waiting = self.input_waiting
    pattern = string.lower(input_waiting)
    self.pattern = pattern
  end
  return pattern
end
function EasyHandler:get_candidate_text(entry)
  local pattern = self:get_pattern()
  local input_waiting = self.input_waiting
  local text = string_helper.replace(entry.text, "^"..pattern, input_waiting)
  return text
end

--[[
  handler: 处理 * 号
]]
local GessHandler = EasyHandler:extend()
function GessHandler:load()
  local env = self.env
  local mem = env.db_mem
  local pattern = self:get_pattern()
  if(not pattern or #pattern<2) then
    return mem:dict_lookup(pattern, env.config_enable_completion, env.config_fuzzy_match_limit); -- 看情况设置，多了会卡
  end
  return mem:dict_lookup(pattern, env.config_enable_completion, 0);
end
function GessHandler:get_pattern()
  local pattern = self.pattern
  if(not pattern) then
    local split = self:get_split()
    pattern = split[1]
    self.pattern = pattern
  end
  return pattern
end
function GessHandler:get_split_raw()
  local split_raw = self.split_raw
  if(not split_raw) then
    local input_waiting = self.input_waiting
    split_raw = string_helper.split(input_waiting, "*")
    self.split_raw = split_raw
  end
  return split_raw
end
function GessHandler:get_split()
  local split = self.split
  if(not split) then
    local input_waiting = self.input_waiting
    split = string_helper.split(string.lower(input_waiting), "*")
    self.split = split
  end
  return split
end
-- bea*ful => bea.*ful => "beautiful" ok, "beakful" ok, ...
function GessHandler:is_yield(entry)
  local text = entry.text
  local input_waiting = self.input_waiting
  if(#text<#input_waiting) then return false end
  local split = self:get_split()
  local yield_pattern = "^"..string_helper.join(split, ".*")..".*$"
  return string.match(text, yield_pattern)~=nil
end
function GessHandler:get_candidate_text(entry)
  local text = entry.text
  local split = self:get_split()
  local split_raw = self:get_split_raw()
  local index = 1
  for i=1,#split do
    local part = split[i]
    local part_raw = split_raw[i]
    local s,e = string.find(text, part, index, true)
    text = string.sub(text,1,s-1)..part_raw..string.sub(text, e+1, #text)
    index = s+#part_raw
  end
  return text
end

-- =============================================================== translator

-- 初始化引用
local db_mem = nil
local db_rev = nil
local format = nil
local user_dict_comment_handler = nil
local user_dict_syllabify_handler = nil

local translator = {}

function translator.init(env)
  local config = env.engine.schema.config
  env.config_enable_completion = config:get_bool(env.name_space .. "/enable_completion")==true and true or false
  env.config_initial_quality = config:get_int(env.name_space .. "/initial_quality") or 0
  env.config_tag = config:get_string(env.name_space .. "/tag") or "easy_en"
  env.config_dictionary = config:get_string(env.name_space .. "/dictionary") or "easy_en"
  env.config_dictionary_comment = config:get_string(env.name_space.."/dictionary_comment") or "easy_en_comment"
  env.config_comment_format = config:get_list(env.name_space .. "/comment_format")
  env.config_fuzzy_match_limit = config:get_int(env.name_space .. "/fuzzy_match_limit") or 1000
  -- text
  env.db_mem = db_mem or (function()
    db_mem = Memory(env.engine, Schema(env.config_dictionary))
    return db_mem
  end)()
  -- comment
  env.db_rev = db_rev or (function()
    db_rev = ReverseDb("build/"..env.config_dictionary_comment..".reverse.bin")
    return db_rev
  end)()
  -- comment preedit
  env.format = format or (function()
    format = Projection()
    if(not format:load(env.config_comment_format)) then
      logger.warn("fail to load \"dictionary_comment\"", env)
    end
    return format
  end)()
  -- 注册用户字典的注释（comment）处理器
  if(not user_dict_comment_handler) then
    user_dict_comment_handler = function(entry)
      local text = entry.text
      text = string.lower(text)
      if(string_helper.is_ascii_visible_string(text)) then
        local text_comment_preedit = get_comment(text, env)
        if(text_comment_preedit and #text_comment_preedit>0) then
          return true, text_comment_preedit
        end
      end
      return false
    end
    comment_handlers_add(user_dict_comment_handler)
  end
  -- 注册用户字典的分词（syllabify）处理器
  if(not user_dict_syllabify_handler) then
    user_dict_syllabify_handler = function(commit_text, script_text, ctx, env)
      if(is_english(commit_text)) then
        -- english
        local syllabify_text_list = {
          script_text,
          commit_text,
          to_english(commit_text),
          to_english(script_text),
        }
        syllabify_text_list = table_helper.arr_remove_duplication(syllabify_text_list)
        return true, syllabify_text_list
      end
      return false
    end
    syllabify_handlers_add(user_dict_syllabify_handler)
  end
  env.init_ok = true
end

function translator.func(input, seg, env)
  if(env.init_ok~=true) then logger.warn("Fail to init \""..env.name_space.."\" component!", env); return end
  if(not seg:has_tag(env.config_tag)) then return end
  local input_waiting = string.sub(input, seg._start+1, seg._end)
  if(not input_waiting) then logger.warn("input waiting nothing.", input, seg._start, seg._end); return end
  local handler = nil
  if(string.find(input_waiting, "%*")) then
    handler = GessHandler(input_waiting, seg, env)
  else
    handler = EasyHandler(input_waiting, seg, env)
  end
  handler:yield()
end

-- =============================================================== pure_filter

local pure_filter = {}

function pure_filter.init(env)
  local context = env.engine.context
  local func_01 = function(ctx)
    if(ctx:get_option(option_name)) then
      if(not rime_api_helper:get_prompt_map_item("easy_en")) then -- 减少调用 property 次数
        rime_api_helper:add_prompt_map(ctx, "easy_en", "⚙(纯英文~\"Shift\"开/关)")
      end
    else
      if(rime_api_helper:get_prompt_map_item("easy_en")) then
        rime_api_helper:clear_prompt_map(ctx, "easy_en")
      end
    end
  end
  func_01(context)
  env.notifiers = {
    context.option_update_notifier:connect(function(ctx, name)
      if(name == option_name) then
        func_01(ctx)
      end
    end),
  }
end

function pure_filter.fini(env)
  for i, n in pairs(env.notifiers) do
    n:disconnect()
  end
end

local function reflect_cand(text)
  local new_cand = Candidate("raw", 1, #text, text, "〔英文〕")
  return new_cand
end

function pure_filter.func(input, env)
  local context = env.engine.context
  if(context:get_option(option_name)) then
    local first = false
    for cand in input:iter() do
      if(rime_api_helper:is_candidate_in_type(cand, cand_type) or string_helper.is_ascii_visible_string(cand.text)) then
        if(not first) then
          first = true
          local text = context.input
          if(text and #text>0 and text~=cand.text) then
            yield(reflect_cand(text))
          end
        end
        yield(cand)
      end
    end
    if(not first) then
      local text = context.input
      if(text and #text>0) then
        yield(reflect_cand(text))
      end
    end
    return
  end
  -- normal
  for cand in input:iter() do
    yield(cand)
  end
end

function pure_filter.tags_match(seg, env)
  return true
end

return {
  -- ====== 纯英文模式
  pure_filter = pure_filter,
  -- ===== 英文注释
  translator = translator,
}