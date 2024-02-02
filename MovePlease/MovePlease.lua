--[[
MovePlease
tes3mp 0.8.1
---------------------------
DESCRIPTION :
activating an actor with the hands to cast a spell makes him move.
---------------------------
INSTALLATION:
Save the file as MovePlease.lua inside your server/scripts/custom folder.
Edits to customScripts.lua add in : require("custom.MovePlease")
---------------------------
]]
local cfg = {
	OnlyInterior = true
}

local blackListCellDescription = {
	[" "] = true,
	[" "] = true
}

local blackListRefId = {
	[" "] = true,
	[" "] = true
}

local blackListUniqueIndex = {
	[" "] = true,
	[" "] = true
}

customEventHooks.registerValidator("OnObjectActivate", function(eventStatus, pid, cellDescription, objects)
	if tes3mp.GetDrawState(pid) ~= 2 then return end
	if cfg.OnlyInterior and tes3mp.IsInExterior(pid) then return end
	if blackListCellDescription[cellDescription] then return end
	for _, object in pairs(objects) do
		if object.uniqueIndex and object.refId and tableHelper.containsValue(LoadedCells[cellDescription].data.packets.actorList, object.uniqueIndex)
		and not tableHelper.containsValue(LoadedCells[cellDescription].data.packets.death, object.uniqueIndex) then
			if blackListRefId[object.refId] then return end
			if blackListUniqueIndex[object.uniqueIndex] then return end			
			logicHandler.RunConsoleCommandOnObject(pid, "PlayGroup, hit2, 1", cellDescription, object.uniqueIndex, false)	
			logicHandler.RunConsoleCommandOnObject(pid, "AIWander, 512, 1, 0", cellDescription, object.uniqueIndex, false)		
			return customEventHooks.makeEventStatus(false,false) 	
		end
	end
end)
