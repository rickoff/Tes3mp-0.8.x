--[[
PreventMerchantEquipFix
tes3mp 0.8.1
---------------------------
DESCRIPTION :
Prevent Merchant Equip
---------------------------
INSTALLATION:
Save the file as PreventMerchantEquipFix.lua inside your server/scripts/custom folder.
Edits to customScripts.lua add in : require("custom.PreventMerchantEquipFix")
---------------------------
]]
local NpcBarterList

local function LoadData()
	NpcBarterList = jsonInterface.load("custom/PreventMerchantEquipList.json")		
end

local function SaveData()
	jsonInterface.quicksave("custom/PreventMerchantEquipList.json", NpcBarterList)	
end

local function GetIndexBarter(uniqueIndex)
	for actorRefId, actorIndex in pairs(NpcBarterList) do		
		if uniqueIndex == actorIndex then		
			return true		
		end		
	end
	return false	
end

customEventHooks.registerHandler("OnServerPostInit", function(eventStatus)
	LoadData()
	if not NpcBarterList then	
		NpcBarterList = {}		
		SaveData()		
	end	
end)

customEventHooks.registerHandler("OnObjectDialogueChoice", function(eventStatus, pid, cellDescription, objects)	
	for _, object in pairs(objects) do		
		local ObjetDialogueType = tableHelper.getIndexByValue(enumerations.dialogueChoice, object.dialogueChoiceType)
		if object.uniqueIndex and object.refId and ObjetDialogueType and ObjetDialogueType == "BARTER" then					
			if not NpcBarterList[object.refId] 
			or NpcBarterList[object.refId] and NpcBarterList[object.refId] ~= object.uniqueIndex then					
				NpcBarterList[object.refId] = object.uniqueIndex					
				SaveData()					
			end			
		end		
	end
end)

customEventHooks.registerValidator("OnActorEquipment", function(eventStatus, pid, cellDescription, actors)
	for _, actor in pairs(actors) do
		if actor.uniqueIndex and GetIndexBarter(actor.uniqueIndex) then
			LoadedCells[cellDescription]:LoadActorEquipment(pid, LoadedCells[cellDescription].data.objectData, {actor.uniqueIndex})			
			return customEventHooks.makeEventStatus(false, false)			
		end			
	end		
end)
