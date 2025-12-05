-- SanctuaryComms/SanctuaryComms.lua

local addonName, addon = ...
local SanctuaryComms = LibStub("AceAddon-3.0"):NewAddon(addon, "SanctuaryComms", "AceConsole-3.0", "AceEvent-3.0")

function SanctuaryComms:OnInitialize()
    self:SetupDB()
    self:SetupOptions()
    self:RegisterChatCommand("sc", "ToggleOptions")
    self:RegisterChatCommand("sanctuarycomms", "ToggleOptions")
    self:Print("Initialized. Type /sc to configure.")
end

function SanctuaryComms:OnEnable()
    if self.db.profile.enabled then
        self.Core:Enable()
    end
end

function SanctuaryComms:OnDisable()
    self.Core:Disable()
end

function SanctuaryComms:ToggleOptions()
    LibStub("AceConfigDialog-3.0"):Open("SanctuaryComms")
end
