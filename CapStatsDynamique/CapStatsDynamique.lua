--[[
CapStatsDynamic
tes3mp 0.8.0
---------------------------
INSTALLATION:
Save the file as CapStatsDynamic.lua inside your server/scripts/custom folder.
Edits to customScripts.lua add in : CapStatsDynamic = require("custom.CapStatsDynamic")
---------------------------
]]
local cfg = {
	Health = 250,
	Fatigue = 400,
	Magicka = 600
}

local function StartCheck(pid)
	local messageMagicka
	local messageFatigue
	local messageHealth
	
	local playerPacketStats = packetReader.GetPlayerPacketTables(pid, "PlayerStatsDynamic")	
	local PlayerHealthBase = playerPacketStats.stats.healthBase			
	local PlayerHealthCurrent = playerPacketStats.stats.healthCurrent
	local PlayerFatigueBase = playerPacketStats.stats.fatigueBase
	local PlayerFatigueCurrent = playerPacketStats.stats.fatigueCurrent
	local PlayerMagickaBase = playerPacketStats.stats.magickaBase
	local PlayerMagickaCurrent = playerPacketStats.stats.magickaCurrent
	
	local playerPacketAttribute = packetReader.GetPlayerPacketTables(pid, "PlayerAttribute")
	local StrengthBase = playerPacketAttribute.attributes["Strength"].base
	local IntelligenceBase = playerPacketAttribute.attributes["Intelligence"].base	
	local WillpowerBase = playerPacketAttribute.attributes["Willpower"].base
	local AgilityBase = playerPacketAttribute.attributes["Agility"].base
	local EnduranceBase = playerPacketAttribute.attributes["Endurance"].base
	local StrengthMod = playerPacketAttribute.attributes["Strength"].modifier
	local IntelligenceMod = playerPacketAttribute.attributes["Intelligence"].modifier		
	local WillpowerMod = playerPacketAttribute.attributes["Willpower"].modifier
	local AgilityMod = playerPacketAttribute.attributes["Agility"].modifier
	local EnduranceMod = playerPacketAttribute.attributes["Endurance"].modifier

	local Race = Players[pid].data.character.race
	local RacialMod = 0
	if Race == "Breton" then
		RacialMod = 0.5
	elseif Race == "High Elf" then
		RacialMod = 1.5 		
	end
	local BirthSign = Players[pid].data.character.birthsign
	local BirthSignMod = 0
	if BirthSign == "fay" then
		BirthSignMod = 0.5
	elseif BirthSign == "elfborn" then
		BirthSignMod = 1.5	
	elseif BirthSign == "atronach" then
		BirthSignMod = 2.0	
	end
	
	local CalculMagicka = ((IntelligenceBase + IntelligenceMod) * (1 + RacialMod + BirthSignMod))
	if CalculMagicka > cfg.Magicka then
		local attributeId = tes3mp.GetAttributeId("Intelligence")
		tes3mp.ClearAttributeModifier(pid, attributeId)
		Players[pid]:LoadAttributes()		
		Players[pid]:LoadStatsDynamic()			
		messageMagicka = color.DarkBlue.."Your magicka has exceeded the maximum allowed value " ..
			"and been reset to its last recorded one.\n"
	elseif (PlayerMagickaBase > cfg.Magicka) or (PlayerMagickaCurrent > cfg.Magicka) then
		local attributeId = tes3mp.GetAttributeId("Intelligence")
		tes3mp.ClearAttributeModifier(pid, attributeId)
		Players[pid]:LoadAttributes()		
		Players[pid]:LoadStatsDynamic()			
		messageMagicka = color.DarkBlue.."Your magicka has exceeded the maximum allowed value " ..
			"and been reset to its last recorded one.\n"		
	end
	
	local CalculFatigue = (StrengthBase + StrengthMod + WillpowerBase + WillpowerMod + AgilityBase + AgilityMod + EnduranceBase + EnduranceMod)
	if CalculFatigue > cfg.Fatigue then	
		local Value = math.floor(cfg.Fatigue / 4)
		local attributeIdS = tes3mp.GetAttributeId("Strength")
		local attributeIdW = tes3mp.GetAttributeId("Willpower")
		local attributeIdA = tes3mp.GetAttributeId("Agility")	
		local attributeIdE = tes3mp.GetAttributeId("Endurance")	
		tes3mp.ClearAttributeModifier(pid, attributeIdS)
		tes3mp.ClearAttributeModifier(pid, attributeIdW)	
		tes3mp.ClearAttributeModifier(pid, attributeIdA)	
		tes3mp.ClearAttributeModifier(pid, attributeIdE)			
		Players[pid]:LoadAttributes()		
		Players[pid]:LoadStatsDynamic()		
		messageFatigue = color.DarkGreen.."Your fatigue has exceeded the maximum allowed value "..
			"and been reset to its last recorded one.\n"	
	elseif (PlayerFatigueBase > cfg.Fatigue) or (PlayerFatigueCurrent > cfg.Fatigue) then
		local Value = math.floor(cfg.Fatigue / 4)
		local attributeIdS = tes3mp.GetAttributeId("Strength")
		local attributeIdW = tes3mp.GetAttributeId("Willpower")
		local attributeIdA = tes3mp.GetAttributeId("Agility")	
		local attributeIdE = tes3mp.GetAttributeId("Endurance")	
		tes3mp.ClearAttributeModifier(pid, attributeIdS)
		tes3mp.ClearAttributeModifier(pid, attributeIdW)	
		tes3mp.ClearAttributeModifier(pid, attributeIdA)	
		tes3mp.ClearAttributeModifier(pid, attributeIdE)			
		Players[pid]:LoadAttributes()		
		Players[pid]:LoadStatsDynamic()		
		messageFatigue = color.DarkGreen.."Your fatigue has exceeded the maximum allowed value "..
			"and been reset to its last recorded one.\n"				
	end
	
	if (PlayerHealthBase > cfg.Health) or (PlayerHealthCurrent > cfg.Health) then
		messageHealth = color.DarkRed.."Your health has exceeded the maximum allowed value "..
			"and been reset to its last recorded one.\n"
		Players[pid]:LoadStatsDynamic()			
	end

	if messageMagicka then
		tes3mp.SendMessage(pid, messageMagicka)	
	end
	
	if messageFatigue then
		tes3mp.SendMessage(pid, messageFatigue)	
	end
	
	if messageHealth then
		tes3mp.SendMessage(pid, messageHealth)	
	end	
end

local CapStatsDynamic = {}

CapStatsDynamic.OnPlayerEvent = function(eventStatus, pid)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
		StartCheck(pid)
	end
end

CapStatsDynamic.OnPlayerAuthentified = function(eventStatus, pid)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
		local messageMagicka
		local messageFatigue
		local messageHealth
		
		local playerPacketStats = packetReader.GetPlayerPacketTables(pid, "PlayerStatsDynamic")	
		local PlayerHealthBase = playerPacketStats.stats.healthBase			
		local PlayerHealthCurrent = playerPacketStats.stats.healthCurrent
		local PlayerFatigueBase = playerPacketStats.stats.fatigueBase
		local PlayerFatigueCurrent = playerPacketStats.stats.fatigueCurrent
		local PlayerMagickaBase = playerPacketStats.stats.magickaBase
		local PlayerMagickaCurrent = playerPacketStats.stats.magickaCurrent
		
		local playerPacketAttribute = packetReader.GetPlayerPacketTables(pid, "PlayerAttribute")
		local StrengthBase = playerPacketAttribute.attributes["Strength"].base
		local IntelligenceBase = playerPacketAttribute.attributes["Intelligence"].base	
		local WillpowerBase = playerPacketAttribute.attributes["Willpower"].base
		local AgilityBase = playerPacketAttribute.attributes["Agility"].base
		local Endurancebase = playerPacketAttribute.attributes["Endurance"].base
		local StrengthMod = playerPacketAttribute.attributes["Strength"].modifier
		local IntelligenceMod = playerPacketAttribute.attributes["Intelligence"].modifier		
		local WillpowerMod = playerPacketAttribute.attributes["Willpower"].modifier
		local AgilityMod = playerPacketAttribute.attributes["Agility"].modifier
		local EnduranceMod = playerPacketAttribute.attributes["Endurance"].modifier

		local Race = Players[pid].data.character.race
		local RacialMod = 0
		if Race == "Breton" then
			RacialMod = 0.5
		elseif Race == "High Elf" then
			RacialMod = 1.5 		
		end
		local BirthSign = Players[pid].data.character.birthsign
		local BirthSignMod = 0
		if BirthSign == "fay" then
			BirthSignMod = 0.5
		elseif BirthSign == "elfborn" then
			BirthSignMod = 1.5	
		elseif BirthSign == "atronach" then
			BirthSignMod = 2.0	
		end		
		local CalculMagicka = ((IntelligenceBase + IntelligenceMod) * (1 + RacialMod + BirthSignMod))
		if CalculMagicka > cfg.Magicka then
			local Value = math.floor(cfg.Magicka / (1 + RacialMod + BirthSignMod))
			local attributeId = tes3mp.GetAttributeId("Intelligence")
			tes3mp.ClearAttributeModifier(pid, attributeId)		
			tes3mp.SetAttributeBase(pid, attributeId, Value)
			tes3mp.SetMagickaBase(pid, cfg.Magicka)
			tes3mp.SetMagickaCurrent(pid, 0)		
			tes3mp.SendAttributes(pid)
			tes3mp.SendStatsDynamic(pid)				
			messageMagicka = color.DarkBlue.."Your magicka has exceeded the maximum allowed value " ..
				"your attributes were recalculated.\n"	
		elseif (PlayerMagickaBase > cfg.Magicka) or (PlayerMagickaCurrent > cfg.Magicka) then
			local Value = math.floor(cfg.Magicka / (1 + RacialMod + BirthSignMod))
			local attributeId = tes3mp.GetAttributeId("Intelligence")
			tes3mp.ClearAttributeModifier(pid, attributeId)		
			tes3mp.SetAttributeBase(pid, attributeId, Value)
			tes3mp.SetMagickaBase(pid, cfg.Magicka)
			tes3mp.SetMagickaCurrent(pid, 0)			
			tes3mp.SendAttributes(pid)
			tes3mp.SendStatsDynamic(pid)		
			messageMagicka = color.DarkBlue.."Your magicka has exceeded the maximum allowed value " ..
				"your attributes were recalculated.\n"				
		end
		
		local CalculFatigue = (StrengthBase + StrengthMod + WillpowerBase + WillpowerMod + AgilityBase + AgilityMod)
		if CalculFatigue > cfg.Fatigue then	
			local Value = math.floor(cfg.Fatigue / 4)
			local attributeIdS = tes3mp.GetAttributeId("Strength")
			local attributeIdW = tes3mp.GetAttributeId("Willpower")
			local attributeIdA = tes3mp.GetAttributeId("Agility")	
			local attributeIdE = tes3mp.GetAttributeId("Endurance")	
			tes3mp.ClearAttributeModifier(pid, attributeIdS)
			tes3mp.ClearAttributeModifier(pid, attributeIdW)	
			tes3mp.ClearAttributeModifier(pid, attributeIdA)	
			tes3mp.ClearAttributeModifier(pid, attributeIdE)			
			tes3mp.SetAttributeBase(pid, attributeIdS, Value)
			tes3mp.SetAttributeBase(pid, attributeIdW, Value)	
			tes3mp.SetAttributeBase(pid, attributeIdA, Value)	
			tes3mp.SetAttributeBase(pid, attributeIdE, Value)	
			tes3mp.SetFatigueBase(pid, cfg.Fatigue)	
			tes3mp.SetFatigueCurrent(pid, 0)			
			tes3mp.SendAttributes(pid)
			tes3mp.SendStatsDynamic(pid)		
			messageFatigue = color.DarkGreen.."Your fatigue has exceeded the maximum allowed value "..
				"your attributes were recalculated.\n"		
		elseif (PlayerFatigueBase > cfg.Fatigue) or (PlayerFatigueCurrent > cfg.Fatigue) then
			local Value = math.floor(cfg.Fatigue / 4)
			local attributeIdS = tes3mp.GetAttributeId("Strength")
			local attributeIdW = tes3mp.GetAttributeId("Willpower")
			local attributeIdA = tes3mp.GetAttributeId("Agility")	
			local attributeIdE = tes3mp.GetAttributeId("Endurance")	
			tes3mp.ClearAttributeModifier(pid, attributeIdS)
			tes3mp.ClearAttributeModifier(pid, attributeIdW)	
			tes3mp.ClearAttributeModifier(pid, attributeIdA)	
			tes3mp.ClearAttributeModifier(pid, attributeIdE)			
			tes3mp.SetAttributeBase(pid, attributeIdS, Value)
			tes3mp.SetAttributeBase(pid, attributeIdW, Value)	
			tes3mp.SetAttributeBase(pid, attributeIdA, Value)	
			tes3mp.SetAttributeBase(pid, attributeIdE, Value)	
			tes3mp.SetFatigueBase(pid, cfg.Fatigue)	
			tes3mp.SetFatigueCurrent(pid, 0)			
			tes3mp.SendAttributes(pid)
			tes3mp.SendStatsDynamic(pid)		
			messageFatigue = color.DarkGreen.."Your fatigue has exceeded the maximum allowed value "..
				"your attributes were recalculated.\n"					

		end
		
		if (PlayerHealthBase > cfg.Health) or (PlayerHealthCurrent > cfg.Health) then
			messageHealth = color.DarkRed.."Your health has exceeded the maximum allowed value "..
				"your attributes were recalculated.\n"	
			tes3mp.SetHealthBase(pid, cfg.Health)	
			tes3mp.SetHealthCurrent(pid, cfg.Health)				
			tes3mp.SendStatsDynamic(pid)			
		end

		if messageMagicka then
			tes3mp.SendMessage(pid, messageMagicka)	
		end
		
		if messageFatigue then
			tes3mp.SendMessage(pid, messageFatigue)	
		end
		
		if messageHealth then
			tes3mp.SendMessage(pid, messageHealth)	
		end	
	end
end

customEventHooks.registerHandler("OnPlayerEquipment", CapStatsDynamic.OnPlayerEvent)
customEventHooks.registerHandler("OnPlayerItemUse", CapStatsDynamic.OnPlayerEvent)
customEventHooks.registerHandler("OnPlayerLevel", CapStatsDynamic.OnPlayerEvent)
customEventHooks.registerHandler("OnPlayerSpellsActive", CapStatsDynamic.OnPlayerEvent)
customEventHooks.registerHandler("OnPlayerAttribute", CapStatsDynamic.OnPlayerEvent)
customEventHooks.registerHandler("OnPlayerAuthentified", CapStatsDynamic.OnPlayerAuthentified)

return CapStatsDynamic
