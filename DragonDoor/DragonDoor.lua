--[[
DragonDoor
tes3mp 0.8.1
script version 1.0
---------------------------
DESCRIPTION :
creatures and hostile npc follow players through doors
---------------------------
INSTALLATION:
Save the file as DragonDoor.lua inside your server/scripts/custom/DragonDoor folder.
Save the file as DoorData.lua inside your server/scripts/custom/DragonDoor folder.
Save the file as NpcsData.lua inside your server/scripts/custom/DragonDoor folder.
Save the file as CreaData.lua inside your server/scripts/custom/DragonDoor folder.
Edits to customScripts.lua add in : require("custom.DragonDoor.DragonDoor")
]]
require("custom.DragonDoor.DataDoor")
require("custom.DragonDoor.DataCrea")
require("custom.DragonDoor.DataNpcs")

local cfg = {
	distance = 1500, --maximum distance between the player and the target actor
	height = 30, --maximum height between player and target actor
	count = 3 --maximum target actor count
}

local DragonDoorTab = {}

local function GetName(pid)
	return string.lower(Players[pid].accountName)
end

local function CalculEcart(valueA, valueB)
	local a = math.abs(valueA) 
	local b = math.abs(valueB)
	local ecart = 0	
	if a > b then
		ecart = a - b
	else
		ecart = b - a
	end	
	return ecart
end

local function CleanTab(pid)
	local PlayerName = GetName(pid)	
	if DragonDoorTab[PlayerName] then
		DragonDoorTab[PlayerName] = nil		
	end
end

local function ActorCellChanges(pid, oldCellDescription, newCellDescription, actorList, location)

    local temporaryLoadedCells = {}

	if not LoadedCells[oldCellDescription] then
		logicHandler.LoadCell(oldCellDescription)
		table.insert(temporaryLoadedCells, oldCellDescription)
	end
	
	if not LoadedCells[newCellDescription] then
		logicHandler.LoadCell(newCellDescription)
		table.insert(temporaryLoadedCells, newCellDescription)
	end

    local actorCount = 0

    tes3mp.ClearActorList()
    tes3mp.SetActorListPid(pid)
    tes3mp.SetActorListCell(oldCellDescription)
	
    for _, uniqueIndex in ipairs(actorList) do

		tes3mp.SetActorCell(newCellDescription)

		local splitIndex = uniqueIndex:split("-")
		tes3mp.SetActorRefNum(splitIndex[1])
		tes3mp.SetActorMpNum(splitIndex[2])

		tes3mp.SetActorPosition(location.posX, location.posY, location.posZ)
		tes3mp.SetActorRotation(location.rotX, location.rotY, location.rotZ)

		tes3mp.AddActor()

		actorCount = actorCount + 1

		if LoadedCells[oldCellDescription].data.objectData[uniqueIndex] then

			if tableHelper.containsValue(LoadedCells[oldCellDescription].data.packets.spawn, uniqueIndex) then

				local refId = LoadedCells[oldCellDescription].data.objectData[uniqueIndex].refId

				if logicHandler.IsGeneratedRecord(refId) then

					local recordStore = logicHandler.GetRecordStoreByRecordId(refId)

					if recordStore ~= nil then
						LoadedCells[newCellDescription]:AddLinkToRecord(recordStore.storeType, refId, uniqueIndex)
						LoadedCells[oldCellDescription]:RemoveLinkToRecord(recordStore.storeType, refId, uniqueIndex)
					end

					for _, visitorPid in pairs(LoadedCells[newCellDescription].visitors) do
						if pid ~= visitorPid then
							recordStore:LoadGeneratedRecords(visitorPid, recordStore.data.generatedRecords, { refId })
						end
					end
				end

				for _, player in pairs(Players) do
					if pid ~= player.pid and not tableHelper.containsValue(LoadedCells[oldCellDescription].visitors, player.pid) then
						LoadedCells[oldCellDescription]:LoadActorPackets(player.pid, LoadedCells[oldCellDescription].data.objectData, { uniqueIndex })
					end
				end

				LoadedCells[oldCellDescription]:MoveObjectData(uniqueIndex, LoadedCells[newCellDescription])

			elseif tableHelper.containsValue(LoadedCells[oldCellDescription].data.packets.cellChangeFrom, uniqueIndex) then

				local originalCellDescription = LoadedCells[oldCellDescription].data.objectData[uniqueIndex].cellChangeFrom

				if originalCellDescription == newCellDescription then
					LoadedCells[oldCellDescription]:MoveObjectData(uniqueIndex, LoadedCells[newCellDescription])

					tableHelper.removeValue(LoadedCells[newCellDescription].data.packets.cellChangeTo, uniqueIndex)
					tableHelper.removeValue(LoadedCells[newCellDescription].data.packets.cellChangeFrom, uniqueIndex)

					LoadedCells[newCellDescription].data.objectData[uniqueIndex].cellChangeTo = nil
					LoadedCells[newCellDescription].data.objectData[uniqueIndex].cellChangeFrom = nil
				else
					LoadedCells[oldCellDescription]:MoveObjectData(uniqueIndex, LoadedCells[newCellDescription])

					if not LoadedCells[originalCellDescription] then
						logicHandler.LoadCell(originalCellDescription)
						table.insert(temporaryLoadedCells, originalCellDescription)
					end

					local originalCell = LoadedCells[originalCellDescription]

					if originalCell.data.objectData[uniqueIndex] then
						originalCell.data.objectData[uniqueIndex].cellChangeTo = newCellDescription
					end
				end

			elseif LoadedCells[oldCellDescription].data.objectData[uniqueIndex].cellChangeTo ~= newCellDescription then

				LoadedCells[oldCellDescription]:MoveObjectData(uniqueIndex, LoadedCells[newCellDescription])

				table.insert(LoadedCells[oldCellDescription].data.packets.cellChangeTo, uniqueIndex)

				if not LoadedCells[oldCellDescription].data.objectData[uniqueIndex] then
					LoadedCells[oldCellDescription].data.objectData[uniqueIndex] = {}
				end

				LoadedCells[oldCellDescription].data.objectData[uniqueIndex].cellChangeTo = newCellDescription

				table.insert(LoadedCells[newCellDescription].data.packets.cellChangeFrom, uniqueIndex)

				LoadedCells[newCellDescription].data.objectData[uniqueIndex].cellChangeFrom = LoadedCells[oldCellDescription].description
			end

			if LoadedCells[newCellDescription].data.objectData[uniqueIndex] then
				LoadedCells[newCellDescription].data.objectData[uniqueIndex].location = {
					posX = location.posX,
					posY = location.posY,
					posZ = location.posZ,
					rotX = location.rotX,
					rotY = location.rotY,
					rotZ = location.rotZ
				}
			end
		end
    end

    if actorCount > 0 then
        tes3mp.SendActorCellChange()
    end

    LoadedCells[oldCellDescription]:QuicksaveToDrive()
    LoadedCells[newCellDescription]:QuicksaveToDrive()	
	
    for arrayIndex, newCellDescription in pairs(temporaryLoadedCells) do
        logicHandler.UnloadCell(newCellDescription)
    end
end

local function GetActorPositions(cellDescription, uniqueIndex)
    tes3mp.ReadCellActorList(cellDescription)
    local actorListSize = tes3mp.GetActorListSize()
    if actorListSize == 0 then
        return false
    end
    for objectIndex = 0, actorListSize - 1 do
        local targetIndex = tes3mp.GetActorRefNum(objectIndex) .. "-" .. tes3mp.GetActorMpNum(objectIndex)
        if targetIndex == uniqueIndex then
            local location = {
                posX = tes3mp.GetActorPosX(objectIndex),
                posY = tes3mp.GetActorPosY(objectIndex),
                posZ = tes3mp.GetActorPosZ(objectIndex)
            }
			return location
        end
    end
end

customEventHooks.registerValidator("OnPlayerDeath", function(eventStatus, pid)
	CleanTab(pid)
end)

customEventHooks.registerHandler("OnObjectActivate", function(eventStatus, pid, cellDescription, objects)
	local count = 0			
	for _, object in pairs(objects) do
		if object.refId and DataDoor[string.lower(object.refId)] then	
			local PlayerName = GetName(pid)			
			DragonDoorTab[PlayerName] = {door = true, uniqueIndex = {}, cellDescription = cellDescription}
			local cell = LoadedCells[cellDescription]			
			for _, uniqueIndex in ipairs(cell.data.packets.actorList) do				
				local valide = false				
				if count == cfg.count then break end
				if not tableHelper.containsValue(cell.data.packets.death, uniqueIndex) 
				and not tableHelper.containsValue(DragonDoorTab[PlayerName].uniqueIndex, uniqueIndex)				
				and cell.data.objectData[uniqueIndex] 
				and cell.data.objectData[uniqueIndex].refId 
				and cell.data.objectData[uniqueIndex].location then				
					local actorRefId = string.lower(cell.data.objectData[uniqueIndex].refId)			
					if DataNpcs[actorRefId] or DataCrea[actorRefId] then
						valide = true						
					end
					if cell.data.objectData[uniqueIndex].ai and cell.data.objectData[uniqueIndex].ai.action and cell.data.objectData[uniqueIndex].ai.targetPlayer
					and cell.data.objectData[uniqueIndex].ai.action == 2 and string.lower(cell.data.objectData[uniqueIndex].ai.targetPlayer) == PlayerName then					
						valide = true						
					end	
					if valide then	
						local creaturePos = GetActorPositions(cellDescription, uniqueIndex)	
						local playerPosX = tes3mp.GetPosX(pid)
						local playerPosY = tes3mp.GetPosY(pid)
						local playerPosZ = tes3mp.GetPosZ(pid)								
						local creaturePosX = creaturePos.posX
						local creaturePosY = creaturePos.posY
						local creaturePosZ = creaturePos.posZ								
						local distance = math.sqrt((playerPosX - creaturePosX)^2 + (playerPosY - creaturePosY)^2) 					
						local height = CalculEcart(playerPosZ, creaturePosZ)						
						if distance <= cfg.distance and height <= cfg.height then
							table.insert(DragonDoorTab[PlayerName].uniqueIndex, uniqueIndex)	
							count = count + 1
						end							
					end
				end
			end	
		end
	end
end)

customEventHooks.registerHandler("OnPlayerCellChange", function(eventStatus, pid, playerPacket, previousCellDescription)
	local PlayerName = GetName(pid)
	local cellDescription = playerPacket.location.cell	
	if DragonDoorTab[PlayerName] 
	and DragonDoorTab[PlayerName].door 
	and DragonDoorTab[PlayerName].cellDescription
	and not tableHelper.isEmpty(DragonDoorTab[PlayerName].uniqueIndex) then		
		if cellDescription ~= previousCellDescription and previousCellDescription == DragonDoorTab[PlayerName].cellDescription then			
			local playerPosX = tes3mp.GetPosX(pid)
			local playerPosY = tes3mp.GetPosY(pid)
			local playerPosZ = tes3mp.GetPosZ(pid)	
			local position = { posX = playerPosX, posY = playerPosY, posZ = playerPosZ, rotX = 0, rotY = 0, rotZ = 0 }		
			ActorCellChanges(pid, previousCellDescription, cellDescription, DragonDoorTab[PlayerName].uniqueIndex, position)
		end		
	end	
	DragonDoorTab[PlayerName] = nil
end)

customEventHooks.registerValidator("OnPlayerSpellsActive", function(eventStatus, pid, playerPacket)
	local action = playerPacket.action	
	for spellId, spellInstances in pairs(playerPacket.spellsActive) do
		for _, spellInstance in ipairs(spellInstances) do	
			for _, effect in ipairs(spellInstance.effects) do		
				if effect.id == enumerations.effects.ALMSIVI_INTERVENTION then
					CleanTab(pid)
					break
				elseif effect.id == enumerations.effects.DIVINE_INTERVENTION then		
					CleanTab(pid)
					break
				elseif effect.id == enumerations.effects.RECALL then		
					CleanTab(pid)
					break
				end
			end	
		end
	end
end)
