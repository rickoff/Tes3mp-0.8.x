--[[
TeamGroup
tes3mp 0.8.0
---------------------------
DESCRIPTION :
Create a group, invite players, teleport to members, group message, sync journal, add/remove allied
---------------------------
INSTALLATION:
Save the file as TeamGroup.lua inside your server/scripts/custom folder.
Save the file as MenuGroup.lua inside your server/scripts/menu folder.
Edits to customScripts.lua
add : TeamGroup = require("custom.TeamGroup")
Edits to config.lua
add in config.menuHelperFiles, "MenuGroup"
---------------------------
COMMAND:
/group for open main menu
]]
local playerGroup = {}

local trad = {}
trad.MainGui = color.Orange .. "WELCOME TO THE GROUP MENU.\n\n"
	..color.Yellow.."List/Teleport :"
	..color.White.." to display your party members and this teleporter.\n\n"
	..color.Yellow.."Exit/Delete :"
	..color.White.." to leave or delete a group.\n\n"
	..color.Yellow.."Invitation :"
	..color.White.." to invite a player to your party.\n\n"
	..color.Yellow.."Expulsion :"
	..color.White.." to kick a player from your party.\n\n"
	..color.Yellow.."Message :"
	..color.White.." to send a message to your group members.\n\n"	
trad.MainGuiBox = "List/Teleport;Exit/Delete;Invitation;Expulsion;Message;Back;Close"
trad.CreateGroupCreate = "You have just created a group !\n"
trad.AlreadyGroup = "You are already part of a group !\n"
trad.InputMsg = "Enter a message for the group"
trad.Group = "Group : "
trad.Return = "* Return *\n"
trad.SelectExit = "Select a player to kick him out of your group."
trad.ExpulseMembers = "You have just kicked a member of the group !\n"
trad.ExpulseYou = "You have just been expelled from the group !\n"
trad.DeleteGroup = "You just deleted your group !\n"
trad.ExitGroup = "You just left the group !\n"
trad.InvitePlayer = "Select a player to send an invitation"
trad.SelectWarp = "Select a player to teleport to" 
trad.JoinGroup = " just joined the group "
trad.JoinGroupYou = "You have just joined the group of "

local cfg = {}
cfg.MainGUI = 20001989
cfg.listGUI = 20001990
cfg.listPlayerGUI = 20001991
cfg.listPlayerExitGUI = 20001992
cfg.MessageInput = 20001993

local playerListOptions = {}
local playerListInvite = {}
local playerExitInvite = {}

local TeamGroup = {}

local function GetName(pid)
	return string.lower(Players[pid].accountName)
end

local function getListMemberGroup(pid)
	local options = {}
	local playerName = GetName(pid)
	if tableHelper.containsValue(playerGroup, playerName, true) then		
		for x, y in pairs(playerGroup) do	
			if tableHelper.containsValue(playerGroup[x].members, playerName, true) then						
				for name, value in pairs(playerGroup[x].members) do
					if playerGroup[x].members[name] ~= nil then	
						table.insert(options, playerGroup[x].members[name])  							
					end
				end	
			end
		end			
	end		
	return options
end

local function getListPlayer(pid) 
	local options = {}  
	local playerName = GetName(pid)
	for pid, player in pairs(Players) do
		if player ~= nil and player:IsLoggedIn() and not player:IsServerStaff() then
			table.insert(options, GetName(pid))  
		end
	end
	return options
end

local function addAlliedInGroup(pid)
	local GroupList = getListMemberGroup(pid)
	for _, playerName in pairs(GroupList) do
		local targetPid = logicHandler.GetPlayerByName(playerName).pid
		if Players[targetPid] ~= nil and Players[targetPid]:IsLoggedIn() then
			for _, targetName in pairs(GroupList) do		
				if not tableHelper.containsValue(Players[targetPid].data.alliedPlayers, targetName) then
					if playerName ~= targetName then			
						table.insert(Players[targetPid].data.alliedPlayers, targetName)
					end
				end
			end
			Players[targetPid]:Save()
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
					Players[targetPid]:Save()
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
			Players[targetPid]:Save()
			Players[targetPid]:LoadAllies()			
		end
	end
end

TeamGroup.showMainGUI = function(pid)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then	
		local message = trad.MainGui
		tes3mp.CustomMessageBox(pid, cfg.MainGUI, message, trad.MainGuiBox)
	end
end

TeamGroup.CreateGroup = function(pid)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
		if not tableHelper.containsValue(playerGroup, GetName(pid), true) then
			local tableGroup = {
				name = {},
				members = {}
			}
			table.insert(tableGroup.name, GetName(pid))
			table.insert(tableGroup.members, GetName(pid))
			table.insert(playerGroup, tableGroup)	
			tes3mp.SendMessage(pid, trad.CreateGroupCreate, false)
		else
			tes3mp.SendMessage(pid, trad.AlreadyGroup, false)
		end
	end
end

TeamGroup.InputMessage = function(pid)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
		return tes3mp.InputDialog(pid, cfg.MessageInput, trad.InputMsg, "")
	end
end

TeamGroup.onChoiceMessage = function(pid, loc)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
	    local playerName = GetName(pid)
		if tableHelper.containsValue(playerGroup, playerName, true) then		
			for x, y in pairs(playerGroup) do	
				if tableHelper.containsValue(playerGroup[x].members, playerName, true) then						
					for name, value in pairs(playerGroup[x].members) do
						if playerGroup[x].members[name] ~= nil then	
							local targetPid = logicHandler.GetPlayerByName(playerGroup[x].members[name]).pid
							if targetPid then
								tes3mp.SendMessage(targetPid, color.Green..trad.Group..color.Pink..loc..color.Default.."\n",false)
							end
						end
					end	
				end
			end			
		end		
	end	
end	

TeamGroup.CheckPlayerExit = function(pid)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
		local playerName = GetName(pid)
		local options = getListMemberGroup(pid)
		local list = trad.Return
		local listItemChanged = false
		local listItem = ""
		
		for i, z in pairs(options) do
			for x, y in pairs(Players) do
				if y:IsLoggedIn() then
					if Players[x].name == options[i] then
						listItem = Players[x].name
						listItemChanged = true
						break
					else
						listItemChanged = false
					end
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
		playerExitInvite[playerName] = {opt = options}
		tes3mp.ListBox(pid, cfg.listPlayerExitGUI, color.CornflowerBlue..trad.SelectExit..color.Default, list)
	end
end
 
TeamGroup.showChoiceExit = function(pid, loc)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
		local choice = playerExitInvite[GetName(pid)].opt[loc]
		local targetPid		
		if choice ~= nil and choice ~= "" then
			targetPid = logicHandler.GetPlayerByName(choice).pid
		end
		if targetPid and Players[targetPid] ~= nil and Players[targetPid]:IsLoggedIn() then	
			playerExitInvite[GetName(pid)].choice = choice
			Players[pid].data.targetPid = targetPid
			Players[targetPid].data.targetPid = pid
			for x, y in pairs(playerGroup) do
				if tableHelper.containsValue(playerGroup[x].name, GetName(pid), true) then
					if tableHelper.containsValue(playerGroup[x].members, GetName(pid), true) then
						for name, value in pairs(playerGroup[x].members) do	
							if playerGroup[x].members[name] == GetName(targetPid) then
								removeAlliedInGroup(targetPid)							
								playerGroup[x].members[name] = nil
								tes3mp.SendMessage(pid, trad.ExpulseMembers, false)
								tes3mp.SendMessage(targetPid, trad.ExpulseYou, false)
							end
						end	
						for r, s in pairs(playerGroup[x].name) do
							if playerGroup[x].name[r] == GetName(targetPid) then
								removeAlliedGroupDeleted(pid)
								playerGroup[x] = nil
								tes3mp.SendMessage(pid, trad.DeleteGroup, false)
							end
						end						
					end
				end
			end	
		end
	end
end

TeamGroup.ExitGroup = function(pid)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() and Players[pid]:HasAccount() then	
		if tableHelper.containsValue(playerGroup, GetName(pid), true) then	
			for x, y in pairs(playerGroup) do
				if tableHelper.containsValue(playerGroup[x].name, GetName(pid), true) then
					removeAlliedGroupDeleted(pid)
					playerGroup[x] = nil
					tes3mp.SendMessage(pid, trad.DeleteGroup, false)
				elseif tableHelper.containsValue(playerGroup[x].members, GetName(pid), true) then
					for name, value in pairs(playerGroup[x].members) do	
						if playerGroup[x].members[name] == GetName(pid) then
							removeAlliedInGroup(pid)						
							playerGroup[x].members[name] = nil
							tes3mp.SendMessage(pid, trad.ExitGroup, false)
						end
					end	
				end
			end				
		end			
	end
end

TeamGroup.CheckPlayer = function(pid)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
		local playerName = GetName(pid)
		local options = getListPlayer(pid)
		local list = trad.Return
		local listItemChanged = false
		local listItem = ""
		
		for i, z in pairs(options) do
			for x, y in pairs(Players) do
				if y:IsLoggedIn() then
					if Players[x].name == options[i] then
						listItem = Players[x].name
						listItemChanged = true
						break
					else
						listItemChanged = false
					end
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
		playerListInvite[playerName] = {opt = options}
		tes3mp.ListBox(pid, cfg.listPlayerGUI, color.CornflowerBlue..trad.InvitePlayer..color.Default, list)
	end
end
 
TeamGroup.showChoiceInvite = function(pid, loc)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
		local choice = playerListInvite[GetName(pid)].opt[loc]
		local targetPid		
		if choice ~= nil and choice ~= "" then
			targetPid = logicHandler.GetPlayerByName(choice).pid
		end
		if targetPid and Players[targetPid] ~= nil and Players[targetPid]:IsLoggedIn() then
			playerListInvite[GetName(pid)].choice = choice
			Players[pid].data.targetPid = targetPid
			Players[targetPid].data.targetPid = pid
			Players[pid].currentCustomMenu = "invite player"--Invite Menu
			menuHelper.DisplayMenu(pid, Players[pid].currentCustomMenu)
		end
	end
end

TeamGroup.CheckGroup = function(pid)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
		local playerName = GetName(pid)
		local options = getListMemberGroup(pid)
		local list = trad.Return
		local listItemChanged = false
		local listItem = ""
		
		for i, z in pairs(options) do
			for x, y in pairs(Players) do
				if y:IsLoggedIn() then
					if Players[x].name == options[i] then
						listItem = Players[x].name
						listItemChanged = true
						break
					else
						listItemChanged = false
					end
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
		playerListOptions[playerName] = {opt = options}
		tes3mp.ListBox(pid, cfg.listGUI, color.CornflowerBlue..trad.SelectWarp..color.Default, list)
	end
end

TeamGroup.showChoiceList = function(pid, loc)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
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
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() and Players[invitePid] ~= nil and Players[invitePid]:IsLoggedIn() then
		if tableHelper.containsValue(playerGroup, Players[invitePid].name, true) then	
			TeamGroup.ExitGroup(invitePid)
		end	
		
		if not tableHelper.containsValue(playerGroup, GetName(pid), true) then
			TeamGroup.CreateGroup(pid)
		end		

		for x, y in pairs(playerGroup) do	
			if not tableHelper.containsValue(playerGroup[x].members, Players[invitePid].name, true) then
				table.insert(playerGroup[x].members, Players[invitePid].name)
				tes3mp.SendMessage(pid, Players[invitePid].name..trad.JoinGroup..GetName(pid).."\n", false)
				tes3mp.SendMessage(invitePid, trad.JoinGroupYou..GetName(pid).."\n", false)
				addAlliedInGroup(invitePid)				
				break
			end			
		end			
	end			
end

TeamGroup.OnGUIAction = function(pid, idGui, data)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then  
		if idGui == cfg.MainGUI then 
			if tonumber(data) == 0 then 
				TeamGroup.CheckGroup(pid)
				return true
			elseif tonumber(data) == 1 then 
				TeamGroup.ExitGroup(pid)
				return TeamGroup.showMainGUI(pid)	
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
				return TeamGroup.showMainGUI(pid)
			else   
				TeamGroup.showChoiceList(pid, tonumber(data)) 
				return TeamGroup.showMainGUI(pid)
			end 
		elseif idGui == cfg.listPlayerGUI then -- Liste
			if tonumber(data) == 0 or tonumber(data) == 18446744073709551615 then            
				return TeamGroup.showMainGUI(pid)
			else   
				TeamGroup.showChoiceInvite(pid, tonumber(data)) 
				return true
			end 
		elseif idGui == cfg.listPlayerExitGUI then -- Liste
			if tonumber(data) == 0 or tonumber(data) == 18446744073709551615 then            
				return TeamGroup.showMainGUI(pid)
			else   
				TeamGroup.showChoiceExit(pid, tonumber(data)) 
				return true
			end 	
		elseif idGui == cfg.MessageInput then -- Liste
			if tonumber(data) == 0 or tonumber(data) == 18446744073709551615 then            
				return TeamGroup.showMainGUI(pid)
			else   
				TeamGroup.onChoiceMessage(pid, tostring(data)) 
				return TeamGroup.showMainGUI(pid)
			end		
		end
	end
end

TeamGroup.ActiveMenu = function(pid)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then 
		Players[pid].currentCustomMenu = "reponse player"--Invite Menu
		menuHelper.DisplayMenu(pid, Players[pid].currentCustomMenu)	
	end
end

TeamGroup.OnPlayerJournal = function(pid)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then 
		for i = 0, tes3mp.GetJournalChangesSize(pid) - 1 do
			local journalItem = {
				type = tes3mp.GetJournalItemType(pid, i),
				index = tes3mp.GetJournalItemIndex(pid, i),
				quest = tes3mp.GetJournalItemQuest(pid, i),
				timestamp = {
					daysPassed = WorldInstance.data.time.daysPassed,
					month = WorldInstance.data.time.month,
					day = WorldInstance.data.time.day
				}
			}
			if journalItem.type == enumerations.journal.ENTRY then
				journalItem.actorRefId = tes3mp.GetJournalItemActorRefId(pid, i)
			end	
			local playerName = Players[pid].name
			if tableHelper.containsValue(playerGroup, playerName, true) then		
				for x, y in pairs(playerGroup) do	
					if tableHelper.containsValue(playerGroup[x].members, playerName, true) then						
						for name, value in pairs(playerGroup[x].members) do
							if playerGroup[x].members[name] ~= nil then	
								local targetPid = logicHandler.GetPlayerByName(playerGroup[x].members[name]).pid
								if targetPid and Players[targetPid] ~= nil and Players[targetPid]:IsLoggedIn() then
									local checkQuest = false
									for key, slot in pairs(Players[targetPid].data.journal) do
										if slot.quest == journalItem.quest and slot.index == journalItem.index then
											checkQuest = true
										end
									end
									if checkQuest == false then
										table.insert(Players[targetPid].data.journal, journalItem)
										Players[targetPid]:QuicksaveToDrive()
										Players[targetPid]:LoadJournal()
									end
								end
							end
						end	
					end
				end			
			end			
		end
	end
end

customEventHooks.registerHandler("OnPlayerJournal", function(eventStatus, pid)
	if config.shareJournal == false then
		TeamGroup.OnPlayerJournal(pid)
	end
end)
customEventHooks.registerValidator("OnPlayerDisconnect", function(eventStatus, pid)
	TeamGroup.ExitGroup(pid)
end)	
customEventHooks.registerHandler("OnGUIAction", function(eventStatus, pid, idGui, data)
	if TeamGroup.OnGUIAction(pid, idGui, data) then return end	
end)
customCommandHooks.registerCommand("group", TeamGroup.showMainGUI)

return TeamGroup
