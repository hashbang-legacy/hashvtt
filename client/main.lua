package.path = package.path .. ";../lib/?.lua"

Socket    = require("socket")
Gamestate = require("gamestate")
Timer     = require("timer")
Camera    = require("camera")
Chat      = require("classes.chat")
helper    = require("helper")

ClientConf = require("client_conf")

require("funcs")
require("tserial")

-- Load Gamestates
for i,v in ipairs(love.filesystem.getDirectoryItems("gamestates/")) do
  require("gamestates." .. string.gsub(v, ".lua", ""))
end

function love.load()
  Gamestate.registerEvents()
  Gamestate.switch(game, arg[2], arg[3], arg[4])
end
