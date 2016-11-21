-- GLOBAL: tq, remotefb, doremotedraw, remotetmr, loaddrawfn, remotetqh

return function(msg)
  if remotetqh then tq:dequeue(remotetqh) end

  local fifo = (require "fifo")()
  local function fdq() if not fifo:dequeue(function(k) k() end) then remotetqh = nil end end

  local d,m,r,g,b

  for d,m,r,g,b in msg:gmatch("(%d+)%s+(%w+)%s+(%x+)%s+(%x+)%s+(%x+)%s*;") do
    g = tonumber(g,16); r = tonumber(r,16); b = tonumber(b,16); d = tonumber(d)
    if d and d > 0 then
      fifo:queue(function() remotetqh = tq:queue(d,fdq) end)
    end
    fifo:queue(function()
      remotetmr:unregister()
      loaddrawfn(m)(remotetmr,remotefb,g,r,b); doremotedraw()
      remotetqh = tq:queue(1,fdq) -- run on callback to avoid stack problems
    end)
  end
  fdq() -- start party
end
