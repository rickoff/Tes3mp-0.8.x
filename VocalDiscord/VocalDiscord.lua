--[[
VocalDiscord
tes3mp 0.8.1
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

------------
-- CONFIG --
------------
local cfg = {
	timerstartvocal = 60,
	kickPlayer = false
}

--------------
-- VARIABLE --
--------------
local playerLocations = {}

--------------
-- FUNCTION --
--------------
local function GetName(pid)
	return string.lower(Players[pid].accountName)
end

local function SavePlayerLocation(pid, disconnect)
	
	if Players[pid] and Players[pid]:IsLoggedIn() then
	
		local PlayerName = GetName(pid)
		
		if not disconnect then
		
			playerLocations[PlayerName] = {
				location = Players[pid].data.location,
				name = Players[pid].accountName,
				level = Players[pid].data.stats.level,
				vocal = Players[pid].data.customVariables.VocalDiscord.vocal	
			}
			
		else
		
			playerLocations[PlayerName] = {
				location = "disconnected",
				name = Players[pid].accountName,
				level = Players[pid].data.stats.level,
				vocal = Players[pid].data.customVariables.VocalDiscord.vocal	
			}
			
		end
		
		playerLocations.Timestamp = os.time()
		
	end
	
	jsonInterface.save("custom/VocalDiscord/playerLocations.json", playerLocations)		

end

function StartKick(pid)

	if Players[pid] and Players[pid]:IsLoggedIn() then
	
		local PlayerName = GetName(pid)
		
		local playerdiscordTable = jsonInterface.load("custom/VocalDiscord/userdiscord.json")
		
		if playerdiscordTable and not playerdiscordTable[PlayerName] then
			
			tes3mp.Kick(pid)
			
			Players[pid] = nil
			
			tes3mp.LogMessage(enumerations.log.INFO, PlayerName.." Kick For Vocal")
			
		end
		
	end
	
end
-------------
-- METHODS --
-------------
local VocalDiscord = {}

VocalDiscord.OnPlayerCellChange = function(eventStatus, pid, playerPacket, previousCellDescription)

	if Players[pid] and Players[pid]:IsLoggedIn() and Players[pid]:HasAccount() then	
	
		if cfg.kickPlayer == true and not Players[pid]:IsServerStaff() then
		
			local PlayerName = GetName(pid)
			
			local playerdiscordTable = jsonInterface.load("custom/VocalDiscord/userdiscord.json")
			
			if playerdiscordTable and not playerdiscordTable[PlayerName] then
				
				local TimerVocal = tes3mp.CreateTimer("StartKick", time.seconds(cfg.timerstartvocal), "i", pid)	
		
				tes3mp.StartTimer(TimerVocal)
				
				tes3mp.MessageBox(pid, 0, color.Red.."Warning !"..color.Default.."\n\nyou must connect to the voice channel to continue playing otherwise you will be disconnected in 1 minute !")	
				
			end

		end
		
		SavePlayerLocation(pid, false)
		
	end
	
end

VocalDiscord.OnPlayerAuthentified = function(eventStatus, pid)

	if Players[pid] and Players[pid]:IsLoggedIn() then
	
		if not Players[pid].data.customVariables.VocalDiscord then
		
			Players[pid].data.customVariables.VocalDiscord = {}	
			
			Players[pid].data.customVariables.VocalDiscord.vocal = 0
			
		else
		
			Players[pid].data.customVariables.VocalDiscord.vocal = 0
			
		end
		
	end
	
	Players[pid]:QuicksaveToDrive()

	SavePlayerLocation(pid, false)	

end

VocalDiscord.OnPlayerDisconnect = function(eventStatus, pid)

	if Players[pid] and Players[pid]:IsLoggedIn() then
	
		if Players[pid].data.customVariables.VocalDiscord then
		
			Players[pid].data.customVariables.VocalDiscord.vocal = 0
			
			SavePlayerLocation(pid, true)	
			
			CountPlayersOnline(true)
		end
		
	end
	
end

VocalDiscord.Vocalon = function(pid)

	if Players[pid] and Players[pid]:IsLoggedIn() then
	
		if Players[pid].data.customVariables.VocalDiscord.vocal == nil then
		
			Players[pid].data.customVariables.VocalDiscord.vocal = 0
			
			tes3mp.MessageBox(pid, -1, color.Gold.."Vocal enable !")	
			
		elseif Players[pid].data.customVariables.VocalDiscord.vocal == 0 then
		
			Players[pid].data.customVariables.VocalDiscord.vocal = 1
			
			tes3mp.MessageBox(pid, -1, color.Gold.."Vocal enable !")	
			
		elseif Players[pid].data.customVariables.VocalDiscord.vocal == 1 then	
		
			Players[pid].data.customVariables.VocalDiscord.vocal = 0
			
			tes3mp.MessageBox(pid, -1, color.Gold.."Vocal disable !")
			
		end
		
		SavePlayerLocation(pid, false)	
		
	end
	
end
------------
-- EVENTS --
------------
customCommandHooks.registerCommand("vocal", VocalDiscord.Vocalon)
customEventHooks.registerHandler("OnPlayerAuthentified", VocalDiscord.OnPlayerAuthentified)	
customEventHooks.registerHandler("OnPlayerDisconnect", VocalDiscord.OnPlayerDisconnect)
customEventHooks.registerHandler("OnPlayerCellChange", VocalDiscord.OnPlayerCellChange)

return VocalDiscord
