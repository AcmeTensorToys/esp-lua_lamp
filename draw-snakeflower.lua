-- snake2 with some camera panning and a vertical flower
--
-- Palette: snake, heart, flower
--
--    1 2 3 4 5 6 7 8
-- 00 o o o o o h x h
-- 08 o o o o o e x o
-- 16 w w w w o o x o
-- 24 w w w w x x x o
--
--    1 2 3 4 5 6 7 8
-- 00 o o x h o f o f
-- 08 o e x o o f f f
-- 16 o o x o o o s o
-- 24 x x x o o o s o

--
return function(t,fb,p)
  local c, h, f, fh

  local z = string.char(0,0,0)
  local s = string.char(15,0,0)
  local sh = string.char(7,0,0)
  local function reinit()
    c = p[1]
    h = p[2] or string.char(0,15,0) -- heart defaults red
    f = p[3] or string.char(0,7,15) -- flower defaults purple

    fh = string.char(math.floor((f:byte(1)+1)/2),
                     math.floor((f:byte(2)+1)/2),
                     math.floor((f:byte(3)+1)/2))
  end
  reinit()

  local function panright()
    fb:shift(-1, ws2812.SHIFT_LOGICAL)
    fb:set(8,z) fb:set(16,z) fb:set(24,z) fb:set(32,z)
  end

  local ft = {   -- snake to full screen, flattened, heart off
               [1] = function()
                      fb:fill(0,0,0)
                      fb:set(25,c) fb:set(26,c) fb:set(27,c) fb:set(28,c) fb:set(29,c) fb:set(30,c)
                      fb:set(23,c) fb:set(15,c) fb:set(7,c) fb:set(8,c)
                    end
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
                 -- slither 3
             , [7] = function() fb:set(18,c) fb:set(19,z) fb:set(20,c) fb:set(26,z) fb:set(27,c) fb:set(28,z) end
                 -- slither 4
             , [8] = function() fb:set(17,c) fb:set(18,z) fb:set(19,c) fb:set(20,z) fb:set(25,z) fb:set(26,c) fb:set(27,z) fb:set(28,c) end
                 -- pan right one column
             , [9] = panright
                 -- and again
             , [10] = panright
                 -- and again, but draw the flower stem and bud
             , [11] = function() panright() fb:set(16,fh) fb:set(24,s) fb:set(32,s) end
                 -- and again, but draw a leaf, too
             , [12] = function() panright() fb:set(24,sh) end
                 -- wait one
             , [13] = function() end
                 -- grow flower
             , [14] = function() fb:set(14,fh) fb:set(15,f) fb:set(16,fh) end
                 -- grow flower again
             , [15] = function() fb:set(6,fh) fb:set(8,fh) fb:set(14,f) fb:set(16,f) end
                 -- wait two
             , [16] = function() end
             , [17] = function() end
             }

  local ix = 2
  ft[1]()

  t:register(500,tmr.ALARM_AUTO,function()
    ft[ix]()
    ix = (ix == #ft and 1) or ix + 1
    dodraw()
  end)

  return { ['ncolors'] = 3,
           ['cccb'] = function()
                        reinit()
                        ft[1]() -- first frame
                        ft[4]() -- render heart
                        ft[9]() -- move over and render flower
                        ft[10]()
                        ft[11]()
                        ft[12]()
                        ft[14]()
                        ft[15]()
                        dodraw()
                        ix = 16
                      end
         }
end
