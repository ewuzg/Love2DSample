degree = math.pi / 180
hour   = 0
minute = 0
second = 0
hour24 = 0


maxParticles = 30

scr_width, scr_height, scr_flags = love.window.getMode()
local snow = require('snow')(scr_width, scr_height, maxParticles)


function love.load()


	ox = scr_width / 2
	oy = scr_height / 2

	-- bkg:
	bkg = nil
	if love.filesystem.exists("bkg.png") then
		bkg = love.graphics.newImage("bkg.png")
	elseif love.filesystem.exists("bkg.jpg")  then
		bkg = love.graphics.newImage("bkg.jpg")
	end


	if bkg ~= nil then
	local img_wh = math.min(bkg:getHeight(), bkg:getWidth(), scr_width, scr_height)
		quad = love.graphics.newQuad(
		math.floor(math.abs(bkg:getWidth() - scr_width)/2),
		math.floor(math.abs(bkg:getHeight() - scr_height)/2),
		img_wh, img_wh,
		bkg:getWidth(), bkg:getHeight());

	end

	snow:load()

end

function love.draw()

	do
		-- bkg:
		if bkg ~= nil then
			love.graphics.setColor(255,255,255)
			--love.graphics.draw(bkg, quad, 0, 0)
			 love.graphics.draw(bkg,
			 math.floor(math.abs(bkg:getWidth() - scr_width)/2),
			 math.floor(math.abs(bkg:getHeight() - scr_height)/2))
		end
	end

	snow:draw()

	local x1
	local y1
	local index = 0
	local xp1, xp2;
	local yp1, yp2;
	local angelSin;
	local angelCos;

	local second_index = math.fmod((45 + second), 60);
	local hour_index   = math.fmod((9  + hour),   12);
	hour_index = (hour_index * 5 + math.floor(minute / 12))
	local minute_index = math.fmod((45 + minute), 60);


	while index < 60 do

		angelCos = math.cos(index * 6 * degree);
		angelSin = math.sin(index * 6 * degree);

		love.graphics.setColor(255,255,255)

		--> hour hand:
		if hour_index == index then
			x1 = ox + (80 * angelCos)
			y1 = oy + (80 * angelSin)
			love.graphics.setLineWidth(3)
			love.graphics.line(ox, oy, x1, y1)
		end

		--> minute hand:
		if minute_index == index then
			x1 = ox + (90 * angelCos)
			y1 = oy + (90 * angelSin)
			love.graphics.setLineWidth(2)
			love.graphics.line(ox, oy, x1, y1)
		end

		--> second hand:
		if second_index == index then
			love.graphics.setColor(255,0,0)
			love.graphics.setLineWidth(1)

			---> big second hand:
			x1 = ox + (100 * angelCos)
			y1 = oy + (100 * angelSin)
			love.graphics.line(ox, oy, x1, y1)

			---------------------------------------
			---> little second hand:
			do
				local angelCos1 = math.cos(math.pi + index * 6 * degree);
				local angelSin1 = math.sin(math.pi + index * 6 * degree);
				x1 = ox + (30 * angelCos1)
				y1 = oy + (30 * angelSin1)
				love.graphics.line(ox, oy, x1, y1)
			end
			---------------------------------------
		end

		-- degree(s):
		xp1 = ox + (115 * angelCos)
		yp1 = oy + (115 * angelSin)

		love.graphics.setColor(255,255,255)

		if math.fmod(index, 5) == 0 then
			xp2 = ox + (105 * angelCos)
			yp2 = oy + (105 * angelSin)
			love.graphics.setLineWidth(2)
		else
			xp2 = ox + (110 * angelCos)
			yp2 = oy + (110 * angelSin)
			love.graphics.setLineWidth(1)
		end
		love.graphics.line(xp1, yp1, xp2, yp2)

		index = index + 1
	end

	-------------
	if hour24 >= 12 then
		str = string.format("%.2d:%.2d:%.2d PM", hour, minute, second)
	else
		str = string.format("%.2d:%.2d:%.2d AM", hour, minute, second)
	end
	love.graphics.print(str, ox-38, scr_height-18)
	love.graphics.setColor(255, 0, 0)
	love.graphics.circle("fill", ox-1, oy-1, 3, 16)
	-------------

end

function love.update(dt)

	second = os.date("%S")
	hour   = os.date("%I") -- 0 ~ 11
	minute = os.date("%M")

	dt = os.date("*t")
	hour24 = dt.hour -- 0 ~ 23

	snow:update(dt)

end

function love.keypressed(k)
	if k == "escape" then
		love.event.quit()
	end
end
