ball = {}

function ball:load()
	local lg = love.graphics
	local la = love.audio

	self.img = lg.newImage("assets/ball/ball.png")
	self.img_large = lg.newImage("assets/ball/ball_large.png")

	self.current_img = self.img
	self.sounds = {
					la.newSource("assets/sounds/hit.wav"),
					la.newSource("assets/sounds/bullet.wav")
				  }
	self.width = 15
	self.height = 15
	self.x = (screenWidth - self.width) / 2
	self.y = (screenHeight - self.height) / 2

	self.speed = 200
	self.speedY = self.speed
	self.speedX = 0
	self.start = false

	self.positions = {}
	self.max_positions = 50
	self.trail_color = {{21, 137, 255}, {226, 88, 34}, {40, 255, 40}}
	self.trail_no = 1
	self.current_trail = self.trail_color[self.trail_no]
	self.trail_size = 10

	self.powerups_table = {}
	self.powerups_type = {"crusher", "speeder", "longer", "gunner", "bigger"}
	self.powerup_timer = 0
	self.img_powerups = {lg.newImage("assets/bricks/crusher.png"),
						 lg.newImage("assets/bricks/speeder.png"),
						 lg.newImage("assets/bricks/longer.png"),
						 lg.newImage("assets/bricks/gunner.png"),
						 lg.newImage("assets/bricks/bigger.png")}

	self.current_powerup = nil
	_power_type = self.powerups_type
	_sounds = self.sounds
	self.speed_2p = 20
	self.game_end = false
end

function ball:update(dt)
	ball:collisions()
	ball:trails()
	ball:trails_update(dt)
		
	if menu.current_state == "action" then
		ball:powerups(dt)

		if not self.start then
			self.x = paddle.x + 30
			self.y = paddle.y - 50
		end
	end
	
	if self.start then
		if menu.current_state == "action" then
			self.y = self.y + self.speedY * dt
			self.x = self.x + self.speedX * dt 
		end

		if menu.current_state == "paddle2" then
			self.y = self.y + self.speedY * dt
			self.x = self.x - self.speedX * dt 
		end
	end
end

function ball:draw()
	local lg = love.graphics

	for i = 1, #self.positions do
		lg.setColor(self.current_trail[1], self.current_trail[2], self.current_trail[3], (124/#self.positions)*i)
		lg.rectangle("fill", self.positions[i].x, self.positions[i].y, self.trail_size, self.trail_size)
	end

	lg.setColor(self.current_trail[1], self.current_trail[2], self.current_trail[3])
	lg.draw(self.current_img, self.x, self.y)

	lg.setColor(255, 255, 255)
	
	if menu.current_state == "action" then
		for i, p in pairs(self.powerups_table) do
			lg.draw(self.img_powerups[p.type], p.x, p.y)
		end

		if self.current_powerup then
			lg.print("Current_powerup: "..self.current_powerup, 500)
		end
	end

	if not self.start then 
		lg.print("Press space to start", screenWidth - 450, 500)
	end
end

function ball:collisions()
	local la = love.audio
-- With Paddle	
	if CheckCollision(self, paddle) then
		if menu.current_state == "action" then
			self.speedY = -self.speed
			local center_ball = (self.x + (self.width / 2))
			local center_paddle = (paddle.x + (paddle.width / 2))
			local center_new = center_ball - center_paddle

			self.speedX = center_new * 20 
		end
		
		if menu.current_state == "paddle2" then
			self.speed_2p = self.speed_2p + 2
			self.speedX = -self.speed
			local center_ball = (self.y + (self.height / 2))
			local center_paddle = (paddle.y + (paddle.height / 2))
			local center_new = center_ball - center_paddle

			self.speedY = center_new * self.speed_2p 
		end
	end

-- With Paddle two

	if menu.current_state == "paddle2" then
		if paddle2 then
			if CheckCollision(self, paddle2) then
				self.speed_2p = self.speed_2p + 2
				self.speedX = self.speed
				local center_ball = (self.y + (self.height / 2))
				local center_paddle = (paddle2.y + (paddle2.height / 2))
				local center_new = center_ball - center_paddle

				self.speedY = center_new * self.speed_2p
			end
		end
	end

-- With bricks

	if menu.current_state == "action" then
		for i, b in pairs(levels.bricks_table) do
			if CheckCollision(self, b) then
				la.play(_sounds[1])

				if self.current_powerup == "crusher" and b then
					table.remove(levels.bricks_table, i)
					levels.brick_no = levels.brick_no - 1
				end

				if self.current_powerup ~= "crusher" then
					if self.y + self.height > b.y + b.height then
						self.speedY = self.speed
					else
						self.speedY = -self.speed
					end
				end
			
				b.lvl = b.lvl - 1

				if b.lvl < 1 then
					local oldX = b.x
					local oldY = b.y
				
					if b.powerup ~= 0 then
						local random = math.random(1, 5)

						if random == 1 then
							table.insert(self.powerups_table, {x = oldX, y = oldY, width = 50, height = 20, type = b.powerup})
						end
					end

					table.remove(levels.bricks_table, i)
					levels.brick_no = levels.brick_no - 1
				end

				if self.current_powerup ~= "crusher" then
					local center_ball = (self.x + (self.width / 2))
					local center_brick = (b.x + (b.width / 2))
					local center_new = center_ball - center_brick

					self.speedX = center_new * 20
				end

				b.img = levels.brick_lvls[b.lvl]
			end
		end
	end

	if self.x <= 0 then
		self.speedX = self.speed
	end

	if self.x + self.width >= screenWidth then
		self.speedX = -self.speed
	end

	if self.y <= 0 then
		self.speedY = self.speed
	end

	if self.y >= screenHeight and menu.current_state == "action" then
		self.start = false
		ball:reset()
		paddle.health = paddle.health - 1
		self.current_powerup = nil
	end
	if menu.current_state == "paddle2" then
		if paddle2 then
			if self.y + self.height >= screenHeight  then
				self.speedY = -self.speed
			end	

			if self.x < 0 then
				self.start = false
				ball:reset()
				paddle2.score = paddle2.score + 1 
			end

			if self.x + self.width > screenWidth then
				self.start = false
				ball:reset()
				paddle.score = paddle.score + 1
			end
		end
	end

	if paddle.health <= 0 and menu.current_state == "action" then
		paddle.game_over = true
	end
end

function ball:reset()
	self.x = (screenWidth - self.width) / 2
	self.y = (screenHeight - self.height) / 2
	if menu.current_state == "action" then
		self.speedX = 0
	end
	if menu.current_state == "paddle2" then
		self.speedY = 0
		self.speed_2p = 20
	end
end

function ball:trails()
	local position_actual = {x = self.x, y = self.y}

	table.insert(self.positions, position_actual)

	if #self.positions > self.max_positions then
		table.remove(self.positions, 1)
	end
end

function ball:powerups(dt)
	for i, p in pairs(self.powerups_table) do
		p.y = p.y + 200 * dt

		if CheckCollision(paddle, p) then
			self.current_powerup = self.powerups_type[p.type]
			self.powerup_timer = 500
			table.remove(self.powerups_table, i)
		end

		if p.y >= screenHeight then
			table.remove(self.powerups_table, i)
		end
	end

	if self.powerup_timer > 0 then
		self.powerup_timer = self.powerup_timer - 100 * dt
	end

	if self.powerup_timer <= 0 then
		self.powerup_timer = 0
		self.speed = 200
		paddle.width = 64
		paddle.current_img = paddle.img
		self.current_powerup = nil
		self.width = 15
		self.height = 15
		self.trail_size = 10
		self.current_img = self.img
	end
end

function ball:trails_update(dt)
	local la = love.audio

	if self.current_powerup == nil then
		self.trail_no = 1
	end

	if self.current_powerup == "crusher" then
		self.speed = 200
		self.trail_no = 2
	end

	if self.current_powerup == "speeder" then
		self.trail_no = 3
		self.speed = 500
	end

	if self.current_powerup == "longer" then
		paddle.width = 128
		paddle.current_img = paddle.img_long
	end

	if self.current_powerup == "bigger" then
		self.width = 31
		self.height = 31
		self.trail_size = 20
		self.current_img = self.img_large
	end

	if self.current_powerup == "gunner" then
		paddle.bullet_timer = paddle.bullet_timer - 500 * dt
		la.play(_sounds[2])
		if paddle.bullet_timer <= 0 then
			paddle.bullet_timer = 100

			local bullet1 = {x = paddle.x, y = paddle.y, width = 5, height = 5}
			local bullet2 = {x = (paddle.x + paddle.width) - 5, y = paddle.y, width = 5, height = 5} 
			table.insert(paddle.bullets, bullet1)
			table.insert(paddle.bullets, bullet2)
		end
	end
	self.current_trail = self.trail_color[self.trail_no]
end

function CheckCollision(a, b)
	return a.x < b.x + b.width and
		   b.x < a.x + a.width and
		   a.y < b.y + b.height and
		   b.y < a.y + a.height 
end