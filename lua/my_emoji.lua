local logger = require("tools/logger")
local rime_api_helper = require("tools/rime_api_helper")
local string_helper = require("tools/string_helper")

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
-- opencc
-- ----------------------------

local opencc = nil
local function init_opencc()
  opencc = opencc or {
    emoji = Opencc("emoji.json")
  }
end
local function run_opencc_convert_word(text)
  local arr_01 = opencc.emoji:convert_word(text)
  return arr_01
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
      _end = cand._end
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
  "Escape",
  "Select",
  "space"
}
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
  if(mode_opencc) then
    if(not context:has_menu()) then
      reset_mode_opencc(env)
      return rime_api_helper.processor_return_kNoop -- 退出 emoji 处理
    else
      -- 操作
      local repr = key:repr()
      if("Escape" == repr) then
        local index = mode_opencc_previous_cand.index
        reset_mode_opencc(env)
        context:refresh_non_confirmed_composition()
        if(not set_segment_selected_index(env, index)) then
          logger.warn("fail to reset selected_index")
        end
        return rime_api_helper.processor_return_kAccepted
      end
      if(not mode_opencc_allow_keys:include(repr)) then
        return rime_api_helper.processor_return_kAccepted
      else
        return rime_api_helper.processor_return_kNoop
      end
    end
  end
  if("space" == key:repr()) then
    if(context:has_menu()) then
      local cand = context:get_selected_candidate()
      if(cand.type == type_emoji_tip) then
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

-- ----------------
-- filter
-- ----------------

local filter = {}

function filter.init(env)
  init_opencc()
end

function filter.func(input, env)
  if(mode_opencc) then
    local text = mode_opencc_previous_cand.text
    local _start = mode_opencc_previous_cand._start
    local _end = mode_opencc_previous_cand._end
    local arr = uniquifyuniquify(run_opencc_convert_word(text), text)
    for i, t in pairs(arr) do 
      local cand = Candidate(type_emoji_opt, _start, _end, t, "〔"..text.."〕")
      yield(cand)
    end
    return
  end
  for cand in input:iter() do
    yield(cand)
    -- 表情提示
    local text = cand.text
    local arr = uniquifyuniquify(run_opencc_convert_word(text), text)
    if(#arr>0) then
      local cand_tip = UniquifiedCandidate(cand, type_emoji_tip, get_text(text), "["..join(arr, 5).."]")
      yield(cand_tip)
    end
  end
end

-- ========================================= segmentor

local segmentor = {}

function segmentor.func(segmentation, env)
  if(mode_opencc) then
    local input_active = segmentation.input
    local pos_comfirm = segmentation:get_confirmed_position()
    local seg = Segment(pos_comfirm, #input_active)
    seg.tags =  Set({tag_emoji})
    segmentation:add_segment(seg)
  end
  return true
end

return {
  filter = filter,
  processor = processor,
  segmentor = segmentor
}