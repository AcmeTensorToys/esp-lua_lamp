return function(t,fb,p)
  local c, ch

  fb:fill(0,0,0)
  local z = string.char(0,0,0)
  local ft = {[1] = function() --start flapping
                       fb:set(2,c)
                       fb:set(9,z)  fb:set(10,c) fb:set(14,c) fb:set(15,z)
                       fb:set(17,z) fb:set(18,c)
                       fb:set(22,c) fb:set(23,z) fb:set(26,c)
                    end,
              [2] = function() -- fully collapsed
                       fb:set(2,z)  fb:set(3,c)  fb:set(5,c)  fb:set(6,z)
                       fb:set(10,z) fb:set(14,z) fb:set(18,z) fb:set(22,z)
                       fb:set(26,z) fb:set(27,c) fb:set(29,c) fb:set(30,z)
                    end,
              [3] = function() -- half expanded
                       fb:set(2,c)  fb:set(3,z)  fb:set(5,z)  fb:set(6,c)
                       fb:set(10,c)
                       fb:set(14,c) fb:set(18,c) fb:set(22,c)
                       fb:set(26,c) fb:set(27,z) fb:set(29,z) fb:set(30,c)
                    end,
              [4] = function() -- back to the beginning
                       fb:set(9,c) fb:set(10,z) fb:set(14,z) fb:set(15,c)
                       fb:set(17,c) fb:set(18,z) fb:set(22,z) fb:set(23,c)
                    end
             }

  local function reinit()
    c = p[1]
    ch = p[2] or c

    fb:set( 2,c) fb:set( 4,c) fb:set( 6,c)
    fb:set( 9,c) fb:set(11,c) fb:set(12,ch) fb:set(13,c) fb:set(15,c)
    fb:set(17,c) fb:set(19,c) fb:set(20,c)  fb:set(21,c) fb:set(23,c)
    fb:set(26,c) fb:set(28,c) fb:set(30,c)
  end
  reinit()

  local ix = 4
  t:register(500,tmr.ALARM_AUTO, function()
    ix = (ix == 4 and 1) or ix + 1
    ft[ix]()
    dodraw()
    end)

  return { ['cccb'] = function() reinit();local ixp for ixp = 1,ix do ft[ixp]() end; dodraw() end }
end
