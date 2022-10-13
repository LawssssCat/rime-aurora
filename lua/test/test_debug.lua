assert(lu, "请通过 test/init.lua 运行本测试用例")

local M = {}

-- 打印函数栈
function M:test_trace() 
  local title = "------------- debug.traceback ---------------"
  local trace_info = debug.traceback(title, 1)
  local pattern = string.format([[------------- debug.traceback ---------------
stack traceback:
.*test_debug.*test_trace.*
.*luaunit]])
  lu.assertStrContains(trace_info, pattern, true)
--[[
e.g.
------------- debug.traceback ---------------
stack traceback:
    .\test/test_debug.lua:8: in function 'test/test_debug.test_trace'
    .\tools/luaunit.lua:1899: in function <.\tools/luaunit.lua:1899>
    [C]: in function 'xpcall'
    .\tools/luaunit.lua:1899: in method 'protectedCall'
    .\tools/luaunit.lua:1967: in method 'execOneFunction'
    .\tools/luaunit.lua:2062: in method 'runSuiteByInstances'
    .\tools/luaunit.lua:2122: in method 'runSuiteByNames'
    .\tools/luaunit.lua:2185: in method 'runSuite'
    test/init.lua:74: in main chunk
    [C]: in ?
]]  
end

local function print_debug_all()
  local info = debug.getinfo(1) -- 0 getinfo, 1 print_debug_all
  -- n
  lu.assertEquals(info.name, "print_debug_all")
  lu.assertEquals(info.namewhat, "upvalue")
  -- S  
  lu.assertStrContains(info.source, "test_debug.lua")
  lu.assertStrContains(info.short_src, "test_debug.lua")
  lu.assertStrContains(info.linedefined, "%d", true) -- "print_debug_all" function define start line
  lu.assertStrContains(info.lastlinedefined, "%d", true) -- "print_debug_all" function define end line
  lu.assertEquals(info.what, "Lua")
  -- l
  lu.assertStrContains(info.currentline, "%d", true) -- "local info = ..." line number
  -- t
  lu.assertFalse(info.istailcall)
  -- u
  lu.assertEquals(info.nups, 1)
  lu.assertEquals(info.nparams, 0)
  lu.assertFalse(info.isvararg)
  -- f
  -- L
end

function M:test_info()
  print_debug_all()
end

return M
