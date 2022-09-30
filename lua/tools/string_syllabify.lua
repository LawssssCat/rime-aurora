--[[
  功能：按音节分词

  规则：
    1. “独立韵母” 独立成字
    2. “声母”+“韵母” 成字
]]

local string_helper = require("tools/string_helper")

-- 声母表
local smb = {"b", "p", "m", "f", "d", "t", "l", "n", "g", "h", "k", "j", "q", "x", "z", "c", "s", "r", "y", "w", "zh", "ch", "sh"}

-- 韵母表
local ymb = {
  "iang", "iong", "uang",
  "ang", "ong", "eng", "ing", "iao", "ian", "uai", "uan",
  "an", "ao", "ai", "ou", "en", "er", "ei",
  "ia", "iu", "ie", "in", "un", "ua", "uo", "ue", "ui",
  "a", "o", "e", "i", "u", "v"
}

-- 独立韵母表
local dlymb = {"ang", "ong", "eng", "ai", "an", "ao", "ou", "en", "er", "o", "a", "e"}

-- 规则：“独立韵母” 独立成字
local function find_word_dlym(str, _start)
  local rs = {}
  for i, dlym in pairs(dlymb) do
    -- 匹配 独立韵母
    if(string.find(str, dlym, _start, true) == _start) then
      table.insert(rs, dlym)
    end
  end
  return rs
end

-- 规则：“声母”+“韵母” 成字
local function find_word_sm_ym(str, _start)
  local rs = {}
  for i, sm in pairs(smb) do
    -- 匹配 声母
    if(string.find(str, sm, _start, true) == _start) then
      local _start_ym = _start + #sm
      -- 匹配 韵母
      for j, ym in pairs(ymb) do
        if(string.find(str, ym, _start_ym, true) == _start_ym) then
          table.insert(rs, sm .. ym)
        end
      end
    end
  end
  return rs
end

local function arr_insert_all(o, vs)
  for i, v in pairs(vs) do
    table.insert(o, v)
  end
  return o
end

local function find_word(str, _start)
  local rs = {}
  local rs1 = find_word_dlym(str, _start)
  local rs2 = find_word_sm_ym(str, _start)
  arr_insert_all(rs, rs1)
  arr_insert_all(rs, rs2)
  return rs
end

--[[
  @param str 待拆分的全拼编码，如：nihao
  @return 全部音节拆分组合，如：{{"ni","hao"}, {"ni","ha","o"}}
]]
local function split_word(str)
  if(type(str)~="string") then error("the excepted type is \"string\". but now is \""..type(str).."\"") end
  local len = #str
  local rs = {}
  local words_list = find_word(str, 1)
  while(#words_list>0) do
    local words = table.remove(words_list, 1)
    words = type(words)=="table" and words or {words}
    local _start = 1
    for i, word in pairs(words) do
      _start = _start + #word
    end
    if(_start>len) then
      table.insert(rs, words)
    else
      local new_word_list = find_word(str, _start)
      for i, new_word in pairs(new_word_list) do
        local new_words = {}
        arr_insert_all(new_words, words)
        table.insert(new_words, new_word)
        table.insert(words_list, new_words)
      end
    end
  end
  return rs
end

--[[
  @param str 待拆分的全拼编码，如：nihao
  @return 全部音节拆分组合，如：{{"ni","hao"}, {"ni","ha","o"}}
]]
local function syllabify(str, delimiter)
  if(type(str)~="string") then error("the excepted type is \"string\". but now is \""..type(str).."\"") end
  if(not delimiter) then delimiter = " " end
  local rs = {}
  local split = string_helper.split(str, delimiter)
  for i, s in pairs(split) do
    local words_list = split_word(s)
    local parts = {}
    for j, words in pairs(words_list) do
      local part = string_helper.join(words, delimiter)
      table.insert(parts, part)
    end
    if(#rs==0) then
      for j, part in pairs(parts) do
        table.insert(rs, part)
      end
    else
      local new_rs = {}
      for j, part in pairs(parts) do
        for k, rss in pairs(rs) do
          table.insert(new_rs, rss..delimiter..part)
        end
      end
      rs = new_rs
    end
  end
  return rs
end

return {
  split_word = split_word,
  syllabify = syllabify
}