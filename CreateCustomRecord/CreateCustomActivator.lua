--[[
CreateCustomActivator
tes3mp 0.8.0
---------------------------
INSTALLATION:
Save the file as CreateCustomActivator.lua inside your server/scripts/custom folder.
Save the file as DataActivator.json inside your server/data/custom/DataBase folder.
Edits to customScripts.lua add : CreateCustomActivator = require("custom.CreateCustomActivator")
---------------------------
INSTRUCTIONS:
to modify a value of an activator such as name, modify the target in the file DataActivator.json
]]

---------------
-- JSON-DATA --
---------------
local DataActivator = jsonInterface.load("custom/DataBase/DataActivator.json")

-------------
-- METHODS --
-------------
local CreateCustomActivator = {}

CreateCustomActivator.OnServerInit = function(eventStatus)
	local recordTable	
	local recordStoreActivator = RecordStores["activator"]
	for refId, slot in pairs(DataActivator) do
		recordTable = {
		  baseId = slot.baseId,
		  id = slot.baseId,
		  name = slot.name,
		  model = slot.model,
		  script = slot.script
		}		
		recordStoreActivator.data.permanentRecords[string.lower(refId)] = recordTable	
	end
	recordStoreActivator:Save()	
	recordTable = nil	
end	

------------
-- EVENTS --
------------
customEventHooks.registerHandler("OnServerInit", CreateCustomActivator.OnServerInit)

return CreateCustomActivator
