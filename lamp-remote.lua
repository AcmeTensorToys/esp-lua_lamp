-- GLOBAL: tq, remotefb, leddefault, doremotedraw, mqtt_revert

local function ledrevert(ix)
  if ix < 3 then
    remotefb:fade(2) doremotedraw()
    tq:queue(500,function() ledrevert(ix+1) end)
  else leddefault(remotefb,0,16,16) end
  dodraw()
end

return function(m)
  if mqtt_revert then tq:dequeue(mqtt_revert) end

  local ix, _, d, m, r, g, b = m:find("^(%d+)%s+(%w+)%s+(%x+)%s+(%x+)%s+(%x+)%s*$")
  if ix then
    g = tonumber(g,16); r = tonumber(r,16); b = tonumber(b,16)
    local f = loadfile "lamp-draw.lc"
    local fn = f and type(f) == "table" and f[m]
    if fn then fn(doremotedraw,remotefb,g,r,b)
     else remotefb:fill(g,r,b); doremotedraw() -- failsafe
    end
    -- if there's a duration set, register a timer to reset the display to the default
    local dn = tonumber(d)
    if dn and dn > 0 then tq:queue(math.min(dn,6870947),ledrevert,0) end
  end

end
