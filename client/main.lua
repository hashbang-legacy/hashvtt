package.path = package.path .. ";../lib/?.lua"

require("lib.funcs")
require("lib.tserial")

Socket    = require("socket")
Gamestate = require("lib.gamestate")
Timer     = require("lib.timer")
Camera    = require("lib.camera")
Chat      = require("classes.chat")
helper    = require("lib.helper")
GUI       = require("lib.gui8")

ClientConf = require("client_conf")

-- Load Gamestates
for i,v in ipairs(love.filesystem.getDirectoryItems("gamestates/")) do
  require("gamestates." .. string.gsub(v, ".lua", ""))
end

function love.load()
  Gamestate.registerEvents()
  Gamestate.switch(menu)
end
