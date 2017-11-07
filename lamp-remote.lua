-- GLOBAL: tq, remotefb, remotetmr, loaddrawfn, remoteqtmrs

local intloop

-- dispatch table; functions take
--   (arguments, label table)
local vt = {
  -- labels have already been collected, so just ignore them now
  ['label'] = function() end,

  -- end means to break out of the processing loop
  ['end'] = function() return true end,

  -- in means to queue up a timer pointing at a label (which must already be known)
  ['in'] = function(s,ls,p)
      local d,l = s:match("^(%d+)%s+(.*)")
      if d and ls[l] then
        s = ls[l]
        d = (tonumber(d)) or 1000
        local tn = #remoteqtmrs + 1
        local t = tmr.create()
        remoteqtmrs[tn] = t
        t:alarm(d,tmr.ALARM_SINGLE,function()
          remoteqtmrs[tn] = nil
          intloop(s,ls,p)
        end)
      end
    end,

  ['color'] = function(s,_,p)
      local ix,r,g,b = s:match("^(%w+)%s+(%x+)%s+(%x+)%s+(%x+)%s*$")
      ix = tonumber(ix)
      if ix then
        g = (tonumber(g,16)) or 1; r = (tonumber(r,16)) or 1; b = (tonumber(b,16)) or 1
        p[ix] = string.char(g,r,b)
      end
    end,

  -- draw is the real reason we're here
  ['draw'] = function(s,_,p)
    -- engage a drawing function and post a time event to pop the fifo
    -- on the next tick (for, e.g., delay's use).  This is done on a
    -- callback to prevent deep stacks.
    local m,r,g,b = s:match("^(%w+)%s+(%x+)%s+(%x+)%s+(%x+)%s*$")
    if m then
      g = (tonumber(g,16)) or 0; r = (tonumber(r,16)) or 0; b = (tonumber(b,16)) or 0
      p[1] = string.char(g,r,b)
      remotetmr:unregister()
      loaddrawfn(m)(remotetmr,remotefb,p)
      remotetmr:start()
      dodraw()
    end
  end,
}

-- loop over all ;-delimited statements in the message and fire them off.
function intloop(msg,labels,palette)
  local c,as
  for c,as in msg:gmatch("(%w*)%s*([^;]*);%s*") do
    if c and vt[c] then if vt[c](as,labels,palette) then break end end
  end
end

return function(msg)
  local labels = {}
  local k,v,c,as,posn

  -- drop any prior timers
  removeremote()

  -- loop over all ;-delimeted statements and collect labels,
  -- which point at substrings of the message.
  for c,as,posn in msg:gmatch("(%w*)%s*([^;]*);%s*()") do
    if c == "label" then
      local eposs = msg:find(";%s*end",posn)
      if eposs ~= nil then
        labels[as] = msg:sub(posn,eposs+1)
      else
        labels[as] = msg:sub(posn)
      end
    end
  end

  intloop(msg,labels,{})
end
