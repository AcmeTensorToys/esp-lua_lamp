--    1 2 3 4 5 6 7 8
-- 00 o o o o o o o o
-- 08 o l o o f f f o
-- 16 s s s s b f o o
-- 24 o o l o f f f o
--

return function(t,fb,p)
  fb:fill(0,0,0)
  local c = p[1]
  local g = c:byte(1)
  local r = c:byte(2)
  local b = c:byte(3)
  local cdim = string.char(math.floor((g+1)/2),math.floor((r+1)/2),math.floor((b+1)/2))

  for i,v in ipairs({17,18,19,20}) do fb:set(v,0xf,0,0) end -- stem (s)
  for i,v in ipairs({10,27})       do fb:set(v,0x7,0,0) end -- leaf (l)

  local function clearflower()
    for i,v in ipairs({5,6,7,8,13,14,15,16,21,22,23,24,29,30,31,32}) do fb:set(v,0,0,0) end
  end

  local ft = {
    [1] = function() -- bud (b)
      clearflower()
      fb:set(21,cdim)
      return 1000
    end,
    [2] = function() -- enlarge bud
      fb:set(21,c)
      fb:set(22,cdim)
      return 500
    end,
    [3] = function() -- flower open
      fb:set(13,c)
      fb:set(14,cdim)
      fb:set(29,c)
      fb:set(30,cdim)
      return 500
    end,
    [4] = function() -- flower open 2
      fb:set(14,c)
      fb:set(15,cdim)
      fb:set(30,c)
      fb:set(31,cdim)
      return 2000
    end,
  }

  local ix = 1
  local function cb() 
	local dly = ft[ix]()
    ix = (ix == #ft and 1) or ix + 1
    dodraw()
	t:register(dly,tmr.ALARM_SINGLE,cb)
    t:start()
  end

  cb()
end
