--[[
  功能：按音节分词

  规则：
    1. “独立韵母” 独立成字
    2. “声母”+“韵母” 成字
]]

local string_helper = require("tools/string_helper")

-- -------------------------------------
-- 基本数据
-- -------------------------------------

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

-- -------------------------------------
-- 拆分规则
-- -------------------------------------

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
-- 規則：“声母+『不完整』韵母” 成字
local function find_word_sm_dlym_part(str, _start)
  local len = #str
  local rs = {}
  for i, sm in pairs(smb) do
    -- 匹配 声母
    if(string.find(str, sm, _start, true) == _start) then
      local part = sm -- 不完整的『字』
      local _start_2 = _start + #sm
      for j = _start_2, len do
        local match = false -- 是否匹配到下一个“声母”or“独立韵母”
        if(not match) then
          -- 查找 下一个声母
          for k, sm in pairs(smb) do
            if(string.find(str, sm, j, true) == j) then
              match = true
              break
            end
          end
        end
        if(not match) then
          -- 查找下一个独立韵母
          for k, dlym in pairs(dlymb) do
            if(string.find(str, dlym, j, true) == j) then
              match = true
              break
            end
          end
        end
        if(match) then
          part = part .. string.sub(str, _start_2, j-1)
          break
        end
      end
      table.insert(rs, part)
    end
  end
  return rs
end

-- --------------------------------
-- 整合规则
-- --------------------------------

local function arr_insert_all(o, vs)
  for i, v in pairs(vs) do
    table.insert(o, v)
  end
  return o
end

local function find_word(str, _start, part)
  local rs = {}
  local rs1 = find_word_dlym(str, _start)
  local rs2 = find_word_sm_ym(str, _start)
  arr_insert_all(rs, rs1)
  arr_insert_all(rs, rs2)
  if(part==true and #rs==0) then -- 如果找不到完整词，找部分词
    local rs3 = find_word_sm_dlym_part(str, _start)
    arr_insert_all(rs, rs3)
  end
  return rs
end

-- --------------------------------
-- 对外接口
-- --------------------------------

--[[
  @param str  string 待拆分的全拼编码，如：nihao
  @param part boolean 是否匹配不完整音节
  @return 全部音节拆分组合，如：{{"ni","hao"}, {"ni","ha","o"}}
]]
local function split_word(str, part)
  if(type(str)~="string") then error("the excepted type is \"string\". but now is \""..type(str).."\"") end
  local len = #str
  local rs = {}
  local words_list = find_word(str, 1, part)
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
      local new_word_list = find_word(str, _start, part)
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

  str, [[delimiter, ]part]

  @param str string 待拆分的全拼编码，如：nihao
  @param delimiter string 连接符
  @param part boolean 是否匹配不完整音节（默认 false）
  @return 全部音节拆分组合，如：{{"ni","hao"}, {"ni","ha","o"}}
]]
local function syllabify(str, delimiter, part)
  if(type(str)~="string") then error("the excepted type is \"string\". but now is \""..type(str).."\"") end
  if(part == nil) then
    if(type(delimiter) == "boolean") then
      part = delimiter
      delimiter = nil
    else
      part = false
    end
  end
  if(delimiter == nil) then delimiter = " " end
  local rs = {}
  local split = string_helper.split(str, delimiter)
  for i, s in pairs(split) do
    local words_list = split_word(s, part)
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