-- GLOBAL: tq, remotefb, doremotedraw, remotetmr, loaddrawfn, remotetqh, remotefifo

if not remotefifo then remotefifo = (require "fifo")() end

-- dequeue from remotefifo; if nothing to dequeue, clean up
local function fdq()
  if not remotefifo:dequeue(function(k) k() end)
   then remotetqh = nil; remotefifo = nil
  end
end

-- queue to remotefifo; if fifo has emptied, fire callback immediately,
-- otherwise, let the functions manage their own timeline
local function fq(what)
  remotefifo:queue(what,fdq)
end

return function(msg)

  local vt = {
    ['new'] = function(_)
      -- really only sensible at the start of a message; throw out
      -- the existing fifo, if any, and stop whatever time event is
      -- pending
      remotefifo = (require "fifo")()
      tq:dequeue(remotetqh)
     end,
    ['wait'] = function(s)
      -- step the fifo in d milliseconds
      local d = tonumber(s) 
      if d and d > 0 then fq(function() remotetqh = tq:queue(d,fdq) end) end
     end,
    ['draw'] = function(s)
      -- engage a drawing function and post a time event to pop the fifo
      -- on the next tick (for, e.g., delay's use).  This is done on a
      -- callback to prevent deep stacks.
      local m,r,g,b = s:match("^(%w+)%s+(%x+)%s+(%x+)%s+(%x+)%s*$")
      g = tonumber(g,16); r = tonumber(r,16); b = tonumber(b,16)
      if m then
        fq(function()
          remotetmr:unregister()
          loaddrawfn(m)(remotetmr,remotefb,g,r,b); doremotedraw()
          remotetqh = tq:queue(1,fdq)
         end)
      end
    end,
  }

  vt["0"] = vt.draw -- XXX hack for backwards compatibility

  -- loop over all ;-delimited statements in the message and fire
  -- them off.  Note that by default this will *append* to the fifo,
  -- making messages not entirely idempotent (unless they start with
  -- "new").
  local c,as
  for c,as in msg:gmatch("(%w*)%s*([^;]*);%s*") do
    if c then vt[c](as) end
  end
end
