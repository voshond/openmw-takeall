local storage = nil
local settings = nil

pcall(function()
    storage = require('openmw.storage')
    if storage then
        settings = storage.playerSection("SettingsTakeAll")
    end
end)

-- Debug module to centralize all logging functionality
local Debug = {}

-- Main logging function that checks if debug is enabled before printing
function Debug.log(module, message)
    if settings and settings:get("enableDebugLogging") then
        print("[" .. module .. "] " .. tostring(message))
    end
end

-- Function to report errors that will always print regardless of debug setting
function Debug.error(module, message)
    print("[ERROR:" .. module .. "] " .. tostring(message))
end

-- Function to report warnings that will always print regardless of debug setting
function Debug.warning(module, message)
    print("[WARNING:" .. module .. "] " .. tostring(message))
end

-- Utility function to create a module-specific logger
function Debug.createPrinter(module)
    return function(message)
        Debug.log(module, message)
    end
end

-- Function to check if debug logging is enabled
function Debug.isEnabled()
    return settings and settings:get("enableDebugLogging") or false
end

-- Module-specific loggers
Debug.takeAll = Debug.createPrinter("TakeAll")

return Debug
