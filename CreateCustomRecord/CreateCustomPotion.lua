--[[
CreateCustomPotion
tes3mp 0.8.0
---------------------------
INSTALLATION:
Save the file as CreateCustomPotion.lua inside your server/scripts/custom folder.
Save the file as DataPotion.json inside your server/data/custom/DataBase folder.
Edits to customScripts.lua add : CreateCustomPotion = require("custom.CreateCustomPotion")
---------------------------
INSTRUCTIONS:
to modify a value of an potion such as value, modify the target in the file DataPotion.json
]]

---------------
-- JSON-DATA --
---------------
local DataPotion = jsonInterface.load("custom/DataBase/DataPotion.json")

-------------
-- METHODS --
-------------
local CreateCustomPotion = {}

CreateCustomPotion.OnServerInit = function(eventStatus)
	local recordTable	
	local recordStoreActivator = RecordStores["potion"]

	for refId, slot in pairs(DataPotion) do
		recordTable = {
		  baseId = slot.baseId,
		  id = slot.baseId,
		  name = slot.name,
		  model = slot.model,
		  icon = slot.icon,
		  script = slot.script,
		  weight = slot.weight,
		  value = slot.value,
		  autoCalc = slot.autoCalc
		}
		
		recordStoreActivator.data.permanentRecords[string.lower(refId)] = recordTable	
	end
	recordStoreActivator:Save()	
	recordTable = nil	
end	

------------
-- EVENTS --
------------
customEventHooks.registerHandler("OnServerInit", CreateCustomPotion.OnServerInit)

return CreateCustomPotion