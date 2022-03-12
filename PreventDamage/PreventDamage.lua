--[[
PreventDamage
tes3mp 0.8.0
---------------------------
INSTALLATION:
Save the file as PreventDamage.lua inside your server/scripts/custom folder.
Edits to customScripts.lua add : PreventDamage = require("custom.PreventDamage")
---------------------------
DESCRIPTION:
Enter /pvp to enable or disable damage prevention from other players
---------------------------
]]
local function GetName(pid)
	return string.lower(Players[pid].accountName)
end

local DisablePvp = { player = {} }

local PreventDamage = {}

PreventDamage.Command = function(pid)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then	
		local PlayerName = GetName(pid)
		if DisablePvp.player[PlayerName] then
			DisablePvp.player[PlayerName] = nil
			tes3mp.MessageBox(pid, -1, color.Red.."Pvp mod enable !")		
		else
			DisablePvp.player[PlayerName] = true
			tes3mp.MessageBox(pid, -1, color.Green.."Pvp mod disable !")			
		end
	end
end

PreventDamage.OnObjectHit = function(eventStatus, pid, cellDescription, objects, targetPlayers)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then	
        for targetPid, targetPlayer in pairs(targetPlayers) do
			if Players[targetPid] ~= nil and Players[targetPid]:IsLoggedIn() then			
				local targetPlayerName = GetName(targetPid)
				if DisablePvp.player[targetPlayerName] and targetPlayer.hittingPid and targetPlayer.hit.success then
					local targetHealthCurrent = math.floor(tes3mp.GetHealthCurrent(targetPid))
					local Damage = math.floor(targetPlayer.hit.damage)
					local newHealth = targetHealthCurrent + Damage
					tes3mp.SetHealthCurrent(targetPid, newHealth)				
					tes3mp.SendStatsDynamic(targetPid)
				end
			end
		end
	end
end

customCommandHooks.registerCommand("pvp", PreventDamage.Command)	
customEventHooks.registerHandler("OnObjectHit", PreventDamage.OnObjectHit)

return PreventDamage
