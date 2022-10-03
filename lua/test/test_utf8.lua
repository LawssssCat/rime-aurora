--[[
  测试string方法
==]]
assert(lu, "请通过 test/init.lua 运行本测试用例")

local M = {}

local function func_01(ch)
  
end

function M:test_equal()
  lu.assertEquals("🙅‍♂" == "🙅‍♂", true)
  lu.assertEquals("🙅‍♂" == "🙅🏻‍♂️", false)
  lu.assertEquals("🙅‍♂" == "🙅", false)
  -- ----------------
  local ch = "🙅‍♂"
  local count = 0
  for p, c in utf8.codes(ch) do 
    lu.assertEquals(utf8.codepoint(ch, p), c)
    count = count + 1
  end
  lu.assertEquals(utf8.len(ch), count)
  -- ----------------
end

function M:test_codepoint()
  lu.assertEquals(utf8.codepoint("👂🏽", 1), 128066)
  lu.assertEquals(utf8.codepoint("👂🏽", 5), 127997)
  lu.assertError(utf8.codepoint, "👂🏽", 9)
  lu.assertEquals(utf8.codepoint("🙅‍♂", 1), 128581)
  lu.assertEquals(utf8.codepoint("🙅‍♂", 5), 8205)
  lu.assertEquals(utf8.codepoint("🙅‍♂", 8), 9794)
  lu.assertEquals(utf8.codepoint("🙅🏻‍♂️", 1), 128581)
  lu.assertEquals(utf8.codepoint("🙅🏽‍♂️", 1), 128581)
  lu.assertEquals(utf8.codepoint("🙅", 1), 128581)
  -- 😄 😸 😀 😁 😂 🤣 😃 🤩 😅 😆 😉 😊 😋 😎
  lu.assertEquals(utf8.codepoint("😄", 1), 128516)
  lu.assertEquals(utf8.codepoint("😸", 1), 128568)
  lu.assertEquals(utf8.codepoint("😀", 1), 128512)
  lu.assertEquals(utf8.codepoint("😁", 1), 128513)
  lu.assertEquals(utf8.codepoint("😂", 1), 128514)
  lu.assertEquals(utf8.codepoint("🤣", 1), 129315)
  lu.assertEquals(utf8.codepoint("😃", 1), 128515)
  lu.assertEquals(utf8.codepoint("🤩", 1), 129321)
  lu.assertEquals(utf8.codepoint("😅", 1), 128517)
  lu.assertEquals(utf8.codepoint("😆", 1), 128518)
  lu.assertEquals(utf8.codepoint("😉", 1), 128521)
  lu.assertEquals(utf8.codepoint("😊", 1), 128522)
  lu.assertEquals(utf8.codepoint("😋", 1), 128523)
  lu.assertEquals(utf8.codepoint("😎", 1), 128526)
end

function M:test_len()
  lu.assertEquals(utf8.len("1"), 1)
  lu.assertEquals(utf8.len("你"), 1)
  lu.assertEquals(utf8.len("𢛎"), 1)
  lu.assertEquals(utf8.len("【"), 1)
  lu.assertEquals(utf8.len("🙅"), 1)
  lu.assertEquals(utf8.len("🙅🏽"), 2)
  lu.assertEquals(utf8.len("🙅🏼"), 2)
  lu.assertEquals(utf8.len("🙅🏻"), 2)
  lu.assertEquals(utf8.len("🙅‍♂"), 3)
  lu.assertEquals(utf8.len("🙅🏼‍♂️"), 5)
  lu.assertEquals(utf8.len("🙅🏻‍♂️"), 5)
  lu.assertEquals(utf8.len("🙅🏽‍♂️"), 5)
end

return M