menu = {}

GUI:createList("list1", 40, 50, 100)
GUI:toggle("list1")

menu.username = GUI:createItem("list1", "input", "Username", false, function() end)
menu.password = GUI:createItem("list1", "input", "Password", true, function() end)

GUI:createItem("list1", "button", "Join", false, function()
  -- print(GUI:access("list1", menu.username))
  if GUI:access("list1", menu.username) ~= "" and
  GUI:access("list1", menu.password) ~= "" then
    GUI:toggle("list1")
    Gamestate.switch(game, "98.186.244.15", 8080, GUI:access("list1", menu.username))
  else
    GUI:action("error")
  end
  end)

  GUI:createItem("list1", "button", "Exit", false, function()
    love.event.quit()
    end)

function menu:enter()

end

function menu:update(dt)
  GUI:update(dt)
end

function menu:draw()
  GUI:draw()
end

function menu:keypressed(key)
  GUI:keypressed(key)
end
