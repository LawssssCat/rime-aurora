
local logger = require("tools/logger")
local rime_api_helper = require("tools/rime_api_helper")
local string_helper = require("tools/string_helper")

local function format(pattern, info)
  -- 生成 comment
  local result = pattern
  for key, value in pairs(info) do
    local replace_value = type(value) == "string" and value or tostring(value)
    result = string_helper.replace(result, "{" .. key .. "}", replace_value or "nil")
  end
  return result
end

local filter = {}

function filter.init(env)
  env.debug_comment_pattern = "『{dynamic_type}:{type}|🏆{quality}』" -- 当 weasel 为前端时，内容过长（或者换行）可能导致闪退（同时关闭父应用...）。 issue https://github.com/rime/home/issues/1129
  logger.info("debug filter init ok", rime_api_helper:get_version_info())
end

function filter.func(input, env)
  local option = env.engine.context:get_option("option_debug_comment_filter") -- 开关
  if option then
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
      local comment = cand.comment .. format(env.debug_comment_pattern, info)
      yield(ShadowCandidate(cand, cand.type, cand.text, comment))
    end
  else
    for cand in input:iter() do
      yield(cand)
    end
  end
end

function filter.tags_match(seg, env)
  local tag_arr = {}
  for tag, _ in pairs(seg.tags) do
    table.insert(tag_arr, tag)
  end
  local prompt_ext = format("🏷({tags})", {
    tags = string_helper.join(tag_arr, ",")
  })
  seg.prompt = seg.prompt .. " " .. prompt_ext
  return true
end

function filter.fini(env)
end

return {
  filter=filter,
}