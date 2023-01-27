--[[
CriminalScript
tes3mp 0.8.1
---------------------------
DESCRIPTION :
script that references players following their bounty, allows to recover a bounty in pvp, sends the criminal to prison for a time
---------------------------
INSTALLATION:
Save the file as CriminalScript.lua inside your server/scripts/custom folder.
Edits to customScripts.lua, add in :
CriminalScript = require("custom.CriminalScript")
---------------------------
CONFIGURATION
displayGlobalWanted : sends the message for all in the chat when a player is declared
displayGlobalClearedBounty : sends the message for all in the chat when a player is out of bounty
displayJail : sends the criminal to prison after being killed in pvp (avoids abusive exploitation)
locationJail : jail location
dividerTimer : divide the wait time in jail (prime / divider) = second wait in jail
bountyBandit : bounty cap before being declared a bandit
bountyMurderer : bounty cap before being declared a murderer
bountyFugitive : bounty cap before being declared a fugitive 
GuiCriminal : do not change, use the methods "CriminalScript.OnGUIAction" to add a return in your main menu for example
---------------------------
ORDERED
/criminal : command in the chat to open the list of connected players by displaying their current bounty
]]
----------------
-- TRADUCTION --
----------------
local trad = {
	statutNeutral =  "[Neutral] ",
	statutBandit =  "[Bandit] ",
	statutMurderer =  "[Murderer] ",
	statutFugitive =  "[Fugitive] ",
	chatInfo = "[Information] : ",
	startBandit = " is reported as a bandit.\n",
	startMurderer = " is reported as a murderer.\n", 
	startFugitive = " is reported as a fugitive.\n",	
	endBounty = " no longer has a bounty on his head.\n",
	reclaimBounty = " claimed a bounty of ",
	onKill = " by killing ",
	connectedPlayer = " connected player",
	listBounty = ", bounty : ",
	jailServer = "SERVER: ",
	jailTemp = " is in prison for a period of: ",
	jailSec = " seconds\n",
	jailWait = "You are in prison for a period of : ",
	jailStop = "Your jail time just ended"
}

------------
-- CONFIG --
------------
local cfg = {
	displayGlobalWanted = true,
	displayGlobalClearedBounty = true,
	displayJail = true,
	locationJail = {
		cellDescription = "Ebonheart, Hawkmoth Legion Garrison",
		posX = 756,
		posY = 2560,
		posZ = -380
	},
	dividerTimer = 2,	
	bountyBandit = 100,
	bountyMurderer = 1000,
	bountyFugitive = 10000,
	GuiCriminal = 19092022
}

--------------
-- VARIABLE --
--------------
local PlayersJail = {}

--------------
-- FUNCTION --
--------------
local function GetName(pid)

	return string.lower(Players[pid].accountName)
	
end

function EventJail(pid)

	if Players[pid] and Players[pid]:IsLoggedIn() then
	
		if Players[pid].data.customVariables.CriminalScript.jailer == true then

			local CustomVar = Players[targetPid].data.customVariables.CriminalScript
			
			CustomVar.jailer = false
			
			PlayersJail[GetName(pid)] = false
			
			tes3mp.MessageBox(pid, -1, trad.jailStop)
			
			tes3mp.SetCell(pid, CustomVar.tempLocation.cellDescription)  
			tes3mp.SetPos(pid, CustomVar.tempLocation.posX, CustomVar.tempLocation.posY, CustomVar.tempLocation.posZ)
			tes3mp.SetRot(pid, 0, 0)
			tes3mp.SendCell(pid)    
			tes3mp.SendPos(pid)
			
		end
	end
end
-------------
-- METHODS --
-------------
local CriminalScript = {}

CriminalScript.PunishPrison = function(pid, targetPid, timer)

	if Players[pid] and Players[pid]:IsLoggedIn()	
	and Players[targetPid] and Players[targetPid]:IsLoggedIn() then

		if not Players[targetPid].data.customVariables.CriminalScript.jailer then
		
			Players[targetPid].data.customVariables.CriminalScript.tempLocation = {				
				cell = tes3mp.GetCell(targetPid),
				posX = tes3mp.GetPosX(targetPid),
				posY = tes3mp.GetPosY(targetPid),
				posZ = tes3mp.GetPosZ(targetPid)	
			}
			
		end

		timer = math.ceil(timer)
		
		local targetPlayerName = Players[tonumber(targetPid)].name
		
		local msg = color.Orange..trad.jailServer..targetPlayerName..trad.jailTemp..timer..trad.jailSec
		
		local cellDescription = cfg.locationJail.cellDescription	
		
		tes3mp.SetCell(targetPid, cellDescription)
		tes3mp.SendCell(targetPid)	
		tes3mp.SetPos(targetPid, cfg.locationJail.posX, cfg.locationJail.posY, cfg.locationJail.posZ)
		tes3mp.SetRot(targetPid, 0, 0)
		tes3mp.SendPos(targetPid)	
		
		tes3mp.SendMessage(targetPid, msg, true)
		
		Players[targetPid].data.customVariables.CriminalScript.jailer = true 
		
		Players[targetPid].data.customVariables.CriminalScript.timer = timer
		
		if not PlayersJail[GetName(pid)] then
		
			local TimerJail = tes3mp.CreateTimerEx("EventJail", time.seconds(timer), "i", targetPid)
			
			tes3mp.StartTimer(TimerJail)
			
			PlayersJail[GetName(pid)] = true

		end
		
		tes3mp.MessageBox(targetPid, -1, trad.jailWait..timer..trad.jailSec)

		
	end
	
end

CriminalScript.OnPlayerCellChange = function(eventStatus, pid, playerPacket, previousCellDescription)

	if Players[pid] and Players[pid]:IsLoggedIn() then 

		if Players[pid].data.customVariables.CriminalScript 
		and Players[pid].data.customVariables.CriminalScript.jailer then
		
			local cellDescription = playerPacket.location.cell
			
			if cellDescription ~= cfg.locationJail.cellDescription then
			
				CriminalScript.PunishPrison(pid, pid, Players[pid].data.customVariables.CriminalScript.timer)
				
			end
			
		end
		
	end   
	
end

CriminalScript.GetConnectedPlayerList = function(pid)

    local playerCount = logicHandler.GetConnectedPlayerCount()
    local label = playerCount..trad.connectedPlayer

    if playerCount ~= 1 then
        label = label .. "s"
    end
	
    local lastPid = tes3mp.GetLastPlayerId()
    local list = ""
    local divider = ""

    for playerIndex = 0, lastPid do
        if playerIndex == lastPid then
            divider = ""
        else
            divider = "\n"
        end
        if Players[playerIndex] ~= nil and Players[playerIndex]:IsLoggedIn() then
			local preFix = CriminalScript.isCriminal(Players[playerIndex].pid)
            list = list..preFix..tostring(Players[playerIndex].name).." (pid: " .. tostring(Players[playerIndex].pid)..
				trad.listBounty..tostring(Players[playerIndex].data.fame.bounty) .. ")\n"
        end
    end

	tes3mp.ListBox(pid, cfg.GuiCriminal, label, list)
end

CriminalScript.OnPlayerAuthentified = function(eventStatus, pid)

	if Players[pid] and Players[pid]:IsLoggedIn() then
	
		if not Players[pid].data.customVariables.CriminalScript then
		
			local criminal
			
			local bounty = Players[pid].data.fame.bounty
			
			if bounty >= cfg.bountyFugitive then
				criminal = 3
			elseif bounty >= cfg.bountyMurderer then
				criminal = 2
			elseif bounty >= cfg.bountyBandit then
				criminal = 1
			else
				criminal = 0
			end
			
			Players[pid].data.customVariables.CriminalScript = {
				rank = criminal,
				timer = 0,
				jailer = false,
				tempLocation = {
					cellDescription = "",
					posX = 0,
					posY = 0,
					posZ = 0
				}
			}
			
		end
		
		if Players[pid].data.customVariables.CriminalScript.jailer then
			
			CriminalScript.PunishPrison(pid, pid, Players[pid].data.customVariables.CriminalScript.timer)
			
		end
		
	end
end

CriminalScript.isCriminal = function(pid)

	if Players[pid] and Players[pid]:IsLoggedIn() then
	
		local bounty = tes3mp.GetBounty(pid)
		
		local prefix = ""
		
		if bounty >= cfg.bountyFugitive then
		
			prefix = color.Red..trad.statutFugitive..color.Default
			
		elseif bounty >= cfg.bountyMurderer then
		
			prefix = color.Salmon..trad.statutMurderer..color.Default
			
		elseif bounty >= cfg.bountyBandit then
		
			prefix = color.LightSalmon..trad.statutBandit..color.Default
			
		else
		
			prefix = color.Green..trad.statutNeutral..color.Default	
			
		end
		
		return prefix
		
	end
end

CriminalScript.getNewCriminalLevel = function(pid)

	if Players[pid] and Players[pid]:IsLoggedIn() then
	
		local bounty = tes3mp.GetBounty(pid)
		
		local previousCriminal = Players[pid].data.customVariables.CriminalScript.rank
		
		local criminal
		
		if bounty >= cfg.bountyFugitive then
		
			if previousCriminal ~= 3 then
				criminal = 3
			end
			
		elseif bounty >= cfg.bountyMurderer then
		
			if previousCriminal ~= 2 then
				criminal = 2
			end
			
		elseif bounty >= cfg.bountyBandit then
		
			if previousCriminal ~= 1 then
				criminal = 1
			end
			
		elseif bounty == 0 then
		
			if previousCriminal ~= 0 then
				criminal = 0
			end
			
		end
		
		if criminal == nil then
			criminal = -1
		else
			Players[pid].data.customVariables.CriminalScript.rank = criminal
		end

		return criminal
		
	end
end

CriminalScript.OnPlayerBounty = function(eventStatus, pid)

	if Players[pid] and Players[pid]:IsLoggedIn() then
	
		local message
		
		local playerName = tes3mp.GetName(pid)
		
		local criminal = CriminalScript.getNewCriminalLevel(pid)
		
		if criminal > 0 then
		
			if cfg.displayGlobalWanted == true then
			
				message = color.Crimson..trad.chatInfo..color.Brown..playerName..color.Default
				
				if criminal == 1 then
					message = message..trad.startBandit
				elseif criminal == 2 then
					message = message..trad.startMurderer
				elseif criminal == 3 then
					message = message..trad.startFugitive
				else
					message = ""
				end
				
				tes3mp.SendMessage(pid, message, true)
				
			end
			
		elseif criminal == 0 then
		
			if cfg.displayGlobalClearedBounty == true then
			
				message = color.Green..trad.chatInfo..color.Brown..playerName..color.Default..trad.endBounty
				
				tes3mp.SendMessage(pid, message, true)
				
			end
			
		end
	end
end

CriminalScript.OnPlayerDeath = function(eventStatus, pid)

	if eventStatus.validCustomHandlers and Players[pid] and Players[pid]:IsLoggedIn() then
	
		local deathReason = tes3mp.GetDeathReason(pid)
		
		local playerKiller = logicHandler.GetPlayerByName(deathReason)
		
		if playerKiller and playerKiller.pid and playerKiller.pid ~= pid
		and Players[playerKiller.pid] ~= nil and Players[playerKiller.pid]:IsLoggedIn() then
		
			local KillerPid = playerKiller.pid
	
			local PlayerName = GetName(pid)
			
			local KillerName = GetName(KillerPid)
			
			local currentBounty = tes3mp.GetBounty(pid)
			
			if currentBounty >= cfg.bountyBandit then

				local message			

				local goldCount = 0
				
				local goldIndex = inventoryHelper.getItemIndex(Players[pid].data.inventory, "gold_001", -1)
				
				local timer = currentBounty / cfg.dividerTimer
				
				local itemRef = { refId = "gold_001", count = currentBounty, charge = -1, enchantmentcharge = -1, soul = "" }
				
				if goldIndex then
				
					goldCount = Players[pid].data.inventory[goldIndex].count
					
					if goldCount >= currentBounty then
					
						if goldCount - currentBounty <= 0 then
						
							Players[pid].data.inventory[goldIndex] = nil
						
						else
						
							Players[pid].data.inventory[goldIndex].count = goldCount - currentBounty
						
						end 

						Players[pid]:QuicksaveToDrive()
						
						Players[pid]:LoadItemChanges({itemref}, enumerations.inventory.REMOVE)	

						table.insert(Players[KillerPid].data.inventory, itemRef)
						
						Players[KillerPid]:QuicksaveToDrive()
						
						Players[KillerPid]:LoadItemChanges({itemref}, enumerations.inventory.ADD)
				
						Players[pid].data.fame.bounty = 0
						
						tes3mp.SetBounty(pid, Players[pid].data.fame.bounty)
						
						tes3mp.SendBounty(pid)
					
						message = (
							color.Brown..KillerName..color.Default..trad.reclaimBounty..tostring(currentBounty)..trad.onKill..color.Brown..PlayerName..color.Default..".\n"..
							color.Green ..trad.chatInfo..color.Brown..PlayerName..color.Default..trad.endBounty
						)
	
						tes3mp.SendMessage(pid, message, true)
						
					end		

				end

				if cfg.displayJail then
				
					
					CriminalScript.PunishPrison(pid, pid, timer)
				
					tes3mp.Resurrect(tonumber(pid), 0)
				
					return customEventHooks.makeEventStatus(false,false)					
				end

			end
			
		end
		
	end	
	
end

CriminalScript.OnGUIAction = function(pid, idGui, data)	

	if idGui == cfg.GuiCriminal then
		
		return true
		
	end
	
end

------------
-- EVENTS --
------------
customEventHooks.registerHandler("OnPlayerAuthentified", CriminalScript.OnPlayerAuthentified)
customEventHooks.registerHandler("OnPlayerBounty", CriminalScript.OnPlayerBounty)
customEventHooks.registerHandler("OnPlayerCellChange", CriminalScript.OnPlayerCellChange)
customEventHooks.registerValidator("OnPlayerDeath", CriminalScript.OnPlayerDeath)
customCommandHooks.registerCommand("criminal", CriminalScript.GetConnectedPlayerList)
customEventHooks.registerHandler("OnGUIAction", function(eventStatus, pid, idGui, data)
	if CriminalScript.OnGUIAction(pid, idGui, data) then return end
end)
	
return CriminalScript
