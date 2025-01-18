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
	local WalkSpeedOn = false
	local ReloadSpeed = 200
	local FireRateVal = 0.8
	local KillAuraSpeed = 0.1
	local function CheckChar(Char)
		Char:WaitForChild('Humanoid')
		library:AddConnection(Char.Humanoid:GetPropertyChangedSignal('WalkSpeed'), function()
			if Char.Humanoid.WalkSpeed ~= WalkSpeedVal and WalkSpeedOn then
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

			Zombie:WaitForChild('Humanoid')
			local DiedFunction
			local HealthFunction
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
				if Client.Character and Client.Character:FindFirstChild('CharStats') then
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

	local RoundBuffs = {
		BoxESP = {false, 5, function(Round)
			Notify('[Modded Gameplay Info]\nRound ' .. tostring(Round) .. ' Reached, Mystery Box ESP Enabled')
			library.options['Mystery Box ESP']:SetState(true)
		end, AddBuffInfo('Mystery Box ESP Enabled', 5)},
		AutoCollect = {false, 10, function(Round)
			Notify('[Modded Gameplay Info]\nRound ' .. tostring(Round) .. ' Reached, Auto-Collect Powerups Enabled')
			library.options['collect']:SetState(true)
		end, AddBuffInfo('Auto Collect Powerups Enabled', 10)},
		Chams = {false, 25, function(Round)
			Notify('[Modded Gameplay Info]\nRound ' .. tostring(Round) .. ' Reached, Zombie Chams Enabled')
			library.options['Zombie Chams']:SetState(true)
		end, AddBuffInfo('Zombie Chams Enabled', 25)},
		Accuracy = {false, 30, function(Round)
			Notify('[Modded Gameplay Info]\nRound ' .. tostring(Round) .. ' Reached, Perfect Accuracy Enabled')
			PerfectAccuracy()
		end, AddBuffInfo('Perfect Accuracy Enabled', 30)},
		NoRecoil = {false, 35, function(Round)
			Notify('[Modded Gameplay Info]\nRound ' .. tostring(Round) .. ' Reached, No Recoil Enabled')
			NoRecoil()
		end, AddBuffInfo('No Recoil Enabled', 35)},
		KillAura = {false, 40, function(Round)
			Notify('[Modded Gameplay Info]\nRound ' .. tostring(Round) .. ' Reached, Defensive Aura Enabled')
			library.options['Kill Aura']:SetState(true)
		end, AddBuffInfo('Defensive Aura Enabled', 40)},
		KillAuraBuff = {false, 45, function(Round)
			Notify('[Modded Gameplay Info]\nRound ' .. tostring(Round) .. ' Reached, Defensive Aura Buffed')
			library.options['Kill Aura Delay']:SetValue(0)
		end, AddBuffInfo('Defensive Aura Buff', 45)},
		SilentAim = {false, 50, function(Round)
			Notify('[Modded Gameplay Info]\nRound ' .. tostring(Round) .. ' Reached, Silent Aim Enabled')
			library.flags['Silent Aim']:SetState(true)
			library.flags['sAimSize']:SetValue(1000)
			library.flags['sAimTrans']:SetValue(1)
		end, AddBuffInfo('Silent Aim', 50)}
	}

	local SpeedColaGot
	local DoubleTapGot
	local StaminUpGot

	local SpeedColaBuffs = {
		Buff1 = {false, 5},
		Buff2 = {false, 15},
		Buff3 = {false, 35}
	}
	local DoubleTapBuffs = {
		Buff1 = {false, 30}
	}

	local SpeedColaInfo
	local ReloadInfo1
	local WalkSpeedInfo1
	local ReloadInfo2
	local DoubleTapInfo
	local FireRateInfo
	local StaminUpInfo

	local SpeedColaEarned = false
	local DoubleTapEarned = false
	local StaminUpEarned = false

	spawn(function()
		while wait() do
			if library.flags['Modded Gameplay'] and Client.Character and Client.Character.CharStats.Perks then
				local Round = ReplicatedStorage.MapSettings.RoundNumber.Value
				for _, Data in pairs(RoundBuffs) do
					if Round >= Data[2] then
						if not Data[1] then
							Data[1] = true
							Data[4].TextColor3 = Color3.fromRGB(0, 255, 100)
							spawn(function()
								Data[3](Data[2])
							end)
						end
					else
						Data[1] = false
						Data[4].TextColor3 = Color3.fromRGB(255, 255, 255)
					end
				end

				if Client.Character.CharStats.Perks:FindFirstChild('SpeedCola') then
					SpeedColaEarned = true
					if not SpeedColaGot then
						SpeedColaGot = Round
						Notify('[Modded Gameplay Info]\nSpeed Cola Aquired, Small WalkSpeed Increase')
						SpeedColaInfo = AddBuffInfo('Speed Cola Aquired', Round)
						ReloadInfo1 = AddBuffInfo('Reload Speed Increase', SpeedColaBuffs.Buff1[2] + SpeedColaGot)
						WalkSpeedInfo1 = AddBuffInfo('WalkSpeed Increase', SpeedColaBuffs.Buff2[2] + SpeedColaGot)
						ReloadInfo2 = AddBuffInfo('Reload Speed Increase', SpeedColaBuffs.Buff3[2] + SpeedColaGot)
					end
					SpeedColaInfo.TextColor3 = Color3.fromRGB(0, 255, 100)
				else
					SpeedColaEarned = false
					if SpeedColaInfo then
						SpeedColaInfo.TextColor3 = Color3.fromRGB(255, 255, 255)
					end
				end

				if Client.Character.CharStats.Perks:FindFirstChild('StaminUp') then
					StaminUpEarned = true
					if not StaminUpGot then
						StaminUpGot = Round
						Notify('[Modded Gameplay Info]\nStaminUp Aquired, WalkSpeed Increased')
						StaminUpInfo = AddBuffInfo('StaminUp Aquired', Round)
					end
					StaminUpInfo.TextColor3 = Color3.fromRGB(0, 255, 100)
				else
					StaminUpEarned = false
					if StaminUpInfo then
						StaminUpInfo.TextColor3 = Color3.fromRGB(255, 255, 255)
					end
				end

				if SpeedColaEarned or StaminUpEarned then
					local Target = 16
					if SpeedColaEarned then Target += 4 end
					if SpeedColaEarned and Round >= SpeedColaGot + SpeedColaBuffs.Buff2[2] then
						if not SpeedColaBuffs.Buff2[1] then
							SpeedColaBuffs.Buff2[1] = true
							Notify('[Modded Gameplay Info]\nSpeed Cola Aquired ' .. tostring(SpeedColaBuffs.Buff1[2]) .. ' Rounds Ago, WalkSpeed Increased')
							WalkSpeedInfo1.TextColor3 = Color3.fromRGB(0, 255, 100)
						end
						Target += 10
					else
						SpeedColaBuffs.Buff2[1] = false
						if WalkSpeedInfo1 then
							WalkSpeedInfo1.TextColor3 = Color3.fromRGB(255, 255, 255)
						end
					end
					if StaminUpEarned then Target += 10 end
					library.options['WalkSpeed']:SetValue(Target)
					library.options['Enable WalkSpeed']:SetState(true)
				else
					library.options['WalkSpeed']:SetValue(16)
					library.options['Enable WalkSpeed']:SetState(false)
					SpeedColaBuffs.Buff2[1] = false
					if WalkSpeedInfo1 then
						WalkSpeedInfo1.TextColor3 = Color3.fromRGB(255, 255, 255)
					end
				end

				if SpeedColaEarned then
					if not SpeedColaBuffs.Buff1[1] and Round >= SpeedColaGot + SpeedColaBuffs.Buff1[2] and Round < SpeedColaGot + SpeedColaBuffs.Buff3[2] then
						SpeedColaBuffs.Buff1[1] = true
						Notify('[Modded Gameplay Info]\nSpeed Cola Aquired ' .. tostring(SpeedColaBuffs.Buff1[2]) .. ' Rounds Ago, Reload Speed Increased')
						ReloadInfo1.TextColor3 = Color3.fromRGB(0, 255, 100)
						library.options['reloadMod']:SetState(true)
						library.options['Choose Reload Speed']:SetValue('Fast')
					elseif not SpeedColaBuffs.Buff3[1] and Round >= SpeedColaGot + SpeedColaBuffs.Buff3[2] then
						SpeedColaBuffs.Buff3[1] = true
						Notify('[Modded Gameplay Info]\nSpeed Cola Aquired ' .. tostring(SpeedColaBuffs.Buff3[2]) .. ' Rounds Ago, Reload Speed Increased')
						ReloadInfo2.TextColor3 = Color3.fromRGB(0, 255, 100)
						library.options['reloadMod']:SetState(true)
						library.options['Choose Reload Speed']:SetValue('Instant')
					end
				else
					if ReloadInfo1 and ReloadInfo2 then
						ReloadInfo1.TextColor3 = Color3.fromRGB(255, 255, 255)
						ReloadInfo2.TextColor3 = Color3.fromRGB(255, 255, 255)
					end
					library.options['reloadMod']:SetState(false)
				end

				if Client.Character.CharStats.Perks:FindFirstChild('DoubleTap') then
					DoubleTapEarned = true
					if not DoubleTapGot then
						DoubleTapGot = Round
						DoubleTapInfo = AddBuffInfo('DoubleTap Aquired', Round)
						FireRateInfo = AddBuffInfo('Firerate Increase', DoubleTapBuffs.Buff1[2] + DoubleTapGot)
					end
					DoubleTapInfo.TextColor3 = Color3.fromRGB(0, 255, 100)
				else
					DoubleTapEarned = false
					if DoubleTapInfo then
						DoubleTapInfo.TextColor3 = Color3.fromRGB(255, 255, 255)
					end
				end
				if DoubleTapEarned then
					if not DoubleTapBuffs.Buff1[1] and Round >= DoubleTapGot + DoubleTapBuffs.Buff1[2] then
						DoubleTapBuffs.Buff1[1] = true
						Notify('[Modded Gameplay Info]\nDouble Tap Aquired ' .. tostring(DoubleTapBuffs.Buff1[2]) .. ' Rounds Ago, FireRate Increased')
						FireRateInfo.TextColor3 = Color3.fromRGB(0, 255, 100)
						library.options['firerateMod']:SetState(true)
						library.options['FireRate Modifier']:SetValue(80)
					end
				else
					if FireRateInfo then
						FireRateInfo.TextColor3 = Color3.fromRGB(255, 255, 255)
					end
					library.options['firerateMod']:SetState(false)
				end
			else
				for _, Data in pairs(RoundBuffs) do
					Data[1] = false
				end
				for _, Data in pairs(SpeedColaBuffs) do
					Data[1] = false
				end
				for _, Data in pairs(DoubleTapBuffs) do
					Data[1] = false
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

	local GuiInset = game:GetService('GuiService'):GetGuiInset().Y

	if game.CoreGui:FindFirstChild('TobBarApp') then
		GuiInset = 58
	end

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
		SilentAimFOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + GuiInset)
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

	local MysteryBoxESP = false
	local PartsESP = false
	local function PartEsp(Part, Color, Bool)
		if not Part then return end
		local Cham = Part:FindFirstChild('AyarumCham') or Instance.new('Highlight')
		Cham.Name = 'AyarumCham'
		Cham.Enabled = Bool
		Cham.FillColor = Color
		Cham.FillTransparency = 0.8
		Cham.OutlineColor = Color
		Cham.OutlineTransparency = 0
		Cham.Parent = Part
	end

	local oldAimPercent
	local oldAimWeight
	local DisableAimAssist = false
	spawn(function()
		while wait(1) do
			if Client.Character and Client.Character:FindFirstChild('Framework') and Client.Character.Framework:FindFirstChild('WeaponHandlerClient') then
				local Module = Client.Character.Framework.WeaponHandlerClient.Modules.AimAssist
				Module = require(Module)

				if not oldAimPercent then
					oldAimPercent = Module.setAimToHeadPercentage
				end
				if not oldAimWeight then
					oldAimWeight = Module.setAimAssistWeight
				end

				if DisableAimAssist then
					Module.setAimToHeadPercentage(0)
					Module.setAimAssistWeight(0)
					Module.setAimToHeadPercentage = function()
						return
					end
					Module.setAimAssistWeight = function()
						return
					end
				else
					Module.setAimToHeadPercentage = oldAimPercent
					Module.setAimAssistWeight = oldAimWeight
				end
			end
		end
	end)

	Tabs.Main = library:AddTab('Michael\'s Zombies')

	Sections.Main = {
		Client = Tabs.Main:AddSection({text = 'Client', column = 1}),
		Chams = Tabs.Main:AddSection({text = 'Chams', column = 1}),
		SilentAim = Tabs.Main:AddSection({text = 'Silent Aim', column = 1}),
		Misc = Tabs.Main:AddSection({text = 'Misc', column = 1})
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
					ReplicatedStorage.Framework.Remotes.KnifeHitbox:FireServer(v)
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
	Sections.Main.Misc:AddToggle({text = 'Parts ESP', state = false, callback = function(bool)
		PartsESP = bool
		if PartsESP then
			while PartsESP do
				for _, v in pairs(Workspace._Parts:GetChildren()) do
					PartEsp(v, Color3.fromRGB(255, 65, 65), PartsESP)
				end
				wait(1)
			end
		else
			for _, v in pairs(Workspace._Parts:GetChildren()) do
				PartEsp(v, Color3.fromRGB(255, 65, 65), PartsESP)
			end
		end
	end})
	Sections.Main.Misc:AddToggle({text = 'Mystery Box ESP', state = false, callback = function(bool)
		if MysteryBoxESP == bool then return end
		MysteryBoxESP = bool
		if MysteryBoxESP then
			while MysteryBoxESP do
				PartEsp(Workspace._MapComponents:FindFirstChild('MysteryBox'), Color3.fromRGB(255, 218, 55), MysteryBoxESP)
				wait(1)
			end
		else
			PartEsp(Workspace._MapComponents:FindFirstChild('MysteryBox'), Color3.fromRGB(255, 218, 55), MysteryBoxESP)
		end
	end})
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

	Sections.Main.Client:AddToggle({text = 'Enable WalkSpeed', state = WalkSpeedOn, callback = function(bool)
		WalkSpeedOn = bool
		if WalkSpeedOn then
			Client.Character.Humanoid.WalkSpeed = WalkSpeedVal
		end
	end})
	Sections.Main.Client:AddSlider({text = 'WalkSpeed', min = 16, max = 300, value = 16, callback = function(value)
		WalkSpeedVal = value
		if WalkSpeedOn then
			Client.Character.Humanoid.WalkSpeed = WalkSpeedVal
		end
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
			ReloadSpeed = 1.5
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
	Sections.Main.Client:AddDivider()
	Sections.Main.Client:AddToggle({text = 'Disable Aim Assist', state = false, callback = function(bool)
			DisableAimAssist = bool
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
	Sections.Main.SilentAim:AddSlider({text = 'Size', flag = 'sAimSize', min = 50, max = 1000, value = SilentAimFOV.Size, callback = function(v)
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