--[[
InterventionPlus
tes3mp 0.8.1
---------------------------
DESCRIPTION :
select the teleport point of the temple of your choice for Almisivi Intervention and the fort of your choice for Divine Intervention
---------------------------
INSTALLATION:
Save the file as InterventionPos.json inside your server/data/custom folder.
Save the file as InterventionPlus.lua inside your server/scripts/custom folder.
Edits to customScripts.lua add : require("custom.InterventionPlus")
---------------------------
CONFIGURATION :
Change trad in your language for your server
Change cfg GUI numbers for a unique numbers 
]]
local DataPos = jsonInterface.load("custom/InterventionPos.json")

local trad = {
	BackList = "* Return *\n",
	SelectPos = color.Green.."Select a location to teleport to",
	ChoicePos = color.Yellow.."Select an option",
	ChoicePosOpt = "Teleport;Cancel",
	NameAlmi = "Almsivi Intervention",	
	NameDivi = "Divine Intervention"
}

local cfg = {
	OnServerInit = true,
	CostDivi = 8,
	CostAlmi = 8,	
	MainGUI = 28022023,
	ChoiceGUI = 28022024
}

local playerChoice = {}

local posTab = {}

local function GetName(pid)
	return string.lower(Players[pid].accountName)
end

local function SelectChoice(pid, index)
	playerChoice[GetName(pid)] = posTab[GetName(pid)][index]
	tes3mp.CustomMessageBox(pid, cfg.ChoiceGUI, trad.ChoicePos, trad.ChoicePosOpt)	
end

local function ListPos(pid, type)
	local list = trad.BackList 	
	local options = DataPos[type]	
	for i = 1, #options do	
		list = list..options[i].name.." : "..math.floor(options[i].location.posX).." ; "..math.floor(options[i].location.posY).." ; "..math.floor(options[i].location.posZ)	
		if not(i == #options) then
			list = list .. "\n"
		end
	end	
	posTab[GetName(pid)] = options	
	tes3mp.ListBox(pid, cfg.MainGUI, trad.SelectPos..color.Default, list)	
end

local function RecallPlayer(pid)
	local data = playerChoice[GetName(pid)]
	local cell = data.cellDescription			
	local posX = data.location.posX
	local posY = data.location.posY
	local posZ = data.location.posZ
	local rotX = data.location.rotX
	local rotZ = data.location.rotZ      
	tes3mp.SetCell(pid, cell)
	tes3mp.SendCell(pid)
	tes3mp.SetPos(pid, posX, posY, posZ)
	tes3mp.SetRot(pid, rotX, rotZ)				
	tes3mp.SendPos(pid)
	posTab[GetName(pid)] = nil
	playerChoice[GetName(pid)] = nil
end

customEventHooks.registerHandler("OnServerInit", function(eventStatus)
	if cfg.OnServerInit then
		local recordTable
		local recordStoreSpells = RecordStores["spell"]
		recordTable = {
		  name = trad.NameAlmi,
		  cost = cfg.CostAlmi,	  
		  subtype = 0,
		  flags = 1,
		  effects = {{
			attribute = -1,
			area = 0,
			duration = 0,
			id = 63,
			rangeType = 0,
			skill = -1,
			magnitudeMax = 0,
			magnitudeMin = 0
			}}
		}
		recordStoreSpells.data.permanentRecords["almsivi intervention"] = recordTable
		recordTable = {
		  name = trad.NameDivi,
		  cost = cfg.CostDivi,	  
		  subtype = 0,
		  flags = 1,
		  effects = {{
			attribute = -1,
			area = 0,
			duration = 0,
			id = 62,
			rangeType = 0,
			skill = -1,
			magnitudeMax = 0,
			magnitudeMin = 0
			}}
		}		
		local recordStoreEnchant = RecordStores["enchantment"]
		recordTable = {
		  cost = cfg.CostAlmi,	  
		  subtype = 2,
		  flags = 40,
		  charge = 40,  
		  effects = {{
			attribute = -1,
			area = 0,
			duration = 0,
			id = 63,
			rangeType = 0,
			skill = -1,
			magnitudeMax = 0,
			magnitudeMin = 0
			}}
		}
		recordStoreEnchant.data.permanentRecords["almsivi intervention_en"] = recordTable
		recordTable = {
		  cost = cfg.CostAlmi,	  
		  subtype = 0,
		  flags = 8,
		  charge = 8,  
		  effects = {{
			attribute = -1,
			area = 0,
			duration = 0,
			id = 63,
			rangeType = 0,
			skill = -1,
			magnitudeMax = 0,
			magnitudeMin = 0
			}}
		}
		recordStoreEnchant.data.permanentRecords["almsivi intervention enchantmen"] = recordTable
		recordTable = {
		  cost = cfg.CostAlmi,	  
		  subtype = 2,
		  flags = 40,
		  charge = 40,  
		  effects = {{
			attribute = -1,
			area = 0,
			duration = 0,
			id = 63,
			rangeType = 0,
			skill = -1,
			magnitudeMax = 0,
			magnitudeMin = 0
			}}
		}
		recordStoreEnchant.data.permanentRecords["divine intervention_en"] = recordTable
		recordTable = {
		  cost = cfg.CostAlmi,	  
		  subtype = 0,
		  flags = 8,
		  charge = 8,  
		  effects = {{
			attribute = -1,
			area = 0,
			duration = 0,
			id = 62,
			rangeType = 0,
			skill = -1,
			magnitudeMax = 0,
			magnitudeMin = 0
			}}
		}
		recordStoreEnchant.data.permanentRecords["divine intervention enchantmen"] = recordTable	
		recordStoreEnchant:Save()	
	end
end)

customEventHooks.registerHandler("OnPlayerSpellsActive", function(eventStatus, pid, playerPacket)
	for spellId, spellInstances in pairs(playerPacket.spellsActive) do
		for _, spellInstance in ipairs(spellInstances) do	
			for _, effect in ipairs(spellInstance.effects) do		
				if effect.id == enumerations.effects.ALMSIVI_INTERVENTION then
					ListPos(pid, "Almi")
					break
				elseif effect.id == enumerations.effects.DIVINE_INTERVENTION then		
					ListPos(pid, "Divi")
					break
				end
			end	
		end
	end	
end)

customEventHooks.registerHandler("OnGUIAction", function(eventStatus, pid, idGui, data)
	if idGui == cfg.MainGUI then
		if tonumber(data) == 0 or tonumber(data) == 18446744073709551615 then
		else   
			SelectChoice(pid, tonumber(data))
		end
	elseif idGui == cfg.ChoiceGUI then
		if tonumber(data) == 0 then
			RecallPlayer(pid)
		end
	end
end)

customEventHooks.registerValidator("OnRecordDynamic", function(eventStatus, pid, recordArray, storeType)
	if storeType == "enchantment" or storeType == "spell" or storeType == "potion" then	
		for _, record in ipairs(recordArray) do			
			for _, effect in ipairs(record.effects) do			
				if effect.id == enumerations.effects.ALMSIVI_INTERVENTION or effect.id == enumerations.effects.DIVINE_INTERVENTION then
					effect.magnitudeMin = 0					
					effect.magnitudeMax = 0				
				end					
			end	
		end
	end
end)
