local logger = require("tools/logger")
local rime_api_helper = require("tools/rime_api_helper")
local ptry = require("tools/ptry")
local string_helper = require("tools/string_helper")

local handle_run_map = {
  Page_Up = function(env)  -- 上一页
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
  Page_Down = function(env) -- 下一页
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
  select = function(env, action)
    local context = env.engine.context
    local composition = context.composition
    if(not composition:empty()) then
      local segment = composition:back()
      local index = segment.selected_index
      context:select(index)
      return true
    end
    return false
  end
}

local processor = {}

function processor.init(env)
  local config = env.engine.schema.config
  env.key_binder_list = rime_api_helper:get_config_item_value(config, env.name_space .. "/key_binder")
end

function processor.func(key, env)
  local context = env.engine.context
  local composition = context.composition
  local segment = not composition:empty() and composition:back() or nil
  -- logger.warn(key.keycode, key:repr())

  -- editor
  local match_key = false
  if(env.key_binder_list) then
    for index, action in pairs(env.key_binder_list) do 
      ptry(function() -- accept
        if(action.accept == key:repr()) then
          return true
        end
      end)
      ._then(function(result) -- when
        if(result) then
          local _when = action.when
          local _match = false
          if(_when == "always") then
            _match = true
            return true
          end
          if(_when == "has_menu") then
            _match = true
            if(context:has_menu()) then
              return true
            end
          end
          if(not _match) then
            error(string.format("unknow action when \"%s\"", _when))
          end
        end
        return false
      end)
      ._then(function(result) -- option
        if(result) then
          local _option = action.option
          return not _option -- 没有设置 option 则直接下一步
            or context:get_option(_option)
        end
        return false
      end)
      ._then(function(result) -- action
        if(result) then
          -- send
          local _run = action.run
          local handler = handle_run_map[_run]
          if(handler) then
            local result = handler(env, action)
            if(not (result == false)) then
              match_key = true
            end
            return
          end
          error(string.format("unknow action run \"%s\"", _run))
        end
      end)
      ._catch(function(err) -- error
        match_key = false
        logger.error(err, action)
      end)
    end
  end

  if(match_key) then
    return rime_api_helper.processor_return_kAccepted
  else
    return rime_api_helper.processor_return_kNoop
  end
end

return {
  processor = processor
}