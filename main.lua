--[==[

[BattleCity]
code = for Love2D 0.10.0
email = ewuzg at 163.com

--]==]

----------------------------------------------------------------------------------
-- version:
local BattleCity = {
Version = "1.00",
Update  = "10:36 2019/8/21"
}
local BattleCity_Soft_info = "[UPDATE: " .. BattleCity.Update .. "]"
function show_soft_info(w, h)
	love.graphics.setColor(128, 128, 128)
	love.graphics.print(BattleCity_Soft_info, w - 260, h - 22)
end
----------------------------------------------------------------------------------

-- os:
scr_width, scr_height, scr_flags = love.window.getMode()
os_str = love.system.getOS()

----------------------------------------------------
-- battlecity_config:
battlecity_config = {
debug = false,
stage = 1
}
function read_cfg()
	local ini = require("lib/ini")
	local cfg = ini.load("battlecity.ini")
	if cfg then
		battlecity_config.debug = cfg.config.debug
		battlecity_config.stage = cfg.config.stage
	end
end
read_cfg()
----------------------------------------------------

----------------------------------------------------
-- game status:
enum_game_status_splash = 1
enum_game_status_start  = 2
enum_game_status_win    = 3
enum_game_status_over   = 4

battlecity_game_status = enum_game_status_splash
battlecity_game_player   = 1
battlecity_game_player_e = 1

----------------------------------------------------

-- World creation
local bump    = require 'lib/bump'
local world   = bump.newWorld()
local col_len = 0 -- how many collisions are happening
local col = nil
local col_guid = 0

local world_obj_guid = 1
local function getObjGuid()
	local guid = world_obj_guid;
	world_obj_guid = world_obj_guid + 1;
	return guid;
end

--- obj:
enum_tank_ot_tile_wall       = 1
enum_tank_ot_tile_steel      = 2
enum_tank_ot_tile_grass      = 3
enum_tank_ot_tile_water1     = 4
enum_tank_ot_tile_water2     = 5
enum_tank_ot_tile_eagle      = 6
enum_tank_ot_tile_eagle_die  = 7

enum_tank_ot_wall_frame      = 8

enum_tank_ot_bullet_player   = 9
enum_tank_ot_bullet_player2  = 10
enum_tank_ot_bullet_enemy    = 11

enum_tank_ot_tank_player  = 12
enum_tank_ot_tank_player2 = 13
enum_tank_ot_tank_enemy   = 14

enum_tank_ot_bonus_id_min = 20
enum_tank_ot_bonus_life   = 20
enum_tank_ot_bonus_time   = 21
enum_tank_ot_bonus_shovel = 22
enum_tank_ot_bonus_bomb   = 23
enum_tank_ot_bonus_star   = 24
enum_tank_ot_bonus_hat    = 25
enum_tank_ot_bonus_id_max = 25


-- stage:
local battlecity_stage = require ("stage")
battlecity_stage_num = math.min(battlecity_config.stage, #battlecity_stage)


-- battlecity dimension:
block_size    = 32
tank_size     = 28
block_x_count = 13
block_y_count = 13
frame_width  = block_x_count * block_size
frame_height = block_y_count * block_size

frame_beg_x = (scr_width - frame_width) / 2
frame_beg_y = (scr_height - frame_height) / 2
frame_end_x = frame_beg_x + frame_width
frame_end_y = frame_beg_y + frame_height

-- frame_edge:
enum_frame_edge_left   = 1
enum_frame_edge_top    = 2
enum_frame_edge_right  = 3
enum_frame_edge_bottom = 4
frame_edges = {
	{x = frame_beg_x - block_size, y = frame_beg_y, w = block_size, h = frame_height, ot = enum_tank_ot_wall_frame, guid = getObjGuid()},
	{x = frame_beg_x - block_size, y = frame_beg_y - tank_size, w = frame_width + block_size * 3, h = tank_size, ot = enum_tank_ot_wall_frame, guid = getObjGuid()},
	{x = frame_end_x, y = frame_beg_y, w = block_size * 2, h = frame_height, ot = enum_tank_ot_wall_frame, guid = getObjGuid()},
	{x = frame_beg_x - block_size, y = frame_end_y, w = frame_width + block_size * 3, h = tank_size, ot = enum_tank_ot_wall_frame, guid = getObjGuid()}
}

-- draw_frame_edges:
function draw_frame_edges()

	love.graphics.setColor(128, 128, 128)
	for i = 1, #frame_edges do
		love.graphics.rectangle("fill", frame_edges[i].x, frame_edges[i].y, frame_edges[i].w, frame_edges[i].h)
	end

end

-- battlecity res:
tank_img_player1  = love.graphics.newImage("res/graphics/player1.bmp")
tank_img_player2  = love.graphics.newImage("res/graphics/player2.bmp")
tank_img_player_w = tank_img_player1:getWidth()
tank_img_player_h = tank_img_player1:getHeight()

tank_img_tile   = love.graphics.newImage("res/graphics/tile.bmp")
tank_img_tile_w = tank_img_tile:getWidth()
tank_img_tile_h = tank_img_tile:getHeight()

tank_bullet_size = 8
tank_img_bullet   = love.graphics.newImage("res/graphics/bullet.bmp")
tank_img_bullet_w = tank_img_bullet:getWidth()
tank_img_bullet_h = tank_img_bullet:getHeight()

tank_img_explode = {}
tank_explode_effect = {}

tank_player_quad = {}
tank_bullet_quad = {}
tank_tile_quad   = {}

-- enemy:
tank_img_enemy   = love.graphics.newImage("res/graphics/enemy.bmp")
tank_img_enemy_w = tank_img_enemy:getWidth()
tank_img_enemy_h = tank_img_enemy:getHeight()
tank_enemy_types = 8
tank_enemy_quad  = {}

-- bonus
tank_img_bonus   = love.graphics.newImage("res/graphics/bonus.bmp")
tank_img_bonus_w = tank_img_bonus:getWidth()
tank_img_bonus_h = tank_img_bonus:getHeight()
tank_bonus_types = 6
tank_bonus_quad  = {}
tank_bonus_state = {}

-- flag:
tank_img_flag = love.graphics.newImage("res/graphics/flag.bmp")

-- shield:
tank_img_shield  = love.graphics.newImage("res/graphics/shield.bmp")
tank_shield_quad = {}

-- misc
tank_img_misc   = love.graphics.newImage("res/graphics/misc.bmp")
tank_img_misc_w = tank_img_misc:getWidth()
tank_img_misc_h = tank_img_misc:getHeight()
tank_sign_size  = tank_img_misc_h
tank_sign_quad  = love.graphics.newQuad(tank_sign_size, 0, tank_sign_size, tank_sign_size, tank_img_misc_w, tank_img_misc_h)

-- splash:
tank_img_game_splash = love.graphics.newImage("res/graphics/splash.bmp")
game_splash_init_x = (scr_width - tank_img_game_splash:getWidth()) / 2
game_splash_init_y = (scr_height - tank_img_game_splash:getHeight()) / 2
game_splash_player_x  = game_splash_init_x + 80
game_splash_player_y1 = game_splash_init_y + 170
game_splash_player_y2 = game_splash_init_y + 200

-- font:
game_font = love.graphics.newFont("res/font/font.ttf", 18);

-- object base speed:
tank_move_base_step = 4
tank_player_move_base_step = 5
tank_bullet_move_base_step = 8

-- tank_enemy_spec:
tank_enemy_spec = {
	{speed = 0, bonus = 0, firedelay = 50}, {speed = 0, bonus = 0, firedelay = 50},
	{speed = 1, bonus = 0, firedelay = 40}, {speed = 1, bonus = 0, firedelay = 40},
	{speed = 2, bonus = 1, firedelay = 30}, {speed = 2, bonus = 1, firedelay = 30},
	{speed = 0, bonus = 0, firedelay = 20}, {speed = 0, bonus = 0, firedelay = 20}
}

-- enemy tank live state:
tank_enemy_state = {}
tank_enemy_max_count   = 15
tank_enemy_store_count = 15
tank_enemy_count       = 0
tank_enemy_live_count  = 0
tank_enemy_frozen      = false
tank_enemy_frozen_tick = 0

-- enemy tank home:
tank_enemy_home = {
	{x = frame_beg_x, y = frame_beg_y},
	{x = (frame_beg_x + math.floor(block_x_count / 2) * block_size), y = frame_beg_y},
	{x = frame_end_x - block_size, y = frame_beg_y}
}


-- sound:
tank_sound_tbl = {}

-- enum_tank_dir_x:
enum_tank_dir_up    = 1
enum_tank_dir_right = 2
enum_tank_dir_down  = 3
enum_tank_dir_left  = 4

-- enum_tank_shield_x:
enum_tank_shield_normal = 1
enum_tank_shield_super  = 2

tank_shield_super_tick  = 180

-- player tank power:
tank_player_power_max = 4
tank_player_firedelay = {35, 25, 15, 5}

tank_player_stage_life = 3

-- player tank data:
tank_player_state = {
	tank_dir   = enum_tank_dir_up,
	tank_dir_e = 1,
	tank_power = 1,
	tank_pos = { x = 0, y = 0, ot = enum_tank_ot_tank_player, guid = getObjGuid() },
	tank_score = 0,
	tank_life  = 0,
	tank_firedelay = 0,
	tank_shield = enum_tank_shield_normal,
	tank_shield_e = 1,
	tank_shield_tick = 0
};

-- player_home_state:
player_home_state = {}

-- tank bullet state:
tank_bullet_state = {}


-- frame blocks:
frame_blocks = {}

-- ctrl area:
dir_bar_size = 30
dir_bar_x = frame_edges[enum_frame_edge_left].x - dir_bar_size * 3
if os_str == "Android" then
	dir_bar_size = 80
	dir_bar_x = frame_edges[enum_frame_edge_left].x - dir_bar_size * 3
end
dir_bar_x = dir_bar_x - 15
dir_bar_y = frame_edges[enum_frame_edge_bottom].y - dir_bar_size * 3

dir_bars = {
	{x = dir_bar_x + dir_bar_size, y = dir_bar_y, dir = "up" },
	{x = dir_bar_x + dir_bar_size * 2, y = dir_bar_y + dir_bar_size, dir = "right"},
	{x = dir_bar_x + dir_bar_size, y = dir_bar_y + dir_bar_size * 2, dir = "down"},
	{x = dir_bar_x, y = dir_bar_y + dir_bar_size, dir = "left"}
}


local fire_bar_size = dir_bar_size
local fire_bar_pos = { x = frame_edges[enum_frame_edge_right].x + frame_edges[enum_frame_edge_right].w + 15, y = frame_end_y - dir_bar_size }


-- draw_tank_sign:
function draw_tank_sign()

	-- enemy stored tanks:
	love.graphics.setColor(255, 255, 255)
	if tank_enemy_store_count > 0 then
		local count = 0
		local x = frame_end_x + tank_sign_size
		local y = frame_beg_y
		for i = 1, 6 do
			count = count + 1
			if count > tank_enemy_store_count then break end
			love.graphics.draw(tank_img_misc, tank_sign_quad, x, y)
			count = count + 1
			if count > tank_enemy_store_count then break end
			love.graphics.draw(tank_img_misc, tank_sign_quad, (x + tank_sign_size + 2), y)
			y = y + tank_sign_size + 2
		end
	end

	-- player tanks lifes:
	local x = frame_end_x + tank_sign_size
	local y = frame_end_y - block_size * 5
	love.graphics.draw(tank_img_misc, tank_sign_quad, x, y)
	love.graphics.setColor(0, 0, 0)
	love.graphics.print(tostring(tank_player_state.tank_life), (x + tank_sign_size + 4), (y - 4))
	love.graphics.setColor(255, 255, 255)

	-- stage flag:
	x = frame_end_x + tank_sign_size
	y = frame_end_y - block_size * 2
	love.graphics.draw(tank_img_flag, x, y)
	love.graphics.setColor(0, 0, 0)
	love.graphics.print(tostring(battlecity_stage_num), x + 8, y + 32 )
	love.graphics.setColor(255, 255, 255)


end


-- init_res:
function init_res()

	-- player tank:
	for i = 1, 4 do
		tank_player_quad[i] = {}
		local x = (i - 1) * 2 * tank_size
		for j = 1, 4 do
			local y = (j - 1) * tank_size
			tank_player_quad[i][j] = {}
			tank_player_quad[i][j][1] = love.graphics.newQuad(x, y, tank_size, tank_size, tank_img_player_w, tank_img_player_h)
			tank_player_quad[i][j][2] = love.graphics.newQuad(x + tank_size, y, tank_size, tank_size, tank_img_player_w, tank_img_player_h)
		end
	end

	-- enemy tank:
	for i = 1, tank_enemy_types do
		tank_enemy_quad[i] = {}
		local x = (i - 1) * 2 * tank_size
		for j = 1, 4 do
			local y = (j - 1) * tank_size
			tank_enemy_quad[i][j] = {}
			tank_enemy_quad[i][j][1] = love.graphics.newQuad(x, y, tank_size, tank_size, tank_img_enemy_w, tank_img_enemy_h)
			tank_enemy_quad[i][j][2] = love.graphics.newQuad(x + tank_size, y, tank_size, tank_size, tank_img_enemy_w, tank_img_enemy_h)
		end
	end

	for i = 1, 7 do
		tank_tile_quad[i] = love.graphics.newQuad((i-1) * block_size , 0, block_size, block_size, tank_img_tile_w, tank_img_tile_h)
	end

	for i = 1, 4 do
		tank_bullet_quad[i] = love.graphics.newQuad((i-1) * tank_bullet_size, 0, tank_bullet_size, tank_bullet_size, tank_img_bullet_w, tank_img_bullet_h)
	end

	tank_img_explode[1] = {}
	tank_img_explode[1].img = love.graphics.newImage("res/graphics/explode1.bmp")
	tank_img_explode[1].w = 28
	tank_img_explode[1].h = 28
	tank_img_explode[2] = {}
	tank_img_explode[2].img = love.graphics.newImage("res/graphics/explode2.bmp")
	tank_img_explode[2].w = 64
	tank_img_explode[2].h = 64

	-- bonus:
	for i = 1, tank_bonus_types do
		local x = (i - 1) * 30
		tank_bonus_quad[i] = love.graphics.newQuad(x, 0, 30, 28, tank_img_bonus_w, tank_img_bonus_h)
	end

	-- shield:
	tank_shield_quad[1] = love.graphics.newQuad(0,  0, 32, 32, 32, 64)
	tank_shield_quad[2] = love.graphics.newQuad(0, 32, 32, 32, 32, 64)

	-- sound:
	init_sound()

end

-- init_sound
function init_sound()

	tank_sound_tbl.fire    = love.audio.newSource("res/sound/Gunfire.wav", "static")
	tank_sound_tbl.hit     = love.audio.newSource("res/sound/Hit.wav", "static")
	tank_sound_tbl.bang    = love.audio.newSource("res/sound/Bang.wav", "static")
	tank_sound_tbl.fanfare = love.audio.newSource("res/sound/Fanfare.wav", "static")
	tank_sound_tbl.peow    = love.audio.newSource("res/sound/Peow.wav", "static")

end

-- play_sound
function play_sound(sname)

	local sound = tank_sound_tbl[sname]
	if sound ~= nil then
		love.audio.play(sound)
	end

end

------------------------------------------------------
-- tank_player_move_filter:
function tank_player_move_filter(item, other)

	if other.ot == enum_tank_ot_tile_grass then
		return "cross"
	else
		return "slide"
	end

end

-- tank_enemy_move_filter:
function tank_enemy_move_filter(item, other)

	if other.ot == enum_tank_ot_tile_grass then
		return "cross"
	elseif other.ot == enum_tank_ot_bullet_enemy then
		return "cross"
	elseif (other.ot >= enum_tank_ot_bonus_id_min and other.ot <= enum_tank_ot_bonus_id_max) then
		return "cross"
	else
		return "slide"
	end

end

-- tank_bullet_player_move_filter:
function tank_bullet_player_move_filter(item, other)

	if other.ot == enum_tank_ot_tile_grass or other.ot == enum_tank_ot_tile_water1 or other.ot == enum_tank_ot_tile_water2 then
		return "cross"
	elseif (other.ot >= enum_tank_ot_bonus_id_min and other.ot <= enum_tank_ot_bonus_id_max) then
		return "cross"
	else
		return "slide"
	end

end

-- tank_bullet_enemy_move_filter:
function tank_bullet_enemy_move_filter(item, other)

	if other.ot == enum_tank_ot_tile_grass or other.ot == enum_tank_ot_tile_water1 or other.ot == enum_tank_ot_tile_water2 then
		return "cross"
	elseif (other.ot >= enum_tank_ot_bonus_id_min and other.ot <= enum_tank_ot_bonus_id_max) then
		return "cross"
	elseif other.ot == enum_tank_ot_tank_enemy then
		return "cross"
	else
		return "slide"
	end

end

------------------------------------------------------

-- add_enemy_tank:
function add_enemy_tank(x, y, d)

	local idx = #tank_enemy_state + 1
	local tti = math.random(tank_enemy_types)
	tank_enemy_state[idx] = {}
	tank_enemy_state[idx].x = x
	tank_enemy_state[idx].y = y
	tank_enemy_state[idx].ot    = enum_tank_ot_tank_enemy
	tank_enemy_state[idx].guid  = getObjGuid()
	tank_enemy_state[idx].t     = tti
	tank_enemy_state[idx].dir   = d
	tank_enemy_state[idx].dir_e = 1
	tank_enemy_state[idx].step  = math.random(50, 200)
	tank_enemy_state[idx].firedelay = math.random(5, tank_enemy_spec[tti].firedelay)

	world:add(tank_enemy_state[idx], x, y, tank_size, tank_size)

	tank_enemy_count = tank_enemy_count + 1
	tank_enemy_store_count = tank_enemy_store_count - 1

	if battlecity_config.debug then
		local str = string.format("add_enemy_tank: (x=%d, y=%d), type = %d",  x, y, tti)
		print(str)
	end

end

-- rand_enemy_tank_dir:
function rand_enemy_tank_dir(ed)

	local dd = 1
	if math.random(2) == 1 then
		dd = -1
	end
	dd = ed + dd
	if dd <= 0 then
		dd = enum_tank_dir_left
	elseif dd > enum_tank_dir_left then
		dd = enum_tank_dir_up
	end
	return dd

end

-- update_enemy_tank:
function update_enemy_tank()

	for k, m in ipairs(tank_enemy_state) do

		local dx = 0
		local dy = 0
		local speed = (tank_move_base_step + tank_enemy_spec[m.t].speed)

		-- enemy tank fire:
		if m.firedelay <= 0 then

			local idx = #tank_bullet_state + 1
			tank_bullet_state[idx] = { x = 0, y = 0, w = tank_bullet_size, h = tank_bullet_size,
									   ot = enum_tank_ot_bullet_enemy, guid = getObjGuid(), dir = m.dir }

			tank_bullet_state[idx] .x, tank_bullet_state[idx] .y = calc_tank_bullet_init_pos(m.x, m.y, m.dir)
			world:add(tank_bullet_state[idx], tank_bullet_state[idx].x, tank_bullet_state[idx].y, tank_bullet_size, tank_bullet_size)

			m.firedelay = tank_enemy_spec[m.t].firedelay
		else
			m.firedelay = m.firedelay - 1
		end

		-- enemy tank move:
		if m.dir == enum_tank_dir_up then
			dy = -speed
		elseif m.dir == enum_tank_dir_down then
			dy = speed
		elseif m.dir == enum_tank_dir_left then
			dx = -speed
		elseif m.dir == enum_tank_dir_right then
			dx = speed
		end

		if dx ~= 0 or dy ~= 0 then

			if m.dir_e == 1 then
				m.dir_e = 2
			else
				m.dir_e = 1
			end

			m.x, m.y, col, col_len = world:move(m, m.x + dx, m.y + dy, tank_enemy_move_filter)
			if col_len > 0 then

				for i = 1, col_len do
					local other = col[i].other;
					-- enemy tank hit player bullet:
					if other.ot == enum_tank_ot_bullet_player then

						if battlecity_config.debug then
							local str = string.format("enemy tank hit player bullet: (x = %d, y = %d)", m.x, m.y)
							print(str)
						end

						-- hit effect:
						play_sound("bang")
						add_explode_effect(m.x, m.y, 0, 0, true)
						tank_player_state.tank_firedelay = 0
						-- remove play bullet:
						remove_bullet(other.guid)
						world:remove(other)
						-- remove enemy tank:
						local guid = m.guid
						world:remove(m)
						remove_enemy_tank(guid)
						-- gen new enemy tank:
						if tank_enemy_store_count > 0 then
							-- gen_enemy_tank()
							gen_enemy_tank_queue_add()
						else
							if #tank_enemy_state == 0 then
								battlecity_game_status = enum_game_status_win
							end
						end
						-- break:
						break

					else
						local changeDir = true
						if other.ot == enum_tank_ot_tile_grass then
							changeDir = false
						elseif other.ot == enum_tank_ot_bullet_enemy then
							changeDir = false
						elseif (other.ot >= enum_tank_ot_bonus_id_min and other.ot <= enum_tank_ot_bonus_id_max) then
							changeDir = false
						end
						if changeDir then
							m.dir  = rand_enemy_tank_dir(m.dir)
							m.step = math.random(10, 200)
						end
					end
				end

			else

				m.step = m.step - 1
				if m.step <= 0 then
					m.dir  = rand_enemy_tank_dir(m.dir)
					m.step = math.random(10, 200)
				end

			end

		end

	end

end

-- remove_enemy_tank:
function remove_enemy_tank(guid)

	for i = 1, #tank_enemy_state do
		if tank_enemy_state[i].guid == guid then
			table.remove(tank_enemy_state, i)
			break
		end
	end

end

-- draw_enemy_tank:
function draw_enemy_tank()

	for _, m in ipairs(tank_enemy_state) do
		love.graphics.draw(tank_img_enemy, tank_enemy_quad[m.t][m.dir][m.dir_e], m.x, m.y)
	end

end


-------------------------------------------------------

-- add_explode_effect:
function add_explode_effect(x, y, w, h, e)

	local idx = #tank_explode_effect + 1
	tank_explode_effect[idx] = {}
	tank_explode_effect[idx].x = x
	tank_explode_effect[idx].y = y
	tank_explode_effect[idx].t = 1
	tank_explode_effect[idx].c = 1
	tank_explode_effect[idx].e = e

end

-- update_explode_effect:
function update_explode_effect()

	local idx = 1
	while idx <= #tank_explode_effect do

		tank_explode_effect[idx].c = tank_explode_effect[idx].c + 1
		if tank_explode_effect[idx].e then
			if tank_explode_effect[idx].c >= 3 then
				if tank_explode_effect[idx].t == 1 then
					tank_explode_effect[idx].t = 2
					tank_explode_effect[idx].c = 1
					idx = idx + 1
				else
					table.remove(tank_explode_effect, idx)
				end
			else
				idx = idx + 1
			end
		else
			if tank_explode_effect[idx].c >= 4 then
				table.remove(tank_explode_effect, idx)
			else
				idx = idx + 1
			end
		end

	end

end

-- draw_explode_effect:
function draw_explode_effect()

	for _, m in ipairs(tank_explode_effect) do
		love.graphics.draw(tank_img_explode[m.t].img, m.x, m.y)
	end

end

-- add_frame_tile:
function add_frame_tile(tile_t, tile_ix, tile_iy)

	local x = frame_beg_x + tile_ix * block_size
	local y = frame_beg_y + tile_iy * block_size

	local idx = #frame_blocks + 1
	frame_blocks[idx] = {}
	frame_blocks[idx].x  = x
	frame_blocks[idx].y  = y
	frame_blocks[idx].w  = block_size
	frame_blocks[idx].h  = block_size
	frame_blocks[idx].ot   = tile_t
	frame_blocks[idx].guid = getObjGuid()

	world:add(frame_blocks[idx], x, y, block_size, block_size)

	return frame_blocks[idx]

end

function remove_frame_tile(guid)

	for i = 1, #frame_blocks do
		if frame_blocks[i].guid == guid then
			table.remove(frame_blocks, i)
			break
		end
	end

end

function locate_stage(n)

	for _, m in ipairs(battlecity_stage[n].map) do
		add_frame_tile(m.ot, m.x, m.y)
	end
	battlecity_stage[n].located = battlecity_stage[n].located + 1

end

-- draw_frame_tile:
function draw_frame_tile()

	love.graphics.setColor(255, 255, 255)

	for _, block in ipairs(frame_blocks) do

		love.graphics.draw(tank_img_tile, tank_tile_quad[block.ot], block.x, block.y)

	end

end

-- calc_tank_bullet_init_pos:
function calc_tank_bullet_init_pos(tank_x, tank_y, tank_dir)

	local x = 0
	local y = 0
	if tank_dir == enum_tank_dir_up then
		x = tank_x + ((tank_size - tank_bullet_size) / 2)
		y = tank_y - tank_bullet_size - 1
	elseif tank_dir == enum_tank_dir_down then
		x = tank_x + ((tank_size - tank_bullet_size) / 2)
		y = tank_y + tank_size + 1
	elseif tank_dir == enum_tank_dir_left then
		x = tank_x - tank_bullet_size - 1
		y = tank_y + ((tank_size - tank_bullet_size) / 2)
	elseif tank_dir == enum_tank_dir_right then
		x = tank_x + tank_size + 1
		y = tank_y + ((tank_size - tank_bullet_size) / 2)
	end

	return x, y

end

-- add_player_bullet:
function add_player_bullet()

	if tank_player_state.tank_firedelay <= 0 then

		play_sound("fire")

		-- restore delay:
		tank_player_state.tank_firedelay = tank_player_firedelay[tank_player_state.tank_power]

		local idx = #tank_bullet_state + 1
		tank_bullet_state[idx] = { x = 0, y = 0, w = tank_bullet_size, h = tank_bullet_size, ot = enum_tank_ot_bullet_player, guid = getObjGuid(),
								   dir = tank_player_state.tank_dir }

		tank_bullet_state[idx] .x, tank_bullet_state[idx] .y =
			calc_tank_bullet_init_pos(tank_player_state.tank_pos.x, tank_player_state.tank_pos.y, tank_player_state.tank_dir)

		world:add(tank_bullet_state[idx], tank_bullet_state[idx].x, tank_bullet_state[idx].y, tank_bullet_size, tank_bullet_size)

		if battlecity_config.debug then
			local str = string.format("add_player_bullet: (x = %d, y = %d), dir = %d", tank_bullet_state[idx].x, tank_bullet_state[idx].y, tank_bullet_state[idx].dir)
			print(str)
		end

	end

end

-- remove_bullet:
function remove_bullet(guid)

	for i = 1, #tank_bullet_state do
		if guid == tank_bullet_state[i].guid then
			table.remove(tank_bullet_state, i)
			break
		end
	end

end

-- draw_bullet:
function draw_bullet()

	for _, m in ipairs(tank_bullet_state) do
		love.graphics.draw(tank_img_bullet, tank_bullet_quad[m.dir], m.x, m.y)
	end

end


-- draw_tank:
function draw_tank()

	if tank_player_state.tank_shield == enum_tank_shield_super then
		love.graphics.draw(tank_img_shield,
				tank_shield_quad[tank_player_state.tank_shield_e],
				tank_player_state.tank_pos.x - 2, tank_player_state.tank_pos.y - 2)
	end

	love.graphics.draw(tank_img_player1,
			tank_player_quad[tank_player_state.tank_power][tank_player_state.tank_dir][tank_player_state.tank_dir_e],
			tank_player_state.tank_pos.x, tank_player_state.tank_pos.y)

end

-- draw_frame:
function draw_frame()

	if battlecity_config.debug then

		love.graphics.setColor(128, 128, 128)
		local x = frame_beg_x
		for i = 1, block_x_count + 1 do
			love.graphics.line(x, frame_beg_y, x, frame_end_y)
			x = x + block_size
		end
		local y = frame_beg_y
		for i = 1, block_y_count + 1 do
			love.graphics.line(frame_beg_x, y, frame_end_x, y)
			y = y + block_size
		end

	end

end

-- draw_dirbar:
function draw_dirbar()

	love.graphics.setColor(128, 128, 128)
	for i = 1, #dir_bars do
		love.graphics.rectangle("fill", dir_bars[i].x, dir_bars[i].y, dir_bar_size, dir_bar_size)
	end

	love.graphics.rectangle("fill", fire_bar_pos.x, fire_bar_pos.y, fire_bar_size, fire_bar_size)


end

-- gen_enemy_tank_left:
function gen_enemy_tank_left()

	local dir = enum_tank_dir_right
	if math.random(2) == 1 then
		dir = enum_tank_dir_down
	end
	add_enemy_tank(frame_beg_x, frame_beg_y, dir)

end

-- gen_enemy_tank_right:
function gen_enemy_tank_right()

	local dir = enum_tank_dir_left
	if math.random(2) == 1 then
		dir = enum_tank_dir_down
	end
	add_enemy_tank(frame_end_x - tank_size, frame_beg_y, dir)

end

-- gen_enemy_tank_center:
function gen_enemy_tank_center()

	local dir = enum_tank_dir_down
	add_enemy_tank((frame_beg_x + math.floor(block_x_count / 2) * block_size), frame_beg_y, dir)

end

-- gen_enemy_tank:
function gen_enemy_tank()

	local idx = tank_enemy_count % 3
	if idx == 0 then
		gen_enemy_tank_left()
	elseif idx == 1 then
		gen_enemy_tank_right()
	else
		gen_enemy_tank_center()
	end

end

-- gen_enemy_tank_queue:
tank_enemy_queue = 0
function gen_enemy_tank_queue_add()

	tank_enemy_queue = tank_enemy_queue + 1

end

function gen_enemy_tank_queue()

	if tank_enemy_queue > 0 then
		local genned = false

		local probe_idx = ((tank_enemy_count % 3) + 1)
		for i = 1, 3 do
			local item, len = world:queryRect(tank_enemy_home[probe_idx].x, tank_enemy_home[probe_idx].y, tank_size, tank_size)
			if len == 0 then
				if probe_idx == 1 then
					gen_enemy_tank_left()
				elseif probe_idx == 2 then
					gen_enemy_tank_center()
				else
					gen_enemy_tank_right()
				end
				genned = true

				if battlecity_config.debug then
					local str = string.format("gen_enemy_tank_queue: index = %d",  probe_idx)
					print(str)
				end

				break
			end
			probe_idx = probe_idx + 1
			if probe_idx > 3 then
				probe_idx = 1
			end
		end

		if genned then
			tank_enemy_queue = tank_enemy_queue - 1
		end
	end

end

-- gen_bonus:
function gen_bonus()

	local x = 0
	local y = 0
	local found = false
	for i = 1, block_x_count - 2 do
		for j = 1, block_y_count - 2 do
			x = frame_beg_x + i * block_size
			y = frame_beg_y + j * block_size
			local item, len = world:queryRect(x, y, block_size, block_size)
			if len == 0 then
				found = true
				break
			end
		end
		if found then break end
	end

	if found then
		local bonus_type = math.random(enum_tank_ot_bonus_id_min, enum_tank_ot_bonus_id_max)
		local idx = #tank_bonus_state + 1
		tank_bonus_state[idx] = {}
		tank_bonus_state[idx].x = x
		tank_bonus_state[idx].y = y
		tank_bonus_state[idx].w = 30
		tank_bonus_state[idx].h = 28
		tank_bonus_state[idx].ot   = bonus_type
		tank_bonus_state[idx].guid = getObjGuid()

		world:add(tank_bonus_state[idx], x, y, tank_bonus_state[idx].w , tank_bonus_state[idx].h)
	end

end

function draw_bonus()

	love.graphics.setColor(255, 255, 255)
	for _, m in ipairs(tank_bonus_state) do
		local idx = m.ot - enum_tank_ot_bonus_id_min + 1
		love.graphics.draw(tank_img_bonus, tank_bonus_quad[idx], m.x, m.y)
	end

end

function remove_bonus(guid)

	for i = 1, #tank_bonus_state do
		if tank_bonus_state[i].guid == guid then
			table.remove(tank_bonus_state, i)
			break
		end
	end

end

function clear_stage()

	world = nil
	world = bump.newWorld()

	tank_bonus_state = nil
	tank_bonus_state = {}

	tank_enemy_state = nil
	tank_enemy_state = {}

	tank_enemy_store_count = 15
	tank_enemy_count = 0
	tank_enemy_live_count = 0

	tank_bullet_state = nil
	tank_bullet_state = {}

	tank_explode_effect = nil
	tank_explode_effect = {}

	frame_blocks = nil
	frame_blocks = {}

	player_home_state = nil
	player_home_state = {}

	tank_enemy_frozen = false

end

-- reload_player_home:
function reload_player_home()

	local eagle_x = math.floor(block_x_count / 2);
	local eagle_y = (block_y_count - 1);

	-- eagle:
	player_home_state[0] = add_frame_tile(enum_tank_ot_tile_eagle, eagle_x, eagle_y)
	-- 5 bricks:
	player_home_state[1] = add_frame_tile(enum_tank_ot_tile_wall, eagle_x-1, eagle_y)
	player_home_state[2] = add_frame_tile(enum_tank_ot_tile_wall, eagle_x+1, eagle_y)
	player_home_state[3] = add_frame_tile(enum_tank_ot_tile_wall, eagle_x-1, eagle_y-1)
	player_home_state[4] = add_frame_tile(enum_tank_ot_tile_wall, eagle_x,   eagle_y-1)
	player_home_state[5] = add_frame_tile(enum_tank_ot_tile_wall, eagle_x+1, eagle_y-1)

end

-- protect_player_home:
function protect_player_home()

	player_home_state[1].ot = enum_tank_ot_tile_steel
	player_home_state[2].ot = enum_tank_ot_tile_steel
	player_home_state[3].ot = enum_tank_ot_tile_steel
	player_home_state[4].ot = enum_tank_ot_tile_steel
	player_home_state[5].ot = enum_tank_ot_tile_steel

end

-- reload_stage:
function reload_stage()

	for _, frame_edge in ipairs(frame_edges) do
		world:add(frame_edge, frame_edge.x, frame_edge.y, frame_edge.w, frame_edge.h)
	end

	tank_player_state.tank_dir   = enum_tank_dir_up
	tank_player_state.tank_dir_e = 1
	tank_player_state.tank_pos.x = frame_beg_x + (math.floor(block_x_count / 2) - 2) * block_size
	tank_player_state.tank_pos.y = frame_end_y - block_size
	tank_player_state.tank_life  = tank_player_state.tank_life + tank_player_stage_life
	tank_player_state.tank_score = 0
	tank_player_state.tank_firedelay = 0

	world:add(tank_player_state.tank_pos, tank_player_state.tank_pos.x, tank_player_state.tank_pos.y, tank_size, tank_size)

	reload_player_home()

	locate_stage(battlecity_stage_num)

	gen_enemy_tank()
	gen_enemy_tank()
	gen_enemy_tank()

end

function next_stage()

	battlecity_stage_num = battlecity_stage_num + 1
	if battlecity_stage_num > #battlecity_stage then
		battlecity_stage_num = 1
	end

	clear_stage()
	reload_stage()

end

-- love.load:
function love.load()

	love.filesystem.setIdentity("battlecity");
	math.randomseed(os.time())

	init_res()

end

function fmt_box(t)

	local str = string.format("{x = %d, y = %d, w = %d, h = %d}", t.x, t.y, t.w or 0, t.h or 0)
	return str

end

-- draw_splash:
function draw_splash()

	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(tank_img_game_splash, game_splash_init_x, game_splash_init_y)
	if battlecity_game_player == 1 then
		love.graphics.draw(tank_img_player1, tank_player_quad[1][2][battlecity_game_player_e], game_splash_player_x, game_splash_player_y1)
	else
		love.graphics.draw(tank_img_player1, tank_player_quad[1][2][battlecity_game_player_e], game_splash_player_x, game_splash_player_y2)
	end

end

-- love.draw:
function love.draw()

	love.graphics.setFont(game_font);

	if battlecity_game_status == enum_game_status_start then

		draw_frame()
		draw_frame_edges()
		draw_frame_tile()
		draw_bonus()
		draw_tank_sign()
		draw_tank()
		draw_bullet()
		draw_enemy_tank()
		draw_explode_effect()

	elseif battlecity_game_status == enum_game_status_splash then

		draw_splash()

	end

	draw_dirbar()
	debug_print()
	show_soft_info(scr_width, scr_height)

end

-- deal_enemy_tank_die:
function deal_enemy_tank_die(guid)

	local isWin = false
	local tankState = nil

	for i = 1, #tank_enemy_state do
		if tank_enemy_state[i].guid == guid then
			tankState = tank_enemy_state[i]
			break
		end
	end

	if tankState ~= nil then

		-- hit effect:
		play_sound("bang")
		add_explode_effect(tankState.x, tankState.y, 0, 0, true)

		local guid = tankState.guid

		world:remove(tankState)
		remove_enemy_tank(guid)

		if tank_enemy_spec[tankState.t].bonus > 0 then
			gen_bonus()
		end

		if tank_enemy_store_count > 0 then
			-- gen_enemy_tank()
			gen_enemy_tank_queue_add()
		else
			if #tank_enemy_state == 0 then
				if battlecity_config.debug then
					local str = string.format("deal_enemy_tank_die game win.")
					print(str)
				end

				battlecity_game_status = enum_game_status_win
				isWin = true
			end
		end

	end

	return isWin

end

-- move_bullet:
function move_bullet()

	for _, m in ipairs(tank_bullet_state) do

		local dx = 0
		local dy = 0
		if m.dir == enum_tank_dir_up then
			dy = -(tank_bullet_move_base_step + 3)
		elseif m.dir == enum_tank_dir_down then
			dy = (tank_bullet_move_base_step + 3)
		elseif m.dir == enum_tank_dir_left then
			dx = -(tank_bullet_move_base_step + 3)
		elseif m.dir == enum_tank_dir_right then
			dx = (tank_bullet_move_base_step + 3)
		end

		if dx ~= 0 or dy ~= 0 then

			if m.ot == enum_tank_ot_tank_player or m.ot == enum_tank_ot_tank_player2 then
				m.x, m.y, col, col_len = world:move(m, m.x + dx, m.y + dy, tank_bullet_player_move_filter)
			else
				m.x, m.y, col, col_len = world:move(m, m.x + dx, m.y + dy, tank_bullet_enemy_move_filter)
			end
			if col_len > 0 then

				for i = 1, col_len do
					local other = col[i].other;

					if battlecity_config.debug then
						if m.ot == enum_tank_ot_bullet_player then
							local str = string.format("player_bullet hit: col_len = %d, (x = %d, y = %d), ot = %d", col_len, m.x, m.y, other.ot)
							print(str)
						end
					end

					if other.ot == enum_tank_ot_tile_wall then

						-- hit effect:
						play_sound("hit")
						add_explode_effect(m.x, m.y, 0, 0, false)

						local guid = other.guid
						remove_frame_tile(guid)
						world:remove(other)

					elseif other.ot == enum_tank_ot_tile_steel or other.ot == enum_tank_ot_wall_frame then

						-- hit effect:
						play_sound("hit")
						add_explode_effect(m.x, m.y, 0, 0, false)

					elseif other.ot == enum_tank_ot_tank_enemy then

						-- player's bullet hit enemy tank:
						if m.ot == enum_tank_ot_bullet_player then

							local guid = other.guid
							if deal_enemy_tank_die(guid) then
								break
							end

						end

					elseif other.ot == enum_tank_ot_bullet_enemy then

						-- bullet hit bullet, all remove:
						remove_bullet(other.guid)
						world:remove(other)

					end

					-- check hit need remove:
					local needRemove = true
					if (other.ot >= enum_tank_ot_bonus_id_min and other.ot <= enum_tank_ot_bonus_id_max) then
						needRemove = false
					elseif other.ot == enum_tank_ot_tile_grass or other.ot == enum_tank_ot_tile_water1 or other.ot == enum_tank_ot_tile_water2 then
						needRemove = false
					else
						if m.ot == enum_tank_ot_bullet_player then
							if other.ot == enum_tank_ot_bullet_player then
								needRemove = false
							end
						elseif m.ot == enum_tank_ot_bullet_enemy then
							if other.ot == enum_tank_ot_tank_enemy then
								needRemove = false
							end
						end
					end
					if needRemove then
						if m.ot == enum_tank_ot_bullet_player then
							tank_player_state.tank_firedelay = 0
						end
						remove_bullet(m.guid)
						world:remove(m)
						break;
					end
				end


			end
		end

	end


end

-- debug_print:
function debug_print()

	local ix = 10
	local iy = 10
	local y_indent = 22
	love.graphics.setColor(192, 192, 192)
	local str = string.format("FPS: %d", love.timer.getFPS())
	love.graphics.print(str, ix, iy)
	local dt = os.date("*t")
	str = string.format("%d-%d-%d %d:%.2d:%.2d", dt.year, dt.month, dt.day, dt.hour, dt.min, dt.sec)
	love.graphics.print(str, (scr_width - 210), iy)

end

-- deal_keypressed:
function deal_keypressed(key)

	local moved = false

	local dx = 0
	local dy = 0
	if (key == "up" or key == "w" ) then

		if (tank_player_state.tank_dir == enum_tank_dir_up) then
			dy = -(tank_player_move_base_step)
		else
			tank_player_state.tank_dir = enum_tank_dir_up
		end

	elseif (key == "down" or key == "s") then

		if (tank_player_state.tank_dir == enum_tank_dir_down) then
			dy = (tank_player_move_base_step)
		else
			tank_player_state.tank_dir = enum_tank_dir_down
		end

	elseif (key == "left" or key == "a") then

		if (tank_player_state.tank_dir == enum_tank_dir_left) then
			dx = -(tank_player_move_base_step)
		else
			tank_player_state.tank_dir = enum_tank_dir_left
		end

	elseif (key == "right" or key == "d") then

		if (tank_player_state.tank_dir == enum_tank_dir_right) then
			dx = (tank_player_move_base_step)
		else
			tank_player_state.tank_dir = enum_tank_dir_right
		end

	end

	if dx ~= 0 or dy ~= 0 then

		tank_player_state.tank_pos.x, tank_player_state.tank_pos.y, col, col_len = world:move(tank_player_state.tank_pos, tank_player_state.tank_pos.x + dx, tank_player_state.tank_pos.y + dy, tank_player_move_filter)
		if col_len > 0 then
			local other = col[1].other;
			if other.ot >= enum_tank_ot_bonus_id_min and other.ot <= enum_tank_ot_bonus_id_max then

				if battlecity_config.debug then
					local str = string.format("player_tank hit: bonus, ot = %d",  other.ot)
					print(str)
				end

				if other.ot == enum_tank_ot_bonus_life then
					play_sound("fanfare")
					tank_player_state.tank_life = tank_player_state.tank_life + 1
					if battlecity_config.debug then
						local str = string.format("player_tank add life: life = %d", tank_player_state.tank_life)
						print(str)
					end
				elseif other.ot == enum_tank_ot_bonus_star then
					play_sound("fanfare")
					tank_player_state.tank_power = tank_player_state.tank_power + 1
					if tank_player_state.tank_power > tank_player_power_max then
						tank_player_state.tank_power = tank_player_power_max
						-- give it super hat:
						tank_player_state.tank_shield = enum_tank_shield_super
						tank_player_state.tank_shield_e = 1
						tank_player_state.tank_shield_tick = tank_shield_super_tick
					end
					if battlecity_config.debug then
						local str = string.format("player_tank add power: power = %d", tank_player_state.tank_power)
						print(str)
					end
				elseif other.ot == enum_tank_ot_bonus_hat then
					play_sound("fanfare")
					tank_player_state.tank_shield = enum_tank_shield_super
					tank_player_state.tank_shield_e = 1
					tank_player_state.tank_shield_tick = tank_shield_super_tick
				elseif other.ot == enum_tank_ot_bonus_bomb then

					if #tank_enemy_state> 0 then
						local guids = {}
						for i = 1, #tank_enemy_state do
							guids[#guids + 1] = tank_enemy_state[i].guid
						end
						for i = 1, #guids do
							deal_enemy_tank_die(guids[i]) ;
						end
					end

				elseif other.ot == enum_tank_ot_bonus_shovel then

					play_sound("fanfare")
					protect_player_home()

				elseif other.ot == enum_tank_ot_bonus_time then

					play_sound("fanfare")
					tank_enemy_frozen      = true
					tank_enemy_frozen_tick = 120

				else
					play_sound("peow")
				end

				local guid = other.guid
				remove_bonus(guid)
				world:remove(other)
			end
		end

		if tank_player_state.tank_dir_e == 1 then
			tank_player_state.tank_dir_e = 2
		else
			tank_player_state.tank_dir_e = 1
		end
	end

end

-- love.update:
dtotal = 0
function love.update(dt)

	dtotal = dtotal + dt
	if dtotal >= 0.1 then

		if battlecity_game_status == enum_game_status_start then

			----------------------------------------------------------------------------
			-- gen queue enemy tank:
			gen_enemy_tank_queue()

			----------------------------------------------------------------------------
			-- update player tank:
			if tank_player_state.tank_firedelay > 0 then
				tank_player_state.tank_firedelay = tank_player_state.tank_firedelay - 1
			end
			if tank_player_state.tank_shield == enum_tank_shield_super then
				tank_player_state.tank_shield_tick = tank_player_state.tank_shield_tick - 1
				if tank_player_state.tank_shield_tick <= 0 then
					tank_player_state.tank_shield = enum_tank_shield_normal
				else
					if tank_player_state.tank_shield_e == 1 then
						tank_player_state.tank_shield_e = 2
					else
						tank_player_state.tank_shield_e = 1
					end
				end
			end
			----------------------------------------------------------------------------

			if love.keyboard.isDown("up") or love.keyboard.isDown("w") then
				deal_keypressed("up")
			elseif love.keyboard.isDown("down") or love.keyboard.isDown("s") then
				deal_keypressed("down")
			elseif love.keyboard.isDown("left") or love.keyboard.isDown("a") then
				deal_keypressed("left")
			elseif love.keyboard.isDown("right") or love.keyboard.isDown("d") then
				deal_keypressed("right")
			end

			if love.mouse.isDown(1) then

				local x, y = love.mouse.getPosition()
				for i = 1, #dir_bars do
					if x >= dir_bars[i].x and x <= (dir_bars[i].x + dir_bar_size)
							and y >= dir_bars[i].y and  y <= (dir_bars[i].y + dir_bar_size) then
						deal_keypressed(dir_bars[i].dir)
						break
					end
				end

			end

			------------------
			move_bullet()

			-----------
			if tank_enemy_frozen then
				tank_enemy_frozen_tick = tank_enemy_frozen_tick - 1
				if tank_enemy_frozen_tick <= 0 then
					tank_enemy_frozen = false
				end
			else
				update_enemy_tank()
			end
			-----------
			update_explode_effect()

		elseif battlecity_game_status == enum_game_status_splash then

			if battlecity_game_player_e == 1 then
				battlecity_game_player_e = 2
			else
				battlecity_game_player_e = 1
			end

		elseif battlecity_game_status == enum_game_status_win then

			next_stage()
			battlecity_game_status = enum_game_status_start

		end

		dtotal = 0

	end

end

-- love.mousepressed:
function love.mousepressed(x, y, button, istouch)

	local processed = false
	if x >= fire_bar_pos.x and x <= (fire_bar_pos.x + fire_bar_size)
		and y >= fire_bar_pos.y and y <= (fire_bar_pos.y + fire_bar_size) then

		if battlecity_game_status == enum_game_status_start then

			add_player_bullet()

		elseif battlecity_game_status == enum_game_status_splash then

			reload_stage()
			battlecity_game_status = enum_game_status_start

		end

		processed = true
	end

	if not processed then

		if battlecity_game_status == enum_game_status_splash then
			for i = 1, #dir_bars do
				if x >= dir_bars[i].x and x <= (dir_bars[i].x + dir_bar_size)
						and y >= dir_bars[i].y and  y <= (dir_bars[i].y + dir_bar_size) then
					if battlecity_game_player == 1 then
						battlecity_game_player = 2
					else
						battlecity_game_player = 1
					end
					processed = true
					break
				end
			end
		end

	end

end



-- love.keypressed:
function love.keypressed(key)

	if (key == "escape") then
		-- quit app:
		love.event.quit()
	elseif (key == "tab") then
		-- toggle debug:
		battlecity_config.debug = not battlecity_config.debug
	elseif key == "printscreen" then
		local screenshot = love.graphics.newScreenshot();
		screenshot:encode('png', os.time() .. '.png')
	end

	if battlecity_game_status == enum_game_status_start then

		if (key == "j") then
			add_player_bullet()
		end

	elseif battlecity_game_status == enum_game_status_splash then

		if (key == "j") or (key == "return") then
			reload_stage()
			battlecity_game_status = enum_game_status_start
		elseif (key == "up") or (key == "down") or (key == "left") or (key == "right") then
			if battlecity_game_player == 1 then
				battlecity_game_player = 2
			else
				battlecity_game_player = 1
			end
		end

	end

end



