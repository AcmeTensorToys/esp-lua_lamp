return function(t,fb,p)
  local c, c2

  local function drawHeart()
    fb:set( 3,c)
    fb:set( 5,c)
    fb:set(10,c)
    fb:set(12,c)
    fb:set(14,c)
    fb:set(19,c)
    fb:set(21,c)
    fb:set(28,c)
  end

  local function reinit()
    c = p[1]
    c2 = p[2] or c
    drawHeart()
  end
  reinit()

  local z = string.char(0,0,0)
  local ft = { [1] = function() fb:set(11,c2)               fb:set(13,c2) end, -- side chambers
               [2] = function() fb:set(11,z)  fb:set(20,c2) fb:set(13,z)  end, -- bottom chamber
               [3] = function()               fb:set(20,z)                end, -- empty
               [4] = function()                                           end  -- stay empty
             }

  fb:fill(0,0,0)
  drawHeart()

  local ix = 4
  t:register(250,tmr.ALARM_AUTO,function()
    ix = (ix == 4 and 1) or ix + 1
    ft[ix]()
    dodraw()
  end)

  return { ['ncolors'] = 2, ['cccb'] = function() reinit(); local ixp for ixp = 1,ix do ft[ixp]() end; dodraw() end }
end
