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
Only works for melee attacks
---------------------------
PROBLEMS:
the first hit is not well taken into account and the calculation is not always done correctly but in any case prevents death.
spell damage and damage over time are not supported.
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
					local targetHealthCurrent = tes3mp.GetHealthCurrent(targetPid)
					local Damage = targetPlayer.hit.damage
					local newHealth = targetHealthCurrent + Damage
					tes3mp.SetHealthCurrent(targetPid, newHealth)				
					tes3mp.SendStatsDynamic(targetPid)
					tes3mp.MessageBox(targetPlayer.hittingPid, -1, color.Red..targetPlayerName.." has pvp mode disable !")				
				end
			end
		end
	end
end

customCommandHooks.registerCommand("pvp", PreventDamage.Command)	
customEventHooks.registerHandler("OnObjectHit", PreventDamage.OnObjectHit)

return PreventDamage
