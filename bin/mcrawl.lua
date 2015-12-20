local event = require("event")
local term = require("term")
local component = require("component")
local unicode = require("unicode")

local map = dofile("/usr/lib/mcrawl-map.lua")
local player = dofile("/usr/lib/mcrawl-player.lua")
local items = dofile("/usr/lib/mcrawl-items.lua")



local gpu = component.gpu
local mrx,mry = gpu.maxResolution()

local maxItems = 15

gpu.setResolution(mrx,mry)
if ( mrx > 40 ) then mrx = 40 end
if ( mry > 20 ) then mry = 20 end


local quit_program = false
local viewChange = true
local infoChange = true
local logChange = true

local log_y_size = math.ceil(mry / 3)
local INFO_X_SIZE = 20
local view_max_x = mrx - INFO_X_SIZE
local view_max_y = mry - ( log_y_size + 1 ) 

local moved = false
local endTurn = false





-- SCREEN DRAWING

function getMapTile(x,y)
   
   if ( x == player.x and y == player.y ) then return unicode.char(9786) end
   
   if ( map.revealMap[x][y] == 0 ) then return unicode.char(9617) end
 
   local chest = map.getChestAt(x,y)
   if ( chest ~= nil ) then return unicode.char(9054) end
  
 
   local item = map.getItemAt(x,y)
   if ( item ~= nil ) then return item.icon end
   
 
   if ( map.tiles[x][y] == "#" ) then return unicode.char(9608) end
   
   return map.tiles[x][y]
end


function drawView()
   local px = math.ceil(view_max_x / 2 )
   local py = math.ceil(view_max_y / 2 )
   
   
   local x_start = 1 + player.x - px 
   if ( x_start < 1 ) then x_start = 1 end
   if ( x_start + view_max_x > map.max_x ) then x_start = map.max_x - view_max_x end
   local x_end = x_start + view_max_x
   
   local dy = player.y - py
   if ( dy < 0 ) then dy = 0 end
   if ( dy + view_max_y > map.max_y ) then dy = map.max_y - view_max_y end
   
   for y = 1, view_max_y, 1 do 
     --local line = mapstring[y+dy]
    --local display = string.sub(line,x_start,x_end)
    term.setCursor(1,y)
   
    for x = x_start, x_end do term.write(getMapTile(x,y+dy)) end
   end
   
   --term.setCursor(player.x - ( x_start - 1 ), player.y - dy )
   --term.write("@")

end
function spaces() term.write("                ") end
function getEquipDisplayString(item)
	return item.name .. " " .. math.floor( 100 * item.dur / item.maxDur ) .. "%" 
end
function drawInfo()
   local sx = view_max_x+4
   term.setCursor(sx,1)
   term.write("Player : " .. player.name)
   spaces()
   term.setCursor(sx,2)
   term.write("Health : " .. player.HP .. "/" .. player.maxHP)
   spaces()
   term.setCursor(sx,3)
   term.write("Defence : " .. player.defence)
   spaces()
   term.setCursor(sx,4)
   term.write("Food : " .. math.ceil(player.food) .. "/" .. player.maxFood)
   spaces()
   term.setCursor(sx,5)
   term.write("Level : " .. player.level)
   spaces()
   term.setCursor(sx,6)
   term.write("EXP : " .. player.xp ) 
   spaces()
   term.setCursor(sx,7)
   term.write("Weapon: ")
   if ( player.weapon == nil ) then term.write("Fists") else term.write(getEquipDisplayString(player.weapon)) end
   spaces()
   term.setCursor(sx,8)
   term.write("Armor: ")
   if ( player.armor == nil ) then term.write("Clothes") else term.write(getEquipDisplayString(player.armor)) end
   spaces()
   term.setCursor(sx,9)
   term.write("Emeralds: " .. player.emeralds)
   spaces()
   
   
end


function drawLog()
   local logI = 0
   for y = view_max_y+3,mry do
     term.setCursor(2,y)
    term.clearLine()
    term.setCursor(2,y)
     logI = logI + 1
    
     if ( mLog[logI] ~= nil ) then term.write(mLog[logI]) end
   end
end

function drawScreen()
   if (viewChange) then drawView() end
   if (infoChange) then drawInfo() end
   if (logChange) then drawLog() end
end

local showingInv = false
local showingInvSub = false

function drawLargeGui()
   top = unicode.char(9484) .. string.rep(unicode.char(9472),mrx-8) .. unicode.char(9488)
   bot = unicode.char(9492) .. string.rep(unicode.char(9472),mrx-8) .. unicode.char(9496)
   mid = unicode.char(9474) .. string.rep(" ",mrx-8) .. unicode.char(9474)
   term.setCursor(3,3)
   term.write(top)
   term.setCursor(3,mry-3)
   term.write(bot)
   for y=4,mry-4 do
      term.setCursor(3,y)
      term.write(mid)
   end
end

function showInventory()
   showingInv = true
   
   infoChange = false
   logChange = false
   
   drawLargeGui()
   term.setCursor(math.ceil((mrx/2) - 12), 4)
   term.write("INVENTORY - 'q' to return")
   
   local itemChar = "a"
   for i,item in pairs(player.inventory) do
	  item.id = i
      if ( i < mry-6 ) then 
         term.setCursor(6, i+5)
         if ( item.dur ~= nil and item.maxDur ~= nil ) then
			term.write(itemChar .. " : " .. getEquipDisplayString(item))
		 else
			term.write(itemChar .. " : " .. item.name)
		 end
         if ( item.quant > 1 ) then term.write(" x".. item.quant) end
         if ( item == player.weapon or item == player.armor ) then term.write(" (EQ)") end
      end
     itemChar = nextLetter(itemChar)
   end
   
   
end

function nextLetter(itemChar)
   itemChar = string.lower(itemChar)
   return string.match('abcdefghijklmnopqrstuvwxyza',itemChar..'(.)')
end

-- PLAYER MOVEMENT

function movePlayer(direction)
   if ( direction == "up"    and player.y > 1  ) then tryToMovePlayer(player.x,player.y-1) end
   if ( direction == "down"  and player.y < map.max_y ) then tryToMovePlayer(player.x,player.y+1) end
   if ( direction == "left"  and player.x > 1  ) then tryToMovePlayer(player.x-1,player.y) end
   if ( direction == "right" and player.x < map.max_x ) then tryToMovePlayer(player.x+1,player.y)  end  
   if ( direction == "nw"    and player.x > 1 and
                                 player.y > 1 ) then tryToMovePlayer(player.x-1,player.y-1) end
   if ( direction == "ne"    and player.x < map.max_x and
                                 player.y > 1 ) then tryToMovePlayer(player.x+1,player.y-1) end
   if ( direction == "sw"    and player.x > 1 and
                                 player.y < map.max_y ) then tryToMovePlayer(player.x-1,player.y+1) end
   if ( direction == "se"    and player.x < map.max_x and
                                 player.y < map.max_y ) then tryToMovePlayer(player.x+1,player.y+1) end

                         
   
end

function tryToMovePlayer(newx,newy)
   
   
   
   local tile = map.tiles[newx][newy]
  
   if ( tile == "#" ) then return end
   local chest = map.getChestAt(newx,newy)
   if ( chest ~= nil ) then
     map.openChest(chest)
	 addLog("You open the treasure chest.")
   else
	player.x = newx
 	player.y = newy
	moved = true
   end
   viewChange = true
   map.changeReveal(player)
   
   endTurn = true
   
end

function isKey(chara,str)
   return ( chara == string.byte(str) or chara == string.byte(string.upper(str)) ) 
end

mLog = {}
logSize = 0
function addLog(message)
    logSize = logSize + 1
   table.insert(mLog,message)
    if ( logSize >= log_y_size ) then
      logSize = logSize - 1
      table.remove(mLog,1)
   end
   logChange = true
end

function handleKey(address,chara,code,pname)
   --print(chara,code)
   if ( player.name == "Steve" ) then
      player.name = pname
      addLog(player.name .. " has entered the dungeon!")
      infoChange = true
   end     
   
   
   if ( showingInv ) then 
     handleInventoryKey(chara,code)
     return
   end
   if ( showingInvSub ) then
    if ( handleSubInvKey(chara,code) ) then infoChange = true end
    return
   end
   
   if ( isKey(chara,"q") ) then quit_program = true return end
   
   if (  code == 200 ) then movePlayer("up") end
   if (  code == 208 ) then movePlayer("down") end
   if (  code == 203 ) then movePlayer("left") end
   if (  code == 205 ) then movePlayer("right") end
   if (  code == 199 ) then movePlayer("nw") end
   if (  code == 201 ) then movePlayer("ne") end
   if (  code == 207 ) then movePlayer("sw") end
   if (  code == 209 ) then movePlayer("se") end
   if ( isKey(chara,"g") ) then playerGet() end
   if ( isKey(chara,"i") ) then showInventory() end
end

local selectedItem

function showInvSubMenu(iItem)
    if ( iItem == nil ) then addLog("Bad item in showInvSubMenu") return end
   selectedItem = iItem
   showingInvSub = true
   addLog("Do what with the " .. iItem.name .. "?")
   addLog("q : nothing")
   addLog("d : drop")
   if ( iItem.iType == "food" ) then
      addLog("e : eat")
   end
   if ( iItem.iType == "weapon" or iItem.iType == "armor" ) then
      if ( player.weapon == iItem or player.armor == iItem ) then
         addLog("e : unequip")
      else
         addLog("e : equip")
      end
   end
   if ( iItem.iType == "potion" ) then
      addLog("q : drink")
   end
   if ( iItem.iType == "craft" ) then
      multiLog(items.getCraftCommands(iItem,player))
	  --addLog("c : craft")
   end
   
end

function multiLog(logList)
	for i,str in pairs(logList) do addLog(str) end
end

function handleSubInvKey(chara,code)
   showingInvSub = false
   if ( isKey(chara,"q") or selectedItem == nil ) then
      
      addLog("Ok.")
      return 1
   end
      
   if ( isKey(chara,"d") ) then
      addLog("You drop the " .. selectedItem.name)
      player.playerDropItem(selectedItem,map)
      return 1
   end
   
   if ( selectedItem.iType == "food" and isKey(chara,"e") ) then
      addLog(player.eat(selectedItem))
      return 1
   end
      
   if ( ( selectedItem.iType == "armor" or selectedItem.iType == "weapon" ) and isKey(chara,"e") ) then
      addLog(player.equip(selectedItem))
      return 1
   end
   
   if ( selectedItem.iType == "potion" and isKey(chara,"q") ) then
      addLog(player.drink(selectedItem))
      return 1
   end	  
   if ( selectedItem.iType == "craft" and isKey(chara,"w") and items.canCraftWeapon(selectedItem,player) ) then
      addLog(player.craftWeapon(selectedItem))
      return 1
   end
   if ( selectedItem.iType == "craft" and isKey(chara,"a") and items.canCraftArmor(selectedItem,player) ) then
      addLog(player.craftArmor(selectedItem))
      return 1
   end     
   -- no valid key pressed, try again dummy
   showingInvSub = true
   return 0
end

function handleInventoryKey(chara,code)
   if ( isKey(chara,"q") ) then 
     showingInv = false
     viewChange = true
     logChange = true
     infoChange = true
     term.clear()
    
    return
   end
   
   
   
   
   local iItem = player.getItemFromLetter(chara)
   if ( iItem ~= nil ) then
    showingInv = false
     viewChange = true
     logChange = true
     infoChange = true
     term.clear()
    
    showInvSubMenu(iItem)
    return
   end
   
   
end


function eventHandler(eventID,...)
   if ( eventID == "key_down" ) then handleKey(...) end
end


-- player actions
function resolveMovement()   
end

function playerGet()
   item = map.getItemAt(player.x,player.y)
   if ( item == nil ) then
      addLog("Nothing to pick up here.")
      return
   end
   
   if ( player.getInventorySize() >= maxItems ) then
      addLog("Your inventory is full.")
      return
   end
   if ( player.GetItem(map,item) ) then 
      infoChange = true
      if ( item.quant ~= 1 ) then
	    if ( item.quant ~= math.floor(item.quant) ) then
		    addLog("You picked up " .. item.quant * 10 .. " " .. item.name .. " shards")
		else
			addLog("You picked up " .. item.quant .. " " .. item.name)
		end
	  else
		addLog("You picked up the " .. item.name)
	  end
	  endTurn = true
   else
      addLog("You can't hold any more.")
   end
end


function resolveTurn()
	player.runHeartBeat() -- hunger, regen, status effects
	
	infoChange = true
	
	-- monster AI here

end

function checkForDeath()
	if ( player.HP <= 0 ) then 
		addLog(player.name .. " " .. player.deathMessage)
		quit_program = true
	end
end

-- MAIN LOOP

items.loadAllItems()
player.resetPlayer()
map.generateMap(player)
term.clear()

addLog("Press Q to quit")
addLog("Press I for inventory")
addLog("Press G to get item")

while ( quit_program == false ) do
   drawScreen()
   viewChange = false
   logChange = false
   infoChange = false
   moved = false
   endTurn = false
   eventHandler(event.pull())
   if ( moved == true ) then resolveMovement() end
   if ( endTurn == true ) then resolveTurn() end
   checkForDeath()
end
