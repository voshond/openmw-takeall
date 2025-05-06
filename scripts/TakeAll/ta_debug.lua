-- Debug module to centralize all logging functionality
local Debug = {}

-- Global debug enable flag (set to true for development)
local enableDebugLogging = true

-- Main logging function that checks if debug is enabled before printing
function Debug.log(module, message)
    if enableDebugLogging then
        print("[" .. module .. "] " .. tostring(message))
    end
end

-- Shorthand for specific module logs
function Debug.takeAll(message)
    -- Print TakeAll messages regardless of debug setting for diagnostic purposes
    print("[TakeAll] " .. tostring(message))
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
    return enableDebugLogging
end

return Debug
