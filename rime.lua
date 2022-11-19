-- ------------------------------------------------------------------------------------------------------------
--                                           说明
-- ------------------------------------------------------------------------------------------------------------
--[[

Wiki：https://github.com/hchunhui/librime-lua/wiki/Scripting

相关文档：
  1. 《加入 Lua 脚本扩展支持 》 - https://github.com/rime/librime/issues/248
  2. 介绍 - https://github.com/LEOYoon-Tsaw/Rime_collections/blob/master/Rime_description.md#%E4%B8%83lua
  3. 《issue：Lua 接口文档请求》 - https://github.com/hchunhui/librime-lua/issues/186
      后续wiki文档：https://github.com/hchunhui/librime-lua/wiki/Scripting
  4. 《TsinamLeung 整理的 api》 - https://github.com/TsinamLeung/librime-lua/wiki/API
--]]

-- ------------------------------------------------------------------------------------------------------------
--                                           环境初始化
-- ------------------------------------------------------------------------------------------------------------

-- ⚠️ 注意： 【全局定义】扩展require功能 - 可以加载请求文件所相对路径的文件
require = require("tools/ext_require")()

--[[
  
  ⚠️ 注意：
  
  注册 
    register("my_symbols")
  等于定义了：
    my_symbols_processor
    my_symbols_segmentor
    my_symbols_translator
    my_symbols_filter
]]
local register = require("tools/register")

-- ------------------------------------------------------------------------------------------------------------
--                                           注册模块
-- ------------------------------------------------------------------------------------------------------------

-- 【功能】："//"+"特定编码" 得到符号候选词
register("my_symbols")

-- 【功能】：限制输入编码长度（过长会导致卡顿、闪退、死机）
register("my_code")

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

register("my_easy_en", {"pure_filter"})

register("my_key_binder")

-- 【功能】：反查五笔笔画
-- 详见 https://github.com/shewer/librime-lua-script/blob/e84e9ea008592484463b6ade405c83a5ff5ab9f0/lua/component/stroke_count.lua

register("my_calc")

register("my_uniquifier")

-- 【功能】：rq输出日期、sj输出时间
-- 详见 `lua/time_translator.lua`
register("my_time")

register("my_version")

register("my_history") -- 历史上屏情况

register("my_component") -- 组件运行情况

register("my_url")

register("my_emoji")

register("my_user_dict")

register("my_prompt")

-- 【功能】：候选项重排序，使单字优先（single_char_filter）
-- 详见 https://github.com/hchunhui/librime-lua/blob/master/sample/lua/single_char.lua

-- 【功能】：依地球拼音为候选项加上带调拼音的注释
-- （不需要lua也能实现）
-- 详见 https://github.com/hchunhui/librime-lua/blob/master/sample/lua/reverse.lua
-- 详见 `lua/reverse.lua`
-- register("my_reverse")

-- 【功能】：use wildcard to search code
-- 详见 https://github.com/hchunhui/librime-lua/blob/master/sample/lua/expand_translator.lua

-- 【功能】：通过选择自定义的候选项来切换开关（以简繁切换和下一方案为例）（switch_processor）
-- 详见 https://github.com/hchunhui/librime-lua/blob/master/sample/lua/switch.lua

-- 【功能】：利用 librime-lua 擴展 rime 輸入法的集成模組
-- https://github.com/shewer/librime-lua-script
-- init_processor = require('init_processor')

