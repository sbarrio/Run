
speed = 150
bottomY=420
playerFloorY=370
jumpAccel = 16
initGravity = 200

counter = 0
obstacles = {}
lastTimeObstacle = 1000

gravity = 200
jumpSND = nil
hitSND = nil
pointSND = nil
player = { x = 100, y = playerFloorY,jumping = false, accel = jumpAccel, img = nil }
font = nil
isGameOver = false

function love.load()
   player.img = love.graphics.newImage("dude.png")
   love.graphics.setBackgroundColor(122,195,255)
   jumpSND = love.audio.newSource("Jump2.wav")
   hitSND = love.audio.newSource("hit.wav")
   pointSND = love.audio.newSource("point.wav")
   font = love.graphics.newFont(35)
end

function love.update(dt)

	-- exit game
	if love.keyboard.isDown('escape') then
		love.event.push('quit')
	end

	-- main loop
	if isGameOver == false then
		-- input
		if love.keyboard.isDown('a') and player.jumping == false then
			love.audio.play(jumpSND)
			player.jumping = true
		end

		--player is jumping
		if player.jumping and player.accel > 0 then
			player.y = player.y - player.accel
			player.accel = player.accel - 1
		end

		--Gravity
		if player.y < playerFloorY then
			player.y = player.y + gravity*dt;
			gravity = gravity + 10;
		end

		if player.y > playerFloorY then 
			player.y = playerFloorY
		end

		if player.y == playerFloorY then
			player.jumping = false
			player.accel = jumpAccel
			gravity = initGravity
		end

		--generates obstacles
		lastTimeObstacle = lastTimeObstacle - 10
		if lastTimeObstacle <= 0 then
			lastTimeObstacle = love.math.random(200,700)

			newObstacle= { x = 640, y = 370, width = 25, height = 50, counted = false}
			table.insert(obstacles, newObstacle)
		end
		
		--moves obstacles
		for i, obstacle in ipairs(obstacles) do
			obstacle.x = obstacle.x - 10
			--obstacle off screen gets removed
			if obstacle.x < 0 then
				table.remove(obstacle, i)
			end

			--obstacle past player counts 1 point
			if obstacle.counted == false and obstacle.x < player.x then
				obstacle.counted = true
				counter = counter + 1
				love.audio.play(pointSND)
			end
		end

		--checks collisions with player
		for i, obstacle in ipairs(obstacles) do
			if CheckCollision(player.x,player.y,player.img:getWidth(),player.img:getHeight(),obstacle.x,obstacle.y,obstacle.width,obstacle.height) then
				isGameOver = true
				love.audio.play(hitSND)
			end
		end
	end
end

function love.draw()
	--draws floor
	love.graphics.setColor(0,199,84)
	love.graphics.rectangle('fill', 0, 420, 640, 60)

	--draws sun
	love.graphics.setColor(0,255,51)
	love.graphics.circle("fill", 550, 70, 40, 100)

	--draws player
    love.graphics.draw(player.img, player.x, player.y)

    --draws jump counter
    love.graphics.setColor(94,117,113)
    love.graphics.setFont(font)
   	love.graphics.print(counter, 300, 200)	

   	if (isGameOver) then
   		love.graphics.setColor(94,117,113)
   		love.graphics.print("GAME OVER", 220, 100)	
   	end

    -- draws obstacles
	for i, obstacle in ipairs(obstacles) do
	  love.graphics.setColor(255,0,0)
	  love.graphics.rectangle('fill', obstacle.x, obstacle.y, obstacle.width, obstacle.height);
	end
end

function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

