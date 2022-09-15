--[[
  测试 lua 异常处理
]]

assert(lu, "请通过 test/init.lua 运行本测试用例")

local M = {}

function M:test_error()
  lu.assertError(function() 
    error("异常抛出 ！！！！")
  end)
end

function M:test_pcall_ok() -- 无异常
  local a1, a2, a3
  local pcall_result = {pcall(function(arg1, arg2, arg3) 
    a1 = arg1
    a2 = arg2
    a3 = arg3
    return "good", "job"
  end, "hello", "world")}
  lu.assertEquals(a1, "hello")
  lu.assertEquals(a2, "world")
  lu.assertEquals(a3, nil)
  lu.assertEquals(pcall_result[1], true)
  lu.assertEquals(pcall_result[2], "good")
  lu.assertEquals(pcall_result[3], "job")
  lu.assertEquals(pcall_result[4], nil)
end

function M:test_pcall_error() -- 异常
  local a1, a2, a3
  local pcall_result = {pcall(function(arg1, arg2, arg3) 
    a1 = arg1
    a2 = arg2
    a3 = arg3
    error("error throw !")
    return "good", "job"
  end, "hello", "world")}
  lu.assertEquals(a1, "hello")
  lu.assertEquals(a2, "world")
  lu.assertEquals(a3, nil)
  lu.assertEquals(pcall_result[1], false)
  lu.assertStrContains(pcall_result[2], "error throw !$", true) -- e.g. ".\test/test_error.lua:38: error throw !"
  lu.assertEquals(pcall_result[3], nil)
  lu.assertEquals(pcall_result[4], nil)
end

return M