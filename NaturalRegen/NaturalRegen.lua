--[[
NaturalRegen by Rickoff
tes3mp 0.8.1
---------------------------
DESCRIPTION :
natural regen health, mana, stamina
---------------------------
INSTALLATION:
Save the file as NaturalRegen.lua inside your server/scripts/custom folder.
Edits to customScripts.lua
NaturalRegen = require("custom.NaturalRegen")
]]
local cfg = {
	OnServerInit = true,
	MagnitudeHealth = 1,
	MagnitudeStamina = 1,
	MagnitudeMana = 1,
	TabSpell = {
		natural_regen_health = true,
		natural_regen_stamina = true,
		natural_regen_mana = true
	}
}

local NaturalRegen = {}

NaturalRegen.OnServerInit = function(eventStatus)

	if cfg.OnServerInit then
	
		local spellCustom = jsonInterface.load("recordstore/spell.json")
		local recordStore = RecordStores["spell"]

		if cfg.TabSpell["natural_regen_health"] then
			local recordTable = {
			  name = "Health Regen",
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
				  magnitudeMax = cfg.MagnitudeHealth,
				  magnitudeMin = cfg.MagnitudeHealth
				}}
			}
			recordStore.data.permanentRecords["natural_regen_health"] = recordTable
		end

		if cfg.TabSpell["natural_regen_mana"] then
			local recordTable = {
			  name = "Mana Regen",
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
				  magnitudeMax = cfg.MagnitudeMana,
				  magnitudeMin = cfg.MagnitudeMana
				}}
			}
			recordStore.data.permanentRecords["natural_regen_mana"] = recordTable
		end
		
		if cfg.TabSpell["natural_regen_stamina"] then
			local recordTable = {
			  name = "Stamina Regen",
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
				  magnitudeMax = cfg.MagnitudeStamina,
				  magnitudeMin = cfg.MagnitudeStamina
				}}
			}
			recordStore.data.permanentRecords["natural_regen_stamina"] = recordTable
		end
		
		recordStore:Save()

	end
end	

NaturalRegen.OnPlayerAuthentified = function(eventStatus, pid)
	for spellId, bool in pairs(cfg.TabSpell) do
		if bool == true then
			if not tableHelper.containsValue(Players[pid].data.spellbook, spellId, true) then	
				logicHandler.RunConsoleCommandOnPlayer(pid, "player->addspell "..spellId, false)		
			end
		elseif bool == false then
			if tableHelper.containsValue(Players[pid].data.spellbook, spellId, true) then	
				logicHandler.RunConsoleCommandOnPlayer(pid, "player->removespell "..spellId, false)		
			end		
		end
	end
end

customEventHooks.registerHandler("OnServerInit", NaturalRegen.OnServerInit)
customEventHooks.registerHandler("OnPlayerAuthentified", NaturalRegen.OnPlayerAuthentified)

return NaturalRegen
