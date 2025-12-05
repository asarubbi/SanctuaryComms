### Addon Development Prompt: SanctuaryComms

You are an expert World of Warcraft addon developer, specializing in creating clean, efficient, and maintainable addons using the Ace3 framework. Your task is to create the **SanctuaryComms** addon from scratch.

#### 1. High-Level Objective

Create a chat filtering addon named **SanctuaryComms**. Its purpose is to act as a firewall for the chat box, filtering incoming messages based on user-defined patterns before they are displayed. The addon must be easy to configure, robust, and efficient, with a clear separation between its core logic, database management, and user interface.

#### 2. Core Functionality (The "Engine")

The core of the addon is the filtering mechanism. This should be implemented in a file named `Core.lua`.

*   **Event Hooking:** The addon must intercept all standard chat messages. The primary method should be to securely hook the `ChatFrame_AddMessage` function. This ensures that we can intercept the message content just before it is rendered.
*   **Filtering Logic:**
    1.  When a message is intercepted, the addon should retrieve the active profile's filter rules from the database.
    2.  It must iterate through the rules sequentially, from top to bottom.
    3.  For each rule, it must parse the `ALLOW:pattern` or `DENY:pattern` prefix.
    4.  **Case-Insensitivity:** To ensure case-insensitive matching, the incoming message content (and any other relevant parts like author or channel name) should be converted to lowercase using `string.lower()` before pattern evaluation.
    5.  The `pattern` part of the rule must be treated as a Lua pattern. Use `string.match()` to test this pattern against the lowercased, full, raw message arguments provided to `ChatFrame_AddMessage`.
    6.  **First Match Wins:** The first rule that matches the message content dictates the outcome.
        *   If it's an `ALLOW` rule, the original `ChatFrame_AddMessage` function is called with the original arguments, and no further rules are processed for that message.
        *   If it's a `DENY` rule, the message is blocked (i.e., the original function is *not* called), and no further rules are processed.
    7.  **Default Action:** If the message does not match any of the defined rules, the profile's "Default Action" (`ALLOW` or `DENY`) is applied.
*   **Enable/Disable:** The entire filtering mechanism must be globally toggleable via the "Enabled" flag in the UI. If disabled, the hook should be bypassed entirely, incurring zero performance overhead.

#### 3. Database and Settings (`DB.lua`)

Use **AceDB-3.0** to manage all saved variables. The main database variable should be `SanctuaryCommsDB`.

*   **Structure:** The database should be profile-based. The default profile structure should be:
    ```lua
    {
        profile = {
            enabled = true,
            defaultAction = "ALLOW", -- or "DENY"
            filters = "ALLOW:some guild recruitment\nDENY:WTS\n" -- A single string with newline separators
        }
    }
    ```
*   **Profiles:** The addon must fully support multiple profiles, allowing users to switch between different rule sets. Use the standard profile management features provided by AceDB.

#### 4. Configuration UI (`Options.lua`)

The user interface for configuration should be built using **AceConfig-3.0** and **AceGUI-3.0**. It should be accessible via the slash commands `/sc` and `/sanctuarycomms`.

*   **Main Options Panel:**
    *   **Enabled Checkbox:** A top-level checkbox to control the `enabled` flag in the database.
        *   **Widget:** `AceGUIWidget-CheckBox`
        *   **Label:** "Enable SanctuaryComms Filtering"
    *   **Profile Management:** Use the standard options provided by **AceDBOptions-3.0** to allow creating, deleting, copying, and switching profiles.
    *   **Default Action Dropdown:** A dropdown menu to set the `defaultAction`.
        *   **Widget:** `AceGUIWidget-Dropdown`
        *   **Label:** "Default action for unmatched messages"
        *   **Values:** `ALLOW`, `DENY`
    *   **Filter Rules Multi-line Edit Box:** A large text area for users to input their filter rules.
        *   **Widget:** `AceGUIWidget-MultiLineEditBox`
        *   **Label:** "Filter Patterns (one per line, e.g., DENY:text or ALLOW:text)"
        *   This should be set to be full-width and have a reasonable height (e.g., 15-20 lines).

#### 5. Project Structure and Files

The addon should be structured in the `sanctuarycomms/` directory, mirroring the clean, modular layout of Bartender4.

*   **`sanctuarycomms/`**
    *   **`SanctuaryComms.toc`**: For Retail.
    *   **`SanctuaryComms_Classic.toc`**: For WoW Classic.
    *   **`SanctuaryComms_Ascension.toc`**: For the Ascension custom server.
    *   **`SanctuaryComms.lua`**: Main addon file. Initializes the addon using `AceAddon-3.0`, registers slash commands with `AceConsole-3.0`, and loads other modules.
    *   **`Core.lua`**: Implements the chat hooking and filtering logic.
    *   **`DB.lua`**: Sets up the `AceDB-3.0` database and default values.
    *   **`Options.lua`**: Contains the `AceConfig-3.0` options table for the UI.
    *   **`libs/`**: Directory to contain all required libraries.
        *   `LibStub/`
        *   `CallbackHandler-1.0/`
        *   `AceAddon-3.0/`
        *   `AceConsole-3.0/`
        *   `AceEvent-3.0/`
        *   `AceDB-3.0/`
        *   `AceDBOptions-3.0/`
        *   `AceGUI-3.0/`
        *   `AceConfig-3.0/`

##### `.toc` File Example (`SanctuaryComms.toc`)

```
## Interface: {RETAIL_VERSION_NUMBER}
## Title: SanctuaryComms
## Notes: Filters unwanted chat messages.
## Author: YourName
## Version: 1.0.0
## SavedVariables: SanctuaryCommsDB
## OptionalDeps: Ace3

#@no-lib-strip@
libs\LibStub\LibStub.lua
libs\CallbackHandler-1.0\CallbackHandler-1.0.xml
libs\AceAddon-3.0\AceAddon-3.0.xml
libs\AceConsole-3.0\AceConsole-3.0.xml
libs\AceEvent-3.0\AceEvent-3.0.xml
libs\AceDB-3.0\AceDB-3.0.xml
libs\AceDBOptions-3.0\AceDBOptions-3.0.xml
libs\AceGUI-3.0\AceGUI-3.0.xml
libs\AceConfig-3.0\AceConfig-3.0.xml
#@end-no-lib-strip@

DB.lua
Core.lua
Options.lua
SanctuaryComms.lua
```
*(Create similar `.toc` files for Classic and Ascension, replacing `{VERSION_NUMBER}` with the appropriate interface numbers you will provide.)*

#### 6. GitHub Actions Release Workflow

Create a file at `.github/workflows/release.yml`. This workflow should automate the packaging and release process.

*   **Trigger:** The workflow must trigger when a tag is pushed, specifically tags matching the pattern `v*` (e.g., `v1.0.1`).
*   **Jobs:**
    1.  **`create-release`:**
        *   Uses an action (e.g., `actions/create-release`) to create a new draft release on GitHub. The release name and body should be derived from the tag.
    2.  **`package-and-upload`:**
        *   Needs to run after `create-release`.
        *   **Checkout Code:** Checks out the repository content.
        *   **Package Retail:**
            *   Creates a `SanctuaryComms/` directory.
            *   Copies all addon files (`.lua`, `libs/`, etc.) into it.
            *   Copies `SanctuaryComms.toc` into the directory.
            *   Zips the `SanctuaryComms/` directory into `SanctuaryComms-Retail.zip`.
        *   **Package Classic:**
            *   Repeats the process, but copies `SanctuaryComms_Classic.toc` and renames it to `SanctuaryComms.toc` inside the temporary packaging directory.
            *   Zips the result into `SanctuaryComms-Classic.zip`.
        *   **Package Ascension:**
            *   Repeats the process, but copies `SanctuaryComms_Ascension.toc` and renames it to `SanctuaryComms.toc`.
            *   Zips the result into `SanctuaryComms-Ascension.zip`.
        *   **Upload Assets:**
            *   Uses an action (e.g., `actions/upload-release-asset`) to upload all three ZIP files (`-Retail`, `-Classic`, `-Ascension`) to the previously created GitHub release.

This detailed prompt provides a complete blueprint for building the SanctuaryComms addon, ensuring it meets all functional requirements while adhering to best practices for structure, maintenance, and distribution.
