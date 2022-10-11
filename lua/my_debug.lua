
local logger = require("tools/logger")
local rime_api_helper = require("tools/rime_api_helper")
local string_helper = require("tools/string_helper")

-- ============================================================= processor

-- ----------------
-- methods
-- ----------------

local function is_option_open(env)
  local context = env.engine.context
  local option = context:get_option("option_debug_comment_filter") or false -- 开关
  return option
end

local function get_segment(env)
  local context = env.engine.context
  local composition =  context.composition
  if(not composition:empty()) then
    -- 获得 Segment 对象
    local segment = composition:back()
    return segment
  end
  return nil
end

-- 时间 信息
local time_start = nil
local function set_time_start()
  time_start = os.clock()
end
local function get_time_duration()
  local time_end = os.clock()
  local duration = time_end - time_start
  return duration -- 毫秒
end

-- 标签 信息
local function get_msg_tags(env)
  local segment = get_segment(env)
  if(segment) then
    local tags = segment.tags
    if(tags) then
      local tag_arr = {}
      for tag, _ in pairs(tags) do
        table.insert(tag_arr, tag)
      end
      local msg = string.format("🏷:(%s)", string_helper.join(tag_arr, ","))
      return true, msg
    end
  end
  return false
end

-- 页码 信息
local function get_msg_page(env)
  local schema = env.engine.schema
  local segment = get_segment(env)
  if(segment) then
    local page_size = schema.page_size
    -- 获得选中的候选词下标
    local count_select = (segment.selected_index or 0) + 1
    local page_select = math.ceil(count_select/page_size)
    -- 获取 Menu 对象
    local menu = segment.menu
    -- 获得（已加载）候选词数量
    local count_loaded = menu and menu:candidate_count() or 0
    local page_loaded = math.ceil(count_loaded/page_size)
    local msg = string.format("📖:[%s/%s]📚:[%s/%s]", 
      count_select, count_loaded,
      page_select, page_loaded)
    return true, msg
  end
  return false
end

-- ----------------
-- processor
-- ----------------

local processor = {}

local function add_prompts(prompts, msg_error, flag, msg)
  if(flag) then
    table.insert(prompts, msg)
  else
    logger.warn(msg_error)
  end
end

function processor.func(key, env)
  local context = env.engine.context
  if(not is_option_open(env)) then
    if(key:release() and rime_api_helper:get_prompt_map_item("debug")) then
      rime_api_helper:clear_prompt_map(context, "debug")
    end
    return rime_api_helper.processor_return_kNoop
  end
  set_time_start() -- 计时开始 ⏳
  if(context:is_composing()) then
    local prompts = {}
    -- 标签
    add_prompts(prompts, "fail to get \"tags\" info.", get_msg_tags(env))
    -- 页码
    add_prompts(prompts, "fail to get \"page\" info.", get_msg_page(env))
    -- 添加
    rime_api_helper:add_prompt_map(context, "debug", string_helper.join(prompts, " "))
  end
  return rime_api_helper.processor_return_kNoop
end

-- ============================================================= filter

local filter = {}

function filter.init(env)
  local config = env.engine.schema.config
  env.debug_comment_pattern = "『{dynamic_type}:{type}|🏆{quality}』" -- 当 weasel 为前端时，内容过长（或者换行）可能导致闪退（同时关闭父应用...）。 issue https://github.com/rime/home/issues/1129
  -- 获取排除类型
  env.excluded_types = (function()
    local types = rime_api_helper:get_config_item_value(config, env.name_space .. "/excluded_types")
    if(not types) then
      types = {}
    elseif(type(types) == "string") then
      types = {types}
    end
    function types:include(text)
      for i,t in pairs(self) do
        if(text == t) then
          return true
        end
      end
      return false
    end
    return types
  end)()
end

function filter.func(input, env)
  local context = env.engine.context
  if not is_option_open(env) then
    if(rime_api_helper:get_prompt_map_item("duration")) then
      rime_api_helper:clear_prompt_map(context, "duration")
    end
    for cand in input:iter() do
      yield(cand)
    end
    return
  end
  -- 时间间隔 processor => filter
  rime_api_helper:add_prompt_map(context, "duration", string.format("⏱️:%0.4fs", get_time_duration())) -- 计时结束 ⏳
  for cand in input:iter() do
    if(env.excluded_types:include(cand.type)) then
      yield(cand)
    else
      -- 整理 info
      local info = {
        dynamic_type = cand:get_dynamic_type(),
        type = cand.type,
        _start = cand._start,
        _end = cand._end,
        preedit = cand.preedit,
        quality = string.format("%6.4f", cand.quality),
      }
      local comment = cand.comment .. string_helper.format(env.debug_comment_pattern, info)
      yield(ShadowCandidate(cand, cand.type, cand.text, comment))
    end
  end
end

return {
  filter=filter,
  processor=processor,
}