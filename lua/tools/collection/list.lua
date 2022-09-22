--[[

  【下标1开始】

  创建对象
  List(...)

]]

local Object = require("tools/classic")

local function error_not_define()
  local method_name = debug.getinfo(2).name
  error(string.format("method \"%s\" is not defined.", method_name))
end

local List = Object:extend() -- class

-- 构造方法
function List:new()
  error_not_define()
end

function List:Size()
  error_not_define()
end

function List:get_at(index)
  error_not_define()
end

function List:index_of(item)
  error_not_define()
end

function List:remove_at(index)
  error_not_define()
end

function List:add_at(index, item)
  error_not_define()
end

function List:add(item)
  error_not_define()
end

function List:remove()
  error_not_define()
end

function List:add_all(list)
  error_not_define()
end

function List:values()
  error_not_define()
end

function List:iter()
  local list = self
  local count = 0
  local index = 0
  local iter = {}
  function iter:remove()
    if(self.removed == false) then
      list:remove_at(index)
      index = index - 1
      self.removed = true
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
      self.value = list:get_at(index)
      self.removed = false
      return self
    end
    return nil
  end
  function iter:has_next()
    return index < list:Size()
  end
  return iter.next, iter
end

return List