local resntpPeriod = 1800000
local mqttHeartbeat = 600000
local mqttUser

-- some exported modules for overlay and REPL use
-- XXX timer 5 reserved for the eventual day that we want animations in lamp-draw.lc
tq = (dofile "tq.lc")(6)            -- timer 6
nwfnet = require "nwfnet"
mqc, mqttUser = dofile("nwfmqtt.lc").mkclient("nwfmqtt.conf")
local mqttBcastPfx = string.format("lamp/%s/out",mqttUser)
local mqttHeartTopic = string.format("lamp/%s/boot",mqttUser)
cap = require "cap1188"

-- telnetd overlay
tcpserv = net.createServer(net.TCP, 120)
tcpserv:listen(23,function(k)
  local telnetd = dofile "telnetd.lc"
  telnetd.on["conn"] = function(k) k:send(string.format("%s [NODE-%06X]",mqttUser,node.chipid())) end
  telnetd.server(k)
end)

-- Maybe SNTP sync periodically, if we ever come to care about the time (XXX?)
-- dofile("nwfnet-sntp.lc").loopsntp(tq,resntpPeriod,nil)

-- hardware setup
ws2812.init(ws2812.MODE_SINGLE)     -- uses GPIO2
i2c.setup(0,2,1,i2c.SLOW)           -- init i2c as per silk screen (GPIO4, GPIO5)

-- and now we get to the lamp stuff
remotefb = ws2812.newBuffer(32,3)
ledfb = remotefb -- points at whichever buffer is appropriate to draw
ledfb_claimed = 0 -- 0 : unclaimed, set remote immediately
                  -- 1 : claimed locally but remote has not changed
                  -- 2 : claimed locally but remote has changed

isblackout = false
function dodraw() if not isblackout then ws2812.write(ledfb) end end
function doremotedraw() if ledfb_claimed > 1 then ledfb_claimed = 2 else ledfb = remotefb; dodraw() end end

function leddefault(fb,...) fb:fill(0,0,0); local ix; for ix = 25,32 do fb:set(ix,...) end end

-- MQTT-driven local setting
local mqtt_revert = nil
nwfnet.onmqtt["lamp"] = function(c,t,m) if t and m and t:find("^lamp/[^/]+/out") then dofile("lamp-remote.lc")(m) end end

-- TODO: messages to specific lamps?  Multiple brokers?
function lamp_announce(fn,g,r,b) mqc:publish(mqttBcastPfx,string.format("0 %s %x %x %x",fn,r,g,b),1,1) end

-- mqtt setup
local mqtt_beat_cancel
local mqtt_reconn_poller
local function mqtt_reconn()
  mqtt_reconn_poller = tq:queue(30000,mqtt_reconn)
  mqc:close(); dofile("nwfmqtt.lc").connect(mqc,"nwfmqtt.conf")
end

-- network callbacks
nwfnet.onnet["init"] = function(e,c)
  if     e == "mqttdscn" and c == mqc then
    if mqtt_beat_cancel then mqtt_beat_cancel(); mqtt_beat_cancel = nil end
    if not mqtt_reconn_poller then mqtt_reconn() end
    dofile("lamp-draw.lc").xx(remotefb,0,5,0); doremotedraw()
  elseif e == "mqttconn" and c == mqc then
    if mqtt_reconn_poller then tq:dequeue(mqtt_reconn_poller); mqtt_reconn_poller = nil end
    if not mqtt_beat_cancel then mqtt_beat_cancel = dofile("nwfmqtt.lc").heartbeat(mqc,mqttHeartTopic,tq,mqttHeartbeat) end
    mqc:publish(mqttHeartTopic,"alive",1,1)
    mqc:subscribe(string.format("lamp/+/out/%s",mqttUser),1)
    dofile("nwfmqtt.lc").suball(mqc,"nwfmqtt.subs")
    leddefault(remotefb,0,16,16); doremotedraw()
  elseif e == "wstagoip"              then
    if not mqtt_reconn_poller then mqtt_reconn() end
    leddefault(remotefb,0,0,4); doremotedraw()
  elseif e == "wstaconn"              then
    leddefault(remotefb,0,4,0); doremotedraw()
  end
end

-- touch overlay loader
function ontouch_load() dofile("lamp-touch.lc") end

-- pin 6 (GPIO12) is cap sensor IRQ (active low)
-- pin 5 (GPIO14) is cap sensor reset (active low)
dofile("cap1188-init.lc").init(6,5,ontouch_load)

-- initialize display
dofile("lamp-draw.lc").xx(remotefb,0,5,5); dodraw()

-- initialize network
dofile("nwfnet-diag.lc")(true)
dofile("nwfnet-go.lc")
