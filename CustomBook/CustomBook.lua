--[[
CustomBook
tes3mp 0.8.0
Version 0.4
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

local config = {}
config.MainGUI = 999363
config.EditTitleGUI = 999364
config.EditTextGUI = 99965
config.ClearTextGUI = 999366
config.StyleGUI = 999367

local trad = {}
trad.mainMenu = color.Orange .. "BIENVENUE DANS LA BIBLIOTHEQUE.\n" .. color.Yellow .. "\nTitre : " .. color.White ..  "pour créer un livre en lui donnant un titre.\n\n"  .. color.Yellow .. "Texte : " .. color.White ..  "pour ajouter une ligne à votre livre en cours.\n\n" .. color.Yellow .. "Nouveau Texte : " .. color.White .. "pour effacer et réecrire toute les lignes.\n" .. color.Default
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

local CustomBook = {}

CustomBook.currentBooks = {} --used to store players individual in progress books
CustomBook.bookStyles = {}
table.insert(CustomBook.bookStyles, {model = "m\\Text_Octavo_03.nif", icon = "m\\tx_octavo_03.tga", scroll = false, name = "Red Book"} )
table.insert(CustomBook.bookStyles, {model = "m\\Text_Parchment_02.nif", icon = "m\\Tx_parchment_02.tga", scroll = true, name = "Letter"} )
table.insert(CustomBook.bookStyles, {model = "m\\Text_Note_02.nif", icon = "m\\Tx_note_02.tga", scroll = true, name = "Note"} )
table.insert(CustomBook.bookStyles, {model = "m\\Text_Octavo_06.nif", icon = "m\\Tx_book_03.tga", scroll = false, name = "Lesson of Vivec"} )

CustomBook.nameSymbol = "~" --the symbol used before and after book names to differintiate them from vanila books

local msg = function(pid, text)
	tes3mp.SendMessage(pid, color.GreenYellow .. "[BookWriting] " .. color.Default .. text .. "\n" .. color.Default)
end

function CustomBook.onCommand(pid, cmd)
    local name = Players[pid].name:lower()
    if cmd[2] == "clear" then
        CustomBook.currentBooks[name] = nil
        msg(pid, trad.clear)
    elseif cmd[2] == "title" then
        CustomBook.startBook(name)
        CustomBook.currentBooks[name].title = table.concat(cmd, " ", 3)
        msg(pid, trad.title)
    elseif cmd[2] == "addtext" then
        CustomBook.startBook(name)
		message = (table.concat(cmd, " ", 3) .. "<p>")
        CustomBook.currentBooks[name].text = CustomBook.currentBooks[name].text .. message
        msg(pid, trad.addText)
    elseif cmd[2] == "settext" then
        CustomBook.startBook(name)
		message = (table.concat(cmd, " ", 3) .. "<p>")
        CustomBook.currentBooks[name].text = message
        msg(pid, trad.setText)
    elseif cmd[2] == "done" then
        if CustomBook.currentBooks[name] == nil then
            msg(pid, trad.noName)
        else
            CustomBook.createBook(pid)
        end
    elseif cmd[2] == "liststyle" or cmd[2] == "liststyles" then
        msg(pid, trad.optionStyle)
        for i, bookType in pairs(CustomBook.bookStyles) do
            msg(pid, tostring(i) .. ": " .. bookType.name)
        end
    elseif cmd[2] == "setstyle" then
        CustomBook.startBook(name)
        if tonumber(cmd[3]) == nil then return end
        if tonumber(cmd[3]) < 1 then return end
        if tonumber(cmd[3]) > #CustomBook.bookStyles then return end
        CustomBook.currentBooks[name].type = tonumber(cmd[3])
        msg(pid, trad.style)
    else
        msg(pid, trad.help)
    end
end

function CustomBook.startBook(name)
    if CustomBook.currentBooks[name] == nil then
        CustomBook.currentBooks[name] = {}
        CustomBook.currentBooks[name].title = "Empty Title"
        CustomBook.currentBooks[name].text = ""
        CustomBook.currentBooks[name].type = 1
    end
end

function CustomBook.createBook(pid)
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
    local model = CustomBook.bookStyles[CustomBook.currentBooks[name].type].model
    local icon = CustomBook.bookStyles[CustomBook.currentBooks[name].type].icon
    local scroll = CustomBook.bookStyles[CustomBook.currentBooks[name].type].scroll
    local book = {}
    book["weight"] = 1
    book["icon"] = icon
    book["skillId"] = "-1"
    book["model"] = model
    book["text"] = CustomBook.currentBooks[name].text
    book["value"] = 1
    book["scrollState"] = scroll
    book["name"] = CustomBook.nameSymbol .. CustomBook.currentBooks[name].title .. CustomBook.nameSymbol
    for id,n in pairs(RecordStores["book"].data.generatedRecords) do
        if n.name == book["name"] and n.text == book["text"] then
            msg(pid, trad.copyBook)
            inventoryHelper.addItem(Players[pid].data.inventory, id, 1)
            Players[pid]:Save()
            Players[pid]:LoadInventory()
            Players[pid]:LoadEquipment()
            Players[pid]:LoadQuickKeys()
            return
        end
    end
    local bookId = CustomBook.nuCreateBookRecord(pid, book)
    Players[pid]:AddLinkToRecord("book", bookId)
    inventoryHelper.addItem(Players[pid].data.inventory, bookId, 1)
    Players[pid]:Save()
	Players[pid]:LoadInventory()
    Players[pid]:LoadEquipment()
    Players[pid]:LoadQuickKeys()
end

function CustomBook.nuCreateBookRecord(pid, recordTable)
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

function CustomBook.onMainGui(pid)
    CustomBook.showMainGUI(pid)
end
 
function CustomBook.showMainGUI(pid)
    tes3mp.CustomMessageBox(pid, config.MainGUI, trad.mainMenu, trad.optionMenu)
end

function CustomBook.showEditTitlePrompt(pid)
    return tes3mp.InputDialog(pid, config.EditTitleGUI, trad.editTitle, "")
end

function CustomBook.showEditTextPrompt(pid)
    return tes3mp.InputDialog(pid, config.EditTextGUI, trad.editText, "")
end

function CustomBook.showClearTextPrompt(pid)
    return tes3mp.InputDialog(pid, config.ClearTextGUI, trad.clearText, "")
end

function CustomBook.showStylePrompt(pid)
    return tes3mp.InputDialog(pid, config.StyleGUI, trad.selectStyle, "")
end

function CustomBook.OnGUIAction(pid, idGui, data)   
    if idGui == config.MainGUI then -- Main
        if tonumber(data) == 0 then --Titre
            CustomBook.showEditTitlePrompt(pid)
            return true
        elseif tonumber(data) == 1 then --Texte
            CustomBook.showEditTextPrompt(pid)
            return true
        elseif tonumber(data) == 2 then --Nouveau Texte
            CustomBook.showClearTextPrompt(pid)
            return true
        elseif tonumber(data) == 3 then --Liste Style
			message = "/book liststyles"
            eventHandler.OnPlayerSendMessage(pid, message)
            return CustomBook.onMainGui(pid)
        elseif tonumber(data) == 4 then -- Selection Style
            CustomBook.showStylePrompt(pid)
            return true
        elseif tonumber(data) == 5 then -- Effacer
			message = "/book clear"
            eventHandler.OnPlayerSendMessage(pid, message)
            return CustomBook.onMainGui(pid)
        elseif tonumber(data) == 6 then -- Imprimer
			message = "/book done"
            eventHandler.OnPlayerSendMessage(pid, message)
            return true
        elseif tonumber(data) == 7 then -- retour
			Players[pid].currentCustomMenu = "menu player"
			menuHelper.DisplayMenu(pid, Players[pid].currentCustomMenu)
            return true
        elseif tonumber(data) == 8 then -- fermer
            return true			
        end
    elseif idGui == config.EditTitleGUI then
        if tonumber(data) == 0 or tonumber(data) == 18446744073709551615 then --Close/Nothing Selected
            return true
        else
			message = ("/book title " .. data)
            eventHandler.OnPlayerSendMessage(pid, message)
            return CustomBook.onMainGui(pid)
        end       
    elseif idGui == config.EditTextGUI then
        if tonumber(data) == 0 or tonumber(data) == 18446744073709551615 then --Close/Nothing Selected
            return true
        else
			message = ("/book addtext " .. data)
            eventHandler.OnPlayerSendMessage(pid, message)
            return CustomBook.onMainGui(pid)
        end       
    elseif idGui == config.ClearTextGUI then
        if tonumber(data) == 0 or tonumber(data) == 18446744073709551615 then --Close/Nothing Selected
            return true
        else
			message = ("/book settext " .. data)
            eventHandler.OnPlayerSendMessage(pid, message)
            return CustomBook.onMainGui(pid)
        end
    elseif idGui == config.StyleGUI then
        if tonumber(data) == 0 or tonumber(data) == 18446744073709551615 then --Close/Nothing Selected
            return true
        else
			message = ("/book setstyle " .. tonumber(data))
            eventHandler.OnPlayerSendMessage(pid, message)
            return CustomBook.onMainGui(pid)
        end 	
	end
end

customCommandHooks.registerCommand("book", CustomBook.onCommand)
customCommandHooks.registerCommand("booking", CustomBook.showMainGUI)
customEventHooks.registerHandler("OnGUIAction", function(eventStatus, pid, idGui, data)
	if CustomBook.OnGUIAction(pid, idGui, data) then return end
end)
