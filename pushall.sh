#!/bin/zsh

set -e -u

. ./core/host/pushcommon.sh

dopushcompile core/net/nwfmqtt.lua
dopushcompile core/cap1188/cap1188.lua
dopushcompile core/cap1188/cap1188-init.lua
dopushcompile lamp-touch.lua
dopushcompile lamp-remote.lua
dopushcompile telnetd-cap.lua
#dopushtext    conf/nwfmqtt.conf
#dopushtext    conf/nwfmqtt.subs
dopushcompile init2.lua

for i in draw-*.lua; do
  dopushcompile ${i}
done

echo "SUCCESS"
