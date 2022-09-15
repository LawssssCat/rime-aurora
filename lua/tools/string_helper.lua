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
  if(arr) then
    for index, value in pairs(arr) do
      value = null(value)
      if(type(value)=="string") then
        table.insert(temp, value)
      else
        table.insert(temp, inspect(value))
      end
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

--[[

  字符串替换【不执行模式替换】

  参考：
    1. https://blog.csdn.net/gouki04/article/details/88559872

  @param s 源字符串
  @param pattern 匹配字符串
  @param repl 替换字符串
  @param pain 是否使用正则查找
  @return 成功返回替换后的字符串，失败返回源字符串
]]
function helper.replace(s, pattern, repl, pain)
  pain = pain or false
  local i,j = string.find(s, pattern, 1, pain)
  if i and j then
      local ret = {}
      local start = 1
      while i and j do
          table.insert(ret, string.sub(s, start, i - 1))
          table.insert(ret, repl)
          start = j + 1
          i,j = string.find(s, pattern, start, pain)
      end
      table.insert(ret, string.sub(s, start))
      return table.concat(ret)
  end
  return s
end

return helper