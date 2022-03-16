--[[
CreateCustomBody
tes3mp 0.8.0
---------------------------
INSTALLATION:
Save the file as CreateCustomBody.lua inside your server/scripts/custom folder.
Save the file as DataBody.json inside your server/data/custom/DataBase folder.
Edits to customScripts.lua add : CreateCustomBody = require("custom.CreateCustomBody")
---------------------------
INSTRUCTIONS:
to modify a value of an Bodypart such as race, modify the target in the file DataBody.json
]]

---------------
-- JSON-DATA --
---------------
local DataBody = jsonInterface.load("custom/DataBase/DataBody.json")

-------------
-- METHODS --
-------------
local CreateCustomBody = {}

CreateCustomBody.OnServerInit = function(eventStatus)
	local recordTable	
	local recordStoreBody = RecordStores["bodypart"]

	for refId, slot in pairs(DataBody) do
		recordTable = {
		  baseId = slot.baseId,
		  id = slot.baseId,
		  subtype = slot.subtype,
		  part = slot.part,		  
		  model = slot.model,
		  race = slot.race,	
		  vampireState = slot.vampireState,
		  flags = slot.flags			  
		}	
		recordStoreBody.data.permanentRecords[string.lower(refId)] = recordTable	
	end
	recordStoreBody:Save()	
	recordTable = nil	
end	

------------
-- EVENTS --
------------
customEventHooks.registerHandler("OnServerInit", CreateCustomBody.OnServerInit)

return CreateCustomBody