assert(lu, "请通过 test/init.lua 运行本测试用例")

local List = require("tools/collection/list")

local M = {}

function M:test_method_undefined()
  local MyList = List:extend()
  function MyList:new()
  end
  local list = MyList()
  lu.assertErrorMsgMatches(".*method \".*\" is not defined.", list.Size, list)
end

function M:test_tostring()
  local MyList = List:extend()
  function MyList:new()
  end
  function MyList:Size()
    return 0
  end
  local list = MyList()
  lu.assertEquals(tostring(list), "[]")
end

return M
