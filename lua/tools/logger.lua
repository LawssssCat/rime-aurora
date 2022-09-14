--[[
  打印日志（日志文件、控制台）
]]

local null = require("tools/null")
local inspect = require("tools/inspect")
local string_helper = require("tools/string_helper")

local INFO = "info"
local WARN = "warn"
local ERROR = "error"
local TRACE = "trace"

local pattern = "{level} {path}:{line} {method}] {msg}"
-- local pattern = "{level} {time} {path}:{line} {method}] {msg}"

local logger = {} -- return 

local function format(level, ...)
  -- 处理 "..." => msg
  local msg = string_helper.join({null(...)}, ", ")
  -- 处理 栈 信息
  --[[
    文档 https://www.lua.org/manual/5.4/manual.html#pdf-debug.getinfo
    'f': pushes onto the stack the function that is running at the given level;
    'l': fills in the field currentline;
    'n': fills in the fields name and namewhat;
    'r': fills in the fields ftransfer and ntransfer;
    'S': fills in the fields source, short_src, linedefined, lastlinedefined, and what;
    't': fills in the field istailcall;
    'u': fills in the fields nups, nparams, and isvararg;
    'L': pushes onto the stack a table whose indices are the lines on the function with some associated code, that is, the lines where you can put a break point. (Lines with no code include empty lines and comments.) If this option is given together with option 'f', its table is pushed after the function. This is the only option that can raise a memory error.
  ]]
  local info = debug.getinfo(3, "nSl") -- 2 本函数调用者，3 更上一级
  -- 处理 pattern 格式
  local result = pattern
  result = string.gsub(result, "{level}", string.upper(level))
  result = string.gsub(result, "{time}", os.date("%Y%m%d %H:%M:%S"))
  result = string.gsub(result, "{path}", info.short_src:match(".?(lua[\\/].+)$") or info.short_src or "nil")
  result = string.gsub(result, "{method}", info.name or "nil")
  result = string.gsub(result, "{line}", info.currentline)
  result = string.gsub(result, "{msg}", msg)
  return result
end

function logger.info(...)
  local func = log and log.info or print
  local msg = format(INFO, ...)
  func(msg)
end

function logger.warn(...)
  local func = log and log.warning or print
  local msg = format(WARN, ...)
  func(msg)
end

function logger.error(...)
  local func = log and log.error or print
  local msg = format(ERROR, ...)
  func(msg)
end

function logger.trace(...)
  local func = log and log.info or print
  local msg = format(TRACE, ...)
  msg = msg .. "\n" .. debug.traceback("------------- debug.traceback ---------------", 2)
  func(msg)
end

return logger