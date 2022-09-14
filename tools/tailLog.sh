# 脚本来源 issue https://github.com/hchunhui/librime-lua/issues/129
# 先下载 cmder https://github.com/cmderdev/cmder 以运行 linux 命令
# for windows
tail -f ~/AppData/Local/Temp/rime*INFO*  | awk  '
BEGIN { e="\033[31;1m" ; w="\033[33;1m" ; r="\033[0m" }
/^I/ { printf r }
/^W/ { printf w }
/^E/ { printf e }
{print $0}
'
# https://blog.csdn.net/u014470361/article/details/81512330
# \033[0m 关闭所有属性
# \33[31;1m 设置红色高亮度 
# \33[33;1m 设置黄色高亮度 
