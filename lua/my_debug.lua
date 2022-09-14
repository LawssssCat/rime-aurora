
local logger = require("tools/logger")
local rime_api_helper = require("tools/rime_api_helper")

local function format(pattern, cand)
  local info = {
    dynamic_type = cand:get_dynamic_type(),
    type = cand.type,
    _start = cand._start,
    _end = cand._end,
    preedit = cand.preedit,
    quality = string.format("%6.4f", cand.quality)
  }
  local result = pattern
  for key, value in pairs(info) do
    local replace_value = type(value) == "string" and value or tostring(value)
    result = string.gsub(result, "{" .. key .. "}", replace_value or "nil")
  end
  return result
end

local M = {}

function M.init(env)
  env.debug_comment_pattern = "『dt={dynamic_type},t={type}|p={preedit}({_start},{_end})|q={quality}』"
  logger.info("debug filter init ok", rime_api_helper:get_version_info())
end

function M.func(input, env)
  for cand in input:iter() do
    local comment = cand.comment .. format(env.debug_comment_pattern, cand) 
    yield(ShadowCandidate(cand, cand.type, cand.text, comment))
  end
end

function M.fini(env)
end

return M