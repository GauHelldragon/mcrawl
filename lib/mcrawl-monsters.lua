--local maps = dofile("/usr/lib/mcrawl-map.lua")


local monsters = {
	monList = {},
	monDB = {}

}
-- Monster data: 
-- x
-- y
-- id
-- tile
-- name
-- HP


function monsters.getMonsterAt(x,y)
	for i,mon in pairs(monList) do
		if ( mon.x == x and mon.y == y ) then
			mon.id = i
			return mon
		end
	end
end

function monsters.hasVisibility(mon,player,map)
	local playerRoom = map.getPlayerRoom(player)
	if ( playerRoom ~= 0 ) then -- Room Check
		local mobRoom = map.getRoomAt(mon.x,mon.y)
		if ( mobRoom == playerRoom ) then
			return true
		else
			return false
		end
	
	else -- Hallway Check
		if ( mon.x >= player.x - 1 and mon.x <= player.x + 1 and mon.y >= player.y - 1 and mon.y <= player.y + 1 ) then
			return true
		else
			return false
		end
	end
	
end

function monsters.getTile(mon)
	if ( mon.tile ~= nil ) return mon.tile
	return "M"
end


function doMonsterTurn(player)
end


return monsters