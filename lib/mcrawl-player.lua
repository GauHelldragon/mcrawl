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
   
   inventory = {},

	deathMessage = "",
   
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
   
   player.foodRegenTick = 0
   
end


local function handleHungerRegen()
	player.foodRegenTick = player.foodRegenTick + 1
	if ( player.foodRegenTick >= 10 ) then
		player.foodRegenTick = 0
		if ( player.food <= 0 ) then player.damage(1,"hunger") end
		local healFood = player.maxFood * 0.75
		if ( player.food >= healFood and player.HP < player.maxHP ) then 
			player.heal(1) 
			player.hunger("regen")
		end
	
	end
end	

function player.runHeartBeat()
	player.hunger("heart")
	handleHungerRegen()
	
end

function player.death(dType)
	player.deathMessage = "died."
	if ( dType == "hunger" ) then player.deathMessage = "starved to death." return end

end

function player.damage(value,dType)
	player.HP = player.HP - value
	if ( player.HP <= 0 ) then player.death(dType) end
end

function player.heal(value)
	player.HP = math.min(player.maxHP,player.HP + value)
end


function player.hunger(hungerType)
	local hungerDec = 0.1
	
	if ( hungerType == "heart" ) then hungerDec = 0.02 end
	if ( hungerType == "move" ) then hungerDec = 0.08 end
	if ( hungerType == "attack" ) then hungerDec = 0.1 end
	if ( hungerType == "regen" ) then hungerDec = 0.5 end
	
	player.food = math.max(0,player.food - hungerDec)

end

function player.equip(item)
	if ( item == nil ) then return "What item?" end
	local retString = "You equip " .. item.name
	
	if ( item == player.weapon ) then 
		player.weapon = nil
		return "You unequip " .. item.name
	end
	if ( item == player.armor ) then
		player.armor = nil
		player.setArmor()
		return "You unequip " .. item.name
	end
	
	if ( item.iType == "weapon" ) then
		
		player.weapon = item
	else
		player.armor = item
		player.setArmor()
	end
	
	return retString
		

end


local function reduceItemQuant(item,quantity)
	if ( quantity == nil or quantity <= 0 ) then quantity = 1 end
	
	item.quant = item.quant - quantity
	
	if ( item.quant <= 0 ) then
		table.remove(player.inventory,item.id)
	end
	
end

function player.drink(item)
	return "Don't drink and drive"
end




function player.craftWeapon(item)
	if ( item.quant < 3 ) then return "You need 3 " .. item.name .. " to make a weapon." end
	
	local craftItem = items.getCraftedWeapon(item)
	
	if ( craftItem == nil ) then return "Something went wrong!" end
	
	table.insert(player.inventory,craftItem)
	reduceItemQuant(item,3)
	
	return "You craft a " .. craftItem.name
end




function player.craftArmor(item)
	if ( item.quant < 6 ) then return "You need 6 " .. item.name .. " to make an armor." end
	
	local craftItem = items.getCraftedArmor(item)
	
	if ( craftItem == nil ) then return "Something went wrong!" end
	
	table.insert(player.inventory,craftItem)
	reduceItemQuant(item,6)
	
	return "You craft a " .. craftItem.name
end



function player.eat(item)
	if ( player.food > ( player.maxFood - 1 ) ) then 
		return "You are too full to eat " .. item.name
	end
	local retString = "You eat the " .. item.name
	player.food = math.min(player.food + item.foodValue,player.maxFood)
	
	reduceItemQuant(item,1)

	return retString
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
   return string.match('abcdefghijklmnopqrstuvwxyza',itemChar..'(.)')
end

function player.getItemFromLetter(chara)
   local letter = string.lower( string.char(chara) )
   local cLetter = "a"
   for i,cItem in pairs(player.inventory) do 
      if ( cLetter == letter ) then return cItem end
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
      player.emeralds = player.emeralds + item.quant
      return true
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