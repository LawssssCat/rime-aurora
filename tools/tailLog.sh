# https://github.com/hchunhui/librime-lua/issues/129
# for windows
tail -f ~/AppData/Local/Temp/rime*INFO*  | awk  '
BEGIN { e="\033[31;1m" ; w="\033[33;1m" ; r="\033[0m" }
/^I/ { print r, $0, r }
/^W/ { print w, $0, r }
/^E/ { print e, $0, r }
'
# \033[0m 关闭所有属性
# \33[31;1m 设置红色高亮度 
# \33[33;1m 设置黄色高亮度 
