assert(lu, "请通过 test/init.lua 运行本测试用例")

local M = {}

-- 打印函数栈
function M:test_trace() 
  print(debug.traceback("------------- debug.traceback ---------------", 2))
end

-- 
function M:test_info()
  local info = debug.getinfo(1)
  print(info.short_src:match(".?(lua[\\/].+)$"))
  print(info.short_src)
  print(info.name)
  print(info.currentline)
end

return M
