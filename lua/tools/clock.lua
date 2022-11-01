local Object = require("tools/classic")

local Clock = Object:extend()

local number = 0

local col_width = "10"

function Clock:new(name)
  number = number + 1
  self.number = number
  self.name = name or ("clock_"..tostring(self.number))
  self.events = {}
end

function Clock:save(msg)
  local events = self.events
  local len = #events
  if(len>0) then
    local clock = events[len].clock
    if(clock) then
      clock:calc()
    end
  end
  table.insert(events, {
    msg = msg or ("event_"..tostring(len+1)),
    time = os.clock()
  })
end

function Clock:sub_save(msg)
  local event = self.events[#self.events]
  local clock = event.clock
  if(not clock) then
    clock = Clock("sub_event")
    event.clock = clock
  end
  clock:save(msg)
end

function Clock:calc()
  if(self.is_calc) then
    return 
  else
    self.is_calc = true
  end
  local time_end = os.clock()
  local len = #self.events
  local prev_i = nil
  for i, p in pairs(self.events) do
    if(prev_i) then
      local prev_p = self.events[prev_i]
      prev_p.duration = p.time - prev_p.time
    end
    if(len==i) then
      p.duration = time_end - p.time
    else
      prev_i = i
    end
  end
  local total = 0
  if(len>0) then
    local s = self.events[1]
    total = time_end - s.time
  end
  self.total = total
end

function Clock:to_sub_string()
  self:calc()
  local lines = {}
  for i, p in pairs(self.events) do
    local line = string.format("%"..col_width.."s\t%"..col_width.."s\t%"..col_width.."s", 
      string.format("+ %s", p.msg), 
      string.format("+ %.4f", p.duration), 
      string.format("%.4f", p.time))
    table.insert(lines, line)
  end
  local result = table.concat(lines, "\n")
  return result
end

function Clock:__tostring()
  self:calc()
  local lines = {
    string.format("Clock \"%s\" status:", self.name),
    string.format("%"..col_width.."s\t%"..col_width.."s\t%"..col_width.."s", "event", "duration(s)", "time")
  }
  for i, p in pairs(self.events) do
    local line = string.format("%"..col_width.."s\t%"..col_width.."s\t%"..col_width.."s", 
      p.msg, 
      string.format("%.4f", p.duration), 
      string.format("%.4f", p.time))
    table.insert(lines, line)
    if(p.clock) then
      table.insert(lines, p.clock:to_sub_string())
    end
  end
  table.insert(lines, string.format("Clock \"%s\" total duration: %0.4fs", self.name, self.total))
  local result = table.concat(lines, "\n")
  return result
end

return Clock