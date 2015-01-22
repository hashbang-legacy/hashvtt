game = {}

game.user = {}

game.moveSpeed = 300
game.moveMod = .5

game.entities = {}

function game:enter(old, ip, port, username)
  -- print(ip, port, username)
  game.tcp = assert(socket.tcp())
  game.tcp:connect(ip, tonumber(port))
  game.tcp:settimeout(0) -- DONT REMOVE

  game.user.name = username

  local r = {}
  r.req = "create_token"
  r.name = game.user.name
  r.img = ClientConf.token
  game.tcp:send(Tserial.pack(r) .. "\n")

  game.camera = Camera(0, 0)

  game.fonts = {}
  game.fonts[1] = love.graphics.newFont(12)
  game.fonts[2] = love.graphics.newFont(24)
  game.fonts[3] = love.graphics.newFont(48)

  love.graphics.setFont(game.fonts[2])

  Chat:load()

  game.mode = "game"
end

function game:update(dt)
  Chat:update(dt)

  local data = game.tcp:receive()
  if data then
    data = Tserial.unpack(data)

  -- Handle Requests
  if data.req == "give_id" then
    game.user.id = data.id
    game.entities = data.tokens

    for i,v in ipairs(game.entities) do
      if v.id and v.img then
        v.img = love.graphics.newImage("assets/tokens/" .. v.img .. ".png")
      end
    end
    elseif data.req == "create_token" then
      -- do something
      local t = {}
      t.id = data.id
      t.name = data.name
      t.x = data.x
      t.y = data.y
      t.img = love.graphics.newImage("assets/tokens/" .. data.img .. ".png")

      if t.id == game.user.id then
        game.user.width = t.img:getWidth()
        game.user.height = t.img:getHeight()
      end

      game.entities[t.id] = t
    elseif data.req == "move_token" then
      game.entities[data.id].x = data.x
      game.entities[data.id].y = data.y
    elseif data.req == "delete_token" then
      table.insert(Chat.buffer, data.msg)
      table.remove(game.entities, data.id)
    elseif data.req == "roll_dice" then
      table.insert(Chat.buffer, data.output)
    elseif data.req == "send_chat" then
      local chats = {}
      local current = ""
      -- Max is 45 currently
      local max_length = 450
      for i=1, #data.chat do
        if love.graphics.getFont():getWidth(current) > max_length then
          table.insert(chats, current)
          current = ""
        end
        current = current .. data.chat:sub(i, i)
      end
      if #current > 0 then
        table.insert(chats, current)
      end
      for i,v in ipairs(chats) do
        table.insert(Chat.buffer, v)
      end
    elseif data.req == "bad_command" then
      table.insert(Chat.buffer, "Command Error")
    elseif data.req == "send_whisper" then
      table.insert(Chat.buffer, "from " .. data.from .. " - " .. data.msg)
    elseif data.req == "change_map" then
      game.map = love.graphics.newImage("assets/maps/" .. data.map .. ".png")
    end
  end
  if game.mode == "game" then

    if love.keyboard.isDown("up") then
      local y = game.camera.y - game.moveSpeed*dt
      game.camera.y = y
    end

    if love.keyboard.isDown("down") then
      local y = game.camera.y + game.moveSpeed*dt
      game.camera.y = y
    end

    if love.keyboard.isDown("left") then
      local x = game.camera.x - game.moveSpeed*dt
      game.camera.x = x
    end

    if love.keyboard.isDown("right") then
      local x = game.camera.x + game.moveSpeed*dt
      game.camera.x = x
    end

  elseif game.mode == "chat" then
    Chat:setMode(true)
  end
end

function game:draw()
  love.graphics.setColor(100, 100, 100)
  love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(),
    love.graphics.getHeight())
  love.graphics.setColor(255,255,255)

  game.camera:attach()

  if game.map then
    love.graphics.draw(game.map, -1380, -1450, 0, 4, 4)
  end

  -- draw stuff
  for i,v in ipairs(game.entities) do
    if v.img then
      love.graphics.draw(v.img, v.x, v.y)
      love.graphics.print(v.name, v.x, v.y-20)
    end
  end

  game.camera:detach()

  -- Draw chat
  Chat:draw()
end

function game:mousepressed(x, y, button)
  -- print(game.camera:mousepos())
  -- print(game.camera.x, game.camera.y)
  Chat:mousepressed(x, y, button)

  if game.mode == "game" then
    if button == "wu" then
      game.camera:zoomTo(game.camera.scale + .1)
    elseif button == "wd" then
      if game.camera.scale > 0.2 then
        game.camera:zoomTo(game.camera.scale - .1)
      end
    end
  end
end

function game:mousereleased(x, y, button)

end

function game:keypressed(key)
  if game.mode ~= "chat" then
    if key == "w" then
      local r = {}
      r.req = "move_token"
      r.id = game.user.id
      r.x = game.entities[game.user.id].x
      r.y = game.entities[game.user.id].y - game.user.height * game.moveMod
      game.tcp:send(Tserial.pack(r) .. "\n")
    elseif key == "s" then
      local r = {}
      r.req = "move_token"
      r.id = game.user.id
      r.x = game.entities[game.user.id].x
      r.y = game.entities[game.user.id].y + game.user.height * game.moveMod
      game.tcp:send(Tserial.pack(r) .. "\n")
    elseif key == "a" then
      local r = {}
      r.req = "move_token"
      r.id = game.user.id
      r.x = game.entities[game.user.id].x - game.user.width * game.moveMod
      r.y = game.entities[game.user.id].y
      game.tcp:send(Tserial.pack(r) .. "\n")
    elseif key == "d" then
      local r = {}
      r.req = "move_token"
      r.id = game.user.id
      r.x = game.entities[game.user.id].x + game.user.width * game.moveMod
      r.y = game.entities[game.user.id].y
      game.tcp:send(Tserial.pack(r) .. "\n")
    elseif key == "1" then
      local r = {}
      r.req = "roll_dice"
      r.input = "1d2"
      game.tcp:send(Tserial.pack(r) .. "\n")
    end
  end
  Chat:keypressed(key)
end

function game:keyreleased(key)
  Chat:keyreleased(key)
end

function game:CenterCamera()
  local x = game.entities.player.x + game.entities.player.width/2
  local y = game.entities.player.y + game.entities.player.height/2
  game.camera:lookAt(x, y)
end

function game:quit()
  local r = {}
  r.req = "quit"
  game.tcp:send(Tserial.pack(r) .. "\n")
  game.tcp:close()
end
