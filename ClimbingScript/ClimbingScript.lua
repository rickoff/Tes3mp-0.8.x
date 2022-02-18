--[[
ClimbingScript
tes3mp 0.8.0
---------------------------
DESCRIPTION :
Climb using the tools on almost any surface
---------------------------
INSTALLATION:
Save the file as ClimbingScript.lua inside your server/scripts/custom folder.
Save the file as StaticData.json inside your server/data/custom/ClimbingScript folder.
Edits to customScripts.lua :
ClimbingScript = require("custom.ClimbingScript")
---------------------------
CONFIGURATION :
cfg.PriceTools = 250 (determines the price in gold for the purchase of the climbing tool)
cfg.Charge = 100 (determines the total resistance of the tool)
cfg.Momentum = false (determines method for climbing between levitation or momentum)
---------------------------
UTILIZATION :
/climp to buy a tool
hit an element of the scenery with the tool to engage the climbing mode
]]
local StaticData = jsonInterface.load("custom/ClimbingScript/StaticData.json")

local cfg = {}
cfg.PriceTools = 250
cfg.Charge = 100
cfg.Momentum = false

local ClimbingScript = {}

function StopClimb(pid)
	logicHandler.RunConsoleCommandOnPlayer(pid, "player->removespell climbing_spell", false)
	Players[pid].data.timerClimb = nil
end

local function GetIndexItemRefId(pid, refId)
	for key, slot in pairs(Players[pid].data.inventory) do
		if slot.refId and string.lower(slot.refId) == string.lower(refId) then
			if Players[pid].data.equipment[enumerations.equipment.CARRIED_RIGHT]
			and Players[pid].data.equipment[enumerations.equipment.CARRIED_RIGHT].refId == refId
			and Players[pid].data.equipment[enumerations.equipment.CARRIED_RIGHT].charge == slot.charge then
				return key
			end
		end
	end
	return false
end

local function GetPlayerGold(pid)
	local goldLoc = inventoryHelper.getItemIndex(Players[pid].data.inventory, "gold_001", -1)	
	if goldLoc then
		return Players[pid].data.inventory[goldLoc].count
	else
		return 0
	end
end

local function RemoveGold(pid, amount)
	local goldLoc = inventoryHelper.getItemIndex(Players[pid].data.inventory, "gold_001", -1)	
	Players[pid].data.inventory[goldLoc].count = Players[pid].data.inventory[goldLoc].count - amount
	if Players[pid].data.inventory[goldLoc].count == 0 then
		Players[pid].data.inventory[goldLoc] = nil
	end
	local itemref = {refId = "gold_001", count = amount, charge = -1, enchantmentCharge = -1, soul = ""}			
	Players[pid]:QuicksaveToDrive()
	Players[pid]:LoadItemChanges({itemref}, enumerations.inventory.REMOVE)			
end

local function DeleteObjectInventory(pid, refId, count)				
	local indexLoc = GetIndexItemRefId(pid, refId)
	local total
	if count then
		total = count
	else
		total = Players[pid].data.inventory[indexLoc].count or 1 
	end
	local itemref = {refId = refId, count = total, charge = -1, enchantmentCharge = -1, soul = ""}
	if Players[pid].data.inventory[indexLoc].count then
		if Players[pid].data.inventory[indexLoc].count - total <= 0 then
			Players[pid].data.inventory[indexLoc] = nil
			if Players[pid].data.equipment[enumerations.equipment.CARRIED_RIGHT] 
			and Players[pid].data.equipment[enumerations.equipment.CARRIED_RIGHT].refId == refId then
				Players[pid].data.equipment[enumerations.equipment.CARRIED_RIGHT] = nil
			end
		else
			Players[pid].data.inventory[indexLoc].count = Players[pid].data.inventory[indexLoc].count - total
		end
	else
		Players[pid].data.inventory[indexLoc] = nil	
		if Players[pid].data.equipment[enumerations.equipment.CARRIED_RIGHT] 
		and Players[pid].data.equipment[enumerations.equipment.CARRIED_RIGHT].refId == refId then
			Players[pid].data.equipment[enumerations.equipment.CARRIED_RIGHT] = nil
		end		
	end
	Players[pid]:LoadItemChanges({itemref}, enumerations.inventory.REMOVE)
	Players[pid]:QuicksaveToDrive()
end

local function DamageChargeObject(pid, refId)
	local indexLoc = GetIndexItemRefId(pid, refId)
	local count = Players[pid].data.inventory[indexLoc].count or 1 
	local charge
	if Players[pid].data.inventory[indexLoc].charge == -1 then
		charge = 100
	elseif Players[pid].data.inventory[indexLoc].charge == 0 then
		DeleteObjectInventory(pid, refId, 1)
		return
	else
		charge = Players[pid].data.inventory[indexLoc].charge
	end
	
	local itemCible = {refId = refId, count = count, charge = Players[pid].data.inventory[indexLoc].charge, enchantmentCharge = -1, soul = ""}	
	Players[pid].data.inventory[indexLoc] = nil	
	Players[pid]:LoadItemChanges({itemCible}, enumerations.inventory.REMOVE)	
	
	local itemRef = {refId = refId, count = count, charge = charge - 1, enchantmentCharge = -1, soul = ""}		
	table.insert(Players[pid].data.inventory, itemRef)
	Players[pid]:LoadItemChanges({itemRef}, enumerations.inventory.ADD)	

	Players[pid]:LoadInventory()
	
	Players[pid].data.equipment[enumerations.equipment.CARRIED_RIGHT] = {refId = refId, count = count, charge = (charge - 1), enchantmentCharge = -1}
	Players[pid]:LoadEquipment()
	Players[pid]:QuicksaveToDrive()
end

ClimbingScript.OnServerInit = function(eventStatus)
	local recordTable
	
	------------------
	--WEAPONS RECORD--
	------------------
	local recordStoreWeapons = RecordStores["weapon"]
	
	recordTable = {
		name = "Climbing tool",
		subtype = 4,
		model = "w\\W_Miner_pick.NIF",
		icon = "w\\tx_miner_pick.tga",
		weight = 1,
		value = 0,
		health = cfg.Charge,
		reach = 0.5,
		speed = 1,
		damageChop = {
			min = 1,
			max = 2
			},
		damageSlash = {
			min = 1,
			max = 2
			},				
		damageThrust = {
			min = 1,
			max = 2
			},
		enchantmentId = "",
		enchantmentCharge = 0,
		script = "",
		flags = 1
	}
	recordStoreWeapons.data.permanentRecords["climbing_tool"] = recordTable	
	
	recordStoreWeapons:Save()	
	recordTable = nil	
	
	-----------------
	--SPELLS RECORD--
	-----------------
	local recordStoreSpells = RecordStores["spell"]

	recordTable = {
	  name = "Climbing",
	  subtype = 1,
	  cost = 0,
	  flags = 0,
	  effects = {{
		  id = 10,
		  attribute = -1,
		  skill = -1,
		  rangeType = 0,
		  area = 0,
		  duration = 1,
		  magnitudeMax = 10,
		  magnitudeMin = 10
		}}
	}
	recordStoreSpells.data.permanentRecords["climbing_spell"] = recordTable

	recordStoreSpells:Save()
	recordTable = nil	
end

ClimbingScript.OnObjectHit = function(eventStatus, pid, cellDescription, objects)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then	
		local ObjectRefid
		local ObjectIndex	
		for _, object in pairs(objects) do
			ObjectRefid = object.refId
			ObjectIndex = object.uniqueIndex
		end	
		if ObjectIndex == nil or ObjectRefid == nil then return end	
		
		local drawState = tes3mp.GetDrawState(pid)
		
		if StaticData[string.lower(ObjectRefid)] then
			if tes3mp.GetDrawState(pid) == 1 and Players[pid].data.equipment[enumerations.equipment.CARRIED_RIGHT].refId == "climbing_tool" then
				local fatigueCurrent = tes3mp.GetFatigueCurrent(pid)
				if cfg.Momentum == true and fatigueCurrent >= 10 then
					local rotZ = tes3mp.GetRotZ(pid)
					local impulseX = math.cos(rotZ) * 5
					local impulseY = math.sin(rotZ) * 5
					tes3mp.SetMomentum(pid, impulseX, impulseY, 500)
					tes3mp.SendMomentum(pid)
					tes3mp.SetFatigueCurrent(pid, Players[pid].data.stats.fatigueCurrent - 10)
					tes3mp.SendStatsDynamic(pid)					
				else
					if Players[pid].data.timerClimb and fatigueCurrent >= 10 then
						tes3mp.StopTimer(Players[pid].data.timerClimb)
						Players[pid].data.timerClimb = nil
						Players[pid].data.timerClimb = tes3mp.CreateTimerEx("StopClimb", time.seconds(1), "i", pid)
						tes3mp.StartTimer(Players[pid].data.timerClimb)	
						tes3mp.SetFatigueCurrent(pid, Players[pid].data.stats.fatigueCurrent - 10)
						tes3mp.SendStatsDynamic(pid)						
					else
						Players[pid].data.timerClimb = tes3mp.CreateTimerEx("StopClimb", time.seconds(1), "i", pid)
						tes3mp.StartTimer(Players[pid].data.timerClimb)	
					end
				
					logicHandler.RunConsoleCommandOnPlayer(pid, "player->addspell climbing_spell", false)
				end
				ClimbingScript.PlaySound(pid, "heavy armor hit")
				DamageChargeObject(pid, "climbing_tool")			
			end
		end		
	end
end

ClimbingScript.BuyTools = function(pid)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then	
		if GetPlayerGold(pid) >= cfg.PriceTools then
			RemoveGold(pid, cfg.PriceTools)	
			local itemref = {refId = "climbing_tool", count = 1, charge = -1, enchantmentCharge = -1, soul = ""}
			table.insert(Players[pid].data.inventory, itemref)			
			Players[pid]:LoadItemChanges({itemref}, enumerations.inventory.ADD)
			local message = (color.Default.."You are buy : climbing tool.")	
			tes3mp.MessageBox(pid, -1, message)	
			Players[pid]:QuicksaveToDrive()			
		else
			local message = (color.Default.."You can't afford to buy : climbing tool.\nPrice : "..cfg.PriceTools..".\nInventory Gold : "..GetPlayerGold(pid))	
			tes3mp.MessageBox(pid, -1, message)	
		end
	end
end

ClimbingScript.PlaySound = function(pid, sound)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
		logicHandler.RunConsoleCommandOnPlayer(pid, "playsound "..'"'..sound..'"')
	end
end

customEventHooks.registerHandler("OnServerInit", ClimbingScript.OnServerInit)
customEventHooks.registerHandler("OnObjectHit", ClimbingScript.OnObjectHit)
customCommandHooks.registerCommand("climb", ClimbingScript.BuyTools)

return ClimbingScript
