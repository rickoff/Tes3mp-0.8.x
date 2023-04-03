--[[
FixFollowAI
tes3mp 0.8.1
---------------------------
INSTALLATION :
Edits to customScripts.lua
FixFollowAI = require("custom.FixFollowAI")
---------------------------
INSTRUCTION:
Save the file as FixFollowAI.lua inside your server/scripts/custom folder
Edits to customScripts.lua
FixFollowAI = require("custom.FixFollowAI")
---------------------------
]]		
local function SendObjectState(pid, cellDescription, uniqueIndex, state)
    tes3mp.ClearObjectList()
    tes3mp.SetObjectListPid(pid)
    tes3mp.SetObjectListCell(cellDescription)
    local splitIndex = uniqueIndex:split("-")
    tes3mp.SetObjectRefNum(splitIndex[1])
    tes3mp.SetObjectMpNum(splitIndex[2])
    tes3mp.SetObjectState(state)
    tes3mp.AddObject()	
    tes3mp.SendObjectState(false)
end

local FixFollowAI = {}

FixFollowAI.OnPlayerCellChange = function(eventStatus, pid, playerPacket, previousCellDescription)

	local cellDescription = playerPacket.location.cell
	
	local playerName = tes3mp.GetName(pid)

	for _, uniqueIndex in ipairs(LoadedCells[cellDescription].data.packets.ai) do

		local npc = LoadedCells[cellDescription].data.objectData[uniqueIndex]

		if npc.ai.action and npc.ai.action == 4 and npc.ai.targetPlayer == playerName then
			SendObjectState(pid, cellDescription, uniqueIndex, false)
			SendObjectState(pid, cellDescription, uniqueIndex, true)			
		end
		
	end

end

FixFollowAI.OnActorAI = function(eventStatus, pid, cellDescription)
	
	local ObjectIndex

	tes3mp.ReadReceivedActorList()

	for actorIndex = 0, tes3mp.GetActorListSize() - 1 do

		local ObjectIndex = tes3mp.GetActorRefNum(actorIndex) .. "-" .. tes3mp.GetActorMpNum(actorIndex)		
	
		logicHandler.SetAIForActor(LoadedCells[cellDescription], ObjectIndex, enumerations.ai.FOLLOW, pid)	
		
	end	
end

customEventHooks.registerHandler("OnPlayerCellChange", FixFollowAI.OnPlayerCellChange)
customEventHooks.registerHandler("OnActorAI", FixFollowAI.OnActorAI)

return FixFollowAI
