--[[
MultiMark
tes3mp 0.8.0
script version 0.5
---------------------------
DESCRIPTION :
multi mark location with /mark and /recall command
OR USE DIRECTLY SPELL MARK AND RECALL
---------------------------
INSTALLATION:
Save the file as MultiMark.lua inside your server/scripts/custom folder.
Edits to customScripts.lua add :
MultiMark = require("custom.MultiMark")
---------------------------
cfg :
Change trad in your language for your server
Change cfg MaxMark for config limite mark
Change cfg GUI numbers for a unique numbers 
]]

---------------------------
--------CONFIGURATION------
---------------------------
local trad = {}
trad.BackList = "* Back *\n"
trad.LimiteMark = color.Red.."The number of mark is limited to : "
trad.SelectMark = color.Green.."Select a mark to recall or remove"
trad.ChoiceMark = color.Yellow.."Select an option"
trad.ChoiceMarkOpt = "Recall;Remove"
trad.AddNewMark = "New mark at\n"

local cfg = {}
cfg.MarkId = "mark"
cfg.RecallId = "recall"
cfg.MaxMark = 5
cfg.costMark = 18
cfg.costRecall = 18
cfg.MainGUI = 21092022
cfg.ChoiceGUI = 21092023

local playerIndex = {}

---------------------------
--------FUNCTION-----------
---------------------------
local function GetName(pid)
	return string.lower(Players[pid].accountName)
end

local function SelectChoice(pid, index)
	playerIndex[GetName(pid)] = index
	tes3mp.CustomMessageBox(pid, cfg.ChoiceGUI, trad.ChoiceMark, trad.ChoiceMarkOpt)	
end

local function ListMark(pid)
    local options = Players[pid].data.customVariables.markLocation
    local list = trad.BackList 
    local listItemChanged = false
    local listItem = ""
	
    for i = 1, #options do
 
		for x, slot in pairs(Players[pid].data.customVariables.markLocation) do	
			if slot == options[i] then
				listItem = string.sub(slot.cell, 1, 25).." : "..math.floor(slot.posX).." ; "..math.floor(slot.posY).." ; "..math.floor(slot.posZ)
				listItemChanged = true
				break
			else
				listItemChanged = false
			end
		end
		
		if listItemChanged == true then
			list = list .. listItem
		end
		
		if listItemChanged == false then
			list= list .. "\n"
		end
		
        if not(i == #options) then
            list = list .. "\n"
        end
    end
	
	listItemChanged = false
	tes3mp.ListBox(pid, cfg.MainGUI, trad.SelectMark..color.Default, list)	
end

local function CountMark(pid)
	local count = 0
	for x, slot in pairs(Players[pid].data.customVariables.markLocation) do
		count = count + 1
	end
	return count
end

local function AddMark(pid)
	if CountMark(pid) < cfg.MaxMark then
		local tablePos = {}
		tablePos.cell = tes3mp.GetCell(pid)
		tablePos.posX = tes3mp.GetPosX(pid)
		tablePos.posY = tes3mp.GetPosY(pid)
		tablePos.posZ = tes3mp.GetPosZ(pid)
		tablePos.rotX = tes3mp.GetRotX(pid)
		tablePos.rotZ = tes3mp.GetRotZ(pid) 			
		table.insert(Players[pid].data.customVariables.markLocation, tablePos)
		tes3mp.MessageBox(pid, -1, trad.AddNewMark..color.Green..tablePos.cell.."\n"..color.White..math.floor(tablePos.posX).." ; "..math.floor(tablePos.posY).." ; "..math.floor(tablePos.posZ))
		Players[pid]:QuicksaveToDrive()
	else
		tes3mp.MessageBox(pid, -1, trad.LimiteMark..color.Green..cfg.MaxMark)
	end
end

local function RemoveMark(pid)
	local index = playerIndex[GetName(pid)]
	Players[pid].data.customVariables.markLocation[index] = nil	
	tableHelper.cleanNils(Players[pid].data.customVariables.markLocation)
	Players[pid]:QuicksaveToDrive()
end

local function RecallPlayer(pid)
	local index = playerIndex[GetName(pid)]
	local cell = Players[pid].data.customVariables.markLocation[index].cell			
	local posX = Players[pid].data.customVariables.markLocation[index].posX
	local posY = Players[pid].data.customVariables.markLocation[index].posY
	local posZ = Players[pid].data.customVariables.markLocation[index].posZ
	local rotX = Players[pid].data.customVariables.markLocation[index].rotX
	local rotZ = Players[pid].data.customVariables.markLocation[index].rotZ      
	tes3mp.SetCell(pid, cell)
	tes3mp.SendCell(pid)
	tes3mp.SetPos(pid, posX, posY, posZ)
	tes3mp.SetRot(pid, rotX, rotZ)				
	tes3mp.SendPos(pid)		
end

---------------------------
--------EVENTS-------------
---------------------------
local MultiMark = {}

MultiMark.OnServerInit = function(eventStatus)

	local recordStoreSpells = RecordStores["spell"]
	local recordTable
	
	recordTable = {
	  name = "Mark",
	  subtype = 0,
	  cost = cfg.costMark,
	  flags = 1,
	  effects = {{
        attribute = -1,
        area = 0,
        duration = 0,
        id = 61,
        rangeType = 0,
        skill = -1,
        magnitudeMax = 0,
        magnitudeMin = 0
		}}
	}
	recordStoreSpells.data.permanentRecords["mark"] = recordTable

	recordTable = {
	  name = "Recall",
	  subtype = 0,
	  cost = cfg.costRecall,
	  flags = 1,
	  effects = {{
        attribute = -1,
        area = 0,
        duration = 0,
        id = 61,
        rangeType = 0,
        skill = -1,
        magnitudeMax = 0,
        magnitudeMin = 0
		}}
	}
	recordStoreSpells.data.permanentRecords["recall"] = recordTable
	
	recordStoreSpells:Save()
end

MultiMark.OnPlayerSpellsActiveHandler = function(eventStatus, pid, playerPacket)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
		local action = playerPacket.action
		for spellId, spellInstances in pairs(playerPacket.spellsActive) do  
			if spellId == cfg.MarkId and action == enumerations.spellbook.ADD then
				AddMark(pid)
				break
			elseif spellId == cfg.RecallId and action == enumerations.spellbook.ADD then
				ListMark(pid)
				break
			end			
		end
	end
end

MultiMark.CommandAddMark = function(pid)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
		AddMark(pid)
	end
end

MultiMark.CommandRecallMark = function(pid)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
		ListMark(pid)
	end
end

MultiMark.OnGUIAction = function(pid, idGui, data)
 	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then  
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
			elseif tonumber(data) == 1 then --Remove
				RemoveMark(pid)
				return ListMark(pid)		
			end
		end
		
	end
end

MultiMark.OnPlayerAuthentified = function(eventStatus, pid)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
		if not Players[pid].data.customVariables.markLocation then
			Players[pid].data.customVariables.markLocation = {}
			Players[pid]:QuicksaveToDrive()
		end
	end
end

customEventHooks.registerHandler("OnPlayerSpellsActive", MultiMark.OnPlayerSpellsActiveHandler)
customCommandHooks.registerCommand("mark", MultiMark.CommandAddMark)
customCommandHooks.registerCommand("recall", MultiMark.CommandRecallMark)
customEventHooks.registerHandler("OnPlayerAuthentified", MultiMark.OnPlayerAuthentified)
customEventHooks.registerHandler("OnGUIAction", function(eventStatus, pid, idGui, data)
	if MultiMark.OnGUIAction(pid, idGui, data) then return end	
end)
customEventHooks.registerHandler("OnServerInit", MultiMark.OnServerInit)

return MultiMark
