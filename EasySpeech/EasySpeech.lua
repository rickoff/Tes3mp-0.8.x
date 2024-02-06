--[[
EasySpeech
tes3mp 0.8.1
------------
INSTALLATION :
Save EasySpeech.lua to server/scripts/custom folder
Save textSpeech.json to server/data/custom/EasySpeech folder
Edits to customScripts.lua add in : require("custom.EasySpeech")
Use /speechmenu in chat for open menu
]]
local textSpeech = jsonInterface.load("custom/EasySpeech/textSpeech.json")

local playerChoice = {}

local cfg = {
	MainGUI = 03022024,
	NumberGUI = 04022024,
	InputDialog = 05022024,
	Extention = false
}

local trd = {
	Title = "MENU SPEECH : ",
	Return = "Return",
	Cancel = "Cancel",
	Default = "Speech",
	Edit = "Edit",
	Mod = "Mode",
	StaffWarning = "Changing mode is reserved for staff members.\n",
	InputMessage = "Write the sentence you hear.",
	InputReturn = "enter the number 0 for return/cancel"
}

local function GetName(pid)
	return string.lower(Players[pid].accountName)
end

local function GetValidListNumber(pid, speechType)
    local numberList = {}
	local speechTextList = {}
	local prefix = "default"
	if string.find(speechType, "_") then
		prefix = string.sub(speechType, 1, string.find(speechType, "_") - 1)
		speechType = string.sub(speechType, string.find(speechType, "_") + 1)	
	end
    local race = string.lower(Players[pid].data.character.race)
    local gender = Players[pid].data.character.gender	
    local genderTableName
    if gender == 0 then
        genderTableName = "femaleFiles"
    else
        genderTableName = "maleFiles"
    end  		
	for x = 1, speechCollections[race][prefix][genderTableName][speechType].count do
		local valid = true
		if speechCollections[race][prefix][genderTableName][speechType].skip 
		and tableHelper.containsValue(speechCollections[race][prefix][genderTableName][speechType].skip, x) then
			valid = false
		end
		if valid then
			local stringSpeech = tostring(x)
			local patch = speechHelper.GetSpeechPath(pid, speechType, x)
			if patch then
				if textSpeech[string.lower(patch)] then
					if textSpeech[string.lower(patch)] == "" then
						stringSpeech = string.lower(patch)
					else
						stringSpeech = textSpeech[string.lower(patch)]
					end
				end
			end
			table.insert(speechTextList, stringSpeech)				
			table.insert(numberList, tostring(x))		
		end
	end	
    return numberList, speechTextList
end

local function GetValidListType(speechCollectionTable, gender, collectionPrefix)
    local validList = {}
    local genderTableName
    if gender == 0 then
        genderTableName = "femaleFiles"
    else
        genderTableName = "maleFiles"
    end  
    if speechCollectionTable[genderTableName] ~= nil then
        for speechType, typeDetails in pairs(speechCollectionTable[genderTableName]) do
            local validInput = ""
            if collectionPrefix then
                validInput = collectionPrefix
            end
            validInput = validInput .. speechType
            table.insert(validList, validInput)
        end
    end
    return validList
end

local function GetValidListForPid(pid)
    local validList = {}
    local race = string.lower(Players[pid].data.character.race)
    local gender = Players[pid].data.character.gender
    if speechCollections[race].default ~= nil then
        validList = GetValidListType(speechCollections[race].default, gender)
    end
	if Extention then
		for speechCollectionKey, speechCollectionTable in pairs(speechCollections[race]) do
			if speechCollectionKey ~= "default" then
				tableHelper.insertValues(validList, GetValidListType(speechCollectionTable, gender, speechCollectionKey .. "_"))
			end
		end
	end
	local buttons
	local count = 0
	for index, speechName in pairs(validList) do
		if not buttons then
			buttons = speechName..";"
		else
			buttons = buttons..speechName..";"
		end
		count = count + 1
	end
	buttons = buttons..trd.Return..";"..trd.Cancel..";"..trd.Mod
	return buttons, validList, count
end

local function ShowMainGUI(pid)
	local PlayerName = GetName(pid)	
	local mode = trd.Default
	if playerChoice[PlayerName] and playerChoice[PlayerName].mode then
		mode = playerChoice[PlayerName].mode
	end
	local race = string.lower(Players[pid].data.character.race)	
	local message = (
		color.Orange..trd.Title..race.."\n"..
		color.Yellow..trd.Mod.." : "..mode.."\n"
	)
	local buttons, validList, count = GetValidListForPid(pid)
	playerChoice[PlayerName] = {
		count = count,
		validList = validList,
		numberList = {},
		speechType = "",
		mode = mode
	}
	tes3mp.CustomMessageBox(pid, cfg.MainGUI, message, buttons)
end

local function ShowNumberGUI(pid, data)
	local speechType = playerChoice[GetName(pid)].validList[tonumber(data)+1]
	local message = (
		color.Orange..trd.Title..speechType.."\n"
	)
	local listNumber, listSpeech = GetValidListNumber(pid, speechType)
	local buttons
	for _, stringSpeech in pairs(listSpeech) do
		if not buttons then
			buttons = stringSpeech.."\n"
		else
			buttons = buttons..stringSpeech.."\n"
		end
	end	
	playerChoice[GetName(pid)].numberList = listNumber
	playerChoice[GetName(pid)].speechType = speechType	
	tes3mp.ListBox(pid, cfg.NumberGUI, message, buttons)
end

local function InputDialog(pid)
	local message = trd.InputMessage
	tes3mp.InputDialog(pid, cfg.InputDialog, message, trd.InputReturn)
end

customEventHooks.registerHandler("OnGUIAction", function(eventStatus, pid, idGui, data)
	if idGui == cfg.MainGUI then 
		if tonumber(data) < playerChoice[GetName(pid)].count then
			ShowNumberGUI(pid, data)
		elseif tonumber(data) == playerChoice[GetName(pid)].count then
			Players[pid].currentCustomMenu = "MenuPlayer"	
			menuHelper.DisplayMenu(pid, Players[pid].currentCustomMenu)	
		elseif tonumber(data) == playerChoice[GetName(pid)].count + 1 then	
			--add your return menu here		
		elseif tonumber(data) == playerChoice[GetName(pid)].count + 2 then
			if Players[pid]:IsServerStaff() then
				if playerChoice[GetName(pid)].mode == trd.Default then
					playerChoice[GetName(pid)].mode	= trd.Edit
				else
					playerChoice[GetName(pid)].mode	= trd.Default
				end
			else
				tes3mp.SendMessage(pid, trd.StaffWarning, false)
			end
			ShowMainGUI(pid)
		end		
	elseif idGui == cfg.NumberGUI then 
		if tonumber(data) >= 18446744073709551615 then
			ShowMainGUI(pid)
		else
			speechHelper.PlaySpeech(pid, playerChoice[GetName(pid)].speechType, tonumber(playerChoice[GetName(pid)].numberList[tonumber(data)+1]))
			if playerChoice[GetName(pid)].mode == trd.Edit then
				local path = speechHelper.GetSpeechPath(pid, playerChoice[GetName(pid)].speechType, tonumber(playerChoice[GetName(pid)].numberList[tonumber(data)+1]))
				playerChoice[GetName(pid)].path = string.lower(path)
				InputDialog(pid)
			else
				ShowMainGUI(pid)
			end
		end	
	elseif idGui == cfg.InputDialog then
		if tonumber(data) == 0 then
			ShowMainGUI(pid)
		else
			local path = playerChoice[GetName(pid)].path
			textSpeech[path] = data
			jsonInterface.save("custom/EasySpeech/textSpeech.json", textSpeech)
			ShowMainGUI(pid)	
		end
	end
end)

customCommandHooks.registerCommand("speechmenu", ShowMainGUI)
