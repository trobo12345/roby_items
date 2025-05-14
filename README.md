# Roby Items

## Description
'roby_items' is a FiveM resource that provides players with a graphical interface for managing items. The system allows listing, retrieving, and transferring items to other players using the OX inventory system.

## Features
- Modern, responsive UI
- Item search functionality
- Item pagination
- Item retrieval
- Item transfer to other players
- Multilingual support (Hungarian, English, and German)
- ESX notification support

## Installation
1. Copy the `roby_items` folder into your server's resources directory.
2. Add `ensure roby_items` to your `server.cfg` file.
3. Restart the server or use the `refresh` and `ensure roby_items` commands.

## Usage
Use the `/items` command to view the item list.

## Configuration
In the `config.lua` file, you can modify the following settings:
- `Roby.Debug`: Enable/disable debug messages
- `Roby.Language`: Language setting ("hu" for Hungarian, "en" for English, "de" for German)
- `Roby.AllowedGroups`: Authorized admin groups (default: admin, superadmin, mod)
- `Roby.EnableAdminDutySupport`: Enable/disable support for the `asdasd_adminduty` system

## Translation
Language settings are located in the `lang.lua` file. You can add a new language based on the existing format.

## Requirements
- ESX Legacy (1.2 or newer)
- OX Inventory

## Version
1.0.4

## Author
RobyScripts
