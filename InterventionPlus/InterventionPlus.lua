--[[
InterventionPlus
tes3mp 0.8.1
version 0.3
---------------------------
DESCRIPTION :
select the teleport point of the temple of your choice for Almisivi Intervention and the fort of your choice for Divine Intervention
---------------------------
INSTALLATION:
Save the file as InterventionPos.json inside your server/data/custom folder.
Save the file as InterventionPlus.lua inside your server/scripts/custom folder.
Edits to customScripts.lua add :
InterventionPlus = require("custom.InterventionPlus")
---------------------------
cfg :
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

local InterventionPlus = {}

InterventionPlus.OnServerInit = function(eventStatus)
	local recordStoreSpells = RecordStores["spell"]
	local recordTable
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
	recordStoreSpells.data.permanentRecords["divine intervention"] = recordTable
	recordStoreSpells:Save()
end

InterventionPlus.OnPlayerSpellsActiveHandler = function(eventStatus, pid, playerPacket)
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
end

InterventionPlus.OnGUIAction = function(eventStatus, pid, idGui, data)
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
end

customEventHooks.registerHandler("OnGUIAction", InterventionPlus.OnGUIAction)
customEventHooks.registerHandler("OnServerInit", InterventionPlus.OnServerInit)
customEventHooks.registerHandler("OnPlayerSpellsActive", InterventionPlus.OnPlayerSpellsActiveHandler)

return InterventionPlus
