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
	local ToSave = {
		'Ammo',
		'Auto',
		'Bullets',
		'DMG',
		'EquipTime',
		'FireRate',
		'Rampup',
		'RecoilControl',
		'StoredAmmo',
		'Spread',
		'MaxSpread',
		'ReloadTime'
	}
	for _, v in pairs(ReplicatedStorage.Weapons:GetChildren()) do
		for _, a in pairs(v:GetChildren()) do
			if table.find(ToSave, a.Name) then
				local Save = Instance.new(a.ClassName)
				Save.Parent = a
				Save.Name = 'AyarumSave'
				Save.Value = a.Value
			end
		end
	end
	local ModVals = {
		['Ammo'] = 999,
		['StoredAmmo'] = 300,
		['Auto'] = true,
		['Bullets'] = 10,
		['DMG'] = 999,
		['EquipTime'] = 0.01,
		['FireRate'] = 0.015,
		['Rampup'] = 0.01,
		['RecoilControl'] = 0,
		['Spread'] = 0,
		['MaxSpread'] = 5,
		['ReloadTime'] = 0
	}

	library:AddConnection(Client.Character.Humanoid:GetPropertyChangedSignal('WalkSpeed'), function()
		if not library.loaded then return end
		if not IsDead(Client) and Client.Character and Client.Character:FindFirstChild('Humanoid') and library.flags['WalkSpeed'] then
			Client.Character.Humanoid.WalkSpeed = library.flags['Speed']
		end
	end)

	local BodyPart
	local function GetClosestHead()
		local Found
		if IsDead(Client) then
			BodyPart = nil
			return
		end
		local ClosestDistance = math.huge
		for _, v in pairs(Players:GetPlayers()) do
			if v == Client or (library.flags['SilentAimTeamCheck'] == true and v.Team == Client.Team) or IsDead(v) or not v.Character:FindFirstChild('Head') then continue end
			local Part = v.Character.Head
			if (library.flags['SilentAimVisibleCheck'] == true and TargetObscured(Part.Position, v.Character)) then continue end
			local Distance = (Part.Position - Client.Character.Head.Position).Magnitude
			if Distance < ClosestDistance then
				ClosestDistance = Distance
				BodyPart = Part
				Found = true
			end
		end
		if not Found then
			BodyPart = nil
		end
	end

	local function PositionToRay(Origin, Target)
		return Ray.new(Origin, (Target - Origin).Unit * 600)
	end

	local Meta = getrawmetatable(game)
	local OldIndex = Meta.__index
	setreadonly(Meta, false)
	Meta.__index = newcclosure(function(Object, Index)
		if Index == 'Clips' and library.flags['Wallbang'] and Workspace:FindFirstChild('Map') then
			return Workspace.Map
		end
		return OldIndex(Object, Index)
	end)

	local OldNameCall
	OldNameCall = hookmetamethod(game, '__namecall', function(Self, ...)
		local Method = getnamecallmethod()
		local Args = {...}
		if Method == 'FindPartOnRayWithIgnoreList' and BodyPart and library.flags['Silent Aim'] then
			Args[1] = PositionToRay(Camera.CFrame.Position, BodyPart.Position)
			return OldNameCall(Self, unpack(Args))
		end
		return OldNameCall(Self, ...)
	end)

	Tabs.Arsenal = library:AddTab('Arsenal')
	Sections.Main = Tabs.Arsenal:AddSection({text = 'Main', column = 1})
	--[[Sections.AutoFarms = Tabs.Arsenal:AddSection({text = 'AutoFarms', column = 2}) -- these gamemodes got removed

	local AutoFarm = false
	Sections.AutoFarms:AddToggle({text = 'Monkey Business', state = false, callback = function(bool)
		AutoFarm = bool
		if bool then
			while AutoFarm do
				if Workspace.Debris.Bananas:FindFirstChild('Banana') then
					for _, v in pairs(Workspace.Debris.Bananas:GetChildren()) do
						if AutoFarm == true and Client.Character and Client.Character:FindFirstChild('HumanoidRootPart') and not IsDead(Client) then
							Client.Character.HumanoidRootPart.CFrame = v.CFrame
							repeat wait() until not v.Parent
						end
					end
				end
				wait()
			end
		end
	end})
	Sections.AutoFarms:AddBind({text = 'Quick-Toggle', key = 'P', callback = function()
		library.options['Monkey Business']:SetState(not library.flags['Monkey Business'])
	end})
	Sections.AutoFarms:AddDivider()
	local Oddball = false
	Sections.AutoFarms:AddToggle({text = 'Oddball', state = false, callback = function(bool)
		Oddball = bool
		if bool then
			repeat wait()
				if Workspace.Debris:FindFirstChild('Oddball') and Client.Character and Client.Character:FindFirstChild('HumanoidRootPart') and not IsDead(Client) then
					Client.Character.HumanoidRootPart.CFrame = Workspace.Debris.Oddball.PrimaryPart.CFrame
				end
			until not Oddball
		end
	end})
	Sections.AutoFarms:AddBind({text = 'Quick-Toggle', key = 'L', callback = function()
		library.options['Oddball']:SetState(not library.flags['Oddball'])
	end})]]

	Sections.Main:AddToggle({text = 'Modded Guns', state = false, callback = function(bool)
		if not library.loaded then return end
		for ModName, ModVal in pairs(ModVals) do
			for _, Weapon in pairs(ReplicatedStorage.Weapons:GetChildren()) do
				local Val = Weapon:FindFirstChild(ModName)
				if not Val then continue end
				local Original = Val.AyarumSave.Value
				Val.Value = bool and ModVal or Original
			end
		end
		Notify('Changed Gun Mods.\nYou may need to reset!')
	end})
	Sections.Main:AddDivider()
	Sections.Main:AddToggle({text = 'WalkSpeed', state = false})
	Sections.Main:AddSlider({text = 'Speed', min = 16, max = 500, value = 16, callback = function(value)
		if library.flags['WalkSpeed'] and Client.Character and Client.Character:FindFirstChild('Humanoid') then
			Client.Character.Humanoid.WalkSpeed = value
		end
	end})
	Sections.Main:AddDivider()
	Sections.Main:AddSlider({text = 'Gravity', min = 0, max = 200, value = 56, callback = function(value)
		ReplicatedStorage.CurrentGrav.Value = value
	end})

	Sections.SilentAim = Tabs.Arsenal:AddSection({text = 'Silent Aim', column = 2})
	Sections.SilentAim:AddToggle({text = 'Enabled', state = false, callback = function(bool)
		if bool then
			RunService:BindToRenderStep('SilentAim', 200, GetClosestHead)
		else
			RunService:UnbindFromRenderStep('SilentAim')
		end
	end})
	Sections.SilentAim:AddToggle({text = 'Wallbang', state = false})
	Sections.SilentAim:AddToggle({text = 'Team Check', flag = 'SilentAimTeamCheck', state = false})
	Sections.SilentAim:AddToggle({text = 'Visible Check', flag = 'SilentAimVisibleCheck', state = false})
end