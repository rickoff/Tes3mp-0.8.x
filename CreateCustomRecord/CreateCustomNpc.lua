--[[
CreateCustomNpc
tes3mp 0.8.1
---------------------------
INSTALLATION:
Save the file as CreateCustomNpc.lua inside your server/scripts/custom folder.
Save the file as DataNpc.json inside your server/data/custom/DataBase folder.
Edits to customScripts.lua add : CreateCustomNpc = require("custom.CreateCustomNpc")
---------------------------
INSTRUCTIONS:
to modify a value of an npc such as name, modify the target in the file DataNpc.json
only the values contained in recordTable can be modified
]]

---------------
-- JSON-DATA --
---------------
local DataNpc = jsonInterface.load("custom/DataBase/DataNpc.json")

-------------
-- METHODS --
-------------
local CreateCustomNpc = {}
	
CreateCustomNpc.OnServerInit = function(eventStatus)
	local recordTable	
	local recordStoreNpc = RecordStores["npc"]

	for refId, slot in pairs(DataNpc) do
		recordTable = {
		  baseId = slot.baseId,	  
		  inventoryBaseId = slot.inventoryBaseId,
		  name = slot.name,
		  gender = slot.gender,		
		  race = slot.race,	
		  hair = slot.hair,
		  head = slot.head,
		  class = slot.class,	
		  level = slot.level,
		  faction = slot.faction,
		  script = slot.script,		  
		  autoCalc = slot.autoCalc,
		  --aiFlee = slot.aiFlee,
		  --aiAlarm = slot.aiAlarm,
		  --aiServices = slot.aiServices,
		  --items = slot.items
		}	
		if slot.aiFight ~= "" then
			recordTableaiFight = slot.aiFight
		end
		
		if slot.autoCalc == 0 then
			recordTable.health = slot.health
			recordTable.magicka = slot.magicka
			recordTable.fatigue = slot.fatigue
		end
		
		if slot.model ~= "" then
			recordTable.model = slot.model
		end
		
		recordStoreNpc.data.permanentRecords[string.lower(refId)] = recordTable	
	end
	recordStoreNpc:Save()	
	recordTable = nil	
end	

------------
-- EVENTS --
------------
customEventHooks.registerHandler("OnServerInit", CreateCustomNpc.OnServerInit)

return CreateCustomNpc

