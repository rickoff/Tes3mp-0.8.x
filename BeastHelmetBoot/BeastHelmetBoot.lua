--[[
BeastHelmetBoot by Rickoff
tes3mp 0.8.1
---------------------------
DESCRIPTION :
BeastHelmetBoot script
---------------------------
INSTALLATION:
Save the file as BeastHelmetBoot.lua inside your server/scripts/custom folder.
Edits to customScripts.lua
BeastHelmetBoot = require("custom.BeastHelmetBoot")
---------------------------
]]
local BeastHelmetBoot = {}

BeastHelmetBoot.OnPlayerItemUseValidator = function(eventStatus, pid)
	local PlayerRace = Players[pid].data.character.race	
	if PlayerRace == "argonian" or PlayerRace == "khajiit" then
		tes3mp.SetRace(pid, "breton")		
		tes3mp.SendBaseInfo(pid)		
	end
end

BeastHelmetBoot.OnPlayerItemUseHandler = function(eventStatus, pid)
	local PlayerRace = Players[pid].data.character.race	
	if PlayerRace == "argonian" or PlayerRace == "khajiit" then	
		tes3mp.SetRace(pid, PlayerRace)	
		tes3mp.SendBaseInfo(pid)		
	end
end

customEventHooks.registerValidator("OnPlayerItemUse", BeastHelmetBoot.OnPlayerItemUseValidator)
customEventHooks.registerHandler("OnPlayerItemUse", BeastHelmetBoot.OnPlayerItemUseHandler)

return BeastHelmetBoot
