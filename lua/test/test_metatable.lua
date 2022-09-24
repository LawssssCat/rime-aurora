assert(lu, "请通过 test/init.lua 运行本测试用例")

local convert_arab_to_chinese = require("tools/number_to_cn").convert_arab_to_chinese

local M = {}

function M:test_getmetatable()
  local t = {a=1}
  local t2 = {b=1}
  setmetatable(t, {__index=t2})
  lu.assertEquals(getmetatable(t), {__index=t2})
  lu.assertEquals(t.a, 1)
  lu.assertEquals(t.b, 1)
end

return M