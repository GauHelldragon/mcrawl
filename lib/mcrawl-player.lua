local items = require("mcrawl-items")


local player = {
   x = 10,
   y = 10,
   name = "Steve",
   maxHP = 10,
   HP = 10,
   level = 1,
   xp = 0,
   defence = 0,
   food = 10,
   maxFood = 10,
   emeralds = 0,
   
   
   weapon = nil,
   armor = nil,
   
   inventory = {}
   
}

function player.movePlayer(map,direction)
   if ( direction == "up"    and player.y > 1  ) then player.tryToMovePlayer(player.x,player.y-1) end
   if ( direction == "down"  and player.y < map.max_y ) then player.tryToMovePlayer(player.x,player.y+1) end
   if ( direction == "left"  and player.x > 1  ) then player.tryToMovePlayer(player.x-1,player.y) end
   if ( direction == "right" and player.x < map.max_x ) then player.tryToMovePlayer(player.x+1,player.y)  end  
   if ( direction == "nw"    and player.x > 1 and
                                 player.y > 1 ) then player.tryToMovePlayer(player.x-1,player.y-1) end
   if ( direction == "ne"    and player.x < map.max_x and
                                 player.y > 1 ) then player.tryToMovePlayer(player.x+1,player.y-1) end
   if ( direction == "sw"    and player.x > 1 and
                                 player.y < map.max_y ) then player.tryToMovePlayer(player.x-1,player.y+1) end
   if ( direction == "se"    and player.x < map.max_x and
                                 player.y < map.max_y ) then player.tryToMovePlayer(player.x+1,player.y+1) end

                         
   
end

function player.tryToMovePlayer(map,newx,newy)
   tile = getMapTile(newx,newy)

   if ( tile == "#" ) then return end
   player.x = newx
   player.y = newy
   viewChange = true
   map.changeReveal(player)
   moved = true
   endTurn = true
   
end


function player.resetPlayer()
	player.name = "Steve"
	player.maxHP = 10
	player.HP = 10
	player.level = 1
	player.xp = 0
	player.defence = 0
	player.food = 10
	player.maxFood = 10
	player.emeralds = 0
	
	player.weapon = nil
	player.armor = nil
	
	player.inventory = {}
	
end

function player.GetItem(item)

   table.remove(map.floorItems,item.id)
   if ( item.iType == "emerald" ) then 
      player.emeralds = player.emeralds + item.quantity
      return
   end
   
   if ( isItemStackable(item) ) then
      existingItem = items.getPlayerItem(item)
      if ( existingItem ~= nil ) then
        if ( existingItem.quant >= 64 ) then return false end
        existingItem.quant = math.min(existingItem.quant + item.quant,64)
        return true
      end
   end
   table.insert(player.inventory,item)
   return true
end

local function getPlayerItem(item)
   for i,sitem in pairs(player.inventory) do
      
      if ( item.name == sitem.name ) then
         sitem.id = i
         return sitem
      end
   end
end



function player.playerDropItem(item,map)
   table.remove(player.inventory,item.id)
   item.x = player.x
   item.y = player.y
   table.insert(map.floorItems,item)
   if ( player.weapon == item ) then player.weapon = nil end
   if ( player.armor == item ) then player.armor = nil end
end



return player