local logger = require("tools/logger")
local rime_api_helper = require("tools/rime_api_helper")
local string_helper = require("tools/string_helper")

local filter = {}

local type_level = (function()
  local M = {}
  M["Phrase"] = 90
  M["Simple"] = 9
  M["Shadow"] = 9
  M["Uniquified"] = 9
  setmetatable(M, {
    __index = function() -- 默认值
      return 10
    end
  })
  return M
end)()

function filter.func(input, env)
  local temp = {}
  for cand in input:iter() do
    local text = cand.text
    local prev = temp[text]
    if(not prev) then
      temp[text] = cand
      yield(cand)
    else
      local prev_level = type_level[prev:get_dynamic_type()]
      local this_level = type_level[cand:get_dynamic_type()]
      if(this_level>prev_level) then
        temp[text] = cand
        yield(cand)
      end
    end
  end
end

return {
  filter = filter
}