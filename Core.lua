-- SanctuaryComms/Core.lua

local addonName, addon = ...
local Core = addon:NewModule("Core", "AceEvent-3.0", "AceHook-3.0")
addon.Core = Core

local strlower = string.lower
local strmatch = string.match

-- Cache parsed rules to avoid reprocessing the string on every message
local parsedRules = {}
local lastFilterString = nil

local function ParseRules(filterString)
    if lastFilterString == filterString then
        return
    end

    wipe(parsedRules)
    if not filterString or filterString == "" then
        lastFilterString = filterString
        return
    end

    for line in filterString:gmatch("([^\r\n]*)") do
        if line and line ~= "" then
            local action, pattern = line:match("^(ALLOW):(.*)")
            if not action then
                action, pattern = line:match("^(DENY):(.*)")
            end

            if action and pattern and pattern ~= "" then
                table.insert(parsedRules, { action = action, pattern = pattern })
            end
        end
    end
    lastFilterString = filterString
end

-- This hook now intercepts the :AddMessage method on a specific chat frame.
-- The 'frame' is passed as the first argument by the hook.
function Core:ChatFilterHook(frame, ...)
    local original_add_message = self.hooks[frame].AddMessage

    if not addon.db.profile.enabled then
        return original_add_message(frame, ...)
    end

    -- The message text is now the first of the variadic arguments.
    local message = select(1, ...)
    if type(message) ~= "string" or message == "" then
        return original_add_message(frame, ...)
    end

    ParseRules(addon.db.profile.filters)
    local lowerMessage = strlower(message)
    local matched = false

    for _, rule in ipairs(parsedRules) do
        if strmatch(lowerMessage, strlower(rule.pattern)) then
            matched = true
            if rule.action == "ALLOW" then
                return original_add_message(frame, ...)
            else -- DENY
                return -- Block the message
            end
        end
    end

    -- If no rules matched, apply the default action
    if not matched then
        if addon.db.profile.defaultAction == "ALLOW" then
            return original_add_message(frame, ...)
        else
            return -- Block the message
        end
    end
end

function Core:InitializeHook()
    local hooked = false
    for i = 1, NUM_CHAT_WINDOWS do
        local frame = _G["ChatFrame"..i]
        if frame and frame.AddMessage and not self:IsHooked(frame, "AddMessage") then
            self:RawHook(frame, "AddMessage", "ChatFilterHook", true)
            hooked = true
        end
    end

    if hooked then
        addon:Print("Chat filtering is active.")
    else
        addon:Print("Error: Could not hook any chat frames.")
    end
end

function Core:PLAYER_ENTERING_WORLD(event, ...)
    self:InitializeHook()
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function Core:OnEnable()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    addon:Print("Core module enabled. Waiting for UI to load...")
end

function Core:OnDisable()
    for i = 1, NUM_CHAT_WINDOWS do
        local frame = _G["ChatFrame"..i]
        if frame then
            self:Unhook(frame, "AddMessage")
        end
    end
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    addon:Print("Core module disabled and chat filtering is inactive.")
end

