
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
	on_use = minetest.item_eat(999)
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
	paramtype2 = "facedir",
	light_source = 8,
	on_timer = function(pos, elapsed)
		minetest.add_item({x = pos.x, y = pos.y + 1, z = pos.z},"finalite:finalite_ingot")
		local node = minetest.get_node(pos)
		minetest.set_node(pos,{name="finalite:finalite_smithing_table", param2 = node.param2})
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
	groups = {cracky=1},
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
	paramtype2 = "facedir",
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
			local node = minetest.get_node(pos)
			minetest.set_node(pos,{name="finalite:finalite_smithing_table_cooking", param2 = node.param2})
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
			{"default:obsidian","default:tinblock","default:obsidian"},
			{"default:obsidian_glass","bucket:bucket_lava","default:obsidian_glass"},
			{"default:mese_crystal","default:obsidian","default:mese_crystal"},
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


local singluarity_needed = 1980

local singularity_count = 0

bens_gear.add_ore_iterate(function(data)
	minetest.register_craftitem(":finalite:" .. data.internal_name .. "_singularity", {
		description = S("@1 Singularity", data.display_name),
		inventory_image = "finalite_singularity.png^[multiply:#" .. data.color,
		groups = {f_singularity=1}
	})
	singularity_count = singularity_count + 1
end)

minetest.register_craftitem("finalite:blackhole", {
	description = S("Black Hole") .. "\n" .. S("Incomprehensible."),
	short_description = S("Black Hole"),
	inventory_image = "finalite_blackhole.png",
	groups = {blackhole=1}
})

minetest.register_craftitem("finalite:blackhole_ingot", {
	description = S("Black Ingot") .. "\n" .. S("Incomprehensible."),
	short_description = S("Black Ingot"),
	inventory_image = "finalite_black_ingot.png",
	wield_scale = {x = 1.5, y = 1.5, z = 1},
	groups = {ingot=1}
})

minetest.register_craft({
		
	output = "finalite:blackhole_ingot 4",
	recipe = {
		{"finalite:finalite_ingot","finalite:blackhole","finalite:finalite_ingot"},
		{"finalite:blackhole","group:f_singularity","finalite:blackhole"},
		{"finalite:finalite_ingot","finalite:blackhole","finalite:finalite_ingot"},
	}
})

local function SearchForGroupOrItemInOreRegister(name)
	if (name == "") then
		return name
	end
	local register = minetest.registered_items[name]
	if (register == nil) then
		register = minetest.registered_nodes[name]
	end
	register = register.groups

	for i=1, #bens_gear.ores do
		if (bens_gear.ores[i].item_name == name) then
			return name
		else
			for v, _ in pairs(register) do
				if (("group:" .. v) == bens_gear.ores[i].item_name) then
					return "group:" .. v
				end
			end
		end
	end
	return ""
end

local function SearchForInternalNameInOreRegister(name)
	if (name == "") then
		return name
	end
	local register = minetest.registered_items[name]
	if (register == nil) then
		register = minetest.registered_nodes[name]
	end
	if (register == nil) then
		register = {}
	else
		register = register.groups
	end

	for i=1, #bens_gear.ores do
		if (bens_gear.ores[i].item_name == name) then
			return bens_gear.ores[i].internal_name
		else
			for v, _ in pairs(register) do
				if (("group:" .. v) == bens_gear.ores[i].item_name) then
					return bens_gear.ores[i].internal_name
				end
			end
		end
	end
	return ""
end


minetest.register_node("finalite:compressor", {
	description = S("Compressor"),
	drawtype = "normal", --stupid minetest!!!!
	paramtype = "light",
	paramtype2 = "facedir",
	light_source = 4,
	tiles = {"finalite_finalite_block.png^finalite_hole.png","finalite_finalite_block.png","finalite_finalite_block.png^finalite_compressor_side.png"},
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_int("item_amount",0)
		meta:set_string("material","air")
		meta:set_string("infotext", S("Compressor (@1/@2)\n@3", "0", singluarity_needed, "No material inserted!"))
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

		local group_belong_to = ""

		group_belong_to = held_item:get_name()

		group_belong_to = SearchForGroupOrItemInOreRegister(group_belong_to)

		if (group_belong_to == "") then
			return
		end

		local mat = meta:get_string("material")
		if (mat == "air") then
			meta:set_string("material",group_belong_to)
			meta:set_int("item_amount",meta:get_int("item_amount") + itemstack:get_count())
			meta:set_string("infotext", S("Compressor (@1/@2)\n@3", meta:get_int("item_amount"), singluarity_needed, group_belong_to))
			return ItemStack()
		else
			if (mat == group_belong_to) then
				meta:set_int("item_amount",meta:get_int("item_amount") + itemstack:get_count())
				if (meta:get_int("item_amount") >= singluarity_needed) then
					minetest.add_item({x = pos.x, y = pos.y + 1, z = pos.z},"finalite:" .. SearchForInternalNameInOreRegister(mat) .. "_singularity")
					itemstack:set_count(meta:get_int("item_amount") - singluarity_needed)
					local node = minetest.get_node(pos)
					minetest.set_node(pos,{name="finalite:compressor", param2 = node.param2})
					minetest.sound_play("finalite_singularity_creation", { pos = pos, max_hear_distance = 16, gain = 1, })
					return itemstack
				else
					minetest.sound_play("finalite_singularity_add", { pos = pos, max_hear_distance = 16, gain = 0.75, })
				end
			else
				return itemstack
			end
			meta:set_string("infotext", S("Compressor (@1/@2)\n@3", meta:get_int("item_amount"), singluarity_needed, group_belong_to))
			return ItemStack()
		end

	end,

	on_dig = function(pos, node, digger)
		if (digger == nil) then
			return minetest.node_dig(pos, node, digger)
		end
		if (digger:get_player_name() == "") then
			return minetest.node_dig(pos, node, digger)
		end
		local meta = minetest.get_meta(pos)
		local item_amount = meta:get_int("item_amount")
		
		if (item_amount ~= 0 and not digger:get_player_control().sneak) then
			minetest.chat_send_player(digger:get_player_name(),S("This compressor has material in it! You won't get it back if you destroy this. Please sneak while mining to confirm!"))
			return false
		else
			return minetest.node_dig(pos, node, digger)
		end
	end
})

minetest.register_node("finalite:singularity_merger", {
	description = S("Singularity Merger"),
	drawtype = "normal", --stupid minetest!!!!
	paramtype = "light",
	paramtype2 = "facedir",
	light_source = 4,
	tiles = {"finalite_finalite_block.png^finalite_hole.png","finalite_finalite_block.png","finalite_finalite_block.png^finalite_bl_side.png"},
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_int("item_count", 0)
		meta:set_string("infotext", S("Singularity Merger (@1/@2)", 0, singularity_count))
	end,

	on_rightclick = function(pos, node, puncher, itemstack, pointed_thing)
		if (puncher == nil) then
			return
		end
		if (not minetest.is_player(puncher)) then
			return
		end
		local meta = minetest.get_meta(pos)
		
		local held_item = minetest.registered_items[itemstack:get_name()]

		if (held_item == nil) then
			return itemstack
		end

		if (held_item.groups["f_singularity"] == 1) then
			if (meta:get_int("has_" .. held_item.description) ~= 1) then
				meta:set_int("item_count", meta:get_int("item_count") + 1)
				meta:set_int("has_" .. held_item.description, 1)
				meta:set_string("infotext", S("Singularity Merger (@1/@2)", meta:get_int("item_count"), singularity_count))
				itemstack:take_item(1)
				if (meta:get_int("item_count") == singularity_count) then
					minetest.add_item({x = pos.x, y = pos.y + 1, z = pos.z},"finalite:blackhole")
					local node = minetest.get_node(pos)
					minetest.set_node(pos,{name="finalite:singularity_merger", param2 = node.param2})
					minetest.sound_play("finalite_blackhole_creation", { pos = pos, max_hear_distance = 16, gain = 0.9, })
				end
				return itemstack
			end
		end

		return itemstack

	end,

	on_dig = function(pos, node, digger)
		if (digger == nil) then
			return minetest.node_dig(pos, node, digger)
		end
		if (digger:get_player_name() == "") then
			return minetest.node_dig(pos, node, digger)
		end
		local meta = minetest.get_meta(pos)
		local item_amount = meta:get_int("item_count")
		
		if (item_amount ~= 0 and not digger:get_player_control().sneak) then
			minetest.chat_send_player(digger:get_player_name(),S("This Singulartor Merger has material in it! You won't get it back if you destroy this. Please sneak while mining to confirm!"))
			return false
		else
			return minetest.node_dig(pos, node, digger)
		end
	end
})

minetest.register_craft({
		
	output = "finalite:compressor",
	recipe = {
		{"finalite:finalite_block","","finalite:finalite_block"},
		{"default:mese","","default:mese"},
		{"finalite:finalite_block","finalite:finalite_block","finalite:finalite_block"},
	}
})

minetest.register_craft({
		
	output = "finalite:singularity_merger",
	recipe = {
		{"finalite:finalite_block","group:f_singularity","finalite:finalite_block"},
		{"finalite:finalite_block","group:f_singularity","finalite:finalite_block"},
		{"finalite:finalite_block","finalite:finalite_block","finalite:finalite_block"},
	}
})


bens_gear.add_ore({
	internal_name = "finalite_blackingot",
	display_name = S("Black Ingot"),
	item_name = "finalite:blackhole_ingot",
	max_drop_level = 3,
	damage_groups_any = {fleshy=20},
	damage_groups_sword = {fleshy=100},
	damage_groups_axe = {fleshy=80},
	full_punch_interval = 0.2,
	uses = 3000,
	flammable = false,
	groupcaps = { --the groupcaps for the tool. durability is typically used instead of "uses" so there is no need to define it
		crumbly = {times={[1]=0.1, [2]=0.07, [3]=0.045}, maxlevel=3},
		cracky = {times={[1]=0.1, [2]=0.07, [3]=0.045}, maxlevel=3},
		choppy = {times={[1]=0.1, [2]=0.07, [3]=0.045}, maxlevel=3},
		snappy = {times={[1]=0.1, [2]=0.07, [3]=0.045}, maxlevel=3},
	
	},
	tool_list = {
	--"pickaxe"
	},
	tool_list_whitelist = false, --if this is true, then tool_list should act like a whitelist, otherwise, it'll act like a blacklist
	color = "000000",
	tool_textures = {
		default_alias = "metal", --what to append to the end of the default texture name, example: "bens_gear_axe_" would become "bens_gear_axe_metal"
		--pickaxe = {"bens_gear_pick_wood.png",true} --use a custom texture for pickaxes, you can add more for other tools
	},
	misc_data = {magic=50}, --here you can store various other weird stats for other mods to utilize, the only stat that is officially supported at the moment is "magic"
	additional_functions = { --a list of additional functions that'll be called upon certain conditions. This is here so that custom tools don't have to have support manually added.
		node_mined = nil,
		tool_destroyed = nil,
		tool_attempt_place = nil,
	},
	pre_finalization_function = nil --this function should be called RIGHT BEFORE the tool/item/whatever gets created, so that the material can add its own custom handling/data
	--it should be called like this: func(tool_id,data)
})

minetest.register_craftitem("finalite:infinite_range", {
	description = S("Infinite Range Upgrade") .. "\n" .. S("Bend space time itself and get close to infinite mining range."),
	short_description = S("Infinite Range Upgrade"),
	inventory_image = "finalite_bh_upgrade_small.png"
})

minetest.register_craft({
		
	output = "finalite:infinite_range",
	recipe = {
		{"finalite:default_mese_singularity","finalite:default_diamond_singularity","finalite:default_mese_singularity"},
		{"finalite:default_diamond_singularity","finalite:blackhole","finalite:default_diamond_singularity"},
		{"finalite:default_mese_singularity","finalite:default_diamond_singularity","finalite:default_mese_singularity"},
	}
})


bens_gear.add_charm({
	item_name = "finalite:infinite_range", --charms use already existing items.
	charm_name = "finalite_infinite", --for creating IDs
	exclusive = false, --if false, mods are allowed to use this charm even if not explicitly supported. (EX: a super axe using an axe charm if this is off, if this is on then the axe won't use this charm)
	valid_tools = { --the charm can only be applied to the following tools
		pickaxe = "finalite_bh_upgrade.png",
		axe = "finalite_bh_upgrade.png",
		shovel = "finalite_bh_upgrade.png",
		hoe = "finalite_bh_upgrade.png"
	},
	charm_function = function(tool_type,tool_data,ore_data,rod_data)
		tool_data.range = 9999
	end
	
})