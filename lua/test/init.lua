--[[
  run in /lua directory

  ```lua
    lua test/init.lua -v
  ```

  luaunit 单元测试:
  - 官网 https://github.com/bluebird75/luaunit
  - 文档 https://luaunit.readthedocs.io/en/latest/
  - 命令行参数 https://luaunit.readthedocs.io/en/latest/#command-line-options
  - api https://luaunit.readthedocs.io/en/latest/#equality-assertions
--]]
lu = require("tools/luaunit")

local function mute(M) -- 静音：禁止print
  for key, value in pairs(M) do 
    if(type(value) == "function") then
      M[key] = function(...)
        local _print = print
        print = function() end
        local temp_result = {pcall(value, ...)}
        print = _print
        local flag = table.remove(temp_result, 1)
        local result = temp_result
        if(flag) then 
          return table.unpack(result)
        else
          error("\n"..result[1])
        end
      end
    end
  end
  return M
end

print(os.clock())
print(os.time())
print(os.date("%Y%m%d%H%M%S"))
print(string.format("%s%s", os.date("%Y%m%d%H%M%S"), math.random(10, 99)))

-- ================================================================ 单元测试内容 start

-- 单元测试链条
-- string
test_basic = require("test/test_basic")
test_string = require("test/test_string")
-- 异常
test_error = require("test/test_error")
-- ptry：异常链式处理
test_ptry = require("test/test_ptry")
-- 调试
test_debug = require("test/test_debug")
test_debug = mute(test_debug) -- 想看输出，注释之
-- logger
test_logger = require("test/test_logger")
test_logger = mute(test_logger) -- 想看输出，注释之
-- 转换：格式化 table => string 
test_inspect = require("test/test_inspect")
-- 转换：1 => 一
test_number = require("test/test_number")
-- table
test_table = require("test/test_table")

-- ================================================================ 单元测试内容 end

-- os.exit( lu.LuaUnit.run() )
runner = lu.LuaUnit.new()
runner:setOutputType("tap") -- Test Anything Protocol https://testanything.org/
os.exit( runner:runSuite() )