--[[
DecorateScript
tes3mp 0.8.1
---------------------------
DESCRIPTION :
---------------------------
INSTALLATION:
Save the file as DecorateScript.lua inside your server/scripts/custom folder.
Edits to customScripts.lua
DecorateScript = require("custom.DecorateScript")
Edits cell/base.lua :
add in function SaveObjectsPlaced under self.data.objectData[uniqueIndex].location = location
self.data.objectData[uniqueIndex].scale = 1
tableHelper.insertValueIfMissing(self.data.packets.scale, uniqueIndex)
---------------------------
]]

------------
-- CONFIG --
------------
local cfg = {
	MainId = 31360,
	PromptId = 31361
}

----------------
-- TRADUCTION --
----------------
local trad = {
	prompt = "] - Enter a number to add/subtract",
	rotx = "Turn X",
	roty = "Turn Y",
	rotz = "Turn Z",
	movn = "+/- Nord",
	move = "+/- East",
	movup = "+/- Height",
	up = "Up",
	down = "Down",
	east = "East",
	west = "West",
	north = "Nord",
	sud = "Sud",
	bigger = "Enlarge",
	Lower = "Shrink",
	drop = "Grab",
	noselect = "No object selected.",
	nooption = "The object cannot be modified.",
	placeobjet = "The object has just been placed.",
	warningcell = "Attention, the object leaves the zone !!!",
	info = "To place the item, enter stealth mode.\nTo rotate, draw your weapon or magic.",
	opt1 = "Choose an option. Your current item:",
	opt2 = "Adjust Nord;Adjust East;Adjust Height;Turn X;Turn Y;Turn Z;Up;Down;East;West;Nord;Sud;Enlarge;Shrink;Grab;Close" 
}

--------------
-- VARIABLE --
--------------
local playerSelectedObject = {}
local playerCurrentMode = {}
local playersTab = {}

--------------
-- FUNCTION --
--------------
function StartDrop(pid)	
	if Players[pid] and Players[pid]:IsLoggedIn() then	
		DecorateScript.moveObject(pid)	
	end
end

local function GetName(pid)
	return string.lower(Players[pid].accountName)	
end

local function setSelectedObject(pid, refIndex)
	playerSelectedObject[GetName(pid)] = refIndex	
end

local function GetObject(refIndex, cell)

	if refIndex == nil then
		return false
	end
	
	if LoadedCells[cell]:ContainsObject(refIndex) then 
		return LoadedCells[cell].data.objectData[refIndex]
	else
		return false
	end	
	
end

local function DeleteObject(pid, cellDescription, uniqueIndex, toEveryone)
	tes3mp.ClearObjectList()
	tes3mp.SetObjectListPid(pid)
	tes3mp.SetObjectListCell(cellDescription)
	local splitIndex = uniqueIndex:split("-")
	tes3mp.SetObjectRefNum(splitIndex[1])
	tes3mp.SetObjectMpNum(splitIndex[2])	
	tes3mp.AddObject()	
	tes3mp.SendObjectDelete(toEveryone)
end

local function ResendPlaceToPlayer(pid, uniqueIndex, cellDescription)
	DeleteObject(pid, cellDescription, uniqueIndex, false)
	tes3mp.ClearObjectList()
	tes3mp.SetObjectListPid(pid)
	tes3mp.SetObjectListCell(cellDescription)	
	local object = LoadedCells[cellDescription].data.objectData[uniqueIndex]	
	if not object then return end	
	local inventory = LoadedCells[cellDescription].data.objectData[uniqueIndex].inventory	
	local scale = object.scale or 1	
	if object and object.location and object.refId then		
		local splitIndex = uniqueIndex:split("-")
		tes3mp.SetObjectRefNum(splitIndex[1])
		tes3mp.SetObjectMpNum(splitIndex[2])
		tes3mp.SetObjectRefId(object.refId)
		tes3mp.SetObjectCharge(object.charge or -1)
		tes3mp.SetObjectEnchantmentCharge(object.enchantmentCharge or -1)
		tes3mp.SetObjectPosition(object.location.posX, object.location.posY, object.location.posZ)
		tes3mp.SetObjectRotation(object.location.rotX, object.location.rotY, object.location.rotZ)
		tes3mp.SetObjectScale(object.scale)
		if inventory then		
			for itemIndex, item in pairs(inventory) do			
				tes3mp.SetContainerItemRefId(item.refId)
				tes3mp.SetContainerItemCount(item.count)
				tes3mp.SetContainerItemCharge(item.charge)
				tes3mp.AddContainerItem()				
			end			
		end			
		tes3mp.AddObject()
	end		
	tes3mp.SendObjectPlace(false)
	tes3mp.SendObjectScale(false)	
	if inventory then	
		tes3mp.SendContainer(false)		
	end	
end

local function ResendPlaceToEveryone(pid, uniqueIndex, cellDescription)
	DeleteObject(pid, cellDescription, uniqueIndex, true)
	tes3mp.ClearObjectList()
	tes3mp.SetObjectListPid(pid)
	tes3mp.SetObjectListCell(cellDescription)	
	local object = LoadedCells[cellDescription].data.objectData[uniqueIndex]	
	if not object then return end	
	local inventory = LoadedCells[cellDescription].data.objectData[uniqueIndex].inventory	
	local scale = object.scale or 1	
	if object and object.location and object.refId then		
		local splitIndex = uniqueIndex:split("-")
		tes3mp.SetObjectRefNum(splitIndex[1])
		tes3mp.SetObjectMpNum(splitIndex[2])
		tes3mp.SetObjectRefId(object.refId)
		tes3mp.SetObjectCharge(object.charge or -1)
		tes3mp.SetObjectEnchantmentCharge(object.enchantmentCharge or -1)
		tes3mp.SetObjectPosition(object.location.posX, object.location.posY, object.location.posZ)
		tes3mp.SetObjectRotation(object.location.rotX, object.location.rotY, object.location.rotZ)
		tes3mp.SetObjectScale(object.scale)
		if inventory then		
			for itemIndex, item in pairs(inventory) do			
				tes3mp.SetContainerItemRefId(item.refId)
				tes3mp.SetContainerItemCount(item.count)
				tes3mp.SetContainerItemCharge(item.charge)
				tes3mp.AddContainerItem()				
			end			
		end			
		tes3mp.AddObject()
	end		
	tes3mp.SendObjectPlace(true)
	tes3mp.SendObjectScale(true)	
	if inventory then	
		tes3mp.SendContainer(true)		
	end	
	LoadedCells[cellDescription]:QuicksaveToDrive()	
end

local function resendPlaceToAll(pid, refIndex, cell)
	local object = GetObject(refIndex, cell)

	if not object then
		return false
	end

	local refId = object.refId
	local count = object.count or 1
	local charge = object.charge or -1
	local posX, posY, posZ = object.location.posX, object.location.posY, object.location.posZ
	local rotX, rotY, rotZ = object.location.rotX, object.location.rotY, object.location.rotZ
	local refIndex = refIndex
	local scale = object.scale or 1
	-- local move_amount = object.move_amount or 1

	local inventory = object.inventory or nil

	local splitIndex = refIndex:split("-")

	for pid, pdata in pairs(Players) do
		if Players[pid]:IsLoggedIn() then
			--First, delete the original
			tes3mp.InitializeEvent(pid)
			tes3mp.SetEventCell(cell)
			tes3mp.SetObjectRefNumIndex(0)
			tes3mp.SetObjectMpNum(splitIndex[2])
			tes3mp.AddWorldObject() --?
			tes3mp.SendObjectDelete()

			--Now remake it
			tes3mp.InitializeEvent(pid)
			tes3mp.SetEventCell(cell)
			tes3mp.SetObjectRefId(refId)
			tes3mp.SetObjectCount(count)
			tes3mp.SetObjectCharge(charge)
			tes3mp.SetObjectPosition(posX, posY, posZ)
			tes3mp.SetObjectRotation(rotX, rotY, rotZ)
			tes3mp.SetObjectRefNumIndex(0)
			tes3mp.SetObjectMpNum(splitIndex[2])
			tes3mp.SetObjectScale(scale)
			if inventory then
				for itemIndex, item in pairs(inventory) do
					tes3mp.SetContainerItemRefId(item.refId)
					tes3mp.SetContainerItemCount(item.count)
					tes3mp.SetContainerItemCharge(item.charge)

					tes3mp.AddContainerItem()
				end
			end

			tes3mp.AddWorldObject()
			tes3mp.SendObjectPlace()
			tes3mp.SendObjectScale()
			if inventory then
				tes3mp.SendContainer()
			end
		end
	end

	-- Make sure to save a scale packet if this object has a non-default scale.
	if scale ~= 1 then
		tableHelper.insertValueIfMissing(LoadedCells[cell].data.packets.scale, refIndex)
	end
	LoadedCells[cell]:QuicksaveToDrive() --Not needed, but it's nice to do anyways
end

local function showPromptGUI(pid)
	local message = "[" .. playerCurrentMode[GetName(pid)] .. trad.prompt	
	tes3mp.InputDialog(pid, cfg.PromptId, message, "")	
end

local function onEnterPrompt(pid, data)
	local cell = tes3mp.GetCell(pid)
	local pname = GetName(pid)
	local mode = playerCurrentMode[pname]
	local data = tonumber(data) or 0
	local object = GetObject(playerSelectedObject[pname], cell)
	local cellSize = 8192	
	local checkPosSafe = true	
	if not object then
		tes3mp.MessageBox(pid, -1, trad.noselect)		
		return false
	else
		if object.scale == nil then object.scale = 1 end	
		local scaling = object.scale 
		if mode == trad.rotx then
			local curDegrees = math.deg(object.location.rotX)
			local newDegrees = (curDegrees + data) % 360
			object.location.rotX = math.rad(newDegrees)
		elseif mode == trad.roty then
			local curDegrees = math.deg(object.location.rotY)
			local newDegrees = (curDegrees + data) % 360
			object.location.rotY = math.rad(newDegrees)
		elseif mode == trad.rotz then
			local curDegrees = math.deg(object.location.rotZ)
			local newDegrees = (curDegrees + data) % 360
			object.location.rotZ = math.rad(newDegrees)
		elseif mode == trad.movn then
			object.location.posY = object.location.posY + data
		elseif mode == trad.move then
			object.location.posX = object.location.posX + data
		elseif mode == trad.movup then
			object.location.posZ = object.location.posZ + data
		elseif mode == trad.up then
			object.location.posZ = object.location.posZ + 10
		elseif mode == trad.down then
			object.location.posZ = object.location.posZ - 10
		elseif mode == trad.east then
			object.location.posX = object.location.posX + 10
		elseif mode == trad.west then
			object.location.posX = object.location.posX - 10
		elseif mode == trad.north then
			object.location.posY = object.location.posY + 10
		elseif mode == trad.sud then
			object.location.posY = object.location.posY - 10
		elseif mode == trad.bigger then
			if scaling ~= nil then
				if scaling < 2 then
					object.scale = object.scale + 0.1
				else
					object.scale = object.scale
				end
			else
				tes3mp.MessageBox(pid, -1, trad.nooption)		
			end
		elseif mode == trad.Lower then
			if scaling ~= nil then
				if scaling > 0.1 then
					object.scale = object.scale - 0.1
				else
					object.scale = object.scale
				end
			else
				tes3mp.MessageBox(pid, -1, trad.nooption)		
			end		
		elseif mode == "close" then
			object.location.posY = object.location.posY		
			return
		end
	end
	if tes3mp.IsInExterior(pid) then
		local correctGridX = math.floor(object.location.posX / cellSize)
		local correctGridY = math.floor(object.location.posY / cellSize)
		if LoadedCells[cell].gridX ~= correctGridX or LoadedCells[cell].gridY ~= correctGridY then
			checkPosSafe = false
		end
	end
	if checkPosSafe == true then	
		ResendPlaceToEveryone(pid, playerSelectedObject[pname], cell)
	else
		tes3mp.MessageBox(pid, -1, trad.warningcell)
	end	
end

-------------
-- METHODS --
-------------
local DecorateScript = {}

DecorateScript.SetSelectedObject = function(pid, refIndex)
	setSelectedObject(pid, refIndex)	
end

DecorateScript.OnObjectPlace = function(eventStatus, pid, cellDescription)
	tes3mp.ReadLastEvent()	
	local refIndex = tes3mp.GetObjectRefNumIndex(0) .. "-" .. tes3mp.GetObjectMpNum(0)	
	setSelectedObject(pid, refIndex)	
end

DecorateScript.OnGUIAction = function(eventStatus, pid, idGui, data)		
	if idGui == cfg.MainId then
		local pname = GetName(pid)		
		if tonumber(data) == 0 then --Move North
			playerCurrentMode[pname] = trad.movn
			showPromptGUI(pid)
		elseif tonumber(data) == 1 then --Move East
			playerCurrentMode[pname] = trad.move
			showPromptGUI(pid)
		elseif tonumber(data) == 2 then --Move Up
			playerCurrentMode[pname] = trad.movup
			showPromptGUI(pid)
		elseif tonumber(data) == 3 then --Rotate X
			playerCurrentMode[pname] = trad.rotx
			showPromptGUI(pid)
		elseif tonumber(data) == 4 then --Rotate Y
			playerCurrentMode[pname] = trad.roty
			showPromptGUI(pid)
		elseif tonumber(data) == 5 then --Rotate Z
			playerCurrentMode[pname] = trad.rotz
			showPromptGUI(pid)
		elseif tonumber(data) == 6 then --Monter
			playerCurrentMode[pname] = trad.up
			onEnterPrompt(pid, 0)			
			DecorateScript.showMainGUI(pid)
		elseif tonumber(data) == 7 then --Descendre
			playerCurrentMode[pname] = trad.down
			onEnterPrompt(pid, 0)			
			DecorateScript.showMainGUI(pid)
		elseif tonumber(data) == 8 then --Est
			playerCurrentMode[pname] = trad.east
			onEnterPrompt(pid, 0)			
			DecorateScript.showMainGUI(pid)	
		elseif tonumber(data) == 9 then --Ouest
			playerCurrentMode[pname] = trad.west
			onEnterPrompt(pid, 0)			
			DecorateScript.showMainGUI(pid)
		elseif tonumber(data) == 10 then --Nord
			playerCurrentMode[pname] = trad.north
			onEnterPrompt(pid, 0)			
			DecorateScript.showMainGUI(pid)
		elseif tonumber(data) == 11 then --Sud
			playerCurrentMode[pname] = trad.sud
			onEnterPrompt(pid, 0)
			DecorateScript.showMainGUI(pid)
		elseif tonumber(data) == 12 then --Agrandir
			playerCurrentMode[pname] = trad.bigger
			onEnterPrompt(pid, 0)			
			DecorateScript.showMainGUI(pid)
		elseif tonumber(data) == 13 then --Reduire
			playerCurrentMode[pname] = trad.Lower
			onEnterPrompt(pid, 0)
			DecorateScript.showMainGUI(pid)	
		elseif tonumber(data) == 14 then --Attraper
			playersTab[pname] = true
			logicHandler.RunConsoleCommandOnPlayer(pid, "tb", false)				
			tes3mp.MessageBox(pid, -1, trad.info)
			local TimerDrop = tes3mp.CreateTimerEx("StartDrop", time.seconds(0.01), "i", pid)
			tes3mp.StartTimer(TimerDrop)			
		elseif tonumber(data) == 15 then --Close
		end
	elseif idGui == cfg.PromptId then
		local pname = GetName(pid)
		if data ~= nil and data ~= "" and tonumber(data) then
			onEnterPrompt(pid, data)
		end			
		playerCurrentMode[pname] = nil
		DecorateScript.showMainGUI(pid)
	end	
end

DecorateScript.moveObject = function(pid)	
	local cellSize = 8192	
	local cell = tes3mp.GetCell(pid)
	local pname = GetName(pid)
	local object = GetObject(playerSelectedObject[pname], cell)	
	local drawState = tes3mp.GetDrawState(pid)
	if not object then
		tes3mp.MessageBox(pid, -1, trad.noselect)	
		return false
	else
		local playerAngleZ = tes3mp.GetRotZ(pid)
		if playerAngleZ > 3.0 then
			playerAngleZ = 3.0
		elseif playerAngleZ < -3.0 then
			playerAngleZ = -3.0
		end
		local playerAngleX = tes3mp.GetRotX(pid)
		if playerAngleX > 1.5 then
			playerAngleX = 1.5
		elseif playerAngleX < -1.5 then
			playerAngleX = -1.5
		end	
		local PosX = (200 * math.sin(playerAngleZ) + tes3mp.GetPosX(pid))
		local PosY = (200 * math.cos(playerAngleZ) + tes3mp.GetPosY(pid))
		local PosZ = (200 * math.sin(-playerAngleX) + (tes3mp.GetPosZ(pid) + 100))
		if PosZ < tes3mp.GetPosZ(pid) then
			PosZ = tes3mp.GetPosZ(pid)
		end
		if tes3mp.IsInExterior(pid) == true then
			local correctGridX = math.floor(PosX / cellSize)
			local correctGridY = math.floor(PosY / cellSize)
			if LoadedCells[cell].gridX ~= correctGridX or LoadedCells[cell].gridY ~= correctGridY then
				PosX = object.location.posX
				PosY = object.location.posY
				PosZ = object.location.posZ
				tes3mp.MessageBox(pid, -1, trad.warningcell)	
			end
		end
		if drawState == 1 then
			local curDegrees = math.deg(object.location.rotZ)
			local newDegrees = (curDegrees + 1) % 360
			object.location.rotZ = math.rad(newDegrees)
		elseif drawState == 2 then
			local curDegrees = math.deg(object.location.rotX)
			local newDegrees = (curDegrees + 1) % 360
			object.location.rotX = math.rad(newDegrees)
		end	
		object.location.posX = PosX
		object.location.posY = PosY
		object.location.posZ = PosZ				
		ResendPlaceToPlayer(pid, playerSelectedObject[pname], cell)			
	end
	if tes3mp.GetSneakState(pid) then	
		tes3mp.MessageBox(pid, -1, trad.placeobjet)	
		ResendPlaceToEveryone(pid, playerSelectedObject[pname], cell)	
		playersTab[GetName(pid)] = nil
		logicHandler.RunConsoleCommandOnPlayer(pid, "tb", false)
	else
		local TimerDrop = tes3mp.CreateTimerEx("StartDrop", time.seconds(0.01), "i", pid)
		tes3mp.StartTimer(TimerDrop)
	end
end

DecorateScript.OnObjectActivate = function(eventStatus, pid, cellDescription, objects)
	if playersTab[GetName(pid)] and GetObject(playerSelectedObject[GetName(pid)], cellDescription) then
		return customEventHooks.makeEventStatus(false, false)
	end
end

DecorateScript.OnPlayerCellChange = function(eventStatus, pid, playerPacket, previousCellDescription) 	
	playerSelectedObject[GetName(pid)] = nil
	if playersTab[GetName(pid)] then
		logicHandler.RunConsoleCommandOnPlayer(pid, "tb", false)	
		playersTab[GetName(pid)] = nil
	end	
end

DecorateScript.OnPlayerAuthentified = function(eventStatus, pid)
	if playersTab[GetName(pid)] then	
		playersTab[GetName(pid)] = nil		
	end	
end

DecorateScript.showMainGUI = function(pid)	
	if not playersTab[GetName(pid)] then
		local currentItem = "Aucun"
		local selected = playerSelectedObject[GetName(pid)]
		local object = GetObject(selected, tes3mp.GetCell(pid))		
		if selected and object then
			currentItem = object.refId .. " (" .. selected .. ")"
		end		
		local message = trad.opt1 .. currentItem
		tes3mp.CustomMessageBox(pid, cfg.MainId, message, trad.opt2)
	end
end
------------
-- EVENTS --
------------
customEventHooks.registerValidator("OnObjectActivate", DecorateScript.OnObjectActivate)
customEventHooks.registerHandler("OnGUIAction", DecorateScript.OnGUIAction)
customEventHooks.registerHandler("OnObjectPlace", DecorateScript.OnObjectPlace)
customEventHooks.registerHandler("OnPlayerCellChange", DecorateScript.OnPlayerCellChange)
customEventHooks.registerHandler("OnPlayerAuthentified", DecorateScript.OnPlayerAuthentified)
customCommandHooks.registerCommand("dh", DecorateScript.showMainGUI)

return DecorateScript
