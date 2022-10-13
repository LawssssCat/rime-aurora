--[[
  测试string方法
==]]
assert(lu, "请通过 test/init.lua 运行本测试用例")

local string_syllabify = require("tools/string_syllabify")

local M = {}

function M:test_split_word()
  lu.assertError(string_syllabify.split_word)
  lu.assertEquals(ymb, nil)
  lu.assertEquals(smb, nil)
  lu.assertEquals(dlymb, nil)
  lu.assertEquals(string_syllabify.split_word(""), {})
  lu.assertEquals(string_syllabify.split_word("nihao"), {{"ni", "hao"}, {"ni", "ha", "o"}})
  -- "x"
  --   => 
  --   1. x
  lu.assertEquals(string_syllabify.split_word("x"), {})
  -- "xi"
  --   => ❌ x i
  --   1. xi
  lu.assertEquals(string_syllabify.split_word("xi"), {{"xi"}})
  -- "xia"
  --   => ❌ x ia 
  --   1. xia
  --   2. xi a
  lu.assertEquals(string_syllabify.split_word("xia"), {{"xia"}, {"xi", "a"}})
  -- "xian"
  --   => ❌ xia n （声母缺韵母）
  --   1. xi an
  --   2. xian
  lu.assertEquals(string_syllabify.split_word("xian"), {{"xian"}, {"xi", "an"}})
  -- "xinan"
  --   => ❌ xina n
  --   1. xi nan
  --   2. xin an
  lu.assertEquals(string_syllabify.split_word("xinan"), {{"xin", "an"}, {"xi", "nan"}})
  -- "xinaning"
  --   => ❌ xin an ing （韵母缺声母）
  --   1. xi na ning
  --   2. xin a ning
  lu.assertEquals(string_syllabify.split_word("xinaning"), {{"xin", "a", "ning"}, {"xi", "na", "ning"}})
end
function M:test_split_word_part()
  local part = true
  lu.assertEquals(string_syllabify.split_word("", part), {})
  lu.assertEquals(string_syllabify.split_word("nihao", part), {{"ni", "hao"}, {"ni", "ha", "o"}})
  lu.assertEquals(string_syllabify.split_word("x", part), {{"x"}})
  lu.assertEquals(string_syllabify.split_word("xi", part), {{"xi"}})
  lu.assertEquals(string_syllabify.split_word("xia", part), {{"xia"}, {"xi", "a"}})
  lu.assertEquals(string_syllabify.split_word("xian", part), {{"xian"}, {"xia", "n"}, {"xi", "an"}, {"xi", "a", "n"}})
  lu.assertEquals(string_syllabify.split_word("xinan", part), {{"xin", "an"}, {"xi", "nan"}, {"xin", "a", "n"}, {"xi", "na", "n"}})
  lu.assertEquals(string_syllabify.split_word("xinaning", part), {
    {"xin", "a", "ning"},
    {"xi", "na", "ning"},
    {"xin", "a", "nin", "g"},
    {"xi", "na", "nin", "g"},
    {"xin", "a", "ni", "n", "g"},
    {"xi", "na", "ni", "n", "g"}
  })
end

function M:test_syllabify()
  lu.assertError(string_syllabify.syllabify)
  lu.assertEquals(string_syllabify.syllabify(""), {})
  lu.assertEquals(string_syllabify.syllabify("nihao"), {"ni hao", "ni ha o"})
  lu.assertEquals(string_syllabify.syllabify("ihao"), {})
  lu.assertEquals(string_syllabify.syllabify("nihao", ","), {"ni,hao", "ni,ha,o"})
  --   "x"
  --   => 空数组
  lu.assertEquals(string_syllabify.syllabify("x"), {})
  -- "xi"
  --   => ❌ x i
  --   1. xi
  lu.assertEquals(string_syllabify.syllabify("xi"), {"xi"})
  -- "xia"
  --   => ❌ x ia 
  --   1. xia
  --   2. xi a
  lu.assertEquals(string_syllabify.syllabify("xia"), {"xia", "xi a"})
  lu.assertEquals(string_syllabify.syllabify("xi a"), {"xi a"})
  -- "xian"
  --   => ❌ xia n （声母缺韵母）
  --   1. xi an
  --   2. xian
  lu.assertEquals(string_syllabify.syllabify("xian"), {"xian", "xi an"})
  -- "xinan"
  --   => ❌ xina n
  --   1. xi nan
  --   2. xin an
  lu.assertEquals(string_syllabify.syllabify("xinan"), {"xin an", "xi nan"})
  lu.assertEquals(string_syllabify.syllabify("xin an"), {"xin an"})
  -- "xinaning"
  --   => ❌ xin an ing （韵母缺声母）
  --   1. xi na ning
  --   2. xin a ning
  lu.assertEquals(string_syllabify.syllabify("xinaning"), {"xin a ning", "xi na ning"})
  lu.assertEquals(string_syllabify.syllabify("xi naning"), {"xi na ning"})
  lu.assertEquals(string_syllabify.syllabify("x inaning"), {})
end
function M:test_syllabify_part()
  local part = true
  lu.assertError(string_syllabify.syllabify)
  lu.assertEquals(string_syllabify.syllabify("", part), {})
  lu.assertEquals(string_syllabify.syllabify("nihao", part), {"ni hao", "ni ha o"})
  lu.assertEquals(string_syllabify.syllabify("nihao", ",", part), {"ni,hao", "ni,ha,o"})
  lu.assertEquals(string_syllabify.syllabify("ihao", ",", part), {})
  lu.assertEquals(string_syllabify.syllabify("x", part), {"x"})
  lu.assertEquals(string_syllabify.syllabify("xi", part), {"xi"})
  lu.assertEquals(string_syllabify.syllabify("xia", part), {"xia", "xi a"})
  lu.assertEquals(string_syllabify.syllabify("xi a", part), {"xi a"})
  lu.assertEquals(string_syllabify.syllabify("xian", part), {"xian", "xia n", "xi an", "xi a n"})
  lu.assertEquals(string_syllabify.syllabify("xinan", part), {"xin an", "xi nan", "xin a n", "xi na n"})
  lu.assertEquals(string_syllabify.syllabify("xin an", part), {"xin an", "xi n an", "xin a n", "xi n a n"})
  lu.assertEquals( string_syllabify.syllabify("xinaning"), {
    "xin a ning", 
    "xi na ning"
  })
  lu.assertEquals( string_syllabify.syllabify("xinaning", part), {
    "xin a ning",
    "xi na ning",
    "xin a nin g",
    "xi na nin g",
    "xin a ni n g",
    "xi na ni n g"
  })
  lu.assertEquals(string_syllabify.syllabify("xi naning", part),  {
    "xi na ning", 
    "xi na nin g", 
    "xi na ni n g"
  })
  lu.assertEquals(string_syllabify.syllabify("x inaning", part), {})
  lu.assertEquals(string_syllabify.syllabify("chqyhslwszds", part), {
    "ch q y h s l w s z d s",
    "c h q y h s l w s z d s"
  })
  -- 不支持拿来处理 url（结果奇怪）
  lu.assertEquals(string_syllabify.syllabify("www", part), {"w w w"})
  lu.assertEquals(string_syllabify.syllabify("www.", part), {})
  lu.assertEquals(string_syllabify.syllabify("www.g", part), {"w w w. g"})
  lu.assertEquals(string_syllabify.syllabify("www.go", part), {"w w w. go"})
  lu.assertEquals(string_syllabify.syllabify("www.goo", part), {"w w w. go o"})
  lu.assertEquals(string_syllabify.syllabify("www.goog", part), {"w w w. go o g"})
  lu.assertEquals(string_syllabify.syllabify("www.googl", part), {"w w w. go o g l"})
  lu.assertEquals(string_syllabify.syllabify("www.google", part), {"w w w. go o g le"})
  lu.assertEquals(string_syllabify.syllabify("www.google.", part), {})
  lu.assertEquals(string_syllabify.syllabify("www.google.c", part), {})
  lu.assertEquals(string_syllabify.syllabify("www.google.co", part), {})
  lu.assertEquals(string_syllabify.syllabify("www.google.com", part), {})
  lu.assertEquals(string_syllabify.syllabify("www.github.com", part), {"w w w. gi t hu b. co m"})
end

return M
