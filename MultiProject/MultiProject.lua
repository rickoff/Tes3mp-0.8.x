--[[
MultiProject
tes3mp 0.8.1
---------------------------
INSTALLATION:
Save the file as MultiProject.lua inside your server/scripts/custom folder.
Edits to customScripts.lua add : require("custom.MultiProject")
---------------------------
CONFIGURATION:
change cfg.projectEchantMulti to modify the multiplier of the following quantity calculation
count = (soul gemme charge * projetiles enchant multiplier)
]]
local cfg = {
	projectEchantMulti = 0.25
}

customEventHooks.registerValidator("OnRecordDynamic", function(eventStatus, pid, recordArray, storeType)
	for _, record in ipairs(recordArray) do
		if storeType == "weapon" then
			if string.find(record.baseId, "arrow") or string.find(record.baseId, "bolt") or string.find(record.baseId, "throwing") then		
				local newQuantity = math.floor(record.enchantmentCharge * cfg.projectEchantMulti)				
				local itemIndex = inventoryHelper.getItemIndex(Players[pid].data.inventory, record.baseId)				
				local itemData = Players[pid].data.inventory[itemIndex]				
				local itemCount = itemData.count or 1			
				if newQuantity > itemCount then newQuantity = itemCount end
				local item = { refId = itemData.refId, count = newQuantity, charge = -1, enchantmentCharge = -1, soul = "" }
				inventoryHelper.removeExactItem(Players[pid].data.inventory, itemData.refId, newQuantity, -1, -1, "")				
				Players[pid]:LoadItemChanges({item}, enumerations.inventory.REMOVE)				
				Players[pid]:QuicksaveToDrive()				
				record.quantity = newQuantity				
			end						
		end
	end
end)
