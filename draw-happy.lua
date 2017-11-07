--
--    1 2 3 4 5 6 7 8
-- 00 o x o o o o x o
-- 08 x o x o o x o x
-- 16 o o o o o o o o
-- 24 o o o x x o o o
--
return function(t,fb,p)
  local c = p[1]
  local i,v
  fb:fill(0,0,0)
  for i,v in ipairs({2,7,9,11,14,16,28,29}) do fb:set(v,c) end
end
