return function(t,fb,g,r,b)
  local c = string.char(g,r,b)
  local ft = { [1] = function() fb:set(11,c)                      fb:set(13,c)     end, -- side chambers
               [2] = function() fb:set(11,0,0,0) fb:set(20,c)     fb:set(13,0,0,0) end, -- bottom chamber
               [3] = function()                  fb:set(20,0,0,0)                  end, -- empty
               [4] = function()                                                    end  -- stay empty
             }

  fb:fill(0,0,0)

               fb:set( 3,c)              fb:set( 5,c)
  fb:set(10,c)              fb:set(12,c)              fb:set(14,c)
               fb:set(19,c)              fb:set(21,c)
                            fb:set(28,c)

  local ix = 1
  t:register(250,tmr.ALARM_AUTO,function()
    ft[ix]()
    ix = (ix == 4 and 1) or ix + 1
    dodraw()
  end)
end
