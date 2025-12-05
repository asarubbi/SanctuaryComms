# SanctuaryComms

SanctuaryComms is a lightweight World of Warcraft addon that acts as a firewall for your chatbox, allowing you to filter unwanted messages before they are ever displayed. Using simple rules and Lua patterns, you can take control of your chat and see only what you want to see.

## Features

- **Pattern-Based Filtering:** Block or allow messages containing specific words, phrases, or complex patterns.
- **Simple Rule Syntax:** Uses an intuitive `ALLOW:pattern` and `DENY:pattern` format.
- **Firewall Logic:** The first rule that matches a message determines its fate.
- **Case-Insensitive:** Patterns are matched without regard to case for ease of use.
- **Profile Management:** Create and switch between different sets of filter rules using built-in profile support, powered by AceDB-3.0.
- **Simple Configuration:** A clean and straightforward options panel built with AceGUI-3.0.

## How to Use

You can configure SanctuaryComms using the slash commands:
- `/sc`
- `/sanctuarycomms`

This will open the main options panel where you can:
- **Enable or Disable** the addon's filtering globally.
- **Manage Profiles** to create different rule sets for different characters or situations.
- **Set a Default Action** (`ALLOW` or `DENY`) for any message that doesn't match a specific rule.
- **Add Filter Rules** in the multi-line text box.

### Filter Rule Examples

Rules are processed from top to bottom. The first pattern to match a message wins.

- **Block trade spam:**
  ```
  DENY:WTS
  DENY:Want to Sell
  ```

- **Ensure you always see messages from your guild, even if they might otherwise be blocked:**
  ```
  ALLOW:MyAwesomeGuild
  DENY:WTS
  ```

- **Block all mentions of a certain legendary weapon:**
  ```
  DENY:thunderfury
  ```

## Installation

1.  Download the latest release ZIP file for your version of World of Warcraft (Retail, Classic, or Ascension).
2.  Extract the ZIP file.
3.  Copy the `SanctuaryComms` folder into your `World of Warcraft/_version_/Interface/AddOns/` directory.
4.  Restart World of Warcraft.

## For Developers

This repository includes a `package.sh` script to build local addon packages. To use it:

1.  Make it executable: `chmod +x package.sh`
2.  Run it with the desired version: `./package.sh <Retail|Classic|Ascension>`
