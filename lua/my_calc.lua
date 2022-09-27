
local logger = require("tools/logger")
local rime_api_helper = require("tools/rime_api_helper")
local string_helper = require("tools/string_helper")
local ptry = require("tools/ptry")
local Stack = require("tools/collection/stack")
local string_calc = require("tools/string_calc")

-- ============================================================= translator

local translator = {}

function translator.func(input, seg, env)
  if(seg:has_tag("calc")) then
    local input_waiting = string.sub(input, seg._start+1, seg._end)
    local formula = string.match(input_waiting, "=(.*)$")
    if(not formula or #formula==0) then
      local cand = Candidate("calc", seg.start, seg._end, "[0-9]+-*/^%", "〔等待输入...〕")
        cand.preedit = input_waiting
        yield(cand)
    else
      ptry(function()
        local result = string_calc.calc(formula)
        local cand = Candidate("calc", seg.start, seg._end, tostring(result), "〔计算结果〕")
        cand.preedit = input_waiting
        yield(cand)
      end)
      ._catch(function(err)
        logger.error("fail to calc", formula, err)
        local msg = string.match(err, "(my_calc.*)") or ""
        local cand = Candidate("calc", seg.start, seg._end, msg, "〔计算异常〕")
        cand.preedit = input_waiting
        yield(cand)
      end)
    end
  end
end

return {
  translator = translator
}