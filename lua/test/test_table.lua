assert(lu, "请通过 test/init.lua 运行本测试用例")

local table_helper = require("tools/table_helper")

local M = {}

function M:test_equal()
  lu.assertFalse({} == {})
  lu.assertFalse({true, "abc"} == true)
  local my_table_id = {}
  lu.assertTrue((function() return my_table_id, "return_1", "return_2" end)() == my_table_id) -- 多个返回值，取第一个与 “==” 做比较
end

function M:test_null()
  local a = function(...)
    return ...
  end
  local ra = {a(1,nil,3)}
  lu.assertEquals(ra, {1,nil, 3})
  lu.assertEquals(#ra, 3)
  local b = function(...)
    local qq = {...}
    return table.unpack(qq)
  end
  local rb = {b(1,nil,3)}
  lu.assertEquals(rb, {1,nil, 3})
  lu.assertEquals(#rb, 3)
end

function M:test_init()
  local t = {
    a = 1,
    b = 2,
  }
  t["c"]  = t["a"]
  lu.assertEquals(t, {a=1,b=2,c=1})
end

function M:test_func()
  local t = {
    f = function()
      return "1"
    end
  }
  t.f2 = function()
    return "2"
  end
  local f = t["f"]
  local f2 = t["f2"]
  lu.assertEquals(type(f), "function")
  lu.assertEquals(type(f2), "function")  
end

function M:test_remove()
  local my_table = {"hello", "world"}
  lu.assertEquals(table.remove(my_table, 1), "hello")
  lu.assertEquals(my_table, {"world"})
  lu.assertEquals(#my_table, 1)
  local my_table = {"hello", "world","!"}
  lu.assertEquals(table.remove(my_table, 2), "world")
  lu.assertEquals(my_table, {"hello", "!"})
  lu.assertEquals(#my_table, 2)
  -------------------------
  -- remove 会影响遍历
  local my_table = {"hello", "world"}
  local count = 1
  for i, v in pairs(my_table) do
    lu.assertEquals(i, count)
    lu.assertEquals(v, my_table[i])
    local rv = table.remove(my_table, i)
    lu.assertEquals(v, rv)
    count = count + 1
  end
  lu.assertEquals(count, 2)
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
  lu.assertEquals(#{nil}, 0) -- 0000000000000000 -- 当没有其他 item 时，不包括 nil
  lu.assertEquals(#{1,2,3,nil,4,5,6}, 7)         -- 当有其他 item 时，包括 nil
  lu.assertEquals(#{1,2,3,nil,4,5,6,a="a",7}, 8)
end

function M:test_unpack()
  lu.assertError(table.unpack, nil)
  lu.assertEquals({table.unpack({})}, {})
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
  local index = nil
  for index, value in pairs({1,2,3, nil, 5}) do -- skip "nil"
    count = count + 1
    lu.assertEquals(index, value)
  end
  lu.assertEquals(index, nil)
  lu.assertEquals(count, 4)
  local t = {a=1,b=2,c=3,d="d"}
  lu.assertEquals(t, {a=1,b=2,c=3,d="d"})
  lu.assertEquals(#t, 0)
  for k,v in pairs(t) do
    t[k] = nil
  end
  lu.assertEquals(t, {})
end

function M:test_arr_remove_duplication()
  lu.assertEquals(table_helper.arr_remove_duplication({1,2,3,4}), {1, 2, 3, 4})
  lu.assertEquals(table_helper.arr_remove_duplication({2,2,3,4}), {2, 3, 4})
  lu.assertEquals(table_helper.arr_remove_duplication({2,2,abc="22",3,4}), {2, 3, 4, "22"})
  local a = {2,2,3,4}
  a["qq"] = "33"
  lu.assertEquals(table_helper.arr_remove_duplication(a), {2, 3, 4, "33"})
end

return M
