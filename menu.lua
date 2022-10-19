menu = {}

function menu:load()
	local lg = love.graphics
	local la = love.audio

	math.randomseed(os.time())

	screenWidth = lg.getWidth()
	screenHeight = lg.getHeight()

	local font = lg.newFont(20)

	lg.setFont(font)

	self.bg_music = la.newSource("assets/sounds/bg.wav")

	self.bg_music:setLooping(self.bg_music)
	self.bg_music:play()

	self.buttons = {
		            lg.newImage("assets/menu/start.png"),
		            lg.newImage("assets/menu/player2.png"),
	                lg.newImage("assets/menu/quit.png")
				   }

	self.mousebox = {x = 0, y = 0, width = 5, height = 5}
	self.states = {menu = "menu", action = "action", paddle2 = "paddle2"}

	self.current_state = self.states.menu 
	self.logo = lg.newImage("assets/menu/logo.png")
	_mousebox = self.mousebox

	self.fullscreen = false
end

function menu:update(dt)
	local lm = love.mouse
	
	_mousebox.x = lm.getX()
	_mousebox.y = lm.getY()
end

function menu:draw()
	local lg = love.graphics

	lg.draw(self.logo, (screenWidth - self.logo:getWidth()) / 2, (screenHeight - self.logo:getHeight()) / 20)

	for i = 1, #self.buttons do
		local btn = {}
			  btn.width = 250
			  btn.height = 50
			  btn.x = (screenWidth - btn.width) / 2
			  btn.y = (i * 100) + (screenHeight - btn.height) / 3
			  btn.img = self.buttons[i]

			  lg.draw(btn.img, btn.x, btn.y)
	end
	love.graphics.print("F2 - Fullscreen\no/p - Music On/Off\nM to pause", 0, 200)
end

function menu:mousepressed(x, y, b, istouch)
	local lg = love.graphics

	for i = 1, #self.buttons do
		local btn = {}
			  btn.width = 250
			  btn.height = 50
			  btn.x = (screenWidth - btn.width) / 2
			  btn.y = (i * 100) + (screenHeight - btn.height) / 3
			  btn.img = self.buttons[i]
			  btn.id = i

			if CheckCollision(_mousebox, btn) then
			  	if b == "l" then
			  		if btn.id == 1 then
			  			self.current_state = self.states.action
			  			menu:set_normal()
			  			menu:mousebox_reset()
			  		end

			  		if btn.id == 2 then
			  			self.current_state = self.states.paddle2
			  			ball.speedY = 0
			  			ball.speedX = ball.speed
						menu:create_paddle2()
			  			menu:mousebox_reset()
			  		end

			  		if btn.id == 3 then
			  			love.quit()
			  		end
			  	end
			end
	end
end

function menu:set_normal()
	local lg = love.graphics
	paddle.width = 64
	paddle.height = 16
	paddle.x = (screenWidth - paddle.width) / 2
	paddle.y = 580
	paddle.img = lg.newImage("assets/paddle/paddle.png")
	ball.speedY = ball.speed
	ball.speedX = 0
end

function menu:create_paddle2()
	local lg = love.graphics
	
	paddle.width = 16
	paddle.height = 64
	paddle.x = 0
	paddle.y = screenHeight - paddle.height
	paddle.img = lg.newImage("assets/bricks/paddle1_2p.png")

	paddle2 = {}
	paddle2.width = 16
	paddle2.height = 64
	paddle2.img = lg.newImage("assets/bricks/paddle2_2p.png")
	paddle2.x = (screenWidth - paddle2.width)
	paddle2.y = (screenHeight - paddle2.height) / 2
	paddle2.xvel = 0
	paddle2.yvel = 0
	paddle2.speed = 25
	paddle2.friction = 2.5
	paddle2.score = 0
end

function menu:keypressed(key)
	local lw = love.window

	if (key == "f2" or key == "i") and self.fullscreen == false then
		self.fullscreen = true
		lw.setFullscreen(true, "normal")
	elseif (key == "f2" or key == "i") and self.fullscreen then
		self.fullscreen = false
		lw.setFullscreen(false, "normal")
		lw.setMode(800, 600, {resizable = false, vsync = false, minwidth = 800, minheight = 600})
	end

	if key == "o" then
		self.bg_music:stop()
	end

	if key == "p" then
		self.bg_music:setLooping(self.bg_music)
		self.bg_music:play()
	end
end

function menu:mousebox_reset()
	_mousebox.x = 0
	_mousebox.y = 0
end