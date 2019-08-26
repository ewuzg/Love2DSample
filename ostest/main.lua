scr_width, scr_height, scr_flags = love.window.getMode()

os_str  = ""
scr_str = ""
key_str = ""
mouse_str = ""
fps_str = ""
cwd_str = ""
usd_str = ""
dt_str  = ""
saveddir_str = ""

logo_img = nil

char_img    = nil
char_quads  = {}
char_img_dx = 8
char_img_dy = 10

function init_char()
	-- char_img = love.graphics.newImage("CharGreen.png")
	if char_img ~= nil then
		for i = 1, 90 do
			char_quads[i] = love.graphics.newQuad((i-1)*char_img_dx, 0, char_img_dx, char_img_dy, char_img:getDimensions())
		end
	end
end

function draw_chars(str, x, y)
	if char_img ~= nil then
		local cur_x = x
		for i = 1, #str do
			local index = string.byte(str, i)
			if index >= 0x21 and index <= 0x7A then
				index = index - 0x21 + 1
				love.graphics.draw(char_img, char_quads[index], cur_x, y)
			end
			cur_x = cur_x + char_img_dx
		end
	else
		love.graphics.print(str, x, y)
	end
end

function love.load()

	--love.filesystem.setIdentity('D:/');
	love.filesystem.setIdentity(love.filesystem.getIdentity(),true)

	logo_img = love.graphics.newImage("unnamed.png")
	init_char()

	os_str  = love.system.getOS();
    scr_str = "screen: " .. tostring(scr_width) .. " * "  .. tostring(scr_height);
	cwd_str = "workingDir: " .. love.filesystem.getWorkingDirectory();
	usd_str = "userDir: " .. love.filesystem.getUserDirectory();
	saveddir_str = "savedDir: " .. love.filesystem.getSaveDirectory();

end

function love.update(dt)

	dt_str = string.format("Dt: %f", dt)

end

function love.draw()

	if logo_img ~= nil then
		love.graphics.draw(logo_img, (scr_width - logo_img:getWidth())/2,(scr_height - logo_img:getHeight())/2)
	end

	draw_chars(os_str, 10, 20)
	draw_chars(scr_str, 10, 40)
	draw_chars(cwd_str, 10, 60)
	draw_chars(usd_str, 10, 80)
	draw_chars(saveddir_str, 10, 100)
	draw_chars(dt_str,  10, 120)
	draw_chars(key_str, 10, 140)
	draw_chars(mouse_str, 10, 160)

	fps_str = "FPS: " .. tostring(love.timer.getFPS())
	draw_chars(fps_str, scr_width - 100, 20)

end

esc_count = 0
function love.keypressed(k)
	if k == "escape" then
		esc_count = esc_count + 1
		if esc_count == 2 then
			love.event.quit()
		end
	elseif k == "printscreen" then
		local screenshot = love.graphics.newScreenshot();
		screenshot:encode('png', 'gtyerd' .. '.png')
	else
		esc_count = 0
	end

	key_str = k

end

function love.mousepressed(x, y, button, istouch)
	mouse_str = "mouse_pressed: " .. tostring(button) .. ", [" .. tostring(x) .. "; " .. tostring(y) .. "]"
end
