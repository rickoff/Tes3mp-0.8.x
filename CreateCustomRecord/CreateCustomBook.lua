--[[
CreateCustomBook
tes3mp 0.8.0
---------------------------
INSTALLATION:
Save the file as CreateCustomBook.lua inside your server/scripts/custom folder.
Save the file as DataBook.json inside your server/data/custom/DataBase folder.
Edits to customScripts.lua add : CreateCustomBook = require("custom.CreateCustomBook")
---------------------------
INSTRUCTIONS:
to modify a value of an book such as text, modify the target in the file DataBook.json
]]

---------------
-- JSON-DATA --
---------------
local DataBook = jsonInterface.load("custom/DataBase/DataBook.json")

-------------
-- METHODS --
-------------
local CreateCustomBook = {}

CreateCustomBook.OnServerInit = function(eventStatus)
	local recordTable	
	local recordStoreBook = RecordStores["book"]

	for refId, slot in pairs(DataBook) do
		recordTable = {
		  baseId = slot.baseId,
		  id = slot.baseId,
		  name = slot.name,		  
		  icon = slot.icon,		
		  script = slot.script,	
		  enchantmentId = slot.enchantmentId,
		  enchantmentCharge = slot.enchantmentCharge,			  
		  model = slot.model,
		  text = slot.text,	
		  weight = slot.weight,
		  value = slot.value,
		  scrollState = slot.scrollState,	
		  skillId = slot.skillId		  
		}	
		recordStoreBook.data.permanentRecords[string.lower(refId)] = recordTable	
	end
	recordStoreBook:Save()	
	recordTable = nil	
end	

------------
-- EVENTS --
------------
customEventHooks.registerHandler("OnServerInit", CreateCustomBook.OnServerInit)

return CreateCustomBook