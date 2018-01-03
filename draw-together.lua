-- Two hands animate together, heartbeat, then repeat at offset (to average
-- out the symmetry breaking)
--
-- Palette: together, left, right
--
--    1 2 3 4 5 6 7 8    --    1 2 3 4 5 6 7 8   --    1 2 3 4 5 6 7 8
-- 00 o 1 o o o o 1 o    -- 00 o o 2 o o 2 o o   -- 00 o o 3 o 3 o o o
-- 08 1 o o o o o o 1    -- 08 o 2 o o o o 2 o   -- 08 o 3 o 3 o 3 o o
-- 16 o 1 o o o o 1 o    -- 16 o o 2 o o 2 o o   -- 16 o o 3 o 3 o o o
-- 24 o o 1 o o 1 o o    -- 24 o o o 2 2 o o o   -- 24 o o o 3 o o o o
--                                                 (or shifted right one)


return function(t,fb,p)
  local k,v
  local c, c2, c3
  local offset = 0
  local ft = {
    -- animate together
    function() fb:fill(0,0,0)
               for k,v in ipairs({2,9,18,27})  do fb:set(v,c2) end -- left
               for k,v in ipairs({7,16,23,30}) do fb:set(v,c3) end -- right
               end,
    function() end,
    function() fb:fill(0,0,0)
               for k,v in ipairs({3,10,19,28}) do fb:set(v,c2) end -- left
               for k,v in ipairs({6,15,22,29}) do fb:set(v,c3) end -- right
               end,
    function() end,
    function() fb:fill(0,0,0)
               for k,v in ipairs({3,10,19}) do fb:set(v+offset,c2) end -- left
               for k,v in ipairs({5,14,21}) do fb:set(v+offset,c3) end -- right
               for k,v in ipairs({12,28})   do fb:set(v+offset,c)  end -- both
               end,
    -- all the both color
    function() fb:fill(0,0,0) for k,v in ipairs({3,5,10,12,14,19,21,28}) do fb:set(v+offset,c) end end,
    -- beat
    function() fb:set(11+offset,c)     fb:set(13+offset,c) end,
    function() fb:set(11+offset,0,0,0) fb:set(13+offset,0,0,0) fb:set(20+offset,c) end,
    function()                                                 fb:set(20+offset,0,0,0) end,
    -- beat
    function() fb:set(11+offset,c)     fb:set(13+offset,c) end,
    function() fb:set(11+offset,0,0,0) fb:set(13+offset,0,0,0) fb:set(20+offset,c) end,
    function()                                                 fb:set(20+offset,0,0,0) ; offset = 1 - offset end,
  }

  local function reinit()
    c = p[1]
    c2 = p[2] or c
    c3 = p[3] or c
  end
  reinit()

  ft[1](); dodraw()
  local ix = 1
  t:register(350,tmr.ALARM_AUTO,function()
    ix = (ix == #ft and 1) or ix + 1
    ft[ix]()
    dodraw()
    t:interval(350) -- put it back in case cccb has changed it
  end)

  -- In cccb, set ix=5 so that all colors are on screen; artificially
  -- increase animation delay
  return { ['ncolors'] = 3, ['cccb'] = function() reinit(); ix = 5; ft[ix]() ; dodraw(); t:interval(800) end }

end
