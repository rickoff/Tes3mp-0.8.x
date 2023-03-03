--[[
MultiProject
tes3mp 0.8.1
---------------------------
INSTALLATION:
Save the file as MultiProject.lua inside your server/scripts/custom folder.
Edits to customScripts.lua add : MultiProject = require("custom.MultiProject")
---------------------------
CONFIGURATION:
change cfg.projectEchantMulti to modify the multiplier of the following quantity calculation
count = (soul gemme charge * projetiles enchant multiplier)
]]
local cfg = {
	projectEchantMulti = 0.25
}

local MultiProject = {}

MultiProject.OnRecordDynamicValidator = function(eventStatus, pid, recordArray, storeType)
	for _, record in ipairs(recordArray) do
		if storeType == "weapon" then
			if string.find(record.baseId, "arrow") or string.find(record.baseId, "bolt") or string.find(record.baseId, "throwing") then		
				local newQuantity = math.floor(record.enchantmentCharge * cfg.projectEchantMulti)				
				local itemIndex = inventoryHelper.getItemIndex(Players[pid].data.inventory, record.baseId)				
				local itemCount = Players[pid].data.inventory[itemIndex].count or 1			
				if newQuantity > itemCount then newQuantity = itemCount end			
				record.quantity = newQuantity			
			end						
		end
	end
end	

customEventHooks.registerValidator("OnRecordDynamic", MultiProject.OnRecordDynamicValidator)

return MultiProject
