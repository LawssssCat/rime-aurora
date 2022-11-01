assert(lu, "请通过 test/init.lua 运行本测试用例")

local M = {}

function M:test_define()
  local a = nil
  local b = (function() a=1 end)()
  lu.assertEquals(b, nil)
  local b = (function() a=1; return a end)()
  lu.assertEquals(b, 1)
end

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

function M:test_for()
  local temp = {}
  for i = 0, 2 do
    table.insert(temp, i)
  end
  lu.assertEquals(temp, {0, 1, 2})
  --
  local temp1 = {}
  for i = 3, 2 do
    table.insert(temp1, i)
  end
  lu.assertEquals(temp1, {})
end

return M
