local logger = require("tools/logger")
local rime_api_helper = require("tools/rime_api_helper")
local string_helper = require("tools/string_helper")
local ptry = require("tools/ptry")

local tag_emoji = "emoji"

local type_emoji_tip = "emoji_tip"
local type_emoji_opt = "emoji_opt"

-- ----------------------------
-- text
-- ----------------------------

local text_suffix = "〔表情〕"
local function get_text(text)
  return text..text_suffix
end
local function reset_text(text)
  local str = string_helper.replace(text, text_suffix, "", true)
  return str
end

-- ----------------------------
-- mode
-- ----------------------------

local mode_opencc = false
local mode_opencc_previous_cand = nil
local function open_mode_opencc(env)
  local context = env.engine.context
  local composition = context.composition
  local segmentation = composition:toSegmentation()
  local segment = nil
  local cand = nil
  if(not segmentation:empty()) then
    segment = segmentation:back()
    cand = segment:get_selected_candidate()
    mode_opencc_previous_cand = {
      index = segment.selected_index,
      text = reset_text(cand.text),
      _start = cand._start,
      _end = cand._end,
      preedit = cand.preedit
    }
    mode_opencc = true
    return
  end
  logger.error(env, composition, segmentation, segment, cand)
  error("error open \"mode_opencc\"")
end
local function reset_mode_opencc(env)
  mode_opencc = false
  mode_opencc_previous_cand = nil
end

local mode_opencc_allow_keys = {
  "Up",
  "Down",
  "Shift+Up",
  "Shift+Down",
  "space"
}
for i=1,9 do -- 数字
  table.insert(mode_opencc_allow_keys, tostring(i))
  table.insert(mode_opencc_allow_keys, "KP_"..tostring(i)) -- 小键盘
end
function mode_opencc_allow_keys:include(repr)
  for i,k in pairs(self) do
    if(k == repr) then
      return true
    end
  end
  return false
end

-- ----------------------------
-- segment
-- ----------------------------

local function get_segment(env) 
  local composition =  env.engine.context.composition
  if(not composition:empty()) then
    local segment = composition:back()
    return true, segment
  end
  return false
end

local function set_segment_selected_index(env, index)
  local flag, segment = get_segment(env)
  if(flag) then
    segment.selected_index = index
    return true
  end
  return false
end

-- ========================================= processor

local processor = {}

function processor.init(env)
  reset_mode_opencc(env)
end

function processor.fini(env)
  reset_mode_opencc(env)
end

function processor.func(key, env)
  local context = env.engine.context
  -- logger.warn(key:repr())
  if(mode_opencc) then
    if(not context:has_menu()) then
      reset_mode_opencc(env)
      return rime_api_helper.processor_return_kNoop -- 退出 emoji 处理
    else
      -- 操作
      local repr = key:repr()
      if("Escape"==repr or "BackSpace"==repr or "Left" == repr) then
        -- 删除
        local index = mode_opencc_previous_cand.index
        reset_mode_opencc(env)
        context:refresh_non_confirmed_composition()
        if(not set_segment_selected_index(env, index)) then
          logger.warn("fail to reset selected_index")
        end
        return rime_api_helper.processor_return_kAccepted
      end
      if("space"==repr) then
        -- 选择
        local composition = context.composition
        if(not composition:empty()) then
          local segment = composition:back()
          local index = segment.selected_index
          context:select(index)
          reset_mode_opencc(env)
          context:refresh_non_confirmed_composition()
        else
          logger.warn("composition empty. \""..context.input.."\"")
        end
        return rime_api_helper.processor_return_kAccepted
      end
      if(not mode_opencc_allow_keys:include(repr)) then
        -- 禁止
        return rime_api_helper.processor_return_kAccepted
      else
        -- 允许
        return rime_api_helper.processor_return_kNoop
      end
    end
  end
  local repr = key:repr()
  local _repr = string_helper.replace(repr, "KP_", "", true) -- fix: KP_ => 小键盘
  -- 通过数字上屏
  if(context:has_menu() and string_helper.is_number(_repr)) then
    local flag, segment = get_segment(env)
    if(flag) then
      local schema = env.engine.schema
      local page_size = schema.page_size
      local num = tonumber(_repr)
      if(num>0 and num<=page_size) then
        local selected_index = segment.selected_index -- 下标0开始
        local page = math.ceil((selected_index+1)/page_size)
        -- 上屏候选词
        local commit_index = (page-1)*page_size + num - 1 -- 下标0开始
        local cand = segment:get_candidate_at(commit_index)
        if(cand) then
          if(rime_api_helper:is_candidate_in_type(cand, type_emoji_tip)) then -- -------------------------- 选择emoji事件
            segment.selected_index = commit_index
            open_mode_opencc(env)
            context:refresh_non_confirmed_composition()
            return rime_api_helper.processor_return_kAccepted
          end
        end
      end
    end
  end
  -- 通过 space 上屏
  if("space" == repr) then
    if(context:has_menu()) then -- ----------------------------------------- 选择emoji事件
      local cand = context:get_selected_candidate()
      if(rime_api_helper:is_candidate_in_type(cand, type_emoji_tip)) then
        open_mode_opencc(env)
        context:refresh_non_confirmed_composition()
        return rime_api_helper.processor_return_kAccepted
      end
    end
  end
  return rime_api_helper.processor_return_kNoop
end

-- ========================================= filter

local function join(arr, max)
  local t = {}
  local flag = false
  for i,v in pairs(arr) do
    if(max and i>max) then
      flag = true
      break
    end
    table.insert(t, v)
  end
  local p = ","
  local r = string_helper.join(t, p)
  if(flag) then
    r = r .. p .. "..."
  end
  return r
end

local function uniquifyuniquify(arr, text)
  local rs = {}
  local map = {}
  for i, v in pairs(arr) do
    if(not map[v] and v~=text) then
      map[v] = true
      table.insert(rs, v)
    end
  end
  return rs
end

-- ----------------------------
-- opencc
-- ----------------------------

local function init_opencc_list(config_name_arr)
  local list = {}
  for i, config_name in pairs(config_name_arr) do
    ptry(function()
      local opencc = Opencc(config_name)
      table.insert(list, opencc)
    end)
    ._catch(function(err)
      logger.error(err, i, config_name, config_name_arr)
    end)
  end
  return list
end
local function run_opencc_list_convert_word(env, text)
  local opencc_list = env.opencc_list
  local result = {}
  for i, opencc_db in pairs(opencc_list) do
    local arr = opencc_db:convert_word(text) or {}
    for i,v in pairs(arr) do
      table.insert(result, v)
    end
  end
  return result
end

-- ----------------
-- filter
-- ----------------

local filter = {}

function filter.init(env)
  local config = env.engine.schema.config
  env.excluded_types = rime_api_helper:get_config_item_value(config, env.name_space .. "/excluded_types") or {}
  local opencc_config = (function()
    local opencc_config = rime_api_helper:get_config_item_value(config, env.name_space .. "/opencc_config")
    if(not opencc_config) then
      opencc_config = {}
    elseif(type(opencc_config) == "string") then
      opencc_config = {opencc_config}
    end
    return opencc_config
  end)()
  env.opencc_list = init_opencc_list(opencc_config)
  
end

function filter.func(input, env)
  if(mode_opencc) then
    local text = mode_opencc_previous_cand.text
    local _start = mode_opencc_previous_cand._start
    local _end = mode_opencc_previous_cand._end
    local arr = uniquifyuniquify(run_opencc_list_convert_word(env, text), text)
    for i, t in pairs(arr) do 
      local cand = Candidate(type_emoji_opt, _start, _end, t, "〔"..text.."〕")
      cand.preedit = mode_opencc_previous_cand.preedit
      yield(cand)
    end
    return
  end
  local excluded_types = env.excluded_types
  for cand in input:iter() do
    yield(cand)
    if(not rime_api_helper:is_candidate_in_types(cand, excluded_types)) then
      -- 表情提示
      local text = cand.text
      local arr = uniquifyuniquify(run_opencc_list_convert_word(env, text), text)
      if(#arr>0) then
        local cand_tip = UniquifiedCandidate(cand, type_emoji_tip, get_text(text), "["..join(arr, 5).."]")
        yield(cand_tip)
      end
    end
  end
end

-- ========================================= segmentor

local segmentor = {}

function segmentor.func(segmentation, env)
  local context = env.engine.context
  if(mode_opencc) then
    local _start = mode_opencc_previous_cand._start
    local _end = mode_opencc_previous_cand._end
    local seg = Segment(_start, _end)
    seg.tags =  Set({tag_emoji})
    segmentation:add_segment(seg)
  end
  if(mode_opencc) then
    if(not rime_api_helper:get_prompt_map_item("emoji")) then -- 减少调用 property 次数
      rime_api_helper:add_prompt_map(context, "emoji", "⚙(表情~\"Esc\"退出)")
    end
  else
    if(rime_api_helper:get_prompt_map_item("emoji")) then -- 减少调用 property 次数
      rime_api_helper:clear_prompt_map(context, "emoji")
    end
  end
  return true
end

return {
  filter = filter,
  processor = processor,
  segmentor = segmentor
}