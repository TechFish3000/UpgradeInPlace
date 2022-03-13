
function playPrint(txt, ind)
	game.players[ind].print(txt)

end



-- so
-- when you try to upgrade something but dont have it but do have the resources
-- begin crafting, mark that peice
-- if crafting is cancelled, unmark the peice
-- if crafting is finished, upgrade it
-- check if crafting recipe needs the old item, give if so, else dont
-- and if it did need it earlier take the extra away again

-- debts{
-- 		playerid{
--			{names of items}
--      }
-- }


-- tobeupgraded {
-- 	playerid{
-- 		itemneeded{
-- 			buildings,
-- 		}
-- 	}

-- }

-- global.UIPdebts = {}
-- global.UIPtobeupgraded = {}

function printglobals(command)

	game.players[command.player_index].print(serpent.block(global))
	log(serpent.block(global))
end

function checkTableIntegrity(playind)
	if (global.UIPtobeupgraded[playind] == nil) then
		global.UIPtobeupgraded[playind] = {}
		log("created tobeupgraded table for player ".. playind)
	end
	if (global.UIPdebts[playind] == nil) then
		global.UIPdebts[playind] = {}
		log("created player " .. playind .. " index table in debts")
	end


end

function checkTableIntegrityCmd(command)
	game.players[command.player_index].print("Checking table integrity...")
	
	if (global.UIPtobeupgraded == nil) then
		global.UIPtobeupgraded = {}
		log("created tobeupgraded table")
	end
	
	if (global.UIPdebts == nil) then
		global.UIPdebts = {}
		log("created debts table")
	end

	if (global.UIPtobeupgraded[command.player_index] == nil) then
		global.UIPtobeupgraded[command.player_index] = {}
		log("created tobeupgraded table for player ".. command.player_index)
		game.players[command.player_index].print("created tobeupgraded table for player ".. command.player_index)
	end
	if (global.UIPdebts[command.player_index] == nil) then
		global.UIPdebts[command.player_index] = {}
		log("created player " .. command.player_index .. " index table in debts")
		game.players[command.player_index].print("created player " .. command.player_index .. " index table in debts")
	end


end

function init() 
	--for i in game.players


	if (global.UIPtobeupgraded == nil) then
		global.UIPtobeupgraded = {}
		log("created tobeupgraded table")
	end
	
	if (global.UIPdebts == nil) then
		global.UIPdebts = {}
		log("created debts table")
	end


	if (global.UIPtobeupgraded[1] == nil) then
		global.UIPtobeupgraded[1] = {}
		log("created tobeupgraded table for player 1")
	end
	if (global.UIPdebts[1] == nil) then
		global.UIPdebts[1] = {}
		log("created player 1 index table in debts")
	end

	game.player.print(global.UIPdebts == nil)
	log(serpent.block(global.UIPdebts[playInd]))

end 


function invupdated(event)
	local playerIndex = event.player_index
	local player = game.players[playerIndex]
	
	checkTableIntegrity(event.player_index)
	
	
	
	
	if (#global.UIPdebts[playerIndex] > 0) then
		for k, v in ipairs(global.UIPdebts[playerIndex]) do
			if (player.get_item_count(v.name) > 0) then
				player.remove_item(v)
				table.remove(global.UIPdebts[playerIndex], k)
			end

		end
	end

	
	if (#global.UIPtobeupgraded[playerIndex] > 0) then
		for k, v in ipairs(global.UIPtobeupgraded[playerIndex]) do

			if (player.get_item_count(v.prototype.next_upgrade.items_to_place_this[1].name) > 0) then
				player.remove_item({name = v.prototype.next_upgrade.items_to_place_this[1].name, count = 1})
				
				local giveitem = v.prototype.items_to_place_this[1]
				-- local pos = selEnt.position
				-- local recip = selEnt.get_recipe()
				-- selEnt.destroy();
				--if (recip == nil) then
				--selEnt.destroy()
				--local clone = table.deepcopy(selEnt)
				
				local newent = game.players[playerIndex].surface.create_entity{
					name = v.prototype.next_upgrade.name,
					position = {v.position.x, v.position.y},
					direction = v.direction,
					force = game.players[playerIndex].force,
					fast_replace = true,
					--player = game.players[playInd],
					spill = false
					}
				--else
				if (game.players[playerIndex].can_insert({name = giveitem.name, count = 1})) then
					game.players[playerIndex].insert({name = giveitem.name, count = 1})

				else
					game.players[playerIndex].surface.spill_item_stack(newent.position,{name = giveitem.name, count = 1}, true, game.players[playerIndex].force, false)
				end
				--newent.remove_item({name = selEnt.items_to_place_this[1].name, count = 1})
				--v.destroy()
				
				
				--table.insert(global.UIPdebts[playerIndex], v.prototype.next_upgrade.items_to_place_this[1])
				table.remove(global.UIPtobeupgraded[playerIndex], k)
			end

		end
	end
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
					--selEnt.destroy()
					
					
					table.insert(global.UIPdebts[playInd], up.items_to_place_this[1])

					-- global.UIPdebts[playInd][#global.UIPdebts[playInd + 1]] = up.items_to_place_this[1] 
				else
					
					-- local recips = {}

					-- for key, recip in ipairs(game.recipe_prototypes) do
					-- 	playPrint(key, playInd)
					-- 	if (recip.product.name == up.items_to_place_this[1].name) then
					-- 		table.insert(recips, recip.name)
					-- 	end
					-- end

					-- playPrint(serpent.block(game.recipe_prototypes`), playInd)
					
					
					-- local firstrecip = recips[1]
					
					-- if (global.UIPtobeupgraded == nil) then
					-- 	global.UIPtobeupgraded = {}
					-- end



					if (game.players[playInd].get_craftable_count(up.items_to_place_this[1].name) > 0) then
						game.players[playInd].begin_crafting{count = 1, recipe = up.items_to_place_this[1].name}
						game.players[playInd].print(selEnt.prototype.name)
						table.insert(global.UIPtobeupgraded[playInd], selEnt)
					end 



				end


			end
		end
	end
end

script.on_init(init)
script.on_event("upgrade-in-place", playerTriedUpgrading)
script.on_event(defines.events.on_player_main_inventory_changed, invupdated)
commands.add_command("checkTableIntegrity", "for UIP", checkTableIntegrityCmd)
commands.add_command("reinit", "for UIP", init)
commands.add_command("UIPprintglobs", "for UIP", printglobals)
commands.add_command("UIPclearglobs", "for uip", function(command)
global.UIPdebts = nil
global.UIPtobeupgraded = nil
game.players[command.player_index].print("cleared")

end)