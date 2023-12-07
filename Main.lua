local AVer = '4.8'

repeat wait() until game:IsLoaded()

local Host = 'https://raw.githubusercontent.com/Zanikes/Ayarum/master/'
local function HttpGet(Url)
	return loadstring(game:HttpGet(Host .. Url, true))();
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

library:Settings({
	name = 'Ayarum Hub v' .. AVer,
	themecolor1 = Color3.fromRGB(137, 0, 254),
	themecolor2 = Color3.fromRGB(223, 0, 255),
	useconfigs = true,
	foldername = 'Ayarum/Configs',
	fileext = '.json',
	autoload = isfile('Ayarum/AutoLoad.txt') and readfile('Ayarum/AutoLoad.txt') or nil
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
local HttpService = game:GetService('HttpService')
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

local EspSettings = {
	Enabled = false,
	ShowDistance = false,
	ShowHealth = false,
	TextOutline = false,
	TextSize = 20,
	Font = 'UI',

	BoxEnabled = false,
	BoxThickness = 1,
	BoxHealthBar = false,

	TracersEnabled = false,
	TracerThickness = 1,
	TracerStem = false,
	TracerFrom = 'Bottom',
	TracerTo = 'Feet',

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

local function Distance(PointA, PointB)
	return math.sqrt(math.pow(PointA.X - PointB.X, 2) + math.pow(PointA.Y - PointB.Y, 2))
end

local function GetClosest(Points, Dest)
	local Min = math.huge
	local Closest = nil
	for _, v in pairs(Points) do
		local Dist = Distance(v, Dest)
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

local function DrawName(Player)
	local TextDrawing = Drawing.new('Text')
	TextDrawing.Center = true
	TextDrawing.OutlineColor = Color3.new(0, 0, 0)
	TextDrawing.Visible = false
	local RenderEvent = RunService.RenderStepped:Connect(function()
		local ClientChar = GetCharacter(Client)
		local Char = GetCharacter(Player)
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
		if Char and ClientChar and Char:FindFirstChild('Head') and Torso and CTorso then
			local Distance = (Torso.Position - CTorso.Position).Magnitude
			local Vector, OnScreen = Camera:WorldToScreenPoint(Char.Head.Position)
			if OnScreen then
				TextDrawing.Size = EspSettings.TextSize
				TextDrawing.Outline = EspSettings.TextOutline
				TextDrawing.Color = EspSettings.Color
				TextDrawing.Font = EspSettings.Fonts[EspSettings.Font]
				TextDrawing.Visible = true
				TextDrawing.Text = Player.Name
				TextDrawing.Transparency = 1 - EspSettings.Transparency
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

				if Top then
					TextDrawing.Position = Vector2.new(Vector.X, Top.Y - 36)
					TextDrawing.Visible = true
				else
					TextDrawing.Visible = false
				end
				if (EspSettings.HideTeam == true and Player.Team == Client.Team) or (Distance > EspSettings.MaxDistance) or (EspSettings.HideDead == true and IsDead(Player)) then
					TextDrawing.Visible = false
				end
				if EspSettings.ShowDistance == true then
					TextDrawing.Text = TextDrawing.Text .. '\n[' .. string.format('%.0f', Distance) .. ']'
				end
				if EspSettings.ShowHealth == true then
					local DropLine = EspSettings.ShowDistance == false and '\n' or ' '
					TextDrawing.Text = TextDrawing.Text .. DropLine .. '[' .. string.split(tostring(GetHealth(Player)), '.')[1] .. '/' .. tostring(GetMaxHealth(Player)) .. ']'
				end
				if GetClosestPlr() == Player then
					TextDrawing.ZIndex = 1
					if EspSettings.HighlightClosest == true then
						TextDrawing.Color = EspSettings.HighlightColor
					end
				else
					TextDrawing.ZIndex = 0
				end
			else
				TextDrawing.Visible = false
			end
		else
			TextDrawing.Visible = false
		end
	end)
	local Removed = false
	local LeavingEvent
	LeavingEvent = Players.PlayerRemoving:Connect(function(LeavingPlayer)
		if LeavingPlayer == Player and not Removed then
			Removed = true
			RenderEvent:Disconnect()
			TextDrawing:Remove()
			LeavingEvent:Disconnect()
		end
	end)
	spawn(function()
		repeat wait() until EspSettings.Enabled == false
		if not Removed then
			Removed = true
			RenderEvent:Disconnect()
			TextDrawing:Remove()
			LeavingEvent:Disconnect()
		end
	end)
end

local function DrawTracer(Player)
	local Tracer = Drawing.new('Line')
	local Stem = Drawing.new('Line')
	local RenderEvent = RunService.RenderStepped:Connect(function()
		local ClientChar = GetCharacter(Client)
		local Char = GetCharacter(Player)
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
		if ClientChar and Char and Torso and CTorso and Char:FindFirstChild('Head') then
			local Distance = (Torso.Position - CTorso.Position).Magnitude
			local Vector, OnScreen = Camera:WorldToScreenPoint(Torso.Position)
			if OnScreen then
				local MousePos = Client:GetMouse()
				Tracer.Visible = true
				Tracer.Transparency = 1 - EspSettings.Transparency
				Tracer.Color = EspSettings.Color
				Tracer.Thickness = EspSettings.TracerThickness
				Stem.Visible = EspSettings.TracerStem
				Stem.Transparency = 1 - EspSettings.Transparency
				Stem.Color = EspSettings.Color
				Stem.Thickness = EspSettings.TracerThickness
				local FromList = {
					['Top'] = Vector2.new(Camera.ViewportSize.X / 2, 0),
					['Bottom'] = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y),
					['Mouse'] = Vector2.new(MousePos.X, MousePos.Y + 36)
				}
				Tracer.From = FromList[EspSettings.TracerFrom]
				if GetClosestPlr() == Player then
					Tracer.ZIndex = 1
					Stem.ZIndex = 1
					if EspSettings.HighlightClosest == true then
						Tracer.Color = EspSettings.HighlightColor
						Stem.Color = EspSettings.HighlightColor
					end
				else
					Tracer.ZIndex = 0
					Stem.ZIndex = 0
				end
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

				if Top and Bottom then
					local ToList = {
						['Head'] = Vector2.new(Vector.X, Top.Y),
						['Feet'] = Vector2.new(Vector.X, Bottom.Y)
					}
					Tracer.To = ToList[EspSettings.TracerTo]
					Tracer.Visible = true
					Stem.From = ToList.Feet
					Stem.To = ToList.Head
					Stem.Visible = EspSettings.TracerStem
				else
					Tracer.Visible = false
					Stem.Visible = false
				end
				if (EspSettings.HideTeam == true and Player.Team == Client.Team) or (Distance > EspSettings.MaxDistance) or (EspSettings.HideDead == true and IsDead(Player)) then
					Tracer.Visible = false
					Stem.Visible = false
				end
			else
				Tracer.Visible = false
				Stem.Visible = false
			end
		else
			Tracer.Visible = false
			Stem.Visible = false
		end
	end)
	local Removed = false
	local LeavingEvent
	LeavingEvent = Players.PlayerRemoving:Connect(function(LeavingPlayer)
		if LeavingPlayer == Player and not Removed then
			Removed = true
			RenderEvent:Disconnect()
			Tracer:Remove()
			Stem:Remove()
			LeavingEvent:Disconnect()
		end
	end)
	spawn(function()
		repeat wait() until EspSettings.TracersEnabled == false
		if not Removed then
			Removed = true
			RenderEvent:Disconnect()
			Tracer:Remove()
			Stem:Remove()
			LeavingEvent:Disconnect()
		end
	end)
end

local function DrawBox(Player)
	local Box = Drawing.new('Quad')
	Box.Visible = false
	Box.Thickness = 1
	local Bar = Drawing.new('Square')
	Bar.Filled = true
	Bar.Visible = false
	local Line = Drawing.new('Line')
	Line.Thickness = 1
	Line.Visible = false
	local RenderEvent = RunService.RenderStepped:Connect(function()
		local ClientChar = GetCharacter(Client)
		local Char = GetCharacter(Player)
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
		if Char and ClientChar and Torso and CTorso and not IsDead(Player) then
			local Dist = (Torso.Position - CTorso.Position).Magnitude
			local Vector, OnScreen = Camera:WorldToScreenPoint(Torso.Position)
			if OnScreen then
				Box.Color = EspSettings.Color
				Box.Visible = true
				Box.Transparency = 1 - EspSettings.Transparency
				Bar.Transparency = 1 - EspSettings.Transparency
				Line.Transparency = 1 - EspSettings.Transparency
				Line.Color = EspSettings.Color
				if GetClosestPlr() == Player then
					Box.ZIndex = 1
					Bar.ZIndex = 1
					Line.ZIndex = 1
					if EspSettings.HighlightClosest == true then
						Box.Color = EspSettings.HighlightColor
						Line.Color = EspSettings.HighlightColor
					end
				else
					Box.ZIndex = 0
					Bar.ZIndex = 0
					Line.ZIndex = 0
				end
				if EspSettings.BoxHealthBar then
					Bar.Visible = true
					Line.Visible = true
				else
					Bar.Visible = false
					Line.Visible = false
				end
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
				local Left = GetClosest(Points, Vector2.new(0, Vector.Y))
				local Right = GetClosest(Points, Vector2.new(Camera.ViewportSize.X, Vector.Y))
				local Top = GetClosest(Points, Vector2.new(Vector.X, 0))
				local Bottom = GetClosest(Points, Vector2.new(Vector.X, Camera.ViewportSize.Y))

				if Left and Right and Top and Bottom then
					Box.PointA = Vector2.new(Right.X, Top.Y)
					Box.PointB = Vector2.new(Left.X, Top.Y)
					Box.PointC = Vector2.new(Left.X, Bottom.Y)
					Box.PointD = Vector2.new(Right.X, Bottom.Y)
					Box.Visible = true

					local BoxHeight = Bottom.Y - Top.Y
					local HealthPercent = GetHealth(Player) / GetMaxHealth(Player)
					Bar.Size = Vector2.new(EspSettings.BoxThickness, -(BoxHeight * HealthPercent) + 1)
					Bar.Position = Vector2.new(Left.X + 0.5, Bottom.Y - 0.5)
					Bar.Color = Color3.new(1 - HealthPercent, HealthPercent, 0)
					Line.From = Vector2.new(Bar.Position.X + Bar.Size.X, Top.Y)
					Line.To = Vector2.new(Bar.Position.X + Bar.Size.X, Bottom.Y)
					if EspSettings.BoxHealthBar then
						Bar.Visible = true
						Line.Visible = true
					else
						Bar.Visible = false
						Line.Visible = false
					end
				else
					Box.Visible = false
					Bar.Visible = false
					Line.Visible = false
				end
				if (EspSettings.HideTeam == true and Player.Team == Client.Team) or (Dist > EspSettings.MaxDistance) then
					Box.Visible = false
					Bar.Visible = false
					Line.Visible = false
				end
			else
				Box.Visible = false
				Bar.Visible = false
				Line.Visible = false
			end
		else
			Box.Visible = false
			Bar.Visible = false
			Line.Visible = false
		end
	end)
	local Removed = false
	local LeavingEvent
	LeavingEvent = Players.PlayerRemoving:Connect(function(LeavingPlayer)
		if LeavingPlayer == Player and not Removed then
			Removed = true
			RenderEvent:Disconnect()
			Box:Remove()
			Bar:Remove()
			Line:Remove()
			LeavingEvent:Disconnect()
		end
	end)
	spawn(function()
		repeat wait() until EspSettings.BoxEnabled == false
		if not Removed then
			Removed = true
			RenderEvent:Disconnect()
			Box:Remove()
			Bar:Remove()
			Line:Remove()
			LeavingEvent:Disconnect()
		end
	end)
end

local function DrawCham(Player)
	local Cham = Instance.new('Highlight')
	Cham.Enabled = false
	local RenderEvent = RunService.RenderStepped:Connect(function()
		local ClientChar = GetCharacter(Client)
		local Char = GetCharacter(Player)
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
		if Char and ClientChar and Torso and CTorso then
			if not Cham or Cham.Parent == nil then
				Cham = Instance.new('Highlight')
			end
			local Distance = (Torso.Position - CTorso.Position).Magnitude
			Cham.Enabled = true
			Cham.FillColor = EspSettings.ChamsColor
			Cham.FillTransparency = EspSettings.ChamsFillTransparency
			Cham.OutlineColor = EspSettings.ChamsOutlineColor
			Cham.OutlineTransparency = EspSettings.ChamsOutlineTransparency
			Cham.Parent = Char
			if (EspSettings.HideTeam == true and Player.Team == Client.Team) or (Distance > EspSettings.MaxDistance) or (EspSettings.HideDead == true and IsDead(Player)) then
				Cham.Enabled = false
			end
			if GetClosestPlr() == Player and EspSettings.HighlightClosest == true then
				Cham.FillColor = EspSettings.HighlightColor
			end
		else
			Cham.Enabled = false
		end
	end)
	local Removed = false
	local LeavingEvent
	LeavingEvent = Players.PlayerRemoving:Connect(function(LeavingPlayer)
		if LeavingPlayer == Player and not Removed then
			Removed = true
			RenderEvent:Disconnect()
			Cham:Destroy()
			LeavingEvent:Disconnect()
		end
	end)
	spawn(function()
		repeat wait() until EspSettings.ChamsEnabled == false
		if not Removed then
			Removed = true
			RenderEvent:Disconnect()
			Cham:Destroy()
			LeavingEvent:Disconnect()
		end
	end)
end

library:AddConnection(Players.PlayerAdded, function(Player)
	if EspSettings.Enabled then
		DrawName(Player)
	end
	if EspSettings.TracersEnabled then
		DrawTracer(Player)
	end
	if EspSettings.BoxEnabled then
		DrawBox(Player)
	end
	if EspSettings.ChamsEnabled then
		DrawCham(Player)
	end
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
	FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
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
	if bool then
		for _, v in pairs(Players:GetPlayers()) do
			if v == Client then continue end
			DrawName(v)
		end
	end
end})
Sections.ESP.NameESP:AddToggle({text = 'Show Distance', state = false, callback = function(bool)
	EspSettings.ShowDistance = bool
end})
Sections.ESP.NameESP:AddToggle({text = 'Show Health', state = false, callback = function(bool)
	EspSettings.ShowHealth = bool
end})
Sections.ESP.NameESP:AddToggle({text = 'Text Outline', state = false, callback = function(bool)
	EspSettings.TextOutline = bool
end})
Sections.ESP.NameESP:AddSlider({text = 'Text Size', value = 20, min = 15, max = 25, suffix = 'px', callback = function(value)
	EspSettings.TextSize = value
end})
Sections.ESP.NameESP:AddList({text = 'Font', values = {'UI', 'System', 'Plex', 'Monospace'}, value = EspSettings.Fonts[1], callback = function(choice)
	EspSettings.Font = choice
end})

Sections.ESP.BoxESP:AddToggle({text = 'Enabled', state = false, callback = function(bool)
	EspSettings.BoxEnabled = bool
	if bool then
		for _, v in pairs(Players:GetPlayers()) do
			if v == Client then continue end
			DrawBox(v)
		end
	end
end})
Sections.ESP.BoxESP:AddDivider()
Sections.ESP.BoxESP:AddToggle({text = 'Health Bar', state = false, callback = function(bool)
	EspSettings.BoxHealthBar = bool
end})
Sections.ESP.BoxESP:AddSlider({text = 'Thickness', value = 2, min = 2, max = 5, callback = function(value)
	EspSettings.BoxThickness = value
end})

Sections.ESP.Tracers:AddToggle({text = 'Enabled', state = false, callback = function(bool)
	EspSettings.TracersEnabled = bool
	if bool then
		for _, v in pairs(Players:GetPlayers()) do
			if v == Client then continue end
			DrawTracer(v)
		end
	end
end})
Sections.ESP.Tracers:AddSlider({text = 'Thickness', value = 1, min = 1, max = 5, callback = function(value)
	EspSettings.TracerThickness = value
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
	if bool then
		for _, v in pairs(Players:GetPlayers()) do
			if v == Client then continue end
			DrawCham(v)
		end
	end
end})
Sections.ESP.Chams:AddSlider({text = 'Fill Transparency', value = 0.5, min = 0, max = 1, float = 0.1, callback = function(value)
	EspSettings.ChamsFillTransparency = value
end})
Sections.ESP.Chams:AddColor({text = 'Outline Color', color = Color3.fromRGB(255, 255, 255), callback = function(color)
	EspSettings.ChamsOutlineColor = color
end})
Sections.ESP.Chams:AddSlider({text = 'Outline Transparency', value = 0, min = 0, max = 1, float = 0.1, callback = function(value)
	EspSettings.ChamsOutlineTransparency = value
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
				writefile('Ayarum/AutoLoad.txt', '')
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
	writefile('Ayarum/AutoLoad.txt', library.flags['Config List'])
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
	writefile('Ayarum/AutoLoad.txt', '')
end})
if isfolder('Ayarum') and isfile('Ayarum/AutoLoad.txt') and isfile(library.foldername .. '/' .. readfile('Ayarum/AutoLoad.txt') .. library.fileext) then
	AutoloadName = readfile('Ayarum/AutoLoad.txt')
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
			getgenv().AyarumWatermark.Text = 'Ayarum Hub - Version 4.1'
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

Notify('Ayarum Hub Loaded Successfully,\nMade by Zanikes#9131')
Notify('Press ' .. library.options['UI Toggle'].key .. ' to toggle the UI')
LoadInfo('Loading Complete (' .. GameName .. ')')
repeat wait() until not library.loaded
FOVCircle:Remove()
if getgenv().AyarumWatermark then
	getgenv().AyarumWatermark:Remove()
	getgenv().AyarumWatermark = nil
end