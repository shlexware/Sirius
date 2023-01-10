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

-- locals
local floor = math.floor;
local round = math.round;
local atan2 = math.atan2;
local sin = math.sin;
local cos = math.cos;
local find = string.find;
local clear = table.clear;

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
local function create(class, properties)
	local drawing = Drawing.new(class);
	for property, value in next, properties do
		drawing[property] = value;
	end
	return drawing;
end

local function isBodyPart(name)
	return name == "Head" or find(name, "Torso") or find(name, "Leg") or find(name, "Arm");
end

local function getBoundingBox(parts)
	local min, max;
	for i = 1, #parts do
		local part = parts[i];
		local cframe, size = part.CFrame, part.Size;

		min = min3(min or cframe.Position, (cframe - size*0.5).Position);
		max = max3(max or cframe.Position, (cframe + size*0.5).Position);
	end

	local center = (min + max)*0.5;
	local front = Vector3.new(center.X, center.Y, max.Z);
	return CFrame.new(center, front), max - min;
end

local function worldToScreen(world)
	local screen, inBounds = wtvp(camera, world);
	return Vector2.new(screen.X, screen.Y), inBounds, screen.Z;
end

local function calculateCorners(cframe, size)
	local min, max = viewportSize, Vector2.zero;
	for i = 1, #VERTICES do
		local screen = worldToScreen((cframe + size*0.5*VERTICES[i]).Position);
		min, max = min2(min, screen), max2(max, screen);
	end

	return {
		topLeft = Vector2.new(floor(min.X), floor(min.Y)),
		topRight = Vector2.new(floor(max.X), floor(min.Y)),
		bottomLeft = Vector2.new(floor(min.X), floor(max.Y)),
		bottomRight = Vector2.new(floor(max.X), floor(max.Y))
	};
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
	self:Construct();
	return self;
end

function EspObject:Construct()
	self.charCache = {};
	self.childCount = 0;
	
	self.drawings = {
		visible = {
			boxOutline = create("Square", {
				Thickness = 3,
				ZIndex = 2,
				Visible = false
			}),
			box = create("Square", {
				Thickness = 1,
				ZIndex = 2,
				Visible = false
			}),
			boxFill = create("Square", {
				Filled = true,
				ZIndex = 2,
				Visible = false
			}),
			healthBarOutline = create("Line", {
				Thickness = 3,
				ZIndex = 2,
				Visible = false
			}),
			healthBar = create("Line", {
				Thickness = 1,
				ZIndex = 2,
				Visible = false
			}),
			healthText = create("Text", {
				Center = true,
				ZIndex = 3,
				Visible = false
			}),
			name = create("Text", {
				Text = self.player.Name,
				Center = true,
				ZIndex = 3,
				Visible = false
			}),
			weapon = create("Text", {
				Center = true,
				ZIndex = 3,
				Visible = false
			}),
			distance = create("Text", {
				Center = true,
				ZIndex = 3,
				Visible = false
			}),
			tracerOutline = create("Line", {
				Thickness = 3,
				ZIndex = 1,
				Visible = false
			}),
			tracer = create("Line", {
				Thickness = 1,
				ZIndex = 1,
				Visible = false
			}),
		},
		hidden = {
			arrowOutline = create("Triangle", {
				Thickness = 3,
				ZIndex = 4,
				Visible = false
			}),
			arrow = create("Triangle", {
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

	for _, drawing in next, self.drawings.visible do
		drawing:Remove();
	end

	for _, drawing in next, self.drawings.hidden do
		drawing:Remove();
	end

	clear(self);
end

function EspObject:Update()
	local interface = self.interface;

	self.options = interface.teamSettings[interface.isFriendly(self.player) and "Friendly" or "Enemy"];
	self.health, self.maxHealth = interface.getHealth(self.player);
	self.character = interface.getCharacter(self.player);
	self.weapon = interface.getWeapon(self.player);
	self.enabled = self.options.enabled and self.character and not
		(#interface.whitelist > 0 and not interface.whitelist[self.player]);

	local head = self.enabled and findFirstChild(self.character, "Head");
	if head then
		local _, onScreen, depth = worldToScreen(head.Position);
		self.onScreen = onScreen;
		self.distance = depth;

		if interface.sharedSettings.limitDistance and depth > interface.sharedSettings.maxDistance then
			self.onScreen = false;
		end

		if self.onScreen then
			local children = getChildren(self.character);
			if not self.charCache[1] or self.childCount ~= #children then
				clear(self.charCache);

				for i = 1, #children do
					local part = children[i];
					if isA(part, "BasePart") and isBodyPart(part.Name) then
						self.charCache[#self.charCache + 1] = part;
					end
				end

				self.childCount = #children;
			end

			self.corners = calculateCorners(getBoundingBox(self.charCache));
		elseif self.options.offScreenArrow then
			local _, yaw, roll = toOrientation(camera.CFrame);
			local flatCFrame = CFrame.Angles(0, yaw, roll) + camera.CFrame.Position;
			local objectSpace = pointToObjectSpace(flatCFrame, head.Position);
			local angle = atan2(objectSpace.Z, objectSpace.X);

			self.direction = Vector2.new(cos(angle), sin(angle));
		end
	end
end

function EspObject:Render()
	local onScreen = self.onScreen or false;
	local enabled = self.enabled or false;
	local visible = self.drawings.visible;
	local hidden = self.drawings.hidden;
	local interface = self.interface;
	local options = self.options;
	local corners = self.corners;

	visible.box.Visible = enabled and onScreen and options.box;
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

	visible.distance.Visible = enabled and onScreen and self.distance and options.distance;
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

	hidden.arrow.Visible = enabled and (not onScreen) and options.offScreenArrow;
	hidden.arrowOutline.Visible = hidden.arrow.Visible and options.offScreenArrowOutline;
	if hidden.arrow.Visible then
		local arrow = hidden.arrow;
		arrow.PointA = min2(max2(viewportSize*0.5 + self.direction*options.offScreenArrowRadius, Vector2.one*25), viewportSize - Vector2.one*25);
		arrow.PointB = arrow.PointA - rotateVector(self.direction, 0.45)*options.offScreenArrowSize;
		arrow.PointC = arrow.PointA - rotateVector(self.direction, -0.45)*options.offScreenArrowSize;
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

function ChamObject:Destruct()
	self.updateConnection:Disconnect();
	self.highlight:Destroy();

	clear(self);
end

function ChamObject:Update()
	local interface = self.interface;
	local character = interface.getCharacter(self.player);

	local options = interface.teamSettings[interface.isFriendly(self.player) and "Friendly" or "Enemy"];
	local enabled = options.enabled and character and not (#interface.whitelist > 0 and not interface.whitelist[self.player]);

	local highlight = self.highlight;
	highlight.Enabled = enabled and options.chams;
	highlight.DepthMode = options.chamsVisibleOnly and Enum.HighlightDepthMode.Occluded or Enum.HighlightDepthMode.AlwaysOnTop;
	highlight.Adornee = character;
	highlight.FillColor = options.chamsFillColor[1];
	highlight.FillTransparency = options.chamsFillColor[2];
	highlight.OutlineColor = options.chamsOutlineColor[1];
	highlight.OutlineTransparency = options.chamsOutlineColor[2];
end

-- instance class
local InstanceObject = {};
InstanceObject.__index = InstanceObject;

function InstanceObject.new(instance, options)
	local self = setmetatable({}, InstanceObject);
	self.instance = assert(instance, "Missing argument #1 (Instance Expected)");
	self.options = assert(options, "Missing argument #2 (table expected)");
	self:Construct();
	return self;
end

function InstanceObject:Construct()
	local options = self.options;
	options.enabled = options.enabled or false;
	options.text = options.text or self.instance.Name;
	options.textColor = options.textColor or { Color3.new(1,1,1), 1 };
	options.textOutline = true;
	options.textOutlineColor = Color3.new();
	options.textSize = 13;
	options.textFont = 2;
	options.limitDistance = false;
	options.maxDistance = 150;

	self.text = create("Text", {
		Center = true
	});

	self.renderConnection = runService.RenderStepped:Connect(function(...)
		self:Render(...);
	end);
end

function InstanceObject:Destruct()
	self.renderConnection:Disconnect();
	self.text:Remove();
end

function InstanceObject:Render()
	if not self.instance or not self.instance.Parent then
		return self:Destruct();
	end

	local text = self.text;
	local options = self.options;
	if options.enabled then
		local world = self.instance:GetPivot().Position;
		local position, visible, depth = worldToScreen(world);
		if options.limitDistance and options.maxDistance > depth then
			visible = false;
		end

		text.Visible = visible;
		if text.Visible then
			text.Position = position;
			text.Text = options.text;
			text.Color = options.textColor[1];
			text.Transparency = options.textColor[2];
			text.Outline = options.textOutline;
			text.OutlineColor = options.textOutlineColor;
			text.Size = options.textSize;
			text.Font = options.textFont;
		end
	else
		text.Visible = false
	end
end

-- interface
local EspInterface = {
	_hasLoaded = false,
	_objectCache = {},
	whitelist = {},
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
};

function EspInterface.AddInstance(instance, options)
	local cache = EspInterface._objectCache;
	if cache[instance] then
		warn("Instance handler already exists.");
	else
		cache[instance] = { InstanceObject.new(instance, options) };
	end
	return cache[instance];
end

function EspInterface.Load()
	assert(not EspInterface._hasLoaded, "Esp has already been loaded.");

	local function createObject(player)
		EspInterface._objectCache[player] = {
			EspObject.new(player, EspInterface),
			ChamObject.new(player, EspInterface)
		};
	end

	local function removeObject(player)
		local object = EspInterface._objectCache[player];
		if object then
			for i = 1, #object do
				object[i]:Destruct();
			end

			EspInterface._objectCache[player] = nil;
		end
	end

	EspInterface.playerAdded = players.PlayerAdded:Connect(createObject);
	EspInterface.playerRemoving = players.PlayerRemoving:Connect(removeObject);

	for _, player in next, players:GetPlayers() do
		if player ~= localPlayer then
			createObject(player);
		end
	end

	EspInterface._hasLoaded = true;
end

function EspInterface.Unload()
	assert(EspInterface._hasLoaded, "Esp has not been loaded yet.");

	EspInterface.playerAdded:Disconnect();
	EspInterface.playerRemoving:Disconnect();

	for _, object in next, EspInterface._objectCache do
		for i = 1, #object do
			object[i]:Destruct();
		end
	end

	EspInterface._hasLoaded = false;
end

-- game specific functions
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

return EspInterface;
