--[[
DragonDoor
tes3mp 0.8.0
---------------------------
DESCRIPTION :
creatures and base hostile npc follow players through doors
---------------------------
INSTALLATION:
Save the file as DragonDoor.lua inside your server/scripts/custom folder.
Save the file as DoorData.json inside your server/data/custom/DragonDoor folder.
Save the file as NpcData.json inside your server/data/custom/DragonDoor folder.
Save the file as CreaData.json inside your server/data/custom/DragonDoor folder.

Edits to customScripts.lua
DragonDoor = require("custom.DragonDoor")
]]
local DoorData = jsonInterface.load("custom/DragonDoor/DoorData.json")
local NpcData = jsonInterface.load("custom/DragonDoor/NpcData.json")
local CreaData = jsonInterface.load("custom/DragonDoor/CreaData.json")

local cfg = {}
cfg.rad = 1000

local doorTab = { player = {} }
local creaTab = { player = {} }
local indexTab = { player = {} }
local cellTab = { player = {} }

local function GetName(pid)
	return string.lower(Players[pid].accountName)
end

local function CleanCellObject(pid, cellDescription, uniqueIndex, forEveryone)
	tes3mp.ClearObjectList()
	tes3mp.SetObjectListPid(pid)
	tes3mp.SetObjectListCell(cellDescription)					
	LoadedCells[cellDescription]:DeleteObjectData(uniqueIndex)
	local splitIndex = uniqueIndex:split("-")
	tes3mp.SetObjectRefNum(splitIndex[1])
	tes3mp.SetObjectMpNum(splitIndex[2])
	tes3mp.AddObject()	
	tes3mp.SendObjectDelete(forEveryone)
	LoadedCells[cellDescription]:QuicksaveToDrive()
end

local DragonDoor = {}

DragonDoor.OnPlayerWarp = function(pid)--place this function in your script to prevent enemies from chasing him
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
		local PlayerName = GetName(pid)	
		if doorTab.player[PlayerName] then
			doorTab.player[PlayerName] = nil
			cellTab.player[PlayerName] = nil
			creaTab.player[PlayerName] = nil
			indexTab.player[PlayerName] = nil
		end
	end
end

DragonDoor.OnPlayerDeath = function(eventStatus, pid)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
		local PlayerName = GetName(pid)	
		if doorTab.player[PlayerName] then
			doorTab.player[PlayerName] = nil
			cellTab.player[PlayerName] = nil
			creaTab.player[PlayerName] = nil
			indexTab.player[PlayerName] = nil
		end
	end
end

DragonDoor.OnObjectActivate = function(eventStatus, pid, cellDescription, objects)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then	
		local ObjectRefid
		local count = 0			
		for _, object in pairs(objects) do
			ObjectRefid = object.refId
		end	
		if ObjectRefid == nil then return end		
		if DoorData[string.lower(ObjectRefid)] then	
			local PlayerName = GetName(pid)			
			doorTab.player[PlayerName] = {object = ObjectRefid} 
			cellTab.player[PlayerName] = {cell = cellDescription} 
			creaTab.player[PlayerName] = {}
			indexTab.player[PlayerName] = {}
			LoadedCells[cellDescription]:SaveActorPositions()
			local cell = LoadedCells[cellDescription]		
			for _, uniqueIndex in pairs(cell.data.packets.actorList) do
				if count == 3 then break end
				if cell.data.objectData[uniqueIndex] then
					if cell.data.objectData[uniqueIndex].refId and cell.data.objectData[uniqueIndex].location then
						local creatureRefId = cell.data.objectData[uniqueIndex].refId
						if NpcData[string.lower(creatureRefId)] or CreaData[string.lower(creatureRefId)] then
							if not tableHelper.containsValue(cell.data.packets.death, uniqueIndex, true) and not tableHelper.containsValue(indexTab.player, uniqueIndex, true) then	
								local playerPosX = tes3mp.GetPosX(pid)
								local playerPosY = tes3mp.GetPosY(pid)								
								local creaturePosX = cell.data.objectData[uniqueIndex].location.posX
								local creaturePosY = cell.data.objectData[uniqueIndex].location.posY							
								local distance = math.sqrt((playerPosX - creaturePosX) * (playerPosX - creaturePosX) + (playerPosY - creaturePosY) * (playerPosY - creaturePosY)) 									
								if distance < cfg.rad then
									table.insert(creaTab.player[PlayerName], creatureRefId)
									table.insert(indexTab.player[PlayerName], uniqueIndex)	
									count = count + 1
								end	
							end
						end
					end
				end
			end	
		end
	end
end

DragonDoor.OnPlayerCellChange = function(eventStatus, pid)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
		local PlayerName = GetName(pid)		
		if creaTab.player[PlayerName] ~= nil and doorTab.player[PlayerName] ~= nil and cellTab.player[PlayerName].cell ~= nil and tes3mp.GetCell(pid) ~= nil and doorTab.player[PlayerName].object ~= nil then
			if tes3mp.GetCell(pid) ~= cellTab.player[PlayerName].cell then	
				local playerPosX = tes3mp.GetPosX(pid)
				local playerPosY = tes3mp.GetPosY(pid)
				local playerPosZ = tes3mp.GetPosZ(pid)	
				local position = { posX = playerPosX, posY = playerPosY, posZ = playerPosZ, rotX = 0, rotY = 0, rotZ = 0 }
				local cellId = tes3mp.GetCell(pid)
				logicHandler.SetCellAuthority(LoadedCells[cellId].authority, cellId)
				for x, y in pairs(creaTab.player[PlayerName]) do	
					local creatureRefId = creaTab.player[PlayerName][x]
					local creatureIndex = logicHandler.CreateObjectAtLocation(cellId, position, dataTableBuilder.BuildObjectData(creatureRefId), "spawn")
					logicHandler.SetAIForActor(LoadedCells[cellId], creatureIndex, "2", pid)
				end
				local cell = LoadedCells[cellTab.player[PlayerName].cell]
				local useTemporaryLoad = false	
				if cell == nil then
					logicHandler.LoadCell(cellTab.player[PlayerName].cell)
					useTemporaryLoad = true
					cell = LoadedCells[cellTab.player[PlayerName].cell]
				end
				for _, uniqueIndex in pairs(indexTab.player[PlayerName]) do
					CleanCellObject(pid, cellTab.player[PlayerName].cell, uniqueIndex, true)
				end							
				if useTemporaryLoad == true then
					logicHandler.UnloadCell(cellTab.player[PlayerName].cell)
				end
			end
		end
		doorTab.player[PlayerName] = nil
		cellTab.player[PlayerName] = nil
		creaTab.player[PlayerName] = nil
		indexTab.player[PlayerName] = nil	
	end
end

customEventHooks.registerValidator("OnPlayerDeath", DragonDoor.OnPlayerDeath)
customEventHooks.registerHandler("OnObjectActivate", DragonDoor.OnObjectActivate)
customEventHooks.registerHandler("OnPlayerCellChange", DragonDoor.OnPlayerCellChange)

return DragonDoor
