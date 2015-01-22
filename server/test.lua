local socket = require("socket")

local tcp = assert(socket.tcp())
tcp:connect("127.0.0.1", 8000)

tcp:send("hi\n")

tcp:close()

print("done")
