-- pin 3 (GPIO0) is AND-gate input while drawing
gpio.mode(3,gpio.OUTPUT,gpio.FLOAT)

ws2812.init(ws2812.MODE_SINGLE)     -- uses GPIO2
local fb = ws2812.newBuffer(32,3)
fb:fill(0,0,0)
gpio.write(3,gpio.HIGH)
ws2812.write(fb)
gpio.write(3,gpio.LOW)
