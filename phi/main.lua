
scr_width, scr_height, scr_flags = love.window.getMode()
quarter_circle = math.pi / 2

local rcenter_x = scr_width / 2 + 200
local rcenter_y = scr_height / 2 + 80

-- local phi = {1, 1, 2, 3, 5, 8, 13, 21, 34, 55}

local dim_scale = 10

local phi_max = 10
local phi = {}

local dir = { {dx = -1, dy = -1, m = 1},
			   {dx = -1, dy = 1, m = 2},
			   {dx = 1,  dy = 1, m = 3},
			   {dx = 1,  dy = -1, m = 4} }


function love.load()

	-- gen fibonacci sequence
	phi[1] = 1
	phi[2] = 1
	for i = 3, phi_max do
		phi[i] = phi[i-2] + phi[i-1]
	end

end

function gettop_m(x1, y1, x2, y2, m)
	local top_x = 0
	local top_y = 0
	local ctr_x = 0
	local ctr_y = 0
	if m == 1 then
		top_x = x2
		top_y = y2

		ctr_x = x2
		ctr_y = y1
	elseif m == 2 then
		top_x = x2
		top_y = y1

		ctr_x = x1
		ctr_y = y2
	elseif m == 3 then
		top_x = x1
		top_y = y1

		ctr_x = x2
		ctr_y = y1
	elseif m == 4 then
		top_x = x1
		top_y = y2

		ctr_x = x1
		ctr_y = y2
	end

	return top_x, top_y, ctr_x, ctr_y
end

function love.draw()

	-------------------------------------------------
	local sfeb = "1"
	for i = 2, #phi do
		sfeb = string.format("%s,%d", sfeb, phi[i])
	end
	sfeb = string.format("feb: %s", sfeb)
	love.graphics.print(sfeb, 10, 10)
	-------------------------------------------------

	love.graphics.setLineWidth(1)

	local x = rcenter_x
	local y = rcenter_y

	idx = 1
	for i = 1, #phi do
		if idx > 4 then
			idx = 1
		end

		local temx = x
		local temy = y
		 x = x + phi[i] * dir[idx].dx * dim_scale
		 y = y + phi[i] * dir[idx].dy * dim_scale

		 local topx, topy, ctrx, ctry = gettop_m(temx, temy, x, y, dir[idx].m)
		 local radius = phi[i] * dim_scale

		 love.graphics.rectangle("line", topx, topy, radius, radius)

		 love.graphics.arc("line", ctrx, ctry, radius, -(idx - 1) *quarter_circle,  -idx *quarter_circle)

		 idx = idx + 1
	end


end


function love.keypressed(k)
	if k == "escape" then
		love.event.quit()
	end
end


