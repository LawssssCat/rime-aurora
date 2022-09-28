assert(lu, "请通过 test/init.lua 运行本测试用例")

local Stack = require("tools/collection/stack")

local M = {}

function M:test_1()
  local stack = Stack()
  stack:push("!")
  stack:push("world")
  stack:push("hello")
  lu.assertEquals(stack:Size(), 3)
  local t = {}
  while(stack:Size() > 0) do
    table.insert(t, stack:pop())
  end
  lu.assertEquals(stack:Size(), 0)
  lu.assertEquals(t, {"hello", "world", "!"})
end

function M:test_1()
  local stack = Stack()
  local num = 100000
  for i=1, num do
    stack:push(i)
  end
  lu.assertEquals(stack:Size(), num)
  while(stack:Size() > 0) do
    lu.assertEquals(stack:peek(), stack:Size())
    lu.assertEquals(stack:pop(), stack:Size()+1)
  end
  lu.assertEquals(stack:Size(), 0)
  lu.assertEquals(stack:peek(), nil)
end

return M
