if game.CoreGui:FindFirstChild('SpectateInfo') then
	game.CoreGui.SpectateInfo:Destroy()
end

local SpectateInfo = Instance.new("ScreenGui")
local SpectateInfo_2 = Instance.new("ImageLabel")
local Title = Instance.new("TextLabel")
local Holder = Instance.new("Frame")
local UIGridLayout = Instance.new("UIGridLayout")
local PlayerInfo = Instance.new("TextLabel")
local WeaponInfo = Instance.new("TextLabel")
local BackpackCombat = Instance.new("TextLabel")
local VitalsInfo = Instance.new("TextLabel")
local HealthInfo = Instance.new("TextLabel")
local DaysIsSpawned = Instance.new("TextLabel")
local KillsInfo = Instance.new("TextLabel")
local PerksInfo = Instance.new("TextLabel")

SpectateInfo.Name = "SpectateInfo"
SpectateInfo.Parent = game.CoreGui

SpectateInfo_2.Name = "SpectateInfo"
SpectateInfo_2.Parent = SpectateInfo
SpectateInfo_2.AnchorPoint = Vector2.new(0.5, 0)
SpectateInfo_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SpectateInfo_2.BackgroundTransparency = 1.000
SpectateInfo_2.Position = UDim2.new(0.5, 0, 0, -236)
SpectateInfo_2.Size = UDim2.new(0, 200, 0, 50)
SpectateInfo_2.Image = "rbxassetid://3570695787"
SpectateInfo_2.ImageColor3 = Color3.fromRGB(0, 0, 0)
SpectateInfo_2.ImageTransparency = 0.750
SpectateInfo_2.ScaleType = Enum.ScaleType.Slice
SpectateInfo_2.SliceCenter = Rect.new(100, 100, 100, 100)
SpectateInfo_2.SliceScale = 0.060
SpectateInfo_2.ImageTransparency = 1

Title.Name = "Title"
Title.Parent = SpectateInfo_2
Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1.000
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Font = Enum.Font.Nunito
Title.Text = "Spectate Info"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 30.000
Title.TextTransparency = 1

Holder.Name = "Holder"
Holder.Parent = SpectateInfo_2
Holder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Holder.BackgroundTransparency = 1.000
Holder.Position = UDim2.new(0, 30, 0, 30)
Holder.Size = UDim2.new(1, -60, 1, -30)

UIGridLayout.Parent = Holder
UIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIGridLayout.CellPadding = UDim2.new(0, 0, 0, 0)
UIGridLayout.CellSize = UDim2.new(0.5, 0, 0, 40)

PlayerInfo.Name = "PlayerInfo"
PlayerInfo.Parent = Holder
PlayerInfo.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
PlayerInfo.BackgroundTransparency = 1.000
PlayerInfo.LayoutOrder = 1
PlayerInfo.Size = UDim2.new(0.5, 0, 0, 35)
PlayerInfo.Font = Enum.Font.Nunito
PlayerInfo.Text = "Player Name: Apocplaayer\nPlayer Nickname: None"
PlayerInfo.TextColor3 = Color3.fromRGB(255, 255, 255)
PlayerInfo.TextSize = 18.000
PlayerInfo.TextXAlignment = Enum.TextXAlignment.Left
PlayerInfo.TextTransparency = 1

WeaponInfo.Name = "WeaponInfo"
WeaponInfo.Parent = Holder
WeaponInfo.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
WeaponInfo.BackgroundTransparency = 1.000
WeaponInfo.LayoutOrder = 2
WeaponInfo.Size = UDim2.new(0.5, 0, 0, 35)
WeaponInfo.Font = Enum.Font.Nunito
WeaponInfo.Text = "Primary Weapon: Hk21\nSecondary Weapon: G18"
WeaponInfo.TextColor3 = Color3.fromRGB(255, 255, 255)
WeaponInfo.TextSize = 18.000
WeaponInfo.TextXAlignment = Enum.TextXAlignment.Right
WeaponInfo.TextTransparency = 1

BackpackCombat.Name = "BackpackCombat"
BackpackCombat.Parent = Holder
BackpackCombat.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
BackpackCombat.BackgroundTransparency = 1.000
BackpackCombat.LayoutOrder = 3
BackpackCombat.Size = UDim2.new(0.5, 0, 0, 35)
BackpackCombat.Font = Enum.Font.Nunito
BackpackCombat.Text = "Backpack: MilitaryPackBlack\nIn Combat: No"
BackpackCombat.TextColor3 = Color3.fromRGB(255, 255, 255)
BackpackCombat.TextSize = 18.000
BackpackCombat.TextXAlignment = Enum.TextXAlignment.Left
BackpackCombat.TextTransparency = 1

VitalsInfo.Name = "VitalsInfo"
VitalsInfo.Parent = Holder
VitalsInfo.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
VitalsInfo.BackgroundTransparency = 1.000
VitalsInfo.LayoutOrder = 4
VitalsInfo.Rotation = 4.000
VitalsInfo.Size = UDim2.new(0.5, 0, 0, 35)
VitalsInfo.Font = Enum.Font.Nunito
VitalsInfo.Text = "Hunger: 100\nThirst: 100"
VitalsInfo.TextColor3 = Color3.fromRGB(255, 255, 255)
VitalsInfo.TextSize = 18.000
VitalsInfo.TextXAlignment = Enum.TextXAlignment.Right
VitalsInfo.TextTransparency = 1

HealthInfo.Name = "HealthInfo"
HealthInfo.Parent = Holder
HealthInfo.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
HealthInfo.BackgroundTransparency = 1.000
HealthInfo.LayoutOrder = 7
HealthInfo.Rotation = 6.000
HealthInfo.Size = UDim2.new(0.5, 0, 0, 35)
HealthInfo.Font = Enum.Font.Nunito
HealthInfo.Text = "Health: 100\nUsing Painkillers: Yes"
HealthInfo.TextColor3 = Color3.fromRGB(255, 255, 255)
HealthInfo.TextSize = 18.000
HealthInfo.TextXAlignment = Enum.TextXAlignment.Left
HealthInfo.TextTransparency = 1

DaysIsSpawned.Name = "DaysIsSpawned"
DaysIsSpawned.Parent = Holder
DaysIsSpawned.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
DaysIsSpawned.BackgroundTransparency = 1.000
DaysIsSpawned.LayoutOrder = 8
DaysIsSpawned.Size = UDim2.new(0.5, 0, 0, 35)
DaysIsSpawned.Font = Enum.Font.Nunito
DaysIsSpawned.Text = "Is Spawned: Yes\nDays: 13"
DaysIsSpawned.TextColor3 = Color3.fromRGB(255, 255, 255)
DaysIsSpawned.TextSize = 18.000
DaysIsSpawned.TextXAlignment = Enum.TextXAlignment.Right
DaysIsSpawned.TextTransparency = 1

KillsInfo.Name = "KillsInfo"
KillsInfo.Parent = Holder
KillsInfo.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
KillsInfo.BackgroundTransparency = 1.000
KillsInfo.LayoutOrder = 10
KillsInfo.Size = UDim2.new(0.5, 0, 0, 35)
KillsInfo.Font = Enum.Font.Nunito
KillsInfo.Text = "Kills: 93\nZombie Kills: 53"
KillsInfo.TextColor3 = Color3.fromRGB(255, 255, 255)
KillsInfo.TextSize = 18.000
KillsInfo.TextXAlignment = Enum.TextXAlignment.Right
KillsInfo.TextTransparency = 1

PerksInfo.Name = "PerksInfo"
PerksInfo.Parent = Holder
PerksInfo.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
PerksInfo.BackgroundTransparency = 1.000
PerksInfo.LayoutOrder = 9
PerksInfo.Size = UDim2.new(0.5, 0, 0, 35)
PerksInfo.Font = Enum.Font.Nunito
PerksInfo.Text = "First Perk: Ninja\nSecond Perk: None"
PerksInfo.TextColor3 = Color3.fromRGB(255, 255, 255)
PerksInfo.TextSize = 18.000
PerksInfo.TextXAlignment = Enum.TextXAlignment.Left
PerksInfo.TextTransparency = 1

local function Tween(Instance, Time, Properties)
	game:GetService('TweenService'):Create(Instance, TweenInfo.new(Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), Properties):Play()
end

local Connections = {}

local function AddConnection(Connection, Callback)
	local New = Connection:Connect(Callback)
	table.insert(Connections, New)
end

local Spectator = {}

local function FindItemFromID(Slot)
	if Slot.Value ~= 1 or not Slot:FindFirstChild('ObjectID') then return 'None' end
	local ObjectID = getrenv()._G.Deobfuscate(Slot.ObjectID.Value)
	for _, v in pairs(game.Lighting.LootDrops:GetChildren()) do
		if v:FindFirstChild('ObjectID') and getrenv()._G.Deobfuscate(v.ObjectID.Value) == ObjectID then
			return v.Name
		end
	end
	return 'None'
end

local Perks = {
	'Cardio',
	'Survivalist',
	'Vitality',
	'Ninja'
}

local function GetPerk(Val)
	if Val == 0 then return 'None' end
	return Perks[Val]
end

function Spectator:InfoPlayer(Player)
	for _, v in pairs(Connections) do
		v:Disconnect()
	end
	table.clear(Connections)
	for _, v in pairs(Holder:GetChildren()) do
		if v:IsA('TextLabel') then
			Tween(v, 0.5, {TextTransparency = 0})
		end
	end
	Tween(Title, 0.5, {TextTransparency = 0})
	Tween(SpectateInfo_2, 0.5, {Position = UDim2.new(0.5, 0, 0, 0), Size = UDim2.new(0, 500, 0, 200), ImageTransparency = 0.75})

	local Nick = Player.DisplayName ~= Player.Name and Player.DisplayName or 'None'
	PlayerInfo.Text = 'Player Name: ' .. Player.Name .. '\nPlayer Nickname: ' .. Nick
	WeaponInfo.Text = 'Primary Weapon: ' .. FindItemFromID(Player.playerstats.slots.slotprimary) .. '\nSecondary Weapon: ' .. FindItemFromID(Player.playerstats.slots.slotsecondary)
	local Combat = Player.playerstats.combat.Value == true and 'Yes' or 'No'
	BackpackCombat.Text = 'Backpack: ' .. FindItemFromID(Player.playerstats.slots.slotbackpack) .. '\nIn Combat: ' .. Combat
	VitalsInfo.Text = 'Hunger: ' .. tostring(Player.playerstats.Hunger.Value) .. '\nThirst: ' .. tostring(Player.playerstats.Thirst.Value)
	HealthInfo.Text = 'Health: ' .. tostring(Player.playerstats.Health.Value) .. '\nUsing Painkillers: Unknown'
	DaysIsSpawned.Text = 'Is Spawned: Unknown\nDays: ' .. tostring(Player.playerstats.Days.Value)
	PerksInfo.Text = 'First Perk: ' .. GetPerk(Player.playerstats.character.perk1.Value) .. '\nSecond Perk: ' .. GetPerk(Player.playerstats.character.perk2.Value)
	local Kills = 0
	for _, v in pairs(Player.playerstats.PlayerKill:GetChildren()) do
		Kills = Kills + v.Value
	end
	local ZKills = 0
	for _, v in pairs(Player.playerstats.ZombieKill:GetChildren()) do
		ZKills = ZKills + v.Value
	end
	KillsInfo.Text = 'Kills: ' .. tostring(Kills) .. '\nZombie Kills: ' .. tostring(ZKills)

	local function AddCharacterConnections(Char)
		local Painkillered = Char:WaitForChild('Humanoid'):FindFirstChild('DefenseMultiplier') and 'Yes' or 'No'
		HealthInfo.Text = 'Health: ' .. tostring(Char.Humanoid.Health) .. '\nUsing Painkillers: ' .. Painkillered
		local Spawned = Char:WaitForChild('IsSpawned').Value == true and 'Yes' or 'No'
		DaysIsSpawned.Text = 'Is Spawned: ' .. Spawned .. '\nDays: ' .. tostring(Player.playerstats.Days.Value)

		AddConnection(Char.Humanoid.ChildRemoved, function()
			local Painkillered = Char:WaitForChild('Humanoid'):FindFirstChild('DefenseMultiplier') and 'Yes' or 'No'
			HealthInfo.Text = 'Health: ' .. tostring(Char.Humanoid.Health) .. '\nUsing Painkillers: ' .. Painkillered
		end)
		AddConnection(Char.Humanoid.ChildAdded, function()
			local Painkillered = Char:WaitForChild('Humanoid'):FindFirstChild('DefenseMultiplier') and 'Yes' or 'No'
			HealthInfo.Text = 'Health: ' .. tostring(Char.Humanoid.Health) .. '\nUsing Painkillers: ' .. Painkillered
		end)
		AddConnection(Char.Humanoid:GetPropertyChangedSignal('Health'), function()
			local Painkillered = Char:WaitForChild('Humanoid'):FindFirstChild('DefenseMultiplier') and 'Yes' or 'No'
			HealthInfo.Text = 'Health: ' .. tostring(Char.Humanoid.Health) .. '\nUsing Painkillers: ' .. Painkillered
		end)
		AddConnection(Char:WaitForChild('IsSpawned'):GetPropertyChangedSignal('Value'), function()
			local Spawned = Char:WaitForChild('IsSpawned').Value == true and 'Yes' or 'No'
			DaysIsSpawned.Text = 'Is Spawned: ' .. Spawned .. '\nDays: ' .. tostring(Player.playerstats.Days.Value)
		end)
		AddConnection(Player.playerstats.Days:GetPropertyChangedSignal('Value'), function()
			local Spawned = Char:WaitForChild('IsSpawned').Value == true and 'Yes' or 'No'
			DaysIsSpawned.Text = 'Is Spawned: ' .. Spawned .. '\nDays: ' .. tostring(Player.playerstats.Days.Value)
		end)
	end

	if Player.Character then
		AddCharacterConnections(Player.Character)
	end

	AddConnection(Player.CharacterAdded, function()
		AddCharacterConnections(Player.Character)
	end)

	AddConnection(Player.playerstats.slots.slotprimary:GetPropertyChangedSignal('Value'), function()
		WeaponInfo.Text = 'Primary Weapon: ' .. FindItemFromID(Player.playerstats.slots.slotprimary) .. '\nSecondary Weapon: ' .. FindItemFromID(Player.playerstats.slots.slotsecondary)
	end)
	AddConnection(Player.playerstats.slots.slotsecondary:GetPropertyChangedSignal('Value'), function()
		WeaponInfo.Text = 'Primary Weapon: ' .. FindItemFromID(Player.playerstats.slots.slotprimary) .. '\nSecondary Weapon: ' .. FindItemFromID(Player.playerstats.slots.slotsecondary)
	end)
	AddConnection(Player.playerstats.slots.slotbackpack:GetPropertyChangedSignal('Value'), function()
		local Combat = Player.playerstats.combat.Value == true and 'Yes' or 'No'
		BackpackCombat.Text = 'Backpack: ' .. FindItemFromID(Player.playerstats.slots.slotbackpack) .. '\nIn Combat: ' .. Combat
	end)
	AddConnection(Player.playerstats.combat:GetPropertyChangedSignal('Value'), function()
		local Combat = Player.playerstats.combat.Value == true and 'Yes' or 'No'
		BackpackCombat.Text = 'Backpack: ' .. FindItemFromID(Player.playerstats.slots.slotbackpack) .. '\nIn Combat: ' .. Combat
	end)
	AddConnection(Player.playerstats.Hunger:GetPropertyChangedSignal('Value'), function()
		VitalsInfo.Text = 'Hunger: ' .. tostring(Player.playerstats.Hunger.Value) .. '\nThirst: ' .. tostring(Player.playerstats.Thirst.Value)
	end)
	AddConnection(Player.playerstats.Thirst:GetPropertyChangedSignal('Value'), function()
		VitalsInfo.Text = 'Hunger: ' .. tostring(Player.playerstats.Hunger.Value) .. '\nThirst: ' .. tostring(Player.playerstats.Thirst.Value)
	end)
	AddConnection(Player.playerstats.character.perk1:GetPropertyChangedSignal('Value'), function()
		PerksInfo.Text = 'First Perk: ' .. GetPerk(Player.playerstats.character.perk1.Value) .. '\nSecond Perk: ' .. GetPerk(Player.playerstats.character.perk2.Value)
	end)
	AddConnection(Player.playerstats.character.perk2:GetPropertyChangedSignal('Value'), function()
		PerksInfo.Text = 'First Perk: ' .. GetPerk(Player.playerstats.character.perk1.Value) .. '\nSecond Perk: ' .. GetPerk(Player.playerstats.character.perk2.Value)
	end)
	AddConnection(Player.playerstats.ZombieKill.Military:GetPropertyChangedSignal('Value'), function()
		local Kills = 0
		for _, v in pairs(Player.playerstats.PlayerKill:GetChildren()) do
			Kills = Kills + v.Value
		end
		local ZKills = 0
		for _, v in pairs(Player.playerstats.ZombieKill:GetChildren()) do
			ZKills = ZKills + v.Value
		end
		KillsInfo.Text = 'Kills: ' .. tostring(Kills) .. '\nZombie Kills: ' .. tostring(ZKills)
	end)
	AddConnection(Player.playerstats.ZombieKill.Civilian:GetPropertyChangedSignal('Value'), function()
		local Kills = 0
		for _, v in pairs(Player.playerstats.PlayerKill:GetChildren()) do
			Kills = Kills + v.Value
		end
		local ZKills = 0
		for _, v in pairs(Player.playerstats.ZombieKill:GetChildren()) do
			ZKills = ZKills + v.Value
		end
		KillsInfo.Text = 'Kills: ' .. tostring(Kills) .. '\nZombie Kills: ' .. tostring(ZKills)
	end)
	AddConnection(Player.playerstats.PlayerKill.Bandit:GetPropertyChangedSignal('Value'), function()
		local Kills = 0
		for _, v in pairs(Player.playerstats.PlayerKill:GetChildren()) do
			Kills = Kills + v.Value
		end
		local ZKills = 0
		for _, v in pairs(Player.playerstats.ZombieKill:GetChildren()) do
			ZKills = ZKills + v.Value
		end
		KillsInfo.Text = 'Kills: ' .. tostring(Kills) .. '\nZombie Kills: ' .. tostring(ZKills)
	end)
	AddConnection(Player.playerstats.PlayerKill.Aggressive:GetPropertyChangedSignal('Value'), function()
		local Kills = 0
		for _, v in pairs(Player.playerstats.PlayerKill:GetChildren()) do
			Kills = Kills + v.Value
		end
		local ZKills = 0
		for _, v in pairs(Player.playerstats.ZombieKill:GetChildren()) do
			ZKills = ZKills + v.Value
		end
		KillsInfo.Text = 'Kills: ' .. tostring(Kills) .. '\nZombie Kills: ' .. tostring(ZKills)
	end)
	AddConnection(Player.playerstats.PlayerKill.Defensive:GetPropertyChangedSignal('Value'), function()
		local Kills = 0
		for _, v in pairs(Player.playerstats.PlayerKill:GetChildren()) do
			Kills = Kills + v.Value
		end
		local ZKills = 0
		for _, v in pairs(Player.playerstats.ZombieKill:GetChildren()) do
			ZKills = ZKills + v.Value
		end
		KillsInfo.Text = 'Kills: ' .. tostring(Kills) .. '\nZombie Kills: ' .. tostring(ZKills)
	end)
end

function Spectator:RemoveInfo()
	for _, v in pairs(Connections) do
		v:Disconnect()
	end
	table.clear(Connections)
	for _, v in pairs(Holder:GetChildren()) do
		if v:IsA('TextLabel') then
			Tween(v, 0.5, {TextTransparency = 1})
		end
	end
	Tween(Title, 0.5, {TextTransparency = 1})
	Tween(SpectateInfo_2, 0.5, {Position = UDim2.new(0.5, 0, 0, -236), Size = UDim2.new(0, 200, 0, 50), ImageTransparency = 1})
end

return Spectator
