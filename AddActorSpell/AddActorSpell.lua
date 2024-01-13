--[[
AddActorSpell
tes3mp 0.8.1
------------
INSTALLATION :
Edits to customScripts.lua add in :
require("custom.AddActorSpell")
]]
local cfg = {
	allActors = true --add spell for all actors true/false
}

local actorList = {--add modify the actor identifiers of the list example
	["refid01"] = true,--The refId(lowercase string) of the actor = true/false
	["refid02"] = false	
}

local spellsTable = {--add/modify spells from list example
	["spellId01"] = {--The spellId of the spell
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
	["spellId02"] = {
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

local function CheckValidActor(cellDescription, uniqueIndex)
	if LoadedCells[cellDescription].data.objectData[uniqueIndex] 
	and not LoadedCells[cellDescription].data.objectData[uniqueIndex].deathState
	and not LoadedCells[cellDescription].data.objectData[uniqueIndex].summon then
		return true
	end
	return false
end

local function SendActorSpellsActive(pid, cellDescription, uniqueIndexList)
    local actorCount = 0
    tes3mp.ClearActorList()
    tes3mp.SetActorListPid(pid)
    tes3mp.SetActorListCell(cellDescription)
    for _, uniqueIndex in ipairs(uniqueIndexList) do
		local splitIndex = uniqueIndex:split("-")
		tes3mp.SetActorRefNum(splitIndex[1])
		tes3mp.SetActorMpNum(splitIndex[2])
		tes3mp.SetActorSpellsActiveAction(enumerations.spellbook.ADD)
		for spellId, spellInstances in pairs(LoadedCells[cellDescription].data.objectData[uniqueIndex].spellsActive) do
			for spellInstanceIndex, spellInstanceValues in pairs(spellInstances) do
				for effectIndex, effectTable in pairs(spellInstanceValues.effects) do
					tes3mp.AddActorSpellActiveEffect(effectTable.id, effectTable.magnitude,
						effectTable.duration, effectTable.timeLeft, effectTable.arg)
				end
				tes3mp.AddActorSpellActive(spellId, spellInstanceValues.displayName,
					spellInstanceValues.stackingState)
			end
		end
		tes3mp.AddActor()
		actorCount = actorCount + 1
    end
    if actorCount > 0 then
        tes3mp.SendActorSpellsActiveChanges()
    end
end

local function AddActorSpellsActive(pid, cellDescription, uniqueIndexList)
	local AddSpell = false
	local uniqueIndexTable = {}
	for _, uniqueIndex in ipairs(uniqueIndexList) do
		if CheckValidActor(cellDescription, uniqueIndex) then		
			local objectData = LoadedCells[cellDescription].data.objectData[uniqueIndex]
			if cfg.allActors or actorList[string.lower(objectData.refId)] then
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
						table.insert(uniqueIndexTable, uniqueIndex)
					end
				end
			end
		end
	end
	if AddSpell then
		SendActorSpellsActive(pid, cellDescription, uniqueIndexTable)
	end
end
customEventHooks.registerHandler("OnActorList", function(eventStatus, pid, cellDescription, actors)
	if LoadedCells[cellDescription] then
		AddActorSpellsActive(pid, cellDescription, LoadedCells[cellDescription].data.packets.actorList)
	end
end)

customEventHooks.registerValidator("OnActorCellChange", function(eventStatus, pid, cellDescription)
	if LoadedCells[cellDescription] then
		tes3mp.ReadReceivedActorList()	
		for actorIndex = 0, tes3mp.GetActorListSize() - 1 do
			local uniqueIndex = tes3mp.GetActorRefNum(actorIndex) .. "-" .. tes3mp.GetActorMpNum(actorIndex)	
			if uniqueIndex and uniqueIndex ~= "0-0" then
				AddActorSpellsActive(pid, cellDescription, {uniqueIndex})
			end
		end
	end
end)

customEventHooks.registerHandler("OnPlayerCellChange", function(eventStatus, pid, playerPacket, previousCellDescription)
	local cellDescription = playerPacket.location.cell
	if LoadedCells[cellDescription] then
		AddActorSpellsActive(pid, cellDescription, LoadedCells[cellDescription].data.packets.actorList)
	end
end)
