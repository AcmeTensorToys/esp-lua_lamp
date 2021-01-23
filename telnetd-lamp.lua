return {
  ["calibrate"] = function(_,s) OVL["cap1188-init"]().calibrate() end,

  ["status"] = function(_,s)
    s(("black: %s; dim: %d; fb: %s"):format(
      isblackout and "true" or "false",
      dimfactor,
      (ledfb == remotefb) and "remote" or "local"
    ))
  end
}
