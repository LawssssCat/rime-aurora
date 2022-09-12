--[[
  打印日志（日志文件、控制台）
]]

local inspect = require("tools/inspect")
local string_helper = require("tools/string_helper")

local INFO = "info"
local WARN = "warn"
local ERROR = "error"
local TRACE = "trace"

local pattern = "{level} {path}:{line} {method}] {msg}"
-- local pattern = "{level} {time} {path}:{line} {method}] {msg}"

local logger = {} -- return 

local function format(level, info, ...)
  local arr = {}
  for k,v in pairs({...}) do
    table.insert(arr, inspect(v))
  end
  local msg = string_helper.join(arr, ", ")
  local result = pattern
  result = string.gsub(result, "{level}", string.upper(level))
  result = string.gsub(result, "{time}", os.date("%Y%m%d %H:%M:%S"))
  result = string.gsub(result, "{path}", info.short_src:match(".?(lua[\\/].+)$"))
  if(info.name) then
    result = string.gsub(result, "{method}", info.name)
  else
    result = string.gsub(result, "%s*{method}", "") -- 管理前分割符
  end
  result = string.gsub(result, "{line}", info.currentline)
  result = string.gsub(result, "{msg}", msg)
  return result
end

function logger.info(...)
  local func = log and log.info or print
  local msg = format(INFO, debug.getinfo(2), ...)
  func(msg)
end

function logger.warn(...)
  local func = log and log.warn or print
  local msg = format(WARN, debug.getinfo(2), ...)
  func(msg)
end

function logger.error(...)
  local func = log and log.error or print
  local msg = format(ERROR, debug.getinfo(2), ...)
  func(msg)
end

function logger.trace(...)
  local func = log and log.info or print
  local msg = format(TRACE, debug.getinfo(2), ...)
  msg = msg .. "\n" .. debug.traceback("------------- debug.traceback ---------------", 2)
  func(msg)
end

return logger