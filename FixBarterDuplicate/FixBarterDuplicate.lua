--[[
FixBarterDuplicate
tes3mp 0.8.1
---------------------------
INSTALLATION:
Save the file as FixBarterDuplicate.lua inside your server/scripts/custom folder.
Edits to customScripts.lua :
require("custom.FixBarterDuplicate")
---------------------------
]]

local tempBarter = {}
local tempPlayers = {}

local function GetName(pid)
	if Players[pid] then
		return string.lower(Players[pid].accountName)
	end
end

local function CheckInventoryActorItem(pid, uniqueIndex, inventory)
	local rejected = false
	local rejectedItems = {}
	if tempBarter[uniqueIndex] then
		local inventoryActor = tempBarter[uniqueIndex]
		for _, item in pairs(inventory) do
			if item.refId ~= "gold_001" then
				local itemIndex = inventoryHelper.getItemIndex(inventoryActor, item.refId, item.charge, item.enchantmentCharge, item.soul)
				if inventoryActor[itemIndex] and inventoryActor[itemIndex].count >= item.count then
					inventoryActor[itemIndex].count = inventoryActor[itemIndex].count - item.count
					if inventoryActor[itemIndex].count == 0 then
						inventoryActor[itemIndex] = nil
					end
				else
					rejected = true
					table.insert(rejectedItems, item)
				end
			end
		end
	end	
	return rejected, rejectedItems
end

customEventHooks.registerHandler("OnObjectActivate", function(eventStatus, pid, cellDescription, objects)	
	if tempPlayers[GetName(pid)] then
		tempPlayers[GetName(pid)] = nil
	end
end)

customEventHooks.registerHandler("OnObjectDialogueChoice", function(eventStatus, pid, cellDescription, objects)
	for _, object in pairs(objects) do
		if object.refId and object.uniqueIndex and object.dialogueChoiceType == enumerations.dialogueChoice.BARTER then
			tempPlayers[GetName(pid)] = object.uniqueIndex
			tempBarter[object.uniqueIndex] = tableHelper.deepCopy(LoadedCells[cellDescription].data.objectData[object.uniqueIndex].inventory)
		end
	end	
end)

customEventHooks.registerValidator("OnPlayerInventory", function(eventStatus, pid, playerPacket)
	local playerName = GetName(pid)	
	if playerPacket.action == enumerations.inventory.ADD and tempPlayers[playerName] then
		local rejected, rejectedItems = CheckInventoryActorItem(pid, tempPlayers[playerName], playerPacket.inventory)
		if rejected then
			Players[pid]:LoadItemChanges(rejectedItems, enumerations.inventory.REMOVE)
			return customEventHooks.makeEventStatus(false, false)			
		end
	end
end)
