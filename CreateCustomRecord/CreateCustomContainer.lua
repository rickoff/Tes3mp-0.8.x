--[[
CreateCustomContainer
tes3mp 0.8.0
---------------------------
INSTALLATION:
Save the file as CreateCustomContainer.lua inside your server/scripts/custom folder.
Save the file as DataContainer.json inside your server/data/custom/DataBase folder.
Edits to customScripts.lua add : CreateCustomContainer = require("custom.CreateCustomContainer")
---------------------------
INSTRUCTIONS:
to modify a value of an container such as weight, modify the target in the file DataContainer.json
]]

---------------
-- JSON-DATA --
---------------
local DataContainer = jsonInterface.load("custom/DataBase/DataContainer.json")

-------------
-- METHODS --
-------------
local CreateCustomContainer = {}

CreateCustomContainer.OnServerInit = function(eventStatus)
	local recordTable	
	local recordStoreContainer = RecordStores["container"]

	for refId, slot in pairs(DataContainer) do
		recordTable = {
		  baseId = slot.baseId,
		  id = slot.baseId,
		  name = slot.name,
		  model = slot.model,	
		  script = slot.script,		
		  weight = slot.weight,
		  flags = slot.flags		  
		}	
		recordStoreContainer.data.permanentRecords[string.lower(refId)] = recordTable	
	end
	recordStoreContainer:Save()	
	recordTable = nil	
end	

------------
-- EVENTS --
------------
customEventHooks.registerHandler("OnServerInit", CreateCustomContainer.OnServerInit)

return CreateCustomContainer