# SanctuaryComms: World of Warcraft Chat Replacement AddOn

## Overview
We want to build **SanctuaryComms**, a drop-in replacement for Blizzard’s default chat frames. It will let players filter, organize, and customize their chat streams with a firewall-style rule system powered by Lua regular expressions.

## Goals
- Hide the standard UI chat frames.
- Provide a resizable, tabbed chat window where each tab corresponds to a user-configurable channel (e.g. General, Trade, Guild, Party, Whispers, etc.).
- Allow players to define ordered “allow” and “deny” rules using Lua patterns (regex) that are tested against each incoming message.
- Let users drag to reorder rules, enable/disable individual rules, and use Allow/Deny toggles.
- Persist all settings between sessions, with an in-game Configuration panel under Interface → AddOns.

## Key Features
1. **Frame Management**
   - Hide Blizzard’s ChatFrame1–10 (and any other frames) upon load.
   - Create a single parent frame with:
     - Tabs for each channel.
     - A scrollable edit/scrollback area.
     - An input box for sending messages.
   - Make the window resizable and position-movable.

2. **Channel Routing**
   - Hook `CHAT_MSG_*` events (e.g. `CHAT_MSG_SAY`, `CHAT_MSG_GUILD`).
   - Dispatch messages to the appropriate tab based on the channel filter settings.

3. **Firewall-Style Rule Engine**
   - A list of user-defined rules: each rule has
     - A Lua pattern string
     - An action: Allow or Deny
     - An enabled/disabled checkbox
   - On each incoming message, iterate rules in order:
     1. If a rule matches and is set to Deny → drop the message.
     2. If a rule matches and is set to Allow → display the message.
     3. If no rules match → follow a configurable default (“default allow” or “default deny”).

4. **Configuration UI**
   - Build an Options panel under **Interface → AddOns → SanctuaryComms**.
   - Let users:
     - Add, edit, copy, delete, and reorder rules via drag-handle or Up/Down buttons.
     - Toggle default allow/deny.
     - Select which chat channels to show as tabs.
     - Reset to default settings.
   - Persist settings via `SavedVariables`.

5. **Performance & Quality**
   - Debounce rapid chat storms so UI remains responsive.
   - Localize all user-facing strings.
   - Include meaningful inline comments and follow Blizzard AddOn best practices.

## Deliverables
- `SanctuaryComms.toc`, `.lua`, and `.xml` files ready for installation.
- In-game Configuration panel under Interface → AddOns.
- Example default rule set (e.g., deny common spam patterns).
- `README.md` with install instructions, feature list, and pattern syntax guide.
- (Optional) Unit tests for the rule engine using a Lua test harness.
- Packaged `.zip` suitable for upload to CurseForge / WoWInterface.

## Technical Stack
- Lua 5.1 (WoW’s embedded Lua).
- XML for frame definitions.
- WoW API event hooks, `SavedVariables`, and Interface Options integration.

## Timeline & Milestones (Suggested)
1. Frame stub: hide Blizzard chat, show blank resizable window.
2. Tabbed channel switching & basic message piping.
3. Rule engine core + simple allow-all default.
4. Config UI + persistence.
5. Polish, performance tuning, README, and packaging.