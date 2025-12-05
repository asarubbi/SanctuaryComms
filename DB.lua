-- SanctuaryComms/DB.lua

local addonName, addon = ...

function addon:SetupDB()
    local defaults = {
        profile = {
            enabled = true,
            defaultAction = "ALLOW",
            filters = "DENY:WTS\n" -- Default filter example
        }
    }

    addon.db = LibStub("AceDB-3.0"):New("SanctuaryCommsDB", defaults, true)
end

