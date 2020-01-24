-- two vertical flowers that occasionally regrow
--
-- Pallette: left flower, right flower (defaults to left flower)
--
--   When regrowing, the pallette is sampled randomly, and the leaves
--   are redrawn for some additional variance.
--
--    1 2 3 4 5 6 7 8
-- 00 f o f o o f o f
-- 08 f f f o o f f f
-- 16 h s h o o h s h
-- 24 o s o o o o s o

local c = string.char(0,0,0)
local stem = string.char(15,0,0)
local stemhalf = string.char(7,0,0)

-- The logic of a flower: step through ft using the transitions in tt, and
-- reinitialize at the end of the loop, sampling colors from p.
local function mkflower(ft, tt, p)
  local ix = 1
  local fc, fch
  local function flower_init(ic)
          fc = ic or p[math.random(#p)] -- pick a random color if not given
          fch = string.char(math.floor((fc:byte(1)+1)/2),
                            math.floor((fc:byte(2)+1)/2),
                            math.floor((fc:byte(3)+1)/2))
          ix = 1
          ft[ix](fc, fch)
  end
  return {
    init = flower_init,
    step = function()
             if math.random(tt[2*ix])-1 < tt[2*ix-1] then
               ix = ix + 1
               if ix > #ft then flower_init(nil) else ft[ix](fc, fch) end
             end
           end
  }
end

local pt = {1, 3,    1, 6,     1, 50}

return function(t, fb, p)

  local function background()
    fb:fill(0,0,0)

    -- left flower background
    fb:set(18, stem)
    fb:set(26, stem)

    -- right flower background
    fb:set(23, stem)
    fb:set(31, stem)
  end

  local lft = {
    [1] = function(fc, fch) -- bud, clear the grown flowers
            fb:set(1, c) fb:set( 3, c) fb:set( 9, c) fb:set(11, c) fb:set(10, fch) 
            fb:set(math.random(2) == 1 and 17 or 19,
                   math.random(2) == 1 and c or stemhalf)
          end
  , [2] = function(fc, fch) -- grow left flower, stage 1
            fb:set( 9, fch) fb:set(10,fc) fb:set(11,fch)
          end

  , [3] = function(fc, fch) -- grow left flower, stage 2
            fb:set( 1, fch) fb:set( 3,fch)
            fb:set( 9, fc)  fb:set(11,fc)
          end
  }

  local rft = {
    [1] = function(fc, fch) -- bud, clear the grown flowers
            fb:set(6, c) fb:set(8, c) fb:set(14, c) fb:set(16, c) fb:set(15, fch)
            fb:set(math.random(2) == 1 and 22 or 24,
                   math.random(2) == 1 and c or stemhalf)
          end
  , [2] = function(fc, fch) -- grow right flower, stage 1
            fb:set(14, fch) fb:set(15,fc) fb:set(16,fch)
          end
  , [3] = function(fc, fch) -- grow right flower, stage 2
            fb:set( 6, fch) fb:set( 8,fch)
            fb:set(14, fc)  fb:set(16,fc)
          end
  }

  local lf = mkflower(lft, pt, p)
  local rf = mkflower(rft, pt, p)

  local function cccb() background() lf.init(p[1]) rf.init(p[2]) dodraw() end

  t:register(500,tmr.ALARM_AUTO,function() lf.step() rf.step() dodraw() end)
  cccb()
  return { ['ncolors'] = 2, ['cccb'] = cccb }
end
