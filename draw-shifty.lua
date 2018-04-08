return function(t,fb,p)
  fb:fill(0,0,0)
  local ix = 0
  local c, c2

  local function drawEyes()
    fb:set( 2,c) fb:set( 3,c) fb:set( 6,c) fb:set( 7,c)
    fb:set( 9,c) fb:set(12,c) fb:set(13,c) fb:set(16,c)
    fb:set(17,c) fb:set(19,c) fb:set(20,c) fb:set(21,c)
    fb:set(23,c) fb:set(24,c) fb:set(26,c) fb:set(27,c)
    fb:set(30,c) fb:set(31,c)
  end

  local function reinit()
    c = p[1]
    c2 = p[2] or c
    drawEyes()
  end
  reinit()

  local ft = {
    [0] = function() fb:set(18,c2) fb:set(19,0,0,0) fb:set(22,c2) fb:set(23,0,0,0) end,
    [1] = function() fb:set(18,0,0,0) fb:set(19,c2) fb:set(22,0,0,0) fb:set(23,c2) end
  }

  t:register(1000,tmr.ALARM_AUTO, function()
    ft[ix]()
    ix = 1 - ix
    dodraw()
  end)
  drawEyes()
  return { ['ncolors'] = 2,  ['cccb'] = function() reinit(); ft[ix](); dodraw() end }
end
