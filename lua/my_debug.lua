
local logger = require("tools/logger")
local rime_api_helper = require("tools/rime_api_helper")
local string_helper = require("tools/string_helper")

local mode_debug = false -- 调试时候打开

local inputMap = nil -- 保存来自translator的tags
local function resetInputMap() -- 初始化/清空
  if(inputMap) then
    for key, value in pairs(inputMap) do
      inputMap[key] = nil -- 直接清除引用
    end
  end
  inputMap = {}
end
resetInputMap() -- 初始化

local function format(pattern, cand)
  -- 处理 tags
  local tags = nil
  if(inputMap and cand.preedit) then
    local input = string.gsub(cand.preedit, "%s+", "")
    tags = string_helper.join(inputMap[input], ",")
  end
  if(mode_debug) 
  then
    logger.warn(cand.preedit, inputMap)
  end
  -- 整理 info
  local info = {
    dynamic_type = cand:get_dynamic_type(),
    type = cand.type,
    _start = cand._start,
    _end = cand._end,
    preedit = cand.preedit,
    quality = string.format("%6.4f", cand.quality),
    tags = tags
  }
  -- 生成 comment
  local result = pattern
  for key, value in pairs(info) do
    local replace_value = type(value) == "string" and value or tostring(value)
    result = string_helper.replace(result, "{" .. key .. "}", replace_value or "nil")
  end
  return result
end

-- =================================================================================================================== processor

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

-- =================================================================================================================== translator

local translator = {}

function translator.init(env)
  local config = env.engine.schema.config
  -- 搜索转换规则
  local format_list = {}
  local preeidt_format = rime_api_helper:get_config_list(config, "translator/preedit_format")
  if(preeidt_format) then
    for index, value in pairs(preeidt_format) do
      -- 分析格式，转换成lua能调用的格式
      if(string.match(value, "^xform")) then
        local pattern = value
        pattern = string.gsub(pattern, "%s+", "/") -- "xform a[&] ā" => "xform/a[&]/ā"
        pattern = string.gsub(pattern, "/$", "") -- "xform/([nl])v/$1ü/" => "xform/([nl])v/$1ü"
        local split = string_helper.split(pattern, "/") -- "xform/([nl])v/$1ü" => { "xform", "([nl])v", "$1ü" }
        local pcall_flag, pcall_error = pcall(function() 
          table.insert(format_list, {
            pattern=split[2],
            replace=string.gsub(split[3], "%$", "%%")
          })
        end)
        if(pcall_flag == false) then -- 异常处理
          logger.error(pcall_error, value, split)
        end
      end
    end -- for
  end
  env.preeidt_format_list = format_list -- 存储转换规则
end

function translator.func(input, seg, env)
  -- 处理 key
  local inputKey = input
  if(env.preeidt_format_list) then
    if(mode_debug) 
    then
      logger.warn(env.preeidt_format_list)
    end
    for index, format in pairs(env.preeidt_format_list) do
      inputKey = string.gsub(inputKey, format.pattern, format.replace)
    end
  end
  -- 处理 value
  local inputItem = {}
  for key,value in pairs(seg.tags) do
    table.insert(inputItem, key)
  end
  -- 存储 key value
  inputMap[inputKey] = inputItem
end

-- =================================================================================================================== filter

local filter = {}

function filter.init(env)
  env.debug_comment_pattern = "『{dynamic_type}:{type}|🏷{tags}|🏆{quality}』" -- 当 weasel 为前端时，内容过长（或者换行）可能导致闪退（同时关闭父应用...）。 issue https://github.com/rime/home/issues/1129
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