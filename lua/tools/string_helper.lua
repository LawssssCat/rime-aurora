--[[
  lua 默认将字符串以字节处理，这里将字符串以utf8编码处理
]]
local helper = {}

local null = require("tools/null")
local split = require("tools/split")
local inspect = require("tools/inspect")
local ptry = require("tools/ptry")

-- 字符串分割
function helper.split(str, delimiter)
  return split.split(str, delimiter)
end

--[[
  str: 1+2-(3*4/5^6)%7
  patterns: {"%d+", "[+\\-*/^%()]"}
  =>
  [1,+,2,-,(,3,*,4,/,5,^,6,),%,7]
]]
function helper.pick(str, patterns)
  patterns = type(patterns)=="table" and patterns or {patterns}
  local r = {} -- result
  local index=1
  local len=#str
  while(index<=len) do
    local _start, _end = 0, 0
    for i, p in pairs(patterns) do
      local _s, _e = string.find(str, p, index)
      if(_s and _e) then
        if(_start==0) then
          _start = _s
          _end = _e
        elseif(_start==_s and _end<_e) then
          _end = _e
        elseif(_start>_s) then
          _start = _s
          _end = _e
        end
      end
    end
    if(_end>=index) then
      local r_item = string.sub(str, _start, _end)
      table.insert(r, r_item)
      index = _end+1
    else
      break
    end
  end
  return r
end

-- 字符串连接
function helper.join(arr, delimiter)
  if(not arr) then error("can't join \"nil\"") end
  if(type(arr) ~= "table") then error("need \"table\" type. not \"" .. type(arr) .. "\"") end
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

--[[
  根据 pattern 替换 info 信息

  e.g. 
  pattern = "hello wor{value1}."
  info = {
    value1="ld"
  }
  =>
  "hello world."
]]
function helper.format(pattern, info)
  if(not info) then error("\"info\" is nil") end
  if(type(info) ~= "table") then error("type of \"info\" must be a \"table\"") end
  local result = pattern
  for key, value in pairs(info) do
    local replace_key = "{" .. key .. "}"
    local replace_value = type(value) == "string" and value or inspect(value)
    result = helper.replace(result, replace_key, replace_value)
  end
  return result
end

-- 【首字母】是否是数字
function helper.is_number(c)
  local t = type(c)
  if(t == "string") then
    return string.match(c, "^[\x30-\x39]+$") ~= nil
  end
  return false
end
function helper.is_ascii_visible_code(c)
  local t = type(c)
  if(t == "number") then
    return c>=0x20 and c<=0x7e
  end
  return false
end
-- 【首字母】是否是（可见）ascii
function helper.is_ascii_visible(c)
  local t = type(c)
  if(t == "string") then
    return string.match(c, "^[\x20-\x7e]$") ~= nil
  end
  return false
end
-- 【字符串】是否是（可见）ascii
function helper.is_ascii_visible_string(text)
  return string.match(text, "^[\x20-\x7e]+$") ~= nil
end

return helper