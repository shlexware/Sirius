# Sirius Style Guide
### for use with Rayfield Interface Suite (https://rayfield.dev)
You must attempt follow this guide for styling when creating scripts for Sirius


## Coding Guidelines
These coding guidelines are recommended to have consistency of the best experience possible.

- All scripts must use Flags (to save configuration files)
- When writing `if` statements, if the code is simple (e.g `if not workspace then return end`), please make it one line, otherwise use multi lined `if` statements.
- When referencing objects, make a variable for them (e.g `local coin = workspace.Coin`)
- When using an ESP, use Sirius Sense (https://github.com/shlexware/Sirius/blob/request/library/sense/Documentation.md)

## Window Settings
```lua
local Window = Rayfield:CreateWindow({
	Name = "Game Name", -- Simplified game name (e.g [GUNS] Arsenal --> Arsenal)
	ConfigurationSaving = {
		Enabled = true,
		FileName = "SiriusGAMENAME" -- Replace `GAMENAME` with the name of the game you're developing for
	}
})
```

## Tab
If any of these do not apply to the game, do not create that tab
### Aim
This is for anything that adjusts your aiming, e.g Aimbot, Silent Aim etc
```lua
local aimTab = Window:CreateTab("Aim")
```
### Player
Flying? Using walkspeed? Invisibility? Put it in here.
```lua
local playerTab = Window:CreateTab("Player")
```
### Visual
This tab will house things such as ESP, gun cosmetics and more, anything on-screen and customisable
```lua
local visualTab = Window:CreateTab("Visual")
```
### Autofarm/Automatic things
This tab is intended to contain anything that is automated, such as an autofarm
```lua
local autoTab = Window:CreateTab("Automated") -- Adjust the tab name to be specific here (e.g Autofarm, Autofish etc)
```
### Server
This tab will include anything that affects the majority of players in the game or does something serverside
```lua
local serverTab = Window:CreateTab("Server")
```
### Misc
Anything that doesn't fit into the other tabs, place in here
```lua
local miscTab = Window:CreateTab("Misc")
```
### Experimental
Got something that isn't reliable 100% of the time? Shove it in this section. 
```lua
local experimentalTab = Window:CreateTab("Experimental")
```
