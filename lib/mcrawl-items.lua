local item = {
   itemList = {}
   
}

function item.loadAllItems()

   local file, reason = io.open("/usr/share/items.dat", "r")
   if not file then
     io.stderr:write("Failed opening items.dat file: " .. reason .. "\n")
     os.exit(1)
   end
   
   local rawdata = file:read("*all")
   file:close()
   
   local data, reason = load("return " .. rawdata)
   if not data then
     io.stderr:write("Failed loading items data: " .. reason .. "\n")
     os.exit(2)
   end
   itemList = data()
end

function item.newItem(itemType,quantity)
   if ( quantity == nil or quantity < 1 ) then quantity = 1 end
   local retItem = {
      name = string.gsub(itemType,"_"," "),
      quant = quantity
   }
   
   if ( itemType == "Emerald" ) then retItem.iType = "emerald" end
   
   local dbItem = itemList[itemType]
   
   
   if ( dbItem == nil ) then addLog("No DBItem for " .. itemType)
   else
     retItem.iType = dbItem.iType
     retItem.value = dbItem.value
   end
   
   if ( retItem.iType == "food" ) then
      retItem.foodValue = dbItem.foodValue
   end
   if ( retItem.iType == "weapon" ) then
      retItem.damage = dbItem.damage
      retItem.maxDur = dbItem.maxDur
	  retItem.dur = retItem.maxDur
   end
   if ( retItem.iType == "armor" ) then
      retItem.def = dbItem.def
      retItem.maxDur = dbItem.maxDur
	  retItem.dur = retItem.maxDur
   end
   
   --if ( itemType == "Apple" ) then 
   --   retItem.iType = "food"
   --   retItem.foodValue = 2
   --end
   
   
   if ( retItem.iType == "food" ) then retItem.icon = "%" end
   if ( retItem.iType == "weapon" ) then retItem.icon = "/" end
   if ( retItem.iType == "armor" ) then retItem.icon = "]" end
   if ( retItem.iType == "potion" ) then retItem.icon = "!" end
   if ( retItem.iType == "emerald" ) then retItem.icon = "$" end
   if ( retItem.iType == "craft" ) then retItem.icon = "^" end
   
   if ( retItem.iType == nil ) then addLog("Bad item: ".. itemType) end
   if ( retItem.icon == nil ) then addLog("Bad itemtype: " .. retItem.iType) end
   
   return retItem

end

function item.isItemStackable(item)
   if ( item.name == "Arrows" ) then return true end
   if ( item.iType == "weapon" or item.iType == "armor" ) then return false end
   return true

end

function item.getCraftCommands(cItem,player)
	local commands = {}
	if  item.canCraftWeapon(cItem,player) then table.insert(commands,"w : Craft weapon") end
	if  item.canCraftArmor(cItem,player) then table.insert(commands,"a : Craft armor") end
	return commands
end

function item.canCraftArmor(cItem,player)
	if ( cItem.name == "Stone" or
	     cItem.name == "Wood" ) then return false end
	return true
end

function item.canCraftWeapon(cItem,player)
	if ( cItem.name == "Leather" ) then return false end
	return true
end


return item