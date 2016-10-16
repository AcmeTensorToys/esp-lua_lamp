-- GLOBAL: tq, remotefb, leddefault, doremotedraw, mqtt_revert, remotetmr, loaddrawfn

local function ledrevert(ix)
  if ix < 3 then
    remotetmr:unregister() 
    remotefb:fade(2) doremotedraw()
    tq:queue(500,function() ledrevert(ix+1) end)
  else leddefault(remotefb,0,16,16) end
  dodraw()
end

return function(msg)
  if mqtt_revert then tq:dequeue(mqtt_revert) end

  local ix, _, d, m, r, g, b = msg:find("^(%d+)%s+(%w+)%s+(%x+)%s+(%x+)%s+(%x+)%s*$")
  if ix then
    g = tonumber(g,16); r = tonumber(r,16); b = tonumber(b,16)

    remotetmr:unregister()
    loaddrawfn(m)(remotetmr,remotefb,g,r,b); doremotedraw()

    -- if there's a duration set, register a timer to reset the display to the default
    local dn = tonumber(d)
    if dn and dn > 0 then tq:queue(math.min(dn,6870947),ledrevert,0) end
  end

end
