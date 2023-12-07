local InputService = game:GetService('UserInputService')
local RunService = game:GetService('RunService')
local Workspace = game:GetService('Workspace')
local Players = game:GetService('Players')
local Lighting = game:GetService('Lighting')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Client = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = Client:GetMouse()

return function(library, HttpGet, QTween, LoadInfo, Tabs, Sections, Notify, IsDead, TargetObscured, GetHealth, GetMaxHealth)
	local AyarumInfo = Instance.new('ScreenGui')
	local Holder = Instance.new('Frame')
	local HolderLayout = Instance.new('UIGridLayout')

	AyarumInfo.Name = 'AyarumInfo'
	AyarumInfo.Parent = game.Players.LocalPlayer:WaitForChild('PlayerGui')
	AyarumInfo.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	AyarumInfo.DisplayOrder = 200
	AyarumInfo.ResetOnSpawn = false
	AyarumInfo.Enabled = false

	Holder.Name = 'Holder'
	Holder.Parent = AyarumInfo
	Holder.AnchorPoint = Vector2.new(1, 0)
	Holder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Holder.BackgroundTransparency = 1.000
	Holder.Position = UDim2.new(1, -10, 0, 0)
	Holder.Size = UDim2.new(0, 200, 1, 0)

	HolderLayout.Name = 'HolderLayout'
	HolderLayout.Parent = Holder
	HolderLayout.FillDirection = Enum.FillDirection.Vertical
	HolderLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	HolderLayout.SortOrder = Enum.SortOrder.LayoutOrder
	HolderLayout.CellPadding = UDim2.new(0, 0, 0, 0)
	HolderLayout.CellSize = UDim2.new(1, 0, 0, 20)

	local function AddBuffInfo(Info, Round)
		local BuffInfo = Instance.new('TextLabel')
		local BuffStroke = Instance.new('UIStroke')

		BuffInfo.Name = 'BuffInfo'
		BuffInfo.Parent = Holder
		BuffInfo.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		BuffInfo.BackgroundTransparency = 1.000
		BuffInfo.LayoutOrder = Round
		BuffInfo.Size = UDim2.new(0, 200, 0, 50)
		BuffInfo.Font = Enum.Font.SourceSans
		BuffInfo.Text = 'Round ' .. tostring(Round) .. ' - ' .. Info
		BuffInfo.TextColor3 = Color3.fromRGB(255, 255, 255)
		BuffInfo.TextSize = 16.000
		BuffInfo.TextXAlignment = Enum.TextXAlignment.Right

		BuffStroke.Name = 'BuffStroke'
		BuffStroke.Parent = BuffInfo

		return BuffInfo
	end

	local WalkSpeedVal = 16
	local ReloadSpeed = 200
	local FireRateVal = 0.8
	local KillAuraSpeed = 0.1
	local function CheckChar(Char)
		Char:WaitForChild('Humanoid')
		library:AddConnection(Char.Humanoid:GetPropertyChangedSignal('WalkSpeed'), function()
			if Char.Humanoid.WalkSpeed < WalkSpeedVal then
				Char.Humanoid.WalkSpeed = WalkSpeedVal
			end
		end)
		if library.flags['reloadMod'] then
			Char:WaitForChild('CharStats'):WaitForChild('ReloadBuffs')
			local Val = Client.Character.CharStats.ReloadBuffs:FindFirstChild('AyarumBuff') or Instance.new('NumberValue')
			Val.Name = 'AyarumBuff'
			Val.Parent = Client.Character.CharStats.ReloadBuffs
			Val.Value = ReloadSpeed
		end
		if library.flags['firerateMod'] then
			Char:WaitForChild('CharStats'):WaitForChild('ShootBuffs')
			local Val = Client.Character.CharStats.ShootBuffs:FindFirstChild('AyarumBuff') or Instance.new('NumberValue')
			Val.Name = 'AyarumBuff'
			Val.Parent = Client.Character.CharStats.ShootBuffs
			Val.Value = FireRateVal
		end
	end

	if Client.Character then
		CheckChar(Client.Character)
	end
	library:AddConnection(Client.CharacterAdded, function()
		CheckChar(Client.Character)
	end)

	local ChamsSettings = {
		Color = Color3.fromRGB(150, 150, 150),
		OutlineColor = Color3.fromRGB(255, 65, 65),
		Transparency = 0.8,
		OutlineTransparency = 0,
		HealthColored = false
	}

	local function UpdateChamFromHealth(Char, Cham)
		local HealthPercent = GetHealth(Char, true) / GetMaxHealth(Char, true)
		local Color = Color3.new(1 - HealthPercent, HealthPercent, 0)
		Cham.FillColor = Color
		Cham.OutlineColor = Color
	end

	local function DrawZombieCham(Zombie)
		spawn(function()
			local Cham = Instance.new('Highlight')
			Cham.Name = 'AyarumCham'
			Cham.Enabled = true
			Cham.FillColor = ChamsSettings.Color
			Cham.FillTransparency = ChamsSettings.Transparency
			Cham.OutlineColor = ChamsSettings.OutlineColor
			Cham.OutlineTransparency = ChamsSettings.OutlineTransparency
			Cham.Parent = Zombie

			local DiedFunction
			local HealthFunction
			Zombie:WaitForChild('Humanoid')
			DiedFunction = Zombie.Humanoid.Died:Connect(function()
				Cham:Destroy()
				DiedFunction:Disconnect()
				HealthFunction:Disconnect()
			end)
			HealthFunction = Zombie.Humanoid.HealthChanged:Connect(function()
				if ChamsSettings.HealthColored then
					UpdateChamFromHealth(Zombie, Cham)
				end
			end)
			if ChamsSettings.HealthColored then
				UpdateChamFromHealth(Zombie, Cham)
			end
		end)
	end

	local function UpdateProperties()
		for _, v in pairs(Workspace.Ignore.Zombies:GetChildren()) do
			local Cham = v:FindFirstChild('AyarumCham')
			if not Cham then continue end
			Cham.FillTransparency = ChamsSettings.Transparency
			Cham.OutlineTransparency = ChamsSettings.OutlineTransparency
			if ChamsSettings.HealthColored then
				UpdateChamFromHealth(v, Cham)
			else
				Cham.FillColor = ChamsSettings.Color
				Cham.OutlineColor = ChamsSettings.OutlineColor
			end
		end
	end

	library:AddConnection(Workspace.Ignore.Zombies.ChildAdded, function(child)
		if library.flags['Zombie Chams'] then
			DrawZombieCham(child)
		end
	end)

	local function PerfectAccuracy()
		for _, v in pairs(ReplicatedStorage.Framework.Guns:GetChildren()) do
			local Module = require(v.Module.Settings)
			Module.SPREAD.DEFUALT = 0
			Module.SPREAD.MIN = 0
			Module.SPREAD.MAX = 0
			Module.SPREAD.WALK_ADDITION = 0
		end
	end

	local RecoilGlobal = Instance.new('BoolValue')
	RecoilGlobal.Value = false
	for _, v in pairs(ReplicatedStorage.Framework.Guns:GetChildren()) do
		local Module = require(v.Module.Settings)
		for k, a in pairs(Module.CAMERA_RECOIL) do
			local OldFunc = a
			Module.CAMERA_RECOIL[k] = function()
				if RecoilGlobal.Value == true then
					return Vector3.new(0, 0, 0)
				else
					return OldFunc()
				end
			end
		end
	end

	local RecoilRemoved = false
	local function NoRecoil()
		RecoilGlobal.Value = true
		if not RecoilRemoved then
			library:AddConnection(RunService.RenderStepped, function()
				if Client.Character then
					for _, v in pairs(Client.Character.CharStats.GunInventory:GetChildren()) do
						for _, a in pairs({'Underbarrel', 'Sight'}) do
							v:SetAttribute(a, '')
						end
					end
				end
			end)
		end
		RecoilRemoved = true
	end

	local BoxESPRound = 5
	local AutoCollectRound = 10
	local ChamsRound = 25
	local AccuracyRound = 30
	local NoRecoilRound = 35
	local KillAuraRound = 40
	local KillAuraBuffRound = 45

	local SpeedColaGot
	local SpeedColaBuff1 = 5
	local SpeedColaBuff2 = 15
	local SpeedColaBuff3 = 35
	local DoubleTapGot
	local DoubleTapBuff1 = 30

	local BoxESPInfo = AddBuffInfo('Mystery Box ESP Enabled', BoxESPRound)
	local AutoCollectInfo = AddBuffInfo('Auto Collect Powerups Enabled', AutoCollectRound)
	local ChamsInfo = AddBuffInfo('Zombie Chams Enabled', ChamsRound)
	local AccuracyInfo = AddBuffInfo('Perfect Accuracy Enabled', AccuracyRound)
	local NoRecoilInfo = AddBuffInfo('No Recoil Enabled', NoRecoilRound)
	local KillAuraInfo = AddBuffInfo('Defensive Aura Enabled', KillAuraRound)
	local KillAuraBuffInfo = AddBuffInfo('Defensive Aura Buff', KillAuraBuffRound)
	local ReloadInfo1
	local WalkSpeedInfo1
	local ReloadInfo2
	local FireRateInfo

	library:AddConnection(ReplicatedStorage.MapSettings.RoundNumber:GetPropertyChangedSignal('Value'), function()
		if not library.flags['Modded Gameplay'] then return end
		local Round = ReplicatedStorage.MapSettings.RoundNumber.Value
		if DoubleTapGot ~= nil and Round == DoubleTapGot + DoubleTapBuff1 then
			Notify('[Modded Gameplay Info]\nDouble Tap Aquired ' .. tostring(DoubleTapBuff1) .. ' Rounds Ago, FireRate Increased')
			FireRateInfo.TextColor3 = Color3.fromRGB(0, 255, 100)
			library.options['firerateMod']:SetState(true)
			library.options['FireRate Modifier']:SetValue(80)
		end
		if SpeedColaGot ~= nil and Round == SpeedColaGot + SpeedColaBuff1 then
			Notify('[Modded Gameplay Info]\nSpeed Cola Aquired ' .. tostring(SpeedColaBuff1) .. ' Rounds Ago, Reload Speed Increased')
			ReloadInfo1.TextColor3 = Color3.fromRGB(0, 255, 100)
			library.options['reloadMod']:SetState(true)
			library.options['Choose Reload Speed']:SetValue('Fast')
		end
		if SpeedColaGot ~= nil and Round == SpeedColaGot + SpeedColaBuff2 then
			Notify('[Modded Gameplay Info]\nSpeed Cola Aquired ' .. tostring(SpeedColaBuff2) .. ' Rounds Ago, WalkSpeed Increased')
			WalkSpeedInfo1.TextColor3 = Color3.fromRGB(0, 255, 100)
			library.options['WalkSpeed']:SetValue(35)
		end
		if SpeedColaGot ~= nil and Round == SpeedColaGot + SpeedColaBuff3 then
			Notify('[Modded Gameplay Info]\nSpeed Cola Aquired ' .. tostring(SpeedColaBuff3) .. ' Rounds Ago, Reload Speed Increased')
			ReloadInfo2.TextColor3 = Color3.fromRGB(0, 255, 100)
			library.options['reloadMod']:SetState(true)
			library.options['Choose Reload Speed']:SetValue('Instant')
		end
		if Round == BoxESPRound then
			Notify('[Modded Gameplay Info]\nRound ' .. tostring(BoxESPRound) .. ' Reached, Mystery Box ESP Enabled')
			BoxESPInfo.TextColor3 = Color3.fromRGB(0, 255, 100)
			library.options['Mystery Box ESP']:SetState(true)
		end
		if Round == NoRecoilRound then
			Notify('[Modded Gameplay Info]\nRound ' .. tostring(NoRecoilRound) .. ' Reached, No Recoil Enabled')
			NoRecoilInfo.TextColor3 = Color3.fromRGB(0, 255, 100)
			NoRecoil()
		end
		if Round == KillAuraBuffRound then
			Notify('[Modded Gameplay Info]\nRound ' .. tostring(KillAuraBuffRound) .. ' Reached, Defensive Aura Buffed')
			KillAuraBuffInfo.TextColor3 = Color3.fromRGB(0, 255, 100)
			library.options['Kill Aura Delay']:SetValue(0)
		end
		if Round == KillAuraRound then
			Notify('[Modded Gameplay Info]\nRound ' .. tostring(KillAuraRound) .. ' Reached, Defensive Aura Enabled')
			KillAuraInfo.TextColor3 = Color3.fromRGB(0, 255, 100)
			library.options['Kill Aura']:SetState(true)
		end
		if Round == AutoCollectRound then
			Notify('[Modded Gameplay Info]\nRound ' .. tostring(AutoCollectRound) .. ' Reached, Auto-Collect Powerups Enabled')
			AutoCollectInfo.TextColor3 = Color3.fromRGB(0, 255, 100)
			library.options['collect']:SetState(true)
		end
		if Round == ChamsRound then
			Notify('[Modded Gameplay Info]\nRound ' .. tostring(ChamsRound) .. ' Reached, Zombie Chams Enabled')
			ChamsInfo.TextColor3 = Color3.fromRGB(0, 255, 100)
			library.options['Zombie Chams']:SetState(true)
			library.options['chamHealth']:SetState(true)
		end
		if Round == AccuracyRound then
			Notify('[Modded Gameplay Info]\nRound ' .. tostring(AccuracyRound) .. ' Reached, Perfect Accuracy Enabled')
			AccuracyInfo.TextColor3 = Color3.fromRGB(0, 255, 100)
			PerfectAccuracy()
		end
	end)

	spawn(function()
		while wait(2) do
			if library.flags['Modded Gameplay'] and Client.Character and Client.Character.CharStats.Perks then
				if Client.Character.CharStats.Perks:FindFirstChild('SpeedCola') and library.flags['WalkSpeed'] ~= 25 and SpeedColaGot == nil then
					Notify('[Modded Gameplay Info]\nSpeed Cola Aquired, WalkSpeed Increased')
					SpeedColaGot = ReplicatedStorage.MapSettings.RoundNumber.Value
					ReloadInfo1 = AddBuffInfo('Reload Speed Increase', SpeedColaBuff1 + SpeedColaGot)
					WalkSpeedInfo1 = AddBuffInfo('WalkSpeed Increase', SpeedColaBuff2 + SpeedColaGot)
					ReloadInfo2 = AddBuffInfo('Reload Speed Increase', SpeedColaBuff3 + SpeedColaGot)
					library.options['WalkSpeed']:SetValue(25)
				end
				if Client.Character.CharStats.Perks:FindFirstChild('DoubleTap') and not Client.Character.CharStats.ShootBuffs:FindFirstChild('AyarumBuff') and DoubleTapGot == nil then
					DoubleTapGot = ReplicatedStorage.MapSettings.RoundNumber.Value
					FireRateInfo = AddBuffInfo('FireRate Increase', DoubleTapBuff1 + DoubleTapGot)
				end
			end
		end
	end)

	local SilentAimFOV = {
		Size = 90,
		Color = Color3.fromRGB(255, 20, 20),
		Transparency = 0,
		Sides = 60,
		Thickness = 2,
		Filled = false
	}

	local SilentAimFOVCircle = Drawing.new('Circle')
	SilentAimFOVCircle.ZIndex = 2
	SilentAimFOVCircle.Visible = false
	library:AddConnection(RunService.RenderStepped, function()
		SilentAimFOVCircle.Transparency = 1 - SilentAimFOV.Transparency
		SilentAimFOVCircle.Color = SilentAimFOV.Color
		SilentAimFOVCircle.Thickness = SilentAimFOV.Thickness
		SilentAimFOVCircle.NumSides = SilentAimFOV.Sides
		SilentAimFOVCircle.Radius = SilentAimFOV.Size
		SilentAimFOVCircle.Filled = SilentAimFOV.Filled
		SilentAimFOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
	end)

	local BodyPart
	local function GetClosestHead()
		local Found
		if IsDead(Client) then
			BodyPart = nil
			return
		end
		local ClosestDistance = math.huge
		for _, v in pairs(Workspace.Ignore.Zombies:GetChildren()) do
			if IsDead(v, true) or not v:FindFirstChild('Head') then continue end
			local Part = v.Head
			if TargetObscured(Part.Position, v, Workspace.Ignore, Workspace._Barriers, Workspace.Lobby, Workspace._Traps, Workspace._WallBuys) then continue end
			local Distance = (Part.Position - Client.Character.Head.Position).Magnitude
			local Vector, OnScreen = Camera:WorldToScreenPoint(Part.Position)

			if not OnScreen then continue end
			local VectorDistance = (Vector2.new(InputService:GetMouseLocation().X, InputService:GetMouseLocation().Y) - Vector2.new(Vector.X, Vector.Y)).Magnitude
			if Distance < ClosestDistance and VectorDistance < SilentAimFOV.Size then
				ClosestDistance = Distance
				BodyPart = Part
				Found = true
			end
		end
		if not Found then
			BodyPart = nil
		end
	end

	local OldNameCall
	OldNameCall = hookmetamethod(game, '__namecall', function(Self, ...)
		local Method = getnamecallmethod()
		local Args = {...}
		if Method == 'FireServer' and tostring(Self) == 'FireBullet' and library.flags['Silent Aim'] and BodyPart then
			Args[1] = BodyPart.Position
			return OldNameCall(Self, unpack(Args))
		end
		return OldNameCall(Self, ...)
	end)

	local function AddMysteryBoxESP()
		local Box = Workspace._MapComponents:FindFirstChild('MysteryBox')
		if not Box then return end
		local Cham = Box:FindFirstChild('AyarumCham') or Instance.new('Highlight')
		Cham.Name = 'AyarumCham'
		Cham.Enabled = library.flags['Mystery Box ESP']
		Cham.FillColor = Color3.fromRGB(255, 218, 55)
		Cham.FillTransparency = 0.8
		Cham.OutlineColor = Color3.fromRGB(255, 218, 55)
		Cham.OutlineTransparency = 0
		Cham.Parent = Box
	end

	Tabs.Main = library:AddTab('Michael\'s Zombies')

	Sections.Main = {
		Client = Tabs.Main:AddSection({text = 'Client', column = 1}),
		Misc = Tabs.Main:AddSection({text = 'Misc', column = 1}),
		Chams = Tabs.Main:AddSection({text = 'Chams', column = 2}),
		SilentAim = Tabs.Main:AddSection({text = 'Silent Aim', column = 2})
	}

	Sections.Main.Chams:AddToggle({text = 'Zombie Chams', state = false, callback = function(bool)
		if bool then
			for _, v in pairs(Workspace.Ignore.Zombies:GetChildren()) do
				DrawZombieCham(v)
			end
		else
			for _, v in pairs(Workspace.Ignore.Zombies:GetChildren()) do
				local Cham = v:FindFirstChild('AyarumCham')
				if Cham then Cham:Destroy() else continue end
			end
		end
	end})
	Sections.Main.Chams:AddDivider()
	Sections.Main.Chams:AddColor({text = 'Cham Fill Color', color = ChamsSettings.Color, callback = function(color)
		ChamsSettings.Color = color
		UpdateProperties()
	end})
	Sections.Main.Chams:AddSlider({text = 'Cham Fill Transparency', min = 0, max = 1, value = ChamsSettings.Transparency, float = 0.1, callback = function(v)
		ChamsSettings.Transparency = v
		UpdateProperties()
	end})
	Sections.Main.Chams:AddDivider()
	Sections.Main.Chams:AddColor({text = 'Cham Outline Color', color = ChamsSettings.OutlineColor, callback = function(color)
		ChamsSettings.OutlineColor = color
		UpdateProperties()
	end})
	Sections.Main.Chams:AddSlider({text = 'Cham Outline Transparency', min = 0, max = 1, value = ChamsSettings.OutlineTransparency, float = 0.1, callback = function(v)
		ChamsSettings.OutlineTransparency = v
		UpdateProperties()
	end})
	Sections.Main.Chams:AddDivider()
	Sections.Main.Chams:AddToggle({text = 'Health Based Coloring', flag = 'chamHealth', state = ChamsSettings.HealthColored, callback = function(bool)
		ChamsSettings.HealthColored = bool
		UpdateProperties()
	end})

	Sections.Main.Misc:AddToggle({text = 'Kill Aura', state = false, callback = function(bool)
		repeat
			if Client.Character then
				Client.Character.Remotes.Knifing:FireServer(true)
			end
			for _, v in pairs(Workspace.Ignore.Zombies:GetChildren()) do
				if v:FindFirstChild('Humanoid') and Client.Character and Client.Character:FindFirstChild('HumanoidRootPart') and v:FindFirstChild('HumanoidRootPart') and (Client.Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude < 25 then
					ReplicatedStorage.Framework.Remotes.KnifeHitbox:FireServer(v.Humanoid)
				end
			end
			if Client.Character then
				Client.Character.Remotes.Knifing:FireServer(false)
			end
			wait(KillAuraSpeed)
		until not library.flags['Kill Aura']
	end})
	Sections.Main.Misc:AddSlider({text = 'Kill Aura Delay', min = 0, max = 0.25, float = 0.05, suffix = 's', value = KillAuraSpeed, callback = function(v)
		KillAuraSpeed = v
	end})
	Sections.Main.Misc:AddDivider()
	Sections.Main.Misc:AddToggle({text = 'Auto-Collect Powerups', state = false, flag = 'collect', callback = function(bool)
		repeat
			for _, v in pairs(Workspace.Ignore._Powerups:GetChildren()) do
				if v:FindFirstChild('TouchInterest') then
					firetouchinterest(Client.Character.Head, v, 0)
				end
			end
			wait()
		until not library.flags['collect']
	end})
	Sections.Main.Misc:AddToggle({text = 'Mystery Box ESP', state = false, callback = AddMysteryBoxESP})
	Sections.Main.Misc:AddButton({text = 'Teleport to Mystery Box', callback = function()
		if Client.Character and Client.Character.HumanoidRootPart and Workspace._MapComponents:FindFirstChild('MysteryBox') then
			Client.Character.HumanoidRootPart.CFrame = Workspace._MapComponents.MysteryBox.Torso.CFrame
			Notify('Teleported to Mystery Box')
		else
			Notify(Client.Name .. '\'s Character Is Missing!')
		end
	end})
	Sections.Main.Misc:AddDivider()
	Sections.Main.Misc:AddToggle({text = 'Modded Gameplay', state = false, callback = function(bool)
		AyarumInfo.Enabled = bool
	end})

	Sections.Main.Client:AddSlider({text = 'WalkSpeed', min = 16, max = 300, value = 16, callback = function(value)
		WalkSpeedVal = value
		Client.Character.Humanoid.WalkSpeed = value
	end})
	Sections.Main.Client:AddDivider()
	Sections.Main.Client:AddToggle({text = 'Modify Reload Speed', flag = 'reloadMod', state = false, callback = function(bool)
		if not Client.Character then return end
		if bool then
			local Val = Client.Character.CharStats.ReloadBuffs:FindFirstChild('AyarumBuff') or Instance.new('NumberValue')
			Val.Name = 'AyarumBuff'
			Val.Parent = Client.Character.CharStats.ReloadBuffs
			Val.Value = ReloadSpeed
		else
			if Client.Character.CharStats.ReloadBuffs:FindFirstChild('AyarumBuff') then
				Client.Character.CharStats.ReloadBuffs.AyarumBuff:Destroy()
			end
		end
	end})
	Sections.Main.Client:AddList({text = 'Choose Reload Speed', values = {'Fast', 'Instant'}, value = 'Instant', callback = function(choice)
		if choice == 'Instant' then
			ReloadSpeed = 200
		else
			ReloadSpeed = 2
		end
		if Client.Character.CharStats.ReloadBuffs:FindFirstChild('AyarumBuff') then
			Client.Character.CharStats.ReloadBuffs.AyarumBuff.Value = ReloadSpeed
		end
	end})
	Sections.Main.Client:AddDivider()
	Sections.Main.Client:AddToggle({text = 'Modify FireRate', flag = 'firerateMod', state = false, callback = function(bool)
		if not Client.Character then return end
		if bool then
			local Val = Client.Character.CharStats.ShootBuffs:FindFirstChild('AyarumBuff') or Instance.new('NumberValue')
			Val.Name = 'AyarumBuff'
			Val.Parent = Client.Character.CharStats.ShootBuffs
			Val.Value = FireRateVal
		else
			if Client.Character.CharStats.ShootBuffs:FindFirstChild('AyarumBuff') then
				Client.Character.CharStats.ShootBuffs.AyarumBuff:Destroy()
			end
		end
	end})
	Sections.Main.Client:AddSlider({text = 'FireRate Modifier', min = 10, max = 150, float = 10, value = 80, suffix = '%', callback = function(v)
		FireRateVal = v / 100
		if Client.Character.CharStats.ShootBuffs:FindFirstChild('AyarumBuff') then
			Client.Character.CharStats.ShootBuffs.AyarumBuff.Value = FireRateVal
		end
	end})
	Sections.Main.Client:AddDivider()
	local Warning = library:AddWarning()
	Sections.Main.Client:AddButton({text = 'Perfect Accuracy', callback = function()
		Warning.text = 'Are you sure you want to enable Perfect Accuracy?\n\nThis cannot be disabled!'
		if Warning:Show() then
			PerfectAccuracy()
			Notify('Enabled Perfect Accuracy')
		end
	end})
	Sections.Main.Client:AddButton({text = 'No Recoil', callback = function()
		Warning.text = 'Are you sure you want to enable No Recoil?\n\nThis cannot be disabled,\nand all your attachments will be un-equipped to prevent bugs!'
		if Warning:Show() then
			NoRecoil()
			Notify('Enabled No Recoil')
		end
	end})

	Sections.Main.SilentAim:AddToggle({text = 'Enabled', flag = 'Silent Aim', state = false, callback = function(bool)
		if bool then
			RunService:BindToRenderStep('SilentAim', 200, GetClosestHead)
		else
			RunService:UnbindFromRenderStep('SilentAim')
		end
		SilentAimFOVCircle.Visible = bool
	end})
	Sections.Main.SilentAim:AddColor({text = 'Color', flag = 'sAimColor', color = SilentAimFOV.Color, callback = function(color)
		SilentAimFOV.Color = color
	end})
	Sections.Main.SilentAim:AddSlider({text = 'Size', flag = 'sAimSize', min = 50, max = 700, value = SilentAimFOV.Size, callback = function(v)
		SilentAimFOV.Size = v
	end})
	Sections.Main.SilentAim:AddSlider({text = 'Transparency', flag = 'sAimTrans', min = 0, max = 1, value = SilentAimFOV.Transparency, float = 0.05, callback = function(v)
		SilentAimFOV.Transparency = v
	end})
	Sections.Main.SilentAim:AddSlider({text = 'Sides', flag = 'sAimSides', min = 4, max = 100, value = SilentAimFOV.Sides, callback = function(v)
		SilentAimFOV.Sides = v
	end})
	Sections.Main.SilentAim:AddSlider({text = 'Thickness', flag = 'sAimThick', min = 1, max = 5, value = SilentAimFOV.Thickness, callback = function(v)
		SilentAimFOV.Thickness = v
	end})
	Sections.Main.SilentAim:AddToggle({text = 'Filled', flag = 'sAimFilled', state = SilentAimFOV.Filled, callback = function(bool)
		SilentAimFOV.Filled = bool
	end})
end