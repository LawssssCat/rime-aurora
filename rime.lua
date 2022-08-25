-- select_character_processor: 以词定字
-- 详见 `lua/select_character.lua`
select_character_processor = require("select_character")

-- easy_en_enhance_filter: 连续输入增强
-- 详见 `lua/easy_en.lua`
local easy_en = require("easy_en")
easy_en_enhance_filter = easy_en.enhance_filter

-- rq输出日期、sj输出时间
-- 参考：
-- https://github.com/LEOYoon-Tsaw/Rime_collections/blob/master/Rime_description.md#%E7%A4%BA%E4%BE%8B-9
-- https://www.zhihu.com/question/268770492/answer/2190114796
function time_translator(input, seg, env)
  if (input == "rq") then
    local cand = Candidate("date", seg.start, seg._end, os.date("%Y-%m-%d"), "")
    -- cand.quality = 1
    yield(cand)
  elseif (input == "sj") then
    local cand = Candidate("time", seg.start, seg._end, os.date("%H:%M"), " ")
    -- cand.quality = 1
    yield(cand)
  end
end
