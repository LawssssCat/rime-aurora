--[[
  测试string方法
==]]
assert(lu, "请通过 test/init.lua 运行本测试用例")

local null = require("tools/null")
local split = require("tools/split")
local string_helper = require("tools/string_helper")

local M = {}

function M:test_byte()
  lu.assertEquals(string.byte("a"), 97)
  lu.assertEquals(string.byte("a"), 0x61)
end

function M:test_char()
  lu.assertEquals(string.char(97), "a")
end

function M:test_equal()
  lu.assertTrue("abcdefghijklnmopqrstuvwxyz" == "abcdefghijklnmopqrstuvwxyz")
  lu.assertFalse("abcdefghijklnmopqrstuvwxyz" == "ABCDEFGHIJKLNMOPQRSTUVWXYZ")
end

-- 字符串转换
function M:test_tostring()
  lu.assertEquals(tostring(nil), "nil")
  lu.assertEquals(tostring(1), "1")
  lu.assertEquals(tostring("abc"), "abc")
  lu.assertStrContains(tostring(function() end), "^function: %w+", true) -- e.g. function: 0000000000746A20
  lu.assertStrContains(tostring({a=1}), "^table: %w+", true) -- e.g. table: 0000000000870890
end

function M:test_format()
  lu.assertStrContains(string.format("%s %s %s %s", 1, nil, "3", {}), "^1 nil 3 table: %w+$", true) -- e.g. "1 nil 3 table: 0000000000837450"
end

function M:test_helper_format()
  lu.assertEquals(string_helper.format("hello {value01}!", {
    value01="world"
  }), "hello world!")
  lu.assertEquals(string_helper.format("hello {abc}!", {
    value="world"
  }), "hello {abc}!")
  lu.assertEquals(string_helper.format("hello {abc}!", {}), "hello {abc}!")
  -- error args
  lu.assertErrorMsgMatches(".*nil.*", string_helper.format, "hello {abc}!", nil)
  lu.assertErrorMsgMatches(".*table.*", string_helper.format, "hello {abc}!", "aaaa")
end

-- 字符串正则
function M:test_gsub()
  lu.assertEquals(string.gsub("abcdefg123321", "%w", "1"), "1111111111111")
  lu.assertEquals(string.gsub("banana", "(a)(n)", "%2%1"), "bnanaa" )
  lu.assertEquals(string.gsub("gu(n", "u[\\(]", "ǔ"), "gǔn" )
  lu.assertEquals(string.gsub("gao&", "([aeo])([iuo])([&\\*\\(\\)])", "%1%3%2"), "ga&o" )
end

-- 字符串替换【非正则】
function M:test_replace()
  lu.assertEquals(string_helper.replace("banana", "(a)(n)", "%2%1"), "b%2%1%2%1a") -- 用正则匹配，不用正则替换
  lu.assertEquals(string_helper.replace("banana", "(a)(n)", "%2%1", true), "banana") -- 不用正则匹配，不用正则替换
  lu.assertEquals(string_helper.replace("banana", "an", "%2%1", true), "b%2%1%2%1a")
end

function M:test_split()
  lu.assertEquals(string_helper.split("1 2  3   4    ", "%s+"), {"1","2","3","4",""})
end

function M:test_join()
  lu.assertError(string_helper.join, nil, " ")
  lu.assertError(string_helper.join, "string", " ")
  lu.assertEquals(string_helper.join({}, " "), "")
  lu.assertEquals(string_helper.join({"hello", "world", "!"}, " "), "hello world !")
  lu.assertEquals(string_helper.join({"hello", nil, "world", "!"}, " "), "hello world !")
  lu.assertEquals(string_helper.join({null("hello", nil, "world", "!")}, " "), "hello nil world !")
  lu.assertEquals(string_helper.join({"hello", "world", a="bb", "!"}, " "), "hello world ! bb")
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

-- 截取（字节）
function M:test_sub()
  lu.assertEquals(string_helper.sub("abc", 1, 1), "a")
end

-- 截取（utf8）
function M:test_helper_sub()
  lu.assertEquals(string_helper.sub("你好", 1, 2), "你好")
  lu.assertEquals(string_helper.sub("你好", 1, 1), "你")
  lu.assertEquals(string_helper.sub("你好", 2, 2), "好")
  lu.assertError(string_helper.sub, "你好", 1, 3) -- 下标异常
end

-- 匹配(第一个) => 返回匹配字符串
function M:test_match()
  -- 纯数字
  local pattern_01 = "^[%d]+$"
  lu.assertError(string.match, nil, pattern_01) -- error
  local _ok1 = string.match("123", pattern_01)
  lu.assertTrue(_ok1)
  lu.assertEquals(_ok1, "123")
  local _err1 = string.match("", pattern_01)
  lu.assertFalse(_err1)
  lu.assertEquals(_err1, nil)
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
  -- 特殊符号
  lu.assertTrue(not string.match("abc/dev", "abc\\/dev")) -- “/” 符号
  -- 返回值
  lu.assertEquals({string.match("good", "^[a-zA-Z]*$")}, {"good"})
  lu.assertEquals({string.match("/good", "^/")}, {"/"})
end

-- 查找(第一个) => 返回找到的下标
function M:test_find()
  local pattern_01 = "^[a-zA-Z]*$"
  -- 找不到
  lu.assertFalse(string.find("1", pattern_01), nil)
  lu.assertEquals(string.find("1", pattern_01))
  lu.assertEquals({string.find("1", pattern_01)}, {})
  lu.assertEquals({string.find("/abc", "^/[0-9a-zA-Z]*$")}, {1, 4})
  --找到了
  lu.assertTrue(string.find("good", pattern_01))
  lu.assertEquals(string.find("good", pattern_01), 1) -- 下标1开始
  lu.assertEquals({string.find("good", pattern_01)}, {1, 4}) -- 开始下标 结束下标
end

return M
