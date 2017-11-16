-- A finger draws a heart, which starts beating
--
-- Palette: together, left, right
--
--    1 2 3 4 5 6 7 8
-- 00 o o 3 o 3 o o o
-- 08 o 3 o 3 o 3 o o
-- 16 o o 3 o 3 o o o
-- 24 o o o 3 o o o o


return function(t,fb,p)
  local k,v
  local c = p[1]
  local offset = 0
  local ft = {
    -- animate together
    function() fb:fill(0,0,0) end,
    -- left side
    function() fb:set(12, c) end,
    function() fb:set(3, c) end,
    function() fb:set(10, c) end,
    function() fb:set(19, c) end,
    function() fb:set(28, c) end,
    -- right side
    function()  end,
    function() fb:set(5, c) end,
    function() fb:set(14, c) end,
    function() fb:set(21, c) end,
    function() end,
    -- all the both color
    function() fb:fill(0,0,0) for k,v in ipairs({3,5,10,12,14,19,21,28}) do fb:set(v+offset,c) end end,
    -- beat
    function() fb:set(11+offset,c)     fb:set(13+offset,c) end,
    function() fb:set(11+offset,0,0,0) fb:set(13+offset,0,0,0) fb:set(20+offset,c) end,
    function()                                                 fb:set(20+offset,0,0,0) end,
    -- beat
    function() fb:set(11+offset,c)     fb:set(13+offset,c) end,
    function() fb:set(11+offset,0,0,0) fb:set(13+offset,0,0,0) fb:set(20+offset,c) end,
    function()                                                 fb:set(20+offset,0,0,0) ; end,
  }
  ft[1](); dodraw()
  local ix = 2
  t:register(350,tmr.ALARM_AUTO,function()
    ft[ix]()
    ix = (ix == #ft and 1) or ix + 1
    dodraw()
  end)

end
