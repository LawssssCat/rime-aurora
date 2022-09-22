assert(lu, "请通过 test/init.lua 运行本测试用例")

local LinkedList = require("tools/collection/linked_list")

local M = {}

function M:test_size() 
  local list = LinkedList()
  lu.assertEquals(list.size, 0)
  lu.assertEquals(list:Size(), 0)
  lu.assertEquals(list:values(), {})

  -- 
  local list_2 = LinkedList({1,2,3})
  lu.assertEquals(list_2:Size(), 3)
  lu.assertEquals(list_2:values(), {1,2,3})
  -- 
  local list_3 = LinkedList(list_2)
  lu.assertEquals(list_3:Size(), 3)
  lu.assertEquals(list_3:values(), {1,2,3})
  list_3:add("world")
  lu.assertEquals(list_3:Size(), 4)
  lu.assertEquals(list_3:values(), {1,2,3, "world"})
end

function M:test_index_of()
  local list = LinkedList({1,2, "hello",3})
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
  local list = LinkedList({1,2,3})
  list:add_at(1, "hello")
  lu.assertEquals(list:values(), {"hello", 1,2,3})
  list:add("world")
  lu.assertEquals(list:Size(), 5)
  lu.assertEquals(list:values(), {"hello", 1,2,3, "world"})
  local has_szie = 5
  local num = 1000 -- 对比 array list
  for i=1,num do
    list:add(i)
  end
  lu.assertEquals(list:Size(), num+has_szie)
  for i=1,num do
    list:add_at(i, i)
  end
  lu.assertEquals(list:Size(), num +num+has_szie)
end

function M:test_remove()
  local list = LinkedList({1,2,3})
  list:add_at(1, "hello")
  list:add("world")
  lu.assertEquals(list:Size(), 5)
  lu.assertEquals(list:values(), {"hello", 1,2,3, "world"})
  list:remove()
  lu.assertEquals(list:Size(), 4)
  lu.assertEquals(list:values(), {"hello", 1,2,3})
  list:remove_at(1)
  lu.assertEquals(list:Size(), 3)
  lu.assertEquals(list:values(), {1,2,3})
  list:remove_at(2)
  lu.assertEquals(list:values(), {1,3})
  lu.assertEquals(list:Size(), 2)
  list:remove()
  lu.assertEquals(list:Size(), 1)
  list:remove()
  lu.assertEquals(list:Size(), 0)
  lu.assertErrorMsgMatches(".*out of range:.*", list.remove, list)
end

function M:test_get_at()
  local list = LinkedList({1,2,3})
  list:add_at(1, "hello")
  list:add("world")
  lu.assertEquals(list:Size(), 5)
  lu.assertEquals(list:values(), {"hello", 1,2,3, "world"})
  lu.assertEquals(list:get_at(1), "hello")
  lu.assertEquals(list:get_at(2), 1)
  lu.assertEquals(list:get_at(3), 2)
  lu.assertEquals(list:get_at(list:Size()), "world")
end

function M:test_iter()
  local list = LinkedList({1,2,3})
  list:add_at(2, "hello")
  list:add("world")
  lu.assertEquals(list:Size(), 5)
  lu.assertEquals(list:values(), { 1,"hello",2,3, "world"})
  -- 遍历
  local count = 1
  local collection = {}
  for iter in list:iter() do
    local index = iter.index
    local value = iter.value
    lu.assertEquals(count, index)
    lu.assertEquals(list:get_at(index), value)
    table.insert(collection, value)
    count = count + 1
  end
  lu.assertEquals(collection, { 1,"hello",2,3, "world"})
  -- 删除
  local count = 1
  for iter in list:iter() do
    local index = iter.index
    local _count = iter.count
    local value = iter.value
    lu.assertEquals(count, _count)
    lu.assertEquals(iter.removed, false)
    lu.assertEquals(list:get_at(index), value) -- 删除前，下标在list中能找到的
    if(0 == (count & 1)) then -- 删除下标为偶数的item
      iter:remove()
      lu.assertEquals(iter.removed, true)
      lu.assertErrorMsgMatches(".*method \"remove\" had been executed once. count=%d.", iter.remove, iter)
    else
      lu.assertEquals(iter.removed, false)
    end
    count = count + 1 
  end
  lu.assertEquals(list:values(), { 1,2,"world"})
end

return M
