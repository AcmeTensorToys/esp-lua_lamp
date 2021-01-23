--
-- Flying dragon w/ rider in profile view
--
--    1 2 3 4 5 6 7 8
-- 00 o o o o w w o r
-- 08 t o o w w w r h
-- 16 t d d d d * d h
-- 24 t o o w w o o o

return function(t, fb, p)
  local cd = p[1]
  local cr = p[2] or string.char(0,7,15)
  local ch = p[3] or p[1]
  local z = string.char(0,0,0)

  local function setchoice(t, c) fb:set(t[math.random(#t)], c) end

  -- head position; returns possible rider positions
  local thead = {
    function() fb:set(16, cd) return {8, 15} end, -- head up, rider might be atop
    function() fb:set(24, cd) return {15} end, -- head level, rider always further back
  }

  -- wing animation frames
  local twing = {
    function() fb:set(5, cd) fb:set(6, cd) fb:set(12, cd) fb:set(13, cd) fb:set(14, cd) end, -- full up
    function() fb:set(5, z)  fb:set(6, z)                                               end, -- start downstroke
    function()                             fb:set(12, z)  fb:set(13, z)  fb:set(14, z)       -- level
                fb:set(22, cd) fb:set(28, cd) fb:set(29, cd)                            end, -- (occludes heart)
    function()                             fb:set(12, cd) fb:set(13, cd) fb:set(14,cd)
                fb:set(22, ch) fb:set(28, z)  fb:set(29, z)                             end, -- quick mid up
  }

  fb:fill(0,0,0)

  -- dragon initial pose
  fb:set(15, cr) -- rider
  fb:set(18, cd)
  fb:set(19, cd)
  fb:set(20, cd)
  fb:set(21, cd)
  fb:set(22, ch)
  fb:set(23, cd)
  fb:set(24, cd)
  fb:set(25, cd)

  local wix = 1
  twing[wix]()

  t:register(400, tmr.ALARM_AUTO, function()
    wix = wix + 1
    if wix > #twing then
      wix = 1
    end
    if math.random(8) == 1 then -- update head and rider position
      fb:set(8, z) fb:set(15,z) fb:set(16,z) fb:set(24,z)
      setchoice(thead[math.random(#thead)](), cr)
    end
    if math.random(10) == 1 then -- update tail position
      fb:set(9, z) fb:set(17, z) fb:set(25, z) setchoice({9, 17, 25}, cd)
    end

    twing[wix]()
    dodraw()
  end)

end
