# Sirius Style Guide
### for Orion UI Library
You must follow this guide for styling when creating scripts for Sirius

## Coding Guidelines
All scripts must use camelCase in coding, not PascalCase or snake_case

All scripts must use Flags (to save config)

When writing `if` statements, if the code is simple (e.g `if not workspace then return end`), please make it one line, otherwise use multi lined `if` statements.

When referencing UI elements, make a variable for them (e.g `local coinButton = UI.Coin.Button`)

## Window Settings
```lua
Name = "Game Name" -- Simplified Version of the game name (e.g [NEW ITEMS!] Arsenal --> Arsenal)
HidePremium = false,
SaveConfig = true,
ConfigFolder = "Sirius",
IntroEnabled = true,
IntroText = "Sirius"
```

## Tab
If any of these do not apply to the game, do not create that tab
### Aim
```lua
Name = "Aim",
Icon = "rbxassetid://10686478216",
PremiumOnly = false
```
### Player
```lua
Name = "Player",
Icon = "rbxassetid://10686489483",
PremiumOnly = false
```
### Visual
```lua
Name = "Visual",
Icon = "rbxassetid://10686484311",
PremiumOnly = false
```
### Autofarm/Automatic things
```lua
Name = "Autofarm",
Icon = "rbxassetid://4483362748",
PremiumOnly = false
```
### Server
```lua
Name = "Server",
Icon = "rbxassetid://4384400106",
PremiumOnly = false
```
### Misc
```lua
Name = "Misc",
Icon = "rbxassetid://4384401360",
PremiumOnly = false
```

## Coloring
Slider: RGB 42, 173, 99
