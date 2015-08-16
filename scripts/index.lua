-- DEBUG
pos_x = 5
pos_y = 1
map = "map1"
event1 = false
party = {"hero","hero2","hero3","hero4"}
-- END DEBUG

-- GPU Setup
Graphics.init()

-- Font Setup
def_font = Font.load(System.currentDirectory().."/fonts/main.ttf")
Font.setPixelSizes(def_font,16)

-- Position Setup
hero_x = 16 + pos_x * 32
hero_y = pos_y * 32
move = "STAY"

-- Map Loading
dofile(System.currentDirectory().."/maps/"..map.."/map.lua")
dofile(System.currentDirectory().."/maps/"..map.."/events.lua")
map_max_x = (map_width / 32) - 1
map_max_y = (map_height / 32) - 1

-- Hero Loading
tmp = Screen.loadImage(System.currentDirectory().."/chars/hero.png")
tmp2 = Screen.createImage(1,1,Color.new(0,0,0,0))
Screen.flipImage(tmp,tmp2)
hero = Graphics.loadImage(tmp2)
hero_max_tile_x = 32 * 3
hero_max_tile_y = 32 * 4
hero_width = hero_max_tile_x / 3
hero_height = hero_max_tile_y / 4
hero_tile_x = hero_width
hero_tile_y = 0

-- Animation Setup
anim_timer = Timer.new()
Timer.pause(anim_timer)

-- Random Encounter function
random_escaper = 0
function RandomEncounter()
	random_escaper = random_escaper + 1
	if rnd_encounter and random_escaper >= 5 then
		h,m,s = System.getTime()
		math.randomseed(h*3600+m*60+s)
		tckt = math.random(1,100)
		if tckt >= 70 then
			random_escaper = 0
			CallBattle({monsters[math.random(1,#monsters)]},false)
		end
	end
end

-- Loading modules
dofile(System.currentDirectory().."/scripts/dialogs.lua") -- Dialogs Module
dofile(System.currentDirectory().."/scripts/rendering.lua") -- Rendering Module
dofile(System.currentDirectory().."/scripts/battle.lua") -- Battle Module
dofile(System.currentDirectory().."/scripts/debug.lua") -- Debug Module

-- Hero Collision Check (TODO: Add NPCs collision checks, level2/3 unwalkable blocks collision checks)
function HeroCollision()
	raw_pos = pos_x + 1 + pos_y * (map_max_x + 1)
	if pos_x == 0 then
		can_go_left = false
	else
		can_go_left = true
		if map_table[raw_pos - 1] == 2 then
			can_go_left = false
		end
	end
	if pos_y == 0 then
		can_go_up = false
	else
		can_go_up = true
		if map_table[raw_pos - (map_max_x + 1)] == 2 then
			can_go_up = false
		end
	end
	if pos_x == ((map_width / 32) - 1) then
		can_go_right = false
	else
		can_go_right = true
		if map_table[raw_pos + 1] == 2 then
			can_go_right = false
		end
	end
	if pos_y == ((map_height / 32) - 1) then
		can_go_down = false
	else
		can_go_down = true
		if map_table[raw_pos + (map_max_x + 1)] == 2 then
			can_go_down = false
		end
	end
end

while true do

	-- Engine Setup
	pad = Controls.read()
	Screen.refresh()
	Screen.clear(TOP_SCREEN)
	Screen.clear(BOTTOM_SCREEN)
	
	-- Map Setup
	start_draw_x = hero_x - 200
	if start_draw_x < 0 then
		deboard_x = 200 - hero_x
		start_draw_x = 0
	else
		deboard_x = 0
	end
	start_draw_y = hero_y - 120
	if start_draw_y < 0 then
		deboard_y = 120 - hero_y
		start_draw_y = 0
	else
		deboard_y = 0
	end
	if hero_x + 200 > map_width then
		if deboard_x == 0 then
			draw_width = 200 + (map_width - hero_x)
		else
			draw_width = (hero_x + 200) - map_width + deboard_x
		end
	else
		draw_width = 400 - deboard_x
	end
	if hero_y + 120 > map_height then
		if deboard_y == 0 then
			draw_height = 120 + (map_height - hero_y)
		else
			draw_height = (hero_y + 120) - map_height + deboard_y
		end
	else
		draw_height = 240 - deboard_y
	end
	
	-- Hero Movement Triggering
	if Controls.check(pad,KEY_DUP) and move == "STAY" then
		HeroCollision()
		if can_go_up then
			move = "UP"
			move_stage = 1
			tot_move_stage = 1
			Timer.resume(anim_timer)
			hero_tile_x = 0
		else
			move = "STAY"
			hero_tile_y = hero_height * 3
		end
	elseif Controls.check(pad,KEY_DDOWN) and move == "STAY" then
		HeroCollision()
		if can_go_down then
			move = "DOWN"
			move_stage = 1
			tot_move_stage = 1
			Timer.resume(anim_timer)
			hero_tile_x = 0
		else
			move = "STAY"
			hero_tile_y = 0
		end
	elseif Controls.check(pad,KEY_DLEFT) and move == "STAY" then
		HeroCollision()
		if can_go_left then
			move = "LEFT"
			move_stage = 1
			tot_move_stage = 1
			Timer.resume(anim_timer)
			hero_tile_x = 0
		else
			move = "STAY"
			hero_tile_y = hero_height
		end
	elseif Controls.check(pad,KEY_DRIGHT) and move == "STAY" then
		HeroCollision()
		if can_go_right then
			move = "RIGHT"
			move_stage = 1
			tot_move_stage = 1
			Timer.resume(anim_timer)
			hero_tile_x = 0
		else
			move = "STAY"
			hero_tile_y = hero_height * 2
		end
	end
	
	-- Drawing Scene through GPU
	RenderMapScene()
	
	-- Events Triggering
	MapEvents()
	
	-- DEBUG
	if Controls.check(pad,KEY_SELECT) and (not Controls.check(oldpad,KEY_SELECT)) then
		System.takeScreenshot("/rpgm.bmp",false)
		Graphics.freeImage(hero)
		Graphics.freeImage(map_l1)
		Graphics.freeImage(map_l2)
		Graphics.freeImage(map_l3)		
		Graphics.term()
		Timer.destroy(anim_timer)
		Timer.CRASH_ME_NOW()
	end
	Screen.debugPrint(0,0,"X: "..pos_x.. " ("..hero_x.." pixels)",Color.new(255,255,255),BOTTOM_SCREEN)
	Screen.debugPrint(0,15,"Y: "..pos_y.. " ("..hero_y.." pixels)",Color.new(255,255,255),BOTTOM_SCREEN)
	Screen.debugPrint(0,30,"Map Width: "..(map_max_x),Color.new(255,255,255),BOTTOM_SCREEN)
	Screen.debugPrint(0,45,"Map Height: "..(map_max_y),Color.new(255,255,255),BOTTOM_SCREEN)
	-- END DEBUG
	
	-- Hero Animation
	if move ~= "STAY" then
		if move == "UP" then
			pos_molt = 3
			hxm = 0
			hym = -4
			new_pos_y = pos_y - 1
			new_pos_x = pos_x
		elseif move == "DOWN" then
			pos_molt = 0
			hxm = 0
			hym = 4
			new_pos_y = pos_y + 1
			new_pos_x = pos_x
		elseif move == "RIGHT" then
			pos_molt = 2
			hxm = 4
			hym = 0
			new_pos_y = pos_y
			new_pos_x = pos_x + 1
		elseif move == "LEFT" then
			pos_molt = 1
			hxm = -4
			hym = 0
			new_pos_y = pos_y
			new_pos_x = pos_x - 1
		end
		if tot_move_stage <= 8 then
			if Timer.getTime(anim_timer) > (40 * move_stage) then
				move_stage = move_stage + 1
				hero_x = hero_x + hxm
				hero_y = hero_y + hym
				tot_move_stage =  tot_move_stage + 1
			end
			if Timer.getTime(anim_timer) > 200 then
				hero_tile_x = hero_tile_x + hero_width * 2
				Timer.reset(anim_timer)
				move_stage = 1
			end
			hero_tile_y = hero_height * pos_molt
			if hero_tile_x	>= hero_max_tile_x then
				hero_tile_x = 0
			end
		else
			Timer.pause(anim_timer)
			Timer.reset(anim_timer)
			move = "STAY"
			hero_tile_x = hero_width
			pos_x = new_pos_x
			pos_y = new_pos_y
			RandomEncounter()
		end
	end
	Screen.flip()
	Screen.waitVblankStart()
	oldpad = pad
end