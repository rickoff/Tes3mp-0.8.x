--[[
AnimationMenu
Made by Kyoufu, edited by Vidi_Aquam, based on JRPAnim by malic, rewritten by Rickoff
tes3mp 0.8.1
---------------------------
DESCRIPTION :
AnimationMenu script
/anim to open the animation menu
---------------------------
INSTALLATION:
Save the file as AnimationMenu.lua inside your server/scripts/custom folder.
Edits to customScripts.lua
AnimationMenu = require("custom.AnimationMenu")

REQUIREMENT:
Download and save files va_sitting.nif, xva_sitting.nif, and xva_sitting.kf inside morrowind/data/meshs
https://www.nexusmods.com/morrowind/mods/48782?tab=files 
---------------------------
]]

--------------
-- VARIABLE --
--------------
local PlayerAnimationList = {}

------------
-- CONFIG --
------------
local cfg = {
	OnServerPostInitHandler = true
}

local guiID = {
	animMenu = 42110
}

local traduction  = {
	title = "ANIMATION MENU",
	option = "Pray;Lying(on back);Lying(on right side);Lying(on left side);Sitting(with legs to the side);Sitting(with legs crossed);Sitting(with legs forward);Sitting(on a chair);Dancing;Cancel(animation)"
}

---------------
-- FUNCTIONS --
---------------
local function GetName(pid)

	return string.lower(Players[pid].accountName)
	
end

-------------
-- METHODS --
-------------
local AnimationMenu = {}

AnimationMenu.OnServerPostInitHandler = function()

	if cfg.OnServerPostInitHandler then
		local recordStore = RecordStores["spell"]
		recordStore.data.permanentRecords["sittingAnim_paralyze"] = {
			name = "Paralysie animation (/anim)",
			subtype = 1,
			cost = 0,
			flags = 0,
			effects = {{
				id = 45,
				attribute = -1,
				skill = -1,
				rangeType = 0,
				duration = -1,
				area = 0,
				magnitudeMin = 1,
				magnitudeMax = 1
			}}
		}
		recordStore:Save()
	end
end

AnimationMenu.showAnimMenu = function(pid)
	
	local message = color.Orange.. traduction.title

	optionList = traduction.option

	tes3mp.CustomMessageBox(pid, guiID.animMenu, message, optionList)
	
end

AnimationMenu.OnGUIAction = function(eventStatus, pid, idGui, data)
	
	if idGui == guiID.animMenu then

		local PlayerName = GetName(pid)

		local cellDescription = tes3mp.GetCell(pid)

		local Model = "base_anim.nif"

		local Animation = "idle"

		if tonumber(data) >= 0 and tonumber(data) < 9 then

			table.insert(Players[pid].data.spellbook, "sittingAnim_paralyze")

			Players[pid]:LoadSpellbook()

			Model = "va_sitting.nif"

			logicHandler.RunConsoleCommandOnPlayer(pid, "PCForce3rdPerson", false)

			logicHandler.RunConsoleCommandOnPlayer(pid, "DisablePlayerViewSwitch", false)	

		end

		if tonumber(data) == 0 then

			Animation = "idle2"

		elseif tonumber(data) == 1 then

			Animation = "idle9"

		elseif tonumber(data) == 2 then

			Animation = "idle7"	

		elseif tonumber(data) == 3 then

			Animation = "idle8"					

		elseif tonumber(data) == 4 then

			Animation = "idle3"				

		elseif tonumber(data) == 5 then

			Animation = "idle4"	

		elseif tonumber(data) == 6 then

			Animation = "idle5"		

		elseif tonumber(data) == 7 then

			Animation = "idle6"			

		elseif tonumber(data) == 8 then

			Model = "anim_dancinggirl.nif"

			Animation = "idle9"	

		elseif tonumber(data) == 9 then

			logicHandler.RunConsoleCommandOnPlayer(pid, "player->removespell sittingAnim_paralyze")

			tableHelper.removeValue(Players[pid].data.spellbook, "sittingAnim_paralyze")				

			logicHandler.RunConsoleCommandOnPlayer(pid, "EnablePlayerViewSwitch", false)

			Players[pid]:LoadSpellbook()

		end

		tes3mp.SetModel(pid, Model)

		tes3mp.SendBaseInfo(pid)	

		tes3mp.PlayAnimation(pid, Animation, 0, 1, true)

		PlayerAnimationList[PlayerName] = {
			animation = Animation,
			model = Model,
			cellDescription = cellDescription
		}

	end	
end

AnimationMenu.ChatListener = function(pid, cmd)
	
	if cmd[1] == "anim" and cmd[2] == nil then

		AnimationMenu.showAnimMenu(pid)

	end	
end

AnimationMenu.OnPlayerAuthentified = function(eventStatus, pid)

	local PlayerName = GetName(pid)

	local Model = "base_anim.nif"

	tes3mp.SetModel(pid, Model)

	tes3mp.SendBaseInfo(pid)

	if tableHelper.containsValue(Players[pid].data.spellbook, "sittingAnim_paralyze") then

		logicHandler.RunConsoleCommandOnPlayer(pid, "player->removespell sittingAnim_paralyze")

		tableHelper.removeValue(Players[pid].data.spellbook, "sittingAnim_paralyze")

		Players[pid]:LoadSpellbook()		

		tes3mp.PlayAnimation(pid, "idle", 0, 1, true)

	end
end

AnimationMenu.OnPlayerCellChange = function(eventStatus, pid, playerPacket, previousCellDescription)

	local PlayerName = GetName(pid)

	for targetName, data in pairs(PlayerAnimationList) do

		if targetName ~= PlayerName and playerPacket.location.cell == data.cellDescription then

			local targetPid = logicHandler.GetPlayerByName(targetName).pid

			if targetPid and Players[targetPid] ~= nil and Players[targetPid]:IsLoggedIn() then

				tes3mp.SetModel(targetPid, data.model)

				tes3mp.SendBaseInfo(targetPid)

				tes3mp.PlayAnimation(targetPid, data.animation, 0, 1, true)					
			end				
		end			
	end	
end

AnimationMenu.OnPlayerDisconnect = function(eventStatus, pid)

	local PlayerName = GetName(pid)

	if PlayerAnimationList[PlayerName] then

		PlayerAnimationList[PlayerName] = nil
	end	
end

------------
-- EVENTS --
------------
customEventHooks.registerHandler("OnServerPostInit", AnimationMenu.OnServerPostInitHandler)

customEventHooks.registerHandler("OnPlayerAuthentified", AnimationMenu.OnPlayerAuthentified)

customEventHooks.registerHandler("OnPlayerCellChange", AnimationMenu.OnPlayerCellChange)

customEventHooks.registerHandler("OnPlayerDisconnect", AnimationMenu.OnPlayerDisconnect)

customEventHooks.registerHandler("OnGUIAction", AnimationMenu.OnGUIAction)

customCommandHooks.registerCommand("anim", AnimationMenu.ChatListener)

return AnimationMenu
