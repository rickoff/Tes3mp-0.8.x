--[[
CreateCustomApparatus
tes3mp 0.8.0
---------------------------
INSTALLATION:
Save the file as CreateCustomApparatus.lua inside your server/scripts/custom folder.
Save the file as DataApparatus.json inside your server/data/custom/DataBase folder.
Edits to customScripts.lua add : CreateCustomApparatus = require("custom.CreateCustomApparatus")
---------------------------
INSTRUCTIONS:
to modify a value of an apparatus such as quality, modify the target in the file DataApparatus.json
]]

---------------
-- JSON-DATA --
---------------
local DataApparatus = jsonInterface.load("custom/DataBase/DataApparatus.json")

-------------
-- METHODS --
-------------
local CreateCustomApparatus = {}

CreateCustomApparatus.OnServerInit = function(eventStatus)
	local recordTable	
	local recordStoreApparatus = RecordStores["apparatus"]

	for refId, slot in pairs(DataApparatus) do
		recordTable = {
		  baseId = slot.baseId,
		  id = slot.baseId,
		  name = slot.name,
		  model = slot.model,
		  icon = slot.icon,
		  script = slot.script,
		  subtype = slot.subtype,
		  weight = slot.weight,
		  value = slot.value,
		  quality = slot.quality
		}	
		recordStoreApparatus.data.permanentRecords[string.lower(refId)] = recordTable	
	end
	recordStoreApparatus:Save()	
	recordTable = nil	
end	

------------
-- EVENTS --
------------
customEventHooks.registerHandler("OnServerInit", CreateCustomApparatus.OnServerInit)

return CreateCustomApparatus