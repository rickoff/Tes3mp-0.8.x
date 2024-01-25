--[[
ResetFactionExpelt
tes3mp 0.8.1
---------------------------
INSTALLATION:
Save the file as ResetFactionExpelt.lua inside your server/scripts/custom folder.
Edits to customScripts.lua add : require("custom.ResetFactionExpelt")
---------------------------
COMMAND:
/resetexpelt for reset expelt
]]

local faction = {
	["mages guild"] = "Set ExpMagesGuild to 0",
	["fighters guild"] = "Set ExpFightersGuild to 0",
	["thieves guild"] = "Set ExpThievesGuild to 0",
	["imperial cult"] = "Set ExpImperialCult to 0",
	["imperial legion"] = "Set ExpImperialLegion to 0",
	["morag tong"] = "Set ExpMoragTong to 0",
	redoran = "Set ExpRedoran to 0",
	temple = "Set ExpTemple to 0"
}

customCommandHooks.registerCommand("resetexpelt", function(pid, cmd) 
	if Players[pid]:IsServerStaff() then
		if cmd[2] and Players[tonumber(cmd[2])] and Players[tonumber(cmd[2])]:IsLoggedIn() then
			local targetPid = tonumber(cmd[2])
			local factionName			
			if cmd[3] and faction[cmd[3]] then
				factionName = cmd[3]
			end
			if cmd[4] and faction[cmd[3].." "..cmd[4]] then
				factionName = cmd[3].." "..cmd[4]
			end
			if factionName then
				local consoleCommand = faction[factionName] 
				if Players[targetPid].data.factionExpulsion[factionName] then
					Players[targetPid].data.factionExpulsion[factionName] = false
					logicHandler.RunConsoleCommandOnPlayer(pid, consoleCommand, false)
					Players[targetPid]:LoadFactionExpulsion() 					
					tes3mp.SendMessage(pid, "Player expulsion "..Players[targetPid].accountName.." from guild "..factionName.."  has been reset\n", false)					
					tes3mp.SendMessage(targetPid, "Your expulsion from the guild "..factionName.." has been reset\n", false)				
				else
					tes3mp.SendMessage(pid, "The player is not kicked from the faction or the faction is not referenced\n", false)				
				end
			else
				local msg = "Enter a valid faction name /resetexpelt pid factionName\n"
				for factionName, command in pairs(faction) do
					msg = msg..factionName.."\n"
				end
				tes3mp.SendMessage(pid, msg, false)			
			end
		else
			tes3mp.SendMessage(pid, "Enter a valid pid /resetexpelt pid factionName\n", false)
		end
	else
		tes3mp.SendMessage(pid, "The order can only be made by a member of staff\n", false)
	end
end) 
