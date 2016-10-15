-- a table of functions that take framebuffers and colors
return {
  ["heart"] = function(t,fb,g,r,b)
    t:unregister()
    fb:fill(0,0,0)
    local c = string.char(g,r,b)
                 fb:set( 3,c)              fb:set( 5,c)
    fb:set(10,c) fb:set(11,c) fb:set(12,c) fb:set(13,c) fb:set(14,c)
                 fb:set(19,c) fb:set(20,c) fb:set(21,c)
                              fb:set(28,c)
  end,
  ["fill"] = function(t,fb,g,r,b) t:unregister(); fb:fill(g,r,b) end,
  ["xx"] = function(t,fb,g,r,b)
    t:unregister()
    fb:fill(0,0,0)
    local c = string.char(g,r,b)
    fb:set( 1,c) fb:set( 4,c) fb:set( 5,c) fb:set( 8,c)
    fb:set(10,c) fb:set(11,c) fb:set(14,c) fb:set(15,c)
    fb:set(18,c) fb:set(19,c) fb:set(22,c) fb:set(23,c)
    fb:set(25,c) fb:set(28,c) fb:set(29,c) fb:set(32,c)
  end,
  ["oo"] = function(t,fb,g,r,b)
    t:unregister()
    fb:fill(0,0,0)
    local c = string.char(g,r,b)
    fb:set( 2,c) fb:set( 3,c) fb:set( 6,c) fb:set( 7,c)
    fb:set( 9,c) fb:set(12,c) fb:set(13,c) fb:set(16,c)
    fb:set(17,c) fb:set(20,c) fb:set(21,c) fb:set(24,c)
    fb:set(26,c) fb:set(27,c) fb:set(30,c) fb:set(31,c)
  end,
  ["laserchase"] = function(t,fb,g,r,b)
    local ix = 1
    local c = string.char(g,r,b)
    fb:fill(0,0,0)
    t:register(50,tmr.ALARM_AUTO,function()
      fb:fade(2); fb:set(ix,c); dodraw()
      ix = ix + 1; if ix > fb:size() then ix = 1 end
    end)
  end,
  ["kiss"] = function(t,fb,g,r,b)
    t:unregister()
    fb:fill(0,0,0)
    local ix = 0
    local c = string.char(g,r,b)
    fb:set( 2,c) fb:set( 9,c) fb:set(10,c)
    fb:set(11,c) fb:set(14,c) fb:set(18,c) fb:set(20,c)
    fb:set(21,c) fb:set(30,c)
    t:register(500,tmr.ALARM_AUTO,function()
      if ix == 1
        then fb:set( 1,c) fb:set( 2,0,0,0) fb:set( 3,c) fb:set( 9,0,0,0) fb:set(11,0,0,0) fb:set(17,c) fb:set(18,0,0,0) fb:set(19,c)
	else fb:set( 1,0,0,0) fb:set( 2,c) fb:set( 3,0,0,0) fb:set( 9,c) fb:set(11,c) fb:set(17,0,0,0) fb:set(18,c) fb:set(19,0,0,0)
      end
      ix = 1 - ix
      dodraw()
    end)
  end,
  ["shifty"] = function(t,fb,g,r,b)
    t:unregister()
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
  end,
  ["snake"] = function(t,fb,g,r,b)
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
}
