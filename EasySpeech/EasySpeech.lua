--[[
EasySpeech
tes3mp 0.8.1
------------
INSTALLATION :
Edits to customScripts.lua add in :
require("custom.EasySpeech")
------------
/speechmenu for open menu speech
]]
local playerChoice = {}

local cfg = {
	MainGUI = 03022024,
	NumberGUI = 04022024
}

local trd = {
	Title = "MENU SPEECH : ",
	Return = "Return",
	Cancel = "Cancel"
}

local function GetName(pid)
	return string.lower(Players[pid].accountName)
end
	
local function GetValidListNumber(pid, speechType)
    local validList = {}
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
			table.insert(validList, tostring(x))		
		end
	end
    return validList
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
    for speechCollectionKey, speechCollectionTable in pairs(speechCollections[race]) do
        if speechCollectionKey ~= "default" then
            tableHelper.insertValues(validList, GetValidListType(speechCollectionTable, gender, speechCollectionKey .. "_"))
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
	buttons = buttons..trd.Return..";"..trd.Cancel
	return buttons, validList, count
end

local function ShowMainGUI(pid)
	local message = (
		color.Orange..trd.Title.."\n\n"
	)
	local buttons, validList, count = GetValidListForPid(pid)
	playerChoice[GetName(pid)] = {
		count = count,
		validList = validList,
		numberList = {},
		speechType = ""
	}
	tes3mp.CustomMessageBox(pid, cfg.MainGUI, message, buttons)
end

local function ShowNumberGUI(pid, data)
	local speechType = playerChoice[GetName(pid)].validList[tonumber(data)+1]
	local message = (
		color.Orange..trd.Title..speechType.."\n"
	)
	local listNumber = GetValidListNumber(pid, speechType)
	local buttons
	for index, number in pairs(listNumber) do
		if not buttons then
			buttons = number.."\n"
		else
			buttons = buttons..number.."\n"
		end
	end	
	playerChoice[GetName(pid)].numberList = listNumber
	playerChoice[GetName(pid)].speechType = speechType	
	tes3mp.ListBox(pid, cfg.NumberGUI, message, buttons)
end

customEventHooks.registerHandler("OnGUIAction", function(eventStatus, pid, idGui, data)
	if idGui == cfg.MainGUI then 
		if tonumber(data) < playerChoice[GetName(pid)].count then
			ShowNumberGUI(pid, data)
		elseif tonumber(data) == playerChoice[GetName(pid)].count then
            --add your return menu
		end	
	elseif idGui == cfg.NumberGUI then 
		if tonumber(data) == 0 or tonumber(data) == 18446744073709551615 then
			ShowMainGUI(pid)
		else
			speechHelper.PlaySpeech(pid, playerChoice[GetName(pid)].speechType, tonumber(playerChoice[GetName(pid)].numberList[tonumber(data)]))
			ShowMainGUI(pid)
		end	
	end
end)

customCommandHooks.registerCommand("speechmenu", ShowMainGUI)
