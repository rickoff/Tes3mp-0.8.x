--[[
DragonDoor
tes3mp 0.8.1
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

local DragonDoorTab = {}

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

DragonDoor.OnPlayerWarp = function(pid)
	local PlayerName = GetName(pid)	
	if DragonDoorTab[PlayerName] then
		DragonDoorTab[PlayerName] = nil
	end
end

DragonDoor.OnPlayerDeath = function(eventStatus, pid)
	local PlayerName = GetName(pid)	
	if DragonDoorTab[PlayerName] then
		DragonDoorTab[PlayerName] = nil
	end
end

DragonDoor.OnObjectActivate = function(eventStatus, pid, cellDescription, objects)
	local ObjectRefid
	local count = 0			
	for _, object in pairs(objects) do
		ObjectRefid = object.refId
	end	
	if ObjectRefid == nil then return end		
	if DoorData[string.lower(ObjectRefid)] then	
		local PlayerName = GetName(pid)
		DragonDoorTab[PlayerName] = {object = ObjectRefid, creature = {}, index = {}}
		LoadedCells[cellDescription]:SaveActorPositions()
		local cell = LoadedCells[cellDescription]		
		for _, uniqueIndex in pairs(cell.data.packets.actorList) do
			if count == 3 then break end
			if cell.data.objectData[uniqueIndex] 
			and cell.data.objectData[uniqueIndex].refId 
			and cell.data.objectData[uniqueIndex].location then
				local creatureRefId = cell.data.objectData[uniqueIndex].refId
				if NpcData[string.lower(creatureRefId)] or CreaData[string.lower(creatureRefId)] then
					if not tableHelper.containsValue(cell.data.packets.death, uniqueIndex, true) 
					and not tableHelper.containsValue(DragonDoorTab[PlayerName].index, uniqueIndex, true) then	
						local playerPosX = tes3mp.GetPosX(pid)
						local playerPosY = tes3mp.GetPosY(pid)								
						local creaturePosX = cell.data.objectData[uniqueIndex].location.posX
						local creaturePosY = cell.data.objectData[uniqueIndex].location.posY							
						local distance = math.sqrt((playerPosX - creaturePosX)^2 + (playerPosY - creaturePosY)^2) 									
						if distance < cfg.rad then
							table.insert(DragonDoorTab[PlayerName].creature, creatureRefId)
							table.insert(DragonDoorTab[PlayerName].index, uniqueIndex)	
							count = count + 1
						end	
					end
				end
			end
		end	
	end
end

DragonDoor.OnPlayerCellChange = function(eventStatus, pid, playerPacket, previousCellDescription)
	local PlayerName = GetName(pid)
	local cellDescription = playerPacket.location.cell
	if DragonDoorTab[PlayerName] 
	and DragonDoorTab[PlayerName].object 
	and DragonDoorTab[PlayerName].creature 
	and DragonDoorTab[PlayerName].index then
		if cellDescription ~= previousCellDescription then	
			local playerPosX = tes3mp.GetPosX(pid)
			local playerPosY = tes3mp.GetPosY(pid)
			local playerPosZ = tes3mp.GetPosZ(pid)	
			local position = { posX = playerPosX, posY = playerPosY, posZ = playerPosZ, rotX = 0, rotY = 0, rotZ = 0 }
			logicHandler.SetCellAuthority(pid, cellDescription)
			for _, refId in ipairs(DragonDoorTab[PlayerName].creature) do	
				local creatureIndex = logicHandler.CreateObjectAtLocation(cellDescription, position, dataTableBuilder.BuildObjectData(refId), "spawn")
				logicHandler.SetAIForActor(LoadedCells[cellDescription], creatureIndex, "2", pid)
			end
			local cell = LoadedCells[previousCellDescription]
			local useTemporaryLoad = false	
			if cell == nil then
				logicHandler.LoadCell(previousCellDescription)
				useTemporaryLoad = true
				cell = LoadedCells[previousCellDescription]
			end
			for _, uniqueIndex in ipairs(DragonDoorTab[PlayerName].index) do
				CleanCellObject(pid, previousCellDescription, uniqueIndex, true)
			end							
			if useTemporaryLoad == true then
				logicHandler.UnloadCell(previousCellDescription)
			end
		end
	end
	DragonDoorTab[PlayerName] = nil
end

DragonDoor.OnPlayerSpellsActive = function(eventStatus, pid, playerPacket)
	local action = playerPacket.action		
	for spellId, spellInstances in pairs(playerPacket.spellsActive) do
		for _, spellInstance in ipairs(spellInstances) do	
			for _, effect in ipairs(spellInstance.effects) do		
				if effect.id == enumerations.effects.ALMSIVI_INTERVENTION then
					DragonDoor.OnPlayerWarp(pid)
					break
				elseif effect.id == enumerations.effects.DIVINE_INTERVENTION then		
					DragonDoor.OnPlayerWarp(pid)
					break
				elseif effect.id == enumerations.effects.RECALL then		
					DragonDoor.OnPlayerWarp(pid)
					break
				end
			end	
		end
	end
end

customEventHooks.registerValidator("OnPlayerSpellsActive", DragonDoor.OnPlayerSpellsActive)
customEventHooks.registerValidator("OnPlayerDeath", DragonDoor.OnPlayerDeath)
customEventHooks.registerHandler("OnObjectActivate", DragonDoor.OnObjectActivate)
customEventHooks.registerHandler("OnPlayerCellChange", DragonDoor.OnPlayerCellChange)

return DragonDoor
