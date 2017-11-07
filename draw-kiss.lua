-- 1 0 1 - - - - -
-- 0 x 0 - - x - -
-- 1 0 1 x x - - -
-- - - - - - x - -
return function(t,fb,g,r,b)
  fb:fill(0,0,0)
  local ix = 1
  local c = string.char(g,r,b)
  fb:set( 2,c) fb:set( 9,c) fb:set(10,c)
  fb:set(11,c) fb:set(14,c) fb:set(18,c) fb:set(20,c)
  fb:set(21,c) fb:set(30,c)
  t:register(500,tmr.ALARM_AUTO,function()
    if ix == 1
      then fb:set( 1,c) fb:set( 2,0,0,0) fb:set( 3,c)
        fb:set( 9,0,0,0) fb:set(11,0,0,0) fb:set(17,c) fb:set(18,0,0,0)
	fb:set(19,c)
      else fb:set( 1,0,0,0) fb:set( 2,c) fb:set( 3,0,0,0) fb:set( 9,c)
	fb:set(11,c) fb:set(17,0,0,0) fb:set(18,c) fb:set(19,0,0,0)
    end
    ix = 1 - ix
    dodraw()
  end)
end
