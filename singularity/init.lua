local S = minetest.get_translator()

local singluarity_needed = 1980

local singularity_count = 0

minetest.register_craftitem("singularity:singularity_examp", {
    description = S("A Singularity\nYou can't obtain this."),
    inventory_image = "singularity_singularity.png",
    groups = {f_singularity=1,not_in_creative_inventory=1}
})

bens_gear.add_ore_iterate(function(data)
	if (data.item_name ~= "singularity:blackhole_ingot") then
		minetest.register_craftitem(":singularity:" .. data.internal_name .. "_singularity", {
			description = S("@1 Singularity", data.display_name),
			inventory_image = "singularity_singularity.png^[multiply:#" .. data.color,
			groups = {f_singularity=1}
		})
		singularity_count = singularity_count + 1
	end
end)

minetest.register_craftitem("singularity:blackhole", {
	description = S("Black Hole") .. "\n" .. S("Incomprehensible."),
	short_description = S("Black Hole"),
	inventory_image = "singularity_blackhole.png",
	groups = {blackhole=1}
})

minetest.register_craftitem("singularity:blackhole_ingot", {
	description = S("Black Ingot") .. "\n" .. S("Incomprehensible."),
	short_description = S("Black Ingot"),
	inventory_image = "singularity_black_ingot.png",
	wield_scale = {x = 1.5, y = 1.5, z = 1},
	groups = {ingot=1}
})

minetest.register_craft({
		
	output = "singularity:blackhole_ingot 4",
	recipe = {
		{"finalite:finalite_ingot","singularity:blackhole","finalite:finalite_ingot"},
		{"singularity:blackhole","group:f_singularity","singularity:blackhole"},
		{"finalite:finalite_ingot","singularity:blackhole","finalite:finalite_ingot"},
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


minetest.register_node("singularity:compressor", {
	description = S("Compressor"),
	drawtype = "normal", --stupid minetest!!!!
	paramtype = "light",
	paramtype2 = "facedir",
	light_source = 4,
	tiles = {"finalite_finalite_block.png^singularity_hole.png","finalite_finalite_block.png","finalite_finalite_block.png^singularity_compressor_side.png"},
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
					minetest.add_item({x = pos.x, y = pos.y + 1, z = pos.z},"singularity:" .. SearchForInternalNameInOreRegister(mat) .. "_singularity")
					itemstack:set_count(meta:get_int("item_amount") - singluarity_needed)
					local node = minetest.get_node(pos)
					minetest.set_node(pos,{name="singularity:compressor", param2 = node.param2})
					minetest.sound_play("singularity_singularity_creation", { pos = pos, max_hear_distance = 16, gain = 1, })
					return itemstack
				else
					minetest.sound_play("singularity_singularity_add", { pos = pos, max_hear_distance = 16, gain = 0.75, })
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

minetest.register_node("singularity:singularity_merger", {
	description = S("Singularity Merger"),
	drawtype = "normal", --stupid minetest!!!!
	paramtype = "light",
	paramtype2 = "facedir",
	light_source = 4,
	tiles = {"finalite_finalite_block.png^singularity_hole.png","finalite_finalite_block.png","finalite_finalite_block.png^singularity_bl_side.png"},
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
					minetest.add_item({x = pos.x, y = pos.y + 1, z = pos.z},"singularity:blackhole")
					local node = minetest.get_node(pos)
					minetest.set_node(pos,{name="singularity:singularity_merger", param2 = node.param2})
					minetest.sound_play("singularity_blackhole_creation", { pos = pos, max_hear_distance = 16, gain = 0.9, })
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
		
	output = "singularity:compressor",
	recipe = {
		{"finalite:finalite_block","","finalite:finalite_block"},
		{"default:mese","","default:mese"},
		{"finalite:finalite_block","finalite:finalite_block","finalite:finalite_block"},
	}
})

minetest.register_craft({
		
	output = "singularity:singularity_merger",
	recipe = {
		{"finalite:finalite_block","group:f_singularity","finalite:finalite_block"},
		{"finalite:finalite_block","group:f_singularity","finalite:finalite_block"},
		{"finalite:finalite_block","finalite:finalite_block","finalite:finalite_block"},
	}
})


bens_gear.add_ore({
	internal_name = "singularity_blackingot",
	display_name = S("Black Ingot"),
	item_name = "singularity:blackhole_ingot",
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

minetest.register_craftitem("singularity:infinite_range", {
	description = S("Infinite Range Upgrade") .. "\n" .. S("Bend space time itself and get close to infinite mining range."),
	short_description = S("Infinite Range Upgrade"),
	inventory_image = "singularity_bh_upgrade_small.png"
})

minetest.register_craft({
		
	output = "singularity:infinite_range",
	recipe = {
		{"singularity:default_mese_singularity","singularity:default_diamond_singularity","singularity:default_mese_singularity"},
		{"singularity:default_diamond_singularity","singularity:blackhole","singularity:default_diamond_singularity"},
		{"singularity:default_mese_singularity","singularity:default_diamond_singularity","singularity:default_mese_singularity"},
	}
})


bens_gear.add_charm({
	item_name = "singularity:infinite_range", --charms use already existing items.
	charm_name = "singularity_infinite", --for creating IDs
	exclusive = false, --if false, mods are allowed to use this charm even if not explicitly supported. (EX: a super axe using an axe charm if this is off, if this is on then the axe won't use this charm)
	valid_tools = { --the charm can only be applied to the following tools
		pickaxe = "singularity_bh_upgrade.png",
		axe = "singularity_bh_upgrade.png",
		shovel = "singularity_bh_upgrade.png",
		hoe = "singularity_bh_upgrade.png"
	},
	charm_function = function(tool_type,tool_data,ore_data,rod_data)
		tool_data.range = 9999
	end
	
})