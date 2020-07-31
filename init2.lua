local mqttUser

-- some exported modules for overlay and REPL use
remotetmr = tmr.create()
touchtmr = tmr.create()
tq = OVL.tq()(tmr.create())
nwfnet = require "nwfnet"
mqc, mqttUser = OVL.nwfmqtt().mkclient("nwfmqtt.conf")
if mqttUser == nil then
  print("YOU FORGOT YOUR MQTT CONFIG FILE!")
end
local mqttBcastPfx = string.format("lamp/%s/out",mqttUser)
local mqttHeartTopic = string.format("lamp/%s/boot",mqttUser)
cap = require "cap1188"
remoteqtmrs = {}
isTouch = false
pendRemoteMsg = nil

local function drawfailsafe(t,fb,p) fb:fill(p[1]:byte(1),p[1]:byte(2),p[1]:byte(3)) end
function loaddrawfn(name)
  local f = OVL[string.format("draw-%s",name)]
  local fn = f and f()
  if fn then return fn else return drawfailsafe end
end

-- telnetd overlay
tcpserv = net.createServer(net.TCP, 120)
tcpserv:listen(23,function(k)
  local telnetd = OVL.telnetd()
  telnetd.on["conn"] = function(k) k(string.format("%s [NODE-%06X]",mqttUser,node.chipid())) end
  telnetd.server(k)
end)

-- hardware setup
ws2812.init(ws2812.MODE_SINGLE)     -- uses GPIO2
i2c.setup(0,2,1,i2c.SLOW)           -- init i2c as per silk screen (GPIO4, GPIO5)

-- and now we get to the lamp stuff
remotefb = ws2812.newBuffer(32,3)
ledfb = remotefb -- points at whichever buffer is appropriate to draw
isblackout = false
isDim = true
dimfactor = 0
local baselinefb = ws2812.newBuffer(32,3)
baselinefb:fill(1,1,1)
local doublefb = ws2812.newBuffer(32,3)
function dodraw()
  if not isblackout then
    local b = ledfb
    if dimfactor > 0 then
      -- dimming, so mix the baseline "all channels on minimum" as 127/256ths
      -- to control rounding (see below).  The image in "ledfb" will be mixed
      -- in as 256/(dimfactor+1) 256ths.
      --
      -- As of nodemcu bd0549ac4aca3455d161bc81b05459d396061854, :mix() itself
      -- rounds by adding 128/256 to the input and then truncating the bottom 8
      -- bits after summation, so adding 127 more means that we now round up
      -- (i.e., by ceil), so an active channel will remain active.
      doublefb:mix(127,baselinefb,256/(dimfactor+1),ledfb)
      b = doublefb
    end
    gpio.write(3,gpio.HIGH)
    ws2812.init(ws2812.MODE_SINGLE)
    ws2812.write(b)
    -- Wait for the UART to drain and for the LED strip to latch (nominally
    -- 350 usec).  This isn't really OK, but we're probably not pushing the
    -- 15 mSec or so that the SDK says we have?
    tmr.delay(350)
    gpio.write(3,gpio.LOW)
    gpio.mode(4,gpio.INPUT) -- LED off
  end
end
-- Not ideal, but at least this keeps all the gpio wibbling to this one file
function doblackout()
  isblackout = true
  gpio.write(3,gpio.HIGH)
  ws2812.init(ws2812.MODE_SINGLE)
    ws2812.write(string.char(0):rep(32*3))
    tmr.delay(350)
  gpio.write(3,gpio.LOW)
  gpio.mode(4,gpio.INPUT) -- LED off
end

function removeremote()
  local k,v

  -- drop all pending script timers
  for k,v in pairs(remoteqtmrs) do v:unregister() end
  remoteqtmrs = {}

  -- and the current remote animation's timer
  remotetmr:unregister()
end

local function remotemsg(m)
  if isTouch
   then pendRemoteMsg = m
   else
    touchtmr:unregister()
    ledfb = remotefb
    removeremote()
    OVL["lamp-remote"]()(m)
  end
end

-- MQTT-driven local setting
nwfnet.onmqtt["lamp"] = function(c,t,m)
  if t and m and t:find("^lamp/[^/]+/out") then remotemsg(m) end
end

local function transformcolors(color)
  local g = color[1]
  local r = color[2]
  local b = color[3]
  return r,g,b
end

-- TODO: messages to specific lamps?  Multiple brokers?
function lamp_announce(fn,colors)
  local ct = {}
  local i
  for i=2,#colors do
    ct[#ct+1] = string.format("color %x %x %x %x; ", i, transformcolors(colors[i]))
  end
  ct[#ct+1] = string.format("draw %s %x %x %x;", fn, transformcolors(colors[1]))
  mqc:publish(mqttBcastPfx, table.concat(ct),1,1)
end

-- mqtt setup
local mqtt_reconn_timer
local function mqtt_reconn(_t)
  mqc:close(); OVL.nwfmqtt().connect(mqc,"nwfmqtt.conf")
end
local function mqtt_conn()
  mqtt_reconn_timer = tmr.create()
  mqtt_reconn(mqtt_reconn_timer)
  mqtt_reconn_timer:alarm(30000,tmr.ALARM_AUTO,mqtt_reconn)
end

local mqtt_beat_cron

local wifitmr = tmr.create()
wifitmr:register(10000, tmr.ALARM_SEMI, function() OVL["nwfnet-go"]() end)

-- network callbacks
nwfnet.onnet["init"] = function(e,c)
  if     e == "mqttdscn" and c == mqc then
    if mqtt_beat_cron then mqtt_beat_cron:unschedule(); mqtt_beat_cron = nil end
    if not mqtt_reconn_timer then mqtt_conn() end
    remotetmr:unregister()
    remotemsg("draw xx 4 0 0 ;")
  elseif e == "mqttconn" and c == mqc then
    if mqtt_reconn_timer then
      mqtt_reconn_timer:unregister()
      mqtt_reconn_timer = nil
    end
    mqtt_beat_cron = cron.schedule("*/5 * * * *",function(e) mqc:publish(mqttHeartTopic,"beat",1,1) end)
    mqc:publish(mqttHeartTopic,"alive",1,1)
    mqc:subscribe(string.format("lamp/+/out/%s",mqttUser),1)
    OVL.nwfmqtt().suball(mqc,"nwfmqtt.subs")
    remotemsg("draw xx 4 0 4 ;")
  elseif e == "wstagoip"              then
    if not mqtt_reconn_poller then mqtt_reconn() end
    remotemsg("draw xx 0 0 4 ;")
    wifitmr:stop()
  elseif e == "wstaconn"              then
    remotemsg("draw xx 0 4 0 ;")
  elseif e == "wstadscn"              then
    wifitmr:start()
  end
end

-- initialize display
remotemsg("draw xx 4 0 0;")

-- touch overlay loader
function ontouch_load() OVL["lamp-touch"]() end

-- pin 6 (GPIO12) is cap sensor IRQ (active low)
-- pin 5 (GPIO14) is cap sensor reset (active low)
OVL["cap1188-init"]().init(6,5,ontouch_load)

-- initialize network
OVL["nwfnet-diag"]()(true)
OVL["nwfnet-go"]()
wifitmr:start()
