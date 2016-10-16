return function(t,fb,g,r,b)
  fb:fill(0,0,0)
  local c = string.char(g,r,b)
  fb:set( 1,c) fb:set( 4,c) fb:set( 5,c) fb:set( 8,c)
  fb:set(10,c) fb:set(11,c) fb:set(14,c) fb:set(15,c)
  fb:set(18,c) fb:set(19,c) fb:set(22,c) fb:set(23,c)
  fb:set(25,c) fb:set(28,c) fb:set(29,c) fb:set(32,c)
end
