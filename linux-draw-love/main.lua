function love.threaderror(thread, errorstr)
  print("Thread error!", thread, errorstr)
  love.event.push('quit')
end

function love.load()
  love.window.setTitle("lampulator")
  love.window.setMode(32, 16, { display = 1, x = 0, y = 0 })

  framechan = love.thread.getChannel ( "framec" );
  netchan = love.thread.getChannel ( "netc" );

  netthread = love.thread.newThread ( "net.lua" );
  netthread:start()

  drawthread = love.thread.newThread ( "draw.lua" );
  drawthread:start()
end

-- Override the event loop
function love.run()
  if love.load then love.load(love.arg.parseGameArguments(arg), arg) end
  if love.timer then love.timer.step() end

  return function()
    local dt = 0

    if love.event then
      local name, a,b,c,d,e,f
      love.event.pump()
      for name, a,b,c,d,e,f in love.event.poll() do
        if name == "quit" then
          if not love.quit or not love.quit() then
            return a or 0
          end
        end
        love.handlers[name](a,b,c,d,e,f)
      end
    end

    -- XXX We have to poll the threads periodically to catch errors
    local imgd = framechan:demand(1)
    if imgd then
      local img = love.graphics.newImage(imgd)
      img:setFilter('nearest')
      love.graphics.clear(love.graphics.getBackgroundColor())
      love.graphics.draw(img, 0, 0, 0, 4, 4)
    end
    love.graphics.present()

    if love.timer then dt = love.timer.step() end

  end
end
