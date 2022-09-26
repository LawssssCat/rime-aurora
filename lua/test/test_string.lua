--[[
  测试string方法
==]]
assert(lu, "请通过 test/init.lua 运行本测试用例")

local null = require("tools/null")
local split = require("tools/split")
local string_helper = require("tools/string_helper")

local M = {}

function M:test_boolean()
  lu.assertEquals(not "", false)
  lu.assertEquals(not "nil", false)
end

function M:test_byte()
  lu.assertEquals(string.byte("a"), 97)
  lu.assertEquals(string.byte("a"), 0x61)
  lu.assertEquals(string.byte("abc"), 97)
  lu.assertEquals(string.byte("你"), 228)
end

function M:test_char()
  lu.assertEquals(string.char(32), " ")
  lu.assertEquals(string.char(97), "a")
  lu.assertError(string.char, 9999999999) -- to 'char' (value out of range)
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
  local str = "version"
  lu.assertEquals(string_helper.split(str, ""), {"v", "e", "r", "s", "i", "o", "n"})
  local t = ""
  local t_list = {}
  for i, v in pairs(string_helper.split(str, "")) do 
    t = t..v
    table.insert(t_list, t)
  end
  lu.assertEquals(t_list,{"v", "ve", "ver", "vers", "versi", "versio", "version"})
  lu.assertEquals(string_helper.join(t_list, "|"),"v|ve|ver|vers|versi|versio|version")
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
  lu.assertEquals(string_helper.sub("abc", 1, 2), "ab")
end

-- 截取（utf8）
function M:test_helper_sub()
  lu.assertEquals(string_helper.sub("你好", 1, 2), "你好")
  lu.assertEquals(string_helper.sub("你好", 1, 1), "你")
  lu.assertEquals(string_helper.sub("你好", 2, 2), "好")
  lu.assertError(string_helper.sub, "你好", 1, 3) -- 下标异常
  lu.assertError(string_helper.sub, "你好", 3) -- 下标异常
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
  lu.assertEquals(string.match("sfasfsdf", "qqqqq"), nil)
  lu.assertNotEquals(string.match("sfasfsdf", "qqqqqqqq"), false)
  lu.assertEquals(not string.match("sfasfsdf", "qqqqqqqq"), true)
  lu.assertEquals(not string.match("aaaaaaaaa", "a"), false)
  lu.assertEquals(string.match("sfasfsdf", "qqqqqqqqqq") ~= nil, false)
  -- 其他
  local env = {
    wildcard = "*"
  }
  lu.assertEquals(string.match("abcdefghijklnmopqrstuvwxyz",  '[^'.. env.wildcard .. ']+$'), "abcdefghijklnmopqrstuvwxyz")
  lu.assertEquals(string.match("abcdefg*hijkln*mopqrstuvwxyz",  '[^'.. env.wildcard .. ']+$'), "mopqrstuvwxyz")
  lu.assertEquals(string.match("abcdefg*hijkln*mopqrstuvwxyz",  '^[^' ..env.wildcard .. ']+'), "abcdefg")
  -- 标点
  local pattern_04 = "^/version+$"
  lu.assertTrue(string.match("/version", pattern_04))
  -- lu.assertTrue(string.match("/versio", pattern_04))
  -- lu.assertTrue(string.match("/versi", pattern_04))
  -- lu.assertTrue(string.match("/vers", pattern_04))
  -- lu.assertTrue(string.match("/ver", pattern_04))
  local tagname_prefix = "dy_cand_"
  local pattern = "^" .. tagname_prefix .. "(%d+)$"
  lu.assertEquals({string.match("dy_cand_1", pattern)}, {"1"})
  
end
function M:test_match_patterns_catch() -- ()
  lu.assertEquals({string.match("aabbbccdc", "a+b+")}, {"aabbb"}) --> 等于 (a+b+)
  lu.assertEquals({string.match("aabbbccdc", "(a+b+)")}, {"aabbb"})
  lu.assertEquals({string.match("aabbbccdc", "(a+)(b+)")}, {"aa", "bbb"})
  lu.assertEquals({string.match("aabbbccdc", "(a(a)+)(b+)")}, {}) -- 不支持子 () 捕获
  lu.assertEquals({string.match("aabbbccdc", "(a+)(z*)(b+)")}, {"aa", "", "bbb"}) -- 不匹配的 () 仍然显示
end
function M:test_match_patterns_a() -- %a 字母
  local pattern = "%a+"
  lu.assertEquals({string.match("abcABC", pattern)}, {"abcABC"})
  lu.assertEquals({string.match("abcABC!", pattern)}, {"abcABC"})
  lu.assertEquals({string.match("abcABC!abc", pattern)}, {"abcABC"}) -- 只返回第一个匹配
  lu.assertEquals({string.match("你好", pattern)}, {})
  pattern = "(%a+).-(%a+)"
  lu.assertEquals({string.match("abcABC!abc", pattern)}, {"abcABC", "abc"})
  for i=0,65536 do
    if((i>=string.byte("a") and i<=string.byte("Z")) or (false --[[...添加条件]])) then
      local c = utf8.char(i)
      lu.assertEquals({i, string.match(c, "%a")}, {i, c})
    end
  end
end
function M:test_match_patterns_c() -- %c 任何控制字符
  local pattern = "[^%c]+"
  lu.assertEquals({string.match("abcABC", pattern)}, {"abcABC"})
  lu.assertEquals({string.match("abcABC!", pattern)}, {"abcABC!"})
  lu.assertEquals({string.match("abcABC!abc", pattern)}, {"abcABC!abc"}) -- 只返回第一个匹配
  lu.assertEquals({string.match("你好", pattern)}, {"你好"})
  local temp = "abcdefghijklnmopqrstuvwxyz_ABCDEFGHIJKLNMOPQRSTUVWXYZ_1234567890_!@#$%^&*()_+[]\\;',./`{}|\"<>?"
  lu.assertEquals({string.match(temp, pattern)}, {temp})
  for i=0,65536 do
    if((i>31 and i~=127) or (false --[[...添加条件]])) then
      local c = utf8.char(i)
      lu.assertEquals({i, string.match(c, "[^%c]+")}, {i, c})
    end
  end
end
function M:test_match_patterns_g() -- %g 表示任何除空白符外的可打印字符(ascii?)
  lu.assertEquals({string.match(" ", "[^%g]+")}, {" "})
  for i=0,65536 do
    if((i>31 and i<127) or (false --[[...添加条件]])) then
      local c = utf8.char(i)
      lu.assertEquals({i, string.match(c, "[%g%s]+")}, {i, c})
    end
  end
end
function M:test_match_patterns_p() -- %p 表示所有标点符号。
  local str = "`~!@#$%^&*()_+-={}|[]\\;':\",./<>?"
  lu.assertEquals({string.match(str, "[%p]+")}, {str})
  -- 不包含中文标点
  lu.assertEquals({string.match("。！¥……（）", "[%p]+")}, {})
end
function M:test_match_patterns_w() -- %w 匹配所有字符
  for i=97,122 do
    local c = utf8.char(i)
    lu.assertEquals({i, string.match(c, "[%w]+")}, {i, c})
  end
  lu.assertFalse(string.match("你好", "[%w]+"))
  lu.assertFalse(string.match("!", "[%w]+"))
  lu.assertFalse(string.match(" ", "[%w]+"))
  lu.assertTrue(string.match(" ", "[%w%s]+"))
  lu.assertFalse(string.match("%", "[%w]+"))
  lu.assertFalse(string.match("_", "[%w]+"))
  lu.assertTrue(string.match("_", "[%w_]+"))
end
function M:test_match_patterns_x() -- %x 表示所有 16 进制数字符号。
  local str = "0123456789abcdefABCDEF"
  lu.assertEquals({string.match(str, "[%x]+")}, {str})
  lu.assertEquals({string.match(str.."ghijklnm...", "[%x]+")}, {str})
end
function M:test_match_patterns_bxy() -- %bxy 匹配xy中的字符
  lu.assertEquals({string.match("aa{abc}bb", "%b{}")}, {"{abc}"})
  lu.assertEquals({string.match("aa{abcbb", "%b{}")}, {})
  lu.assertEquals({string.match("aa{ab{c}bb", "%b{}")}, {"{c}"})
  lu.assertEquals({string.match("aa{ab{c}b}b", "%b{}")}, {"{ab{c}b}"})
  lu.assertEquals({string.match("aa{ab c}b}b", "%b }")}, {" c}"})
  lu.assertEquals({string.match("aa{ab}aaa{b}b", "%b{}")}, {"{ab}"})
end

function M:test_gmatch_patterns_bxy()
  local t = {}
  for v in string.gmatch("aa{ab}aaa{b}b", "%b{}") do
    table.insert(t, v)
  end
  lu.assertEquals(t,  {"{ab}", "{b}"})
  -- 
  local t = {}
  for v in string.gmatch("aa{ab}?aaa{b}?b", "{%w+}%?") do
    table.insert(t, v)
  end
  lu.assertEquals(t,  {"{ab}?", "{b}?"})
  --
  local t = {}
  for v in string.gmatch("aa{ab}?aaa{b}?b", "{%w+}[?]") do
    table.insert(t, v)
  end
  lu.assertEquals(t,  {"{ab}?", "{b}?"})
  -- 
  local t = {}
  for v in string.gmatch("aa{ab}?aaa{b}?b", "{(%w+)}%?") do
    table.insert(t, v)
  end
  lu.assertEquals(t,  {"ab", "b"})
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

function M:test_is_ascii_visible()
  lu.assertTrue(string_helper.is_ascii_visible("a"))
  lu.assertTrue(string_helper.is_ascii_visible(97)) -- a
  lu.assertFalse(string_helper.is_ascii_visible(16)) -- dle
  lu.assertFalse(string_helper.is_ascii_visible(99999999))
  lu.assertFalse(string_helper.is_ascii_visible(string.char(16))) -- dle
  lu.assertFalse(string_helper.is_ascii_visible(string.char(31))) -- us
  lu.assertTrue(string_helper.is_ascii_visible(string.char(32))) -- space
  lu.assertTrue(string_helper.is_ascii_visible(string.char(33))) -- !
  for c = 32, 126 do
    lu.assertTrue(string_helper.is_ascii_visible(string.char(c))) -- 全部可见字符
  end
  lu.assertFalse(string_helper.is_ascii_visible(string.char(127))) -- del
  lu.assertFalse(string_helper.is_ascii_visible("你"))
end

function M:test_is_ascii_visible_string()
  lu.assertTrue(string_helper.is_ascii_visible_string("a"))
  lu.assertTrue(string_helper.is_ascii_visible_string("abc"))
  lu.assertTrue(string_helper.is_ascii_visible_string("a bcd!"))
  lu.assertFalse(string_helper.is_ascii_visible_string("你好"))
  lu.assertFalse(string_helper.is_ascii_visible_string("a你好"))
  lu.assertFalse(string_helper.is_ascii_visible_string(string.char(127)))
  for c = 32, 126 do
    lu.assertTrue(string_helper.is_ascii_visible_string(string.char(c))) -- 全部可见字符
  end
  lu.assertFalse(string_helper.is_ascii_visible_string("abc" .. string.char(127) .. "你好"))
end

return M
