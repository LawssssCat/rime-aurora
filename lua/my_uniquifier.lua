local logger = require("tools/logger")
local rime_api_helper = require("tools/rime_api_helper")
local string_helper = require("tools/string_helper")

local filter = {}

function filter.init(env)
  local config = env.engine.schema.config
  -- 获取排除类型
  env.excluded_types = rime_api_helper:get_config_item_value(config, env.name_space .. "/excluded_types") or {}
end

--[[
  作用：（去掉就知道啥作用了😂）
  1. 原本的 uniquifier 处理 emoji 时有问题（去重不完全）

  ⚡ 结果是否理想，component 的顺序很重要 ⚡
  ⚡ 结果是否理想，component 的顺序很重要 ⚡
  ⚡ 结果是否理想，component 的顺序很重要 ⚡
  ⚡ 结果是否理想，component 的顺序很重要 ⚡

  条件：
  1. my_user_dict translator 在最前
  1. cand 的 type 没有被改为 “simplified”
]]
function filter.func(input, env)
  local excluded_types = env.excluded_types
  local map = {}
  for cand in input:iter() do
    local text = cand.text
    local prev = map[text]
    if(rime_api_helper:is_candidate_in_types(cand, excluded_types)) then
      -- 排除
      yield(cand)
    elseif(not prev) then
      -- 不重复
      -- local u_cand = UniquifiedCandidate(cand,cand.type,"","")
      -- map[text] = u_cand
      -- yield(u_cand)
      map[text] = cand
      yield(cand)
    else
      -- prev:append(cand)
    end
  end
end

return {
  filter = filter
}