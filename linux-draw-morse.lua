package.loaded["morse"] = dofile("../core/morse/morse.lua")

local dit = 500 -- milliseconds

function dodraw() end

function loaddrawfn(name)
  local m = (require"morse")(name)
  printerr(name)
  return function (t,_,p)
    local g = p[1]:byte(1)
    local r = p[1]:byte(2)
    local b = p[1]:byte(3)
    local function onf()
      print(string.format("%x %x %x",r,g,b))
    end
    local function offf() print("0 0 0") end

    local function morsecb(dur,on)
     if on then onf() else offf() end
     t:alarm(dur*250,tmr.ALARM_SINGLE,function()
       local did = m(morsecb)
       if not did then
          offf() -- off at end
          -- t:alarm(1000,tmr.ALARM_SINGLE,function() (require"morse")(name)(morsecb) end) -- cyclic behavior
          t:alarm(dit,tmr.ALARM_SINGLE,function() onf() end) -- solid at end
       end
      end)
    end
    -- begin by being solid on for 10 dit times, then off for 4, then run
    -- morse sequence
    onf()
    t:alarm(10*dit,tmr.ALARM_SINGLE, function()
      offf() ; t:alarm(4*dit,tmr.ALARM_SINGLE,function() m(morsecb) end)
     end)
  end
end

