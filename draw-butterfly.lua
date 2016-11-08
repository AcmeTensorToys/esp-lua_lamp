return function(t,fb,g,r,b)
  fb:fill(0,0,0)
  local c = string.char(g,r,b)
  local ft = { [1] = function() fb:set(2,c) fb:set(9,0,0,0) fb:set(10,c) fb:set(17,0,0,0) fb:set(18,c) fb:set(14,c) fb:set(15,0,0,0) fb:set(22,c) fb:set(23,0,0,0) fb:set(26,c) end, --start flapping
              [2] = function() fb:set(2,0,0,0) fb:set(3,c)
	              fb:set(6,0,0,0) fb:set(27,c) fb:set(5,c)
		      fb:set(26,0,0,0) fb:set(29,c) fb:set(30,0,0,0)
		      fb:set(10,0,0,0) fb:set(18,0,0,0)
		      fb:set(14,0,0,0) fb:set(22,0,0,0) end, -- fully collapsed
	      [3] = function() fb:set(2,c) fb:set(3,0,0,0) fb:set(27,0,0,0)
	              fb:set(5,0,0,0) fb:set(6,c) fb:set(29,0,0,0) fb:set(10,c)
		      fb:set(18,c) fb:set(14,c) fb:set(22,c) fb:set(26,c)
		      fb:set(30,c)
		      end, -- half expanded
	      [4] = function() fb:set(9,c) fb:set(10,0,0,0) fb:set(17,c)
	              fb:set(18,0,0,0) fb:set(14,0,0,0) fb:set(15,c)
		      fb:set(22,0,0,0) fb:set(23,c) end -- back to the beginning
              }

  fb:set( 2,c) fb:set( 4,c) fb:set( 6,c) fb:set( 9,c)
  fb:set(11,c) fb:set(12,c) fb:set(13,c) fb:set(15,c)
  fb:set(17,c) fb:set(19,c) fb:set(20,c) fb:set(21,c)
  fb:set(23,c) fb:set(26,c) fb:set(28,c) fb:set(30,c)
  local ix = 1
  t:register(500,tmr.ALARM_AUTO, function()
    ft[ix]()
    ix = (ix == 4 and 1) or ix + 1
    dodraw()
    end)
 end