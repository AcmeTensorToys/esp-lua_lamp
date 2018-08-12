#!/bin/bash

set -e -u

SOURCES=(
  lamp-lfs-strings.lua
  core/cap1188/cap1188.lua
  core/cap1188/cap1188-init.lua
  core/fifo/fifo.lua
  core/net/{fifosock,nwfmqtt,nwfnet*}.lua
  core/telnetd/telnetd{,-{diag,file}}.lua
  core/tq/tq.lua
  core/util/compileall.lua
  core/util/diag.lua
  core/util/lfs-strings.lua
)

rm -rf _lfs_build
mkdir _lfs_build

# for i in ${SOURCES[@]}; do
#   lua5.1 -e "package.path=package.path..';core/_external/luasrcdiet/?.lua'" \
#     core/_external/luasrcdiet/bin/luasrcdiet $i -o _lfs_build/`basename $i` --quiet
# done
cp ${SOURCES[@]} _lfs_build/

(cd _lfs_build; $LUACROSS -f *.lua)
