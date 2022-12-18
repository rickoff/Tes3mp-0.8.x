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
local NpcBarterList = jsonInterface.load("custom/PreventMerchantEquipList.json")

--------------
-- FUNCTION --
--------------
local function LoadData()

	NpcBarterList = jsonInterface.load("custom/PreventMerchantEquipList.json")	
	
end

local function SaveData()

	jsonInterface.save("custom/PreventMerchantEquipList.json", NpcBarterList)
	
	LoadData()
	
end

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
		local ObjetDialogueType
		
		for _, object in pairs(objects) do
			ObjectIndex = object.uniqueIndex
			ObjetDialogueType = tableHelper.getIndexByValue(enumerations.dialogueChoice, object.dialogueChoiceType)
		end	
		
		if ObjectIndex and ObjetDialogueType then
			
			if ObjetDialogueType == "BARTER" then
			
				if not GetIndexBarter(ObjectIndex) then
					
					NpcBarterList[ObjectIndex] = true
					
					SaveData()
					
				end
				
			end
			
		end
	end
end

PreventMerchantEquipFix.OnActorEquipment = function(eventStatus, pid, cellDescription, actors)

	if Players[pid] and Players[pid]:IsLoggedIn() then
		
		for _, actor in pairs(actors) do
		
			local ActorIndex = actor.uniqueIndex
	
			if ActorIndex then
				
				if NpcBarterList[ActorIndex] then

					LoadedCells[cellDescription]:LoadActorEquipment(pid, LoadedCells[cellDescription].data.objectData, {ActorIndex})
				
					return customEventHooks.makeEventStatus(false, false)	
					
				end
				
			end
			
		end
		
	end
	
end

PreventMerchantEquipFix.OnServerPostInit = function(eventStatus)

	if NpcBarterList == nil then
	
		NpcBarterList = {}
		
		SaveData()
		
	end
	
end

------------
-- EVENTS --
------------
customEventHooks.registerHandler("OnObjectDialogueChoice", PreventMerchantEquipFix.OnObjectDialogueChoice)

customEventHooks.registerHandler("OnServerPostInit", PreventMerchantEquipFix.OnServerPostInit)

customEventHooks.registerValidator("OnActorEquipment", PreventMerchantEquipFix.OnActorEquipment)

return PreventMerchantEquipFix
