-- a more curious snake with occasional red "heart" nearby
--
-- Palette: snake, heart
--
--
--    1 2 3 4 5 6 7 8
-- 00 o o o o o h x h
-- 08 o o o o o e x o
-- 16 w w w w o o x o
-- 24 w w w w x x x o
--
return function(t,fb,p)
  local ix = 2 -- since we start effectively in state 1...
  local c, h

  local z = string.char(0,0,0)
  local ft = {   -- flatten out
               [1] = function() fb:set(25,c) fb:set(27,c) fb:set(17,z) fb:set(19,z) end
                 -- look back
             , [2] = function() fb:set(6,c) fb:set(8,z) end
                 -- look forward
             , [3] = function() fb:set(6,z) fb:set(8,c) end
                 -- heart on (like what we see)
             , [4] = function() fb:set(14,h) end
                 -- slither 1
             , [5] = function() fb:set(20,c) fb:set(28,z) end
                 -- slither 2
             , [6] = function() fb:set(19,c) fb:set(20,z) fb:set(27,z) fb:set(28,c) end
                 -- slither 3, heart off
             , [7] = function() fb:set(18,c) fb:set(19,z) fb:set(20,c) fb:set(26,z) fb:set(27,c) fb:set(28,z) fb:set(14,z) end
                 -- slither 4
             , [8] = function() fb:set(17,c) fb:set(18,z) fb:set(19,c) fb:set(20,z) fb:set(25,z) fb:set(26,c) fb:set(27,z) fb:set(28,c) end
             }

  local function reinit()
    c = p[1]
    h = p[2] or string.char(0,15,0) -- heart defaults red

    fb:fill(0,0,0)
    fb:set(25,c) fb:set(26,c) fb:set(27,c) fb:set(28,c) fb:set(29,c) fb:set(30,c)
    fb:set(23,c) fb:set(15,c) fb:set(7,c) fb:set(8,c)
  end
  reinit()

  t:register(500,tmr.ALARM_AUTO,function()
    ft[ix]()
    ix = (ix == 8 and 1) or ix + 1
    dodraw()
  end)

  return { ['ncolors'] = 2, ['cccb'] = function() reinit(); ix = 4; ft[ix](); dodraw() end }
end
