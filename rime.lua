--[[

调用方法：
  在配方文件中作如下修改：
  ```yaml
    engine:
      ...
      translators:
        ...
        - lua_translator@lua_function3
        - lua_translator@lua_function4
        ...
      filters:
        ...
        - lua_filter@lua_function1
        - lua_filter@lua_function2
        ...
  -- ```
  其中各 `lua_function` 为在本文件所定义变量名。
  ```lua
    lua_function = 调用函数
  ```
  另外：lua_translator@lua_function@config 的写法中，第三个参数为方案中的块名

调用方法初始化：
  修改本文件中 `lua_function` 所定义变量名的类型，从方法改为对象
  ```lua
    lua_function = {
      init=初始化函数
      func=调用函数
    }
  ```

相关文档：
  1. 《加入 Lua 脚本扩展支持 》 - https://github.com/rime/librime/issues/248
  2. 介绍 - https://github.com/LEOYoon-Tsaw/Rime_collections/blob/master/Rime_description.md#%E4%B8%83lua
  3. 《issue：Lua 接口文档请求》 - https://github.com/hchunhui/librime-lua/issues/186

--]]

-- ==============================================================================
-- I. translators:
-- ==============================================================================
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--[[

关于translator

  translator 的功能是将分好段的输入串翻译为一系列候选项。

  欲定义的 translator 包含三个输入参数：
  - input: 待翻译的字符串
  - seg: 包含 `start` 和 `_end` 两个属性，分别表示当前串在输入框中的起始和结束位置
  - env: 可选参数，表示 translator 所处的环境

  translator 的输出是若干候选项。
  与通常的函数使用 `return` 返回不同，translator 要求您使用 `yield` 产生候选项。
  `yield` 每次只能产生一个候选项。有多个候选时，可以多次使用 `yield` 。
  用 `yield` 产生一个候选项
  候选项的构造函数是 `Candidate`，它有五个参数：
  - type: 字符串，表示候选项的类型
  - start: 候选项对应的输入串的起始位置
  - _end:  候选项对应的输入串的结束位置
  - text:  候选项的文本
  - comment: 候选项的注释

--]]
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- rq输出日期、sj输出时间
-- 详见 `lua/time_translator.lua`
time_translator = require("time_translator")

-- ==============================================================================
-- II. filters:
-- ==============================================================================
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--[[

关于filter

  filter 的功能是对 translator 翻译而来的候选项做修饰，
  如：去除不想要的候选、为候选加注释、候选项重排序等。

  欲定义的 filter 包含两个输入参数：
  - input: 候选项列表
  - env: 可选参数，表示 filter 所处的环境

  filter 的输出与 translator 相同，也是若干候选项，也要求您使用 `yield` 产生候选项。
  不同的是，filter的候选词（cand）需要被yeild才会被保留
    ```lua
    for cand in input:iter() do
      ...
    end
    ```
--]]
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- charset_filter: 滤除含 CJK 扩展汉字的候选项
-- charset_comment_filter: 为候选项加上其所属字符集的注释
-- 详见 `lua/charset.lua`
local charset = require("charset")
charset_filter = charset.filter
charset_comment_filter = charset.comment_filter

-- single_char_filter: 候选项重排序，使单字优先
-- 详见 https://github.com/hchunhui/librime-lua/blob/master/sample/lua/single_char.lua

-- reverse_lookup_filter: 依地球拼音为候选项加上带调拼音的注释
-- 详见 https://github.com/hchunhui/librime-lua/blob/master/sample/lua/reverse.lua

-- use wildcard to search code
-- 详见 https://github.com/hchunhui/librime-lua/blob/master/sample/lua/expand_translator.lua

-- ==============================================================================
-- III. processors:
-- ==============================================================================
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- switch_processor: 通过选择自定义的候选项来切换开关（以简繁切换和下一方案为例）
-- 详见 https://github.com/hchunhui/librime-lua/blob/master/sample/lua/switch.lua

-- 利用 librime-lua 擴展 rime 輸入法的集成模組
-- https://github.com/shewer/librime-lua-script
-- init_processor = require('init_processor')
