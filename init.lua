symmetric_crafts = {}
symmetric_crafts.mod = {author = "Louis Royer", version = "1.0.0"}

minetest.register_on_mods_loaded(function()
	for _, item in pairs(minetest.registered_items) do
		local recipes = minetest.get_all_craft_recipes(item.name)
		if recipes then
			for i, recipe in ipairs(recipes) do
				if (recipe.method == "normal") and (recipe.width > 1) then
					local input = {method = "normal", width = recipe.width, items = {}}
					for pos, ritem in pairs(recipe.items) do
						local origin_col = (pos-1) % recipe.width
						local origin_row = ((pos-1) - origin_col) / recipe.width
						local dest_col = recipe.width - origin_col
						local dest_pos = (origin_row * recipe.width) + dest_col
						input.items[dest_pos] = ritem
					end
					if minetest.get_craft_result(input).item:is_empty()
						and not(minetest.get_item_group(item.name, "force_asymmetric_crafts") == 1) then
						local sym_recipe = {}
						for pos, ritem in pairs(input.items) do
							local col = ((pos-1) % recipe.width)
							local row = (((pos-1) - col) / recipe.width)
							if sym_recipe[row+1] == nil then
								sym_recipe[row+1] = {}
								for w=1,recipe.width do
									sym_recipe[row+1][w] = ""
								end
							end
							sym_recipe[row+1][col+1] = ritem
						end
						local output, dec_input = minetest.get_craft_result(recipe)
						local replacements = {}
						if dec_input then
							for pos, repl in pairs(dec_input.items) do
								if not repl:is_empty() then
									table.insert(replacements, {
										recipe.items[pos],
										repl:get_name()
										..((repl:get_count() > 1) and (" "..repl:get_count()) or "")
									})
								end
							end
						end
						local craft = {
							output = output.item:get_name()
								..((output.item:get_count() > 1) and (" "..output.item:get_count()) or ""),
							recipe = sym_recipe,
							replacements = replacements
						}
						minetest.register_craft(craft)
					end
				end
			end
		end
	end

end)
