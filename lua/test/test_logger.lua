assert(lu, "请通过 test/init.lua 运行本测试用例")

local logger = require("tools/logger")

local M = {}

function M:test_no_error() 
  lu.assertStrContains(logger.error("hello", "world"), "hello, world$", true)
  lu.assertStrContains(logger.info("hello", {a="1", b=2}), "hello.*{.*a.*=.*1.*b.*=.*2.*}$", true)
  lu.assertStrContains(logger.warn("hello", "wor\nld"), "hello.*wor.*ld$", true)
  lu.assertStrContains(logger.trace(logger.INFO, "hello", "world"), "hello, world", true) -- trace 的正确示范
  lu.assertError(logger.trace, --[[ logger.INFO, ]]"hello", "world") -- trace 的错误示范
end

return M
