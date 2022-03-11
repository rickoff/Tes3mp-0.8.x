--[[
TrueSurvive
tes3mp 0.8.0
---------------------------
DESCRIPTION :
Survival script
/survive for open main menu
---------------------------
INSTALLATION:

Save the file as TrueSurvive.lua inside your server/scripts/custom folder.
Save the file as MenuSurvive.lua inside your server/scripts/menu folder.
Save the file as DataBaseAlch.json inside your server/data/custom/TrueSurvive folder.
Save the file as DataBaseIngr.json inside your server/data/custom/TrueSurvive folder.
Save the file as DataBaseBed.json inside your server/data/custom/TrueSurvive folder.

Edits to customScripts.lua add
TrueSurvive = require("custom.TrueSurvive")

Edits to config.lua in config.menuHelperFiles
"MenuSurvive"
---------------------------
INSTRUCTION:
the consumption of the ingredients by the inventory will give the normal effects of the basic game, to eat, drink or sleep you must activate the objects placed.
timers are not taken into account for staff players, change config.staff to false to undo this.
change config.sleepTime;config.eatTime;config.drinkTime;config.rainMax;config.coldMax to increase the countdown before the needs.
change config.eatRange;config.drinkRange to increase the gain to each ingredient consumed.
change config.debuffSleep;config.debuffEat;config.debuffDrink;config.debuffWet;config.debuffFrozen to modify the value of the penalty
change the text in SurviveMessage to translate it or modify it according to your wishes
the number is in seconds, the script is based on the world clock
---------------------------
]]

------------
-- CONFIG --
------------
local config = {}
config.sleepTime = 1200 
config.eatTime = 600 
config.drinkTime = 600
config.eatRange = 60
config.drinkRange = 60
config.rainMax = 1000
config.coldMax = 1000
config.debuffSleep = 200
config.debuffEat = 200
config.debuffDrink = 200
config.debuffWet = 200
config.debuffFrozen = 200
config.staff = true

-------------
-- MESSAGE --
-------------
local SurviveMessage = {}
SurviveMessage.Fatigue = color.White.."You're "..color.Red.."tired !"..color.White.." you should "..color.Green.."sleep !"
SurviveMessage.Hunger = color.White.."You are "..color.Red.."hungry !"..color.White.." you should "..color.Yellow.."eat !"
SurviveMessage.Thirsth = color.White.."You are "..color.Red.."thirsty !"..color.White.." you should "..color.Cyan.."drink !"
SurviveMessage.Wet = color.White.."You are "..color.Red.."wet !"..color.White.." you should "..color.Brown.."to dry off !"
SurviveMessage.Freeze = color.White.."You are "..color.Red.."frozen !"..color.White.." you should "..color.Orange.."warm up !"
SurviveMessage.Sleep = color.White.."You "..color.Green.."rest ."
SurviveMessage.Eat = color.White.."You "..color.Yellow.."eat ."
SurviveMessage.Drink = color.White.."You "..color.Cyan.."drink ."

---------------
-- JSON-DATA --
---------------
local DrinkingData = jsonInterface.load("custom/TrueSurvive/DataBaseAlch.json")
local DiningData = jsonInterface.load("custom/TrueSurvive/DataBaseIngr.json")
local SleepingData = jsonInterface.load("custom/TrueSurvive/DataBaseBed.json")

--------------
-- FUNCTION --
--------------
local function CheckCustomVariable(pid)
	local TimeWorld = os.time()
	local customVariable = Players[pid].data.customVariables.TrueSurvive	
	if not customVariable then
		Players[pid].data.customVariables.TrueSurvive = {
			SleepTime = 0,
			SleepWorld = TimeWorld,
			SleepTimeMax = config.sleepTime,
			HungerTime = 0,
			HungerWorld = TimeWorld,
			HungerTimeMax = config.eatTime,
			ThirsthTime = 0,
			ThirstWorld = TimeWorld,
			ThirsthTimeMax = config.drinkTime,
			Rain = 0,
			RainMax = config.rainMax,
			Cold = 0,
			ColdMax = config.coldMax
		}
		customVariable = Players[pid].data.customVariables.TrueSurvive
	else
		if customVariable.HungerTimeMax ~= config.eatTime then
			customVariable.HungerTimeMax = config.eatTime
		end
		if customVariable.ThirsthTimeMax ~= config.drinkTime then
			customVariable.ThirsthTimeMax = config.drinkTime
		end
		if customVariable.SleepTimeMax ~= config.sleepTime then
			customVariable.SleepTimeMax = config.sleepTime
		end
		if not customVariable.Rain then
			customVariable.Rain = 0
			customVariable.RainMax = config.rainMax
		end
		if not customVariable.Cold then
			customVariable.Cold = 0
			customVariable.ColdMax = config.coldMax
		end			
		if customVariable.RainMax ~= config.rainMax then
			customVariable.RainMax = config.rainMax
		end			
		if customVariable.ColdMax ~= config.coldMax then
			customVariable.ColdMax = config.coldMax
		end		
	end
	return customVariable
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

------------
-- METHOD --
------------
local TrueSurvive = {}

TrueSurvive.OnServerInit = function(eventStatus)
	local recordTable
	local recordStoreSpells = RecordStores["spell"]

	recordTable = {
	  name = "Digestion",
	  subtype = 1,
	  cost = 1,
	  flags = 0,
	  effects = {{
		  id = 75,
		  attribute = -1,
		  skill = -1,
		  rangeType = 0,
		  area = 0,
		  duration = 0,
		  magnitudeMax = 1,
		  magnitudeMin = 1
		}}
	}
	recordStoreSpells.data.permanentRecords["true_survive_digestion"] = recordTable

	recordTable = {
	  name = "Hydrate",
	  subtype = 1,
	  cost = 1,
	  flags = 0,
	  effects = {{
		  id = 76,
		  attribute = -1,
		  skill = -1,
		  rangeType = 0,
		  area = 0,
		  duration = 1,
		  magnitudeMax = 1,
		  magnitudeMin = 1
		}}
	}
	recordStoreSpells.data.permanentRecords["true_survive_hydrated"] = recordTable

	recordTable = {
	  name = "Rests",
	  subtype = 1,
	  cost = 1,
	  flags = 0,
	  effects = {{
		  id = 77,
		  attribute = -1,
		  skill = -1,
		  rangeType = 0,
		  area = 0,
		  duration = 1,
		  magnitudeMax = 1,
		  magnitudeMin = 1
		}}
	}
	recordStoreSpells.data.permanentRecords["true_survive_rests"] = recordTable
	
	recordTable = {
	  name = "Thirsty",
	  subtype = 1,
	  cost = 1,
	  flags = 0,
	  effects = {{
		  id = 17,
		  attribute = 1,
		  skill = -1,
		  rangeType = 0,
		  area = 0,
		  duration = -1,
		  magnitudeMax = config.debuffDrink,
		  magnitudeMin = config.debuffDrink
		}}
	}
	recordStoreSpells.data.permanentRecords["true_survive_thirsth"] = recordTable

	recordTable = {
	  name = "Hungry",
	  subtype = 1,
	  cost = 1,
	  flags = 0,
	  effects = {{
		  id = 17,
		  attribute = 5,
		  skill = -1,
		  rangeType = 0,
		  area = 0,
		  duration = -1,
		  magnitudeMax = config.debuffEat,
		  magnitudeMin = config.debuffEat
		},{
		  id = 17,
		  attribute = 2,
		  skill = -1,
		  rangeType = 0,
		  area = 0,
		  duration = -1,
		  magnitudeMax = config.debuffEat,
		  magnitudeMin = config.debuffEat
		},{
		  id = 17,
		  attribute = 3,
		  skill = -1,
		  rangeType = 0,
		  area = 0,
		  duration = -1,
		  magnitudeMax = config.debuffEat,
		  magnitudeMin = config.debuffEat
		}}
	}
	recordStoreSpells.data.permanentRecords["true_survive_hunger"] = recordTable

	recordTable = {
	  name = "Tired",
	  subtype = 1,
	  cost = 1,
	  flags = 0,
	  effects = {{
		  id = 17,
		  attribute = 4,
		  skill = -1,
		  rangeType = 0,
		  area = 0,
		  duration = -1,
		  magnitudeMax = config.debuffSleep,
		  magnitudeMin = config.debuffSleep
		}}
	}
	recordStoreSpells.data.permanentRecords["true_survive_fatigue"] = recordTable

	recordTable = {
	  name = "Wet",
	  subtype = 1,
	  cost = 1,
	  flags = 0,
	  effects = {{
		  id = 17,
		  attribute = 4,
		  skill = -1,
		  rangeType = 0,
		  area = 0,
		  duration = -1,
		  magnitudeMax = config.debuffWet,
		  magnitudeMin = config.debuffWet
		}}
	}
	recordStoreSpells.data.permanentRecords["true_survive_wet"] = recordTable
	
	recordTable = {
	  name = "Frozen",
	  subtype = 1,
	  cost = 1,
	  flags = 0,
	  effects = {{
		  id = 17,
		  attribute = 1,
		  skill = -1,
		  rangeType = 0,
		  area = 0,
		  duration = -1,
		  magnitudeMax = config.debuffFrozen,
		  magnitudeMin = config.debuffFrozen
		}}
	}
	recordStoreSpells.data.permanentRecords["true_survive_freeze"] = recordTable
	
	recordStoreSpells:Save()
	recordTable = nil
end

TrueSurvive.OnPlayerAuthentified = function(eventStatus, pid)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
		local customVariable = CheckCustomVariable(pid)
		customVariable.SleepWorld = os.time() - customVariable.SleepTime
		customVariable.HungerWorld = os.time() - customVariable.HungerTime
		customVariable.ThirstWorld = os.time() - customVariable.ThirsthTime		
	end
end

TrueSurvive.OnCheckTimePlayers = function(pid)
	local TimeWorld = os.time()
	tes3mp.ReadReceivedWorldstate()
	local regionName = string.lower(tes3mp.GetWeatherRegion())
	local customVariable = CheckCustomVariable(pid)	
	local tableSpellPlayer = {}
	for slot, spellId in pairs(Players[pid].data.spellbook) do
		tableSpellPlayer[spellId] = true
	end
	
	if config.staff == true and Players[pid]:IsServerStaff() then
		customVariable.SleepTime = 0
		customVariable.HungerTime = 0
		customVariable.ThirsthTime = 0
		customVariable.Rain = 0
		customVariable.Cold = 0	
	else		
		customVariable.HungerTime = TimeWorld - customVariable.HungerWorld
		customVariable.ThirsthTime = TimeWorld - customVariable.ThirstWorld
		customVariable.SleepTime = TimeWorld - customVariable.SleepWorld
		
		if tes3mp.IsInExterior(pid) == true then 
			if WorldInstance.storedRegions[regionName] and WorldInstance.storedRegions[regionName].currentWeather then
				if WorldInstance.storedRegions[regionName].currentWeather == enumerations.weather.RAIN then	
					customVariable.Rain = customVariable.Rain + 5
				elseif WorldInstance.storedRegions[regionName].currentWeather == enumerations.weather.THUNDER then	
					customVariable.Rain = customVariable.Rain + 10	
				elseif WorldInstance.storedRegions[regionName].currentWeather == enumerations.weather.SNOW then	
					customVariable.Rain = customVariable.Cold + 5	
				elseif WorldInstance.storedRegions[regionName].currentWeather == enumerations.weather.BLIZZARD then
					customVariable.Rain = customVariable.Cold + 10			
				elseif WorldInstance.storedRegions[regionName].currentWeather == enumerations.weather.CLEAR then	
					customVariable.Rain = customVariable.Rain - 5
					customVariable.Cold = customVariable.Cold - 5				
				end
			end
		else
			customVariable.Rain = customVariable.Rain - 5
			customVariable.Cold = customVariable.Cold - 5		
		end
		
		if customVariable.HungerTime > customVariable.HungerTimeMax then
			customVariable.HungerTime = customVariable.HungerTimeMax		
		end
		
		if customVariable.ThirsthTime > customVariable.ThirsthTimeMax then
			customVariable.ThirsthTime = customVariable.ThirsthTimeMax		
		end

		if customVariable.SleepTime > customVariable.SleepTimeMax then
			customVariable.SleepTime = customVariable.SleepTimeMax		
		end
	end
	
	if customVariable.SleepTime >= customVariable.SleepTimeMax then
		if tableSpellPlayer["true_survive_rests"] then
			logicHandler.RunConsoleCommandOnPlayer(pid, "player->removespell true_survive_rests", false)
		end	
		if tableSpellPlayer["true_survive_fatigue"] then		
			if Players[pid].data.character.gender == 1 then
				TrueSurvive.PlaySound(pid, "NOM_sleep_m")
			elseif Players[pid].data.character.gender == 0 then
				TrueSurvive.PlaySound(pid, "NOM_sleep_f")
			end				
			logicHandler.RunConsoleCommandOnPlayer(pid, "FadeOut, 2", false)
			logicHandler.RunConsoleCommandOnPlayer(pid, "Fadein, 2", false)			
		else
			tes3mp.MessageBox(pid, -1, SurviveMessage.Fatigue)
			if Players[pid].data.character.gender == 1 then
				TrueSurvive.PlaySound(pid, "NOM_sleep_m")
			elseif Players[pid].data.character.gender == 0 then
				TrueSurvive.PlaySound(pid, "NOM_sleep_f")
			end
			logicHandler.RunConsoleCommandOnPlayer(pid, "player->addspell true_survive_fatigue", false)
			logicHandler.RunConsoleCommandOnPlayer(pid, "FadeOut, 2", false)
			logicHandler.RunConsoleCommandOnPlayer(pid, "Fadein, 2", false)			
		end	
	elseif customVariable.SleepTime >= (customVariable.SleepTimeMax / 2) and customVariable.SleepTime < customVariable.SleepTimeMax then
		if tableSpellPlayer["true_survive_rests"] then	
			logicHandler.RunConsoleCommandOnPlayer(pid, "player->removespell true_survive_rests", false)
		end	
	end

	if customVariable.HungerTime >= customVariable.HungerTimeMax then	
		if tableSpellPlayer["true_survive_digestion"] then		
			logicHandler.RunConsoleCommandOnPlayer(pid, "player->removespell true_survive_digestion", false)
		end	
		if not tableSpellPlayer["true_survive_hunger"] then	
			tes3mp.MessageBox(pid, -1, SurviveMessage.Hunger)					
			logicHandler.RunConsoleCommandOnPlayer(pid, "player->addspell true_survive_hunger", false)
			if Players[pid].data.character.gender == 1 then
				TrueSurvive.PlaySound(pid, "fv_thirst_m")
			elseif Players[pid].data.character.gender == 0 then
				TrueSurvive.PlaySound(pid, "fv_thirst_f")
			end						
		end			
	elseif customVariable.HungerTime >= (customVariable.HungerTimeMax / 2) and customVariable.HungerTime < customVariable.HungerTimeMax then
		if tableSpellPlayer["true_survive_digestion"] then	
			logicHandler.RunConsoleCommandOnPlayer(pid, "player->removespell true_survive_digestion", false)
		end	
	end

	if customVariable.ThirsthTime >= customVariable.ThirsthTimeMax then	
		if tableSpellPlayer["true_survive_hydrated"] then	
			logicHandler.RunConsoleCommandOnPlayer(pid, "player->removespell true_survive_hydrated", false)
		end			
		if not tableSpellPlayer["true_survive_thirsth"] then									
			tes3mp.MessageBox(pid, -1, SurviveMessage.Thirsth)
			logicHandler.RunConsoleCommandOnPlayer(pid, "player->addspell true_survive_thirsth", false)
			if Players[pid].data.character.gender == 1 then
				TrueSurvive.PlaySound(pid, "fv_thirst_m")
			elseif Players[pid].data.character.gender == 0 then
				TrueSurvive.PlaySound(pid, "fv_thirst_f")
			end						
		end		
	elseif customVariable.ThirsthTime >= (customVariable.ThirsthTimeMax / 2) and customVariable.ThirsthTime < customVariable.ThirsthTimeMax then
		if tableSpellPlayer["true_survive_hydrated"] then
			logicHandler.RunConsoleCommandOnPlayer(pid, "player->removespell true_survive_hydrated", false)
		end	

	end

	if customVariable.Rain >= customVariable.RainMax then		
		if not tableSpellPlayer["true_survive_wet"] then									
			tes3mp.MessageBox(pid, -1, trad.Wet)
			logicHandler.RunConsoleCommandOnPlayer(pid, "player->addspell true_survive_wet", false)					
		end	
	else
		if tableSpellPlayer["true_survive_wet"] then
			logicHandler.RunConsoleCommandOnPlayer(pid, "player->removespell true_survive_wet", false)	
		end
	end

	if customVariable.Cold >= customVariable.ColdMax then		
		if not tableSpellPlayer["true_survive_freeze"] then									
			tes3mp.MessageBox(pid, -1, trad.Freeze)
			logicHandler.RunConsoleCommandOnPlayer(pid, "player->addspell true_survive_freeze", false)					
		end	
	else
		if tableSpellPlayer["true_survive_freeze"] then
			logicHandler.RunConsoleCommandOnPlayer(pid, "player->removespell true_survive_freeze", false)	
		end
	end
	
	Players[pid]:QuicksaveToDrive()
end

TrueSurvive.OnActivatedObject = function(eventStatus, pid, cellDescription, objects)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
		local ObjectIndex
		local ObjectRefid
		for _, object in pairs(objects) do
			ObjectIndex = object.uniqueIndex
			ObjectRefid = object.refId
		end	
		if ObjectIndex ~= nil and ObjectRefid ~= nil then
			Players[pid].data.targetRefId = ObjectRefid
			Players[pid].data.targetUniqueIndex = ObjectIndex
			Players[pid].data.targetCellDescription = cellDescription
			
			if DiningData[string.lower(ObjectRefid)] then
				Players[pid].currentCustomMenu = "survive hunger"
				menuHelper.DisplayMenu(pid, Players[pid].currentCustomMenu)					
				return customEventHooks.makeEventStatus(false, false) 
			end				
			
			if DrinkingData[string.lower(ObjectRefid)] then
				Players[pid].currentCustomMenu = "survive drink"
				menuHelper.DisplayMenu(pid, Players[pid].currentCustomMenu)	
				return customEventHooks.makeEventStatus(false, false) 
			end		
			
			if SleepingData[string.lower(ObjectRefid)]then
				Players[pid].currentCustomMenu = "survive sleep"
				menuHelper.DisplayMenu(pid, Players[pid].currentCustomMenu)	
				return customEventHooks.makeEventStatus(false, false) 
			end			
		end
	end
end

TrueSurvive.OnPlayerEvent = function(eventStatus, pid)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
		TrueSurvive.OnCheckTimePlayers(pid)
	end
end

TrueSurvive.OnHungerObject = function(pid, cellDescription, uniqueIndex)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
		local countObject = 1
		if LoadedCells[cellDescription].data.objectData[uniqueIndex] and LoadedCells[cellDescription].data.objectData[uniqueIndex].count then
			countObject = LoadedCells[cellDescription].data.objectData[uniqueIndex].count
		end
		local totalCount = config.eatRange * countObject
		logicHandler.RunConsoleCommandOnPlayer(pid, "player->removespell true_survive_hunger", false)
		logicHandler.RunConsoleCommandOnPlayer(pid, "player->addspell true_survive_digestion", false)
		if os.time() - (Players[pid].data.customVariables.TrueSurvive.HungerWorld + totalCount) <= 0 then 
			Players[pid].data.customVariables.TrueSurvive.HungerWorld = os.time()		
		else
			Players[pid].data.customVariables.TrueSurvive.HungerWorld = Players[pid].data.customVariables.TrueSurvive.HungerWorld + totalCount	
		end	
		tes3mp.MessageBox(pid, -1, SurviveMessage.Eat..color.White.."\nTime : "..color.Green..os.time() - (Players[pid].data.customVariables.TrueSurvive.HungerWorld)..color.White.." / "..color.Red..Players[pid].data.customVariables.TrueSurvive.HungerTimeMax)		
		TrueSurvive.OnCheckTimePlayers(pid)
	end	
end

TrueSurvive.OnDrinkObject = function(pid, cellDescription, uniqueIndex)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
		local countObject = 1
		if LoadedCells[cellDescription].data.objectData[uniqueIndex] and LoadedCells[cellDescription].data.objectData[uniqueIndex].count then
			countObject = LoadedCells[cellDescription].data.objectData[uniqueIndex].count
		end
		local totalCount = config.drinkRange * countObject	
		logicHandler.RunConsoleCommandOnPlayer(pid, "player->removespell true_survive_thirsth", false)
		logicHandler.RunConsoleCommandOnPlayer(pid, "player->addspell true_survive_hydrated", false)
		if os.time() - (Players[pid].data.customVariables.TrueSurvive.ThirstWorld + totalCount) <= 0 then 
			Players[pid].data.customVariables.TrueSurvive.ThirstWorld = os.time()		
		else
			Players[pid].data.customVariables.TrueSurvive.ThirstWorld = Players[pid].data.customVariables.TrueSurvive.ThirstWorld + totalCount	
		end
		tes3mp.MessageBox(pid, -1, SurviveMessage.Drink..color.White.."\nTime : "..color.Green..os.time() - (Players[pid].data.customVariables.TrueSurvive.ThirstWorld)..color.White.." / "..color.Red..Players[pid].data.customVariables.TrueSurvive.ThirsthTimeMax)		
		TrueSurvive.OnCheckTimePlayers(pid)
	end	
end

TrueSurvive.OnSleepObject = function(pid)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
		logicHandler.RunConsoleCommandOnPlayer(pid, "player->removespell true_survive_fatigue", false)	
		logicHandler.RunConsoleCommandOnPlayer(pid, "player->addspell true_survive_rests", false)
		logicHandler.RunConsoleCommandOnPlayer(pid, "FadeOut, 2", false)
		logicHandler.RunConsoleCommandOnPlayer(pid, "Fadein, 5", false)
		tes3mp.MessageBox(pid, -1, SurviveMessage.Sleep)	
		Players[pid].data.customVariables.TrueSurvive.SleepWorld = os.time()
		TrueSurvive.OnCheckTimePlayers(pid)
	end
end

TrueSurvive.OnSleepObjectVanilla = function(pid)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then		
		logicHandler.RunConsoleCommandOnPlayer(pid, "ShowRestMenu", false)
	end
end

TrueSurvive.PlaySound = function(pid, sound)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
		logicHandler.RunConsoleCommandOnPlayer(pid, "playsound "..'"'..sound..'"')
	end
end

TrueSurvive.MainMenu = function(pid)
    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
		Players[pid].currentCustomMenu = "survive menu"
		menuHelper.DisplayMenu(pid, Players[pid].currentCustomMenu)	
	end
end

TrueSurvive.OnPlayerDeath = function(eventStatus, pid)
    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
		logicHandler.RunConsoleCommandOnPlayer(pid, "player->removespell true_survive_fatigue", false)	
		logicHandler.RunConsoleCommandOnPlayer(pid, "player->removespell true_survive_thirsth", false)
		logicHandler.RunConsoleCommandOnPlayer(pid, "player->removespell true_survive_hunger", false)
		Players[pid].data.customVariables.TrueSurvive.SleepWorld = os.time()
		Players[pid].data.customVariables.TrueSurvive.HungerWorld = os.time()
		Players[pid].data.customVariables.TrueSurvive.ThirstWorld = os.time()
		TrueSurvive.OnCheckTimePlayers(pid)
    end
end

TrueSurvive.CleanCellObject = function(pid, cellDescription, uniqueIndex, forEveryone)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
		CleanCellObject(pid, cellDescription, uniqueIndex, forEveryone)
	end
end

-----------
-- EVENT --
-----------
customEventHooks.registerValidator("OnObjectActivate", TrueSurvive.OnActivatedObject)
customEventHooks.registerHandler("OnObjectActivate", TrueSurvive.OnPlayerEvent)
customEventHooks.registerHandler("OnPlayerEquipment", TrueSurvive.OnPlayerEvent)
customEventHooks.registerHandler("OnPlayerInventory", TrueSurvive.OnPlayerEvent)
customEventHooks.registerHandler("OnPlayerItemUse", TrueSurvive.OnPlayerEvent)
customEventHooks.registerHandler("OnPlayerCellChange", TrueSurvive.OnPlayerEvent)
customEventHooks.registerHandler("OnPlayerDeath", TrueSurvive.OnPlayerDeath)
customEventHooks.registerHandler("OnPlayerAuthentified", TrueSurvive.OnPlayerAuthentified)
customEventHooks.registerHandler("OnServerInit", TrueSurvive.OnServerInit)
customCommandHooks.registerCommand("survive", TrueSurvive.MainMenu)

return TrueSurvive
