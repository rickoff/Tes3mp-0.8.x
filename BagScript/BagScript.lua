--[[
BagScript
tes3mp 0.8.1
---------------------------
DESCRIPTION :
the bottomless bag script allows you to store additional items in a container directly available in the player's inventory
---------------------------
INSTALLATION:
Save the file as BagScript.lua inside your server/scripts/custom folder.
Edits to customScripts.lua, add in :
BagScript = require("custom.BagScript")
---------------------------
CONFIGURATION:
Modify cfg.quickKey by the number suits you
---------------------------
USE:
Press the keyboard shortcut defined in your configuration to open the bottomless bag
---------------------------
]]
------------
-- CONFIG --
------------
local cfg = {
	OnServerInit = true,
	quickKey = 8
}
----------------
-- TRADUCTION --
----------------
local trad = {
	bagName = "Sac sans fond"	
}

--------------
-- FUNCTION --
--------------
local function SendPacketBag(pid, cellDescription, uniqueIndex, object)

	tes3mp.ClearObjectList()

	tes3mp.SetObjectListPid(pid)

	tes3mp.SetObjectListCell(cellDescription)

	local splitIndex = uniqueIndex:split("-")

	tes3mp.SetObjectRefNum(splitIndex[1])

	tes3mp.SetObjectMpNum(splitIndex[2])

	tes3mp.SetObjectRefId("bag_container")

	tes3mp.SetObjectPosition(object.location.posX, object.location.posY, object.location.posZ)

	tes3mp.SetObjectRotation(object.location.rotX, object.location.rotY, object.location.rotZ)

	tes3mp.SetObjectScale(object.scale)

	tes3mp.AddObject()

	tes3mp.SendObjectPlace(false)

	tes3mp.SendObjectScale(false)			

end

local function CloseMenu(pid)

	for x = 1, 2 do
	
		tes3mp.ClearObjectList()
		
		tes3mp.SetObjectListPid(pid)
		
		tes3mp.SetObjectListCell(Players[pid].data.location.cell)
		
		tes3mp.SetObjectListConsoleCommand("TM")
		
		tes3mp.SetPlayerAsObject(pid)
		
		tes3mp.AddObject()

		tes3mp.SendConsoleCommand(false)
		
	end
	
end

local function AddBag(pid)

	tes3mp.ClearObjectList()
	
	tes3mp.SetObjectListPid(pid)
	
	tes3mp.SetObjectListCell(Players[pid].data.location.cell)
	
	tes3mp.SetObjectListConsoleCommand("player->additem bag_book 1")
	
	tes3mp.SetPlayerAsObject(pid)
	
	tes3mp.AddObject()

	tes3mp.SendConsoleCommand(false)
	
end

local function ActivateBag(pid, objectCellDescription, objectUniqueIndex)

    tes3mp.ClearObjectList()
	
    tes3mp.SetObjectListPid(pid)
	
    tes3mp.SetObjectListCell(objectCellDescription)

    local splitIndex = objectUniqueIndex:split("-")
	
    tes3mp.SetObjectRefNum(splitIndex[1])
	
    tes3mp.SetObjectMpNum(splitIndex[2])
	
    tes3mp.SetObjectActivatingPid(pid)

    tes3mp.AddObject()
	
    tes3mp.SendObjectActivate()
end

local function UpdateBag(pid)

	local targetEquipment = Players[pid].data.customVariables.Bag.inventory

	local targetCellDescription = Players[pid].data.customVariables.Bag.cellDescription

	local targetUniqueIndex = Players[pid].data.customVariables.Bag.uniqueIndex

	tes3mp.ClearObjectList()

	tes3mp.SetObjectListPid(pid)

	tes3mp.SetObjectListCell(targetCellDescription)

	local splitIndex = targetUniqueIndex:split("-")

	tes3mp.SetObjectRefNum(splitIndex[1])

	tes3mp.SetObjectMpNum(splitIndex[2])

	tes3mp.SetObjectRefId("bag_container")

	for _, item in pairs(targetEquipment) do

		if item.refId ~= nil and item.refId ~= "" then

			local count = item.count or 1

			local charge = item.charge or -1

			local enchantmentCharge = item.enchantmentCharge or -1

			local soul = item.soul or ""

			tes3mp.SetContainerItemRefId(item.refId)

			tes3mp.SetContainerItemCount(count)

			tes3mp.SetContainerItemCharge(charge)

			tes3mp.SetContainerItemEnchantmentCharge(enchantmentCharge)

			tes3mp.SetContainerItemSoul(soul)

			tes3mp.AddContainerItem()

		end

	end

	tes3mp.AddObject()

	tes3mp.SetObjectListAction(enumerations.container.SET)

	tes3mp.SendContainer(false, false)

end

local function CreateBag(cellDescription, location, refId)
	
	local mpNum = WorldInstance:GetCurrentMpNum() + 1
	
	local uniqueIndex =  0 .. "-" .. mpNum	
	
	LoadedCells[cellDescription]:InitializeObjectData(uniqueIndex, refId)
	
	if LoadedCells[cellDescription].data.objectData[uniqueIndex] then
	
		LoadedCells[cellDescription].data.objectData[uniqueIndex].location = location
		
		LoadedCells[cellDescription].data.objectData[uniqueIndex].scale = 0.0001
		
		LoadedCells[cellDescription].data.objectData[uniqueIndex].inventory = {}
		
		table.insert(LoadedCells[cellDescription].data.packets.place, uniqueIndex)
		
		table.insert(LoadedCells[cellDescription].data.packets.scale, uniqueIndex)
		
		table.insert(LoadedCells[cellDescription].data.packets.container, uniqueIndex)	
		
	end
	
	WorldInstance:SetCurrentMpNum(mpNum) 
	
	tes3mp.SetCurrentMpNum(mpNum)
	
	return uniqueIndex
	
end

local function DeleteBag(pid)

	local cellDescription = Players[pid].data.customVariables.Bag.cellDescription
	
	local uniqueIndex = Players[pid].data.customVariables.Bag.uniqueIndex

	if cellDescription == "" or uniqueIndex == 0 then return end
	
	local temporyLoad = false
	
	if LoadedCells[cellDescription] == nil then
	
		logicHandler.LoadCellForPlayer(pid, cellDescription)
		
		temporyLoad = true
		
	end
	
	tes3mp.ClearObjectList()
	
	tes3mp.SetObjectListPid(pid)
	
	tes3mp.SetObjectListCell(cellDescription)

	local splitIndex = uniqueIndex:split("-")
	
	tes3mp.SetObjectRefNum(splitIndex[1])
	
	tes3mp.SetObjectMpNum(splitIndex[2])
	
	tes3mp.AddObject()
	
	LoadedCells[cellDescription]:DeleteObjectData(uniqueIndex)

	tes3mp.SendObjectDelete(false)

	if temporyLoad then
	
		logicHandler.UnloadCellForPlayer(pid, cellDescription)
		
	end
	
end
-------------
-- METHODS --
-------------
local BagScript = {}

BagScript.OnServerInit = function(eventStatus)

	if cfg.OnServerInit then

		local recordStoreBook = RecordStores["book"]

		local recordStoreContainer = RecordStores["container"]	
		
		local recordBookTable = {
		  name = trad.bagName,
		  icon = "l\\Tx_buglamp_01.tga",
		  model = "l\\Light_buglamp_01.NIF",	  
		  value = 0,
		  weight = 0
		}
		
		local recordContainerTable = {
		  name = trad.bagName,
		  model = "l\\Light_buglamp_01.NIF",
		  weight = 9999999999999999999999
		}	

		recordStoreBook.data.permanentRecords["bag_book"] = recordBookTable	

		recordStoreContainer.data.permanentRecords["bag_container"] = recordContainerTable
		
		recordStoreBook:Save()	
		
		recordStoreContainer:Save()	
		
	end
	
end

BagScript.OnPlayerAuthentified = function(eventStatus, pid)

	if Players[pid] and Players[pid]:IsLoggedIn() then
	
		if Players[pid].data.customVariables.Bag == nil then
		
			Players[pid].data.customVariables.Bag = {
				inventory = {},
				cellDescription = "",
				uniqueIndex = 0
			}
			
		end

		if not tableHelper.containsValue(Players[pid].data.inventory, "bag_book", true) then
			AddBag(pid)
		end
		
		Players[pid].data.quickKeys[cfg.quickKey] = {
			keyType = 0,
			itemId = "bag_book"
		}
		
		Players[pid]:LoadQuickKeys()
		
	end
	
end

BagScript.OnPlayerDisconnect = function(eventStatus, pid)

	if Players[pid] and Players[pid]:IsLoggedIn() then
	
		DeleteBag(pid)
	
	end
	
end

BagScript.OnPlayerItemUse = function(eventStatus, pid, refId)

	if Players[pid] and Players[pid]:IsLoggedIn() then	
		
		if string.lower(refId) == "bag_book" then	

			DeleteBag(pid)
			
			local cellDescription = tes3mp.GetCell(pid)
			
			local location = { posX = tes3mp.GetPosX(pid), posY = tes3mp.GetPosY(pid), posZ = -99999, rotX = 0, rotY = 0, rotZ = 0 }
			
			local uniqueIndex = CreateBag(cellDescription, location, "bag_container")

			Players[pid].data.customVariables.Bag.cellDescription = cellDescription
			
			Players[pid].data.customVariables.Bag.uniqueIndex = uniqueIndex

			SendPacketBag(pid, cellDescription, uniqueIndex, LoadedCells[cellDescription].data.objectData[uniqueIndex])

			if Players[pid].data.customVariables.Bag.inventory ~= nil then
			
				LoadedCells[cellDescription].data.objectData[uniqueIndex].inventory = Players[pid].data.customVariables.Bag.inventory
			
				UpdateBag(pid)
				
			end
			
			CloseMenu(pid)

			ActivateBag(pid, cellDescription, uniqueIndex)
		
			return customEventHooks.makeEventStatus(false,false) 
		end
		
	end
end	

BagScript.OnContainerHandler = function(eventStatus, pid, cellDescription, objects)

	if Players[pid] and Players[pid]:IsLoggedIn() then	
	
		local ObjectIndex
		
		local ObjectRefid
		
		for _, object in pairs(objects) do
		
			ObjectIndex = object.uniqueIndex
			
			ObjectRefid = object.refId
			
		end	
		
		if ObjectIndex ~= nil and ObjectRefid ~= nil then
	
			if ObjectIndex == Players[pid].data.customVariables.Bag.uniqueIndex then
				
				local containerSubAction = tes3mp.GetObjectListContainerSubAction()	

				if containerSubAction == enumerations.containerSub.TAKE_ALL then
				
					DeleteBag(pid)
					
				end

			end
			
		end
		
    end
	
end

BagScript.OnContainerValidator = function(eventStatus, pid, cellDescription, objects)

	if Players[pid] and Players[pid]:IsLoggedIn() then	
	
		local ObjectIndex
		
		local ObjectRefid
		
		for _, object in pairs(objects) do
		
			ObjectIndex = object.uniqueIndex
			
			ObjectRefid = object.refId
			
		end	
		
		if ObjectIndex ~= nil and ObjectRefid ~= nil then
	
			for containerIndex = 0, tes3mp.GetObjectListSize() - 1 do

				for itemIndex = 0, tes3mp.GetContainerChangesSize(containerIndex) - 1 do
				
					local ObjectRefid = tes3mp.GetContainerItemRefId(containerIndex, itemIndex)
					
					if ObjectRefid and ObjectRefid == "bag_book" then
					
						return customEventHooks.makeEventStatus(false, false)	
						
					end
					
				end
				
			end
			
		end
		
    end
	
end

BagScript.OnPlayerInventory = function(eventStatus, pid, playerPacket)

	if Players[pid] and Players[pid]:IsLoggedIn() then
	
		local action = tes3mp.GetInventoryChangesAction(pid)
		
		local itemChangesCount = tes3mp.GetInventoryChangesSize(pid)
		
		if action == enumerations.inventory.REMOVE then
		
			for index = 0, itemChangesCount - 1 do
			
				local ObjectRefid = tes3mp.GetInventoryItemRefId(pid, index)
				
				if ObjectRefid and ObjectRefid == "bag_book" then	
				
					local item = {
						refId = ObjectRefid,
						count = tes3mp.GetInventoryItemCount(pid, index),
						charge = tes3mp.GetInventoryItemCharge(pid, index),
						enchantmentCharge = tes3mp.GetInventoryItemEnchantmentCharge(pid, index),
						soul = tes3mp.GetInventoryItemSoul(pid, index)
					}	
					
					Players[pid]:LoadItemChanges({item}, enumerations.inventory.ADD)
					
					return customEventHooks.makeEventStatus(false, false)	
					
				end
				
			end	
		end
		
	end
	
end

BagScript.OnObjectPlace = function(eventStatus, pid, cellDescription, objects)

	if Players[pid] and Players[pid]:IsLoggedIn() then
		
		local ObjectIndex
		
		local ObjectRefid
		
		for _, object in pairs(objects) do
		
			ObjectIndex = object.uniqueIndex
			
			ObjectRefid = object.refId
		end	
		
		if ObjectIndex ~= nil and ObjectRefid ~= nil then
		
			if ObjectRefid == "bag_book" then
			
				return customEventHooks.makeEventStatus(false, false)
				
			end
			
		end
		
	end
	
end
------------
-- EVENTS --
------------

customEventHooks.registerValidator("OnPlayerItemUse", BagScript.OnPlayerItemUse)

customEventHooks.registerValidator("OnPlayerInventory", BagScript.OnPlayerInventory)

customEventHooks.registerValidator("OnObjectPlace", BagScript.OnObjectPlace)

customEventHooks.registerValidator("OnContainer", BagScript.OnContainerValidator)

customEventHooks.registerHandler("OnContainer", BagScript.OnContainerHandler)

customEventHooks.registerHandler("OnServerInit", BagScript.OnServerInit)

customEventHooks.registerHandler("OnPlayerAuthentified", BagScript.OnPlayerAuthentified)

customEventHooks.registerHandler("OnPlayerDisconnect", BagScript.OnPlayerDisconnect)

return BagScript
