function string:split(sep)
  local sep, fields = sep or ":", {}
  if sep == "" then
    for i=1, #self do
      fields[#fields+1] = self:sub(i, i)
    end
  else
    local pattern = string.format("([^%s]+)", sep)
    self:gsub(pattern, function(c) fields[#fields+1] = c end)
  end
  return fields
end
