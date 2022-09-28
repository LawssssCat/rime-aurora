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

local logger = require("tools/logger")
local rime_api_helper = require("tools/rime_api_helper")

local processor = {}

-- 输入进入用户字典
function processor.init(env)
  local context = env.engine.context
  local mem = Memory(env.engine, env.engine.schema) 
  env.notifiers = {
    context.commit_notifier:connect(function(ctx)
      local commit_text = ctx:get_commit_text()
      if(commit_text) then
        local e = DictEntry()
        e.text = commit_text
        e.weight = 1
        e.custom_code = ctx:get_script_text()
        mem:update_userdict(e,1,"") -- do nothing to userdict
      end
    end),
  }
end

function processor.fini(env)
  for i, n in pairs(env.notifiers) do
    n:disconnect()
  end
end

function processor.func(key, env)
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

return {
  processor = processor
}