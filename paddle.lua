paddle = {}

function paddle:load()
	local lg = love.graphics

	self.width = 64
	self.height = 16

	self.x = (screenWidth - self.width) / 2
	self.y = 580

	self.img = lg.newImage("assets/paddle/paddle.png")
	self.img_long = lg.newImage("assets/paddle/paddle x2.png")
	self.img_bullet = lg.newImage("assets/paddle/bullet.png")
	self.img_health = lg.newImage("assets/paddle/health.png")

	self.current_img = self.img
	self.xvel = 0
	self.yvel = 0
	self.speed = 25
	self.friction = 2.5
	self.bullets = {}
	self.bullet_timer = 100
	self.health = 10
	self.bullets_left = 15
	self.game_over = false
	self.score = 0
end

function paddle:update(dt)
	if not self.game_over then
		paddle:boundary(dt)
	end
end

function paddle:draw()
	local lg = love.graphics

	lg.draw(self.current_img, self.x, self.y)

	for i, b in pairs(self.bullets) do
		lg.draw(self.img_bullet, b.x, b.y)
	end

	for i = 1, self.health do
		lg.draw(self.img_health, (i - 1) * 30, 0)
	end

	if self.game_over then
		lg.print("R to restart", (screenWidth - 150) / 2, (screenHeight - 39) / 2)
	end

	lg.print(self.bullets_left, screenWidth - 30, screenHeight - 30)
end

function paddle:movement(dt)
	local lk = love.keyboard

	self.xvel = self.xvel * (1 - math.min(dt * self.friction, 1))
	self.yvel = self.yvel * (1 - math.min(dt * self.friction, 1))

	if menu.current_state == "action" then
		if lk.isDown("left") and self.xvel > -100 then
			self.xvel = self.xvel - self.speed * dt
		end

		if lk.isDown("right") and self.xvel < 100 then
			self.xvel = self.xvel + self.speed * dt
		end
	end

	if menu.current_state == "paddle2" then
		if lk.isDown("w") and self.yvel > -100 then
			self.yvel = self.yvel - self.speed * dt
		end

		if lk.isDown("s") and self.yvel < 100 then
			self.yvel = self.yvel + self.speed * dt
		end
	end

	self.x = self.x + self.xvel
	self.y = self.y + self.yvel

	paddle:player_two_movement(dt)
end

function paddle:boundary(dt)
	local la = love.audio

	if self.x <= 0 then
		self.x = 0
		self.xvel = 0
	end

	if self.x + self.width >= screenWidth then
		self.x = screenWidth - self.width
		self.xvel = 0
	end

	if self.bullets then
		for i1, b in pairs(self.bullets) do
			b.y = b.y - 200 * dt

			if b.y <= 0 or levels.brick_no <= 0 then
				table.remove(self.bullets, i1)
			end

			for i2, t in pairs(levels.bricks_table) do
				if CheckCollision(b, t) then
					la.play(_sounds[1])
					local oldX, oldY = t.x, t.y
					
					if t.powerup ~= 0 then
						local random = math.random(1, 5)
						
						if random == 1 then
							table.insert(ball.powerups_table, {x = oldX, y = oldY, width = 50, height = 20, type = t.powerup})
						end
					end

					table.remove(self.bullets, i1)
					table.remove(levels.bricks_table, i2)
					levels.brick_no = levels.brick_no - 1
				end
			end
		end 
	end
end

function paddle:keypressed(key)
	local la = love.audio

	if key == "z" and self.bullets_left > 0 and menu.current_state == "action" then
		la.play(_sounds[2])
		self.bullets_left = self.bullets_left - 1
		
		local bullet1 = {x = paddle.x, y = paddle.y, width = 5, height = 5}
		local bullet2 = {x = (paddle.x + paddle.width) - 5, y = paddle.y, width = 5, height = 5} 
		table.insert(paddle.bullets, bullet1)
		table.insert(paddle.bullets, bullet2)
	end

	if key == "r" and self.game_over then
		self.xvel = 0
		self.game_over = false
		self.health = 10
	end

	if key == " " and not ball.start and not self.game_over then
		ball.start = true
	end 
end

function paddle:player_two_movement(dt)
	local lk = love.keyboard

	if menu.current_state == "paddle2" then
		if paddle2 then

			paddle2.yvel = paddle2.yvel * (1 - math.min(dt * paddle2.friction, 1))
		
			if lk.isDown("up") and paddle2.yvel > -100 then
				paddle2.yvel = paddle2.yvel - paddle2.speed * dt
			end

			if lk.isDown("down") and paddle2.yvel < 100 then
				paddle2.yvel = paddle2.yvel + paddle2.speed * dt
			end

			paddle2.y = paddle2.y + paddle2.yvel
		end
	end
end