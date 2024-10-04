--[[
RecallContact
tes3mp 0.8.1
---------------------------
INSTALLATION:
Save the file as RecallContact.lua inside your server/scripts/custom folder.
Edits to customScripts.lua
require("custom.RecallContact")
---------------------------
]]
local cfg = {
	onServerInit = true,
	addSpellsOnAuth = true,
	costMark = 18,
	costRecall = 18
}

local trd = {
	nameMark = "Mark contact",
	nameRecall = "Recall contact",
	noMark = "Impossible to teleport another player without having placed a mark."
}

local function RecallPlayer(pid, pos)   
	tes3mp.SetCell(pid, pos.cellDescription)
	tes3mp.SendCell(pid)
	tes3mp.SetPos(pid, pos.posX, pos.posY, pos.posZ)
	tes3mp.SetRot(pid, pos.rotX, pos.rotZ)				
	tes3mp.SendPos(pid)		
end

local function AddSpell(pid, spellsId)
	local Change = false	
	tes3mp.ClearSpellbookChanges(pid)	
	tes3mp.SetSpellbookChangesAction(pid, enumerations.spellbook.ADD)
	for _, spellId in ipairs(spellsId) do	
		if not tableHelper.containsValue(Players[pid].data.spellbook, spellId) then				
			tes3mp.AddSpell(pid, spellId)			
			table.insert(Players[pid].data.spellbook, spellId)					
			Change = true			
		end		
	end	
	if Change then
		tes3mp.SendSpellbookChanges(pid)		
	end
end

customEventHooks.registerHandler("OnServerInit", function(eventStatus)
	if cfg.onServerInit then
		local recordStoreSpells = RecordStores["spell"]
		local recordTable
		recordTable = {
			name = trd.nameMark,
			cost = cfg.costMark,	  
			subtype = 0,
			flags = 1,
			effects = {
				{
					attribute = -1,
					area = 0,
					duration = 0,
					id = 60,
					rangeType = 0,
					skill = -1,
					magnitudeMax = 0,
					magnitudeMin = 0
				}
			}
		}
		recordStoreSpells.data.permanentRecords["mark_contact"] = recordTable
		recordTable = {
			name = trd.nameRecall,
			cost = cfg.costRecall,		
			subtype = 0,
			flags = 1,
			effects = {
				{
					attribute = -1,
					area = 0,
					duration = 0,
					id = 61,
					rangeType = 1,
					skill = -1,
					magnitudeMax = 0,
					magnitudeMin = 0
				}
			}
		}
		recordStoreSpells.data.permanentRecords["recall_contact"] = recordTable
		recordStoreSpells:Save()
	end
end)

customEventHooks.registerHandler("OnPlayerSpellsActive", function(eventStatus, pid, playerPacket)
	for spellId, spellInstances in pairs(playerPacket.spellsActive) do
		if spellId == "recall_contact" then
			for _, spellInstance in ipairs(spellInstances) do
				if spellInstance.caster.pid then
					local casterPid = spellInstance.caster.pid	
					if casterPid ~= -1 and pid ~= casterPid then
						if Players[casterPid].data.customVariables.markContact then
							RecallPlayer(pid, Players[casterPid].data.customVariables.markContact)
						else
							tes3mp.MessageBox(pid, -1, trd.noMark)
						end
						break
					end
				end
			end
		elseif spellId == "mark_contact" then
			Players[pid].data.customVariables.markContact = {}
			Players[pid].data.customVariables.markContact = {
				cellDescription = tes3mp.GetCell(pid),
				posX = tes3mp.GetPosX(pid),
				posY = tes3mp.GetPosY(pid),
				posZ = tes3mp.GetPosZ(pid),
				rotX = tes3mp.GetRotX(pid),
				rotY = 0,
				rotZ = tes3mp.GetRotZ(pid)	
			}
		end
	end
end)

customEventHooks.registerHandler("OnPlayerAuthentified", function(eventStatus, pid)
	if cfg.addSpellsOnAuth then
		local spellsId = {}
		if not tableHelper.containsValue(Players[pid].data.spellbook, "mark_contact") then
			table.insert(spellsId, "mark_contact")
		end
		if not tableHelper.containsValue(Players[pid].data.spellbook, "recall_contact") then
			table.insert(spellsId, "recall_contact")
		end	
		if next(spellsId) then
			AddSpell(pid, spellsId)
		end
	end
end)
