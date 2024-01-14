--[[
--[[
MultiMark
tes3mp 0.8.1
script version 1.0
---------------------------
INSTALLATION:
Save the file as MultiMark.lua inside your server/scripts/custom folder.
Edits to customScripts.lua add : require("custom.MultiMark")
---------------------------
CONFIGURATION :
Change trad in your language for your server
Change cfg MaxMark for config limite mark
Change cfg GUI numbers for a unique numbers 
]]
---------------------------
local trad = {
	BackList = "* Back *\n",
	LimiteMark = color.Red.."The number of mark is limited to : ",
	SelectMark = color.Green.."Select a mark to recall or remove",
	ChoiceMark = color.Yellow.."Select an option",
	ChoiceMarkOpt = "Recall;Remove",
	AddNewMark = "New mark at\n",
	NameMark = "Mark",
	NameRecall = "Recall"
}

local cfg = {
	OnServerInit = true,	
	MaxMark = 5,
	costMark = 18,
	costRecall = 18,
	MainGUI = 21092022,
	ChoiceGUI = 21092023
}
	
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
	else
		tes3mp.MessageBox(pid, -1, trad.LimiteMark..color.Green..cfg.MaxMark)
	end
end

local function RemoveMark(pid)
	local index = playerIndex[GetName(pid)]
	Players[pid].data.customVariables.markLocation[index] = nil	
	tableHelper.cleanNils(Players[pid].data.customVariables.markLocation)
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

customEventHooks.registerHandler("OnServerInit", function(eventStatus)
	if cfg.OnServerInit then
		local recordStoreSpells = RecordStores["spell"]
		local recordTable
		recordTable = {
			name = trad.NameMark,
			cost = cfg.costMark,	  
			subtype = 0,
			flags = 1,
			effects = {
				{
					attribute = -1,
					area = 0,
					duration = 0,
					id = 60,
					rangeType = 0,
					skill = -1,
					magnitudeMax = 0,
					magnitudeMin = 0
				}
			}
		}
		recordStoreSpells.data.permanentRecords["mark"] = recordTable
		recordTable = {
			name = trad.NameRecall,
			cost = cfg.costRecall,		
			subtype = 0,
			flags = 1,
			effects = {
				{
					attribute = -1,
					area = 0,
					duration = 0,
					id = 61,
					rangeType = 0,
					skill = -1,
					magnitudeMax = 0,
					magnitudeMin = 0
				}
			}
		}
		recordStoreSpells.data.permanentRecords["recall"] = recordTable
		recordStoreSpells:Save()
		local recordStoreEnchant = RecordStores["enchantment"]	
		recordTable = {
			cost = cfg.costMark,		
			subtype = 2,
			flags = 90,
			charge = 90,
			effects = {
				{
					attribute = -1,
					area = 0,
					duration = 0,
					id = 60,
					rangeType = 0,
					skill = -1,
					magnitudeMax = 0,
					magnitudeMin = 0
				}
			}
		}
		recordStoreEnchant.data.permanentRecords["mark_en"] = recordTable	
		recordStoreEnchant.data.permanentRecords["markring_en"] = recordTable		
		recordTable = {
			cost = cfg.costMark,		
			subtype = 0,
			flags = 18,
			charge = 18,
			effects = {
				{
					attribute = -1,
					area = 0,
					duration = 0,
					id = 60,
					rangeType = 0,
					skill = -1,
					magnitudeMax = 0,
					magnitudeMin = 0
				}
			}
		}
		recordStoreEnchant.data.permanentRecords["sc_mark_en"] = recordTable
		recordTable = {
			cost = cfg.costRecall,		
			subtype = 2,
			flags = 90,
			charge = 90,
			effects = {
				{
					attribute = -1,
					area = 0,
					duration = 0,
					id = 61,
					rangeType = 0,
					skill = -1,
					magnitudeMax = 0,
					magnitudeMin = 0
				}
			}
		}
		recordStoreEnchant.data.permanentRecords["recallring_en"] = recordTable	
		recordStoreEnchant.data.permanentRecords["recall_en"] = recordTable		
		recordTable = {
			cost = cfg.costRecall,		
			subtype = 0,
			flags = 18,
			charge = 18,
			effects = {
				{
					attribute = -1,
					area = 0,
					duration = 0,
					id = 61,
					rangeType = 0,
					skill = -1,
					magnitudeMax = 0,
					magnitudeMin = 0
				}
			}
		}
		recordStoreEnchant.data.permanentRecords["sc_leaguestep_en"] = recordTable	
		recordStoreEnchant:Save()
	end
end)

customEventHooks.registerHandler("OnPlayerSpellsActive", function(eventStatus, pid, playerPacket)
	for spellId, spellInstances in pairs(playerPacket.spellsActive) do	
		for _, spellInstance in ipairs(spellInstances) do	
			for _, effect in ipairs(spellInstance.effects) do		
				if effect.id == enumerations.effects.MARK then
					AddMark(pid)
					break
				elseif effect.id == enumerations.effects.RECALL then			
					ListMark(pid)
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
		elseif tonumber(data) == 1 then
			RemoveMark(pid)
			ListMark(pid)		
		end
	end
end)

customEventHooks.registerHandler("OnPlayerAuthentified", function(eventStatus, pid)
	if not Players[pid].data.customVariables.markLocation then
		Players[pid].data.customVariables.markLocation = {}
	end
end)

customEventHooks.registerValidator("OnRecordDynamic", function(eventStatus, pid, recordArray, storeType)
	if storeType == "enchantment" or storeType == "spell" or storeType == "potion" then	
		for _, record in ipairs(recordArray) do			
			for _, effect in ipairs(record.effects) do			
				if effect.id == enumerations.effects.MARK or effect.id == enumerations.effects.RECALL then
					effect.magnitudeMin = 0					
					effect.magnitudeMax = 0				
				end					
			end	
		end
	end
end)
