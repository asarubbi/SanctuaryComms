# sanctuarycomms
A Drop-In Firewall-Style Chat Filter for WoW


SanctuaryComms gives you complete control over your chat by plugging directly into Blizzard’s default ChatFrames and
applying ordered Allow/Deny rules using Lua patterns. Instead of building a separate window, it filters messages at the
source, so only the lines you want ever reach your chat panels.

Key Features
• Pattern-Based Rules – Define ALLOW: or DENY: rules with full Lua regex support (e.g. “DENY: [Rr]ecruit”).
• Default Policy – Choose to block everything not explicitly allowed, or allow everything not explicitly denied.
• Channel Toggles – Easily enable/disable entire streams (Guild, Party, Trade, etc.) via the config panel.
• Seamless Integration – Uses ChatFrame_AddMessageEventFilter; your filtered chat shows up in the regular WoW chat windows.
• In-Game Configuration – Edit rules and settings under Interface → AddOns → SanctuaryComms or via /sc.
• Link & Tooltip Support – Item and URL hyperlinks work exactly like the default chat.

Usage

    1. Install the addon and reload UI.
    2. Open the config panel (/sc).
    3. Add your ALLOW/DENY rules, set your default policy, and toggle channels.
    4. Sit back and enjoy spam-free, personalized chat.

SanctuaryComms requires no external libraries and minimal overhead—just pure Lua filtering on Blizzard’s built-in chat
events. Perfect for anyone who wants a light, configurable chat guard without abandoning the standard WoW chat UI.

# Examples
```
DENY:%f[%a][Ww][Tt][Ss]%f[%A]
DENY:%f[%a][Ww][Tt][Bb]%f[%A]
DENY: %f[%a][Gg]uild%f[%A]
DENY: [Rr]ecruit%a+w
DENY: ^%[1%. Ascension%]
DENY: %f[%a][Rr]ecruit%f[%A]
```
