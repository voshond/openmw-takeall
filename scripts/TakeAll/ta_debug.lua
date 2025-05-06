local storage = require('openmw.storage')
local settings = storage.playerSection("SettingsTakeAll")

-- Debug module to centralize all logging functionality
local Debug = {}

-- Main logging function that checks if debug is enabled before printing
function Debug.log(module, message)
    if settings:get("enableDebugLogging") then
        print("[" .. module .. "] " .. tostring(message))
    end
end

-- Shorthand for specific module logs
function Debug.takeAll(message)
    Debug.log("TakeAll", message)
end

-- Function to report errors that will always print regardless of debug setting
function Debug.error(module, message)
    print("[ERROR:" .. module .. "] " .. tostring(message))
end

-- Function to report warnings that will always print regardless of debug setting
function Debug.warning(module, message)
    print("[WARNING:" .. module .. "] " .. tostring(message))
end

-- Function to check if debug logging is enabled
function Debug.isEnabled()
    return settings:get("enableDebugLogging")
end

return Debug
