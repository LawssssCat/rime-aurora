--[[

关于CJK扩展字符
  CJK = 中日韩（China, Japan, Korea），这个主要是指的东亚地区使用汉字及部分衍生偏僻字的字符集
  （由于其使用频率非常低，一般的电脑系统里没有相关的字符，因此不能显示这些字）

查询unicode 编码
  1. https://unicode.org/charts/

导出函数
  1. charset_filter: 滤除含 CJK 扩展汉字的候选项
  2. charset_comment_filter: 为候选项加上其所属字符集的注释

--]]

local string_helper = require("tools/string_helper")

local charset = {
  { name = "CJK", first = 0x4E00, last = 0x9FFF },     -- CJK Unified Ideographs - https://unicode.org/charts/PDF/U4E00.pdf
  { name = "ExtA", first = 0x3400, last = 0x4DBF },    -- CJK Unified Ideographs Extension A - https://unicode.org/charts/PDF/U3400.pdf
  { name = "ExtB", first = 0x20000, last = 0x2A6DF },  -- CJK Unified Ideographs Extension B - https://unicode.org/charts/PDF/U20000.pdf
  { name = "ExtC", first = 0x2A700, last = 0x2B73F },  -- CJK Unified Ideographs Extension C - https://unicode.org/charts/PDF/U2A700.pdf
  { name = "ExtD", first = 0x2B740, last = 0x2B81F },  -- CJK Unified Ideographs Extension D - https://unicode.org/charts/PDF/U2B740.pdf
  { name = "ExtE", first = 0x2B820, last = 0x2CEAF },  -- CJK Unified Ideographs Extension E - https://unicode.org/charts/PDF/U2B820.pdf
  { name = "ExtF", first = 0x2CEB0, last = 0x2EBEF },  -- CJK Unified Ideographs Extension F - https://unicode.org/charts/PDF/U2CEB0.pdf
  { name = "ExtG", first = 0x30000, last = 0x3134A },  -- CJK Unified Ideographs Extension G - https://unicode.org/charts/PDF/U30000.pdf
  { name = "Compat", first = 0x2F800, last = 0x2FA1F } -- CJK Compatibility Ideographs Supplement - https://unicode.org/charts/PDF/U2F800.pdf
}

local function get_utf8_code(c)
  for index, obj in pairs(charset) do
    local code = utf8.codepoint(c, 1)
    if(code >= obj.first and code <= obj.last) then
      return {
        code = code,
        name = obj.name
      }
    end
  end
  return nil
end

--[[
为候选项加上其所属字符集的注释：
--]]
local function charset_comment_filter(input, env)
  local option = env.engine.context:get_option("option_charset_comment_filter") -- 开关
  -- 使用 `iter()` 遍历所有输入候选项
  for cand in input:iter() do
    local text = cand.text
    local len = utf8.len(cand.text)
    local flag01 = not string.match(text, "^[%w]*$") -- 非纯字母/数字
    if(option and flag01 and len == 1) -- 只对单字显示编码
    -- if(option and flag01)
    then
      local m_arr = {}
      for i = 1, len do
        local c = string_helper.sub(text, i, i)
        local m = get_utf8_code(c)
        if(m) then
          table.insert(m_arr, c .. "=" .. string.format("0x%x", m.code) .. "(" .. m.name .. ")")
        end
      end
      if(#m_arr > 0) then
        local comment = "|" .. table.concat(m_arr, ", ") .. "| "
        cand:get_genuine().comment = comment .. cand.comment
      end
    end -- option
    -- 在结果中对应产生一个带注释的候选
    yield(cand)
  end
end

return { 
  comment_filter = charset_comment_filter 
}