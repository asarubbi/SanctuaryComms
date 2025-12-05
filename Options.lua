-- SanctuaryComms/Options.lua

local addonName, addon = ...

function addon:SetupOptions()
    local options = {
        name = "SanctuaryComms",
        handler = addon,
        type = "group",
        args = {
            enabled = {
                type = "toggle",
                name = "Enable SanctuaryComms Filtering",
                desc = "Globally enable or disable the chat filter.",
                order = 1,
                get = function(info) return addon.db.profile.enabled end,
                set = function(info, value)
                    addon.db.profile.enabled = value
                    if value then
                        addon.Core:Enable()
                    else
                        addon.Core:Disable()
                    end
                end,
            },
            profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(addon.db),
            defaultAction = {
                type = "select",
                name = "Default action for unmatched messages",
                desc = "What to do with a message that doesn't match any filter.",
                order = 20,
                values = {
                    ALLOW = "Allow",
                    DENY = "Deny",
                },
                get = function(info) return addon.db.profile.defaultAction end,
                set = function(info, value) addon.db.profile.defaultAction = value end,
            },
            filters = {
                type = "group",
                name = "Filters",
                order = 30,
                args = {
                    desc = {
                        type = "description",
                        name = "Enter filter patterns, one per line.\nFormat: ALLOW:pattern or DENY:pattern\nPatterns are case-insensitive.",
                        order = 1,
                    },
                    rules = {
                        type = "input",
                        name = "Filter Patterns",
                        width = "full",
                        multiline = 15,
                        order = 2,
                        get = function(info) return addon.db.profile.filters end,
                        set = function(info, value) addon.db.profile.filters = value end,
                    },
                },
            },
        },
    }

    LibStub("AceConfig-3.0"):RegisterOptionsTable("SanctuaryComms", options)
    LibStub("AceConfigDialog-3.0"):SetDefaultSize("SanctuaryComms", 700, 550)
    addon.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("SanctuaryComms", "SanctuaryComms")
end
