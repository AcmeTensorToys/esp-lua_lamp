return function(t,fb,p)
  local c = p[1]
  local c2 = p[2] or c
  local z = string.char(0,0,0)

  local s = {}
  local b = {}

  -- fill sequence table
  local ft = { [1] = function() local k,v for k,v in ipairs(s) do fb:set(8  + v,c2) end end, -- side chambers
               [2] = function() local k,v for k,v in ipairs(s) do fb:set(8  + v,z)  end
                                local k,v for k,v in ipairs(b) do fb:set(16 + v,c2) end end, -- bottom chambers
               [3] = function() local k,v for k,v in ipairs(b) do fb:set(16 + v,z)  end end, -- empty
               [4] = function()                                                         end  -- stay empty
             }

  -- heart sequence table (leftmost column only; see use of fb:shift below)
  local ht = { [1] = function() fb:set(9,c)              end,
               [2] = function() fb:set(1,c) fb:set(17,c) table.insert(s,1,1) end,
               [3] = function() fb:set(9,c) fb:set(25,c) table.insert(b,1,1) end,
               [4] = function() fb:set(1,c) fb:set(17,c) table.insert(s,1,1) end,
               [5] = function() fb:set(9,c)              end,
               [6] = function()                          end,
             }

  -- update fill positions when advancing frame
  local function fm()
    local k,v
    for k,v in ipairs(b) do if v == 8 then table.remove(b,k) else b[k] = v+1 end end
    for k,v in ipairs(s) do if v == 8 then table.remove(s,k) else s[k] = v+1 end end
  end

  fb:fill(0,0,0)

  local tix = 0
  local fix = #ft
  local hix = 1
  t:register(150,tmr.ALARM_AUTO,function()
    fm() ; fb:set(8,z) fb:set(16,z) fb:set(24,z) ; fb:shift(1,ws2812.SHIFT_LOGICAL)

    -- heart positions
    ht[hix]()
    hix = (hix == #ht and 1) or hix + 1

    -- fill positions always render (may be superfluous)
    tix = (tix + 1) % 3
    if tix == 0 then
      fix = (fix == #ft and 1) or fix + 1
    end
    ft[fix]()

    dodraw()
  end)
end
