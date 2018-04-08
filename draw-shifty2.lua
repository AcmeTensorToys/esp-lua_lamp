return function(t,fb,p)
    fb:fill(0,0,0)
    local ix = 0
    local c
    local x = string.char(0,0,0)

    local function drawEyes()
      fb:set( 3,c) fb:set( 8,c) fb:set(10,c) fb:set(15,c)
      fb:set(17,c) fb:set(18,c) fb:set(22,c) fb:set(23,c)
      fb:set(27,c) fb:set(28,c) fb:set(29,c) fb:set(32,c)
    end

    local function reinit()
      c = p[1]
      drawEyes()
    end
    reinit()

    local ft = {
      [0] = function() fb:set( 1,x) fb:set( 3,c) fb:set( 6,x) fb:set( 8,c)
                fb:set(17,c) fb:set(19,x) fb:set(22,c) fb:set(24,x)
                fb:set(25,x) fb:set(27,c) fb:set(30,x) fb:set(32,c) end,
      [1] = function()  fb:set( 1,c) fb:set( 3,x) fb:set( 6,c) fb:set( 8,x)
          fb:set(17,x) fb:set(19,c) fb:set(22,x) fb:set(24,c)
          fb:set(25,c) fb:set(27,x) fb:set(30,c) fb:set(32,x) end
    }

    t:register(1000,tmr.ALARM_AUTO, function()
      ft[ix]()
      ix = 1 - ix
      dodraw()
    end)

    drawEyes()
    return {['cccb'] = function() reinit(); ft[ix](); dodraw() end }
  end
