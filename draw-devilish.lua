return function(t,fb,g,r,b)
  t:unregister()
  fb:fill(0,0,0)
  local c = string.char(g,r,b)
  fb:set( 2,c) fb:set( 5,c) fb:set( 8,c) fb:set( 9,c)
  fb:set(10,c) fb:set(12,c) fb:set(15,c) fb:set(17,c)
  fb:set(18,c) fb:set(22,c) fb:set(23,c) fb:set(26,c)
  fb:set(29,c) fb:set(32,c)
end