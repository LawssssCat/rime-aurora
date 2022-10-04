local helper = {}

function helper.arr_remove_duplication(arr)
  local rs = {}
  local map = {}
  for i, v in pairs(arr) do
    if(not map[v]) then
      map[v] = true
      table.insert(rs, v)
    end
  end
  return rs
end

return helper
