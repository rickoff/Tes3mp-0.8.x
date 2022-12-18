--[[
PreventMerchantEquipFix
Rickoff
tes3mp 0.8.1
---------------------------
DESCRIPTION :
Prevent Merchant Equip
---------------------------
INSTALLATION:
Save the file as PreventMerchantEquipFix.lua inside your server/scripts/custom folder.
Edits to customScripts.lua
PreventMerchantEquipFix = require("custom.PreventMerchantEquipFix")
---------------------------
]]

--------------
-- VARIABLE --
--------------
local NpcBarterList = {}

--------------
-- FUNCTION --
--------------
local function GetIndexBarter(uniqueIndex)

	for actorIndex, bool in pairs(NpcBarterList) do
		
		if uniqueIndex == actorIndex then
		
			return true
			
		end
		
	end

	return false
	
end

-------------
-- METHODS --
-------------
local PreventMerchantEquipFix = {}

PreventMerchantEquipFix.OnObjectDialogueChoice = function(eventStatus, pid, cellDescription, objects)

	if Players[pid] and Players[pid]:IsLoggedIn() then
	
		local ObjectIndex
		local ObjectRefid
		local ObjetDialogueType
		
		for _, object in pairs(objects) do
			ObjectIndex = object.uniqueIndex
			ObjectRefid = object.refId
			ObjetDialogueType = tableHelper.getIndexByValue(enumerations.dialogueChoice, object.dialogueChoiceType)
		end	
		
		if ObjectIndex and ObjectRefid and ObjetDialogueType then
			
			if ObjetDialogueType == "BARTER" then
			
				if not GetIndexBarter(ObjectIndex) then
					
					NpcBarterList[ObjectIndex] = true
					
				end
				
			end
			
		end
	end
end

PreventMerchantEquipFix.OnActorEquipment = function(eventStatus, pid, cellDescription, actors)

	if Players[pid] and Players[pid]:IsLoggedIn() then

		local ActorIndex
		local ActorRefid
		
		for _, actor in pairs(actors) do
			ActorIndex = actor.uniqueIndex
			ActorRefid = actor.refId
		end	

		print(ActorIndex)
		
		if NpcBarterList[ActorIndex] then

			LoadedCells[cellDescription]:LoadActorEquipment(pid, LoadedCells[cellDescription].data.objectData, {ActorIndex})

			return customEventHooks.makeEventStatus(false, false)	
			
		end
		
	end
	
end

------------
-- EVENTS --
------------
customEventHooks.registerHandler("OnObjectDialogueChoice", PreventMerchantEquipFix.OnObjectDialogueChoice)

customEventHooks.registerValidator("OnActorEquipment", PreventMerchantEquipFix.OnActorEquipment)

return PreventMerchantEquipFix
