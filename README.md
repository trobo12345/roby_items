# Roby Items

> **v2.0.0** — Complete redesign with modern UI, ACE permissions, Discord logging, banned items, amount selection, and automatic update notifications.

## Features

- **Modern UI** — Glassmorphism design with Inter font, rounded cards, pill-shaped buttons, and smooth transitions
- **Item images** — Pulls item icons directly from `ox_inventory` (with graceful fallback)
- **Amount selection** — Choose exactly how many items to retrieve or give
- **Give to player** — Give any item to another player by their server ID
- **Banned items** — Block specific items from being retrieved or given via config
- **Permission system** — Choose between ACE permissions (`roby_items.use`) or ESX group-based access
- **Discord logging** — Webhook embed logging for every retrieve and give action
- **Multilingual** — English, Hungarian, German (`shared/lang.lua`)
- **Update notifications** — Server console and in-game UI badge when a new version is available
- **Pagination & search** — 10 items per page with live search filtering

## Requirements

- [ESX Framework](https://github.com/esx-framework/esx_core)
- [ox_inventory](https://github.com/overextended/ox_inventory)

## Installation

1. Drop the `roby_items` folder into your server's `resources` directory.
2. Add `ensure roby_items` to your `server.cfg`.
3. Restart the server or run `refresh` + `ensure roby_items` in the console.

## Configuration

All settings are split between `shared/config.lua` (shared) and `server/server.lua` (server-only).

### `shared/config.lua`

```lua
Roby.Debug = false          -- Print debug messages to console
Roby.Language = "en"        -- "en" | "hu" | "de"

-- Permission system
-- true  → ACE node "roby_items.use"
--         add_ace identifier.license:XXXX roby_items.use allow
-- false → ESX group check (AllowedGroups below)
Roby.UseAcePermission = false

Roby.AllowedGroups = {
    ['admin']      = true,
    ['superadmin'] = true,
    ['mod']        = true,
}

-- Items that cannot be retrieved or given (server key names)
Roby.BannedItems = {
    -- 'money',
    -- 'black_money',
}
```

### `server/server.lua` (top of file)

```lua
Roby.DiscordWebhook = ""       -- Paste your webhook URL here; leave empty to disable
Roby.DiscordBotName = "Roby Items"
```

## ACE Permissions (optional)

If `Roby.UseAcePermission = true`, grant access per player:

```
add_ace identifier.license:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX roby_items.use allow
```

Or grant to a group:

```
add_ace group.admin roby_items.use allow
```

## Commands

| Command | Description |
|---------|-------------|
| `/items` | Open the item list UI |

## Changelog

### v2.0.0
- Complete UI redesign (glassmorphism, Inter font, item images)
- Amount input for both retrieve and give actions
- ACE permission support (alternative to ESX group check)
- Discord webhook logging with embed for every action
- Banned items list in config
- Automatic version check — update badge in UI + console warning
- Removed admin duty dependency
- English codebase (comments & strings)

### v1.0.4
- Initial public release

Language settings are located in the `lang.lua` file. You can add a new language based on the existing format.

## Requirements
- ESX Legacy (1.2 or newer)
- OX Inventory

## Version
1.0.4

## Author
RobyScripts
