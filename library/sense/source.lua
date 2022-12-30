-- services
local runService = game:GetService("RunService");
local players = game:GetService("Players");
local workspace = game:GetService("Workspace");
local coreGui = game:GetService("CoreGui");

-- variables
local localPlayer = players.LocalPlayer;
local camera = workspace.CurrentCamera;
local viewportSize = camera.ViewportSize;
local container = Instance.new("Folder", coreGui);

-- namecalls
local wtvp = camera.WorldToViewportPoint;
local isA = workspace.IsA;
local findFirstChild = workspace.FindFirstChild;
local findFirstChildOfClass = workspace.FindFirstChildOfClass;
local getChildren = workspace.GetChildren;
local toOrientation = CFrame.identity.ToOrientation;
local pointToObjectSpace = CFrame.identity.PointToObjectSpace;
local lerpColor = Color3.new().Lerp;
local min2 = Vector2.zero.Min;
local max2 = Vector2.zero.Max;
local lerp2 = Vector2.zero.Lerp;
local min3 = Vector3.zero.Min;
local max3 = Vector3.zero.Max;

-- locals
local floor = math.floor;
local round = math.round;
local atan2 = math.atan2;
local sin = math.sin;
local cos = math.cos;

-- constants
local HEALTH_BAR_OFFSET = Vector2.new(5, 0);
local HEALTH_TEXT_OFFSET = Vector2.new(3, 0);
local HEALTH_BAR_OUTLINE_OFFSET = Vector2.new(0, 1);
local NAME_OFFSET = Vector2.new(0, 2);
local WEAPON_OFFSET = Vector2.new(0, 2);
local DISTANCE_OFFSET = Vector2.new(0, 2);
local VERTICES = {
    Vector3.new(1, 1, 1),
    Vector3.new(-1, 1, 1),
    Vector3.new(1, -1, 1),
    Vector3.new(-1, -1, 1),
    Vector3.new(1, 1, -1),
    Vector3.new(-1, 1, -1),
    Vector3.new(1, -1, -1),
    Vector3.new(-1, -1, -1),
};

-- utils
local function isBodyPart(name)
    return (name == "Head" or
        string.find(name, "Torso") or
        string.find(name, "Leg") or
        string.find(name, "Arm"));
end

local function worldToScreen(world)
    local screen, inBounds = wtvp(camera, world);
    return Vector2.new(screen.X, screen.Y), inBounds, screen.Z;
end

local function getBoundingBox(parts)
    local min, max;
    for _, part in next, parts do
        if isA(part, "BasePart") and isBodyPart(part.Name) then
            local cframe, size = part.CFrame, part.Size;
            min = min3(min or cframe.Position, (cframe - size*0.5).Position);
            max = max3(max or cframe.Position, (cframe + size*0.5).Position);
        end
    end

    local center = (min + max)*0.5;
    local front = Vector3.new(center.X, center.Y, max.Z);
    return CFrame.new(center, front), max - min;
end

local function floor2(x, y)
    return Vector2.new(floor(x), floor(y));
end

local function calculateBox(cframe, size)
    local screenPoints = {};
    for index, vertex in next, VERTICES do
        screenPoints[index] = worldToScreen((cframe + size*0.5 * vertex).Position);
    end

    local topLeft = min2(viewportSize, unpack(screenPoints));
    local bottomRight = max2(Vector2.zero, unpack(screenPoints));
    return {
        topLeft = floor2(topLeft.X, topLeft.Y),
        topRight = floor2(bottomRight.X, topLeft.Y),
        bottomLeft = floor2(topLeft.X, bottomRight.Y),
        bottomRight = floor2(bottomRight.X, bottomRight.Y)
    }
end

local function rotateVector(vector, radians)
    local c, s = cos(radians), sin(radians);
    return Vector2.new(c*vector.X - s*vector.Y, s*vector.X + c*vector.Y);
end

-- esp object
local EspObject = {};
EspObject.__index = EspObject;

function EspObject.new(player, interface)
    local self = setmetatable({}, EspObject);
    self.player = assert(player, "Missing argument #1 (Player expected)");
    self.interface = assert(interface, "Missing argument #2 (table expected)");
    self.bin = {};
    self:Construct();
    return self;
end

function EspObject:Create(class, properties)
    local drawing = Drawing.new(class);
    for property, value in next, properties do
        drawing[property] = value;
    end
    table.insert(self.bin, drawing);
    return drawing;
end

function EspObject:Construct()
    self.drawings = {
        visible = {
            boxOutline = self:Create("Square", {
                Thickness = 3,
                ZIndex = 2,
                Visible = false
            }),
            box = self:Create("Square", {
                Thickness = 1,
                ZIndex = 2,
                Visible = false
            }),
            boxFill = self:Create("Square", {
                Filled = true,
                ZIndex = 2,
                Visible = false
            }),
            healthBarOutline = self:Create("Line", {
                Thickness = 3,
                ZIndex = 2,
                Visible = false
            }),
            healthBar = self:Create("Line", {
                Thickness = 1,
                ZIndex = 2,
                Visible = false
            }),
            healthText = self:Create("Text", {
                Center = true,
                ZIndex = 3,
                Visible = false
            }),
            name = self:Create("Text", {
                Text = self.player.Name,
                Center = true,
                ZIndex = 3,
                Visible = false
            }),
            weapon = self:Create("Text", {
                Center = true,
                ZIndex = 3,
                Visible = false
            }),
            distance = self:Create("Text", {
                Center = true,
                ZIndex = 3,
                Visible = false
            }),
            tracerOutline = self:Create("Line", {
                Thickness = 3,
                ZIndex = 1,
                Visible = false
            }),
            tracer = self:Create("Line", {
                Thickness = 1,
                ZIndex = 1,
                Visible = false
            }),
        },
        hidden = {
            arrowOutline = self:Create("Triangle", {
                Thickness = 3,
                ZIndex = 4,
                Visible = false
            }),
            arrow = self:Create("Triangle", {
                Filled = true,
                ZIndex = 4,
                Visible = false
            })
        }
    };

    self.updateConnection = runService.Heartbeat:Connect(function(...)
        self:Update(...);
    end);

    self.renderConnection = runService.RenderStepped:Connect(function(...)
        self:Render(...);
    end);
end

function EspObject:Destruct()
    self.updateConnection:Disconnect();
    self.renderConnection:Disconnect();

    for _, drawing in next, self.bin do
        drawing:Remove();
    end

    table.clear(self);
end

function EspObject:Update()
    local character = self.interface.getCharacter(self.player);
    local head = character and findFirstChild(character, "Head");
    if head then
        local _, onScreen, depth = worldToScreen(head.Position);
        self.onScreen = onScreen;
        self.distance = depth;

        if onScreen then
            local cframe, size = getBoundingBox(getChildren(character));
            self.corners = calculateBox(cframe, size);
        elseif self.drawings.hidden.arrow.Visible then
            local _, yaw, roll = toOrientation(camera.CFrame);
            local flatCFrame = CFrame.Angles(0, yaw, roll) + camera.CFrame.Position;
            local objectSpace = pointToObjectSpace(flatCFrame, head.Position);
            local angle = atan2(objectSpace.Z, objectSpace.X);

            self.screenDirection = Vector2.new(cos(angle), sin(angle));
        end
    end

    self.hasUpdated = true;
    self.character = character;
    self.team = self.interface.getTeam(self.player);
    self.weapon = self.interface.getWeapon(self.player);
    self.health, self.maxHealth = self.interface.getHealth(self.player);
    self.options = self.interface.teamSettings[(self.team and self.team == localPlayer.Team) and "Friendly" or "Enemy"];
end

function EspObject:Render()
    if not self.hasUpdated then
        return;
    end

    local visible = self.drawings.visible;
    local hidden = self.drawings.hidden;
    local interface = self.interface;
    local options = self.options;
    local corners = self.corners;

    local onScreen = self.onScreen or false;
    local alive = self.character and self.health and self.health > 0 or false;
    local enabled = options.enabled and alive and not (#interface.whitelist > 0 and not interface.whitelist[self.player]);

    visible.box.Visible = enabled and onScreen and options.boxEnabled;
    visible.boxOutline.Visible = visible.box.Visible and options.boxOutline;
    if visible.box.Visible then
        local box = visible.box;
        box.Position = corners.topLeft;
        box.Size = corners.bottomRight - corners.topLeft;
        box.Color = options.boxColor[1];
        box.Transparency = options.boxColor[2];

        local boxOutline = visible.boxOutline;
        boxOutline.Position = box.Position;
        boxOutline.Size = box.Size;
        boxOutline.Color = options.boxOutlineColor[1];
        boxOutline.Transparency = options.boxOutlineColor[2];
    end

    visible.boxFill.Visible = enabled and onScreen and options.boxFill;
    if visible.boxFill.Visible then
        local boxFill = visible.boxFill;
        boxFill.Position = corners.topLeft;
        boxFill.Size = corners.bottomRight - corners.topLeft;
        boxFill.Color = options.boxFillColor[1];
        boxFill.Transparency = options.boxFillColor[2];
    end

    visible.healthBar.Visible = enabled and onScreen and options.healthBar;
    visible.healthBarOutline.Visible = visible.healthBar.Visible and options.healthBarOutline;
    if visible.healthBar.Visible then
        local barFrom = corners.topLeft - HEALTH_BAR_OFFSET;
        local barTo = corners.bottomLeft - HEALTH_BAR_OFFSET;

        local healthBar = visible.healthBar;
        healthBar.To = barTo;
        healthBar.From = lerp2(barTo, barFrom, self.health/self.maxHealth);
        healthBar.Color = lerpColor(options.dyingColor, options.healthyColor, self.health/self.maxHealth);

        local healthBarOutline = visible.healthBarOutline;
        healthBarOutline.To = barTo + HEALTH_BAR_OUTLINE_OFFSET;
        healthBarOutline.From = barFrom - HEALTH_BAR_OUTLINE_OFFSET;
        healthBarOutline.Color = options.healthBarOutlineColor[1];
        healthBarOutline.Transparency = options.healthBarOutlineColor[2];
    end

    visible.healthText.Visible = enabled and onScreen and options.healthText;
    if visible.healthText.Visible then
        local barFrom = corners.topLeft - HEALTH_BAR_OFFSET;
        local barTo = corners.bottomLeft - HEALTH_BAR_OFFSET;

        local healthText = visible.healthText;
        healthText.Text = round(self.health) .. "hp";
        healthText.Size = interface.sharedSettings.textSize;
        healthText.Font = interface.sharedSettings.textFont;
        healthText.Color = options.healthTextColor[1];
        healthText.Transparency = options.healthTextColor[2];
        healthText.Outline = options.healthTextOutline;
        healthText.OutlineColor = options.healthTextOutlineColor;
        healthText.Position = lerp2(barTo, barFrom, self.health/self.maxHealth) - healthText.TextBounds*0.5 - HEALTH_TEXT_OFFSET;
    end

    visible.name.Visible = enabled and onScreen and options.name;
    if visible.name.Visible then
        local name = visible.name;
        name.Size = interface.sharedSettings.textSize;
        name.Font = interface.sharedSettings.textFont;
        name.Color = options.nameColor[1];
        name.Transparency = options.nameColor[2];
        name.Outline = options.nameOutline;
        name.OutlineColor = options.nameOutlineColor;
        name.Position = (corners.topLeft + corners.topRight)*0.5 - Vector2.yAxis*name.TextBounds.Y - NAME_OFFSET;
    end

    visible.weapon.Visible = enabled and onScreen and options.weapon;
    if visible.weapon.Visible then
        local weapon = visible.weapon;
        weapon.Text = self.weapon;
        weapon.Size = interface.sharedSettings.textSize;
        weapon.Font = interface.sharedSettings.textFont;
        weapon.Color = options.weaponColor[1];
        weapon.Transparency = options.weaponColor[2];
        weapon.Outline = options.weaponOutline;
        weapon.OutlineColor = options.weaponOutlineColor;
        weapon.Position = (corners.bottomLeft + corners.bottomRight)*0.5 + WEAPON_OFFSET;
    end

    visible.distance.Visible = enabled and onScreen and options.distance;
    if visible.distance.Visible then
        local distance = visible.distance;
        distance.Text = round(self.distance) .. " studs";
        distance.Size = interface.sharedSettings.textSize;
        distance.Font = interface.sharedSettings.textFont;
        distance.Color = options.distanceColor[1];
        distance.Transparency = options.distanceColor[2];
        distance.Outline = options.distanceOutline;
        distance.OutlineColor = options.distanceOutlineColor;
        distance.Position =
            (corners.bottomLeft + corners.bottomRight)*0.5 + DISTANCE_OFFSET +
            (visible.weapon.Visible and WEAPON_OFFSET + Vector2.yAxis*visible.weapon.TextBounds.Y or Vector2.zero);
    end

    visible.tracer.Visible = enabled and onScreen and options.tracer;
    visible.tracerOutline.Visible = visible.tracer.Visible and options.tracerOutline;
    if visible.tracer.Visible then
        local tracer = visible.tracer;
        tracer.Color = options.tracerColor[1];
        tracer.Transparency = options.tracerColor[2];
        tracer.To = (corners.bottomLeft + corners.bottomRight)*0.5;
        tracer.From =
            options.tracerOrigin == "Middle" and viewportSize*0.5 or
            options.tracerOrigin == "Top" and viewportSize*Vector2.new(0.5, 0) or
            options.tracerOrigin == "Bottom" and viewportSize*Vector2.new(0.5, 1);

        local tracerOutline = visible.tracerOutline;
        tracerOutline.Color = options.tracerOutlineColor[1];
        tracerOutline.Transparency = options.tracerOutlineColor[2];
        tracerOutline.To = tracer.To;
        tracerOutline.From = tracer.From;
    end

    hidden.arrow.Visible = enabled and not onScreen and options.offScreenArrow;
    hidden.arrowOutline.Visible = hidden.arrow.Visible and options.offScreenArrowOutline;
    if hidden.arrow.Visible then
        local arrow = hidden.arrow;
        arrow.PointA = min2(max2(viewportSize*0.5 + self.screenDirection*options.offScreenArrowRadius, Vector2.one*25), viewportSize - Vector2.one*25);
        arrow.PointB = arrow.PointA - rotateVector(self.screenDirection, 0.45)*options.offScreenArrowSize;
        arrow.PointC = arrow.PointA - rotateVector(self.screenDirection, -0.45)*options.offScreenArrowSize;
        arrow.Color = options.offScreenArrowColor[1];
        arrow.Transparency = options.offScreenArrowColor[2];

        local arrowOutline = hidden.arrowOutline;
        arrowOutline.PointA = arrow.PointA;
        arrowOutline.PointB = arrow.PointB;
        arrowOutline.PointC = arrow.PointC;
        arrowOutline.Color = options.offScreenArrowOutlineColor[1];
        arrowOutline.Transparency = options.offScreenArrowOutlineColor[2];
    end
end

-- cham object
local ChamObject = {};
ChamObject.__index = ChamObject;

function ChamObject.new(player, interface)
    local self = setmetatable({}, ChamObject);
    self.player = assert(player, "Missing argument #1 (Player expected)");
    self.interface = assert(interface, "Missing argument #2 (table expected)");
    self:Construct();
    return self;
end

function ChamObject:Construct()
    self.highlight = Instance.new("Highlight", container);
    self.updateConnection = runService.Heartbeat:Connect(function()
        self:Update();
    end);
end

function ChamObject:Update()
    local interface = self.interface;
    local character = interface.getCharacter(self.player);
    local team = interface.getTeam(self.player);
    local options = interface.teamSettings[(team and team == localPlayer.Team) and "Friendly" or "Enemy"];

    local alive = self.character and self.health and self.health > 0 or false;
    local enabled = options.enabled and alive and not (#interface.whitelist > 0 and not interface.whitelist[self.player]);

    local highlight = self.highlight;
    highlight.Enabled = enabled and options.chams;
    highlight.DepthMode = options.chamsVisibleOnly and Enum.HighlightDepthMode.Occluded or Enum.HighlightDepthMode.AlwaysOnTop;
    highlight.Adornee = character;
    highlight.FillColor = options.chamsFillColor[1];
    highlight.FillTransparency = options.chamsFillColor[2];
    highlight.OutlineColor = options.chamsOutlineColor[1];
    highlight.OutlineTransparency = options.chamsOutlineColor[2];
end

function ChamObject:Destruct()
    self.updateConnection:Disconnect();
    self.highlight:Destroy();

    table.clear(self);
end

-- interface
local EspInterface = {
    objectCache = {},
    hasLoaded = false,
    whitelist = {},
    sharedSettings = {
        textSize = 13,
        textFont = 2
    },
    teamSettings = {
        Enemy = {
            enabled = false,
            boxEnabled = false,
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
            boxEnabled = false,
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
};

function EspInterface.Load()
    assert(not EspInterface.hasLoaded, "Esp has already been loaded.");

    local function createObject(player)
        EspInterface.objectCache[player] = {
            esp = EspObject.new(player, EspInterface),
            cham = ChamObject.new(player, EspInterface)
        };
    end

    local function removeObject(player)
        local object = EspInterface.objectCache[player];
        if object then
            object.esp:Destruct();
            object.cham:Destruct();
        end
        EspInterface.objectCache[player] = nil;
    end

    EspInterface.playerAdded = players.PlayerAdded:Connect(createObject);
    EspInterface.playerRemoving = players.PlayerRemoving:Connect(removeObject);

    for _, player in next, players:GetPlayers() do
        if player ~= localPlayer then
            createObject(player);
        end
    end

    EspInterface.hasLoaded = true;
end

function EspInterface.Unload()
    assert(EspInterface.hasLoaded, "Esp has not been loaded yet.");

    EspInterface.playerAdded:Disconnect();
    EspInterface.playerRemoving:Disconnect();

    for _, object in next, EspInterface.objectCache do
        object.esp:Destruct();
        object.cham:Destruct();
    end

    EspInterface.hasLoaded = false;
end

-- game specific functions
function EspInterface.getWeapon(player)
    return "Unknown"; 
end

function EspInterface.getTeam(player)
    return player and player.Team;
end

function EspInterface.getCharacter(player)
    return player and player.Character;
end

function EspInterface.getHealth(player)
    local character = EspInterface.getCharacter(player);
    local humanoid = character and findFirstChildOfClass(character, "Humanoid");
    if humanoid then
        return humanoid.Health, humanoid.MaxHealth;
    end
    return 100, 100;
end

return EspInterface;
