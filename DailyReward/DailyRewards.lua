--[[
DailyRewards
tes3mp 0.8.1
---------------------------
DESCRIPTION :
gives daily login rewards
---------------------------
INSTALLATION:
Save the file as DailyRewards.lua inside your server/scripts/custom folder.
Edits to customScripts.lua
DailyRewards = require("custom.DailyRewards")
---------------------------
]]
local cfg = {
	randomizeReward = false
}

local trad = {
	rewardLoginMessageDaily = color.Green.."Récompenses de connexion journalière :"
}

local sound = {
	name = "item gold up",
	volume = 1,
	pitch = 1.3
}

local dailyRewardsTable = {
	{
		refId = "gold_001",
		name = "Or",
		count = 500,
		soul = ""
	},	
	{
		refId = "p_restore_health_s",
		name = "Potion de santé standard",
		count = 5,
		soul = ""
	},	
	{
		refId = "p_restore_magicka_s",
		name = "Potion magique standard",
		count = 5,
		soul = ""
	},	
	{
		refId = "p_restore_fatigue_s",
		name = "Potion de fatigue standard",
		count = 5,
		soul = ""
	},
	{
		refId = "p_fortify_speed_s",
		name = "Potion de rapidité standard",
		count = 5,
		soul = ""
	}
}

local function AddObjectInventoryPlayer(pid, item)	

	local itemref = {
		refId = item.refId,
		count = item.count or 1,
		charge = item.charge or -1,
		enchantmentCharge = item.enchantmentCharge or -1,
		soul = item.soul or ""
	}	
	
	local indexLoc = inventoryHelper.getItemIndex(Players[pid].data.inventory, itemref.refId, itemref.charge, itemref.enchantmentCharge, itemref.soul)

	if indexLoc then
	
		if Players[pid].data.inventory[indexLoc].count then
			
			Players[pid].data.inventory[indexLoc].count = Players[pid].data.inventory[indexLoc].count + itemref.count
			
		else
		
			Players[pid].data.inventory[indexLoc].count = itemref.count
			
		end
		
	else
		
		table.insert(Players[pid].data.inventory, itemref)	
		
	end

	Players[pid]:LoadItemChanges({itemref}, enumerations.inventory.ADD)
	
	Players[pid]:QuicksaveToDrive()
	
end

local function randomPull(pid, targetTable)
	
	math.randomseed((pid * (1 + math.random())) * os.time() + math.random())
	math.random()
	math.random()
	math.random()
	
	local keyset = {}
	
	for k in pairs(targetTable) do
	
		table.insert(keyset, k)
		
	end
	
	return targetTable[keyset[math.random(#keyset)]]
	
end

local function giveDailyLoginItem(pid)
	
	local addedItems = {}
	
	local rewardMsg = trad.rewardLoginMessageDaily
	
	if cfg.randomizeReward == true then

		local item = randomPull(pid, dailyRewardsTable)
		
		if item then
		
			AddObjectInventoryPlayer(pid, item)
			
			table.insert(addedItems, item)
			
		end
		
	else

		for i=1,#dailyRewardsTable do
		
			local item = dailyRewardsTable[i]
			
			if item then
			
				AddObjectInventoryPlayer(pid, item)
				
				table.insert(addedItems, item)
				
			end
			
		end
		
	end
	
	for i = 1, #addedItems do
	
		local item = addedItems[i]
		
		local iCount = item.count
		
		rewardMsg = rewardMsg.."\n"..color.White..item.name.." ("..item.count..")"

	end
	
	logicHandler.RunConsoleCommandOnPlayer(pid, "PlaySoundVP \""..sound.name.."\" "..sound.volume.." "..sound.pitch, false)
	
	tes3mp.MessageBox(pid, -1, rewardMsg)

end

local DailyRewards = {}

DailyRewards.OnPlayerAuthentified = function(eventStatus, pid)
	
	local daysName = os.date("%A")

	if not Players[pid].data.customVariables.DailyRewards then

		Players[pid].data.customVariables.DailyRewards = {
			days = ""
		}

	end

	if Players[pid].data.customVariables.DailyRewards.days ~= daysName then

		giveDailyLoginItem(pid)

		Players[pid].data.customVariables.DailyRewards.days = daysName			

		Players[pid]:QuicksaveToDrive()

	end	
end

customEventHooks.registerHandler("OnPlayerAuthentified", DailyRewards.OnPlayerAuthentified)

return DailyRewards
