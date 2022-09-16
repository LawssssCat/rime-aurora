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

return M
