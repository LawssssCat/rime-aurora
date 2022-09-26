assert(lu, "请通过 test/init.lua 运行本测试用例")

local CycleList = require("tools/collection/cycle_list")

local M = {}

function M:test_add()
  local list = CycleList(2)
  list:add({1,2,3})
  list:add(22)
  list:add("aaa")
  list:add("hello")
  list:add_at(1,"bbbbb")
  list:add("world")
  lu.assertEquals(tostring(list), '["hello","world"]')
end

function M:test_tostring()
  local list = CycleList(2)
  list:add_all({1,2,3})
  lu.assertEquals(tostring(list), "[2,3]")
end

return M
