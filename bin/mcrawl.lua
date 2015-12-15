local event = require("event")
local term = require("term")
local component = require("component")
local map = require("mcrawl-map")
local player = require("mcrawl-player")
local items = require("mcrawl-items")

local gpu = component.gpu
local mry
local mrx
mrx, mry = gpu.maxResolution()
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

function showInventory()
   showingInv = true
   
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
   term.setCursor(math.ceil((mrx/2) - 4), 4)
   term.write("INVENTORY")
   for i,item in pairs(player.inventory) do
      if ( i < mry-6 ) then 
         term.setCursor(6, i+5)
         term.write(item.name)
         if ( item.quant > 1 ) then term.write(" x".. item.quant) end
      end
   
   end
   
   
end

-- PLAYER MOVEMENT


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
     showingInv = false
     viewChange = true
     logChange = true
     infoChange = true
     term.clear()
	 return
   end
   
   if ( isKey(chara,"w") or code == 200 ) then player.movePlayer("up") end
   if ( isKey(chara,"x") or code == 208 ) then player.movePlayer("down") end
   if ( isKey(chara,"a") or code == 203 ) then player.movePlayer("left") end
   if ( isKey(chara,"d") or code == 205 ) then player.movePlayer("right") end
   if ( isKey(chara,"q") or code == 199 ) then player.movePlayer("nw") end
   if ( isKey(chara,"e") or code == 201 ) then player.movePlayer("ne") end
   if ( isKey(chara,"z") or code == 207 ) then player.movePlayer("sw") end
   if ( isKey(chara,"c") or code == 209 ) then player.movePlayer("se") end
   if ( isKey(chara,"g") ) then playerGet() end
   if ( isKey(chara,"i") ) then showInventory() end
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
   if ( player.GetItem(item) ) then 
     addLog("You picked up the " .. item.name)
   else
     addLog("You can't hold any more.")
   end
end

-- Monsters?
function resolveTurn()
end

-- MAIN LOOP

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
