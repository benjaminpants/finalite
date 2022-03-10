
local S = minetest.get_translator()

finalite = {}
finalite.needed_items = {}


bens_gear.register_on_all_materials_registered(function()
	local ores = bens_gear.ores
	for i=1, #ores do
		if (ores[i].item_name ~= "finalite:finalite_ingot") then
			table.insert(finalite.needed_items,ores[i].item_name)
		end
	end

end)

local function split(pString, pPattern) --thanks to https://stackoverflow.com/a/1579673
   local Table = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pPattern
   local last_end = 1
   local s, e, cap = pString:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
     table.insert(Table,cap)
      end
      last_end = e+1
      s, e, cap = pString:find(fpat, last_end)
   end
   if last_end <= #pString then
      cap = pString:sub(last_end)
      table.insert(Table, cap)
   end
   return Table
end

finalite.item_is_needed = function(item)
	for i=1, #finalite.needed_items do
		if (finalite.needed_items[i] == item) then
			return true
		end
		local split_result = split(finalite.needed_items[i],":")
		if (split_result[1] == "group") then --is the needed item we're currently checking a group?
			if (minetest.registered_nodes[item] ~= nil) then --is it a node?
				if (minetest.registered_nodes[item].groups ~= nil) then
					if (minetest.registered_nodes[item].groups[split_result[2]] ~= nil) then --if it does, check if it has the specific group we're looking for
						return finalite.needed_items[i] --return the name of the group.
					end
				end
			end
			
			if (minetest.registered_craftitems[item] ~= nil) then --is it a node?
				if (minetest.registered_craftitems[item].groups ~= nil) then
					if (minetest.registered_craftitems[item].groups[split_result[2]] ~= nil) then --if it does, check if it has the specific group we're looking for
						return finalite.needed_items[i] --return the name of the group.
					end
				end
			end
		end
	end
	return false
end

minetest.register_craftitem("finalite:finalite_ingot", {
	description = S("Finalite Ingot"),
	inventory_image = "finalite_finalite_ingot.png",
	groups = {finalite=1}
})

minetest.register_craftitem("finalite:finalite_apple", {
	description = S("Finalite Apple"),
	inventory_image = "finalite_finalite_apple.png",
	groups = {food_apple=1},
	on_use = minetest.item_eat(20)
})

minetest.register_craftitem("finalite:finalite_shard", {
	description = S("Finalite Shard"),
	inventory_image = "finalite_finalite_shard.png",
	groups = {finalite=1}
})

minetest.register_craft({
		
		output = "finalite:finalite_apple",
		recipe = {
			{"finalite:finalite_shard","finalite:finalite_shard","finalite:finalite_shard"},
			{"finalite:finalite_shard","default:apple","finalite:finalite_shard"},
			{"finalite:finalite_shard","finalite:finalite_shard","finalite:finalite_shard"},
		}
})

minetest.register_craft({
		
		output = "finalite:finalite_ingot",
		recipe = {
			{"finalite:finalite_shard","finalite:finalite_shard","finalite:finalite_shard"},
			{"finalite:finalite_shard","bucket:bucket_lava","finalite:finalite_shard"},
			{"finalite:finalite_shard","finalite:finalite_shard","finalite:finalite_shard"},
		},
		replacements = {{"bucket:bucket_lava","bucket:bucket_empty"}}
})

local smith_table_side = "finalite_processor_side.png"

local smith_table_side_cookin = "finalite_processor_side_active.png"


minetest.register_node("finalite:finalite_smithing_table_cooking", {
	description = S("Finalite Smithing Table (Cooking)"),
	drawtype = "normal", --stupid minetest!!!!
	paramtype = "light",
	light_source = 8,
	on_timer = function(pos, elapsed)
		minetest.add_item({x = pos.x, y = pos.y + 1, z = pos.z},"finalite:finalite_ingot")
		minetest.set_node(pos,{name="finalite:finalite_smithing_table"})
	end,
	on_construct = function(pos)
		local timer = minetest.get_node_timer(pos)
		minetest.sound_play("finalite_ingot_creation", { pos = pos, max_hear_distance = 16, gain = 0.7, })
		timer:set(10,0)
	end,
	tiles = {"finalite_processor_top_close.png","default_obsidian_brick.png",smith_table_side_cookin,smith_table_side_cookin,smith_table_side_cookin,smith_table_side_cookin},
	groups = {not_in_creative_inventory=1},
	sounds = default.node_sound_stone_defaults()
	
})


minetest.register_node("finalite:finalite_block", {
	description = S("Finalite Block"),
	drawtype = "normal",
	paramtype = "light",
	light_source = 15,
	groups = {cracky=3},
	tiles = {"finalite_finalite_block.png"},
	sounds = default.node_sound_metal_defaults(),
	
})

minetest.register_craft({
		
		output = "finalite:finalite_block",
		recipe = {
			{"finalite:finalite_ingot","finalite:finalite_ingot","finalite:finalite_ingot"},
			{"finalite:finalite_ingot","finalite:finalite_ingot","finalite:finalite_ingot"},
			{"finalite:finalite_ingot","finalite:finalite_ingot","finalite:finalite_ingot"},
		}
})

minetest.register_craft({
		type = "shapeless",
		output = "finalite:finalite_ingot 9",
		recipe = {"finalite:finalite_block"}
})

minetest.register_craft({
		type = "shapeless",
		output = "finalite:finalite_shard 8",
		recipe = {"finalite:finalite_ingot"}
})

minetest.register_node("finalite:finalite_smithing_table", {
	description = S("Finalite Smithing Table"),
	drawtype = "normal", --stupid minetest!!!!
	paramtype = "light",
	light_source = 4,
	tiles = {"finalite_processor_top_open.png","default_obsidian_brick.png",smith_table_side,smith_table_side,smith_table_side,smith_table_side},
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", S("Finalite Smithing Table (@1/@2 Materials)",0,#finalite.needed_items))
	end,
	
	on_rightclick = function(pos, node, puncher, itemstack, pointed_thing)
		if (puncher == nil) then
			return
		end
		if (not minetest.is_player(puncher)) then
			return
		end
		local meta = minetest.get_meta(pos)
		
		local held_item = itemstack
		
		local cur_thing = held_item:get_name()
		local is_needed = finalite.item_is_needed(cur_thing)
		if (type(is_needed) == "string") then
			cur_thing = is_needed
		else
			if (is_needed == false) then
				local required_stuff = ""
				for i=1, #finalite.needed_items do
					local cur_to_check = finalite.needed_items[i]
					cur_to_check = cur_to_check:gsub("%:", "_")
					if (not (meta:get_int("has_" .. cur_to_check) == 1)) then
						required_stuff = required_stuff .. finalite.needed_items[i] .. ", "
					end
				end
				minetest.chat_send_player(puncher:get_player_name(),S("This table needs: ") .. required_stuff)
				return
			end
		end
		cur_thing = cur_thing:gsub("%:", "_")
		if (meta:get_int("has_" .. cur_thing) == 0) then
			meta:set_int("has_" .. cur_thing,1)
			held_item:take_item(1)
		else
			minetest.chat_send_player(puncher:get_player_name(),S("This table already has that material!"))
		end
		--minetest.chat_send_all(meta:get_int(cur_thing))
		
		local item_amount = 0
		for i=1, #finalite.needed_items do
			local cur_to_check = finalite.needed_items[i]
			cur_to_check = cur_to_check:gsub("%:", "_")
			if (meta:get_int("has_" .. cur_to_check) == 1) then
				item_amount = item_amount + 1
			end
		end
		meta:set_string("infotext", S("Finalite Smithing Table (@1/@2 Materials)",item_amount,#finalite.needed_items))
		
		if (item_amount == #finalite.needed_items) then
			minetest.set_node(pos,{name="finalite:finalite_smithing_table_cooking"})
		end
		return held_item
	end,
	
	
	on_dig = function(pos, node, digger)
		if (digger == nil) then
			return minetest.node_dig(pos, node, digger)
		end
		if (digger:get_player_name() == "") then
			return minetest.node_dig(pos, node, digger)
		end
		local meta = minetest.get_meta(pos)
		local item_amount = 0
		for i=1, #finalite.needed_items do
			local cur_to_check = finalite.needed_items[i]
			cur_to_check = cur_to_check:gsub("%:", "_")
			if (meta:get_int("has_" .. cur_to_check) == 1) then
				item_amount = item_amount + 1
			end
		end
		
		if (item_amount ~= 0 and not digger:get_player_control().sneak) then
			minetest.chat_send_player(digger:get_player_name(),S("This table has material in it! You won't get it back if you destroy this. Please sneak while mining to confirm!"))
			return false
		else
			return minetest.node_dig(pos, node, digger)
		end
	end

})


minetest.register_craft({
		
		output = "finalite:finalite_smithing_table",
		recipe = {
			{"group:obsidian","default:tinblock","group:obsidian"},
			{"default:obsidian_glass","bucket:bucket_lava","default:obsidian_glass"},
			{"default:mese_crystal","group:obsidian","default:mese_crystal"},
		}
})

bens_gear.add_ore({
		internal_name = "finalite_finalite",
		display_name = S("Finalite"),
		item_name = "finalite:finalite_ingot",
		max_drop_level = 3,
		damage_groups_any = {fleshy=8},
		damage_groups_sword = {fleshy=20},
		damage_groups_axe = {fleshy=15},
		full_punch_interval = 1,
		uses = 120,
		flammable = false,
		groupcaps = { --the groupcaps for the tool. durability is typically used instead of "uses" so there is no need to define it
			crumbly = {times={[1]=0.4, [2]=0.3, [3]=0.2}, maxlevel=3},
			cracky = {times={[1]=0.4, [2]=0.3, [3]=0.2}, maxlevel=3},
			choppy = {times={[1]=0.4, [2]=0.3, [3]=0.2}, maxlevel=3},
			snappy= {times={[1]=0.4, [2]=0.3, [3]=0.2}, maxlevel=3},
		
		},
		tool_list = {
		--"pickaxe"
		},
		tool_list_whitelist = false, --if this is true, then tool_list should act like a whitelist, otherwise, it'll act like a blacklist
		color = "110C11",
		tool_textures = {
			default_alias = "metal", --what to append to the end of the default texture name, example: "bens_gear_axe_" would become "bens_gear_axe_metal"
			pickaxe = {"finalite_pick.png",false},
			axe = {"finalite_axe.png",false},
			shovel = {"finalite_shovel.png",false},
			sword = {"finalite_sword.png",false},
			hoe = {"finalite_hoe.png",false}
		},
		misc_data = {magic=15}, --here you can store various other weird stats for other mods to utilize, the only stat that is officially supported at the moment is "magic"
		additional_functions = { --a list of additional functions that'll be called upon certain conditions. This is here so that custom tools don't have to have support manually added.
			node_mined = nil,
			tool_destroyed = nil,
			tool_attempt_place = nil,
		},
		pre_finalization_function = nil --this function should be called RIGHT BEFORE the tool/item/whatever gets created, so that the material can add its own custom handling/data
		--it should be called like this: func(tool_id,data)
	})






