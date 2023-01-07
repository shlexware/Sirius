# Sirius Sense Esp Library
### Pure Performance. No Compromise.
`Sirius Sense was created by mickey for Sirius. It is being actively updated and developed by mickey.`

## Booting Sense
```lua
local Sense = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Sirius/request/library/sense/source.lua'))()
```

### Changing Configuration
You'll need to do this for every value you'd like to change using this method.
If you'd like to know what you can change, read the [`Sense Default Configuration`](https://github.com/shlexware/Sirius/blob/request/library/sense/Documentation.md#sense-default-configuration) part of the documentation.
```lua
Sense.teamSettings.Enemy.enabled = true
```

## Loading Sense
Run this under the code changing the configuration to your liking.
```lua
Sense.Load()
```

## Sense Default Configuration
This is the default configuration for Sense, and most things will be disabled by default.
This shows you everything you can change.
```lua
Sense = {
    whitelist = {}, -- { [game.Players.Player1] = true }
    sharedSettings = {
        textSize = 13,
        textFont = 2,
        limitDistance = false,
        maxDistance = 150,
    },
    teamSettings = {
        Enemy = {
            enabled = false,
            box = false,
            boxColor = { Color3.new(1,0,0), 1 },
            boxOutline = true,
            boxOutlineColor = { Color3.new(), 1 },
            boxFill = false,
            boxFillColor = { Color3.new(1,0,0), 0.5 },
            healthBar = false,
            healthyColor = Color3.new(0,1,0),
            dyingColor = Color3.new(1,0,0),
            healthBarOutline = true,
            healthBarOutlineColor = { Color3.new(), 1 },
            healthText = false,
            healthTextColor = { Color3.new(1,1,1), 1 },
            healthTextOutline = true,
            healthTextOutlineColor = Color3.new(),
            name = false,
            nameColor = { Color3.new(1,1,1), 1 },
            nameOutline = true,
            nameOutlineColor = Color3.new(),
            weapon = false,
            weaponColor = { Color3.new(1,1,1), 1 },
            weaponOutline = true,
            weaponOutlineColor = Color3.new(),
            distance = false,
            distanceColor = { Color3.new(1,1,1), 1 },
            distanceOutline = true,
            distanceOutlineColor = Color3.new(),
            tracer = false,
            tracerOrigin = "Bottom",
            tracerColor = { Color3.new(1,0,0), 1 },
            tracerOutline = true,
            tracerOutlineColor = { Color3.new(), 1 },
            offScreenArrow = false,
            offScreenArrowColor = { Color3.new(1,1,1), 1 },
            offScreenArrowSize = 15,
            offScreenArrowRadius = 150,
            offScreenArrowOutline = true,
            offScreenArrowOutlineColor = { Color3.new(), 1 },
            chams = false,
            chamsVisibleOnly = false,
            chamsFillColor = { Color3.new(0.2, 0.2, 0.2), 0.5 },
            chamsOutlineColor = { Color3.new(1,0,0), 0 }
        },
        Friendly = {
            enabled = false,
            box = false,
            boxColor = { Color3.new(0,1,0), 1 },
            boxOutline = true,
            boxOutlineColor = { Color3.new(), 1 },
            boxFill = false,
            boxFillColor = { Color3.new(0,1,0), 0.5 },
            healthBar = false,
            healthyColor = Color3.new(0,1,0),
            dyingColor = Color3.new(1,0,0),
            healthBarOutline = true,
            healthBarOutlineColor = { Color3.new(), 1 },
            healthText = false,
            healthTextColor = { Color3.new(1,1,1), 1 },
            healthTextOutline = true,
            healthTextOutlineColor = Color3.new(),
            name = false,
            nameColor = { Color3.new(1,1,1), 1 },
            nameOutline = true,
            nameOutlineColor = Color3.new(),
            weapon = false,
            weaponColor = { Color3.new(1,1,1), 1 },
            weaponOutline = true,
            weaponOutlineColor = Color3.new(),
            distance = false,
            distanceColor = { Color3.new(1,1,1), 1 },
            distanceOutline = true,
            distanceOutlineColor = Color3.new(),
            tracer = false,
            tracerOrigin = "Bottom",
            tracerColor = { Color3.new(0,1,0), 1 },
            tracerOutline = true,
            tracerOutlineColor = { Color3.new(), 1 },
            offScreenArrow = false,
            offScreenArrowColor = { Color3.new(1,1,1), 1 },
            offScreenArrowSize = 15,
            offScreenArrowRadius = 150,
            offScreenArrowOutline = true,
            offScreenArrowOutlineColor = { Color3.new(), 1 },
            chams = false,
            chamsVisibleOnly = false,
            chamsFillColor = { Color3.new(0.2, 0.2, 0.2), 0.5 },
            chamsOutlineColor = { Color3.new(0,1,0), 0 }
        }
    }
}
```

## Sense Functions
These are our built-in functions for Sense which you can edit to give the library information about the player in games with for example custom replication systems.
```lua
function EspInterface.getWeapon(player)
    return "Unknown";
end

function EspInterface.isFriendly(player)
    return player.Team and player.Team == localPlayer.Team;
end

function EspInterface.getCharacter(player)
    return player.Character;
end

function EspInterface.getHealth(player)
    local character = EspInterface.getCharacter(player);
    local humanoid = character and findFirstChildOfClass(character, "Humanoid");
    if humanoid then
        return humanoid.Health, humanoid.MaxHealth;
    end
    return 100, 100;
end
```

## Unloading Sense
```lua
Sense.Unload()
```

## Example Usage
```lua
local Sense = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Sirius/request/library/sense/source.lua'))()

Sense.teamSettings.Enemy.enabled = true
Sense.teamSettings.Enemy.box = true

Sense.Load()
task.wait(5)
Sense.Unload()
```
