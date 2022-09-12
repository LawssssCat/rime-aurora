--[[
  测试第三方库：inspect.lua

  https://github.com/kikito/inspect.lua
]]

assert(lu, "请通过 test/init.lua 运行本测试用例")

local inspect = require("tools/inspect")

local M = {}

function M:test_inspect() 
  lu.assertEquals(inspect(1), "1")
  lu.assertEquals(inspect("Hello"), '"Hello"')
  -- "Array-like" tables are rendered horizontally
  lu.assertEquals(inspect({1,2,3,4}), "{ 1, 2, 3, 4 }")
  -- "Dictionary-like" tables are rendered with one element per line:
  lu.assertEquals(inspect({a=1,b=2}), [[{
  a = 1,
  b = 2
}]])
  -- "Hybrid" tables will have the array part on the first line, and the dictionary part just below them:
  lu.assertEquals(inspect({1,2,3,b=2,a=1}), [[{ 1, 2, 3,
  a = 1,
  b = 2
}]])
  lu.assertEquals(inspect({a={b=2}}), [[{
  a = {
    b = 2
  }
}]])
  -- Functions, userdata and any other custom types from Luajit are simply as <function x>, <userdata x>, etc.:
--   local some_user_data = ???
--   local a_thread = ???
--   lu.assertEquals(inspect({ f = print, ud = some_user_data, thread = a_thread} ), [[{
--   f = <function 1>,
--   u = <userdata 1>,
--   thread = <thread 1>
-- }]])
  -- If the table has a metatable, inspect will include it at the end, in a special field called <metatable>:
  lu.assertEquals(inspect(setmetatable({a=1}, {b=2})), [[{
  a = 1,
  <metatable> = {
    b = 2
  }
}]])
  -- inspect can handle tables with loops inside them. It will print <id> right before the table is printed out the first time, and replace the whole table with <table id> from then on, preventing infinite loops.
  local a = {1, 2}
  local b = {3, 4, a}
  a[3] = b -- a references b, and b references a
  lu.assertEquals(inspect(a), [[<1>{ 1, 2, { 3, 4, <table 1> } }]])

  -- more https://github.com/kikito/inspect.lua#options

end

return M