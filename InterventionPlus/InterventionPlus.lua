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
Edits to customScripts.lua add :
InterventionPlus = require("custom.InterventionPlus")
---------------------------
cfg :
Change trad in your language for your server
Change cfg GUI numbers for a unique numbers 
]]

local DataPos = jsonInterface.load("custom/InterventionPos.json")

---------------------------
--------CONFIGURATION------
---------------------------
local trad = {
	BackList = "* Return *\n",
	SelectPos = color.Green.."Select a location to teleport to",
	ChoicePos = color.Yellow.."Select an option",
	ChoicePosOpt = "Teleport;Cancel"
}

local cfg = {
	OnServerInit = false,
	AlmisiviId = "almsivi intervention",
	DivineId = "divine intervention",
	costAlmi = 8,
	costDivi = 8,
	MainGUI = 28022023,
	ChoiceGUI = 28022024
}

local playerChoice = {}

local posTab = {}
---------------------------
--------FUNCTION-----------
---------------------------
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

---------------------------
--------EVENTS-------------
---------------------------
local InterventionPlus = {}

InterventionPlus.OnServerInit = function(eventStatus)

	if cfg.OnServerInit then
		local recordStoreSpells = RecordStores["spell"]
		local recordTable
		
		recordTable = {
		  name = "Almsivi Intervention",
		  subtype = 0,
		  cost = cfg.costAlmi,
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
		  name = "Divine Intervention",
		  subtype = 0,
		  cost = cfg.costDivi,
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
end

InterventionPlus.OnPlayerSpellsActiveValidator = function(eventStatus, pid, playerPacket)

	local action = playerPacket.action
	
	for spellId, spellInstances in pairs(playerPacket.spellsActive) do  
	
		if spellId == cfg.AlmisiviId and action == enumerations.spellbook.ADD then
			
			ListPos(pid, "Almi")
			
			return customEventHooks.makeEventStatus(false, false)
			
		elseif spellId == cfg.DivineId and action == enumerations.spellbook.ADD then
		
			ListPos(pid, "Divi")
			
			return customEventHooks.makeEventStatus(false, false)
			
		end	
		
	end
end

InterventionPlus.OnGUIAction = function(pid, idGui, data) 
	if idGui == cfg.MainGUI then -- Main
		if tonumber(data) == 0 or tonumber(data) == 18446744073709551615 then --Close/Nothing
			return true
		else   
			SelectChoice(pid, tonumber(data)) --Select
			return true
		end
	elseif idGui == cfg.ChoiceGUI then -- Choice
		if tonumber(data) == 0 then --Recall
			RecallPlayer(pid)
			return true
		elseif tonumber(data) == 1 then --Cancel
			return true	
		end
	end
end

InterventionPlus.OnPlayerAuthentified = function(eventStatus, pid)
	if not Players[pid].data.customVariables.markLocation then
		Players[pid].data.customVariables.markLocation = {}
		Players[pid]:QuicksaveToDrive()
	end
end

customEventHooks.registerValidator("OnPlayerSpellsActive", InterventionPlus.OnPlayerSpellsActiveValidator)
customEventHooks.registerHandler("OnPlayerAuthentified", InterventionPlus.OnPlayerAuthentified)
customEventHooks.registerHandler("OnGUIAction", function(eventStatus, pid, idGui, data)
	if InterventionPlus.OnGUIAction(pid, idGui, data) then return end	
end)
customEventHooks.registerHandler("OnServerInit", InterventionPlus.OnServerInit)

return InterventionPlus
