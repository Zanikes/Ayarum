local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Lighting = game:GetService('Lighting')

local ShadersOn = false
local Effects = {
	'BloomEffect',
	'BlurEffect',
	'ColorCorrectionEffect',
	'ColorGradingEffect',
	'DepthOfFieldEffect',
	'SunRaysEffect',
	'Atmosphere',
	'Clouds',
	'Sky'
}
local LightingOptions = {
	Ambient = Color3.fromRGB(59, 33, 27),
	Brightness = 2.25,
	ColorShift_Bottom = Color3.fromRGB(11, 0, 20),
	ColorShift_Top = Color3.fromRGB(240, 127, 14),
	EnvironmentDiffuseScale = 0.2,
	EnvironmentSpecularScale = 0.2,
	GlobalShadows = true,
	OutdoorAmbient = Color3.fromRGB(34, 0, 49),
	ShadowSoftness = 0.2,
	GeographicLatitude = 45,
	ExposureCompensation = 0.5,
	FogColor = Color3.fromRGB(94, 76, 106)
}
local OldLighting = {}
for Property, Value in pairs(LightingOptions) do
	OldLighting[Property] = Lighting[Property]
	Lighting:GetPropertyChangedSignal(Property):Connect(function()
		if ShadersOn then
			Lighting[Property] = Value
		end
	end)
end

local AddProtectedInstance
AddProtectedInstance = function(Type, Properties)
	local NewInstance = Instance.new(Type)
	NewInstance.Name = 'AyarumProtectedInstance'
	NewInstance.Parent = Lighting

	for Property, Value in pairs(Properties) do
		NewInstance[Property] = Value
	end

	local ChangedFunc
	ChangedFunc = NewInstance.AncestryChanged:Connect(function()
		if not ShadersOn then return ChangedFunc:Disconnect() end
		if NewInstance.Parent ~= nil then
			NewInstance.Parent = Lighting
		else
			AddProtectedInstance(Type, Properties)
			ChangedFunc:Disconnect()
		end
	end)
end

local function AddShaders(State)
	ShadersOn = State
	if ShadersOn then
		if not ReplicatedStorage:FindFirstChild('AyarumShadersStorage') then
			local AyarumShadersStorage = Instance.new('Folder')
			AyarumShadersStorage.Name = 'AyarumShadersStorage'
			AyarumShadersStorage.Parent = ReplicatedStorage
		end

		for Property, Value in pairs(LightingOptions) do
			Lighting[Property] = Value
		end
		for _, v in pairs(Lighting:GetChildren()) do
			if table.find(Effects, v.ClassName) then
				v.Parent = ReplicatedStorage.AyarumShadersStorage
			end
		end

		AddProtectedInstance('BloomEffect', {
			Intensity = 0.3,
			Size = 10,
			Threshold = 0.8
		})
		AddProtectedInstance('ColorCorrectionEffect', {
			Brightness = 0.1,
			Contrast = 0.35,
			Saturation = -0.3,
			TintColor = Color3.fromRGB(255, 235, 203)
		})
		AddProtectedInstance('SunRaysEffect', {
			Intensity = 0.075,
			Spread = 0.727
		})
		AddProtectedInstance('Sky', {
			SkyboxBk = 'rbxassetid://151165214',
			SkyboxDn = 'rbxassetid://151165197',
			SkyboxFt = 'rbxassetid://151165224',
			SkyboxLf = 'rbxassetid://151165191',
			SkyboxRt = 'rbxassetid://151165206',
			SkyboxUp = 'rbxassetid://151165227',
			SunAngularSize = 10
		})
		AddProtectedInstance('Atmosphere', {
			Density = 0.364,
			Offset = 0.556,
			Color = Color3.fromRGB(199, 175, 166),
			Decay = Color3.fromRGB(44, 39, 33),
			Glare = 0.36,
			Haze = 1.72
		})
		AddProtectedInstance('DepthOfFieldEffect', {
			FarIntensity = 0.2,
			FocusDistance = 0.05,
			InFocusRadius = 20,
			NearIntensity = 0
		})
	else
		if not ReplicatedStorage:FindFirstChild('AyarumShadersStorage') then return end
		for Property, Value in pairs(OldLighting) do
			Lighting[Property] = Value
		end
		for _, v in pairs(Lighting:GetChildren()) do
			if table.find(Effects, v.ClassName) then
				v:Destroy()
			end
		end
		for _, v in pairs(ReplicatedStorage.AyarumShadersStorage:GetChildren()) do
			v.Parent = Lighting
		end
	end
end

return AddShaders