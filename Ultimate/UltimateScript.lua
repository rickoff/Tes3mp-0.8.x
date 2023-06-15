--[[
UltimateScript by Rickoff
tes3mp 0.8.1
script 0.1
---------------------------
DESCRIPTION :
Enter /ultimate to buy your ultimate "price = cfg.PriceUltimate"
After a certain number of hits "cfg.CountUltimateHit" on actors or creatures, the spell can be used only once, then the counter resumes at 0
When the player dies, the ultimate will be canceled and the counter will start from zero
Add new ultimates by simply adding spells to the "ListSpell" list as in the examples and restart server with cfg.OnServerInit = true
---------------------------
INSTALLATION:
Save the file as UltimateScript.lua inside your server/scripts/custom folder.

Edits to customScripts.lua add :
UltimateScript = require("custom.UltimateScript")
---------------------------
]]

local cfg = {
	OnServerInit = true,
	CountUltimateHit = 100,
	PriceUltimate = 100000,
	UltGUI = 15062023
}

local trd = {
	UltimateReady = "Ultimate ready !",
	Price = " | Price : ",
	Select = "Select an ultimate you want to use.",
	NoPermBuy = "You can't afford this purchase ",
	AddUltimate = " is ready to use, knock 100 times before you can activate it.",
	Return = "* Return *\n",
	Ultimate1 = "Fire ultimate",
	Ultimate2 = "Ice Ultimate",
	Ultimate3 = "Lightning Ultimate"
}

local ListSpell = {
	ultimatefire = {
		name = trd.Ultimate1,
		subtype = 0,
		cost = 0,
		flags = 4,
		effects = {
			{
				id = 4,
				attribute = -1,
				skill = -1,
				rangeType = 0,
				area = 1,
				duration = 60,
				magnitudeMax = 100,
				magnitudeMin = 100
			},		
			{
				id = 14,
				attribute = -1,
				skill = -1,
				rangeType = 0,
				area = 500,
				duration = 1,
				magnitudeMax = 100,
				magnitudeMin = 100
			}			
		}	
	},
	ultimatefrost = {
		name = trd.Ultimate2,
		subtype = 0,
		cost = 0,
		flags = 4,
		effects = {
			{
				id = 6,
				attribute = -1,
				skill = -1,
				rangeType = 0,
				area = 1,
				duration = 60,
				magnitudeMax = 100,
				magnitudeMin = 100
			},		
			{
				id = 16,
				attribute = -1,
				skill = -1,
				rangeType = 0,
				area = 500,
				duration = 1,
				magnitudeMax = 100,
				magnitudeMin = 100
			}				
		}	
	},
	ultimateshock = {
		name = trd.Ultimate3,
		subtype = 0,
		cost = 1,
		flags = 0,
		effects = {
			{
				id = 5,
				attribute = -1,
				skill = -1,
				rangeType = 0,
				area = 1,
				duration = 60,
				magnitudeMax = 100,
				magnitudeMin = 100
			},		
			{
				id = 15,
				attribute = -1,
				skill = -1,
				rangeType = 0,
				area = 500,
				duration = 1,
				magnitudeMax = 100,
				magnitudeMin = 100
			}				
		}	
	}
}

local ListPlayer = {}

local PlayerGUIOptions = {}

local function GetName(pid)
	return string.lower(Players[pid].accountName)
end

local function GetUltimateStock(pid)
	local options = {}   	
	for spellId, spell in pairs(ListSpell) do
		local newSpell = {
			spellId = spellId,
			name = spell.name
		}		
		table.insert(options, newSpell)		
	end 
 	table.sort(options, function(a,b) return a.name<b.name end)		
	return options	
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
	Players[pid]:LoadItemChanges({itemref}, enumerations.inventory.REMOVE)			
end

local function OnBuyChoice(pid, choice)
	local pgold = GetPlayerGold(pid)
	if pgold < cfg.PriceUltimate then
		tes3mp.MessageBox(pid, -1, trd.NoPermBuy.. choice.name .. ".")
		return false
	else
		RemoveGold(pid, cfg.PriceUltimate)
		tes3mp.MessageBox(pid, -1, "" .. choice.name .. trd.AddUltimate)
		Players[pid].data.customVariables.ultimateSpell = choice.spellId
		return true	
	end	
end

local function AddSpell(pid, tabSpell)
	local Change = false	
	tes3mp.ClearSpellbookChanges(pid)	
	tes3mp.SetSpellbookChangesAction(pid, enumerations.spellbook.ADD)
	for _, spellId in ipairs(tabSpell) do	
		if not tableHelper.containsValue(Players[pid].data.spellbook, spellId) then				
			tes3mp.AddSpell(pid, spellId)			
			table.insert(Players[pid].data.spellbook, spellId)				
			Change = true			
		end		
	end	
	if Change then	
		tes3mp.SendSpellbookChanges(pid)		
	end
end

local function RemoveSpell(pid, tabSpell)
	local Change = false	
	tes3mp.ClearSpellbookChanges(pid)
	tes3mp.SetSpellbookChangesAction(pid, enumerations.spellbook.REMOVE)
	for _, spellId in ipairs(tabSpell) do	
		if tableHelper.containsValue(Players[pid].data.spellbook, spellId) == true then	
			tes3mp.AddSpell(pid, spellId)		
			local foundIndex = tableHelper.getIndexByValue(Players[pid].data.spellbook, spellId)		
			Players[pid].data.spellbook[foundIndex] = nil			
			Change = true			
		end		
	end	
	if Change then
		tes3mp.SendSpellbookChanges(pid)	
		tableHelper.cleanNils(Players[pid].data.spellbook)			
	end	
end

local UltimateScript = {}

UltimateScript.OnServerInit = function(eventStatus)
	if cfg.OnServerInit then	
		local recordStoreSpells = RecordStores["spell"]
		for refId, slot in pairs(ListSpell) do
			local recordTable = {
			  name = slot.name,
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
			
			recordStoreSpells.data.permanentRecords[refId] = recordTable	
		end		
		recordStoreSpells:Save()
	end
end

UltimateScript.OnObjectHit = function(eventStatus, pid, cellDescription, objects, targetPlayers)
	if Players[pid].data.customVariables.ultimateSpell == "nothing" then return end
	local PlayerName = GetName(pid)	
	if ListPlayer[PlayerName].ready then return end	
	for uniqueIndex, object in pairs(objects) do
		if object.hittingPid and object.hit.success then
			if tableHelper.containsValue(LoadedCells[cellDescription].data.packets.actorList, uniqueIndex) then	
				ListPlayer[PlayerName].count = ListPlayer[PlayerName].count + 1				
				if ListPlayer[PlayerName].count >= cfg.CountUltimateHit then				
					ListPlayer[PlayerName] = {
						count = 0,
						spell = Players[pid].data.miscellaneous.selectedSpell,
						ready = true
					}					
					tes3mp.MessageBox(pid, -1, trd.UltimateReady)					
					local SpellId = Players[pid].data.customVariables.ultimateSpell
					AddSpell(pid, {SpellId})					
					Players[pid].data.miscellaneous.selectedSpell = SpellId					
					tes3mp.SetSelectedSpellId(pid, SpellId)					
					tes3mp.SendSelectedSpell(pid)  
				end						
			end		
		end		
	end
end

UltimateScript.OnPlayerSpellsActive = function(eventStatus, pid, playerPacket)
	for spellId, spellInstances in pairs(playerPacket.spellsActive) do	
		if ListSpell[spellId] then
			RemoveSpell(pid, {spellId})	
			local PlayerName = GetName(pid)		
			local SpellId = ListPlayer[PlayerName].spell		
			Players[pid].data.miscellaneous.selectedSpell = SpellId	
			tes3mp.SetSelectedSpellId(pid, SpellId)		
			tes3mp.SendSelectedSpell(pid) 		
			ListPlayer[PlayerName] = {
				count = 0,
				spell = "",
				ready = false
			}	
		end
	end	
end

UltimateScript.OnPlayerAuthentified = function(eventStatus, pid)
	local PlayerName = GetName(pid)
	ListPlayer[PlayerName] = {
		count = 0,
		spell = "",
		ready = false
	}		
	if not Players[pid].data.customVariables.ultimateSpell then
		Players[pid].data.customVariables.ultimateSpell = "nothing"
	end
end

UltimateScript.OnPlayerDeath = function(eventStatus, pid)
	if Players[pid].data.customVariables.ultimateSpell == "nothing" then return end
	local PlayerName = GetName(pid)			
	if ListPlayer[PlayerName].ready then 
		RemoveSpell(pid, {Players[pid].data.customVariables.ultimateSpell})	
		local SpellId = ListPlayer[PlayerName].spell		
		Players[pid].data.miscellaneous.selectedSpell = SpellId	
		tes3mp.SetSelectedSpellId(pid, SpellId)		
		tes3mp.SendSelectedSpell(pid) 		
		ListPlayer[PlayerName] = {
			count = 0,
			spell = "",
			ready = false
		}	
	end
end

UltimateScript.ShowUltimateGUI = function(pid)	
	local PlayerName = GetName(pid)	
	local options = GetUltimateStock(pid)	
	local list = trd.Return	
	for i = 1, #options do		
		list = list..options[i].name..trd.Price..cfg.PriceUltimate
		if not(i == #options) then
			list = list .. "\n"
		end			
	end
	PlayerGUIOptions[PlayerName] = {opt = options}	
	tes3mp.ListBox(pid, cfg.UltGUI, color.CornflowerBlue..trd.Select..color.Default, list)
end

UltimateScript.OnGUIAction = function(eventStatus, pid, idGui, data)
	if idGui == cfg.UltGUI then	
		if tonumber(data) == 0 or tonumber(data) == 18446744073709551615 then			
		else   		
			local Choice = PlayerGUIOptions[GetName(pid)].opt[tonumber(data)]		
			OnBuyChoice(pid, Choice)			
		end		
	end
end

customEventHooks.registerHandler("OnServerInit", UltimateScript.OnServerInit)
customEventHooks.registerHandler("OnPlayerAuthentified", UltimateScript.OnPlayerAuthentified)
customEventHooks.registerHandler("OnObjectHit", UltimateScript.OnObjectHit)
customEventHooks.registerHandler("OnPlayerSpellsActive", UltimateScript.OnPlayerSpellsActive)
customEventHooks.registerHandler("OnGUIAction", UltimateScript.OnGUIAction)
customEventHooks.registerValidator("OnPlayerDeath", UltimateScript.OnPlayerDeath)
customCommandHooks.registerCommand("ultimate", UltimateScript.ShowUltimateGUI)

return UltimateScript
