local items = dofile("/usr/lib/mcrawl-items.lua")


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


local function getPlayerItem(player,item)
   for i,sitem in pairs(player.inventory) do
      
      if ( item.name == sitem.name ) then
         sitem.id = i
         return sitem
      end
   end
end

local function nextLetter(itemChar)
   itemChar = string.lower(itemChar)
   return ('abcdefghijklmnopqrstuvwxyza':match(itemChar..'(.)')
end

function player.getItemFromLetter(letter)
   local cLetter = "a"
   for i,cItem in player.inventory do 
      if ( cLetter == letter ) then return cItem
      cLetter = nextLetter(cLetter)
   end
   
end


function player.getInventorySize()
   local count = 0
   for i,item in pairs(player.inventory) do
      count = count + 1
   end
   return count
end


function player.GetItem(map,item)

   table.remove(map.floorItems,item.id)
   if ( item.iType == "emerald" ) then 
      player.emeralds = player.emeralds + item.quantity
      return
   end
   
   if ( items.isItemStackable(item) ) then
      existingItem = getPlayerItem(player,item)
      if ( existingItem ~= nil ) then
        if ( existingItem.quant >= 64 ) then return false end
        existingItem.quant = math.min(existingItem.quant + item.quant,64)
        return true
      end
   end
   table.insert(player.inventory,item)
   return true
end


function player.setArmor()
   if ( player.armor ~= nil ) then 
      player.defence = player.armor.def
   else
      player.defence = 0
   end

end

function player.playerDropItem(item,map)
   table.remove(player.inventory,item.id)
   item.x = player.x
   item.y = player.y
   table.insert(map.floorItems,item)
   if ( player.weapon == item ) then player.weapon = nil end
   if ( player.armor == item ) then player.armor = nil player.setArmor() end
end



return player