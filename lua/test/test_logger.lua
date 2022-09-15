assert(lu, "请通过 test/init.lua 运行本测试用例")

local logger = require("tools/logger")

local M = {}

function M:test_log() 
  logger.info("hello", {a="1", b=2})
  logger.warn("hello", "wor\nld")
  logger.error("hello", "world")
  logger.trace(logger.INFO, "hello", "world") -- trace 的正确示范
  lu.assertError(logger.trace, --[[ logger.INFO, ]]"hello", "world") -- trace 的错误示范
end

return M
