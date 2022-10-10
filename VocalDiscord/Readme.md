* VocalDiscord by Rickoff
* tes3mp 0.8.0
--------------------------
* DESCRIPTION :
* Automatically creates, deletes and moves a player on the discord channel corresponding to the cell being explored ig
* Automatically kicks players not present on a voice channel
---------------------------
* REQUIRE:
* Create a bot on your discord https://discord.com/developers/applications
* Your Discord name/nickname must match your character name
---------------------------
* INSTALLATION:
* Save luadiscord folder in server/lib
* Save the file as VocalDiscord.lua inside your server/scripts/custom folder.
* Save the file as userdiscord.json inside your server/data/custom/VocalDiscord folder.
* Save the file as playerLocations.json inside your server/data/custom/VocalDiscord folder.
* Edits to customScripts.lua : VocalDiscord = require("custom.VocalDiscord")
* Edit the config.lua file in server/lib/luadiscord :
	- config.botToken = "your token bot"
	- config.pathCustom = "your patch data custom server"
	- config.vocalRole = "your id role voice"
	- config.channelAcc = "your id channel base"
	- config.vocalCat = "your id categorie for created channels"
	- config.RoleEveryone = "your id role everyone"
	- config.channelSafe = {
		your name channel vocal = true,
		your name channel vocal = true,
		your name channel vocal = true
	}
	- config.serverId = "your id server"
* Execute start.bat located in server/lib/luadiscord (for windows) or command linux "luvit BotVocal.lua"
* Connect to any voice channel of your discord with a nickname corresponding to your character name
	(the modification of the nickname is not taken into account if you are already connected to the voice channel, then disconnect/reconnect to the channel for the consideration)
* Start your server
* Use /vocal in chat ig for active instancied vocal
---------------------------
- USE :
* Connect to a vocal channel in your discord
* Put /vocal in game chat for active or disable instancied vocal
-------------------------- 
 ![alt-text](https://github.com/rickoff/Tes3mp-Ecarlate-Script/blob/0.7.0/VoiceBot/ac7c1c20e9390b53baedc525f231e44f.gif)
