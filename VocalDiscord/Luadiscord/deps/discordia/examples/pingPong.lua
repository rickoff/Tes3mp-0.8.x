local discordia = require("discordia")
local client = discordia.Client()

client:on("ready", function() -- bot is ready
	print("Logged in as " .. client.user.username)
end)

client:on("messageCreate", function(message)

	local content = message.content

	if content == "!ping" then
		message:reply("Pouet!")
	elseif content == "!pong" then
		message:reply("Pouet!")
	end

end)

client:run("Bot xxxxxxxxxxxxxxxxxxxxx") -- replace BOT_TOKEN with your bot token

client:on("reactionAdd", function(message)--TALENTS

	local content = message.content
	local author = message.author
	local member = message.member
	
	if content == "👋" and member.nickname ~= "Dumac Faer" then
		local PlayerFile = jsonInterface.load(path.."/"..member.nickname..".json")
		if PlayerFile then
			local EquipList = ""
			for item, equip in pairs(PlayerFile.equipment) do
				EquipList = (EquipList..""..PlayerFile.equipment[item].refId.."\n")
			end
			local InvList = ""
			for item, equip in pairs(PlayerFile.equipment) do
				InvList = (InvList..""..PlayerFile.inventory[item].refId.."\n")
			end			
				
			message:reply {
				embed = {
					title = "INVENTAIRE",
					description = "Inventaire actuel de votre personnage",
					author = {
						name = member.nickname,
						icon_url = author.avatarURL
					},
					fields = { -- array of fields
						{
							name = "Equipement",
							value = EquipList,
							inline = true
						},
						{
							name = "Objets",
							value = InvList,
							inline = false
						}
					},
					footer = {
						text = "Personnage disponible sur Ecarlate"
					},
					color = 0x000000 -- hex color code
				}
			}
		else
			local msg = ("```Aucun personnage existe sous le nom de : "..member.nickname..".```")
			message:reply(msg)
		end			
	end
end)
