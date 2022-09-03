-- select_character_processor: 以词定字
-- 详见 `lua/select_character.lua`
select_character_processor = require("select_character")

-- easy_en_enhance_filter: 连续输入增强
-- 详见 `lua/easy_en.lua`
local easy_en = require("easy_en")
easy_en_enhance_filter = easy_en.enhance_filter

-- rq输出日期、sj输出时间
time_translator = require("time_translator")


-- ===================================================================================
--- @@ single_char_filter
--[[
single_char_filter: 候選項重排序，使單字優先
--]]
function single_char_filter(input)
  local l = {}
  for cand in input:iter() do
    if (utf8.len(cand.text) == 1) then
      yield(cand)
    else
      table.insert(l, cand)
    end
  end
  for i, cand in ipairs(l) do
    yield(cand)
  end
end

--- @@ email_urlw_translator
--[[
把 recognizer 正則輸入網址使用 lua 實現，使之有選項，避免設定空白清屏時無法上屏。
該項多加「www.」
--]]
function email_urlw_translator(input, seg)
  local email_in = string.match(input, "^([a-z][-_.0-9a-z]*@.*)$")
  local www_in = string.match(input, "^(www[.][-_0-9a-z]*[-_.0-9a-z]*)$")
  local url1_in = string.match(input, "^(https?:.*)$")
  local url2_in = string.match(input, "^(ftp:.*)$")
  local url3_in = string.match(input, "^(mailto:.*)$")
  local url4_in = string.match(input, "^(file:.*)$")
  if (www_in~=nil) or (url1_in~=nil) or (url2_in~=nil) or (url3_in~=nil) or (url4_in~=nil) then
    yield(Candidate("abc", seg.start, seg._end, input , "〔URL〕"))
    return
  end
  if (email_in~=nil) then
    yield(Candidate("abc", seg.start, seg._end, email_in , "〔e-mail〕"))
    return
  end
end
