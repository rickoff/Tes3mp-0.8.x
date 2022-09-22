--[[
CustomBook
tes3mp 0.8.1
Version 0.5
Rewrite by Rickoff original script by Jakob
---------------------------
DESCRIPTION :
/book: Help menu
/book title <text>: Set the Name of the book
/book addtext <text>: Add text to the book
/book settext <text>: Set the text in the book (will remove all previus text)
/book listsyles: lists all the styles
/book setstyle: sets the style the book is going to use
/book done: Creates the book
/book clear: Deletes the book
/booking: gui menu
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
trad.mainMenu = color.Orange .. "MENU IMPRIMERIE\n" .. color.Yellow .. "\nTitre : " .. color.White ..  "pour créer un livre en lui donnant un titre.\n\n"  .. color.Yellow .. "Texte : " .. color.White ..  "pour ajouter une ligne à votre livre en cours.\n\n" .. color.Yellow .. "Nouveau Texte : " .. color.White .. "pour effacer et réecrire toute les lignes.\n" .. color.Default
trad.optionMenu = "Titre;Texte;Nouveau Texte;Liste Style;Selection Style;Effacer;Imprimer;Retour;Fermer"
trad.editTitle = "Entrer un titre pour votre livre"
trad.editText = "Entrer du texte pour ajouter une ligne à votre livre."
trad.clearText = "Entrer du texte pour remplacer les lignes de votre livre."
trad.selectStyle = "Entrer un chiffre pour votre style de livre."
trad.clear = "Effacer"
trad.title = "Titre créé"
trad.addText = "Texte ajouté"
trad.setText = "Texte modifié"
trad.noName = "Vous n'avez pas encore créé de livre"
trad.optionStyle = "Type de papier"
trad.style = "Type selectionné"
trad.help = "Utilisation: /book <commande>\ntitle <texte>: définit le titre du livre (utilisez-le pour en créer un nouveau).\naddtext <text>: Ajouter du texte au livre.\nsettext <text>: définit le texte dans le livre (supprimera tout autre texte).\nliststyles: répertorie tous les styles.\nsetstyle <nombre>: définit le style.\ndone: imprime le document\nclear: Efface toutes les données du livre pour pouvoir en créer une nouvelle."
trad.wrote = "Vous avez écrit un livre!"
trad.needPaper = "Il vous manque le papier pour écrire un livre."
trad.copyBook = "Vous avez une copie de votre livre!"

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
customCommandHooks.registerCommand("booking", CustomBook.showMainGUI)
customEventHooks.registerHandler("OnGUIAction", function(eventStatus, pid, idGui, data)
	if CustomBook.OnGUIAction(pid, idGui, data) then return end
end)

return CustomBook
