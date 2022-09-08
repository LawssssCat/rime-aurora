
---拆分字符串
---@param str string 被拆分的源字符串
---@param sep string 拆分符
function string.split(str, sep)
    local result = {}
    if str == nil or sep == nil or type(str) ~= "string" or type(sep) ~= "string" then
        return result
    end

    if string.len(sep) == 0 then
        return result
    end
    local pattern = string.format("([^%s]+)", sep)
    --print(pattern)

    string.gsub(
        str,
        pattern,
        function(c)
            result[#result + 1] = c
        end
    )

    return result
end

---连接字符串
---@param arr string 被连接的源字符串（数组）
---@param sep string 连接符
---@return 返回连接后的新串。失败返回nil和失败信息。
function string.join(arr, sep)  
    if arr == nil or sep == nil then  
        return nil, "the string array or the sub-string parameter is nil"  
    end  
    local xlen = #arr
    if xlen == 0 then  
        return ""
    end  
    local str_tmp = ""  
    for i = 1, xlen-1 do  
        str_tmp = str_tmp .. arr[i] .. sep  
    end  
    str_tmp = str_tmp .. arr[xlen]
    return str_tmp  
end
