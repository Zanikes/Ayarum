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
	local BaseTable = {}
	local function UpdateBaseList()
		BaseTable = HttpGet('GetBases.lua')
	end
	LoadInfo('Loading Base List...')
	UpdateBaseList()
	LoadInfo('Loading Spectate Info...')
	local Spectator = HttpGet('SpectateInfo.lua')
	LoadInfo('Getting Broken Instances...')
	wait(0.5)
	local CorrectMats = {'Bricks', 'C4Placed', 'Fireplace', 'Floodlight', 'LargeCrateOpen', 'Planks', 'RoadFlareLit', 'Slabs', 'SmallCrateOpen', 'Stone', 'TM46Placed', 'Timber', 'VS50Placed', 'Walls', 'MetalTruss'}
	local VehiclesList = {'PoliceCar', 'SportsCar', 'DeliveryVan', 'Bicycle', 'TrinitySUV', 'Tractor', 'Pickup2', 'Jeep', 'ATV', 'Jeep2', 'Motorside', 'Motorcycle', 'Van', 'Humvee2', 'Humvee', 'Firetruck', 'Pickup', 'Ural2', 'Ural', 'Ambulance'}

	local function AddBroken(Table, Instance, CorrectParent)
		local OldParent = ''
		local Parent = ''

		local FoundFullOldParent = false
		local FoundFullParent = false

		local OldParLoop = Instance.Parent
		local ParLoop = CorrectParent

		repeat
			if OldParLoop ~= game then
				OldParent = OldParLoop.Name .. '.' .. OldParent
				OldParLoop = OldParLoop.Parent
			else
				OldParent = 'game.' .. OldParent
				FoundFullOldParent = true
			end
		until FoundFullOldParent == true

		repeat
			if ParLoop ~= game then
				Parent = ParLoop.Name .. '.' .. Parent
				ParLoop = ParLoop.Parent
			else
				Parent = 'game.' .. Parent
				FoundFullParent = true
			end
		until FoundFullParent == true

		Parent = string.sub(Parent, 0, string.len(Parent) - 1)
		OldParent = string.sub(OldParent, 0, string.len(OldParent) - 1)

		table.insert(Table, {Instance, CorrectParent, OldParent, Parent})
	end

	local function FixServer()
		local MoveThings = {}
		for _, v in pairs(game:GetDescendants()) do
			if v.Name == 'Zombies' and not v:FindFirstChild('Skeleton') and v.Parent ~= Workspace and v:IsA('Model') then
				AddBroken(MoveThings, v, Workspace)
			elseif v.Name == 'Zombie' and v.Parent.Name ~= 'Zombies' and v.Parent.Parent.Name ~= 'Zombies' and v.Parent ~= Lighting.Materials then
				AddBroken(MoveThings, v, ReplicatedStorage.Zombies)
			elseif table.find(CorrectMats, v.Name) and v.Parent ~= Lighting.Materials and v.Parent ~= Lighting.LootDrops and v.Parent ~= Workspace.Remote and v.Parent ~= ReplicatedStorage.private and v.Parent ~= ReplicatedStorage.SpawnPlate.Models and not Lighting.Materials:FindFirstChild(v.Name) and v.Name ~= 'Floodlight' then
				AddBroken(MoveThings, v, Lighting.Materials)
			elseif table.find(VehiclesList, v.Name) and v.Parent ~= Workspace.Vehicles and v.Parent.Name ~= 'Models' then
				AddBroken(MoveThings, v, Workspace.Vehicles)
			elseif v.Parent == Lighting.Materials and not table.find(CorrectMats, v.Name) and v.Name ~= 'Animal1' and v.Name ~= 'Animal2' and v.Name ~= 'Animal3' and v.Name ~= 'Animal4' and v.Name ~= 'Animal5' and v.Name ~= 'Animal6' and v.Name ~= 'AyarumStorage' then
				AddBroken(MoveThings, v, Lighting.LootDrops)
			elseif (v.Name == 'Animal1' or v.Name == 'Animal2' or v.Name == 'Animal3' or v.Name == 'Animal4' or v.Name == 'Animal5' or v.Name == 'Animal6') and v.Parent ~= ReplicatedStorage.Animals and v.Parent ~= Workspace then
				AddBroken(MoveThings, v, ReplicatedStorage.Animals)
			elseif (v.Name == 'DropLoot' or v.Name == 'SpawnLoot') and v.Parent ~= Workspace then
				AddBroken(MoveThings, v, Workspace)
			elseif (v.Name == 'Corpse' or v.Name == 'GhostCorpse') and v.Parent ~= Workspace and v.Parent ~= ReplicatedStorage and v.Parent.Name ~= 'Corpse' and v.Parent.Name ~= 'GhostCorpse' then
				AddBroken(MoveThings, v, ReplicatedStorage)
			end
		end
		if #MoveThings == 0 then
			return false
		else
			return MoveThings
		end
	end
	local FixItems = FixServer()

	local HttpService = game:GetService('HttpService')
	local Mapname = game:GetService('MarketplaceService'):GetProductInfo(game.PlaceId).Name
	local NameLength = 20
	local IsXbox = false
	if string.sub(Mapname, 1, 4) == 'Xbox' then
		NameLength = NameLength + 5
		IsXbox = true
	end
	Mapname = string.sub(Mapname, NameLength)

	local Vehicles = Workspace.Vehicles
	local LootDrops = Lighting.LootDrops
	local Materials = Lighting.Materials
	local Remote = Workspace.Remote

	local MetaCall = getrawmetatable(getrenv().shared)
	local RemoteCall = debug.getupvalues(debug.getupvalues(MetaCall.__index)[3])
	local Serial = RemoteCall[6]
	local GrabKey = RemoteCall[7]
	local function fireServer(RemoteName, ...)
		local args = { ... }
		spawn(function()
			for _, v in pairs(Remote:GetChildren()) do
				if v:IsA('RemoteEvent') and v.Name == RemoteName then
					v:FireServer(Serial({unpack(args)}, GrabKey()))
				end
			end
		end)
	end

	local function ChangeParent(Instance, NewParent)
		fireServer('ChangeParent', Instance, NewParent)
	end
	local function ChangeValue(Instance, Value)
		fireServer('ChangeValue', Instance, Value)
	end
	local function Delete(Instance)
		ChangeParent(Instance, nil)
	end

	local function MakeStorage(Player)
		if typeof(Player) == 'string' then Player = Players[Player] end
		if not Player:FindFirstChild('AyarumStorage') then
			Remote.AddClothing:FireServer('AyarumStorage', Player, '', '', '')
			Player:WaitForChild('AyarumStorage')
			for _, v in pairs(Player.AyarumStorage:GetChildren()) do
				if v:IsA('StringValue') then
					Delete(v)
				end
			end
		end
		return Player.AyarumStorage
	end

	local LimAmount = 0
	MaxAmount = 1700
	TimeToWait = 1.5
	local function Limiter()
		LimAmount = LimAmount + 1
		if LimAmount >= MaxAmount then
			wait(TimeToWait)
			LimAmount = 0
		end
	end

	local function MakeWeld(Part0, Part1, C0, C1)
		if C0 == nil then
			C0 = CFrame.new()
		end
		if C1 == nil then
			C1 = CFrame.new()
		end
		Remote.CreateWeld:FireServer(Part0, Part1, C0, C1)
		local Weld = Instance.new('Weld', Part0)
		Weld.Part0 = Part0
		Weld.Part1 = Part1
		Weld.C0 = C0
		Weld.C1 = C1
	end

	local function PlaceFlare(Player)
		if Player == nil or Player.Character == nil or not Player.Character:FindFirstChild('Head') then return end
		local Head = Player.Character.Head
		local Pos = Head.Position
		local Flare = Materials.RoadFlareLit
		Remote.PlaceMaterial:FireServer('RoadFlareLit', Pos - Flare.Head.Position)
		while wait() do
			for _, v in pairs(Workspace:GetChildren()) do
				if v.Name == 'RoadFlareLit' and (v.Head.Position - Pos).Magnitude < 2 then
					MakeWeld(v.Head, Head, CFrame.new(0, 2, 0))
					return v
				end
			end
		end
	end

	local function Rocket(Player, Distance)
		spawn(function()
			local Flare = PlaceFlare(Player)
			local StartPos = Flare.Head.Position
			local Max = 90
			if Distance ~= nil and Distance > 90 then
				Max = Distance
			end
			local NSpeed = 1.2
			if Max > 200 then
				local S = Max / 200 - 1
				NSpeed = NSpeed + S
			end
			local Broken = false
			local Event
			Event = Workspace.ChildAdded:Connect(function(Child)
				if Child.Name == 'Explosion' and (Child.Position - Flare.Head.Position).Magnitude < 10 then
					Broken = true
					Event:Disconnect()
				end
			end)
			for i = 1, 999999 do
				if i == Max - 50 then
					Remote.Detonate:FireServer({['Head'] = Flare.Head})
				end
				if Broken == true or i > Max then
					break
				end
				Remote.ReplicateModel:FireServer(Flare, CFrame.new(0, i * NSpeed, 0) + StartPos)
				wait()
			end
			Delete(Flare)
		end)
	end

	local function Convert(Numb)
		if Numb < 0 then
			return Numb*-1
		end
		return Numb
	end

	local function GetMid(Item)
		local Base = Item:FindFirstChild('Essentials'):FindFirstChild('Base')
		if Base then return Base.Position end

		local Tab = {['LowX'] = nil, ['HighX'] = nil, ['LowY'] = nil, ['HighY'] = nil, ['LowZ'] = nil, ['HighZ'] = nil}
		local List = Item
		if typeof(Item) ~= 'table' then
			List = Item:GetDescendants()
		end
		for i, v in pairs(List) do
			if v:IsA('BasePart') then
				local Pos = v.Position
				local X = Pos.X
				local Y = Pos.Y
				local Z = Pos.Z
				if Tab['LowX'] == nil and not v:FindFirstChild('IgnorePosition') then
					Tab['LowX'] = X
					Tab['HighX'] = X
					Tab['LowY'] = Y
					Tab['HighY'] = Y
					Tab['LowZ'] = Z
					Tab['HighZ'] = Z
				end
				if not v:FindFirstChild('IgnorePosition') then
					if Tab['LowX'] > X then
						Tab['LowX'] = X
					end
					if Tab['HighX'] < X then
						Tab['HighX'] = X
					end
					if Tab['LowY'] > Y then
						Tab['LowY'] = Y
					end
					if Tab['HighY'] < Y then
						Tab['HighY'] = Y
					end
					if Tab['LowZ'] > Z then
						Tab['LowZ'] = Z
					end
					if Tab['HighZ'] < Z then
						Tab['HighZ'] = Z
					end
				end
			end
		end

		local Mid = Vector3.new()
		if Tab['LowX'] then
			Mid = Vector3.new(Tab['LowX'] + Convert(Tab['HighX'] - Tab['LowX']) / 2, Tab['LowY'] + Convert(Tab['HighY'] - Tab['LowY']) / 2, Tab['LowZ'] + Convert(Tab['HighZ'] - Tab['LowZ']) / 2)
		end
		return Mid
	end

	local function SetZombieVisible(Player, Value)
		local Storage = MakeStorage(Player)
		local Hum = Player.Character.Humanoid
		local Vis = Hum:FindFirstChild('Visibility')

		if Value == true and Vis then
			if Vis.Value == '-100000000' then
				Notify(Player.Name .. ' is already Invisible to Zombies!')
				return true
			end
			if Storage:FindFirstChild('Visibility') then
				Delete(Storage['Visibility'])
			end
			ChangeParent(Vis, Storage)
			repeat wait() until Vis.Parent == Storage
			Remote.AddClothing:FireServer('Visibility', Hum, '-100000000', 'Shooting', '0')
			repeat wait() until Hum:FindFirstChild('Visibility')
			Remote.AddClothing:FireServer('Stance', Hum.Visibility, '0', '', '')
		elseif Value == false and Vis and Storage:FindFirstChild('Visibility') then
			Delete(Vis)
			ChangeParent(Storage.Visibility, Hum)
		end
	end

	local ItemSizes = {}
	for _, v in pairs(Materials:GetChildren()) do
		if v:FindFirstChild('Head') and v.Name ~= 'Zombie' then
			local Size = v.Head.Size
			ItemSizes[tostring(Size.X) .. tostring(Size.Y) .. tostring(Size.Z)] = true
		end
	end

	local function CheckModel(Model)
		for _, v in pairs(Model:GetChildren()) do
			if v:IsA('BasePart') and ItemSizes[tostring(v.Size.X) .. tostring(v.Size.Y) .. tostring(v.Size.Z)] == true then
				return true
			end
		end
		return false
	end

	local function CleanBuildings()
		local List = {}
		local Count = 0
		for _, v in pairs(Workspace:GetChildren()) do
			if v:IsA('BasePart') and ItemSizes[tostring(v.Size.X) .. tostring(v.Size.Y) .. tostring(v.Size.Z)] == true or v:IsA('Model') and (CheckModel(v) == true or v.Name == 'Model' or v.Name == 'MilitaryPack') or Lighting.Hair:FindFirstChild(tostring(v)) then
				table.insert(List, v)
			elseif v.Name == 'LargeCrateOpen' or v.Name == 'SmallCrateOpen' or v.Name == 'FloodLight' and v:FindFirstChild('Head') or LootDrops:FindFirstChild(tostring(v)) and not v:FindFirstAncestorOfClass('Model') and v.Name ~= 'FloodLight' then
				table.insert(List, v)
			else
				for _, a in pairs(v:GetChildren()) do
					if Lighting.Hair:FindFirstChild(tostring(a)) and not Players:FindFirstChild(tostring(v)) then
						table.insert(List, v)
						break
					end
				end
			end
		end
		for _, v in pairs(Vehicles:GetChildren()) do
			for _, a in pairs(v:GetChildren()) do
				if a:IsA('BasePart') and ItemSizes[tostring(a.Size.X) .. tostring(a.Size.Y) .. tostring(a.Size.Z)] == true or a:IsA('Model') and (CheckModel(a) == true or a.Name == 'Model' or a.Name == 'MilitaryPack') then
					table.insert(List, a)
				end
				if a.Name == 'LargeCrateOpen' or a.Name == 'SmallCrateOpen' or a.Name == 'FloodLight' and a:FindFirstChild('Head') or LootDrops:FindFirstChild(tostring(a)) and not a:FindFirstChildOfClass('Model') and v.Name ~= 'FloodLight' then
					table.insert(List, a)
				end
			end
		end
		if #List > 7000 then
			MaxAmount = 600
			TimeToWait = 2
		end
		for i = 1, #List do
			local ItemName = List[i].Name
			if ItemName ~= 'C4Placed' and ItemName ~= 'VS50Placed' and ItemName ~= 'TM46Placed' and (not LootDrops:FindFirstChild(ItemName) or ItemName == 'Floodlight') then
				Delete(List[i])
				Limiter()
				Count = Count + 1
			end
		end
		MaxAmount = 1700
		TimeToWait = 1.5
		return Count
	end

	local function CheckNumber(Number)
		return tonumber(string.sub(tostring(Number), 1, 1))
	end

	local function setvalue(Value, Min, Max, Clamp)
		if not Clamp then
			Value = math.clamp(Value, Min, Max)
			return Value
		end
		Value = math.floor(Value + Clamp)
		Value = math.clamp(Value, Min, Max)
		return Value
	end

	local function CheckForExploiters()
		for _, v in pairs(Players:GetPlayers()) do
			if v ~= Client then
				pcall(function()
					if CheckNumber(v.playerstats.Hunger.Value) == nil or CheckNumber(v.playerstats.Thirst.Value) == nil or (setvalue(v.playerstats.Thirst.Value, 0, 100) ~= v.playerstats.Thirst.Value or setvalue(v.playerstats.Hunger.Value, 0, 100) ~= v.playerstats.Hunger.Value) then
						Notify(v.Name .. ' has infinite vitals')
					end
					if not v.Character:FindFirstChild('Humanoid') then
						Notify(v.Name .. ' is missing their Humanoid')
					end
					if CheckNumber(v.Character.Humanoid.Health) == nil then
						Notify(v.Name .. ' has infinite health')
					end
					if v.Character:FindFirstChild('Humanoid') and v.Character.Humanoid:FindFirstChild('DefenseMultiplier') and tonumber(v.Character.Humanoid.DefenseMultiplier.Value) <= 0 then
						Notify(v.Name .. ' has PainKiller God')
					end
					if v:FindFirstChild('playerstats') and v.playerstats:FindFirstChild('character') and (v.playerstats.character:FindFirstChild('AntiTP') or v.playerstats.character:FindFirstChild('AA')) then
						Notify(v.Name .. ' is using XR Hub')
					end
					for _, a in pairs(v.playerstats.slots:GetChildren()) do
						if a:FindFirstChild('ObjectID') then
							if a.ObjectID:FindFirstChild('Clip') then
								if tonumber(getrenv()._G.Deobfuscate(a.ObjectID.Clip.Value)) > 100 then
									Notify(v.Name .. ' has Infinite Ammo')
									break
								end
							end
						end
					end
				end)
			end
		end
	end

	local function GetItemFromString(Item, Parent)
		if typeof(Item) == 'Instance' then return Item end
		if Parent:FindFirstChild(Item) then
			return Parent[Item]
		elseif Materials:FindFirstChild(Item) then
			return Materials[Item]
		end
	end

	local function GetPart(Model)
		local Part
		for _, v in pairs(Model:GetDescendants()) do
			if v:IsA('BasePart') and (not Part or tostring(v) == 'Head' or tostring(v) == 'Driver') then
				Part = v
			end
		end
		return Part
	end

	local SpawnedItems = {}
	local function SpawnItem(Player, Item, Parent, Offset, Amount)
		if Player == nil or Item == nil or GetItemFromString(Item, Parent) == nil then return end
		if not SpawnedItems[tostring(Item)] then
			SpawnedItems[tostring(Item)] = Amount
		else
			SpawnedItems[tostring(Item)] = SpawnedItems[tostring(Item)] + Amount
		end
		Item = GetItemFromString(Item, Parent)
		local MoveItem
		if Parent == LootDrops then
			for _, v in pairs(Materials:GetChildren()) do
				if v.Name == Item.Name and not v:FindFirstChild('ObjectID') then
					MoveItem = v
				end
			end
		end
		if MoveItem then
			local Storage = MakeStorage(Materials)
			ChangeParent(MoveItem, Storage)
			Storage:WaitForChild(MoveItem.Name)
		end
		if Item.Parent ~= Materials then
			ChangeParent(Item, Materials)
		end
		local ItemWait = Materials:WaitForChild(Item.Name)
		if ItemWait.PrimaryPart == nil then
			ItemWait.PrimaryPart = GetPart(ItemWait)
		end
		for i = 1, Amount do
			local SpawnPos = Vector3.new(math.random(Offset.X[1], Offset.X[2]), math.random(Offset.Y[1], Offset.Y[2]), math.random(Offset.Z[1], Offset.Z[2]))
			Remote.PlaceMaterial:FireServer(ItemWait.Name, Player.Character.Torso.Position - ItemWait.PrimaryPart.Position - SpawnPos)
		end
		spawn(function()
			local ItemsFound = 0
			repeat wait()
				if ItemsFound ~= SpawnedItems[Item.Name] then
					ItemsFound = 0
				end
				for _, v in pairs(Workspace:GetChildren()) do
					if v:FindFirstChild('IsAyarumSpawned') and v.Name == Item.Name then
						ItemsFound = ItemsFound + 1
					end
				end
			until ItemsFound == SpawnedItems[Item.Name]
			if Materials:FindFirstChild(Item.Name) then
				ChangeParent(Materials[Item.Name], Parent)
			end
			if MoveItem then
				ChangeParent(MoveItem, Materials)
			end
			for _, v in pairs(Workspace:GetChildren()) do
				if v:FindFirstChild('IsAyarumSpawned') and v.Name == Item.Name then
					v.IsAyarumSpawned:Destroy()
				end
			end
			SpawnedItems[Item.Name] = SpawnedItems[Item.Name] - Amount
			if SpawnedItems[Item.Name] <= 0 then
				SpawnedItems[Item.Name] = nil
			end
		end)
	end

	local function GetPartPosition(Mod)
		if Mod then
			for _, v in pairs(Mod:GetDescendants()) do
				if v:IsA('BasePart') then
					return v.Position
				end
			end
		end
		return Vector3.new(-1000000, -1000000, -1000000)
	end

	local AntiSpam = 0
	library:AddConnection(Workspace.ChildAdded, function(Item)
		wait()
		if SpawnedItems[Item.Name] ~= nil then
			local Val = Instance.new('StringValue')
			Val.Name = 'IsAyarumSpawned'
			Val.Parent = Item
			Delete(Item:WaitForChild('IsBuildingMaterial'))
		elseif SpawnedItems[Item.Name] == nil and not Item:FindFirstChild('Handle') and not table.find(VehiclesList, Item.Name) and not table.find(CorrectMats, Item.Name) and (LootDrops:FindFirstChild(Item.Name) or Materials:FindFirstChild(Item.Name)) and (Item.Name ~= 'C4' and Item.Name ~= 'TM46' and Item.Name ~= 'VS50' and Item.Name ~= 'SmallCrate' and Item.Name ~= 'LargeCrate') then
			local Pos = GetPartPosition(Item)
			if library.flags['DisableSpawn'] == true then
				Delete(Item)
			end
			if AntiSpam == 0 then
				spawn(function()
					wait(5)
					AntiSpam = 0
				end)
			end
			if AntiSpam >= 5 then
				return
			else
				local Closest = nil
				for _, v in pairs(Players:GetPlayers()) do
					if v.Character ~= nil and v.Character:FindFirstChild('Head') and (v.Character.Head.Position - Pos).Magnitude < 100 and (Closest == nil or (v.Character.Head.Position - Pos).Magnitude < (Closest.Character.Head.Position - Pos).Magnitude) then
						Closest = v
					end
				end
				if Closest ~= nil then
					Notify('Someone Spawned ' .. Item.Name .. '\nNear ' .. Closest.Name)
				elseif Pos.X == -1000000 then
					Notify('Someone Spawned ' .. Item.Name)
				end
			end
			AntiSpam = AntiSpam + 1
		end
	end)

	local AttachmentList = {
		['Acog'] = {'sight', 9013},
		['SUSAT'] = {'sight', 9014},
		['CCO'] = {'sight', 9001},
		['Holo'] = {'sight', 9002},
		['Reflex'] = {'sight', 9003},
		['Kobra'] = {'sight', 9004},
		['Grip'] = {'under', 9005},
		['Laser'] = {'under', 9006},
		['Suppressor9'] = {'silencer', 9007},
		['Suppressor45'] = {'silencer', 9008},
		['Suppressor545'] = {'silencer', 9011},
		['Suppressor556'] = {'silencer', 9009},
		['Suppressor762'] = {'silencer', 9010},
		['Flashlight'] = {'under', 9012}
	}
	local AttachmentList2 = {'Acog', 'SUSAT', 'CCO', 'Holo', 'Reflex', 'Kobra', 'Grip', 'Laser', 'Suppressor9', 'Suppressor45', 'Suppressor545', 'Suppressor556', 'Suppressor762', 'Flashlight'}

	local function AntiKick()
		repeat wait() until Client.Character ~= nil
		local DidTryKick = false
		for _, v in pairs(Client.Character:GetChildren()) do
			if v:IsA('Part') then
				library:AddConnection(v.ChildAdded, function(child)
					if tostring(child) == 'IsBuildingMaterial' and child:IsA('StringValue') then
						if child.Value == 'AyarumBypassed' then return end
						Remote.Detonate:FireServer(child)
						DidTryKick = true
						pcall(function()
							repeat
								wait()
								Delete(child)
							until child.Parent == nil
						end)
					end
				end)
			end
		end
		library:AddConnection(Client.Character.ChildAdded, function(child)
			if tostring(child) == 'IsBuildingMaterial' and child:IsA('StringValue') then
				if child.Value == 'AyarumBypassed' then return end
				Remote.Detonate:FireServer(child)
				DidTryKick = true
				pcall(function()
					repeat
						wait()
						Delete(child)
					until child.Parent == nil
				end)
			end
		end)
		local Root = Client.Character:WaitForChild('HumanoidRootPart')
		local PrevPos = Root.Position
		library:AddConnection(Root:GetPropertyChangedSignal('Position'), function()
			wait(0.1)
			if Client.Character == nil or not Client.Character:FindFirstChild('HumanoidRootPart') then return end
			if (Root.Position - PrevPos).Magnitude > 100 and DidTryKick == true then
				Root.Velocity = Vector3.new()
				DidTryKick = false
				Client.Character:MoveTo(PrevPos)
			else
				PrevPos = Root.Position
			end
		end)
	end

	local function AntiCrash()
		local OldIndex = nil
		local Meta = getrawmetatable(game)
		setreadonly(Meta, false)

		OldIndex = hookmetamethod(game, '__index', newcclosure(function(...)
			if tostring(...) == 'PermanentBan' then return end
			return OldIndex(...)
		end))
	end

	library:AddConnection(Client.CharacterAdded, AntiKick)
	AntiKick()
	AntiCrash()

	local function GetRemote(Name)
		for _, v in pairs(Remote:GetChildren()) do
			if v.Name == Name and v:IsA('RemoteEvent') then
				return v
			end
		end
	end

	local function KickPlayer(Player)
		spawn(function()
			Remote.AddClothing:FireServer('PermanentBan', Players[Player], '', '', '')
			wait()
			local remote = GetRemote('SpawnCrate')
			if remote then
				remote:FireServer(Players[Player])
			end
		end)
	end

	local function AddInstance(ValueName, Parent)
		local Value = ''
		if ValueName == 'IsBuildingMaterial' then
			Value = 'AyarumBypassed'
		end
		if not Parent:FindFirstChild(ValueName) then
			Remote.AddClothing:FireServer(ValueName, Parent, Value, '', '')
			repeat wait() until Parent:FindFirstChild(ValueName)
		end
		return Parent:FindFirstChild(ValueName)
	end

	local function Teleport(Player, Param)
		spawn(function()
			pcall(function()
				if typeof(Player) == 'string' then
					Player = Players:FindFirstChild(Player)
				end
				if typeof(Param) == 'Vector3' then
					Param = CFrame.new() + Param
				end
				if not Player or not Player.Character or not Player.Character.Torso then return end
				local Char = Player.Character
				local driven = AddInstance('driven', Char)
				local SeatPoint = AddInstance('SeatPoint', Char.Torso)
				local IsBuildingMaterial = AddInstance('IsBuildingMaterial', Char)
				wait(0.1)
				repeat
					Remote.HurtZombie:FireServer(Char)
					wait()
				until Char.Humanoid.Sit == true
				wait()
				Remote.ReplicateModel:FireServer(Char, Param)
				spawn(function()
					for i = 1, 20 do
						wait(0.05)
						Remote.HurtZombie:FireServer(Char)
					end
				end)
				local Teleported = false
				repeat
					wait()
					if not Char.Torso then
						return
					elseif (Char.Torso.CFrame.Position - Param.Position).Magnitude < 25 then
						Teleported = true
					end
				until Teleported == true
				Delete(driven)
				Delete(SeatPoint)
				Delete(IsBuildingMaterial)
			end)
		end)
	end

	local Colors = {'Bright red', 'Bright blue', 'Bright green', 'Bright orange', 'Bright yellow', 'Bright bluish green', 'Bright violet', 'Grime', 'Earth green', 'Navy blue', 'Dusty Rose', 'Black', 'Reddish brown', 'Nougat', 'Brick yellow', 'Really blue', 'Really red', 'New Yeller', 'Lime green', 'Hot pink', 'White', 'Really black', 'Deep orange', 'Cyan', 'Slime green', 'Alder', 'Royal purple', 'CGA brown', 'Maroon', 'Gold', 'Cool yellow', 'Cashmere', 'Dirt brown', 'Crimson', 'Institutional white', 'Pearl', 'Baby blue', 'Sea green', 'Salmon', 'Light reddish violet', 'Pink', 'Pastel violet', 'Alder', 'Pastel blue-green', 'Persimmon', 'Quill grey', 'Cool yellow', 'Pastel light blue', 'Br. yellowish orange', 'Laurel green', 'Pastel blue-green', 'Khaki', 'Cashmere', 'Grime', 'Toothpaste', 'Neon orange', 'Teal', 'Camo', 'Terra Cotta', 'Electric blue', 'Fog', 'Pastel yellow', 'Lily white', 'Dark stone grey', 'Sand red'}
	local function ColorModel(Model, Color, Texture, BasePart)
		if BasePart == true then
			local Part
			repeat wait() until Model:FindFirstChild('Head') or Model:FindFirstChild('Part') or Model:FindFirstChild('Truss')
			for _, v in pairs(Model:GetChildren()) do
				if v.Name == 'Head' or v.Name == 'Part' or v.Name == 'Truss' then
					Part = v
				end
			end
			if not Model:FindFirstChild('SecondaryColor') then
				Remote.AddClothing:FireServer('SecondaryColor', Model, '1', '', '')
				repeat wait() until Model:FindFirstChild('SecondaryColor')
			end
			GetRemote('ColorGun'):FireServer(Model, Color, Texture, Color, Texture)
			repeat wait() until tostring(Part.BrickColor) == Colors[Color]
		else
			spawn(function()
				if not Model:FindFirstChild('SecondaryColor') then
					Remote.AddClothing:FireServer('SecondaryColor', Model, '0', '', '')
					repeat wait() until Model:FindFirstChild('SecondaryColor')
				end
				GetRemote('ColorGun'):FireServer(Model, Color, Texture, Color, Texture)
				wait(0.5)
				for _, v in pairs(Model:GetChildren()) do
					if v.Name == 'SecondaryColor' then
						Delete(v)
					end
				end
			end)
		end
	end

	local function Repair(Vehicle, Armor, Value, Fuel, ArmorVal)
		if Armor then
			fireServer('WindowArmorSet', Vehicle.Essentials.Details:FindFirstChild('Windows'), 'Ballistic')
			for _, v in pairs(Vehicle.Wheels:GetChildren()) do
				fireServer('WheelVisibleSet', v, 'Armored')
			end
			if Vehicle == 'Firetruck' or Vehicle == 'Ambulance' then
				fireServer('HullArmorSet', Vehicle:FindFirstChild('ArmorSkirt', true))
			else
				fireServer('HullArmorSet', Vehicle:FindFirstChild('ArmorSkirt', true), Vehicle:FindFirstChild('Color', true), Vehicle:FindFirstChild('Special', true))
			end
		end
		for _, v in pairs(Vehicle.Stats:GetChildren()) do
			if v.Name == 'MaxSpeed' or v.Name == 'storage' then continue end
			if v.Name == 'Fuel' then
				ChangeValue(v, Fuel)
				ChangeValue(v.Max, Fuel)
			elseif v.Name == 'Armor' then
				ChangeValue(v, ArmorVal)
				ChangeValue(v.Max, Value)
			else
				ChangeValue(v, Value)
				ChangeValue(v.Max, Value)
			end
		end
	end

	local function Noclient(Player, Action)
		if Player == Client then
			Notify('You cannot ' .. Action .. ' yourself')
			return true
		end
	end

	local function Notloaded(Player)
		if not Workspace:FindFirstChild(Player.Name) or not Workspace[Player.Name]:FindFirstChild('Humanoid') then
			Notify(Player.Name .. ' is not loaded or is punished')
			return true
		end
	end

	local function Notspawned(Player)
		if not Player.Character.IsSpawned.Value == true then
			Notify(Player.Name .. ' is not spawned')
			return true
		end
	end

	local function CheckGroup(Player)
		Player = tostring(Player)
		local GroupFound = false
		repeat wait() until Lighting.Groups ~= nil
		for _, v in pairs(Lighting.Groups:GetDescendants()) do
			if v:IsA('StringValue') and v.Value == Player then
				GroupFound = true
			end
		end
		if GroupFound == false then
			Notify(Player .. ' is not in a Group!')
			return true
		end
	end

	local function GetGroup(Player)
		Player = tostring(Player)
		repeat wait() until Lighting.Groups ~= nil
		for _, v in pairs(Lighting.Groups:GetDescendants()) do
			if v:IsA('StringValue') and v.Value == Player then
				return tostring(v.Parent)
			end
		end
	end

	local function WipeInv(Player, SkipExtra)
		for _, v in pairs(Player.playerstats.slots:GetChildren()) do
			for _, a in pairs(v:GetChildren()) do
				Delete(a)
			end
			fireServer('ChangeValue', v, 0)
		end

		for _, v in pairs(Player.playerstats.utilityslots:GetChildren()) do
			for _, a in pairs(v:GetChildren()) do
				Delete(a)
			end
			fireServer('ChangeValue', v, 0)
		end

		for _, v in pairs(Player.playerstats.attachments.primary:GetChildren()) do
			for _, a in pairs(v:GetChildren()) do
				Delete(a)
			end
			fireServer('ChangeValue', v, 0)
		end

		for _, v in pairs(Player.playerstats.attachments.secondary:GetChildren()) do
			for _, a in pairs(v:GetChildren()) do
				Delete(a)
			end
			fireServer('ChangeValue', v, 0)
		end

		if not SkipExtra then
			for _, v in pairs(Player.playerstats.character:GetChildren()) do
				if v.Name == 'hat' or v.Name == 'accessory' then
					for _, a in pairs(v:GetChildren()) do
						Delete(a)
					end
					fireServer('ChangeValue', v, 0)
				end
			end
		end
	end

	local function StealSlot(FromSlot, ToSlot)
		if ToSlot:FindFirstChild('ObjectID') then
			fireServer('ChangeValue', ToSlot, 0)
			fireServer('ChangeParent', ToSlot.ObjectID, nil)
		end
		fireServer('ChangeValue', FromSlot, 0)
		fireServer('ChangeParent', FromSlot.ObjectID, ToSlot)
		fireServer('ChangeValue', ToSlot, 1)
	end

	local function SetPlayerInvis(Plr, Value)
		local Storage = MakeStorage(Plr)
		if Value == true and Plr.Character:FindFirstChild('Head') and Plr.Character.Head:FindFirstChild('face') then
			local PlrFace = Plr.Character.Head.face
			ChangeParent(PlrFace, Storage)
			repeat wait() until PlrFace.Parent == Storage
		elseif Value == false and Plr.Character ~= nil and Plr.Character:FindFirstChild('Head') and not Plr.Character.Head:FindFirstChild('face') and Storage:FindFirstChild('face') then
			ChangeParent(Storage.face, Plr.Character.Head)
		end
		fireServer('VehichleLightsSet', Plr.Character, 'Plastic', Value == true and 1 or 0)
		for _, v in pairs(Plr.Character:GetChildren()) do
			if v:FindFirstChild('thisisarmor') then
				Delete(v.thisisarmor)
			end
			if v:FindFirstChild('WeldScript') then
				Delete(v.WeldScript)
			end
			fireServer('VehichleLightsSet', v, 'Plastic', Value == true and 1 or 0)
		end
		if Plr == Client then
			spawn(function()
				repeat wait() until Plr.Character.Head.Transparency == 1
				local Parts = {'Head', 'Left Arm', 'Right Arm', 'Torso', 'Left Leg', 'Right Leg'}
				for _, v in pairs(Plr.Character:GetChildren()) do
					if table.find(Parts, v.Name) then
						v.Transparency = 0.8
					end
				end
			end)
		end
	end

	local function SpawnKit(Items, Player)
		spawn(function()
			for _, v in pairs(Items) do
				SpawnItem(Player, v[1], LootDrops, {
					X = {-5, 5},
					Y = {1, 1},
					Z = {-5, 5}
				}, v[2])
			end
		end)
	end

	local TextureCodes = {
		{'Smooth Plastic', 1},
		{'Diamond Plate', 2},
		{'Marble', 3},
		{'Pebble', 4},
		{'Corroded Metal', 5},
		{'Sand', 6},
		{'Slate', 7},
		{'Granite', 8},
		{'Foil', 9},
		{'Grass', 10},
		{'Ice', 11},
		{'Metal', 12}
	}

	local ColorCodes = {
		{'Bright Red', 1},
		{'Bright Blue', 2},
		{'Bright Green', 3},
		{'Bright Orange', 4},
		{'Bright Yellow', 5},
		{'Bright Bluish Green', 6},
		{'Bright Violet', 7},
		{'Grime', 8},
		{'Earth Green', 9},
		{'Navy Blue', 10},
		{'Dusty Rose', 11},
		{'Black', 12},
		{'Reddish Brown', 13},
		{'Nougat', 14},
		{'Brick Yellow', 15},
		{'Really Blue', 16},
		{'Really Red', 17},
		{'New Yeller', 18},
		{'Lime Green', 19},
		{'Hot Pink', 20},
		{'White', 21},
		{'Really Black', 22},
		{'Deep Orange', 23},
		{'Cyan', 24},
		{'Slime Green', 25},
		{'Alder', 26},
		{'Royal Purple', 27},
		{'CGA Brown', 28},
		{'Maroon', 29},
		{'Gold', 30},
		{'Cool Yellow', 31},
		{'Cashmere', 32},
		{'Medium Brown', 33},
		{'Crimson', 34},
		{'Institutional White', 35},
		{'Pearl', 36},
		{'Baby Blue', 37},
		{'Sea Green', 38},
		{'Salmon', 39},
		{'Light Reddish Violet', 40},
		{'Pink', 41},
		{'Pastel Violet', 42},
		{'Alder', 43},
		{'Pastel Blue-Green', 44},
		{'Persimmon', 45},
		{'Quill Gray', 46},
		{'Cool Yellow', 47},
		{'Pastel Light Blue', 48},
		{'Br. Yellowish Orange', 49},
		{'Laurel Green', 50},
		{'Pastel Blue-Green', 51},
		{'Khaki', 52},
		{'Cashmere', 53},
		{'Grime', 54},
		{'Toothpaste', 55},
		{'Neon Orange', 56},
		{'Teal', 57},
		{'Camo', 58},
		{'Terra Cotta', 59},
		{'Electric Blue', 60},
		{'Fog', 61},
		{'Pastel Yellow', 62},
		{'Lily White', 63},
		{'Dark Stone Gray', 64},
		{'Sand Red', 65}
	}

	local function GetCode(Table, Code)
		for i = 1, #Table do
			if Table[i][2] == Code then
				return Table[i][1]
			end
		end
	end

	local ZombieInstances = {'Head', 'Torso', 'Left Arm', 'Right Arm', 'Left Leg', 'Right Leg', 'HumanoidRootPart', 'Control', 'Role', 'ZombieID', 'animations', 'Shirt', 'Pants'}

	local function FindInstances(Model, NeededInstances)
		local FoundInstances = 0

		for _, v in pairs(NeededInstances) do
			if Model:FindFirstChild(v) then
				FoundInstances = FoundInstances + 1
			else
				return false
			end
		end

		if FoundInstances == #NeededInstances then return true end
	end

	local function GetZombie()
		for _, v in pairs(Workspace.Zombies:GetDescendants()) do
			if v:IsA('Humanoid') and v.Parent:FindFirstChild('Head') then
				if FindInstances(v.Parent, ZombieInstances) then
					if v.Parent.Role.Value == 'Military' then
						return v.Parent
					end
				end
			end
		end
		for _, v in pairs(Workspace.Zombies:GetDescendants()) do
			if v:IsA('Humanoid') and v.Parent:FindFirstChild('Head') then
				if FindInstances(v.Parent, ZombieInstances) then
					return v.Parent
				end
			end
		end
	end

	local function SpawnZombies(Player, Amount)
		local Zombie = GetZombie()
		if Zombie == nil then return end

		local OldZomb

		if Lighting.Materials:FindFirstChild('Zombie') then
			OldZomb = Lighting.Materials.Zombie
			ChangeParent(OldZomb, ReplicatedStorage)
			repeat wait() until not Materials:FindFirstChild('Zombie')
		end

		ChangeParent(Zombie, Materials)
		repeat wait() until Materials:FindFirstChild('Zombie')

		ChangeParent(Zombie.Humanoid, Zombie.Head)
		repeat wait() until Zombie.Head:FindFirstChild('Humanoid')

		local AmountSpawned = 0
		local ChildAddedFunc
		local AddedZombies = {}
		ChildAddedFunc = Workspace.ChildAdded:Connect(function(Child)
			if Child.Name == 'Zombie' and AddedZombies[Child] == nil then
				AddedZombies[Child] = true

				repeat wait() until FindInstances(Child, ZombieInstances) and Child:FindFirstChild('IsBuildingMaterial')
				if not Child.Parent then return end

				ChangeParent(Child, Workspace.Zombies)
				repeat wait() until Child.Parent == Workspace.Zombies
				local Control = Child.Control
				ChangeParent(Control, ReplicatedStorage)
				ChangeParent(Child.Head:WaitForChild('Humanoid'), Child)
				repeat wait() until Control.Parent == ReplicatedStorage and Child:FindFirstChild('Humanoid')

				spawn(function()
					if Player.Character ~= nil and Player.Character:FindFirstChild('Head') then
						ChangeParent(Control, Child)
						repeat wait() until Child:FindFirstChild('Control')
						Remote.ReplicateModel:FireServer(Child, CFrame.new(0, 0, 0) + Player.Character.Head.Position + Vector3.new(math.random(-15, 15), 0, math.random(-15, 15)))
					else
						Delete(Control)
						Delete(Child)
					end
				end)
			end
		end)

		for i = 1, Amount do
			if not Player.Character or not Player.Character.Head then break end
			Remote.PlaceMaterial:FireServer('Zombie', Player.Character.Head.Position + Vector3.new(math.random(-15, 15), 5, math.random(-15, 15)))
			wait(0.1)
		end

		wait(1)

		Delete(Zombie)
		if OldZomb then
			ChangeParent(OldZomb, Materials)
		end
	end

	local FullBrightOn = false
	local DisableZoomLimiter = false

	library:AddConnection(Lighting:GetPropertyChangedSignal('ClockTime'), function()
		if Lighting.ClockTime ~= 12 and FullBrightOn == true then
			Lighting.ClockTime = 14
		end
	end)
	library:AddConnection(Lighting:GetPropertyChangedSignal('Brightness'), function()
		if Lighting.Brightness ~= 1 and FullBrightOn == true then
			Lighting.Brightness = 1
		end
	end)
	library:AddConnection(Client:GetPropertyChangedSignal('CameraMaxZoomDistance'), function()
		if Client.CameraMaxZoomDistance ~= 1150 and DisableZoomLimiter == true then
			Client.CameraMaxZoomDistance = 1150
			if Client.PlayerGui:FindFirstChild('CameraZoom') then
				local CameraZoom = Client.PlayerGui.CameraZoom
				if Client:FindFirstChild('CameraZoom') then
					CameraZoom:Destroy()
				else
					CameraZoom.Parent = MakeStorage(Client)
				end
			end
		end
	end)

	library:AddConnection(Workspace.ChildAdded, function(child)
		if table.find(VehiclesList, child.Name) then
			ChangeParent(child, Vehicles)
		end
	end)

	local function FindItemsInLighting(Item)
		if LootDrops:FindFirstChild(tostring(Item)) then
			return LootDrops[tostring(Item)], LootDrops
		end
		for _, v in pairs(Lighting:GetChildren()) do
			if v.Name == tostring(Item) and v:IsA('Model') then
				return v, v.Parent
			elseif v.Name ~= 'Materials' and v:FindFirstChild(tostring(Item)) then
				return v[tostring(Item)], v
			end
		end
		for _, v in pairs(ReplicatedStorage:GetChildren()) do
			if v.Name == tostring(Item) and v:IsA('Model') then
				return v, v.Parent
			elseif v:FindFirstChild(tostring(Item)) then
				return v[tostring(Item)], v
			end
		end
	end

	local function PlaceItem(Item, Pos, Val)
		pcall(function()
			if Materials[tostring(Item)]:FindFirstChild('Head') then
				Remote.PlaceMaterial:FireServer(tostring(Item), Pos - Materials[tostring(Item)].Head.Position, false, Val)
			elseif Materials[tostring(Item)]:FindFirstAncestorOfClass('Model') and Materials[tostring(Item)]:FindFirstAncestorOfClass('Model'):FindFirstChild('Head') then
				Remote.PlaceMaterial:FireServer(tostring(Item), Pos - Materials[tostring(Item)]:FindFirstChildOfClass('Model').Head.Position, false, Val)
			end
		end)
	end

	local function SpawnParts(Item, PlrPos, Amount, Val)
		local Prev = nil
		local I
		Item = tostring(Item)
		if not Materials:FindFirstChild(Item) then
			I, Prev = FindItemsInLighting(Item)
			if I ~= nil and Prev ~= nil then
				ChangeParent(I, Materials)
				repeat wait() until Materials:FindFirstChild(Item)
			end
			if LootDrops:FindFirstChild(Item) then
				Prev = LootDrops
				ChangeParent(LootDrops[Item], Materials)
				repeat wait() until Materials:FindFirstChild(Item)
			end
		end
		if Materials:FindFirstChild(Item) then
			if #Materials:FindFirstChild(Item):GetChildren() == 0 then
				return false
			end
			local C
			if Materials[Item]:FindFirstChild('Control') then
				C = Materials[Item]['Control']
				ChangeParent(C, ReplicatedStorage)
			end
			for i = 1, Amount do
				PlaceItem(Item, PlrPos - Vector3.new(0, 10, 0), Val)
				Limiter()
			end
			if C ~= nil then
				ChangeParent(C, Materials[Item])
			end
		end
		if Prev ~= nil then
			ChangeParent(Materials[Item], Prev)
		end
	end

	local function CountParts(TheWS, Item, Val, SPos)
		local Amount = 0
		local Parts = {}
		for _, v in pairs(Workspace:GetChildren()) do
			if TheWS[v] ~= true and v:FindFirstChild('IsBuildingMaterial') and (v:IsA('BasePart') and (v.Position - SPos).Magnitude < 25 and v.Size == Materials[Item].Head.Size or Val == true and (v:FindFirstChild('Head') and (v.Head.Position - SPos).Magnitude < 25 or v:FindFirstChildOfClass('Model') and v:FindFirstChildOfClass('Model'):FindFirstChild('Head') and (v:FindFirstChildOfClass('Model').Head.Position - SPos).Magnitude < 25) and v.Name == Item) then
				Amount = Amount + 1
				table.insert(Parts, v)
			end
		end
		return {Amount, Parts}
	end

	local TakenItems = {}
	local function GetCreatedItem(Par, Item, Val)
		while wait() do
			for _, v in pairs(Par:GetChildren()) do
				if v.Name == tostring(Item) and TakenItems[v] == nil and (Val == nil or Val ~= nil and v.Value == Val) then
					TakenItems[v] = true
					return v
				end
			end
		end
	end

	local function MakeThingsInside(Item, Par)
		for _, v in pairs(Item:GetChildren()) do
			if v.Name ~= 'MaxClip' then
				Remote.AddClothing:FireServer(v.Name, Par, v.Value, '', '')
				repeat wait() until Par:FindFirstChild(v.Name)
				MakeThingsInside(v, Par[v.Name])
			else
				Remote.GroupCreate:FireServer(v.Name)
				local I = GetCreatedItem(Lighting.Groups, v.Name)
				ChangeValue(I, v.Value)
				ChangeParent(I, Par)
				repeat wait() until Par:FindFirstChild(v.Name)
				MakeThingsInside(v, I)
			end
		end
	end

	local SelectableRandomLoot = {}
	for _, v in pairs(LootDrops:GetChildren()) do
		if v:FindFirstChild('ObjectID') then
			table.insert(SelectableRandomLoot, v)
		end
	end
	local function AddItem(Item, Slot)
		if not LootDrops:FindFirstChild(tostring(Item)) and tostring(Item) ~= 'Random' then return elseif tostring(Item) == 'Random' then
			Item = SelectableRandomLoot[math.random(1, #SelectableRandomLoot)]
		end
		Item = LootDrops[tostring(Item)].ObjectID
		Remote.AddClothing:FireServer('ObjectID', Slot, Item.Value, '', '')
		spawn(function()
			local ID = GetCreatedItem(Slot, 'ObjectID', Item.Value)
			for _, v in pairs(ID:GetChildren()) do
				if v.Name == '' then
					Delete(v)
				end
			end
			MakeThingsInside(Item, ID)
			ChangeValue(Slot, 1)
		end)
	end

	local function MakeEmptyModel()
		local TempModel = nil
		for _, v in pairs(Lighting.Hair:GetDescendants()) do
			if v.Name == 'Handle' and v:FindFirstChild('AttachmentPoint') then
				TempModel = v.Parent
				break
			end
		end
		local Char = Client.Character
		local TempTab = {}
		for _, v in pairs(Char:GetChildren()) do
			TempTab[v] = true
		end
		Remote.AttachAccessory:FireServer(TempModel, Char.HumanoidRootPart, CFrame.new(0, -100, 0))
		local Model = nil
		repeat
			wait()
			for _, v in pairs(Char:GetChildren()) do
				if TempTab[v] == nil and tostring(v) == tostring(TempModel) then
					Model = v
					ChangeParent(v, Workspace)
					for _, b in pairs(v:GetChildren()) do
						Delete(b)
						Limiter()
					end
					break
				end
			end
		until Model ~= nil
		return Model
	end

	local function SetDecimal(Number, Amount)
		Number = string.split(tostring(Number), '.')
		local NewNum = Number[1]
		if Number[2] and Amount > 0 then
			NewNum = NewNum .. '.' .. string.sub(Number[2], 1, Amount)
		end
		return NewNum
	end

	local TabVals = {['Kill'] = true, ['Teleport'] = true, ['TeleportIgnore'] = true, ['ToolRemoval'] = true, ['Clothing'] = true, ['FakeStorage'] = true, ['NF'] = true, ['Trip'] = true, ['VehicleSpawn'] = true, ['Dis'] = true, ['Storage'] = true, ['DoUn'] =  true}
	local function HandleSpecial(Item, Tab, Pos, CTab)
		local ItemsTab = {}
		if Item:IsA('BasePart') then
			table.insert(ItemsTab, Item)
		elseif Item:IsA('Model') then
			for _, v in pairs(Item:GetChildren()) do
				if v:IsA('BasePart') then
					table.insert(ItemsTab, v)
				end
			end
		end
		if typeof(Tab[1]) == 'string' then
			Tab = {Tab}
		end
		for a = 1, #Tab do
			if TabVals[Tab[a][1]] == true then
				if Tab[a][1] == 'Storage' and Item:IsA('Model') and Item:FindFirstChild('Head') and Item.Head:FindFirstChild('storage') then
					for _, v in pairs(Item.Head.storage:GetChildren()) do
						local slot = tonumber(string.sub(v.Name, 5))
						if slot and Tab[a][2][slot] then
							AddItem(Tab[a][2][slot], v)
						end
					end
				end
				for i = 1, #ItemsTab do
					if Tab[a][1] == 'FakeStorage' then
						Remote.AddClothing:FireServer('storage', ItemsTab[i], '', 'slot1', '0')
						Limiter()
						if Tab[a]['CID'] == nil and Tab[a]['TRD'] == nil and Tab[a]['MAT'] == nil then
							if CTab['FakeStorage'] == nil then
								local Model = MakeEmptyModel()
								Remote.AddClothing:FireServer('IsBuildingMaterial', Model, '', '', '')
								CTab['FakeStorage'] = Model
							end
							ChangeParent(ItemsTab[i], CTab['FakeStorage'])
						end
						spawn(function()
							repeat
								wait()
							until ItemsTab[i]:FindFirstChild('storage')
							if #Tab[a][2] > 0 then
								AddItem(Tab[a][2][1], ItemsTab[i].storage.slot1)
								Limiter()
							end
							for b = 2, 40 do
								Remote.AddClothing:FireServer('slot' .. tostring(b), ItemsTab[i].storage, '0', '', '')
								Limiter()
								if #Tab[a][2] >= b then
									repeat
										wait()
									until ItemsTab[i].storage:FindFirstChild('slot' .. tostring(b))
									AddItem(Tab[a][2][b], ItemsTab[i].storage['slot' .. tostring(b)])
								end
							end
						end)
					end
				end
			elseif Tab[a][1] == 'Decor' and Item:FindFirstChild('LootCF') and Item:FindFirstChildOfClass('Model') then
				spawn(function()
					local Pos = Item:FindFirstChildOfClass('Model').Head.Position
					repeat wait() until Item:FindFirstChildOfClass('Model').Head.Position ~= Pos
					ChangeParent(Item:FindFirstChildOfClass('Model'), Item.Parent)
					Delete(Item)
					Limiter()
				end)
			end
		end
	end

	local function CheckForStuff(Tab, ID)
		local A = Tab[ID]
		if A == nil then
			A = 'NA'
		end
		return tostring(A)
	end

	local function MoveParts(Items, ItemTab, Spot, Tab, Remove)
		local Broken = false
		local Lowest
		for i = 1, #Items do
			if not Items[i]:FindFirstChild('IsBuildingMaterial') then
				Remote.AddClothing:FireServer('IsBuildingMaterial', Items[i], '', '', '')
			end
			if ItemTab[i] == nil then
				Broken = true
				Delete(Items[i])
			end
			if Items[i]:IsA('BasePart') and Broken ~= true then
				local Pos = ItemTab[i][1]
				if typeof(Pos) ~= 'CFrame' then
					Pos = (ItemTab[i][2] + ItemTab[i][1])
				end
				Pos = Pos + Spot
				Remote.ReplicatePart:FireServer(Items[i], Pos)
				if Lowest == nil or Lowest > Pos.Y then
					Lowest = Pos.Y
				end
			elseif Broken ~= true then
				local Pos = ItemTab[i][1]
				if typeof(Pos) ~= 'CFrame' then
					Pos = ItemTab[i][2] + ItemTab[i][1]
				end
				Pos = Pos + Spot
				if Items[i]:FindFirstChildOfClass('Model') then
					spawn(function()
						local M = Items[i]:FindFirstChildOfClass('Model')
						repeat wait() until M:FindFirstChild('IsBuildingMaterial')
						Remote.ReplicateModel:FireServer(Items[i]:FindFirstChildOfClass('Model'), Pos)
					end)
				else
					Remote.ReplicateModel:FireServer(Items[i], Pos)
				end
				if Lowest == nil or Lowest > Pos.Y then
					Lowest = Pos.Y
				end
				if Items[i].Name == 'Floodlight' then
					fireServer('ToggleFloodLight', Items[i])
					Limiter()
				end
			end
			if ItemTab[i] ~= nil and typeof(ItemTab[i][1]) == 'CFrame' and ItemTab[i][2] ~= nil then
				HandleSpecial(Items[i], ItemTab[i][2], Spot, Tab)
			elseif ItemTab[i] ~= nil and typeof(ItemTab[i][2]) == 'CFrame' and ItemTab[i][3] ~= nil then
				HandleSpecial(Items[i], ItemTab[i][3], Spot, Tab)
			end
			Limiter()
			if Broken ~= true and (ItemTab[i]['CID'] ~= nil or ItemTab[i]['TRD'] ~= nil or ItemTab[i]['MAT'] ~= nil) then
				local CID, TRD, MAT = CheckForStuff(ItemTab[i], 'CID'), CheckForStuff(ItemTab[i], 'TRD'), CheckForStuff(ItemTab[i], 'MAT')
				if MAT == 'NA' then
					MAT = string.sub(tostring(Items[i].Material), 15)
				end
				if TRD == 'NA' then
					TRD = '0'
				end
				local NAM = CID .. ';' .. tostring(Items[i].BrickColor) .. ';' .. TRD .. ';' .. MAT
				if Tab[NAM] == nil then
					local Model = MakeEmptyModel()
					Remote.AddClothing:FireServer('IsBuildingMaterial', Model, '', '', '')
					Tab[NAM] = Model
				end
				ChangeParent(Items[i], Tab[NAM])
				Limiter()
			end
			if Remove == true then
				for _, v in pairs(Items[i]:GetDescendants()) do
					if v.Name == 'IsBuildingMaterial' then
						Delete(v)
					end
				end
			end
		end
		return Lowest, nil
	end

	local function SpawnBase(Tab, Spot, Kick)
		local Lowest
		for _, v in pairs(LootDrops:GetChildren()) do
			if v:FindFirstChild('Head') then
				ChangeParent(v, Materials)
			end
		end
		local CTab = {}
		Notify('Number of Items: ' .. tostring(#Tab), 10)
		local MaxCount = 120
		local CurrentPos = Client.Character.Head.Position
		for i = 1, #Tab do
			local Item = Tab[i]['Item']
			local Amount = Tab[i]['Amount']
			local Whole = Tab[i]['Whole']
			Notify('Item #' .. tostring(i) .. ': ' .. Item .. ',\nAmount: ' .. tostring(#Tab[i]), 10)
			local WS = {}
			for _, v in pairs(Workspace:GetChildren()) do
				WS[v] = true
			end
			local CurrentCount = 0
			local PartsSpawned = true
			if SpawnParts(Item, CurrentPos, Amount, not Whole) ~= false then
				repeat
					CurrentCount = CurrentCount + 1
					if CurrentCount >= MaxCount then
						PartsSpawned = false
						break
					end
					wait()
				until (Whole == false and CountParts(WS, Item, Whole, CurrentPos)[1] == #Materials[Item]:GetChildren() * Amount) or (Whole == true and CountParts(WS, Item, Whole, CurrentPos)[1] == Amount)
				if PartsSpawned then
					local PartsTab = CountParts(WS, Item, Whole, CurrentPos)[2]
					local L = MoveParts(PartsTab, Tab[i], Spot, CTab, Kick)
					if L ~= nil and (Lowest == nil or Lowest > L) then
						Lowest = L
					end
				end
			end
		end
		for i, v in pairs(CTab) do
			if #string.split(i, ';') == 4 then
				local Spl = string.split(i, ';')
				local CID, TRD, MAT = Spl[1], tonumber(Spl[3]), Spl[4]
				if TRD == nil then
					TRD = 0
				end
				repeat wait() until v.Parent:IsA('Model')
				if tonumber(CID) ~= nil then
					ColorModel(v, tonumber(CID), 1, true)
					Limiter()
				end
				fireServer('VehichleLightsSet', v, MAT, TRD)
				Limiter()
				for _, a in pairs(v:GetChildren()) do
					if a:IsA('BasePart') then
						ChangeParent(a, Workspace)
					end
				end
				Delete(v)
			end
		end

		return Lowest
	end

	local ColorsTab = {'Bright red', 'Bright blue', 'Bright green', 'Bright orange', 'Bright yellow', 'Bright bluish green', 'Bright violet', 'Grime', 'Earth green', 'Navy blue', 'Dusty Rose', 'Black', 'Reddish brown', 'Nougat', 'Brick yellow', 'Really blue', 'Really red', 'New Yeller', 'Lime green', 'Hot pink', 'White', 'Really black', 'Deep orange', 'Cyan', 'Slime green', 'Alder', 'Royal purple', 'CGA brown', 'Maroon', 'Gold', 'Cool yellow', 'Cashmere', 'Dirt brown', 'Crimson', 'Institutional white', 'Pearl', 'Baby blue', 'Sea green', 'Salmon', 'Light reddish violet', 'Pink', 'Pastel violet', 'Alder', 'Pastel blue-green', 'Persimmon', 'Quill grey', 'Cool yellow', 'Pastel light blue', 'Br. yellowish orange', 'Laurel green', 'Pastel blue-green', 'Khaki', 'Cashmere', 'Grime', 'Toothpaste', 'Neon orange', 'Teal', 'Camo', 'Terra Cotta', 'Electric blue', 'Fog', 'Pastel yellow', 'Lily white', 'Dark stone grey', 'Sand red'}
	local ViewingTab = {false, 'Name', 'Model'}
	local function PreviewItem(BaseName, Part, Bool, Offset)
		if BaseName == false then
			ViewingTab[1] = false
			ViewingTab[2] = ''
			if ViewingTab[3] ~= nil and typeof(ViewingTab[3]) ~= 'string' then
				ViewingTab[3]:Remove()
			end
			return
		end
		local SpawnPos = Part.Position
		if ViewingTab[1] == true and ViewingTab[2] == BaseName and ViewingTab[3] ~= nil and ViewingTab[4] == Part then
			return
		elseif ViewingTab[1] == true and (ViewingTab[2] ~= BaseName or ViewingTab[4] ~= Part) and ViewingTab[3] ~= nil then
			ViewingTab[3]:Remove()
		end
		if Offset == nil then
			Offset = Vector3.new(0, 0, 0)
		end
		if Bool ==  true then
			local ray = Ray.new(Part.Position, Vector3.new(0, -10, 0))
			local Pt, Pos = Workspace:FindPartOnRayWithIgnoreList(ray, {Part.Parent})
			if Pt ~= nil then
				SpawnPos = Pos
			else
				Offset = Vector3.new(0, -4, 0)
			end
		end
		local Tab = BaseTable[BaseName]
		if Tab['CenterPos'] then
			Part = {Position = Tab['CenterPos'], Parent = Part.Parent}
			Offset = Vector3.new()
			SpawnPos = Part.Position
		end
		local PreviewModel = Instance.new('Model', Workspace)
		PreviewModel.Name = 'Preview'
		local CenterPart = Instance.new('Part', PreviewModel)
		CenterPart.Position = SpawnPos + Offset
		CenterPart.Size = Vector3.new(1, 1, 1)
		CenterPart.CanCollide = false
		CenterPart.CanQuery = false
		CenterPart.Anchored = true
		CenterPart.Transparency = 1
		PreviewModel.PrimaryPart = CenterPart
		ViewingTab[1] = true
		ViewingTab[2] = BaseName
		ViewingTab[3] = PreviewModel
		for i = 1, #Tab do
			local Item = Tab[i]['Item']
			local Whole = Tab[i]['Whole']
			local TempItem = Materials:FindFirstChild(Item)
			if not TempItem then
				TempItem = FindItemsInLighting(Item)
			end
			if TempItem ~= nil then
				if Whole == false then
					TempItem = TempItem:FindFirstChild('Head')
				end
				if TempItem:IsA('Model') then
					TempItem.PrimaryPart = GetPart(TempItem)
				end
				for a = 1, #Tab[i] do
					local C = TempItem:Clone()
					C.Parent = PreviewModel
					if C:IsA('Part') or C:IsA('TrussPart') then
						C.CanQuery = false
					elseif C:IsA('Model') then
						for _, part in pairs(C:GetDescendants()) do
							if part:IsA('Part') or part:IsA('TrussPart') then
								part.CanQuery = false
							end
						end
					end
					local Pos = Tab[i][a][1]
					if typeof(Tab[i][a][2]) == 'CFrame' then
						Pos = Tab[i][a][2] + Pos
					end
					if C:IsA('BasePart') then
						if Tab[i][a]['CID'] ~= nil and ColorsTab[tonumber(Tab[i][a]['CID'])] ~= nil then
							C.BrickColor = BrickColor.new(ColorsTab[tonumber(Tab[i][a]['CID'])])
						end
						C.Transparency = 0.6
						C.CanCollide = false
						C.CFrame = Pos + CenterPart.Position
					else
						for _, v in pairs(C:GetDescendants()) do
							if v:IsA('BasePart') then
								v.Transparency = 0.6
								v.CanCollide = false
							end
						end
						C:SetPrimaryPartCFrame(Pos + CenterPart.Position)
					end
				end
			end
		end
		if not Tab['CenterPos'] then
			spawn(function()
				repeat
					wait()
					if PreviewModel.PrimaryPart ~= nil then
						local PPos = Part.Position
						if Bool then
							local ray = Ray.new(Part.Position, Vector3.new(0, -10, 0))
							local Pt, Pos = Workspace:FindPartOnRayWithIgnoreList(ray, {Part.Parent, PreviewModel})
							PPos = PPos-Vector3.new(0,-4,0)
							if Pt ~= nil then
								PPos = Pos
							end
						end
						PreviewModel:SetPrimaryPartCFrame(CFrame.new(PPos))
					end
				until ViewingTab[1] == false or ViewingTab[2] ~= BaseName or ViewingTab[3] ~= PreviewModel
			end)
		end
	end

	local function SpawnBaseF(Plr, BaseToSpawn, UseHead, Kick, UseRay)
		if (typeof(BaseToSpawn) == 'table' and BaseToSpawn['MapSpecific'] and BaseToSpawn['MapSpecific'] ~= Mapname) then
			local Problem = 'This base is for ' .. BaseToSpawn['MapSpecific'] .. ' only'
			return Problem
		end
		local Part = Plr.Character.Head
		local Pos
		if BaseToSpawn['CenterPos'] then
			Part = {Position = BaseToSpawn['CenterPos'], Parent = LootDrops}
			Pos = BaseToSpawn['CenterPos']
		elseif UseHead == true then
			Pos = Part.Position - Vector3.new(0, 12, 0)
		elseif UseRay == true then
			local ray = Ray.new(Part.Position, Vector3.new(0, -10, 0))
			local Ignores = {Part.Parent}
			local Tab = {Workspace:FindPartOnRayWithIgnoreList(ray, Ignores)}
			Pos = Part.Position - Vector3.new(0, 4, 0)
			if Tab[1] ~= nil then
				Pos = Tab[2]
			end
		else
			Pos = Part.Position
		end
		SpawnBase(BaseToSpawn, Pos, Kick)
	end

	local MousePart = Instance.new('Part')
	MousePart.Parent = Workspace
	MousePart.Name = 'AyarumMouse'
	MousePart.Size = Vector3.new(1, 1, 1)
	MousePart.Transparency = 1
	MousePart.CanCollide = false
	MousePart.Anchored = true
	MousePart.CanQuery = false

	local ImportWaiting = false
	library:AddConnection(InputService.InputBegan, function(input)
		if ImportWaiting == true and input.KeyCode == Enum.KeyCode.Return then
			ImportWaiting = false
			local SelectedBase = library.flags['Selected Base']
			SelectedBase = string.split(SelectedBase, ' (')[1]

			PreviewItem(false)
			if Notloaded(Client) then return end

			local Timer = os.time()

			Notify('Please Wait...')
			local FakePlayer = {
				Character = {
					Head = {
						Position = MousePart.Position,
						Parent = Client.Character
					}
				}
			}
			SpawnBaseF(FakePlayer, BaseTable[SelectedBase], false, not library.flags['Movable'], false)
			Notify('Imported ' .. SelectedBase .. ' in ' .. SetDecimal(os.time() - Timer, 1) .. 's')
		elseif ImportWaiting == true and input.KeyCode == Enum.KeyCode.Backspace then
			ImportWaiting = false
			Notify('Cancelled')
			PreviewItem(false)
		end
	end)

	local WalkEnabled = false
	local WalkValue = 16
	local JumpEnabled = false
	local JumpValue = 50
	local Walks = {
		{'C4Placed', false},
		{'VS50Placed', false},
		{'TM46Placed', false}
	}
	library:AddConnection(RunService.RenderStepped, function()
		if Client.PlayerGui:FindFirstChild('SkyboxRenderMode') then
			Client.PlayerGui.SkyboxRenderMode:Remove()
		end
		if WalkEnabled then
			getrenv()._G.walkbase = WalkValue
		end
		if JumpEnabled and Client.Character ~= nil and Client.Character:FindFirstChild('Humanoid') then
			Client.Character.Humanoid.JumpPower = JumpValue
		end
		for _, Info in pairs(Walks) do
			local Item = Info[1]
			local Enabled = Info[2]
			if Enabled == true and Materials:FindFirstChild(tostring(Item)) and Client.Character ~= nil then
				Remote.PlaceC4:FireServer(Materials[tostring(Item)], Client.Character.Torso.Position - Vector3.new(0, -2.9, 0), true)
			end
		end
	end)

	local Banned = {}
	local ServerLock = false
	library:AddConnection(Players.PlayerAdded, function(player)
		player = player.Name
		if isfolder('Ayarum') and isfile('Ayarum/AutoBans.json') then
			local Info = readfile('Ayarum/AutoBans.json')
			local DecodedInfo = HttpService:JSONDecode(Info)
			if typeof(DecodedInfo) == 'table' then
				if table.find(DecodedInfo, player) then
					KickPlayer(player)
					Notify('Kicked ' .. player .. ' [AutoBan]')
					return
				end
			end
		end
		if table.find(Banned, player) then
			KickPlayer(player)
			Notify('Kicked ' .. player .. ' [Banned]')
			return
		end
		if ServerLock then
			KickPlayer(player)
			Notify('Kicked ' .. player .. ' [ServerLock]')
			return
		end

		library.options['Player Selection']:AddValue(player)
		library.options['Spawn Player']:AddValue(player)
		library.options['Base Player']:AddValue(player)
		library.options['Vehicle Player']:AddValue(player)
		library.options['Gun Player']:AddValue(player)
	end)
	library:AddConnection(Players.PlayerRemoving, function(player)
		player = player.Name
		library.options['Player Selection']:RemoveValue(player)
		library.options['Spawn Player']:RemoveValue(player)
		library.options['Base Player']:RemoveValue(player)
		library.options['Vehicle Player']:RemoveValue(player)
		library.options['Gun Player']:RemoveValue(player)
	end)

	local PlayerList = {'All', 'Others'}
	local PlayerList2 = {}
	local LocationList = {}
	local AutoBanList = {}
	local TexturesList = {}
	local ColorsList = {}
	local BaseList = {}
	local VehicleList = {'All', 'Others', 'Current'}

	local function CheckForWreckage(Veh)
		local CheckFunc
		local OldName = Veh.Name
		local Removed = false
		CheckFunc = Veh:GetPropertyChangedSignal('Name'):Connect(function()
			if Veh.Name == 'VehicleWreck' then
				if Removed == true then return end
				Removed = true
				local ThisOrder = Veh:FindFirstChild('AyarumValue')
				if not ThisOrder then return end
				ThisOrder = ThisOrder.Value
				Veh.AyarumValue:Destroy()
				local ToRemove = {}
				for _, v in pairs(VehicleList) do
					if v == 'All' or v == 'Others' or v == 'Current' then continue end
					local Info = string.split(v, ') ')
					local Vehicle = Info[2]
					local Order = tonumber(string.sub(Info[1], 2, #Info[1]))
					if Vehicle == OldName then
						if Order >= ThisOrder then
							table.insert(ToRemove, v)
						end
					end
				end
				for _, v in pairs(ToRemove) do
					library.options['Vehicle']:RemoveValue(v)
				end
				for _, v in pairs(Vehicles:GetChildren()) do
					if v.Name == OldName and v:FindFirstChild('AyarumValue') then
						local Order = v.AyarumValue.Value
						if Order >= ThisOrder then
							v.AyarumValue:Remove()
							local Amount = 1
							for _, a in pairs(VehicleList) do
								if a == 'All' or a == 'Others' or a == 'Current' then continue end
								if string.split(a, ') ')[2] == v.Name then
									Amount = Amount + 1
								end
							end
							library.options['Vehicle']:AddValue('(' .. tostring(Amount) .. ') ' .. v.Name)
							local Val = Instance.new('IntValue')
							Val.Name = 'AyarumValue'
							Val.Parent = v
							Val.Value = Amount
						end
					end
				end
				CheckFunc:Disconnect()
			end
		end)
	end

	for _, v in pairs(Vehicles:GetChildren()) do
		if v.Name ~= 'VehicleWreck' then
			local Amount = 1
			for _, a in pairs(VehicleList) do
				if a == 'All' or a == 'Others' or a == 'Current' then continue end
				if string.split(a, ') ')[2] == v.Name then
					Amount = Amount + 1
				end
			end
			table.insert(VehicleList, '(' .. tostring(Amount) .. ') ' .. v.Name)
			local Val = Instance.new('IntValue')
			Val.Name = 'AyarumValue'
			Val.Parent = v
			Val.Value = Amount
			CheckForWreckage(v)
		end
	end
	library:AddConnection(Vehicles.ChildAdded, function(Child)
		if Child.Name == 'VehicleWreck' then return end
		if Child:FindFirstChild('Unweld') then
			Child.Unweld:Remove()
			return
		end
		local Amount = 1
		for _, v in pairs(VehicleList) do
			if v == 'All' or v == 'Others' or v == 'Current' then continue end
			if string.split(v, ') ')[2] == Child.Name then
				Amount = Amount + 1
			end
		end
		library.options['Vehicle']:AddValue('(' .. tostring(Amount) .. ') ' .. Child.Name)
		if Child:FindFirstChild('AyarumValue') then
			Child.AyarumValue:Remove()
		end
		local Val = Instance.new('IntValue')
		Val.Name = 'AyarumValue'
		Val.Parent = Child
		Val.Value = Amount
		CheckForWreckage(Child)
	end)
	library:AddConnection(Vehicles.ChildRemoved, function(Child)
		if Child.Name == 'VehicleWreck' or Child:FindFirstChild('Unweld') then return end
		local ThisOrder = Child:FindFirstChild('AyarumValue')
		if not ThisOrder then return end
		ThisOrder = ThisOrder.Value
		local ToRemove = {}
		for _, v in pairs(VehicleList) do
			if v == 'All' or v == 'Others' or v == 'Current' then continue end
			local Info = string.split(v, ') ')
			local Vehicle = Info[2]
			local Order = tonumber(string.sub(Info[1], 2, #Info[1]))
			if Vehicle == Child.Name then
				if Order >= ThisOrder then
					table.insert(ToRemove, v)
				end
			end
		end
		for _, v in pairs(ToRemove) do
			library.options['Vehicle']:RemoveValue(v)
		end
		for _, v in pairs(Vehicles:GetChildren()) do
			if v.Name == Child.Name and v:FindFirstChild('AyarumValue') then
				local Order = v.AyarumValue.Value
				if Order >= ThisOrder then
					v.AyarumValue:Remove()
					local Amount = 1
					for _, a in pairs(VehicleList) do
						if a == 'All' or a == 'Others' or a == 'Current' then continue end
						if string.split(a, ') ')[2] == v.Name then
							Amount = Amount + 1
						end
					end
					library.options['Vehicle']:AddValue('(' .. tostring(Amount) .. ') ' .. v.Name)
					local Val = Instance.new('IntValue')
					Val.Name = 'AyarumValue'
					Val.Parent = v
					Val.Value = Amount
				end
			end
		end
	end)
	for _, v in pairs(Players:GetPlayers()) do
		table.insert(PlayerList, v.Name)
		if v ~= Client then
			table.insert(PlayerList2, v.Name)
		end
	end
	for _, v in pairs(Workspace.Locations:GetChildren()) do
		if v:IsA('Part') then
			table.insert(LocationList, v.Name)
		end
	end
	if isfolder('Ayarum') and isfile('Ayarum/AutoBans.json') then
		local Info = readfile('Ayarum/AutoBans.json')
		local DecodedInfo = HttpService:JSONDecode(Info)
		if typeof(DecodedInfo) == 'table' then
			for _, v in pairs(DecodedInfo) do
				table.insert(AutoBanList, v)
			end
		end
	end
	for _, v in pairs(TextureCodes) do
		local Filler = v[2] < 10 and '0' or ''
		table.insert(TexturesList, '(' .. Filler .. tostring(v[2]) .. ') ' .. v[1])
	end
	for _, v in pairs(ColorCodes) do
		local Filler = v[2] < 10 and '0' or ''
		table.insert(ColorsList, '(' .. Filler .. tostring(v[2]) .. ') ' .. v[1])
	end
	for i, v in pairs(BaseTable) do
		local Suffix: string = ''
		if v['MapSpecific'] then
			local Name = v['MapSpecific'] == 'Reimagined' and 'Reim' or v['MapSpecific']
			Suffix = ' (' .. Name .. ')'
		end
		table.insert(BaseList, i .. Suffix)
	end

	local ItemMaterials = {
		['Material1'] = 'WoodenSlabs',
		['Material2'] = 'Bricks',
		['Material3'] = 'StoneBricks',
		['Material4'] = 'Timber',
		['Material5'] = 'StoneWalls',
		['Material6'] = 'WoodenPlanks',
		['Material7'] = 'Truss',
	}

	local function GetItemName(str)
		if str == nil or str == '' then return end

		for Original, MaterialName in pairs(ItemMaterials) do
			if MaterialName:lower() == str:lower() then
				return Original
			end
		end
		for Original, MaterialName in pairs(ItemMaterials) do
			if MaterialName:lower():sub(1, #str) == str:lower() then
				return Original
			end
		end

		for _, Item in pairs(LootDrops:GetChildren()) do
			local Original = Item.Name
			Item = Item.Name
			if Item:lower() == str:lower() then
				return Original
			end
		end
		for _, Item in pairs(LootDrops:GetChildren()) do
			local Original = Item.Name
			Item = Item.Name
			if Item:lower():sub(1, #str) == str:lower() then
				return Original
			end
		end
		return
	end

	local GoddedHumanoids = {}
	local function God()
		if Notloaded(Client) or Notspawned(Client) then return end
		if GoddedHumanoids[Client.Character.Humanoid] == true then
			Notify('You already have Infinite Health!')
			return
		end
		GoddedHumanoids[Client.Character.Humanoid] = true
		spawn(function()
			pcall(function()
				while Client.Character.Humanoid ~= nil and library do
					if Client.Character.Humanoid.Health ~= 100 then
						Client.Character.Humanoid.Health = 100
					end
					wait()
				end
			end)
		end)
		fireServer('Damage', Client.Character.Humanoid, math.huge)
		Notify('Gave ' .. Client.Name .. ' Infinite Health')
	end

	local function ColorMap(Color, Texture)
		if game.PlaceId == 237590761 or game.PlaceId == 302647266 or game.PlaceId == 1228676522 or game.PlaceId == 1228677045 then
			Notify('Coloring and Texturing is disabled on ' .. Mapname)
			return
		elseif not Workspace:FindFirstChild('Anchored Objects') then
			Notify('Map is removed!')
			return
		end
		local Plates = Workspace['Anchored Objects'].Plates
		if game.PlaceId == 237590657 or game.PlaceId == 1228674372 then
			ColorModel(Plates, Color, Texture)
			for _, v in pairs(Plates.Hills:GetDescendants()) do
				if v:IsA('Model') then
					ColorModel(v, Color, Texture)
				end
			end
		elseif game.PlaceId == 290815963 or game.PlaceId == 1228677761 then
			ColorModel(Plates.Plates, Color, Texture)
			for _, v in pairs(Plates.Hills:GetDescendants()) do
				if v:IsA('Model') then
					ColorModel(v, Color, Texture)
				end
			end
		end
		Notify('Set ' .. Mapname .. '\'s Color to ' .. GetCode(ColorCodes, Color) .. ' and Texture to ' .. GetCode(TextureCodes, Texture))
	end

	local function GetVeh()
		local ReturnList = {}
		if library.flags['Vehicle'] == 'Current' then
			for _, v in pairs(Vehicles:GetDescendants()) do
				if v.Name ~= 'VehicleWreck' and v:IsA('Weld') and v.Name == 'SeatWeld' and v.Part1 ~= nil and v.Part1.Parent.Name == Client.Name then
					if v.Parent.Parent.Parent.Name == 'Seats' then
						table.insert(ReturnList, v.Parent.Parent.Parent.Parent)
					else
						table.insert(ReturnList, v.Parent.Parent.Parent)
					end
				end
			end
		elseif library.flags['Vehicle'] == 'All' then
			for _, v in pairs(Workspace.Vehicles:GetChildren()) do
				if v.Name ~= 'VehicleWreck' then
					table.insert(ReturnList, v)
				end
			end
		elseif library.flags['Vehicle'] == 'Others' then
			local SeatFound = false
			for _, v in pairs(Vehicles:GetDescendants()) do
				if v.Name ~= 'VehicleWreck' and v:IsA('Weld') and v.Name == 'SeatWeld' and v.Part1 ~= nil and v.Part1.Parent.Name == Client.Name then
					if v.Parent.Parent.Parent.Name == 'Seats' then
						SeatFound = v.Parent.Parent.Parent.Parent
					else
						SeatFound = v.Parent.Parent.Parent
					end
				end
			end
			if SeatFound ~= false then
				for _, v in pairs(Workspace.Vehicles:GetChildren()) do
					if v.Name ~= 'VehicleWreck' and v ~= SeatFound then
						table.insert(ReturnList, v)
					end
				end
			else
				for _, v in pairs(Vehicles:GetChildren()) do
					if v.Name ~= 'VehicleWreck' then
						table.insert(ReturnList, v)
					end
				end
			end
		else
			local Info = string.split(library.flags['Vehicle'], ') ')
			local Vehicle = Info[2]
			if library.flags['sameType'] == true then
				for _, v in pairs(Vehicles:GetChildren()) do
					if v.Name == Vehicle then
						table.insert(ReturnList, v)
					end
				end
			else
				local Order = string.sub(Info[1], 2, #Info[1])
				for _, v in pairs(Vehicles:GetChildren()) do
					if v.Name == Vehicle and v:FindFirstChild('AyarumValue') and v.AyarumValue.Value == tonumber(Order) then
						table.insert(ReturnList, v)
					end
				end
			end
		end
		return ReturnList
	end

	local MatsList = {'Smooth Plastic', 'Plastic', 'Wood', 'Slate', 'Concrete', 'Corroded Metal', 'Diamond Plate', 'Foil', 'Grass', 'Ice', 'Marble', 'Granite', 'Brick', 'Pebble', 'Sand', 'Fabric', 'Metal', 'Wood Planks', 'Cobblestone', 'Neon', 'Glass', 'Force Field'}

	local Outfits = {
		{
			Name = 'Special Operations',
			Hat = 7019,
			Accessory = 8009,
			Shirt = 116109084,
			Pants = 116109135
		}, {
			Name = 'Jungle Camo',
			Hat = 7017,
			Accessory = 8009,
			Shirt = 116109064,
			Pants = 116109123
		}, {
			Name = 'Urban Camo',
			Hat = 7018,
			Accessory = 8009,
			Shirt = 116109073,
			Pants = 116109125
		}, {
			Name = 'Desert Camo',
			Hat = 7016,
			Accessory = 8002,
			Shirt = 116109070,
			Pants = 116109116
		}, {
			Name = 'Snow Camo',
			Hat = 7003,
			Accessory = 8005,
			Shirt = 116109082,
			Pants = 116109132
		}
	}

	local function ChangeClothing(Player, Clothing, ID)
		local Char = Player.playerstats.character
		local Object = Char:FindFirstChild(string.lower(Clothing))
		if not Object then return end
		local ClothingID = Object.ObjectID:FindFirstChild(Clothing)
		if not ClothingID then return end
		ChangeValue(ClothingID, tostring(ID))
		local DeleteFunc
		DeleteFunc = Object.ChildAdded:Connect(function(Ch)
			wait()
			Delete(Ch)
			DeleteFunc:Disconnect()
		end)
		Remote.AddClothing:FireServer('Dummy', Object, '', '', '')
	end

	local function AddID(Player, Slot, ID)
		ID = getrenv()._G.Obfuscate(ID)
		Remote.AddClothing:FireServer('ObjectID', Player, ID, '', '')
		Player:WaitForChild('ObjectID')
		for _, v in pairs(Player.ObjectID:GetChildren()) do
			Delete(v)
			repeat wait() until v.Parent == nil
		end
		ChangeParent(Player.ObjectID, Slot)
		ChangeValue(Slot, 1)
		Slot:WaitForChild('ObjectID')
	end

	local function Unweld(Veh, Val)
		for _, v in pairs(Veh:GetDescendants()) do
			if v:IsA('Weld') and (not string.find(v.Parent.Name, 'Icon') and v.Parent.Name ~= 'Base' and v.Parent.CanCollide == true or Val ==  true) then
				Delete(v)
			end
		end
	end
	local function Pancake(Veh)
		local Notice = Instance.new('BoolValue')
		Notice.Name = 'Unweld'
		Notice.Value = true
		Notice.Parent = Veh
		Unweld(Veh)
		wait(1.2)
		ChangeParent(Veh, Lighting)
		ChangeParent(Veh, Vehicles)
	end

	local Clothing = {
		['Silenced Squad Camo'] = {
			337129807,
			337130336
		},
		['Big Smoke Camo'] = {
			593699904,
			415701837
		},
		['Shenanigans Mod Camo'] = {
			588584241,
			159218882
		},
		['Blood Camo'] = {
			215316057,
			215316131
		},
		['Bright Red Camo'] = {
			568952825,
			466961351
		},
		['Apocalypse Rising Bright Pink'] = {
			467600288,
			467600429
		},
		['Apocalypse Rising Galaxy Blue'] = {
			510178412,
			510178635
		},
		['Red & Black & White Camo'] = {
			473519774,
			473519972
		},
		['Red & White Camo'] = {
			472480924,
			472323288
		},
		['Blue & Black Splattered paint'] = {
			467173965,
			467174397
		},
		['Galaxy Red Camo'] = {
			467531032,
			467531149
		},
		['Green Camo'] = {
			593700583,
			466869006
		},
		['Pink Gusmanak'] = {
			174147656,
			174147930
		},
		['Yellow Zolar'] = {
			229993750,
			222311494
		},
		['Blue Zolar'] = {
			198624220,
			198624035
		},
		['Red ZolarKeth'] = {
			184800610,
			184800783
		},
		['Purple Zolar'] = {
			187543757,
			187543760
		},
		['Gusmanak Ice'] = {
			242698915,
			242698963
		},
		['Gusmanak Green & Gray'] = {
			233505839,
			233505875
		},
		['Light Blue Camo'] = {
			621320757,
			621321071
		},
		['Gusmanak Tan & Beige'] = {
			525673005,
			525673313
		},
		['Light pink Camo'] = {
			608942892,
			608173166
		},
		['DS Uniform - red space'] = {
			772679941,
			815303433
		},
		['Vapor'] = {
			929357729,
			929360510
		},
		['Somnum'] = {
			929374243,
			929375454
		},
		['Retaliation'] = {
			929368028,
			929368521
		},
		['DS Unifor'] = {
			2122445354,
			2122447731
		},
		['Honeybager'] = {
			929373244,
			929373657
		},
		['Diaamnd Old Uniform'] = {
			929353581,
			929354110
		},
		['Oof! Uniform'] = {
			929349688,
			929350308
		},
		['D-3 Uniform'] = {
			929345322,
			929345896
		},
		['Euphoric Uniform'] = {
			929356714,
			929357125
		},
		['Mist Uniform'] = {
			929355529,
			929356057
		},
		['Cunning Biscuit Uniform'] = {
			659265006,
			659265396
		},
		['TanqR Uniform'] = {
			929370461,
			929370906
		},
		['Hayha Revisited'] = {
			649122210,
			649122414
		},
		['Oblivian Uniform'] = {
			457164559,
			457164804
		},
		['Royal Era Uniform'] = {
			397516365,
			397516464
		},
		['H_Squad Uniform'] = {
			454654104,
			454654195
		},
		['Swarm Squad Uniform'] = {
			435063632,
			435063707
		},
		['D-3 Squad Uniform'] = {
			413185337,
			413185478
		},
		['Termination Uniform'] = {
			399810161,
			399810060
		},
		['Diaamnd Uniform'] = {
			397517096,
			397517173
		},
		['D-3 Uniform 2'] = {
			397516801,
			397516931
		},
		['Gus Rainbow'] = {
			218966904,
			218968778
		},
		['Winter Camo'] = {
			4528536166,
			4528536651
		},
		['Red splash'] = {
			201524314,
			201524555
		},
		['Blatto uniform'] = {
			337128174,
			337128215
		},
		['Canadian Armed Forces Uniform'] = {
			239576236,
			239574835
		},
		['Green Skeleton'] = {
			688551640,
			404609258
		},
		['Purple KS'] = {
			415680101,
			415680101
		},
		['Gus Dark Grey & Green'] = {
			237129536,
			195009358
		},
		['Gus Original'] = {
			201064170,
			201064197
		},
		['Gus Red & Dark Blue'] = {
			180686042,
			180754089
		},
		['Gus Purple & Cyan'] = {
			221085596,
			238763451
		},
		['Gus Yellow & Black'] = {
			163062897,
			185545016
		},
		['Gus Purple & Black'] = {
			168825224,
			168825280
		},
		['Gus Orange & Black'] = {
			166690305,
			166690653
		},
		['Paradox Uniform'] = {
			1799543924,
			1745660911
		},
		['DIAAMND dmndOG Old Uniform '] = {
			874977426,
			874927167
		},
		['DIAAMND dmndOG Old Uniform - green'] = {
			880411509,
			880412103
		},
		['DIAAMND dmndOG Old Uniform - purple'] = {
			880414013,
			880414613
		},
		['DIAAMND dmndOG Old Uniform - yellow'] = {
			880410307,
			880410864
		},
		['TanqR Uniform - Dark Blue'] = {
			863735908,
			863736115
		},
		['TanqR Uniform - Black'] = {
			1273422971,
			1273426526
		},
		['TanqR Uniform - White'] = {
			1273423290,
			1273426873
		},
		['TanqR Uniform - Red'] = {
			1273423680,
			1273427710
		},
		['TanqR Uniform - Purple'] = {
			1273423998,
			1273427917
		},
		['TanqR Uniform - Green'] = {
			1273424160,
			1273428132
		},
		['TanqR Uniform - Light Blue'] = {
			1273424336,
			1273428372
		},
		['TanqR Uniform Pink'] = {
			1273425294,
			1273428921
		},
		['Tanqr Christmas Jumper - Green and Black'] = {
			4472633019,
			4472637694
		},
		['Tanqr Christmas Jumper - Red and Black'] = {
			4472617967,
			4472617431
		},
		['Tanqr Christmas Jumper - Light Blue and White'] = {
			4472577026,
			4472576077
		},
		['Tanqr Christmas Jumper - Red and White'] = {
			4472609821,
			4472610584
		},
		['Tanqr Christmas Jumper - Green and Red'] = {
			4472600497,
			4472593833
		},
		['Tanqr Christmas Jumper - Blue and Black'] = {
			4472705661,
			4472706341
		}
	}

	spawn(function()
		while wait(0.25) and library do
			for _, Veh in pairs(Vehicles:GetChildren()) do
				if Veh:FindFirstChild('AyarumRepair') and Veh:FindFirstChild('Wheels') and Veh.Essentials.Details:FindFirstChild('Windows') then
					for _, Wheel in pairs(Veh.Wheels:GetChildren()) do
						if Wheel.Wheel.Transparency == 1 then
							fireServer('WheelVisibleSet', Wheel, 'Armored')
						end
					end
					for _, Window in pairs(Veh.Essentials.Details.Windows:GetChildren()) do
						if Window.Transparency == 1 then
							fireServer('WindowArmorSet', Veh.Essentials.Details:FindFirstChild('Windows'), 'Ballistic')
							break
						end
					end
				end
			end
		end
	end)

	local function AddZombieCheck()
		library:AddConnection(Workspace.Zombies.ChildAdded, function(Child)
			if (Child.Name == 'Zombie' or Child:FindFirstChild('Humanoid')) and library.flags['Disable Zombies'] == true then
				Delete(Child)
			end
		end)
		for _, v in pairs(Workspace.Zombies:GetChildren()) do
			if v.Name ~= 'Zombie' and not v:FindFirstChild('Humanoid') then
				library:AddConnection(v.ChildAdded, function(Child)
					if (Child.Name == 'Zombie' or Child:FindFirstChild('Humanoid')) and library.flags['Disable Zombies'] == true then
						Delete(Child)
					end
				end)
			end
		end
	end

	if Workspace:FindFirstChild('Zombies') then
		AddZombieCheck()
	end

	library:AddConnection(Workspace.ChildAdded, function(child)
		if child.Name == 'Zombies' then
			AddZombieCheck()
		end
	end)

	local VehicleSpeeds = {
		['DeliveryVan'] = {58, 30},
		['Jeep'] = {58, 40},
		['Jeep2'] = {58, 40},
		['Tractor'] = {45, 40},
		['Ambulance'] = {65, 35},
		['Bicycle'] = {36, 28},
		['SportsCar'] = {85, 28},
		['Ural'] = {55, 35},
		['Ural2'] = {55, 35},
		['ATV'] = {52, 46},
		['Motorcycle'] = {58, 36},
		['Pickup'] = {58, 40},
		['Pickup2'] = {58, 40},
		['Firetruck'] = {66, 36},
		['PoliceCar'] = {68, 36},
		['Humvee'] = {62, 40},
		['Humvee2'] = {62, 40},
		['TrinitySUV'] = {62, 42},
		['Motorside'] = {55, 35},
		['Van'] = {56, 30}
	}

	Tabs.Client = library:AddTab('Client')
	Tabs.Players = library:AddTab('Players')
	Tabs.Server = library:AddTab('Server')
	Tabs.Vehicles = library:AddTab('Vehicles')
	Tabs.GunMods = library:AddTab('Gun Mods')
	Tabs.Misc = library:AddTab('Misc')

	Sections.Client = {
		Character = Tabs.Client:AddSection({text = 'Character', column = 1}),
		Other = Tabs.Client:AddSection({text = 'Other', column = 2}),
		Camera = Tabs.Client:AddSection({text = 'Camera', column = 2})
	}
	Sections.Players = {
		Selection = Tabs.Players:AddSection({text = 'Selection', column = 1}),
		Character = Tabs.Players:AddSection({text = 'Character', column = 1}),
		Teleporting = Tabs.Players:AddSection({text = 'Teleporting', column = 2}),
		Moderation = Tabs.Players:AddSection({text = 'Moderation', column = 2}),
		Stats = Tabs.Players:AddSection({text = 'Stats', column = 2}),
		Abusive = Tabs.Players:AddSection({text = 'Abusive', column = 3}),
		Groups = Tabs.Players:AddSection({text = 'Groups', column = 3}),
		Clothing = Tabs.Players:AddSection({text = 'Clothing', column = 3})
	}
	Sections.Server = {
		Selection = Tabs.Server:AddSection({text = 'Selection', column = 1}),
		Map = Tabs.Server:AddSection({text = 'Map', column = 1}),
		Bases = Tabs.Server:AddSection({text = 'Bases', column = 2}),
		AntiLag = Tabs.Server:AddSection({text = 'Anti-Lag', column = 2}),
		Other = Tabs.Server:AddSection({text = 'Other', column = 2})
	}
	Sections.Vehicles = {
		Selection = Tabs.Vehicles:AddSection({text = 'Selection', column = 1}),
		Main = Tabs.Vehicles:AddSection({text = 'Main', column = 1}),
		Abusive = Tabs.Vehicles:AddSection({text = 'Abusive', column = 2}),
		Color = Tabs.Vehicles:AddSection({text = 'Coloring & Texturing', column = 2})
	}
	Sections.GunMods = {
		Selection = Tabs.GunMods:AddSection({text = 'Selection', column = 1}),
		Main = Tabs.GunMods:AddSection({text = 'Main', column = 1}),
		Effects = Tabs.GunMods:AddSection({text = 'Effects', column = 2})
	}
	Sections.Misc = {
		Selection = Tabs.Misc:AddSection({text = 'Selection', column = 1}),
		Spawning = Tabs.Misc:AddSection({text = 'Spawning', column = 1}),
		Skins = Tabs.Misc:AddSection({text = 'Skins', column = 1}),
		Kits = Tabs.Misc:AddSection({text = 'Kits', column = 2})
	}

	local function ReturnPlayers()
		local FromList
		if library.selectedtab == Tabs.Players then
			FromList = library.flags['Player Selection']
		elseif library.selectedtab == Tabs.Server then
			FromList = library.flags['Base Player']
		elseif library.selectedtab == Tabs.Vehicles then
			FromList = library.flags['Vehicle Player']
		elseif library.selectedtab == Tabs.Misc then
			FromList = library.flags['Spawn Player']
		elseif library.selectedtab == Tabs.GunMods then
			FromList = library.flags['Gun Player']
		end
		if not library.loaded or not FromList then return {} end
		local ReturnList = {}
		if FromList == 'All' then
			for _, v in pairs(Players:GetPlayers()) do
				table.insert(ReturnList, v)
			end
		elseif FromList == 'Others' then
			for _, v in pairs(Players:GetPlayers()) do
				if v == Client then continue end
				table.insert(ReturnList, v)
			end
		else
			if Players:FindFirstChild(FromList) then
				table.insert(ReturnList, Players[FromList])
			end
		end
		return ReturnList
	end

	local function GetTextSize(Text, TextSize, Font)
		return game:GetService('TextService'):GetTextSize(Text, TextSize, Font, Vector2.new(9e9, 9e9))
	end

	local function FlashVeh(Veh)
		if not library.fullloaded then return end
		spawn(function()
			local Highlight = Instance.new('Highlight')
			Highlight.Parent = Veh
			Highlight.Adornee = Veh
			Highlight.FillColor = Color3.fromRGB(0, 255, 100)
			Highlight.OutlineColor = Highlight.FillColor
			Highlight.FillTransparency = 1
			Highlight.Name = 'AyarumSelection'
			Highlight.DepthMode = Enum.HighlightDepthMode.Occluded
			Highlight.OutlineTransparency = 1
			QTween(Highlight, 0.5, {FillTransparency = 0.6, OutlineTransparency = 0})
			wait(0.5)
			QTween(Highlight, 0.5, {FillTransparency = 1, OutlineTransparency = 1})
			wait(0.5)
			QTween(Highlight, 0.5, {FillTransparency = 0.6, OutlineTransparency = 0})
			wait(0.5)
			QTween(Highlight, 0.5, {FillTransparency = 1, OutlineTransparency = 1})
			wait(0.5)
			Highlight:Destroy()
		end)
		spawn(function()
			local Pos, OnScreen
			local TextLength = GetTextSize(Veh.Name, 18, Enum.Font.SourceSansLight).X
			local Circle = Drawing.new('Circle')
			local Line = Drawing.new('Line')
			local Text = Drawing.new('Text')
			local Line2 = Drawing.new('Line')
			local Quad = Drawing.new('Quad')

			Circle.Color = Color3.fromRGB(0, 255, 100)
			Circle.Filled = true
			Circle.Radius = 4

			Line.Color = Color3.fromRGB(0, 255, 100)
			Line.Thickness = 1

			Text.Color = Color3.fromRGB(0, 255, 100)
			Text.Text = Veh.Name
			Text.Size = 16
			Text.Font = 3
			Text.ZIndex = 1

			Line2.Color = Color3.fromRGB(0, 255, 100)
			Line2.Thickness = 1

			Quad.Color = Color3.new(0, 0, 0)
			Quad.Transparency = 0.3
			Quad.Filled = true
			Quad.Thickness = 0

			local Loop = RunService.RenderStepped:Connect(function()
				Pos, OnScreen = Camera:WorldToViewportPoint(GetMid(Veh))
				Pos = Vector2.new(Pos.X, Pos.Y)
				Circle.Position = Pos
				Line.From = Pos
				Line.To = Pos + Vector2.new(60, -100)
				Text.Position = Line.To + Vector2.new(5, -20)
				Quad.PointA = Line.To + Vector2.new(TextLength + 15, -20)
				Quad.PointB = Line.To + Vector2.new(0, -20)
				Quad.PointC = Line.To + Vector2.new(0, -1)
				Quad.PointD = Line.To + Vector2.new(TextLength + 15, -1)
				Line2.From = Line.To
				Line2.To = Line.To + Vector2.new(TextLength + 15, 0)

				Line.Visible = OnScreen
				Text.Visible = OnScreen
				Quad.Visible = OnScreen
				Line2.Visible = OnScreen
				Circle.Visible = OnScreen
			end)

			wait(2)
			Loop:Disconnect()
			Line:Remove()
			Text:Remove()
			Quad:Remove()
			Line2:Remove()
			Circle:Remove()
		end)
	end

	local function UpdateGun(Gun)
		if Gun:FindFirstChild('Shooter') then
			local Shooter = Gun.Shooter
			ChangeParent(Shooter, ReplicatedStorage)
			repeat wait() until Shooter.Parent == ReplicatedStorage
			ChangeParent(Shooter, Gun)
		end
	end

	local function GetNameFromID(ID)
		local Deob = getrenv()._G.Deobfuscate(ID)
		for _, v in pairs(LootDrops:GetChildren()) do
			if v:FindFirstChild('ObjectID') and getrenv()._G.Deobfuscate(v.ObjectID.Value) == Deob then
				return v.Name
			end
		end
		return false
	end

	local function GetWeapon(Player, Type)
		local Slot = Player.playerstats.slots['slot' .. Type:lower()]
		if Slot:FindFirstChild('ObjectID') then
			return GetNameFromID(Slot.ObjectID.Value)
		else
			return false
		end
	end

	local function GunStat(Player, Gun, Name, Value)
		local Ob = getrenv()._G.Obfuscate
		Gun = Player.Backpack[Gun]

		local Stats = Gun:FindFirstChild('Stats')
		if not Stats then return end
		local Extra = Stats[Name]:FindFirstChildOfClass(Stats[Name].ClassName)
		if Value then
			if Stats[Name]:FindFirstChild('Rate') then
				ChangeValue(Stats[Name].Rate, Ob(Value))
			else
				Remote.AddClothing:FireServer('Rate', Stats[Name], Ob(Value), '', '')
			end
			repeat wait() until Stats[Name]:FindFirstChild('Rate')
		end
		local set = 1
		if Stats[Name]:IsA('StringValue') then
			set = Ob(set)
		end
		ChangeValue(Stats[Name], set)
		if Extra then
			ChangeValue(Extra, set)
		end
		UpdateGun(Gun)
	end

	local function BulletEffect(Parent, Name, Bool)
		if Bool then
			if ReplicatedStorage.Effects.Bullet:FindFirstChild(Name) then return end
			ChangeParent(Parent:FindFirstChild(Name), ReplicatedStorage.Effects.Bullet)
			Remote.SwitchEnabled:FireServer(true, ReplicatedStorage.Effects.Bullet:WaitForChild(Name))
		else
			if Parent:FindFirstChild(Name) then return end
			ChangeParent(ReplicatedStorage.Effects.Bullet:FindFirstChild(Name), Parent)
		end
	end

	local Bullets = {
		{'Fire', 'FireEffect', Lighting},
		{'Smoke', 'BuildingSmoke', Lighting},
		{'Smoke', 'Smoke', ReplicatedStorage.SpawnPlate.Models.Ural.NotAVehicle.Wheels.RFWheel.Wheel, '2'},
		{'Snow', 'Droplets1', ReplicatedStorage.Snow},
		{'Snow', 'Droplets4', ReplicatedStorage.Snow, '2'},
		{'Rain', 'Droplets', ReplicatedStorage.Rain},
		{'Blood', 'Blood', ReplicatedStorage.Effects},
		{'Sparkle', 'Sparkles', Materials.RoadFlareLit.Tip},
		{'Red light', 'PointLight', Materials.RoadFlareLit.Tip},
		{'Tornado', 'Sheets', ReplicatedStorage.Rain}
	}

	local function MakeInt(Name, Parent, Value)
		Remote.GroupCreate:FireServer(Name)
		local Int = Lighting.Groups:WaitForChild(Name)
		ChangeValue(Int, tonumber(Value))
		ChangeParent(Int, Parent)
		repeat wait() until Int.Parent == Parent
		for _, v in pairs(Int:GetChildren()) do
			Delete(v)
		end
	end

	local function SetSlot(Slot, Item)
		Remote.AddClothing:FireServer('ObjectID', Slot, Item.Value, '', '')
		local ObjectID = Slot:WaitForChild('ObjectID')
		for _, v in pairs(ObjectID:GetChildren()) do
			if v.Name == '' then
				Delete(v)
			end
		end
		if Item:FindFirstChild('Clip') then
			Remote.AddClothing:FireServer('Clip', ObjectID, Item.Clip.Value, '', '')
			local Clip = ObjectID:WaitForChild('Clip')
			for _, v in pairs(Clip:GetChildren()) do
				if v.Name == '' then
					Delete(v)
				end
			end
			for _, v in pairs(Item.Clip:GetChildren()) do
				MakeInt(v.Name, Clip, v.Value)
			end
		end
		ChangeValue(Slot, 1)
	end

	local function LoadKit(Kit, Player)
		WipeInv(Player, true)
		if Kit['backpack'] then
			SetSlot(Player.playerstats.slots.slotbackpack, LootDrops[Kit['backpack']].ObjectID)
		end
		for Slot, Item in pairs(Kit) do
			if Slot == 'backpack' then continue end
			Slot = Player.playerstats.slots:FindFirstChild('slot' .. tostring(Slot))
			Item = LootDrops:FindFirstChild(Item)
			if not Slot or not Item then continue end
			spawn(function()
				SetSlot(Slot, Item.ObjectID)
			end)
			Limiter()
		end
	end
	--[[LoadKit({
		['backpack'] = 'MilitaryPackBlack',
		['primary'] = 'HK21',
		['secondary'] = 'G18',
		'M14Ammo50',
		'M14Ammo50',
		'M14Ammo50',
		'M14Ammo50',
		'M14Ammo50',
		'M14Ammo50',
		'M14Ammo50',
		'M14Ammo50',
		'M9Ammo32',
		'M9Ammo32'
	}, Client)]]

	Sections.Players.Groups:AddButton({text = 'Join Group', callback = function()
		local Player = ReturnPlayers()[1]
		if not Player or CheckGroup(Player) then return end
		Remote.GroupInvite:FireServer(Client, GetGroup(Player))
		Notify('Invited you to ' .. Player.Name .. '\'s Group')
	end})

	Sections.Players.Groups:AddButton({text = 'Invite To Group', callback = function()
		if CheckGroup(Client) then return end
		for _, Player in pairs(ReturnPlayers()) do
			Remote.GroupInvite:FireServer(Player, GetGroup(Client))
			Notify('Invited ' .. Player.Name .. ' to your Group')
		end
	end})

	Sections.Players.Groups:AddButton({text = 'Kick Group', callback = function()
		for _, Player in pairs(ReturnPlayers()) do
			if CheckGroup(Player) then continue end
			Remote.GroupKick:FireServer(Lighting.Groups[GetGroup(Player)], Player)
			Notify('Kicked ' .. Player.Name .. ' from thier Group')
		end
	end})

	Sections.GunMods.Selection:AddList({text = 'Player', flag = 'Gun Player', value = Client.Name, values = PlayerList, max = 20, skipflag = true})
	Sections.GunMods.Selection:AddList({text = 'Weapon', value = 'Primary', values = {'Primary', 'Secondary'}, skipflag = true})
	Sections.GunMods.Selection:AddList({text = 'Attachment', value = 'Acog', values = AttachmentList2, max = 20, skipflag = true})

	for i = 1, #Bullets do
		local Info = Bullets[i]
		local Show = Info[1]
		local Name = Info[2]
		local Parent = Info[3]
		local Suffix = Info[4] ~= nil and (' ' .. Info[4]) or ''
		Sections.GunMods.Effects:AddToggle({text = Show .. ' Bullets' .. Suffix, state = false, skipflag = true, callback = function(bool)
			BulletEffect(Parent, Name, bool)
		end})
	end

	Sections.GunMods.Main:AddButton({text = 'Add Attachment to Weapon', callback = function()
		for _, Player in pairs(ReturnPlayers()) do
			if Notspawned(Player) then return end
			local Weapon = GetWeapon(Player, library.flags['Weapon'])
			if not Weapon then
				Notify(Player.Name .. ' does not have a ' .. library.flags['Weapon'] .. ' Weapon')
				continue
			end
			local Attach = library.flags['Attachment']
			local Attachments = Player.playerstats.attachments[library.flags['Weapon']:lower()]
			local Type = AttachmentList[Attach][1]
			local ID = AttachmentList[Attach][2]
			spawn(function()
				if not Attachments[Type]:FindFirstChild('ObjectID') then
					Remote.AddClothing:FireServer('ObjectID', Attachments[Type], '', '', '')
				end
				Attachments[Type]:WaitForChild('ObjectID')
				ChangeValue(Attachments[Type], 1)
				ChangeValue(Attachments[Type].ObjectID, getrenv()._G.Obfuscate(ID))
				Remote.AddClothing:FireServer('Dummy', Attachments[Type], '', '', '')
				Delete(Attachments[Type]:WaitForChild('Dummy'))
				UpdateGun(Player.Backpack[tostring(Weapon)])
				Notify('Attached a(n) ' .. tostring(Attach) .. ' to ' .. Player.Name .. '\'s ' .. tostring(Weapon))
			end)
		end
	end})
	Sections.GunMods.Main:AddDivider()
	Sections.GunMods.Main:AddButton({text = 'Fast Gun Firerate', callback = function()
		for _, Player in pairs(ReturnPlayers()) do
			if Notspawned(Player) then return end
			local Weapon = GetWeapon(Player, library.flags['Weapon'])
			if not Weapon then
				Notify(Player.Name .. ' does not have a ' .. library.flags['Weapon'] .. ' Weapon')
				continue
			end
			GunStat(Player, Weapon, 'Action', 999999)
			Notify('Set ' .. Player.Name .. '\'s ' .. Weapon .. ' Firerate to 999999')
		end
	end})
	Sections.GunMods.Main:AddButton({text = 'Fast Gun Reload', callback = function()
		for _, Player in pairs(ReturnPlayers()) do
			if Notspawned(Player) then return end
			local Weapon = GetWeapon(Player, library.flags['Weapon'])
			if not Weapon then
				Notify(Player.Name .. ' does not have a ' .. library.flags['Weapon'] .. ' Weapon')
				continue
			end
			GunStat(Player, Weapon, 'Reload')
			Notify('Set ' .. Player.Name .. '\'s ' .. Weapon .. ' Reload Time to 0')
		end
	end})
	Sections.GunMods.Main:AddButton({text = 'Perfect Gun Accuracy', callback = function()
		for _, Player in pairs(ReturnPlayers()) do
			if Notspawned(Player) then return end
			local Weapon = GetWeapon(Player, library.flags['Weapon'])
			if not Weapon then
				Notify(Player.Name .. ' does not have a ' .. library.flags['Weapon'] .. ' Weapon')
				continue
			end
			GunStat(Player, Weapon, 'Accuracy')
			Notify('Set ' .. Player.Name .. '\'s ' .. Weapon .. ' Bullet Spread to 0')
		end
	end})
	Sections.GunMods.Main:AddButton({text = 'No Gun Recoil', callback = function()
		for _, Player in pairs(ReturnPlayers()) do
			if Notspawned(Player) then return end
			local Weapon = GetWeapon(Player, library.flags['Weapon'])
			if not Weapon then
				Notify(Player.Name .. ' does not have a ' .. library.flags['Weapon'] .. ' Weapon')
				continue
			end
			ChangeValue(Player.Backpack[Weapon].Stats.Recoil, getrenv()._G.Obfuscate(1))
			Notify('Set ' .. Player.Name .. '\'s ' .. Weapon .. ' Recoil to 0')
		end
	end})
	Sections.GunMods.Main:AddDivider()
	Sections.GunMods.Main:AddButton({text = 'Give Infinite Ammo', callback = function()
		for _, Player in pairs(ReturnPlayers()) do
			if Notspawned(Player) then continue end
			for _, v in pairs(Player.playerstats.slots:GetChildren()) do
				if v:FindFirstChild('ObjectID') then
					if v.ObjectID:FindFirstChild('Clip') then
						ChangeValue(v.ObjectID.Clip.MaxClip, 99999999999999)
						repeat wait() until v.ObjectID.Clip.MaxClip.Value == 99999999999999
						ChangeValue(v.ObjectID.Clip, getrenv()._G.Obfuscate(99999999999999))
					end
				end
			end
			Notify('Set ' .. Player.Name .. '\'s Ammo to 99999999999999')
		end
	end})
	Sections.GunMods.Main:AddButton({text = 'Refill Ammo', callback = function()
		for _, Player in pairs(ReturnPlayers()) do
			if Notspawned(Player) then continue end
			for _, v in pairs(Player.playerstats.slots:GetChildren()) do
				if v:FindFirstChild('ObjectID') then
					if v.ObjectID:FindFirstChild('Clip') then
						local MaxAmmo = v.ObjectID.Clip.MaxClip.Value
						fireServer('ChangeValue', v.ObjectID.Clip, getrenv()._G.Obfuscate(MaxAmmo))
					end
				end
			end
			Notify('Refilled ' .. Player.Name .. '\'s Ammo')
		end
	end})

	Sections.Vehicles.Selection:AddList({text = 'Player', flag = 'Vehicle Player', value = Client.Name, values = PlayerList, max = 20, skipflag = true})
	Sections.Vehicles.Selection:AddList({text = 'Vehicle', value = VehicleList[1], values = VehicleList, max = 20, skipflag = true, callback = function(choice)
		local FoundVehs = {}
		if choice == 'All' then
			for _, v in pairs(Vehicles:GetChildren()) do
				if v.Name ~= 'VehicleWreck' then
					table.insert(FoundVehs, v)
				end
			end
		elseif choice == 'Others' then
			local SeatFound = false
			for _, v in pairs(Vehicles:GetDescendants()) do
				if v.Name ~= 'VehicleWreck' and v:IsA('Weld') and v.Name == 'SeatWeld' and v.Part1 ~= nil and v.Part1.Parent.Name == Client.Name then
					if v.Parent.Parent.Parent.Name == 'Seats' then
						SeatFound = v.Parent.Parent.Parent.Parent
					else
						SeatFound = v.Parent.Parent.Parent
					end
				end
			end
			if SeatFound ~= false then
				for _, v in pairs(Workspace.Vehicles:GetChildren()) do
					if v.Name ~= 'VehicleWreck' and v ~= SeatFound then
						table.insert(FoundVehs, v)
					end
				end
			else
				for _, v in pairs(Vehicles:GetChildren()) do
					if v.Name ~= 'VehicleWreck' then
						table.insert(FoundVehs, v)
					end
				end
			end
		elseif choice == 'Current' then
			for _, v in pairs(Vehicles:GetDescendants()) do
				if v.Name ~= 'VehicleWreck' and v:IsA('Weld') and v.Name == 'SeatWeld' and v.Part1 ~= nil and v.Part1.Parent.Name == Client.Name then
					if v.Parent.Parent.Parent.Name == 'Seats' then
						table.insert(FoundVehs, v.Parent.Parent.Parent.Parent)
					else
						table.insert(FoundVehs, v.Parent.Parent.Parent)
					end
				end
			end
		else
			local Info = string.split(choice, ') ')
			local Vehicle = Info[2]
			if library.flags['sameType'] == true then
				for _, v in pairs(Vehicles:GetChildren()) do
					if v.Name == Vehicle then
						table.insert(FoundVehs, v)
					end
				end
			else
				local Order = string.sub(Info[1], 2, #Info[1])
				for _, v in pairs(Vehicles:GetChildren()) do
					if v.Name == Vehicle and v:FindFirstChild('AyarumValue') and v.AyarumValue.Value == tonumber(Order) then
						table.insert(FoundVehs, v)
					end
				end
			end
		end
		for _, v in pairs(FoundVehs) do
			FlashVeh(v)
		end
	end})
	Sections.Vehicles.Selection:AddToggle({text = 'All Vehicles of same type', state = false, flag = 'sameType', skipflag = true, callback = function(bool)
		local choice = library.flags['Vehicle']
		local FoundVehs = {}
		if choice == 'All' then
			for _, v in pairs(Vehicles:GetChildren()) do
				if v.Name ~= 'VehicleWreck' then
					table.insert(FoundVehs, v)
				end
			end
		elseif choice == 'Others' then
			local SeatFound = false
			for _, v in pairs(Vehicles:GetDescendants()) do
				if v.Name ~= 'VehicleWreck' and v:IsA('Weld') and v.Name == 'SeatWeld' and v.Part1 ~= nil and v.Part1.Parent.Name == Client.Name then
					if v.Parent.Parent.Parent.Name == 'Seats' then
						SeatFound = v.Parent.Parent.Parent.Parent
					else
						SeatFound = v.Parent.Parent.Parent
					end
				end
			end
			if SeatFound ~= false then
				for _, v in pairs(Workspace.Vehicles:GetChildren()) do
					if v.Name ~= 'VehicleWreck' and v ~= SeatFound then
						table.insert(FoundVehs, v)
					end
				end
			else
				for _, v in pairs(Vehicles:GetChildren()) do
					if v.Name ~= 'VehicleWreck' then
						table.insert(FoundVehs, v)
					end
				end
			end
		elseif choice == 'Current' then
			for _, v in pairs(Vehicles:GetDescendants()) do
				if v.Name ~= 'VehicleWreck' and v:IsA('Weld') and v.Name == 'SeatWeld' and v.Part1 ~= nil and v.Part1.Parent.Name == Client.Name then
					if v.Parent.Parent.Parent.Name == 'Seats' then
						table.insert(FoundVehs, v.Parent.Parent.Parent.Parent)
					else
						table.insert(FoundVehs, v.Parent.Parent.Parent)
					end
				end
			end
		else
			local Info = string.split(choice, ') ')
			local Vehicle = Info[2]
			if bool == true then
				for _, v in pairs(Vehicles:GetChildren()) do
					if v.Name == Vehicle then
						table.insert(FoundVehs, v)
					end
				end
			else
				local Order = string.sub(Info[1], 2, #Info[1])
				for _, v in pairs(Vehicles:GetChildren()) do
					if v.Name == Vehicle and v:FindFirstChild('AyarumValue') and v.AyarumValue.Value == tonumber(Order) then
						table.insert(FoundVehs, v)
					end
				end
			end
		end
		for _, v in pairs(FoundVehs) do
			FlashVeh(v)
		end
	end})

	Sections.Vehicles.Color:AddList({text = 'Color Code', flag = 'Veh Color', value = ColorsList[1], values = ColorsList, max = 20, skipflag = true})
	Sections.Vehicles.Color:AddButton({text = 'Set Vehicle Color', callback = function()
		local Color = library.flags['Veh Color']
		Color = string.split(Color, '(')[2]
		Color = string.split(Color, ') ')[1]
		Color = tonumber(Color)
		for _, Veh in pairs(GetVeh()) do
			for _, v in pairs(Veh:GetDescendants()) do
				if Veh.Stats.Armor.Value > 0 then
					if v.Name == 'Special' or v.Name == 'Color' or v.Name == 'White' then
						ColorModel(v, Color, 2)
					end
				elseif v.Name == 'Special' or v.Name == 'Color' or v.Name == 'White' then
					ColorModel(v, Color, 1)
				end
				if Veh.Name ~= 'PoliceCar' and v.Name == 'ArmorSkirt' then
					ColorModel(v, Color, 2)
				end
			end
			Notify('Set ' .. Veh.Name .. '\'s Color to ' .. GetCode(ColorCodes, Color))
		end
	end})
	Sections.Vehicles.Color:AddDivider()
	Sections.Vehicles.Color:AddList({text = 'Texture', flag = 'Veh Texture', value = MatsList[1], values = MatsList, max = 20, skipflag = true})
	Sections.Vehicles.Color:AddSlider({text = 'Transparency', flag = 'Veh Trans', value = 0, min = 0, max = 1, float = 0.1, subs = 3})
	Sections.Vehicles.Color:AddButton({text = 'Set Texture & Transparency', callback = function()
		local Mat = library.flags['Veh Texture']
		Mat = string.gsub(Mat, ' ', '')
		local Trans = library.flags['Veh Trans']
		for _, Veh in pairs(GetVeh()) do
			local MovedArmor = false
			if Veh.Essentials.Color:FindFirstChild('ArmorSkirt') then
				MovedArmor = true
				ChangeParent(Veh.Essentials.Color.ArmorSkirt, Veh)
				Veh:WaitForChild('ArmorSkirt')
				fireServer('VehichleLightsSet', Veh.ArmorSkirt, Mat, Trans)
			end
			for _, v in pairs(Veh:GetDescendants()) do
				if v.Name == 'Special' or v.Name == 'Color' or v.Name == 'Black' or v.Name == 'White' or v.Name == 'LMWheel' or v.Name == 'LBWheel' or v.Name == 'Black' then
					fireServer('VehichleLightsSet', v, Mat, Trans)
				end
				if v.Name == 'LMWheel' or v.Name == 'LBWheel' or v.Name == 'Black' or v.Name == 'LFWheel' or v.Name == 'RFWheel' or v.Name == 'RMWheel' or v.Name == 'RBWheel' then
					fireServer('VehichleLightsSet', v, Mat, setvalue(Trans, 0, 0.99999))
				end
			end
			if MovedArmor == true then
				ChangeParent(Veh.ArmorSkirt, Veh.Essentials.Color)
			end
			Notify('Set ' .. Veh.Name .. '\'s Texture to ' .. Mat .. ' and Transparency to ' .. tostring(Trans))
		end
	end})

	Sections.Vehicles.Main:AddButton({text = 'Clone Vehicle to Player', callback = function()
		local Vehicle = GetVeh()[1]
		if not Vehicle then return end
		for _, Player in pairs(ReturnPlayers()) do
			if Notloaded(Player) then continue end
			Limiter()
			for _, v in pairs(Vehicle:GetDescendants()) do
				if v.Name == 'SeatWeld' and v.Part1 ~= nil then
					Delete(v)
				end
			end
			SpawnItem(Player, Vehicle, Vehicles, {
				X = {15, 20},
				Y = {1, 1},
				Z = {15, 20}
			}, 1)
			Notify('Cloned ' .. Vehicle.Name .. ' to ' .. Player.Name)
		end
	end})
	Sections.Vehicles.Main:AddButton({text = 'Bring Player to Vehicle', callback = function()
		local Vehicle = GetVeh()[1]
		if not Vehicle then return end
		for _, Player in pairs(ReturnPlayers()) do
			if Notloaded(Player) then continue end
			Teleport(Player, Vehicle.Essentials.Base.CFrame + Vector3.new(0, 10, 0))
			Notify('Teleported ' .. Player.Name .. ' to ' .. Vehicle.Name)
		end
	end})
	Sections.Vehicles.Main:AddButton({text = 'Bring Vehicle to Player', callback = function()
		local Veh = GetVeh()[1]
		local Player = ReturnPlayers()[1]
		if not Veh or not Player or Notloaded(Player) then return end
		spawn(function()
			local Param = Player.Character.Torso.CFrame + Vector3.new(math.random(10, 20), 4, math.random(10, 20))
			local IsBuildingMaterial = AddInstance('IsBuildingMaterial', Veh.Essentials.Base)
			Veh.Essentials.Base:WaitForChild('IsBuildingMaterial')
			Remote.ReplicatePart:FireServer(Veh.Essentials.Base, Param)
			wait(1)
			Delete(IsBuildingMaterial)
		end)
		Notify('Brought ' .. Veh.Name .. ' to ' .. Player.Name)
	end})
	Sections.Vehicles.Main:AddDivider()
	Sections.Vehicles.Main:AddSlider({text = 'Speed', flag = 'Vehicle Speed', value = 250, min = 0, max = 500, skipflag = true})
	Sections.Vehicles.Main:AddButton({text = 'Set Vehicle Speed', callback = function()
		for _, Veh in pairs(GetVeh()) do
			ChangeValue(Veh.Stats.MaxSpeed, library.flags['Vehicle Speed'])
			ChangeValue(Veh.Stats.MaxSpeed.Offroad, library.flags['Vehicle Speed'])
			Notify('Set ' .. Veh.Name .. '\'s Speed to ' .. tostring(library.flags['Vehicle Speed']))
		end
	end})
	Sections.Vehicles.Main:AddButton({text = 'God Vehicle', callback = function()
		for _, Veh in pairs(GetVeh()) do
			Repair(Veh, true, 133742069, 9999999, 133742069)
			Notify('Godded ' .. Veh.Name)
		end
	end})
	Sections.Vehicles.Main:AddButton({text = 'Ungod Vehicle', callback = function()
		for _, Veh in pairs(GetVeh()) do
			Repair(Veh, false, 350, 100, 0)
			Notify('Ungodded ' .. Veh.Name)
		end
	end})
	Sections.Vehicles.Main:AddButton({text = 'Repair Vehicle', callback = function()
		for _, Veh in pairs(GetVeh()) do
			Repair(Veh, true, 350, 100, 350)
			Notify('Repaired ' .. Veh.Name)
		end
	end})
	Sections.Vehicles.Main:AddButton({text = 'Loop Repair Armor', callback = function()
		for _, Veh in pairs(GetVeh()) do
			if Veh:FindFirstChild('AyarumRepair') then
				Notify(Veh.Name .. '\'s Armor is already looped!')
				continue
			end
			local AyarumRepair = Instance.new('BoolValue')
			AyarumRepair.Name = 'AyarumRepair'
			AyarumRepair.Value = true
			AyarumRepair.Parent = Veh
			Notify('Enabled Armor Repair for ' .. Veh.Name)
		end
	end})
	Sections.Vehicles.Main:AddButton({text = 'Un-Loop Repair Armor', callback = function()
		for _, Veh in pairs(GetVeh()) do
			if not Veh:FindFirstChild('AyarumRepair') then
				Notify(Veh.Name .. '\'s Armor isn\'t looped!')
				continue
			end
			Veh.AyarumRepair:Remove()
			Notify('Disabled Armor Repair for ' .. Veh.Name)
		end
	end})
	Sections.Vehicles.Main:AddButton({text = 'Reset Vehicle Speed', callback = function()
		for _, Veh in pairs(GetVeh()) do
			if VehicleSpeeds[Veh.Name] ~= nil then
				ChangeValue(Veh.Stats.MaxSpeed, VehicleSpeeds[Veh.Name][1])
				ChangeValue(Veh.Stats.MaxSpeed.Offroad, VehicleSpeeds[Veh.Name][2])
				Notify('Reset ' .. Veh.Name .. '\'s Speed')
			end
		end
	end})
	Sections.Vehicles.Main:AddButton({text = 'Infinite Vehicle Speed', callback = function()
		for _, Veh in pairs(GetVeh()) do
			ChangeValue(Veh.Stats.MaxSpeed, tonumber('inf'))
			ChangeValue(Veh.Stats.MaxSpeed.Offroad, tonumber('inf'))
			Notify('Set ' .. Veh.Name .. '\'s Speed to Infinite')
		end
	end})

	Sections.Vehicles.Abusive:AddButton({text = 'Explode Vehicle', callback = function()
		for _, Veh in pairs(GetVeh()) do
			if Veh.Name == 'Bicycle' then
				Remote.Detonate:FireServer({['Head'] = Veh.Essentials.Base})
			else
				fireServer('ChangeValue', Veh.Stats.Engine, 0)
			end
			Notify('Exploded ' .. Veh.Name)
		end
	end})
	Sections.Vehicles.Abusive:AddButton({text = 'Delete Vehicle', callback = function()
		for _, Veh in pairs(GetVeh()) do
			Delete(Veh)
			Notify('Deleted ' .. Veh.Name)
		end
	end})
	Sections.Vehicles.Abusive:AddButton({text = 'Unweld Vehicle', callback = function()
		for _, Veh in pairs(GetVeh()) do
			Unweld(Veh, true)
			Notify('Removed ' .. Veh.Name .. '\'s Welds')
		end
	end})
	Sections.Vehicles.Abusive:AddButton({text = 'Pancake Vehicle', callback = function()
		for _, Veh in pairs(GetVeh()) do
			Pancake(Veh)
			Notify('Made ' .. Veh.Name .. ' into a Pancake')
		end
	end})

	Sections.Server.Selection:AddList({text = 'Player', flag = 'Base Player', value = Client.Name, values = PlayerList, max = 20, skipflag = true})

	Sections.Server.Other:AddToggle({text = 'ServerLock', state = false, skipflag = true, callback = function(bool)
		ServerLock = bool
	end})
	Sections.Server.Other:AddToggle({text = 'Disable Zombies', state = false, skipflag = true, callback = function(bool)
		if bool == true then
			if not Workspace:FindFirstChild('Zombies') then
				Notify('Zombies is not a valid member of game.Workspace')
				return
			end
			for _, v in pairs(Workspace.Zombies:GetDescendants()) do
				if v.Name == 'Zombie' or v:FindFirstChild('Humanoid') then
					Delete(v)
				end
			end
		end
	end})
	Sections.Server.Other:AddToggle({text = 'Disable Spawning Loot', flag = 'DisableSpawn', state = false})
	Sections.Server.Other:AddButton({text = 'Delete Zombies', callback = function()
		if not Workspace:FindFirstChild('Zombies') then
			Notify('Zombies is not a valid member of game.Workspace')
			return
		end
		local Count = 0
		for _, v in pairs(Workspace.Zombies:GetDescendants()) do
			if v.Name == 'Zombie' or v:FindFirstChild('Humanoid') then
				Delete(v)
				Count = Count + 1
			end
		end
		Notify('Deleted ' .. tostring(Count) .. ' Zombies')
	end})
	Sections.Server.Other:AddButton({text = 'Fix Server', callback = function()
		Notify('Fixing Server...\n(This could lag)')
		wait(0.5)
		local Problems = FixServer()
		wait(0.5)

		local StringFound = false
		for _, v in pairs(Remote:GetChildren()) do
			if v:IsA('StringValue') then
				StringFound = true
				Delete(v)
				Notify('Deleted StringValue ' .. v.Name, 10)
			end
		end

		if Problems == false and StringFound == false then
			Notify('No issues found!')
		elseif typeof(Problems) == 'table' then
			for i = 1, #Problems do
				ChangeParent(Problems[i][1], Problems[i][2])
				Notify('Moved ' .. Problems[i][1].Name .. ' from ' .. Problems[i][3] .. ' to ' .. Problems[i][4], 10)
			end
			table.clear(Problems)
		end
	end})

	Sections.Server.AntiLag:AddList({text = 'Clean Selection', value = 'Spawned Loot', values = {'Spawned Loot', 'Cloned Buildings', 'Building Parts', 'Explosives', 'Bodies', 'Vehicle Wrecks'}, skipflag = true, max = 20, callback = function(choice)
		if not library.loaded then return end
		spawn(function()
			if choice == 'Spawned Loot' then
				local Count = 0
				for _, v in pairs(Workspace:GetChildren()) do
					if LootDrops:FindFirstChild(v.Name) and v:IsA('Model') and not v:FindFirstChild('THIS_IS_A_TOOL') then
						Delete(v)
						Count = Count + 1
					end
				end
				Notify('Cleaned ' .. tostring(Count) .. ' Spawned Loot')
			elseif choice == 'Cloned Buildings' then
				local Count = 0
				if Workspace:FindFirstChild('Anchored Objects') and Workspace['Anchored Objects']:FindFirstChild('Towns/Cities') then
					for _, v in pairs(Workspace:GetChildren()) do
						if Workspace['Anchored Objects']['Towns/Cities']:FindFirstChild(v.Name) and v:IsA('Model') then
							Delete(v)
							Count = Count + 1
						end
					end
				end
				Notify('Cleaned ' .. tostring(Count) .. ' Clones')
			elseif choice == 'Building Parts' then
				local Count = CleanBuildings()
				Notify('Cleaned ' .. tostring(Count) .. ' Parts')
			elseif choice == 'Explosives' then
				local Count = 0
				for _, v in pairs(Workspace:GetChildren()) do
					if v.Name == 'C4Placed' or v.Name == 'VS50Placed' or v.Name == 'TM46Placed' then
						Delete(v)
						Count = Count + 1
					end
				end
				Notify('Cleaned ' .. tostring(Count) .. ' Explosives')
			elseif choice == 'Bodies' then
				local Count = 0
				for _, v in pairs(Workspace:GetChildren()) do
					if v.Name == 'Corpse' or v.Name == 'GhostCorpse' then
						Delete(v)
						Count = Count + 1
					end
				end
				Notify('Cleaned ' .. tostring(Count) .. ' Bodies')
			elseif choice == 'Vehicle Wrecks' then
				local Count = 0
				for _, v in pairs(Vehicles:GetChildren()) do
					if v.Name == 'VehicleWreck' and v:IsA('Model') then
						Delete(v)
						Count = Count + 1
					end
				end
				for _, v in pairs(Workspace:GetChildren()) do
					if v.Name == 'VehicleWreck' and v:IsA('Model') then
						Delete(v)
						Count = Count + 1
					end
				end
				Notify('Cleaned ' .. tostring(Count) .. ' VehicleWrecks')
			end
		end)
	end})

	Sections.Server.AntiLag:AddButton({text = 'Fullclean', callback = function()
		for _, v in pairs(library.options['Clean Selection'].values) do
			library.options['Clean Selection']:SetValue(v)
			wait()
		end
	end})

	Sections.Server.Bases:AddList({text = 'Base', flag = 'Selected Base', value = BaseList[1], values = BaseList, max = 20, skipflag = true})
	Sections.Server.Bases:AddButton({text = 'Import Base', callback = function()
		local SelectedBase = library.flags['Selected Base']
		SelectedBase = string.split(SelectedBase, ' (')[1]
		if not BaseTable[SelectedBase] then
			Notify('Invalid Base!')
			return
		end
		local RequiredMap = BaseTable[SelectedBase]['MapSpecific']

		if RequiredMap and RequiredMap ~= Mapname then
			Notify('This base is for ' .. RequiredMap .. ' only!')
			return
		end
		if library.flags['Import at Mouse'] == true then
			Notify('Ready to Import\nEnter: Confirm\nBackspace: Cancel')
			PreviewItem(SelectedBase, MousePart, false)
			wait()
			ImportWaiting = true
			spawn(function()
				while library and ImportWaiting do
					wait()
					if Mouse.Hit.Position ~= nil and Client.Character ~= nil and Client.Character:FindFirstChild('Torso') and (Client.Character.Torso.Position - Mouse.Hit.Position).Magnitude < 200 then
						MousePart.Position = Mouse.Hit.Position
					else
						if Client.Character and Client.Character:FindFirstChild('Head') then
							MousePart.Position = Client.Character.Head.Position
						end
					end
				end
			end)
		else
			ImportWaiting = false
			PreviewItem(false)
			for _, Player in pairs(ReturnPlayers()) do
				if Notloaded(Player) then continue end

				local Timer = os.time()

				Notify('Please Wait...')
				local UseHead = false
				if SelectedBase == 'Cage' then
					UseHead = true
				end
				SpawnBaseF(Player, BaseTable[SelectedBase], UseHead, not library.flags['Movable'], true)
				local Filler = not BaseTable[SelectedBase]['CenterPos'] and (' at ' .. Player.Name) or ''
				Notify('Imported ' .. SelectedBase .. Filler .. ' in ' .. SetDecimal(os.time() - Timer, 1) .. 's')
			end
		end
	end})
	Sections.Server.Bases:AddToggle({text = 'Import at Mouse', state = false})
	Sections.Server.Bases:AddToggle({text = 'Movable', state = true})
	Sections.Server.Bases:AddDivider()
	Sections.Server.Bases:AddButton({text = 'Refresh Bases', callback = function()
		local Remove = {}
		for _, v in pairs(library.options['Selected Base'].values) do
			table.insert(Remove, v)
		end
		for _, v in pairs(Remove) do
			library.options['Selected Base']:RemoveValue(v)
		end
		Notify('Updating Bases...')
		UpdateBaseList()
		for i, v in pairs(BaseTable) do
			local Suffix = ''
			if v['MapSpecific'] then
				local Name = v['MapSpecific'] == 'Reimagined' and 'Reim' or v['MapSpecific'] == 'Amend' and 'Amend' or v['MapSpecific'] == 'Reborn' and 'Reborn'
				Suffix = ' (' .. Name .. ')'
			end
			table.insert(BaseList, i .. Suffix)
			library.options['Selected Base']:AddValue(i .. Suffix)
		end
		Notify('Updated Bases')
	end})

	Sections.Server.Map:AddList({text = 'Color Code', flag = 'Map Color', value = ColorsList[1], values = ColorsList, max = 20, skipflag = true})
	Sections.Server.Map:AddList({text = 'Texture Code', flag = 'Map Texture', value = TexturesList[1], values = TexturesList, max = 20, skipflag = true})
	Sections.Server.Map:AddButton({text = 'Set Map Color & Texture', callback = function()
		local Color = library.flags['Map Color']
		local Texture = library.flags['Map Texture']
		Color = string.split(Color, '(')[2]
		Color = string.split(Color, ') ')[1]
		Color = tonumber(Color)
		Texture = string.split(Texture, '(')[2]
		Texture = string.split(Texture, ') ')[1]
		Texture = tonumber(Texture)
		ColorMap(Color, Texture)
	end})
	Sections.Server.Map:AddButton({text = 'Snow Map', callback = function() ColorMap(21, 7) end})
	Sections.Server.Map:AddButton({text = 'Desert Map', callback = function() ColorMap(32, 6) end})
	Sections.Server.Map:AddButton({text = 'Reset Map', callback = function() ColorMap(8, 10) end})
	Sections.Server.Map:AddDivider()
	Sections.Server.Map:AddButton({text = 'Delete Windows', callback = function()
		local Count = 0
		for _, v in pairs(Workspace:GetDescendants()) do
			if v.Name == 'Window' or v.Name == 'SpecialWindow' then
				Delete(v)
				Count = Count + 1
			end
		end
		Notify('Deleted ' .. tostring(Count) .. ' Windows')
	end})
	Sections.Server.Map:AddToggle({text = 'Remove Buildings', state = false, skipflag = true, callback = function(bool)
		if not library.loaded then return end
		if not Workspace:FindFirstChild('Anchored Objects') then
			Notify('Map is removed!')
			return
		end
		if bool == true then
			if not Workspace['Anchored Objects']:FindFirstChild('Towns/Cities') then
				Notify('Buildings are already removed!')
				return
			end
			local Towns = Workspace['Anchored Objects']['Towns/Cities']
			ChangeParent(Towns, Lighting)
			Notify('Deleted Buildings')
		else
			local Towns = Lighting:FindFirstChild('Towns/Cities') or ReplicatedStorage:FindFirstChild('Towns/Cities')
			if Workspace['Anchored Objects']:FindFirstChild('Towns/Cities') or not Towns then
				Notify('Building are not removed!')
				return
			end
			ChangeParent(Towns, Workspace['Anchored Objects'])
			Notify('Added Buildings')
		end
	end})
	Sections.Server.Map:AddToggle({text = 'Remove Hills', state = false, skipflag = true, callback = function(bool)
		if not library.loaded then return end
		if not Workspace:FindFirstChild('Anchored Objects') then
			Notify('Map is removed!')
			return
		end
		if bool == true then
			if not Workspace['Anchored Objects'].Plates:FindFirstChild('Hills') then
				Notify('Hills are already removed!')
				return
			end
			local Hills = Workspace['Anchored Objects'].Plates.Hills
			ChangeParent(Hills, Lighting)
			Notify('Removed Hills')
		else
			local Hills = Lighting:FindFirstChild('Hills') or ReplicatedStorage:FindFirstChild('Hills')
			if Workspace['Anchored Objects'].Plates:FindFirstChild('Hills') or not Hills then
				Notify('Hills are not removed!')
				return
			end
			ChangeParent(Hills, Workspace['Anchored Objects'].Plates)
			Notify('Added Hills')
		end
	end})
	Sections.Server.Map:AddToggle({text = 'Remove Extras', state = false, skipflag = true, callback = function(bool)
		if not library.loaded then return end
		if not Workspace:FindFirstChild('Anchored Objects') then
			Notify('Map is removed!')
			return
		end
		local RemoveThings
		if Mapname == 'Reimagined' then
			RemoveThings = {
				['Plates'] = {
					'Roads',
					'Dirt Roads',
					'Fields'
				},
				'RoadSigns',
				'Trees/Foliage',
				'WallMessages'
			}
		elseif Mapname == 'Amend' then
			RemoveThings = {
				['Plates'] = {
					'Roads',
					'Paths',
					'Fields'
				},
				'WallMessages',
				'RoadSigns',
				'TownSigns'
			}
		else
			Notify('Deleting Extras is disabled on ' .. Mapname)
			return
		end
		if bool == true then
			for i, v in pairs(RemoveThings) do
				if i == 'Plates' then
					for k, a in pairs(v) do
						if not Workspace['Anchored Objects'].Plates:FindFirstChild(a) then continue end
						ChangeParent(Workspace['Anchored Objects'].Plates[a], MakeStorage(Lighting))
					end
				else
					if not Workspace['Anchored Objects']:FindFirstChild(v) then continue end
					ChangeParent(Workspace['Anchored Objects'][v], MakeStorage(Lighting))
				end
			end
			Notify('Removed Extras')
		else
			for i, v in pairs(RemoveThings) do
				if i == 'Plates' then
					for k, a in pairs(v) do
						if not MakeStorage(Lighting):FindFirstChild(a) then continue end
						ChangeParent(MakeStorage(Lighting)[a], Workspace['Anchored Objects'].Plates)
					end
				else
					if not MakeStorage(Lighting):FindFirstChild(v) then continue end
					ChangeParent(MakeStorage(Lighting)[v], Workspace['Anchored Objects'])
				end
			end
			Notify('Added Extras')
		end
	end})
	Sections.Server.Map:AddToggle({text = 'Remove Loot', state = false, skipflag = true, callback = function(bool)
		if not library.loaded then return end
		if bool == true then
			if not Workspace:FindFirstChild('SpawnLoot') and not Workspace:FindFirstChild('DropLoot') then
				Notify('Loot is already removed!')
				return
			end
			if Workspace:FindFirstChild('DropLoot') then
				ChangeParent(Workspace['DropLoot'], Lighting)
			end
			if Workspace:FindFirstChild('SpawnLoot') then
				ChangeParent(Workspace['SpawnLoot'], Lighting)
			end
			Notify('Removed Loot')
		else
			if Workspace:FindFirstChild('SpawnLoot') or Workspace:FindFirstChild('DropLoot') then
				Notify('Loot is not removed!')
				return
			end
			if Lighting:FindFirstChild('DropLoot') then
				ChangeParent(Lighting['DropLoot'], Workspace)
			end
			if Lighting:FindFirstChild('SpawnLoot') then
				ChangeParent(Lighting['SpawnLoot'], Workspace)
			end
			Notify('Added Loot')
		end
	end})
	Sections.Server.Map:AddList({text = 'Location', flag = 'Clone Location', value = LocationList[1], values = LocationList, max = 20, skipflag = true})
	Sections.Server.Map:AddButton({text = 'Clone Location to Player', callback = function()
		local Location = library.flags['Clone Location']
		if game.PlaceId == 237590761 or game.PlaceId == 302647266 or game.PlaceId == 1228676522 or game.PlaceId == 1228677045 then
			Notify('Cloning is disabled on ' .. Mapname)
			return
		end
		if not Workspace:FindFirstChild('Anchored Objects') then
			Notify('Map is removed!')
			return
		end

		for _, Player in pairs(ReturnPlayers()) do
			if Notloaded(Player) then continue end
			SpawnItem(Player, Location, Workspace['Anchored Objects']['Towns/Cities'], {
				X = {-4, 4},
				Y = {-5, -5},
				Z = {-4, 4}
			}, 1)
			Notify('Cloned ' .. Location .. ' to ' .. Player.Name)
		end
	end})

	Sections.Misc.Skins:AddButton({text = 'Give All Weapon Skins', callback = function()
		local Vals = {
			-- Plain Colors --

			{17,1,17,1},
			{2,1,2,1},
			{19,1,19,1},
			{4,1,4,1},
			{18,1,18,1},
			{6,1,6,1},
			{20,1,20,1},
			{16,1,16,1},
			{35,1,35,1},
			{22,1,22,1},

			-- Black & Plain Color --

			{22,1,17,1},
			{17,1,22,1},

			{22,1,2,1},
			{2,1,22,1},

			{22,1,19,1},
			{19,1,22,1},

			{22,1,4,1},
			{4,1,22,1},

			{22,1,18,1},
			{18,1,22,1},

			{22,1,6,1},
			{6,1,22,1},

			{22,1,20,1},
			{20,1,22,1},

			{22,1,16,1},
			{16,1,22,1},

			{22,1,35,1},
			{35,1,22,1},

			-- White & Plain Color --

			{35,1,17,1},
			{17,1,35,1},

			{35,1,2,1},
			{2,1,35,1},

			{35,1,19,1},
			{19,1,35,1},

			{35,1,4,1},
			{4,1,35,1},

			{35,1,18,1},
			{18,1,35,1},

			{35,1,6,1},
			{6,1,35,1},

			{35,1,20,1},
			{20,1,35,1},

			{35,1,16,1},
			{16,1,35,1},

			-- Other Mixed Colors --

			{18,1,16,1},
			{16,1,18,1},

			{64,1,65,1},
			{65,1,64,1},

			-- Solid Colors & Textures --

			{22,5,22,5},
			{55,9,55,9},
			{8,10,8,10},

			-- Black & Granite --

			{22,1,24,8},
			{24,8,22,1},

			{22,1,1,8},
			{1,8,22,1},

			{22,1,2,8},
			{2,8,22,1},

			{22,1,3,8},
			{3,8,22,1},

			{22,1,4,8},
			{4,8,22,1},

			{22,1,5,8},
			{5,8,22,1},

			{22,1,6,8},
			{6,8,22,1},

			{22,1,7,8},
			{7,8,22,1},

			{22,1,10,8},
			{10,8,22,1},

			{22,1,31,8},
			{31,8,22,1},

			{22,1,44,8},
			{44,8,22,1},

			{22,1,55,8},
			{55,8,22,1}
		}
		for _, Player in pairs(ReturnPlayers()) do
			Notify('Please Wait...')
			local AmountGiven = 0
			for i = 1, #Vals do
				local SkinSlot = Player.playerstats.skins['skin' .. tostring(i)]
				ChangeValue(SkinSlot.material, Vals[i][2])
				ChangeValue(SkinSlot.secondary, Vals[i][3])
				ChangeValue(SkinSlot.secondary.material, Vals[i][4])
				ChangeValue(SkinSlot, Vals[i][1])
				AmountGiven = AmountGiven + 1
				if AmountGiven >= 50 then
					repeat wait() until SkinSlot.Value == Vals[i][1]
					AmountGiven = 0
				end
			end
			repeat wait() until Player.playerstats.skins['skin' .. tostring(#Vals)].Value == Vals[#Vals][1]
			Notify('Gave ' .. Player.Name .. ' all Weapon Skins')
		end
		table.clear(Vals)
	end})
	Sections.Misc.Skins:AddDivider()
	Sections.Misc.Skins:AddList({text = 'Color Code', value = ColorsList[1], values = ColorsList, max = 20})
	Sections.Misc.Skins:AddList({text = 'Texture Code', value = TexturesList[1], values = TexturesList, max = 20})
	Sections.Misc.Skins:AddList({text = 'Color Code 2', value = ColorsList[1], values = ColorsList, max = 20})
	Sections.Misc.Skins:AddList({text = 'Texture Code 2', value = TexturesList[1], values = TexturesList, max = 20})
	Sections.Misc.Skins:AddButton({text = 'Give Player Skin', callback = function()
		local Color = library.flags['Color Code']
		local Texture = library.flags['Texture Code']
		local Color2 = library.flags['Color Code 2']
		local Texture2 = library.flags['Texture Code 2']
		Color = string.split(Color, '(')[2]
		Color = string.split(Color, ') ')[1]
		Color = tonumber(Color)
		Texture = string.split(Texture, '(')[2]
		Texture = string.split(Texture, ') ')[1]
		Texture = tonumber(Texture)
		Color2 = string.split(Color2, '(')[2]
		Color2 = string.split(Color2, ') ')[1]
		Color2 = tonumber(Color2)
		Texture2 = string.split(Texture2, '(')[2]
		Texture2 = string.split(Texture2, ') ')[1]
		Texture2 = tonumber(Texture2)

		for _, Player in pairs(ReturnPlayers()) do
			local Slot
			for i = 1, 99 do
				if Player.playerstats.skins['skin' .. tostring(i)].Value == 0 then
					Slot = Player.playerstats.skins['skin' .. tostring(i)]
					break
				end
			end
			if not Slot then
				Notify(Player.Name .. ' does not have an empty Skin Slot')
				continue
			end
			ChangeValue(Slot.material, Texture)
			ChangeValue(Slot.secondary, Color2)
			ChangeValue(Slot.secondary.material, Texture2)
			ChangeValue(Slot, Color)
			repeat wait() until Slot.Value == Color
			Notify('Set ' .. Player.Name .. '\'s ' .. Slot.Name .. ' slot to:\n' .. GetCode(ColorCodes, Color) .. ', ' .. GetCode(TextureCodes, Texture) .. ',\n' .. GetCode(ColorCodes, Color2) .. ', ' .. GetCode(TextureCodes, Texture2), 10)
		end
	end})

	Sections.Misc.Kits:AddButton({text = 'M14 Kit', callback = function()
		for _, Player in pairs(ReturnPlayers()) do
			if Notloaded(Player) then continue end
			SpawnKit({
				{'M14', 1},
				{'M14Ammo50', 8},
				{'ACOG', 1},
				{'Grip', 1},
				{'Suppressor762', 1},
				{'MilitaryPackBlack', 1}
			}, Player)
			Notify('Spawned M14 Kit at ' .. Player.Name)
		end
	end})
	Sections.Misc.Kits:AddButton({text = 'HK21 Kit', callback = function()
		for _, Player in pairs(ReturnPlayers()) do
			if Notloaded(Player) then continue end
			SpawnKit({
				{'HK21', 1},
				{'M14Ammo50', 8},
				{'ACOG', 1},
				{'Grip', 1},
				{'Suppressor762', 1},
				{'MilitaryPackBlack', 1}
			}, Player)
			Notify('Spawned HK21 Kit at ' .. Player.Name)
		end
	end})
	Sections.Misc.Kits:AddButton({text = 'Patriot Kit', callback = function()
		for _, Player in pairs(ReturnPlayers()) do
			if Notloaded(Player) then continue end
			SpawnKit({
				{'Patriot', 1},
				{'STANAGAmmo100', 8},
				{'ACOG', 1},
				{'Grip', 1},
				{'Suppressor556', 1},
				{'MilitaryPackBlack', 1}
			}, Player)
			Notify('Spawned Patriot Kit at ' .. Player.Name)
		end
	end})
	Sections.Misc.Kits:AddButton({text = 'G36K Kit', callback = function()
		for _, Player in pairs(ReturnPlayers()) do
			if Notloaded(Player) then continue end
			SpawnKit({
				{'G36K', 1},
				{'STANAGAmmo100', 8},
				{'ACOG', 1},
				{'Grip', 1},
				{'Suppressor556', 1},
				{'MilitaryPackBlack', 1}
			}, Player)
			Notify('Spawned G36K Kit at ' .. Player.Name)
		end
	end})
	Sections.Misc.Kits:AddButton({text = 'G18 Kit', callback = function()
		for _, Player in pairs(ReturnPlayers()) do
			if Notloaded(Player) then continue end
			SpawnKit({
				{'G18', 1},
				{'M9Ammo32', 4},
				{'Laser', 1},
				{'Suppressor9', 1}
			}, Player)
			Notify('Spawned G18 Kit at ' .. Player.Name)
		end
	end})
	Sections.Misc.Kits:AddButton({text = 'Driveby Kit', callback = function()
		for _, Player in pairs(ReturnPlayers()) do
			if Notloaded(Player) then continue end
			SpawnKit({
				{'M1014', 1},
				{'M870Ammo', 8},
				{'Laser', 1},
				{'ACOG', 1},
				{'Uzi', 1},
				{'TEC9Ammo32', 4},
				{'MilitaryPackBlack', 1},
				{'BloodBag', 8}
			}, Player)
			Notify('Spawned Driveby Kit at ' .. Player.Name)
		end
	end})
	Sections.Misc.Kits:AddButton({text = 'Car Kit', callback = function()
		for _, Player in pairs(ReturnPlayers()) do
			if Notloaded(Player) then continue end
			SpawnKit({
				{'ReinforcedWheel', 6},
				{'ScrapMetal', 1},
				{'ArmorPlates', 1},
				{'EngineParts', 1},
				{'FuelTank', 1},
				{'JerryCan', 2},
				{'BallisticGlass', 1}
			}, Player)
			Notify('Spawned Car Kit at ' .. Player.Name)
		end
	end})
	Sections.Misc.Kits:AddButton({text = 'Base Kit', callback = function()
		for _, Player in pairs(ReturnPlayers()) do
			if Notloaded(Player) then continue end
			SpawnKit({
				{'Entrencher', 1},
				{'Material5', 3},
				{'Material3', 2},
				{'Material4', 1},
				{'LargeCrate', 1}
			}, Player)
			Notify('Spawned Base Kit at ' .. Player.Name)
		end
	end})
	Sections.Misc.Kits:AddButton({text = 'Health Kit', callback = function()
		for _, Player in pairs(ReturnPlayers()) do
			if Notloaded(Player) then continue end
			SpawnKit({
				{'BloodBag', 10},
				{'Painkillers', 4},
				{'MRE', 6},
				{'WaterBottle', 6}
			}, Player)
			Notify('Spawned Health Kit at ' .. Player.Name)
		end
	end})
	Sections.Misc.Kits:AddButton({text = 'Utility Kit', callback = function()
		for _, Player in pairs(ReturnPlayers()) do
			if Notloaded(Player) then continue end
			SpawnKit({
				{'Katana', 1},
				{'Entrencher', 1},
				{'Map', 1},
				{'FlashlightMilitary', 1},
				{'GPS', 1},
				{'Compass', 1},
				{'Detonator', 1}
			}, Player)
			Notify('Spawned Utility Kit at ' .. Player.Name)
		end
	end})

	Sections.Misc.Selection:AddList({text = 'Player', flag = 'Spawn Player', value = Client.Name, values = PlayerList, max = 20, skipflag = true})
	Sections.Misc.Spawning:AddSlider({text = 'Amount', flag = 'Item Amount', value = 1, min = 1, max = 20, skipflag = true})
	local PrevText
	Sections.Misc.Spawning:AddBox({text = 'Item Name', flag = 'Item Name', value = '', skipflag = true, callback = function(text)
		if not library.loaded then return end
		if PrevText == text then return end
		PrevText = text
		local Item = GetItemName(text)
		if Item then
			library.options['Item Name']:SetValue(Item, nil, true)
		else
			library.options['Item Name']:SetValue('', nil, true)
		end
	end})
	Sections.Misc.Spawning:AddButton({text = 'Spawn', callback = function()
		local Item = GetItemName(library.flags['Item Name'])
		if not Item then
			Notify('Invalid Item!')
			return
		end

		for _, Player in pairs(ReturnPlayers()) do
			if Notloaded(Player) then continue end
			SpawnItem(Player, Item, LootDrops, {
				X = {-5, 5},
				Y = {1, 1},
				Z = {-5, 5}
			}, library.flags['Item Amount'])
			Notify('Spawned ' .. tostring(library.flags['Item Amount']) .. ' of ' .. Item .. ' at ' .. Player.Name)
		end
		library.options['Item Amount']:SetValue(1)
	end})

	Sections.Players.Selection:AddList({text = 'Player', flag = 'Player Selection', value = Client.Name, values = PlayerList, max = 20, skipflag = true})
	Sections.Players.Selection:AddList({text = 'Location', flag = 'Location Selection', value = LocationList[1] or '', values = LocationList, max = 20, skipflag = true})
	Sections.Players.Selection:AddList({text = 'PermBanned Player', flag = 'BanPlayer Selection', value = AutoBanList[1] or '', values = AutoBanList, max = 20, skipflag = true})

	Sections.Players.Character:AddButton({text = 'Spectate', callback = function()
		local Player = ReturnPlayers()[1]
		if not Player then return end
		Camera.CameraSubject = Player.Character.Humanoid
		if Player == Client then
			Spectator:RemoveInfo()
		else
			Spectator:InfoPlayer(Player)
		end
	end})
	Sections.Players.Character:AddButton({text = 'Unspectate', callback = function()
		Camera.CameraSubject = Client.Character.Humanoid
		Spectator:RemoveInfo()
	end})
	Sections.Players.Character:AddButton({text = 'Remove Vest', callback = function()
		for _, Player in pairs(ReturnPlayers()) do
			if Notloaded(Player) then continue end
			local Vest
			local Storage = MakeStorage(Player)
			for _, v in pairs(Lighting.PlayerVests:GetChildren()) do
				if Player.Character:FindFirstChild(v.Name) then
					Vest = Player.Character[v.Name]
				end
			end
			if not Vest then
				Notify(Player.Name .. '\'s vest is already removed!')
				continue
			end
			for _, v in pairs(Lighting.PlayerVests:GetChildren()) do
				if Storage:FindFirstChild(v.Name) then
					Delete(Storage[v.Name])
				end
			end
			ChangeParent(Vest, Storage)
			Notify('Removed ' .. Player.Name .. '\'s Vest')
		end
	end})
	Sections.Players.Character:AddButton({text = 'Add Vest', callback = function()
		for _, Player in pairs(ReturnPlayers()) do
			if Notloaded(Player) then continue end
			local Vest
			local Storage = MakeStorage(Player)
			for _, v in pairs(Lighting.PlayerVests:GetChildren()) do
				if Storage:FindFirstChild(v.Name) then
					Vest = Storage[v.Name]
				end
			end
			if not Vest then
				Notify(Player.Name .. '\'s vest has not been removed!')
				continue
			end
			for _, v in pairs(Lighting.PlayerVests:GetChildren()) do
				if Player.Character:FindFirstChild(v.Name) then
					Delete(Player.Character[v.Name])
				end
			end
			ChangeParent(Vest, Player.Character)
			Notify('Added a Vest to ' .. Player.Name)
		end
	end})
	Sections.Players.Character:AddDivider()
	Sections.Players.Character:AddButton({text = 'Make Invisible', callback = function()
		for _, Player in pairs(ReturnPlayers()) do
			if Notloaded(Player) then continue end
			SetPlayerInvis(Player, true)
			Notify('Made ' .. Player.Name .. ' Invisible')
		end
	end})
	Sections.Players.Character:AddButton({text = 'Make Visible', callback = function()
		for _, Player in pairs(ReturnPlayers()) do
			if Notloaded(Player) then continue end
			SetPlayerInvis(Player, false)
			Notify('Made ' .. Player.Name .. ' Visible')
		end
	end})
	Sections.Players.Character:AddButton({text = 'Make Zombie Invisible', callback = function()
		for _, Player in pairs(ReturnPlayers()) do
			if Notloaded(Player) then continue end
			if SetZombieVisible(Player, true) then return end
			Notify('Made ' .. Player.Name .. ' Invisible to Zombies')
		end
	end})
	Sections.Players.Character:AddButton({text = 'Make Zombie Visible', callback = function()
		for _, Player in pairs(ReturnPlayers()) do
			if Notloaded(Player) then continue end
			if SetZombieVisible(Player, false) then return end
			Notify('Made ' .. Player.Name .. ' Visible to Zombies')
		end
	end})
	Sections.Players.Character:AddDivider()
	Sections.Players.Character:AddButton({text = 'PainKiller God', callback = function()
		for _, Player in pairs(ReturnPlayers()) do
			if Notloaded(Player) then continue end
			if Player.Character.Humanoid:FindFirstChild('DefenseMultiplier') and Player.Character.Humanoid.DefenseMultiplier.Value == '0' then
				Notify(Player.Name .. ' is already Godded')
				continue
			end
			for _, v in pairs(Player.Character:GetDescendants()) do
				if v.Name == 'DefenseMultiplier' then
					Delete(v)
				end
			end
			Remote.AddClothing:FireServer('DefenseMultiplier', Player.Character.Humanoid, 0, '', '')
			Notify('PainKiller Godded ' .. Player.Name)
		end
	end})
	Sections.Players.Character:AddButton({text = 'PainKiller Ungod', callback = function()
		for _, Player in pairs(ReturnPlayers()) do
			if Notloaded(Player) then continue end
			if not Player.Character.Humanoid:FindFirstChild('DefenseMultiplier') or Player.Character.Humanoid.DefenseMultiplier.Value ~= '0' then
				Notify(Player.Name .. ' is not Godded')
				continue
			end
			for _, v in pairs(Player.Character:GetDescendants()) do
				if v.Name == 'DefenseMultiplier' then
					Delete(v)
				end
			end
			Notify('Removed ' .. Player.Name .. '\'s PainKiller God')
		end
	end})
	Sections.Players.Character:AddButton({text = 'Heal', callback = function()
		for _, Player in pairs(ReturnPlayers()) do
			if Notloaded(Player) then continue end
			local WasGodded = false
			if Player.Character.Humanoid:FindFirstChild('DefenseMultiplier') and Player.Character.Humanoid.DefenseMultiplier.Value == '0' then
				for _, v in pairs(Player.Character:GetDescendants()) do
					if v.Name == 'DefenseMultiplier' then
						Delete(v)
					end
				end
				WasGodded = true
				repeat wait() until not Player.Character.Humanoid:FindFirstChild('DefenseMultiplier')
			end
			repeat
				fireServer('Damage', Player.Character.Humanoid, -100)
				wait()
			until Player.Character.Humanoid.Health == 100
			if WasGodded then
				Remote.AddClothing:FireServer('DefenseMultiplier', Player.Character.Humanoid, 0, '', '')
			end
			Notify('Healed ' .. Player.Name)
		end
	end})

	for i = 1, #Outfits do
		local Info = Outfits[i]
		Sections.Players.Clothing:AddButton({text = Info.Name .. ' Outfit', callback = function()
			for _, Player in pairs(ReturnPlayers()) do
				Notify('Please Wait...')
				local Char = Player.playerstats.character
				local Hat = Char.hat
				local Accessory = Char.accessory
				if Hat:FindFirstChild('ObjectID') then
					fireServer('ChangeValue', Hat, 0)
					Delete(Hat.ObjectID)
					repeat wait() until not Hat:FindFirstChild('ObjectID')
				end
				if Accessory:FindFirstChild('ObjectID') then
					fireServer('ChangeValue', Accessory, 0)
					Delete(Accessory.ObjectID)
					repeat wait() until not Accessory:FindFirstChild('ObjectID')
				end
				ChangeClothing(Player, 'Shirt', Info.Shirt)
				ChangeClothing(Player, 'Pants', Info.Pants)
				AddID(Player, Hat, Info.Hat)
				AddID(Player, Accessory, Info.Accessory)
				Notify('Set ' .. Player.Name .. '\'s Outfit to ' .. Info.Name)
			end
		end})
	end
	Sections.Players.Clothing:AddList({text = 'Clothing', value = 'Silenced Squad Camo', values = Clothing, max = 20})
	Sections.Players.Clothing:AddButton({text = 'Set Player Clothing', callback = function()
		local Name = library.flags['Clothing']
		local Shirt = Clothing[Name][1]
		local Pants = Clothing[Name][2]
		for _, Player in pairs(ReturnPlayers()) do
			ChangeClothing(Player, 'Shirt', Shirt)
			ChangeClothing(Player, 'Pants', Pants)
			Notify('Changed ' .. Player.Name .. '\'s Clothes to ' .. Name)
		end
	end})
	Sections.Players.Character:AddButton({text = 'Nugget Player', callback = function()
		for _, Player in pairs(ReturnPlayers()) do
			if Notloaded(Player) then continue end
			local Storage = MakeStorage(Player)
			local Char = Player.Character
			if not Char:FindFirstChild('Left Arm') and not Char:FindFirstChild('Right Arm') and not Char:FindFirstChild('Left Leg') and not Char:FindFirstChild('Right Leg') then
				Notify(Player.Name .. ' is already a Nugget!')
				continue
			end
			for _, v in pairs(Char:GetChildren()) do
				if v.Name == 'Left Arm' or v.Name == 'Right Arm' or v.Name == 'Left Leg' or v.Name == 'Right Leg' then
					ChangeParent(v, Storage)
				end
			end
			Notify('Made ' .. Player.Name .. ' into a Nugget')
		end
	end})
	Sections.Players.Character:AddButton({text = 'Un-Nugget Player', callback = function()
		for _, Player in pairs(ReturnPlayers()) do
			if Notloaded(Player) then continue end
			local Storage = MakeStorage(Player)
			local Char = Player.Character
			if not Storage:FindFirstChild('Left Arm') and not Storage:FindFirstChild('Right Arm') and not Storage:FindFirstChild('Left Leg') and not Storage:FindFirstChild('Right Leg') then
				Notify(Player.Name .. ' is not a Nugget!')
				continue
			end
			for _, v in pairs(Storage:GetChildren()) do
				if v.Name == 'Left Arm' or v.Name == 'Right Arm' or v.Name == 'Left Leg' or v.Name == 'Right Leg' then
					ChangeParent(v, Char)
				end
			end
			Notify('Added ' .. Player.Name .. '\'s Limbs')
		end
	end})

	Sections.Players.Stats:AddBox({text = 'Value', value = '', flag = 'Player Value', skipflag = true})
	Sections.Players.Stats:AddButton({text = 'Set Days Survived', callback = function()
		local val = tonumber(library.flags['Player Value'])
		if not val then
			Notify('Please enter a valid number!')
			return
		elseif val > 9e9 then
			Notify('Value cannot be over ' .. tostring(9e9))
			return
		elseif val < 0 then
			Notify('Value cannot be below 0')
			return
		end
		for _, Player in pairs(ReturnPlayers()) do
			ChangeValue(Player.playerstats.Days, val)
			Notify('Set ' .. Player.Name .. '\'s Days Survived to ' .. tostring(val))
		end
	end})
	Sections.Players.Stats:AddButton({text = 'Set Players Killed', callback = function()
		local val = tonumber(library.flags['Player Value'])
		if not val then
			Notify('Please enter a valid number!')
			return
		elseif val > 9e9 then
			Notify('Value cannot be over ' .. tostring(9e9))
			return
		elseif val < 0 then
			Notify('Value cannot be below 0')
			return
		end
		for _, Player in pairs(ReturnPlayers()) do
			ChangeValue(Player.playerstats.PlayerKill.Bandit, val)
			ChangeValue(Player.playerstats.PlayerKill.Defensive, 0)
			ChangeValue(Player.playerstats.PlayerKill.Aggressive, 0)
			Notify('Set ' .. Player.Name .. '\'s Players Killed to ' .. tostring(val))
		end
	end})
	Sections.Players.Stats:AddButton({text = 'Set Zombies Killed', callback = function()
		local val = tonumber(library.flags['Player Value'])
		if not val then
			Notify('Please enter a valid number!')
			return
		elseif val > 9e9 then
			Notify('Value cannot be over ' .. tostring(9e9))
			return
		elseif val < 0 then
			Notify('Value cannot be below 0')
			return
		end
		for _, Player in pairs(ReturnPlayers()) do
			ChangeValue(Player.playerstats.ZombieKill.Military, val)
			ChangeValue(Player.playerstats.ZombieKill.Civilian, 0)
			Notify('Set ' .. Player.Name .. '\'s Zombies Killed to ' .. tostring(val))
		end
	end})
	Sections.Players.Stats:AddSlider({text = 'Hunger', value = 100, min = 0, max = 100, flag = 'Hunger Slider', callback = function(val)
		for _, Player in pairs(ReturnPlayers()) do
			ChangeValue(Player.playerstats.Hunger, val)
		end
	end, skipflag = true})
	Sections.Players.Stats:AddSlider({text = 'Thirst', value = 100, min = 0, max = 100, flag = 'Thirst Slider', callback = function(val)
		for _, Player in pairs(ReturnPlayers()) do
			ChangeValue(Player.playerstats.Thirst, val)
		end
	end, skipflag = true})
	Sections.Players.Stats:AddButton({text = 'Infinite Vitals', callback = function()
		for _, Player in pairs(ReturnPlayers()) do
			spawn(function()
				repeat
					ChangeValue(Player.playerstats.Hunger, math.huge)
					ChangeValue(Player.playerstats.Thirst, math.huge)
					wait()
				until (Player.playerstats.Thirst.Value < 0 or Player.playerstats.Thirst.Value > 100) and (Player.playerstats.Hunger.Value < 0 or Player.playerstats.Hunger.Value > 100)
				Notify('Gave ' .. Player.Name .. ' Infinite Vitals')
			end)
		end
	end})

	Sections.Players.Abusive:AddButton({text = 'Kill Player', callback = function()
		for _, Player in pairs(ReturnPlayers()) do
			if Notloaded(Player) then continue end
			Delete(Player.Character.Head)
			Notify('Killed ' .. Player.Name)
		end
	end})
	Sections.Players.Abusive:AddButton({text = 'Explode Player', callback = function()
		for _, Player in pairs(ReturnPlayers()) do
			if Notloaded(Player) then continue end
			Remote.Detonate:FireServer({['Head'] = Player.Character.Head})
			Notify('Exploded ' .. Player.Name)
		end
	end})
	Sections.Players.Abusive:AddButton({text = 'Rocket Player', callback = function()
		for _, Player in pairs(ReturnPlayers()) do
			if Notloaded(Player) then continue end
			Rocket(Player, 90)
			Notify('Made ' .. Player.Name .. ' into a Rocket')
		end
	end})
	Sections.Players.Abusive:AddButton({text = 'Punish Player', callback = function()
		for _, Player in pairs(ReturnPlayers()) do
			if Notloaded(Player) then continue end
			local Storage = MakeStorage(Player)
			for _, v in pairs(Storage:GetChildren()) do
				if v:IsA('Model') and v.Name == Player.Name then
					Delete(v)
				end
			end
			ChangeParent(Player.Character, Storage)
			Notify('Punished ' .. Player.Name)
		end
	end})
	Sections.Players.Abusive:AddButton({text = 'Unpunish Player', callback = function()
		for _, Player in pairs(ReturnPlayers()) do
			if Workspace:FindFirstChild(Player.Name) then
				Notify(Player.Name .. ' is not Punished!')
				continue
			end
			local Storage = MakeStorage(Player)
			for _, v in pairs(Storage:GetChildren()) do
				if v:IsA('Model') and v.Name == Player.Name then
					ChangeParent(v, Workspace)
				end
			end
			Notify('Unpunished ' .. Player.Name)
		end
	end})
	local HordeBusy = false
	Sections.Players.Abusive:AddButton({text = 'Horde Player', callback = function()
		if GetZombie() == nil then
			Notify('No Zombies found, at least one Zombie is required to horde a player')
			return
		elseif HordeBusy == true then
			Notify('Ayarum is busy spawning Zombies already!')
			return
		end
		local Player = ReturnPlayers()[1]
		if not Player then return end
		if Notloaded(Player) then return end
		HordeBusy = true
		Notify('Spawning Zombies, Please Wait...')
		SpawnZombies(Player, 100)
		Notify('Spawned 100 Zombies at ' .. Player.Name)
		HordeBusy = false
	end})
	Sections.Players.Abusive:AddButton({text = 'Delete Player Inventory', callback = function()
		for _, Player in pairs(ReturnPlayers()) do
			WipeInv(Player)
			Notify('Deleted ' .. Player.Name .. '\'s Inventory')
		end
	end})
	local StealWarning = library:AddWarning({type = 'confirm'})
	Sections.Players.Abusive:AddButton({text = 'Steal Player Inventory', callback = function()
		local Player = ReturnPlayers()[1]
		if not Player then return end
		if Player == Client then
			Notify('Cannot steal your own Inventory!')
			return
		end
		StealWarning.text = 'Are you sure you want to steal <b>' .. Player.Name .. '\'s</b> Inventory?\nThis will erase yours in the process!'
		if StealWarning:Show() then
			WipeInv(Client)

			local BackpackSlot = Player.playerstats.slots.slotbackpack

			if BackpackSlot.Value == 1 and BackpackSlot:FindFirstChild('ObjectID') then
				StealSlot(BackpackSlot, Client.playerstats.slots.slotbackpack)
			end

			for _, v in pairs(Player.playerstats.slots:GetChildren()) do
				if v.Value == 1 and v:FindFirstChild('ObjectID') then
					StealSlot(v, Client.playerstats.slots[v.Name])
				end
			end

			for _, v in pairs(Player.playerstats.utilityslots:GetChildren()) do
				if v.Value == 1 and v:FindFirstChild('ObjectID') then
					StealSlot(v, Client.playerstats.utilityslots[v.Name])
				end
			end

			for _, v in pairs(Player.playerstats.attachments:GetChildren()) do
				for _, a in pairs(v:GetChildren()) do
					if a.Value == 1 and a:FindFirstChild('ObjectID') then
						StealSlot(a, Client.playerstats.attachments[v.Name][a.Name])
					end
				end
			end

			for _, v in pairs(Player.playerstats.character:GetChildren()) do
				if v.Name == 'hat' or v.Name == 'accessory' then
					if v.Value == 1 and v:FindFirstChild('ObjectID') then
						StealSlot(v, Client.playerstats.character[v.Name])
					end
				end
			end

			Notify('Stole ' .. Player.Name .. '\'s Inventory')
		end
	end})
	Sections.Players.Abusive:AddButton({text = 'Steal Player C4', callback = function()
		for _, Player in pairs(ReturnPlayers()) do
			for _, v in pairs(Workspace:GetChildren()) do
				if v.Name == 'C4Placed' and v:FindFirstChild('Owner') and v.Owner.Value == Player.Name then
					ChangeValue(v.Owner, Client.Name)
				end
			end
			Notify('Stole ' .. Player.Name .. '\'s C4')
		end
	end})

	Sections.Players.Moderation:AddButton({text = 'Kick Player', callback = function()
		for _, Player in pairs(ReturnPlayers()) do
			KickPlayer(Player.Name)
			Notify('Kicked ' .. Player.Name)
		end
	end})
	Sections.Players.Moderation:AddButton({text = 'Ban Player', callback = function()
		for _, Player in pairs(ReturnPlayers()) do
			table.insert(Banned, Player.Name)
			KickPlayer(Player.Name)
			Notify('Banned ' .. Player.Name)
		end
	end})
	Sections.Players.Moderation:AddButton({text = 'Permban Player', callback = function()
		for _, Player in pairs(ReturnPlayers()) do
			if Noclient(Player, 'PermBan') then continue end
			if isfolder('Ayarum') and isfile('Ayarum/AutoBans.json') then
				local Info = readfile('Ayarum/AutoBans.json')
				local DecodedInfo = HttpService:JSONDecode(Info)
				if typeof(DecodedInfo) == 'table' then
					table.insert(DecodedInfo, Player.Name)
					library.options['BanPlayer Selection']:AddValue(Player.Name)
					KickPlayer(Player.Name)
					local EncodedInfo = HttpService:JSONEncode(DecodedInfo)
					writefile('Ayarum/AutoBans.json', EncodedInfo)
					Notify('Kicked ' .. Player.Name)
					Notify('Added ' .. Player.Name .. ' to your AutoBan List')
				else
					Notify('Error with Ayarum/AutoBans.json: Contents arent a valid JSON Table!')
				end
			elseif not isfile('Ayarum/AutoBans.json') then
				library.options['BanPlayer Selection']:AddValue(Player.Name)
				KickPlayer(Player.Name)
				local EncodedInfo = HttpService:JSONEncode({Player.Name})
				writefile('Ayarum/AutoBans.json', EncodedInfo)
				Notify('Kicked ' .. Player.Name)
				Notify('Added ' .. Player.Name .. ' to your AutoBan List')
			else
				Notify('Error finding folder Ayarum: Folder does not Exist!')
			end
		end
	end})
	Sections.Players.Moderation:AddDivider()
	Sections.Players.Moderation:AddButton({text = 'Combat Log Player', callback = function()
		for _, Player in pairs(ReturnPlayers()) do
			ChangeValue(Player.playerstats.combat, true)
			Player.TrackCombat:FireServer()
			KickPlayer(Player.Name)
			Notify('Combat Logged ' .. Player.Name)
		end
	end})
	Sections.Players.Moderation:AddButton({text = 'Combat Ban Player', callback = function()
		for _, Player in pairs(ReturnPlayers()) do
			ChangeValue(Player.playerstats.combat, true)
			Player.TrackCombat:FireServer()
			table.insert(Banned, Player.Name)
			KickPlayer(Player.Name)
			Notify('Combat Banned ' .. Player.Name)
		end
	end})
	Sections.Players.Moderation:AddButton({text = 'Combat Permban Player', callback = function()
		for _, Player in pairs(ReturnPlayers()) do
			if Noclient(Player, 'Combat PermBan') then continue end
			if isfolder('Ayarum') and isfile('Ayarum/AutoBans.json') then
				local Info = readfile('Ayarum/AutoBans.json')
				local DecodedInfo = HttpService:JSONDecode(Info)
				if typeof(DecodedInfo) == 'table' then
					ChangeValue(Player.playerstats.combat, true)
					Player.TrackCombat:FireServer()
					table.insert(DecodedInfo, Player.Name)
					library.options['BanPlayer Selection']:AddValue(Player.Name)
					KickPlayer(Player.Name)
					local EncodedInfo = HttpService:JSONEncode(DecodedInfo)
					writefile('Ayarum/AutoBans.json', EncodedInfo)
					Notify('Combat Logged ' .. Player.Name)
					Notify('Added ' .. Player.Name .. ' to your AutoBan List')
				else
					Notify('Error with Ayarum/AutoBans.json: Contents arent a valid JSON Table!')
				end
			elseif not isfile('Ayarum/AutoBans.json') then
				library.options['BanPlayer Selection']:AddValue(Player.Name)
				KickPlayer(Player.Name)
				local EncodedInfo = HttpService:JSONEncode({Player.Name})
				writefile('Ayarum/AutoBans.json', EncodedInfo)
				Notify('Combat Logged ' .. Player.Name)
				Notify('Added ' .. Player.Name .. ' to your AutoBan List')
			else
				Notify('Error finding folder Ayarum: Folder does not Exist!')
			end
		end
	end})
	local UnpermbanWarning = library:AddWarning({type = 'confirm'})
	Sections.Players.Moderation:AddButton({text = 'Unpermban Player', callback = function()
		local Player = library.flags['BanPlayer Selection']
		UnpermbanWarning.text = 'Are you sure you want to remove <b>' .. Player .. '</b> from your AutoBan list?'
		if UnpermbanWarning:Show() then
			if isfolder('Ayarum') and isfile('Ayarum/AutoBans.json') then
				local Info = readfile('Ayarum/AutoBans.json')
				local DecodedInfo = HttpService:JSONDecode(Info)
				if typeof(DecodedInfo) == 'table' and table.find(DecodedInfo, Player) then
					table.remove(DecodedInfo, table.find(DecodedInfo, Player))
					library.options['BanPlayer Selection']:RemoveValue(Player)
					local EncodedInfo = HttpService:JSONEncode(DecodedInfo)
					writefile('Ayarum/AutoBans.json', EncodedInfo)
					Notify('Removed ' .. Player .. ' from your AutoBan List')
				else
					Notify('Error with Ayarum/AutoBans.json: Contents arent a valid JSON Table!')
				end
			elseif not isfile('Ayarum/AutoBans.json') then
				Notify('Error finding file Ayarum/AutoBans.json: File does not Exist!')
			else
				Notify('Error finding folder Ayarum: Folder does not Exist!')
			end
		end
	end})

	Sections.Players.Teleporting:AddButton({text = 'Goto Player', callback = function()
		local Player = ReturnPlayers()[1]
		if not Player then return end
		if Notloaded(Player) or Notloaded(Client) then return end
		Teleport(Client.Name, Player.Character.Torso.CFrame + Vector3.new(0, 0, 3))
		Notify('Teleported you to ' .. Player.Name)
	end})
	Sections.Players.Teleporting:AddButton({text = 'Bring Player', callback = function()
		if Notloaded(Client) then return end
		for _, Player in pairs(ReturnPlayers()) do
			if Notloaded(Player) then continue end
			Teleport(Player.Name, Client.Character.Torso.CFrame + Vector3.new(0, 0, 3))
			Notify('Brought ' .. Player.Name .. ' to you')
		end
	end})
	Sections.Players.Teleporting:AddButton({text = 'Bring Player To Location', callback = function()
		for _, Player in pairs(ReturnPlayers()) do
			if Notloaded(Player) then continue end
			Teleport(Player.Name, Workspace.Locations[library.flags['Location Selection']].CFrame + Vector3.new(0, 10, 0))
			Notify('Teleported ' .. Player.Name .. ' to ' .. library.flags['Location Selection'])
		end
	end})

	local ClearingFog = false
	Sections.Client.Camera:AddToggle({text = 'Remove Fog', state = false, callback = function(bool)
		ClearingFog = bool
		if ClearingFog then
			spawn(function()
				repeat wait()
					Lighting.FogStart = 10000
					Lighting.FogEnd = 100000
				until ClearingFog == false
			end)
		else
			wait()
			Lighting.FogEnd = 1300
			Lighting.FogStart = 800
		end
	end})
	Sections.Client.Camera:AddToggle({text = 'FullBright', state = false, callback = function(bool)
		FullBrightOn = bool
		Lighting.ClockTime = 12
		Lighting.Brightness = 1
	end})
	Sections.Client.Camera:AddToggle({text = 'Disable Zoom Limiter', state = false, callback = function(bool)
		DisableZoomLimiter = bool
		local Storage = MakeStorage(Client)
		if not DisableZoomLimiter then
			Client.CameraMaxZoomDistance = 15
			if Storage:FindFirstChild('CameraZoom') then
				local CameraZoom = Storage.CameraZoom
				if Client.PlayerGui:FindFirstChild('CameraZoom') then
					CameraZoom:Destroy()
				else
					CameraZoom.Parent = Client.PlayerGui
				end
			end
		else
			Client.CameraMaxZoomDistance = 1150
			if Client.PlayerGui:FindFirstChild('CameraZoom') then
				local CameraZoom = Client.PlayerGui.CameraZoom
				if Client:FindFirstChild('CameraZoom') then
					CameraZoom:Destroy()
				else
					CameraZoom.Parent = Storage
				end
			end
		end
	end})

	local InfHealthWarning = library:AddWarning({type = 'confirm'})
	Sections.Client.Character:AddButton({text = 'Infinite Health', callback = function()
		InfHealthWarning.text = 'Are you sure you want Infinite Health?\n\nThis cannot be reverted until you Reset!'
		if InfHealthWarning:Show() then God() end
	end})
	Sections.Client.Character:AddButton({text = 'Remove Fall Damage', callback = function()
		if Client.PlayerGui.HitEqualsYouDie:FindFirstChild('JumpLimiter') then
			Delete(Client.PlayerGui.HitEqualsYouDie.JumpLimiter)
			Notify('Removed Fall Damage')
		else
			Notify('Fall Damage has already been removed!')
		end
	end})
	Sections.Client.Character:AddToggle({text = 'WalkSpeed', state = false, callback = function(bool)
		WalkEnabled = bool
		if bool == false then
			wait()
			getrenv()._G.walkbase = 16
		end
	end})
	Sections.Client.Character:AddSlider({text = 'Speed', value = WalkValue, min = 0, max = 500, callback = function(val)
		WalkValue = val
	end})
	Sections.Client.Character:AddBind({text = 'Toggle', flag = 'WalkSpeed Toggle', nomouse = true, key = 'T', callback = function(a)
		library.options['WalkSpeed']:SetState(a)
	end})
	Sections.Client.Character:AddDivider()
	Sections.Client.Character:AddToggle({text = 'JumpPower', state = false, callback = function(bool)
		JumpEnabled = bool
		if bool == false then
			wait()
			Client.Character.Humanoid.JumpPower = 50
		end
	end})
	Sections.Client.Character:AddSlider({text = 'Power', value = JumpValue, min = 0, max = 500, callback = function(val)
		JumpValue = val
	end})
	Sections.Client.Character:AddBind({text = 'Toggle', flag = 'JumpPower Toggle', nomouse = true, key = 'T', callback = function(a)
		library.options['JumpPower']:SetState(a)
	end})
	Sections.Client.Character:AddDivider()
	local InfStamina = false
	Sections.Client.Character:AddToggle({text = 'Infinite Stamina', state = false, callback = function(bool)
		InfStamina = bool
		if InfStamina then
			spawn(function()
				repeat wait()
					if Client:FindFirstChild('Backpack') and Client.Backpack:FindFirstChild('GlobalFunctions') then
						Client.Backpack.GlobalFunctions.Stamina.Value = 100
					end
				until not InfStamina
			end)
		end
	end})
	Sections.Client.Character:AddToggle({text = 'Loop Vitals', state = false, callback = function(bool)
		if bool == true then
			repeat
				ChangeValue(Client.playerstats.Hunger, 100)
				ChangeValue(Client.playerstats.Thirst, 100)
				wait(20)
			until library.flags['Loop Vitals'] == false
		end
	end})
	Sections.Client.Character:AddToggle({text = 'LoopHeal', state = false, callback = function(bool)
		if bool == true then
			repeat
				if Client.Character and Client.Character.Humanoid and Client.Character.Humanoid.Health < Client.Character.Humanoid.MaxHealth then
					fireServer('Damage', Client.Character.Humanoid, -100)
				end
				wait()
			until library.flags['LoopHeal'] == false
		end
	end})
	Sections.Client.Character:AddToggle({text= 'Noclip', state = false, callback = function(bool)
		if bool == true then
			if not Client.Character then
				Notify('Your Character is Missing!')
				library.options.Noclip:SetState(false)
				return
			end
			while library.flags['Noclip'] == true do
				for _, v in pairs(Client.Character:GetChildren()) do
					pcall(function()
						if v.ClassName == 'Part' then
							v.CanCollide = false
						elseif v.ClassName == 'Model' then
							v.Head.CanCollide = false
						end
					end)
				end
				RunService.Stepped:Wait()
			end
		end
	end})

	Sections.Client.Other:AddButton({text = 'Bring Bodies', callback = function()
		if Workspace:FindFirstChild('Corpse') or Workspace:FindFirstChild('GhostCorpse') then
			for _, v in pairs(Workspace:GetChildren()) do
				if v.Name == 'Corpse' or v.Name == 'GhostCorpse' then
					v:MoveTo(Client.Character.Torso.Position + Vector3.new(math.random(-10, 10), 0, math.random(-10, 10)))
				end
			end
			Notify('Teleported Bodies to ' .. Client.Name)
		else
			Notify('No Bodies in this server')
		end
	end})
	Sections.Client.Other:AddButton({text = 'Bring Crates', callback = function()
		if Workspace:FindFirstChild('LargeCrateOpen') or Workspace:FindFirstChild('SmallCrateOpen') then
			for _, v in pairs(Workspace:GetChildren()) do
				if v.Name == 'LargeCrateOpen' or v.Name == 'SmallCrateOpen' then
					v:MoveTo(Client.Character.Torso.Position + Vector3.new(math.random(-10, 10), 0, math.random(-10, 10)))
				end
			end
			Notify('Teleported Crates to ' .. Client.Name)
		else
			Notify('No Crates in this server')
		end
	end})
	Sections.Client.Other:AddButton({text = 'Teleport to Xbox Server', callback = function()
		if IsXbox then
			Notify('You are already in an Xbox Server!')
		else
			if Mapname == 'Amend' or Mapname == 'Reimagined' or Mapname == 'Reborn' then
				local XboxIDs = {
					['Amend'] = 1228677761,
					['Reimagined'] = 1228674372,
					['Reborn'] = 1228676522
				}
				Notify('Found Xbox Server for ' .. Mapname .. ', Teleporting...')
				wait(0.5)
				local TeleportService = game:GetService('TeleportService')
				TeleportService:Teleport(XboxIDs[Mapname], Client)
			else
				Notify('Couldn\'t find an Xbox Server for ' .. Mapname)
			end
		end
	end})
	for i = 1, #Walks do
		Sections.Client.Other:AddToggle({text = string.gsub(Walks[i][1], 'Placed', ' Walk'), state = false, callback = function(bool)
			Walks[i][2] = bool
		end})
	end
	Sections.Client.Other:AddDivider()
	Sections.Client.Other:AddToggle({text = 'Click Delete', state = false, skipflag = true})

	spawn(function()
		repeat wait() until library.fullloaded

		local MagFixCount = 0
		local FixedMag = false
		repeat wait() until Client:FindFirstChild('playerstats') and Client.playerstats:FindFirstChild('slots')
		for _, v in pairs(Client.playerstats.slots:GetChildren()) do
			if v:FindFirstChild('ObjectID') and v.ObjectID:FindFirstChild('Clip') then
				repeat wait() until v.ObjectID.Clip:FindFirstChild('MaxClip')
				local DeobClip = getrenv()._G.Deobfuscate(v.ObjectID.Clip.Value)
				if DeobClip > v.ObjectID.Clip.MaxClip.Value then
					FixedMag = true
					MagFixCount = MagFixCount + 1
					ChangeValue(v.ObjectID.Clip.MaxClip, DeobClip)
				end
			end
		end

		if FixedMag then
			local Plural = MagFixCount > 1 and 's' or ''
			Notify('Found and fixed ' .. tostring(MagFixCount) .. ' magazine' .. Plural)
		end
		for _, v in pairs(Remote:GetChildren()) do
			if v:IsA('StringValue') then
				Notify('Deleted StringValue ' .. v.Name, 15)
				Delete(v)
			end
		end

		if typeof(FixItems) == 'table' then
			for i = 1, #FixItems do
				ChangeParent(FixItems[i][1], FixItems[i][2])
				Notify('Moved ' .. FixItems[i][1].Name .. ' from ' .. FixItems[i][3] .. ' to ' .. FixItems[i][4], 15)
			end
			table.clear(FixItems)
		end

		if isfolder('Ayarum') and isfile('Ayarum/AutoBans.json') then
			local Info = readfile('Ayarum/AutoBans.json')
			local DecodedInfo = HttpService:JSONDecode(Info)
			if typeof(DecodedInfo) == 'table' then
				for _, v in pairs(Players:GetPlayers()) do
					if table.find(DecodedInfo, v.Name) then
						KickPlayer(v.Name)
						Notify('Kicked ' .. v.Name .. ' [AutoBan]')
					end
				end
			end
		end

		local Hidden = {}
		spawn(function()
			while library and wait(0.5) do
				for _, v in pairs(Workspace:GetChildren()) do
					if Hidden[v.Name] == true then
						Delete(v)
					end
				end
			end
		end)
		spawn(function()
			while library do
				wait(10)
				CheckForExploiters()
				for _, v in pairs(Workspace:GetChildren()) do
					if v:FindFirstChild('Humanoid') and not LootDrops:FindFirstChild(v.Name) and not Players:FindFirstChild(v.Name) then
						Hidden[v.Name] = true
						Notify(v.Name .. ' was hidden from the Player List!')
					end
				end
			end
		end)

		library:AddConnection(Mouse.Button1Down, function()
			if library.flags['Click Delete'] == true then
				local v = Mouse.Target
				if v.Name == 'Baseplate' then return end
				Delete(v)
			end
		end)

		HttpGet('UI.lua')
	end)
end