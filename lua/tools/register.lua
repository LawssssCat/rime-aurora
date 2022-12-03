local null = require("tools/null")
local ptry = require("tools/ptry")
local string_helper = require("tools/string_helper")
local table_helper = require("tools/table_helper")
local rime_api_helper = require("tools/rime_api_helper")

-- 异常 + stack info
local function throw_error(...)
  local msg = string_helper.join({null(...)}, ", ")
  local trace_info = debug.traceback("------------- debug.traceback ---------------", 2)
  error(msg.."\n"..trace_info)
end

local function get_env(args)
  if(args and type(args)=="table") then
    local env = nil
    for i,v in pairs(args) do
      env = v
    end
    if(env and type(env)=="table" and env.engine) then
      return env
    end
  end
  return nil
end

-- lua 层面捕获 lua 异常
local function run_safety(func, component_name, function_name)
  if(not func) then return nil end
  return function(...)
    local args = {...}
    local clock_start = os.clock()
    local result = nil
    ptry(function()
      result = {func(table.unpack(args))}
    end)
    ._catch(function(err)
      local input = ""
      ptry(function()
        local env = get_env(args)
        if(env) then
          local context = env.engine.context
          input = context.input
        end
      end)
      ._catch(function(frr)
        input = input .. " [fail to get env! \""..frr.."\"]"
      end)
      throw_error(string_helper.join({
        string_helper.join({"error:("..type(err)..")", err}, " "),
        string_helper.join({"duration: ", string.format("%04fms", os.clock()-clock_start)}, " "),
        string_helper.join({"component:", component_name}, " "),
        string_helper.join({"function:", function_name}, " "),
        string_helper.join({"result:", result}, " "),
        string_helper.join({"args:", args}, " "),
        string_helper.join({"input:", input}, " "),
      }, "\n"))
    end)
    local clock_end = os.clock()
    rime_api_helper:add_component_run_info({
      component_name = component_name,
      function_name = function_name,
      run_duration = clock_end-clock_start,
      env = get_env(args)
    })
    return table.unpack(result)
  end
end

-- 规范化全局变量
local function wrap_component(component_type, component_func, component_name)
  if(not component_func) then return nil end
  local t = type(component_func)
  if(t == "function") then
    return run_safety(component_func, component_name, "func")
  elseif(t == "table") then
    if(component_type=="filter" or string.find(component_type, "filter$")) then
      return {
        init = run_safety(component_func.init, component_name, "init"),
        func = run_safety(component_func.func, component_name, "func"),
        fini = run_safety(component_func.fini, component_name, "fini"),
        tags_match = run_safety(component_func.tags_match, component_name, "tags_match"),
      }
    end
    return {
      init = run_safety(component_func.init, component_name, "init"),
      func = run_safety(component_func.func, component_name, "func"),
      fini = run_safety(component_func.fini, component_name, "fini"),
    }
  end
  error("error args #component_func type \""..t.."\".")
end

--[[ 提供模块名，自动注册全部 component
  {module_name}_{component}
  e.g. my_symbols_processor
]]
local component_name_suffix = {
  "processor", "segmentor", "translator", "filter"
}
local function register(module_name, ext_component_name_suffix)
  local module = require(module_name)
  local t = type(module)
  if(t=="function" or (t=="table" and type(module.func)=="function")) then
    throw_error(string_helper.join({
[[error require("]],module_name,[[") return type "function".
please change the return to be a "table". 
excepted:
{
  filter=<function>, -- key can be "processor", "segmentor", "translator", "filter"
  or
  filter={init=<function>,func=<function>,fini=<function>},
  ...
}
actual:
]], module}, ""))
  elseif(t == "table") then
    local suffixs = {}
    table_helper.merge_array(component_name_suffix, suffixs)
    table_helper.merge_array(ext_component_name_suffix or {}, suffixs)
    for i, suffix in pairs(suffixs) do
      local component_name = module_name .. "_" .. suffix
      local component_func = module[suffix]
      local component_type = suffix
      ptry(function()
        _G[component_name] = wrap_component(component_type, component_func, component_name)
      end)
      ._catch(function(err)
        throw_error(err, i, component_type, component_func, component_name)
      end)
    end
  else
    throw_error("error require(\""..module_name.."\") return type \""..t.."\".")
  end
end

return register