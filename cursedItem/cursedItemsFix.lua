--[[
cursedItemsFix
tes3mp 0.8.1
---------------------------
DESCRIPTION :
When picking up a cursed item, the curse is triggered but the item is converted 
into its normal non-cursed version to prevent constant summoning of cursed item creatures.
---------------------------
INSTALLATION:
Save the file as cursedItemsFix.lua inside your server/scripts/custom folder.
Edits to customScripts.lua add in : require("custom.cursedItemsFix")
]]

local itemCursedList = {
	["ingred_cursed_daedras_heart_01"] = "ingred_daedras_heart_01",
	["ingred_dae_cursed_diamond_01"] = "ingred_diamond_01",
	["ebony broadsword_dae_cursed"] = "ebony broadsword",
	["ingred_dae_cursed_emerald_01"] = "ingred_emerald_01",
	["fiend spear_dae_cursed"] = "fiend spear",
	["glass dagger_dae_cursed"] = "glass dagger",
	["imperial helmet armor_dae_curse"] = "imperial helmet armor",
	["ingred_dae_cursed_pearl_01"] = "ingred_pearl_01",
	["ingred_dae_cursed_raw_ebony_01"] = "ingred_raw_ebony_01",
	["ingred_dae_cursed_ruby_01"] = "ingred_ruby_01",
	["light_com_dae_cursed_candle_10"] = "light_com_candle_16",
	["misc_dwrv_cursed_coin00"] = "misc_dwrv_coin00",
	["silver dagger_hanin cursed"] = "ancient silver dagger noncursed",
	["misc_com_bottle_14_float"] = "misc_com_bottle_14",
	["misc_com_bottle_07_float"] = "misc_com_bottle_07"
 }

local function AddObjectInventoryPlayer(pid, item)	
	local indexLoc = inventoryHelper.getItemIndex(Players[pid].data.inventory, item.refId, item.charge, item.enchantmentCharge, item.soul)
	if indexLoc then	
		if Players[pid].data.inventory[indexLoc].count then			
			Players[pid].data.inventory[indexLoc].count = Players[pid].data.inventory[indexLoc].count + item.count			
		else		
			Players[pid].data.inventory[indexLoc].count = item.count			
		end	
	else		
		table.insert(Players[pid].data.inventory, item)			
	end
	Players[pid]:LoadItemChanges({item}, enumerations.inventory.ADD)	
end

local function RemoveObjectInventoryPlayer(pid, item)		
	local indexLoc = inventoryHelper.getItemIndex(Players[pid].data.inventory, item.refId, item.charge, item.enchantmentCharge, item.soul)	
	if indexLoc then	
		if Players[pid].data.inventory[indexLoc].count then			
			Players[pid].data.inventory[indexLoc].count = Players[pid].data.inventory[indexLoc].count - item.count					
		end	
		if Players[pid].data.inventory[indexLoc].count <= 0 then
			Players[pid].data.inventory[indexLoc] = nil				
			tableHelper.cleanNils(Players[pid].data.inventory)
		end	
		Players[pid]:LoadItemChanges({item}, enumerations.inventory.REMOVE)			
		return true			
	else		
		return false			
	end	
end

customEventHooks.registerHandler("OnPlayerInventory", function(eventStatus, pid)
	local action = tes3mp.GetInventoryChangesAction(pid)	
	local itemChangesCount = tes3mp.GetInventoryChangesSize(pid)
	for index = 0, itemChangesCount - 1 do	
		local itemRefId = tes3mp.GetInventoryItemRefId(pid, index)
		if itemRefId and itemRefId ~= "" then		
			if action == enumerations.inventory.SET or action == enumerations.inventory.ADD then			
				if itemCursedList[string.lower(itemRefId)] then
					local item = {
						refId = itemRefId,
						count = tes3mp.GetInventoryItemCount(pid, index),
						charge = tes3mp.GetInventoryItemCharge(pid, index),
						enchantmentCharge = tes3mp.GetInventoryItemEnchantmentCharge(pid, index),
						soul = tes3mp.GetInventoryItemSoul(pid, index)
					}				
					RemoveObjectInventoryPlayer(pid, item)
					local newItem = {
						refId = itemCursedList[string.lower(itemRefId)],
						count = item.count,
						charge = item.charge,
						enchantmentCharge = item.enchantmentCharge,
						soul = item.soul
					}
					AddObjectInventoryPlayer(pid, newItem)					
				end
			end
		end
	end
end)
