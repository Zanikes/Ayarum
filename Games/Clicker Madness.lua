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
	Client.PlayerGui.BuyGems.Enabled = false
	local ClickScript = require(Client.PlayerScripts.Aero.Controllers.UI.Click)
	local Spam = false

	local thou = 1000
	local mil = 1000000
	local bil = 1000000000
	local tril = 1000000000000
	local quad = 1000000000000000
	local quin = 1000000000000000000
	local eggInfo = {
		{'Halloween', 350},
		{'Basic', 5 * thou},
		{'Lava', 2 * mil},
		{'Desert', 20 * mil},
		{'Ocean', 1 * bil},
		{'Winter', 10 * bil},
		{'Toxic', 200 * bil},
		{'Candy', 5 * tril},
		{'Forest', 20 * tril},
		{'Storm', 1 * quad},
		{'Blocky', 2 * quad},
		{'Space', 10 * quad},
		{'Dominus', 100 * quad},
		{'Infinity', 625 * quad},
		{'Future', 30 * quin},
		{'City', 87.5 * quin},
		{'Moon', 87.5 * quin},
		{'Fire', 87.5 * quin}
	}
	local list = {}
	local prices = {}
	for _, v in pairs(eggInfo) do
		table.insert(list, v[1])
		prices[v[1]] = v[2]
	end
	local type = 'basic'

	local locs = {}
	for _, v in pairs(Workspace.Worlds:GetChildren()) do
		table.insert(locs, v.Name)
	end

	local kill = false
	local range = 50

	local Collect = false
	local Capturing = false

	local function BuyEggs()
		if type == 'Halloween' then
			if library.flags['AutoEgg'] and Client.Data.EventCurrency.Value >= prices[type] then
				ReplicatedStorage.Aero.AeroRemoteServices.EggService.Purchase:FireServer(type:lower())
			end
		else
			if library.flags['AutoEgg'] and Client.Data.Gems.Value >= prices[type] then
				ReplicatedStorage.Aero.AeroRemoteServices.EggService.Purchase:FireServer(type:lower())
			end
		end
	end

	library:AddConnection(Client.Data.Gems:GetPropertyChangedSignal('Value'), BuyEggs)
	library:AddConnection(Client.Data.EventCurrency:GetPropertyChangedSignal('Value'), BuyEggs)

	Tabs.Main = library:AddTab('Clicker Madness')

	Sections.Main = {
		Clicking = Tabs.Main:AddSection({text = 'Clicking', column = 1}),
		Eggs = Tabs.Main:AddSection({text = 'Eggs', column = 1}),
		Teleports = Tabs.Main:AddSection({text = 'Teleports', column = 2}),
		Other = Tabs.Main:AddSection({text = 'Other', column = 2})
	}

	Sections.Main.Clicking:AddToggle({text = 'Spam Clicks', state = false, callback = function(bool)
		Spam = bool
		if Spam then
			repeat
				ClickScript:Click()
				wait()
			until not Spam
		end
	end})

	Sections.Main.Eggs:AddList({text = 'Egg Type', values = list, callback = function(choice)
		type = choice
	end})
	Sections.Main.Eggs:AddToggle({text = 'Auto-Purchase Eggs', flag = 'AutoEgg', state = false, callback = function(bool)
		if bool then
			BuyEggs()
		end
	end})

	Sections.Main.Teleports:AddList({text = 'Location', flag = 'LocationList', values = locs})
	Sections.Main.Teleports:AddButton({text = 'Teleport', callback = function()
		local char = Client.Character
		if char then
			char.HumanoidRootPart.CFrame = Workspace.Worlds[library.flags['LocationList']].Teleport.CFrame
			Notify('Teleported you to ' .. library.flags['LocationList'])
		end
	end})

	Sections.Main.Other:AddButton({text = 'Capture All Flags', callback = function()
		if Capturing then
			Notify('Ayarum is already capturing flags!')
			return
		end
		Capturing = true
		Notify('Please Wait...')
		local Done = 0
		local Max = 1
		for _, v in pairs(Workspace.Flags:GetChildren()) do
			if v:FindFirstChild('Hitbox') then
				Max += 1
			end
		end
		local CaptureBar = library:AddLoadingBar('Flag Capture')
		local char = Client.Character
		local PrevPos = char.HumanoidRootPart.CFrame
		for _, v in pairs(Workspace.Flags:GetChildren()) do
			if v:FindFirstChild('Hitbox') then
				if char then
					Done += 1
					CaptureBar:Update(Done, Max, 'Capturing Flag ' .. tostring(Done) .. ' of ' .. tostring(Max))
					char.HumanoidRootPart.CFrame = CFrame.new() + v.Hitbox.CFrame.Position + Vector3.new(0, 5, 0)
					repeat wait() until v.Flag.Player.Info.PlayerName.Text == Client.Name and v.Height.Value == 1
				else
					return
				end
			end
		end
		if char then
			char.HumanoidRootPart.CFrame = PrevPos
		end
		CaptureBar:Update(Max, Max, 'Done!')
		Capturing = false
	end})
	Sections.Main.Other:AddButton({text = 'Unlock Gamepasses', callback = function()
		local GamepassScript = require(ReplicatedStorage.Aero.Shared.Gamepasses)
		GamepassScript.HasPassOtherwisePrompt = function()
			return true
		end
		Notify('Unlocked All Gamepasses')
	end})
	Sections.Main.Other:AddToggle({text = 'Collect all Pickups', state = false, callback = function(bool)
		Collect = bool
		if Collect == true then
			repeat
				if not Client.Character then return end
				for _, v in pairs(Workspace.ScriptObjects:GetDescendants()) do
					if not Collect then return end
					if v and v.Parent and v.Name == 'TouchInterest' and v.Parent.Parent.Name == 'BasePickup' and Client.Character and Client.Character.Head then
						firetouchinterest(Client.Character.Head, v.Parent, 0)
						wait()
					end
				end
				wait(0.5)
			until not Collect
		end
	end})
	Sections.Main.Other:AddDivider()
	Sections.Main.Other:AddSlider({text = 'Range', min = 10, max = 200, value = range, callback = function(v)
		range = v
	end})
	Sections.Main.Other:AddToggle({text = 'Kill Aura', state = false, callback = function(bool)
		kill = bool
		if kill then
			repeat
				wait()
				spawn(function()
					for _, vplr in pairs(Players:GetPlayers()) do
						if not Client.Character or not Client.Character:FindFirstChild('HumanoidRootPart') then continue end
						if vplr ~= Client and vplr.Character and (vplr.Character.HumanoidRootPart.Position - Client.Character.HumanoidRootPart.Position).Magnitude < range and not IsDead(vplr) then
							ReplicatedStorage.Aero.AeroRemoteServices.CursorCannonService.FireCursor:FireServer(vplr)
						end
					end
				end)
			until not kill
		end
	end})
end