--[[
  测试 lua 异常处理
]]

assert(lu, "请通过 test/init.lua 运行本测试用例")

local re = require("tools/regex/re")
local ptry = require("tools/ptry")

local M = {}

function M:test_ESC()
  lu.assertEquals(ESC,"/") -- define in re
  lu.assertEquals(re.compile("a/]"):execute("a]"),{})
  lu.assertEquals(re.compile("a]"):execute("a]"),{})
  lu.assertEquals(re.compile("a//]"):execute("a/]"),{})
  lu.assertEquals(re.compile("a\\]"):execute("a\\]"),{})
end
function M:test_ESC_modify()
  -- 测试内容
  local test = function()
    M:test_official_sample() -- 调用官方测试案例
  end
  -- 测试环境设置（希望若本测试失败不影响其他测试结果）
  local _ESC = ESC
  ESC = "\\"
  local rund = false
  local always_func = function()
    if(not rund) then
      ESC = _ESC
      rund = true
    end
  end
  ptry(function()
    test()
  end)
  ._then(function()
    always_func()
  end)
  ._catch(function(err)
    error(err)
  end)
  always_func()
end

function M:test_official_sample()

  -- should match simple regexes
  lu.assertEquals(re.compile("abc"):execute("abc"),{})
  lu.assertTrue(re.compile("abc"):execute("abc"))

  -- shouldn't match a simple non-match
  lu.assertEquals(re.compile("abc"):execute("def"), nil)
  lu.assertFalse(re.compile("abc"):execute("def"))

  -- should match any char
  lu.assertEquals(re.compile("..."):execute("abc"),{})

  -- should allow escaping metacharacters
  -- [ESC set by re to `/` by default]
  lu.assertEquals(re.compile(ESC .. "+abc"):execute("+abc"),{})
  lu.assertEquals(re.compile("abc" .. ESC .. "+abc"):execute("abc+abc"),{})
  lu.assertEquals(re.compile(ESC .. "."):execute("."),{})
  lu.assertEquals(re.compile(ESC .. "."):execute("!"),nil)
  -- [Multiple escapes]
  lu.assertEquals(re.compile(ESC .. "." .. ESC .. ".."):execute("..a"),{})
  lu.assertEquals(re.compile(ESC .. "." .. ESC .. ".."):execute(".ab"),nil)

  -- ---------------------------
  -- character classes
  -- ---------------------------

  -- should match basic classes
  lu.assertEquals(re.compile("ab[cdef]+gh"):execute("abcgh"),{"c"}) -- + 起作用
  lu.assertEquals(re.compile("ab[cdef]+gh"):execute("abcdegh"),{"cde"})
  lu.assertEquals(re.compile("ab[cdef]+gh"):execute("abzgh"),nil)

  -- should allow ']' to be escaped
  lu.assertEquals(re.compile("a[b" .. ESC .. "]]+gh." .. ESC .. "."):execute("ab]gh!."),{"b]"})

  -- should allow / to be escaped
  lu.assertEquals(re.compile("a[" .. ESC .. ESC .. "]+gh." .. ESC .. "."):execute("a" .. ESC .. ESC .. "gh!."),{ESC..ESC})

  -- shouldn't affect escaping outside the class
  lu.assertEquals(re.compile("[a" .. ESC .. "]]+b" .. ESC .. "."):execute("a]ab."),{"a]a"})
  lu.assertEquals(re.compile("[a" .. ESC .. "]]+b" .. ESC .. "."):execute("a]ab!"),nil)

  -- should not include / in the clas
  lu.assertEquals(re.compile("a[b" .. ESC .. "]]+c"):execute("a" .. ESC .. "c"),nil)
end

function M:test_brackets()
  lu.assertEquals(re.compile("abc"):execute("abc"),{})
  lu.assertEquals(re.compile("(ab)(c)"):execute("abc"),{"ab", "c"})
  lu.assertEquals(re.compile("(ab+)(c)"):execute("abc"),{"b", "ab", "c"})
  lu.assertEquals(re.compile("(ab[ABC])(c)"):execute("abAc"),{"abA", "c"})
  lu.assertEquals(re.compile("(abc|BCD)(c)"):execute("BCDc"),{"BCD", "c"})
  lu.assertEquals(re.compile("(abc|BCD.*)(c)"):execute("BCD??c"),{"??", "BCD??", "c"})
  lu.assertEquals(re.compile("(abc|BCD.*)(c)"):execute("abc??c"),nil)
  lu.assertEquals(re.compile("(abc|BCD.*)(c)"):execute("abcc"),{"", "abc", "c"}) -- ?? => 若匹配了，(), * 必然出结果
  lu.assertEquals(re.compile("(abc|(BCD.*))(c)"):execute("abcc"),{"", "", "abc", "c"}) -- ?? => 若匹配了，(), * 必然出结果
  lu.assertEquals(re.compile("(abc|(BCD.*))(c)"):execute("BCDac"),{"a", "BCDa", "BCDa", "c"})
  lu.assertEquals(re.compile("abc"):execute("abcd"),nil)
  lu.assertEquals(re.compile("abc.*"):execute("abcd"),{"d"})
  lu.assertEquals(re.compile("a(bc.*)"):execute("abcd"),{"d", "bcd"})
  lu.assertEquals(re.compile("a(bc.*)"):execute("abcde"),{"de", "bcde"})
  lu.assertEquals(re.compile("a.*(bc.*)"):execute("abcde"),{"", "de", "bcde"})
  lu.assertEquals(re.compile("(a.*)(bc.*)"):execute("abcde"),{"", "a", "de", "bcde"})
  lu.assertEquals(re.compile("(a.*)(bc.*)"):execute("a??bcde"),{"??", "a??", "de", "bcde"})
  lu.assertEquals(re.compile("(.*a.*)(bc.*)"):execute("AAa??bcde"),{"AA", "??", "AAa??", "de", "bcde"})
  lu.assertEquals(re.compile("abc"):execute("def"),nil)
  -- lu.assertEquals(re.compile("r(e*)gex?"):execute("reeeeegex"),{})
  lu.assertEquals(re.compile("%w"):execute("%w"),{})
  lu.assertEquals(re.compile("[a-z]"):execute("z"),{})
end

function M:test_square_brackets()
  lu.assertEquals(re.compile("[^a]"):execute("b"),{})
  lu.assertEquals(re.compile("[^a]"):execute("a"),nil)
end

function M:test_expansion_brackets()
  lu.assertEquals(re.compile("a{1}"):execute("a{1}"),{})
  lu.assertEquals(re.compile("(a){1}"):execute("a{1}"),{"a"})
  lu.assertEquals(re.compile("[a]{1}"):execute("a{1}"),{})
end

function M:test_url()
  lu.assertEquals(re.compile("^a$"):execute("^a$"),{})
  local pattern = "(www[.]|https?:|ftp[.:]|mailto:|file:).*"
  lu.assertEquals(re.compile(pattern):execute("www.b"),{"", "www.", "b"})
  lu.assertEquals(re.compile(pattern):execute("https://www.baidu.com"),{"s", "https:", "//www.baidu.com"})
  local pattern = "[a-zA-Z/_/-]+[:.](////)?.*" -- 简简单单才是真
  lu.assertFalse(re.compile(pattern):execute("goo"))
  lu.assertTrue(re.compile(pattern):execute("goo-_."))
  lu.assertTrue(re.compile(pattern):execute("good-_.bbbgoo"))
  lu.assertTrue(re.compile(pattern):execute("good-_.bbbgood-_."))
  lu.assertTrue(re.compile(pattern):execute("good-_.bbbgood-_.bbbgood-_."))
  lu.assertFalse(re.compile(pattern):execute("https"))
  lu.assertTrue(re.compile(pattern):execute("https:"))
  lu.assertTrue(re.compile(pattern):execute("https:aa")) -- true
  lu.assertTrue(re.compile(pattern):execute("https:/"))
  lu.assertTrue(re.compile(pattern):execute("https://"))
  lu.assertTrue(re.compile(pattern):execute("https://aa"))
  lu.assertTrue(re.compile(pattern):execute("https://aaa."))
  lu.assertTrue(re.compile(pattern):execute("https://aaa.b"))
  lu.assertTrue(re.compile(pattern):execute("https://aaa.bbb."))
  lu.assertTrue(re.compile(pattern):execute("https://aaa.bbb.ccc"))
end

return M --|((https?|ftp|mailto|file):(//)?)?([a-z_A-Z]+[.]?)+