--[[
    made by siper#9938, credits to spoorloos/mickey.#5612 for bounding box/out of view arrows
]]

-- Module
local EspLibrary = {
    drawings = {},
    instances = {},
    espCache = {},
    chamsCache = {},
    conns = {},
    whitelist = {}, -- insert string that is the player's name you want to whitelist (turns esp color to whitelistColor in options)
    blacklist = {}, -- insert string that is the player's name you want to blacklist (removes player from esp)
    options = {
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
}

-- Variables
local instanceNew = Instance.new
local drawingNew = Drawing.new
local vector2New = Vector2.new
local vector3New = Vector3.new
local cframeNew = CFrame.new
local color3New = Color3.new
local raycastParamsNew = RaycastParams.new
local tan = math.tan
local rad = math.rad
local floor = math.floor
local insert = table.insert
local findFirstChild = game.FindFirstChild
local raycast = workspace.Raycast
local pointToObjectSpace = cframeNew().PointToObjectSpace
local cross = vector3New().Cross

-- Services
local workspace = game:GetService("Workspace")
local runService = game:GetService("RunService")
local players = game:GetService("Players")
local coreGui = game:GetService("CoreGui")
local userInputService = game:GetService("UserInputService")

-- Cache
local currentCamera = workspace.CurrentCamera
local localPlayer = players.LocalPlayer
local chamsFolder = instanceNew("Folder", coreGui)

-- Support Functions
local function isDrawing(type)
    return type == "Square" or type == "Text" or type == "Triangle" or type == "Image" or type == "Line" or type == "Circle"
end

local function create(type, properties)
    local drawing = isDrawing(type)
    local object = drawing and drawingNew(type) or instanceNew(type)

    if (properties) then
        for i,v in next, properties do
            object[i] = v
        end
    end

    insert(drawing and EspLibrary.drawings or EspLibrary.instances, object)
    return object
end

local function worldToViewportPoint(position)
    local screenPosition, onScreen = currentCamera:WorldToViewportPoint(position)
    return vector2New(screenPosition.X, screenPosition.Y), onScreen, screenPosition.Z
end

local function round(number)
    if (typeof(number) == "Vector2") then
        return vector2New(round(number.X), round(number.Y))
    else
        return floor(number)
    end
end

-- Main Functions
function EspLibrary.GetTeam(player)
    local team = player.Team
    return team, player.TeamColor.Color
end

function EspLibrary.GetCharacter(player)
    local character = player.Character
    return character, character and findFirstChild(character, "HumanoidRootPart")
end

function EspLibrary.GetBoundingBox(torso)
    local torsoPosition, onScreen, depth = worldToViewportPoint(torso.Position)
    local scaleFactor = 1 / (tan(rad(currentCamera.FieldOfView * 0.5)) * 2 * depth) * 1000
    local size = round(vector2New(EspLibrary.options.scaleFactorX * scaleFactor, EspLibrary.options.scaleFactorY * scaleFactor))
    return onScreen, size, round(vector2New(torsoPosition.X - (size.X * 0.5), torsoPosition.Y - (size.Y * 0.5))), torsoPosition
end

function EspLibrary.GetHealth(player, character)
    local humanoid = findFirstChild(character, "Humanoid")
    if (humanoid) then
        return humanoid.Health, humanoid.MaxHealth
    end

    return 100, 100
end

function EspLibrary.VisibleCheck(character, position)
    local origin = currentCamera.CFrame.Position
    local params = raycastParamsNew();

    params.FilterDescendantsInstances = { EspLibrary.GetCharacter(localPlayer), currentCamera, character }
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.IgnoreWater = true

    local result = raycast(workspace, origin, position - origin, params)
    return not result
end

function EspLibrary.AddEsp(player)
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
    }

    EspLibrary.espCache[player] = objects
end

function EspLibrary.RemoveEsp(player)
    local espCache = EspLibrary.espCache[player]

    if (espCache) then
        EspLibrary.espCache[player] = nil

        for index, object in next, espCache do
            espCache[index] = nil
            object:Remove()
        end
    end
end

function EspLibrary.AddChams(player)
    if (player == localPlayer) then
        return
    end

    EspLibrary.chamsCache[player] = create("Highlight", {
        Parent = chamsFolder,
    })
end

function EspLibrary.RemoveChams(player)
    local highlight = EspLibrary.chamsCache[player]

    if (highlight) then
        EspLibrary.chamsCache[player] = nil
        highlight:Destroy()
    end
end

function EspLibrary.Unload()
    for _, connection in next, EspLibrary.conns do
        connection:Disconnect()
    end

    for _, player in next, players:GetPlayers() do
        EspLibrary.RemoveEsp(player)
        EspLibrary.RemoveChams(player)
    end

    for _, object in next, EspLibrary.drawings do
        object:Remove()
    end

    for _, object in next, EspLibrary.instances do
        object:Destroy()
    end

    chamsFolder:Destroy()

    runService:UnbindFromRenderStep("esp_rendering")
end

function EspLibrary.Init()
    insert(EspLibrary.conns, players.PlayerAdded:Connect(function(player)
        EspLibrary.AddEsp(player)
        EspLibrary.AddChams(player)
    end))

    insert(EspLibrary.conns, players.PlayerRemoving:Connect(function(player)
        EspLibrary.RemoveEsp(player)
        EspLibrary.RemoveChams(player)
    end))

    for _, player in next, players:GetPlayers() do
        EspLibrary.AddEsp(player)
        EspLibrary.AddChams(player)
    end

    runService:BindToRenderStep("esp_rendering", Enum.RenderPriority.Camera.Value + 1, function()
        for player, objects in next, EspLibrary.espCache do
            local character, torso = EspLibrary.GetCharacter(player)

            if (character and torso) then
                local onScreen, size, position, torsoPosition = EspLibrary.GetBoundingBox(torso)
                local distance = (currentCamera.CFrame.Position - torso.Position).Magnitude
                local canShow, enabled = onScreen and (size and position), EspLibrary.options.enabled
                local team, teamColor = EspLibrary.GetTeam(player)
                local color = EspLibrary.options.teamColor and teamColor or nil

                if (EspLibrary.options.fillColor ~= nil) then
                    color = EspLibrary.options.fillColor
                end

                if (table.find(EspLibrary.whitelist, player.Name)) then
                    color = EspLibrary.options.whitelistColor
                end

                if (table.find(EspLibrary.blacklist, player.Name)) then
                    enabled = false
                end

                if (EspLibrary.options.limitDistance and distance > EspLibrary.options.maxDistance) then
                    enabled = false
                end

                if (EspLibrary.options.visibleOnly and not EspLibrary.VisibleCheck(character, torso.Position)) then
                    enabled = false
                end

                if (EspLibrary.options.teamCheck and (team == EspLibrary.GetTeam(localPlayer))) then
                    enabled = false
                end

                local viewportSize = currentCamera.ViewportSize

                local screenCenter = vector2New(viewportSize.X / 2, viewportSize.Y / 2)
                local objectSpacePoint = (pointToObjectSpace(currentCamera.CFrame, torso.Position) * vector3New(1, 0, 1)).Unit
                local crossVector = cross(objectSpacePoint, vector3New(0, 1, 1))
                local rightVector = vector2New(crossVector.X, crossVector.Z)

                local arrowRadius, arrowSize = EspLibrary.options.outOfViewArrowsRadius, EspLibrary.options.outOfViewArrowsSize
                local arrowPosition = screenCenter + vector2New(objectSpacePoint.X, objectSpacePoint.Z) * arrowRadius
                local arrowDirection = (arrowPosition - screenCenter).Unit

                local pointA, pointB, pointC = arrowPosition, screenCenter + arrowDirection * (arrowRadius - arrowSize) + rightVector * arrowSize, screenCenter + arrowDirection * (arrowRadius - arrowSize) + -rightVector * arrowSize

                local health, maxHealth = EspLibrary.GetHealth(player, character)
                local healthBarSize = round(vector2New(EspLibrary.options.healthBarsSize, -(size.Y * (health / maxHealth))))
                local healthBarPosition = round(vector2New(position.X - (3 + healthBarSize.X), position.Y + size.Y))

                local origin = EspLibrary.options.tracerOrigin
                local show = canShow and enabled

                objects.arrow.Visible = (not canShow and enabled) and EspLibrary.options.outOfViewArrows
                objects.arrow.Filled = EspLibrary.options.outOfViewArrowsFilled
                objects.arrow.Transparency = EspLibrary.options.outOfViewArrowsTransparency
                objects.arrow.Color = color or EspLibrary.options.outOfViewArrowsColor
                objects.arrow.PointA = pointA
                objects.arrow.PointB = pointB
                objects.arrow.PointC = pointC

                objects.arrowOutline.Visible = (not canShow and enabled) and EspLibrary.options.outOfViewArrowsOutline
                objects.arrowOutline.Filled = EspLibrary.options.outOfViewArrowsOutlineFilled
                objects.arrowOutline.Transparency = EspLibrary.options.outOfViewArrowsOutlineTransparency
                objects.arrowOutline.Color = color or EspLibrary.options.outOfViewArrowsOutlineColor
                objects.arrowOutline.PointA = pointA
                objects.arrowOutline.PointB = pointB
                objects.arrowOutline.PointC = pointC

                objects.top.Visible = show and EspLibrary.options.names
                objects.top.Font = EspLibrary.options.font
                objects.top.Size = EspLibrary.options.fontSize
                objects.top.Transparency = EspLibrary.options.nameTransparency
                objects.top.Color = color or EspLibrary.options.nameColor
                objects.top.Text = player.Name
                objects.top.Position = round(position + vector2New(size.X * 0.5, -(objects.top.TextBounds.Y + 2)))

                objects.side.Visible = show and EspLibrary.options.healthText
                objects.side.Font = EspLibrary.options.font
                objects.side.Size = EspLibrary.options.fontSize
                objects.side.Transparency = EspLibrary.options.healthTextTransparency
                objects.side.Color = color or EspLibrary.options.healthTextColor
                objects.side.Text = health .. EspLibrary.options.healthTextSuffix
                objects.side.Position = round(position + vector2New(size.X + 3, -3))

                objects.bottom.Visible = show and EspLibrary.options.distance
                objects.bottom.Font = EspLibrary.options.font
                objects.bottom.Size = EspLibrary.options.fontSize
                objects.bottom.Transparency = EspLibrary.options.distanceTransparency
                objects.bottom.Color = color or EspLibrary.options.nameColor
                objects.bottom.Text = tostring(round(distance)) .. EspLibrary.options.distanceSuffix
                objects.bottom.Position = round(position + vector2New(size.X * 0.5, size.Y + 1))

                objects.box.Visible = show and EspLibrary.options.boxes
                objects.box.Color = color or EspLibrary.options.boxesColor
                objects.box.Transparency = EspLibrary.options.boxesTransparency
                objects.box.Size = size
                objects.box.Position = position

                objects.boxOutline.Visible = show and EspLibrary.options.boxes
                objects.boxOutline.Transparency = EspLibrary.options.boxesTransparency
                objects.boxOutline.Size = size
                objects.boxOutline.Position = position

                objects.boxFill.Visible = show and EspLibrary.options.boxFill
                objects.boxFill.Color = color or EspLibrary.options.boxFillColor
                objects.boxFill.Transparency = EspLibrary.options.boxFillTransparency
                objects.boxFill.Size = size
                objects.boxFill.Position = position

                objects.healthBar.Visible = show and EspLibrary.options.healthBars
                objects.healthBar.Color = color or EspLibrary.options.healthBarsColor
                objects.healthBar.Transparency = EspLibrary.options.healthBarsTransparency
                objects.healthBar.Size = healthBarSize
                objects.healthBar.Position = healthBarPosition

                objects.healthBarOutline.Visible = show and EspLibrary.options.healthBars
                objects.healthBarOutline.Transparency = EspLibrary.options.healthBarsTransparency
                objects.healthBarOutline.Size = round(vector2New(healthBarSize.X, -size.Y) + vector2New(2, -2))
                objects.healthBarOutline.Position = healthBarPosition - vector2New(1, -1)

                objects.line.Visible = show and EspLibrary.options.tracers
                objects.line.Color = color or EspLibrary.options.tracerColor
                objects.line.Transparency = EspLibrary.options.tracerTransparency
                objects.line.From =
                    origin == "Mouse" and userInputService:GetMouseLocation() or
                    origin == "Top" and vector2New(viewportSize.X * 0.5, 0) or
                    origin == "Bottom" and vector2New(viewportSize.X * 0.5, viewportSize.Y)
                objects.line.To = torsoPosition
            else
                for _, object in next, objects do
                    object.Visible = false
                end
            end
        end

        for player, highlight in next, EspLibrary.chamsCache do
            local character, torso = EspLibrary.GetCharacter(player)

            if (character and torso) then
                local distance = (currentCamera.CFrame.Position - torso.Position).Magnitude
                local canShow = EspLibrary.options.enabled and EspLibrary.options.chams
                local team, teamColor = EspLibrary.GetTeam(player)
                local color = EspLibrary.options.teamColor and teamColor or nil

                if (EspLibrary.options.fillColor ~= nil) then
                    color = EspLibrary.options.fillColor
                end

                if (table.find(EspLibrary.whitelist, player.Name)) then
                    color = EspLibrary.options.whitelistColor
                end

                if (table.find(EspLibrary.blacklist, player.Name)) then
                    canShow = false
                end

                if (EspLibrary.options.limitDistance and distance > EspLibrary.options.maxDistance) then
                    canShow = false
                end

                if (EspLibrary.options.teamCheck and (team == EspLibrary.GetTeam(localPlayer))) then
                    canShow = false
                end

                highlight.Enabled = canShow
                highlight.DepthMode = EspLibrary.options.visibleOnly and Enum.HighlightDepthMode.Occluded or Enum.HighlightDepthMode.AlwaysOnTop
                highlight.Adornee = character
                highlight.FillColor = color or EspLibrary.options.chamsFillColor
                highlight.FillTransparency = EspLibrary.options.chamsFillTransparency
                highlight.OutlineColor = color or EspLibrary.options.chamsOutlineColor
                highlight.OutlineTransparency = EspLibrary.options.chamsOutlineTransparency
            end
        end
    end)
end

return EspLibrary
