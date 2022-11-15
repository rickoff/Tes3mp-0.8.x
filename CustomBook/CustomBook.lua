--[[
CustomBook
tes3mp 0.8.1
Version 0.6
Rewrite by Rickoff original script by Jakob
---------------------------
DESCRIPTION :
/book : Help menu
/bookmenu : Edit menu
/book title <text> : Set the Name of the book
/book addtext <text> : Add text to the book
/book settext <text> : Set the text in the book (will remove all previus text)
/book listsyles : lists all the styles
/book setstyle : sets the style the book is going to use
/book done : Creates the book
/book clear : Deletes the book
You can use "/book done" several times as long at you dont use "/book clear" to make several copies of your book
---------------------------
INSTALLATION:
Save the file as CustomBook.lua inside your server/scripts/custom folder.
Edits to customScripts.lua
CustomBook = require("custom.CustomBook")
---------------------------
]]

local cfg = {}
cfg.MainGUI = 999363
cfg.EditTitleGUI = 999364
cfg.EditTextGUI = 99965
cfg.ClearTextGUI = 999366
cfg.StyleGUI = 999367

local trad = {}
trad.mainMenu = color.Orange .. "PRINTING MENU\n" .. color.Yellow .. "\nTitle : " .. color.White ..  "to create a book by giving it a title.\n\n"  .. color.Yellow .. "Text : " .. color.White ..  "to add a line to your current book.\n\n" .. color.Yellow .. "New Text : " .. color.White .. "to erase and rewrite all lines.\n" .. color.Default
trad.optionMenu = "Title;Text;New Text;Style List;Style Selection;Clear;Print;Back;Close"
trad.editTitle = "Enter a title for your book"
trad.editText = "Enter text to add a line to your book."
trad.clearText = "Enter text to replace lines in your book."
trad.selectStyle = "Enter a number for your book style."
trad.clear = "Clear"
trad.title = "Title created"
trad.addText = "Text added"
trad.setText = "Modified text"
trad.noName = "You haven't created a book yet"
trad.optionStyle = "Paper type"
trad.style = "Type selected"
trad.help = "Use: /bookmenu : open the edit menu\n/book <commande>\ntitle <texte>: sets the title of the book (use it to create a new one).\naddtext <text>: Add text to the book.\nsettext <text>: sets the text in the book (will remove any other text).\nliststyles: lists all styles.\nsetstyle <nombre>: sets the style.\ndone: print the document\nclear: Clears all data from the book so you can create a new one."
trad.wrote = "You have written a book!"
trad.needPaper = "You lack the paper to write a book."
trad.copyBook = "You have a copy of your book."

local EditBook = {
	nameSymbol = "~",
	currentBooks = {},
	bookStyles = {
		{model = "m\\Text_Octavo_03.nif", icon = "m\\tx_octavo_03.tga", scroll = false, name = "Livre Rouge"},
		{model = "m\\Text_Parchment_02.nif", icon = "m\\Tx_parchment_02.tga", scroll = true, name = "Lettre"},
		{model = "m\\Text_Note_02.nif", icon = "m\\Tx_note_02.tga", scroll = true, name = "Note"},
		{model = "m\\Text_Octavo_06.nif", icon = "m\\Tx_book_03.tga", scroll = false, name = "Parchemin de Vivec"}	
	},
}

local msg = function(pid, text)
	tes3mp.SendMessage(pid, color.GreenYellow .. "[Edition] " .. color.Default .. text .. "\n" .. color.Default)
end

local CustomBook = {}

CustomBook.onCommand = function(pid, cmd)
	local name = Players[pid].name:lower()
	if cmd[2] == "clear" then
		EditBook.currentBooks[name] = nil
		msg(pid, trad.clear)
	elseif cmd[2] == "title" then
		CustomBook.startBook(name)
		EditBook.currentBooks[name].title = table.concat(cmd, " ", 3)
		msg(pid, trad.title)
	elseif cmd[2] == "addtext" then
		CustomBook.startBook(name)
		message = (table.concat(cmd, " ", 3) .. "<p>")
		EditBook.currentBooks[name].text = EditBook.currentBooks[name].text .. message
		msg(pid, trad.addText)
	elseif cmd[2] == "settext" then
		CustomBook.startBook(name)
		message = (table.concat(cmd, " ", 3) .. "<p>")
		EditBook.currentBooks[name].text = message
		msg(pid, trad.setText)
	elseif cmd[2] == "done" then
		if EditBook.currentBooks[name] == nil then
		    msg(pid, trad.noName)
		else
		    CustomBook.createBook(pid)
		end
	elseif cmd[2] == "liststyle" or cmd[2] == "liststyles" then
		msg(pid, trad.optionStyle)
		for i, bookType in pairs(EditBook.bookStyles) do
		    msg(pid, tostring(i) .. ": " .. bookType.name)
		end
	elseif cmd[2] == "setstyle" then
		CustomBook.startBook(name)
		if tonumber(cmd[3]) == nil then return end
		if tonumber(cmd[3]) < 1 then return end
		if tonumber(cmd[3]) > #EditBook.bookStyles then return end
		EditBook.currentBooks[name].type = tonumber(cmd[3])
		msg(pid, trad.style)
	else
		msg(pid, trad.help)
	end
end

CustomBook.startBook = function(name)
	if EditBook.currentBooks[name] == nil then
		EditBook.currentBooks[name] = {}
		EditBook.currentBooks[name].title = "Empty Title"
		EditBook.currentBooks[name].text = ""
		EditBook.currentBooks[name].type = 1
	end
end

CustomBook.createBook = function(pid)
	local name = Players[pid].name:lower()
	if inventoryHelper.containsItem(Players[pid].data.inventory,"sc_paper plain") then
		inventoryHelper.removeItem(Players[pid].data.inventory,"sc_paper plain",1)
		msg(pid, color.Green .. trad.wrote)
	elseif inventoryHelper.containsItem(Players[pid].data.inventory,"sc_paper_plain_01_canodia") then
		inventoryHelper.removeItem(Players[pid].data.inventory,"sc_paper_plain_01_canodia",1)
		msg(pid, color.Green .. trad.wrote)
	else
		msg(pid, color.Red .. trad.needPaper)
		return
	end
	local model = EditBook.bookStyles[EditBook.currentBooks[name].type].model
	local icon = EditBook.bookStyles[EditBook.currentBooks[name].type].icon
	local scroll = EditBook.bookStyles[EditBook.currentBooks[name].type].scroll
	local book = {}
	book["weight"] = 1
	book["icon"] = icon
	book["skillId"] = "-1"
	book["model"] = model
	book["text"] = EditBook.currentBooks[name].text
	book["value"] = 1
	book["scrollState"] = scroll
	book["name"] = EditBook.nameSymbol .. EditBook.currentBooks[name].title .. EditBook.nameSymbol

	for id,n in pairs(RecordStores["book"].data.generatedRecords) do
		if n.name == book["name"] and n.text == book["text"] then
			msg(pid, trad.copyBook)
			inventoryHelper.addItem(Players[pid].data.inventory, id, 1)
			Players[pid]:QuicksaveToDrive()
			local itemRef = {refId = id, count = 1, charge = -1, soul = ""}
			Players[pid]:LoadItemChanges({itemRef}, enumerations.inventory.ADD)
			return
		end
	end
	local bookId = CustomBook.nuCreateBookRecord(pid, book)
	Players[pid]:AddLinkToRecord("book", bookId)
	inventoryHelper.addItem(Players[pid].data.inventory, bookId, 1)
	Players[pid]:QuicksaveToDrive()
	local itemRef = {refId = bookId, count = 1, charge = -1, soul = ""}
	Players[pid]:LoadItemChanges({itemRef}, enumerations.inventory.ADD)
end

CustomBook.nuCreateBookRecord = function(pid, recordTable)
	local recordStore = RecordStores["book"]
	local id = recordStore:GenerateRecordId()
	local savedTable = recordTable
	recordStore.data.generatedRecords[id] = savedTable
	for _, player in pairs(Players) do
		if not tableHelper.containsValue(player.generatedRecordsReceived, id) then
		    table.insert(player.generatedRecordsReceived, id)
		end
	end
	recordStore:Save()
	tes3mp.ClearRecords()
	tes3mp.SetRecordType(enumerations.recordType[string.upper("book")])
	packetBuilder.AddBookRecord(id, savedTable)
	tes3mp.SendRecordDynamic(pid, true, false)
	return id
end
 
CustomBook.showMainGUI = function(pid)
	tes3mp.CustomMessageBox(pid, cfg.MainGUI, trad.mainMenu, trad.optionMenu)
end

CustomBook.showEditTitlePrompt = function(pid)
	return tes3mp.InputDialog(pid, cfg.EditTitleGUI, trad.editTitle, "")
end

CustomBook.showEditTextPrompt = function(pid)
	return tes3mp.InputDialog(pid, cfg.EditTextGUI, trad.editText, "")
end

CustomBook.showClearTextPrompt = function(pid)
	return tes3mp.InputDialog(pid, cfg.ClearTextGUI, trad.clearText, "")
end

CustomBook.showStylePrompt = function(pid)
	return tes3mp.InputDialog(pid, cfg.StyleGUI, trad.selectStyle, "")
end

CustomBook.OnGUIAction = function(pid, idGui, data) 
	if idGui == cfg.MainGUI then
		if tonumber(data) == 0 then
			CustomBook.showEditTitlePrompt(pid)
			return true
		elseif tonumber(data) == 1 then
			CustomBook.showEditTextPrompt(pid)
			return true
		elseif tonumber(data) == 2 then
			CustomBook.showClearTextPrompt(pid)
			return true
		elseif tonumber(data) == 3 then
			message = "/book liststyles"
			eventHandler.OnPlayerSendMessage(pid, message)
			return CustomBook.showMainGUI(pid)
		elseif tonumber(data) == 4 then
			CustomBook.showStylePrompt(pid)
			return true
		elseif tonumber(data) == 5 then
			message = "/book clear"
			eventHandler.OnPlayerSendMessage(pid, message)
			return CustomBook.showMainGUI(pid)
		elseif tonumber(data) == 6 then
			message = "/book done"
			eventHandler.OnPlayerSendMessage(pid, message)
			return true
		elseif tonumber(data) == 7 then
			return true
		elseif tonumber(data) == 8 then
			return true			
		end
	elseif idGui == cfg.EditTitleGUI then
		if tonumber(data) == 0 or tonumber(data) == 18446744073709551615 then
			return true
		else
			message = ("/book title " .. data)
			eventHandler.OnPlayerSendMessage(pid, message)
			return CustomBook.showMainGUI(pid)
		end       
	elseif idGui == cfg.EditTextGUI then
		if tonumber(data) == 0 or tonumber(data) == 18446744073709551615 then
			return true
		else
			message = ("/book addtext " .. data)
			eventHandler.OnPlayerSendMessage(pid, message)
			return CustomBook.showMainGUI(pid)
		end       
	elseif idGui == cfg.ClearTextGUI then
		if tonumber(data) == 0 or tonumber(data) == 18446744073709551615 then
			return true
		else
			message = ("/book settext " .. data)
			eventHandler.OnPlayerSendMessage(pid, message)
			return CustomBook.showMainGUI(pid)
		end
	elseif idGui == cfg.StyleGUI then
		if tonumber(data) == 0 or tonumber(data) == 18446744073709551615 then
			return true
		else
			message = ("/book setstyle " .. tonumber(data))
			eventHandler.OnPlayerSendMessage(pid, message)
			return CustomBook.showMainGUI(pid)
		end 	
	end
end

customCommandHooks.registerCommand("book", CustomBook.onCommand)
customCommandHooks.registerCommand("bookmenu", CustomBook.showMainGUI)
customEventHooks.registerHandler("OnGUIAction", function(eventStatus, pid, idGui, data)
	if CustomBook.OnGUIAction(pid, idGui, data) then return end
end)

return CustomBook
