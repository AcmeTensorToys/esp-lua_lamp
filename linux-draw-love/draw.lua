-- LOVE interface
limg = require "love.image"
ltmr = require "love.timer"
lthr = require "love.thread"

imgd = limg.newImageData(8,4)
netchan = lthr.getChannel ( "netc" )
framechan = lthr.getChannel ( "framec" )

-- emulate enough framebuffer functionality, backed by a Lua array <<<
ws2812 = {}
ws2812.SHIFT_LOGICAL = 0
ws2812.SHIFT_CIRCULAR = 1

remotefb = {}
remotefb.length = 32
function remotefb.set(self,ix,a1,a2,a3)
  if ix > self.length then return end
  if type(a1) == 'string' and a2 == nil and a3 == nil then
    self[ix] = a1
  else
    self[ix] = string.char(math.floor(a1),math.floor(a2),math.floor(a3))
  end
end
function remotefb.size(self) return self.length end
function remotefb.fade(self,factor,out)
  local ix, f
  if not out
   then f = function(c) return string.char(string.byte(c,1) / factor) end
   else f = function(c) return string.char(string.byte(c,1) * factor) end
  end
  for ix = 1,self.length do self[ix] = self[ix]:gsub(".", f) end
end
function remotefb.fill(self,...)
  local i
  for i = 1,self.length do self:set(i,...) end
end
function remotefb.shift(self,n,m,i,j)
  if      j == nil then j = self.length
   elseif j < 0    then j = self.length - j
                        if j <= 0 then return end
   elseif j == 0 then return
   elseif j > self.length then return
  end
  if      i == nil then i = 1
   elseif i < 0    then i = self.length - i
                        if i <= 0 then return end
   elseif i == 0 then return
   elseif i > self.length then return
  end

  if m == nil then m = remotefb.SHIFT_LOGICAL end

  if n == 0 then return
  elseif n > 0 then
    local ix
    for ix = 1, n do
      local v = table.remove(self,j)
      if m == ws2812.SHIFT_LOGICAL then v = string.char(0,0,0) end
      table.insert(self,i,v)
    end
  elseif n < 0 then
    local ix
    for ix = 1, -n do
      local v = table.remove(self,i)
      if m == ws2812.SHIFT_LOGICAL then v = string.char(0,0,0) end
      table.insert(self,j,v)
    end
  end
end
remotefb:fill(0,0,0)
-- >>>
-- drawfailsafe and dodraw <<<
local function drawfailsafe(t,fb,p) fb:fill(0,0,0) end
function loaddrawfn(name)
  local f = loadfile (string.format("draw-%s.lua",name))
  local fn = f and f()
  if fn
   then return function(t,fb,p) return fn(t,fb,p) end
   else return drawfailsafe
  end
end

-- dump the ws2812 array into a LOVE image and push it into a channel
function dodraw()
  local ix = 0, r, c
  for r = 0,3 do
    for c = 0,7 do
      ix = ix + 1 
      imgd:setPixel(c, r,
        math.min(0xFF,string.byte(remotefb[ix],2)*16)/256,
        math.min(0xFF,string.byte(remotefb[ix],1)*16)/256,
        math.min(0xFF,string.byte(remotefb[ix],3)*16)/256
      )
    end
  end

  framechan:push(imgd)
end
--- >>>
-- timer queue and tmr emulation <<<

local snooze = 1
tq = require("core/tq/tq")(nil)
tq.now = function() return ltmr.getTime() * 1000000 end
tq.arm = function(self,t,et)
  snooze = (t + 20) / 1000 -- round up a bit so we don't so often undershoot
end
local tqf = tq.fire
tq.fire = function(self) snooze = nil ; tqf(self) end

-- how backwards is this!?  We are using tq as faked above for tmr support
-- since it's not obvious to me how to remove pending events in cqueues.
tmr = {}
tmr.ALARM_SINGLE = 0
tmr.ALARM_SEMI   = 1
tmr.ALARM_AUTO   = 2
function tmr._start(self)
  if self.fn then self.tqe = tq:queue(self.period,self.fn) end
end
function tmr.stop(self)
  if self.tqe then tq:dequeue(self.tqe); self.tqe = nil end
end
function tmr.unregister(self)
  self:stop()
  self.fn = nil
end
function tmr.register(self,period,mode,fn)
  tmr.stop(self)

  self.period = period
  if mode == tmr.ALARM_AUTO then
    self.fn = function() tmr._start(self); fn() end
  else
    self.fn = fn
  end
end
function tmr.start(self)
  tmr.stop(self)
  tmr._start(self)
end
function tmr.alarm(self,period,mode,fn)
  tmr.stop(self)
  tmr.register(self,period,mode,fn)
  tmr.start(self)
end
function tmr.interval(self, period)
  self.period = period
  if self.tqe == nil then return end -- just update interval
  self:start() -- otherwise, re-schedule
end
tmr_mt = { __index = tmr }
function tmr.create()
  return setmetatable({}, tmr_mt)
end

-- >>>
-- remote timer management <<<

remotetmr = tmr.create()
remoteqtmrs = {}

function removeremote()
  local k,v

  -- drop all pending script timers
  for k,v in pairs(remoteqtmrs) do v:unregister() end
  remoteqtmrs = {}

  -- and the current remote animation's timer
  remotetmr:unregister()
end

-- >>>

while true do
  local line = netchan:demand(snooze)

  if line then
    local from, cmd = line:match("^(%S+)%s+(.*)$")
    if cmd then dofile("lamp-remote.lua")(cmd) end
  end

  tq:fire()
end
