local logger = require("tools/logger")
local rime_api_helper = require("tools/rime_api_helper")
local string_helper = require("tools/string_helper")

local option_name = "ascii_mode"

-- =============================================================== filter

local pure_filter = {}

function pure_filter.init(env)
end

function pure_filter.fini(env)
end

local function yield_raw_input(env)
  local context = env.engine.context
  local input = context.input
  if(input and #input>0) then
    local cand = Candidate("raw", 1, #input, input, "〔英文〕")
    yield(cand)
  end
end

function pure_filter.func(input, env)
  if(env.option_ascii_mode) then
    yield_raw_input(env)
    for cand in input:iter() do
      if(string_helper.is_ascii_visible_string(cand.text)) then -- ascii visible
        yield(cand)
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
  local context = env.engine.context
  env.option_ascii_mode = context:get_option(option_name)

  if(env.option_ascii_mode) then
    if(not rime_api_helper:get_prompt_map_item("easy_en")) then -- 减少调用 property 次数
      rime_api_helper:add_prompt_map(context, "easy_en", "⚙(纯英文~\"Shift\"开/关)")
    end
  else
    if(rime_api_helper:get_prompt_map_item("easy_en")) then
      rime_api_helper:clear_prompt_map(context, "easy_en")
    end
  end
  return true
end

return {
  filter = pure_filter,
}