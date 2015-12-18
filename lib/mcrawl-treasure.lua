local items = dofile("/usr/lib/mcrawl-items.lua")


local treasure = {
	lootTable,
}

local function getRandomSpot(room)
   local x = room.x + math.random(0,room.w-1)
   local y = room.y + math.random(0,room.h-1)
   return x,y
end


local function addFloorItem(map,nitem,x,y)
   nitem.x = x
   nitem.y = y
   table.insert(map.floorItems,nitem)
end



local function loadLootTable()
   local file, reason = io.open("/usr/share/treasure.dat", "r")
   if not file then
     io.stderr:write("Failed opening treasure.dat file: " .. reason .. "\n")
     os.exit(1)
   end
   
   local rawdata = file:read("*all")
   file:close()
   
   local data, reason = load("return " .. rawdata)
   if not data then
     io.stderr:write("Failed loading treasure data: " .. reason .. "\n")
     os.exit(2)
   end
   lootTable = data()
end

local function getWeightedLoot( lootList )
	local totalWeight = 0 
	for i,loot in pairs(lootList) do
		totalWeight = totalWeight + loot.weight
	end
	
	local myWeight = math.random(totalWeight)
	local weightCount = 0

	for i,loot in pairs(lootList) do
		
		weightCount = weightCount + loot.weight
		if ( weightCount >= myWeight ) then return loot end
	end
	
end

local function getLootItem(lootList)
	local loot = getWeightedLoot( lootList )
	
	local iType = loot.iType
	local minItem = loot.min
	local maxItem = loot.max
	local quantity = 1
	if ( maxItem > 1 ) then quantity = math.random(minItem,maxItem) end
	if ( iType == "Emerald" ) then quantity = quantity / 10 end
	
	return items.newItem(iType,quantity)
end

local function getRandomRoomLoot(lootLevel)
	local lootList = lootTable.room[lootLevel]
	if ( lootList == nil ) then
	     io.stderr:write("Could not find room treasure level " .. lootLevel .."\n")
		os.exit(2)
	end
	return getLootItem(lootList)
end	
	

	
	



function treasure.addRoomLoot(map,room,lootLevel)
	if ( lootTable == nil ) then loadLootTable() end
	local treasureAmount = 0
	if ( math.random() < 0.75 ) then treasureAmount = treasureAmount + 1 end
	if ( math.random() < 0.50 ) then treasureAmount = treasureAmount + 1 end
	if ( math.random() < 0.25 ) then treasureAmount = treasureAmount + 1 end
	for i=1,treasureAmount do
		local ix,iy = getRandomSpot(room)
		local newItem = getRandomRoomLoot(lootLevel)
		
		addFloorItem(map,newItem,ix,iy)

	end
	

end





return treasure