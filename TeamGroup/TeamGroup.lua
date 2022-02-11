--[[
TeamGroup
tes3mp 0.8.0
---------------------------
DESCRIPTION :
Create a group, invite players, teleport to members, group message
---------------------------
INSTALLATION:
Save the file as TeamGroup.lua inside your server/scripts/custom folder.
Save the file as MenuGroup.lua inside your server/scripts/menu folder.
Edits to customScripts.lua
add : TeamGroup = require("custom.TeamGroup")
Edits to config.lua
add in config.menuHelperFiles : "MenuGroup"
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

local config = {}
config.MainGUI = 20001989
config.listGUI = 20001990
config.listPlayerGUI = 20001991
config.listPlayerExitGUI = 20001992
config.MessageInput = 20001993

local playerListOptions = {}
local playerListInvite = {}
local playerExitInvite = {}

local TeamGroup = {}

local function getListMemberGroup(pid)
	local options = {}
	local playerName = Players[pid].name
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
	local playerName = Players[pid].name
	for pid, player in pairs(Players) do
		if player ~= nil and player:IsLoggedIn() and not player:IsServerStaff() then
			table.insert(options, Players[pid].name)  
		end
	end
	return options
end
-- ===========
--  MAIN MENU
-- ===========
-------------------------

TeamGroup.showMainGUI = function(pid)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then	
		local message = trad.MainGui
		tes3mp.CustomMessageBox(pid, config.MainGUI, message, trad.MainGuiBox)
	end
end

TeamGroup.CreateGroup = function(pid)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
		if not tableHelper.containsValue(playerGroup, Players[pid].name, true) then
			local tableGroup = {
				name = {},
				members = {}
			}
			table.insert(tableGroup.name, Players[pid].name)
			table.insert(tableGroup.members, Players[pid].name)
			table.insert(playerGroup, tableGroup)	
			tes3mp.SendMessage(pid, trad.CreateGroupCreate, false)
		else
			tes3mp.SendMessage(pid, trad.AlreadyGroup, false)
		end
	end
end

TeamGroup.InputMessage = function(pid)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
		return tes3mp.InputDialog(pid, config.MessageInput, trad.InputMsg, "")
	end
end

TeamGroup.onChoiceMessage = function(pid, loc)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
	    local playerName = Players[pid].name
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
		local playerName = Players[pid].name
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
		tes3mp.ListBox(pid, config.listPlayerExitGUI, color.CornflowerBlue..trad.SelectExit..color.Default, list)
	end
end
 
TeamGroup.showChoiceExit = function(pid, loc)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
		local choice = playerExitInvite[Players[pid].name].opt[loc]
		local targetPid		
		if choice ~= nil and choice ~= "" then
			targetPid = logicHandler.GetPlayerByName(choice).pid
		end
		if targetPid then
			playerExitInvite[Players[pid].name].choice = choice
			Players[pid].data.targetPid = targetPid
			Players[targetPid].data.targetPid = pid
			for x, y in pairs(playerGroup) do
				if tableHelper.containsValue(playerGroup[x].name, Players[pid].name, true) then
					if tableHelper.containsValue(playerGroup[x].members, Players[pid].name, true) then
						for name, value in pairs(playerGroup[x].members) do	
							if playerGroup[x].members[name] == Players[targetPid].name then
								playerGroup[x].members[name] = nil
								tes3mp.SendMessage(pid, trad.ExpulseMembers, false)
								tes3mp.SendMessage(targetPid, trad.ExpulseYou, false)
							end
						end	
						for r, s in pairs(playerGroup[x].name) do
							if playerGroup[x].name[r] == Players[targetPid].name then
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
		if tableHelper.containsValue(playerGroup, Players[pid].name, true) then	
			for x, y in pairs(playerGroup) do
				if tableHelper.containsValue(playerGroup[x].name, Players[pid].name, true) then
					playerGroup[x] = nil
					tes3mp.SendMessage(pid, trad.DeleteGroup, false)
				elseif tableHelper.containsValue(playerGroup[x].members, Players[pid].name, true) then
					for name, value in pairs(playerGroup[x].members) do	
						if playerGroup[x].members[name] == Players[pid].name then
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
		local playerName = Players[pid].name
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
		tes3mp.ListBox(pid, config.listPlayerGUI, color.CornflowerBlue..trad.InvitePlayer..color.Default, list)
	end
end
 
TeamGroup.showChoiceInvite = function(pid, loc)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
		local choice = playerListInvite[Players[pid].name].opt[loc]
		local targetPid		
		if choice ~= nil and choice ~= "" then
			targetPid = logicHandler.GetPlayerByName(choice).pid
		end
		if targetPid then
			playerListInvite[Players[pid].name].choice = choice
			Players[pid].data.targetPid = targetPid
			Players[targetPid].data.targetPid = pid
			Players[pid].currentCustomMenu = "invite player"--Invite Menu
			menuHelper.DisplayMenu(pid, Players[pid].currentCustomMenu)
		end
	end
end

TeamGroup.CheckGroup = function(pid)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
		local playerName = Players[pid].name
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
		tes3mp.ListBox(pid, config.listGUI, color.CornflowerBlue..trad.SelectWarp..color.Default, list)
	end
end

TeamGroup.showChoiceList = function(pid, loc)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
		local choice = playerListOptions[Players[pid].name].opt[loc]
		local targetPid
		if choice ~= nil and choice ~= "" then
			targetPid = logicHandler.GetPlayerByName(choice).pid
		end
		if targetPid then
			playerListOptions[Players[pid].name].choice = choice
			if DragonDoor then
				DragonDoor.OnPlayerConnect(true, pid)	
			end
			local targetCell = tes3mp.GetCell(targetPid)
			if targetCell then
				DragonDoor.OnPlayerWarp(pid)
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
		
		if not tableHelper.containsValue(playerGroup, Players[pid].name, true) then
			TeamGroup.CreateGroup(pid)
		end		

		for x, y in pairs(playerGroup) do	
			if not tableHelper.containsValue(playerGroup[x].members, Players[invitePid].name, true) then
				table.insert(playerGroup[x].members, Players[invitePid].name)
				tes3mp.SendMessage(pid, Players[invitePid].name..trad.JoinGroup..Players[pid].name.."\n", false)
				tes3mp.SendMessage(invitePid,trad.JoinGroupYou..Players[pid].name.."\n", false)	
				break
			end			
		end			
	end			
end

TeamGroup.OnGUIAction = function(pid, idGui, data)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then  
		if idGui == config.MainGUI then 
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
				return true			
			end
		elseif idGui == config.listGUI then -- Liste
			if tonumber(data) == 0 or tonumber(data) == 18446744073709551615 then            
				return TeamGroup.showMainGUI(pid)
			else   
				TeamGroup.showChoiceList(pid, tonumber(data)) 
				return TeamGroup.showMainGUI(pid)
			end 
		elseif idGui == config.listPlayerGUI then -- Liste
			if tonumber(data) == 0 or tonumber(data) == 18446744073709551615 then            
				return TeamGroup.showMainGUI(pid)
			else   
				TeamGroup.showChoiceInvite(pid, tonumber(data)) 
				return true
			end 
		elseif idGui == config.listPlayerExitGUI then -- Liste
			if tonumber(data) == 0 or tonumber(data) == 18446744073709551615 then            
				return TeamGroup.showMainGUI(pid)
			else   
				TeamGroup.showChoiceExit(pid, tonumber(data)) 
				return true
			end 	
		elseif idGui == config.MessageInput then -- Liste
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

customEventHooks.registerValidator("OnPlayerDisconnect", function(eventStatus, pid)
	TeamGroup.ExitGroup(pid)
end)	
customEventHooks.registerHandler("OnGUIAction", function(eventStatus, pid, idGui, data)
	if TeamGroup.OnGUIAction(pid, idGui, data) then return end	
end)
customCommandHooks.registerCommand("group", TeamGroup.showMainGUI)

return TeamGroup
