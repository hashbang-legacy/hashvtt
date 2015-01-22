local helper = {}

helper.warnings = 0

helper.warning = function(warning)
  print("WARNING[" .. helper.warnings .. "] - " .. warning)
  helper.warnings = helper.warnings + 1
end

helper.error = function(error)
  print("ERROR - " .. helper.error)
  os.exit()
end

function helper.dis(x1, y1, x2, y2)
  return math.floor(math.sqrt((y2-y1)^2 + (x2-x1)^2))
end

function helper.bbox(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
  x2 < x1+w1 and
  y1 < y2+h2 and
  y2 < y1+h1
end

return helper
