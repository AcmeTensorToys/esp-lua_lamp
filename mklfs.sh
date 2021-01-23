#!/bin/bash

set -e -u

SOURCES=(
  lamp-lfs-strings.lua
  core/cap1188/cap1188.lua
  core/cap1188/cap1188-init.lua
  core/firm/lua_modules/fifo/fifo{,sock}.lua
  core/net/{nwfmqtt,nwfnet*}.lua
  core/telnetd/telnetd{,-{diag,file}}.lua
  core/tq/tq.lua
  core/util/compileall.lua
  core/util/diag.lua
  core/util/lfs-strings.lua

  init2.lua
  init-early.lua
  lamp-remote.lua
  lamp-touch.lua
  telnetd-lamp.lua

  draw-*.lua
)

rm -rf _lfs_build
mkdir _lfs_build

# for i in ${SOURCES[@]}; do
#   lua5.1 -e "package.path=package.path..';core/_external/luasrcdiet/?.lua'" \
#     core/_external/luasrcdiet/bin/luasrcdiet $i -o _lfs_build/`basename $i` --quiet
# done
cp ${SOURCES[@]} _lfs_build/

if [ -z "${LUACROSS-}" ]; then
  OZF=lamplfs.zip
  (cd _lfs_build; zip ${OZF} *.lua)
  echo "Please send _lfs_build/${OZF} to https://blog.ellisons.org.uk/article/nodemcu/a-lua-cross-compile-web-service/"
else
  echo "Compiling image locally..."
  (cd _lfs_build; $LUACROSS -f *.lua)
fi
