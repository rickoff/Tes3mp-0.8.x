--[[
AutomaticEquipBoltArrow
tes3mp 0.8.1
------------
INSTALLATION :
Edits to customScripts.lua add in :
require("custom.AutomaticEquipBoltArrow")
]]

local function GetBowCrossbow(refId)
	if string.find(string.lower(refId), "bow") then
		if string.find(string.lower(refId), "crossbow") then
			return "crossbow"
		else
			return "bow"
		end
	end
	return false
end

local function GetBoltArrow(refId)
	if string.find(string.lower(refId), "bolt") then
		return "bolt"
	end
	if string.find(string.lower(refId), "arrow") then	
		return "arrow"
	end
	return false
end

local function GetItemCustomRecord(refId)
	if RecordStores.weapon.data.permanentRecords[refId] 
	and RecordStores.weapon.data.permanentRecords[refId].baseId then
		return RecordStores.weapon.data.permanentRecords[refId].baseId
	elseif RecordStores.weapon.data.generatedRecords[refId]
	and RecordStores.weapon.data.generatedRecords[refId].baseId then	
		return RecordStores.weapon.data.generatedRecords[refId].baseId
	else
		return refId
	end
end

local function GetAmmunitionInventory(pid, typ)
	for _, item in pairs(Players[pid].data.inventory) do
		if item.refId and item.refId ~= "" then
			local TargetRefId = GetItemCustomRecord(item.refId)		
			if string.find(string.lower(TargetRefId), typ) then
				return item
			end
		end
	end
	return false
end

local function GetAmmunitionEquipment(pid, typ)
	local item = Players[pid].data.equipment[enumerations.equipment.AMMUNITION]
	if item and item.refId and item.refId ~= "" then
		local TargetRefId = GetItemCustomRecord(item.refId)		
		if string.find(string.lower(TargetRefId), typ) then
			if item.count > 0 then
				return true
			else
				return false
			end
		end
	end
	return false
end

local function EquipAmmunition(pid, item)
	tes3mp.EquipItem(pid, enumerations.equipment.AMMUNITION, item.refId, item.count,
	item.charge, item.enchantmentCharge)				
	tes3mp.SendEquipment(pid)
	local equipItem = {
		refId = item.refId,
		count = item.count,						
		charge = item.charge,
		enchantmentCharge = item.enchantmentCharge
	}
	Players[pid].previousEquipment[enumerations.equipment.AMMUNITION] = Players[pid].data.equipment[enumerations.equipment.AMMUNITION]					
	Players[pid].data.equipment[enumerations.equipment.AMMUNITION] = equipItem	
end

customEventHooks.registerHandler("OnPlayerEquipment", function(eventStatus, pid, playerPacket)
	if playerPacket.equipment[enumerations.equipment.CARRIED_RIGHT] 
	and playerPacket.equipment[enumerations.equipment.CARRIED_RIGHT].refId then
		local TargetRefId = GetItemCustomRecord(playerPacket.equipment[enumerations.equipment.CARRIED_RIGHT].refId)
		local WeaponsType = GetBowCrossbow(TargetRefId)
		if WeaponsType then
			local AmmunitionType 
			if WeaponsType == "bow" then 
				AmmunitionType = "arrow"
			else
				AmmunitionType = "bolt"	
			end
			if not GetAmmunitionEquipment(pid, AmmunitionType) then
				local item = GetAmmunitionInventory(pid, AmmunitionType)
				if item then
					EquipAmmunition(pid, item)									
				end
			end
		end			
	end	
	if playerPacket.equipment[enumerations.equipment.AMMUNITION] 
	and playerPacket.equipment[enumerations.equipment.AMMUNITION].refId then
		local TargetRefId = GetItemCustomRecord(playerPacket.equipment[enumerations.equipment.AMMUNITION].refId)	
		local AmmunitionType = GetBoltArrow(TargetRefId)
		if AmmunitionType then
			if not GetAmmunitionEquipment(pid, AmmunitionType) then
				local item = GetAmmunitionInventory(pid, AmmunitionType)
				if item then
					EquipAmmunition(pid, item)					
				end
			end
		end			
	end		
end)
