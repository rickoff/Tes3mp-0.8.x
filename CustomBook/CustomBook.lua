--[[
MailScript
tes3mp 0.8.1
---------------------------
INSTALLATION:
Save the file as MailScript.lua inside your server/scripts/custom folder.
Edits to customScripts.lua
require("custom.MailScript")
Create folder server/data/custom/MailScript/
---------------------------
]]
local cfg = {
	MainMenu = 08092024,
	PlayerSentList = 09092024,
	MessageInput = 10092024,
	MessageList = 11092024,
	PlayerReceiveList = 12092024,
	MessageReceiveList = 13092024,
	MessageReceive = 14092024,
	OnlyStaffCommand = true
}

local trd = {
	MainTitle = "MESSAGING\n\nNew Message: ",
	TotalMessage = "\nTotal messages: ",
	MainOption = "New;Inbox;Back;Quit",
	NewMsgTitle = "NEW MESSAGE",
	ReceiveMsgTitle = "INBOX",
	ListReturn = "*Back*\n",
	Connected = " connected\n",
	Disconnected = " disconnected\n",
	InputTitle = "Write the message for the recipient",
	ChoiceMessage = "Delete;Back;Quit",
	DeleteMsg = color.Red.."[MESSAGING] - You have deleted a message from: ",
	SentMsg = color.Green.."[MESSAGING] - You have sent a message to: ",
	ReceiveMsg = color.Green.."[MESSAGING] - You have received a message from: ",
	NewMsgAuth = color.Green.."[MESSAGING] - You have ",
	NewMsg = " new messages\n",
	NeedPaper = "You lack the paper to write a letter."
}

local MailData = jsonInterface.load("custom/MailScript/MailData.json")
if MailData == nil then
	MailData = {}
end

local SelectedPlayer = {}

local function SaveData()
	jsonInterface.save("custom/MailScript/MailData.json", MailData)
end

function ConvertOsTime()
    local t = os.date("*t", os.time())
    local formatted_time = string.format("%02d:%02d:%02d:%02d:%02d:%04d", t.hour, t.min, t.sec, t.day, t.month, t.year)
    return formatted_time
end

local function ShowMainGUI(pid)
	local countMessageNotReading = 0
	local countMessageReading = 0	
	local playerName = GetName(pid)	
	for targetName, slot in pairs(MailData[playerName]) do
		for timer, data in pairs(slot) do
			if data.reading then
				countMessageReading = countMessageReading + 1
			else
				countMessageNotReading = countMessageNotReading + 1
			end
		end
	end
	local title = trd.MainTitle..countMessageNotReading..trd.TotalMessage..countMessageReading + countMessageNotReading
	tes3mp.CustomMessageBox(pid, cfg.MainMenu, title, trd.MainOption)	
end

local function ShowPlayerSentListGUI(pid)
	local playerName = GetName(pid)
	local list = trd.ListReturn
	local nameList = {}
	SelectedPlayer[playerName] = {}
	SelectedPlayer[playerName] = {
		targetName = {},
		timer = {},
		message = {}
	}	
	for targetPid, player in pairs(Players) do
		local targetName = GetName(targetPid)
		list = list..GetName(targetPid)..trd.Connected
		nameList[targetName] = true		
		table.insert(SelectedPlayer[playerName].targetName, targetName)
	end
	for targetName, data in pairs(MailData) do
		if not nameList[targetName] then
			list = list..targetName..trd.Disconnected
			table.insert(SelectedPlayer[playerName].targetName, targetName)			
		end
	end
	tes3mp.ListBox(pid, cfg.PlayerSentList, trd.NewMsgTitle, list)
end

local function InputMessage(pid)
	tes3mp.InputDialog(pid, cfg.MessageInput, trd.InputTitle, "")
end

local function SaveMessageInput(pid, message)
	if inventoryHelper.containsItem(Players[pid].data.inventory,"sc_paper plain") then
		inventoryHelper.removeItem(Players[pid].data.inventory,"sc_paper plain",1)
	elseif inventoryHelper.containsItem(Players[pid].data.inventory,"sc_paper_plain_01_canodia") then
		inventoryHelper.removeItem(Players[pid].data.inventory,"sc_paper_plain_01_canodia",1)
	else
		tes3mp.SendMessage(pid, color.Red..trd.NeedPaper)
		return
	end
	local playerName = GetName(pid)
	local targetName = SelectedPlayer[playerName].targetName
	local messageTime = ConvertOsTime()
	if not MailData[targetName] then
		MailData[targetName] = {}
	end
	if not MailData[targetName][playerName] then
		MailData[targetName][playerName] = {}
	end
	if not MailData[targetName][playerName][messageTime] then
		MailData[targetName][playerName][messageTime] = {}
	end
	MailData[targetName][playerName][messageTime] = {
		message = tostring(message),
		reading = false
	}
	if logicHandler.GetPlayerByName(targetName) then
		local targetPid = logicHandler.GetPlayerByName(targetName).pid
		tes3mp.SendMessage(targetPid, trd.ReceiveMsg..playerName.."\n", false)
		PlaySound(targetPid, "book open")		
	end
	tes3mp.SendMessage(pid, trd.SentMsg..targetName.."\n", false)	
	PlaySound(pid, "mysticism area")
	SaveData()
end

local function ShowPlayerReceiveListGUI(pid)
	local playerName = GetName(pid)
	local list = trd.ListReturn
	SelectedPlayer[playerName] = {}
	SelectedPlayer[playerName] = {
		targetName = {},
		timer = {},		
		message = {}
	}	
	for targetName, data in pairs(MailData[playerName]) do
		list = list..targetName
		table.insert(SelectedPlayer[playerName].targetName, targetName)
	end
	tes3mp.ListBox(pid, cfg.PlayerReceiveList, trd.ReceiveMsgTitle, list)
end

local function ShowMessageReceiveList(pid)
	local playerName = GetName(pid)
	local targetName = SelectedPlayer[playerName].targetName
	local list = trd.ListReturn
	local count = 0
	for timer, data in pairs(MailData[playerName][targetName]) do
		if data.reading then
			list = list..color.Green..timer.." | "..data.message.."\n"
		else
			list = list..color.Red..timer.." | "..data.message.."\n"
		end
		table.insert(SelectedPlayer[playerName].timer, timer)
		table.insert(SelectedPlayer[playerName].message, data.message)
		count = count + 1
	end	
	tes3mp.ListBox(pid, cfg.MessageReceiveList, targetName.."\n"..color.Green..count, list)
end

local function ShowMessageReceive(pid)
	local playerName = GetName(pid)
	local targetName = SelectedPlayer[playerName].targetName	
	local timer = SelectedPlayer[playerName].timer
	MailData[playerName][targetName][timer].reading = true
	tes3mp.CustomMessageBox(pid, cfg.MessageReceive, targetName.."\n"..timer.."\n\n"..SelectedPlayer[playerName].message, trd.ChoiceMessage)
end

local function DeleteMessage(pid)
	local playerName = GetName(pid)
	local targetName = SelectedPlayer[playerName].targetName
	local timer = SelectedPlayer[playerName].timer
	MailData[playerName][targetName][timer] = nil
	tes3mp.SendMessage(pid, trd.DeleteMsg..targetName.."\n", false)	
	PlaySound(pid, "book close")	
	SaveData()
end

customEventHooks.registerHandler("OnGUIAction", function(eventStatus, pid, idGui, data)
	if idGui == cfg.MainMenu then 
		if tonumber(data) == 0 then
			ShowPlayerSentListGUI(pid)		
		elseif tonumber(data) == 1 then
			ShowPlayerReceiveListGUI(pid)
		elseif tonumber(data) == 2 then
		elseif tonumber(data) == 3 then		
		end
	elseif idGui == cfg.PlayerSentList then 
		if tonumber(data) == 0 or tonumber(data) == 18446744073709551615 then   		
			ShowMainGUI(pid)			
		else   	
			SelectedPlayer[GetName(pid)].targetName = SelectedPlayer[GetName(pid)].targetName[tonumber(data)]
			InputMessage(pid)
		end 	
	elseif idGui == cfg.MessageInput then
		if data and data ~= "" then
			SaveMessageInput(pid, data)
			ShowMainGUI(pid)
		end
	elseif idGui == cfg.PlayerReceiveList then 
		if tonumber(data) == 0 or tonumber(data) == 18446744073709551615 then   		
			ShowMainGUI(pid)			
		else   	
			SelectedPlayer[GetName(pid)].targetName = SelectedPlayer[GetName(pid)].targetName[tonumber(data)]
			ShowMessageReceiveList(pid)
		end 
	elseif idGui == cfg.MessageReceiveList then 
		if tonumber(data) == 0 or tonumber(data) == 18446744073709551615 then   		
			ShowMainGUI(pid)			
		else
			SelectedPlayer[GetName(pid)].timer = SelectedPlayer[GetName(pid)].timer[tonumber(data)]
			SelectedPlayer[GetName(pid)].message = SelectedPlayer[GetName(pid)].message[tonumber(data)]
			ShowMessageReceive(pid)
		end 
	elseif idGui == cfg.MessageReceive then 
		if tonumber(data) == 0 then
			DeleteMessage(pid)
			ShowMainGUI(pid)			
		elseif tonumber(data) == 1 then
			ShowMainGUI(pid)		
		elseif tonumber(data) == 2 then		
		end
	end
end)

customEventHooks.registerHandler("OnPlayerAuthentified", function(eventStatus, pid)
	local playerName = GetName(pid)
	if not MailData[playerName] then
		MailData[playerName] = {}
	end
	local countMessageNotReading = 0	
	local playerName = GetName(pid)	
	for targetName, slot in pairs(MailData[playerName]) do
		for timer, data in pairs(slot) do
			if not data.reading then
				countMessageNotReading = countMessageNotReading + 1
			end
		end
	end	
	tes3mp.SendMessage(pid, trd.NewMsgAuth..countMessageNotReading..trd.NewMsg, false)
end)

customEventHooks.registerHandler("OnPlayerItemUse", function(eventStatus, pid, refId)
	if refId == "misc_dwrv_artifact50" then
		ShowMainGUI(pid)
	end
end)

customCommandHooks.registerCommand("mail", function(pid,cmd)
	if cfg.OnlyStaffCommand and not Players[pid]:IsServerStaff() then
		return
	end
	ShowMainGUI(pid)
end)
