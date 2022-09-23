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
      后续wiki文档：https://github.com/hchunhui/librime-lua/wiki/Scripting
  4. 《TsinamLeung 整理的 api》 - https://github.com/TsinamLeung/librime-lua/wiki/API
--]]

require = require("tools/ext_require")() -- 【全局定义】扩展require以获取请求文件所相对路径的文件

--[[
  提供模块名，自动注册全部 component
]]
local component_names = {
  "processor", "segmentor", "translator", "filter"
}
local function register(module_name)
  local module = require(module_name)
  for _, name in pairs(component_names) do
    _G[module_name .. "_" .. name] = module[name]
  end
end

-- 【功能】："//"+"特定编码" 得到符号候选词
register("my_symbols")

-- 【功能】：对候选词做处理
-- 参考：https://github.com/hchunhui/librime-lua/blob/master/sample/lua/charset.lua
-- charset_filter: 滤除含 CJK 扩展汉字的候选项
-- charset_comment_filter: 为候选项加上其所属字符集的注释
-- 详见 `lua/charset.lua`
register("my_charset")

-- 【功能】：候选词详情（测试用）
register("my_debug")

register("my_matcher")

register("my_punct")

register("my_easy_en")

register("my_key_binder")

local my_key_binder = require("my_key_binder")

-- ==============================================================================
-- I. translators:
-- ==============================================================================
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--[[

关于translator

  translator 的功能是将分好段的输入串翻译为一系列候选项。

  欲定义的 translator 包含三个输入参数：
  - input: 待翻译的字符串（string）
  - seg: 包含 `start` 和 `_end` 两个属性，分别表示当前串在输入框中的起始和结束位置（Segment 对象）
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

-- 【功能】：rq输出日期、sj输出时间
-- 详见 `lua/time_translator.lua`
time_translator = require("time_translator")

-- 【功能】：反查五笔笔画
-- 详见 https://github.com/shewer/librime-lua-script/blob/e84e9ea008592484463b6ade405c83a5ff5ab9f0/lua/component/stroke_count.lua




-- ==============================================================================
-- II. filters:
-- ==============================================================================
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--[[

关于filter

  filter 的功能是对 translator 翻译而来的候选项做修饰，
  如：去除不想要的候选、为候选加注释、候选项重排序等。

  欲定义的 filter 包含两个输入参数：
  - input: 候选项列表（Translation 对象）
  - env: 可选参数，表示 filter 所处的环境

  filter 的输出与 translator 相同，也是若干候选项，也要求您使用 `yield` 产生候选项。
  不同的是，filter的候选词（cand）需要被yeild才会被保留
    ```lua
    for cand in input:iter() do
      ...
    end
    ```

  另外，可定义 filer.tags_match(seg,env) 决定是否执行 filter
  返回值 true 执行
  返回值 false 不执行
--]]
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- 【功能】：候选项重排序，使单字优先（single_char_filter）
-- 详见 https://github.com/hchunhui/librime-lua/blob/master/sample/lua/single_char.lua

-- 【功能】：依地球拼音为候选项加上带调拼音的注释
-- （不需要lua也能实现）
-- 详见 https://github.com/hchunhui/librime-lua/blob/master/sample/lua/reverse.lua
-- 详见 `lua/reverse.lua`
py_comment_filter = require("my_reverse")

-- 【功能】：use wildcard to search code
-- 详见 https://github.com/hchunhui/librime-lua/blob/master/sample/lua/expand_translator.lua

-- ==============================================================================
-- III. processors:
-- ==============================================================================
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--[[

关于processor

  processor 的功能是对按键的监听

  欲定义的 processor 包含两个输入参数：
  - key: 按键事件（KeyEvent 对象）
  - env: 可选参数，表示 filter 所处的环境

  返回不同返回值以表示按键事件是否继续往下传递
  - 0 （kRejected）输入法拒绝处理
  - 1 （kAccepted）输入法接受处理，并由本processor处理
  - 2 （kNoop）交由输入法下一个processor判断是否处理

--]]
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- 【功能】：限制输入编码长度（过长会导致卡顿、闪退、死机）
code_length_limit_processor = require("my_code")

-- 【功能】：通过选择自定义的候选项来切换开关（以简繁切换和下一方案为例）（switch_processor）
-- 详见 https://github.com/hchunhui/librime-lua/blob/master/sample/lua/switch.lua

-- 【功能】：利用 librime-lua 擴展 rime 輸入法的集成模組
-- https://github.com/shewer/librime-lua-script
-- init_processor = require('init_processor')

-- ==============================================================================
-- IV. segmentors:
-- ==============================================================================
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--[[

关于segmentor

  segmentor 的功能是识别不同内容的类型，将输入码分段并加上 tag

  欲定义的 segmentor 包含两个输入参数：
  - segmentation: （Segmentation 对象）
  - env: 可选参数，表示 filter 所处的环境

  返回值为bool

--]]
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



