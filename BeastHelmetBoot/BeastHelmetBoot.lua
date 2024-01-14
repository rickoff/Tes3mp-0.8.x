--[[
BeastHelmetBoot
tes3mp 0.8.1
---------------------------
DESCRIPTION :
BeastHelmetBoot script
---------------------------
INSTALLATION:
Save the file as BeastHelmetBoot.lua inside your server/scripts/custom folder.
Edits to customScripts.lua add in : require("custom.BeastHelmetBoot")
---------------------------
]]
customEventHooks.registerValidator("OnPlayerItemUse", function(eventStatus, pid))
	local PlayerRace = Players[pid].data.character.race	
	if PlayerRace == "argonian" or PlayerRace == "khajiit" then
		tes3mp.SetRace(pid, "breton")		
		tes3mp.SendBaseInfo(pid)		
	end
end)

customEventHooks.registerHandler("OnPlayerItemUse", function(eventStatus, pid))
	local PlayerRace = Players[pid].data.character.race	
	if PlayerRace == "argonian" or PlayerRace == "khajiit" then	
		tes3mp.SetRace(pid, PlayerRace)	
		tes3mp.SendBaseInfo(pid)		
	end
end
