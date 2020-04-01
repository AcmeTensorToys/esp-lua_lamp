function love.threaderror(thread, errorstr)
  print("Thread error!", thread, errorstr)
  love.event.quit(1)
end

function love.load()
  love.window.setTitle("lampulator")
  love.window.setMode(32, 16, { display = 1, x = 0, y = 0 })

  drawchan  = love.thread.getChannel ("drawc" ) -- main -> draw
  framechan = love.thread.getChannel ("framec") -- draw -> main
  netchan   = love.thread.getChannel ("netc"  ) -- net  -> main

  netthread = love.thread.newThread  ("net.lua")
  netthread:start()

  drawthread = love.thread.newThread ("draw.lua")
  drawthread:start()
end

love.timer = nil -- don't tick, we do that ourselves in update

local lastnetline

function love.mousepressed(x, y, btn, ist, presses)
  if btn == 1 and lastnetline then
    love.system.setClipboardText(lastnetline)
  end
end

function love.update()
  -- Poor man's fanout
  local line = netchan:pop()
  if line then
    lastnetline = line
    drawchan:push(line)
  end

  -- We have to let the event loop run every so often, even if there
  -- aren't frames coming our way.
  local imgd = framechan:demand(1)
  if imgd then
    love.draw = function()
      local img = love.graphics.newImage(imgd)
      img:setFilter('nearest')
      love.graphics.clear(love.graphics.getBackgroundColor())
      love.graphics.draw(img, 0, 0, 0, 4, 4)
    end
  end
end
