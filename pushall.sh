#!/bin/bash

set -e -u

. ./host/pushcommon.sh

dopushcompile net/nwfmqtt.lua
dopushcompile cap1188/cap1188.lua
dopushcompile cap1188/cap1188-init.lua
dopushcompile examples/lamp/lamp-touch.lua
dopushcompile examples/lamp/lamp-remote.lua
dopushcompile examples/lamp/telnetd-cap.lua
dopush        examples/lamp/conf/nwfmqtt.conf
dopush        examples/lamp/conf/nwfmqtt.subs
dopushcompile examples/lamp/init2.lua

for i in examples/lamp/draw-*.lua; do
  dopushcompile ${i}
done

echo "SUCCESS"
