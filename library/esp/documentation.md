# Sirius Esp Library
Documentation for how to edit the sirius esp for your game
## Booting the library
```lua
local espLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Sirius/request/library/esp/esp.lua'),true))()
```
## Setting defualt settings
These settings are all set my defualt, and so are the functions
```lua
espLib.whitelist = {} -- insert string that is the player's name you want to whitelist (turns esp color to whitelistColor in options)
espLib.blacklist = {} -- insert string that is the player's name you want to blacklist (removes player from esp)
espLib.options = {
    enabled = true,
    scaleFactorX = 4,
    scaleFactorY = 5,
    font = 2,
    fontSize = 13,
    limitDistance = false,
    maxDistance = 1000,
    visibleOnly = false,
    teamCheck = false,
    teamColor = false,
    fillColor = nil,
    whitelistColor = Color3.new(1, 0, 0),
    outOfViewArrows = true,
    outOfViewArrowsFilled = true,
    outOfViewArrowsSize = 25,
    outOfViewArrowsRadius = 100,
    outOfViewArrowsColor = Color3.new(1, 1, 1),
    outOfViewArrowsTransparency = 0.5,
    outOfViewArrowsOutline = true,
    outOfViewArrowsOutlineFilled = false,
    outOfViewArrowsOutlineColor = Color3.new(1, 1, 1),
    outOfViewArrowsOutlineTransparency = 1,
    names = true,
    nameTransparency = 1,
    nameColor = Color3.new(1, 1, 1),
    boxes = true,
    boxesTransparency = 1,
    boxesColor = Color3.new(1, 1, 1),
    boxFill = true,
    boxFillTransparency = 0.5,
    boxFillColor = Color3.new(1, 1, 1),
    healthBars = true,
    healthBarsSize = 1,
    healthBarsTransparency = 1,
    healthBarsColor = Color3.new(0, 1, 0),
    healthText = true,
    healthTextTransparency = 1,
    healthTextSuffix = "%",
    healthTextColor = Color3.new(1, 1, 1),
    distance = true,
    distanceTransparency = 1,
    distanceSuffix = " Studs",
    distanceColor = Color3.new(1, 1, 1),
    tracers = false,
    tracerTransparency = 1,
    tracerColor = Color3.new(1, 1, 1),
    tracerOrigin = "Bottom", -- Available [Mouse, Top, Bottom]
}
```
## Functions 
```lua
function espLib.GetCharacter(player)
    local character = player.Character
    return character, character and findFirstChild(character, "HumanoidRootPart")
end
function espLib.GetTeam(player)
    local team = player.Team
    return team, player.TeamColor.Color
end
function espLib.GetHealth(player, character)
    local humanoid = findFirstChild(character, "Humanoid")
    if (humanoid) then
        return humanoid.Health, humanoid.MaxHealth
    end
    return 100, 100
end
```
## Starting the esp 
```lua
espLib.Init()
```
## Unloading the esp 
```lua
espLib.Unload()
```
# Example for Bad Business 
If you need it!
```lua
local espLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Sirius/request/library/esp.lua'),true))()
-- Everything is set by defualt, change what you need (the functions are defualted too)
espLib.whitelist = {} -- insert string that is the player's name you want to whitelist (turns esp color to whitelistColor in options)
espLib.blacklist = {} -- insert string that is the player's name you want to blacklist (removes player from esp)
espLib.options = {
    enabled = true,
    scaleFactorX = 4,
    scaleFactorY = 5,
    font = 2,
    fontSize = 13,
    limitDistance = false,
    maxDistance = 1000,
    visibleOnly = false,
    teamCheck = true,
    teamColor = true,
    fillColor = nil,
    whitelistColor = Color3.new(1, 0, 0),
    outOfViewArrows = true,
    outOfViewArrowsFilled = true,
    outOfViewArrowsSize = 25,
    outOfViewArrowsRadius = 100,
    outOfViewArrowsColor = Color3.new(1, 1, 1),
    outOfViewArrowsTransparency = 0.5,
    outOfViewArrowsOutline = true,
    outOfViewArrowsOutlineFilled = false,
    outOfViewArrowsOutlineColor = Color3.new(1, 1, 1),
    outOfViewArrowsOutlineTransparency = 1,
    names = true,
    nameTransparency = 1,
    nameColor = Color3.new(1, 1, 1),
    boxes = true,
    boxesTransparency = 1,
    boxesColor = Color3.new(1, 1, 1),
    boxFill = true,
    boxFillTransparency = 0.5,
    boxFillColor = Color3.new(1, 1, 1),
    healthBars = true,
    healthBarsSize = 1,
    healthBarsTransparency = 1,
    healthBarsColor = Color3.new(0, 1, 0),
    healthText = true,
    healthTextTransparency = 1,
    healthTextSuffix = "%",
    healthTextColor = Color3.new(1, 1, 1),
    distance = true,
    distanceTransparency = 1,
    distanceSuffix = " Studs",
    distanceColor = Color3.new(1, 1, 1),
    tracers = false,
    tracerTransparency = 1,
    tracerColor = Color3.new(1, 1, 1),
    tracerOrigin = "Bottom", -- Available [Mouse, Top, Bottom]
}


-- THIS STUFF IS FOR MY BAD BUSINESS EXAMPLE
local client = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local mouse = client:GetMouse()
local players = game:GetService("Players")
local rs = game:GetService("RunService") 
local uis = game:GetService("UserInputService")
local ts = require(game:GetService("ReplicatedStorage").TS)
local playerList = {}
for i,v in ipairs(workspace.Characters:GetChildren()) do 
    playerList[ts.Characters:GetPlayerFromCharacter(v).Name] = v
end
workspace.Characters.ChildAdded:connect(function(v)
    playerList[v.Name] = v
end)
workspace.Characters.ChildRemoved:connect(function(v)
    playerList[ts.Characters:GetPlayerFromCharacter(v).Name] = nil
end)
players.PlayerRemoving:connect(function(v) playerList[v.Name] = nil end)
local function tableHas(x,y)
    for i,v in pairs(x) do 
        if v == y then return true end 
    end
end


-- Changing the library
function espLib.GetCharacter(player) -- Change how you get characters for your game
    local character = playerList[player.Name]
    return character, character and game.FindFirstChild(character, "Root") -- Return the character and that the character has it's primary part
end
function espLib.GetTeam(player) -- Change how you get teams of a player 
    -- I DIDN'T ADD THE COLORS TO BE TEAM CHECKED, YOU SHOULD THOUGH!!!
    local team = "Omega"  -- My defualt team for bad business, it doesn't have to be a string they just have to be different 
    local teamColor = Color3.fromRGB(255,0,0) -- Defualt team color
    if tableHas(ts.Teams:GetTeamPlayers("Beta"),player) then  -- Checking the other team 
        team = "Beta" -- Changing the info
        teamColor = Color3.fromRGB(0,0,255)
    end
    return team, teamColor -- Return the team and team color 
end
function espLib.GetHealth(player, character) -- Change how you get health 
    local health = game.FindFirstChild(character, "Health") -- Make sure they have a humanoid / health container 
    if (health) then 
        return health.Value,health.MaxHealth.Value -- Return their current health and their max health 
    end
    return 100, 100 -- If no humanoid just return 100,100 so no error 
end
espLib.Init() -- Start the esp 
wait(10)
espLib.Unload() -- Unload esp 
```
