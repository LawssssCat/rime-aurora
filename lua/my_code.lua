--[[
  限制用户输入长度（避免编码过长导致卡顿、闪退、死机）

  *.schema.yaml
  ```yaml
    processors:
      - "lua_processor@code_length_limit_processor@code"
    code:
      length_limit: 50 # 限制输入长度
  ```

  rime.lua
  ```lua
    code_length_limit_processor = require("code")
  ```
--]]

local rime_api_helper = require("tools/rime_api_helper")

local M = {}

function M.func(key, env)
  local ctx = env.engine.context
  local config = env.engine.schema.config

  -- 限制
  local length_limit = config:get_string(env.name_space .."/length_limit")
  if(length_limit~=nil) then
    if(string.len(ctx.input) > tonumber(length_limit)) then
      -- ctx:clear()
      ctx:pop_input(1) -- 删除输入框中最后个编码字符
      return rime_api_helper.processor_return_kAccepted
    end
  end

  -- 放行
  return rime_api_helper.processor_return_kNoop
end

return M