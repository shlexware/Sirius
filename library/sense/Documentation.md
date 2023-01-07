## Sirius Sense Esp Library

<details>
  <summary>Getting Started</summary>

  Our library is very easy to implement into your projects by doing the following.
  &nbsp;
  1. Load the library
  ```lua
  local Sense = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Sirius/request/library/sense/source.lua'))()
  ```
  2. `Change the configuration` You'll need to do this for every value you'd like to change. Read [`Sense Default Configuration`](https://github.com/shlexware/Sirius/blob/request/library/sense/Documentation.md#sense-default-configuration) to see all the available settings.
  ```lua
  Sense.teamSettings.Enemy.enabled = true
  ```
  3. `Load the esp` It doesn't really matter where you put this, but it's recommended you put it at the end of your script.
  ```lua
  Sense.Load()
  ```
  4. `Unload the esp` When you unload Sense, it will clean up every drawing object and instance it has made.
  ```lua
  Sense.Unload()
  ```
</details>
<details>
  <summary>Sense Default Configuration</summary>

  This is the default configuration for Sense, most things will be disabled by default.
  &nbsp;
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
</details>
<details>
  <summary>Game Specific Functions</summary>

  These are our game specific functions, you're required to modify these for games that use custom replication systems such as Phantom Forces.
  ```lua
  function Sense.getWeapon(player)
      return "Unknown";
  end

  function Sense.isFriendly(player)
      return player.Team and player.Team == localPlayer.Team;
  end

  function Sense.getCharacter(player)
      return player.Character;
  end

  function Sense.getHealth(player)
      local character = Sense.getCharacter(player);
      local humanoid = character and findFirstChildOfClass(character, "Humanoid");
      if humanoid then
          return humanoid.Health, humanoid.MaxHealth;
      end
      return 100, 100;
  end
  ```
</details>
<details>
  <summary>Instance ESP</summary>

  You can create an ESP object for instances by doing to following:
  &nbsp;
  ```lua
  Sense.AddInstance(workspace.Part, {
      text = "Part",
      textColor = { Color3.new(1,1,1), 1 },
      textOutline = true,
      textOutlineColor = Color3.new(),
      textSize = 13,
      textFont = 2,
      limitDistance = false,
      maxDistance = 150
  })
  ```
</details>
