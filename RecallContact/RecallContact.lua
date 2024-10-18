--[[
RecallContact
tes3mp 0.8.1
---------------------------
INSTALLATION:
Save the file as RecallContact.lua inside your server/scripts/custom folder.
Edits to customScripts.lua
require("custom.RecallContact")
---------------------------
]]
local cfg = {
	onServerInit = true,
	addSpellsOnAuth = true,
	players = true,
	actors = true,
	costMark = 18,
	costRecall = 18
}

local trd = {
	DropMark = "Impossible to teleport a character without having placed a mark."
}

local protectActor = {
	["0-0"] = true,
	["player"] = true
}

local function RecallPlayer(pid, pos)   
	tes3mp.SetCell(pid, pos.cellDescription)
	tes3mp.SendCell(pid)
	tes3mp.SetPos(pid, pos.posX, pos.posY, pos.posZ)
	tes3mp.SetRot(pid, pos.rotX, pos.rotZ)				
	tes3mp.SendPos(pid)		
end

local function RecallActor(pid, uniqueIndex, cellDescription, location)   
    tes3mp.ClearActorList()
    tes3mp.SetActorListPid(pid)
    tes3mp.SetActorListCell(cellDescription)	
	local splitIndex = uniqueIndex:split("-")
	tes3mp.SetActorRefNum(splitIndex[1])
	tes3mp.SetActorMpNum(splitIndex[2])
	tes3mp.SetActorPosition(location.posX, location.posY, location.posZ)
	tes3mp.SetActorRotation(location.rotX, location.rotY, location.rotZ)		
	tes3mp.AddActor()
	tes3mp.SendActorPosition(true)
	LoadedCells[cellDescription].data.objectData[uniqueIndex].location = {
		posX = location.posX,
		posY = location.posY,
		posZ = location.posZ,
		rotX = location.rotX,
		rotY = location.rotY,
		rotZ = location.rotZ
	}
	LoadedCells[cellDescription]:QuicksaveToDrive()
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
	local oldCellDescriptionData = LoadedCells[oldCellDescription]	
	local newCellDescriptionData = LoadedCells[newCellDescription]	
    local actorCount = 0
    tes3mp.ClearActorList()
    tes3mp.SetActorListPid(pid)
    tes3mp.SetActorListCell(oldCellDescription)	
    for _, uniqueIndex in ipairs(actorList) do
		if oldCellDescriptionData.data.objectData[uniqueIndex] then
			local refId = oldCellDescriptionData.data.objectData[uniqueIndex].refId			
			tes3mp.SetActorCell(newCellDescription)
			local splitIndex = uniqueIndex:split("-")
			tes3mp.SetActorRefNum(splitIndex[1])
			tes3mp.SetActorMpNum(splitIndex[2])
			tes3mp.SetActorPosition(location.posX, location.posY, location.posZ)
			tes3mp.SetActorRotation(location.rotX, location.rotY, location.rotZ)
			tes3mp.AddActor()
			actorCount = actorCount + 1			
			if tableHelper.containsValue(oldCellDescriptionData.data.packets.spawn, uniqueIndex) then
				if logicHandler.IsGeneratedRecord(refId) then
					local recordStore = logicHandler.GetRecordStoreByRecordId(refId)
					if recordStore ~= nil then
						newCellDescriptionData:AddLinkToRecord(recordStore.storeType, refId, uniqueIndex)
						oldCellDescriptionData:RemoveLinkToRecord(recordStore.storeType, refId, uniqueIndex)
					end
					for _, visitorPid in pairs(newCellDescriptionData.visitors) do
						if pid ~= visitorPid then
							recordStore:LoadGeneratedRecords(visitorPid, recordStore.data.generatedRecords, { refId })
						end
					end
				end
				for _, player in pairs(Players) do
					if pid ~= player.pid and not tableHelper.containsValue(oldCellDescriptionData.visitors, player.pid) then
						oldCellDescriptionData:LoadActorPackets(player.pid, oldCellDescriptionData.data.objectData, { uniqueIndex })
					end
				end
				oldCellDescriptionData:MoveObjectData(uniqueIndex, newCellDescriptionData)
			elseif tableHelper.containsValue(oldCellDescriptionData.data.packets.cellChangeFrom, uniqueIndex) then
				local originalCellDescription = oldCellDescriptionData.data.objectData[uniqueIndex].cellChangeFrom
				if originalCellDescription == newCellDescription then
					oldCellDescriptionData:MoveObjectData(uniqueIndex, newCellDescriptionData)
					tableHelper.removeValue(newCellDescriptionData.data.packets.cellChangeTo, uniqueIndex)
					tableHelper.removeValue(newCellDescriptionData.data.packets.cellChangeFrom, uniqueIndex)
					newCellDescriptionData.data.objectData[uniqueIndex].cellChangeTo = nil
					newCellDescriptionData.data.objectData[uniqueIndex].cellChangeFrom = nil
				else
					oldCellDescriptionData:MoveObjectData(uniqueIndex, newCellDescriptionData)
					if not LoadedCells[originalCellDescription] then
						logicHandler.LoadCell(originalCellDescription)
						table.insert(temporaryLoadedCells, originalCellDescription)
					end
					local originalCell = LoadedCells[originalCellDescription]
					if originalCell.data.objectData[uniqueIndex] then
						originalCell.data.objectData[uniqueIndex].cellChangeTo = newCellDescription
					end
				end
			elseif oldCellDescriptionData.data.objectData[uniqueIndex].cellChangeTo ~= newCellDescription then
				oldCellDescriptionData:MoveObjectData(uniqueIndex, newCellDescriptionData)
				table.insert(oldCellDescriptionData.data.packets.cellChangeTo, uniqueIndex)
				if not oldCellDescriptionData.data.objectData[uniqueIndex] then
					oldCellDescriptionData.data.objectData[uniqueIndex] = {}
				end
				oldCellDescriptionData.data.objectData[uniqueIndex].cellChangeTo = newCellDescription
				table.insert(newCellDescriptionData.data.packets.cellChangeFrom, uniqueIndex)
				newCellDescriptionData.data.objectData[uniqueIndex].cellChangeFrom = oldCellDescriptionData.description
			end
			if newCellDescriptionData.data.objectData[uniqueIndex] then
				newCellDescriptionData.data.objectData[uniqueIndex].location = {
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
        tes3mp.SendActorCellChange(true)
    end
    oldCellDescriptionData:QuicksaveToDrive()
    newCellDescriptionData:QuicksaveToDrive()		
    for _, cellDescription in ipairs(temporaryLoadedCells) do
        logicHandler.UnloadCell(cellDescription)
    end
end

customEventHooks.registerHandler("OnServerInit", function(eventStatus)
	if cfg.onServerInit then
		local recordStoreSpells = RecordStores["spell"]
		local recordTable
		recordTable = {
			name = "Mark Contact",
			cost = cfg.costMark,	  
			subtype = 0,
			flags = 1,
			effects = {
				{
					attribute = -1,
					area = 0,
					duration = 0,
					id = 60,
					rangeType = 0,
					skill = -1,
					magnitudeMax = 0,
					magnitudeMin = 0
				}
			}
		}
		recordStoreSpells.data.permanentRecords["mark_contact"] = recordTable
		recordTable = {
			name = "Recall Contact",
			cost = cfg.costRecall,		
			subtype = 0,
			flags = 1,
			effects = {
				{
					attribute = -1,
					area = 0,
					duration = 0,
					id = 61,
					rangeType = 1,
					skill = -1,
					magnitudeMax = 0,
					magnitudeMin = 0
				}
			}
		}
		recordStoreSpells.data.permanentRecords["recall_contact"] = recordTable
		recordStoreSpells:Save()
	end
end)

customEventHooks.registerHandler("OnPlayerSpellsActive", function(eventStatus, pid, playerPacket)
	if not cfg.players then return end
	for spellId, spellInstances in pairs(playerPacket.spellsActive) do
		if spellId == "recall_contact" then
			for _, spellInstance in ipairs(spellInstances) do
				if spellInstance.caster.pid then
					local casterPid = spellInstance.caster.pid	
					if casterPid ~= -1 and pid ~= casterPid and Players[casterPid] then
						if Players[casterPid].data.customVariables.markContact then
							RecallPlayer(pid, Players[casterPid].data.customVariables.markContact)
						else
							tes3mp.MessageBox(pid, -1, trd.DropMark)
						end
						break
					end
				end
			end
		elseif spellId == "mark_contact" then
			Players[pid].data.customVariables.markContact = {}
			Players[pid].data.customVariables.markContact = {
				cellDescription = tes3mp.GetCell(pid),
				posX = tes3mp.GetPosX(pid),
				posY = tes3mp.GetPosY(pid),
				posZ = tes3mp.GetPosZ(pid),
				rotX = tes3mp.GetRotX(pid),
				rotY = 0,
				rotZ = tes3mp.GetRotZ(pid)	
			}
		end
	end
end)

customEventHooks.registerHandler("OnActorSpellsActive", function(eventStatus, pid, cellDescription, actorPacket)
	if not cfg.actors then return end
	for _, actor in pairs(actorPacket) do
		local uniqueIndex = actor.uniqueIndex
		local refId = actor.refId
		if protectActor[uniqueIndex] or protectActor[refId] then return end
		for spellId, spellInstances in pairs(actor.spellsActive) do
			if spellId == "recall_contact" then
				for _, spellInstance in ipairs(spellInstances) do
					if spellInstance.caster.pid then
						local casterPid = spellInstance.caster.pid
						if casterPid and Players[casterPid] then
							if Players[casterPid].data.customVariables.markContact then
								local targetLocation = Players[casterPid].data.customVariables.markContact
								local newCellDescription = targetLocation.cellDescription
								if newCellDescription == cellDescription then								
									RecallActor(casterPid, uniqueIndex, cellDescription, targetLocation) 
								else
									ActorCellChanges(casterPid, cellDescription, newCellDescription, {uniqueIndex}, targetLocation)
								end
							else
								tes3mp.MessageBox(pid, -1, trd.DropMark)
							end
							break
						end
					end
				end
			end
		end
	end
end)

customEventHooks.registerHandler("OnPlayerAuthentified", function(eventStatus, pid)
	if cfg.addSpellsOnAuth then
		local spellsId = {}
		if not tableHelper.containsValue(Players[pid].data.spellbook, "mark_contact") then
			table.insert(spellsId, "mark_contact")
		end
		if not tableHelper.containsValue(Players[pid].data.spellbook, "recall_contact") then
			table.insert(spellsId, "recall_contact")
		end	
		if #spellsId > 0 then
			AddSpell(pid, spellsId)
		end
	end
end)
