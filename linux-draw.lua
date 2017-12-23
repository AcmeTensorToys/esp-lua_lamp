-- Expects to be fed a series of draw commands on stdin and a worker module
-- lua file (e.g. ...-xpm.lua or ...-morse.lua) as argv[1].
--
-- This wraps around lamp-remote.lua for all the parsing logic (ain't code
-- reuse great?) and expects the worker modules to provide "enough" of the
-- nodemcu environment for whatever else they load.  e.g. -xpm provides a
-- full frame buffer emulation and loads the various draw-*.lua modules just
-- like the hardware, while -morse does nothing of the sort.

cq = require "cqueues"
local cqs = require "cqueues.signal"
cqc = cq.new()
package.loaded["fifo"] = require "fifo/fifo"

function printerr(...)
  local s = "", i, v
  for i,v in ipairs{...} do s = s .. tostring(v) .. "\t" end
  s = s .. "\n"
  io.stderr:write(s)
end

-- Emulate tq with facilities available thanks to cqueues.
--
-- It might be OK that we don't (and can't) cancel the coroutines spawned
-- by arm because the callback is observably idempotent, but it keeps extras
-- laying around, and they might accumulate without bound.  So we have a
-- notion of which callback was registered last and the others turn into
-- NOPs by comparing the current callback against the value we closed over.
tq = require("tq/tq")(nil)
tq.__emu_lastcb = 0
tq.now = function() return cq.monotime() * 1000000 end
tq.arm = function(self,t,et)
  local cbix = tq.__emu_lastcb + 1
  tq.__emu_lastcb = cbix
  cqc:wrap(function() cq.poll(t/1000) ; if tq.__emu_lastcb == cbix then tq:fire() end end)
end

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
tmr_mt = { __index = tmr }
function tmr.create()
  return setmetatable({}, tmr_mt)
end

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

remotefb = {}

if arg[1] then dofile(arg[1]) else print("You probably meant to give a filename"); os.exit(1) end

cqc:wrap(function()
  while true do
    cq.poll({ pollfd = 0, events = 'r' })
    local line = io.read() -- XXX :(
    if line == nil or line == "" then return end
    printerr("line: " .. line)
    local from, cmd = line:match("^(%S+)%s+(.*)$")
    dofile("lamp-remote.lua")(cmd)
  end
end)
io.stdout:setvbuf("no")

cqc:wrap(function()
  cq.poll(cqs.listen(cqs.SIGINT, cqs.SIGTERM, cqs.SIGQUIT))
  print("exit")
  os.exit()
end)
cqs.block(cqs.SIGINT)
cqs.block(cqs.SIGTERM)
cqs.block(cqs.SIGQUIT)

cqc:wrap(function()
  cq.poll(cqs.listen(cqs.SIGHUP))
  print("hup")
end)
cqs.block(cqs.SIGHUP)

assert(cqc:loop())
