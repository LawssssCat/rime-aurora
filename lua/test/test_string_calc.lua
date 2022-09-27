--[[
  测试string方法
==]]
assert(lu, "请通过 test/init.lua 运行本测试用例")

local string_helper = require("tools/string_helper")
local string_calc = require("tools/string_calc")

local M = {}

function M:test_split()
  lu.assertEquals(string_helper.pick("1+222-(3*4/59999^6)%7", {"%d+", "[+%-*/^%%()]"}),
  {"1", "+", "222", "-", "(", "3","*","4","/","59999","^","6",")","%","7"})
end

function M:test_infix_to_postfix()
end

function M:test_calc()
  -- normal
  lu.assertEquals(string_calc.calc("1+2"), 3)
  lu.assertEquals(string_calc.calc("1-2"), -1)
  lu.assertEquals(string_calc.calc("21*2"), 42)
  lu.assertEquals(string_calc.calc("1/2"), 0.5)
  lu.assertEquals(string_calc.calc("4^2"), 16)
  lu.assertEquals(string_calc.calc("4%2"), 0)
  lu.assertEquals(string_calc.calc("4%3"), 1)
  lu.assertEquals(string_calc.calc("1+(2)/(3+7)"), 1.2)
  -- 组合
  lu.assertEquals(string_calc.calc("(1+2-3)/2+1+(66/3^7%6-20)/(3+7)"), 1.2)
end

return M
