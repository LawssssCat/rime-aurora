
local logger = require("tools/logger")
local string_helper = require("tools/string_helper")
local rime_api_helper = require("tools/rime_api_helper")

local component_func_names = {"init", "func", "fini"}

-- ============================================================= translator

local translator = {}

function translator.init(env)
end

function translator.fini(env)
end

function translator.func(input, seg, env)
  if(seg:has_tag("component")) then
    local component_run_info = rime_api_helper:get_component_run_info()
    for component_name, component_info in pairs(component_run_info) do
        for i, function_name in pairs(component_func_names) do
            -- info
            local count = component_info[function_name.."_count"]
            local duration_max = component_info[function_name.."_duration_max"]
            local duration_min = component_info[function_name.."_duration_min"]
            local duration_avg = component_info[function_name.."_duration_avg"]
            local info = {
                count = count and count or "-",
                duration_max = duration_max and string.format("%0.4fs", duration_max) or "-------",
                duration_min = duration_min and string.format("%0.4fs", duration_min) or "-------",
                duration_avg = duration_avg and string.format("%0.4fs", duration_avg) or "-------",
            }
            -- show
            local text = component_name.."."..function_name
            local comment = string_helper.format("📊 count:\"{count}\", avg:\"{duration_avg}\", max:\"{duration_max}\", min:\"{duration_min}\"）", info)
            -- cand
            local cand = Candidate("component", seg.start, seg._end, text, comment)
            local cand_uniq = UniquifiedCandidate(cand, cand.type, cand.text, cand.comment)
            yield(cand_uniq)
        end
    end
    for iter in temp:iter() do
      local item = iter.value
      local text = item.text
      local comment = string_helper.format("（💬:\"{preedit}\",✍🏻️:{dynamic_type}-{type},🏆:{quality}）", item)
      local cand = Candidate("history", seg.start, seg._end, text, comment)
      local cand_uniq = UniquifiedCandidate(cand, cand.type, cand.text, cand.comment)
      -- cand.quality = -199
      yield(cand_uniq)
    end
  end
end

return {
  translator = translator
}