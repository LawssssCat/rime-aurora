--[[
  打印日志（日志文件、控制台）
]]

local null = require("tools/null")
local inspect = require("tools/inspect")
local string_helper = require("tools/string_helper")
local ptry = require("tools/ptry")

-- 日志格式模版
local pattern = "{level} [{depth}] {path}:{line} {method}] {msg}"

local logger = {} -- return 

-- 日志等级
logger.INFO = "info"
logger.WARN = "warn"
logger.ERROR = "error"

-- 日志输出格式化
local function format(log_level, debug_level, ...)
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
  debug_level = debug_level + 1
  local info = debug.getinfo(debug_level, "nSl")
  -- 处理 pattern 格式
  local result = pattern
  ptry(function()
    result = string_helper.replace(result, "{level}", string.upper(log_level))
    result = string_helper.replace(result, "{depth}", debug_level)
    result = string_helper.replace(result, "{time}", os.date("%Y%m%d %H:%M:%S"))
    result = string_helper.replace(result, "{path}", info.short_src:match(".?(lua[\\/].+)$") or info.short_src or "nil")
    result = string_helper.replace(result, "{method}", info.name or "nil")
    result = string_helper.replace(result, "{line}", info.currentline)
    result = string_helper.replace(result, "{msg}", msg)
  end)
  ._catch(function(err)
    error(inspect({
      err=err,
      log_level=log_level,
      debug_level=debug_level,
      stack_info=info,
      args=msg,
      result=result
    }))
  end)
  return result
end

-- 日志输出方法选择
local function _get_log_func(level)
  return log and log[level] or print
end
local function get_log_func(level)
  local func = nil
  if(level == logger.INFO) then func = _get_log_func("info")
  elseif(level == logger.WARN) then func = _get_log_func("warning")
  elseif(level == logger.ERROR) then func = _get_log_func("error")
  else -- level传递错误。
    error("strange log level: \"" .. tostring(level) .. "\"")
  end
  return func
end

--[[
  @param debug_level: 2 本函数调用者，3 更上一级
]] 
local function _print(log_level, debug_level, ...)
  local func = get_log_func(log_level)
  local msg = format(log_level, debug_level+1, ...)
  func(msg)
  return msg
end

--[[

  注意⚠️：

  下面 logger.info、logger.warn、...
  应该
  ```lua
    local result = _print()
    return result
  ```
  不应该改为 `return _print()`

  ⚡因为会影响函数上下文！⚡
  ⚡因为会影响函数上下文！⚡
  ⚡因为会影响函数上下文！⚡

  因为前者（正常）
  ```txt
  stack traceback:
    [C]: in function 'debug.traceback'
    .\tools/logger.lua:56: in upvalue 'format'
    .\tools/logger.lua:79: in upvalue '_print'
    .\tools/logger.lua:120: in function 'tools/logger.error'
    .\test/test_logger.lua:8: in function <.\test/test_logger.lua:7>
  ```
  而后者调用栈出现 “(...tail calls...)” 导致调用 debug.getinfo 时候少了一层（原因？）
  ```txt
  stack traceback:
    [C]: in function 'debug.traceback'
    .\tools/logger.lua:56: in upvalue 'format'
    .\tools/logger.lua:79: in function <.\tools/logger.lua:77>
    (...tail calls...)
    .\test/test_logger.lua:8: in function <.\test/test_logger.lua:7>
  ```
]]

function logger.info(...)
  local result = _print(logger.INFO, 2, ...)
  return result
end

function logger.warn(...)
  local result = _print(logger.WARN, 2, ...)
  return result
end

function logger.error(...)
  local result = _print(logger.ERROR, 2, ...)
  return result
end

--[[
  @param log_level:
  - logger.INFO
  - logger.WARN
  - logger.ERROR
]] 
function logger.trace(log_level, ...)
  local debug_level = 2 -- 2 => 函数调用者的栈
  local trace_info = debug.traceback("------------- debug.traceback ---------------", debug_level)
  local args = {...}
  table.insert(args, "\n" .. trace_info)
  local result = _print(log_level, debug_level, table.unpack(args))
  return result
end

return logger