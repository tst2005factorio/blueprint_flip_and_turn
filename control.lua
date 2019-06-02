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
				local dir = ents[i].direction or 0
				if ents[i].name == "curved-rail" then
					ents[i].direction = (13 - dir)%8
				elseif ents[i].name == "storage-tank" then
					if ents[i].direction == 2 or ents[i].direction == 6 then
						ents[i].direction = 4
					else
						ents[i].direction = 2
					end
				elseif ents[i].name == "rail-signal" or ents[i].name == "rail-chain-signal" then
					if dir == 1 then
						ents[i].direction = 7
					elseif  dir == 2 then
						ents[i].direction = 6
					elseif  dir == 3 then
						ents[i].direction = 5
					elseif  dir == 5 then
						ents[i].direction = 3
					elseif  dir == 6 then
						ents[i].direction = 2
					elseif  dir == 7 then
						ents[i].direction = 1
					end
				elseif ents[i].name == "train-stop" then
					if dir == 2 then
						ents[i].direction = 6
					elseif  dir == 6 then
						ents[i].direction = 2
					end
				else
					ents[i].direction = (12 - dir)%8
				end
				ents[i].position.y = -ents[i].position.y
				if ents[i].drop_position then
					ents[i].drop_position.y = -ents[i].drop_position.y
				end
				if ents[i].pickup_position then
					ents[i].pickup_position.y = -ents[i].pickup_position.y
				end
			end
			cursor.set_blueprint_entities(ents)
		end
		if cursor.get_blueprint_tiles() ~= nil then
			ents = cursor.get_blueprint_tiles()
			for i = 1, #ents do
				local dir = ents[i].direction or 0
				ents[i].direction = (12 - dir)%8
				ents[i].position.y = -ents[i].position.y
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
				local dir = ents[i].direction or 0
				if ents[i].name == "curved-rail" then
					ents[i].direction = (9 - dir)%8
				elseif ents[i].name == "storage-tank" then
					if ents[i].direction == 2 or ents[i].direction == 6 then
						ents[i].direction = 4
					else
						ents[i].direction = 2
					end
				elseif ents[i].name == "rail-signal" or ents[i].name == "rail-chain-signal" then
					--player.print("1. " .. ents[i].name .. ": " .. dir)
					if dir == 0 then
						ents[i].direction = 4
					elseif  dir == 1 then
						ents[i].direction = 3
					elseif  dir == 3 then
						ents[i].direction = 1
					elseif  dir == 4 then
						ents[i].direction = 0
					elseif  dir == 5 then
						ents[i].direction = 7
					elseif  dir == 7 then
						ents[i].direction = 5
					end
					--player.print("2. " .. ents[i].name .. ": " .. ents[i].direction)
				elseif ents[i].name == "train-stop" then
					--player.print("1. " .. ents[i].name .. ": " .. dir)
					if dir == 0 then
						ents[i].direction = 4
					elseif  dir == 4 then
						ents[i].direction = 0
					end
					--player.print("2. " .. ents[i].name .. ": " .. ents[i].direction)
				else
					ents[i].direction = (16 - dir)%8
				end
				ents[i].position.x = -ents[i].position.x
				if ents[i].drop_position then
					ents[i].drop_position.x = -ents[i].drop_position.x
				end
				if ents[i].pickup_position then
					ents[i].pickup_position.x = -ents[i].pickup_position.x
				end
			end
			cursor.set_blueprint_entities(ents)
		end
		if cursor.get_blueprint_tiles() ~= nil then
			ents = cursor.get_blueprint_tiles()
			for i = 1, #ents do
				local dir = ents[i].direction or 0
				ents[i].direction = (16 - dir)%8
				ents[i].position.x = -ents[i].position.x
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
