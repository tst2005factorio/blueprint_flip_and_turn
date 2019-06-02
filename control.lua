--require("defines")

blpflip_location = "top" -- top/left/center
blpflip_flow_direction = "horizontal" -- horizontal/vertical

local function getBlueprintCursorStack(player)
	local cursor = player.cursor_stack
	if cursor.valid_for_read and (cursor.name == "blueprint" or cursor.name == "blueprint-book") and cursor.is_blueprint_setup() then --check if is a blueprint, work in book as well
		return cursor
	end
	--[[ --old way setup -- OH my god Why??? 
	if cursor.valid_for_read and cursor.name == "blueprint" and cursor.is_blueprint_setup() then
		return cursor
	elseif cursor.valid_for_read and cursor.name == "blueprint-book" then
		local bookInv = cursor.get_inventory(defines.inventory.item_active)
		if (bookInv[1].valid_for_read and bookInv[1].name == "blueprint") then
			if bookInv[1].is_blueprint_setup() then
				return bookInv[1]
			end
		end
	end
	--]]
	return nil
end

local function flip_v(player_index)
	local player = game.players[player_index]
	local cursor = getBlueprintCursorStack(player)
	local ents = {}
	if cursor then
		if cursor.get_blueprint_entities() ~= nil then
			ents = cursor.get_blueprint_entities()
			for i = 1, #ents do
				local ent = ents[i]
				local dir = ent.direction or 0
				if ent.name == "curved-rail" then
					ent.direction = (13 - dir)%8
				elseif ent.name == "storage-tank" then
					if ent.direction == 2 or ent.direction == 6 then
						ent.direction = 4
					else
						ent.direction = 2
					end
				elseif ent.name == "rail-signal" or ent.name == "rail-chain-signal" then
					if dir == 1 then
						ent.direction = 7
					elseif  dir == 2 then
						ent.direction = 6
					elseif  dir == 3 then
						ent.direction = 5
					elseif  dir == 5 then
						ent.direction = 3
					elseif  dir == 6 then
						ent.direction = 2
					elseif  dir == 7 then
						ent.direction = 1
					end
				elseif ent.name == "train-stop" then
					if dir == 2 then
						ent.direction = 6
					elseif  dir == 6 then
						ent.direction = 2
					end
				elseif ent.name == "splitter" or ent.name == "fast-splitter" or ent.name == "express-splitter" then
					--[[
					Initial:
						For a vertical flip (horizontal axe) (up/down) the "entities" with "name" equal to "splitter", "fast-splitter" or "express-splitter"
						with "direction" 2 or 6 should toggle the "input_priority" and "output_priority" fields (if exists).
					Update:
						The flip rotate the splitter then we must toggle the left/right in all cases. No need to check the direction.
					]]--
					local function toggle_priority(pri)
						return ({left="right",right="left"})[pri] or pri
					end
					if ent.input_priority then
						ent.input_priority = toggle_priority(ent.input_priority)
					end
					if ent.output_priority then
						ent.output_priority = toggle_priority(ent.output_priority)
					end
					ent.direction = (12 - dir)%8
				else
					ent.direction = (12 - dir)%8
				end
				ent.position.y = -ent.position.y
				if ent.drop_position then
					ent.drop_position.y = -ent.drop_position.y
				end
				if ent.pickup_position then
					ent.pickup_position.y = -ent.pickup_position.y
				end
			end
			cursor.set_blueprint_entities(ents)
		end
		if cursor.get_blueprint_tiles() ~= nil then
			ents = cursor.get_blueprint_tiles()
			for i = 1, #ents do
				local ent = ents[i]
				local dir = ent.direction or 0
				ent.direction = (12 - dir)%8
				ent.position.y = -ent.position.y
			end
			cursor.set_blueprint_tiles(ents)
		end
	end
end

local function flip_h(player_index)
	local player = game.players[player_index]
	local cursor = getBlueprintCursorStack(player)
	local ents = {}
	if cursor then
		if cursor.get_blueprint_entities() ~= nil then
			ents = cursor.get_blueprint_entities()
			for i = 1, #ents do
				local ent = ents[i]
				local dir = ent.direction or 0
				if ent.name == "curved-rail" then
					ent.direction = (9 - dir)%8
				elseif ent.name == "storage-tank" then
					if dir == 2 or dir == 6 then
						ent.direction = 4
					else
						ent.direction = 2
					end
				elseif ent.name == "rail-signal" or ent.name == "rail-chain-signal" then
					--player.print("1. " .. ent.name .. ": " .. dir)
					if dir == 0 then
						ent.direction = 4
					elseif dir == 1 then
						ent.direction = 3
					elseif dir == 3 then
						ent.direction = 1
					elseif dir == 4 then
						ent.direction = 0
					elseif dir == 5 then
						ent.direction = 7
					elseif dir == 7 then
						ent.direction = 5
					end
					--player.print("2. " .. ent.name .. ": " .. ent.direction)
				elseif ent.name == "train-stop" then
					--player.print("1. " .. ent.name .. ": " .. dir)
					if dir == 0 then
						ent.direction = 4
					elseif  dir == 4 then
						ent.direction = 0
					end
					--player.print("2. " .. ent.name .. ": " .. ent.direction)
				elseif ent.name == "splitter" or ent.name == "fast-splitter" or ent.name == "express-splitter" then
					--[[
					Initial:
						For a horizontal flip (vertical axe) (left/right) the "entities" with "name" equal to "splitter", "fast-splitter" or "express-splitter"
						with "direction" 0 or 4 should toggle the "input_priority" and "output_priority" fields (if exists).
					Update:
						The flip rotate the splitter then we must toggle the left/right in all cases. No need to check the direction.
					]]--
					local function toggle_priority(pri)
						return ({left="right",right="left"})[pri] or pri
					end
					if ent.input_priority then
						ent.input_priority = toggle_priority(ent.input_priority)
					end
					if ent.output_priority then
						ent.output_priority = toggle_priority(ent.output_priority)
					end
					ent.direction = (16 - dir)%8
				else
					ent.direction = (16 - dir)%8
				end
				ent.position.x = -ent.position.x
				if ent.drop_position then
					ent.drop_position.x = -ent.drop_position.x
				end
				if ent.pickup_position then
					ent.pickup_position.x = -ent.pickup_position.x
				end
			end
			cursor.set_blueprint_entities(ents)
		end
		if cursor.get_blueprint_tiles() ~= nil then
			ents = cursor.get_blueprint_tiles()
			for i = 1, #ents do
				local ent = ents[i]
				local dir = ent.direction or 0
				ent.direction = (16 - dir)%8
				ent.position.x = -ent.position.x
			end
			cursor.set_blueprint_tiles(ents)
		end
	end
end

local function doButtons(player_index)
	if not game.players[player_index].gui[blpflip_location].blpflip_flow then
		local flow = game.players[player_index].gui[blpflip_location].add{type = "flow", name = "blpflip_flow", direction = blpflip_flow_direction}
		flow.add{type = "button", name = "blueprint_flip_horizontal", style = "blpflip_button_horizontal"}
		flow.add{type = "button", name = "blueprint_flip_vertical", style = "blpflip_button_vertical"}
	end
	if game.players[player_index].gui.top.blueprint_flipper_flow then
		game.players[player_index].gui.top.blueprint_flipper_flow.destroy()
	end
end

script.on_event(defines.events.on_gui_click,function(event)
	if event.element.name == "blueprint_flip_horizontal" then
		flip_h(event.player_index)
	elseif event.element.name == "blueprint_flip_vertical" then
		flip_v(event.player_index)
	end
end)

script.on_event(defines.events.on_player_created,function(event) doButtons(event.player_index) end)

script.on_configuration_changed(function(data) for i=1,#game.players do doButtons(i) end end)
script.on_init(function() for i=1,#game.players do doButtons(i) end end)

script.on_event("blueprint_hotkey_flip_horizontal",
	function(event) flip_h(event.player_index) end)
script.on_event("blueprint_hotkey_flip_vertical",
	function(event) flip_v(event.player_index) end)
