return function(t,fb,p)
  local ix = 1
  local c = p[1]
  fb:fill(0,0,0)
  t:register(50,tmr.ALARM_AUTO,function()
    fb:fade(2); fb:set(ix,c); dodraw()
    ix = ix + 1; if ix > fb:size() then ix = 1 end
  end)
end
