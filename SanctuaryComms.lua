local addonName = "SanctuaryComms"
-- WoW client flavor detection
local _, _, _, tocVersion = GetBuildInfo()
local project = WOW_PROJECT_ID or 0
local RETAIL_PROJECT = WOW_PROJECT_MAINLINE or 1
local CLASSIC_PROJECT = WOW_PROJECT_CLASSIC or 2
local ASCENSION_TOC = 30300
local flavor
if project == RETAIL_PROJECT then
    flavor = "Retail"
elseif project == CLASSIC_PROJECT then
    flavor = "Classic"
elseif tocVersion == ASCENSION_TOC then
    flavor = "Ascension"
else
    flavor = "Unknown"
end

-- Rule filter: returns true to suppress message, false to allow
local function MessageFilter(self, event, msg, author, ...)
    local db = SanctuaryCommsDB or {}
    if db.defaultAllow == nil then db.defaultAllow = true end
    local display = nil
    for _, line in ipairs(db.rules or {}) do
        if type(line) == "string" then
            local prefix, pattern = line:match("^%s*(%a+):%s*(.*)$")
            if prefix and pattern and msg then
                local ok, startIndex = pcall(string.find, msg, pattern)
                if ok and startIndex then
                    local pfx = prefix:upper()
                    if pfx == "DENY" then
                        return true
                    elseif pfx == "ALLOW" then
                        display = true
                        break
                    end
                end
            end
        end
    end
    if display == nil then
        display = db.defaultAllow
    end
    return not display
end

-- Channel filter: returns true to suppress message, false to allow
local function ChannelFilter(self, event, msg, author, ...)
    local db = SanctuaryCommsDB or {}
    local chKey = event:match("^CHAT_MSG_(.+)$")
    if chKey and db.channels and db.channels[chKey] == false then
        return true
    end
    return false
end

local function ToggleConfigPanel()
    if flavor == "Retail" then
        InterfaceOptionsFrame_OpenToCategory(addonName)
        InterfaceOptionsFrame_OpenToCategory(addonName)
    else
        local configPanel = _G["SanctuaryCommsOptions"]
        if configPanel:IsShown() then
            configPanel:Hide()
        else
            configPanel:Show()
        end
    end
end

-- Slash to open config
SLASH_SANCTUARYCOMMS1 = "/sc"
SLASH_SANCTUARYCOMMS2 = "/sanctcomms"
SlashCmdList["SANCTUARYCOMMS"] = ToggleConfigPanel

-- Register filters and setup config panel on ADDON_LOADED
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("ADDON_LOADED")
initFrame:SetScript("OnEvent", function(self, event, name)
    if name ~= addonName then return end
    if not SanctuaryCommsDB then SanctuaryCommsDB = {} end
    local db = SanctuaryCommsDB
    if db.defaultAllow == nil then db.defaultAllow = true end
    if type(db.rules) ~= "table" then db.rules = {} end
    if type(db.channels) ~= "table" then
        db.channels = {
            SAY=true, YELL=true, GUILD=true, OFFICER=false,
            PARTY=true, RAID=true, INSTANCE_CHAT=true, WHISPER=true, CHANNEL=true,
        }
    end
    local chatEvents = {
        "CHAT_MSG_SAY","CHAT_MSG_YELL","CHAT_MSG_GUILD","CHAT_MSG_OFFICER",
        "CHAT_MSG_PARTY","CHAT_MSG_RAID","CHAT_MSG_INSTANCE_CHAT",
        "CHAT_MSG_WHISPER","CHAT_MSG_CHANNEL"
    }
    for _, ev in ipairs(chatEvents) do
        ChatFrame_AddMessageEventFilter(ev, ChannelFilter)
        ChatFrame_AddMessageEventFilter(ev, MessageFilter)
    end

    -- Configuration panel logic
    local configPanel = _G["SanctuaryCommsOptions"]
    local defaultCB = _G["SanctuaryCommsOptionsDefaultAllowCB"]
    local rulesEB = _G["SanctuaryCommsOptionsRulesEditBox"]
    local closeBtn = _G["SanctuaryCommsOptionsCloseButton"]

    configPanel.name = addonName

    configPanel.refresh = function()
        local db = SanctuaryCommsDB or {}
        defaultCB:SetChecked(db.defaultAllow)
        if db.rules then
            rulesEB:SetText(table.concat(db.rules, "\n"))
        else
            rulesEB:SetText("")
        end
    end

    configPanel.okay = function()
        if not SanctuaryCommsDB then SanctuaryCommsDB = {} end
        local db = SanctuaryCommsDB
        db.defaultAllow = defaultCB:GetChecked()
        local text = rulesEB:GetText() or ""
        local newRules = {}
        for line in text:gmatch("[^\r\n]+") do
            table.insert(newRules, line)
        end
        db.rules = newRules
    end

    configPanel:SetScript("OnShow", function(self) self:refresh() end)
    closeBtn:SetScript("OnClick", function()
        configPanel:okay()
        configPanel:Hide()
    end)

    if flavor == "Retail" then
        InterfaceOptions_AddCategory(configPanel)
    else
        configPanel:SetScript("OnDragStart", configPanel.StartMoving)
        configPanel:SetScript("OnDragStop", configPanel.StopMovingOrSizing)
    end
end)
