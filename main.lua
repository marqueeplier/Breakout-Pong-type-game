require "menu"
require "levels"
require "paddle"
require "ball"

function love.load()
	menu:load()
	levels:load()
	paddle:load()
	ball:load()
end

function love.update(dt)
	if menu.current_state == "menu" then
		menu:update(dt)
	end

	if menu.current_state == "action" then
		levels:update(dt)
		paddle:update(dt)
		ball:update(dt)
	end

	if menu.current_state == "paddle2" then
		if paddle2 then
			if paddle2.y < 0 then
				paddle2.y = 0
				paddle2.yvel = 0
			end

			if paddle2.y + paddle2.height > screenHeight then
				paddle2.y = screenHeight - paddle2.height
				paddle2.yvel = 0
			end
		end

		if paddle.y < 0 then
			paddle.y = 0
			paddle.yvel = 0
		end

		if paddle.y + paddle.height > screenHeight then
			paddle.y = screenHeight - paddle.height
			paddle.yvel = 0
		end
		ball:update(dt)
	end
	paddle:movement(dt)
end

function love.draw()
	local lg = love.graphics
	lg.setColor(255, 255, 255, 100)
	lg.draw(levels.current_background)
	lg.setColor(255, 255, 255)

	if menu.current_state == "menu" then
		menu:draw()
	end

	if menu.current_state == "paddle2" then
		if paddle2 then
			lg.draw(paddle2.img, paddle2.x, paddle2.y)
			lg.print(paddle2.score, screenWidth - 250, (screenHeight - 20) / 2)
		end
		lg.draw(paddle.img, paddle.x, paddle.y)
		lg.print(paddle.score, 250, (screenHeight - 20) / 2)
		ball:draw()
	end

	if menu.current_state == "action" then
		levels:draw()
		paddle:draw()
		ball:draw()
	end

	if ball.game_end then
		lg.draw(levels.current_background)
		lg.print("Congratulations!!! You beat the game\nThanks for playing :D\n M to go back to menu", screenWidth - 250, (screenHeight - 20) / 2)
	end
end

function love.keypressed(key)
	if key == "escape" then
		love.quit()
	end

	if menu.current_state == "action" or menu.current_state == "paddle2" then
		
		if key == "m" then
			menu.current_state = menu.states.menu
			reset()
		end

		paddle:keypressed(key)
	end
	menu:keypressed(key)
end

function love.mousepressed(x, y, b, istouch)
	if menu.current_state == "menu" then
		menu:mousepressed(x, y, b, istouch)
	end
end

function love.quit()
	love.event.quit()
end

function reset()
	paddle.xvel = 0
	paddle.yvel = 0
	ball.x = (screenWidth - ball.width) / 2
	ball.y = (screenHeight - ball.height) / 2
	ball.start = false
	ball.game_end = false
end