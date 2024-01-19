--[[
FixRepairTools
tes3mp 0.8.1
------------
INSTALLATION :
Edits to customScripts.lua add in :
require("custom.FixRepairTools")
]]

local PlayersUseTool = {}

local function GetName(pid)
	return string.lower(Players[pid].accountName)
end

local RepairToolsTable = {
	["repair_prongs"] = 25,
	["hammer repair"] = 20,
	["repair_journeyman_01"] = 20,
	["repair_master_01"] = 10,
	["repair_grandmaster_01"] = 10,
	["repair_secretmaster_01"] = 10	
}

local function SaveChargeTool(pid, item)
	local index = inventoryHelper.getItemIndex(Players[pid].data.inventory, item.refId, item.charge, item.enchantmentCharge, item.soul)
	if index then
		if Players[pid].data.inventory[index].count > 1 then
			local oldItem = {
				refId = item.refId,
				count = 1,
				charge = item.charge,
				enchantmentCharge = item.enchantmentCharge,
				soul = item.soul
			}
			Players[pid].data.inventory[index].count = Players[pid].data.inventory[index].count - 1	
			Players[pid]:LoadItemChanges({oldItem}, enumerations.inventory.REMOVE)	
			if item.charge == -1 then
				item.charge = RepairToolsTable[item.refId]
			end
			local newItem = {
				refId = item.refId,
				count = 1,
				charge = item.charge - 1,
				enchantmentCharge = item.enchantmentCharge,
				soul = item.soul
			}
			local newIndex = inventoryHelper.getItemIndex(Players[pid].data.inventory, newItem.refId, newItem.charge, newItem.enchantmentCharge, newItem.soul)	
			if newIndex then
				newItem.count = Players[pid].data.inventory[newIndex].count + 1
				Players[pid]:LoadItemChanges({Players[pid].data.inventory[newIndex]}, enumerations.inventory.REMOVE)				
				Players[pid].data.inventory[newIndex] = nil
				tableHelper.cleanNils(Players[pid].data.inventory)
			end	
			table.insert(Players[pid].data.inventory, newItem)			
			Players[pid]:LoadItemChanges({newItem}, enumerations.inventory.ADD)				
			PlayersUseTool[GetName(pid)] = newItem				
		else
			if item.charge == -1 then
				item.charge = RepairToolsTable[item.refId]
			end		
			Players[pid].data.inventory[index].charge = item.charge - 1
			PlayersUseTool[GetName(pid)] = tableHelper.deepCopy(Players[pid].data.inventory[index])		
		end	
		logicHandler.RunConsoleCommandOnPlayer(pid, 'player->Equip, "'..item.refId..'"')	
	end	
end

customEventHooks.registerHandler("OnPlayerItemUse", function(eventStatus, pid, itemRefId)
	local PlayerName = GetName(pid)
	if RepairToolsTable[string.lower(itemRefId)] then
		local item = {
			refId = itemRefId,
			count = tes3mp.GetUsedItemCount(pid),
			charge = tes3mp.GetUsedItemCharge(pid),
			enchantmentCharge = tes3mp.GetUsedItemEnchantmentCharge(pid),
			soul = tes3mp.GetUsedItemSoul(pid)
		}
		local index = inventoryHelper.getItemIndex(Players[pid].data.inventory, item.refId, item.charge, item.enchantmentCharge, item.soul)
		if index then
			PlayersUseTool[PlayerName] = item
		end
	else
		if PlayersUseTool[PlayerName] then 
			PlayersUseTool[PlayerName] = nil
		end
	end
end)

customEventHooks.registerHandler("OnObjectSound", function(eventStatus, pid, cellDescription, objects, targetPlayers)
	for targetPid, targetPlayer in pairs(targetPlayers) do
		local PlayerName = GetName(targetPid)
		if PlayersUseTool[PlayerName] and targetPlayer.soundId then
			if string.lower(targetPlayer.soundId) == "repair" or string.lower(targetPlayer.soundId) == "repair fail" then 
				SaveChargeTool(targetPid, PlayersUseTool[PlayerName])
			end
		end
	end
end)
