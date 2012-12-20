require "sprite"

local player
local ground

function setupGround()
	ground = display.newGroup()
	groundSheet = sprite.newSpriteSheet("floor_set.png", 64, 32)
	baseTileSet = sprite.newSpriteSet(groundSheet, 1, 1)
	altTileSet = sprite.newSpriteSet(groundSheet, 6, 1)
	altTileSet2 = sprite.newSpriteSet(groundSheet, 10, 1)

	baseTile = sprite.newSprite(baseTileSet)

	local first = createGround(3,9)
	first.type = "corridor"
	first.direction = "up"
	ground:insert(first)

	for i=0, 10, 1 do
		createCorridor()
	end
	
	ground.x, ground.y = (display.contentWidth / 2) - (first.width / 4), 0
	ground.targetx, ground.targety = ground.x, ground.y
	ground.speedx, ground.speedy = 0, 0	
end

function createCorridor()
	local previous = ground[ground.numChildren]
	local newDirection = math.random(1, 3)
	local corridor = createGround(math.random(1, 9), math.random(1, 9))
	if newDirection == 1 then
		print("adding right corridor")
		corridor.x = previous.x
		corridor.direction = "right"
	elseif newDirection == 2 then
		print("adding left corridor")
		corridor.x = previous.x - corridor.width + previous.width
		corridor.direction = "left"
	elseif newDirection == 3 then
		print("adding up corridor")
		if math.random(1, 2) == 1 then
			corridor.x = previous.x - corridor.width + previous.width			
		else
			corridor.x = previous.x
		end
		corridor.direction = "up"
	end
	ground:insert(corridor)
end

function createGround(x, y)
	local grnd = display.newGroup()
	for i=0, x, 1 do
		for j=0, y, 1 do
			local tileSeed = math.random(1, 10)
			local tile
			if tileSeed == 7 then
				tile = sprite.newSprite(altTileSet)
			elseif tileSeed == 5 then
				tile = sprite.newSprite(altTileSet2)
			else
				tile = sprite.newSprite(baseTileSet)
			end
			tile.x = i * 128
			tile.y = j * 64
			tile:scale(4,4)
			grnd:insert(tile)
		end
	end
	
	if ground.numChildren > 0 then
		grnd.y = ground[ground.numChildren].y - grnd.height + 192
	end

	grnd.type = "corridor"
	
	return grnd
end

function setupPlayer()
	playerSheet = sprite.newSpriteSheet("player.png", 64, 64)
	standingSet = sprite.newSpriteSet(playerSheet, 1, 210)
	sprite.add(standingSet, "runleft", 5, 8, 1000)
	sprite.add(standingSet, "runright", 133, 8, 1000)
	sprite.add(standingSet, "standup", 65,1, 1000)
	sprite.add(standingSet, "standleft", 1, 1, 1000)
	sprite.add(standingSet, "standright", 129, 1, 1000)
	sprite.add(standingSet, "standdown", 193, 1, 1000)
	sprite.add(standingSet, "runup", 69, 8, 1000)
	sprite.add(standingSet, "rundown", 197, 8, 1000)
	player = sprite.newSprite(standingSet)
	player.x = display.contentWidth / 2
	player.y = display.contentHeight / 2
	player:scale(4,4)
	player.lastDirection = 1 --0 left, 1 up, 2 right, 3 down	
end

setupGround()
setupPlayer()

local function onTap(event)
	ground.targetx = event.x - display.contentWidth / 2
	ground.targety = event.y - (display.contentHeight / 2) - player.height / 2

	if math.abs(ground.targetx) > math.abs(ground.targety) then		
		if ground.targetx < 0 then
			player:prepare("runleft")
			player.lastDirection = 0
		else
			player:prepare("runright")
			player.lastDirection = 2
		end
		
		local ratio = math.abs(ground.targety) / math.abs(ground.targetx) 
		ground.speedx = 10
		ground.speedy = 10 * ratio		
	else
		if ground.targety < 0 then
			player:prepare("runup")
			player.lastDirection = 1
		else
			player:prepare("rundown")
			player.lastDirection = 3
		end		
		local ratio = math.abs(ground.targetx) / math.abs(ground.targety) 
		ground.speedx = 10 * ratio
		ground.speedy = 10
	end

	player:play()
end

local function update(event)
	local oldx = ground.x
	local oldy = ground.y

	if ground.targetx > 10 then
		ground.x = ground.x - ground.speedx
		ground.targetx = ground.targetx - ground.speedx		
	elseif ground.targetx < -10 then
		ground.x = ground.x + ground.speedx
		ground.targetx = ground.targetx + ground.speedx
	end

	if ground.targety > 10 then
		ground.y = ground.y - ground.speedy
		ground.targety = ground.targety - ground.speedy		
	elseif ground.targety < -10 then
		ground.y = ground.y + ground.speedy
		ground.targety = ground.targety + ground.speedy
	end

	if oldx + oldy == ground.x + ground.y then
		if player.lastDirection == 0 then
			player:prepare("standleft")	
		end

		if player.lastDirection == 1 then
			player:prepare("standup")
		end

		if player.lastDirection == 2 then
			player:prepare("standright")
		end

		if player.lastDirection == 3 then
			player:prepare("standdown")
		end
		
		player.currentFrame = 1
	end
end

timer.performWithDelay(1, update, -1)
Runtime:addEventListener("tap", onTap)