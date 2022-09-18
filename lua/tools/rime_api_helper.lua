--[[
  
  包含 librime-lua 接口的进一步分装

  地址：https://github.com/hchunhui/librime-lua
  文档：https://github.com/hchunhui/librime-lua/wiki/Scripting
  相关：
    1. https://github.com/hchunhui/librime-lua/issues/186
  参考：
    1. https://github.com/shewer/librime-lua-script
]]

local helper = {}

-- the version of librime (https://github.com/rime/librime): 输入法核心引擎
function helper:get_rime_version()
  return rime_api and rime_api.get_rime_version and rime_api.get_rime_version()
end

-- the version of lua (https://www.lua.org/): 脚本语言
function helper:get_lua_version()
  return _VERSION
end

-- the version of librime-lua (https://github.com/hchunhui/librime-lua): librime插件，引导lua代码的执行
function helper:get_rime_lua_version() -- 版本规则参考：https://github.com/shewer/librime-lua-script
  local ver
  if LevelDb then
    ver = 177
  elseif Opencc then
    ver = 147
  elseif KeySequence and KeySequence().repr then
    ver= 139
  elseif  ConfigMap and ConfigMap().keys then
    ver= 127
  elseif Projection then
    ver= 102
  elseif KeyEvent then
    ver = 100
  elseif Memory then
    ver = 80
  else
    ver= 79
  end
  return ver
end

function helper:get_version_info()
  return string.format("\nVer: librime %s \nlibrime-lua %s \nlua %s",
  helper.get_rime_version(), helper.get_rime_lua_version(), helper.get_lua_version())
end

-- 获取配置 ==> string
function helper:get_config_string(config, path)
  return config:get_string(path)
end

-- 获取配置 => arr table
function helper:get_config_list(config, path)
  -- issue about is_list https://github.com/hchunhui/librime-lua/issues/193
  local config_list = config:is_list(path) and config:get_list(path)
  if(not config_list) then return nil end
  local result_list = {}
  local temp = nil
  for i = 1, config_list.size do
    temp = config_list:get_value_at(i-1) -- 下标 0 开始
    if(temp) then
      table.insert(result_list, temp.value)
    end
  end
  return result_list
end

-- 获取配置 => map table
function helper:get_config_map(config, path)
  local result_map = {}
  local config_map = config:get_map(path)
  if(not config_map) then return nil end
  for index, key in pairs(config_map:keys()) do 
    local value = config_map:get_value(key).value
    result_map[key] = value
  end
  return result_map
end

return helper
