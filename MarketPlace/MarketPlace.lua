--[[
MarketPlace by Rickoff
tes3mp 0.8.1
---------------------------
DESCRIPTION :
Hotel for item sale between players with menu, gold is sent to sellers even offline
---------------------------
INSTALLATION:
Save the file as MarketPlace.lua inside your server/scripts/custom folder.
Edits to customScripts.lua, add in :
MarketPlace = require("custom.MarketPlace")
---------------------------
UTILIZATION:
Enter /hdv in your chat for open marketplace menu
]]
-------------------
-- CONFIGURATION --
-------------------
local cfg = {
	MainGUI = 070223,
	InvGUI = 070224,
	BuyGUI = 070225,
	StkGUI = 070226,
	BuyOptionsGUI = 070227,
	StkOptionsGUI = 070228,
	EditPriceGUI = 070229,
	MaxBuy = 25,
	MaxStock = 5,
	ReturnMenu = ""
}

----------------
-- TRADUCTION --
----------------
local trad = {
	MaxItemBuy = "You have reached the maximum number of items for sale: ",
	MaxItemStock = "You have reached the maximum number of items in stock: ",
	NoGold = "You have no gold.",
	NoBuy = "You cannot afford this item.",
	MainMenu = (color.Orange .. "WELCOME TO THE SALE HOTEL.\n"
		..color.Yellow.."\nTransfer:\n"..color.White.."to view items in your inventory.\n\n"
		..color.Yellow.."Store:\n"..color.White.."to display items for sale.\n\n"
		..color.Yellow.."Stock:\n"..color.White.."to display the list of your pending items.\n"
	),
	MainChoice = "Transfer;Store;Stock;Return;Close",
	Count = " | Count : ",
	SelectWait = "Select an item you want to put on sale in stock.",
	SelectBuy = "Select the item you want to buy or collect.\n",
	BuyTime = "\n Sale in progress : ",
	Return = "* Return *\n",
	Item ="Item : ",
	BuyOptionChoice = "Buy/Collect;Return",
	BuyByPlayer = "This item was just purchased by another player.\n",
	Price = " | Price : ",
	SelectStock ="Select a stock item to edit it.\n",
	Stock = "Stock : ",
	SelectStockChoice = "Change price;Sell;Retrieve;Return",
	NewPrice = "Enter a new price : "
}

--------------
-- VARIABLE --
--------------
local playerInventoryOptions = {}
local playerBuyOptions = {}
local playerStockOptions = {}
local playerStockChoice = {}
local HdvList = {}
local HdvInv = {}

--------------
-- FUNCTION --
--------------
local function GetName(pid)
	return string.lower(Players[pid].accountName)	
end
 
local function SaveHdvInv()
	jsonInterface.save("custom/MarketPlace/HdvInv.json", HdvInv)
end

local function SaveHdvList()
	jsonInterface.save("custom/MarketPlace/HdvList.json", HdvList)
end

local function LoadHdvList()	
	HdvList = jsonInterface.load("custom/MarketPlace/HdvList.json")	
	if HdvList == nil then	
		HdvList = {}		
		SaveHdvList()		
	end	
end

local function LoadHdvInv()	
	HdvInv = jsonInterface.load("custom/MarketPlace/HdvInv.json")	
	if HdvInv == nil then		
		HdvInv = {}		
		SaveHdvInv()		
	end	
end

local function getAvailablePlayerInventoryStock(pid)
	local options = {}   	
	for _, item in pairs(Players[pid].data.inventory) do		
		if item and item.refId ~= "" then		
			table.insert(options, item)			
		end
	end 
 	table.sort(options, function(a,b) return a.refId<b.refId end)		
	return options	
end
 
local function getHdvFurnitureStock(pid)  
	local options = {}  
	for playerName, data in pairs(HdvList) do	
		for _, item in ipairs(data) do			
			table.insert(options, item) 			
		end		
	end	
  	table.sort(options, function(a,b) return a.refId<b.refId end)	
	return options
end
 
local function getHdvInventoryStock(pid)
	local options = {}	
	local playerName = GetName(pid)    
	for _, item in ipairs(HdvInv[playerName]) do		
		table.insert(options, item)  		
	end
 	table.sort(options, function(a,b) return a.refId<b.refId end)		
	return options	
end
 
local function editPrice(pid, item, price)
	local playerName = GetName(pid)	
	local newprice = price or 0	
	local newItem = { refId = item.refId, price = newprice, owner = item.owner, count = item.count }
	local existingIndex = tableHelper.getIndexByNestedKeyValue(HdvInv[playerName], "refId", item.refId) 
	if existingIndex then	
		HdvInv[playerName][existingIndex] = newItem	
		SaveHdvInv()		
	end	
end
 
local function addHdv(pid, item)
	local playerName = GetName(pid)
	local existingIndex = tableHelper.getIndexByNestedKeyValue(HdvInv[playerName], "refId", item.refId)
	if existingIndex and tableHelper.getCount(HdvList[playerName]) < cfg.MaxBuy then		
		local newItem = HdvInv[playerName][existingIndex]		
		table.insert(HdvList[playerName], newItem)		
		HdvInv[playerName][existingIndex] = nil		
		tableHelper.cleanNils(HdvInv[playerName])		
		SaveHdvList()			
		SaveHdvInv()		
	else
		tes3mp.SendMessage(pid, color.Red..trad.MaxItemBuy..cfg.MaxBuy.."\n", false)
	end
end
 
local function itemAdd(pid, item)
	local playerName = GetName(pid)	
	local removedCount = item.count	
	local existingIndex	
	for index, slot in pairs(Players[pid].data.inventory) do	
		if slot.refId == item.refId then		
			existingIndex = index			
		end		
	end 
	if existingIndex and tableHelper.getCount(HdvInv[playerName]) < cfg.MaxStock then	
		local inventoryItem = Players[pid].data.inventory[existingIndex]		
		local newItem = {
			refId = inventoryItem.refId,
			price = 0,
			count = inventoryItem.count,
			owner = playerName
		}		
		for _, item in pairs(Players[pid].data.equipment) do		
			if item.refId == newItem.refId then			
				item = nil				
			end  			
		end				
		inventoryItem.count = inventoryItem.count - removedCount		
		if inventoryItem.count < 1 then		
			Players[pid].data.inventory[existingIndex] = nil			
		end
		local itemref = {refId = newItem.refId, count = removedCount, charge = -1, soul = ""}		
		Players[pid]:QuicksaveToDrive()		
		Players[pid]:LoadItemChanges({itemref}, enumerations.inventory.REMOVE)			
		table.insert(HdvInv[playerName], newItem)		
		SaveHdvInv()		
	else	
		tes3mp.SendMessage(pid, color.Red..trad.MaxItemStock..cfg.MaxStock.."\n", false)		
	end	
end

local function addItemPlayer(pid, item, data)
	local playerName = GetName(pid)	
	local existingIndex	
	local existingPlayer	
	for targetPlayerName, slot in pairs(data) do	
		for index, slot in ipairs(slot) do		
			if slot.refId == item.refId and slot.owner == item.owner then			
				existingIndex = index				
				existingPlayer = targetPlayerName				
			end			
		end		
	end	
	local count = item.count
	if existingIndex and existingPlayer then
		local newItem = data[existingPlayer][existingIndex] 		
		data[existingPlayer][existingIndex] = nil		
		tableHelper.cleanNils(data[existingPlayer])		
		table.insert(Players[pid].data.inventory, {refId = newItem.refId, count = count, charge = -1})		
		local itemref = {refId = newItem.refId, count = count, charge = -1}		
		Players[pid]:QuicksaveToDrive()		
		Players[pid]:LoadItemChanges({itemref}, enumerations.inventory.ADD)			
		SaveHdvInv()		
		SaveHdvList()			
	end	
end
 
local function itemAchat(pid, item)
	local playerName = GetName(pid)	
	local existingIndex	
	local existingPlayer	
	for targetPlayerName, data in pairs(HdvList) do	
		for index, slot in ipairs(data) do		
			if slot.refId == item.refId and slot.owner == item.owner then			
				existingIndex = index				
				existingPlayer = targetPlayerName				
			end
		end
	end
	if existingPlayer and existingIndex then	
		if existingPlayer == playerName then		
			addItemPlayer(pid, item, HdvList)			
			return			
		end		
		local newItem = HdvList[existingPlayer][existingIndex] 		
		local goldLoc = inventoryHelper.getItemIndex(Players[pid].data.inventory, "gold_001", -1)		
		local newPrice = newItem.price
		if goldLoc == nil then		
			tes3mp.MessageBox(pid, -1, trad.NoGold)			
		elseif goldLoc then		
			local goldcount = Players[pid].data.inventory[goldLoc].count			
			if goldcount >= newPrice then
				HdvList[existingPlayer][existingIndex] = nil				
				tableHelper.cleanNils(HdvList[existingPlayer])				
				Players[pid].data.inventory[goldLoc].count = Players[pid].data.inventory[goldLoc].count - newPrice
				local itemref = {refId = newItem.refId, count = newItem.count, charge = -1, soul = ""}				
				table.insert(Players[pid].data.inventory, itemref)				
				local goldprice = {refId = "gold_001", count = newPrice, charge = -1, soul = ""}				
				Players[pid]:QuicksaveToDrive()				
				Players[pid]:LoadItemChanges({goldprice}, enumerations.inventory.REMOVE)				
				Players[pid]:LoadItemChanges({itemref}, enumerations.inventory.ADD)					
				local TargetPlayer = logicHandler.GetPlayerByName(existingPlayer)				
				local goldLocSeller = inventoryHelper.getItemIndex(TargetPlayer.data.inventory, "gold_001", -1)				
				if goldLocSeller then				
					TargetPlayer.data.inventory[goldLocSeller].count = TargetPlayer.data.inventory[goldLocSeller].count + newPrice				
					if TargetPlayer:IsLoggedIn() then						
						TargetPlayer:QuicksaveToDrive()						
						TargetPlayer:LoadItemChanges({goldprice}, enumerations.inventory.ADD)							
					else					
						TargetPlayer.loggedIn = true						
						TargetPlayer:QuicksaveToDrive()						
						TargetPlayer.loggedIn = false						
					end					
				else				
					table.insert(TargetPlayer.data.inventory, goldprice)						
					if TargetPlayer:IsLoggedIn() then						
						TargetPlayer:QuicksaveToDrive()						
						TargetPlayer:LoadItemChanges({goldprice}, enumerations.inventory.ADD)						
					else					
						TargetPlayer.loggedIn = true						
						TargetPlayer:QuicksaveToDrive()						
						TargetPlayer.loggedIn = false						
					end
				end				
				SaveHdvList()				
			else			
				tes3mp.MessageBox(pid, -1, trad.NoBuy)					
			end				
		end			
	end	
end
-------------
-- METHODE --
-------------
local MarketPlace = {}

MarketPlace.OnServerPostInit = function(eventStatus)
	LoadHdvList()
	LoadHdvInv()
end

MarketPlace.OnPlayerAuthentified = function(eventStatus, pid)	
	local PlayerName = GetName(pid)
	if not HdvInv[PlayerName] then
		HdvInv[PlayerName] = {}
		SaveHdvInv()
	end
	if not HdvList[PlayerName] then
		HdvList[PlayerName] = {}
		SaveHdvList()
	end
end
 
MarketPlace.showMainGUI = function(pid)		
	tes3mp.CustomMessageBox(pid, cfg.MainGUI, trad.MainMenu, trad.MainChoice)	
end
 
MarketPlace.showInventoryGUI = function(pid)	
	local playerName = GetName(pid)
	local options = getAvailablePlayerInventoryStock(pid)
	local list = trad.Return
	for i = 1, #options do
		list = list..options[i].refId..trad.Count..options[i].count or 1
		if not(i == #options) then
			list = list.."\n"
		end
	end
	playerInventoryOptions[playerName] = {opt = options}
	tes3mp.ListBox(pid, cfg.InvGUI, color.CornflowerBlue..trad.SelectWait..color.Default, list)
end
 
MarketPlace.showBuyGUI = function(pid)	
	local playerName = GetName(pid)		
	local goldcount = 0
	local goldLoc = inventoryHelper.getItemIndex(Players[pid].data.inventory, "gold_001", -1)
	if goldLoc then		
		goldcount = Players[pid].data.inventory[goldLoc].count	
	end		
	local options = getHdvFurnitureStock(pid)		
	local list = trad.Return	   	
	for i = 1, #options do
		list = list..string.sub(options[i].refId, 1, 10).." | P: "..options[i].price.." | V: "..options[i].owner.." | N: "..options[i].count			
		if not(i == #options) then
			list = list .. "\n"
		end			
	end		
	playerBuyOptions[GetName(pid)] = {opt = options} 		
	local message = (color.CornflowerBlue..trad.SelectBuy
		..color.Yellow.."Gold : "..goldcount
		..color.White..trad.BuyTime..tableHelper.getCount(HdvList[playerName]).." | "..cfg.MaxBuy
	)
	tes3mp.ListBox(pid, cfg.BuyGUI, message, list)
end
 
MarketPlace.showBuyOptionsGUI = function(pid, loc)
	local message = ""
	local choice = playerBuyOptions[GetName(pid)].opt[loc]
	if choice and choice.refId  then
		message = message..trad.Item..choice.refId
		playerBuyOptions[GetName(pid)].choice = choice
		tes3mp.CustomMessageBox(pid, cfg.BuyOptionsGUI, message, trad.BuyOptionChoice)
	else
		tes3mp.SendMessage(pid, trad.BuyByPlayer, false)
	end
end
 
MarketPlace.showStockGUI = function(pid)	
	local playerName = GetName(pid)		
	local options = getHdvInventoryStock(pid)		
	local list = trad.Return		
	for i = 1, #options do			
		list = list..options[i].refId..trad.Price..options[i].price..trad.Count..options[i].count			
		if not(i == #options) then
			list = list .. "\n"
		end			
	end
	playerStockOptions[playerName] = {opt = options}		
	local message = (color.CornflowerBlue..trad.SelectStock
	..color.White..trad.Stock..tableHelper.getCount(HdvInv[playerName]).." | "..cfg.MaxStock
	)
	tes3mp.ListBox(pid, cfg.StkGUI, message, list)
end
 
MarketPlace.showViewOptionsGUI = function(pid, loc)	
	local choice = playerStockOptions[GetName(pid)].opt[loc]
	local message = playerStockOptions[GetName(pid)].opt[loc].refId
	playerStockChoice[GetName(pid)] = choice
	tes3mp.CustomMessageBox(pid, cfg.StkOptionsGUI, message, trad.SelectStockChoice)
end
 
MarketPlace.showEditPricePrompt = function(pid, loc)	
	local message = trad.NewPrice
	return tes3mp.InputDialog(pid, cfg.EditPriceGUI, message, "")
end
 
MarketPlace.OnGUIAction = function(eventStatus, pid, idGui, data)
	if idGui == cfg.MainGUI then		
		if tonumber(data) == 0 then			
			MarketPlace.showInventoryGUI(pid)				
		elseif tonumber(data) == 1 then			
			MarketPlace.showBuyGUI(pid)				
		elseif tonumber(data) == 2 then			
			MarketPlace.showStockGUI(pid)
		elseif tonumber(data) == 3 then			
			Players[pid].currentCustomMenu = cfg.ReturnMenu				
			menuHelper.DisplayMenu(pid, Players[pid].currentCustomMenu)
		elseif tonumber(data) == 4 then			
			--Do nothing				
		end
	elseif idGui == cfg.InvGUI then		
		if tonumber(data) == 0 or tonumber(data) == 18446744073709551615 then			
			MarketPlace.showMainGUI(pid)				
		else   			
			local choice = playerInventoryOptions[GetName(pid)].opt[tonumber(data)]				
			itemAdd(pid, choice)				
			MarketPlace.showMainGUI(pid)				
		end
	elseif idGui == cfg.EditPriceGUI then		
		if tonumber(data) ~= nil then			
			local choice = playerStockChoice[GetName(pid)] 				
			editPrice(pid, choice, tonumber(data))				
			MarketPlace.showStockGUI(pid)				
		else			
			MarketPlace.showStockGUI(pid)				
		end			
	elseif idGui == cfg.BuyGUI then		
		if tonumber(data) == 0 or tonumber(data) == 18446744073709551615 then			
			MarketPlace.showMainGUI(pid)				
		else			
			MarketPlace.showBuyOptionsGUI(pid, tonumber(data))
		end			
	elseif idGui == cfg.BuyOptionsGUI then		
		if tonumber(data) == 0 then			
			local choice = playerBuyOptions[GetName(pid)].choice				
			itemAchat(pid, choice) 				
			MarketPlace.showBuyGUI(pid)					
		end
	elseif idGui == cfg.StkGUI then		
		if tonumber(data) == 0 or tonumber(data) == 18446744073709551615 then
			MarketPlace.showMainGUI(pid)				
		else			
			MarketPlace.showViewOptionsGUI(pid, tonumber(data))
		end
	elseif idGui == cfg.StkOptionsGUI then		
		if tonumber(data) == 0 then			
			MarketPlace.showEditPricePrompt(pid)				
		elseif tonumber(data) == 1 then			
			local choice = playerStockChoice[GetName(pid)]					
			addHdv(pid, choice)				
			MarketPlace.showStockGUI(pid)				
		elseif tonumber(data) == 2 then			
			local choice = playerStockChoice[GetName(pid)]				
			addItemPlayer(pid, choice, HdvInv)				
			MarketPlace.showStockGUI(pid)					
		else
			MarketPlace.showStockGUI(pid)
		end
	end
end
------------
--  EVENT --
------------
customEventHooks.registerHandler("OnServerPostInit", MarketPlace.OnServerPostInit)
customEventHooks.registerHandler("OnPlayerAuthentified", MarketPlace.OnPlayerAuthentified)
customEventHooks.registerHandler("OnGUIAction", MarketPlace.OnGUIAction)

customCommandHooks.registerCommand("hdv", MarketPlace.showMainGUI)

return MarketPlace
