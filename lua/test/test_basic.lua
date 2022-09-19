assert(lu, "请通过 test/init.lua 运行本测试用例")

local M = {}

function M:test_type() 
  -- nil
  lu.assertEquals(type(nil), "nil")
  -- string
  lu.assertEquals(type("aaaa"), "string")
  -- number
  lu.assertEquals(type(1), "number")
  lu.assertEquals(type(1.1), "number")
  -- table
  lu.assertEquals(type({}), "table")
  lu.assertEquals(type({a=1}), "table")
  -- function
  lu.assertEquals(type(function() print("hello world") end), "function")
end

return M
