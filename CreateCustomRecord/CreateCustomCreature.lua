--[[
CreateCustomCreature
tes3mp 0.8.1
---------------------------
INSTALLATION:
Save the file as CreateCustomCreature.lua inside your server/scripts/custom folder.
Save the file as DataCreature.json inside your server/data/custom/DataBase folder.
Edits to customScripts.lua add : CreateCustomCreature = require("custom.CreateCustomCreature")
---------------------------
INSTRUCTIONS:
to modify a value of an creature such as name, modify the target in the file DataCreature.json
]]

---------------
-- JSON-DATA --
---------------
local DataCreature = jsonInterface.load("custom/DataBase/DataCreature.json")

-------------
-- METHODS --
-------------
local CreateCustomCreature = {}

CreateCustomCreature.OnServerInit = function(eventStatus)
	local recordTable	
	local recordStoreCreature = RecordStores["creature"]

	for refId, slot in pairs(DataCreature) do
		recordTable = {
		  baseId = slot.baseId,
		  id = slot.baseId,
		  name = slot.name,
		  model = slot.model,		  
		  --scale = slot.scale,		
		  script = slot.script,	
		  --bloodType = slot.bloodType,
		  level = slot.level,
		  subtype = slot.subtype,	
		  --soulValue = slot.soulValue,
		  --health = slot.health,
		  magicka = slot.magicka,
		  fatigue = slot.fatigue,
		  --damageChop = {min = slot.damageChop.min, max = slot.damageChop.max},
		  --damageSlash = {min = slot.damageSlash.min, max = slot.damageSlash.max},
		  --damageThrust = {min = slot.damageThrust.min, max = slot.damageThrust.max},	
		  aiFight = slot.aiFight,
		  --aiFlee = slot.aiFlee,
		  --aiAlarm = slot.aiAlarm,
		  --aiServices = slot.aiServices,
		  flags = slot.flags		  
		}	
		recordStoreCreature.data.permanentRecords[string.lower(refId)] = recordTable	
	end
	recordStoreCreature:Save()	
	recordTable = nil	
end	

------------
-- EVENTS --
------------
customEventHooks.registerHandler("OnServerInit", CreateCustomCreature.OnServerInit)

return CreateCustomCreature
