assert(lu, "请通过 test/init.lua 运行本测试用例")

local ArrayList = require("tools/collection/array_list")

local M = {}

function M:test_size() 
  local list = ArrayList()
  lu.assertEquals(list.size, 0)
  lu.assertEquals(list:Size(), 0)
  lu.assertEquals(list:values(), {})

  -- 
  local list_2 = ArrayList({1,2,3})
  lu.assertEquals(list_2:Size(), 3)
  lu.assertEquals(list_2:values(), {1,2,3})
  -- 
  local list_3 = ArrayList(list_2)
  lu.assertEquals(list_3:Size(), 3)
  lu.assertEquals(list_3:values(), {1,2,3})
  list_3:add("world")
  lu.assertEquals(list_3:Size(), 4)
  lu.assertEquals(list_3:values(), {1,2,3, "world"})
end

function M:test_index_of()
  local list = ArrayList({1,2, "hello",3})
  list:add_at(1, "hello")
  lu.assertEquals(list:values(), {"hello", 1,2, "hello",3})
  list:add("world")
  lu.assertEquals(list:values(), {"hello", 1,2, "hello",3, "world"})
  list:add_at(1, "aa")
  lu.assertEquals(list:values(), {"aa", "hello", 1,2, "hello",3, "world"})
  list:add("hello")
  lu.assertEquals(list:values(), {"aa", "hello",1,2, "hello",3, "world", "hello"})
  lu.assertEquals(list:index_of("hello"), 2)
end

function M:test_add()
  local list = ArrayList({1,2,3})
  list:add_at(1, "hello")
  list:add("world")
  lu.assertEquals(list:Size(), 5)
  lu.assertEquals(list:values(), {"hello", 1,2,3, "world"})
end

function M:test_remove()
  local list = ArrayList({1,2,3})
  list:add_at(1, "hello")
  list:add("world")
  lu.assertEquals(list:Size(), 5)
  lu.assertEquals(list:values(), {"hello", 1,2,3, "world"})
  list:remove()
  lu.assertEquals(list:values(), {"hello", 1,2,3})
  list:remove_at(1)
  lu.assertEquals(list:values(), {1,2,3})
  list:remove_at(2)
  lu.assertEquals(list:values(), {1,3})
  lu.assertEquals(list:Size(), 2)
end

function M:test_get_at()
  local list = ArrayList({1,2,3})
  list:add_at(1, "hello")
  list:add("world")
  lu.assertEquals(list:Size(), 5)
  lu.assertEquals(list:values(), {"hello", 1,2,3, "world"})
  lu.assertEquals(list:get_at(1), "hello")
  lu.assertEquals(list:get_at(2), 1)
  lu.assertEquals(list:get_at(3), 2)
  lu.assertEquals(list:get_at(list:Size()), "world")
end

return M
