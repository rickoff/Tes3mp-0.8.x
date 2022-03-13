--[[
CreateCustomWeapon
tes3mp 0.8.0
---------------------------
INSTALLATION:
Save the file as CreateCustomWeapon.lua inside your server/scripts/custom folder.
Save the file as DataWeapon.json inside your server/data/custom/DataBase folder.
Edits to customScripts.lua add : CreateCustomWeapon = require("custom.CreateCustomWeapon")
---------------------------
INSTRUCTIONS:
to modify a value of an item such as damageSlash, modify the target in the file DataWeapon.json
]]

---------------
-- JSON-DATA --
---------------
local DataWeapon = jsonInterface.load("custom/DataBase/DataWeapon.json")

-------------
-- METHODS --
-------------
local CreateCustomWeapon = {}

CreateCustomWeapon.OnServerInit = function(eventStatus)
	local recordTable	
	local recordStoreWeapon = RecordStores["weapon"]		
	for refId, record in pairs(DataWeapon) do
		recordTable = {
			baseId = record.baseId,
			id = record.baseId,
			name = record.name,
			subtype = record.subtype,
			model = record.model,
			icon = record.icon,
			weight = record.weight,						
			value = record.value,
			health = record.health,
			speed = record.speed,
			reach = record.reach,
			enchantmentId = record.enchantmentId,
			enchantmentCharge = record.enchantmentCharge,
			script = record.script,	
			flags = record.flags,
			damageSlash = { 
				min = record.damageSlash.min,
				max = record.damageSlash.max
			},
			damageChop = {
				min = record.damageChop.min,
				max = record.damageChop.max
			},
			damageThrust = {
				min = record.damageThrust.min,
				max = record.damageThrust.max
			}
		}	
		recordStoreWeapon.data.permanentRecords[string.lower(refId)] = recordTable
	end
	recordStoreWeapon:Save()	
	recordTable = nil
end	

------------
-- EVENTS --
------------
customEventHooks.registerHandler("OnServerInit", CreateCustomWeapon.OnServerInit)

return CreateCustomWeapon
