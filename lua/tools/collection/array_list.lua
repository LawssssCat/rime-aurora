--[[

  【下标0开始】

  创建对象
  List(...)

]]

local List = require("tools/collection/list")
local null = require("tools/null")

function assert_index(self, index)
  if(0>=index or self.size<index) then
    error(string.format("\"%s\" out of range: (0, %s]", index, self.size))
  end
end

local ArrayList = List:extend() -- class

function ArrayList:new(list)
  self.size = 0
  self.data = {}
  self:add_all(list)
end

function ArrayList:Size()
  return self.size
end

function ArrayList:get_at(index)
  assert_index(self, index)
  local result = null(self.data[index])
  return result
end

function ArrayList:index_of(item)
  local temp = null(item) -- nil 
  for i, v in pairs(self.data) do
    if(v == temp) then
      return i
    end
  end
end

function ArrayList:remove_at(index)
  assert_index(self, index)
  local result = null(self.data[index])
  for i = index+1, self.size do
    self.data[i-1] = self.data[i]
  end
  self.data[self.size] = nil -- 释放引用
  self.size = self.size - 1
  return result
end

function ArrayList:add_at(index, item)
  if(index == (self.size+1)) then
    return self:add(item)
  end
  assert_index(self, index)
  local next = self.data[index]
  for i = index, self.size do
    local temp = next
    next = self.data[i+1]
    self.data[i+1] = temp
  end
  self.data[index] = null(item)
  self.size = self.size + 1
end

function ArrayList:add(item)
  self.data[self.size+1] = null(item)
  self.size = self.size + 1
end

function ArrayList:remove()
  local index = self.size
  return self:remove_at(index)
end

function ArrayList:add_all(list)
  if(not list) then return end 
  if(type(list) ~= "table") then error("type must be a table. but now \"" .. type(list) .. "\"") end
  if(list.is and list:is(List)) then
    for i = 1, list:Size() do
      local item = list:get_at(i)
      self:add(item)
    end
  else
    local size = select('#', table.unpack(list))
    for i = 1, size do 
      local item = list[i]
      self:add(item)
    end
  end
end

function ArrayList:values()
  return self.data
end

return ArrayList