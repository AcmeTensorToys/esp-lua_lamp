--
return function(t,fb,p)
  local ix = 2 -- since we start effectively in state 1...
  local c

  local function reinit()
    c = p[1]
  end
  reinit()

  local z = string.char(0,0,0)
  local ft = {   -- open mouth
               [1] = function() fb:set(16,z) fb:set(24,z) fb:set(9,c) fb:set(17,c) fb:set(2,c) fb:set(26,c) end
                 -- close mouth
             , [2] = function() fb:set(10, c) fb:set(18,c) fb:set(2,z) fb:set(26,z) end
                 -- advance & open mouth
             , [3] = function() fb:set(9,z) fb:set(17,z) fb:set(3, c) fb:set(27,c) end
                 -- close mouth
             , [4] = function() fb:set(3,z) fb:set(27,z) fb:set(11,c) fb:set(19,c) end
                 -- nom
             , [5] = function() fb:set(10,z) fb:set(18,z) fb:set(4,c) fb:set(28,c) end
                 -- nom 1
             , [6] = function() fb:set(4,z) fb:set(28,z) fb:set(12,c) fb:set(20,c) end
                 -- nom 2
             , [7] = function() fb:set(11,z) fb:set(19,z) fb:set(5,c) fb:set(29,c) end
                 -- nom 3
             , [8] = function() fb:set(5,z) fb:set(29,z) fb:set(13,c) fb:set(21,c) end
                 -- nom 4
             , [9] = function() fb:set(12,z) fb:set(20,z) fb:set(6,c) fb:set(30,c) end
	     , [10] = function() fb:set(6,z) fb:set(30,z) fb:set(14,c) fb:set(22,c) end
	     , [11] = function() fb:set(13,z) fb:set(21,z) fb:set(7,c) fb:set(31,c) end
	     , [12] = function() fb:set(7,z) fb:set(31,z) fb:set(15,c) fb:set(23,c) end
	     , [13] = function() fb:set(14,z) fb:set(22,z) fb:set(8,c) fb:set(32,c) end
	     , [14] = function() fb:set(8,z) fb:set(32,z) fb:set(16,c) fb:set(24,c) end
	     , [15] = function() fb:set(15,z) fb:set(23,z) fb:set(1,c) fb:set(25,c) end
	     , [16] = function() fb:set(1,z) fb:set(25,z) fb:set(9,c) fb:set(17,c) end
             }
  fb:fill(0,0,0)
  fb:set(9,c) fb:set(17,c) fb:set(2,c) fb:set(26,c)
  t:register(500,tmr.ALARM_AUTO,function()
    ft[ix]()
    ix = (ix == 16 and 1) or ix + 1
    dodraw()
  end)
    return {['cccb'] = function() reinit(); local ixp for ixp=1,ix do ft[ixp]() end; dodraw() end }
end
