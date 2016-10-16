-- globals referenced: isblackout, dodraw, ledfb, ledfb_claimed, remotefb, remotetmr, lamp_announce, tq, loaddrawfn
-- assumptions: gpio.trig(6) is the right thing to do for touch IRQs

local touchfb = ws2812.newBuffer(32,3)
local touch_fini = nil
local touch_db_blackout = nil
local touch_db_fn = nil
local touchcolor  = 40
local touchfns    = { }
local touchfnix = 1

-- Whip through the drawing functions and build indexes
local k,v
for k,v in pairs(file.list()) do
  local ix, _, meth = k:find("^draw%-(%w+)%.lc$")
  if ix then
    touchfns[#touchfns+1] = meth
    if meth == "fill" then touchfnix = #touchfns end
  end
end

local function claimfb()
  if ledfb_claimed == 0 then
    remotetmr:stop()
    ledfb_claimed = 1
    ledfb = touchfb
  end
end

local set0 = function(o) return bit.bor(o,0x01) end
local clear0 = function(o) return bit.band(o,0xFE) end
local function setblackout(nb)
  if nb then
    isblackout = true
    ws2812.write(string.char(0):rep(32*3))
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

local function touchcolorvec(c)
  local r, g, b
  local cm = c % 16
  if     c < 16 then r = 15 - cm; g = cm; b = 0
  elseif c < 32 then r = 0; g = 15 - cm; b = cm
  else               r = cm; g = 0; b = 15 - cm
  end
  return g,r,b
end

local function onblackdebounce() touch_db_blackout = nil end
local function onfndebounce() touch_db_fn = nil end

local set30 = function(o) return bit.bor(o,0x1E) end
local clear30 = function(o) return bit.band(o,0xE1) end
local function ontouchdone()
  gpio.trig(6, "low", ontouch_load) -- unload overlay

  -- we did something.  Announce it!
  if ledfb == touchfb then
    -- flash the four control LEDs to show the user that settings took
    cap:mr(0x74,set30) -- drive
    cap:mr(0x72,clear30) -- unlink
    tq:queue(100, function()
      cap:mr(0x74,clear30) -- undrive
      cap:mr(0x72,set30) -- link
    end)

    lamp_announce(touchfns[touchfnix],touchcolorvec(touchcolor))
  end

  -- leave the ledfb pointing at us; it'll get updated eventually,
  -- unless there was a remote message while we were doing our thing
  -- in which case, display it now
  if ledfb_claimed == 2
   then ledfb_claimed = 0; remotetmr:start(); doremotedraw()
   else ledfb_claimed = 0
  end
end

-- must not change ledfb to touchfb unless the user interacts with us
local function ontouch()
  local _, down = cap:rt()

  if touch_fini ~= nil then tq:dequeue(touch_fini) end

  -- nothing down, kick off timer for touch done
  if down == 0 then touch_fini = tq:queue(1500,ontouchdone) end

  -- back right button: display toggle once per touch of button
  if bit.isset(down,0) then
    if touch_db_blackout == nil then toggleblackout() else tq:dequeue(touch_db_blackout) end
    touch_db_blackout = tq:queue(300,onblackdebounce)
  end

  if not isblackout then
    -- front right buttons: local color wheel
    if bit.isset(down,1) then
      -- go forward quickly or slowly
      if bit.isset(down,2) then touchcolor = touchcolor + 1 else touchcolor = touchcolor + 2 end
      claimfb()
    else
      -- go backward, slowly
      if bit.isset(down,2) then touchcolor = touchcolor - 1; claimfb() end
    end
    if     touchcolor >= 48 then touchcolor = touchcolor - 48
    elseif touchcolor < 0  then touchcolor = touchcolor + 48
    end

    -- front middle: mode select (rate-limited, not exactly debounced)
    if bit.isset(down,3) then
      if touch_db_fn == nil then
       touchfnix = touchfnix + 1
       if touchfnix > #touchfns then touchfnix = 1 end
       touch_db_fn = tq:queue(200,onfndebounce)
      end
      claimfb()
    elseif touch_db_fn then tq:dequeue(touch_db_fn); touch_db_fn = nil
    end
  end

  -- XXX front left: no function assigned, maybe device select or something?
  -- if bit.isset(down,4) then end

  -- draw if we've claimed it!
  if ledfb == touchfb then
    touchtmr:unregister()
    loaddrawfn(touchfns[touchfnix])(touchtmr,touchfb,touchcolorvec(touchcolor)); dodraw()
    touchtmr:start()
  end
end

gpio.trig(6, "low", ontouch) -- hook overlay
ontouch()
