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
Edits to customScripts.lua add :
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
local function SaveData()
	jsonInterface.save("custom/PreventMerchantEquipList.json", NpcBarterList)	
end

-------------
-- METHODS --
-------------
local PreventMerchantEquipFix = {}

PreventMerchantEquipFix.OnObjectDialogueChoice = function(eventStatus, pid, cellDescription, objects)	
	local ObjectIndex
	local ObjetDialogueType
	for _, object in pairs(objects) do
		ObjectIndex = object.uniqueIndex
		ObjetDialogueType = tableHelper.getIndexByValue(enumerations.dialogueChoice, object.dialogueChoiceType)
	end	
	if ObjectIndex and ObjetDialogueType
	and ObjetDialogueType == "BARTER" and not NpcBarterList[ObjectIndex] then
		NpcBarterList[ObjectIndex] = true
		SaveData()
	end
end

PreventMerchantEquipFix.OnActorEquipment = function(eventStatus, pid, cellDescription, actors)		
	for _, actor in pairs(actors) do
		local ActorIndex = actor.uniqueIndex
		if ActorIndex and NpcBarterList[ActorIndex] then
			LoadedCells[cellDescription]:LoadActorEquipment(pid, LoadedCells[cellDescription].data.objectData, {ActorIndex})
			return customEventHooks.makeEventStatus(false, false)
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
customEventHooks.registerValidator("OnActorEquipment", PreventMerchantEquipFix.OnActorEquipment)
customEventHooks.registerHandler("OnObjectDialogueChoice", PreventMerchantEquipFix.OnObjectDialogueChoice)
customEventHooks.registerHandler("OnServerPostInit", PreventMerchantEquipFix.OnServerPostInit)

return PreventMerchantEquipFix
