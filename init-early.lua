ws2812.init(ws2812.MODE_SINGLE)     -- uses GPIO2
local fb = ws2812.newBuffer(32,3)
fb:fill(0,0,0)
ws2812.write(fb)
