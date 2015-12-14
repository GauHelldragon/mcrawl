local map = { 
	tiles = {},
	revealmap = {},
	
	max_x = 50,
	max_y = 50,
	max_rooms = 10,
	rooms = {},
	floorItems = {}
	
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


function map.generateMap() 
   map.tiles = {}
   map.revealMap = {}
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
      local newRoom = newRoom()
      local tries = 1
      while ( not isRoomOK(newRoom) and tries < 10 ) do
         tries = tries + 1
         newRoom = newRoom()
      end
      if ( isRoomOK(newRoom) ) then 
      table.insert(map.rooms,newRoom) 
      totalRooms = totalRooms + 1
     local ix, iy = map.getRandomSpot(newRoom)
     addNewFloorItem("Apple",ix,iy)
   end
   end
   
   map.max_rooms = totalRooms
   
   startRoom = map.rooms[1]
   player.x, player.y = map.getRandomSpot(startRoom)
   revealRoom(startRoom)
   
   for i=1,map.max_rooms do
     drawRoom(map.rooms[i])
   end
   for i=1,map.max_rooms-1 do 
     drawPath(map.rooms[i],map.rooms[i+1])
   end
end







return map
