local event = require("event")
local term = require("term")
local component = require("component")

local map = dofile("/usr/lib/mcrawl-map.lua")
local player = dofile("/usr/lib/mcrawl-player.lua")
local items = dofile("/usr/lib/mcrawl-items.lua")

local gpu = component.gpu
local mry,mrx = gpu.maxResolution()

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
   
   if ( x == player.x and y == player.y ) then return "@" end
   
   if ( map.revealMap[x][y] == 0 ) then return "*" end
   
   local item = map.getItemAt(x,y)
   if ( item ~= nil ) then return item.icon end
   
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

function drawInfo()
   local sx = view_max_x+4
   term.setCursor(sx,1)
   term.write("Player : " .. player.name)
   term.setCursor(sx,2)
   term.write("Health : " .. player.HP .. "/" .. player.maxHP)
   term.setCursor(sx,3)
   term.write("Defence : " .. player.defence)
   term.setCursor(sx,4)
   term.write("Food : " .. math.ceil(player.food) .. "/" .. player.maxFood)
   term.setCursor(sx,5)
   term.write("Level : " .. player.level)
   term.setCursor(sx,6)
   term.write("EXP : " .. player.xp ) 
   term.setCursor(sx,7)
   term.write("Weapon: ")
   if ( player.weapon == nil ) then term.write("Fists") else term.write(weapon.name) end
   term.setCursor(sx,8)
   term.write("Armor: ")
   if ( player.armor == nil ) then term.write("Clothes") else term.write(armor.name) end
   term.setCursor(sx,9)
   term.write("Emeralds: " .. player.emeralds)
   
   
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
   top = string.rep("=",mrx-6)
   mid = "|" .. string.rep(" ",mrx-8) .. "|"
   term.setCursor(3,3)
   term.write(top)
   term.setCursor(3,mry-3)
   term.write(top)
   for y=4,mry-4 do
      term.setCursor(3,y)
      term.write(mid)
   end
end

function showInventory()
   showingInv = true
   
   drawLargeGui()
   term.setCursor(math.ceil((mrx/2) - 4), 4)
   term.write("INVENTORY")
   
   local itemChar = "a"
   for i,item in pairs(player.inventory) do
      if ( i < mry-6 ) then 
         term.setCursor(6, i+5)
         term.write(itemChar .. " : " .. item.name)
         if ( item.quant > 1 ) then term.write(" x".. item.quant) end
       
      end
     itemChar = nextLetter(itemChar)
   end
   
   
end

function nextLetter(itemChar)
   itemChar = string.lower(itemChar)
   return ('abcdefghijklmnopqrstuvwxyza':match(itemChar..'(.)'))
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
   tile = map.tiles[newx][newy]

   if ( tile == "#" ) then return end
   player.x = newx
   player.y = newy
   viewChange = true
   map.changeReveal(player)
   moved = true
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
   if ( isKey(chara,"1") ) then quit_program = true end
   
   if ( showingInv ) then 
     handleInventoryKey(chara,code)
     return
   end
   if ( showingInvSub ) then
    if ( handleSubInvKey(chara,code) ) then infoChange = true end
    return
   end
   
   if ( isKey(chara,"w") or code == 200 ) then movePlayer("up") end
   if ( isKey(chara,"x") or code == 208 ) then movePlayer("down") end
   if ( isKey(chara,"a") or code == 203 ) then movePlayer("left") end
   if ( isKey(chara,"d") or code == 205 ) then movePlayer("right") end
   if ( isKey(chara,"q") or code == 199 ) then movePlayer("nw") end
   if ( isKey(chara,"e") or code == 201 ) then movePlayer("ne") end
   if ( isKey(chara,"z") or code == 207 ) then movePlayer("sw") end
   if ( isKey(chara,"c") or code == 209 ) then movePlayer("se") end
   if ( isKey(chara,"g") ) then playerGet() end
   if ( isKey(chara,"i") ) then showInventory() end
end

local selectedItem

function showInvSubMenu(iItem)
    if ( iItem ~= nil ) then addLog("Bad item in showInvSubMenu") return end
   selectedItem = iItem
   showingInvSub = true
   addLog("Do what with the .. " iItem.name .. "?")
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
      addLog("c : craft")
   end
   
end

function handleSubInvKey(chara,code)
   showingInvSub = false
   if ( isKey(chara,"q") or selectedItem ~= nil ) then
      
      addLog("Ok.")
      return 1
   end
      
   if ( isKey(chara,"d") ) then
      addLog("You drop the " .. selectedItem.name)
      player.playerDropItem(selectedItem,map)
      return 1
   end
   
   if ( selectedItem.iType == "food" and isKey(chara,"e") ) then
      player.eat(selectedItem)
      return 1
   end
      
   if ( ( selectedItem.iType == "armor" or selectedItem.iType == "weapon" ) and isKey(chara,"e") ) then
      player.equip(selectedItem)
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
      addLog("You picked up the " .. item.name)
   else
      addLog("You can't hold any more.")
   end
end

-- Monsters?
function resolveTurn()
end

-- MAIN LOOP

items.loadAllItems()
player.resetPlayer()
map.generateMap(player)
term.clear()

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
   
end
