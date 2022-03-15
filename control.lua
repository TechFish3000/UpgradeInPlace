
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
-- 		{building, upgrade sprite associated}
-- 	}

-- }

--
-- Mod functions
-- 

-- when an entity is mined
function entitymined(event)
	-- assign the player index
	local pid = event.player_index
	-- and the queue
	local playerupgradequeue = global.UIPtobeupgraded[pid]
	-- if the queue is not empty
	if (#playerupgradequeue > 0) then
		for key1, entspritetable in ipairs(playerupgradequeue) do
			if entspritetable[1] == event.entity then

				rendering.destroy(entspritetable[2])
				table.remove(global.UIPtobeupgraded[pid], key1)

			end
		end
	end	

end


function canceledcraft(event)
	local pid = event.player_index
	local playerupgradequeue = global.UIPtobeupgraded[pid]

	--game.players[pid].print(event.recipe.name)

	if (#playerupgradequeue > 0) then
		for key1, entspritetable in ipairs(playerupgradequeue) do
			if event.recipe.name == entspritetable[1].prototype.next_upgrade.items_to_place_this[1].name then
				
				rendering.destroy(entspritetable[2])
				table.remove(global.UIPtobeupgraded[pid], key1)

			end
		end
	end	


end



function checkcraftingqueueempty(event)

	
	-- for every player
	for playerIndex, player in pairs(game.players) do
        -- for every item in their upgrade queue
		for k, entspritetable in ipairs(global.UIPtobeupgraded[playerIndex]) do
			-- if the entity is no longer valid
			if (not entspritetable[1].valid) then

				rendering.destroy(entspritetable[2])
				-- remove it from the table
				table.remove(global.UIPtobeupgraded[playerIndex], k)
			-- otherwise
			else
				-- if the player is not crafting anything and has the items needed to craft the next upgrade item
				if (player.crafting_queue_size == 0 and player.get_craftable_count(entspritetable[1].prototype.next_upgrade.items_to_place_this[1].name) > 0) then
					-- begin crafting the item
					player.begin_crafting{ count = 1 , recipe = entspritetable[1].prototype.next_upgrade.items_to_place_this[1].name}
				end
			end
		end
	end
end




-- function checkTableIntegrity(playind)
-- 	if (global.UIPtobeupgraded[playind] == nil) then
-- 		global.UIPtobeupgraded[playind] = {}
-- 		log("created tobeupgraded table for player ".. playind)
-- 	end
-- 	if (global.UIPdebts[playind] == nil) then
-- 		global.UIPdebts[playind] = {}
-- 		log("created player " .. playind .. " index table in debts")
-- 	end
	


-- end

function checkTableIntegrity(command)
	--game.players[command.player_index].print("Checking table integrity...")
	
	-- to be upgraded table
	if (global.UIPtobeupgraded == nil) then
		global.UIPtobeupgraded = {}
		log("created tobeupgraded table")
	end


	-- item debts table
	if (global.UIPdebts == nil) then
		global.UIPdebts = {}
		log("created debts table")
	end


	-- upgrades table for current player
	if (global.UIPtobeupgraded[command.player_index] == nil) then
		global.UIPtobeupgraded[command.player_index] = {}
		log("created tobeupgraded table for player ".. command.player_index)
		--game.players[command.player_index].print("created tobeupgraded table for player ".. command.player_index)
	end
	-- item debts table for current player
	if (global.UIPdebts[command.player_index] == nil) then
		global.UIPdebts[command.player_index] = {}
		log("created player " .. command.player_index .. " index table in debts")
		--game.players[command.player_index].print("created player " .. command.player_index .. " index table in debts")
	end
	-- if (global.UIPsprites[command.player_index] == nil) then
	-- 	global.UIPsprites[command.player_index] = {}
	-- 	log("created sprites table for player " ..command.player_index)
	-- end


end

function init() 

	checkTableIntegrity({player_index = 1})

end 


function invupdated(event)

	-- assign the player index
	local playerIndex = event.player_index

	-- assign the player
	local player = game.players[playerIndex]
	
	-- check the tables of upgrade queue and other are existing and correct
	checkTableIntegrity(event)
	
	-- if the player has debts
	if (#global.UIPdebts[playerIndex] > 0) then
		-- for every debt
		for key, item in ipairs(global.UIPdebts[playerIndex]) do
			-- if the player has at least one of the item
			if (player.get_item_count(item.name) > 0) then
				-- remove it from their inventory
				player.remove_item(item)
				-- remove it from debts
				table.remove(global.UIPdebts[playerIndex], key)
			end
		end
	end

	
	if (#global.UIPtobeupgraded[playerIndex] > 0) then
		for key, entspritetable in ipairs(global.UIPtobeupgraded[playerIndex]) do

			local ent = entspritetable[1]
			if (not ent.valid) then

				rendering.destroy(entspritetable[2])
				table.remove(global.UIPtobeupgraded[playerIndex], key)
				
			
			else 
				if (player.get_item_count(ent.prototype.next_upgrade.items_to_place_this[1].name) > 0) then 
					player.remove_item({name = ent.prototype.next_upgrade.items_to_place_this[1].name, count = 1})
					
					local giveitem = ent.prototype.items_to_place_this[1]
					-- local pos = selEnt.position
					-- local recip = selEnt.get_recipe()
					-- selEnt.destroy();
					--if (recip == nil) then
					--selEnt.destroy()
					--local clone = table.deepcopy(selEnt)
					
					local newent = game.players[playerIndex].surface.create_entity{
						name = ent.prototype.next_upgrade.name,
						position = {ent.position.x, ent.position.y},
						direction = ent.direction,
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

					rendering.destroy(entspritetable[2])

					table.remove(global.UIPtobeupgraded[playerIndex], key)
				end
			end
		end
	end
end



function playerTriedUpgrading(event)
	-- if the event was actually the upgrade in place keybind
	if (event.input_name == "upgrade-in-place") then
		-- assign the player index
		local playInd = event.player_index
		-- check which entity is selected, this is the target
		local selEnt = game.players[playInd].selected

		-- if there actually is something selected in the cursor
		if (not (selEnt == nil)) then
			-- assign up the value of the next upgrade
			local up = selEnt.prototype.next_upgrade
			-- if there is an upgrade
			if (not (up == nil)) then
				-- if the player in question has the items to upgrade immediately
				if (game.players[playInd].get_main_inventory().get_item_count(up.items_to_place_this[1].name) > 0) then
					-- item to give back (the current entity)
					local giveitem = selEnt.prototype.items_to_place_this[1]
					-- create a new entity with much the same parameters
					local newent = game.players[playInd].surface.create_entity{
						name = up.name,
						position = {selEnt.position.x, selEnt.position.y},
						direction = selEnt.direction,
						force = game.players[playInd].force,
						fast_replace = true,
						--player = game.players[playInd],
						spill = false
						}
					
					-- if the player can pick up the result
					if (game.players[playInd].can_insert({name = giveitem.name, count = 1})) then
						-- insert the result
						game.players[playInd].insert({name = giveitem.name, count = 1})

					else
						-- otherwise spill it on the floor, but never on a conveyor
						game.players[playInd].surface.spill_item_stack(newent.position,{name = giveitem.name, count = 1}, true, game.players[playInd].force, false)
					end
					
					-- debit the player the item needed to place the upgrade
					table.insert(global.UIPdebts[playInd], up.items_to_place_this[1])
				else
					-- otherwise we need to craft an item
					

					
					-- if the materials to craft it are present
					if (game.players[playInd].get_craftable_count(up.items_to_place_this[1].name) > 0) then
						-- begin crafting
						game.players[playInd].begin_crafting{count = 1, recipe = up.items_to_place_this[1].name}
						-- create an upgrade sprite attached
						
						-- make sure the upgrade queues are correct and existing
						checkTableIntegrity({player_index = playInd})


						local renderID = rendering.draw_sprite{sprite = "UIPupgrade", target = selEnt, surface = selEnt.surface, forces = {selEnt.force}, x_scale = 0.02, y_scale = 0.02}
						-- insert it onto the upgrade queue
						local newtable = {
							[1] = selEnt,[2] = renderID
						}
						
						table.insert(global.UIPtobeupgraded[playInd], newtable)
					end 



				end


			end
		end
	end
end

--
-- Player Info Commands
-- 

function printglobals(command)
	game.players[command.player_index].print(serpent.block(global))
	log(serpent.block(global))
end

commands.add_command("checkTableIntegrity", "for UIP, checks and fixes broken global tables", checkTableIntegrity)
commands.add_command("reinit", "for UIP, re-runs init function, if something messed up", init)
commands.add_command("UIPprintglobs", "for UIP, prints out data currently in global", printglobals)
commands.add_command("UIPclearglobs", "for UIP, clears the global table", function(command)
	global.UIPdebts = nil
	global.UIPtobeupgraded = nil
	game.players[command.player_index].print("cleared")
end)



-- 
-- Script Event Handles (is that the right term?)
-- 

-- on init, construct tables
script.on_init(init)
-- on key pressed, try triggering upgrade
script.on_event("upgrade-in-place", playerTriedUpgrading)
-- when inventory changed, check for debts
script.on_event(defines.events.on_player_main_inventory_changed, invupdated)
-- when an entity is mined, check it wasn't currently being upgraded
script.on_event(defines.events.on_player_mined_entity, entitymined)
-- when crafting is cancelled, check if it was the upgrade item needed
script.on_event(defines.events.on_player_cancelled_crafting, canceledcraft)
-- every five ticks, check if crafting needs to be done but currently isn't
script.on_nth_tick(5,checkcraftingqueueempty )

