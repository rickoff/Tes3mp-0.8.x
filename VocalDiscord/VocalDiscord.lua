--[[
VocalDiscord
tes3mp 0.8.0
---------------------------
DESCRIPTION :
	- Automatically creates, deletes and moves a player on the discord channel corresponding to the cell being explored ig
	- Automatically kicks players not present on a voice channel
---------------------------
INSTALLATION:
	- Save the file as VocalDiscord.lua inside your server/scripts/custom folder.
	- Save the file as BotVocal.lua inside your server/lib/luadiscord folder.
	- Save the file as userdiscord.json inside your server/data/custom/VocalDiscord folder.
	- Save the file as playerLocations.json inside your server/data/custom/VocalDiscord folder.
	
	Edits to customScripts.lua
	- VocalDiscord = require("custom.VocalDiscord")
	
	Edits to config.lua in server/lib/luadiscord
	- change by your patchCustom data server
	- change by your voice role id discord 
	- change by your voice channel hall id discord
	- change by your categorie channel id discord
	- change by your role everyone members id discord
	- change by your channel name not to be deleted
	- change by your id server
---------------------------	
RUN/USE:
	- run the StartBotVocal.bat file and check that it connects to your discord
	- connect to any voice channel of your discord with a nickname corresponding to your character name
	(the modification of the nickname is not taken into account if you are already connected to the voice channel, then disconnect/reconnect to the channel for the consideration)
	- Use /vocal in chat ig for active instancied vocal
---------------------------	
CONFIG:
	- config.timerstartvocal is the time in seconds before kicking players not connected to voice
	- config.kickPlayer toggle to true to enable kick option
---------------------------
]]
local config = {}
config.timerstartvocal = 60
config.kickPlayer = false

VocalDiscord = {}

VocalDiscord.OnPlayerCellChange = function(eventStatus, pid, playerPacket, previousCellDescription)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() and Players[pid]:HasAccount() then	
		if config.kickPlayer == true then
			if not Players[pid]:IsServerStaff() then		
				local playerdiscordTable = jsonInterface.load("custom/VocalDiscord/userdiscord.json")
				local playerName = string.lower(Players[pid].name)
				if playerdiscordTable.players ~= nil then
					if not tableHelper.containsValue(playerdiscordTable.players, playerName, true) then
						local TimerVocal = tes3mp.CreateTimer("StartKick", time.seconds(config.timerstartvocal))				
						tes3mp.StartTimer(TimerVocal, time.seconds(config.timerstartvocal))
						tes3mp.MessageBox(pid, 0, color.Red.."Warning!"..color.Default.."\n\nyou must connect to the voice channel to continue playing otherwise you will be disconnected in 1 minute!")						
					end
				end
				
				function StartKick()
					if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then	
						local playerdiscordTable = jsonInterface.load("custom/VocalDiscord/userdiscord.json")
						if playerdiscordTable then
							if not tableHelper.containsValue(playerdiscordTable.players, playerName, true) then
								tes3mp.Kick(pid)
								Players[pid] = nil
								tes3mp.LogMessage(enumerations.log.INFO, "On Player Kick For Vocal")					
							end
						end
					end
				end
			end
		end
		local playerLocations = {players={}}
		for pid, ply in pairs(Players) do
			local newindex = #playerLocations.players+1
			playerLocations.players[newindex] = {}
			for k, v in pairs(ply.data.location) do
				playerLocations.players[newindex][k] = v
			end
			playerLocations.players[newindex].name = ply.accountName
			if ply.data.customVariables.VocalDiscord.vocal then
				playerLocations.players[newindex].vocal = ply.data.customVariables.VocalDiscord.vocal
			end
		end
		jsonInterface.save("custom/VocalDiscord/playerLocations.json", playerLocations)		
	end
end

VocalDiscord.PlayerDisconnect = function(pid)
	local playerLocations = {players={}}
	for pid, ply in pairs(Players) do
		local newindex = #playerLocations.players+1
		playerLocations.players[newindex] = {}
		for k, v in pairs(ply.data.location) do
			playerLocations.players[newindex][k] = v
		end
		playerLocations.players[newindex].name = ply.accountName
		if ply.data.customVariables.VocalDiscord.vocal then
			playerLocations.players[newindex].vocal = ply.data.customVariables.VocalDiscord.vocal
		end
	end
	jsonInterface.save("custom/VocalDiscord/playerLocations.json", playerLocations)	
end

VocalDiscord.Vocalon = function(pid)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() and Players[pid]:HasAccount() then
		if Players[pid].data.customVariables.VocalDiscord.vocal == nil then
			Players[pid].data.customVariables.VocalDiscord.vocal = 1
			tes3mp.MessageBox(pid, -1, color.Gold.."Vocal enable !")				
		elseif Players[pid].data.customVariables.VocalDiscord.vocal == 0 then
			Players[pid].data.customVariables.VocalDiscord.vocal = 1
			tes3mp.MessageBox(pid, -1, color.Gold.."Vocal enable !")			
		elseif Players[pid].data.customVariables.VocalDiscord.vocal == 1 then	
			Players[pid].data.customVariables.VocalDiscord.vocal = 0
			tes3mp.MessageBox(pid, -1, color.Gold.."Vocal disable !")			
		end
		local playerLocations = {players={}}
		for pid, ply in pairs(Players) do
			local newindex = #playerLocations.players+1
			playerLocations.players[newindex] = {}
			for k, v in pairs(ply.data.location) do
				playerLocations.players[newindex][k] = v
			end
			playerLocations.players[newindex].name = ply.accountName
			if ply.data.customVariables.VocalDiscord.vocal then
				playerLocations.players[newindex].vocal = ply.data.customVariables.VocalDiscord.vocal
			end
		end
		jsonInterface.save("custom/VocalDiscord/playerLocations.json", playerLocations)		
	end
end

VocalDiscord.OnPlayerAuthentified = function(eventStatus, pid)
	if Players[pid] ~= nil then
		if not Players[pid].data.customVariables.VocalDiscord then
			Players[pid].data.customVariables.VocalDiscord = {vocal = 0}
		else
			Players[pid].data.customVariables.VocalDiscord.vocal = 0
		end
	end	
end
	
customEventHooks.registerHandler("OnPlayerDisconnect", function(eventStatus, pid)
	VocalDiscord.PlayerDisconnect(pid)
end)
customCommandHooks.registerCommand("vocal", VocalDiscord.Vocalon)
customEventHooks.registerHandler("OnPlayerCellChange", VocalDiscord.OnPlayerCellChange)
customEventHooks.registerHandler("OnPlayerAuthentified", VocalDiscord.OnPlayerAuthentified)

return VocalDiscord
