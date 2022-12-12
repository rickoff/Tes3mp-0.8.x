--[[
ChessTes3mp 0.1.0
tes3mp 0.8.1
OpenMw 0.47
Script written by Eric Chartier (Rickoff) all rights of exploitation and free modification. Don't forget to credit me somewhere on your server. Thanks
---------------------------
DESCRIPTION :
Play chess with other players or against a stupid artificial intelligence. All original game rules are scripted
---------------------------
INSTALLATION :
Save the file as ChessTes3mp.lua inside your server/scripts/custom folder.
Edits to customScripts.lua
ChessTes3mp = require("custom.ChessTes3mp")
---------------------------
USE :
enter /chess in the chat to bring up a chess table in front of you, only interior
the creator can configure the options of the table by activating a case or a pawn
Free for a free game alone or with others
Tournaments for a game according to rules, starting bet, number of rounds
Pve to play against artificial intelligence. Note: currently the AI ​​plays the first available move
]]
----------
-- DATA --
----------
local ChessBoard = jsonInterface.load("custom/ChessDataBoard.json")
------------
-- CONFIG --
------------
local cfg = {
	OnServerInit = true,
	scale = 2.5,
	SelectModeGUI = 04122022,
	SelectPriceRegisterGUI = 04122023,
	SelectGameRoundGUI = 04122024
}
----------------
-- TRADUCTION --
----------------
local trad = {
	tower = "Tower",
	knight = "Knight",
	bishop = "Bishop",
	queen = "Queen",
	king = "King",
	pawn = "Pawn",
	white = "White",
	red = "Red",
	congrat = "Congratulations, you have won the game of chess.",
	desolat = "Sorry, you have lost the game of chess.",
	menu = "CHESS BOARD MENU\n\nSelect a game mode.\n\nFree: Free play alone or in a group\nTournament: Rules-based play in 1 on 1\nPve: Play against artificial intelligence alone\n",
	choice = "Free;Tournament;Pve;Back",
	wait = "Please wait for the owner to select a game mode.",
	tournament = "Tournament",
	bet = "Enter a registration fee.",
	waitBet = "Please wait for the owner to select an enrollment amount.",
	round = "Enter a number of winning rounds.",
	waitRound = "Please wait for the owner to select a number of rounds.",
	free = "Free",
	noChange = "Unable to change teams in game mode: ",
	noGold = "You do not have the gold required for registration: ",
	register = "To register for the game of chess, you have spent: ",
	pve = "Pve",
	noAvailable = "The team is not available.",
	waitTurn = "Please wait, it is the turn of the team: ",
	kingMate = "The king of your team is in check\n",
	by = "By the piece: ",
	located = "\nLocated on the square: ",
	come = "\nJust played on the square: ",
	kingEnnemy = "The king of the team: ",
	isMate = " is in check\n",
	unknown = "unknown",
	noPlay = "\nCannot be played on the square: ",
	cause = "\nCause: ",
	noSelect = "Please select a piece to begin playing",
	sameTeam = "same team",
	samePawn = "same piece",
	moveRule = "movement rule",
	sameTeamRoute = "same team on the route",
	checkKing = "check to the king",
	whiteCase = "White Square",
	redCase = "Red Square",
	whiteTower = "White Tower",
	redTower = "Red Tower",
	whiteQueen = "White Queen",
	redQueen = "Red Queen",
	whiteKing = "White King",
	redKing = "Red King",
	whiteBishop = "White Bishop",
	redBishop = "Red Bishop",
	whiteKnight = "White Knight",
	redKnight = "Red Knight",
	whitePawn = "White Pawn",
	redPawn = "Red Pawn",
	pate = "Draw game, no pieces can be moved for you and your opponent."
}
--------------
-- VARIABLE --
--------------
local listPawnCase = {
	[1] = {
		refId = "pawn_white_tower",
		posZ = 2,
		rotZ = 1.5,
		scale = 0.004,
		name = trad.tower
	},
	[2] = {
		refId = "pawn_white_knight",
		posZ = 0,
		rotZ = 1.5,		
		scale = 0.01,
		name = trad.knight
	},
	[3] = {
		refId = "pawn_white_bishop",
		posZ = 0,
		rotZ = 1.5,		
		scale = 0.03,
		name = trad.bishop
	},	
	[4] = {
		refId = "pawn_white_queen",
		posZ = 0,
		rotZ = 1.5,		
		scale = 0.03,
		name = trad.queen
	},
	[5] = {
		refId = "pawn_white_king",
		posZ = 0,
		rotZ = 1.5,		
		scale = 0.03,
		name = trad.king
	},
	[6] = {
		refId = "pawn_white_bishop",
		posZ = 0,
		rotZ = 1.5,		
		scale = 0.03,
		name = trad.bishop
	},
	[7] = {
		refId = "pawn_white_knight",
		posZ = 0,
		rotZ = 1.5,		
		scale = 0.01,
		name = trad.knight
	},	
	[8] = {
		refId = "pawn_white_tower",
		posZ = 2,
		rotZ = 1.5,		
		scale = 0.004,
		name = trad.tower
	},
	[9] = {
		refId = "pawn_white_pawn",
		posZ = 0,
		rotZ = 1.5,		
		scale = 0.02,
		name = trad.pawn
	},
	[10] = {
		refId = "pawn_white_pawn",
		posZ = 0,
		rotZ = 1.5,		
		scale = 0.02,
		name = trad.pawn
	},
	[11] = {
		refId = "pawn_white_pawn",
		posZ = 0,
		rotZ = 1.5,		
		scale = 0.02,
		name = trad.pawn
	},
	[12] = {
		refId = "pawn_white_pawn",
		posZ = 0,
		rotZ = 1.5,		
		scale = 0.02,
		name = trad.pawn
	},
	[13] = {
		refId = "pawn_white_pawn",
		posZ = 0,
		rotZ = 1.5,		
		scale = 0.02,
		name = trad.pawn
	},
	[14] = {
		refId = "pawn_white_pawn",
		posZ = 0,
		rotZ = 1.5,		
		scale = 0.02,
		name = trad.pawn
	},
	[15] = {
		refId = "pawn_white_pawn",
		posZ = 0,
		rotZ = 1.5,		
		scale = 0.02,
		name = trad.pawn
	},
	[16] = {
		refId = "pawn_white_pawn",
		posZ = 0,
		rotZ = 1.5,		
		scale = 0.02,
		name = trad.pawn
	},
	[64] = {
		refId = "pawn_red_tower",
		posZ = 1,
		rotZ = -1.5,
		scale = 0.003,
		name = trad.tower
	},
	[63] = {
		refId = "pawn_red_knight",
		posZ = 0,
		rotZ = -1.5,		
		scale = 0.01,
		name = trad.knight
	},
	[62] = {
		refId = "pawn_red_bishop",
		posZ = 0,
		rotZ = -1.5,		
		scale = 0.03,
		name = trad.bishop
	},	
	[61] = {
		refId = "pawn_red_queen",
		posZ = 0,
		rotZ = -1.5,		
		scale = 0.03,
		name = trad.queen
	},
	[60] = {
		refId = "pawn_red_king",
		posZ = 0,
		rotZ = -1.5,		
		scale = 0.03,
		name = trad.king
	},
	[59] = {
		refId = "pawn_red_bishop",
		posZ = 0,
		rotZ = -1.5,		
		scale = 0.03,
		name = trad.bishop
	},
	[58] = {
		refId = "pawn_red_knight",
		posZ = 0,
		rotZ = -1.5,		
		scale = 0.01,
		name = trad.knight
	},	
	[57] = {
		refId = "pawn_red_tower",
		posZ = 1,
		rotZ = -1.5,		
		scale = 0.003,
		name = trad.tower
	},
	[56] = {
		refId = "pawn_red_pawn",
		posZ = 0,
		rotZ = -1.5,		
		scale = 0.02,
		name = trad.pawn
	},
	[55] = {
		refId = "pawn_red_pawn",
		posZ = 0,
		rotZ = -1.5,		
		scale = 0.02,
		name = trad.pawn
	},
	[54] = {
		refId = "pawn_red_pawn",
		posZ = 0,
		rotZ = -1.5,		
		scale = 0.02,
		name = trad.pawn
	},
	[53] = {
		refId = "pawn_red_pawn",
		posZ = 0,
		rotZ = -1.5,		
		scale = 0.02,
		name = trad.pawn
	},
	[52] = {
		refId = "pawn_red_pawn",
		posZ = 0,
		rotZ = -1.5,		
		scale = 0.02,
		name = trad.pawn
	},
	[51] = {
		refId = "pawn_red_pawn",
		posZ = 0,
		rotZ = -1.5,		
		scale = 0.02,
		name = trad.pawn
	},
	[50] = {
		refId = "pawn_red_pawn",
		posZ = 0,
		rotZ = -1.5,		
		scale = 0.02,
		name = trad.pawn
	},
	[49] = {
		refId = "pawn_red_pawn",
		posZ = 0,
		rotZ = -1.5,		
		scale = 0.02,
		name = trad.pawn
	}	
}
--------------
-- FUNCTION --
--------------
local function LoadData()
	ChessBoard = jsonInterface.load("custom/ChessDataBoard.json")	
end
local function SaveData()
	jsonInterface.save("custom/ChessDataBoard.json", ChessBoard)
	LoadData()
end
local function GetName(pid)
	return string.lower(Players[pid].accountName)	
end
local function RegisterGold(pid, count)
	local itemref = {
		refId = "gold_001",
		count = count,
		charge = -1,
		enchantmentCharge = -1,
		soul = ""
	}	
	if count > 0 then
		local indexLoc = inventoryHelper.getItemIndex(Players[pid].data.inventory, itemref.refId, itemref.charge, itemref.enchantmentCharge, itemref.soul)
		if indexLoc then
			if Players[pid].data.inventory[indexLoc].count >= count then
				Players[pid].data.inventory[indexLoc].count = Players[pid].data.inventory[indexLoc].count - count
				if Players[pid].data.inventory[indexLoc].count == 0 then
					Players[pid].data.inventory[indexLoc].count = nil
				end
				Players[pid]:LoadItemChanges({itemref}, enumerations.inventory.REMOVE)
				Players[pid]:QuicksaveToDrive()
				return true
			else
				return false
			end
		else
			return false	
		end
	else
		return true
	end
end
local function RewardEndGame(winnerPid, DataChess)
	local count = DataChess.registerPrice * 2
	local itemref = {
		refId = "gold_001",
		count = count,
		charge = -1,
		enchantmentCharge = -1,
		soul = ""
	}	
	local indexLoc = inventoryHelper.getItemIndex(Players[pid].data.inventory, itemref.refId, itemref.charge, itemref.enchantmentCharge, itemref.soul)
	if indexLoc then
		if Players[pid].data.inventory[indexLoc].count then
			Players[pid].data.inventory[indexLoc].count = Players[pid].data.inventory[indexLoc].count + itemref.count
		else
			Players[pid].data.inventory[indexLoc].count = itemref.count
		end
	else
		table.insert(Players[pid].data.inventory, itemref)	
	end
	Players[pid]:LoadItemChanges({itemref}, enumerations.inventory.ADD)
	Players[pid]:QuicksaveToDrive()
end
local function CreateObjectAtLocation(cellDescription, location, refId, scale)
	local scale = scale or 1
	local mpNum = WorldInstance:GetCurrentMpNum() + 1
	local uniqueIndex =  0 .. "-" .. mpNum	
	LoadedCells[cellDescription]:InitializeObjectData(uniqueIndex, refId)
	if LoadedCells[cellDescription].data.objectData[uniqueIndex] then
		LoadedCells[cellDescription].data.objectData[uniqueIndex].location = location
		LoadedCells[cellDescription].data.objectData[uniqueIndex].scale = scale		
		table.insert(LoadedCells[cellDescription].data.packets.position, uniqueIndex)
		table.insert(LoadedCells[cellDescription].data.packets.scale, uniqueIndex)	
		table.insert(LoadedCells[cellDescription].data.packets.place, uniqueIndex)
	end
	WorldInstance:SetCurrentMpNum(mpNum)
	tes3mp.SetCurrentMpNum(mpNum)	
	return uniqueIndex
end
local function DeleteObject(pid, cellDescription, StatePackets)
	local count = 0
	tes3mp.ClearObjectList()
	tes3mp.SetObjectListPid(pid)
	tes3mp.SetObjectListCell(cellDescription)	
	for i = 1, #StatePackets do
		if LoadedCells[cellDescription] and LoadedCells[cellDescription].data.objectData[StatePackets[i]] then
			LoadedCells[cellDescription]:DeleteObjectData(StatePackets[i])
			local splitIndex = StatePackets[i]:split("-")
			tes3mp.SetObjectRefNum(splitIndex[1])
			tes3mp.SetObjectMpNum(splitIndex[2])
			tes3mp.AddObject()	
			count = count + 1
			if count >= 1000 then
				tes3mp.SendObjectDelete(true)
				tes3mp.ClearObjectList()
				tes3mp.SetObjectListPid(pid)
				tes3mp.SetObjectListCell(cellDescription)
				count = 0
			end	
		end
	end
	if count > 0 then	
		tes3mp.SendObjectDelete(true)
	end
end
local function DeleteChessBoard(pid, playerName)
	local listDeletePacket = {}
	local DataChess = ChessBoard[playerName]
	local cellDescription = DataChess.cellDescription
	local temporyLoadCell = false
	if LoadedCells[cellDescription] == nil then
		logicHandler.LoadCell(cellDescription)
		temporyLoadCell = true
	end
	for uniqueIndex, data in pairs(DataChess.listCaseIndex) do
		table.insert(listDeletePacket, uniqueIndex)
	end
	for uniqueIndex, data in pairs(DataChess.listPawnIndex) do
		table.insert(listDeletePacket, uniqueIndex)
	end
	table.insert(listDeletePacket, DataChess.tableUnique)	
	DeleteObject(pid, cellDescription, listDeletePacket)
	if temporyLoadCell then
		logicHandler.UnloadCell(cellDescription)
	end
end
local function SendPacket(pid, cellDescription, StatePackets)
	local count = 0
	tes3mp.ClearObjectList()
	tes3mp.SetObjectListPid(pid)
	tes3mp.SetObjectListCell(cellDescription)
	for i = 1, #StatePackets do
		local object = LoadedCells[cellDescription].data.objectData[StatePackets[i]]
		if object and object.refId then
			local splitIndex = StatePackets[i]:split("-")
			tes3mp.SetObjectRefNum(splitIndex[1])
			tes3mp.SetObjectMpNum(splitIndex[2])
			tes3mp.SetObjectRefId(object.refId)
			tes3mp.SetObjectPosition(object.location.posX, object.location.posY, object.location.posZ)
			tes3mp.SetObjectRotation(object.location.rotX, object.location.rotY, object.location.rotZ)
			tes3mp.SetObjectScale(object.scale)
			tes3mp.AddObject()
			count = count + 1
		end
		if count >= 1000 then
			tes3mp.SendObjectPlace(true)
			tes3mp.SendObjectScale(true)
			tes3mp.ClearObjectList()
			tes3mp.SetObjectListPid(pid)
			tes3mp.SetObjectListCell(cellDescription)
			count = 0
		end	
	end
	if count > 0 then	
		tes3mp.SendObjectPlace(true)
		tes3mp.SendObjectScale(true)
	end
end
local function SendMove(pid, cellDescription, StatePackets, toEveryone)
	local count = 0
	tes3mp.ClearObjectList()
	tes3mp.SetObjectListPid(pid)
	tes3mp.SetObjectListCell(cellDescription)
	for i = 1, #StatePackets do
		local object = LoadedCells[cellDescription].data.objectData[StatePackets[i]]
		if not object then return end
		if object and object.location then	
			local splitIndex = StatePackets[i]:split("-")
			tes3mp.SetObjectRefNum(splitIndex[1])
			tes3mp.SetObjectMpNum(splitIndex[2])
			tes3mp.SetObjectPosition(object.location.posX, object.location.posY, object.location.posZ)
			tes3mp.SetObjectRotation(object.location.rotX, object.location.rotY, object.location.rotZ)
			tes3mp.AddObject()
			count = count + 1
			if count >= 1000 then
				tes3mp.SendObjectMove(toEveryone)
				tes3mp.SendObjectRotate(toEveryone)	
				tes3mp.ClearObjectList()
				tes3mp.SetObjectListPid(pid)
				tes3mp.SetObjectListCell(cellDescription)
				count = 0
			end	
		end	
	end
	if count > 0 then
		tes3mp.SendObjectMove(toEveryone)
		tes3mp.SendObjectRotate(toEveryone)
	end
end
local function GetObject(cellDescription, uniqueIndex)
	if LoadedCells[cellDescription] and LoadedCells[cellDescription].data.objectData[uniqueIndex] then
		return LoadedCells[cellDescription].data.objectData[uniqueIndex]
	end	
end
local function GetOriginalCase(refId, tableCaseNumber)
	for numberCase, data in pairs(listPawnCase) do
		if data.refId == refId and not tableCaseNumber[numberCase] then
			return numberCase
		end
	end
end
local function GetChessBoard(ObjectIndex, PlayerName)
	for ownerName, data in pairs(ChessBoard) do
		if ownerName == PlayerName then 
			return data, ownerName
		end
		for targetName, slot in pairs(data.listPlayers) do
			if targetName == PlayerName then
				return data, ownerName
			end
		end
		for uniqueIndex, slot in pairs(data.listPawnIndex) do
			if uniqueIndex == ObjectIndex then
				return data, ownerName
			end
		end
		for uniqueIndex, slot in pairs(data.listCaseIndex) do
			if uniqueIndex == ObjectIndex then
				return data, ownerName
			end
		end		
	end
	return false
end
local function GetAvailableTeam(teamPawn, DataChess)
	for playerName, data in pairs(DataChess.listPlayers) do
		if data.team == teamPawn then
			return false
		end
	end
	return true
end
local function GetIndexPawnInCase(CaseNumber, DataChess)
	for uniqueIndex, data in pairs(DataChess.listPawnIndex) do
		if CaseNumber == data.case then
			return uniqueIndex
		end
	end
	return false
end
local function GetIndexPawnByRefId(refId, DataChess)
	for uniqueIndex, data in pairs(DataChess.listPawnIndex) do
		if refId == data.refId then
			return uniqueIndex
		end
	end
	return false
end
local function GetIndexCaseByNumber(CaseNumber, DataChess)
	for uniqueIndex, data in pairs(DataChess.listCaseIndex) do
		if CaseNumber == data.case then
			return uniqueIndex
		end
	end
	return false
end
local function GetNumberCase(coorA, coorB, DataChess)
	for caseIndex, data in pairs(DataChess.listCaseIndex) do
		if data.coorA == coorA and data.coorB == coorB then
			return data.case
		end
	end
	return false
end
local function GetCaseIsEmpty(coorA, coorB, DataChess)
	for pawnIndex, data in pairs(DataChess.listPawnIndex) do
		if data.coorA == coorA and data.coorB == coorB then
			return false
		end
	end
	return true
end
local function GetTeamPawn(refId)
	local team
	if string.find(refId, "white") then
		team = trad.white
	else
		team = trad.red
	end	
	return team
end
local function GetPlayerNameTeam(team, DataChess)
	for playerName, data in pairs(DataChess.listPlayers) do
		if data.team == team then
			return playerName
		end
	end
	return false
end
local function GetPlayerByName(playerName)
	if playerName then
		for iteratorPid, player in pairs(Players) do
			if string.lower(playerName) == string.lower(player.accountName) then
				return player
			end
		end
	end
	return false
end
local function GetAllValideMove(pawnIndex, caseIndex, DataChess)
	local DataPawn = DataChess.listPawnIndex[pawnIndex]
	local team = GetTeamPawn(DataPawn.refId)
	local protect = false
	local targetCaseNumber
	local targetCaseIndex
	local targetPawnIndex
	if DataPawn.name == trad.pawn then
		local targetCaseNumber
		local targetCaseIndex
		if team == trad.white then
			for div = 1, 2 do
				if div == 1 then
					targetCaseNumber = GetNumberCase(DataPawn.coorA + 1, DataPawn.coorB + 1, DataChess)
				else
					targetCaseNumber = GetNumberCase(DataPawn.coorA - 1, DataPawn.coorB + 1, DataChess)
				end
				targetCaseIndex = GetIndexCaseByNumber(targetCaseNumber, DataChess)
				if targetCaseIndex then
					if targetCaseIndex == caseIndex then
						return true --menace
					end
				end
			end
		else
			for div = 1, 2 do
				if div == 1 then
					targetCaseNumber = GetNumberCase(DataPawn.coorA + 1, DataPawn.coorB - 1, DataChess)
				else
					targetCaseNumber = GetNumberCase(DataPawn.coorA - 1, DataPawn.coorB - 1, DataChess)
				end
				targetCaseIndex = GetIndexCaseByNumber(targetCaseNumber, DataChess)
				if targetCaseIndex then
					if targetCaseIndex == caseIndex then
						return true --menace
					end
				end
			end		
		end
	end
	if DataPawn.name == trad.tower then
		for div = 1, 4 do
			protect = false
			if div == 1 then
				for a = 1, 8 do
					targetCaseNumber = GetNumberCase(DataPawn.coorA + a, DataPawn.coorB, DataChess)
					targetCaseIndex = GetIndexCaseByNumber(targetCaseNumber, DataChess)
					targetPawnIndex = GetIndexPawnInCase(targetCaseNumber, DataChess)
					if targetPawnIndex then
						local targetPawnTeam = GetTeamPawn(DataChess.listPawnIndex[targetPawnIndex].refId)
						local targetPawnName = DataChess.listPawnIndex[targetPawnIndex].name
						if targetPawnName == trad.king and targetPawnTeam ~= team and not protect then
							protect = false
						else
							protect = true
						end
					end
					if targetCaseIndex then
						if targetCaseIndex == caseIndex and not protect then
							return true --menace
						end
					end	
				end
			elseif div == 2 then
				for a = 1, 8 do
					targetCaseNumber = GetNumberCase(DataPawn.coorA - a, DataPawn.coorB, DataChess)
					targetCaseIndex = GetIndexCaseByNumber(targetCaseNumber, DataChess)
					targetPawnIndex = GetIndexPawnInCase(targetCaseNumber, DataChess)
					if targetPawnIndex then
						local targetPawnTeam = GetTeamPawn(DataChess.listPawnIndex[targetPawnIndex].refId)
						local targetPawnName = DataChess.listPawnIndex[targetPawnIndex].name
						if targetPawnName == trad.king and targetPawnTeam ~= team and not protect then
							protect = false
						else
							protect = true
						end
					end
					if targetCaseIndex then
						if targetCaseIndex == caseIndex and not protect then
							return true --menace
						end
					end	
				end
			elseif div == 3 then
				for b = 1, 8 do
					targetCaseNumber = GetNumberCase(DataPawn.coorA, DataPawn.coorB + b, DataChess)
					targetCaseIndex = GetIndexCaseByNumber(targetCaseNumber, DataChess)
					targetPawnIndex = GetIndexPawnInCase(targetCaseNumber, DataChess)
					if targetPawnIndex then
						local targetPawnTeam = GetTeamPawn(DataChess.listPawnIndex[targetPawnIndex].refId)
						local targetPawnName = DataChess.listPawnIndex[targetPawnIndex].name
						if targetPawnName == trad.king and targetPawnTeam ~= team and not protect then
							protect = false
						else
							protect = true
						end
					end
					if targetCaseIndex then
						if targetCaseIndex == caseIndex and not protect then
							return true --menace
						end
					end	
				end
			elseif div == 4 then
				for b = 1, 8 do
					targetCaseNumber = GetNumberCase(DataPawn.coorA, DataPawn.coorB - b, DataChess)
					targetCaseIndex = GetIndexCaseByNumber(targetCaseNumber, DataChess)
					targetPawnIndex = GetIndexPawnInCase(targetCaseNumber, DataChess)
					if targetPawnIndex then
						local targetPawnTeam = GetTeamPawn(DataChess.listPawnIndex[targetPawnIndex].refId)
						local targetPawnName = DataChess.listPawnIndex[targetPawnIndex].name
						if targetPawnName == trad.king and targetPawnTeam ~= team and not protect then
							protect = false
						else
							protect = true
						end
					end
					if targetCaseIndex then
						if targetCaseIndex == caseIndex and not protect then
							return true --menace
						end
					end	
				end
			end
		end
		return false
	end
	if DataPawn.name == trad.knight then
		for div = 1, 8 do
			if div == 1 then
				targetCaseNumber = GetNumberCase(DataPawn.coorA + 2, DataPawn.coorB + 1, DataChess)	
			elseif div == 2 then
				targetCaseNumber = GetNumberCase(DataPawn.coorA + 2, DataPawn.coorB - 1, DataChess)
			elseif div == 3 then
				targetCaseNumber = GetNumberCase(DataPawn.coorA + 1, DataPawn.coorB + 2, DataChess)
			elseif div == 4 then
				targetCaseNumber = GetNumberCase(DataPawn.coorA + 1, DataPawn.coorB - 2, DataChess)
			elseif div == 5 then
				targetCaseNumber = GetNumberCase(DataPawn.coorA - 2, DataPawn.coorB + 1, DataChess)	
			elseif div == 6 then
				targetCaseNumber = GetNumberCase(DataPawn.coorA - 2, DataPawn.coorB - 1, DataChess)
			elseif div == 7 then
				targetCaseNumber = GetNumberCase(DataPawn.coorA - 1, DataPawn.coorB + 2, DataChess)
			elseif div == 8 then
				targetCaseNumber = GetNumberCase(DataPawn.coorA - 1, DataPawn.coorB - 2, DataChess)
			end
			targetCaseIndex = GetIndexCaseByNumber(targetCaseNumber, DataChess)
			if targetCaseIndex then
				if targetCaseIndex == caseIndex then
					return true --menace
				end
			end	
		end	
	end
	if DataPawn.name == trad.bishop then
		for div = 1, 4 do
			protect = false
			if div == 1 then
				for x = 1, 8 do
					targetCaseNumber = GetNumberCase(DataPawn.coorA + x, DataPawn.coorB + x, DataChess)
					targetCaseIndex = GetIndexCaseByNumber(targetCaseNumber, DataChess)
					targetPawnIndex = GetIndexPawnInCase(targetCaseNumber, DataChess)
					if targetPawnIndex then
						local targetPawnTeam = GetTeamPawn(DataChess.listPawnIndex[targetPawnIndex].refId)
						local targetPawnName = DataChess.listPawnIndex[targetPawnIndex].name
						if targetPawnName == trad.king and targetPawnTeam ~= team and not protect then
							protect = false
						else
							protect = true
						end
					end
					if targetCaseIndex then
						if targetCaseIndex == caseIndex and not protect then
							return true --menace
						end
					end	
				end
			elseif div == 2 then
				for x = 1, 8 do
					targetCaseNumber = GetNumberCase(DataPawn.coorA - x, DataPawn.coorB - x, DataChess)
					targetCaseIndex = GetIndexCaseByNumber(targetCaseNumber, DataChess)
					targetPawnIndex = GetIndexPawnInCase(targetCaseNumber, DataChess)
					if targetPawnIndex then
						local targetPawnTeam = GetTeamPawn(DataChess.listPawnIndex[targetPawnIndex].refId)
						local targetPawnName = DataChess.listPawnIndex[targetPawnIndex].name
						if targetPawnName == trad.king and targetPawnTeam ~= team and not protect then
							protect = false
						else
							protect = true
						end
					end
					if targetCaseIndex then
						if targetCaseIndex == caseIndex and not protect then
							return true --menace
						end
					end	
				end
			elseif div == 3 then
				for x = 1, 8 do
					targetCaseNumber = GetNumberCase(DataPawn.coorA + x, DataPawn.coorB - x, DataChess)
					targetCaseIndex = GetIndexCaseByNumber(targetCaseNumber, DataChess)
					targetPawnIndex = GetIndexPawnInCase(targetCaseNumber, DataChess)
					if targetPawnIndex then
						local targetPawnTeam = GetTeamPawn(DataChess.listPawnIndex[targetPawnIndex].refId)
						local targetPawnName = DataChess.listPawnIndex[targetPawnIndex].name
						if targetPawnName == trad.king and targetPawnTeam ~= team and not protect then
							protect = false
						else
							protect = true
						end
					end
					if targetCaseIndex then
						if targetCaseIndex == caseIndex and not protect then
							return true --menace
						end
					end	
				end
			elseif div == 4 then
				for x = 1, 8 do
					targetCaseNumber = GetNumberCase(DataPawn.coorA - x, DataPawn.coorB + x, DataChess)
					targetCaseIndex = GetIndexCaseByNumber(targetCaseNumber, DataChess)
					targetPawnIndex = GetIndexPawnInCase(targetCaseNumber, DataChess)
					if targetPawnIndex then
						local targetPawnTeam = GetTeamPawn(DataChess.listPawnIndex[targetPawnIndex].refId)
						local targetPawnName = DataChess.listPawnIndex[targetPawnIndex].name
						if targetPawnName == trad.king and targetPawnTeam ~= team and not protect then
							protect = false
						else
							protect = true
						end
					end
					if targetCaseIndex then
						if targetCaseIndex == caseIndex and not protect then
							return true --menace
						end
					end	
				end
			end
		end
		return false
	end
	if DataPawn.name == trad.queen then
		for div = 1, 4 do
			protect = false
			if div == 1 then
				for a = 1, 8 do
					targetCaseNumber = GetNumberCase(DataPawn.coorA + a, DataPawn.coorB, DataChess)
					targetCaseIndex = GetIndexCaseByNumber(targetCaseNumber, DataChess)
					targetPawnIndex = GetIndexPawnInCase(targetCaseNumber, DataChess)
					if targetPawnIndex then
						local targetPawnTeam = GetTeamPawn(DataChess.listPawnIndex[targetPawnIndex].refId)
						local targetPawnName = DataChess.listPawnIndex[targetPawnIndex].name
						if targetPawnName == trad.king and targetPawnTeam ~= team and not protect then
							protect = false
						else
							protect = true
						end
					end
					if targetCaseIndex then
						if targetCaseIndex == caseIndex and not protect then
							return true --menace
						end
					end	
				end
			elseif div == 2 then
				for a = 1, 8 do
					targetCaseNumber = GetNumberCase(DataPawn.coorA - a, DataPawn.coorB, DataChess)
					targetCaseIndex = GetIndexCaseByNumber(targetCaseNumber, DataChess)
					targetPawnIndex = GetIndexPawnInCase(targetCaseNumber, DataChess)
					if targetPawnIndex then
						local targetPawnTeam = GetTeamPawn(DataChess.listPawnIndex[targetPawnIndex].refId)
						local targetPawnName = DataChess.listPawnIndex[targetPawnIndex].name
						if targetPawnName == trad.king and targetPawnTeam ~= team and not protect then
							protect = false
						else
							protect = true
						end
					end
					if targetCaseIndex then
						if targetCaseIndex == caseIndex and not protect then
							return true --menace
						end
					end	
				end
			elseif div == 3 then
				for b = 1, 8 do
					targetCaseNumber = GetNumberCase(DataPawn.coorA, DataPawn.coorB + b, DataChess)
					targetCaseIndex = GetIndexCaseByNumber(targetCaseNumber, DataChess)
					targetPawnIndex = GetIndexPawnInCase(targetCaseNumber, DataChess)
					if targetPawnIndex then
						local targetPawnTeam = GetTeamPawn(DataChess.listPawnIndex[targetPawnIndex].refId)
						local targetPawnName = DataChess.listPawnIndex[targetPawnIndex].name
						if targetPawnName == trad.king and targetPawnTeam ~= team and not protect then
							protect = false
						else
							protect = true
						end
					end
					if targetCaseIndex then
						if targetCaseIndex == caseIndex and not protect then
							return true --menace
						end
					end		
				end
			elseif div == 4 then
				for b = 1, 8 do
					targetCaseNumber = GetNumberCase(DataPawn.coorA, DataPawn.coorB - b, DataChess)
					targetCaseIndex = GetIndexCaseByNumber(targetCaseNumber, DataChess)
					targetPawnIndex = GetIndexPawnInCase(targetCaseNumber, DataChess)
					if targetPawnIndex then
						local targetPawnTeam = GetTeamPawn(DataChess.listPawnIndex[targetPawnIndex].refId)
						local targetPawnName = DataChess.listPawnIndex[targetPawnIndex].name
						if targetPawnName == trad.king and targetPawnTeam ~= team and not protect then
							protect = false
						else
							protect = true
						end
					end
					if targetCaseIndex then
						if targetCaseIndex == caseIndex and not protect then
							return true --menace
						end
					end	
				end
			end
		end
		for div = 1, 4 do
			protect = false
			if div == 1 then
				for x = 1, 8 do
					targetCaseNumber = GetNumberCase(DataPawn.coorA + x, DataPawn.coorB + x, DataChess)
					targetCaseIndex = GetIndexCaseByNumber(targetCaseNumber, DataChess)
					targetPawnIndex = GetIndexPawnInCase(targetCaseNumber, DataChess)
					if targetPawnIndex then
						local targetPawnTeam = GetTeamPawn(DataChess.listPawnIndex[targetPawnIndex].refId)
						local targetPawnName = DataChess.listPawnIndex[targetPawnIndex].name
						if targetPawnName == trad.king and targetPawnTeam ~= team and not protect then
							protect = false
						else
							protect = true
						end
					end
					if targetCaseIndex then
						if targetCaseIndex == caseIndex and not protect then
							return true --menace
						end
					end	
				end
			elseif div == 2 then
				for x = 1, 8 do
					targetCaseNumber = GetNumberCase(DataPawn.coorA - x, DataPawn.coorB - x, DataChess)
					targetCaseIndex = GetIndexCaseByNumber(targetCaseNumber, DataChess)
					targetPawnIndex = GetIndexPawnInCase(targetCaseNumber, DataChess)
					if targetPawnIndex then
						local targetPawnTeam = GetTeamPawn(DataChess.listPawnIndex[targetPawnIndex].refId)
						local targetPawnName = DataChess.listPawnIndex[targetPawnIndex].name
						if targetPawnName == trad.king and targetPawnTeam ~= team and not protect then
							protect = false
						else
							protect = true
						end
					end
					if targetCaseIndex then
						if targetCaseIndex == caseIndex and not protect then
							return true --menace
						end
					end	
				end
			elseif div == 3 then
				for x = 1, 8 do
					targetCaseNumber = GetNumberCase(DataPawn.coorA + x, DataPawn.coorB - x, DataChess)
					targetCaseIndex = GetIndexCaseByNumber(targetCaseNumber, DataChess)
					targetPawnIndex = GetIndexPawnInCase(targetCaseNumber, DataChess)
					if targetPawnIndex then
						local targetPawnTeam = GetTeamPawn(DataChess.listPawnIndex[targetPawnIndex].refId)
						local targetPawnName = DataChess.listPawnIndex[targetPawnIndex].name
						if targetPawnName == trad.king and targetPawnTeam ~= team and not protect then
							protect = false
						else
							protect = true
						end
					end
					if targetCaseIndex then
						if targetCaseIndex == caseIndex and not protect then
							return true --menace
						end
					end		
				end
			elseif div == 4 then
				for x = 1, 8 do
					targetCaseNumber = GetNumberCase(DataPawn.coorA - x, DataPawn.coorB + x, DataChess)
					targetCaseIndex = GetIndexCaseByNumber(targetCaseNumber, DataChess)
					targetPawnIndex = GetIndexPawnInCase(targetCaseNumber, DataChess)
					if targetPawnIndex then
						local targetPawnTeam = GetTeamPawn(DataChess.listPawnIndex[targetPawnIndex].refId)
						local targetPawnName = DataChess.listPawnIndex[targetPawnIndex].name
						if targetPawnName == trad.king and targetPawnTeam ~= team and not protect then
							protect = false
						else
							protect = true
						end
					end
					if targetCaseIndex then
						if targetCaseIndex == caseIndex and not protect then
							return true --menace
						end
					end	
				end
			end
		end		
		return false
	end	
	if DataPawn.name == trad.king then
		for div = 1, 8 do
			if div == 1 then
				targetCaseNumber = GetNumberCase(DataPawn.coorA + 1, DataPawn.coorB, DataChess)
			elseif div == 2 then
				targetCaseNumber = GetNumberCase(DataPawn.coorA + 1, DataPawn.coorB + 1, DataChess)
			elseif div == 3 then
				targetCaseNumber = GetNumberCase(DataPawn.coorA + 1, DataPawn.coorB - 1, DataChess)
			elseif div == 4 then
				targetCaseNumber = GetNumberCase(DataPawn.coorA - 1, DataPawn.coorB, DataChess)
			elseif div == 5 then
				targetCaseNumber = GetNumberCase(DataPawn.coorA - 1, DataPawn.coorB + 1, DataChess)
			elseif div == 6 then
				targetCaseNumber = GetNumberCase(DataPawn.coorA - 1, DataPawn.coorB - 1, DataChess)
			elseif div == 7 then
				targetCaseNumber = GetNumberCase(DataPawn.coorA, DataPawn.coorB + 1, DataChess)
			elseif div == 8 then
				targetCaseNumber = GetNumberCase(DataPawn.coorA, DataPawn.coorB - 1, DataChess)
			end
			targetCaseIndex = GetIndexCaseByNumber(targetCaseNumber, DataChess)
			if targetCaseIndex then
				if targetCaseIndex == caseIndex then
					return true --menace
				end
			end
		end		
	end
end
local function CheckMenaceKing(caseIndex, team, DataChess)
	for b = 1, 8 do
		for a = 1, 8 do
			local targetCaseNumber = GetNumberCase(a, b, DataChess)
			local targetCaseIndex = GetIndexCaseByNumber(targetCaseNumber, DataChess)
			local targetPawnIndex = GetIndexPawnInCase(targetCaseNumber, DataChess)
			if targetPawnIndex then
				local targetPawnRefid = DataChess.listPawnIndex[targetPawnIndex].refId
				local targetPawnTeam = GetTeamPawn(targetPawnRefid)
				if targetPawnTeam ~= team then
					local CheckMenace = GetAllValideMove(targetPawnIndex, caseIndex, DataChess)
					if CheckMenace then
						return true
					end
				end
			end
		end
	end
end
local function GetAllMate(pawnIndex, DataChess)
	local DataPawn = DataChess.listPawnIndex[pawnIndex]
	local IndexCase = GetIndexCaseByNumber(DataPawn.case, DataChess)
	local teamPawn = GetTeamPawn(DataPawn.refId)
	local targetCaseNumber
	local targetCaseIndex
	local targetPawnIndex	
	local targetPawnTeam
	if DataPawn.name == trad.pawn then
		if teamPawn == trad.white then
			for div = 1, 2 do
				if div == 1 then
					targetCaseNumber = GetNumberCase(DataPawn.coorA + 1, DataPawn.coorB + 1, DataChess)
				else
					targetCaseNumber = GetNumberCase(DataPawn.coorA - 1, DataPawn.coorB + 1, DataChess)
				end
				targetPawnIndex = GetIndexPawnInCase(targetCaseNumber, DataChess)
				targetCaseIndex = GetIndexCaseByNumber(targetCaseNumber, DataChess)
				if targetPawnIndex and DataChess.listPawnIndex[targetPawnIndex] then
					targetPawnTeam = GetTeamPawn(DataChess.listPawnIndex[targetPawnIndex].refId)
					targetPawnName = DataChess.listPawnIndex[targetPawnIndex].name
					if targetPawnTeam ~= teamPawn
					and targetPawnName == trad.king then
						return true, pawnIndex, IndexCase
					end
				end
			end
		else
			for div = 1, 2 do
				if div == 1 then
					targetCaseNumber = GetNumberCase(DataPawn.coorA + 1, DataPawn.coorB - 1, DataChess)
				else
					targetCaseNumber = GetNumberCase(DataPawn.coorA - 1, DataPawn.coorB - 1, DataChess)
				end
				targetPawnIndex = GetIndexPawnInCase(targetCaseNumber, DataChess)
				targetCaseIndex = GetIndexCaseByNumber(targetCaseNumber, DataChess)
				if targetPawnIndex and DataChess.listPawnIndex[targetPawnIndex] then
					targetPawnTeam = GetTeamPawn(DataChess.listPawnIndex[targetPawnIndex].refId)
					targetPawnName = DataChess.listPawnIndex[targetPawnIndex].name
					if targetPawnTeam ~= teamPawn
					and targetPawnName == trad.king then
						return true, pawnIndex, IndexCase
					end
				end
			end		
		end
	end
	if DataPawn.name == trad.tower then
		for div = 1, 4 do
			if div == 1 then
				for a = 1, 8 do
					targetCaseNumber = GetNumberCase(DataPawn.coorA + a, DataPawn.coorB, DataChess)
					targetPawnIndex = GetIndexPawnInCase(targetCaseNumber, DataChess)
					targetCaseIndex = GetIndexCaseByNumber(targetCaseNumber, DataChess)
					if targetPawnIndex and DataChess.listPawnIndex[targetPawnIndex] then
						targetPawnTeam = GetTeamPawn(DataChess.listPawnIndex[targetPawnIndex].refId)
						targetPawnName = DataChess.listPawnIndex[targetPawnIndex].name
						if targetPawnTeam ~= teamPawn
						and targetPawnName == trad.king then
							return true, pawnIndex, IndexCase
						else
							return false
						end
					end
				end
			elseif div == 2 then
				for a = 1, 8 do
					targetCaseNumber = GetNumberCase(DataPawn.coorA - a, DataPawn.coorB, DataChess)
					targetPawnIndex = GetIndexPawnInCase(targetCaseNumber, DataChess)
					targetCaseIndex = GetIndexCaseByNumber(targetCaseNumber, DataChess)
					if targetPawnIndex and DataChess.listPawnIndex[targetPawnIndex] then
						targetPawnTeam = GetTeamPawn(DataChess.listPawnIndex[targetPawnIndex].refId)
						targetPawnName = DataChess.listPawnIndex[targetPawnIndex].name
						if targetPawnTeam ~= teamPawn
						and targetPawnName == trad.king then
							return true, pawnIndex, IndexCase
						else
							return false
						end
					end
				end
			elseif div == 3 then
				for b = 1, 8 do
					targetCaseNumber = GetNumberCase(DataPawn.coorA, DataPawn.coorB + b, DataChess)
					targetPawnIndex = GetIndexPawnInCase(targetCaseNumber, DataChess)
					targetCaseIndex = GetIndexCaseByNumber(targetCaseNumber, DataChess)
					if targetPawnIndex and DataChess.listPawnIndex[targetPawnIndex] then
						targetPawnTeam = GetTeamPawn(DataChess.listPawnIndex[targetPawnIndex].refId)
						targetPawnName = DataChess.listPawnIndex[targetPawnIndex].name
						if targetPawnTeam ~= teamPawn
						and targetPawnName == trad.king then
							return true, pawnIndex, IndexCase
						else
							return false
						end
					end
				end
			elseif div == 4 then
				for b = 1, 8 do
					targetCaseNumber = GetNumberCase(DataPawn.coorA, DataPawn.coorB - b, DataChess)
					targetPawnIndex = GetIndexPawnInCase(targetCaseNumber, DataChess)
					targetCaseIndex = GetIndexCaseByNumber(targetCaseNumber, DataChess)
					if targetPawnIndex and DataChess.listPawnIndex[targetPawnIndex] then
						targetPawnTeam = GetTeamPawn(DataChess.listPawnIndex[targetPawnIndex].refId)
						targetPawnName = DataChess.listPawnIndex[targetPawnIndex].name
						if targetPawnTeam ~= teamPawn
						and targetPawnName == trad.king then
							return true, pawnIndex, IndexCase
						else
							return false
						end
					end
				end
			end
		end
	end
	if DataPawn.name == trad.knight then
		for div = 1, 8 do
			if div == 1 then
				targetCaseNumber = GetNumberCase(DataPawn.coorA + 2, DataPawn.coorB + 1, DataChess)	
			elseif div == 2 then
				targetCaseNumber = GetNumberCase(DataPawn.coorA + 2, DataPawn.coorB - 1, DataChess)
			elseif div == 3 then
				targetCaseNumber = GetNumberCase(DataPawn.coorA + 1, DataPawn.coorB + 2, DataChess)
			elseif div == 4 then
				targetCaseNumber = GetNumberCase(DataPawn.coorA + 1, DataPawn.coorB - 2, DataChess)
			elseif div == 5 then
				targetCaseNumber = GetNumberCase(DataPawn.coorA - 2, DataPawn.coorB + 1, DataChess)	
			elseif div == 6 then
				targetCaseNumber = GetNumberCase(DataPawn.coorA - 2, DataPawn.coorB - 1, DataChess)
			elseif div == 7 then
				targetCaseNumber = GetNumberCase(DataPawn.coorA - 1, DataPawn.coorB + 2, DataChess)
			elseif div == 8 then
				targetCaseNumber = GetNumberCase(DataPawn.coorA - 1, DataPawn.coorB - 2, DataChess)
			end
			targetPawnIndex = GetIndexPawnInCase(targetCaseNumber, DataChess)
			targetCaseIndex = GetIndexCaseByNumber(targetCaseNumber, DataChess)
			if targetPawnIndex and DataChess.listPawnIndex[targetPawnIndex] then
				targetPawnTeam = GetTeamPawn(DataChess.listPawnIndex[targetPawnIndex].refId)
				targetPawnName = DataChess.listPawnIndex[targetPawnIndex].name
				if targetPawnTeam ~= teamPawn
				and targetPawnName == trad.king then
					return true, pawnIndex, IndexCase
				end
			end
		end	
	end
	if DataPawn.name == trad.bishop then
		for div = 1, 4 do
			if div == 1 then
				for x = 1, 8 do
					targetCaseNumber = GetNumberCase(DataPawn.coorA + x, DataPawn.coorB + x, DataChess)
					targetPawnIndex = GetIndexPawnInCase(targetCaseNumber, DataChess)
					targetCaseIndex = GetIndexCaseByNumber(targetCaseNumber, DataChess)
					if targetPawnIndex and DataChess.listPawnIndex[targetPawnIndex] then
						targetPawnTeam = GetTeamPawn(DataChess.listPawnIndex[targetPawnIndex].refId)
						targetPawnName = DataChess.listPawnIndex[targetPawnIndex].name
						if targetPawnTeam ~= teamPawn
						and targetPawnName == trad.king then
							return true, pawnIndex, IndexCase
						else
							return false
						end
					end
				end
			elseif div == 2 then
				for x = 1, 8 do
					targetCaseNumber = GetNumberCase(DataPawn.coorA - x, DataPawn.coorB - x, DataChess)
					targetPawnIndex = GetIndexPawnInCase(targetCaseNumber, DataChess)
					targetCaseIndex = GetIndexCaseByNumber(targetCaseNumber, DataChess)
					if targetPawnIndex and DataChess.listPawnIndex[targetPawnIndex] then
						targetPawnTeam = GetTeamPawn(DataChess.listPawnIndex[targetPawnIndex].refId)
						targetPawnName = DataChess.listPawnIndex[targetPawnIndex].name
						if targetPawnTeam ~= teamPawn
						and targetPawnName == trad.king then
							return true, pawnIndex, IndexCase
						else
							return false
						end
					end
				end
			elseif div == 3 then
				for x = 1, 8 do
					targetCaseNumber = GetNumberCase(DataPawn.coorA + x, DataPawn.coorB - x, DataChess)
					targetPawnIndex = GetIndexPawnInCase(targetCaseNumber, DataChess)
					targetCaseIndex = GetIndexCaseByNumber(targetCaseNumber, DataChess)
					if targetPawnIndex and DataChess.listPawnIndex[targetPawnIndex] then
						targetPawnTeam = GetTeamPawn(DataChess.listPawnIndex[targetPawnIndex].refId)
						targetPawnName = DataChess.listPawnIndex[targetPawnIndex].name
						if targetPawnTeam ~= teamPawn
						and targetPawnName == trad.king then
							return true, pawnIndex, IndexCase
						else
							return false
						end
					end	
				end
			elseif div == 4 then
				for x = 1, 8 do
					targetCaseNumber = GetNumberCase(DataPawn.coorA - x, DataPawn.coorB + x, DataChess)
					targetPawnIndex = GetIndexPawnInCase(targetCaseNumber, DataChess)
					targetCaseIndex = GetIndexCaseByNumber(targetCaseNumber, DataChess)
					if targetPawnIndex and DataChess.listPawnIndex[targetPawnIndex] then
						targetPawnTeam = GetTeamPawn(DataChess.listPawnIndex[targetPawnIndex].refId)
						targetPawnName = DataChess.listPawnIndex[targetPawnIndex].name
						if targetPawnTeam ~= teamPawn
						and targetPawnName == trad.king then
							return true, pawnIndex, IndexCase
						else
							return false
						end
					end
				end
			end
		end
	end
	if DataPawn.name == trad.queen then
		local menace = 0
		local protect = 0
		for div = 1, 4 do
			if div == 1 then
				for a = 1, 8 do
					targetCaseNumber = GetNumberCase(DataPawn.coorA + a, DataPawn.coorB, DataChess)
					targetPawnIndex = GetIndexPawnInCase(targetCaseNumber, DataChess)
					targetCaseIndex = GetIndexCaseByNumber(targetCaseNumber, DataChess)
					if targetPawnIndex and DataChess.listPawnIndex[targetPawnIndex] then
						targetPawnTeam = GetTeamPawn(DataChess.listPawnIndex[targetPawnIndex].refId)
						targetPawnName = DataChess.listPawnIndex[targetPawnIndex].name
						if targetPawnTeam ~= teamPawn
						and targetPawnName == trad.king then
							menace = a
						else
							protect = a
						end
					end
					if menace > 0 then
						if protect > 0 then
							if protect > menace then
								return true, pawnIndex, IndexCase
							end
						else
							return true, pawnIndex, IndexCase
						end
					end
				end
				menace = 0
				protect = 0		
			elseif div == 2 then
				for a = 1, 8 do
					targetCaseNumber = GetNumberCase(DataPawn.coorA - a, DataPawn.coorB, DataChess)
					targetPawnIndex = GetIndexPawnInCase(targetCaseNumber, DataChess)
					targetCaseIndex = GetIndexCaseByNumber(targetCaseNumber, DataChess)
					if targetPawnIndex and DataChess.listPawnIndex[targetPawnIndex] then
						targetPawnTeam = GetTeamPawn(DataChess.listPawnIndex[targetPawnIndex].refId)
						targetPawnName = DataChess.listPawnIndex[targetPawnIndex].name
						if targetPawnTeam ~= teamPawn
						and targetPawnName == trad.king then
							menace = a
						else
							protect = a
						end
					end
					if menace > 0 then
						if protect > 0 then
							if protect > menace then
								return true, pawnIndex, IndexCase
							end
						else
							return true, pawnIndex, IndexCase
						end
					end
				end
				menace = 0
				protect = 0	
			elseif div == 3 then
				for b = 1, 8 do
					targetCaseNumber = GetNumberCase(DataPawn.coorA, DataPawn.coorB + b, DataChess)
					targetPawnIndex = GetIndexPawnInCase(targetCaseNumber, DataChess)
					targetCaseIndex = GetIndexCaseByNumber(targetCaseNumber, DataChess)
					if targetPawnIndex and DataChess.listPawnIndex[targetPawnIndex] then
						targetPawnTeam = GetTeamPawn(DataChess.listPawnIndex[targetPawnIndex].refId)
						targetPawnName = DataChess.listPawnIndex[targetPawnIndex].name
						if targetPawnTeam ~= teamPawn
						and targetPawnName == trad.king then
							menace = b
						else
							protect = b
						end
					end
					if menace > 0 then
						if protect > 0 then
							if protect > menace then
								return true, pawnIndex, IndexCase
							end
						else
							return true, pawnIndex, IndexCase
						end
					end
				end
				menace = 0
				protect = 0	
			elseif div == 4 then
				for b = 1, 8 do
					targetCaseNumber = GetNumberCase(DataPawn.coorA, DataPawn.coorB - b, DataChess)
					targetPawnIndex = GetIndexPawnInCase(targetCaseNumber, DataChess)
					targetCaseIndex = GetIndexCaseByNumber(targetCaseNumber, DataChess)
					if targetPawnIndex and DataChess.listPawnIndex[targetPawnIndex] then
						targetPawnTeam = GetTeamPawn(DataChess.listPawnIndex[targetPawnIndex].refId)
						targetPawnName = DataChess.listPawnIndex[targetPawnIndex].name
						if targetPawnTeam ~= teamPawn
						and targetPawnName == trad.king then
							menace = b
						else
							protect = b
						end
					end
					if menace > 0 then
						if protect > 0 then
							if protect > menace then
								return true, pawnIndex, IndexCase
							end
						else
							return true, pawnIndex, IndexCase
						end
					end
				end
				menace = 0
				protect = 0	
			end
		end
		for div = 1, 4 do
			if div == 1 then
				for x = 1, 8 do
					targetCaseNumber = GetNumberCase(DataPawn.coorA + x, DataPawn.coorB + x, DataChess)
					targetPawnIndex = GetIndexPawnInCase(targetCaseNumber, DataChess)
					targetCaseIndex = GetIndexCaseByNumber(targetCaseNumber, DataChess)
					if targetPawnIndex and DataChess.listPawnIndex[targetPawnIndex] then
						targetPawnTeam = GetTeamPawn(DataChess.listPawnIndex[targetPawnIndex].refId)
						targetPawnName = DataChess.listPawnIndex[targetPawnIndex].name
						if targetPawnTeam ~= teamPawn
						and targetPawnName == trad.king then
							menace = x
						else
							protect = x
						end
					end
					if menace > 0 then
						if protect > 0 then
							if protect > menace then
								return true, pawnIndex, IndexCase
							end
						else
							return true, pawnIndex, IndexCase
						end
					end
				end
				menace = 0
				protect = 0	
			elseif div == 2 then
				for x = 1, 8 do
					targetCaseNumber = GetNumberCase(DataPawn.coorA - x, DataPawn.coorB - x, DataChess)
					targetPawnIndex = GetIndexPawnInCase(targetCaseNumber, DataChess)
					targetCaseIndex = GetIndexCaseByNumber(targetCaseNumber, DataChess)
					if targetPawnIndex and DataChess.listPawnIndex[targetPawnIndex] then
						targetPawnTeam = GetTeamPawn(DataChess.listPawnIndex[targetPawnIndex].refId)
						targetPawnName = DataChess.listPawnIndex[targetPawnIndex].name
						if targetPawnTeam ~= teamPawn
						and targetPawnName == trad.king then
							menace = x
						else
							protect = x
						end
					end
					if menace > 0 then
						if protect > 0 then
							if protect > menace then
								return true, pawnIndex, IndexCase
							end
						else
							return true, pawnIndex, IndexCase
						end
					end
				end
				menace = 0
				protect = 0	
			elseif div == 3 then
				for x = 1, 8 do
					targetCaseNumber = GetNumberCase(DataPawn.coorA + x, DataPawn.coorB - x, DataChess)
					targetPawnIndex = GetIndexPawnInCase(targetCaseNumber, DataChess)
					targetCaseIndex = GetIndexCaseByNumber(targetCaseNumber, DataChess)
					if targetPawnIndex and DataChess.listPawnIndex[targetPawnIndex] then
						targetPawnTeam = GetTeamPawn(DataChess.listPawnIndex[targetPawnIndex].refId)
						targetPawnName = DataChess.listPawnIndex[targetPawnIndex].name
						if targetPawnTeam ~= teamPawn
						and targetPawnName == trad.king then
							menace = x
						else
							protect = x
						end
					end
					if menace > 0 then
						if protect > 0 then
							if protect > menace then
								return true, pawnIndex, IndexCase
							end
						else
							return true, pawnIndex, IndexCase
						end
					end
				end
				menace = 0
				protect = 0	
			elseif div == 4 then
				for x = 1, 8 do
					targetCaseNumber = GetNumberCase(DataPawn.coorA - x, DataPawn.coorB + x, DataChess)
					targetPawnIndex = GetIndexPawnInCase(targetCaseNumber, DataChess)
					targetCaseIndex = GetIndexCaseByNumber(targetCaseNumber, DataChess)
					if targetPawnIndex and DataChess.listPawnIndex[targetPawnIndex] then
						targetPawnTeam = GetTeamPawn(DataChess.listPawnIndex[targetPawnIndex].refId)
						targetPawnName = DataChess.listPawnIndex[targetPawnIndex].name
						if targetPawnTeam ~= teamPawn
						and targetPawnName == trad.king then
							menace = x
						else
							protect = x
						end
					end
					if menace > 0 then
						if protect > 0 then
							if protect > menace then
								return true, pawnIndex, IndexCase
							end
						else
							return true, pawnIndex, IndexCase
						end
					end
				end
				menace = 0
				protect = 0	
			end
		end		
		return false		
	end	
	if DataPawn.name == trad.king then
		for div = 1, 8 do
			if div == 1 then
				targetCaseNumber = GetNumberCase(DataPawn.coorA + 1, DataPawn.coorB, DataChess)
			elseif div == 2 then
				targetCaseNumber = GetNumberCase(DataPawn.coorA + 1, DataPawn.coorB + 1, DataChess)
			elseif div == 3 then
				targetCaseNumber = GetNumberCase(DataPawn.coorA + 1, DataPawn.coorB - 1, DataChess)
			elseif div == 4 then
				targetCaseNumber = GetNumberCase(DataPawn.coorA - 1, DataPawn.coorB, DataChess)
			elseif div == 5 then
				targetCaseNumber = GetNumberCase(DataPawn.coorA - 1, DataPawn.coorB + 1, DataChess)
			elseif div == 6 then
				targetCaseNumber = GetNumberCase(DataPawn.coorA - 1, DataPawn.coorB - 1, DataChess)
			elseif div == 7 then
				targetCaseNumber = GetNumberCase(DataPawn.coorA, DataPawn.coorB + 1, DataChess)
			elseif div == 8 then
				targetCaseNumber = GetNumberCase(DataPawn.coorA, DataPawn.coorB - 1, DataChess)
			end
			targetPawnIndex = GetIndexPawnInCase(targetCaseNumber, DataChess)
			targetCaseIndex = GetIndexCaseByNumber(targetCaseNumber, DataChess)
			if targetPawnIndex and DataChess.listPawnIndex[targetPawnIndex] then
				targetPawnTeam = GetTeamPawn(DataChess.listPawnIndex[targetPawnIndex].refId)
				targetPawnName = DataChess.listPawnIndex[targetPawnIndex].name
				if targetPawnTeam ~= teamPawn
				and targetPawnName == trad.king then
					return true, pawnIndex, IndexCase
				end
			end
		end		
	end
end
local function CheckMate(team, DataChess)
	for b = 1, 8 do
		for a = 1, 8 do
			local targetCaseNumber = GetNumberCase(a, b, DataChess)
			local targetIndexPawn = GetIndexPawnInCase(targetCaseNumber, DataChess)
			local targetCaseIndex = GetIndexCaseByNumber(targetCaseNumber, DataChess)
			if targetIndexPawn and DataChess.listPawnIndex[targetIndexPawn] then
				local targetPawnTeam = GetTeamPawn(DataChess.listPawnIndex[targetIndexPawn].refId)
				if targetPawnTeam == team then
					local Mate, targetPawnIndexMate, targetCaseIndexMate = GetAllMate(targetIndexPawn, DataChess)
					if Mate then
						return true, targetPawnIndexMate, targetCaseIndexMate
					end
				end
			end
		end
	end
end
local function CastlingMove(pid, kingIndex, towerIndex, DataChess)
	local TryCastlingBig = false
	local TryCastlingLite = false
	local caseIndexKing = GetIndexCaseByNumber(DataChess.listPawnIndex[kingIndex].case, DataChess) 
	local team = GetTeamPawn(DataChess.listPawnIndex[kingIndex].refId)
	local targetTeam
	local CastlingBig
	local CastlingLite
	local newPosKing = {}
	local newPosTower = {}
	if CheckMenaceKing(caseIndexKing, team, DataChess) then
		return false, "MENACE KING"..DataChess.listPawnIndex[kingIndex].case
	end
	if DataChess.listPawnIndex[kingIndex].original and DataChess.listPawnIndex[towerIndex].original then
		if team == trad.white then
			CastlingBig = {
				A = 1,
				B = 1
			}
			CastlingLite = {
				A = 8,
				B = 1
			}
			targetTeam = trad.red
		else
			CastlingBig = {
				A = 1,
				B = 8
			}
			CastlingLite = {
				A = 8,
				B = 8
			}
			targetTeam = trad.white
		end
		if DataChess.listPawnIndex[towerIndex].coorA == CastlingBig.A and DataChess.listPawnIndex[towerIndex].coorB == CastlingBig.B then
			TryCastlingBig = true
		elseif DataChess.listPawnIndex[towerIndex].coorA == CastlingLite.A and DataChess.listPawnIndex[towerIndex].coorB == CastlingLite.B then
			TryCastlingLite = true
		end
	end
	local listSendPacketMove = {}
	if TryCastlingBig then
		for a = 1, 3 do
			if GetCaseIsEmpty(DataChess.listPawnIndex[kingIndex].coorA - a, DataChess.listPawnIndex[kingIndex].coorB, DataChess) then
				local targetCaseNumber = GetNumberCase(DataChess.listPawnIndex[kingIndex].coorA - a, DataChess.listPawnIndex[kingIndex].coorB, DataChess)
				local targetCaseIndex = GetIndexCaseByNumber(targetCaseNumber, DataChess)
				if CheckMenaceKing(targetCaseIndex, team, DataChess) then
					return false, "MENACE KING"..targetCaseNumber
				end
			else
				return false, "NO EMPTY CASE A = "..DataChess.listPawnIndex[kingIndex].coorA - a
			end
		end
		for a = 1, 3 do	
			local targetCaseNumber = GetNumberCase(DataChess.listPawnIndex[kingIndex].coorA - a, DataChess.listPawnIndex[kingIndex].coorB, DataChess)
			local targetCaseIndex = GetIndexCaseByNumber(targetCaseNumber, DataChess)
			if a == 1 then
				DataChess.listPawnIndex[towerIndex].coorA = DataChess.listPawnIndex[kingIndex].coorA - a
				DataChess.listPawnIndex[towerIndex].case = targetCaseNumber					
				newPosTower = DataChess.listCaseIndex[targetCaseIndex].pos
				newPosTower.posZ = newPosTower.posZ + DataChess.listPawnIndex[towerIndex].posZ
				local PawnObject = GetObject(DataChess.cellDescription, towerIndex)
				PawnObject.location = newPosTower
				DataChess.listPawnIndex[towerIndex].location = newPosTower
				table.insert(listSendPacketMove, towerIndex)	
			elseif a == 2 then
				DataChess.listPawnIndex[kingIndex].coorA = DataChess.listPawnIndex[kingIndex].coorA - a
				DataChess.listPawnIndex[kingIndex].case = targetCaseNumber	
				newPosKing = DataChess.listCaseIndex[targetCaseIndex].pos
				newPosKing.posZ = newPosKing.posZ + DataChess.listPawnIndex[kingIndex].posZ
				local PawnObject = GetObject(DataChess.cellDescription, kingIndex)
				PawnObject.location = newPosKing
				DataChess.listPawnIndex[kingIndex].location = newPosKing
				table.insert(listSendPacketMove, kingIndex)
			end
		end
	elseif TryCastlingLite then
		for a = 1, 2 do
			if GetCaseIsEmpty(DataChess.listPawnIndex[kingIndex].coorA + a, DataChess.listPawnIndex[kingIndex].coorB, DataChess) then
				local targetCaseNumber = GetNumberCase(DataChess.listPawnIndex[kingIndex].coorA + a, DataChess.listPawnIndex[kingIndex].coorB, DataChess)
				local targetCaseIndex = GetIndexCaseByNumber(targetCaseNumber, DataChess)
				if CheckMenaceKing(targetCaseIndex, team, DataChess) then
					return false, "MENACE KING"..targetCaseNumber
				end
			else
				return false, "NO EMPTY CASE A = "..DataChess.listPawnIndex[kingIndex].coorA + a
			end
		end
		for a = 1, 2 do
			local targetCaseNumber = GetNumberCase(DataChess.listPawnIndex[kingIndex].coorA + a, DataChess.listPawnIndex[kingIndex].coorB, DataChess)
			local targetCaseIndex = GetIndexCaseByNumber(targetCaseNumber, DataChess)
			if a == 1 then
				DataChess.listPawnIndex[towerIndex].coorA = DataChess.listPawnIndex[kingIndex].coorA + a
				DataChess.listPawnIndex[towerIndex].case = targetCaseNumber					
				newPosTower = DataChess.listCaseIndex[targetCaseIndex].pos
				newPosTower.posZ = newPosTower.posZ + DataChess.listPawnIndex[towerIndex].posZ
				local PawnObject = GetObject(DataChess.cellDescription, towerIndex)
				PawnObject.location = newPosTower
				DataChess.listPawnIndex[towerIndex].location = newPosTower
				table.insert(listSendPacketMove, towerIndex)	
			elseif a == 2 then
				DataChess.listPawnIndex[kingIndex].coorA = DataChess.listPawnIndex[kingIndex].coorA + a
				DataChess.listPawnIndex[kingIndex].case = targetCaseNumber	
				newPosKing = DataChess.listCaseIndex[targetCaseIndex].pos
				newPosKing.posZ = newPosKing.posZ + DataChess.listPawnIndex[kingIndex].posZ
				local PawnObject = GetObject(DataChess.cellDescription, kingIndex)
				PawnObject.location = newPosKing
				DataChess.listPawnIndex[kingIndex].location = newPosKing
				table.insert(listSendPacketMove, kingIndex)
			end
		end
	else
		return false, "NO TRY CASTLING"
	end
	DataChess.listPawnIndex[kingIndex].original	= false
	DataChess.listPawnIndex[towerIndex].original = false
	DataChess.turn = targetTeam
	SendMove(pid, DataChess.cellDescription, listSendPacketMove, true)
	SaveData()
	return true
end
local function ValideCaseMove(caseIndex, pawnIndex, DataChess)
	local DataCase = DataChess.listCaseIndex[caseIndex]
	local DataPawn = DataChess.listPawnIndex[pawnIndex]
	local PawnRefId = DataPawn.refId
	local team = GetTeamPawn(PawnRefId)
	local targetTeam
	if team == trad.white then
		targetTeam = trad.red
	else
		targetTeam = trad.white
	end
	local targetIndexPawnCase = GetIndexPawnInCase(DataCase.case, DataChess)
	if targetIndexPawnCase then
		local targetTeamPawn = GetTeamPawn(DataChess.listPawnIndex[targetIndexPawnCase].refId)	
		if targetTeamPawn == team then
			return false, trad.sameTeam
		end
		if targetIndexPawnCase == pawnIndex then
			return false, trad.samePawn
		end
	end
	if DataPawn.name == trad.pawn then
		local originalPosB
		local ecartA = 0
		local ecartB = 0
		if team == trad.white then
			originalPosB = 2
			if DataCase.coorA > DataPawn.coorA then
				ecartA = DataCase.coorA - DataPawn.coorA
			elseif DataCase.coorA < DataPawn.coorA then
				ecartA = DataPawn.coorA - DataCase.coorA 
			end
			if DataCase.coorB > DataPawn.coorB then
				ecartB = DataCase.coorB - DataPawn.coorB
			elseif DataCase.coorB < DataPawn.coorB then
				return false, trad.moveRule
			end
			if ecartA == 0 and ecartB == 1 then
				if targetIndexPawnCase then
					return false
				else
					return true
				end
			elseif ecartA == 1 and ecartB == 1 then
				if targetIndexPawnCase then
					return true, targetIndexPawnCase
				else
					return false, trad.moveRule
				end
			elseif DataPawn.coorB == originalPosB and ecartA == 0 and ecartB == 2 then
				if targetIndexPawnCase then
					return false, trad.moveRule
				end 
				local targetCaseNumber =  GetNumberCase(DataCase.coorA, DataCase.coorB - 1, DataChess)
				local targetIndexPawn = GetIndexPawnInCase(targetCaseNumber, DataChess)
				if targetIndexPawn then
					return false, trad.moveRule
				end
				return true
			else
				return false, trad.moveRule
			end		
		else
			originalPosB = 7
			if DataCase.coorA > DataPawn.coorA then
				ecartA = DataCase.coorA - DataPawn.coorA
			elseif DataCase.coorA < DataPawn.coorA then
				ecartA = DataPawn.coorA - DataCase.coorA 
			end
			if DataCase.coorB > DataPawn.coorB then
				return false, trad.moveRule
			elseif DataCase.coorB < DataPawn.coorB then
				ecartB = DataPawn.coorB - DataCase.coorB
			end
			if ecartA == 0 and ecartB == 1 then
				if targetIndexPawnCase then
					return false, trad.moveRule
				else
					return true
				end
			elseif ecartA == 1 and ecartB == 1 then
				if targetIndexPawnCase then
					return true, targetIndexPawnCase
				else
					return false, trad.moveRule
				end
			elseif DataPawn.coorB == originalPosB and ecartA == 0 and ecartB == 2 then
				if targetIndexPawnCase then
					return false, trad.moveRule
				end 
				local targetCaseNumber =  GetNumberCase(DataCase.coorA, DataCase.coorB + 1, DataChess)
				local targetIndexPawn = GetIndexPawnInCase(targetCaseNumber, DataChess)
				if targetIndexPawn then
					return false, trad.moveRule
				end
				return true
			else
				return false, trad.moveRule
			end		
		end
		return false
	end
	if DataPawn.name == trad.tower then
		if DataCase.coorA ~= DataPawn.coorA and DataCase.coorB ~= DataPawn.coorB then
			return false, trad.moveRule
		elseif DataCase.coorA ~= DataPawn.coorA and DataCase.coorB == DataPawn.coorB then
			if DataCase.coorA > DataPawn.coorA then
				local ecart = DataCase.coorA - DataPawn.coorA
				for x = 1, ecart do
					local targetCaseNumber = GetNumberCase(DataPawn.coorA + x, DataPawn.coorB, DataChess)
					local targetPawnIndex = GetIndexPawnInCase(targetCaseNumber, DataChess)
					local targetCaseIndex = GetIndexCaseByNumber(targetCaseNumber, DataChess)
					if targetPawnIndex then
						if GetTeamPawn(DataChess.listPawnIndex[targetPawnIndex].refId) == team then
							return false, trad.sameTeamRoute
						else
							return true, targetPawnIndex, targetCaseIndex
						end
					end
				end
			elseif DataCase.coorA < DataPawn.coorA then
				local ecart = DataPawn.coorA - DataCase.coorA
				for x = 1, ecart do
					local targetCaseNumber = GetNumberCase(DataPawn.coorA - x, DataPawn.coorB, DataChess)
					local targetPawnIndex = GetIndexPawnInCase(targetCaseNumber, DataChess)
					local targetCaseIndex = GetIndexCaseByNumber(targetCaseNumber, DataChess)
					if targetPawnIndex then
						if GetTeamPawn(DataChess.listPawnIndex[targetPawnIndex].refId) == team then
							return false, trad.sameTeamRoute
						else
							return true, targetPawnIndex, targetCaseIndex
						end
					end
				end
			end
			return true
		elseif DataCase.coorA == DataPawn.coorA and DataCase.coorB ~= DataPawn.coorB then
			if DataCase.coorB > DataPawn.coorB then
				local ecart = DataCase.coorB - DataPawn.coorB
				for x = 1, ecart do
					local targetCaseNumber = GetNumberCase(DataPawn.coorA, DataPawn.coorB + x, DataChess)
					local targetPawnIndex = GetIndexPawnInCase(targetCaseNumber, DataChess)
					local targetCaseIndex = GetIndexCaseByNumber(targetCaseNumber, DataChess)
					if targetPawnIndex then
						if GetTeamPawn(DataChess.listPawnIndex[targetPawnIndex].refId) == team then
							return false, trad.sameTeamRoute
						else
							return true, targetPawnIndex, targetCaseIndex
						end
					end
				end
			elseif DataCase.coorB < DataPawn.coorB then
				local ecart = DataPawn.coorB - DataCase.coorB
				for x = 1, ecart do
					local targetCaseNumber = GetNumberCase(DataPawn.coorA, DataPawn.coorB - x, DataChess)
					local targetPawnIndex = GetIndexPawnInCase(targetCaseNumber, DataChess)
					local targetCaseIndex = GetIndexCaseByNumber(targetCaseNumber, DataChess)
					if targetPawnIndex then
						if GetTeamPawn(DataChess.listPawnIndex[targetPawnIndex].refId) == team then
							return false, trad.sameTeamRoute
						else
							return true, targetPawnIndex, targetCaseIndex
						end
					end
				end
			end
			return true
		end
	end
	if DataPawn.name == trad.knight then
		local ecartA = 0
		local ecartB = 0
		if DataCase.coorA > DataPawn.coorA then
			ecartA = DataCase.coorA - DataPawn.coorA
		elseif DataCase.coorA < DataPawn.coorA then
			ecartA = DataPawn.coorA - DataCase.coorA 
		end
		if DataCase.coorB > DataPawn.coorB then
			ecartB = DataCase.coorB - DataPawn.coorB
		elseif DataCase.coorB < DataPawn.coorB then
			ecartB = DataPawn.coorB - DataCase.coorB 
		end
		if ecartA == 1 and ecartB == 2
		or ecartA == 2 and ecartB == 1 then
			return true, targetIndexPawnCase
		else
			return false, trad.moveRule
		end
	end
	if DataPawn.name == trad.bishop then
		local ecartA = 0
		local ecartB = 0
		local denoA
		local denoB
		if DataCase.coorA > DataPawn.coorA then
			ecartA = DataCase.coorA - DataPawn.coorA
			denoA = "positive"
		elseif DataCase.coorA < DataPawn.coorA then
			ecartA = DataPawn.coorA - DataCase.coorA 
			denoA = "negative"	
		end
		if DataCase.coorB > DataPawn.coorB then
			ecartB = DataCase.coorB - DataPawn.coorB
			denoB = "positive"
		elseif DataCase.coorB < DataPawn.coorB then
			ecartB = DataPawn.coorB - DataCase.coorB 
			denoB = "negative"
		end
		if ecartA == ecartB then
			local targetPawnIndex 
			local targetCaseIndex
			for x = 1, ecartA do
				local targetCaseNumber
				if denoA == "positive" and denoB == "positive" then
					targetCaseNumber = GetNumberCase(DataPawn.coorA + x, DataPawn.coorB + x, DataChess)
				elseif denoA == "negative" and denoB == "positive" then
					targetCaseNumber = GetNumberCase(DataPawn.coorA - x, DataPawn.coorB + x, DataChess)
				elseif denoA == "negative" and denoB == "negative" then
					targetCaseNumber = GetNumberCase(DataPawn.coorA - x, DataPawn.coorB - x, DataChess)
				elseif denoA == "positive" and denoB == "negative" then
					targetCaseNumber = GetNumberCase(DataPawn.coorA + x, DataPawn.coorB - x, DataChess)
				end
				targetPawnIndex = GetIndexPawnInCase(targetCaseNumber, DataChess)
				targetCaseIndex = GetIndexCaseByNumber(targetCaseNumber, DataChess)
				if targetPawnIndex then
					if GetTeamPawn(DataChess.listPawnIndex[targetPawnIndex].refId) == team then
						return false, trad.sameTeamRoute
					else
						return true, targetPawnIndex, targetCaseIndex
					end
				end
			end	
			if targetPawnIndex then
				return true, targetPawnIndex, targetCaseIndex
			else
				return true, targetIndexPawnCase
			end
		else
			return false, trad.moveRule
		end
	end
	if DataPawn.name == trad.queen then
		local ecartA = 0
		local ecartB = 0
		local denoA
		local denoB
		if DataCase.coorA > DataPawn.coorA then
			ecartA = DataCase.coorA - DataPawn.coorA
			denoA = "positive"
		elseif DataCase.coorA < DataPawn.coorA then
			ecartA = DataPawn.coorA - DataCase.coorA 
			denoA = "negative"	
		end
		if DataCase.coorB > DataPawn.coorB then
			ecartB = DataCase.coorB - DataPawn.coorB
			denoB = "positive"
		elseif DataCase.coorB < DataPawn.coorB then
			ecartB = DataPawn.coorB - DataCase.coorB 
			denoB = "negative"
		end
		if ecartA == ecartB then
			local targetPawnIndex 
			local targetCaseIndex
			for x = 1, ecartA do
				local targetCaseNumber
				if denoA == "positive" and denoB == "positive" then
					targetCaseNumber = GetNumberCase(DataPawn.coorA + x, DataPawn.coorB + x, DataChess)
				elseif denoA == "negative" and denoB == "positive" then
					targetCaseNumber = GetNumberCase(DataPawn.coorA - x, DataPawn.coorB + x, DataChess)
				elseif denoA == "negative" and denoB == "negative" then
					targetCaseNumber = GetNumberCase(DataPawn.coorA - x, DataPawn.coorB - x, DataChess)
				elseif denoA == "positive" and denoB == "negative" then
					targetCaseNumber = GetNumberCase(DataPawn.coorA + x, DataPawn.coorB - x, DataChess)
				end
				targetPawnIndex = GetIndexPawnInCase(targetCaseNumber, DataChess)
				targetCaseIndex = GetIndexCaseByNumber(targetCaseNumber, DataChess)
				if targetPawnIndex then
					if GetTeamPawn(DataChess.listPawnIndex[targetPawnIndex].refId) == team then
						return false, trad.sameTeamRoute
					else
						return true, targetPawnIndex, targetCaseIndex	
					end
				end
			end	
			if targetPawnIndex then
				return true, targetPawnIndex, targetCaseIndex
			else
				return true, targetIndexPawnCase
			end
		elseif DataCase.coorA ~= DataPawn.coorA and DataCase.coorB == DataPawn.coorB then
			if DataCase.coorA > DataPawn.coorA then
				local ecart = DataCase.coorA - DataPawn.coorA
				for x = 1, ecart do
					local targetCaseNumber = GetNumberCase(DataPawn.coorA + x, DataPawn.coorB, DataChess)
					local targetPawnIndex = GetIndexPawnInCase(targetCaseNumber, DataChess)
					local targetCaseIndex = GetIndexCaseByNumber(targetCaseNumber, DataChess)
					if targetPawnIndex then
						if GetTeamPawn(DataChess.listPawnIndex[targetPawnIndex].refId) == team then
							return false, trad.sameTeamRoute
						else
							return true, targetPawnIndex, targetCaseIndex
						end
					end
				end
			elseif DataCase.coorA < DataPawn.coorA then
				local ecart = DataPawn.coorA - DataCase.coorA
				for x = 1, ecart do
					local targetCaseNumber = GetNumberCase(DataPawn.coorA - x, DataPawn.coorB, DataChess)
					local targetPawnIndex = GetIndexPawnInCase(targetCaseNumber, DataChess)
					local targetCaseIndex = GetIndexCaseByNumber(targetCaseNumber, DataChess)
					if targetPawnIndex then
						if GetTeamPawn(DataChess.listPawnIndex[targetPawnIndex].refId) == team then
							return false, trad.sameTeamRoute
						else
							return true, targetPawnIndex, targetCaseIndex
						end
					end
				end
			end
			return true, targetIndexPawnCase
		elseif DataCase.coorA == DataPawn.coorA and DataCase.coorB ~= DataPawn.coorB then
			if DataCase.coorB > DataPawn.coorB then
				local ecart = DataCase.coorB - DataPawn.coorB
				for x = 1, ecart do
					local targetCaseNumber = GetNumberCase(DataPawn.coorA, DataPawn.coorB + x, DataChess)
					local targetPawnIndex = GetIndexPawnInCase(targetCaseNumber, DataChess)
					local targetCaseIndex = GetIndexCaseByNumber(targetCaseNumber, DataChess)
					if targetPawnIndex then
						if GetTeamPawn(DataChess.listPawnIndex[targetPawnIndex].refId) == team then
							return false, trad.sameTeamRoute
						else
							return true, targetPawnIndex, targetCaseIndex
						end
					end
				end
			elseif DataCase.coorB < DataPawn.coorB then
				local ecart = DataPawn.coorB - DataCase.coorB
				for x = 1, ecart do
					local targetCaseNumber = GetNumberCase(DataPawn.coorA, DataPawn.coorB - x, DataChess)
					local targetPawnIndex = GetIndexPawnInCase(targetCaseNumber, DataChess)
					local targetCaseIndex = GetIndexCaseByNumber(targetCaseNumber, DataChess)
					if targetPawnIndex then
						if GetTeamPawn(DataChess.listPawnIndex[targetPawnIndex].refId) == team then
							return false, trad.sameTeamRoute
						else
							return true, targetPawnIndex, targetCaseIndex
						end
					end
				end
			end
			return true, targetIndexPawnCase
		else
			return false, trad.moveRule
		end
	end
	if DataPawn.name == trad.king then
		local ecartA = 0
		local ecartB = 0
		local denoA
		local denoB
		if DataCase.coorA > DataPawn.coorA then
			ecartA = DataCase.coorA - DataPawn.coorA
		elseif DataCase.coorA < DataPawn.coorA then
			ecartA = DataPawn.coorA - DataCase.coorA 	
		end
		if DataCase.coorB > DataPawn.coorB then
			ecartB = DataCase.coorB - DataPawn.coorB
		elseif DataCase.coorB < DataPawn.coorB then
			ecartB = DataPawn.coorB - DataCase.coorB 
		end	
		if ecartA > 1 or ecartB > 1 then
			return false, trad.moveRule
		end
		if not CheckMenaceKing(caseIndex, team, DataChess) then
			return true, targetIndexPawnCase
		else
			return false, trad.checkKing
		end
	end
end
local function RestartGame(pidWinner, pidLooser, DataChess)
	local listSendPacketMove = {}
	local listSendPacketCreate = {}
	local listOriginalCase = {}
	local cellDescription = DataChess.cellDescription
	local pid
	if pidWinner then pid = pidWinner end
	if pidLooser then pid = pidLooser end
	for pawnIndex, data in pairs(DataChess.listPawnIndex) do
		local targetCaseNumber = GetOriginalCase(data.refId, listOriginalCase)
		local targetCaseIndex = GetIndexCaseByNumber(targetCaseNumber, DataChess)
		local targetCasePos = DataChess.listCaseIndex[targetCaseIndex].pos
		cellDescription = data.cellDescription
		if data.case ~= targetCaseNumber then
			local PawnObject = GetObject(cellDescription, pawnIndex)
			PawnObject.location = {
				posX = targetCasePos.posX,
				posY = targetCasePos.posY,
				posZ = targetCasePos.posZ + data.posZ,
				rotX = targetCasePos.rotX,
				rotY = targetCasePos.rotY,
				rotZ = targetCasePos.rotZ + data.rotZ
			}
			DataChess.listPawnIndex[pawnIndex] = {
				refId = data.refId,
				name = data.name,
				posZ = data.posZ,
				rotZ = data.rotZ,
				case = targetCaseNumber,
				scale = data.scale,
				coorA = DataChess.listCaseIndex[targetCaseIndex].coorA,
				coorB = DataChess.listCaseIndex[targetCaseIndex].coorB,
				cellDescription = cellDescription,
				original = true,
				location = PawnObject.location
			}
			table.insert(listSendPacketMove, pawnIndex)
		end
		listOriginalCase[targetCaseNumber] = true		
	end
	SendMove(pid, cellDescription, listSendPacketMove, true)
	for caseNumber, data in pairs(listPawnCase) do
		local targetCaseIndex = GetIndexCaseByNumber(caseNumber, DataChess)
		if not listOriginalCase[caseNumber] and GetCaseIsEmpty(DataChess.listCaseIndex[targetCaseIndex].coorA, DataChess.listCaseIndex[targetCaseIndex].coorB, DataChess) then
			local targetCasePos = DataChess.listCaseIndex[targetCaseIndex].pos	
			local newPos = {
				posX = targetCasePos.posX,
				posY = targetCasePos.posY,
				posZ = targetCasePos.posZ + data.posZ,
				rotX = 0,
				rotY = 0,
				rotZ = data.rotZ
			}
			local PawnUniqueIndex = CreateObjectAtLocation(cellDescription, newPos, data.refId, (data.scale * (cfg.scale / 1.5)))
			table.insert(listSendPacketCreate, PawnUniqueIndex)
			DataChess.listPawnIndex[PawnUniqueIndex] = {
				refId = data.refId,
				name = data.name,
				posZ = data.posZ,
				rotZ = data.rotZ,
				case = caseNumber,
				scale = data.scale,
				coorA = DataChess.listCaseIndex[targetCaseIndex].coorA,
				coorB = DataChess.listCaseIndex[targetCaseIndex].coorB,
				cellDescription = cellDescription,
				original = true
			}	
			listOriginalCase[caseNumber] = true
		end
	end
	SendPacket(pid, cellDescription, listSendPacketCreate)
	if DataChess.mode ~= trad.tournament then
		DataChess.turn = trad.white
		DataChess.mode = false
		DataChess.registerPrice = false
		DataChess.cfgRound = false
		DataChess.scoreWhite = 0
		DataChess.scoreRed = 0		
		DataChess.listPlayers = {}
	else
		local EndTournament = false
		if DataChess.scoreWhite >= DataChess.cfgRound then
			EndTournament = true
		elseif DataChess.scoreRed >= DataChess.cfgRound then
			EndTournament = true
		end
		if EndTournament then
			RewardEndGame(pidWinner, DataChess)
			DataChess.turn = trad.white
			DataChess.mode = false
			DataChess.registerPrice = false
			DataChess.cfgRound = false
			DataChess.scoreWhite = 0
			DataChess.scoreRed = 0	
			DataChess.listPlayers = {}
		end
	end
end
local function EndGameMate(winnerTeam, looserTeam, DataChess)
	if winnerTeam == trad.white then
		DataChess.scoreWhite = DataChess.scoreWhite + 1
	else
		DataChess.scoreRed = DataChess.scoreRed + 1
	end
	local winnerName = GetPlayerNameTeam(winnerTeam, DataChess)
	local looserName = GetPlayerNameTeam(looserTeam, DataChess)
	local playerWinner = GetPlayerByName(winnerName)
	local playerLooser = GetPlayerByName(looserName)
	local pidWinner
	local pidLooser
	local cellDescription
	if playerWinner and playerWinner.pid and Players[playerWinner.pid]:IsLoggedIn() then
		pidWinner = playerWinner.pid
		cellDescription = DataChess.listPlayers[winnerName].cellDescription
		tes3mp.MessageBox(pidWinner, -1, trad.congrat)
	end
	if playerLooser and playerLooser.pid and Players[playerLooser.pid]:IsLoggedIn() then
		pidLooser = playerLooser.pid
		cellDescription = DataChess.listPlayers[looserName].cellDescription
		tes3mp.MessageBox(pidLooser, -1, trad.desolat)
	end
	RestartGame(pidWinner, pidLooser, DataChess)
end
local function EndGamePate(winnerTeam, looserTeam, DataChess)
	local winnerName = GetPlayerNameTeam(winnerTeam, DataChess)
	local looserName = GetPlayerNameTeam(looserTeam, DataChess)
	local playerWinner = GetPlayerByName(winnerName)
	local playerLooser = GetPlayerByName(looserName)
	local pidWinner
	local pidLooser
	local cellDescription
	if playerWinner and playerWinner.pid and Players[playerWinner.pid]:IsLoggedIn() then
		pid = playerWinner.pid
		cellDescription = DataChess.listPlayers[winnerName].cellDescription
		tes3mp.MessageBox(playerWinner.pid, -1, trad.pate)
	end
	if playerLooser and playerLooser.pid and Players[playerLooser.pid]:IsLoggedIn() then
		pid = playerLooser.pid
		cellDescription = DataChess.listPlayers[looserName].cellDescription
		tes3mp.MessageBox(playerLooser.pid, -1, trad.pate)
	end
	RestartGame(pidWinner, pidLooser, DataChess)
end
local function CheckEndMate(teamPlayer, DataChess)
	local ValideMove = true
	local temporalyDataChess = tableHelper.deepCopy(DataChess)
	for pawnIndex, data in pairs(temporalyDataChess.listPawnIndex) do
		local temporalyPawnData = tableHelper.deepCopy(DataChess.listPawnIndex[pawnIndex])
		local pawnTeam = GetTeamPawn(data.refId)
		local targetTeam
		if teamPlayer == trad.white then
			targetTeam = trad.red
		else
			targetTeam = trad.white
		end
		if teamPlayer == pawnTeam then
			for caseNumber = 1, 64 do
				local temporalyTargetPawnData
				local caseIndex = GetIndexCaseByNumber(caseNumber, temporalyDataChess)
				if caseIndex ~= data.case then
					local Check, TargetIndexPawn, TargetCaseIndex = ValideCaseMove(caseIndex, pawnIndex, temporalyDataChess)
					if Check then
						temporalyDataChess.listPawnIndex[pawnIndex].coorA = temporalyDataChess.listCaseIndex[caseIndex].coorA
						temporalyDataChess.listPawnIndex[pawnIndex].coorB = temporalyDataChess.listCaseIndex[caseIndex].coorB							
						temporalyDataChess.listPawnIndex[pawnIndex].case = temporalyDataChess.listCaseIndex[caseIndex].case
						if TargetCaseIndex then
							temporalyDataChess.listPawnIndex[pawnIndex].coorA = temporalyDataChess.listCaseIndex[TargetCaseIndex].coorA
							temporalyDataChess.listPawnIndex[pawnIndex].coorB = temporalyDataChess.listCaseIndex[TargetCaseIndex].coorB							
							temporalyDataChess.listPawnIndex[pawnIndex].case = temporalyDataChess.listCaseIndex[TargetCaseIndex].case
						end
						if TargetIndexPawn then
							temporalyTargetPawnData = tableHelper.deepCopy(DataChess.listPawnIndex[TargetIndexPawn])
							temporalyDataChess.listPawnIndex[TargetIndexPawn] = nil
						end						
						local Mate, PawnIndexMate, CaseIndexMate = CheckMate(targetTeam, temporalyDataChess)
						if not Mate then
							ValideMove = false
						else
							temporalyDataChess.listPawnIndex[pawnIndex].coorA = temporalyPawnData.coorA
							temporalyDataChess.listPawnIndex[pawnIndex].coorB = temporalyPawnData.coorB							
							temporalyDataChess.listPawnIndex[pawnIndex].case = temporalyPawnData.case
							if TargetIndexPawn then
								temporalyDataChess.listPawnIndex[TargetIndexPawn] = temporalyTargetPawnData
							end
						end
					end
				end
			end
		end
	end
	return ValideMove
end
local function TurnIA(pid, cellDescription, teamIA, DataChess)
	local ValideMove = false
	local targetTeam
	local PlayerName = GetName(pid)
	local temporalyDataChess = tableHelper.deepCopy(DataChess)
	for pawnIndex, data in pairs(temporalyDataChess.listPawnIndex) do
		local temporalyPawnData = tableHelper.deepCopy(DataChess.listPawnIndex[pawnIndex])
		local pawnTeam = GetTeamPawn(data.refId)
		if teamIA == trad.white then
			targetTeam = trad.red
		else
			targetTeam = trad.white
		end
		if teamIA == pawnTeam then
			for caseNumber = 1, 64 do
				if caseNumber ~= data.case then
					local caseIndex = GetIndexCaseByNumber(caseNumber, temporalyDataChess)
					local Check, TargetIndexPawn, TargetCaseIndex = ValideCaseMove(caseIndex, pawnIndex, temporalyDataChess)
					if Check then
						local listDeletePacket = {}
						temporalyDataChess.listPawnIndex[pawnIndex].coorA = temporalyDataChess.listCaseIndex[caseIndex].coorA
						temporalyDataChess.listPawnIndex[pawnIndex].coorB = temporalyDataChess.listCaseIndex[caseIndex].coorB							
						temporalyDataChess.listPawnIndex[pawnIndex].case = temporalyDataChess.listCaseIndex[caseIndex].case
						if TargetCaseIndex then
							temporalyDataChess.listPawnIndex[pawnIndex].coorA = temporalyDataChess.listCaseIndex[TargetCaseIndex].coorA
							temporalyDataChess.listPawnIndex[pawnIndex].coorB = temporalyDataChess.listCaseIndex[TargetCaseIndex].coorB							
							temporalyDataChess.listPawnIndex[pawnIndex].case = temporalyDataChess.listCaseIndex[TargetCaseIndex].case
						end
						if TargetIndexPawn then
							temporalyTargetPawnData = tableHelper.deepCopy(DataChess.listPawnIndex[TargetIndexPawn])
							temporalyDataChess.listPawnIndex[TargetIndexPawn] = nil
							table.insert(listDeletePacket, TargetIndexPawn)
						end						
						local Mate, PawnIndexMate, CaseIndexMate = CheckMate(targetTeam, temporalyDataChess)
						if not Mate then
							ValideMove = true
						else
							temporalyDataChess.listPawnIndex[pawnIndex].coorA = temporalyPawnData.coorA
							temporalyDataChess.listPawnIndex[pawnIndex].coorB = temporalyPawnData.coorB							
							temporalyDataChess.listPawnIndex[pawnIndex].case = temporalyPawnData.case
							if TargetIndexPawn then
								temporalyDataChess.listPawnIndex[TargetIndexPawn] = temporalyTargetPawnData
							end
						end
						if ValideMove then
							local indexCase = caseIndex
							if TargetCaseIndex then
								indexCase = TargetCaseIndex
							end
							local newPos = {
								posX = temporalyDataChess.listCaseIndex[indexCase].pos.posX,
								posY = temporalyDataChess.listCaseIndex[indexCase].pos.posY,
								posZ = temporalyDataChess.listCaseIndex[indexCase].pos.posZ + temporalyDataChess.listPawnIndex[pawnIndex].posZ,
								rotX = 0,
								rotY = 0,						
								rotZ = temporalyDataChess.listPawnIndex[pawnIndex].rotZ							
							}
							DeleteObject(pid, cellDescription, listDeletePacket)
							local PawnObject = GetObject(cellDescription, pawnIndex)
							PawnObject.location = newPos
							temporalyDataChess.listPawnIndex[pawnIndex].location = newPos
							local listSendPacketMove = {}
							table.insert(listSendPacketMove, pawnIndex)
							SendMove(pid, cellDescription, listSendPacketMove, true)
							temporalyDataChess.turn = targetTeam	
							ChessBoard[PlayerName] = temporalyDataChess
							SaveData()
							return true
						end
					end
				end
			end
		end
	end
	if not ValideMove then
		if CheckEndMate(targetTeam, DataChess) then
			EndGamePate(targetTeam, teamPlayer, DataChess)
		else
			EndGameMate(targetTeam, teamPlayer, DataChess)	
		end
	end
end
-------------
-- METHODS --
-------------
local ChessTes3mp = {} 
ChessTes3mp.OnServerPostInit = function(eventStatus)
	if ChessBoard == nil then
		ChessBoard = {}
		SaveData()
	end
end
ChessTes3mp.CreateChessboard = function(pid, cmd)
	if Players[pid] and Players[pid]:IsLoggedIn() then
		local PlayerName = GetName(pid)
		if ChessBoard[PlayerName] then
			DeleteChessBoard(pid, PlayerName)
		end
		local listSendPacketCreate = {}
		local cellDescription = tes3mp.GetCell(pid)
		local playerAngleZ = tes3mp.GetRotZ(pid)
		if playerAngleZ > 3.0 then
			playerAngleZ = 3.0
		elseif playerAngleZ < -3.0 then
			playerAngleZ = -3.0
		end
		local PosX = (60 * math.sin(playerAngleZ) + tes3mp.GetPosX(pid))
		local PosY = (60 * math.cos(playerAngleZ) + tes3mp.GetPosY(pid))
		local PosZ = tes3mp.GetPosZ(pid)
		local posTable = {
			posX = PosX,
			posY = PosY,
			posZ = PosZ + 30,
			rotX = 0,
			rotY = 0,			
			rotZ = 0
		}
		local tableUniqueIndex = CreateObjectAtLocation(cellDescription, posTable, "furn_de_p_table_05", 1)
		table.insert(listSendPacketCreate, tableUniqueIndex)
		ChessBoard[PlayerName] = {
			listPawnIndex = {},
			listCaseIndex = {},
			listPlayers = {},
			tableUnique = tableUniqueIndex,
			cellDescription = cellDescription,
			turn = trad.white,
			mode = false,
			registerPrice = false,
			cfgRound = false,
			scoreWhite = 0,
			scoreRed = 0
		}		
		local pos = {
			posX = PosX - 21,
			posY = PosY + 21,
			posZ = PosZ + 61,
			rotX = 0,
			rotY = 0,			
			rotZ = 0
		}
		local positive = true
		local countCase = 0
		local totalCount = 0
		local coorA = 1
		local coorB = 1
		local line = false
		for x = 1, 64 do
			local newPos
			if line then
				pos = {
					posX = pos.posX + (2.56000042 * cfg.scale),
					posY = pos.posY,
					posZ = pos.posZ,
					rotX = 0,
					rotY = 0,						
					rotZ = 0							
				}
				coorB = coorB + 1
				line = false
			end
			if positive then
				if countCase == 0 then
					newPos = {
						posX = pos.posX,
						posY = pos.posY,
						posZ = pos.posZ,
						rotX = 0,
						rotY = 0,							
						rotZ = 0						
					}
					countCase = countCase + 1
					coorA = countCase
				elseif countCase > 0 and countCase < 8 then
					newPos = {
						posX = pos.posX,
						posY = pos.posY - (2.5600009 * cfg.scale),
						posZ = pos.posZ,
						rotX = 0,
						rotY = 0,							
						rotZ = 0						
					}
					countCase = countCase + 1
					coorA = countCase
					if countCase < 8 then
						positive = true
					else
						positive = false
						line = true
						countCase = 0
					end
				end
			else
				if countCase == 0 then
					newPos = {
						posX = pos.posX,
						posY = pos.posY,
						posZ = pos.posZ,
						rotX = 0,
						rotY = 0,							
						rotZ = 0						
					}
					countCase = countCase + 1
					coorA = 8
				elseif countCase > 0 and countCase < 8 then
					newPos = {
						posX = pos.posX,
						posY = pos.posY + (2.5600009 * cfg.scale),
						posZ = pos.posZ,
						rotX = 0,
						rotY = 0,						
						rotZ = 0							
					}
					coorA = 8 - countCase
					countCase = countCase + 1
					if countCase < 8 then
						positive = false
					else
						positive = true
						line = true
						countCase = 0
					end
				end			
			end			
			totalCount = totalCount + 1
			local CaseUniqueIndex
			if countCase % 2 == 0 then
				local whitePos = {
					posX = newPos.posX,
					posY = newPos.posY,
					posZ = newPos.posZ + (1.28 * cfg.scale),
					rotX = 0,
					rotY = 0,						
					rotZ = 0							
				}				
				CaseUniqueIndex = CreateObjectAtLocation(cellDescription, whitePos, "chess_white_case", 0.01 * cfg.scale)
				ChessBoard[PlayerName].listCaseIndex[CaseUniqueIndex] = {
					case = totalCount,
					pos = newPos,
					coorA = coorA,
					coorB = coorB,
					cellDescription = cellDescription
				}
			else
				CaseUniqueIndex = CreateObjectAtLocation(cellDescription, newPos, "chess_red_case", 0.005 * cfg.scale)
				ChessBoard[PlayerName].listCaseIndex[CaseUniqueIndex] = {
					case = totalCount,
					pos = newPos,
					coorA = coorA,
					coorB = coorB,
					cellDescription = cellDescription					
				}
			end
			table.insert(listSendPacketCreate, CaseUniqueIndex)
			pos = newPos
			if listPawnCase[totalCount] then
				local newPos = {
					posX = newPos.posX,
					posY = newPos.posY,
					posZ = newPos.posZ + listPawnCase[totalCount].posZ,
					rotX = 0,
					rotY = 0,						
					rotZ = listPawnCase[totalCount].rotZ							
				}	
				local PawnUniqueIndex = CreateObjectAtLocation(cellDescription, newPos, listPawnCase[totalCount].refId, (listPawnCase[totalCount].scale * (cfg.scale / 1.5)))
				table.insert(listSendPacketCreate, PawnUniqueIndex)
				ChessBoard[PlayerName].listPawnIndex[PawnUniqueIndex] = {
					refId = listPawnCase[totalCount].refId,
					name = listPawnCase[totalCount].name,
					posZ = listPawnCase[totalCount].posZ,
					rotZ = listPawnCase[totalCount].rotZ,
					case = totalCount,
					scale = listPawnCase[totalCount].scale,
					coorA = coorA,
					coorB = coorB,
					original = true,
					cellDescription = cellDescription,
					location = newPos					
				}
			end
		end
		SendPacket(pid, cellDescription, listSendPacketCreate)
		SaveData()	
	end
end
ChessTes3mp.OnServerInit = function(eventStatus)
	if cfg.OnServerInit then
		local recordStoreScript = RecordStores["script"]
		local recordTable = {
			id = "chess_pawn_script_red",
			scriptText = [[
				Begin chess_pawn_script_red
				StopCombat	
				ModCurrentHealth, 99999
				SetResistParalysis, 0
				ModParalysis, 99999
				SetParalysis, 99999
				AIWander, 0, 0, 0 	
				SetFight 0
				End chess_pawn_script_red
			]]
		}
		recordStoreScript.data.permanentRecords["chess_pawn_script_red"] = recordTable
		local recordTable = {
			id = "chess_pawn_script_white",
			scriptText = [[
				Begin chess_pawn_script_white
				StopCombat	
				ModCurrentHealth, 99999
				SetResistParalysis, 0
				ModParalysis, 99999
				SetParalysis, 99999
				AIWander, 0, 0, 0 	
				SetFight 0
				End chess_pawn_script_white
			]]
		}
		recordStoreScript.data.permanentRecords["chess_pawn_script_white"] = recordTable		
		recordStoreScript:Save()
		local recordStoreCreature = RecordStores["creature"]
		local recordTable = {
			baseId = "almalexia",
			name = trad.whiteQueen,
			aiFight = 0,
			aiFlee = 0,
			aiAlarm = 0,
			script = "chess_pawn_script_white"
		}
		recordStoreCreature.data.permanentRecords["pawn_white_queen"] = recordTable		
		local recordTable = {
			baseId = "vivec_god",
			name = trad.whiteKing,
			aiFight = 0,
			aiFlee = 0,
			aiAlarm = 0,
			script = "chess_pawn_script_white"
		}
		recordStoreCreature.data.permanentRecords["pawn_white_king"] = recordTable	
		local recordTable = {
			baseId = "guar_white_unique",
			name = trad.whiteKnight,
			aiFight = 0,
			aiFlee = 0,
			aiAlarm = 0,
			script = "chess_pawn_script_white"
		}
		recordStoreCreature.data.permanentRecords["pawn_white_knight"] = recordTable	
		local recordTable = {
			baseId = "guar_pack",
			name = trad.redKnight,
			aiFight = 0,
			aiFlee = 0,
			aiAlarm = 0,
			script = "chess_pawn_script_red"
		}
		recordStoreCreature.data.permanentRecords["pawn_red_knight"] = recordTable
		recordStoreCreature:Save()	
		local recordStoreNpc = RecordStores["npc"]
		local recordTable = {
			baseId = "king hlaalu helseth",
			name = trad.redKing,
			aiFight = 0,
			aiFlee = 0,
			aiAlarm = 0,
			script = "chess_pawn_script_red"
		}
		recordStoreNpc.data.permanentRecords["pawn_red_king"] = recordTable
		local recordTable = {
			baseId = "barenziah",
			name = trad.redQueen,
			aiFight = 0,
			aiFlee = 0,
			aiAlarm = 0,
			script = "chess_pawn_script_red"
		}
		recordStoreNpc.data.permanentRecords["pawn_red_queen"] = recordTable
		local recordTable = {
			baseId = "fargoth",
			name = trad.whiteBishop,
			aiFight = 0,
			aiFlee = 0,
			aiAlarm = 0,
			script = "chess_pawn_script_white"
		}
		recordStoreNpc.data.permanentRecords["pawn_white_bishop"] = recordTable		
		local recordTable = {
			baseId = "Gaenor",
			name = trad.redBishop,
			aiFight = 0,
			aiFlee = 0,
			aiAlarm = 0,
			script = "chess_pawn_script_red"
		}
		recordStoreNpc.data.permanentRecords["pawn_red_bishop"] = recordTable	
		local recordTable = {
			baseId = "ervis verano",
			name = trad.redPawn,
			aiFight = 0,
			aiFlee = 0,
			aiAlarm = 0,
			script = "chess_pawn_script_red"
		}
		recordStoreNpc.data.permanentRecords["pawn_red_pawn"] = recordTable	
		local recordTable = {
			baseId = "suryn athones",
			name = trad.whitePawn,
			aiFight = 0,
			aiFlee = 0,
			aiAlarm = 0,
			script = "chess_pawn_script_white"
		}
		recordStoreNpc.data.permanentRecords["pawn_white_pawn"] = recordTable	
		recordStoreNpc:Save()	
		local recordStoreActivator = RecordStores["activator"]	
		local recordTable = {
			model = "i/In_vs_pitfloor_01.NIF",
			name = trad.whiteCase
		}
		recordStoreActivator.data.permanentRecords["chess_white_case"] = recordTable	
		local recordTable = {
			model = "i/In_DAE_room_L_floor_01.nif",
			name = trad.redCase
		}
		recordStoreActivator.data.permanentRecords["chess_red_case"] = recordTable	
		local recordTable = {
			model = "x/Ex_imp_guardtower_01.NIF",
			name = trad.whiteTower
		}
		recordStoreActivator.data.permanentRecords["pawn_white_tower"] = recordTable
		local recordTable = {
			model = "x/Ex_common_tower_thatch.NIF",
			name = trad.redTower
		}
		recordStoreActivator.data.permanentRecords["pawn_red_tower"] = recordTable
		recordStoreActivator:Save()	
	end
end
ChessTes3mp.OnObjectActivate = function(eventStatus, pid, cellDescription, objects)
	if Players[pid] and Players[pid]:IsLoggedIn() then	
		local ObjectRefid
		local ObjectIndex	
		for _, object in pairs(objects) do
			ObjectRefid = object.refId
			ObjectIndex = object.uniqueIndex
		end	
		if ObjectIndex and ObjectRefid then 
			local PlayerName = GetName(pid)
			local DataChess, ownerName = GetChessBoard(ObjectIndex, PlayerName)
			if DataChess and DataChess.listPawnIndex[ObjectIndex] 
			or DataChess and DataChess.listCaseIndex[ObjectIndex] then
				if not DataChess.mode then
					if ownerName == PlayerName then
						tes3mp.CustomMessageBox(pid, cfg.SelectModeGUI, trad.menu, trad.choice)					
					else
						tes3mp.MessageBox(pid, -1, trad.wait)					
					end
					return customEventHooks.makeEventStatus(false, false) 
				elseif DataChess.mode == trad.tournament then
					if not DataChess.registerPrice then
						if ownerName == PlayerName then
							tes3mp.InputDialog(pid, cfg.SelectPriceRegisterGUI, trad.bet, "")
						else
							tes3mp.MessageBox(pid, -1, trad.waitBet)
						end
						return customEventHooks.makeEventStatus(false, false) 
					elseif DataChess.registerPrice and not DataChess.cfgRound then
						if ownerName == PlayerName then
							tes3mp.InputDialog(pid, cfg.SelectGameRoundGUI, trad.round, "")
						else
							tes3mp.MessageBox(pid, -1, trad.waitRound)
						end				
						return customEventHooks.makeEventStatus(false, false) 
					end
				end
				if DataChess.listPawnIndex[ObjectIndex] then
					local teamPawn = GetTeamPawn(ObjectRefid)
					local targetTeam
					if teamPawn == trad.white then
						targetTeam = trad.red
					else
						targetTeam = trad.white
					end
					if DataChess.listPlayers[PlayerName] then
						if DataChess.listPlayers[PlayerName].team == teamPawn then
							if DataChess.listPawnIndex[ObjectIndex].name == trad.tower
							and DataChess.listPawnIndex[DataChess.listPlayers[PlayerName].uniqueIndex].name == trad.king
							and DataChess.listPlayers[PlayerName].team == DataChess.turn then
								local Castling, Cause = CastlingMove(pid, DataChess.listPlayers[PlayerName].uniqueIndex, ObjectIndex, DataChess)
								if Castling then
									if DataChess.mode == trad.pve then
										TurnIA(pid, cellDescription, targetTeam, DataChess)
									end								
									return customEventHooks.makeEventStatus(false, false)
								else
									print(Cause)
								end
							end
							DataChess.listPlayers[PlayerName].uniqueIndex = ObjectIndex
							DataChess.listPlayers[PlayerName].cellDescription = cellDescription
							local Message = (
								DataChess.listPawnIndex[ObjectIndex].name..
								"\nA = "..DataChess.listPawnIndex[ObjectIndex].coorA.." B = "..DataChess.listPawnIndex[ObjectIndex].coorB
							)
							tes3mp.MessageBox(pid, -1, Message)	
						else
							if DataChess.mode == trad.free then
								DataChess.listPlayers[PlayerName] = {
									cellDescription = cellDescription,
									uniqueIndex = ObjectIndex,
									team = teamPawn
								}
								local Message = (
									DataChess.listPawnIndex[ObjectIndex].name..
									"\nA = "..DataChess.listPawnIndex[ObjectIndex].coorA.." B = "..DataChess.listPawnIndex[ObjectIndex].coorB
								)
								tes3mp.MessageBox(pid, -1, Message)
							else
								local Message = trad.noChange..DataChess.mode
								tes3mp.MessageBox(pid, -1, Message)
							end
						end
					else
						if GetAvailableTeam(teamPawn, DataChess) then
							if DataChess.mode == trad.tournament then
								if not RegisterGold(pid, DataChess.registerPrice) then
									local Message = trad.noGold..DataChess.registerPrice
									tes3mp.MessageBox(pid, -1, Message)
									return customEventHooks.makeEventStatus(false, false) 
								else
									local Message = (
										trad.register..DataChess.registerPrice
									)
									tes3mp.MessageBox(pid, -1, Message)
								end
							end
							DataChess.listPlayers[PlayerName] = {
								cellDescription = cellDescription,
								uniqueIndex = ObjectIndex,
								team = teamPawn
							}
							local Message = (
								DataChess.listPawnIndex[ObjectIndex].name..
								"\nA = "..DataChess.listPawnIndex[ObjectIndex].coorA.." B = "..DataChess.listPawnIndex[ObjectIndex].coorB
							)
							tes3mp.MessageBox(pid, -1, Message)	
							if DataChess.mode == trad.pve and teamPawn == trad.red then
								TurnIA(pid, cellDescription, targetTeam, DataChess)
							end
						else
							tes3mp.MessageBox(pid, -1, trad.noAvailable)	
						end
					end
					return customEventHooks.makeEventStatus(false, false) 
				elseif DataChess.listCaseIndex[ObjectIndex] then
					if DataChess.listPlayers[PlayerName] and DataChess.listPawnIndex[DataChess.listPlayers[PlayerName].uniqueIndex] then
						local TemporySaveDataChess = tableHelper.deepCopy(DataChess)
						local PawnIndex = DataChess.listPlayers[PlayerName].uniqueIndex
						local teamPlayer = DataChess.listPlayers[PlayerName].team
						if teamPlayer ~= DataChess.turn then
							local Message = trad.waitTurn..DataChess.turn
							tes3mp.MessageBox(pid, -1, Message)	
							return customEventHooks.makeEventStatus(false, false) 
						end
						local targetTeam 
						if teamPlayer == trad.white then
							targetTeam = trad.red
						else
							targetTeam = trad.white
						end
						local newPos = {
							posX = DataChess.listCaseIndex[ObjectIndex].pos.posX,
							posY = DataChess.listCaseIndex[ObjectIndex].pos.posY,
							posZ = DataChess.listCaseIndex[ObjectIndex].pos.posZ + DataChess.listPawnIndex[PawnIndex].posZ,
							rotX = 0,
							rotY = 0,						
							rotZ = DataChess.listPawnIndex[PawnIndex].rotZ							
						}					
						if CheckEndMate(teamPlayer, DataChess) then
							if CheckEndMate(targetTeam, DataChess) then
								EndGamePate(targetTeam, teamPlayer, DataChess)
							else
								EndGameMate(targetTeam, teamPlayer, DataChess)	
							end
							DataChess.turn = trad.white
							return customEventHooks.makeEventStatus(false, false) 
						end
						local Check, TargetIndexPawn, TargetCaseIndex = ValideCaseMove(ObjectIndex, PawnIndex, DataChess)
						if Check then
							local listDeletePacket = {}
							DataChess.listPawnIndex[PawnIndex].case = DataChess.listCaseIndex[ObjectIndex].case
							DataChess.listPawnIndex[PawnIndex].coorA = DataChess.listCaseIndex[ObjectIndex].coorA
							DataChess.listPawnIndex[PawnIndex].coorB = DataChess.listCaseIndex[ObjectIndex].coorB	
							if TargetCaseIndex then
								newPos = DataChess.listCaseIndex[TargetCaseIndex].pos
								newPos.posZ = newPos.posZ + DataChess.listPawnIndex[PawnIndex].posZ	
								DataChess.listPawnIndex[PawnIndex].coorA = DataChess.listCaseIndex[TargetCaseIndex].coorA
								DataChess.listPawnIndex[PawnIndex].coorB = DataChess.listCaseIndex[TargetCaseIndex].coorB							
								DataChess.listPawnIndex[PawnIndex].case = DataChess.listCaseIndex[TargetCaseIndex].case
							end
							if TargetIndexPawn then
								table.insert(listDeletePacket, TargetIndexPawn)
								DataChess.listPawnIndex[TargetIndexPawn] = nil	
							end
							local Mate, PawnIndexMate, CaseIndexMate = CheckMate(targetTeam, DataChess)
							if Mate then
								local Message = (
									trad.kingMate..
									trad.by..DataChess.listPawnIndex[PawnIndexMate].name..
									trad.located.."A = "..DataChess.listCaseIndex[CaseIndexMate].coorA.." B = "..DataChess.listCaseIndex[CaseIndexMate].coorB
								)
								tes3mp.MessageBox(pid, -1, Message)	
								DataChess = TemporySaveDataChess
								return customEventHooks.makeEventStatus(false, false) 
							end	
							if DataChess.listPawnIndex[PawnIndex].original then
								DataChess.listPawnIndex[PawnIndex].original = false
							end
							DeleteObject(pid, cellDescription, listDeletePacket)
							local PawnObject = GetObject(cellDescription, PawnIndex)
							PawnObject.location = newPos
							DataChess.listPawnIndex[PawnIndex].location = newPos
							local listSendPacketMove = {}
							table.insert(listSendPacketMove, PawnIndex)
							SendMove(pid, cellDescription, listSendPacketMove, true)						
							local Message = (
								DataChess.listPawnIndex[PawnIndex].name..
								" A = "..TemporySaveDataChess.listPawnIndex[PawnIndex].coorA.." B = "..TemporySaveDataChess.listPawnIndex[PawnIndex].coorB..
								trad.come..
								"A = "..DataChess.listPawnIndex[PawnIndex].coorA.." B = "..DataChess.listPawnIndex[PawnIndex].coorB
							)
							tes3mp.MessageBox(pid, -1, Message)	
							local Mate, PawnIndexMate, CaseIndexMate = CheckMate(teamPlayer, DataChess)
							if Mate then
								local Message = (
									trad.kingEnnemy..targetTeam..trad.isMate..
									trad.by..DataChess.listPawnIndex[PawnIndexMate].name..
									trad.located.."A = "..DataChess.listCaseIndex[CaseIndexMate].coorA.." B = "..DataChess.listCaseIndex[CaseIndexMate].coorB
								)
								tes3mp.MessageBox(pid, -1, Message)
							end
							if DataChess.mode == trad.pve then
								TurnIA(pid, cellDescription, targetTeam, DataChess)
							else
								DataChess.turn = targetTeam	
							end
							SaveData()		
							LoadedCells[cellDescription]:SaveToDrive()
						else
							local Cause = trad.unknown
							if TargetIndexPawn then
								Cause = TargetIndexPawn
							end
							local Message = (
								DataChess.listPawnIndex[PawnIndex].name..
								" A = "..TemporySaveDataChess.listPawnIndex[PawnIndex].coorA.." B = "..TemporySaveDataChess.listPawnIndex[PawnIndex].coorB..
								trad.noPlay..
								"A = "..DataChess.listCaseIndex[ObjectIndex].coorA.." B = "..DataChess.listCaseIndex[ObjectIndex].coorB..
								trad.cause..Cause
							)
							tes3mp.MessageBox(pid, -1, Message)						
						end
					else
						tes3mp.MessageBox(pid, -1, trad.noSelect)	
					end
					return customEventHooks.makeEventStatus(false, false) 
				end	
			end
		end
	end
end
ChessTes3mp.OnCellLoad = function(eventStatus, pid, cellDescription)
	if Players[pid] and Players[pid]:IsLoggedIn() then
		for ownerName, data in pairs(ChessBoard) do
			if data.cellDescription == cellDescription then
				local count = 0
				tes3mp.ClearObjectList()
				tes3mp.SetObjectListPid(pid)
				tes3mp.SetObjectListCell(cellDescription)
				for uniqueIndex, object in pairs(data.listPawnIndex) do
					if object and object.location then	
						local splitIndex = uniqueIndex:split("-")
						tes3mp.SetObjectRefNum(splitIndex[1])
						tes3mp.SetObjectMpNum(splitIndex[2])
						tes3mp.SetObjectPosition(object.location.posX, object.location.posY, object.location.posZ)
						tes3mp.SetObjectRotation(object.location.rotX, object.location.rotY, object.location.rotZ)
						tes3mp.AddObject()
						count = count + 1
						if count >= 1000 then
							tes3mp.SendObjectMove(true)
							tes3mp.SendObjectRotate(true)	
							tes3mp.ClearObjectList()
							tes3mp.SetObjectListPid(pid)
							tes3mp.SetObjectListCell(cellDescription)
							count = 0
						end	
					end	
				end
				if count > 0 then
					tes3mp.SendObjectMove(true)
					tes3mp.SendObjectRotate(true)
				end
			end
		end
	end
end
ChessTes3mp.OnGUIAction = function(pid, idGui, data)
	if Players[pid] and Players[pid]:IsLoggedIn() then
		local PlayerName = GetName(pid)
		if idGui == cfg.SelectModeGUI then
			if tonumber(data) == 0 then
				ChessBoard[PlayerName].mode = trad.free
				return true
			elseif tonumber(data) == 1 then	
				ChessBoard[PlayerName].mode = trad.tournament
				return true
			elseif tonumber(data) == 2 then		
				ChessBoard[PlayerName].mode = trad.pve
				return true
			elseif tonumber(data) == 3 then		
				return true
			end
		elseif idGui == cfg.SelectPriceRegisterGUI then
			if data ~= nil and data ~= "" and tonumber(data) then
				ChessBoard[PlayerName].registerPrice = tonumber(data)
			end		
			return true
		elseif idGui == cfg.SelectGameRoundGUI then
			if data ~= nil and data ~= "" and tonumber(data) then
				ChessBoard[PlayerName].cfgRound = tonumber(data)
			end		
			return true
		end
	end
end
------------
-- EVENTS --
------------	
customCommandHooks.registerCommand("chess", ChessTes3mp.CreateChessboard)
customEventHooks.registerHandler("OnServerInit", ChessTes3mp.OnServerInit)
customEventHooks.registerHandler("OnCellLoad", ChessTes3mp.OnCellLoad)
customEventHooks.registerValidator("OnObjectActivate", ChessTes3mp.OnObjectActivate)
customEventHooks.registerHandler("OnGUIAction", function(eventStatus, pid, idGui, data)
	if ChessTes3mp.OnGUIAction(pid, idGui, data) then return end
end)
customEventHooks.registerHandler("OnServerPostInit", ChessTes3mp.OnServerPostInit)
return ChessTes3mp
