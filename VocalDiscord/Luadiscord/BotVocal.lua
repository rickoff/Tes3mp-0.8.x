local discordia = require("discordia")
local jsonInterface = require('jsonInterface')
local tableHelper = require('tableHelper')
local timer = require('timer')
local config = require('config')

local client = discordia.Client()
local pathCustom = config.pathCustom 
local vocalRole = config.vocalRole  
local channelAcc = config.channelAcc 
local vocalCat = config.vocalCat  
local RoleEveryone = config.RoleEveryone 
local channelSafe = config.channelSafe
local guild 
local LocationFile
local tempTable = {}

local BotDiscord = {}

local function GetName(name)
	if name then
		local name = string.lower(name)
		return name
	end
end

local function GetRole(member)
	local LocationFile = jsonInterface.load(pathCustom.."/VocalDiscord/playerLocations.json")
	local RoleIg

	for index, data in pairs(LocationFile.players) do
		if tableHelper.containsValue(data, string.lower(member.name), true) then	
			RoleIg = LocationFile.players[index].vocal
		end
	end
	local tableRole = member.roles
	
	if member:hasRole(vocalRole) == false and RoleIg == 1 then
		member:addRole(vocalRole)
	elseif member:hasRole(vocalRole) == true and RoleIg == 0 then
		member:removeRole(vocalRole)
		member:setVoiceChannel(channelAcc)
	end
end

local function CheckJsonChange()
	local LocationFileCheck = jsonInterface.load(pathCustom.."/VocalDiscord/playerLocations.json")
	
	if LocationFile ~= LocationFileCheck then
		BotDiscord.CheckChannel()
	else
		timer.sleep(1000)
		CheckJsonChange()
	end
end

BotDiscord.CheckChannel = function()

	LocationFile = jsonInterface.load(pathCustom.."/VocalDiscord/playerLocations.json")
	
	tempTable = {}	
	local tableChannel = guild.voiceChannels	
	for number, channel in pairs(tableChannel) do
		table.insert(tempTable, channel.name)
	end		
	if guild ~= nil and tableChannel ~= nil and tempTable ~= nil then

		for number, channel in pairs(tableChannel) do
			local ChannelName = channel.name
			local tableMembers = channel.connectedMembers
			if tableMembers ~= nil then
				for number, member in pairs(tableMembers) do
					local MemberName = GetName(member.name)
					GetRole(member)
					if member:hasRole(vocalRole) == true and tableHelper.containsValue(LocationFile, string.lower(member.name), true) then
						for index, data in pairs(LocationFile.players) do
							local JsonName = GetName(LocationFile.players[index].name)
							if JsonName == MemberName then
								local Cell = LocationFile.players[index].cell
								if ChannelName ~= Cell then					
									if not tableHelper.containsValue(tempTable, Cell, true) then
										local NewChannel = guild:createVoiceChannel(Cell)
										NewChannel:setCategory(vocalCat)
										local Rrole = guild:getRole(RoleEveryone)
										local Perm = NewChannel:getPermissionOverwriteFor(Rrole)
										Perm:denyPermissions(0x00100000)									
										member:setVoiceChannel(NewChannel)
										table.insert(tempTable, Cell)
										break
										print("CHANNEL CREATE")
									else
										local NextChannel
										for number, channel in pairs(tableChannel) do
											if channel.name == Cell then
												NextChannel = channel
											end
										end
										member:setVoiceChannel(NextChannel)
										break
										print("PLAYER MOVED")
									end
								end
							end
						end
					end
				end
			end
			if not tableHelper.containsValue(channelSafe, ChannelName, true) then
				if not tableHelper.containsValue(LocationFile, ChannelName, true) then
					channel:delete()
					break
					print("CHANNEL DELETED")
				end
			end
		end
	end
	timer.sleep(1000)
	CheckJsonChange()
end

client:on("ready", function() --EVENT START
	print("Logged in as " .. client.user.username)
	guild = client:getGuild(config.serverId) 
	client:setGame("Instancied Vocal")
	timer.sleep(1000)
	LocationFile = jsonInterface.load(pathCustom.."/VocalDiscord/playerLocations.json")	
	CheckJsonChange()
end)

client:on("shardResumed", function() --EVENT RESUMED
	print("Logged resumed " .. client.user.username)
	guild = client:getGuild(config.serverId) 
	client:setGame("Instancied Vocal")
	timer.sleep(1000)
	LocationFile = jsonInterface.load(pathCustom.."/VocalDiscord/playerLocations.json")	
	CheckJsonChange()	
end)

client:on("voiceConnect", function(member)
	local MemberName = GetName(member.name)
	local DiscordFile = jsonInterface.load(pathCustom.."/VocalDiscord/userdiscord.json")
	if not DiscordFile then 
		local tabTemp = {players = {}}
		jsonInterface.quicksave(pathCustom.."/VocalDiscord/userdiscord.json", tabTemp)
		DiscordFile = jsonInterface.load(pathCustom.."/VocalDiscord/userdiscord.json")
	end
	if not tableHelper.containsValue(DiscordFile.players, MemberName, true) then
		table.insert(DiscordFile.players, MemberName)
		jsonInterface.quicksave(pathCustom.."/VocalDiscord/userdiscord.json", DiscordFile)
	end
end)

client:on("voiceDisconnect", function(member)
	local MemberName = GetName(member.name)	
	local Index
	local DiscordFile = jsonInterface.load(pathCustom.."/VocalDiscord/userdiscord.json")
	if not DiscordFile then 
		local tabTemp = {players = {}}
		jsonInterface.quicksave(pathCustom.."/VocalDiscord/userdiscord.json", tabTemp)
		DiscordFile = jsonInterface.load(pathCustom.."/VocalDiscord/userdiscord.json")
	end	
	for pos, name in pairs(DiscordFile.players) do
		if name == MemberName then
			Index = pos
		end
	end
	if Index ~= nil then
		table.remove(DiscordFile.players, Index)	
		jsonInterface.quicksave(pathCustom.."/VocalDiscord/userdiscord.json", DiscordFile)
	end
end)

client:run("Bot "..config.botToken)
