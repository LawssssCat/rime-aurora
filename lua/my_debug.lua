
local logger = require("tools/logger")
local rime_api_helper = require("tools/rime_api_helper")
local string_helper = require("tools/string_helper")
local ptry = require("tools/ptry")

-- ============================================================= processor

local processor = {}

function processor.func(key, env)
  local schema = env.engine.schema
  local context = env.engine.context
  local composition =  context.composition
  if(not composition:empty()) then
    -- 获得 Segment 对象
    local segment = composition:back()
    local prompts = {}
    -- 标签
    ptry(function()
      local tags = segment.tags
      if(tags) then
        local tag_arr = {}
        for tag, _ in pairs(tags) do
          table.insert(tag_arr, tag)
        end
        local msg = string.format("🏷:(%s)", string_helper.join(tag_arr, ","))
        table.insert(prompts, msg)
      end
    end)
    ._catch(function(err)
      logger.error(err)
    end)
    -- 页码
    ptry(function()
      local page_size = schema.page_size
      -- 获取 Menu 对象
      local menu = segment.menu
      -- 获得选中的候选词下标
      local count_select = segment.selected_index or 0
      local page_select = count_select/page_size
      -- 获得（已加载）候选词数量
      local count_loaded = menu and menu:candidate_count() or 0
      local page_loaded = count_loaded/page_size
      local msg = string.format("📖:[%s/%s]📚:[%0.0f/%0.0f]", 
        count_select, count_loaded,
        page_select, page_loaded)
      table.insert(prompts, msg)
    end)
    ._catch(function(err)
      logger.error(err)
    end)
    rime_api_helper:add_prompt_map("debug", string_helper.join(prompts, " "))
    local prompt_map = rime_api_helper:get_prompt_map()
    -- 修改 prompt
    local prompt_arr = {}
    for key, msg in pairs(prompt_map) do
      table.insert(prompt_arr, msg)
    end
    segment.prompt = table.concat(prompt_arr, " ")
    rime_api_helper:clear_prompt_map()
  end
  return rime_api_helper.processor_return_kNoop
end

-- ============================================================= filter

local filter = {}

function filter.init(env)
  env.debug_comment_pattern = "『{dynamic_type}:{type}|🏆{quality}』" -- 当 weasel 为前端时，内容过长（或者换行）可能导致闪退（同时关闭父应用...）。 issue https://github.com/rime/home/issues/1129
end

local function show_candidate_info(input, env)
  for cand in input:iter() do
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

function filter.func(input, env)
  local option = env.engine.context:get_option("option_debug_comment_filter") -- 开关
  if option then
    show_candidate_info(input, env)
  else
    for cand in input:iter() do
      yield(cand)
    end
  end
end

return {
  filter=filter,
  processor=processor,
  add_prompt_msg = add_prompt_msg
}