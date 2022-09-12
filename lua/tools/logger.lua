--[[
  打印日志（日志文件、控制台）
]]

local string_helper = require("tools/string_helper")

local INFO = "info"
local WARN = "warn"
local ERROR = "error"
local TRACE = "trace"

local pattern = "{level} {time} {path}:{line} {method}] {msg}"

local MODE_DEBUG_ON = 1
local MODE_DEBUG_OFF = 0
MODE_DEBUG = MODE_DEBUG or MODE_DEBUG_ON

local logger = {} -- return 

-- 调试模式 判断
function logger.isDebug()
  return MODE_DEBUG_ON == MODE_DEBUG
end
-- 调试模式 开
function logger.setDebugOn()
  MODE_DEBUG = MODE_DEBUG_ON
end
-- 调式模式 关
function logger.setDebugOff()
  MODE_DEBUG = MODE_DEBUG_OFF
end

local function format(level, info, ...)
  local arr = {...}
  local msg = string_helper.join(arr, ", ")
  local result = pattern
  result = string.gsub(result, "{level}", string.upper(level))
  result = string.gsub(result, "{time}", os.date("%Y%m%d %H:%M:%S"))
  result = string.gsub(result, "{path}", info.short_src)
  result = string.gsub(result, "{method}", info.name)
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