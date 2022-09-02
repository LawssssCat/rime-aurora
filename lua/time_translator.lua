-- rq输出日期、sj输出时间
-- 参考：
-- https://github.com/LEOYoon-Tsaw/Rime_collections/blob/master/Rime_description.md#%E7%A4%BA%E4%BE%8B-9
-- https://www.zhihu.com/question/268770492/answer/2190114796
-- https://zhuanlan.zhihu.com/p/471429749

local function getWeek()
  local day_w=os.date("%w")
  local day_w1=""
  local day_w2=""
  local day_w3=""
  if day_w=="0" then 
    day_w1="星期日" 
    day_w2="Sunday" 
    day_w3="Sun." 
  end
  if day_w=="1" then
    day_w1="星期一" 
    day_w2="Monday" 
    day_w3="Mon." 
  end
  if day_w=="2" then
    day_w1="星期二" 
    day_w2="Tuesday" 
    day_w3="Tues." 
  end
  if day_w=="3" then 
    day_w1="星期三" 
    day_w2="Wednesday" 
    day_w3="Wed." 
  end
  if day_w=="4" then 
    day_w1="星期四" 
    day_w2="Thursday" 
    day_w3="Thur." 
  end
  if day_w=="5" then 
    day_w1="星期五"  
    day_w2="Friday" 
    day_w3="Fri." 
  end
  if day_w=="6" then 
    day_w1="星期六" 
    day_w2="Saturday" 
    day_w3="Sat." 
  end
  return {
    cn=day_w1,
    en=day_w2,
    en_l=day_w3
  }
end

local function getDate_en()
  --英文日期          date_m1="Jan." date_m2="January"       symbal
  local date_d=os.date("%d")
  local date_m=os.date("%m")
  local date_y=os.date("%Y")
  local symbal=""
  local date_m1=""
  local date_m2=""

  if date_m=="01" then 
    date_m1="Jan."
    date_m2="January"
  end
  if date_m=="02" then 
    date_m1="Feb."
    date_m2="February"
  end
  if date_m=="03" then 
    date_m1="Mar."
    date_m2="March"
  end
  if date_m=="04" then 
    date_m1="Apr."
    date_m2="April"
  end
  if date_m=="05" then 
    date_m1="May."
    date_m2="May"
  end
  if date_m=="06" then 
    date_m1="Jun."
    date_m2="June"
  end
  if date_m=="07" then 
    date_m1="Jul."
    date_m2="July"
  end
  if date_m=="08" then 
    date_m1="Aug."
    date_m2="August"
  end
  if date_m=="09" then 
    date_m1="Sept."
    date_m2="September"
  end
  if date_m=="10" then 
    date_m1="Oct."
    date_m2="October"
  end
  if date_m=="11" then 
    date_m1="Nov."
    date_m2="November"
  end
  if date_m=="12" then 
    date_m1="Dec."
    date_m2="December"
  end

  if date_d=="0" then 
    symbal="st" 
  elseif date_d=="1" then
    symbal="nd" 
  elseif date_d=="2" then 
    symbal="rd" 
  else
    symbal="th"
  end

  return {
    en=date_m2.." "..date_d..symbal..","..date_y,
    en_l=date_m1..""..date_d..symbal..","..date_y
  }
end

local function time_translator(input, seg, env)
  if (input == "rq" or input == "riqi" or input == "date") then
    -- 日期
    -- cand.quality = 1
    local tip = "〔日期〕"
    yield(Candidate("date", seg.start, seg._end, os.date("%Y.%m.%d"), tip))
    yield(Candidate("date", seg.start, seg._end, os.date("%Y/%m/%d"), tip))
    -- yield(Candidate("date", seg.start, seg._end, os.date("%Y/%m/%d %H:%M:%S"), ""))
    yield(Candidate("date", seg.start, seg._end, os.date("%Y-%m-%d"), tip))
    -- yield(Candidate("date", seg.start, seg._end, os.date("%Y-%m-%d %H:%M:%S"), ""))
    yield(Candidate("date", seg.start, seg._end, os.date("%Y年%m月%d日"), tip))
    -- yield(Candidate("date", seg.start, seg._end, os.date("%Y年%m月%d日 %H:%M:%S"), ""))
    local date_en = getDate_en()
    yield(Candidate("date", seg.start, seg._end, date_en.en, tip))
    -- yield(Candidate("date", seg.start, seg._end, date_en.en..os.date(" %H:%M:%S"), ""))
    yield(Candidate("date", seg.start, seg._end, date_en.en_l, tip))
    -- yield(Candidate("date", seg.start, seg._end, date_en.en_l..os.date(" %H:%M:%S"), ""))
  elseif (input == "sj" or input == "shijian" or input == "time") then
    -- 时间
    -- cand.quality = 1
    local tip = "〔时间〕"
    yield(Candidate("time", seg.start, seg._end, os.date("%H:%M"), tip))
    yield(Candidate("time", seg.start, seg._end, os.date("%H:%M:%S"), tip))
    yield(Candidate("time", seg.start, seg._end, os.date("%H点%M分"), tip))
    yield(Candidate("time", seg.start, seg._end, os.date("%H点%M分%S秒"), tip))
  elseif (input == "xq" or input == "xingqi" or input == "week") then
    -- 星期
    local tip = "〔星期〕"
    local week = getWeek();
    yield(Candidate("week", seg.start, seg._end, week.cn, tip))
    yield(Candidate("week", seg.start, seg._end, week.en, tip))
    yield(Candidate("week", seg.start, seg._end, week.en_l, tip))
  end
end

return time_translator
