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

return player