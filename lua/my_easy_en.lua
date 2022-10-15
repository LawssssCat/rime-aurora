local logger = require("tools/logger")
local rime_api_helper = require("tools/rime_api_helper")
local string_helper = require("tools/string_helper")

local option_name = "ascii_mode"

local cand_type = "easy_en"

-- =============================================================== translator

local translator = {}

function translator.init(env)
  local config = env.engine.schema.config
  env.config_enable_completion = config:get_bool(env.name_space .. "/enable_completion")==true and true or false
  env.config_initial_quality = config:get_int(env.name_space .. "/initial_quality"); if(env.config_initial_quality==nil) then env.config_initial_quality = 0 end
  env.config_tag = config:get_string(env.name_space .. "/tag") or "easy_en"
  env.config_dictionary = config:get_string(env.name_space .. "/dictionary") or "easy_en"
  env.mem = Memory(env.engine, Schema(env.config_dictionary))
  env.init_ok = true
end

function translator.func(input, seg, env)
  if(env.init_ok~=true) then logger.warn("Fail to init easy_en component!", env); return end
  if(seg:has_tag(env.config_tag)) then
    local input_waiting = string.sub(input, seg._start+1, seg._end)
    if(not input_waiting) then logger.warn("input waiting nothing.", input, seg._start, seg._end); return end
    local mem = env.mem
    local pattern = string.lower(input_waiting)
    if(mem:dict_lookup(pattern, env.config_enable_completion, 0)) then
      for entry in mem:iter_dict() do
        local text = string_helper.replace(entry.text, "^"..pattern, input_waiting)
        local cand = Candidate(cand_type, seg.start, seg._end, text, entry.comment)
        cand.quality = env.config_initial_quality
        yield(cand)
      end
    end
  end
end

-- =============================================================== filter

local pure_filter = {}

function pure_filter.init(env)
  local context = env.engine.context
  env.notifiers = {
    context.option_update_notifier:connect(function(ctx, name)
      if(name == option_name) then
        if(context:get_option(option_name)) then
          if(not rime_api_helper:get_prompt_map_item("easy_en")) then -- 减少调用 property 次数
            rime_api_helper:add_prompt_map(context, "easy_en", "⚙(纯英文~\"Shift\"开/关)")
          end
        else
          if(rime_api_helper:get_prompt_map_item("easy_en")) then
            rime_api_helper:clear_prompt_map(context, "easy_en")
          end
        end
      end
    end),
  }
end

function pure_filter.fini(env)
  for i, n in pairs(env.notifiers) do
    n:disconnect()
  end
end

local function reflect_cand(text)
  local new_cand = Candidate("raw", 1, #text, text, "〔英文〕")
  return new_cand
end

function pure_filter.func(input, env)
  local context = env.engine.context
  if(context:get_option(option_name)) then
    local first = false
    for cand in input:iter() do
      if(cand.type==cand_type or string_helper.is_ascii_visible_string(cand.text)) then
        if(not first) then
          first = true
          local text = context.input
          if(text and #text>0 and text~=cand.text) then
            yield(reflect_cand(text))
          end
        end
        yield(cand)
      end
    end
    if(not first) then
      local text = context.input
      if(text and #text>0) then
        yield(reflect_cand(text))
      end
    end
    return
  end
  -- normal
  for cand in input:iter() do
    yield(cand)
  end
end

function pure_filter.tags_match(seg, env)
  return true
end

return {
  filter = pure_filter,
  translator = translator,
}