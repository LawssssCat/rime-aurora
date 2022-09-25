
local logger = require("tools/logger")
local rime_api_helper = require("tools/rime_api_helper")
local string_helper = require("tools/string_helper")

-- ============================================================= translator

local translator = {}

function translator.version_handle(input, seg, env)
  yield(Candidate("version", seg.start, seg._end, rime_api_helper.get_rime_version(), "librime"))
  yield(Candidate("version", seg.start, seg._end, rime_api_helper.get_rime_lua_version(), "librime-lua"))
  yield(Candidate("version", seg.start, seg._end, rime_api_helper.get_lua_version(), "lua"))
  logger.info("debug version info", rime_api_helper:get_version_info())
end

return translator