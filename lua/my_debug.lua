
local logger = require("tools/logger")
local rime_api_helper = require("tools/rime_api_helper")
local string_helper = require("tools/string_helper")

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

function filter.tags_match(seg, env)
  local tags = seg and seg.tags

  if(tags) then
    local tag_arr = {}
    for tag, _ in pairs(tags) do
      table.insert(tag_arr, tag)
    end
    local prompt_ext = string_helper.format("🏷({tags})", {
      tags = string_helper.join(tag_arr, ",")
    })
    seg.prompt = seg.prompt .. " " .. prompt_ext
  end
  return true
end

function filter.fini(env)
end

return {
  filter=filter,
}