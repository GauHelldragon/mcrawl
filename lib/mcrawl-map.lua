local items = dofile("/usr/lib/mcrawl-items.lua")
local treasure = dofile("/usr/lib/mcrawl-treasure.lua")
local unicode = require("unicode")


local map = { 
	tiles = {},
	revealmap = {},
	
	max_x = 50,
	max_y = 50,
	max_rooms = 10,
	rooms = {},
	floorItems = {},
	treasureLevel = 1,
	chests = {}
	
}


-- MAP GENERATION

local function drawSquare(x,y,x2,y2)
   xadder = 1
   yadder = 1
   if ( x > x2 ) then xadder = -1 end
   if ( y > y2 ) then yadder = -1 end
  
   for mx = x,x2,xadder do
      for my = y,y2,yadder do
         if ( my >= 1 and my <= map.max_y and mx >= 1 and mx <= map.max_x ) then
            if ( math.random() > 0.1 ) then map.tiles[mx][my] = "."
            else map.tiles[mx][my] = "," end
         end
      end
   end
end

local function doRoomsIntersect(room1,room2)
   if ( room1.x-2 < room2.x2 and room1.x2+2 > room2.x and room1.y-2 < room2.y2 and room1.y2+2 > room2.y ) then return true end
   return false
end

local function isRoomOK(room)
   for i,croom in pairs(map.rooms)    do 
      
      if ( doRoomsIntersect(room,croom)) then return false end
   end
   return true
end


local function drawRoom(room)
   x = room.x
   y = room.y
   x2 = room.x2
   y2 = room.y2
   drawSquare(x,y,x2,y2)
end


local function newRoom()
   local width = math.random(4,8)
   local height = math.random(4,8)
   local mx = math.random(2,map.max_x-width-1)
   local my = math.random(2,map.max_y-height-1)
   room = {
      x = mx,
      y = my,
      w = width,
      h = height,
      x2 = mx + width - 1,
      y2 = my + height - 1
   }
   return room
end

function map.getRandomSpot(room)
   local x = room.x + math.random(0,room.w-1)
   local y = room.y + math.random(0,room.h-1)
   return x,y
end

local function drawPath(room1,room2)
   startX, startY = map.getRandomSpot(room1)
   endX, endY = map.getRandomSpot(room2)
   
   if ( math.random() > 0.5 ) then
      drawSquare(startX,startY,endX,startY)
      drawSquare(endX,startY,endX,endY)
   else
      drawSquare(startX,startY,startX,endY)
      drawSquare(startX,endY,endX,endY)
   end

end

local function revealRoom(room)
   room.revealed = true
   for x=room.x-1,room.x2+1 do
      for y=room.y-1,room.y2+1 do
         map.revealMap[x][y] = 1
      end
   end
end


local function revealTunnel(player)
   for x=player.x-1,player.x+1 do
      for y=player.y-1,player.y+1 do
         map.revealMap[x][y] = 1
      end
   end
end   

function map.getPlayerRoom(player)
   for i,room in pairs(map.rooms) do
      if ( player.x >= room.x and player.x <= room.x2 and player.y >= room.y and player.y <= room.y2 ) then return room end
   end
   return 0
end


function map.changeReveal(player)
   local playerRoom = map.getPlayerRoom(player)
   if ( playerRoom ~= 0 ) then
      if ( playerRoom.revealed ~= true ) then
         revealRoom(playerRoom)
      end
   else 
      revealTunnel(player)
   end
end


function map.generateMap(player) 
   map.tiles = {}
   map.revealMap = {}
   map.rooms = {}
   map.floorItems = {}
   map.chests = {}
   for x=1,map.max_x do  -- Clear Map
      map.tiles[x] = {}
     map.revealMap[x] = {}
      for y=1,map.max_y do
         map.tiles[x][y] = "#"
       map.revealMap[x][y] = 0
      end
   end
   
   local totalRooms = 0
   for i=1,map.max_rooms do
      local nRoom = newRoom()
      local tries = 1
      while ( not isRoomOK(nRoom) and tries < 10 ) do
         tries = tries + 1
         nRoom = newRoom()
      end
      if ( isRoomOK(nRoom) ) then 
         table.insert(map.rooms,nRoom) 
         totalRooms = totalRooms + 1
		 treasure.addRoomLoot(map,nRoom,map.treasureLevel)
      end
   end
   
   map.max_rooms = totalRooms
   
   startRoom = map.rooms[1]
   player.x, player.y = map.getRandomSpot(startRoom)
   revealRoom(startRoom)
   
   local chestRoomID = math.random(math.floor(totalRooms /2),totalRooms)  
   --chestRoomID = 1
   local chestRoom = map.rooms[chestRoomID]
   treasure.addRoomChest(map,chestRoom,map.treasureLevel)
   
   
   
   for i=1,map.max_rooms do
     drawRoom(map.rooms[i])
	 
   end
   for i=1,map.max_rooms-1 do 
     drawPath(map.rooms[i],map.rooms[i+1])
   end
end



function map.getItemAt(x,y)
   for i,item in pairs(map.floorItems) do
	  item.id = i
      if ( item.x == x and item.y == y ) then return item end
   end
end

function map.getChestAt(x,y)
	for i,chest in pairs(map.chests) do
		chest.id = i
		if ( chest.x == x and chest.y == y ) then return chest end
	end
end

function map.isFloor(x,y)
	if ( map.tiles[x][y] == "#" ) then return false end
	return true
end

function map.openChest(chest)
	
	local neighbors = {}
	for x = chest.x-1,chest.x+1 do
		for y = chest.y-1,chest.y+1 do
			if map.isFloor(x,y) then table.insert(neighbors,{x=x,y=y}) end
		end
	end
	for i,item in pairs(chest.contents) do
		local spot = neighbors[math.random(#neighbors)]
		item.x = spot.x
		item.y = spot.y
		table.insert(map.floorItems,item)
	end
	
	table.remove(map.chests,chest.id)
	
end

return map
