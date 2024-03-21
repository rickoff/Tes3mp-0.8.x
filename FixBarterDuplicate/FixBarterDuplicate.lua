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
local tempActivate = {}

function OnObjectActivateTimer(uniqueIndex)
    tempActivate[uniqueIndex] = nil
end

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

customEventHooks.registerValidator("OnObjectActivate", function(eventStatus, pid, cellDescription, objects) 
	for _, object in pairs(objects) do
		if object.uniqueIndex then   
			if tempActivate[object.uniqueIndex] then
				return customEventHooks.makeEventStatus(false, false)
			else
				tempActivate[object.uniqueIndex] = true
				local timerActivate = tes3mp.CreateTimerEx("OnObjectActivateTimer", time.seconds(1), "s", object.uniqueIndex)
				tes3mp.StartTimer(timerActivate)
			end
		end
    end
end)

customEventHooks.registerHandler("OnObjectActivate", function(eventStatus, pid, cellDescription, objects)	
	for _, object in pairs(objects) do
		if object.activatingPid and tempPlayers[GetName(object.activatingPid)] then
			tempPlayers[GetName(object.activatingPid)] = nil
		end
	end
end)

customEventHooks.registerHandler("OnObjectDialogueChoice", function(eventStatus, pid, cellDescription, objects)
	for _, object in pairs(objects) do
		if object.refId and object.uniqueIndex and object.dialogueChoiceType == enumerations.dialogueChoice.BARTER then
			tempPlayers[GetName(pid)] = {
				uniqueIndex = object.uniqueIndex,
				inventory = {}
			}
			tempBarter[object.uniqueIndex] = tableHelper.deepCopy(LoadedCells[cellDescription].data.objectData[object.uniqueIndex].inventory)
		end
	end	
end)

customEventHooks.registerValidator("OnPlayerInventory", function(eventStatus, pid, playerPacket)
	local playerName = GetName(pid)	
	if playerPacket.action == enumerations.inventory.ADD and tempPlayers[playerName] then	
		local rejected, rejectedItems = CheckInventoryActorItem(pid, tempPlayers[playerName].uniqueIndex, playerPacket.inventory)
		if rejected then
			tempPlayers[playerName].inventory = rejectedItems				
			Players[pid]:LoadItemChanges(rejectedItems, enumerations.inventory.REMOVE)
			return customEventHooks.makeEventStatus(false, false)			
		end
	end
end)

customEventHooks.registerValidator("OnContainer", function(eventStatus, pid, cellDescription, objects)	
	for _, object in pairs(objects) do
		if object.uniqueIndex and tempBarter[object.uniqueIndex] then		
			local action = tes3mp.GetObjectListAction()				
			if action == enumerations.container.REMOVE then			
				for containerIndex = 0, tes3mp.GetObjectListSize() - 1 do
					for itemIndex = 0, tes3mp.GetContainerChangesSize(containerIndex) - 1 do
						local item = {
							refId = tes3mp.GetContainerItemRefId(containerIndex, itemIndex),
							count = tes3mp.GetContainerItemCount(containerIndex, itemIndex),
							charge = tes3mp.GetContainerItemCharge(containerIndex, itemIndex),
							enchantmentCharge = tes3mp.GetContainerItemEnchantmentCharge(containerIndex, itemIndex),
							soul = tes3mp.GetContainerItemSoul(containerIndex, itemIndex)
						}
						for _, inv in ipairs(tempPlayers[GetName(pid)].inventory) do
							if inv.refId == item.refId
							and inv.count == item.count
							and inv.charge == item.charge
							and inv.enchantmentCharge == item.enchantmentCharge
							and inv.soul == item.soul then
								inventoryHelper.addItem(Players[pid].data.inventory, item.refId, item.count, item.charge, item.enchantmentCharge, item.soul)
								Players[pid]:LoadItemChanges({item}, enumerations.inventory.ADD)								
							end
						end
					end
				end
			end
		end
	end
end)
