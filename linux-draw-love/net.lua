-- Pull lines off stdin and push them into a LOVE channel
lev  = require "love.event"
ltmr = require "love.timer"
lthr = require "love.thread"

netchan = lthr.getChannel ( "netc" )
for line in io.lines() do
  netchan:push(line)
end
lev.push("quit")
