-- emulate enough framebuffer functionality
ws2812 = {}
ws2812.SHIFT_LOGICAL = 0
ws2812.SHIFT_CIRCULAR = 1

remotefb.length = 32
function remotefb.set(self,ix,a1,a2,a3)
  -- printerr(ix,a1,a2,a3)
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

  local ix

  for ix = 1, n do
    local v = table.remove(self,j)
    if m == ws2812.SHIFT_LOGICAL then v = string.char(0,0,0) end

    table.insert(self,i,v)
  end
end
remotefb:fill(0,0,0)

local function drawfailsafe(t,fb,p) fb:fill(0,0,0) end
function loaddrawfn(name)
  local f = loadfile (string.format("draw-%s.lua",name))
  local fn = f and f()
  if fn
   then return function(t,fb,p) return fn(t,fb,p) end
   else return drawfailsafe
  end
end

local outfn = "/run/user/1000/lamp-purple.xpm"
local tmpfn = outfn .. ".tmp"
local drawstr = "abcdefghijklmnopqrstuvwxzy123456"
local drawstr2 = ""
local function computedrawstr2()
  local ix = 0, r, c
  for r = 1,4 do
    local line = ""
    for c = 1,8 do
      ix = ix + 1
      local h = drawstr:sub(ix,ix)
      if c ~= 1 then line = line .. "0" end
      line = line .. h .. h
    end
    line = line .. "\n"
    if r ~= 1 then drawstr2 = drawstr2 .. "00000000000000000000000\n" end
    drawstr2 = drawstr2 .. line
    drawstr2 = drawstr2 .. line
  end
end
computedrawstr2()
local function pixelval(byteval)

end
function dodraw()
  local f = io.open(tmpfn,"w+")
  f:write("! XPM2\n23 11 33 1\n") -- header
  f:write("0 c #000000\n")
  local ix = 0, r, c
  for r = 1,4 do
    for c = 1,8 do
      ix = ix + 1
      f:write(string.format("%s c #%02x%02x%02x\n",
              drawstr:sub(ix,ix),
              math.min(0xFF,string.byte(remotefb[ix],2)*16), -- r
              math.min(0xFF,string.byte(remotefb[ix],1)*16), -- g
              math.min(0xFF,string.byte(remotefb[ix],3)*16)  -- b
           ))
    end
  end
  f:write(drawstr2)
  f:close()
  os.rename(tmpfn, outfn)
  io.write("\n\n") -- XXX? WTF?
  io.flush()
end
