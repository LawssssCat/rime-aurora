local my_null = "nil"

-- 遍历时得到 nil 值
-- issue https://stackoverflow.com/a/40444150/19214602
local function null(...)
  local t, n = {...}, select('#', ...)
  for k = 1, n do
     local v = t[k]
     if     v == my_null then t[k] = nil
     elseif v == nil  then t[k] = my_null
     end
  end
  return (table.unpack or unpack)(t, 1, n)
end

return null