-- Two hands animate together, heartbeat, then repeat at offset (to average
-- out the symmetry breaking)

--    1 2 3 4 5 6 7 8    --    1 2 3 4 5 6 7 8   --    1 2 3 4 5 6 7 8
-- 00 o 1 o o o o 1 o    -- 00 o o 2 o o 2 o o   -- 00 o o 3 o 3 o o o
-- 08 1 o o o o o o 1    -- 08 o 2 o o o o 2 o   -- 08 o 3 o 3 o 3 o o
-- 16 o 1 o o o o 1 o    -- 16 o o 2 o o 2 o o   -- 16 o o 3 o 3 o o o
-- 24 o o 1 o o 1 o o    -- 24 o o o 2 2 o o o   -- 24 o o o 3 o o o o
--                                                 (or shifted right one)


return function(t,fb,g,r,b)
  local k,v
  local c = string.char(g,r,b)
  local offset = 0
  local ft = {
    -- animate together
    function() fb:fill(0,0,0) for k,v in ipairs({2,7,9,16,18,23,27,30}) do fb:set(v,c) end end,
    function() end,
    function() fb:fill(0,0,0) for k,v in ipairs({3,6,10,15,19,22,28,29}) do fb:set(v,c) end end,
    function() end,
    function() fb:fill(0,0,0) for k,v in ipairs({3,5,10,12,14,19,21,28}) do fb:set(v+offset,c) end end,
    function() end,
    -- beat
    function() fb:set(11+offset,c)     fb:set(13+offset,c) end,
    function() fb:set(11+offset,0,0,0) fb:set(13+offset,0,0,0) fb:set(20+offset,c) end,
    function()                                                 fb:set(20+offset,0,0,0) end,
    -- beat
    function() fb:set(11+offset,c)     fb:set(13+offset,c) end,
    function() fb:set(11+offset,0,0,0) fb:set(13+offset,0,0,0) fb:set(20+offset,c) end,
    function()                                                 fb:set(20+offset,0,0,0) ; offset = 1 - offset end,
  }
  ft[1](); dodraw()
  local ix = 2
  t:register(350,tmr.ALARM_AUTO,function()
    ft[ix]()
    ix = (ix == #ft and 1) or ix + 1
    dodraw()
  end)

end
