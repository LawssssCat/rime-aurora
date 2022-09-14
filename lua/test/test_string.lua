--[[
  测试string方法
==]]
assert(lu, "请通过 test/init.lua 运行本测试用例")

local null = require("tools/null")
local split = require("tools/split")
local string_helper = require("tools/string_helper")

local M = {}

function M:test_split()
  lu.assertEquals(string_helper.split("1 2  3   4    ", "%s+"), {"1","2","3","4",""})
end

function M:test_join()
  lu.assertEquals(string_helper.join({"hello", "world", "!"}, " "), "hello world !")
  lu.assertEquals(string_helper.join({"hello", nil, "world", "!"}, " "), "hello world !")
  lu.assertEquals(string_helper.join({null("hello", nil, "world", "!")}, " "), "hello nil world !")
  lu.assertEquals(string_helper.join({"hello", "wor\nld", "!"}, " "), [[hello wor
ld !]])
  lu.assertEquals(string_helper.join({"hello", {a=1}, "!"}, " "), [[hello {
  a = 1
} !]])
end

function M:test_utf8len()
  lu.assertEquals(string_helper.len("123"), 3)
  lu.assertEquals(string_helper.len("123你"), 4)
  lu.assertEquals(string_helper.len(" 你好！"), 4)
  lu.assertEquals(string_helper.len(" 𩧱2"), 3) -- extcjk
end

-- 截取
function M:test_slice()
  lu.assertEquals(string_helper.sub("你好", 1, 2), "你好")
  lu.assertEquals(string_helper.sub("你好", 1, 1), "你")
  lu.assertEquals(string_helper.sub("你好", 2, 2), "好")
  lu.assertError(string_helper.sub, "你好", 1, 3) -- 下标异常
end

-- 匹配
function M:test_match()
  -- 纯数字
  local pattern_01 = "^[%d]+$"
  lu.assertTrue(string.match("123", pattern_01))
  lu.assertFalse(string.match("", pattern_01))
  lu.assertFalse(string.match("123 ", pattern_01))
  lu.assertFalse(string.match("bcd", pattern_01)) 
  lu.assertFalse(string.match("你好", pattern_01)) 
  lu.assertFalse(string.match("123bcd", pattern_01)) 
  lu.assertFalse(string.match("123你好", pattern_01)) 
  -- 纯数字/字母
  local pattern_02 = "^[%w]+$" 
  lu.assertTrue(string.match("123", pattern_02))
  lu.assertTrue(string.match("abc", pattern_02))
  lu.assertTrue(string.match("ABC", pattern_02))
  lu.assertTrue(string.match("abc123", pattern_02))
  lu.assertFalse(string.match("你好", pattern_02))
  lu.assertFalse(string.match("你好123", pattern_02))
  -- 非纯数字/字母
  -- local pattern_03 = "^[^%w]+$" 
  -- lu.assertTrue(string.match("你好", pattern_03))
  -- lu.assertTrue(string.match("你123好", pattern_03)) -- 奇怪
  local pattern_03 = "^[%w]+$" 
  lu.assertTrue(not string.match("你好", pattern_03))
  lu.assertTrue(not string.match("你123好", pattern_03))
end

return M
