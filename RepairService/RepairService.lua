--[[
RepairService
tes3mp 0.8.1
---------------------------
INSTALLATION:
Save the file as RepairService.lua inside your server/scripts/custom/RepairService folder.
Save the file as DataWeapons.lua inside your server/scripts/custom/RepairService folder.
Save the file as DataArmors.lua inside your server/scripts/custom/RepairService folder.
Edits to customScripts.lua add in : require("custom.RepairService.RepairService")
---------------------------
]]
require("custom.RepairService.DataWeapons")
require("custom.RepairService.DataArmors")

local cfg = {
	InvGui = 19012024,
	PriceMult = 1
}

local playerInventoryOptions = {}

local function GetName(pid)
	return string.lower(Players[pid].accountName)	
end

local function PlaySound(pid, sound)
	logicHandler.RunConsoleCommandOnPlayer(pid, "playsound "..'"'..sound..'"', false)
end

local function GetPlayerGold(pid)
	local goldLoc = inventoryHelper.getItemIndex(Players[pid].data.inventory, "gold_001", -1)	
	if goldLoc then
		return Players[pid].data.inventory[goldLoc].count
	else
		return 0
	end
end

local function GetObjectName(refId)
	local Record = {"weapon", "armor"}	
	for _, nameRecord in ipairs(Record) do	
		if RecordStores[nameRecord].data.permanentRecords[string.lower(refId)] then	
			return RecordStores[nameRecord].data.permanentRecords[string.lower(refId)].name			
		elseif RecordStores[nameRecord].data.generatedRecords[string.lower(refId)] then		
			return RecordStores[nameRecord].data.generatedRecords[string.lower(refId)].name			
		end	
	end
	if DataWeapons[string.lower(refId)] then
		return DataWeapons[string.lower(refId)].name
	elseif DataArmors[string.lower(refId)] then
		return DataArmors[string.lower(refId)].name
	end
	return string.gsub(refId, "_", " ")
end

local function GetObjectCharge(refId)
	local Record = {"weapon", "armor"}
	for _, nameRecord in ipairs(Record) do	
		if RecordStores[nameRecord].data.permanentRecords[string.lower(refId)] then		
			return RecordStores[nameRecord].data.permanentRecords[string.lower(refId)].health			
		elseif RecordStores[nameRecord].data.generatedRecords[string.lower(refId)] then		
			refId = RecordStores[nameRecord].data.generatedRecords[string.lower(refId)].baseId
			if RecordStores[nameRecord].data.permanentRecords[string.lower(refId)] then		
				return RecordStores[nameRecord].data.permanentRecords[string.lower(refId)].health
			end
		end	
	end	
	if DataWeapons[string.lower(refId)] then
		return DataWeapons[string.lower(refId)].health
	elseif DataArmors[string.lower(refId)] then
		return DataArmors[string.lower(refId)].health
	end	
end

local function GetListInventoryRepair(pid)
	local options = {}	
	for _, item in pairs(Players[pid].data.inventory) do		
		if item.refId and item.refId ~= "" then	
			local ObjectName = GetObjectName(string.lower(item.refId))		
			local ObjectCharge = GetObjectCharge(string.lower(item.refId))			
			if ObjectName and ObjectName ~= "" and ObjectCharge
			and item.charge and item.charge ~= -1 and ObjectCharge - item.charge > 0 then			
				local Price = math.ceil(ObjectCharge - item.charge) * cfg.PriceMult			
				local newItem = {
					refId = item.refId,
					count = item.count or 1,
					charge = item.charge or -1,
					enchantmentCharge = item.enchantmentCharge or -1,
					soul = item.soul or "",
					name = ObjectName,
					price = Price
				}				
				table.insert(options, newItem)				
			end
		end
	end
 	table.sort(options, function(a,b) return a.name<b.name end)	
	return options	
end

local function RepairObject(pid, data)
	local playerName = GetName(pid)	
	local TargetObject = playerInventoryOptions[playerName][data]
	local GoldCount = GetPlayerGold(pid)
	if GoldCount >= TargetObject.price then
		local ItemGold = inventoryHelper.getItemIndex(Players[pid].data.inventory, "gold_001")
		if ItemGold then
			local goldItem = {
				refId = "gold_001",
				count = TargetObject.price,
				charge = -1,
				enchantmentCharge = -1,
				soul = ""
			}
			Players[pid]:LoadItemChanges({goldItem}, enumerations.inventory.REMOVE)
			Players[pid].data.inventory[ItemGold].count = GoldCount - TargetObject.price
			if Players[pid].data.inventory[ItemGold].count == 0 then
				Players[pid].data.inventory[ItemGold] = nil
				tableHelper.cleanNils(Players[pid].data.inventory)
			end
		end
		local ItemLoc = inventoryHelper.getItemIndex(Players[pid].data.inventory, TargetObject.refId)		
		if ItemLoc then			
			Players[pid]:LoadItemChanges({Players[pid].data.inventory[ItemLoc]}, enumerations.inventory.REMOVE)			
			Players[pid].data.inventory[ItemLoc] = nil
			tableHelper.cleanNils(Players[pid].data.inventory)			
		end		
		local newItem = {
			refId = TargetObject.refId,
			count = TargetObject.count or 1,
			charge = -1,
			enchantmentCharge = TargetObject.enchantmentCharge or -1,
			soul = TargetObject.soul or ""
		}	
		table.insert(Players[pid].data.inventory, newItem)		
		Players[pid]:LoadItemChanges({newItem}, enumerations.inventory.ADD)		
		PlaySound(pid, "repair")		
	else		
		PlaySound(pid, "repair fail")	
	end	
end

local function showInventoryRepair(pid)
	local playerName = GetName(pid)	
	local options = GetListInventoryRepair(pid)	
	local list = "Choose object to repair\n"
	for i = 1, #options do		
		list = list..options[i].name.." | Price : "..options[i].price		
		if not(i == #options) then		
			list = list.."\n"			
		end		
	end
	playerInventoryOptions[playerName] = options
	local GoldCount = GetPlayerGold(pid)
	local Title = (
		"Repair menu(service)\n"..
		"gold coins: "..GoldCount
	)
	tes3mp.ListBox(pid, cfg.InvGui, Title, list)
end

customEventHooks.registerValidator("OnObjectDialogueChoice", function(eventStatus, pid, cellDescription, objects)
	for _, object in pairs(objects) do
		if object.dialogueChoiceType and object.dialogueChoiceType == 9 then
			showInventoryRepair(pid)
			return customEventHooks.makeEventStatus(false, false)
		end
	end
end)

customEventHooks.registerHandler("OnGUIAction", function(eventStatus, pid, idGui, data)	
	if idGui == cfg.InvGui then	
		if tonumber(data) == 0 or tonumber(data) == 18446744073709551615 then			
		else		
			RepairObject(pid, tonumber(data))			
			showInventoryRepair(pid)			
		end
	end
end)
