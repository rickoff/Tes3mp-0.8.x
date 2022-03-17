--[[
CreateCustomClothing
tes3mp 0.8.0
---------------------------
INSTALLATION:
Save the file as CreateCustomClothing.lua inside your server/scripts/custom folder.
Save the file as DataClothing.json inside your server/data/custom/DataBase folder.
Edits to customScripts.lua add : CreateCustomClothing = require("custom.CreateCustomClothing")
---------------------------
INSTRUCTIONS:
to modify a value of an book such as name, modify the target in the file DataClothing.json
]]

---------------
-- JSON-DATA --
---------------
local DataClothing = jsonInterface.load("custom/DataBase/DataClothing.json")

-------------
-- METHODS --
-------------
local CreateCustomClothing = {}

CreateCustomClothing.OnServerInit = function(eventStatus)
	local recordTable	
	local recordStoreClothing = RecordStores["clothing"]

	for refId, slot in pairs(DataClothing) do
		recordTable = {
		  baseId = slot.baseId,
		  id = slot.baseId,
		  name = slot.name,
		  model = slot.model,		  
		  icon = slot.icon,		
		  script = slot.script,	
		  enchantmentId = slot.enchantmentId,
		  enchantmentCharge = slot.enchantmentCharge,
		  subtype = slot.subtype,	
		  weight = slot.weight,
		  value = slot.value		  
		}	
		recordStoreClothing.data.permanentRecords[string.lower(refId)] = recordTable	
	end
	recordStoreClothing:Save()	
	recordTable = nil	
end	

------------
-- EVENTS --
------------
customEventHooks.registerHandler("OnServerInit", CreateCustomClothing.OnServerInit)

return CreateCustomClothing