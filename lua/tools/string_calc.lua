local string_helper = require("tools/string_helper")
local Stack = require("tools/collection/stack")
local LinkedList = require("tools/collection/linked_list")
local inspect = require("tools/inspect")

local level_map = (function()
  local map = {}
  map["("]=0
  map["+"]=1
  map["-"]=1
  map["*"]=2
  map["/"]=2
  map["^"]=3 -- n次方
  map["@"]=3 -- 开方
  map["%"]=3 -- 取余
  return map
end)()

local function my_error(...)
  local msg = table.concat({...}, "\n")
  error(msg)
end

--[[
  中缀转后缀
  e.g. 【简单】
    a+b
    =>
    ab+
  e.g. 【复杂】
    a*(b+c)^d%e-f
    =>
    abc+d^e%*f-
]]
local function infix_to_postfix(items)
  local output = LinkedList()
  local stack = Stack()
  for i, item in pairs(items) do
    
    if(string.match(item, "%d+")) then -- 数字
      output:add(item)
    elseif(item == "(") then -- --------- (
      stack:push(item)
    elseif(item == ")") then -- --------- )
      local f = nil
      while(not stack:empty()) do
        f = stack:pop()
        if(f == "(") then
          break
        else
          output:add(f)
        end
      end
      if(f ~= "(") then
        my_error("cannot match \"(\"", 
          "last fix:   "..tostring(f), 
          "last index: "..tostring(i),
          "stack: "..tostring(stack), 
          "output:"..tostring(output), 
          "input: "..inspect(items))
      end
    else -- ---------------------------- 运算符
      local l = level_map[item]
      if(not l) then
        error("unrecognized character \""..tostring(item).."\"(type="..type(item)..")")
      end
      while(not stack:empty()) do
        local p = stack:peek()
        local pl = level_map[p]
        if(pl>=l) then
          output:add(stack:pop())
        else
          break
        end
      end
      stack:push(item)
    end
  end
  while(not stack:empty()) do
    local p = stack:pop()
    if(p == "(") then
      error("cannot match \")\""..tostring(stack))
    end
    output:add(p)
  end
  return output:values()
end

local function calc(postfix)
  local stack = Stack()
  for i,item in pairs(postfix) do
    if(string.match(item, "%d+")) then -- 数字
      stack:push(tonumber(item))
    elseif(item == "+") then
      local a = stack:pop()
      local b = stack:pop()
      stack:push(a+b)
    elseif(item == "-") then
      local a = stack:pop()
      local b = stack:pop()
      stack:push(b-a)
    elseif(item == "*") then
      local a = stack:pop()
      local b = stack:pop()
      stack:push(a*b)
    elseif(item == "/") then
      local a = stack:pop()
      local b = stack:pop()
      stack:push(b/a)
    elseif(item == "^") then
      local a = stack:pop()
      local b = stack:pop()
      stack:push(b^a)
    elseif(item == "%") then
      local a = stack:pop()
      local b = stack:pop()
      stack:push(b%a)
    elseif(item == "@") then
      local a = stack:pop()
      local b = stack:pop()
      stack:push(math.log(b, a))
    else
      error("unknow operation \""..item.."\"")
    end
  end
  if(stack:Size() == 1) then
    return stack:pop()
  end
  error("unknow calc error:"..tostring(stack))
end

return {
  infix_to_postfix=infix_to_postfix,
  calc=function(str)
    -- “整体”拆分成“单独”item（中缀）
    local infix = string_helper.pick(str, {"[%d.]+", "[+%-*/^@%%()]"})
    -- 中缀转后缀
    local postfix = infix_to_postfix(infix)
    local result = calc(postfix)
    return result
  end
}