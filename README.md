HashVTT
========

### HashVTT is a virtual tabletop for playing tabletop RPG's. It's called HashVTT because it was created to play RPG's with [Hashbang](http://hashbang.sh/#!) users.

### Current Version - 0.0.1

## Requirements for server
* Lua 5.2
* LuaRocks 2.2.0
* LuaSocket 2.0.2 (luarocks install luasocket)
* Copas 1.1.1 (luarocks install copas)

## Requirements for client
[LÖVE](https://love2d.org/)

## Communication
```
irc.hashbang.sh/6697 #!, #!social, #!rpg
```

## Contributing
1. Join the "#!rpg" channel on the Hashbang network, mentioned in Communication
2. Mention what you want to do, and wait for a response
3. Begin hacking, then submit a [pull request](https://help.github.com/articles/using-pull-requests/)

## Running the server
```
cd server/
lua server.lua
```

## Running the client
```
cd client/
love .
```

### What about built packages?
There are none yet.

#### Note: LÖVE runs on Windows, Mac, and Linux, which means that the client will forever be supported by all of them.

## License
See LICENSE
