local core = require("openmw.core")
local I = require('openmw.interfaces')
local storage = require('openmw.storage')

-- Create a settings section for our mod
local settings = storage.playerSection("SettingsTakeAll")

-- Register a settings page for our mod
I.Settings.registerPage {
    key = "SettingsTakeAll",
    l10n = "SettingsTakeAll",
    name = "Take All",
    description = "Settings for the Take All mod."
}

-- Register settings group with our options
I.Settings.registerGroup {
    key = "SettingsTakeAll",
    page = "SettingsTakeAll",
    l10n = "SettingsTakeAll",
    name = "Main Settings",
    permanentStorage = true,
    description = [[
    These settings allow you to modify the behavior of the Take All mod.
    ]],
    settings = {
        {
            key = "enableDebugLogging",
            renderer = "checkbox",
            name = "Enable Debug Logging",
            description = "If enabled, debug messages will be shown in the console. Useful for troubleshooting but may impact performance.",
            default = false
        },
        {
            key = "takeAllHotkey",
            renderer = "inputBinding",
            name = "Take All Hotkey",
            description = "Key binding to trigger the Take All functionality.",
            default = "R",
            argument = {
                key = "TakeAll",
                type = "trigger"
            }
        },
    },
}

return settings
