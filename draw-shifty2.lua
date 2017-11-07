return function(t,fb,p)
    fb:fill(0,0,0)
    local ix = 0
    local c = p[1]
    local x = string.char(0,0,0)
    fb:set( 3,c) fb:set( 8,c) fb:set(10,c) fb:set(15,c)
    fb:set(17,c) fb:set(18,c) fb:set(22,c) fb:set(23,c)
    fb:set(27,c) fb:set(28,c) fb:set(29,c) fb:set(32,c)
    t:register(1000,tmr.ALARM_AUTO, function()
      if ix == 1
        then fb:set( 1,c) fb:set( 3,x) fb:set( 6,c) fb:set( 8,x)
            fb:set(17,x) fb:set(19,c) fb:set(22,x) fb:set(24,c)
            fb:set(25,c) fb:set(27,x) fb:set(30,c) fb:set(32,x)
	else fb:set( 1,x) fb:set( 3,c) fb:set( 6,x) fb:set( 8,c)
            fb:set(17,c) fb:set(19,x) fb:set(22,c) fb:set(24,x)
            fb:set(25,x) fb:set(27,c) fb:set(30,x) fb:set(32,c)
      end
      ix = 1 - ix
      dodraw()
    end)
  end
