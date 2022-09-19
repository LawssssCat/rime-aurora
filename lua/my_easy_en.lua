local logger = require("tools/logger")
local rime_api_helper = require("tools/rime_api_helper")

-- =============================================================== filter

local pure_filter = {}

function pure_filter.init(env)
end

function pure_filter.fini(env)
end

function pure_filter.func(input, env)
  if(env.option_ascii_mode) then
    for cand in input:iter() do
      if(string.match(cand.text, "^[\x20-\x7f]+$")) then -- ascii visible
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
  env.option_ascii_mode = context:get_option("ascii_mode")

  if(env.option_ascii_mode) then
    seg.prompt = "⚙(纯英文~\"Shift\"开/关)" .. seg.prompt
  end
  return true
end

return {
  pure_filter = pure_filter,
}