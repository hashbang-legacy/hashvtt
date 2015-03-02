local gui = {}

gui.lists = {}
gui.items = {}
gui.actions = {}

gui.activeList = nil

gui.font = love.graphics.newFont(32)

gui.max_color = 255
gui.min_color = 100
gui.dir_color = true
gui.color_speed = 200
gui.color = gui.min_color

gui.lower_chars = "`1234567890-=[]\\;',./`"
gui.lower_chars = gui.lower_chars:split("")

gui.upper_chars = "~!@#$%^&*()_+{}|:\"<>?"
gui.upper_chars = gui.upper_chars:split("")

gui.lower_alpha = "abcdefghijklmnopqrstuvwxyz "
gui.lower_alpha = gui.lower_alpha:split("")

gui.is_caps = false

function gui:createList(id, margin, x, y)
  local l = {}
  l.items = {}
  l.active = false
  l.current = 1
  l.margin = margin
  l.x = x
  l.y = y
  gui.lists[id] = l
  return true
end

function gui:deleteList(id)
  gui.lists[id] = nil
  return true
end

function gui:createItem(id1, type, name, hidden, callback)
  local i = {}
  i.name = name
  i.type = type
  i.callback = callback
  i.text = ""
  i.hidden = hidden
  table.insert(gui.lists[id1].items, i)
  return #gui.lists[id1].items
end

function gui:toggle(id)
  if gui.activeList == id then
    gui.activeList = nil
  else
    gui.activeList = id
  end
  return true
end

function gui:addAction(id, path)
  gui.actions[id] = love.audio.newSource(path, "static")
end

function gui:action(id)
  gui.actions[id]:stop()
  gui.actions[id]:play()
end

function gui:update(dt)
  -- Handle item glowing
  if gui.dir_color then
    if gui.color < gui.max_color-2 then
      gui.color = gui.color + dt*gui.color_speed
    else
      gui.dir_color = not gui.dir_color
    end
  else
    if gui.color > gui.min_color then
      gui.color = gui.color - dt*gui.color_speed
    else
      gui.dir_color = not gui.dir_color
    end
  end

  -- Handle caps
  if love.keyboard.isDown("rshift") or love.keyboard.isDown("lshift") then
    gui.is_caps = true
  else
    gui.is_caps = false
  end
end

function gui:useFont(path, size)
  gui.font = love.graphics.newFont(path, size)
  love.graphics.setFont(gui.font)
end

function gui:draw()
  gui.oldFont = love.graphics.getFont()
  love.graphics.setFont(gui.font)
  if gui.activeList ~= nil then
    for i,v in ipairs(gui.lists[gui.activeList].items) do
      local x = gui.lists[gui.activeList].x
      local y = gui.lists[gui.activeList].y + gui.lists[gui.activeList].margin * i

      if gui.lists[gui.activeList].current == i then
        love.graphics.setColor(gui.color, gui.color, gui.color)
      else
        love.graphics.setColor(100, 100, 100)
      end

      if v.type == "button" then
        love.graphics.print(v.name, x, y)
      elseif v.type == "input" then
        if v.hidden then
          local str = ""
          for i=1, #v.text do
            str = str .. "*"
          end
          love.graphics.print(v.name .. ": " .. str, x, y)
        else
          love.graphics.print(v.name .. ": " .. v.text, x, y)
        end
      end
    end
  end
  love.graphics.setFont(gui.oldFont)
end

function gui:keypressed(key, isRepeat)
  if gui.activeList ~= nil then
    if key == "up" then
      if gui.lists[gui.activeList].current > 1 then
        gui.lists[gui.activeList].current = gui.lists[gui.activeList].current - 1
      else
        gui.lists[gui.activeList].current = #gui.lists[gui.activeList].items
      end
    elseif key == "down" then
      if gui.lists[gui.activeList].current < #gui.lists[gui.activeList].items then
        gui.lists[gui.activeList].current = gui.lists[gui.activeList].current + 1
      else
        gui.lists[gui.activeList].current = 1
      end
    elseif key == "return" then
      gui.lists[gui.activeList].items[gui.lists[gui.activeList].current].callback()
    else
      if gui.activeList ~= nil then
        local found = false
        for i,v in ipairs(gui.lists[gui.activeList].items) do
          if i == gui.lists[gui.activeList].current then
            if v.type == "input" then
              for x,y in ipairs(gui.lower_alpha) do
                if y == key then
                  if gui.is_caps then
                    v.text = v.text .. string.upper(key)
                  else
                    v.text = v.text .. key
                  end
                  break
                end
              end

              for x,y in ipairs(gui.lower_chars) do
                if y == key then
                  if gui.is_caps then
                    v.text = v.text .. gui.upper_chars[x]
                  else
                    v.text = v.text .. key
                  end
                  break
                end
              end

              if key == "backspace" then
                v.text = v.text:sub(1, #v.text-1)
              end

            end
          end -- end type check
        end
      end -- end if gui.activeList
    end
  end
end

function gui:access(id1, id2)
  return GUI.lists[id1].items[id2].text
end

return gui
