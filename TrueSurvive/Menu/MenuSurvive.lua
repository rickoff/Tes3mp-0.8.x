Menus["survive menu"] = {
	text = {color.Orange .. "SURVIVE MENU\n",
		color.Yellow .. "\nHunger : " .. color.White,
		menuHelper.variables.currentPlayerDataVariable("customVariables.TrueSurvive.HungerTime"), 
		color.Red .. " >= ",
		menuHelper.variables.currentPlayerDataVariable("customVariables.TrueSurvive.HungerTimeMax"),
		"\n",
		color.Yellow .. "\nThirst : " .. color.White,
		menuHelper.variables.currentPlayerDataVariable("customVariables.TrueSurvive.ThirsthTime"), 
		color.Red .. " >= ",
		menuHelper.variables.currentPlayerDataVariable("customVariables.TrueSurvive.ThirsthTimeMax"),
		"\n",
		color.Yellow .. "\nSleep : " .. color.White,
		menuHelper.variables.currentPlayerDataVariable("customVariables.TrueSurvive.SleepTime"),
		color.Red .. " >= ",
		menuHelper.variables.currentPlayerDataVariable("customVariables.TrueSurvive.SleepTimeMax"),
		"\n"
	},
    buttons = {			
        { caption = "Exit", destinations = nil }	
    }
}

Menus["survive hunger"] = {
    text = color.Gold .. "Do you want\n" .. color.LightGreen ..
    "eat\n" .. color.Gold .. "this food ?\n" ..
        color.White .. "...",
    buttons = {						
        { caption = "yes",
            destinations = {
				menuHelper.destinations.setDefault(nil,
				{ 
					menuHelper.effects.runGlobalFunction("TrueSurvive", "OnHungerObject", 
					{
                        menuHelper.variables.currentPid(),
						menuHelper.variables.currentPlayerDataVariable("targetCellDescription")
                    }),
                    menuHelper.effects.runGlobalFunction("TrueSurvive", "CleanCellObject",
                    {
						menuHelper.variables.currentPid(),
                        menuHelper.variables.currentPlayerDataVariable("targetCellDescription"),
                        menuHelper.variables.currentPlayerDataVariable("targetUniqueIndex"),
						true
                    }),
					menuHelper.effects.runGlobalFunction("TrueSurvive", "PlaySound", 
					{
                        menuHelper.variables.currentPid(), "swallow"
                    }),					
                })
            }
        },            
        { caption = "no",
            destinations = {
                menuHelper.destinations.setDefault(nil,
                { 
                    menuHelper.effects.runGlobalFunction("logicHandler", "ActivateObjectForPlayer",
                    {
                        menuHelper.variables.currentPid(), menuHelper.variables.currentPlayerDataVariable("targetCellDescription"),
                        menuHelper.variables.currentPlayerDataVariable("targetUniqueIndex")
                    })
                })
            }
        }
    }
}

Menus["survive drink"] = {
    text = color.Gold .. "Do you want\n" .. color.LightGreen ..
    "drink\n" .. color.Gold .. "this ?\n" ..
        color.White .. "...",
    buttons = {                        
        { caption = "yes",
            destinations = {
                menuHelper.destinations.setDefault(nil,
                { 
                    menuHelper.effects.runGlobalFunction("TrueSurvive", "OnDrinkObject", 
                    {
                        menuHelper.variables.currentPid(),
						menuHelper.variables.currentPlayerDataVariable("targetCellDescription")
                    }),
                    menuHelper.effects.runGlobalFunction("TrueSurvive", "CleanCellObject",
                    {
						menuHelper.variables.currentPid(),
                        menuHelper.variables.currentPlayerDataVariable("targetCellDescription"),
                        menuHelper.variables.currentPlayerDataVariable("targetUniqueIndex"),
						true
                    }),
					menuHelper.effects.runGlobalFunction("TrueSurvive", "PlaySound", 
					{
                        menuHelper.variables.currentPid(), "drink"
                    }),											
                })
            }
        },            
        { caption = "no",
            destinations = {
                menuHelper.destinations.setDefault(nil,
                { 
                    menuHelper.effects.runGlobalFunction("logicHandler", "ActivateObjectForPlayer",
                    {
                        menuHelper.variables.currentPid(), menuHelper.variables.currentPlayerDataVariable("targetCellDescription"),
                        menuHelper.variables.currentPlayerDataVariable("targetUniqueIndex")
                    })
                })
            }
        }
    }
}

Menus["survive sleep"] = {
    text = color.Gold .. "Do you want\n" .. color.LightGreen ..
    "sleep\n" .. color.Gold .. "in this bed ?\n" ..
        color.White .. "...",
    buttons = {						
        { caption = "rest survival",
            destinations = {menuHelper.destinations.setDefault(nil,
            { 
				menuHelper.effects.runGlobalFunction("TrueSurvive", "OnSleepObject", 
					{menuHelper.variables.currentPid()})
                })
            }
        },			
        { caption = "rest normal",
            destinations = {menuHelper.destinations.setDefault(nil,
            { 
				menuHelper.effects.runGlobalFunction("TrueSurvive", "OnSleepObjectVanilla", 
					{menuHelper.variables.currentPid()})
                })
            }
        },	
    }
}
