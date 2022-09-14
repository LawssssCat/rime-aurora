--[[
  lua 默认将字符串以字节处理，这里将字符串以utf8编码处理
]]
local helper = {}

local null = require("tools/null")
local split = require("tools/split")
local inspect = require("tools/inspect")

-- 字符串分割
function helper.split(str, delimiter)
  return split.split(str, delimiter)
end

-- 字符串连接
function helper.join(arr, delimiter)
  local temp = {}
  for index, value in pairs(arr) do
    value = null(value)
    if(type(value)=="string") then
      table.insert(temp, value)
    else
      table.insert(temp, inspect(value))
    end
  end
  return table.concat(temp, delimiter)
end

-- utf8长度
function helper.len(str)
  return utf8.len(str)
end

--[[
  截取 utf8 字符串
  @param s 字符串
  @param i 开始
  @param j 结束
]]
function helper.sub(s,i,j)
  i=utf8.offset(s,i)
  j=utf8.offset(s,j+1)-1
  return string.sub(s,i,j)
end

return helper