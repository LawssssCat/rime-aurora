--[[

  【下标1开始】

  双向链表实现
]]

local List = require("tools/collection/list")
local Object = require("tools/classic")

-- =============================================== Node

local Node = Object:extend()

function Node:new(data, prev, _next)
  self.data = data
  self.next = _next
  self.prev = prev
end

function Node:destroy()
  self.data = nil
  self.next = nil
  self.prev = nil
end

-- ============================================= LinkedList

local function assert_index(self, index)
  if(0>=index or self.size<index) then
    error(string.format("\"%s\" out of range: (0, %s]", index, self.size))
  end
end

local LinkedList = List:extend()

function LinkedList:new(list)
  self.size = 0
  local head = Node(nil)
  local tail = Node(nil)
  head.next = tail
  tail.prev = head
  self.head = head
  self.tail = tail
  self:add_all(list)
end

function LinkedList:Size()
  return self.size
end

function LinkedList:values()
  local values = {}
  for iter in self:iter() do
    table.insert(values, iter.value)
  end
  return values
end

function LinkedList:get_at(index)
  local node = self:get_node_at(index)
  return node.data
end

function LinkedList:get_node_at(index)
  assert_index(self, index)
  if(index == self.size) then
    return self.tail.prev
  end
  local count = 1
  local node = self.head
  while count<=index do
    node = node.next
    count = count + 1
  end
  return node
end

function LinkedList:index_of(item)
  local count = 1
  local node = self.head
  while count <= self.size do
    node = node.next
    if(node.data == item) then
      return count
    end
    count = count + 1
  end
  return 0
end

function LinkedList:remove_at(index)
  local node = self:get_node_at(index)
  local prev = node.prev
  local _next = node.next
  prev.next = _next
  _next.prev = prev
  local value = node.data
  node:destroy()
  self.size = self.size - 1
  return value
end

function LinkedList:add_at(index, item)
  if(index == (self.size+1)) then
    self:add(item)
    return 
  end
  assert_index(self, index)
  local _next = self:get_node_at(index)
  local prev = _next.prev
  local node = Node(item, prev, _next)
  prev.next = node
  _next.prev = node
  self.size = self.size + 1
end

function LinkedList:add(item)
  local tail = self.tail
  local prev = tail.prev
  local node = Node(item, prev, tail)
  prev.next = node
  tail.prev = node
  self.size = self.size + 1
end

function LinkedList:remove()
  local index = self.size
  local result = self:remove_at(index)
  return result
end

function LinkedList:iter()
  local list = self
  local node = self.head
  local tail = self.tail
  local count = 0
  local index = 0
  local iter = {}
  function iter:remove()
    if(self.removed == false) then
      local prev = node.prev
      local _next = node.next
      prev.next = _next
      _next.prev = prev
      local value = node.data
      node:destroy()
      node = prev
      list.size = list.size - 1
      index = index - 1
      self.removed = true
      return value
    else
      error(string.format("method \"remove\" had been executed once. count=%s.", count))
    end
  end
  function iter:next()
    if(self:has_next()) then
      count = count + 1
      index = index + 1
      self.index = index
      self.count = count
      node = node.next
      self.value = node.data
      self.removed = false
      return self
    end
    return nil
  end
  function iter:has_next()
    return node.next ~= tail
  end
  return iter.next, iter
end

function LinkedList:sort(compare_func)
  if(type(compare_func)~="function") then error("error type of arguments #1 \""..type(compare_func).."\". it should be \"function\".") end
  if(self:Size()<2) then return end
  local node_one = self.head.next
  local node_end = self.tail.prev
  local node_cur = node_one
  while(node_one~=node_end) do
    local node_a = node_cur
    local node_b = node_cur.next
    local a = node_a.data
    local b = node_b.data
    if(compare_func(a, b)) then
      -- do nothing ...
      -- node_a.data = a
      -- node_b.data = b
    else
      node_a.data = b
      node_b.data = a
    end
    node_cur = node_cur.next
    if(node_cur==node_end) then
      node_end = node_end.prev
      node_cur = node_one
    end
  end
end

return LinkedList