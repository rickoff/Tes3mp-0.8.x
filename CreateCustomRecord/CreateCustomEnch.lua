--[[
CreateCustomEnch
tes3mp 0.8.1
---------------------------
INSTALLATION:
Save the file as CreateCustomEnch.lua inside your server/scripts/custom folder.
Save the file as DataSpell.json inside your server/data/custom/DataBase folder.
Edits to customScripts.lua add : CreateCustomEnch = require("custom.CreateCustomEnch")
---------------------------
INSTRUCTIONS:
to modify a value of an enchantment such as cost, modify the target in the file DataEnch.json
]]

---------------
-- JSON-DATA --
---------------
local DataEnchant = jsonInterface.load("custom/DataBase/DataEnch.json")

-------------
-- METHODS --
-------------
local CreateCustomEnch = {}

CreateCustomEnch.OnServerInit = function(eventStatus)

	local recordTable	
	
	local recordStoreEnch = RecordStores["enchantment"]


	for refId, slot in pairs(DataEnchant) do
		recordTable = {
		  baseId = slot.baseId,
		  id = slot.baseId,
		  charge = slot.charge,
		  subtype = slot.subtype,
		  cost = slot.cost,
		  flags = slot.flags,
		  effects = {}
		}
		for x, data in pairs(slot.effects) do
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
		
		recordStoreEnch.data.permanentRecords[string.lower(refId)] = recordTable	
	end
	recordStoreEnch:Save()	
	recordTable = nil	
end	

------------
-- EVENTS --
------------
customEventHooks.registerHandler("OnServerInit", CreateCustomEnch.OnServerInit)

return CreateCustomEnch
