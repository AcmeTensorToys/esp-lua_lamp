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
  ["laserchase"] = function(t,fb,g,r,b)
    local ix = 1
    local c = string.char(g,r,b)
    fb:fill(0,0,0)
    t:register(50,tmr.ALARM_AUTO,function()
      fb:fade(2); fb:set(ix,c); dodraw()
      ix = ix + 1; if ix > fb:size() then ix = 1 end
    end)
  end
}
