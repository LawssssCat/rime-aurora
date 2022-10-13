local LinkedList = require("tools/collection/linked_list")

local CycleList = LinkedList:extend()

function CycleList:new(max_size)
  CycleList.super.new(self)
  self:set_max_size(max_size)
end

function CycleList:set_max_size(max_size)
  local max = tonumber(max_size) or 1
  self.max_size = max > 0 and max or 1
end

function CycleList:get_max_size()
  return self.max_size
end

local function adjust_size(my)
  while((my:Size()+1) > my.max_size) do
    my:remove_at(1)
  end
end

function CycleList:add_at(index, item)
  adjust_size(self)
  CycleList.super.add_at(self, index, item)
end

function CycleList:add(item)
  adjust_size(self)
  CycleList.super.add(self, item)
end

return CycleList