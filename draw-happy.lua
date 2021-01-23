--
--    1 2 3 4 5 6 7 8
-- 00 o x o o o o x o
-- 08 x o x o o x o x
-- 16 o o o o o o o o
-- 24 o o o x x o o o

local face = {2,7,9,11,14,16,28,29}
local dots = {1,8,32,25}

return function(t,fb,p)
  local c = p[1]
  local i,v
  fb:fill(0,0,0)
  for i,v in ipairs(face) do fb:set(v,c) end

  local hc = p[2]
  local z = string.char(0,0,0)
  if hc then
    local ix = 1
    local nix = 2

    local adv, blink_off, blink_on
    function blink_off()
      fb:set(dots[ix], z)
      t:alarm(100, tmr.ALARM_SINGLE, blink_on)
      dodraw()
    end

    function blink_on()
      fb:set(dots[ix], hc)
      t:alarm(400, tmr.ALARM_SINGLE, adv)
      dodraw()
    end

    function adv()
      fb:set(dots[ix], z)
      fb:set(dots[nix], hc)
      ix = nix
      nix = (nix == #dots) and 1 or (nix + 1)
      t:alarm(400, tmr.ALARM_SINGLE, blink_off)
      dodraw()
    end

    adv()
  end
end
