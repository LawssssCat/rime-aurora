assert(lu, "请通过 test/init.lua 运行本测试用例")

local M = {}

function M:test_equal()
  lu.assertFalse({} == {})
  lu.assertFalse({true, "abc"} == true)
  local my_table_id = {}
  lu.assertTrue((function() return my_table_id, "return_1", "return_2" end)() == my_table_id) -- 多个返回值，取第一个与 “==” 做比较
end

function M:test_remove()
  local my_table = {"hello", "world"}
  lu.assertEquals(table.remove(my_table, 1), "hello")
  lu.assertEquals(my_table, {"world"})
end

function M:test_len_select()
  -- nil
  lu.assertEquals(select('#', 1), 1)
  lu.assertEquals(select('#', 1,2,3), 3)
  lu.assertEquals(select('#', nil), 1) -- 111111111111111111111
  lu.assertEquals(select('#', 1,2,3,nil,4,5,6), 7)
  lu.assertEquals(select('#', table.unpack({1,2,3,nil,4,5,6,a="a",7})), 8)
end

function M:test_len()
  lu.assertEquals(#{1}, 1)
  lu.assertEquals(#{1,2,3}, 3)
  lu.assertEquals(#{nil}, 0) -- 0000000000000000
  lu.assertEquals(#{1,2,3,nil,4,5,6}, 7)
  lu.assertEquals(#{1,2,3,nil,4,5,6,a="a",7}, 8)
end

function M:test_unpack()
  lu.assertEquals({table.unpack({1,2,3})}, {1, 2, 3})
  lu.assertEquals({table.unpack({1,2,nil,3})}, {1, 2, nil, 3})
  lu.assertEquals({table.unpack({1,2,nil,3,b="q",4})}, {1, 2, nil, 3, 4})
end

function M:test_insert()
  local t = {}
  table.insert(t, nil)
  lu.assertEquals(t, {})
end

function M:test_for()
  local count = 0
  for index, value in pairs({1,2,3, nil, 5}) do -- skip "nil"
    count = count + 1
    lu.assertEquals(index, value)
  end
  lu.assertEquals(count, 4)
end

return M
