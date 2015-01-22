package.path = package.path .. ";../lib/?.lua"

local socket = require("socket")
local copas  = require("copas")
local helper = require("helper")
local conf   = require("conf")
local dice   = require("dice")

require("tserial")
require("funcs") -- Random useful functions

local hvtt = {}

hvtt.version = "0.0.1"

hvtt.users = {}
hvtt.begun = false

hvtt.conf = conf

hvtt.server = socket.bind("*", hvtt.conf.port)
hvtt.host, hvtt.port = hvtt.server:getsockname()

hvtt.tokens = {}

hvtt.eventStack = {}

function hvtt:sendAll(r)
  for i,v in ipairs(hvtt.users) do
    if v.skt then
      v.skt:send(Tserial.pack(r) .. "\n")
    end
  end
end

function hvtt.gameHandler(skt)
  local user = {}
  skt = copas.wrap(skt)
  user.skt = skt

  while true do

    if #hvtt.eventStack > 0 then
      for i,v in ipairs(hvtt.eventStack) do
        v()
        table.remove(hvtt.eventStack, i)
      end
    end

    local data = skt:receive()
    if data then
      data = Tserial.unpack(data)

      if data.req == "testing" then
        local r = {}
        r.req = "testing"
        skt:send(Tserial.pack(r) .. "\n")
      elseif data.req == "create_token" then
        user.name = data.name
        user.id = #hvtt.users + 1
        user.img = data.img

        hvtt.users[user.id] = user

        local r = {}
        r.req = "give_id"
        r.id = user.id
        r.tokens = hvtt.tokens
        r.start_x = conf.start_x
        r.start_y = conf.start_y
        skt:send(Tserial.pack(r) .. "\n")

        local r = {}
        r.req = "create_token"
        r.id = user.id
        r.name = user.name
        r.x = 100
        r.y = 100
        r.img = data.img
        hvtt:sendAll(r)

        local t = {}
        t.id = user.id
        t.name = data.name
        t.x = 100
        t.y = 100
        t.img = data.img
        hvtt.tokens[t.id] = t

        print("Created user named [" .. user.name .. "] with id " .. user.id)
      elseif data.req == "move_token" then
        local event = function()
          local r = {}
          r.req = "move_token"
          r.id = data.id
          r.x = data.x
          r.y = data.y
          hvtt:sendAll(r)
          hvtt.tokens[r.id].x = r.x
          hvtt.tokens[r.id].y = r.y
        end
        table.insert(hvtt.eventStack, event)
      elseif data.req == "send_chat" then
        local r = {}
        r.req = "send_chat"
        r.chat = user.name .. " - " .. data.chat
        hvtt:sendAll(r)
      elseif data.req == "send_whisper" then
        local r = {}
        r.req = "send_whisper"
        r.from = user.name
        r.msg = data.msg
        hvtt:sendAll(r)
      elseif data.req == "roll_dice" then
        local r = {}
        r.req = "roll_dice"
        r.output = user.name .. " rolled a " .. dice.roll(data.input)
        hvtt:sendAll(r)
      elseif data.req == "change_map" then
        local r = {}
        r.req = "change_map"
        r.map = data.map
        hvtt:sendAll(r)
      elseif data.req == "quit" then
        hvtt.users[user.id] = {}
        hvtt.tokens[user.id] = {}
        print("Removed player " .. user.id .. " [" .. user.name .. "]")
        -- hvtt.sendChatAll("Player " .. user.name .. " has left.")
        local r = {}
        r.req = "delete_token"
        r.id = user.id
        r.msg = "Player " .. user.name .. " has left."
        hvtt:sendAll(r)
        break
      end

      -- print(Tserial.pack(data))
    end
  end
end

copas.addserver(hvtt.server, hvtt.gameHandler)
print("Started HashVTT " .. hvtt.version .. " Server on port " .. hvtt.port)
copas.loop()
