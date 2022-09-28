
local logger = require("tools/logger")
local rime_api_helper = require("tools/rime_api_helper")
local string_helper = require("tools/string_helper")

-- ============================================================= translator

local translator = {}

function translator.func(input, seg, env)
  if(seg:has_tag("version")) then
    local function my_cand(text, comment)
      local cand = Candidate("version", seg.start, seg._end, text, comment)
      cand.preedit = string.sub(input, seg._start+1, seg._end)
      return cand
    end
    yield(my_cand(rime_api_helper.get_rime_version(), "librime"))
    yield(my_cand(rime_api_helper.get_rime_lua_version(), "librime-lua"))
    yield(my_cand(rime_api_helper.get_lua_version(), "lua"))
    logger.info("debug version info", rime_api_helper:get_version_info())
  end
end

return {
  translator = translator
}