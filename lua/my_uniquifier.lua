local logger = require("tools/logger")
local rime_api_helper = require("tools/rime_api_helper")
local string_helper = require("tools/string_helper")

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

local filter = {}

function filter.init(env)
  local config = env.engine.schema.config
  -- 获取排除类型
  local excluded_types = rime_api_helper:get_config_item_value(config, env.name_space .. "/excluded_types")
  local excluded_types_type = type(excluded_types)
  if(excluded_types_type == "table") then
    -- nothing to do ..
  elseif(excluded_types_type == "string") then
    excluded_types = {excluded_types}
  else
    excluded_types = {}
  end
  env.excluded_types = excluded_types
end

function filter.func(input, env)
  local temp = {}
  for cand in input:iter() do
    local text = cand.text
    local prev = temp[text]
    local handles = {
      ------------------------
      -- 排除
      function()
        for i,type in pairs(env.excluded_types) do
          if(type == cand.type) then
            yield(cand)
            return true
          end
        end
        return false
      end,
      ------------------------
      -- 不重复
      function()
        if(not prev) then
          temp[text] = cand
          yield(cand)
          return true
        end
        return false
      end,
      ------------------------
      -- 重复，覆盖or抛弃
      function()
        local prev_level = type_level[prev:get_dynamic_type()]
        local this_level = type_level[cand:get_dynamic_type()]
        if(this_level>prev_level) then -- 用新的
          temp[text] = cand
          yield(cand)
          return true
        end
        return false
      end
    }
    for i,h in pairs(handles) do
      if(h() == true) then
        break
      end
    end
  end
end

return {
  filter = filter
}