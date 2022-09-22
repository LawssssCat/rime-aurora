assert(lu, "请通过 test/init.lua 运行本测试用例")

local convert_arab_to_chinese = require("tools/number_to_cn").convert_arab_to_chinese

local M = {}

function M:test_boolean()
  lu.assertEquals(not 0, false)
  lu.assertEquals(not 1, false)
  lu.assertEquals(not nil, true)
  lu.assertNotEquals(nil, false)
end

function M:test_divide()
  lu.assertEquals(0.33333333333333, 0.33333333333333)
  lu.assertNotEquals(1/3, 0.33333333333333)
  lu.assertEquals(math.ceil(1/3), 1)
  lu.assertEquals(math.floor(1/3), 0)
end

-- 数值转换：罗马 => 中文
function M:test_convert_arab_to_chinese()
  lu.assertEquals(convert_arab_to_chinese(0), "零")
  lu.assertEquals(convert_arab_to_chinese(1), "一")
  lu.assertEquals(convert_arab_to_chinese(10), "十")
  lu.assertEquals(convert_arab_to_chinese(19), "十九")
  lu.assertEquals(convert_arab_to_chinese(20), "二十")
  lu.assertEquals(convert_arab_to_chinese(33), "三十三")
  lu.assertEquals(convert_arab_to_chinese(100), "一百")
  lu.assertEquals(convert_arab_to_chinese(109), "一百零九")
  lu.assertEquals(convert_arab_to_chinese(2009), "二千零九")
  lu.assertEquals(convert_arab_to_chinese(2109), "二千一百零九")
  lu.assertEquals(convert_arab_to_chinese(10109), "一万零一百零九")
  lu.assertEquals(convert_arab_to_chinese(10000), "一万")
  lu.assertEquals(convert_arab_to_chinese(13009), "一万三千零九")
  lu.assertEquals(convert_arab_to_chinese(993009), "九十九万三千零九")
  lu.assertEquals(convert_arab_to_chinese(993000), "九十九万三千")
  lu.assertEquals(convert_arab_to_chinese(999999999), "九亿九千九百九十九万九千九百九十九") -- max
  lu.assertError(convert_arab_to_chinese, 9223372036854775807) -- 传入参数位数19必须在(0, 9]之间！
end

return M
