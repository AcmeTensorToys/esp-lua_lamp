return function(t,fb,g,r,b)
  local ix = 0
  local c = string.char(g,r,b)
  fb:fill(0,0,0)
  fb:set(25,c) fb:set(26,c) fb:set(19,c) fb:set(28,c) fb:set(29,c) fb:set(30,c)
  fb:set(23,c) fb:set(15,c) fb:set(7,c) fb:set(8,c)
  t:register(1000,tmr.ALARM_AUTO,function()
    if ix == 1
     then fb:set(19,c) fb:set(27,0,0,0) fb:set(20,0,0,0) fb:set(28,c)
     else fb:set(19,0,0,0) fb:set(27,c) fb:set(20,c) fb:set(28,0,0,0)
    end
    ix = 1 - ix
    dodraw()
  end)
end
