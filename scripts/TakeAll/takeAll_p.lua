local core = require("openmw.core")
local async = require('openmw.async')
local input = require("openmw.input")
local ui = require("openmw.ui")
local types = require("openmw.types")
local settings = require("scripts.TakeAll.ta_settings")
local Debug = require("scripts.TakeAll.ta_debug")
local I = require("openmw.interfaces")
local self = require("openmw.self")

-- Main TakeAll module
local TakeAll = {}

-- Variable to store the currently opened container
local currentContainer = nil

-- Test global script communication
local function testGlobalScript()
    Debug.takeAll("Testing global script communication")
    core.sendGlobalEvent("TakeAll_test", { "Test message from player script" })
end

-- Function to take a single item - delegates to global script
local function takeItem(player, container, item)
    Debug.takeAll("Taking item: " .. item.type.records[item.recordId].name)

    -- Animate the container
    if container then
        container:sendEvent("TakeAll_openAnimation", player)
    end

    -- Send to global script for processing
    core.sendGlobalEvent("TakeAll_take", { player, container, item })
    return true
end

-- Create the handler for the TakeAll trigger
local function onTakeAll()
    Debug.takeAll("--------------------------------")
    Debug.takeAll("TakeAll trigger activated!")

    if currentContainer then
        local containerName = currentContainer.type.records[currentContainer.recordId].name
        Debug.takeAll("Container detected: " .. containerName)

        -- Use the global script to take all items
        local player = self
        local disposeCorpse = false -- Could be a setting option in the future

        -- First, close the container interface if it's open
        if I.UI.getMode() == "Container" then
            I.UI.setMode()
        end

        -- Animate container opening
        currentContainer:sendEvent("TakeAll_openAnimation", player)

        -- Process items immediately instead of using async
        -- Send to global script for processing
        local itemCount = core.sendGlobalEvent("TakeAll_takeAll", { player, currentContainer, disposeCorpse }) or 0

        -- Display a message about how many items were taken
        if itemCount > 0 then
            ui.showMessage("Took " .. itemCount .. " items from " .. containerName)
        else
            Debug.takeAll("No items taken, opening standard container UI as fallback")
            ui.showMessage(containerName .. " is empty or items couldn't be taken")

            -- Open standard container as a fallback
            I.UI.setMode("Container", { target = currentContainer })
        end
    else
        Debug.takeAll("No container is currently open")
        ui.showMessage("No container is currently open")
    end
end

-- Function to handle UI mode changes (detect when containers are opened/closed)
local function UiModeChanged(data)
    Debug.takeAll("UI Mode changed from " .. (data.oldMode or "none") .. " to " .. (data.newMode or "none"))

    if data.newMode == "Container" and data.arg then
        Debug.takeAll("Container opened: " .. data.arg.type.records[data.arg.recordId].name)
        currentContainer = data.arg

        -- Send open animation event when container UI opens normally
        currentContainer:sendEvent("TakeAll_openAnimation", self)
    elseif data.oldMode == "Container" and currentContainer then
        Debug.takeAll("Container closed")
        -- Animate container closing
        if currentContainer then
            currentContainer:sendEvent("TakeAll_closeAnimation", self)

            -- After short delay, clear the container reference
            -- Don't use async timer here - just clear it immediately
            currentContainer = nil
        else
            currentContainer = nil
        end
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
    input.registerTriggerHandler("TakeAll", async:callback(function()
        onTakeAll()
    end))

    -- Test global script communication on init
    testGlobalScript()
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
    return {}
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
        UiModeChanged = UiModeChanged
    }
}
