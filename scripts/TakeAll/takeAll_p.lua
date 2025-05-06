local core = require("openmw.core")
local async = require('openmw.async')
local input = require("openmw.input")
local ui = require("openmw.ui")
local types = require("openmw.types")
local settings = require("scripts.TakeAll.ta_settings")
local Debug = require("scripts.TakeAll.ta_debug")
local I = require("openmw.interfaces")

-- Main TakeAll module
local TakeAll = {}

-- Variable to store the currently opened container
local currentContainer = nil

-- Create the handler for the TakeAll trigger
local function onTakeAll()
    Debug.takeAll("TakeAll trigger activated!")

    if currentContainer then
        local containerName = currentContainer.type.records[currentContainer.recordId].name
        Debug.takeAll("Container detected: " .. containerName)
        ui.showMessage("Taking all items from: " .. containerName)
        -- In the future, this will actually transfer all items from the container
    else
        Debug.takeAll("No container is currently open")
        ui.showMessage("No container is currently open")
    end
end

-- Function to handle UI mode changes (detect when containers are opened/closed)
local function onUiModeChanged(data)
    Debug.takeAll("UI Mode changed from " .. (data.oldMode or "none") .. " to " .. (data.newMode or "none"))

    if data.newMode == "Container" and data.arg then
        Debug.takeAll("Container opened: " .. data.arg.type.records[data.arg.recordId].name)
        currentContainer = data.arg
    elseif data.oldMode == "Container" and currentContainer then
        Debug.takeAll("Container closed")
        currentContainer = nil
    end
end

-- Initialize function for the TakeAll module
local function onInit()
    Debug.takeAll("TakeAll mod initialized!")

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

-- Clean up function for when script is unloaded
local function onSave()
    -- Reset the container reference when saving
    currentContainer = nil
    return {}
end

-- Load function to restore state
local function onLoad(data)
    -- Initialize the TakeAll system when loading a save
    onInit()
    -- Reset container reference on load
    currentContainer = nil
end

return {
    interfaceName = "TakeAll",
    interface = TakeAll,
    engineHandlers = {
        onInit = onInit,
        onSave = onSave,
        onLoad = onLoad
    },
    eventHandlers = {
        UiModeChanged = onUiModeChanged
    }
}
