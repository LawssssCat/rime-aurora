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
-- ----------------------------------------------------------------
--                  环境 - 配置
-- ----------------------------------------------------------------
require = require("tools/ext_require")() -- 全局定义

lu = require("luaunit") -- require 扩展后，不假 test 也能找到了

local string_helper = require("tools/string_helper")

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

-- ----------------------------------------------------------------
--                  环境 - 打印
-- ----------------------------------------------------------------
print("===================[path: init.lua]======================") --init.lua所在位置
print(debug.getinfo(1, "S").source)
print(debug.getinfo(1, "S").short_src)
print("===================[package.path]======================") --搜索lua模块
for index, value in pairs(string_helper.split(package.path, ";")) do 
  print(value)
end
print("==================[package.cpath]=====================") --搜索so模块
for index, value in pairs(string_helper.split(package.cpath, ";")) do 
  print(value)
end
print("==================[package.searchers]=====================") --搜索so模块
for index, value in pairs(package.searchers) do 
  if(index == 5) then
    print("--------- expand ---------")
  end
  print(value)
end
print("==================[time]=====================")
print(os.clock())
print(os.time())
print(os.date("%Y%m%d%H%M%S"))
print(string.format("%s%s", os.date("%Y%m%d%H%M%S"), math.random(10, 99)))

-- ----------------------------------------------------------------
--                  测试 - 单元
-- ----------------------------------------------------------------
print("==================[test config]=====================")
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
-- test_debug = mute(test_debug) -- 想看输出，注释之
-- logger
test_logger = require("test/test_logger")
test_logger = mute(test_logger) -- 想看输出，注释之
-- 转换：格式化 table => string 
test_inspect = require("test/test_inspect")
-- 转换：1 => 一
test_number = require("test/test_number")
-- table
test_table = require("test/test_table")
-- metatable
test_metatable = require("test/test_metatable")
-- list
test_list = require("test/test_list")
test_array_list = require("test/test_array_list")
test_linked_list = require("test/test_linked_list")
test_cycle_list = require("test/test_cycle_list")
test_stack = require("test/test_stack")
-- regex -- 更新 librime-lua，引入 rime_api.regex_match(str, pattern)
-- calc
test_string_calc = require("test/test_string_calc")

-- ----------------------------------------------------------------
--                  测试 - 运行
-- ----------------------------------------------------------------
print("==================[test run]=====================")
-- os.exit( lu.LuaUnit.run() )
runner = lu.LuaUnit.new()
runner:setOutputType("tap") -- Test Anything Protocol https://testanything.org/
os.exit( runner:runSuite() )