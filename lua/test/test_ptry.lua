--[[
  测试 lua 异常处理
]]

assert(lu, "请通过 test/init.lua 运行本测试用例")

local ptry = require("tools/ptry")
local string_helper = require("tools/string_helper")

local M = {}

function M:test_basefunc() -- 测试基本功能：链式调用、异常捕获
  -- 结果
  local token = {}
  -- 测试
  local promise = ptry(function(...)
    for index, arg in pairs({...}) do
      table.insert(token, arg)
    end
    return "ok", "_1"
  end, "hello", "world")
  ._then(function(result_1, result_2) -- 接收上一个结果
    table.insert(token, result_1..result_2)
    return "ok_2" -- 继续往下传结果
  end)
  ._then(function(result) -- 继续接收新的结果
    table.insert(token, result)
    -- 返回空
  end)
  ._then(function(result) -- 接收nil不报错
    table.insert(token, result or "ok_3")
    return ptry(function() -- 调用新的 ptry
      return "sub_ok_1"
    end)
  end)
  ._then(function(result) -- 接收新的 ptry 的返回
    table.insert(token, result)
    return "sub", "_ok", "_2"
  end)

  promise._then(function(result_1, result_2, result_3)
    table.insert(token, result_1..result_2..result_3)
    error("my_error") -- 报错
    return "sub_ok_3"
  end)
  ._then(function(result) -- 不执行
    table.insert(token, result)
    table.insert(token, "ssfsdfdfasdfasfa 不执行 sfsadfdsafsdfsda")
    table.insert(token, "ssfsdfdfasdfasfa 不执行 sfsadfdsafsdfsda")
    table.insert(token, "ssfsdfdfasdfasfa 不执行 sfsadfdsafsdfsda")
    table.insert(token, "ssfsdfdfasdfasfa 不执行 sfsadfdsafsdfsda")
    table.insert(token, "ssfsdfdfasdfasfa 不执行 sfsadfdsafsdfsda")
    table.insert(token, "ssfsdfdfasdfasfa 不执行 sfsadfdsafsdfsda")
    table.insert(token, "ssfsdfdfasdfasfa 不执行 sfsadfdsafsdfsda")
  end)
  ._catch(function(err)
    local split_error = string_helper.split(err, ": ") -- e.g. .\test/test_ptry.lua:42: my_error
    table.insert(token, split_error[2])
  end)
  table.insert(token, "smail")
  -- 判断结果
  lu.assertEquals(token, {"hello", "world", "ok_1", "ok_2", "ok_3", "sub_ok_1", "sub_ok_2", "my_error", "smail"})
end

return M