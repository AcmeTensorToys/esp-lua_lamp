return function(t,fb,g,r,b)
  local ix = 1
  local c = string.char(g,r,b)
  fb:fill(0,0,0)
  t:register(50,tmr.ALARM_AUTO,function()
    fb:fade(2); fb:set(ix,c); dodraw()
    ix = ix + 1; if ix > fb:size() then ix = 1 end
  end)
end
