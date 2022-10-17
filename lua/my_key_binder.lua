-- ------------------------
-- 快捷键相关功能
-- ------------------------

local logger = require("tools/logger")
local rime_api_helper = require("tools/rime_api_helper")
local ptry = require("tools/ptry")
local string_helper = require("tools/string_helper")

-- ----------------------------
-- 功能 run 列表
--[[
  @return 
    ture  run 成功，接收 keyEvent
    false run 失败，匹配其他功能
]]
-- ----------------------------

local handle_run_map = {
  Page_Up = function(key, env)  -- 上一页
    local schema = env.engine.schema
    local composition = env.engine.context.composition
    if(not composition:empty()) then
      local segment = composition:back()
      local page_size = schema.page_size
      rime_api_helper:page_prev(segment, page_size)
      return true
    end
    return false
  end,
  Page_Down = function(key, env) -- 下一页
    local schema = env.engine.schema
    local composition = env.engine.context.composition
    if(not composition:empty()) then
      local segment = composition:back()
      local page_size = schema.page_size
      rime_api_helper:page_next(segment, page_size)
      return true
    end
    return false
  end,
  select = function(key, env, action)
    local context = env.engine.context
    if(not context:has_menu()) then
      context:commit()
      return true
    end
    local composition = context.composition
    if(not composition:empty()) then
      local segment = composition:back()
      local index = segment.selected_index
      context:select(index)
      return true
    else
      logger.warn("fail to handle. \""..context.input.."\"")
    end
    return false
  end,
  delete = function(key, env)
    local context = env.engine.context
    local composition = context.composition
    local input = context.input
    local len = #input
    if(len>0) then
      if(composition:has_finished_composition()) then
        context:reopen_previous_selection()
        return true
      else
        local input = context.input
        local len = #input
        local caret_pos = context.caret_pos
        if(caret_pos == 0) then
          logger.warn("delete inputing text. but caret_pos is 0.")
          return false
        end
        if(len == caret_pos) then
          context.input = string.sub(input, 1, len-1)
          return true
        else
          local sub_a = string.sub(input, 1, caret_pos-1)
          local sub_b = string.sub(input, caret_pos+1, len)
          context.input = sub_a .. sub_b
          context.caret_pos = caret_pos - 1
          return true
        end
      end
    end
    return false
  end,
  delete_candidate = function(key, env)
    local context = env.engine.context
    local composition = context.composition
    if(not composition:empty()) then
      local segment = composition:back()
      local selected_index = segment.selected_index
      context:delete_current_selection()
      segment.selected_index = selected_index
      return true
    end
    return false
  end,
  push_input = function(key, env)
    local context = env.engine.context
    local code = key.keycode
    local ch = utf8.char(code)
    context:push_input(ch)
    return true
  end,
  reject = function(key, env)
    return false, rime_api_helper.processor_return_kRejected
  end
}

-- -----------------------------
-- 匹配『事件』列表
--[[
  @return
    true  交给下一个匹配。最后一个 true 代表匹配成功
    false 匹配失败
]]
-- -----------------------------

local key_binder_matching_chains = {
  function(key, env, index, action) -- accept
    if(action.accept == key:repr()) then
      return true
    end
    return false
  end,
  function(key, env, index, action) -- when
    local context = env.engine.context
    local _when = action.when
    if(_when) then
      if(_when == "always") then
        return true
      end
      if(_when == "has_menu") then
        if(context:has_menu()) then
          return true
        end
        return false
      end
      if(_when == "composing") then
        if(context:is_composing()) then
          return true
        end
        return false
      end
      error(string.format("unknow action when \"%s\"", _when))
    end
    return true
  end,
  function(key, env, index, action) -- option
    local context = env.engine.context
    local _option = action.option
    if(_option) then
      return context:get_option(_option)
    end
    return true
  end,
  -- 【 action 放最后】
  function(key, env, index, action) -- action
    -- send
    local _run = action.run
    local handler = handle_run_map[_run]
    if(handler) then
      return handler(key, env, action)
    end
    error(string.format("unknow action run \"%s\"", _run))
  end
}

-- ======================================= processor

local processor = {}

function processor.init(env)
  local config = env.engine.schema.config
  env.key_binder_list = rime_api_helper:get_config_item_value(config, env.name_space .. "/bindings")
  env.mem = Memory(env.engine,env.engine.schema)
end

function processor.func(key, env)
  local match_key = rime_api_helper.processor_return_kNoop
  if(env.key_binder_list) then
    local status_index = 0
    local status_action = nil
    ptry(function()
      -- 匹配配置
      for index, action in pairs(env.key_binder_list) do 
        status_index = index
        status_action = action
        local continue = false
        local flag = nil
        -- 匹配配置项目
        for jndex, match in pairs(key_binder_matching_chains) do
          continue, flag = match(key, env, index, action)
          if(not continue) then
            if(flag==nil) then
              -- match_key = rime_api_helper.processor_return_kNoop
              break
            else
              match_key = flag
              return
            end
          end
        end
        -- 匹配配置 - 成功
        if(continue) then
          if(flag==nil) then
            match_key = rime_api_helper.processor_return_kAccepted
          else
            match_key = flag
          end
          break
        end
      end
    end)
    ._catch(function(err) -- error
      match_key = rime_api_helper.processor_return_kNoop
      logger.error(err, status_index, status_action)
    end)
  end
  return match_key
end

return {
  processor = processor
}