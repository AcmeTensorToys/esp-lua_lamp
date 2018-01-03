package.loaded["morse"] = dofile("morse/morse")

local dit = 500 -- milliseconds

function loaddrawfn(name)
  local m = (require"morse")(name)
  printerr(name)
  return function (t,_,g,r,b)
    local function onf()
      print(string.format("%x %x %x",r,g,b)) 
    end
    local function offf() print("0 0 0") end

    local function morsecb(dur,on)
     if on then onf() else offf() end
     t:register(dur*250,tmr.ALARM_SINGLE,function()
       local did = m(morsecb)
       if not did then
          offf() -- off at end
          -- t:register(1000,tmr.ALARM_SINGLE,function() (require"morse")(name)(morsecb) end) -- cyclic behavior
          t:register(dit,tmr.ALARM_SINGLE,function() onf() end) -- solid at end
       end
      end)
    end
    -- begin by being solid on for 10 dit times, then off for 4, then run
    -- morse sequence
    onf()
    t:register(10*dit,tmr.ALARM_SINGLE, function()
      offf() ; t:register(4*dit,tmr.ALARM_SINGLE,function() m(morsecb) end)
     end)
  end
end
