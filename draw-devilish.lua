-- o x o o x o o x
-- x o o x o o x o
-- x o o o o x x o
-- o x o o x o o x
return function(t,fb,p)
  fb:fill(0,0,0)
  local c = p[1]
  fb:set( 2,c) fb:set( 5,c) fb:set( 8,c)
  fb:set( 9,c) fb:set(12,c) fb:set(15,c)
  fb:set(17,c) fb:set(22,c) fb:set(23,c)
  fb:set(26,c) fb:set(29,c) fb:set(32,c)
end
