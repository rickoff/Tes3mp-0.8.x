--[[
ResetJournal
tes3mp 0.8.1
---------------------------
INSTALLATION:
Save the file as ResetJournal.lua inside your server/scripts/custom folder.
Edits to customScripts.lua
require("custom.ResetJournal")
---------------------------
]]
local trd = {
	resetJournal = "Your journal has been reset!\nPlease log out/log back in to apply the changes.",
	resetReputation = "Your guild reputation has been reset!\n",
	resetExpulsion = "Your guild expulsion has been reset!\n",
	resetKill = "All kill counts for creatures and NPCs have been reset.\n",
	expulsion = "Your guild expulsion has been validated!\n",
	resetRank = "Your guild rank has been reset!\n",
	titleMenu = "RESET MENU\n",
	choiceMenu = "Quest;Reputation;Integrate;Exclusion;Rank;Death;Return",
	titleQuest1 = "QUEST RESET PAGE 1\n",
	choiceQuest1 = "Blades;Warriors Guild;Mages Guild;Thieves Guild;Hlaalu;Redoran;Telvanni;Temple;Imperial Cult;Imperial Legion;Page 2;Return",
	titleQuest2 = "QUEST RESET PAGE 2\n",
	choiceQuest2 = "Morag Tong;Tribunal;Nerevarine;Daedras;Vivec;Annex;Vampire;Vampire;Bloodmoon;Eastern Empire;All;Page 1;Return",
	titleReputation = "REPUTATION RESET\n",
	titleIntegration = "INTEGRATION MENU\n",
	titleExclusion = "INTEGRATION MENU EXCLUSIONS\n",
	titleRank = "RANK RESET\n",
	choiceReset = "Blades;Fighters Guild;Mages Guild;Thieves Guild;Hlaalu;Redoran;Telvanni;Temple;Imperial Cult;Imperial Legion;Morag Tong;Ashlander;Twin Lanterns;Eastern Empire;Return",	
}

local gui = {
	MainGUI = 12082022,
	MainGUIQuest1 = 12082023,
	MainGUIQuest2 = 12082024,
	MainGUIReputation = 12082025,
	MainGUIIntegration = 12082026,
	MainGUIExclusion = 12082027,
	MainGUIRang = 12082028
}

local cfg = {
	OnlyStaff = false
}

local listAnnexeVariables = {"plaguerock", "plagueactivate", "plaguestage", "droth_var", "museumdonations", "matchmakeswitch", "matchmakefons", "matchmakegoval", "matchmakesunel"}

local listBloodmoonVariables = {"smugdead", "riekkilled", "deaddaedra", "caenlorndead", "werewolfdead", "werebdead", "huntersdead", "trackersdead",
 "trollsdead", "krishcount", "foundbooze", "artoriachosen", "luciuschosen", "stones", "part", "aesliptalk", "skaalattack", "trackercount", "huntercount", "cariustalk"}

local listTribunalVariables = {"rent_mh_guar", "contractcalvusday", "contractcalvusmonth", "contract_calvus_days_left", "mournholdattack", "fabattack", 
 "shrinecleanse", "bladefix", "hasblade", "kgaveblade", "duelmiss", "karrodbribe", "karrodbeaten", "karrodfightstart", "karrodcheapshot", "gobchiefdead", "helsassdead", "mournweather"}

local listMorrowindVariables = {"hortatorvotes", "heartdestroyed", "destroyblight", "redoranmurdered", "telvannidead"}

local function ConsoleCommandToExpulsion(pid, guild, typ, forEveryone)
	local value = 0	
	local consoleCommand	
	if typ then
		value = 1
	end	
	if guild == "mages guild" then	
		consoleCommand = "Set ExpMagesGuild to "..value		
	elseif guild == "fighters guild" then	
		consoleCommand = "Set ExpFightersGuild to "..value			
	elseif guild == "thieves guild" then	
		consoleCommand = "Set ExpThievesGuild to "..value	
	elseif guild == "imperial cult" then		
		consoleCommand = "Set ExpImperialCult to "..value		
	elseif guild == "imperial legion" then		
		consoleCommand = "Set ExpImperialLegion to "..value
	elseif guild == "morag tong" then		
		consoleCommand = "Set ExpMoragTong to "..value			
	elseif guild == "redoran" then		
		consoleCommand = "Set ExpRedoran to "..value	
	elseif guild == "temple" then		
		consoleCommand = "Set ExpTemple to "..value
	end
	if consoleCommand then
		logicHandler.RunConsoleCommandOnPlayer(pid, consoleCommand, forEveryone)
	end
end

local function ResetGlobalVariable(pid, guild, forEveryone)
	local target
	if config.shareJournal then
		target = WorldInstance
	else
		target = Players[pid]
	end
	if guild == "annex" then	
		for index, variable in ipairs(listAnnexeVariables) do		
			if target.data.clientVariables.globals[variable] then			
				target.data.clientVariables.globals[variable].intValue = 0				
			end			
		end
	elseif guild == "bloodmoon" then	
		for index, variable in ipairs(listBloodmoonVariables) do		
			if target.data.clientVariables.globals[variable] then			
				target.data.clientVariables.globals[variable].intValue = 0				
			end			
		end		
	elseif guild == "nerevarine" then	
		for index, variable in ipairs(listMorrowindVariables) do		
			if target.data.clientVariables.globals[variable] then			
				target.data.clientVariables.globals[variable].intValue = 0				
			end			
		end		
	elseif guild == "tribunal" then	
		for index, variable in ipairs(listTribunalVariables) do		
			if target.data.clientVariables.globals[variable] then			
				target.data.clientVariables.globals[variable].intValue = 0			
			end		
		end	
	end
	tes3mp.SendClientScriptGlobal(pid, forEveryone, forEveryone)
end

local function Quest(pid, guild)
	local target
	if config.shareJournal then
		target = WorldInstance
	else
		target = Players[pid]	
	end
	local list = {}
	list.mainquest = {"a1", "a2", "b1", "b2", "b3", "b4", "b5", "b6", "b7", "b8", "c0", "c2", "c3", "cx"}		
	for index, slot in pairs(target.data.journal) do	
		local quest = slot["quest"]
		local questsub = string.sub(quest, 1, 2)
		local lowerSub = string.lower(questsub)		
		if guild == "blades" and lowerSub == "bl" then
			target.data.journal[index] = nil
		elseif guild == "fighters guild" and lowerSub == "fg" then
			target.data.journal[index] = nil
		elseif guild == "mages guild" and lowerSub == "mg" then
			target.data.journal[index] = nil	
		elseif guild == "thieves guild" and lowerSub == "tg" then
			target.data.journal[index] = nil				
		elseif guild == "hlaalu" and lowerSub == "hh" then
			target.data.journal[index] = nil
		elseif guild == "redoran" and lowerSub == "hr" then
			target.data.journal[index] = nil
		elseif guild == "telvanni" and lowerSub == "ht" then
			target.data.journal[index] = nil
		elseif guild == "temple" and lowerSub == "tt" then
			target.data.journal[index] = nil
		elseif guild == "imperial cult" and lowerSub == "ic" then
			target.data.journal[index] = nil
		elseif guild == "imperial legion" and lowerSub == "il" then
			target.data.journal[index] = nil	
		elseif guild == "morag tong" and lowerSub == "mt" then
			target.data.journal[index] = nil	
		elseif guild == "tribunal" and lowerSub == "tr" and quest ~= "tr_dbattack" then
			target.data.journal[index] = nil	
		elseif guild == "nerevarine" and tableHelper.containsValue(list.mainquest, lowerSub) then
			target.data.journal[index] = nil	
		elseif guild == "daedras" and lowerSub == "da" then
			target.data.journal[index] = nil				
		elseif guild == "vivec" and lowerSub == "eb" then
			target.data.journal[index] = nil	
		elseif guild == "annex" and lowerSub == "ms" then
			target.data.journal[index] = nil							
		elseif guild == "vampire" and lowerSub == "va" then
			target.data.journal[index] = nil	
		elseif guild == "vampcure" and quest == "ms_vampirecure" then
			target.data.journal[index] = nil	
		elseif guild == "bloodmoon" and lowerSub == "bm" then
			target.data.journal[index] = nil					
		elseif guild == "east empire company" and lowerSub == "co" then
			target.data.journal[index] = nil					
		elseif guild == "all" and lowerSub ~= nil and quest ~= "tr_dbattack" then
			target.data.journal[index] = nil
		end
	end		
	ResetGlobalVariable(pid, guild, config.shareJournal)
	tableHelper.cleanNils(target.data.journal)
	target:LoadJournal(pid)		
	tes3mp.SendMessage(pid, trd.resetJournal, config.shareJournal)	
end

local function Reputation(pid, guild)
	local target
	if config.shareFactionReputation then
		target = WorldInstance
	else
		target = Players[pid]	
	end	
	target.data.factionReputation[guild] = 0
	target:LoadFactionReputation(pid)	
	tes3mp.SendMessage(pid, trd.resetReputation, config.shareFactionReputation)	
end

local function Integration(pid, guild)
	local target
	if config.shareFactionExpulsion then
		target = WorldInstance
	else
		target = Players[pid]	
	end	
	target.data.factionExpulsion[guild] = false
	ConsoleCommandToExpulsion(pid, guild, false, config.shareFactionExpulsion)
	target:LoadFactionExpulsion(pid)
	tes3mp.SendMessage(pid, trd.resetExpulsion, config.shareFactionExpulsion)	
end

local function Exclusion(pid, guild)
	local target
	if config.shareFactionExpulsion then
		target = WorldInstance
	else
		target = Players[pid]	
	end	
	target.data.factionExpulsion[guild] = true	
	ConsoleCommandToExpulsion(pid, guild, true, config.shareFactionExpulsion)	
	target:LoadFactionExpulsion(pid)		
	tes3mp.SendMessage(pid, trd.expulsion, config.shareFactionExpulsion)	
end

local function Kills(pid)
	local target
	if config.shareKills then
		target = WorldInstance
	else
		target = Players[pid]	
	end		
	if target.data.kills == nil then	
		target.data.kills = {}		
	end
	for refId, killCount in pairs(target.data.kills) do	
		target.data.kills[refId] = 0		
	end	
	target:LoadKills(pid, config.shareKills)	
	tes3mp.SendMessage(pid, trd.resetKill, config.shareKills)	
end

local function Ranks(pid, guild)
	local target
	if config.shareFactionRanks then
		target = WorldInstance
	else
		target = Players[pid]	
	end	
	target.data.factionRanks[guild] = 0	
	target:LoadFactionRanks(pid)			
	tes3mp.SendMessage(pid, trd.resetRank, config.shareFactionRanks)	
end

local function ShowMainGui(pid)
	if cfg.OnlyStaff and not Players[pid]:IsServerStaff() then return end 
	local message = (color.Orange .. trd.titleMenu)
	tes3mp.CustomMessageBox(pid, gui.MainGUI, message, trd.choiceMenu)
end

local function ShowQuestChoice1(pid)	
	local message = (color.Orange .. trd.titleQuest1)	
	tes3mp.CustomMessageBox(pid, gui.MainGUIQuest1, message, trd.choiceQuest1)
end

local function ShowQuestChoice2(pid)	
	local message = (color.Orange .. trd.titleQuest2)	
	tes3mp.CustomMessageBox(pid, gui.MainGUIQuest2, message, trd.choiceQuest2)	
end

local function ShowGuildReputationChoice(pid)	
	local message = (color.Orange .. trd.titleReputation)		
	tes3mp.CustomMessageBox(pid, gui.MainGUIReputation, message, trd.choiceReset)
end

local function ShowGuildIntegrationChoice(pid)	
	local message = (color.Orange .. trd.titleIntegration)			
	tes3mp.CustomMessageBox(pid, gui.MainGUIIntegration, message, trd.choiceReset)
end

local function ShowGuildExclusionChoice(pid)	
	local message = (color.Orange .. trd.titleExclusion)				
	tes3mp.CustomMessageBox(pid, gui.MainGUIExclusion, message, trd.choiceReset)
end

local function ShowGuildRangChoice(pid)	
	local message = (color.Orange .. trd.titleRank)		
	tes3mp.CustomMessageBox(pid, gui.MainGUIRang, message, trd.choiceReset)
end

customEventHooks.registerHandler("OnGUIAction", function(eventStatus, pid, idGui, data)	
	if idGui == gui.MainGUI then
		if tonumber(data) == 0 then
			ShowQuestChoice1(pid)
		elseif tonumber(data) == 1 then
			ShowGuildReputationChoice(pid)
		elseif tonumber(data) == 2 then
			ShowGuildIntegrationChoice(pid)
		elseif tonumber(data) == 3 then
			ShowGuildExclusionChoice(pid)
		elseif tonumber(data) == 4 then
			ShowGuildRangChoice(pid)
		elseif tonumber(data) == 5 then
			Kills(pid)			
		elseif tonumber(data) == 6 then
			return
		end
	elseif idGui == gui.MainGUIQuest1 then
		if tonumber(data) == 0 then
			Quest(pid, "blades")
		elseif tonumber(data) == 1 then
			Quest(pid, "fighters guild")
		elseif tonumber(data) == 2 then
			Quest(pid, "mages guild")
		elseif tonumber(data) == 3 then
			Quest(pid, "thieves guild")
		elseif tonumber(data) == 4 then
			Quest(pid, "hlaalu")
		elseif tonumber(data) == 5 then
			Quest(pid, "redoran")					
		elseif tonumber(data) == 6 then
			Quest(pid, "telvanni")
		elseif tonumber(data) == 7 then
			Quest(pid, "temple")
		elseif tonumber(data) == 8 then
			Quest(pid, "imperial cult")
		elseif tonumber(data) == 9 then
			Quest(pid, "imperial legion")
		elseif tonumber(data) == 10 then
			ShowQuestChoice2(pid)		
		elseif tonumber(data) == 11 then	
			ShowMainGui(pid)
		end
	elseif idGui == gui.MainGUIQuest2 then
		if tonumber(data) == 0 then
			Quest(pid, "morag tong")
		elseif tonumber(data) == 1 then
			Quest(pid, "tribunal")
		elseif tonumber(data) == 2 then
			Quest(pid, "nerevarine")
		elseif tonumber(data) == 3 then
			Quest(pid, "daedras")
		elseif tonumber(data) == 4 then
			Quest(pid, "vivec")
		elseif tonumber(data) == 5 then
			Quest(pid, "annex")					
		elseif tonumber(data) == 6 then
			Quest(pid, "vampire")
		elseif tonumber(data) == 7 then
			Quest(pid, "vampcure")
		elseif tonumber(data) == 8 then
			Quest(pid, "bloodmoon")
		elseif tonumber(data) == 9 then
			Quest(pid, "east empire company")
		elseif tonumber(data) == 10 then
			Quest(pid, "all")			
		elseif tonumber(data) == 11 then
			ShowQuestChoice1(pid)		
		elseif tonumber(data) == 12 then	
			ShowMainGui(pid)				
		end
	elseif idGui == gui.MainGUIReputation then
		if tonumber(data) == 0 then 
			Reputation(pid, "blades")
		elseif tonumber(data) == 1 then 
			Reputation(pid, "fighters guild")
		elseif tonumber(data) == 2 then  
			Reputation(pid, "mages guild")
		elseif tonumber(data) == 3 then  
			Reputation(pid, "thieves guild")
		elseif tonumber(data) == 4 then  
			Reputation(pid, "hlaalu")
		elseif tonumber(data) == 5 then  
			Reputation(pid, "redoran")					
		elseif tonumber(data) == 6 then 
			Reputation(pid, "telvanni")
		elseif tonumber(data) == 7 then 
			Reputation(pid, "temple")
		elseif tonumber(data) == 8 then  
			Reputation(pid, "imperial cult")
		elseif tonumber(data) == 9 then  
			Reputation(pid, "imperial legion")
		elseif tonumber(data) == 10 then  
			Reputation(pid, "morag tong")			
		elseif tonumber(data) == 11 then 
			Reputation(pid, "ashlanders")	
		elseif tonumber(data) == 12 then  	
			Reputation(pid, "twin lamps")			
		elseif tonumber(data) == 13 then  	
			Reputation(pid, "east empire company")			
		elseif tonumber(data) == 14 then  	
			ShowMainGui(pid)		
		end
	elseif idGui == gui.MainGUIIntegration then
		if tonumber(data) == 0 then 
			Integration(pid, "blades")
		elseif tonumber(data) == 1 then 
			Integration(pid, "fighters guild")
		elseif tonumber(data) == 2 then  
			Integration(pid, "mages guild")
		elseif tonumber(data) == 3 then  
			Integration(pid, "thieves guild")
		elseif tonumber(data) == 4 then  
			Integration(pid, "hlaalu")
		elseif tonumber(data) == 5 then  
			Integration(pid, "redoran")				
		elseif tonumber(data) == 6 then 
			Integration(pid, "telvanni")
		elseif tonumber(data) == 7 then 
			Integration(pid, "temple")
		elseif tonumber(data) == 8 then  
			Integration(pid, "imperial cult")
		elseif tonumber(data) == 9 then  
			Integration(pid, "imperial legion")
		elseif tonumber(data) == 10 then  
			Integration(pid, "morag tong")		
		elseif tonumber(data) == 11 then 
			Integration(pid, "ashlanders")
		elseif tonumber(data) == 12 then  	
			Integration(pid, "twin lamps")
		elseif tonumber(data) == 13 then  	
			Integration(pid, "east empire company")
		elseif tonumber(data) == 14 then  	
			ShowMainGui(pid)	
		end
	elseif idGui == gui.MainGUIExclusion then
		if tonumber(data) == 0 then 
			Exclusion(pid, "blades")
		elseif tonumber(data) == 1 then 
			Exclusion(pid, "fighters guild")
		elseif tonumber(data) == 2 then  
			Exclusion(pid, "mages guild")
		elseif tonumber(data) == 3 then  
			Exclusion(pid, "thieves guild")
		elseif tonumber(data) == 4 then  
			Exclusion(pid, "hlaalu")
		elseif tonumber(data) == 5 then  
			Exclusion(pid, "redoran")		
		elseif tonumber(data) == 6 then 
			Exclusion(pid, "telvanni")
		elseif tonumber(data) == 7 then 
			Exclusion(pid, "temple")
		elseif tonumber(data) == 8 then  
			Exclusion(pid, "imperial cult")
		elseif tonumber(data) == 9 then  
			Exclusion(pid, "imperial legion")
		elseif tonumber(data) == 10 then  
			Exclusion(pid, "morag tong")			
		elseif tonumber(data) == 11 then 
			Exclusion(pid, "ashlanders")	
		elseif tonumber(data) == 12 then  	
			Exclusion(pid, "twin lamps")			
		elseif tonumber(data) == 13 then  	
			Exclusion(pid, "east empire company")			
		elseif tonumber(data) == 14 then  	
			ShowMainGui(pid)		
		end
	elseif idGui == gui.MainGUIRang then
		if tonumber(data) == 0 then 
			Ranks(pid, "blades")
		elseif tonumber(data) == 1 then 
			Ranks(pid, "fighters guild")
		elseif tonumber(data) == 2 then  
			Ranks(pid, "mages guild")
		elseif tonumber(data) == 3 then  
			Ranks(pid, "thieves guild")
		elseif tonumber(data) == 4 then  
			Ranks(pid, "hlaalu")
		elseif tonumber(data) == 5 then  
			Ranks(pid, "redoran")					
		elseif tonumber(data) == 6 then 
			Ranks(pid, "telvanni")
		elseif tonumber(data) == 7 then 
			Ranks(pid, "temple")
		elseif tonumber(data) == 8 then  
			Ranks(pid, "imperial cult")
		elseif tonumber(data) == 9 then  
			Ranks(pid, "imperial legion")
		elseif tonumber(data) == 10 then  
			Ranks(pid, "morag tong")			
		elseif tonumber(data) == 11 then
			Ranks(pid, "ashlanders")	
		elseif tonumber(data) == 12 then 	
			Ranks(pid, "twin lamps")	
		elseif tonumber(data) == 13 then	
			Ranks(pid, "east empire company")	
		elseif tonumber(data) == 14 then	
			ShowMainGui(pid)		
		end
	end
end)

customCommandHooks.registerCommand("resetmenu", ShowMainGui)
