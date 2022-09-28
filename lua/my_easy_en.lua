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

function pure_filter.func(input, env)
  if(env.option_ascii_mode) then
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
    rime_api_helper:add_prompt_map("easy_en", "⚙(纯英文~\"Shift\"开/关)")
  end
  return true
end

return {
  filter = pure_filter,
}