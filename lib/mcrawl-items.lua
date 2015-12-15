local item = {}



function item.newItem(itemType,quantity)
   if ( quantity == nil or quantity < 1 ) then quantity = 1 end
   local retItem = {
      name = itemType,
      quant = quantity
   }
   
   if ( itemType == "Emerald" ) then retItem.iType = "emerald" end
   
   if ( itemType == "Apple" ) then 
      retItem.iType = "food"
      retItem.foodValue = 2
   end
   
   
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

local function isItemStackable(item)
   if ( item.name == "Arrows" ) then return true end
   if ( item.iType == "weapon" or item.iType == "armor" ) then return false end
   return true

end








return item