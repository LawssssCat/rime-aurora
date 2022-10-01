
local logger = require("tools/logger")
local rime_api_helper = require("tools/rime_api_helper")
local string_helper = require("tools/string_helper")

-- ============================================================= translator

local translator = {}

local function yieldCandidate(seg, input) 
  local cand = Candidate("url", seg.start, seg._end, input, "〔网址〕")
    yield(cand)
end

function translator.func(input, seg, env)
  if(seg:has_tag("url")) then
    yieldCandidate(seg, input)
    -- 预测输入
    local predict = input
    if(rime_api_helper:regex_match(predict, "^(?!www)[^.]+[.][^.]*$")) then
      predict = "www."..predict
    end
    if(rime_api_helper:regex_match(predict, "^([^.]+[.])?[^.]+[.]?(?!org|com|cn|tv)$")) then
      if(rime_api_helper:regex_match(predict, "[.]$")) then
        predict = predict.."com"
      else
        predict = predict..".com"
      end
    end
    if(input ~= predict) then
      yieldCandidate(seg, predict)
    end
  end
end

return {
  translator = translator
}