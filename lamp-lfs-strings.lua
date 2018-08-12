local modload =
  "ALARM_AUTO", "unregister",
  "cron", "cron.entry", "schedule", "unschedule",
  "error",
  "mqtt.socket", "publish", "subscribe",
  "ws2812", "ws2812.buffer", "fill"

local lampload =
  "%s [NODE-%06X]",
  "*/5 * * * *",
  "^lamp/[^/]+/out",
  "lamp/+/out/%s",
  "alive", "beat",
  "color %x %x %x %x; ",
  "draw %s %x %x %x;",
  "draw xx 0 0 4 ;",
  "draw xx 0 4 0 ;",
  "draw xx 4 0 0 ;",
  "draw xx 4 0 4 ;",
  "draw-%s",
  "dimfactor", "dodraw", "isDim", "isTouch", "isblackout",
  "lamp", "lamp-remote", "lamp-touch", "lamp_announce", "ledfb", "loaddrawfn",
  "mix", "mqc", "mqtt_reconn_poller",
  "nwfmqtt.conf", "nwfmqtt.subs",
  "ontouch_load", "pendRemoteMsg", "remotefb", "remoteqtmrs", "remotetmr",
  "removeremote", "tcpserv", "touchtmr", "transformcolors"
 
