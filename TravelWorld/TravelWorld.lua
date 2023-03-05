--[[
TravelWorld
tes3mp 0.8.1
---------------------------
DESCRIPTION :
Fast travel by activating Stiltstrider, Boat or SignPost
---------------------------
INSTALLATION:
Save the file as TravelWorld.lua inside your server/scripts/custom folder.
Save the file as DataStri.json inside your server/data/custom/TravelWorld folder.
Save the file as DataBoat.json inside your server/data/custom/TravelWorld folder.
Save the file as DataSign.json inside your server/data/custom/TravelWorld folder.

Edits to customScripts.lua add in :
TravelWorld = require("custom.TravelWorld")
---------------------------
]]
---------------
-- JSON-DATA --
---------------
local TravelStriData = jsonInterface.load("custom/TravelWorld/DataStri.json")	
local TravelBoatData = jsonInterface.load("custom/TravelWorld/DataBoat.json")
local TravelSignData = jsonInterface.load("custom/TravelWorld/DataSign.json")

--------------
-- VARIABLE --
--------------
local PlayerChoice = {}

------------
-- CONFIG --
------------
local cfg = {
	OnServerInit = true,
	PriceDivider = 1000,
	MainGUI = 27102022,
	MainGUIBoat = 27102023,
	MainGUISign = 27102024
}

----------------
-- TRADUCTION --
----------------
local trad = {
	youBuy = "You paid : ",
	golds = " gold coins.",
	notEnough = "You do not have enough money !\nCost : ",
	noGolds = "You have no money !\nCost : ",
	destination = "Destination : ",
	price = " / Price : ",
	retur = "* Return *\n",
	travelStri = "Stilt walker trip",
	travelBoat = "Boat trip",
	travelSign = "Fast Travel\n\nDestination : ",
	signQuestion = "Do you want to travel to : ",
	signChoice = "Yes;No",
	siltStrider = "Silt Strider",
	boat = "Boat"	
}

--------------
-- FUNCTION --
--------------
local function GetName(pid)

	return string.lower(Players[pid].accountName)
	
end

local function DeleteObjectInventory(pid, refId, price)	
	
	local indexLoc = inventoryHelper.getItemIndex(Players[pid].data.inventory, refId, -1, -1, "")
	
	if indexLoc then
	
		if Players[pid].data.inventory[indexLoc].count >= price then
		
			local itemref = {refId = refId, count = price, charge = -1, enchantmentCharge = -1, soul = ""}	
			
			Players[pid].data.inventory[indexLoc].count = Players[pid].data.inventory[indexLoc].count - price
			
			Players[pid]:LoadItemChanges({itemref}, enumerations.inventory.REMOVE)
			
			Players[pid]:QuicksaveToDrive()
			
			local message = trad.youBuy..price..trad.golds	
			tes3mp.MessageBox(pid, -1, message)	
			
			return true			
		else
		
			local message = trad.notEnough..price
			
			tes3mp.MessageBox(pid, -1, message)
			
			return false
			
		end
		
	else
	
		local message = trad.noGolds..price	
		tes3mp.MessageBox(pid, -1, message)
		
		return false	
		
	end
	
end

-------------
-- METHODS --
-------------
local TravelWorld = {}

TravelWorld.OnServerInit = function(eventStatus)

	if cfg.OnServerInit then

		local recordStoreActivator = RecordStores["activator"]	
		
		recordTable = {
		  name = trad.siltStrider,
		  model = "r\\Siltstrider.NIF"
		}
		recordStoreActivator.data.permanentRecords["a_siltstrider"] = recordTable	

		recordTable = {
		  name = trad.boat,
		  model = "x\\ex_longboat01.nif"
		}
		recordStoreActivator.data.permanentRecords["ex_longboat01"] = recordTable

		recordTable = {
		  name = trad.boat,
		  model = "x\\Ex_longboat02.NIF"
		}
		recordStoreActivator.data.permanentRecords["ex_longboat02"] = recordTable

		recordTable = {
		  name = trad.boat,
		  model = "x\\Ex_DE_ship.NIF"
		}
		recordStoreActivator.data.permanentRecords["chargen boat"] = recordTable

		recordTable = {
		  name = trad.boat,
		  model = "x\\ex_de_ship.nif"
		}
		recordStoreActivator.data.permanentRecords["ex_de_ship"] = recordTable

		recordStoreActivator:Save()	
		
	end
	
end

TravelWorld.OnActivatedObject = function(eventStatus, pid, cellDescription, objects)
	
	local ObjectIndex
	local ObjectRefid

	for _, object in pairs(objects) do
		ObjectIndex = object.uniqueIndex
		ObjectRefid = object.refId
	end	

	if ObjectIndex and ObjectRefid then

		if TravelStriData[cellDescription] and ObjectRefid == "a_siltstrider" then

			TravelWorld.ShowMainGuiStrider(pid, cellDescription)

		elseif TravelBoatData[cellDescription] and string.lower(TravelBoatData[cellDescription].refId) == string.lower(ObjectRefid) then

			TravelWorld.ShowMainGuiBoat(pid, cellDescription)

		elseif TravelSignData[cellDescription] and TravelSignData[cellDescription].destination[ObjectIndex] then

			local nameDestination = TravelSignData[cellDescription].destination[ObjectIndex].name

			local cellDestination = TravelSignData[cellDescription].destination[ObjectIndex].cellDescription

			local position

			if nameDestination and cellDestination and TravelSignData[cellDestination] then

				position = TravelSignData[cellDestination].position

			end

			if position then

				TravelWorld.ShowMainGuiSign(pid, cellDescription, nameDestination, cellDestination, position)

			end				
		end			
	end	
end

TravelWorld.ShowMainGuiStrider = function(pid, cellDescription)	
	
	local list = trad.retur

	local nameP = GetName(pid)

	PlayerChoice[nameP] = {}

	local playerPosX = TravelStriData[cellDescription].pos.XPos

	local playerPosY = TravelStriData[cellDescription].pos.YPos	

	for cellDestination, data in pairs(TravelStriData) do

		local PosX = TravelStriData[cellDestination].pos.XPos

		local PosY = TravelStriData[cellDestination].pos.YPos	

		local distance = math.sqrt((playerPosX - PosX) * (playerPosX - PosX) + (playerPosY - PosY) * (playerPosY - PosY)) 

		local price = math.floor(distance/cfg.PriceDivider)

		list = list..trad.destination..data.nameDes..trad.price..price.."\n"

		local tempTable = {cellDescription = cellDestination, price = price}

		table.insert(PlayerChoice[nameP], tempTable)

	end

	tes3mp.ListBox(pid, cfg.MainGUI, color.Default..trad.travelStri, list)
	
end

TravelWorld.ShowMainGuiBoat = function(pid, cellDescription)	
	
	local list = trad.retur

	local nameP = GetName(pid)	

	PlayerChoice[nameP] = {}

	local playerPosX = TravelBoatData[cellDescription].pos.XPos

	local playerPosY = TravelBoatData[cellDescription].pos.YPos	

	for cellDestination, data in pairs(TravelBoatData) do

		local PosX = TravelBoatData[cellDestination].pos.XPos

		local PosY = TravelBoatData[cellDestination].pos.YPos	

		local distance = math.sqrt((playerPosX - PosX) * (playerPosX - PosX) + (playerPosY - PosY) * (playerPosY - PosY)) 

		local price = math.floor(distance/cfg.PriceDivider)

		list = list..trad.destination.. data.nameDes ..trad.price..price.."\n"

		local tempTable = {cellDescription = cellDestination, price = price}

		table.insert(PlayerChoice[nameP], tempTable)

	end

	tes3mp.ListBox(pid, cfg.MainGUIBoat, color.Default..trad.travelBoat, list)
end

TravelWorld.ShowMainGuiSign = function(pid, cellDescription, nameDestination, cellDestination, position)
		
	local nameP = GetName(pid)		

	local checkPos = TravelSignData[cellDescription].position 

	local signPosX = checkPos.posX

	local signPosY = checkPos.posY	

	local destinationPosX = position.posX

	local destinationPosY = position.posY	

	local distance = math.sqrt((signPosX - destinationPosX) * (signPosX - destinationPosX) + (signPosY - destinationPosY) * (signPosY - destinationPosY)) 	

	local price = math.floor(distance/cfg.PriceDivider)

	PlayerChoice[nameP] = { 
		cellDescription = cellDestination,
		location = position,
		price = price
	}

	local message = trad.travelSign..nameDestination..trad.price..price.."\n\n"..trad.signQuestion..nameDestination

	local choice = trad.signChoice

	tes3mp.CustomMessageBox(pid, cfg.MainGUISign, message, choice)

end

TravelWorld.OnGUIAction = function(eventStatus, pid, idGui, data)
	
	local nameP = GetName(pid)	

	if idGui == cfg.MainGUI then

		if tonumber(data) == 0 or tonumber(data) == 18446744073709551615 then
		else   

			local cellDescription = PlayerChoice[nameP][tonumber(data)].cellDescription	

			local price = PlayerChoice[nameP][tonumber(data)].price

			if DeleteObjectInventory(pid, "gold_001", price) then	

				local TravelData = TravelStriData[cellDescription]

				tes3mp.SetCell(pid, cellDescription)
				tes3mp.SendCell(pid)
				tes3mp.SetPos(pid, TravelData.pos.XPos, TravelData.pos.YPos, TravelData.pos.ZPos + 1500)
				tes3mp.SetRot(pid, 0, 0)
				tes3mp.SendPos(pid)

			end

		end		

	elseif idGui == cfg.MainGUIBoat then

		if tonumber(data) == 0 or tonumber(data) == 18446744073709551615 then
		else   

			local cellDescription = PlayerChoice[nameP][tonumber(data)].cellDescription

			local price = PlayerChoice[nameP][tonumber(data)].price

			if DeleteObjectInventory(pid, "gold_001", price) then	

				local TravelData = TravelBoatData[cellDescription]

				tes3mp.SetCell(pid, cellDescription)
				tes3mp.SendCell(pid)
				tes3mp.SetPos(pid, TravelData.pos.XPos + 50, TravelData.pos.YPos - 50, TravelData.pos.ZPos + 250)
				tes3mp.SetRot(pid, 0, 0)
				tes3mp.SendPos(pid)	 

			end
		end	

	elseif idGui == cfg.MainGUISign then

		if tonumber(data) == 0 then 

			local cellDestination = PlayerChoice[nameP].cellDescription

			local position = PlayerChoice[nameP].location

			local price = PlayerChoice[nameP].price

			if DeleteObjectInventory(pid, "gold_001", price) then	

				tes3mp.SetCell(pid, cellDestination)
				tes3mp.SendCell(pid)
				tes3mp.SetPos(pid, position.posX, position.posY, position.posZ + 200)
				tes3mp.SetRot(pid, 0, 0)
				tes3mp.SendPos(pid)	 

			end
		end
	end	
end

------------
-- EVENTS --
------------
customEventHooks.registerHandler("OnObjectActivate", TravelWorld.OnActivatedObject)

customEventHooks.registerHandler("OnServerInit",TravelWorld.OnServerInit)

customEventHooks.registerHandler("OnGUIAction", TravelWorld.OnGUIAction)

return TravelWorld
