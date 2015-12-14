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

function map:drawSquare(x,y,x2,y2)
   xadder = 1
   yadder = 1
   if ( x > x2 ) then xadder = -1 end
   if ( y > y2 ) then yadder = -1 end
  
   for mx = x,x2,xadder do
      for my = y,y2,yadder do
         if ( my >= 1 and my <= self.max_y and mx >= 1 and mx <= self.max_x ) then
            if ( math.random() > 0.1 ) then self.tiles[mx][my] = "."
            else self.tiles[mx][my] = "," end
         end
      end
   end
end

local function doRoomsIntersect(room1,room2)
   if ( room1.x-2 < room2.x2 and room1.x2+2 > room2.x and room1.y-2 < room2.y2 and room1.y2+2 > room2.y ) then return true end
   return false
end

function map:isRoomOK(room)
   for i,croom in pairs(self.rooms)    do 
      
      if ( doRoomsIntersect(room,croom)) then return false end
   end
   return true
end


function map:drawRoom(room)
   x = room.x
   y = room.y
   x2 = room.x2
   y2 = room.y2
   drawSquare(x,y,x2,y2)
end


function map:newRoom()
   local width = math.random(4,8)
   local height = math.random(4,8)
   local mx = math.random(2,self.max_x-width-1)
   local my = math.random(2,self.max_y-height-1)
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

local function getRandomSpot(room)
   local x = room.x + math.random(0,room.w-1)
   local y = room.y + math.random(0,room.h-1)
   return x,y
end

function map:drawPath(room1,room2)
   startX, startY = getRandomSpot(room1)
   endX, endY = getRandomSpot(room2)
   
   if ( math.random() > 0.5 ) then
      drawSquare(startX,startY,endX,startY)
      drawSquare(endX,startY,endX,endY)
   else
      drawSquare(startX,startY,startX,endY)
      drawSquare(startX,endY,endX,endY)
   end

end

function map:revealRoom(room)
   room.revealed = true
   for x=room.x-1,room.x2+1 do
      for y=room.y-1,room.y2+1 do
         self.revealMap[x][y] = 1
      end
   end
end


function map:revealTunnel(player)
   for x=player.x-1,player.x+1 do
      for y=player.y-1,player.y+1 do
         self.revealMap[x][y] = 1
      end
   end
end   

function map:getPlayerRoom(player)
   for i,room in pairs(self.rooms) do
      if ( player.x >= room.x and player.x <= room.x2 and player.y >= room.y and player.y <= room.y2 ) then return room end
   end
   return 0
end


function map:changeReveal(player)
   local playerRoom = getPlayerRoom(player)
   if ( playerRoom ~= 0 ) then
      if ( playerRoom.revealed ~= true ) then
         revealRoom(playerRoom)
      end
   else 
      revealTunnel(player)
   end
end


function map:generateMap() 
   self.tiles = {}
   self.revealMap = {}
   for x=1,self.max_x do  -- Clear Map
      self.tiles[x] = {}
     self.revealMap[x] = {}
      for y=1,self.max_y do
         self.tiles[x][y] = "#"
       self.revealMap[x][y] = 0
      end
   end
   
   local totalRooms = 0
   for i=1,self.max_rooms do
      local newRoom = NewRoom()
      local tries = 1
      while ( not isRoomOK(newRoom) and tries < 10 ) do
         tries = tries + 1
         newRoom = NewRoom()
      end
      if ( isRoomOK(newRoom) ) then 
      table.insert(self.rooms,newRoom) 
      totalRooms = totalRooms + 1
     local ix, iy = getRandomSpot(newRoom)
     addNewFloorItem("Apple",ix,iy)
   end
   end
   
   self.max_rooms = totalRooms
   
   startRoom = self.rooms[1]
   player.x, player.y = getRandomSpot(startRoom)
   revealRoom(startRoom)
   
   for i=1,self.max_rooms do
     drawRoom(self.rooms[i])
   end
   for i=1,self.max_rooms-1 do 
     drawPath(self.rooms[i],self.rooms[i+1])
   end
end







return map
