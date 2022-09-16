assert(lu, "请通过 test/init.lua 运行本测试用例")

local M = {}

-- 打印函数栈
function M:test_trace() 
  print(debug.traceback("------------- debug.traceback ---------------", 2))
end

local function print_debug_all()
  local info = debug.getinfo(1) -- 0 getinfo, 1 print_debug_all
  -- n
  print(info.name)
  print(info.namewhat)
  -- S  
  print(info.source)
  print(info.short_src)
  print(info.linedefined)
  print(info.lastlinedefined)
  print(info.what)
  -- l
  print(info.currentline)
  -- t
  print(info.istailcall)
  -- u
  print(info.nups)
  print(info.nparams)
  print(info.isvararg)
  -- f
  -- L
end

function M:test_info()
  print_debug_all()
end

return M
