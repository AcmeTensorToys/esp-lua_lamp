-- a votive-style candle?
--
--    1 2 3 4 5 6 7 8
-- 00 o o o f f o o o
-- 08 o w o f f o w o
-- 16 o W w w w w W o
-- 24 o W W W W W W o
--

return function(t,fb,g,r,b)
  fb:fill(0,0,0)
  -- static base
  local i,v
  for i,v in ipairs({18,23,26,27,28,29,30,31}) do fb:set(v,2,2,1) end -- whiteish (W)
  for i,v in ipairs({10,15,19,20,21,22})       do fb:set(v,1,1,1) end -- dim white (w)

  local cmax = math.max(r,g,b)

  -- off channels stay off, on channels stay on, just minimally dim
  local function adjust(val,bias) if val == 0 then return 0 elseif val <= bias then return 1 else return val - bias end end
  -- update many pixels together with the same bias
  local function drawbiased(...)
    local i,v
    local bias = math.random(cmax)
    local ag = adjust(g,bias)
    local ar = adjust(r,bias)
    local ab = adjust(b,bias)
    for i,v in ipairs(arg) do fb:set(v,ag,ar,ab) end
  end

  -- flame (f) behaviors: equal intensity, dimmer top, dimmer left, and dimmer right
  local function draweq() for i,v in ipairs({4,5,12,13}) do fb:set(v,g,r,b) end end
  local function drawbb() drawbiased(4,5) end
  local function drawlb() drawbiased(4,12) end
  local function drawrb() drawbiased(5,13) end

  local ft = { [0] = draweq, draweq, draweq, drawbb, drawlb, drawrb }
  t:register(125,tmr.ALARM_AUTO,function() ft[math.random(#ft)]() dodraw() end)
  draweq()
end
