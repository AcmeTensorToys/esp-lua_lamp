-- Expects to be invoked by linux-draw.lua (i.e. as argv[1]) and given the
-- touch module as argv[2]; will further wrap a worker module given as
-- argv[3].  Consumes from stdin and routes keys to the touch handler; keys
-- 1-6 toggle the corresponding bits in the "touch sensor".

bit = require "bit"
function bit.isset(v,b)   return bit.band(v,bit.lshift(1,b)) ~= 0 end
function bit.isclear(v,b) return bit.band(v,bit.lshift(1,b)) == 0 end

local touchcb = nil

gpio = { }
gpio.LOW = 0
gpio.HIGH = 1
function gpio.trig(p,m,fn)
  printerr("GPIO", "TRIG", fn or "nil")
  touchcb = touchcb or fn -- set once, ignore subsequent
end
function gpio.write(p,v)
  printerr("GPIO", p, v)
end

local touches = 0

cap = {}
function cap.mr(self,addr,fn)
  printerr("CAP", addr)
end
function cap.rt(self)
  return 0, touches
end

file = {}
function file.list()
  return { ["draw-happy.lc"] = 1, ["draw-heart.lc"] = 1}
end

touchtmr = tmr.create()

if arg[1]
 then local f = arg[1]; table.remove(arg,1) ; dofile(f)
 else print("You probably meant to give a filename"); os.exit(1)
end

ws2812 = ws2812 or {}
function ws2812.newBuffer()
  return remotefb
end
function ws2812.write()
  printerr("WS2182", "WRITE")
end

function lamp_announce(...)
  print("ANNOUNCE", ...)
end

if arg[1]
  then local f = arg[1]; table.remove(arg,1) ; dofile(f)
  else print("You probably meant to give a filename"); os.exit(1)
end

dimfactor = 1
isDim = true

fns = {
  ['q'] = function() os.execute("stty sane"); os.exit(0) end,
  ['1'] = function() touches = bit.bxor(touches,   1) end,
  ['2'] = function() touches = bit.bxor(touches,   2) end,
  ['3'] = function() touches = bit.bxor(touches,   4) end,
  ['4'] = function() touches = bit.bxor(touches,   8) end,
  ['5'] = function() touches = bit.bxor(touches,  16) end,
  ['6'] = function() touches = bit.bxor(touches,  32) end,
  ['7'] = function() touches = bit.bxor(touches,  64) end,
  ['8'] = function() touches = bit.bxor(touches, 128) end
}

os.execute("stty -icanon isig onlret")

onStdin = function()
  local ch = io.stdin:read(1)
  local f = fns[ch] or (function() printerr("IGNORE", ch) end)
  f()
  printerr("TLOOP", touches, dimfactor, isDim)
  if type(touchcb) == "function" then touchcb() end
end
