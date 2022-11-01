require = require("tools/ext_require")() -- 【全局定义】扩展require以获取请求文件所相对路径的文件
local string_helper = require("tools/string_helper")
local table_helper = require("tools/table_helper")
local LinkedList = require("tools/collection/linked_list")
local logger = require("tools/logger")
local Clock = require("tools/clock")
local ptry = require("tools/ptry")

local base_dir = "../opencc/"
local function runOpencc(title, sources, target, opts)
  -- 参数
  opts = opts or {}
  local _option_set_word_into_tips = true ;if(opts.set_word_into_tips~=nil) then _option_set_word_into_tips = opts.set_word_into_tips end
  -- 计时
  local clock = Clock(title)
  -- 解析文件行
  clock:save("解析文件行")
  local record = {}
  local word_index_map = {}
  local word_info_list = LinkedList()
  for i, source in pairs(sources) do
    local l = 0
    local ok = 0
    local er = 0
    local path = base_dir .. source
    for line in io.lines(path) do
      l = l + 1
      local word = nil
      local tips = nil
      ptry(function()
        if(not line or line=="" or string.match(line, "^#")) then return end -- 忽略 "" "# xxxxx"
        local split = string_helper.split(line, "\t")
        -- local word = string_helper.trim(split[1])
        word = split[1] -- 有 " " 空格 key
        tips = string_helper.trim(split[2])
        if(string_helper.empty(word)) then
          error("empty word")
        end
        if(string_helper.empty(tips)) then
          error("empty tips")
        end
        local word_index = word_index_map[word]
        if(word_index) then
          local word_info = word_info_list:get_at(word_index)
          word_info.tips = word_info.tips .. " " .. tips
        else
          local word_info = {
            word = word,
            tips = tips
          }
          word_info_list:add(word_info)
          word_index_map[word] = word_info_list:Size()
        end
        ok = ok + 1
      end)
      ._catch(function(err)
        er = er + 1
        logger.error(err, source, i, l, string.format("word: \"%s\", tips: \"%s\", line: \"%s\"", word, tips, line))
      end)
    end
    record[i] = {
      ok = ok,
      er = er,
      line = l,
      path = path,
    }
  end
  -- 处理数据
  clock:save("处理数据")
  -- + [1-9A-Za-z] len 排序
  clock:sub_save("排序")
  word_info_list:sort(function(a,b)
    return a.word < b.word
  end)
  -- + set_word_into_tips
  if(_option_set_word_into_tips) then
    clock:sub_save("反显")
    for iter in word_info_list:iter() do
      local word_info = iter.value
      local word = word_info.word
      local tips = word_info.tips
      word_info.tips = word .. " " .. tips
    end
  end
  -- + tips 去重
  clock:sub_save("去重")
  for iter in word_info_list:iter() do
    local word_info = iter.value
    local word = word_info.word
    local tips = word_info.tips
    local split = string_helper.split(tips, "%s+")
    split = table_helper.arr_remove_duplication(split)
    tips = string_helper.join(split, " ")
    word_info.tips = tips
  end
  -- 输出文件
  clock:save("输出文件")
  local target_file = io.open(base_dir .. target, "w")
  target_file:setvbuf("line")
  for iter in word_info_list:iter() do
    local word_info = iter.value
    local word = word_info.word
    local tips = word_info.tips
    target_file:write(word .. "\t" .. tips .."\n")
  end
  target_file:close()
  -- 打印信息
  logger.info(record)
  logger.info(clock)
end

-- kemoji 颜表情
runOpencc("kemoji", {
  'kemoji_base.yml',
  'kemoji_meow.yml',
}, 
'kemoji_all.txt');

-- emoji 表情
runOpencc("emoji", {
  'emoji_category.yml',
  'emoji_word.yml',
  'emoji_2021t.yml',
  'emoji_getemoji.yml'
},
'emoji_all.txt')

-- 标点/符号
runOpencc("back_mark", {
  'back_mark_ocm.yml',
},
'back_mark_all.txt',
{
  set_word_into_tips = false -- 关键字 添加入 提示队列
});
