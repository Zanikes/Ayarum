local function Roundify(Object, Extra)
	if Object:FindFirstChild('UICorner') then Object.UICorner:Destroy() end
	local UICorner = Instance.new('UICorner')
	UICorner.Parent = Object
	UICorner.CornerRadius = UDim.new(0, 5)
	if Extra then
		UICorner.CornerRadius = UDim.new(0, 25)
	end
end

local function Border(Object, Color, Transparency)
	if Object:FindFirstChild('UIStroke') then Object.UIStroke:Destroy() end
	local UIStroke = Instance.new('UIStroke')
	UIStroke.Parent = Object
	UIStroke.Color = Color
	UIStroke.Transparency = Transparency
	UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
end

local function ABorder(Object)
	if Object:FindFirstChild('UIStroke') then Object.UIStroke:Destroy() end
	local UIStroke = Instance.new('UIStroke')
	UIStroke.Parent = Object
	UIStroke.Color = Object.BorderColor3
	UIStroke.Transparency = Object.BackgroundTransparency
	UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
end

local Gui = game.Players.LocalPlayer.PlayerGui
local Lighting = game.Lighting
local ReplicatedStorage = game.ReplicatedStorage

Roundify(Lighting.Spawn.Spawn)
Border(Lighting.Spawn.Spawn, Color3.new(), 0.5)

Roundify(Lighting.GroupInvite.Frame)
Roundify(Lighting.GroupInvite.Frame.Yes)
Roundify(Lighting.GroupInvite.Frame.No)
ABorder(Lighting.GroupInvite.Frame)
ABorder(Lighting.GroupInvite.Frame.Yes)
ABorder(Lighting.GroupInvite.Frame.No)

Roundify(Lighting.Map.Frame.TextLabel)
Roundify(Lighting.Map.Frame.Map)
ABorder(Lighting.Map.Frame.Map)
Lighting.Map.Frame.TextLabel.Position = UDim2.new(0, 0, 0, 610)

Roundify(Lighting.StrikeThree.Intro)
Roundify(Lighting.StrikeThree.Intro.Yes)
ABorder(Lighting.StrikeThree.Intro)
ABorder(Lighting.StrikeThree.Intro.Yes)

Roundify(ReplicatedStorage.AmmoGui.Frame)
ABorder(ReplicatedStorage.AmmoGui.Frame)

if ReplicatedStorage.VehicleHUD:FindFirstChild('CustomHUD') then ReplicatedStorage.VehicleHUD.CustomHUD:Destroy() end
ReplicatedStorage.VehicleHUD.Stats.Visible = false

local CustomHUD = Instance.new("Frame")
local Fuel = Instance.new("Frame")
local Bar = Instance.new("Frame")
local _75 = Instance.new("Frame")
local _50 = Instance.new("Frame")
local _25 = Instance.new("Frame")
local VehicleName = Instance.new("TextLabel")
local Stats = Instance.new("Frame")
local Hull = Instance.new("TextLabel")
local Tank = Instance.new("TextLabel")
local Engine = Instance.new("TextLabel")
local Armor = Instance.new("TextLabel")
local Speed = Instance.new("Frame")

CustomHUD.Name = "CustomHUD"
CustomHUD.Parent = ReplicatedStorage.VehicleHUD
CustomHUD.AnchorPoint = Vector2.new(0.5, 1)
CustomHUD.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
CustomHUD.BackgroundTransparency = 0.300
CustomHUD.BorderColor3 = Color3.fromRGB(0, 0, 0)
CustomHUD.Position = UDim2.new(0.5, 0, 1, -115)
CustomHUD.Size = UDim2.new(0, 200, 0, 105)
Roundify(CustomHUD)
ABorder(CustomHUD)

Fuel.Name = "Fuel"
Fuel.Parent = CustomHUD
Fuel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Fuel.BorderColor3 = Color3.fromRGB(0, 0, 0)
Fuel.Position = UDim2.new(0, 5, 0, 5)
Fuel.Size = UDim2.new(0, 8, 0, 95)
Roundify(Fuel)
ABorder(Fuel)

Bar.Name = "Bar"
Bar.Parent = Fuel
Bar.AnchorPoint = Vector2.new(0, 1)
Bar.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
Bar.BorderColor3 = Color3.fromRGB(0, 0, 0)
Bar.Position = UDim2.new(0, 0, 1, 0)
Bar.Size = UDim2.new(1, 0, 0, 50)
Bar.BackgroundTransparency = 1
Bar.ClipsDescendants = true

local BarFrame = Instance.new('Frame')
BarFrame.Name = "BarFrame"
BarFrame.Parent = Bar
BarFrame.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
BarFrame.Size = UDim2.new(1, 0, 0, 95)
BarFrame.AnchorPoint = Vector2.new(0, 1)
BarFrame.Position = UDim2.new(0, 0, 1, 0)
Roundify(BarFrame)

_75.Name = "75"
_75.Parent = Fuel
_75.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
_75.BorderColor3 = Color3.fromRGB(0, 0, 0)
_75.BorderSizePixel = 0
_75.Position = UDim2.new(0, 0, 0.25, 0)
_75.Size = UDim2.new(0, 5, 0, 1)

_50.Name = "50"
_50.Parent = Fuel
_50.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
_50.BorderColor3 = Color3.fromRGB(0, 0, 0)
_50.BorderSizePixel = 0
_50.Position = UDim2.new(0, 0, 0.5, 0)
_50.Size = UDim2.new(0, 5, 0, 1)

_25.Name = "25"
_25.Parent = Fuel
_25.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
_25.BorderColor3 = Color3.fromRGB(0, 0, 0)
_25.BorderSizePixel = 0
_25.Position = UDim2.new(0, 0, 0.75, 0)
_25.Size = UDim2.new(0, 5, 0, 1)

VehicleName.Name = "VehicleName"
VehicleName.Parent = CustomHUD
VehicleName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
VehicleName.BackgroundTransparency = 1.000
VehicleName.Size = UDim2.new(1, 0, 0, 18)
VehicleName.Font = Enum.Font.ArialBold
VehicleName.TextColor3 = Color3.fromRGB(255, 255, 255)
VehicleName.TextSize = 14.000
VehicleName.TextStrokeTransparency = 0.000

Stats.Name = "Stats"
Stats.Parent = CustomHUD
Stats.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Stats.BackgroundTransparency = 0.300
Stats.BorderColor3 = Color3.fromRGB(0, 0, 0)
Stats.Position = UDim2.new(0, 18, 0, 20)
Stats.Size = UDim2.new(1, -23, 1, -43)
Roundify(Stats)
ABorder(Stats)

Hull.Name = "Hull"
Hull.Parent = Stats
Hull.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Hull.BackgroundTransparency = 1.000
Hull.Size = UDim2.new(0.5, 0, 0.5, 0)
Hull.Font = Enum.Font.ArialBold
Hull.Text = "Hull"
Hull.TextColor3 = Color3.fromRGB(0, 255, 100)
Hull.TextSize = 14.000
Hull.TextStrokeTransparency = 0.000

Tank.Name = "Tank"
Tank.Parent = Stats
Tank.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Tank.BackgroundTransparency = 1.000
Tank.Position = UDim2.new(0.5, 0, 0, 0)
Tank.Size = UDim2.new(0.5, 0, 0.5, 0)
Tank.Font = Enum.Font.ArialBold
Tank.Text = "Tank"
Tank.TextColor3 = Color3.fromRGB(0, 255, 100)
Tank.TextSize = 14.000
Tank.TextStrokeTransparency = 0.000

Engine.Name = "Engine"
Engine.Parent = Stats
Engine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Engine.BackgroundTransparency = 1.000
Engine.Position = UDim2.new(0, 0, 0.5, 0)
Engine.Size = UDim2.new(0.5, 0, 0.5, 0)
Engine.Font = Enum.Font.ArialBold
Engine.Text = "Engine"
Engine.TextColor3 = Color3.fromRGB(0, 255, 100)
Engine.TextSize = 14.000
Engine.TextStrokeTransparency = 0.000

Armor.Name = "Armor"
Armor.Parent = Stats
Armor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Armor.BackgroundTransparency = 1.000
Armor.Position = UDim2.new(0.5, 0, 0.5, 0)
Armor.Size = UDim2.new(0.5, 0, 0.5, 0)
Armor.Font = Enum.Font.ArialBold
Armor.Text = "Armor"
Armor.TextColor3 = Color3.fromRGB(0, 255, 100)
Armor.TextSize = 14.000
Armor.TextStrokeTransparency = 0.000

Speed.Name = "Speed"
Speed.Parent = CustomHUD
Speed.AnchorPoint = Vector2.new(0, 1)
Speed.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Speed.BorderColor3 = Color3.fromRGB(0, 0, 0)
Speed.Position = UDim2.new(0, 18, 1, -5)
Speed.Size = UDim2.new(1, -23, 0, 13)
Roundify(Speed)
ABorder(Speed)

local SpeedText = Instance.new("TextLabel")

SpeedText.Name = "SpeedText"
SpeedText.Parent = Speed
SpeedText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SpeedText.BackgroundTransparency = 1.000
SpeedText.Size = UDim2.new(1, 0, 1, 0)
SpeedText.ZIndex = 2
SpeedText.Font = Enum.Font.ArialBold
SpeedText.Text = "0 km/h"
SpeedText.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedText.TextSize = 12.000
SpeedText.TextStrokeTransparency = 0.000
SpeedText.TextYAlignment = Enum.TextYAlignment.Bottom

local SpeedBar = Instance.new("Frame")

SpeedBar.Name = "SpeedBar"
SpeedBar.Parent = Speed
SpeedBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SpeedBar.BorderColor3 = Color3.fromRGB(0, 0, 0)
SpeedBar.Size = UDim2.new(0, 150, 1, 0)
SpeedBar.BorderSizePixel = 0
SpeedBar.ClipsDescendants = true
SpeedBar.BackgroundTransparency = 1

local Color = Instance.new("Frame")
local UIGradient = Instance.new("UIGradient")

Color.Name = "Color"
Color.Parent = SpeedBar
Color.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Color.Size = UDim2.new(0, 177, 1, 0)
Roundify(Color)

UIGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(0, 255, 100)), ColorSequenceKeypoint.new(0.50, Color3.fromRGB(200, 200, 50)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 65, 65))}
UIGradient.Parent = Color

for _, v in pairs(ReplicatedStorage.Menus:GetChildren()) do
	for _, a in pairs(v:GetChildren()) do
		Roundify(a)
		ABorder(a)
	end
end

local function Load()
	Gui.Inventory.InventoryFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	Gui.Inventory.InventoryFrame.BackFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	for _, v in pairs(Gui.Inventory.InventoryFrame.Slots:GetChildren()) do
		v.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		v.BorderColor3 = Color3.fromRGB(15, 15, 15)
	end
	Gui.Inventory.InventoryFrame.Description.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	Gui.Inventory.InventoryFrame.RightClick.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	for _, v in pairs(Gui.Inventory.InventoryFrame:GetChildren()) do
		if v:IsA('ImageButton') then
			v.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
			v.BorderColor3 = Color3.fromRGB(15, 15, 15)
		end
	end
	for _, v in pairs(Gui.Inventory.InventoryFrame.UtilitySlots:GetChildren()) do
		v.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		v.BorderColor3 = Color3.fromRGB(15, 15, 15)
	end
	Gui.Inventory.InventoryFrame.Options.BorderColor3 = Color3.new()
	Gui.Inventory.WeaponSkins.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	for _, v in pairs(Gui.Inventory.WeaponSkins:GetChildren()) do
		if string.sub(v.Name, 1, 5) == 'Slots' then
			for _, a in pairs(v:GetChildren()) do
				a.BackgroundTransparency = 1
				a.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
			end
		end
	end
	Gui.Inventory.WeaponSkins.Back.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	Gui.Inventory.WeaponSkins.Close.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	Gui.Inventory.WeaponSkins.Switch.Back.ImageColor3 = Color3.fromRGB(150, 150, 150)
	Gui.Inventory.WeaponSkins.Switch.Next.ImageColor3 = Color3.fromRGB(150, 150, 150)
	Gui.Options.Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	Gui.Options.Frame.Controls.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	Gui.Options.Frame.Options.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	Gui.Options.Frame.Statistics.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	Gui.Options.Frame.Back.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	Gui.Options.Frame.Close.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	for _, v in pairs(Gui.Options.Frame.Controls:GetChildren()) do
		if v:FindFirstChild('NoToggle') then
			v.NoToggle.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
		end
	end
	for _, v in pairs(Gui.Options.Frame.Statistics:GetChildren()) do
		if v:IsA('TextLabel') then
			v.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
			v.BorderColor3 = Color3.new()
			for _, a in pairs(v:GetChildren()) do
				if a:IsA('TextLabel') then
					a.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
					a.BorderColor3 = Color3.new()
				end
			end
		end
	end
	Gui.ViewContents.LightInventory.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	for _, v in pairs(Gui.ViewContents.LightInventory:GetChildren()) do
		if v:IsA('ImageButton') then
			v.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
			v.BorderColor3 = Color3.fromRGB()
		end
	end
	for _, v in pairs(Gui.ViewContents.LightInventory.Slots:GetChildren()) do
		if v.Name ~= 'Title' then
			v.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
			v.BorderColor3 = Color3.fromRGB()
		end
	end
	for _, v in pairs(Gui.ViewContents.LightInventory.UtilitySlots:GetChildren()) do
		if v.Name ~= 'Title' then
			v.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
			v.BorderColor3 = Color3.fromRGB()
		end
	end
	for _, v in pairs(Gui.ViewContents.Storage.Slots:GetChildren()) do
		v.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
		v.BorderColor3 = Color3.fromRGB()
	end
	Gui.ViewContents.Storage.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	Gui.Sidebar.Bin.Compass.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	Gui.Sidebar.Bin.Watch.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	Gui.Sidebar.Bin.Compass.Bar.BackgroundTransparency = 1
	for _, v in pairs(Gui.Sidebar.Bin.Frame.Main:GetChildren()) do
		if not v:IsA('ImageButton') then continue end
		v.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
		v:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
			if v.BackgroundColor3 ~= Color3.fromRGB(35, 35, 35) then
				v.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
			end
		end)
	end
	Gui.Sidebar.Bin.Frame.Bottom.Settings.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	Gui.Sidebar.Bin.Frame.Bottom.Lobby.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	Gui.Sidebar.Bin.Message.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	Gui.Sidebar.Bin.Message.Label.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	Gui.Sidebar.Bin.Message.Yes.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	Gui.Sidebar.Bin.Message.No.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	Gui.Sidebar.DisplayOrder = 1
	Gui.MyGroup.Bin.PlayerInfo.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	Gui.MyGroup.Bin.BareInfo.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	Gui.MyGroup.Bin.LeaderInfo.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	for _, v in pairs(Gui.MyGroup.Bin.PlayerInfo:GetChildren()) do
		if v:IsA('TextButton') then
			v.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
		end
	end
	for _, v in pairs(Gui.MyGroup.Bin.BareInfo:GetChildren()) do
		if v:IsA('TextButton') then
			v.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
		end
	end
	for _, v in pairs(Gui.MyGroup.Bin.LeaderInfo:GetChildren()) do
		if v:IsA('TextButton') then
			v.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
		end
	end
	Lighting.GroupInvite.Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	ReplicatedStorage.AmmoGui.Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	for _, v in pairs(Gui.Inventory.InventoryFrame:GetChildren()) do
		if v:IsA('ImageButton') then
			v.ChildAdded:Connect(function(a)
				if string.find(a.Name, 'Drop') then
					for _, k in pairs(a:GetChildren()) do
						k.BackgroundTransparency = 1
						k.UIStroke.Transparency = 1
						k.MouseEnter:Connect(function()
							k.BackgroundTransparency = 0.3
							k.UIStroke.Transparency = 0.3
						end)
						k.MouseLeave:Connect(function()
							k.BackgroundTransparency = 1
							k.UIStroke.Transparency = 1
						end)
					end
					local f = Instance.new('Frame')
					f.Parent = a
					f.Size = UDim2.new(0, v.AbsoluteSize.X, 0, v.AbsoluteSize.Y)
					f.BackgroundColor3 = Color3.new()
					f.BackgroundTransparency = 0.8
					f.ZIndex = 10
					Roundify(f)
				end
			end)
		end
	end
	for _, v in pairs(Gui.Inventory.InventoryFrame.UtilitySlots:GetChildren()) do
		v.ChildAdded:Connect(function(a)
			if string.find(a.Name, 'Drop') then
				for _, k in pairs(a:GetChildren()) do
					k.BackgroundTransparency = 1
					k.UIStroke.Transparency = 1
					k.MouseEnter:Connect(function()
						k.BackgroundTransparency = 0.3
						k.UIStroke.Transparency = 0.3
					end)
					k.MouseLeave:Connect(function()
						k.BackgroundTransparency = 1
						k.UIStroke.Transparency = 1
					end)
				end
				local f = Instance.new('Frame')
				f.Parent = a
				f.Size = UDim2.new(0, v.AbsoluteSize.X, 0, v.AbsoluteSize.Y)
				f.BackgroundColor3 = Color3.new()
				f.BackgroundTransparency = 0.8
				f.ZIndex = 10
				Roundify(f)
			end
		end)
	end
	for _, v in pairs(Gui.Inventory.InventoryFrame.Slots:GetChildren()) do
		v.ChildAdded:Connect(function(a)
			if string.find(a.Name, 'Drop') then
				for _, k in pairs(a:GetChildren()) do
					k.BackgroundTransparency = 1
					k.UIStroke.Transparency = 1
					k.MouseEnter:Connect(function()
						k.BackgroundTransparency = 0.3
						k.UIStroke.Transparency = 0.3
					end)
					k.MouseLeave:Connect(function()
						k.BackgroundTransparency = 1
						k.UIStroke.Transparency = 1
					end)
				end
				local f = Instance.new('Frame')
				f.Parent = a
				f.Size = UDim2.new(0, v.AbsoluteSize.X, 0, v.AbsoluteSize.Y)
				f.BackgroundColor3 = Color3.new()
				f.BackgroundTransparency = 0.8
				f.ZIndex = 10
				Roundify(f)
			end
		end)
	end

	Roundify(Lighting.Info.Frame.Text)
	ABorder(Lighting.Info.Frame.Text)
	for _, v in pairs(Gui:WaitForChild('Tools').Bin.Fakes:GetChildren()) do
		v.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
		v.BorderSizePixel = 0
		v.Number.TextColor3 = Color3.fromRGB(150, 150, 150)
	end
	for _, v in pairs(Gui:WaitForChild('Survival').Bin:GetDescendants()) do
		if v.Name == 'White' then
			v.Position = UDim2.new(0, 0, 0, 0)
			v.Size = UDim2.new(1, 0, 1, 0)
		end
	end

	if Gui:FindFirstChild('Spawn') then
		Roundify(Gui.Spawn.Spawn)
		Border(Gui.Spawn.Spawn, Color3.new(), 0.5)
	end

	Roundify(Gui.MyGroup.Bin.BareInfo)
	Border(Gui.MyGroup.Bin.BareInfo, Color3.new(), 0.5)
	Roundify(Gui.MyGroup.Bin.BareInfo.Cancel)
	Border(Gui.MyGroup.Bin.BareInfo.Cancel, Color3.new(), 0.6)

	Roundify(Gui.MyGroup.Bin.LeaderInfo)
	Border(Gui.MyGroup.Bin.LeaderInfo, Color3.new(), 0.5)
	Roundify(Gui.MyGroup.Bin.LeaderInfo.Cancel)
	Border(Gui.MyGroup.Bin.LeaderInfo.Cancel, Color3.new(), 0.6)
	Roundify(Gui.MyGroup.Bin.LeaderInfo.Leaderize)
	Border(Gui.MyGroup.Bin.LeaderInfo.Leaderize, Color3.new(), 0.6)
	Roundify(Gui.MyGroup.Bin.LeaderInfo.Kick)
	Border(Gui.MyGroup.Bin.LeaderInfo.Kick, Color3.new(), 0.6)

	Roundify(Gui.MyGroup.Bin.PlayerInfo)
	Border(Gui.MyGroup.Bin.PlayerInfo, Color3.new(), 0.5)
	Roundify(Gui.MyGroup.Bin.PlayerInfo.Cancel)
	Border(Gui.MyGroup.Bin.PlayerInfo.Cancel, Color3.new(), 0.6)
	Roundify(Gui.MyGroup.Bin.PlayerInfo.Invite)
	Border(Gui.MyGroup.Bin.PlayerInfo.Invite, Color3.new(), 0.6)

	Roundify(Gui.Options.Frame)
	ABorder(Gui.Options.Frame)
	Roundify(Gui.Options.Frame.Controls)
	ABorder(Gui.Options.Frame.Controls)
	Roundify(Gui.Options.Frame.Statistics)
	ABorder(Gui.Options.Frame.Statistics)
	Roundify(Gui.Options.Frame.Options)
	ABorder(Gui.Options.Frame.Options)
	Roundify(Gui.Options.Frame.Back)
	ABorder(Gui.Options.Frame.Back)
	Roundify(Gui.Options.Frame.Close)
	ABorder(Gui.Options.Frame.Close)

	for _, v in pairs(Gui.Options.Frame.Controls:GetChildren()) do
		if v:IsA('TextLabel') then
			if v.BackgroundTransparency == 1 then
				local a = v:FindFirstChildOfClass('TextButton') or v:FindFirstChildOfClass('TextLabel')
				Roundify(a)
				ABorder(a)
			else
				Roundify(v)
				ABorder(v)
			end
		end
	end

	for _, v in pairs(Gui.Options.Frame.Statistics:GetChildren()) do
		if v:IsA('TextLabel') then
			Roundify(v)
			ABorder(v)
			if string.sub(v.Text, 1, 1) ~= ' ' then
				v.Text = ' ' .. v.Text
			end
			for _, a in pairs(v:GetChildren()) do
				if a.Name ~= 'Amount' and a:IsA('TextLabel') then
					Roundify(a)
					ABorder(a)
					if string.sub(a.Text, 1, 1) ~= ' ' then
						a.Text = ' ' .. a.Text
					end
				end
			end
		end
	end

	for _, v in pairs(Gui.Options.Frame.Options:GetChildren()) do
		if v:FindFirstChild('Toggle') then
			Roundify(v.Toggle)
			ABorder(v.Toggle)
		end
	end

	for _, v in pairs(Gui.Sidebar.Bin.Frame.Main:GetChildren()) do
		if v:IsA('ImageButton') then
			Roundify(v)
			ABorder(v)
			if v:FindFirstChild('Indicator') then
				Roundify(v.Indicator)
				ABorder(v.Indicator)
			end
			if v:FindFirstChild('Volume') then
				for _, a in pairs(v.Volume:GetChildren()) do
					if not a:IsA('TextButton') then continue end
					Roundify(a)
					ABorder(a)
				end
				Roundify(v.Volume)
				ABorder(v.Volume)
			end
		end
	end

	for _, v in pairs(Gui.Sidebar.Bin.Frame.Bottom:GetChildren()) do
		Roundify(v)
		ABorder(v)
	end

	Roundify(Gui.Sidebar.Bin.Compass)
	Roundify(Gui.Sidebar.Bin.Compass.Bar)
	ABorder(Gui.Sidebar.Bin.Compass)
	ABorder(Gui.Sidebar.Bin.Compass.Bar)
	Roundify(Gui.Sidebar.Bin.Message)
	Roundify(Gui.Sidebar.Bin.Message.Yes)
	Roundify(Gui.Sidebar.Bin.Message.No)
	Roundify(Gui.Sidebar.Bin.Message.Label)
	ABorder(Gui.Sidebar.Bin.Message)
	ABorder(Gui.Sidebar.Bin.Message.Yes)
	ABorder(Gui.Sidebar.Bin.Message.No)
	ABorder(Gui.Sidebar.Bin.Message.Label)
	Roundify(Gui.Sidebar.Bin.Watch)
	ABorder(Gui.Sidebar.Bin.Watch)

	for _, v in pairs(Gui.Tools.Bin.Fakes:GetChildren()) do
		Roundify(v)
	end

	for _, v in pairs(Gui.Tools.Bin.Hotbar:GetChildren()) do
		Roundify(v)
		Border(v, Color3.new(), 0.5)
	end
	Gui.Tools.Bin.Hotbar.ChildAdded:Connect(function(child)
		Roundify(child)
		Border(child, Color3.new(), 0.5)
	end)

	Roundify(Gui.ViewContents.LightInventory)
	ABorder(Gui.ViewContents.LightInventory)
	for _, v in pairs(Gui.ViewContents.LightInventory:GetChildren()) do
		if v:IsA('ImageButton') then
			Roundify(v)
			ABorder(v)
			if v.Position.Y.Offset == 15 then
				v.Position = v.Position + UDim2.new(0, 0, 0, 5)
			elseif v.Position.Y.Offset == 82 then
				v.Position = v.Position + UDim2.new(0, 0, 0, 10)
			end
		end
	end
	Gui.ViewContents.LightInventory.Slots.Position = UDim2.new(0, 5, 0, 179)
	Gui.ViewContents.LightInventory.UtilitySlots.Position = UDim2.new(0, 243, 0, 20)

	for _, v in pairs(Gui.ViewContents.LightInventory.Slots:GetChildren()) do
		if v:IsA('ImageButton') then
			for _, a in pairs(v.SlotDisplay:GetChildren()) do
				Roundify(a)
				ABorder(a)
			end
			Roundify(v)
			ABorder(v)
		end
	end

	for _, v in pairs(Gui.ViewContents.LightInventory.UtilitySlots:GetChildren()) do
		Roundify(v)
		ABorder(v)
	end

	Roundify(Gui.ViewContents.Storage)
	ABorder(Gui.ViewContents.Storage)

	for _, v in pairs(Gui.ViewContents.Storage.Slots:GetChildren()) do
		Roundify(v)
		ABorder(v)
	end

	Roundify(Gui.CustomChat.Bin.TextFrame)
	ABorder(Gui.CustomChat.Bin.TextFrame)
	Gui.CustomChat.Bin.TextFrame.Position = UDim2.new(0, 5, 0, 135)
	Gui.CustomChat.Bin.TextFrame:GetPropertyChangedSignal('Size'):Connect(function()
		if Gui.CustomChat.Bin.TextFrame.Size ~= UDim2.new(0, 225, 0, 20) then
			Gui.CustomChat.Bin.TextFrame.Size = UDim2.new(0, 225, 0, 20)
		end
	end)
	Gui.CustomChat.Bin.TextFrame.Size = UDim2.new(0, 225, 0, 20)

	Roundify(Gui.CustomChat.Bin.Global)
	Roundify(Gui.CustomChat.Bin.Group)
	ABorder(Gui.CustomChat.Bin.Global)
	ABorder(Gui.CustomChat.Bin.Group)

	Gui.CustomChat.Bin.Global.Size = UDim2.new(0, 109, 0, 20)
	Gui.CustomChat.Bin.Group.Size = UDim2.new(0, 109, 0, 20)
	Gui.CustomChat.Bin.Global.Position = UDim2.new(0, 5, 0, 160)
	Gui.CustomChat.Bin.Group.Position = UDim2.new(0, 121, 0, 160)

	Roundify(Gui.Survival.Bin.Health)
	ABorder(Gui.Survival.Bin.Health)
	Roundify(Gui.Survival.Bin.Health.Damage)
	Roundify(Gui.Survival.Bin.Health.Bar)
	Roundify(Gui.Survival.Bin.Health.Damage.White)
	Roundify(Gui.Survival.Bin.Health.Bar.White)

	Roundify(Gui.Survival.Bin.Hunger)
	ABorder(Gui.Survival.Bin.Hunger)
	Roundify(Gui.Survival.Bin.Hunger.Bar)
	Roundify(Gui.Survival.Bin.Hunger.Bar.White)

	Roundify(Gui.Survival.Bin.Thirst)
	ABorder(Gui.Survival.Bin.Thirst)
	Roundify(Gui.Survival.Bin.Thirst.Bar)
	Roundify(Gui.Survival.Bin.Thirst.Bar.White)

	Roundify(Gui.Survival.Bin.Stamina)
	ABorder(Gui.Survival.Bin.Stamina)

	Roundify(Gui.Inventory.InventoryFrame)
	ABorder(Gui.Inventory.InventoryFrame)
	for _, v in pairs(Gui.Inventory.InventoryFrame.Slots:GetChildren()) do
		Roundify(v)
		ABorder(v)
		for _, a in pairs(v.SlotDisplay:GetChildren()) do
			Roundify(a)
			ABorder(a)
		end
	end
	Roundify(Gui.Inventory.InventoryFrame.Description)
	Roundify(Gui.Inventory.InventoryFrame.RightClick)
	ABorder(Gui.Inventory.InventoryFrame.Description)
	ABorder(Gui.Inventory.InventoryFrame.RightClick)
	for _, v in pairs(Gui.Inventory.InventoryFrame:GetChildren()) do
		if v:IsA('ImageButton') then
			Roundify(v)
			ABorder(v)
		end
	end
	Gui.Inventory.InventoryFrame.UtilitySlots.BorderSizePixel = 0
	for _, v in pairs(Gui.Inventory.InventoryFrame.UtilitySlots:GetChildren()) do
		Roundify(v)
		ABorder(v)
	end
	Roundify(Gui.Inventory.InventoryFrame.Options)
	Roundify(Gui.Inventory.InventoryFrame.Skins)
	ABorder(Gui.Inventory.InventoryFrame.Options)
	ABorder(Gui.Inventory.InventoryFrame.Skins)
	Roundify(Gui.Inventory.InventoryFrame.BackFrame)
	ABorder(Gui.Inventory.InventoryFrame.BackFrame)

	Roundify(Gui.Inventory.WeaponSkins)
	ABorder(Gui.Inventory.WeaponSkins)
	Roundify(Gui.Inventory.WeaponSkins.Close)
	Roundify(Gui.Inventory.WeaponSkins.Back)
	ABorder(Gui.Inventory.WeaponSkins.Close)
	ABorder(Gui.Inventory.WeaponSkins.Back)

	for _, v in pairs(Gui.Inventory.WeaponSkins:GetChildren()) do
		if string.sub(v.Name, 1, 5) == 'Slots' then
			for _, a in pairs(v:GetChildren()) do
				a.Border.Visible = false
				Roundify(a)
				Border(a, a.BorderColor3, 0)
				Roundify(a.Primary)
				Roundify(a.Secondary)
			end
		end
	end

	for _, v in pairs(Gui.VehicleInterface:GetChildren()) do
		if v:IsA('SurfaceGui') then
			Roundify(v.Icon, true)
			ABorder(v.Icon)
		end
	end

	if Gui:FindFirstChild('CharacterCreation') then
		local Char = Gui.CharacterCreation
		Roundify(Char.Details)
		ABorder(Char.Details)
		Char.Sliders.ScrollBarThickness = 0
		Char.Sliders.Size = UDim2.new(0, 201, 0, 285)

		local Frame = Instance.new('Frame')
		if Char:FindFirstChild('CustomFrame') then Char.CustomFrame:Destroy() end
		Frame.Name = 'CustomFrame'
		Frame.Parent = Char
		Frame.Size = Char.Sliders.Size
		Frame.BackgroundColor3 = Char.Sliders.BackgroundColor3
		Frame.BorderColor3 = Char.Sliders.BorderColor3
		Frame.BorderSizePixel = Char.Sliders.BorderSizePixel
		Frame.Position = Char.Sliders.Position
		Frame.BackgroundTransparency = 0.3
		Frame.ZIndex = 0
		Roundify(Frame)
		ABorder(Frame)
		Char.Sliders.BackgroundTransparency = 1

		for _, v in pairs(Char.Sliders:GetChildren()) do
			if v:IsA('Frame') then
				Roundify(v.Bar)
				ABorder(v.Bar)
				Roundify(v.Bar.Slider)
				v.Bar.Slider.BorderColor3 = Color3.new()
				ABorder(v.Bar.Slider)
				v.Bar.Slider.Text = ''
			elseif v:IsA('TextButton') and v:FindFirstChild('Box') then
				Roundify(v.Box)
				ABorder(v.Box)
			elseif v.Name == 'Region' then
				Roundify(v.N)
				Roundify(v.S)
				Roundify(v.E)
				Roundify(v.W)
				Roundify(v.Any)
				ABorder(v.N)
				ABorder(v.S)
				ABorder(v.E)
				ABorder(v.W)
				ABorder(v.Any)
			elseif v:IsA('ImageButton') then
				Roundify(v)
				ABorder(v)
			end
		end

		Roundify(Char.Store)
		ABorder(Char.Store)
		Roundify(Char.Store.Label)
		ABorder(Char.Store.Label)
		Roundify(Char.Store.Close)
		ABorder(Char.Store.Close)

		Roundify(Char.Add)
		ABorder(Char.Add)
		Roundify(Char.Last)
		ABorder(Char.Last)
		Char.Last.Size = UDim2.new(0, 201, 0, 25)
		Char.Add.Size = UDim2.new(0, 201, 0, 25)
		Char.Spawn.Size = UDim2.new(0, 201, 0, 50)
		Roundify(Char.Spawn)
		ABorder(Char.Spawn)
		Roundify(Char.Info)
		ABorder(Char.Info)
		Char.Border.Visible = false
		Char.Sliders:GetPropertyChangedSignal('Visible'):Connect(function()
			Frame.Visible = Char.Sliders.Visible
		end)
	end
end

Gui.ChildAdded:Connect(function(child)
	if child.Name == 'CharacterCreation' then
		wait(0.3)
		Load()
	elseif child.Name == 'VehicleHUD' then
		local Custom = child.CustomHUD
		local Stats = child.Stats
		local Veh = child.target.Value
		local Connections = {}
		local function AddConnection(Connection, Callback)
			Connection = Connection:Connect(Callback)
			table.insert(Connections, Connection)
			return Connection
		end

		Custom.VehicleName.Text = Veh.Name

		repeat wait() until Stats:FindFirstChild('Hull') and Stats:FindFirstChild('Engine') and Stats:FindFirstChild('Tank') and Stats:FindFirstChild('Armor') and Custom:FindFirstChild('Fuel')

		AddConnection(Veh.Stats.Fuel:GetPropertyChangedSignal('Value'), function()
			Custom.Fuel.Bar.Size = UDim2.new(1, 0, Veh.Stats.Fuel.Value / Veh.Stats.Fuel.Max.Value, 0)
		end)

		if Stats.Hull.BackgroundColor3 == Color3.fromRGB(0, 153, 0) then
			Custom.Stats.Hull.TextColor3 = Color3.fromRGB(0, 255, 100)
		elseif Stats.Hull.BackgroundColor3 == Color3.fromRGB(153, 153, 0) then
			Custom.Stats.Hull.TextColor3 = Color3.fromRGB(200, 200, 50)
		elseif Stats.Hull.BackgroundColor3 == Color3.fromRGB(153, 102, 0) then
			Custom.Stats.Hull.TextColor3 = Color3.fromRGB(200, 100, 25)
		elseif Stats.Hull.BackgroundColor3 == Color3.fromRGB(153, 0, 0) then
			Custom.Stats.Hull.TextColor3 = Color3.fromRGB(255, 65, 65)
		end
		Stats.Hull:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
			if Stats.Hull.BackgroundColor3 == Color3.fromRGB(0, 153, 0) then
				Custom.Stats.Hull.TextColor3 = Color3.fromRGB(0, 255, 100)
			elseif Stats.Hull.BackgroundColor3 == Color3.fromRGB(153, 153, 0) then
				Custom.Stats.Hull.TextColor3 = Color3.fromRGB(200, 200, 50)
			elseif Stats.Hull.BackgroundColor3 == Color3.fromRGB(153, 102, 0) then
				Custom.Stats.Hull.TextColor3 = Color3.fromRGB(200, 100, 25)
			elseif Stats.Hull.BackgroundColor3 == Color3.fromRGB(153, 0, 0) then
				Custom.Stats.Hull.TextColor3 = Color3.fromRGB(255, 65, 65)
			end
		end)

		if Stats.Engine.BackgroundColor3 == Color3.fromRGB(0, 153, 0) then
			Custom.Stats.Engine.TextColor3 = Color3.fromRGB(0, 255, 100)
		elseif Stats.Engine.BackgroundColor3 == Color3.fromRGB(153, 153, 0) then
			Custom.Stats.Engine.TextColor3 = Color3.fromRGB(200, 200, 50)
		elseif Stats.Engine.BackgroundColor3 == Color3.fromRGB(153, 102, 0) then
			Custom.Stats.Engine.TextColor3 = Color3.fromRGB(200, 100, 25)
		elseif Stats.Engine.BackgroundColor3 == Color3.fromRGB(153, 0, 0) then
			Custom.Stats.Engine.TextColor3 = Color3.fromRGB(255, 65, 65)
		end
		Stats.Engine:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
			if Stats.Engine.BackgroundColor3 == Color3.fromRGB(0, 153, 0) then
				Custom.Stats.Engine.TextColor3 = Color3.fromRGB(0, 255, 100)
			elseif Stats.Engine.BackgroundColor3 == Color3.fromRGB(153, 153, 0) then
				Custom.Stats.Engine.TextColor3 = Color3.fromRGB(200, 200, 50)
			elseif Stats.Engine.BackgroundColor3 == Color3.fromRGB(153, 102, 0) then
				Custom.Stats.Engine.TextColor3 = Color3.fromRGB(200, 100, 25)
			elseif Stats.Engine.BackgroundColor3 == Color3.fromRGB(153, 0, 0) then
				Custom.Stats.Engine.TextColor3 = Color3.fromRGB(255, 65, 65)
			end
		end)

		if Stats.Tank.BackgroundColor3 == Color3.fromRGB(0, 153, 0) then
			Custom.Stats.Tank.TextColor3 = Color3.fromRGB(0, 255, 100)
		elseif Stats.Tank.BackgroundColor3 == Color3.fromRGB(153, 153, 0) then
			Custom.Stats.Tank.TextColor3 = Color3.fromRGB(200, 200, 50)
		elseif Stats.Tank.BackgroundColor3 == Color3.fromRGB(153, 102, 0) then
			Custom.Stats.Tank.TextColor3 = Color3.fromRGB(200, 100, 25)
		elseif Stats.Tank.BackgroundColor3 == Color3.fromRGB(153, 0, 0) then
			Custom.Stats.Tank.TextColor3 = Color3.fromRGB(255, 65, 65)
		end
		Stats.Tank:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
			if Stats.Tank.BackgroundColor3 == Color3.fromRGB(0, 153, 0) then
				Custom.Stats.Tank.TextColor3 = Color3.fromRGB(0, 255, 100)
			elseif Stats.Tank.BackgroundColor3 == Color3.fromRGB(153, 153, 0) then
				Custom.Stats.Tank.TextColor3 = Color3.fromRGB(200, 200, 50)
			elseif Stats.Tank.BackgroundColor3 == Color3.fromRGB(153, 102, 0) then
				Custom.Stats.Tank.TextColor3 = Color3.fromRGB(200, 100, 25)
			elseif Stats.Tank.BackgroundColor3 == Color3.fromRGB(153, 0, 0) then
				Custom.Stats.Tank.TextColor3 = Color3.fromRGB(255, 65, 65)
			end
		end)

		if Stats.Armor.BackgroundColor3 == Color3.fromRGB(0, 153, 0) then
			Custom.Stats.Armor.TextColor3 = Color3.fromRGB(0, 255, 100)
		elseif Stats.Armor.BackgroundColor3 == Color3.fromRGB(153, 153, 0) then
			Custom.Stats.Armor.TextColor3 = Color3.fromRGB(200, 200, 50)
		elseif Stats.Armor.BackgroundColor3 == Color3.fromRGB(153, 102, 0) then
			Custom.Stats.Armor.TextColor3 = Color3.fromRGB(200, 100, 25)
		elseif Stats.Armor.BackgroundColor3 == Color3.fromRGB(153, 0, 0) then
			Custom.Stats.Armor.TextColor3 = Color3.fromRGB(255, 65, 65)
		end
		Stats.Armor:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
			if Stats.Armor.BackgroundColor3 == Color3.fromRGB(0, 153, 0) then
				Custom.Stats.Armor.TextColor3 = Color3.fromRGB(0, 255, 100)
			elseif Stats.Armor.BackgroundColor3 == Color3.fromRGB(153, 153, 0) then
				Custom.Stats.Armor.TextColor3 = Color3.fromRGB(200, 200, 50)
			elseif Stats.Armor.BackgroundColor3 == Color3.fromRGB(153, 102, 0) then
				Custom.Stats.Armor.TextColor3 = Color3.fromRGB(200, 100, 25)
			elseif Stats.Armor.BackgroundColor3 == Color3.fromRGB(153, 0, 0) then
				Custom.Stats.Armor.TextColor3 = Color3.fromRGB(255, 65, 65)
			end
		end)

		if Veh.Name == 'Bicycle' then
			Custom.Stats.Armor.TextColor3 = Color3.fromRGB(50, 50, 50)
			Custom.Stats.Tank.TextColor3 = Color3.fromRGB(50, 50, 50)
			Custom.Stats.Engine.TextColor3 = Color3.fromRGB(50, 50, 50)
		end

		Stats.Speed:GetPropertyChangedSignal('Text'):Connect(function()
			Custom.Speed.SpeedText.Text = Stats.Speed.Text
			local SpeedV = string.gsub(Stats.Speed.Text, ' km/h', '')
			SpeedV = tonumber(SpeedV)
			local Size = SpeedV / Veh.Stats.MaxSpeed.Value
			Size = math.clamp(Size, 0, 1)
			game:GetService('TweenService'):Create(Custom.Speed.SpeedBar, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = UDim2.new(Size, 0, 1, 0)}):Play()
		end)
		Custom.Speed.SpeedBar.Size = UDim2.new(0, 0, 1, 0)

		child.Destroying:Connect(function()
			for _, v in pairs(Connections) do
				v:Disconnect()
			end
		end)
	end
end)

Load()