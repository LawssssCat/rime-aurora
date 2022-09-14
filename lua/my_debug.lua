
local logger = require("tools/logger")
local rime_api_helper = require("tools/rime_api_helper")
local string_helper = require("tools/string_helper")

local inputMap = nil -- 保存来自translator的tags
local function resetInputMap() -- 初始化/清空
  inputMap = {}
end
resetInputMap()

local function format(pattern, cand)
  local tags = nil
  if(inputMap and cand.preedit) then
    local input = string.gsub(cand.preedit, "%s", "")
    tags = string_helper.join(inputMap[input], ",")
  end
  local info = {
    dynamic_type = cand:get_dynamic_type(),
    type = cand.type,
    _start = cand._start,
    _end = cand._end,
    preedit = cand.preedit,
    quality = string.format("%6.4f", cand.quality),
    tags = tags
  }
  local result = pattern
  for key, value in pairs(info) do
    local replace_value = type(value) == "string" and value or tostring(value)
    result = string.gsub(result, "{" .. key .. "}", replace_value or "nil")
  end
  return result
end

-- ===================================================================================================================

local processor = {}

local kRejected = 0
local kAccepted = 1
local kNoop = 2

function processor.func(key, env) 
  local ctx = env.engine.context
  if(not ctx:has_menu()) then -- 没有候选词时清空缓存
    resetInputMap()
  end
  return kNoop
end

-- ===================================================================================================================

local translator = {}

function translator.func(input, seg, env)
  local inputItem = {}
  for key,value in pairs(seg.tags) do
    table.insert(inputItem, key)
  end
  inputMap[input] = inputItem
end

-- ===================================================================================================================

local filter = {}

function filter.init(env)
  env.debug_comment_pattern = "『dt={dynamic_type},t={type}|ts=[{tags}]|p={preedit}({_start},{_end})|q={quality}』"
  logger.info("debug filter init ok", rime_api_helper:get_version_info())
end

function filter.func(input, env)
  local option = env.engine.context:get_option("option_debug_comment_filter") -- 开关
  if option then
    for cand in input:iter() do
      local comment = cand.comment .. format(env.debug_comment_pattern, cand)
      yield(ShadowCandidate(cand, cand.type, cand.text, comment))
    end
  else
    for cand in input:iter() do
      yield(cand)
    end
  end
end

function filter.fini(env)
end

return {
  processor=processor,
  filter=filter,
  translator=translator
}