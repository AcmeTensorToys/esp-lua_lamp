return function(t,fb,g,r,b)
  local c = string.char(g,r,b)
  local cmax = math.max(r,g,b)
  local i,v
  
  -- off channels stay off, on channels stay on, just minimally dim
  local function adjust(val,bias) if val == 0 then return 0 elseif val <= bias then return 1 else return val - bias end end
  -- update many pixels together with the same bias
  local function drawbiased(...)
    local i,v
    local bias = math.random(cmax)
    local ag = adjust(g,bias)
    local ar = adjust(r,bias)
    local ab = adjust(b,bias)
    for i,v in ipairs{...} do fb:set(v,ag,ar,ab) end
  end

  local function drawEq() for i,v in ipairs({3,6}) do fb:set(v,g,r,b) end end
  local function drawTwinkleEyes() drawbiased(3,6) end
  local ft = { [0] = drawEq, drawEq, drawTwinkleEyes }
  fb:fill(0,0,0)
  fb:set(3,c) fb:set(6,c) fb:set(10,c) fb:set(15,c) fb:set(17,c)
  fb:set(18,c) fb:set(23,c) fb:set(24,c) fb:set(28,c) fb:set(29,c)
  -- TODO make eyes (3&6 flicker)

  local ix = 1;
  t:register(400, tmr.ALARM_AUTO, function()
    ft[math.random(#ft)]()
    dodraw()
  end)
end
