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

local tempBarters = {}
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

customEventHooks.registerValidator("OnObjectActivate", function(eventStatus, pid, cellDescription, objects) 
	for _, object in pairs(objects) do
		if object.uniqueIndex then 
			if object.activatingPid and tempPlayers[GetName(object.activatingPid)] then
				tempPlayers[GetName(object.activatingPid)] = nil
			end
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

customEventHooks.registerValidator("OnPlayerItemUse", function(eventStatus, pid, refId)
	local playerName = GetName(pid)	
	if tempPlayers[playerName] then
		tempPlayers[playerName] = nil
	end
end)

customEventHooks.registerHandler("OnObjectDialogueChoice", function(eventStatus, pid, cellDescription, objects)
	local playerName = GetName(pid)
	for _, object in pairs(objects) do
		if object.refId and object.uniqueIndex and object.dialogueChoiceType == enumerations.dialogueChoice.BARTER then
			tempPlayers[playerName] = {}
		end
	end	
end)

customEventHooks.registerValidator("OnPlayerInventory", function(eventStatus, pid, playerPacket)
	local playerName = GetName(pid)	
	local rejectedItem = {}
	if playerPacket.action == enumerations.inventory.ADD and tempPlayers[playerName] then
		for _, item in pairs(playerPacket.inventory) do
			if item.refId ~= "gold_001" then 
				table.insert(rejectedItem, item)
			end
		end
		tempPlayers[playerName] = rejectedItem				
		Players[pid]:LoadItemChanges(rejectedItem, enumerations.inventory.REMOVE)
		return customEventHooks.makeEventStatus(false, false)			
	end
end)

customEventHooks.registerValidator("OnContainer", function(eventStatus, pid, cellDescription, objects)
	local playerName = GetName(pid)	
	if not tempPlayers[playerName] then return end
	local authorizedItem
	for _, object in pairs(objects) do	
		local action = tes3mp.GetObjectListAction()				
		if action ~= enumerations.container.REMOVE then	return end		
		for containerIndex = 0, tes3mp.GetObjectListSize() - 1 do
			for itemIndex = 0, tes3mp.GetContainerChangesSize(containerIndex) - 1 do
				local item = {
					refId = tes3mp.GetContainerItemRefId(containerIndex, itemIndex),
					count = tes3mp.GetContainerItemCount(containerIndex, itemIndex),
					charge = tes3mp.GetContainerItemCharge(containerIndex, itemIndex),
					enchantmentCharge = tes3mp.GetContainerItemEnchantmentCharge(containerIndex, itemIndex),
					soul = tes3mp.GetContainerItemSoul(containerIndex, itemIndex)
				}
				for _, inv in pairs(tempPlayers[playerName]) do
					if inv.refId == item.refId
					and inv.count <= item.count
					and inv.charge == item.charge
					and inv.enchantmentCharge == item.enchantmentCharge
					and inv.soul == item.soul then					
						inventoryHelper.addItem(Players[pid].data.inventory, inv.refId, inv.count, inv.charge, inv.enchantmentCharge, inv.soul)
						if not authorizedItem then authorizedItem = {} end
						table.insert(authorizedItem, inv)
					end							
				end
			end
		end
	end
	if authorizedItem then
		Players[pid]:LoadItemChanges(authorizedItem, enumerations.inventory.ADD)	
	end
end)
