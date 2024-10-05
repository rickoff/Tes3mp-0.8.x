--[[
VampHead
tes3mp 0.8.1
---------------------------
INSTALLATION:
Save the file as VampHead.lua inside your server/scripts/custom folder.
Edits to customScripts.lua, add in :
require("custom.VampHead")
---------------------------
]]
local function GetPlayerVamp(pid)
	local hashList = {}
	for i = 1, #Players[pid].data.spellbook do
		local spellId = Players[pid].data.spellbook[i]
		if spellId then
			hashList[spellId] = true
		end
	end
	local spellList = {"vampire blood quarra", "vampire blood berne", "vampire blood aundae", "vampire attributes"}
	for _, spellId in ipairs(spellList) do
		if hashList[spellId] then
			return true	
		end
	end	
	return false
end

local function GetVampHeadRefId(pid)
	local gender = ""	
	if Players[pid].data.character.gender == 0 then 
		gender = "_f"
	else
		gender = "_h"
	end	
	local refId = "b_v_"..string.lower(Players[pid].data.character.race)..gender.."_head_01"	
	return refId	
end

local function CheckToggleHead(pid)
	if GetPlayerVamp(pid) then
		if not Players[pid].data.customVariables.vampHead.active then
			tes3mp.SetHead(pid, GetVampHeadRefId(pid))
			tes3mp.SendBaseInfo(pid)	
			Players[pid].data.customVariables.vampHead.active = true
		end
	else
		if Players[pid].data.customVariables.vampHead.active then
			tes3mp.SetHead(pid, Players[pid].data.customVariables.vampHead.baseHead)
			tes3mp.SendBaseInfo(pid)
			Players[pid].data.customVariables.vampHead.active = false
		end
	end
end

customEventHooks.registerHandler("OnPlayerAuthentified", function(eventStatus, pid)
	if not Players[pid].data.customVariables.vampHead then	
		Players[pid].data.customVariables.vampHead = {}
		Players[pid].data.customVariables.vampHead = {
			baseHead = Players[pid].data.character.head,
			active = false
		}
	end	
	CheckToggleHead(pid)	
end)

customEventHooks.registerHandler("OnPlayerCellChange", function(eventStatus, pid, playerPacket, previousCellDescription)	
	CheckToggleHead(pid)
end)
