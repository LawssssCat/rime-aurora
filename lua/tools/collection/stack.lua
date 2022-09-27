local LinkedList = require("tools/collection/linked_list")

local Stack = LinkedList:extend()

function Stack:peek()
  if(self:Size()>0) then
    local value = self:get_at(1)
    return value
  end
  return nil
end

function Stack:push(value)
  self:add_at(1, value)
end

function Stack:pop()
  local value = self:remove_at(1)
  return value
end

return Stack