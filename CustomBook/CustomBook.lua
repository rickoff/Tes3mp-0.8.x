--[[
CustomBook
tes3mp 0.8.1
Version 1.0
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
require("custom.CustomBook")
---------------------------
]]

local cfg = {
	MainGUI = 999363,
	EditTitleGUI = 999364,
	EditTextGUI = 99965,
	ClearTextGUI = 999366,
	StyleGUI = 999367
}

local trd = {
	mainMenu = color.Orange .. "PRINTING MENU\n" .. color.Yellow .. "\nTitle : " .. color.White ..  "to create a book by giving it a title.\n\n"  .. color.Yellow .. "Text : " .. color.White ..  "to add a line to your current book.\n\n" .. color.Yellow .. "New Text : " .. color.White .. "to erase and rewrite all lines.\n" .. color.Default,
	optionMenu = "Title;Text;New Text;Style List;Style Selection;Clear;Print;Back;Close",
	editTitle = "Enter a title for your book",
	editText = "Enter text to add a line to your book.",
	clearText = "Enter text to replace lines in your book.",
	selectStyle = "Enter a number for your book style.",
	clear = "Clear",
	title = "Title created",
	addText = "Text added",
	setText = "Modified text",
	noName = "You haven't created a book yet",
	optionStyle = "Paper type",
	style = "Type selected",
	help = "Use: /bookmenu : open the edit menu\n/book <commande>\ntitle <texte>: sets the title of the book (use it to create a new one).\naddtext <text>: Add text to the book.\nsettext <text>: sets the text in the book (will remove any other text).\nliststyles: lists all styles.\nsetstyle <nombre>: sets the style.\ndone: print the document\nclear: Clears all data from the book so you can create a new one.",
	wrote = "You have written a book!",
	needPaper = "You lack the paper to write a book.",
	copyBook = "You have a copy of your book."
}

local EditBook = {
	nameSymbol = "~",
	currentBooks = {},
	bookStyles = {
		{model = "m\\Text_Octavo_03.nif", icon = "m\\tx_octavo_03.tga", scroll = false, name = "Red Book"},
		{model = "m\\Text_Octavo_06.nif", icon = "m\\Tx_book_03.tga", scroll = false, name = "Green Book"},
		{model = "m\\Text_Octavo_08.nif", icon = "m\\Tx_book_02.tga", scroll = false, name = "Blue Book"},
		{model = "m\\Text_Octavo_04.nif", icon = "m\\Tx_octavo_04.tga", scroll = false, name = "Brown Book"},
		{model = "m\\Text_Parchment_02.nif", icon = "m\\Tx_parchment_02.tga", scroll = true, name = "Letter"},
		{model = "m\\Text_Note_02.nif", icon = "m\\Tx_note_02.tga", scroll = true, name = "Note"},
		{model = "m\\Text_Scroll_open_02.nif", icon = "m\\Tx_scroll_open_02.tga", scroll = true, name = "Open Scroll"},
		{model = "m\\Text_Scroll_02.nif", icon = "m\\Tx_scroll_02.tga", scroll = true, name = "Closed Scroll"},
		{model = "m\\Text_paper_roll_01.nif", icon = "m\\Tx_paper_roll_01.tga", scroll = true, name = "Writ"}			
	}
}

local function msg(pid, text)
	tes3mp.SendMessage(pid, color.GreenYellow .. "[Style] " .. color.Default .. text .. "\n" .. color.Default)
end

local function startBook(name)
	if EditBook.currentBooks[name] == nil then
		EditBook.currentBooks[name] = {}
		EditBook.currentBooks[name].title = "Empty Title"
		EditBook.currentBooks[name].text = ""
		EditBook.currentBooks[name].type = 1
	end
end

local function nuCreateBookRecord(pid, recordTable)
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

local function createBook(pid)
	local name = Players[pid].name:lower()
	if inventoryHelper.containsItem(Players[pid].data.inventory, "sc_paper plain") then
		inventoryHelper.removeItem(Players[pid].data.inventory, "sc_paper plain", 1, -1, -1, "")
		local itemRef = {refId = "sc_paper plain", count = 1, charge = -1, enchantmentCharge = -1, soul = ""}
		Players[pid]:LoadItemChanges({itemRef}, enumerations.inventory.REMOVE)		
		msg(pid, color.Green .. trd.wrote)
	elseif inventoryHelper.containsItem(Players[pid].data.inventory,"sc_paper_plain_01_canodia") then
		inventoryHelper.removeItem(Players[pid].data.inventory,"sc_paper_plain_01_canodia", 1, -1, -1, "")
		local itemRef = {refId = "sc_paper_plain_01_canodia", count = 1, charge = -1, enchantmentCharge = -1, soul = ""}
		Players[pid]:LoadItemChanges({itemRef}, enumerations.inventory.REMOVE)				
		msg(pid, color.Green .. trd.wrote)
	else
		msg(pid, color.Red .. trd.needPaper)
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
			msg(pid, trd.copyBook)
			inventoryHelper.addItem(Players[pid].data.inventory, id, 1, -1, -1, "")
			local itemRef = {refId = id, count = 1, charge = -1, enchantmentCharge = -1, soul = ""}
			Players[pid]:LoadItemChanges({itemRef}, enumerations.inventory.ADD)
			return
		end
	end
	local bookId = nuCreateBookRecord(pid, book)
	Players[pid]:AddLinkToRecord("book", bookId)
	inventoryHelper.addItem(Players[pid].data.inventory, bookId, 1, -1, -1, "")
	local itemRef = {refId = bookId, count = 1, charge = -1, enchantmentCharge = -1, soul = ""}
	Players[pid]:LoadItemChanges({itemRef}, enumerations.inventory.ADD)
end

local function onCommand(pid, cmd)
	local name = Players[pid].name:lower()
	if cmd[2] == "clear" then
		EditBook.currentBooks[name] = nil
		msg(pid, trd.clear)
	elseif cmd[2] == "title" then
		startBook(name)
		EditBook.currentBooks[name].title = table.concat(cmd, " ", 3)
		msg(pid, trd.title)
	elseif cmd[2] == "addtext" then
		startBook(name)
		message = (table.concat(cmd, " ", 3) .. "<p>")
		EditBook.currentBooks[name].text = EditBook.currentBooks[name].text .. message
		msg(pid, trd.addText)
	elseif cmd[2] == "settext" then
		startBook(name)
		message = (table.concat(cmd, " ", 3) .. "<p>")
		EditBook.currentBooks[name].text = message
		msg(pid, trd.setText)
	elseif cmd[2] == "done" then
		if EditBook.currentBooks[name] == nil then
		    msg(pid, trd.noName)
		else
		    createBook(pid)
		end
	elseif cmd[2] == "liststyle" or cmd[2] == "liststyles" then
		msg(pid, trd.optionStyle)
		for i, bookType in pairs(EditBook.bookStyles) do
		    msg(pid, tostring(i) .. ": " .. bookType.name)
		end
	elseif cmd[2] == "setstyle" then
		startBook(name)
		if tonumber(cmd[3]) == nil then return end
		if tonumber(cmd[3]) < 1 then return end
		if tonumber(cmd[3]) > #EditBook.bookStyles then return end
		EditBook.currentBooks[name].type = tonumber(cmd[3])
		msg(pid, trd.style)
	else
		msg(pid, trd.help)
	end
end
 
local function showMainGUI(pid)
	tes3mp.CustomMessageBox(pid, cfg.MainGUI, trd.mainMenu, trd.optionMenu)
end

local function showEditTitlePrompt(pid)
	tes3mp.InputDialog(pid, cfg.EditTitleGUI, trd.editTitle, "")
end

local function showEditTextPrompt(pid)
	tes3mp.InputDialog(pid, cfg.EditTextGUI, trd.editText, "")
end

local function showClearTextPrompt(pid)
	tes3mp.InputDialog(pid, cfg.ClearTextGUI, trd.clearText, "")
end

local function showStylePrompt(pid)
	tes3mp.InputDialog(pid, cfg.StyleGUI, trd.selectStyle, "")
end

customEventHooks.registerHandler("OnGUIAction", function(eventStatus, pid, idGui, data)  
	if idGui == cfg.MainGUI then
		if tonumber(data) == 0 then
			showEditTitlePrompt(pid)
		elseif tonumber(data) == 1 then
			showEditTextPrompt(pid)
		elseif tonumber(data) == 2 then
			showClearTextPrompt(pid)
		elseif tonumber(data) == 3 then
			local command = {"book","liststyles"}
			onCommand(pid, command)
			showMainGUI(pid)
		elseif tonumber(data) == 4 then
			showStylePrompt(pid)
		elseif tonumber(data) == 5 then
			local command = {"book","clear"}
			onCommand(pid, command)		
			showMainGUI(pid)
		elseif tonumber(data) == 6 then
			local command = {"book","done"}
			onCommand(pid, command)				
		elseif tonumber(data) == 7 then	
		end
	elseif idGui == cfg.EditTitleGUI then
		if data and tostring(data) then
			local command = {"book","title",tostring(data)}
			onCommand(pid, command)				
			showMainGUI(pid)
		else
			showMainGUI(pid)
		end
	elseif idGui == cfg.EditTextGUI then
		if data and tostring(data) then
			local command = {"book","addtext",tostring(data)}
			onCommand(pid, command)
			showMainGUI(pid)
		else
			showMainGUI(pid)
		end      
	elseif idGui == cfg.ClearTextGUI then
		if data and tostring(data) then
			local command = {"book","settext",tostring(data)}
			onCommand(pid, command)	
			showMainGUI(pid)
		else
			showMainGUI(pid)
		end
	elseif idGui == cfg.StyleGUI then
		if data and tonumber(data) then
			local command = {"book","setstyle",tonumber(data)}
			onCommand(pid, command)
			showMainGUI(pid)
		else
			showMainGUI(pid)
		end	
	end
end)

customCommandHooks.registerCommand("book", onCommand)

customCommandHooks.registerCommand("bookmenu", showMainGUI)
