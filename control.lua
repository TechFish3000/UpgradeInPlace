
function playPrint(txt, ind)
	game.players[ind].print(txt)

end



function playerTriedUpgrading(event)
	if (event.input_name == "upgrade-in-place") then
		
		local playInd = event.player_index
		--playPrint("yes", playInd)
		local selEnt = game.players[playInd].selected

		if (not (selEnt == nil)) then
			
			local up = selEnt.prototype.next_upgrade
			if (not (up == nil)) then
				


				if (game.players[playInd].get_main_inventory().get_item_count(up.items_to_place_this[1].name) > 0) then
					local giveitem = selEnt.prototype.items_to_place_this[1]
					-- local pos = selEnt.position
					-- local recip = selEnt.get_recipe()
					-- selEnt.destroy();
					--if (recip == nil) then
					--selEnt.destroy()
					--local clone = table.deepcopy(selEnt)
					
					local newent = game.players[playInd].surface.create_entity{
						name = up.name,
						position = {selEnt.position.x, selEnt.position.y},
						direction = selEnt.direction,
						force = game.players[playInd].force,
						fast_replace = true,
						--player = game.players[playInd],
						spill = false
						}
					--else
					if (game.players[playInd].can_insert({name = giveitem.name, count = 1})) then
						game.players[playInd].insert({name = giveitem.name, count = 1})

					else
						game.players[playInd].surface.spill_item_stack(newent.position,{name = giveitem.name, count = 1}, true, game.players[playInd].force, false)
					end
					--newent.remove_item({name = selEnt.items_to_place_this[1].name, count = 1})
					selEnt.destroy()
					
				end


			end
		end
	end
end


script.on_event("upgrade-in-place", playerTriedUpgrading)

