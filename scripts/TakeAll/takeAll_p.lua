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
            -- Proper way to close UI in OpenMW
            I.UI.setMode()
        end

        -- Animate container opening first
        currentContainer:sendEvent("TakeAll_openAnimation", player)

        -- Process the items
        local itemCount = core.sendGlobalEvent("TakeAll_takeAll", { player, currentContainer, disposeCorpse }) or 0

        -- Make sure to notify global script that we've closed the UI
        core.sendGlobalEvent("TakeAll_closeGUI", self.object)

        -- Display a message about how many items were taken
        if itemCount > 0 then
            ui.showMessage("Took " .. itemCount .. " items from " .. containerName)
        else
            Debug.takeAll("No items taken")
            ui.showMessage(containerName .. " is empty or items couldn't be taken")
        end

        -- Reset container reference
        currentContainer = nil
    else
        Debug.takeAll("No container is currently open")
        ui.showMessage("No container is currently open")
    end
end

-- Function to handle UI mode changes (detect when containers are opened/closed)
local function UiModeChanged(data)
    Debug.takeAll("UI Mode changed from " .. (data.oldMode or "none") .. " to " .. (data.newMode or "none"))

    -- Container is being opened
    if data.newMode == "Container" and data.arg then
        Debug.takeAll("Container opened: " .. data.arg.type.records[data.arg.recordId].name)
        currentContainer = data.arg

        -- Notify global script that we've opened the UI
        core.sendGlobalEvent("TakeAll_openGUI", self.object)
        -- Container is being closed
    elseif data.oldMode == "Container" then
        Debug.takeAll("Container closed")

        -- Only send the close animation if we have a valid container
        if currentContainer then
            -- Send close animation event
            currentContainer:sendEvent("TakeAll_closeAnimation", self)

            -- Notify global script that we've closed the UI
            core.sendGlobalEvent("TakeAll_closeGUI", self.object)

            -- Reset container reference
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

    -- Register our handler using async:callback pattern from QuickLoot
    input.registerTriggerHandler("TakeAll", async:callback(onTakeAll))

    -- Test global script communication on init
    testGlobalScript()
end

-- Clean up function for when script is unloaded
local function onSave()
    -- Reset the container reference when saving
    if currentContainer then
        core.sendGlobalEvent("TakeAll_closeGUI", self.object)
    end
    currentContainer = nil
    return {}
end

-- Load function to restore state
local function onLoad(data)
    -- Initialize the TakeAll system when loading a save
    onInit()
    -- Reset container reference on load
    if currentContainer then
        core.sendGlobalEvent("TakeAll_closeGUI", self.object)
    end
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
