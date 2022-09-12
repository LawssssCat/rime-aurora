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
        local result = value(...)
        print = _print
        return result
      end
    end
  end
  return M
end

-- 单元测试链条
test_string = require("test/test_string")
test_debug = require("test/test_debug")
test_debug = mute(test_debug) -- 想看输出，注释之
test_logger = require("test/test_logger")
-- test_logger = mute(test_logger) -- 想看输出，注释之
test_inspect = require("test/test_inspect")

-- os.exit( lu.LuaUnit.run() )
runner = lu.LuaUnit.new()
runner:setOutputType("tap") -- Test Anything Protocol https://testanything.org/
os.exit( runner:runSuite() )