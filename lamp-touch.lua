-- globals referenced: isblackout, dimfactor, isDim, dodraw, ledfb, remotefb, remotetmr, lamp_announce, tq, loaddrawfn
--
-- globals asserted: touchcolor, touchlastfn
--
-- assumptions: gpio.trig(6) is the right thing to do for touch IRQs

local touchfb = ws2812.newBuffer(32,3)
local touch_fini = nil
local touch_db_blackout = nil
local touch_db_fn = nil
local touchfns    = { }
local touchfnix = 1
local cccb        = nil
local ncolors     = 1
-- colors table initialized below, once we have touchcolorvec in scope

if touchcolor == nil then touchcolor = 40 end
if touchlastfn == nil then touchlastfn = "fill" end

-- Whip through the drawing functions and build indexes
local k,v
for k,v in pairs(file.list()) do
  local ix, _, meth = k:find("^draw%-(%w+)%.lc$")
  if ix then touchfns[#touchfns+1] = meth end
end
table.sort(touchfns)
for k,v in ipairs(touchfns) do if v == touchlastfn then touchfnix = k end end

-- ensure that there's *something* in the array; even if we can't load this
-- from the filesystem we'll hit the failsafe path in loaddrawfn
if #touchfns == 0 then touchfns[1] = "xx" end

local function claimfb()
  removeremote()
  isTouch = true
  ledfb = touchfb
end

local set0 = function(o) return bit.bor(o,0x01) end
local clear0 = function(o) return bit.band(o,0xFE) end
local function setblackout(nb)
  if nb then
    isblackout = true
    gpio.write(3,gpio.HIGH)
    ws2812.write(string.char(0):rep(32*3))
    gpio.write(3,gpio.LOW)
    cap:mr(0x81,function(o) return bit.bor(o,0x03) end) -- breathe
    cap:mr(0x74,set0) -- drive
    cap:mr(0x72,clear0) -- unlink
  else
    isblackout = false
    dodraw()
    cap:mr(0x81,function(o) return bit.band(o,0xFC) end) -- steady
    cap:mr(0x74,clear0) -- undrive
    cap:mr(0x72,set0) -- link
  end
end
local function toggleblackout() setblackout(not isblackout) end

local function dimdisplay()
  if isDim then
    dimfactor = dimfactor + 1
  else
    dimfactor = dimfactor - 1
  end
  if dimfactor == 7 then
    isDim = false
  elseif dimfactor == 0 then
    isDim = true
  end
end

local function touchcolorvec(c)
  local r, g, b
  local cm = c % 16
  if     c < 16 then r = 15 - cm; g = cm; b = 0
  elseif c < 32 then r = 0; g = 15 - cm; b = cm
  else               r = cm; g = 0; b = 15 - cm
  end
  return g,r,b
end

local colors      = { [1] = string.char(touchcolorvec(touchcolor)) }
local networkcolors = {[1] = {touchcolorvec(touchcolor)} }
local colorindex = 1;

local function onblackdebounce() touch_db_blackout = nil end
local function onfndebounce() touch_db_fn = nil end

local set30 = function(o) return bit.bor(o,0x1E) end
local clear30 = function(o) return bit.band(o,0xE1) end
local function ontouchdone()
  gpio.trig(6, "low", ontouch_load) -- unload overlay

  -- we did something.  Announce it!
  if isTouch then
    -- flash the four control LEDs to show the user that settings took
    cap:mr(0x74,set30) -- drive
    cap:mr(0x72,clear30) -- unlink
    tq:queue(100, function()
      cap:mr(0x74,clear30) -- undrive
      cap:mr(0x72,set30) -- link
    end)

    lamp_announce(touchfns[touchfnix],networkcolors)
  end

  isTouch = false

  -- leave the ledfb pointing at us; it'll get updated eventually,
  -- unless there was a remote message while we were doing our thing
  -- in which case, display it now
  if pendRemoteMsg ~= nil then
    touchtmr:unregister()
    ledfb = remotefb
    dofile("lamp-remote.lc")(pendRemoteMsg)
    pendRemoteMsg = nil
  end
end

-- must not change ledfb to touchfb unless the user interacts with us
local function ontouch()
  local _, down = cap:rt()

  local didChangeFn    = false
  local didChangeColor = false

  if touch_fini ~= nil then tq:dequeue(touch_fini) end

  -- nothing down, kick off timer for touch done
  if down == 0 then touch_fini = tq:queue(1500,ontouchdone) end

  -- back right button: display toggle once per touch of button
  if bit.isset(down,0) then
    if touch_db_blackout == nil then
      toggleblackout()
    else
      print("dequeueing blackout call")
      tq:dequeue(touch_db_blackout)
    end
    print("queueing blackout call")
    touch_db_blackout = tq:queue(300,onblackdebounce)
  end

  -- left side back button: reset colors and dimming.
  if bit.isset(down,7) then
    dimfactor = 0;
    colors = { [1] = string.char(touchcolorvec(touchcolor)) }
    networkcolors = { [1] = {touchcolorvec(touchcolor)}}
    colorindex = 1;
    -- Don't claim the image, just dim whatever is currently on the screen.
    dodraw()
  end

  if not isblackout then
    -- front right buttons: local color wheel
    if bit.isset(down,1) then
      -- go forward quickly or slowly
      if bit.isset(down,2)
       then touchcolor = touchcolor + 1
       else touchcolor = touchcolor + 2
      end
      claimfb()
      didChangeColor = true
    elseif bit.isset(down,2) and bit.isclear(down,3) then
      -- go backward, slowly (unless mode select; see below)
      touchcolor = touchcolor - 1
      claimfb()
      didChangeColor = true
    end
    if didChangeColor then
     if     touchcolor >= 48 then touchcolor = touchcolor - 48
     elseif touchcolor < 0  then touchcolor = touchcolor + 48
     end
     print(colors, "colorindex is while changing color", colorindex);
     colors[colorindex] = string.char(touchcolorvec(touchcolor))
     networkcolors[colorindex] = {touchcolorvec(touchcolor)}
    end

    -- front middle: mode select (rate-limited, not exactly debounced)
    if bit.isset(down,3) then
      print("front middle touched", touch_db_fn)
      if touch_db_fn == nil then
       if bit.isset(down,2)
        then touchfnix = touchfnix - 1
        else touchfnix = touchfnix + 1
       end
       if touchfnix > #touchfns then touchfnix = 1 end
       if touchfnix <= 0 then touchfnix = #touchfns end
       touch_db_fn = tq:queue(200,onfndebounce)
      end
      didChangeFn = true
      claimfb()
    elseif touch_db_fn then tq:dequeue(touch_db_fn); touch_db_fn = nil
    end
  end

  -- XXX left side front button, dim the display
  if bit.isset(down,5) then
    dimdisplay()
    -- Don't claim the image, just dim whatever is currently on the screen.
    dodraw()
  end

  -- XXX left side middle button; change colors!
  if bit.isset(down, 6) then
    print("ncolors is ", ncolors);
    if ncolors and colorindex < ncolors then
      colorindex = colorindex + 1;
    else
      colorindex = 1;
    end
        print("should increment color", colorindex);
  end

  -- XXX front left
  if bit.isset(down, 4) then
  end

  -- draw if we've claimed it!
  if (ledfb == touchfb) and not didChangeFn and didChangeColor and cccb ~= nil then
    print("colors only");
    -- all we did was change the color(s); inform the existing animation
    cccb()
  elseif didChangeFn or didChangeColor then
    -- full (re)load
    touchtmr:unregister()
    touchlastfn = touchfns[touchfnix]
    print(touchlastfn);
    local drawinfo = loaddrawfn(touchlastfn)(touchtmr,touchfb,colors)
    print(touchlasstfn, "trying drawinfo", drawinfo);
    if drawinfo then
      for k,v in pairs(drawinfo) do print(k,v) end
    end
    cccb = drawinfo and drawinfo['cccb']
    ncolors = drawinfo and drawinfo['ncolors'] or 1
    print(ncolors);

    dodraw()
    touchtmr:start()
  end
end

gpio.trig(6, "low", ontouch) -- hook overlay
ontouch()
