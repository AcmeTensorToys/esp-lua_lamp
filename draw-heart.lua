return function(t,fb,p)
  fb:fill(0,0,0)
  local c = p[1]
               fb:set( 3,c)              fb:set( 5,c)
  fb:set(10,c) fb:set(11,c) fb:set(12,c) fb:set(13,c) fb:set(14,c)
               fb:set(19,c) fb:set(20,c) fb:set(21,c)
                            fb:set(28,c)
end
