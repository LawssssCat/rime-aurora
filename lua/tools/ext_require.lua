--[[
  从调用 require 的文件相对路径加载模块
  https://lawsssscat.blog.csdn.net/article/details/127001946
]]
table.insert(package.searchers, function(modulename)
  local call_file_path = debug.getinfo(3, "S").short_src
  local call_dir_path = string.gsub(call_file_path, "(.*)[\\/][%w-_]+.lua", "%1")
  local ext_pattern = call_dir_path .. "/" .. modulename .. ".lua"
  return loadfile(ext_pattern)
end)

return function(_require)
  return _require or require
end