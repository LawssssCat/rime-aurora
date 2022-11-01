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

function helper.merge_array(source, distance)
  for k,v in pairs(source) do
    table.insert(distance,v)
  end
end

return helper
