--[[
MultiMark
tes3mp 0.8.1
script version 0.7
---------------------------
DESCRIPTION :
USE DIRECTLY SPELL MARK AND RECALL
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

local trad = {}
trad.BackList = "* Back *\n"
trad.LimiteMark = color.Red.."The number of mark is limited to : "
trad.SelectMark = color.Green.."Select a mark to recall or remove"
trad.ChoiceMark = color.Yellow.."Select an option"
trad.ChoiceMarkOpt = "Recall;Remove"
trad.AddNewMark = "New mark at\n"

local cfg = {}
cfg.MaxMark = 5
cfg.MainGUI = 21092022
cfg.ChoiceGUI = 21092023

local playerIndex = {}

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
    for i = 1, #options do
		list = list..string.sub(options[i].cell, 1, 25).." : "..math.floor(options[i].posX).." ; "..math.floor(options[i].posY).." ; "..math.floor(options[i].posZ)		
        if not(i == #options) then
            list = list .. "\n"
        end
    end
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

local MultiMark = {}

MultiMark.OnPlayerSpellsActiveValidator = function(eventStatus, pid, playerPacket)
	for spellId, spellInstances in pairs(playerPacket.spellsActive) do	
		for _, spellInstance in ipairs(spellInstances) do	
			for _, effect in ipairs(spellInstance.effects) do		
				if effect.id == enumerations.effects.MARK then
					effect.magnitude = 0
					AddMark(pid)
					break
				elseif effect.id == enumerations.effects.RECALL then
					effect.magnitude = 0			
					ListMark(pid)
					break
				end
			end	
		end
	end
end

MultiMark.OnGUIAction = function(eventStatus, pid, idGui, data)
	if idGui == cfg.MainGUI then
		if tonumber(data) == 0 or tonumber(data) == 18446744073709551615 then --Close/Nothing
		else   
			SelectChoice(pid, tonumber(data))
		end
	elseif idGui == cfg.ChoiceGUI then
		if tonumber(data) == 0 then
			RecallPlayer(pid)
		elseif tonumber(data) == 1 then
			RemoveMark(pid)
			return ListMark(pid)		
		end
	end
end

MultiMark.OnPlayerAuthentified = function(eventStatus, pid)
	if not Players[pid].data.customVariables.markLocation then
		Players[pid].data.customVariables.markLocation = {}
		Players[pid]:QuicksaveToDrive()
	end
end

customEventHooks.registerValidator("OnPlayerSpellsActive", MultiMark.OnPlayerSpellsActiveValidator)
customEventHooks.registerHandler("OnPlayerAuthentified", MultiMark.OnPlayerAuthentified)
customEventHooks.registerHandler("OnGUIAction", MultiMark.OnGUIAction)

return MultiMark
