--[[
  异常处理
]]

-- 用以识别 table 是否 primise
local promise_identiry = {}
local function is_promise(maybe_promise)
  return maybe_promise and type(maybe_promise) == "table" and maybe_promise._ptry_promise_identiry == promise_identiry
end

--[[
  异常处理

  链式调用
  
  模仿 js 的 promise
]]
local function ptry(func, ...)
  -- 执行
  local temp_result = {pcall(func, ...)}
  -- 结果
  local pcall_flag = table.remove(temp_result, 1) -- true 无异常， false 异常
  local pcall_result = temp_result
  -- 返回
  local promise = { _ptry_promise_identiry = promise_identiry }
  promise._catch = function(func_catch)
    if(pcall_flag == false) then -- error to run
      func_catch(table.unpack(pcall_result)) -- args: error_string
    end
    return nil -- end
  end
  promise._then = function(func_then)
    if(pcall_flag == true) then -- ok to run
      local sub_promise, sub_pcall_result_1 = ptry(func_then, table.unpack(pcall_result))
      if(is_promise(sub_pcall_result_1)) then
        return sub_pcall_result_1
      else
        return sub_promise
      end
    end
    return promise
  end
  return promise, table.unpack(pcall_result)
end

return ptry