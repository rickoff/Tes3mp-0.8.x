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

FixFollowAI.OnActorCellChange = function(eventStatus, pid, cellDescription)
	
	tes3mp.ReadReceivedActorList()

	for actorIndex = 0, tes3mp.GetActorListSize() - 1 do

		local ActorIndex = tes3mp.GetActorRefNum(actorIndex) .. "-" .. tes3mp.GetActorMpNum(actorIndex)
		local newCellDescription = tes3mp.GetActorCell(actorIndex)
		
		if cellDescription ~= newCellDescription and ActorIndex then

			local useTemporaryLoad = false	
			
			if LoadedCells[newCellDescription] == nil then
				logicHandler.LoadCell(newCellDescription)
				useTemporaryLoad = true
			end		
			
			if not LoadedCells[newCellDescription].isExterior then
				LoadedCells[newCellDescription]:SetAuthority(pid)
				logicHandler.SetAIForActor(LoadedCells[newCellDescription], ActorIndex, enumerations.ai.FOLLOW, pid)				
			end
			
			if useTemporaryLoad == true then
				logicHandler.UnloadCell(newCellDescription)
			end		
		end
	end
end

customEventHooks.registerHandler("OnPlayerCellChange", FixFollowAI.OnPlayerCellChange)
customEventHooks.registerHandler("OnActorCellChange", FixFollowAI.OnActorCellChange)

return FixFollowAI
