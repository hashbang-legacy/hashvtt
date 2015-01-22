-- License something or other Jesse Horne 2015
-- Give me credit, or give me death.

-- You need split, to use this. Sorry folks. You probably have it already somewhere.

local dice = {}

function dice.roll(str)
  -- str should be in "xdy" format
  -- Example - "1d10"
  local t = str:split("d")
  if #t == 2 then
    local sum = 0
    for i=1, t[1] do
      sum = sum + math.random(1, t[2])
    end
    return sum
  else
    return "error"
  end
end

return dice
