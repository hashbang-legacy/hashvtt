local chat = {}

function chat:load()
  chat.font = love.graphics.newFont(12)
  chat.show = true
  chat.width = 500
  chat.height = 200
  chat.x = 50
  chat.y = love.graphics.getHeight() - chat.height - 20
  chat.back_color = {0, 0, 0, 100}
  chat.text_color = {0, 255, 0, 100}
  chat.text_height = chat.font:getHeight("A")
  chat.margin = 2
  chat.buffer = {}

  chat.mode = false
  chat.chatting = false
  chat.current = ""

  chat.can_upper = "abcdefghijklmnopqrstuvwxyz"
  chat.can_upper = chat.can_upper:split("")
  chat.can_upper_symbols = "`1234567890-=[]\\;',./`"
  chat.can_upper_symbols = chat.can_upper_symbols:split("")
  chat.upper_symbols = "~!@#$%^&*()_+{}|:\"<>?"
  chat.upper_symbols = chat.upper_symbols:split("")
end

function chat:update(dt)
  if chat.mode then
  end
end

function chat:draw()
  if chat.show then
    -- Draw Back piece
    love.graphics.setColor(unpack(chat.back_color))
    love.graphics.rectangle("fill", chat.x, chat.y, chat.width, chat.height)

    -- Draw text
    local old_font = love.graphics.getFont()
    love.graphics.setFont(chat.font)
    love.graphics.setColor(unpack(chat.text_color))
    local i = 0
    if #chat.buffer >= 13 then
      for x=#chat.buffer-12, #chat.buffer do
        i = i + 1
        love.graphics.print(chat.buffer[x], chat.x + 2, chat.y + i * chat.text_height + chat.margin - chat.text_height)
      end
    else
      for i,v in ipairs(chat.buffer) do
        love.graphics.print(v, chat.x + 2, chat.y + i * chat.text_height + chat.margin - chat.text_height)
      end
    end

    if chat.chatting then
      love.graphics.print(chat.current .. "|", chat.x + 2, chat.y + 14 * chat.text_height + chat.margin - chat.text_height)
    else
      love.graphics.print(chat.current, chat.x + 2, chat.y + 14 * chat.text_height + chat.margin - chat.text_height)
    end

    love.graphics.setFont(old_font)
    love.graphics.setColor(255, 255, 255)
  end

  if game.mode == "chat" then
    chat.chatting = true
  elseif game.mode == "game" then
    chat.chatting = false
  end

  if chat.show == false then
    game.chatting = false
    game.mode = "game"
  end
end

function chat:keypressed(key)
  if key == "`" then
    chat.show = not chat.show
  else
    if chat.chatting and game.mode == "chat" then
      if key == "return" then
        if chat.current:sub(1, 1) == "/" then
          local s = chat.current:sub(2)
          s = s:split(" ")
          if s[1] == "roll" then
            local r = {}
            r.req = "roll_dice"
            r.input = s[2]
            game.tcp:send(Tserial.pack(r) .. "\n")
          elseif s[1] == "whisper" then
            local to = s[2]
            local msg = table.concat(s, " ", 3, #s)

            if to and msg then
              local r = {}
              r.req = "send_whisper"
              r.to = to
              r.msg = msg
              game.tcp:send(Tserial.pack(r) .. "\n")

              table.insert(chat.buffer, "to " .. r.to .. " - " .. r.msg)
            else
              table.insert(chat.buffer, "Whisper Error")
            end
          elseif s[1] == "load_map" then
            local r = {}
            r.req = "change_map"
            r.map = s[2]

            if love.filesystem.exists("assets/maps/" .. r.map .. ".png") then
              game.tcp:send(Tserial.pack(r) .. "\n")
            end
          end
        else
          local r = {}
          r.req = "send_chat"
          r.chat = chat.current
          game.tcp:send(Tserial.pack(r) .. "\n")
        end
        chat.current = ""
        elseif key == "backspace" then
          chat.current = chat.current:sub(1, #chat.current-1)
        else
          if love.keyboard.isDown("rshift") or love.keyboard.isDown("lshift") then
            if key ~= "rshift" and key ~= "lshift" then
              for i,v in ipairs(chat.can_upper) do
                if key == v then
                  chat.current = chat.current .. string.upper(key)
                  break
                end
              end
              for x,y in ipairs(chat.can_upper_symbols) do
                if y == key then
                  chat.current = chat.current .. chat.upper_symbols[x]
                  break
                end
              end
            end
          else
            chat.current = chat.current .. key
          end
        end
      end
  end
end

function chat:keyreleased(key)

end

function chat:mousepressed(x, y, button)
  if helper.bbox(x, y, 1, 1, chat.x, chat.y, chat.width, chat.height) then
    game.mode = "chat"
  else
    game.mode = "game"
  end
end

function chat:setMode(bool)
  chat.mode = bool
end

return chat
