--[[
GrassGeneration
tes3mp 0.8.1
---------------------------
DESCRIPTION :
grass, forest and random creature generation when starting the server
---------------------------
INSTALLATION:
Save the file as GrassGeneration.lua inside your server/scripts/custom folder.
Save the fodler as GrassGeneration inside your server/data/custom folder.
Edits to customScripts.lua
GrassGeneration = require("custom.GrassGeneration")
---------------------------
INSTRUCTION:
For your first launch activate cfg.OnServerPostInit = true
wait about for all the elements to be created
after that, cfg.OnServerPostInit = false
restart your server
Add 'GrassGeneration.OnResetGrass(pid, cellDescription)' in your Reset Cell Script after your reset for each cell
---------------------------
CONFIGURATION:
cfg.OnServerPostInit = true --activate auto generation cell at start
cfg.CleanCell = true --activate auto clean cell at start
cfg.DensityGrass = 1000 --density grass 0 for disabled
cfg.DensityTree = 10 --density tree 0 for disabled
cfg.DensityCrea = 1 --density creature 0 for disabled
information, too many elements cause a very large drop in framerate
---------------------------
COMMANDS:
only for player staff
/resetgrass for reset cell
/cleangrass for clean cell
---------------------------
]]	

---------------
-- JSON-DATA --
---------------
local DataCellsName = jsonInterface.load("custom/GrassGeneration/DataCellsName.json")
local DataGrasRefId = jsonInterface.load("custom/GrassGeneration/DataGrasRefId.json")
local DataCreaRefId = jsonInterface.load("custom/GrassGeneration/DataCreaRefId.json")
local DataTreeRefId = jsonInterface.load("custom/GrassGeneration/DataTreeRefId.json")

------------
-- CONFIG --
------------
local cfg = {
	OnServerPostInit = true,
	CleanCell = false,
	DensityGrass = 1000,
	DensityTree = 8,
	DensityCrea = 1
}
--------------
-- VARIABLE --
--------------
local ListCellToReset =  {}

local WorldMpNum

local ListGrass = {}
for refId, bool in pairs(DataGrasRefId) do
	table.insert(ListGrass, refId)
end

local ListTree = {}
for refId, bool in pairs(DataTreeRefId) do
	table.insert(ListTree, refId)
end

local ListCrea = {}
for refId, bool in pairs(DataCreaRefId) do
	table.insert(ListCrea, refId)
end

--------------
-- FUNCTION --
--------------
local function RandomGrassId()
	return ListGrass[math.random(1, #ListGrass)]
end

local function RandomTreeId()
	return ListTree[math.random(1, #ListTree)]	
end

local function RandomCreaId()
	return ListCrea[math.random(1, #ListCrea)]	
end

local function CleanCell(pid, cellDescription)

    tes3mp.ClearObjectList()
    tes3mp.SetObjectListPid(pid)
    tes3mp.SetObjectListCell(cellDescription)

    local objectCount = 0
	
	local cell = LoadedCells[cellDescription]

	local useTemporaryLoad = false	
	
	if cell == nil then
		logicHandler.LoadCell(cellDescription)
		useTemporaryLoad = true
		cell = LoadedCells[cellDescription]
	end
	
	for _, uniqueIndex in pairs(cell.data.packets.place) do
	
		if cell.data.objectData[uniqueIndex] and cell.data.objectData[uniqueIndex].refId then
		
			local refId = cell.data.objectData[uniqueIndex].refId
			
			if DataGrasRefId[string.lower(refId)] or DataTreeRefId[string.lower(refId)] then
			
				local splitIndex = uniqueIndex:split("-")
				tes3mp.SetObjectRefNum(splitIndex[1])
				tes3mp.SetObjectMpNum(splitIndex[2])
				tes3mp.AddObject()
				objectCount = objectCount + 1					
				cell:DeleteObjectData(uniqueIndex)	
				
			end
		end
		
		if objectCount >= 3000 then
			tes3mp.SendObjectDelete(true)		
			tes3mp.ClearObjectList()
			tes3mp.SetObjectListPid(pid)
			tes3mp.SetObjectListCell(cellDescription)			
			objectCount = 0
		end			
		
	end	
	
	for _, uniqueIndex in pairs(cell.data.packets.actorList) do
		
		if cell.data.objectData[uniqueIndex] and cell.data.objectData[uniqueIndex].refId then
		
			local actorRefId = cell.data.objectData[uniqueIndex].refId	
			
			if DataCreaRefId[string.lower(actorRefId)] then
			
				local splitIndex = uniqueIndex:split("-")
				tes3mp.SetObjectRefNum(splitIndex[1])
				tes3mp.SetObjectMpNum(splitIndex[2])
				tes3mp.AddObject()	
				objectCount = objectCount + 1				
				cell:DeleteObjectData(uniqueIndex)	
				
			end
			
		end
		
		if objectCount >= 3000 then
			tes3mp.SendObjectDelete(true)			
			tes3mp.ClearObjectList()
			tes3mp.SetObjectListPid(pid)
			tes3mp.SetObjectListCell(cellDescription)			
			objectCount = 0
		end	
		
	end	
	
	if objectCount > 0 then
		tes3mp.SendObjectDelete(true)
	end
	
	if useTemporaryLoad == true then
		logicHandler.UnloadCell(cellDescription)
	else
		cell:QuicksaveToDrive()	
	end	
	
end
	
local function CleanCellJson(cellData)
	
	for _, uniqueIndex in pairs(cellData.packets.place) do

		if cellData.objectData[uniqueIndex] and cellData.objectData[uniqueIndex].refId then
		
			local refId = cellData.objectData[uniqueIndex].refId
			
			if DataGrasRefId[string.lower(refId)] or DataTreeRefId[string.lower(refId)] then
				
				tableHelper.removeValue(cellData.packets, uniqueIndex)	
				cellData.objectData[uniqueIndex] = nil
				
			end
		end
		
	end
	
	for _, uniqueIndex in pairs(cellData.packets.actorList) do
		
		if cellData.objectData[uniqueIndex] and cellData.objectData[uniqueIndex].refId then
		
			local actorRefId = cellData.objectData[uniqueIndex].refId	
			
			if DataCreaRefId[string.lower(actorRefId)] then

				tableHelper.removeValue(cellData.packets, uniqueIndex)	
				cellData.objectData[uniqueIndex] = nil
				
			end

		end
		
	end	

	return cellData
	
end

local function CreateObjectAtLocation(cellDescription, location, refId, packetType, scale)

	local scale = scale or 1
	local mpNum = WorldMpNum + 1
	local uniqueIndex =  0 .. "-" .. mpNum	
	
	LoadedCells[cellDescription]:InitializeObjectData(uniqueIndex, refId)
	
	if LoadedCells[cellDescription].data.objectData[uniqueIndex] then
	
		LoadedCells[cellDescription].data.objectData[uniqueIndex].location = location
		LoadedCells[cellDescription].data.objectData[uniqueIndex].scale = scale		
		
		if packetType == "place" then
		
			table.insert(LoadedCells[cellDescription].data.packets.place, uniqueIndex)
			table.insert(LoadedCells[cellDescription].data.packets.scale, uniqueIndex)
			
		elseif packetType == "spawn" then
		
			table.insert(LoadedCells[cellDescription].data.packets.spawn, uniqueIndex)
			table.insert(LoadedCells[cellDescription].data.packets.actorList, uniqueIndex)
			table.insert(LoadedCells[cellDescription].data.packets.scale, uniqueIndex)
			
		end
		
	end
	
	WorldMpNum = mpNum	
end

local function CreateObjectAtLocationJson(CellCible, location, refId, packetType, scale)	

	local scale = scale or 1
	local mpNum = WorldMpNum + 1	
	local uniqueIndex =  0 .. "-" .. mpNum	
	
	if uniqueIndex ~= nil and refId ~= nil and CellCible.objectData[uniqueIndex] == nil then	
	
		CellCible.objectData[uniqueIndex] = {}
		CellCible.objectData[uniqueIndex].refId = refId
		CellCible.objectData[uniqueIndex].location = location
		CellCible.objectData[uniqueIndex].scale = scale
		
		if packetType == "place" then
		
			table.insert(CellCible.packets.place, uniqueIndex)
			table.insert(CellCible.packets.scale, uniqueIndex)
			
		elseif packetType == "spawn" then
		
			table.insert(CellCible.packets.spawn, uniqueIndex)
			table.insert(CellCible.packets.actorList, uniqueIndex)
			table.insert(CellCible.packets.scale, uniqueIndex)
		
		end
	end	
	
	WorldMpNum = mpNum
	
	return CellCible
	
end

local function CreateCellBase(cellDescription)
	CellCible = {}
	CellCible =
	{
		entry = {
			description = cellDescription,
			creationTime = os.time()
		},
		loadState = {
			hasFullActorList = false,
			hasFullContainerData = false
		},		
		visitors = {},
		lastVisit = {},
		objectData = {},
		packets = {},
		recordLinks = {},
		authority = {},
		isRequestingContainers = false,
		containerRequestPid = {},
		isRequestingActorList = false,
		actorListRequestPid = {},
		unusableContainerUniqueIndexes = {},
		isExterior = false
	}

	if CellCible.packets == nil then CellCible.packets = {} end
	
	for _, packetType in pairs(config.cellPacketTypes) do
	
		if CellCible.packets[packetType] == nil then
		
			CellCible.packets[packetType] = {}
			
		end
		
	end	
	
	if string.match(cellDescription, patterns.exteriorCell) then
	
		CellCible.isExterior = true
		
		local _, _, gridX, gridY = string.find(cellDescription, patterns.exteriorCell)
		
		CellCible.gridX = tonumber(gridX)
		
		CellCible.gridY = tonumber(gridY)
		
	end
	
	return CellCible
end

local function CheckCell()

	tes3mp.LogAppend(enumerations.log.INFO, "....START CLEAN CELL....")
	
	local count = 0
	
	local timeStart = os.time()
	
	for cellDescription, data in pairs(DataCellsName) do
	
		count = count + 1
		
		local pourcent = math.floor((count * 100) / 2888)
		
		local CellCible = jsonInterface.load("cell/"..cellDescription..".json")
		
		if not CellCible then
		
			CellCible = CreateCellBase(cellDescription)
			tes3mp.LogAppend(enumerations.log.INFO, "....CELL CREATE IN : "..cellDescription.."......PROGRESS : "..pourcent.." %")	
			
		else
		
			CellCible = CleanCellJson(CellCible)
			tes3mp.LogAppend(enumerations.log.INFO, "....CELL CLEAN IN : "..cellDescription.."......PROGRESS : "..pourcent.." %")
			
		end
		
		jsonInterface.quicksave("cell/"..cellDescription..".json", CellCible)
		
	end
	
	local timeEnd = os.time() - timeStart
	
	tes3mp.LogAppend(enumerations.log.INFO, "....CELL CLEAN TERMINATE IN : "..math.floor(timeEnd).." secondes".."....TOTAL : "..count.." cell")
	tes3mp.LogAppend(enumerations.log.INFO, "....PLEASE WAIT FOR START WORLD GENERATION....")	
	
end

local function GenerateGrass()

	local count = 0	
	
	local timeStart = os.time()	
	
	WorldMpNum = WorldInstance:GetCurrentMpNum()
	
	for cellDescription, bool in pairs(DataCellsName) do
	
		count = count + 1
		
		local CellGrass = jsonInterface.load("custom/GrassGeneration/cell/"..cellDescription..".json")	
		
		local CellCible = jsonInterface.load("cell/"..cellDescription..".json")
		
		for index, data in pairs(CellGrass[1].objects) do
		
			if data.pos then
			
				local randomGras = math.random(1, 1000)
				local randomCrea = math.random(1, 1000)
				local randomTree = math.random(1, 1000)
				
				local position = {
					posX = tonumber(data.pos.XPos),
					posY = tonumber(data.pos.YPos),
					posZ = tonumber(data.pos.ZPos),
					rotX = tonumber(data.pos.XRot),
					rotY = tonumber(data.pos.YRot),
					rotZ = tonumber(data.pos.ZRot)
				}
				
				local packetType

				local Tree = false
				
				if randomGras <= cfg.DensityGrass then
				
					packetType = "place"
					
					CellCible = CreateObjectAtLocationJson(CellCible, position, RandomGrassId(), packetType, 0.8)

				end
		
				if randomTree <= cfg.DensityTree then
				
					packetType = "place"
					
					CellCible = CreateObjectAtLocationJson(CellCible, position, RandomTreeId(), packetType, 1)
					
					Tree = true
				end

				if not Tree and randomCrea <= cfg.DensityCrea then
	 
					packetType = "spawn"
					
					position.posZ = position.posZ + 50
					
					CellCible = CreateObjectAtLocationJson(CellCible, position, RandomCreaId(), packetType, 1)
					
				end
				
			end

		end
		
		jsonInterface.quicksave("cell/"..cellDescription..".json", CellCible)
		
		local pourcent = math.floor((count * 100) / 563)
		
		tes3mp.LogAppend(enumerations.log.INFO, "....EXTERIOR WORLD CREATE IN : "..cellDescription.."......PROGRESS : "..pourcent.." %")
		
	end
	
	WorldInstance:SetCurrentMpNum(WorldMpNum)
	
	tes3mp.SetCurrentMpNum(WorldMpNum)
	
	local timeEnd = os.time() - timeStart
	
	tes3mp.LogAppend(enumerations.log.INFO, "....EXTERIOR WORLD CREATE TERMINATE IN : "..math.floor(timeEnd).." secondes".."....TOTAL : "..count.." cell")
	tes3mp.LogAppend(enumerations.log.INFO, "....EXTERIOR WORLD GENERATION TERMINATE....")		
end

local function SendPacketType(pid, cellDescription, packetType)

	local count = 0
	
	tes3mp.ClearObjectList()
	
	tes3mp.SetObjectListPid(pid)
	
	tes3mp.SetObjectListCell(cellDescription)
	
	local StatePackets = LoadedCells[cellDescription].data.packets[packetType]
	
	for i = 1, #StatePackets do
	
		local object = LoadedCells[cellDescription].data.objectData[StatePackets[i]]
		
		if object and object.location and object.refId and object.scale then
		
			local splitIndex = StatePackets[i]:split("-")
			tes3mp.SetObjectRefNum(splitIndex[1])
			tes3mp.SetObjectMpNum(splitIndex[2])
			tes3mp.SetObjectRefId(object.refId)
			
			if packetType == "place" then 
			
				tes3mp.SetObjectPosition(object.location.posX, object.location.posY, object.location.posZ)
				tes3mp.SetObjectRotation(object.location.rotX, object.location.rotY, object.location.rotZ)
				tes3mp.SetObjectScale(object.scale)

			elseif packetType == "actorList" then
			
				tes3mp.SetObjectPosition(object.location.posX, object.location.posY, object.location.posZ)
				tes3mp.SetObjectRotation(object.location.rotX, object.location.rotY, object.location.rotZ)
				tes3mp.SetObjectScale(object.scale)	
		
			end
			
			tes3mp.AddObject()
			
			count = count + 1
		end
		
		if count >= 3000 then
		
			if packetType == "place" then
			
				tes3mp.SendObjectPlace(true)
				tes3mp.SendObjectScale(true)	
				
			elseif packetType == "actorList" then
			
				tes3mp.SendObjectSpawn(true)
				tes3mp.SendObjectScale(true)	

			end
			
			tes3mp.ClearObjectList()
			tes3mp.SetObjectListPid(pid)
			tes3mp.SetObjectListCell(cellDescription)
			count = 0
			
		end		
		
	end
	
	if count > 0 then	
	
		if packetType == "place" then
		
			tes3mp.SendObjectPlace(true)
			tes3mp.SendObjectScale(true)
			
		elseif packetType == "actorList" then
		
			tes3mp.SendObjectSpawn(true)
			tes3mp.SendObjectScale(true)	
			
		end
		
	end
	
end

local function ResetCell(pid, cellDescription)

	local cell = LoadedCells[cellDescription]

	local useTemporaryLoad = false	
	
	if cell == nil then
		logicHandler.LoadCell(cellDescription)
		useTemporaryLoad = true
		cell = LoadedCells[cellDescription]
	end

	CleanCell(pid, cellDescription)	
	
	tes3mp.LogMessage(enumerations.log.INFO, "Reset Grass Data of cell "..cellDescription.." for "..logicHandler.GetChatName(pid))

	WorldMpNum = WorldInstance:GetCurrentMpNum()

	local CellGrass = jsonInterface.load("custom/GrassGeneration/cell/"..cellDescription..".json")	
	
	for index, data in pairs(CellGrass[1].objects) do		

		if data.pos then
		
			local randomGras = math.random(1, 1000)
			local randomCrea = math.random(1, 1000)
			local randomTree = math.random(1, 1000)
			
			local position = {
				posX = tonumber(data.pos.XPos),
				posY = tonumber(data.pos.YPos),
				posZ = tonumber(data.pos.ZPos),
				rotX = tonumber(data.pos.XRot),
				rotY = tonumber(data.pos.YRot),
				rotZ = tonumber(data.pos.ZRot)
			}
			
			local packetType

			local Tree = false
			
			if randomGras <= cfg.DensityGrass then
			
				packetType = "place"
				
				CreateObjectAtLocation(cellDescription, position, RandomGrassId(), packetType, 0.8)
				
			end
			
			if randomTree <= cfg.DensityTree then
			
				packetType = "place"
				
				CreateObjectAtLocation(cellDescription, position, RandomTreeId(), packetType, 2)
				
				Tree = true	
				
			end
			
			if not Tree and randomCrea <= cfg.DensityCrea then
 
				packetType = "spawn"
				
				position.posZ = position.posZ + 50
				
				CreateObjectAtLocation(cellDescription, position, RandomCreaId(), packetType, 1)
				
			end
			
		end

	end
	
	WorldInstance:SetCurrentMpNum(WorldMpNum)	
	tes3mp.SetCurrentMpNum(WorldMpNum)

	SendPacketType(pid, cellDescription, "place")	
	SendPacketType(pid, cellDescription, "actorList")
	
	if useTemporaryLoad == true then
	
		logicHandler.UnloadCell(cellDescription)
		
	else
	
		cell:QuicksaveToDrive()	
		
	end				

end

-------------
-- METHODS --
-------------
local GrassGeneration = {}

GrassGeneration.OnServerPostInit = function(eventStatus)

	if cfg.OnServerPostInit then
	
		CheckCell()	
		
		if not cfg.CleanCell then
		
			GenerateGrass()
			
		end	
		
	end
	
end

GrassGeneration.OnPlayerResetCommand = function(pid)

	if Players[pid] and Players[pid]:IsLoggedIn() and Players[pid]:IsServerStaff() then
	
		local cellDescription = tes3mp.GetCell(pid)

		if DataCellsName[cellDescription] then	
		
			ResetCell(pid, cellDescription)	
			
		end
		
	end
	
end

GrassGeneration.OnPlayerCleanCommand = function(pid)

	if Players[pid] and Players[pid]:IsLoggedIn() and Players[pid]:IsServerStaff() then

		local cellDescription = tes3mp.GetCell(pid)
		
		if DataCellsName[cellDescription] then
		
			CleanCell(pid, cellDescription)
			
		end
		
	end
end

GrassGeneration.OnResetGrass = function(pid, cellDescription)

	if DataCellsName[cellDescription] then
	
		ResetCell(pid, cellDescription)	
		
	end
	
end

------------
-- EVENTS --
------------
customEventHooks.registerHandler("OnServerPostInit", GrassGeneration.OnServerPostInit)

customCommandHooks.registerCommand("resetgrass", GrassGeneration.OnPlayerResetCommand)
customCommandHooks.registerCommand("cleangrass", GrassGeneration.OnPlayerCleanCommand)

return GrassGeneration
