local core = require("openmw.core")
local async = require('openmw.async')
local input = require("openmw.input")
local ui = require("openmw.ui")
local settings = require("scripts.TakeAll.ta_settings")
local Debug = require("scripts.TakeAll.ta_debug")

-- Main TakeAll module
local TakeAll = {}

-- Create the handler for the TakeAll trigger
local function onTakeAll()
    Debug.log("TakeAll", "TakeAll trigger activated!")
    ui.showMessage("Take All activated! (This is just a placeholder)")
    -- In the future, this is where the actual implementation will go
    -- to take all items from the currently viewed container
end

-- Initialize function for the TakeAll module
local function onInit()
    Debug.takeAll("TakeAll mod initialized! Hello World!")

    -- Register the TakeAll trigger in the input system
    input.registerTrigger {
        key = "TakeAll",
        l10n = "SettingsTakeAll", -- Use same context as our settings
        name = "Take All",
        description = "Take all items from containers with a single key press"
    }

    -- Register our handler to be called when the TakeAll trigger is activated
    input.registerTriggerHandler("TakeAll", async:callback(onTakeAll))
end

return {
    interfaceName = "TakeAll",
    interface = TakeAll,
    engineHandlers = {
        onInit = onInit,
        onLoad = function()
            -- Initialize the TakeAll system when loading a save
            onInit()
        end
    }
}
