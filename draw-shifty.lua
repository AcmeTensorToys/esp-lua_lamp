return function(t,fb,g,r,b)
  fb:fill(0,0,0)
  local ix = 0
  local c = string.char(g,r,b)
  fb:set( 2,c) fb:set( 3,c) fb:set( 6,c) fb:set( 7,c)
  fb:set( 9,c) fb:set(12,c) fb:set(13,c) fb:set(16,c)
  fb:set(17,c) fb:set(19,c) fb:set(20,c) fb:set(21,c)
  fb:set(23,c) fb:set(24,c) fb:set(26,c) fb:set(27,c)
  fb:set(30,c) fb:set(31,c)
  t:register(1000,tmr.ALARM_AUTO, function()
    if ix == 1
      then fb:set(18,0,0,0) fb:set(19,c) fb:set(22,0,0,0) fb:set(23,c)
      else fb:set(18,c) fb:set(19,0,0,0) fb:set(22,c) fb:set(23,0,0,0)
    end
    ix = 1 - ix
    dodraw()
  end)
end
