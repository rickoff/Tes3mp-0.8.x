--[[
AddActorSpell
tes3mp 0.8.1
------------
INSTALLATION :
Edits to customScripts.lua add in :
require("custom.AddActorSpell")
]]

local actorList = {--add modify the actor identifiers of the list example
	["refId 01"] = true,--The refId of the actor = true/false
	["refId 02"] = false	
}

local spellsTable = {--add/modify spells from list example
	["spellId 01"] = {--The spellId of the spell
		displayName = "Exemple01",--The displayName of the spell
		stackingState = false,--Whether the spell should stack with other instances of itself
		effects = {
			{
				id = 117,--The id of the effect, refer to server/scripts/enumerations.lua
				magnitude = 100,--The magnitude of the effect
				duration = 999,--The duration of the effect
				timeLeft = 999,--The timeLeft for the effect
				arg = -1--The arg of the effect when applicable, e.g. the skill used for Fortify Skill or the attribute used for Fortify Attribute
			}
		}
	},
	["spellId 02"] = {
		displayName = "Exemple02",
		stackingState = true,
		effects = {
			{
				id = 117,
				magnitude = 100,
				duration = 999,
				timeLeft = 999,
				arg = -1
			},
			{
				id = 116,
				magnitude = 50,
				duration = 60,
				timeLeft = 60,
				arg = -1
			}			
		}
	}	
}

customEventHooks.registerHandler("OnPlayerCellChange", function(eventStatus, pid, playerPacket, previousCellDescription)
	local AddSpell = false
	local cellDescription = playerPacket.location.cell
	for _, uniqueIndex in ipairs(LoadedCells[cellDescription].data.packets.actorList) do
		if LoadedCells[cellDescription].data.objectData[uniqueIndex] then	
			local objectData = LoadedCells[cellDescription].data.objectData[uniqueIndex]
			if actorList[string.lower(objectData.refId)] then
				for spellId, spellTable in pairs(spellsTable) do			
					if not objectData.spellsActive then objectData.spellsActive = {} end
					if not objectData.spellsActive[spellId] then
						tableHelper.insertValueIfMissing(LoadedCells[cellDescription].data.packets.spellsActive, uniqueIndex)
						objectData.spellsActive[spellId] = {}			
						objectData.spellsActive[spellId][1] = {
							displayName = spellTable.displayName,
							stackingState = spellTable.stackingState,
							effects = tableHelper.deepCopy(spellTable.effects),
							startTime = os.time()
						}
						AddSpell = true					
					end
				end
			end
		end
	end
	if AddSpell then	
		local objectsData = LoadedCells[cellDescription].data.objectData
		local packetSpell = LoadedCells[cellDescription].data.packets.spellsActive
		LoadedCells[cellDescription]:LoadActorSpellsActive(pid, objectsData, packetSpell)
	end
end)
