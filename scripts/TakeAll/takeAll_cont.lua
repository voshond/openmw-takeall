local core = require('openmw.core')
local animation = require('openmw.animation')
local self = require('openmw.self')
local Debug = require("scripts.TakeAll.ta_debug")

-- Container animation handling
local inspectors = {}
local currentTime = nil
local active = false
local initialized = false
local lootTime = nil
local stopTime = nil
local closeTime = nil

-- Initialize the animation timings when needed
local function initialize()
    if not initialized then
        initialized = true
        lootTime = animation.getTextKeyTime(self, "containeropen: loot")
        stopTime = animation.getTextKeyTime(self, "containeropen: stop") or 0
        closeTime = animation.getTextKeyTime(self, "containerclose: stop") or 0
        Debug.takeAll("Container animation initialized: loot=" ..
        (lootTime or "nil") .. ", stop=" .. stopTime .. ", close=" .. closeTime)
    end
end

-- Open container animation
local function openAnimation(player)
    initialize()
    if not lootTime then return end

    Debug.takeAll("Opening container animation for: " .. player.recordId)

    -- If no other inspectors, animate opening
    if not next(inspectors) then
        local tempTime = closeTime - (currentTime or closeTime)
        animation.cancel(self, 'containerclose')
        if tempTime + 1 / 30 > lootTime then
            animation.playBlended(self, 'containeropen', {
                priority = 9999,
                startPoint = math.max(tempTime, 0.0001),
                startKey = "loot",
                stopKey = "stop",
                autoDisable = false
            })
        else
            animation.playBlended(self, 'containeropen', {
                priority = 9999,
                startPoint = tempTime,
                startKey = "start",
                stopKey = "stop",
                autoDisable = false
            })
        end
        currentTime = animation.getCurrentTime(self, "containeropen")
    end

    -- Add this player to inspectors list
    inspectors[player.id] = true
    active = true
end

-- Close container animation
local function closeAnimation(player)
    initialize()
    if not lootTime then return end

    Debug.takeAll("Closing container animation for: " .. player.recordId)

    -- Remove this player from inspectors
    inspectors[player.id] = nil

    -- If no more inspectors, start closing animation
    if not next(inspectors) and currentTime then
        animation.cancel(self, 'containeropen')
        animation.playBlended(self, 'containerclose', {
            priority = 9999,
            startPoint = stopTime - (currentTime or stopTime),
            startKey = "start",
            stopKey = "stop"
        })
        currentTime = stopTime - (currentTime or stopTime)
    end
    active = true
end

-- Update function to handle animation transitions
local function onUpdate(dt)
    if not active then
        return
    end

    local at = animation.getCurrentTime(self, "containeropen")
    currentTime = at

    if at and at + dt + 1 / 60 > lootTime and at < lootTime then
        animation.cancel(self, 'containeropen')
        animation.playBlended(self, 'containeropen', {
            priority = 9999,
            startKey = "loot",
            startPoint = 0.0001,
            stopKey = "stop",
            autoDisable = false
        })
    elseif not at then
        at = animation.getCurrentTime(self, "containerclose")
        currentTime = at
    end

    if not currentTime then
        active = false
    end
end

-- Return the script interface
return {
    engineHandlers = {
        onUpdate = onUpdate
    },
    eventHandlers = {
        TakeAll_openAnimation = openAnimation,
        TakeAll_closeAnimation = closeAnimation
    }
}
