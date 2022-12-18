--[[
TeamGroup
tes3mp 0.8.1
Script by Rickoff
---------------------------
DESCRIPTION :
Create a group, invite players, teleport to members, group message, sync journal, add/remove allied
---------------------------
INSTALLATION:
Save the file as TeamGroup.lua inside your server/scripts/custom folder.
Edits to customScripts.lua
add : TeamGroup = require("custom.TeamGroup")
---------------------------
COMMAND:
/group for open main menu
]]

--------------
-- VARIABLE --
--------------
local playerGroup = {}
local playerListOptions = {}
local playerListInvite = {}
local playerExitInvite = {}

----------------
-- TRADUCTION --
----------------
local trad = {}
trad.MainGui = color.Orange .. "GROUP MENU\n\n"
	..color.Yellow.."List/Teleport:"
	..color.White.." to display group members and teleport.\n\n"
	..color.Yellow.."Leave/Delete:"
	..color.White.." to leave or delete a group.\n\n"
	..color.Yellow.."Invite:"
	..color.White.." to invite a player to your group.\n\n"
	..color.Yellow.."Expel:"
	..color.White.." to expel a player from your group.\n\n"
	..color.Yellow.."Message:"
	..color.White.." to send a message to group members.\n\n"
trad.MainGuiBox = "List/Teleport;Leave/Delete;Invite;Expel;Message;Return;Close"
trad.CreateGroupCreate = "You just created a group!\n"
trad.InputMsg = "Enter a message for the group"
trad.Group = "Group: "
trad.Return = "* Return *\n"
trad.SelectExit = "Select a player to expel from your group."
trad.ExpulseMembers = "You just expelled a member from the group!\n"
trad.ExpulseYou = "You have been expelled from the group!\n"
trad.DeleteGroup = "You just deleted your group!\n"
trad.ExitGroup = "You have left the group!\n"
trad.InvitePlayer = "Select a player to send an invitation to"
trad.SelectWarp = "Select a player to teleport to"
trad.JoinGroup = " has joined the group "
trad.JoinGroupYou = "You have joined "
trad.Xp = " exp."
trad.Bonus = "Group bonus: "
trad.Gain = "You gained: "
trad.Invitation1 = "Do you want to ask "
trad.Invitation2 = " to join the group?"
trad.Choice = "Yes;No"
trad.Reponse = "Do you want to join "

------------
-- CONFIG --
------------
local cfg = {}
cfg.MainGUI = 20001989
cfg.listGUI = 20001990
cfg.listPlayerGUI = 20001991
cfg.listPlayerExitGUI = 20001992
cfg.MessageInput = 20001993
cfg.MessageInvitation = 2000194
cfg.MessageReponse = 20001995

---------------
-- FUNCTIONS --
---------------
local function GetName(pid)
	return string.lower(Players[pid].accountName)
end

local function getGroupData(pid)

	local group = {}
	
	local playerName = GetName(pid)	
	
	if playerGroup[playerName] then	
		
		group = playerGroup[playerName]

	else	
	
		for groupName, members in pairs(playerGroup) do
		
			if members[playerName] then
			
				group = playerGroup[groupName]
				
				break
				
			end
			
		end
		
	end
	
	return group

end

local function getListMemberGroup(pid)

	local options = {}
	
	local playerName = GetName(pid)	

	local playerGroup = getGroupData(pid)

	for memberName, name in pairs(playerGroup) do
	
		if memberName then	
		
			table.insert(options, memberName)  
			
		end
		
	end	

	return options
	
end

local function getListPlayer(pid) 

	local options = {}  
	
	local playerName = GetName(pid)
	
	for pid, player in pairs(Players) do
	
		if Players[pid] and Players[pid]:IsLoggedIn() then
		
			table.insert(options, GetName(pid)) 
			
		end
		
	end
	
	return options
	
end

local function addAlliedInGroup(pid)

	local GroupList = getListMemberGroup(pid)
	
	for _, playerName in ipairs(GroupList) do
	
		local targetPid = logicHandler.GetPlayerByName(playerName).pid
		
		if targetPid and Players[targetPid] ~= nil and Players[targetPid]:IsLoggedIn() then
		
			for _, targetName in ipairs(GroupList) do	
			
				if not tableHelper.containsValue(Players[targetPid].data.alliedPlayers, targetName) then
				
					if playerName ~= targetName then	
					
						table.insert(Players[targetPid].data.alliedPlayers, targetName)
						
					end
					
				end
				
			end
			
			Players[targetPid]:QuicksaveToDrive()
			
			Players[targetPid]:LoadAllies()	
			
		end
		
	end
	
end

local function removeAlliedInGroup(pid)

	local targetName = GetName(pid)
	
	local GroupList = getListMemberGroup(pid)
	
	for _, playerName in pairs(GroupList) do
	
		local targetPid = logicHandler.GetPlayerByName(playerName).pid
		
		if targetPid and Players[targetPid] ~= nil and Players[targetPid]:IsLoggedIn() then	
		
			if tableHelper.containsValue(Players[targetPid].data.alliedPlayers, targetName) then
			
				if playerName ~= targetName then		
				
					tableHelper.removeValue(Players[targetPid].data.alliedPlayers, targetName)
					
					tableHelper.cleanNils(Players[targetPid].data.alliedPlayers)
					
					Players[targetPid]:QuicksaveToDrive()
					
					Players[targetPid]:LoadAllies()		
					
				end
			end		
		end
	end
end

local function removeAlliedGroupDeleted(pid)

	local GroupList = getListMemberGroup(pid)
	
	for _, playerName in pairs(GroupList) do
	
		local targetPid = logicHandler.GetPlayerByName(playerName).pid
		
		if targetPid and Players[targetPid] ~= nil and Players[targetPid]:IsLoggedIn() then
		
			for _, targetName in pairs(GroupList) do	
			
				if not tableHelper.containsValue(Players[targetPid].data.alliedPlayers, targetName) then
				
					if playerName ~= targetName then	
					
						tableHelper.removeValue(Players[targetPid].data.alliedPlayers, targetName)
						
						tableHelper.cleanNils(Players[targetPid].data.alliedPlayers)
						
					end
					
				end
				
			end
			
			Players[targetPid]:QuicksaveToDrive()
			
			Players[targetPid]:LoadAllies()	
			
		end
	end
end

-------------
-- METHODS --
-------------
local TeamGroup = {}

TeamGroup.ShowMainGUI = function(pid)

	if Players[pid] and Players[pid]:IsLoggedIn() then	
	
		local message = trad.MainGui
		
		tes3mp.CustomMessageBox(pid, cfg.MainGUI, message, trad.MainGuiBox)
		
	end
	
end

TeamGroup.CreateGroup = function(pid)

	if Players[pid] and Players[pid]:IsLoggedIn() then
	
		local playerName = GetName(pid)
		
		playerGroup[playerName] = {}
		playerGroup[playerName][playerName] = true

		tes3mp.SendMessage(pid, trad.CreateGroupCreate, false)
		
	end
	
end

TeamGroup.InputMessage = function(pid)

	if Players[pid] and Players[pid]:IsLoggedIn() then
	
		return tes3mp.InputDialog(pid, cfg.MessageInput, trad.InputMsg, "")
		
	end
	
end

TeamGroup.onChoiceMessage = function(pid, loc)

	if Players[pid] and Players[pid]:IsLoggedIn() then
	
	    local playerName = GetName(pid)

		local playerGroup = getGroupData(pid)
	
		for memberName, bool in pairs(playerGroup) do
	
			if memberName then	
			
				local targetPid = logicHandler.GetPlayerByName(memberName).pid
				
				if targetPid and Players[targetPid] ~= nil and Players[targetPid]:IsLoggedIn() then
				
					tes3mp.SendMessage(targetPid, "["..playerName.."] : "..color.Green..trad.Group..color.Pink..loc..color.Default.."\n",false)
					
				end
				
			end
			
		end	
		
	end	
	
end	

TeamGroup.CheckPlayerExit = function(pid)

	if Players[pid] and Players[pid]:IsLoggedIn() then
	
		local playerName = GetName(pid)
		
		local options = getListMemberGroup(pid)
		
		local listItem = trad.Return
		
		for _, name in pairs(options) do
		
			listItem = listItem..name.."\n"
			
		end		
		
		playerExitInvite[playerName] = {opt = options}
		
		tes3mp.ListBox(pid, cfg.listPlayerExitGUI, color.CornflowerBlue..trad.SelectExit..color.Default, listItem)
		
	end
	
end
 
TeamGroup.showChoiceExit = function(pid, loc)

	if Players[pid] and Players[pid]:IsLoggedIn() then
	
		local playerName = GetName(pid)
		
		local choice = playerExitInvite[playerName].opt[loc]
		
		local targetPid		
		
		if choice ~= nil and choice ~= "" then
		
			targetPid = logicHandler.GetPlayerByName(choice).pid
			
		end
		
		if targetPid and Players[targetPid] ~= nil and Players[targetPid]:IsLoggedIn() then	
		
			if GetName(targetPid) == playerName then
			
				return false
				
			end
			
			playerExitInvite[playerName].choice = choice
			
			Players[pid].data.targetPid = targetPid
			
			Players[targetPid].data.targetPid = pid
			
			if playerGroup[playerName] then
				
				local targetName = GetName(targetPid)
				
				if playerGroup[playerName][targetName] then
				
					removeAlliedInGroup(targetPid)
					
					playerGroup[playerName][targetName] = nil
					
					tes3mp.SendMessage(pid, trad.ExpulseMembers, false)
					
					tes3mp.SendMessage(targetPid, trad.ExpulseYou, false)
					
				end
	
			end
			
		end
		
	end
	
end

TeamGroup.ExitGroup = function(pid)

	if Players[pid] and Players[pid]:IsLoggedIn() then
	
		local playerName = GetName(pid)	

		if playerGroup[playerName] then
		
			removeAlliedGroupDeleted(pid)
			
			playerGroup[playerName] = nil
			
			tes3mp.SendMessage(pid, trad.DeleteGroup, false) 
			
		else

			for groupName, name in pairs(playerGroup) do
			
				if playerGroup[groupName][playerName] then	
				
					removeAlliedInGroup(pid)
					
					playerGroup[groupName][playerName] = nil
					
					tes3mp.SendMessage(pid, trad.ExitGroup, false)
				
					break
					
				end	
				
			end	
			
		end
		
	end
	
end

TeamGroup.CheckPlayer = function(pid)

	if Players[pid] and Players[pid]:IsLoggedIn() then
	
		local playerName = GetName(pid)
		
		local options = getListPlayer(pid)
		
		local listItem = trad.Return	
		
		for _, name in pairs(options) do
		
			listItem = listItem..name.."\n"
			
		end
		
		playerListInvite[playerName] = {opt = options}
		
		tes3mp.ListBox(pid, cfg.listPlayerGUI, color.CornflowerBlue..trad.InvitePlayer..color.Default, listItem)
		
	end
	
end
 
TeamGroup.showChoiceInvite = function(pid, loc)

	if Players[pid] and Players[pid]:IsLoggedIn() then

		local playerName = GetName(pid)
		
		local choice = playerListInvite[playerName].opt[loc]
		
		local targetPid		
		
		if choice ~= nil and choice ~= "" then
		
			targetPid = logicHandler.GetPlayerByName(choice).pid
			
		end
		
		if targetPid then
		
			TeamGroup.InviteMessage(pid, targetPid)
			
		end
		
	end
	
end

TeamGroup.InviteMessage = function(pid, targetPid)

	if Players[pid] and Players[pid]:IsLoggedIn() and Players[targetPid] ~= nil and Players[targetPid]:IsLoggedIn() then

		Players[pid].data.targetPid = targetPid
		
		Players[targetPid].data.targetPid = pid
		
		local targetName = GetName(targetPid)
		
		local message = trad.Invitation1..targetName..trad.Invitation2

		tes3mp.CustomMessageBox(pid, cfg.MessageInvitation, message, trad.Choice)	
		
	end
	
end

TeamGroup.ReponseMessage = function(pid, targetPid)

	if Players[pid] and Players[pid]:IsLoggedIn() and Players[targetPid] ~= nil and Players[targetPid]:IsLoggedIn() then
		
		local targetName = GetName(targetPid)
		
		local message = trad.Reponse..targetName.." ?"

		tes3mp.CustomMessageBox(pid, cfg.MessageReponse, message, trad.Choice)
	
	end
	
end

TeamGroup.CheckGroup = function(pid)

	if Players[pid] and Players[pid]:IsLoggedIn() then
	
		local playerName = GetName(pid)
		
		local options = getListMemberGroup(pid)
		
		local listItem = trad.Return	
		
		for _, name in pairs(options) do
		
			listItem = listItem..name.."\n"
			
		end	
		
		playerListOptions[playerName] = {opt = options}
		
		tes3mp.ListBox(pid, cfg.listGUI, color.CornflowerBlue..trad.SelectWarp..color.Default, listItem)
		
	end
	
end

TeamGroup.showChoiceList = function(pid, loc)

	if Players[pid] and Players[pid]:IsLoggedIn() then
	
		local choice = playerListOptions[GetName(pid)].opt[loc]
		
		local targetPid
		
		if choice ~= nil and choice ~= "" then
		
			targetPid = logicHandler.GetPlayerByName(choice).pid
			
		end
		
		if targetPid and Players[targetPid] ~= nil and Players[targetPid]:IsLoggedIn() then
		
			playerListOptions[GetName(pid)].choice = choice
			
			local targetCell = tes3mp.GetCell(targetPid)
			
			if targetCell then
			
				logicHandler.TeleportToPlayer(pid, pid, targetPid)
				
			end
			
		end
		
	end
	
end

TeamGroup.RegisterGroup = function(pid, invitePid)	

	if Players[pid] and Players[pid]:IsLoggedIn() and Players[invitePid] ~= nil and Players[invitePid]:IsLoggedIn() then
	
		local playerName = GetName(pid)
		
		local targetName = GetName(invitePid)
		
		TeamGroup.ExitGroup(invitePid)

		if not playerGroup[playerName] then
		
			TeamGroup.CreateGroup(pid)
		
		end

		playerGroup[playerName][targetName] = true
		
		tes3mp.SendMessage(pid, targetName..trad.JoinGroup..playerName.."\n", false)
		
		tes3mp.SendMessage(invitePid, trad.JoinGroupYou..playerName.."\n", false)
		
		addAlliedInGroup(invitePid)	

	end		
	
end

TeamGroup.OnGUIAction = function(pid, idGui, data)

	if Players[pid] and Players[pid]:IsLoggedIn() then 
	
		if idGui == cfg.MainGUI then 
		
			if tonumber(data) == 0 then 
			
				TeamGroup.CheckGroup(pid)
				
				return true
				
			elseif tonumber(data) == 1 then 
			
				TeamGroup.ExitGroup(pid)
				
				return TeamGroup.ShowMainGUI(pid)
				
			elseif tonumber(data) == 2 then 
			
				TeamGroup.CheckPlayer(pid)
				
				return true
				
			elseif tonumber(data) == 3 then 
			
				TeamGroup.CheckPlayerExit(pid)
				
				return true	
				
			elseif tonumber(data) == 4 then
			
				TeamGroup.InputMessage(pid)
				
				return true		
				
			elseif tonumber(data) == 5 then	
				
				return true
				
			elseif tonumber(data) == 6 then
				--Do nothing
				return true	
				
			end
			
		elseif idGui == cfg.listGUI then -- Liste
		
			if tonumber(data) == 0 or tonumber(data) == 18446744073709551615 then 
			
				return TeamGroup.ShowMainGUI(pid)
				
			else   
			
				TeamGroup.showChoiceList(pid, tonumber(data)) 
				
				return TeamGroup.ShowMainGUI(pid)
				
			end 
			
		elseif idGui == cfg.listPlayerGUI then -- Liste
		
			if tonumber(data) == 0 or tonumber(data) == 18446744073709551615 then    
			
				return TeamGroup.ShowMainGUI(pid)
				
			else   
			
				TeamGroup.showChoiceInvite(pid, tonumber(data)) 
				
				return true
				
			end 

		elseif idGui == cfg.listPlayerExitGUI then -- Liste
		
			if tonumber(data) == 0 or tonumber(data) == 18446744073709551615 then   
			
				return TeamGroup.ShowMainGUI(pid)
				
			else   
			
				TeamGroup.showChoiceExit(pid, tonumber(data)) 
				
				return true
				
			end 	
			
		elseif idGui == cfg.MessageInput then -- Liste
		
			if tonumber(data) == 0 or tonumber(data) == 18446744073709551615 then    
			
				return TeamGroup.ShowMainGUI(pid)
				
			else   
			
				TeamGroup.onChoiceMessage(pid, tostring(data)) 
				
				return TeamGroup.ShowMainGUI(pid)
				
			end		
			
		elseif idGui == cfg.MessageInvitation then 
		
			if tonumber(data) == 0 then 

				local targetPid = Players[pid].data.targetPid
		
				TeamGroup.ReponseMessage(targetPid, pid)
				
				return true
				
			elseif tonumber(data) == 1 then
				--Do nothing
				return true	
				
			end
		elseif idGui == cfg.MessageReponse then 
		
			if tonumber(data) == 0 then 

				local targetPid = Players[pid].data.targetPid
				
				TeamGroup.RegisterGroup(targetPid, pid)
				
				return true
				
			elseif tonumber(data) == 1 then
				--Do nothing
				return true	
				
			end
		end
	end
	
end

TeamGroup.ActiveMenu = function(pid)

	if Players[pid] and Players[pid]:IsLoggedIn() then 
	
		Players[pid].currentCustomMenu = "reponse player"--Invite Menu
		
		menuHelper.DisplayMenu(pid, Players[pid].currentCustomMenu)	
		
	end
	
end

TeamGroup.OnPlayerDisconnect = function(pid)

	if Players[pid] and Players[pid]:IsLoggedIn() then

		Players[pid].data.alliedPlayers = {}
		
	end
	
end

TeamGroup.OnPlayerJournal = function(pid, playerPacket)

	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
	
		local playerName = GetName(pid)	
		
		local playerGroup = getGroupData(pid)
		
		for _, journalItem in ipairs(playerPacket.journal) do
		
			for memberName, bool in pairs(playerGroup) do
		
				if memberName then	
					
					local targetPid = logicHandler.GetPlayerByName(name).pid
					
					if targetPid and Players[targetPid] ~= nil and Players[targetPid]:IsLoggedIn() then
					
						local checkQuest = false
						
						local targetPlayerPacket = packetReader.GetPlayerPacketTables(targetPid, "PlayerJournal")
						
						for _, targetJournalItem in ipairs(targetPlayerPacket.journal) do
						
							if journalItem.quest == targetJournalItem.quest and journalItem.index == targetJournalItem.index then
							
								checkQuest = true
								
							end
							
						end
						
						if checkQuest == false then
						
							Players[targetPid]:SaveDataByPacketType("PlayerJournal", playerPacket)
							
							Players[targetPid]:LoadJournal()
						end
						
					end
				end
			end						
		end
	end
end

------------
-- EVENTS --
------------
customEventHooks.registerValidator("OnPlayerDisconnect", function(eventStatus, pid)
	TeamGroup.ExitGroup(pid)
end)

customEventHooks.registerHandler("OnPlayerDisconnect", function(eventStatus, pid)
	TeamGroup.OnPlayerDisconnect(pid)
end)

customEventHooks.registerHandler("OnGUIAction", function(eventStatus, pid, idGui, data)
	if TeamGroup.OnGUIAction(pid, idGui, data) then return end	
end)

customEventHooks.registerHandler("OnPlayerJournal", function(eventStatus, pid, playerPacket)
	if config.shareJournal == false then
		TeamGroup.OnPlayerJournal(pid, playerPacket)
	end
end)

customCommandHooks.registerCommand("group", TeamGroup.ShowMainGUI)

return TeamGroup
