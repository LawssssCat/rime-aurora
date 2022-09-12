assert(lu, "请通过 test/init.lua 运行本测试用例")

local logger = require("tools/logger")

local M = {}

function M:test_log() 
  logger.info("hello", "world")
  logger.warn("hello", "world")
  logger.error("hello", "world")
  logger.trace("hello", "world")
end

return M
