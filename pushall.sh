#!/bin/zsh

set -e -u

. ./core/host/pushcommon.sh

if [ -z ${LUACROSS:-} ] ; then
  . ./core/host/pushinit.sh
  dopushcompile core/net/nwfmqtt.lua
  dopushcompile core/cap1188/cap1188.lua
  dopushcompile core/cap1188/cap1188-init.lua
else
  ./mklfs.sh
  dopushtext _lfs_build/luac.out
fi

dopushcompile lamp-touch.lua
dopushcompile lamp-remote.lua
dopushcompile telnetd-cap.lua
#dopushtext    conf/nwfmqtt.conf
#dopushtext    conf/nwfmqtt.subs
dopushlua     init-early.lua
dopushcompile init2.lua

for i in draw-*.lua; do
  dopushcompile ${i}
done

echo "SUCCESS"
