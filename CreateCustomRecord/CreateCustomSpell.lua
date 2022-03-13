--[[
CreateCustomSpell
tes3mp 0.8.0
---------------------------
INSTALLATION:
Save the file as CreateCustomSpell.lua inside your server/scripts/custom folder.
Save the file as DataSpell.json inside your server/data/custom/DataBase folder.
Edits to customScripts.lua add : CreateCustomSpell = require("custom.CreateCustomSpell")
---------------------------
INSTRUCTIONS:
to modify a value of an spell such as magnitudeMax, modify the target in the file DataSpell.json
]]

---------------
-- JSON-DATA --
---------------
local DataSpell = jsonInterface.load("custom/DataBase/DataSpell.json")

-------------
-- METHODS --
-------------
local CreateCustomSpell = {}
CreateCustomSpell.OnServerInit = function(eventStatus)
	local recordTable	
	local recordStoreSpell = RecordStores["spell"]

	for refId, slot in pairs(DataSpell) do
		recordTable = {
		  baseId = slot.baseId,
		  id = slot.baseId,
		  name = slot.name,
		  subtype = slot.subtype,
		  cost = slot.cost,
		  flags = slot.flags,
		  effects = {}
		}
		for x, data in pairs(slot.enchant) do
			local tableEnchant = {}
			tableEnchant.id = data.id
			tableEnchant.attribute = data.attribute
			tableEnchant.skill = data.skill
			tableEnchant.rangeType = data.rangeType
			tableEnchant.area = data.area
			tableEnchant.duration = data.duration
			tableEnchant.magnitudeMax = data.magnitudeMax
			tableEnchant.magnitudeMin = data.magnitudeMin
			table.insert(recordTable.effects, tableEnchant)
		end
		
		recordStoreSpell.data.permanentRecords[string.lower(refId)] = recordTable	
	end
	recordStoreSpell:Save()	
	recordTable = nil	
end	

------------
-- EVENTS --
------------
customEventHooks.registerHandler("OnServerInit", CreateCustomSpell.OnServerInit)

return CreateCustomSpell
