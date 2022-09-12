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

testaa = require("test/test_string")

-- os.exit( lu.LuaUnit.run() )
runner = lu.LuaUnit.new()
runner:setOutputType("tap") -- Test Anything Protocol https://testanything.org/
os.exit( runner:runSuite() )