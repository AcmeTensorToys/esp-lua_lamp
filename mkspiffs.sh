#!/bin/bash

set -e -u -x

: ${BOARDNAME:=test}

if [ -z "${FWSZ-}" ]; then
  FWSZ=${FWSZ:$(stat --printf="%s" ./core/firm/bin/nodemcu_integer_expect-tests.bin)}
  FWSZ=$((FWSZ + 131072)) # Pad for LFS
fi

(
	# Init is the only core Lua that does not live in LFS.
	echo import core/init.lua init.lua

	# Configuration
	echo import conf/${BOARDNAME}/nwfnet.conf nwfnet.conf
	echo import conf/${BOARDNAME}/nwfmqtt.conf nwfmqtt.conf
	echo import conf/${BOARDNAME}/nwfmqtt.subs nwfmqtt.subs

	# And the LFS image with the rest of everything
	#  We could, and used to, but we now go via the nodemcu partition tool
	# echo import _lfs_build/luac.out luac.out
) | ./core/firm/tools/spiffsimg/spiffsimg \
     -f spiffs-${BOARDNAME}.img \
     -S 4MB -U ${FWSZ} \
     -r /dev/fd/0
     
	# -c 262144 \
