local logger = require("tools/logger")
local rime_api_helper = require("tools/rime_api_helper")
local string_helper = require("tools/string_helper")
local LinkedList = require("tools/collection/linked_list")

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
  -- 去重集合上限
  env.uniquify_num = (function()
    local max = rime_api_helper:get_config_item_value(config, env.name_space .. "/uniquifier_max")
    max = tonumber(max) or 200
    return max
  end)()
  -- 获取排除类型
  env.excluded_types = (function()
    local types = rime_api_helper:get_config_item_value(config, env.name_space .. "/excluded_types")
    if(not types) then
      types = {}
    elseif(type(types) == "string") then
      types = {types}
    end
    function types:include(text)
      for i,t in pairs(self) do
        if(text == t) then
          return true
        end
      end
      return false
    end
    return types
  end)()
end

function filter.func(input, env)
  -- 队列 生成
  local queue = LinkedList()
  local map = {}
  local count = 1
  for cand in input:iter() do
    if(env.uniquify_num < count) then
      break
    else
      count = count + 1 -- 框架问题，仅去重前多少个。 see https://github.com/hchunhui/librime-lua/issues/203
    end
    local text = cand.text
    local prev = map[text]
    if(env.excluded_types:include(cand.type)) then
      -- 排除
      queue:add(cand)
    elseif(not prev) then
      -- 不重复
      queue:add(text)
      map[text] = cand
    else
      -- 重复，覆盖or抛弃
      local prev_level = type_level[prev:get_dynamic_type()]
      local this_level = type_level[cand:get_dynamic_type()]
      if(this_level>prev_level) then -- 用新的
        map[text] = cand
      end
    end
  end
  -- 队列 执行
  for iter in queue:iter() do
    local cand = iter.value
    if(type(cand) == "string") then
      cand = map[cand]
    end
    yield(cand)
  end
  -- 将显示剩下的候选词
  for cand in input:iter() do
    yield(cand)
  end
end

return {
  filter = filter
}