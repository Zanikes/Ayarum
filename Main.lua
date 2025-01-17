local AVer = '5.0'

repeat wait() until game:IsLoaded()

local CollectionService = game:GetService('CollectionService')
local GuiService = game:GetService('GuiService')
local HttpService = game:GetService('HttpService')
local TeleportService = game:GetService("TeleportService")
local InputService = game:GetService('UserInputService')
local RunService = game:GetService('RunService')
local Workspace = game:GetService('Workspace')
local Players = game:GetService('Players')
local Lighting = game:GetService('Lighting')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Stats = game:GetService('Stats')
local Client = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = Client:GetMouse()
local GuiInset = GuiService:GetGuiInset().Y

local Host = 'https://raw.githubusercontent.com/Zanikes/Ayarum/master/'
local function HttpGet(File)
	local Result = request({
		Url = Host .. File,
		Method = 'GET'
	})
	return loadstring(Result.Body)()
end

local library = HttpGet('Library.lua')

local function QTween(Instance, Time, Properties)
	game:GetService('TweenService'):Create(Instance, TweenInfo.new(Time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), Properties):Play()
end

local LoadVal = 0
local LoadTotal = 4

local ApocIds = {
	237590761,
	302647266,
	1228676522,
	1228677045,
	237590657,
	1228674372,
	290815963,
	1228677761
}
local SupportedGames = {
	['Apocalypse Rising'] = ApocIds,
	['Arsenal'] = 286090429,
	['Clicker Madness'] = 5490351219,
	['Michael\'s Zombies'] = 9544666096
}

local GameName = 'Universal'
for Game, ID in pairs(SupportedGames) do
	local Supported = false
	if typeof(ID) == 'table' then
		for _, a in pairs(ID) do
			if game.PlaceId == a then
				Supported = true
				break
			end
		end
	else
		if game.PlaceId == ID then
			Supported = true
		end
	end
	if Supported then
		GameName = Game
		if GameName == 'Apocalypse Rising' then
			LoadTotal = LoadTotal + 3
		end
		break
	end
end

local Autoload
if isfile('Ayarum/AutoLoad.txt') and readfile('Ayarum/AutoLoad.txt') then
	local Contents = HttpService:JSONDecode(readfile('Ayarum/AutoLoad.txt'))
	if type(Contents) == 'table' and Contents[GameName] and isfile('Ayarum/Configs/' .. Contents[GameName] .. '.json') then
		Autoload = Contents[GameName]
	end
end

library:Settings({
	name = 'Ayarum Hub v' .. AVer,
	useconfigs = true,
	foldername = 'Ayarum/Configs',
	fileext = '.json',
	autoload = Autoload
})

local LoadingBar = library:AddLoadingBar('Ayarum Hub v' .. AVer .. ' - Loader')
local function LoadInfo(Text)
	LoadVal = LoadVal + 1
	LoadingBar:Update(LoadVal, LoadTotal, Text)
end

LoadInfo('Loading Shaders...')
local AddShaders = HttpGet('Shaders.lua')
LoadInfo('Loading Options...')

local function Notify(...)
	if not library.fullloaded then return end
	library:Notify(...)
end

local Tabs = {}
local Sections = {}

if game.CoreGui:FindFirstChild('TobBarApp') then
	GuiInset = 58
end

if game.PlaceId == 286090429 then
	for _, v in pairs(Client.PlayerGui:GetChildren()) do
		if v:IsA('Highlight') then
			v:Destroy()
		end
	end
end

local EspSettings = {
	Enabled = false,
	ShowDistance = false,
	ShowHealth = false,
	TextOutline = false,
	TextSize = 20,
	Font = 'UI',

	TracersEnabled = false,
	TracerThickness = 1,
	TracerStem = false,
	TracerFrom = 'Bottom',
	TracerTo = 'Feet',

	BoxEnabled = false,
	BoxThickness = 1,
	BoxHealthBar = false,

	ChamsEnabled = false,
	ChamsFillTransparency = 0.5,
	ChamsOutlineTransparency = 0,
	ChamsColor = Color3.fromRGB(255, 0, 0),
	ChamsOutlineColor = Color3.new(1, 1, 1),

	HighlightIgnore = {},
	HighlightClosest = false,
	Color = Color3.new(1, 1, 1),
	HighlightColor = Color3.fromRGB(255, 0, 0),
	MaxDistance = 5000,
	HideTeam = false,
	HideDead = false,
	Transparency = 0,

	Fonts = {
		['UI'] = 0,
		['System'] = 1,
		['Plex'] = 2,
		['Monospace'] = 3
	}
}

local function GetCharacter(Player)
	if Workspace:FindFirstChild(Player.Name) or Player.Character then
		return Workspace:FindFirstChild(Player.Name) or Player.Character
	end
end

local function SetDecimal(Number, Amount)
	Number = string.split(tostring(Number), '.')
	local NewNum = Number[1]
	if Number[2] and Amount > 0 then
		NewNum = NewNum .. '.' .. string.sub(Number[2], 1, Amount)
	end
	local PostDecimal = string.split(NewNum, '.')[2]
	if PostDecimal and string.sub(NewNum, #NewNum, #NewNum) == '0' then
		repeat
			NewNum = string.sub(NewNum, 1, #NewNum - 1)
		until string.sub(NewNum, #NewNum, #NewNum) ~= '0'
	end
	return NewNum
end

local function GetDistance(PointA, PointB)
	return math.sqrt(math.pow(PointA.X - PointB.X, 2) + math.pow(PointA.Y - PointB.Y, 2))
end

local function GetClosest(Points, Dest)
	local Min = math.huge
	local Closest = nil
	for _, v in pairs(Points) do
		local Dist = GetDistance(v, Dest)
		if Dist < Min then
			Min = Dist
			Closest = v
		end
	end
	return Closest
end

local function GetHealth(Player, Char)
	if game.PlaceId == 286090429 then -- Arsenal
		if Char then Player = Players:FindFirstChild(Char.Name) end
		local NRPBS = Player:FindFirstChild('NRPBS')
		if not NRPBS then return 0 end
		return NRPBS.Health.Value
	else
		if Char then
			if not Player:FindFirstChild('Humanoid') then return 0 end
			return Player.Humanoid.Health
		else
			if not Player.Character or not Player.Character:FindFirstChild('Humanoid') then return 0 end
			return Player.Character.Humanoid.Health
		end
	end
end

local function GetMaxHealth(Player, Char)
	if game.PlaceId == 286090429 then -- Arsenal
		if Char then Player = Players:FindFirstChild(Char.Name) end
		local NRPBS = Player:FindFirstChild('NRPBS')
		if not NRPBS then return 100 end
		return NRPBS.MaxHealth.Value
	else
		if Char then
			if not Player:FindFirstChild('Humanoid') then return 0 end
			return Player.Humanoid.MaxHealth
		else
			if not Player.Character or not Player.Character:FindFirstChild('Humanoid') then return 0 end
			return Player.Character.Humanoid.MaxHealth
		end
	end
end

local function IsDead(Player, Char)
	local Health = GetHealth(Player, Char)
	if Health > 0 then return false end
	return true
end

local function GetClosestPlr()
	local Min = math.huge
	local Closest = nil
	for _, v in pairs(Players:GetPlayers()) do
		if v == Client or EspSettings.HighlightIgnore[v.Name] == true or (EspSettings.HideTeam == true and v.Team == Client.Team) then continue end
		local ClientChar = GetCharacter(Client)
		local Char = GetCharacter(v)
		local Torso
		local CTorso
		if Char then
			for _, t in pairs(Char:GetChildren()) do
				if (t.Name == 'Torso' or t.Name == 'UpperTorso') and (t.ClassName == 'Part' or t.ClassName == 'MeshPart') then
					Torso = t
					break
				end
			end
		end
		if ClientChar then
			for _, t in pairs(ClientChar:GetChildren()) do
				if (t.Name == 'Torso' or t.Name == 'UpperTorso') and (t.ClassName == 'Part' or t.ClassName == 'MeshPart') then
					CTorso = t
					break
				end
			end
		end
		if Char and Torso and ClientChar and CTorso and not (EspSettings.HideDead == true and IsDead(v)) then
			local Dist = (Torso.Position - CTorso.Position).Magnitude
			if Dist < Min then
				Min = Dist
				Closest = v
			end
		end
	end
	return Closest
end

local RenderList = {}
local function AddPlayer(Player)
	local Drawings = {
		['Active'] = true,

		['Name'] = Drawing.new('Text'),

		['Tracer'] = Drawing.new('Line'),
		['Stem'] = Drawing.new('Line'),

		['Box'] = Drawing.new('Quad'),
		['Bar'] = Drawing.new('Square'),
		['Line'] = Drawing.new('Line'),

		['Cham'] = Instance.new('Highlight')
	}

	Drawings.Name.Center = true
	Drawings.Name.OutlineColor = Color3.new(0, 0, 0)
	Drawings.Name.Outline = EspSettings.TextOutline
	Drawings.Name.Size = EspSettings.TextSize
	Drawings.Name.Font = EspSettings.Fonts[EspSettings.Font]
	Drawings.Name.Transparency = 1 - EspSettings.Transparency
	Drawings.Name.Visible = false

	Drawings.Tracer.Thickness = EspSettings.TracerThickness
	Drawings.Tracer.Transparency = 1 - EspSettings.Transparency
	Drawings.Tracer.Visible = false
	Drawings.Stem.Thickness = EspSettings.TracerThickness
	Drawings.Stem.Transparency = 1 - EspSettings.Transparency
	Drawings.Stem.Visible = false

	Drawings.Box.Thickness = EspSettings.BoxThickness
	Drawings.Box.Transparency = 1 - EspSettings.Transparency
	Drawings.Box.Visible = false
	Drawings.Bar.Filled = true
	Drawings.Bar.Visible = false
	Drawings.Bar.Transparency = 1 - EspSettings.Transparency
	Drawings.Line.Thickness = 1
	Drawings.Line.Transparency = 1 - EspSettings.Transparency
	Drawings.Line.Visible = false

	Drawings.Cham.Parent = game.CoreGui
	Drawings.Cham.Enabled = false
	Drawings.Cham.FillTransparency = EspSettings.ChamsFillTransparency
	Drawings.Cham.OutlineColor = EspSettings.ChamsOutlineColor
	Drawings.Cham.OutlineTransparency = EspSettings.ChamsOutlineTransparency

	RenderList[Player.Name] = Drawings
end
for _, v in pairs(Players:GetPlayers()) do
	if v == Client then continue end
	AddPlayer(v)
end

local LastRefresh = 0
local function Update()
	if (tick() - LastRefresh) < 0.005 then return end
	LastRefresh = tick()

	local ClientChar = GetCharacter(Client)
	local MousePos = Client:GetMouse()
	local ClosestPlr
	local CTorso
	if EspSettings.HighlightClosest then
		ClosestPlr = GetClosestPlr()
	end
	if ClientChar then
		for _, t in pairs(ClientChar:GetChildren()) do
			if (t.Name == 'Torso' or t.Name == 'UpperTorso') and (t.ClassName == 'Part' or t.ClassName == 'MeshPart') then
				CTorso = t
				break
			end
		end
	end

	for Player, Drawings in pairs(RenderList) do
		if not Drawings.Active then continue end
		Player = Players:FindFirstChild(Player)
		if not Player then continue end

		local Char = GetCharacter(Player)
		local Torso
		if Char then
			for _, t in pairs(Char:GetChildren()) do
				if (t.Name == 'Torso' or t.Name == 'UpperTorso') and (t.ClassName == 'Part' or t.ClassName == 'MeshPart') then
					Torso = t
					break
				end
			end
		end

		if Char and ClientChar and Char:FindFirstChild('Head') and Torso and CTorso then
			local Distance = (Torso.Position - CTorso.Position).Magnitude
			local Vector, OnScreen = Camera:WorldToScreenPoint(Char.Head.Position)
			if OnScreen then
				local Points = {}
				local Tab = 0
				for _, v in pairs(Char:GetChildren()) do
					if v:IsA('BasePart') then
						Tab = Tab + 1
						local Pos = Camera:WorldToViewportPoint(v.Position)
						if v.Name == 'Torso' or v.Name == 'UpperTorso' then
							Pos = Camera:WorldToViewportPoint((v.CFrame * CFrame.new(0, 0, -v.Size.Z)).p)
						elseif v.Name == 'Head' then
							Pos = Camera:WorldToViewportPoint((v.CFrame * CFrame.new(0, v.Size.Y / 2, v.Size.Z / 1.25)).p)
						elseif string.match(v.Name, 'Left') then
							Pos = Camera:WorldToViewportPoint((v.CFrame * CFrame.new(-v.Size.X / 2, 0, 0)).p)
						elseif string.match(v.Name, 'Right') then
							Pos = Camera:WorldToViewportPoint((v.CFrame * CFrame.new(v.Size.X / 2, 0, 0)).p)
						end
						Points[Tab] = Pos
					end
				end

				local Top = GetClosest(Points, Vector2.new(Vector.X, 0))
				local Bottom = GetClosest(Points, Vector2.new(Vector.X, Camera.ViewportSize.Y))
				local Left = GetClosest(Points, Vector2.new(0, Vector.Y))
				local Right = GetClosest(Points, Vector2.new(Camera.ViewportSize.X, Vector.Y))

				local PlrHealth = GetHealth(Player)
				local PlrMaxHealth = GetMaxHealth(Player)
				local PlrIsDead = IsDead(Player)

				if EspSettings.Enabled then
					Drawings.Name.Color = EspSettings.Color
					Drawings.Name.Text = Player.Name

					if Top then
						Drawings.Name.Position = Vector2.new(Vector.X, Top.Y - GuiInset)
						Drawings.Name.Visible = true
					else
						Drawings.Name.Visible = false
					end
					if (EspSettings.HideTeam == true and Player.Team == Client.Team) or (Distance > EspSettings.MaxDistance) or (EspSettings.HideDead == true and PlrIsDead) then
						Drawings.Name.Visible = false
					end
					if EspSettings.ShowDistance == true then
						Drawings.Name.Text = Drawings.Name.Text .. '\n[' .. string.format('%.0f', Distance) .. ']'
					end
					if EspSettings.ShowHealth == true then
						local DropLine = EspSettings.ShowDistance == false and '\n' or ' '
						Drawings.Name.Text = Drawings.Name.Text .. DropLine .. '[' .. string.split(tostring(PlrHealth), '.')[1] .. '/' .. tostring(PlrMaxHealth) .. ']'
					end
					if ClosestPlr == Player then
						if EspSettings.HighlightClosest == true then
							Drawings.Name.Color = EspSettings.HighlightColor
						end
					end
				else
					Drawings.Name.Visible = false
				end

				if EspSettings.TracersEnabled then
					Drawings.Tracer.Color = EspSettings.Color
					Drawings.Stem.Color = EspSettings.Color
					local FromList = {
						['Top'] = Vector2.new(Camera.ViewportSize.X / 2, 0),
						['Bottom'] = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y),
						['Mouse'] = Vector2.new(MousePos.X, MousePos.Y + GuiInset)
					}
					Drawings.Tracer.From = FromList[EspSettings.TracerFrom]
					if ClosestPlr == Player then
						if EspSettings.HighlightClosest == true then
							Drawings.Tracer.Color = EspSettings.HighlightColor
							Drawings.Stem.Color = EspSettings.HighlightColor
						end
					end

					if Top and Bottom then
						local ToList = {
							['Head'] = Vector2.new(Vector.X, Top.Y),
							['Feet'] = Vector2.new(Vector.X, Bottom.Y)
						}
						Drawings.Tracer.To = ToList[EspSettings.TracerTo]
						Drawings.Tracer.Visible = true
						Drawings.Stem.From = ToList.Feet
						Drawings.Stem.To = ToList.Head
						Drawings.Stem.Visible = EspSettings.TracerStem
					else
						Drawings.Tracer.Visible = false
						Drawings.Stem.Visible = false
					end
					if (EspSettings.HideTeam == true and Player.Team == Client.Team) or (Distance > EspSettings.MaxDistance) or (EspSettings.HideDead == true and PlrIsDead) then
						Drawings.Tracer.Visible = false
						Drawings.Stem.Visible = false
					end
				else
					Drawings.Tracer.Visible = false
					Drawings.Stem.Visible = false
				end

				if EspSettings.BoxEnabled then
					Drawings.Box.Color = EspSettings.Color
					Drawings.Line.Color = EspSettings.Color
					if ClosestPlr == Player then
						if EspSettings.HighlightClosest == true then
							Drawings.Box.Color = EspSettings.HighlightColor
							Drawings.Line.Color = EspSettings.HighlightColor
						end
					end
					if EspSettings.BoxHealthBar then
						Drawings.Bar.Visible = true
						Drawings.Line.Visible = true
					else
						Drawings.Bar.Visible = false
						Drawings.Line.Visible = false
					end

					if Left and Right and Top and Bottom then
						Drawings.Box.PointA = Vector2.new(Right.X, Top.Y)
						Drawings.Box.PointB = Vector2.new(Left.X, Top.Y)
						Drawings.Box.PointC = Vector2.new(Left.X, Bottom.Y)
						Drawings.Box.PointD = Vector2.new(Right.X, Bottom.Y)
						Drawings.Box.Visible = true

						if EspSettings.BoxHealthBar then
							local BoxHeight = Bottom.Y - Top.Y
							local HealthPercent = PlrHealth / PlrMaxHealth
							Drawings.Bar.Size = Vector2.new(EspSettings.BoxThickness * 2, -(BoxHeight * HealthPercent) + 1)
							Drawings.Bar.Position = Vector2.new(Left.X + 0.5, Bottom.Y - 0.5)
							Drawings.Bar.Color = Color3.new(1 - HealthPercent, HealthPercent, 0)
							Drawings.Line.From = Vector2.new(Drawings.Bar.Position.X + Drawings.Bar.Size.X, Top.Y)
							Drawings.Line.To = Vector2.new(Drawings.Bar.Position.X + Drawings.Bar.Size.X, Bottom.Y)
							Drawings.Bar.Visible = true
							Drawings.Line.Visible = true
						else
							Drawings.Bar.Visible = false
							Drawings.Line.Visible = false
						end
					else
						Drawings.Box.Visible = false
						Drawings.Bar.Visible = false
						Drawings.Line.Visible = false
					end
					if (EspSettings.HideTeam == true and Player.Team == Client.Team) or (Distance > EspSettings.MaxDistance) or (EspSettings.HideDead == true and PlrIsDead) then
						Drawings.Box.Visible = false
						Drawings.Bar.Visible = false
						Drawings.Line.Visible = false
					end
				else
					Drawings.Box.Visible = false
					Drawings.Bar.Visible = false
					Drawings.Line.Visible = false
				end

				if EspSettings.ChamsEnabled then
					Drawings.Cham.FillColor = EspSettings.ChamsColor
					Drawings.Cham.Enabled = true
					if Drawings.Cham.Adornee ~= Char then
						Drawings.Cham.Adornee = Char
					end
					if (EspSettings.HideTeam == true and Player.Team == Client.Team) or (Distance > EspSettings.MaxDistance) or (EspSettings.HideDead == true and PlrIsDead) then
						Drawings.Cham.Enabled = false
					end
					if ClosestPlr == Player and EspSettings.HighlightClosest == true then
						Drawings.Cham.FillColor = EspSettings.HighlightColor
					end
				else
					Drawings.Cham.Enabled = false
				end
			else
				Drawings.Name.Visible = false

				Drawings.Tracer.Visible = false
				Drawings.Stem.Visible = false

				Drawings.Box.Visible = false
				Drawings.Bar.Visible = false
				Drawings.Line.Visible = false
			end
		else
			Drawings.Name.Visible = false

			Drawings.Tracer.Visible = false
			Drawings.Stem.Visible = false

			Drawings.Box.Visible = false
			Drawings.Bar.Visible = false
			Drawings.Line.Visible = false

			Drawings.Cham.Enabled = false
		end
	end
end

library:AddConnection(Players.PlayerAdded, function(Player)
	AddPlayer(Player)
end)

library:AddConnection(Players.PlayerRemoving, function(Player)
	local Drawings = RenderList[Player.Name]
	if not Drawings then return end
	Drawings.Active = false
	for _, v in pairs(Drawings) do
		if type(v) ~= "boolean" then
			v:Remove()
		end
	end
	table.remove(RenderList, table.find(RenderList, Player.Name))
end)

local AimbotSettings = {
	Enabled = false,
	TeamCheck = false,
	VisibleCheck = false,
	Aimpart = 'Head',
	IgnoreList = {},
	AutoShoot = false,
	FOV = {
		Enabled = false,
		Size = 90,
		Color = Color3.fromRGB(255, 20, 20),
		Transparency = 0,
		Sides = 60,
		Thickness = 2,
		Filled = false
	}
}

local FOVCircle = Drawing.new('Circle')
FOVCircle.ZIndex = 2
library:AddConnection(RunService.RenderStepped, function()
	FOVCircle.Visible = AimbotSettings.FOV.Enabled
	FOVCircle.Transparency = 1 - AimbotSettings.FOV.Transparency
	FOVCircle.Color = AimbotSettings.FOV.Color
	FOVCircle.Thickness = AimbotSettings.FOV.Thickness
	FOVCircle.NumSides = AimbotSettings.FOV.Sides
	FOVCircle.Radius = AimbotSettings.FOV.Size
	FOVCircle.Filled = AimbotSettings.FOV.Filled
	FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + GuiInset)
end)

local function TargetObscured(Table, ...)
	if #Camera:GetPartsObscuringTarget({Table}, {Camera, Client.Character, ...}) == 0 then
		return false
	else
		return true
	end
end

local function GetClosestPlayer()
	local Min = math.huge
	local Closest = nil

	for _, Player in pairs(Players:GetPlayers()) do
		if Player == Client or not Player.Character or not Player.Character:FindFirstChild('Head') or AimbotSettings.IgnoreList[Player.Name] then continue end
		local Vector, OnScreen = Camera:WorldToScreenPoint(Player.Character.Head.Position)
		local Distance = (Client.Character.Head.Position - Player.Character.Head.Position).Magnitude

		if not OnScreen or Distance > Min or (AimbotSettings.TeamCheck == true and Player.Team == Client.Team) or IsDead(Player) then continue end
		local VectorDistance = (Vector2.new(InputService:GetMouseLocation().X, InputService:GetMouseLocation().Y) - Vector2.new(Vector.X, Vector.Y)).Magnitude
		if (AimbotSettings.VisibleCheck and TargetObscured(Player.Character.Head.Position, Player.Character)) or (AimbotSettings.FOV.Enabled and VectorDistance > AimbotSettings.FOV.Size) then continue end
		Closest = Player
		Min = Distance
	end
	return Closest
end

local Cooldown = false
local function Aimbot()
	if not Client.Character or not AimbotSettings.Enabled or IsDead(Client) then return end
	local Closest = GetClosestPlayer()
	if Closest then
		local AimTo = AimbotSettings.Aimpart == 'Torso' and (Closest.Character:FindFirstChild('Torso') or Closest.Character:FindFirstChild('UpperTorso')) or Closest.Character:FindFirstChild('Head')
		Camera.CFrame = CFrame.new(Camera.CFrame.Position, AimTo.Position)
		if AimbotSettings.AutoShoot then
			if Cooldown then return end
			Cooldown = true
			mouse1press()
			wait()
			mouse1release()
			wait(0.015)
			Cooldown = false
		end
	end
end

Tabs.ESP = library:AddTab('ESP')
Tabs.Aimbot = library:AddTab('Aimbot')

Sections.ESP = {
	NameESP = Tabs.ESP:AddSection({text = 'Name ESP', column = 1}),
	BoxESP = Tabs.ESP:AddSection({text = 'Box ESP', column = 1}),
	Tracers = Tabs.ESP:AddSection({text = 'Tracers', column = 2}),
	Chams = Tabs.ESP:AddSection({text = 'Chams', column = 1}),
	All = Tabs.ESP:AddSection({text = 'All', column = 2})
}
Sections.Aimbot = {
	Main = Tabs.Aimbot:AddSection({text = 'Main', column = 1}),
	FOV = Tabs.Aimbot:AddSection({text = 'FOV', column = 2})
}

local PlayerNames = {}
for _, v in pairs(Players:GetPlayers()) do
	if v == Client then continue end
	table.insert(PlayerNames, v.Name)
end

library:AddConnection(Players.PlayerAdded, function(player)
	library.options['Highlight Ignore List']:AddValue(player.Name)
	library.options['Ignore List']:AddValue(player.Name)
end)

library:AddConnection(Players.PlayerRemoving, function(player)
	library.options['Highlight Ignore List']:RemoveValue(player.Name)
	library.options['Ignore List']:RemoveValue(player.Name)
end)

Sections.ESP.NameESP:AddToggle({text = 'Enabled', state = false, callback = function(bool)
	EspSettings.Enabled = bool
end})
Sections.ESP.NameESP:AddToggle({text = 'Show Distance', state = false, callback = function(bool)
	EspSettings.ShowDistance = bool
end})
Sections.ESP.NameESP:AddToggle({text = 'Show Health', state = false, callback = function(bool)
	EspSettings.ShowHealth = bool
end})
Sections.ESP.NameESP:AddToggle({text = 'Text Outline', state = false, callback = function(bool)
	EspSettings.TextOutline = bool
	for _, v in pairs(RenderList) do
		for k, a in pairs(v) do
			if k == 'Name' then
				a.Outline = bool
			end
		end
	end
end})
Sections.ESP.NameESP:AddSlider({text = 'Text Size', value = 20, min = 15, max = 25, suffix = 'px', callback = function(value)
	EspSettings.TextSize = value
	for _, v in pairs(RenderList) do
		for k, a in pairs(v) do
			if k == 'Name' then
				a.Size = value
			end
		end
	end
end})
Sections.ESP.NameESP:AddList({text = 'Font', values = {'UI', 'System', 'Plex', 'Monospace'}, value = EspSettings.Fonts[1], callback = function(choice)
	EspSettings.Font = choice
	for _, v in pairs(RenderList) do
		for k, a in pairs(v) do
			if k == 'Name' then
				a.Font = EspSettings.Fonts[choice]
			end
		end
	end
end})

Sections.ESP.BoxESP:AddToggle({text = 'Enabled', state = false, callback = function(bool)
	EspSettings.BoxEnabled = bool
end})
Sections.ESP.BoxESP:AddDivider()
Sections.ESP.BoxESP:AddToggle({text = 'Health Bar', state = false, callback = function(bool)
	EspSettings.BoxHealthBar = bool
end})
Sections.ESP.BoxESP:AddSlider({text = 'Thickness', value = 1, min = 1, max = 5, callback = function(value)
	EspSettings.BoxThickness = value
	for _, v in pairs(RenderList) do
		for k, a in pairs(v) do
			if k == 'Box' or k == 'Line' then
				a.Thickness = value
			end
		end
	end
end})

Sections.ESP.Tracers:AddToggle({text = 'Enabled', state = false, callback = function(bool)
	EspSettings.TracersEnabled = bool
end})
Sections.ESP.Tracers:AddSlider({text = 'Thickness', value = 1, min = 1, max = 5, callback = function(value)
	EspSettings.TracerThickness = value
	for _, v in pairs(RenderList) do
		for k, a in pairs(v) do
			if k == 'Tracer' or k == 'Stem' then
				a.Thickness = value
			end
		end
	end
end})
Sections.ESP.Tracers:AddList({text = 'From', values = {'Bottom', 'Top', 'Mouse'}, value = 'Bottom', callback = function(choice)
	EspSettings.TracerFrom = choice
end})
Sections.ESP.Tracers:AddList({text = 'To', values = {'Head', 'Feet'}, value = 'Feet', callback = function(choice)
	EspSettings.TracerTo = choice
end})
Sections.ESP.Tracers:AddToggle({text = 'Stem', state = false, callback = function(bool)
	EspSettings.TracerStem = bool
end})

Sections.ESP.Chams:AddToggle({text = 'Enabled', state = false, callback = function(bool)
	EspSettings.ChamsEnabled = bool
end})
Sections.ESP.Chams:AddSlider({text = 'Fill Transparency', value = 0.5, min = 0, max = 1, float = 0.1, callback = function(value)
	EspSettings.ChamsFillTransparency = value
	for _, v in pairs(RenderList) do
		for k, a in pairs(v) do
			if k == 'Cham' then
				a.FillTransparency = value
			end
		end
	end
end})
Sections.ESP.Chams:AddColor({text = 'Outline Color', color = Color3.fromRGB(255, 255, 255), callback = function(color)
	EspSettings.ChamsOutlineColor = color
	for _, v in pairs(RenderList) do
		for k, a in pairs(v) do
			if k == 'Cham' then
				a.OutlineColor = color
			end
		end
	end
end})
Sections.ESP.Chams:AddSlider({text = 'Outline Transparency', value = 0, min = 0, max = 1, float = 0.1, callback = function(value)
	EspSettings.ChamsOutlineTransparency = value
	for _, v in pairs(RenderList) do
		for k, a in pairs(v) do
			if k == 'Cham' then
				a.OutlineTransparency = value
			end
		end
	end
end})

Sections.ESP.All:AddColor({text = 'Color', color = Color3.fromRGB(255, 255, 255), callback = function(color)
	EspSettings.Color = color
	EspSettings.ChamsColor = color
end})
Sections.ESP.All:AddToggle({text = 'Highlight Closest', state = false, callback = function(bool)
	EspSettings.HighlightClosest = bool
end})
Sections.ESP.All:AddColor({text = 'Highlight Color', color = Color3.fromRGB(255, 20, 20), callback = function(color)
	EspSettings.HighlightColor = color
end})
Sections.ESP.All:AddList({text = 'Highlight Ignore List', values = PlayerNames, multiselect = true, skipflag = true, callback = function(choices)
	EspSettings.HighlightIgnore = choices
end})
Sections.ESP.All:AddSlider({text = 'Max Distance', value = 5000, min = 2500, max = 50000, suffix = ' Studs', callback = function(value)
	EspSettings.MaxDistance = value
end})
Sections.ESP.All:AddToggle({text = 'Hide Team', state = false, callback = function(bool)
	EspSettings.HideTeam = bool
end})
Sections.ESP.All:AddToggle({text = 'Hide Dead', state = false, callback = function(bool)
	EspSettings.HideDead = bool
end})
Sections.ESP.All:AddSlider({text = 'Transparency', value = 0, min = 0, max = 1, float = 0.1, callback = function(value)
	EspSettings.Transparency = value
	for _, v in pairs(RenderList) do
		for k, a in pairs(v) do
			if k == 'Name' or k == 'Tracer' or k == 'Stem' or k == 'Box' or k == 'Bar' or k == 'Line' then
				a.Transparency = 1 - EspSettings.Transparency
			end
		end
	end
end})

Sections.Aimbot.Main:AddToggle({text = 'Enabled', state = false, callback = function(bool)
	AimbotSettings.Enabled = bool
end})
Sections.Aimbot.Main:AddToggle({text = 'Team Check', state = false, callback = function(bool)
	AimbotSettings.TeamCheck = bool
end})
Sections.Aimbot.Main:AddToggle({text = 'Visible Check', state = false, callback = function(bool)
	AimbotSettings.VisibleCheck = bool
end})
Sections.Aimbot.Main:AddToggle({text = 'Auto Shoot', state = false, callback = function(bool)
	AimbotSettings.AutoShoot = bool
end})
Sections.Aimbot.Main:AddList({text = 'Aimpart', values = {'Head', 'Torso'}, value = 'Head', callback = function(choice)
	AimbotSettings.Aimpart = choice
end})
Sections.Aimbot.Main:AddList({text = 'Ignore List', values = PlayerNames, multiselect = true, skipflag = true, callback = function(choices)
	AimbotSettings.IgnoreList = choices
end})
Sections.Aimbot.Main:AddBind({text = 'Aim Key', key = Enum.UserInputType.MouseButton2, hold = true, callback = function()
	Aimbot()
end})

Sections.Aimbot.FOV:AddToggle({text = 'Use FOV', state = false, callback = function(bool)
	AimbotSettings.FOV.Enabled = bool
end})
Sections.Aimbot.FOV:AddColor({text = 'Color', color = Color3.fromRGB(255, 20, 20), callback = function(color)
	AimbotSettings.FOV.Color = color
end})
Sections.Aimbot.FOV:AddSlider({text = 'Size', value = 90, min = 50, max = 700, callback = function(value)
	AimbotSettings.FOV.Size = value
end})
Sections.Aimbot.FOV:AddSlider({text = 'Transparency', value = 0, min = 0, max = 1, float = 0.05, callback = function(value)
	AimbotSettings.FOV.Transparency = value
end})
Sections.Aimbot.FOV:AddSlider({text = 'Sides', value = 60, min = 4, max = 100, callback = function(value)
	AimbotSettings.FOV.Sides = value
end})
Sections.Aimbot.FOV:AddSlider({text = 'Thickness', value = 1, min = 1, max = 5, callback = function(value)
	AimbotSettings.FOV.Thickness = value
end})
Sections.Aimbot.FOV:AddToggle({text = 'Filled', state = false, callback = function(bool)
	AimbotSettings.FOV.Filled = bool
end})

if GameName ~= 'Universal' then
	local ArgsToSend = {library, HttpGet, QTween, LoadInfo, Tabs, Sections, Notify, IsDead, TargetObscured, GetHealth, GetMaxHealth}
	HttpGet('Games/' .. GameName:gsub(' ', '%%20') .. '.lua')(unpack(ArgsToSend))
end

Tabs.Settings = library:AddTab('Settings')
Sections.Settings = {
	Main = Tabs.Settings:AddSection({text = 'Main', column = 1}),
	UI = Tabs.Settings:AddSection({text = 'UI', column = 1}),
	Configs = Tabs.Settings:AddSection({text = 'Configs', column = 2}),
	Credits = Tabs.Settings:AddSection({text = 'Credits', column = 2})
}

Sections.Settings.UI:AddBind({text = 'Open / Close', flag = 'UI Toggle', nomouse = true, key = 'RightShift', callback = function() library:Toggle(not library.open) end})
Sections.Settings.UI:AddColor({text = 'Gradient Start Color', color = library.themecolor1})
Sections.Settings.UI:AddColor({text = 'Gradient End Color', color = library.themecolor2})
Sections.Settings.UI:AddButton({text = 'Set Theme', callback = function()
	library.themecolor1 = library.flags['Gradient Start Color']
	library.themecolor2 = library.flags['Gradient End Color']
	for _, v in pairs(library.theme) do
		v.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, library.themecolor1), ColorSequenceKeypoint.new(1, library.themecolor2)})
	end
end})
Sections.Settings.UI:AddDivider()
Sections.Settings.UI:AddToggle({text = 'Watermark', flag = 'showMark', state = true})
Sections.Settings.UI:AddToggle({text = 'Show Memory Usage', flag = 'showMem', state = true})

Sections.Settings.Credits:AddLabel('Zanikes ~ Script Developer\nZanikes ~ UI Library Developer\nDekkonot & moo1210 ~ Shaders\nErji ~ UI Library Inspiration')
Sections.Settings.Configs:AddBox({text = 'Config Name', value = '', skipflag = true})
Sections.Settings.Configs:AddButton({text = 'Create', callback = function()
	if string.gsub(library.flags['Config Name'], ' ', '') == '' then
		Notify('Please Enter a valid Config Name')
		return
	end
	library:GetConfigs()
	library:SaveConfig(library.flags['Config Name'])
	library.options['Config List']:AddValue(library.flags['Config Name'])
	Notify('Created Config ' .. library.flags['Config Name'])
end})
local ConfigWarning = library:AddWarning({type = 'confirm'})
Sections.Settings.Configs:AddList({text = 'Configs', skipflag = true, value = library:GetConfigs()[1] or '', flag = 'Config List', values = library:GetConfigs(), max = 20})
Sections.Settings.Configs:AddButton({text = 'Save', callback = function()
	ConfigWarning.text = 'Are you sure you want to save the current settings to config <b>' .. library.flags['Config List'] .. '</b>?'
	if ConfigWarning:Show() then
		library:SaveConfig(library.flags['Config List'])
		Notify('Saved Config ' .. library.flags['Config List'])
	end
end})
Sections.Settings.Configs:AddButton({text = 'Load', callback = function()
	ConfigWarning.text = 'Are you sure you want to load config <b>' .. library.flags['Config List'] .. '</b>?'
	if ConfigWarning:Show() then
		library:LoadConfig(library.flags['Config List'])
		Notify('Loaded Settings from ' .. library.flags['Config List'])
	end
end})
local AutoloadName
local AutoloadLabel
Sections.Settings.Configs:AddButton({text = 'Delete', callback = function()
	ConfigWarning.text = 'Are you sure you want to delete config <b>' .. library.flags['Config List'] .. '</b>?'
	if ConfigWarning:Show() then
		local Config = library.flags['Config List']
		if table.find(library:GetConfigs(), Config) and isfile(library.foldername .. '/' .. Config .. library.fileext) then
			local OldName = library.flags['Config List']
			library.options['Config List']:RemoveValue(Config)
			delfile(library.foldername .. '/' .. Config .. library.fileext)
			if AutoloadName == Config then
				AutoloadName = 'None'
				AutoloadLabel:SetText('Auto-Load: ' .. AutoloadName)
				if not isfolder('Ayarum') then
					makefolder('Ayarum')
				end
				local Contents = isfile('Ayarum/AutoLoad.txt') and HttpService:JSONDecode(readfile('Ayarum/AutoLoad.txt')) or {}
				if not type(Contents) == 'table' then Contents = {} end
				Contents[GameName] = nil
				writefile('Ayarum/AutoLoad.txt', HttpService:JSONEncode(Contents))
			end
			Notify('Deleted Config ' .. OldName)
		end
	end
end})
Sections.Settings.Configs:AddButton({text = 'Set to Auto-Load', callback = function()
	if not isfolder('Ayarum') then
		makefolder('Ayarum')
	end
	if not isfolder(library.foldername) then
		makefolder(library.foldername)
	end
	local Contents = isfile('Ayarum/AutoLoad.txt') and HttpService:JSONDecode(readfile('Ayarum/AutoLoad.txt')) or {}
	if not type(Contents) == 'table' then Contents = {} end
	Contents[GameName] = library.flags['Config List']
	writefile('Ayarum/AutoLoad.txt', HttpService:JSONEncode(Contents))

	AutoloadLabel:SetText('Auto-Load: ' .. library.flags['Config List'])
	AutoloadName = library.flags['Config List']
end})
Sections.Settings.Configs:AddButton({text = 'Clear Auto-Load', callback = function()
	AutoloadName = 'None'
	AutoloadLabel:SetText('Auto-Load: None')
	if not isfolder('Ayarum') then
		makefolder('Ayarum')
	end
	if not isfolder(library.foldername) then
		makefolder(library.foldername)
	end
	local Contents = isfile('Ayarum/AutoLoad.txt') and HttpService:JSONDecode(readfile('Ayarum/AutoLoad.txt')) or {}
	if not type(Contents) == 'table' then Contents = {} end
	Contents[GameName] = nil
	writefile('Ayarum/AutoLoad.txt', HttpService:JSONEncode(Contents))
end})
if isfolder('Ayarum') and isfile('Ayarum/AutoLoad.txt') then
	local Contents = HttpService:JSONDecode(readfile('Ayarum/AutoLoad.txt'))
	if type(Contents) == 'table' and Contents[GameName] and isfile('Ayarum/Configs/' .. Contents[GameName] .. '.json') then
		AutoloadName = Contents[GameName]
	end
else
	AutoloadName = 'None'
end
AutoloadLabel = Sections.Settings.Configs:AddLabel('Auto-Load: ' .. AutoloadName)
Sections.Settings.Configs:AddButton({text = 'Revert to Defaults', callback = function()
	library:Defaults()
end})

Sections.Settings.Main:AddButton({text = 'Unload Cheat', callback = library.Unload})
Sections.Settings.Main:AddBind({text = 'Panic Key', nomouse = true, callback = library.Unload})
Sections.Settings.Main:AddDivider()
local PrevLighting = {
	Ambient = 0,
	Brightness = 0,
	ClockTime = 0,
	ColorShift_Bottom = 0,
	ColorShift_Top = 0,
	ExposureCompensation = 0,
	FogColor = 0,
	FogEnd = 0,
	FogStart = 0,
	GeographicLatitude = 0,
	GlobalShadows = 0,
	OutdoorAmbient = 0,
	Outlines = 0
}
Sections.Settings.Main:AddToggle({text = 'Shaders', state = false, callback = function(bool)
	if not ReplicatedStorage:FindFirstChild('AyarumShaders') then
		local AyarumShaders = Instance.new('Folder')
		AyarumShaders.Name = 'AyarumShaders'
		AyarumShaders.Parent = ReplicatedStorage
	end
	local ShadersInLighting = Lighting:FindFirstChild('AyarumShadersEnabled')
	local ShadersInStorage = ReplicatedStorage.AyarumShaders:FindFirstChild('AyarumShadersEnabled')
	if ShadersInStorage then
		for _, v in pairs(ReplicatedStorage.AyarumShaders:GetChildren()) do
			if v:IsA('BloomEffect') or v:IsA('Sky') or v:IsA('BlurEffect') or v:IsA('ColorCorrectionEffect') or v:IsA('SunRaysEffect') or v.Name == 'AyarumShadersEnabled' then
				v:Destroy()
			end
		end
	end
	if bool then
		if ShadersInLighting then return end
		for Property, _ in pairs(PrevLighting) do
			PrevLighting[Property] = Lighting[Property]
		end
		for _, v in pairs(Lighting:GetChildren()) do
			if v:IsA('BloomEffect') or v:IsA('Sky') or v:IsA('BlurEffect') or v:IsA('ColorCorrectionEffect') or v:IsA('SunRaysEffect') then
				v.Parent = ReplicatedStorage.AyarumShaders
			end
		end
		AddShaders()
	else
		if ShadersInLighting then
			for _, v in pairs(Lighting:GetChildren()) do
				if v:IsA('BloomEffect') or v:IsA('Sky') or v:IsA('BlurEffect') or v:IsA('ColorCorrectionEffect') or v:IsA('SunRaysEffect') or v.Name == 'AyarumShadersEnabled' then
					v:Destroy()
				end
			end
			for Property, Value in pairs(PrevLighting) do
				if typeof(Value) ~= typeof(Lighting[Property]) then continue end
				Lighting[Property] = Value
			end
			for _, v in pairs(ReplicatedStorage.AyarumShaders:GetChildren()) do
				v.Parent = Lighting
			end
		end
	end
end})

LoadInfo('Initializing UI...')
library:Init()
repeat wait() until library.fullloaded
if getgenv().AyarumWatermark then getgenv().AyarumWatermark:Remove() end
getgenv().AyarumWatermark = Drawing.new('Text')
getgenv().AyarumWatermark.Position = Vector2.new(5, Camera.ViewportSize.Y - 20)
getgenv().AyarumWatermark.Size = 16
getgenv().AyarumWatermark.Center = false
getgenv().AyarumWatermark.Font = 3
getgenv().AyarumWatermark.Visible = true
getgenv().AyarumWatermark.Outline = true
getgenv().AyarumWatermark.OutlineColor = Color3.new()
getgenv().AyarumWatermark.Color = Color3.new(1, 1, 1)

Camera:GetPropertyChangedSignal('ViewportSize'):Connect(function()
	getgenv().AyarumWatermark.Position = Vector2.new(5, Camera.ViewportSize.Y - 20)
end)

spawn(function()
	while library and getgenv().AyarumWatermark and wait() do
		if not getgenv().AyarumWatermark then return end
		getgenv().AyarumWatermark.Text = ''
		if library.flags['showMark'] then
			getgenv().AyarumWatermark.Text = 'Ayarum Hub - Version ' .. AVer
		end
		if library.flags['showMem'] then
			local Mem = SetDecimal(Stats.PerformanceStats.Memory:GetValue(), 2) .. ' MB'
			if library.flags['showMark'] then
				getgenv().AyarumWatermark.Text = getgenv().AyarumWatermark.Text .. ' [Mem: ' .. Mem .. ']'
			else
				getgenv().AyarumWatermark.Text = 'Mem: ' .. Mem
			end
		end
	end
end)

RunService:UnbindFromRenderStep('UpdateEsp')
RunService:BindToRenderStep('UpdateEsp', 300, Update)

Notify('Ayarum Hub Loaded Successfully,\nMade by Zanikes#9131')
Notify('Press ' .. library.options['UI Toggle'].key .. ' to toggle the UI')
LoadInfo('Loading Complete (' .. GameName .. ')')
repeat wait() until not library.loaded
FOVCircle:Remove()
if getgenv().AyarumWatermark then
	getgenv().AyarumWatermark:Remove()
	getgenv().AyarumWatermark = nil
end
RunService:UnbindFromRenderStep('UpdateEsp')