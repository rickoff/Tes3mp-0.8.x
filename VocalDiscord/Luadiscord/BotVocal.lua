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
local tableChannel
local LocationFile

local BotDiscord = {}

local function GetName(name)
	if name then
		local name = string.lower(name)
		return name
	end
end

local function GetRole(member)
	
	local RoleIg
	
	local PlayerName = GetName(member.name)
	
	if LocationFile[PlayerName] then	
		RoleIg = LocationFile[PlayerName].vocal
	end
	
	if member:hasRole(vocalRole) == false and RoleIg == 1 then
		member:addRole(vocalRole)
	elseif member:hasRole(vocalRole) == true and RoleIg == 0 then
		member:removeRole(vocalRole)
		member:setVoiceChannel(channelAcc)
	end
	
end

local function CheckDeletedChannel()	
	
	for number, channel in pairs(tableChannel) do	
		
		if not channelSafe[channel.name] and not tableHelper.containsValue(LocationFile, channel.name, true) then	
			
			channel:delete()
			print("CHANNEL DELETE : "..channel.name)	
			
		end			
	end
	
end

local function CheckJsonChange()
	
	if LocationFile.Timestamp ~= LocationFileCheck.Timestamp then
	
		LocationFile = LocationFileCheck
		
		for PlayerName, PlayerData in pairs(LocationFile) do
		
			if type(PlayerData) == "number" then
			
			else
				BotDiscord.CheckChannel(PlayerName, PlayerData)
			end

		end
		
		CheckDeletedChannel()
		
	end
end

local function CheckExistChannel(CellDescription)
	
	for number, channel in pairs(tableChannel) do
	
		if channel.name == CellDescription then
	
			return channel
			
		end
	
	end
	
	return false

end

local function CheckConnectedMember(PlayerName, CellDescription)
	
	for number, channel in pairs(tableChannel) do

		local tableMembers = channel.connectedMembers
		
		for number, member in pairs(tableMembers) do
		
			GetRole(member)
			
			if string.lower(member.name) == PlayerName and channel.name ~= CellDescription then
			
				return member
				
			end
			
		end
		
	end
	
	return false

end

local function ChangePlayerChannel(Member, CellDescription, ChannelId)

	if ChannelId then
	
		Member:setVoiceChannel(ChannelId)	
		
	else
	
		local NewChannel = guild:createVoiceChannel(CellDescription)

		NewChannel:setCategory(vocalCat)

		local Rrole = guild:getRole(RoleEveryone)

		local Perm = NewChannel:getPermissionOverwriteFor(Rrole)
		
		Perm:denyPermissions(0x00100000)	
		
		Member:setVoiceChannel(NewChannel)
		
		print("CHANNEL CREATE : "..CellDescription.." FOR : "..Member.name)
		
	end
	
	print("PLAYER MOVE : "..Member.name.." IN : "..CellDescription)
	
end

BotDiscord.CheckChannel = function(PlayerName, PlayerData)

	guild = client:getGuild(config.serverId) 

	tableChannel = guild.voiceChannels	
	
	local CellDescription = PlayerData.location.cell	
	
	local Channel = CheckExistChannel(CellDescription)
	
	local Member = CheckConnectedMember(PlayerName, CellDescription)
	
	if Member and Member:hasRole(vocalRole) then
	
		if Channel then

			ChangePlayerChannel(Member, CellDescription, Channel.id)
			
		elseif not Channel then
		
			ChangePlayerChannel(Member, CellDescription, false)	
			
		end
		
	end
	
end

client:on("ready", function()
	print("Logged in as " .. client.user.username)
	guild = client:getGuild(config.serverId) 
	client:setGame("Instancied Vocal")
	LocationFile = jsonInterface.load(pathCustom.."/VocalDiscord/playerLocations.json")	
	timer.setInterval(1000, function()
		coroutine.wrap(CheckJsonChange)()		
	end)
end)

client:on("shardResumed", function()
	print("Logged resumed " .. client.user.username)
	guild = client:getGuild(config.serverId) 
	client:setGame("Instancied Vocal")
	LocationFile = jsonInterface.load(pathCustom.."/VocalDiscord/playerLocations.json")
	timer.setInterval(1000, function()
		coroutine.wrap(CheckJsonChange)()		
	end)	
end)

client:on("voiceConnect", function(member)

	local MemberName = GetName(member.name)
	
	local DiscordFile = jsonInterface.load(pathCustom.."/VocalDiscord/userdiscord.json")
	
	if not DiscordFile then 
	
		local tabTemp = {}
		
		jsonInterface.quicksave(pathCustom.."/VocalDiscord/userdiscord.json", tabTemp)
		
		DiscordFile = jsonInterface.load(pathCustom.."/VocalDiscord/userdiscord.json")
		
	end
	
	if not DiscordFile[MemberName] then
	
		DiscordFile[MemberName] = true
		
		jsonInterface.quicksave(pathCustom.."/VocalDiscord/userdiscord.json", DiscordFile)
		
	end
	
end)

client:on("voiceDisconnect", function(member)

	local MemberName = GetName(member.name)	
	
	local DiscordFile = jsonInterface.load(pathCustom.."/VocalDiscord/userdiscord.json")
	
	if not DiscordFile then 
	
		local tabTemp = {}
		
		jsonInterface.quicksave(pathCustom.."/VocalDiscord/userdiscord.json", tabTemp)
		
		DiscordFile = jsonInterface.load(pathCustom.."/VocalDiscord/userdiscord.json")
		
	end	
	
	if DiscordFile[MemberName] then
	
		DiscordFile[MemberName] = nil

		jsonInterface.quicksave(pathCustom.."/VocalDiscord/userdiscord.json", DiscordFile)
		
	end
	
end)

client:run("Bot "..config.botToken)
