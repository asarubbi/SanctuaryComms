local addonName = "SanctuaryComms"
-- Minimal WoW Classic chat replacement
local f = CreateFrame("Frame", addonName.."Frame", UIParent)
f:SetSize(600,300)
f:SetPoint("BOTTOMLEFT",UIParent,"BOTTOMLEFT",5,5)
f:SetMovable(true); f:EnableMouse(true)
f:RegisterForDrag("LeftButton")
   -- Enable dragging
   f:SetScript("OnDragStart", function(self)
       self:StartMoving()
   end)
   f:SetScript("OnDragStop", function(self)
       self:StopMovingOrSizing()
   end)
   -- Enable resizing
   f:SetResizable(true)
   f:SetMinResize(200,100)
   local resizeBtn = CreateFrame("Button", addonName.."ResizeButton", f)
   resizeBtn:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -4, 4)
   resizeBtn:SetSize(16,16)
   resizeBtn:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
   resizeBtn:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
   resizeBtn:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
   resizeBtn:SetScript("OnMouseDown", function(self, button)
       if button == "LeftButton" then
           f:StartSizing("BOTTOMRIGHT")
       end
   end)
   resizeBtn:SetScript("OnMouseUp", function(self)
       f:StopMovingOrSizing()
   end)
   f:Show()

-- Scrollable message frame
local msgf = CreateFrame("ScrollingMessageFrame", addonName.."MsgFrame", f)
msgf:SetAllPoints(f)
msgf:SetFontObject(ChatFontNormal)
msgf:SetJustifyH("LEFT")
msgf:SetMaxLines(200)
msgf:EnableMouseWheel(true)
msgf:SetScript("OnMouseWheel", function(self,delta)
    if delta>0 then self:ScrollUp() else self:ScrollDown() end
end)
msgf:Show()

-- Hide default chat
for i=1,(NUM_CHAT_WINDOWS or 10) do
    local cf=_G["ChatFrame"..i]
    if cf then cf:Hide(); cf:UnregisterAllEvents() end
end

-- Handle addon loaded and chat events
f:RegisterEvent("ADDON_LOADED")
local chatEvents = {
    "CHAT_MSG_SAY","CHAT_MSG_YELL","CHAT_MSG_GUILD","CHAT_MSG_OFFICER",
    "CHAT_MSG_PARTY","CHAT_MSG_RAID","CHAT_MSG_INSTANCE_CHAT","CHAT_MSG_WHISPER","CHAT_MSG_CHANNEL"
}
for _,event in ipairs(chatEvents) do
    f:RegisterEvent(event)
end
f:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local name = ...
        if name == addonName then
            if not SanctuaryCommsDB then SanctuaryCommsDB = {} end
            local db = SanctuaryCommsDB
            if db.defaultAllow == nil then db.defaultAllow = true end
            if type(db.rules) ~= "table" then db.rules = {} end
            if type(db.channels) ~= "table" then
                db.channels = {
                    SAY = true, YELL = true, GUILD = true, OFFICER = false,
                    PARTY = true, RAID = true, INSTANCE_CHAT = true, WHISPER = true, CHANNEL = true,
                }
            end
        end
        return
    end
    -- Chat event handling
    local msg, author = ...
    local db = SanctuaryCommsDB or {}
    -- Channel filtering
    local chKey = event:match("^CHAT_MSG_(.+)$")
    if chKey and db.channels and db.channels[chKey] == false then
        return
    end
    -- Rule engine
    local display = nil
    for _, ruleLine in ipairs(db.rules or {}) do
        if type(ruleLine) == "string" then
            local trimmed = ruleLine:match("^%s*(.-)%s*$")
            local prefix, pattern = trimmed:match("^(%a+):%s*(.*)$")
            if prefix and pattern and msg then
                local ok, startIndex = pcall(string.find, msg, pattern)
                if ok and startIndex then
                    local pfx = prefix:upper()
                    if pfx == "DENY" then
                        display = false
                        break
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
    if display then
        local out
        if event == "CHAT_MSG_CHANNEL" then
            local chn = select(9, ...)
            out = string.format("[%s] %s: %s", chn or "", author or "", msg or "")
        else
            out = string.format("%s: %s", author or "", msg or "")
        end
        msgf:AddMessage(out)
    end
end)

-- Configuration panel
do
    local p = CreateFrame("Frame", addonName.."Options", UIParent)
    p.name = addonName
    -- Title
    local title = p:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText(addonName.." Configuration")
    -- Default allow checkbox
    local defaultCB = CreateFrame("CheckButton", addonName.."DefaultAllowCB", p, "InterfaceOptionsCheckButtonTemplate")
    defaultCB:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -16)
    _G[defaultCB:GetName().."Text"]:SetText("Default Allow")
    -- Rules label
    local rulesLabel = p:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    rulesLabel:SetPoint("TOPLEFT", defaultCB, "BOTTOMLEFT", 0, -32)
    rulesLabel:SetText("Rules (one per line, prefix ALLOW: or DENY:)")
    -- Rules edit box
    local rulesEB = CreateFrame("EditBox", addonName.."RulesEditBox", p, "InputBoxTemplate")
    rulesEB:SetMultiLine(true)
    rulesEB:SetAutoFocus(false)
    rulesEB:EnableMouse(true)
    rulesEB:SetSize(400, 200)
    rulesEB:SetPoint("TOPLEFT", rulesLabel, "BOTTOMLEFT", 0, -8)
    rulesEB:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    -- Populate and save functions
    p.refresh = function()
        local db = SanctuaryCommsDB or {}
        defaultCB:SetChecked(db.defaultAllow)
        if db.rules then
            rulesEB:SetText(table.concat(db.rules, "\n"))
        else
            rulesEB:SetText("")
        end
    end
    p.okay = function()
        local db = SanctuaryCommsDB
        db.defaultAllow = defaultCB:GetChecked()
        local text = rulesEB:GetText() or ""
        local newRules = {}
        for line in text:gmatch("[^\r\n]+") do
            table.insert(newRules, line)
        end
        db.rules = newRules
    end
    p:SetScript("OnShow", function(self) self:refresh() end)
    InterfaceOptions_AddCategory(p)
end

-- Slash to open config
SLASH_SANCTUARYCOMMS1="/sc"
SLASH_SANCTUARYCOMMS2="/sanctuary"
SlashCmdList["SANCTUARYCOMMS"] = function() InterfaceOptionsFrame_OpenToCategory(addonName); InterfaceOptionsFrame_OpenToCategory(addonName) end