Menus["invite player"] = {
    text = color.Gold .. "Do you want to invite\n" .. color.LightGreen ..
    " the player in the group ?\n" ..
        color.White .. "...",
    buttons = {						
        { caption = "yes",
            destinations = {menuHelper.destinations.setDefault(nil,
            { 
				menuHelper.effects.runGlobalFunction("TeamGroup", "ActiveMenu", 
					{menuHelper.variables.currentPlayerDataVariable("targetPid")}),
				menuHelper.effects.runGlobalFunction("TeamGroup", "showMainGUI",
						{menuHelper.variables.currentPid()})					
                })
            }
        },			
        { caption = "no", 
			destinations = {menuHelper.destinations.setDefault(nil,	
            { 
				menuHelper.effects.runGlobalFunction("TeamGroup", "showMainGUI", 
					{menuHelper.variables.currentPid()})	
				})
			}
		}
    }
}

Menus["reponse player"] = {
    text = color.Gold .. "Do you want to join\n" .. color.LightGreen ..
    " the group ?\n" ..
        color.White .. "...",
    buttons = {						
        { caption = "yes",
            destinations = {menuHelper.destinations.setDefault(nil,
            { 
				menuHelper.effects.runGlobalFunction("TeamGroup", "RegisterGroup", 
					{menuHelper.variables.currentPlayerDataVariable("targetPid"), menuHelper.variables.currentPid()})
                })
            }
        },			
        { caption = "no", destinations = nil }
    }
}
