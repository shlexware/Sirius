# Sirius ESP
## Booting the library
```lua
local espLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Sirius/request/library/esp/esp.lua'),true))()
```
## Setting Defaults
These settings are all set to default, and so are the functions.
```lua
local espLibrary = {
    drawings = {},
    instances = {},
    espCache = {},
    chamsCache = {},
    objectCache = {},
    conns = {},
    whitelist = {}, -- insert string that is the player's name you want to whitelist (turns esp color to whitelistColor in options)
    blacklist = {}, -- insert string that is the player's name you want to blacklist (removes player from esp)
    options = {
        enabled = true,
        minScaleFactorX = 1,
        maxScaleFactorX = 10,
        minScaleFactorY = 1,
        maxScaleFactorY = 10,
        boundingBoxDescending = true,
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
        boxesColor = Color3.new(1, 0, 0),
        boxFill = false,
        boxFillTransparency = 0.5,
        boxFillColor = Color3.new(1, 0, 0),
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
        chams = true,
        chamsFillColor = Color3.new(1, 0, 0),
        chamsFillTransparency = 0.5,
        chamsOutlineColor = Color3.new(),
        chamsOutlineTransparency = 0
    },
};
```
## Functions 
```
-- function espLibrary.getTeam(player)
-- arguments: player -> Class: Player
-- returns: Class: Team, BrickColor: TeamColor
```
```lua
function espLibrary.getTeam(player)
    local team = player.Team;
    return team, player.TeamColor.Color;
end 
```
```
-- function espLibrary.getCharacter(player)
-- arguments: player -> Class: Player
-- returns: Model: Character, Part: HumanoidRootPart
```
```lua
function espLibrary.getCharacter(player)
    local character = player.Character;
    return character, character and findFirstChild(character, "HumanoidRootPart");
end
```
```
-- function espLibrary.getBoundingBox(character)
-- arguments: player -> Class: Player
-- returns: Vector3: BoundingBox
```
```lua
function espLibrary.getBoundingBox(character)
    local minX, minY, minZ = inf, inf, inf;
    local maxX, maxY, maxZ = -inf, -inf, -inf;

    for _, part in next, espLibrary.options.boundingBoxDescending and getDescendants(character) or getChildren(character) do
        if (isA(part, "BasePart")) then
            local size = part.Size;
            local sizeX, sizeY, sizeZ = size.X, size.Y, size.Z;

            local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = getComponents(part.CFrame);

            local wiseX = 0.5 * (abs(r00) * sizeX + abs(r01) * sizeY + abs(r02) * sizeZ);
            local wiseY = 0.5 * (abs(r10) * sizeX + abs(r11) * sizeY + abs(r12) * sizeZ);
            local wiseZ = 0.5 * (abs(r20) * sizeX + abs(r21) * sizeY + abs(r22) * sizeZ);

            minX = minX > x - wiseX and x - wiseX or minX;
            minY = minY > y - wiseY and y - wiseY or minY;
            minZ = minZ > z - wiseZ and z - wiseZ or minZ;

            maxX = maxX < x + wiseX and x + wiseX or maxX;
            maxY = maxY < y + wiseY and y + wiseY or maxY;
            maxZ = maxZ < z + wiseZ and z + wiseZ or maxZ;
        end
    end

    local oMin, oMax = vector3New(minX, minY, minZ), vector3New(maxX, maxY, maxZ);
    return (oMax + oMin) * 0.5, oMax - oMin;
end
```

```
-- function espLibrary.getScaleFactor(fov, depth)
-- arguments: fov -> number, depth -> number
-- returns: Number
```
```lua
function espLibrary.getScaleFactor(fov, depth)
    if (fov ~= lastFov) then
        lastScale = tan(rad(fov * 0.5)) * 2;
        lastFov = fov;
    end

    return 1 / (depth * lastScale) * 1000;
end
```

```
-- function espLibrary.getBoxData(position, size)
-- arguments: position -> Vector3, size -> Vector3
-- returns: BoxSize, BoxPosition, BoxRoot
```
```lua
function espLibrary.getBoxData(position, size)
    local torsoPosition, onScreen, depth = worldToViewportPoint(position);
    local scaleFactor = espLibrary.getScaleFactor(currentCamera.FieldOfView, depth);

    local clampX = clamp(size.X, espLibrary.options.minScaleFactorX, espLibrary.options.maxScaleFactorX);
    local clampY = clamp(size.Y, espLibrary.options.minScaleFactorY, espLibrary.options.maxScaleFactorY);
    local size = round(vector2New(clampX * scaleFactor, clampY * scaleFactor));

    return onScreen, size, round(vector2New(torsoPosition.X - (size.X * 0.5), torsoPosition.Y - (size.Y * 0.5))), torsoPosition;
end
```

```
-- function espLibrary.getHealth(player, character)
-- arguments: player -> Player, Character -> Model
-- returns: Health: Number, MaxHealth: Number
```
```lua
function espLibrary.getHealth(player, character)
    local humanoid = findFirstChild(character, "Humanoid");

    if (humanoid) then
        return humanoid.Health, humanoid.MaxHealth;
    end

    return 100, 100;
end
```

```
-- function espLibrary.visibleCheck(character, position)
-- arguments: character -> Model, Position -> Vector3
-- returns: boolean
```
```lua
function espLibrary.visibleCheck(character, position)
    local origin = currentCamera.CFrame.Position;
    local params = raycastParamsNew();

    params.FilterDescendantsInstances = { espLibrary.getCharacter(localPlayer), currentCamera, character };
    params.FilterType = Enum.RaycastFilterType.Blacklist;
    params.IgnoreWater = true;

    return (not raycast(workspace, origin, position - origin, params));
end
```
```
-- function espLibrary.addEsp(player)
-- arguments: player -> Player
-- returns: nothing
```
```lua
function espLibrary.addEsp(player)
    if (player == localPlayer) then
        return
    end

    local objects = {
        arrow = create("Triangle", {
            Thickness = 1,
        }),
        arrowOutline = create("Triangle", {
            Thickness = 1,
        }),
        top = create("Text", {
            Center = true,
            Size = 13,
            Outline = true,
            OutlineColor = color3New(),
            Font = 2,
        }),
        side = create("Text", {
            Size = 13,
            Outline = true,
            OutlineColor = color3New(),
            Font = 2,
        }),
        bottom = create("Text", {
            Center = true,
            Size = 13,
            Outline = true,
            OutlineColor = color3New(),
            Font = 2,
        }),
        boxFill = create("Square", {
            Thickness = 1,
            Filled = true,
        }),
        boxOutline = create("Square", {
            Thickness = 3,
            Color = color3New()
        }),
        box = create("Square", {
            Thickness = 1
        }),
        healthBarOutline = create("Square", {
            Thickness = 1,
            Color = color3New(),
            Filled = true
        }),
        healthBar = create("Square", {
            Thickness = 1,
            Filled = true
        }),
        line = create("Line")
    };

    espLibrary.espCache[player] = objects;
end
```

```
-- function espLibrary.removeEsp(player)
-- arguments: player -> Player
-- returns: void
```
```lua
function espLibrary.removeEsp(player)
    local espCache = espLibrary.espCache[player];

    if (espCache) then
        espLibrary.espCache[player] = nil;

        for index, object in next, espCache do
            espCache[index] = nil;
            object:Remove();
        end
    end
end
```

```
-- function espLibrary.addChams(player)
-- arguments: player -> Player
-- returns: void
```
```lua
function espLibrary.addChams(player)
    if (player == localPlayer) then
        return
    end

    espLibrary.chamsCache[player] = create("Highlight", {
        Parent = screenGui,
    });
end
```

```
-- function espLibrary.removeChams(player)
-- arguments: player -> Player
-- returns: void
```
```lua
function espLibrary.removeChams(player)
    local highlight = espLibrary.chamsCache[player];

    if (highlight) then
        espLibrary.chamsCache[player] = nil;
        highlight:Destroy();
    end
end
```

```
-- function espLibrary.addObject(object, options)
-- arguments: object -> Object, options -> table 
-- returns: void
```
```lua
function espLibrary.addObject(object, options)
    espLibrary.objectCache[object] = {
        options = options,
        text = create("Text", {
            Center = true,
            Size = 13,
            Outline = true,
            OutlineColor = color3New(),
            Font = 2,
        })
    };
end
```

```
-- function espLibrary.removeObject(object)
-- arguments: object -> Object
-- returns: void
```
```lua
function espLibrary.removeObject(object)
    local cache = espLibrary.objectCache[object];

    if (cache) then
        espLibrary.objectCache[object] = nil;
        cache.text:Remove();
    end
end
```

```
-- function espLibrary:AddObjectEsp(object, defaultOptions)
-- arguments: object -> Object, defaultOptions -> table
-- returns: options or defaultOptions: table
```
```lua
function espLibrary:AddObjectEsp(object, defaultOptions)
    assert(object and isA(object, "BasePart") and object.Parent, "invalid object passed");

    local options = defaultOptions or {};

    options.enabled = options.enabled or true;
    options.limitDistance = options.limitDistance or false;
    options.maxDistance = options.maxDistance or false;
    options.visibleOnly = options.visibleOnly or false;
    options.color = options.color or color3New(1, 1, 1);
    options.transparency = options.transparency or 1;
    options.text = options.text or object.Name;
    options.font = options.font or 2;
    options.fontSize = options.fontSize or 13;

    self.addObject(object, options);

    insert(self.conns, object.Parent.ChildRemoved:Connect(function(child)
        if (child == object) then
            self.removeObject(child);
        end
    end));

    return options;
end
```
```
## Starting the esp 
```lua
espLib.Init()
```
## Unloading the esp 
```lua
espLib.Unload()
```
