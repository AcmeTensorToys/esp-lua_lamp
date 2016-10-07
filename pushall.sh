#!/bin/bash

set -e -u
PUSHCMD="./host/pushvia.expect ${HOST} ${PORT:-23}"
dopush() { ${PUSHCMD} ${2:-`basename $1`} $1; }
dopushcompile() { ${PUSHCMD} ${2:-`basename $1`} $1 compile; }

dopushcompile net/nwfmqtt.lua
dopushcompile cap1188/cap1188.lua
dopushcompile cap1188/cap1188-init.lua
dopushcompile examples/lamp/lamp-draw.lua
dopushcompile examples/lamp/lamp-touch.lua
dopushcompile examples/lamp/lamp-remote.lua
dopushcompile examples/lamp/telnetd-cap.lua
dopush        examples/lamp/conf/nwfmqtt.conf
dopush        examples/lamp/conf/nwfmqtt.subs
dopushcompile examples/lamp/init2.lua

echo "SUCCESS"
