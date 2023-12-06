local ContentProvider = game:GetService('ContentProvider')
local InputService = game:GetService('UserInputService')
local TweenService = game:GetService('TweenService')
local RunService = game:GetService('RunService')
local Mouse = game.Players.LocalPlayer:GetMouse()
local Ids = {
	'rbxassetid://10025201748',
	'rbxassetid://6814674798',
	'rbxassetid://11421095840',
	'rbxassetid://11419718822',
	'rbxassetid://4155801252',
	'rbxassetid://6034308946'
}
ContentProvider:PreloadAsync(Ids)

local Keys = Enum.KeyCode
local InputTypes = Enum.UserInputType
local BlacklistedKeys = {Keys.Unknown, Keys.W, Keys.A, Keys.S, Keys.D, Keys.Slash, Keys.Tab, Keys.Escape}
local WhitelistedMouseInputs = {InputTypes.MouseButton1, InputTypes.MouseButton2, InputTypes.MouseButton3}

local function Tween(Instance, Time, Properties)
	TweenService:Create(Instance, TweenInfo.new(Time, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), Properties):Play()
end
local function QTween(Instance, Time, Properties, In)
	TweenService:Create(Instance, TweenInfo.new(Time, Enum.EasingStyle.Quart, In and Enum.EasingDirection.In or Enum.EasingDirection.Out), Properties):Play()
end
local function BTween(Instance, Time, Properties, In)
	TweenService:Create(Instance, TweenInfo.new(Time, Enum.EasingStyle.Back, In and Enum.EasingDirection.In or Enum.EasingDirection.Out), Properties):Play()
end
local function STween(Instance, Time, Properties)
	TweenService:Create(Instance, TweenInfo.new(Time, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), Properties):Play()
end

if getgenv().ayarum then
	getgenv().ayarum:Unload()
end

local Library = {
	flags = {},
	options = {},
	tabs = {},
	theme = {},
	connections = {},
	open = false,
	loaded = false,
	fullloaded = false,
	selectedtab = nil,
	popup = nil,
	warning = nil,
	themecolor1 = Color3.fromRGB(255, 130, 130),
	themecolor2 = Color3.fromRGB(255, 135, 210),
	foldername = 'Configs',
	fileext = '.json',
	useconfigs = false,
	autoload = ''
}
getgenv().ayarum = Library

local function CheckTable(Table, Default)
	if typeof(Table) ~= 'table' or Table == {} then return Default end
	for Option, Value in pairs(Default) do
		if typeof(Table[Option]) ~= typeof(Value) then
			Table[Option] = Value
		end
	end
	return Table
end

local function GetTextSize(Text, TextSize, Font)
	return game:GetService('TextService'):GetTextSize(Text, TextSize, Font, Vector2.new(9e9, 9e9))
end

local function Round(Num, Bracket)
	Bracket = Bracket or 1
	local a = math.floor(Num / Bracket + (math.sign(Num) * 0.5)) * Bracket
	if a < 0 then
		a = a + Bracket
	end
	return a
end

local function GetDecimal(Number)
	Number = string.split(tostring(Number), '.')
	local Amount = 0
	if Number[2] then
		Amount = #Number[2]
	end
	return Amount
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

local function tablefind(Table, Name)
	for i, _ in pairs(Table) do
		if i == Name then return true end
	end
	return false
end

local ChromaColor
local RainbowTime = 5
spawn(function()
	while wait() do
		ChromaColor = Color3.fromHSV(tick() % RainbowTime / RainbowTime, 1, 1)
	end
end)

local function Border(Object)
	local UIStroke = Instance.new('UIStroke')
	UIStroke.Name = 'UIStroke'
	UIStroke.Parent = Object
	UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIStroke.Color = Object.BorderColor3
	return UIStroke
end

local function Roundify(Object)
	Object.BorderSizePixel = 0
	local UICorner = Instance.new('UICorner')
	UICorner.Parent = Object
	UICorner.CornerRadius = UDim.new(0, 6)
	return UICorner
end

local function Gradient(Object, Rotation)
	local UIGradient = Instance.new('UIGradient')
	UIGradient.Parent = Object
	UIGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Library.themecolor1), ColorSequenceKeypoint.new(1, Library.themecolor2)})
	UIGradient.Rotation = Rotation or 0
	table.insert(Library.theme, UIGradient)
	return UIGradient
end

local function Glow(Object, Color)
	local ImageLabel = Instance.new('ImageLabel')
	ImageLabel.Name = 'Glow'
	ImageLabel.Parent = Object
	ImageLabel.BackgroundTransparency = 1
	ImageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	ImageLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
	ImageLabel.Size = UDim2.new(1, 60, 1, 60)
	ImageLabel.Image = 'rbxassetid://10025201748'
	ImageLabel.ScaleType = Enum.ScaleType.Slice
	ImageLabel.SliceCenter = Rect.new(38, 38, 262, 262)
	if Color then
		ImageLabel.ImageColor3 = Color
	else
		ImageLabel.ImageColor3 = Color3.new(1, 1, 1)
		Gradient(ImageLabel)
	end
	return ImageLabel
end

function Library:AddConnection(connection, name, callback)
	callback = type(name) == 'function' and name or callback
	connection = connection:Connect(callback)
	if name ~= callback then
		Library.connections[name] = connection
	else
		table.insert(Library.connections, connection)
	end
	return connection
end

local Ayarumv4 = Instance.new('ScreenGui')
local Mainframe = Instance.new('Frame')
local DragBar = Instance.new('Frame')
local MouseUnlock = Instance.new('TextButton')
local Title = Instance.new('TextLabel')
local TabButtonsHolder = Instance.new('Frame')
local TabButtonsLayout = Instance.new('UIListLayout')
local Holder = Instance.new('Frame')

Ayarumv4.Name = 'Ayarum v4'
Ayarumv4.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Ayarumv4.DisplayOrder = 200
Ayarumv4.ResetOnSpawn = false
Ayarumv4.IgnoreGuiInset = true

Mainframe.Name = 'Mainframe'
Mainframe.Parent = Ayarumv4
Mainframe.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
Mainframe.BorderColor3 = Color3.fromRGB(44, 44, 60)
Mainframe.Position = UDim2.new(0, 10, 0, 46)
Mainframe.Size = UDim2.new(0, 519, 0, 450)
Mainframe.Visible = false
Roundify(Mainframe)
Glow(Mainframe, Color3.new(0, 0, 0))

DragBar.Name = 'DragBar'
DragBar.Parent = Mainframe
DragBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
DragBar.BackgroundTransparency = 1.000
DragBar.Position = UDim2.new(0, 0, 0, 0)
DragBar.Size = UDim2.new(1, 0, 0, 30)

MouseUnlock.Name = 'MouseUnlock'
MouseUnlock.Parent = Mainframe
MouseUnlock.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MouseUnlock.BackgroundTransparency = 1.000
MouseUnlock.BorderSizePixel = 0
MouseUnlock.Position = UDim2.new(0, 0, 0, 0)
MouseUnlock.Size = UDim2.new(0, 0, 0, 0)
MouseUnlock.Modal = true
MouseUnlock.Font = Enum.Font.SourceSans
MouseUnlock.TextColor3 = Color3.fromRGB(0, 0, 0)
MouseUnlock.TextSize = 14.000
MouseUnlock.Text = ''

Title.Name = 'Title'
Title.Parent = Mainframe
Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1.000
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Size = UDim2.new(1, -10, 0, 25)
Title.RichText = true
Title.Font = Enum.Font.Nunito
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20.000
Title.TextXAlignment = Enum.TextXAlignment.Left
Gradient(Title)

TabButtonsHolder.Name = 'TabButtonsHolder'
TabButtonsHolder.Parent = Mainframe
TabButtonsHolder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TabButtonsHolder.BackgroundTransparency = 1.000
TabButtonsHolder.Position = UDim2.new(0, 14, 0, 30)
TabButtonsHolder.Size = UDim2.new(1, -28, 0, 24)

TabButtonsLayout.Name = 'TabButtonsLayout'
TabButtonsLayout.Parent = TabButtonsHolder
TabButtonsLayout.FillDirection = Enum.FillDirection.Horizontal
TabButtonsLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabButtonsLayout.Padding = UDim.new(0, 7)

Holder.Name = 'Holder'
Holder.Parent = Mainframe
Holder.BackgroundColor3 = Color3.fromRGB(27, 27, 36)
Holder.BorderColor3 = Color3.fromRGB(44, 44, 60)
Holder.ClipsDescendants = true
Holder.Position = UDim2.new(0, 14, 0, 70)
Holder.Size = UDim2.new(1, -28, 1, -84)
Roundify(Holder)
Border(Holder)

Library:AddConnection(Title:GetPropertyChangedSignal('Text'), function()
	local SetText = Title.Text:gsub('<b>', ''):gsub('</b>', '')
	local Size = GetTextSize(SetText, Title.TextSize, Title.Font).X
	Title.Size = UDim2.new(0, Size, 0, 25)
end)
Title.Text = '<b>Ayarum v4.1</b>'

local SelectedTabButton
local SelectedTabPage
local HasTabBeenAdded = false
function Library:AddTab(Text)
	Text = typeof(Text) == 'string' and Text or 'New Tab'

	local Tab = {selected = false, sections = {}, first = not HasTabBeenAdded}
	HasTabBeenAdded = true

	local TabFrame = Instance.new('Frame')
	local TabLayout = Instance.new('UIListLayout')
	local TabButton = Instance.new('TextButton')
	local TabButtonText = Instance.new('TextLabel')
	local TabButtonGradient = Instance.new('Frame')

	TabFrame.Name = 'Tab'
	TabFrame.Parent = Holder
	TabFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TabFrame.BackgroundTransparency = 1.000
	TabFrame.Size = UDim2.new(1, 0, 0, 0)
	TabFrame.Visible = false

	TabLayout.Name = 'TabLayout'
	TabLayout.Parent = TabFrame
	TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	TabLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	TabLayout.FillDirection = Enum.FillDirection.Horizontal
	TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
	TabLayout.Padding = UDim.new(0, 0)

	TabButton.Name = 'TabButton'
	TabButton.Parent = TabButtonsHolder
	TabButton.BackgroundColor3 = Color3.fromRGB(27, 27, 36)
	TabButton.BorderColor3 = Color3.fromRGB(44, 44, 60)
	TabButton.Size = UDim2.new(0, 58, 1, 0)
	TabButton.AutoButtonColor = false
	TabButton.Font = Enum.Font.Nunito
	TabButton.Text = ''
	TabButton.TextColor3 = Color3.fromRGB(144, 144, 165)
	TabButton.TextSize = 16.000
	Roundify(TabButton)
	Border(TabButton)

	TabButtonText.Name = 'TabButtonText'
	TabButtonText.Parent = TabButton
	TabButtonText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TabButtonText.BackgroundTransparency = 1.000
	TabButtonText.Size = UDim2.new(1, 0, 1, 0)
	TabButtonText.Font = Enum.Font.Nunito
	TabButtonText.Text = Text
	TabButtonText.TextColor3 = Color3.fromRGB(144, 144, 165)
	TabButtonText.TextSize = 16.000

	TabButtonGradient.Name = 'TabButtonGradient'
	TabButtonGradient.Parent = TabButton
	TabButtonGradient.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	TabButtonGradient.BackgroundTransparency = 1.000
	TabButtonGradient.BorderColor3 = Color3.fromRGB(27, 42, 53)
	TabButtonGradient.BorderSizePixel = 0
	TabButtonGradient.Size = UDim2.new(1, 0, 1, 0)
	TabButtonGradient.ZIndex = 0
	Roundify(TabButtonGradient)
	Border(TabButtonGradient).Color = Color3.new(1, 1, 1)
	TabButtonGradient.UIStroke.Transparency = 1
	Gradient(TabButtonGradient.UIStroke)
	Glow(TabButtonGradient).ImageTransparency = 1
	Gradient(TabButtonGradient)

	TabButton.Size = UDim2.new(0, GetTextSize(TabButtonText.Text, 16, Enum.Font.Nunito).X + 11, 1, 0)

	local function Update()
		local BiggestColumn = 0
		for _, Column in pairs(TabFrame:GetChildren()) do
			if Column:IsA('UIListLayout') then continue end
			local ColumnSize = 10
			for _, Section in pairs(Column:GetChildren()) do
				if Section:IsA('UIListLayout') or Section:IsA('UIPadding') then continue end
				local SectionSize = -Section.SectionHolder.SectionLayout.Padding.Offset
				for _, v in pairs(Section.SectionHolder:GetChildren()) do
					if v:IsA('UIListLayout') or v:IsA('UIPadding') then continue end
					SectionSize = SectionSize + v.AbsoluteSize.Y + Section.SectionHolder.SectionLayout.Padding.Offset
				end
				SectionSize = SectionSize + 35
				Section.Size = UDim2.new(1, 0, 0, SectionSize)
				ColumnSize = ColumnSize + SectionSize + Column.ColumnLayout.Padding.Offset
			end
			Column.Size = UDim2.new(0, 245, 0, ColumnSize)
			if ColumnSize > BiggestColumn then
				BiggestColumn = ColumnSize
			end
		end
		TabFrame.Size = UDim2.new(0, 245 * (#TabFrame:GetChildren() - 1), 0, BiggestColumn)
		if Library.selectedtab == Tab then
			BTween(Mainframe, 0.3, {Size = UDim2.new(0, TabFrame.AbsoluteSize.X + 28, 0, TabFrame.AbsoluteSize.Y + 84)})
		end
	end

	function Tab:Select()
		if SelectedTabPage ~= TabFrame then
			if SelectedTabPage then SelectedTabPage.Visible = false end
			TabFrame.Visible = true
			BTween(Mainframe, 0.3, {Size = UDim2.new(0, TabFrame.AbsoluteSize.X + 28, 0, TabFrame.AbsoluteSize.Y + 84)})
			SelectedTabPage = TabFrame
		end
		if SelectedTabButton ~= TabButton then
			if SelectedTabButton then
				QTween(SelectedTabButton.TabButtonGradient, 0.5, {BackgroundTransparency = 1})
				QTween(SelectedTabButton.TabButtonGradient.Glow, 0.5, {ImageTransparency = 1})
				QTween(SelectedTabButton.TabButtonGradient.UIStroke, 0.5, {Transparency = 1})
			end
			QTween(TabButtonGradient, 0.5, {BackgroundTransparency = 0})
			QTween(TabButtonGradient.Glow, 0.5, {ImageTransparency = 0})
			QTween(TabButtonGradient.UIStroke, 0.5, {Transparency = 0})
			SelectedTabButton = TabButton
		end
		if Library.popup then Library.popup:Close() end
		Library.selectedtab = Tab
	end

	TabButton.MouseEnter:Connect(function()
		if Library.warning then return end
		QTween(TabButton, 0.3, {BackgroundColor3 = Color3.fromRGB(44, 44, 60)})
		QTween(TabButtonGradient, 0.3, {BackgroundColor3 = Color3.new(1, 1, 1)})
		QTween(TabButtonText, 0.3, {TextColor3 = Color3.new(1, 1, 1)})
	end)

	TabButton.MouseLeave:Connect(function()
		QTween(TabButton, 0.3, {BackgroundColor3 = Color3.fromRGB(27, 27, 36)})
		QTween(TabButtonGradient, 0.3, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)})
		QTween(TabButtonText, 0.3, {TextColor3 = Color3.fromRGB(144, 144, 165)})
	end)

	TabButton.MouseButton1Down:Connect(function()
		if Library.warning then return end
		Tab:Select()
	end)

	local ColCount = 0
	function Tab:AddSection(Options)
		Options = CheckTable(Options, {
			text = 'New Section',
			column = 1
		})
		local Column
		for _, v in pairs(TabFrame:GetChildren()) do
			if v.Name == 'Column' and v.LayoutOrder == Options.column then
				Column = v
				break
			end
		end
		if not Column then
			repeat
				ColCount = ColCount + 1

				local ColumnFrame = Instance.new('Frame')
				local ColumnLayout = Instance.new('UIListLayout')
				local ColumnPadding = Instance.new('UIPadding')

				ColumnFrame.Name = 'Column'
				ColumnFrame.Parent = TabFrame
				ColumnFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				ColumnFrame.BackgroundTransparency = 1.000
				ColumnFrame.Size = UDim2.new(0, 245, 1, 0)
				ColumnFrame.LayoutOrder = ColCount

				ColumnLayout.Name = 'ColumnLayout'
				ColumnLayout.Parent = ColumnFrame
				ColumnLayout.SortOrder = Enum.SortOrder.LayoutOrder
				ColumnLayout.Padding = UDim.new(0, 10)

				ColumnPadding.Name = 'ColumnPadding'
				ColumnPadding.Parent = ColumnFrame
				ColumnPadding.PaddingBottom = UDim.new(0, 10)
				ColumnPadding.PaddingLeft = UDim.new(0, 10)
				ColumnPadding.PaddingRight = UDim.new(0, 10)
				ColumnPadding.PaddingTop = UDim.new(0, 10)

				if ColumnFrame.LayoutOrder == Options.column then
					Column = ColumnFrame
				end
			until Column
		end

		local Section = Instance.new('Frame')
		local SectionTitle = Instance.new('TextLabel')
		local SectionHolder = Instance.new('Frame')
		local SectionLayout = Instance.new('UIListLayout')
		local SectionPadding = Instance.new('UIPadding')

		Section.Name = 'Section'
		Section.Parent = Column
		Section.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
		Section.BorderColor3 = Color3.fromRGB(44, 44, 60)
		Section.Size = UDim2.new(1, 0, 0, 200)
		Roundify(Section)
		Border(Section)

		SectionTitle.Name = 'SectionTitle'
		SectionTitle.Parent = Section
		SectionTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		SectionTitle.BackgroundTransparency = 1.000
		SectionTitle.Position = UDim2.new(0, 10, 0, 0)
		SectionTitle.Size = UDim2.new(1, -10, 0, 20)
		SectionTitle.Font = Enum.Font.Nunito
		SectionTitle.RichText = true
		SectionTitle.Text = '<b>' .. Options.text .. '</b>'
		SectionTitle.TextColor3 = Color3.fromRGB(144, 144, 165)
		SectionTitle.TextSize = 16.000
		SectionTitle.TextXAlignment = Enum.TextXAlignment.Left

		SectionHolder.Name = 'SectionHolder'
		SectionHolder.Parent = Section
		SectionHolder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		SectionHolder.BackgroundTransparency = 1.000
		SectionHolder.Position = UDim2.new(0, 0, 0, 25)
		SectionHolder.Size = UDim2.new(1, 0, 1, -35)

		SectionLayout.Name = 'SectionLayout'
		SectionLayout.Parent = SectionHolder
		SectionLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		SectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
		SectionLayout.Padding = UDim.new(0, 6)

		SectionPadding.Name = 'SectionPadding'
		SectionPadding.Parent = SectionHolder
		SectionPadding.PaddingLeft = UDim.new(0, 14)
		SectionPadding.PaddingRight = UDim.new(0, 14)

		SectionLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(Update)

		function Options:AddButton(Options)
			Options = CheckTable(Options, {
				text = 'New Button',
				callback = function() end
			})
			Options.type = 'button'

			local Button = Instance.new('TextButton')
			local ButtonGradient = Instance.new('Frame')

			Button.Name = 'Button'
			Button.Parent = SectionHolder
			Button.BackgroundColor3 = Color3.fromRGB(27, 27, 36)
			Button.BorderColor3 = Color3.fromRGB(44, 44, 60)
			Button.Size = UDim2.new(1, 0, 0, 20)
			Button.AutoButtonColor = false
			Button.Font = Enum.Font.Nunito
			Button.Text = '   ' .. Options.text
			Button.TextColor3 = Color3.fromRGB(144, 144, 165)
			Button.TextSize = 16.000
			Button.TextXAlignment = Enum.TextXAlignment.Left
			Roundify(Button)
			Border(Button)

			ButtonGradient.Name = 'ButtonGradient'
			ButtonGradient.Parent = Button
			ButtonGradient.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ButtonGradient.BackgroundTransparency = 1.000
			ButtonGradient.Size = UDim2.new(1, 0, 1, 0)
			Roundify(ButtonGradient)
			Border(ButtonGradient).Color = Color3.new(1, 1, 1)
			ButtonGradient.UIStroke.Transparency = 1
			Gradient(ButtonGradient.UIStroke)
			Glow(ButtonGradient).ImageTransparency = 1

			Button.MouseEnter:Connect(function()
				if Library.warning or (Library.popup and Library.popup.hovering) then return end
				QTween(Button, 0.3, {BackgroundColor3 = Color3.fromRGB(44, 44, 60)})
			end)

			Button.MouseLeave:Connect(function()
				QTween(Button, 0.3, {BackgroundColor3 = Color3.fromRGB(27, 27, 36)})
				QTween(ButtonGradient.UIStroke, 0.3, {Transparency = 1})
				QTween(ButtonGradient.Glow, 0.3, {ImageTransparency = 1})
			end)

			Button.MouseButton1Down:Connect(function()
				if Library.warning or (Library.popup and Library.popup.hovering) then return end
				QTween(ButtonGradient.UIStroke, 0.3, {Transparency = 0})
				QTween(ButtonGradient.Glow, 0.3, {ImageTransparency = 0})
			end)

			Button.MouseButton1Up:Connect(function()
				QTween(ButtonGradient.UIStroke, 0.3, {Transparency = 1})
				QTween(ButtonGradient.Glow, 0.3, {ImageTransparency = 1})
			end)

			Button.MouseButton1Click:Connect(function()
				if Library.warning or (Library.popup and Library.popup.hovering) then return end

				local Ripple = Instance.new('ImageLabel')

				Ripple.Name = 'Ripple'
				Ripple.Parent = Button
				Ripple.AnchorPoint = Vector2.new(0.5, 0)
				Ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Ripple.BackgroundTransparency = 1.000
				Ripple.Position = UDim2.new(0.5, 0, 0, 0)
				Ripple.Size = UDim2.new(0, 0, 1, 0)
				Ripple.Image = 'rbxassetid://6814674798'
				Ripple.ImageTransparency = 0.500
				Roundify(Ripple)

				QTween(Ripple, 0.5, {ImageTransparency = 1, Size = UDim2.new(1, 0, 1, 0)})

				delay(0.5, function()
					Ripple:Destroy()
				end)

				Options.callback()
			end)
		end

		function Options:AddLabel(Text)
			Text = typeof(Text) == 'string' and Text or 'New Label'

			local Label = Instance.new('TextLabel')

			Label.Name = 'Label'
			Label.Parent = SectionHolder
			Label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Label.BackgroundTransparency = 1.000
			Label.Font = Enum.Font.Nunito
			Label.TextColor3 = Color3.fromRGB(144, 144, 165)
			Label.TextSize = 18.000

			local Options = {text = Text}

			function Options:SetText(NewText)
				NewText = typeof(NewText) == 'string' and NewText or Options.text
				Options.text = NewText
				Label.Text = Options.text
				Label.Size = UDim2.new(1, 0, 0, GetTextSize(Options.text, Label.TextSize, Label.Font).Y + 2)
			end

			function Options:GetText()
				return Options.text
			end

			Options:SetText(Text)
			return Options
		end

		function Options:AddDivider()
			local Divider = Instance.new('Frame')

			Divider.Name = 'Divider'
			Divider.Parent = SectionHolder
			Divider.BackgroundColor3 = Color3.fromRGB(44, 44, 60)
			Divider.BorderSizePixel = 0
			Divider.Size = UDim2.new(1, 28, 0, 1)
		end

		function Options:AddToggle(Options)
			Options = CheckTable(Options, {
				text ='New Toggle',
				state = false,
				callback = function() end,
				skipflag = false
			})
			Options.flag = typeof(Options.flag) == 'string' and Options.flag or Options.text
			if tablefind(Library.options, Options.flag) then
				repeat
					Options.flag = Options.flag .. '_'
				until not tablefind(Library.options, Options.flag)
			end
			Options.type = 'toggle'
			Options.default = Options.state

			local Toggle = Instance.new('TextButton')
			local ToggleText = Instance.new('TextLabel')
			local ToggleHolder = Instance.new('Frame')
			local ToggleBox = Instance.new('Frame')
			local BoxFiller = Instance.new('Frame')
			local FillerGradient = Instance.new('Frame')
			local ToggleGradient = Instance.new('Frame')

			Toggle.Name = 'Toggle'
			Toggle.Parent = SectionHolder
			Toggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Toggle.BackgroundTransparency = 1.000
			Toggle.Size = UDim2.new(1, 0, 0, 20)
			Toggle.Font = Enum.Font.SourceSans
			Toggle.Text = ''
			Toggle.TextColor3 = Color3.fromRGB(0, 0, 0)
			Toggle.TextSize = 14.000

			ToggleText.Name = 'ToggleText'
			ToggleText.Parent = Toggle
			ToggleText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ToggleText.BackgroundTransparency = 1.000
			ToggleText.Size = UDim2.new(1, 0, 1, 0)
			ToggleText.Font = Enum.Font.Nunito
			ToggleText.Text = Options.text
			ToggleText.TextColor3 = Color3.fromRGB(144, 144, 165)
			ToggleText.TextSize = 16.000
			ToggleText.TextXAlignment = Enum.TextXAlignment.Left

			ToggleHolder.Name = 'ToggleHolder'
			ToggleHolder.Parent = Toggle
			ToggleHolder.AnchorPoint = Vector2.new(1, 0)
			ToggleHolder.BackgroundColor3 = Color3.fromRGB(27, 27, 36)
			ToggleHolder.BorderColor3 = Color3.fromRGB(44, 44, 60)
			ToggleHolder.Position = UDim2.new(1, 0, 0, 0)
			ToggleHolder.Size = UDim2.new(0, 45, 1, 0)
			Roundify(ToggleHolder)
			Border(ToggleHolder)

			ToggleBox.Name = 'ToggleBox'
			ToggleBox.Parent = ToggleHolder
			ToggleBox.BackgroundColor3 = Color3.fromRGB(34, 34, 45)
			ToggleBox.BorderSizePixel = 0
			ToggleBox.Position = UDim2.new(0, 2, 0, 2)
			ToggleBox.Size = UDim2.new(0, 16, 0, 16)
			Roundify(ToggleBox)

			BoxFiller.Name = 'BoxFiller'
			BoxFiller.Parent = ToggleBox
			BoxFiller.AnchorPoint = Vector2.new(0.5, 0.5)
			BoxFiller.BackgroundColor3 = Color3.fromRGB(27, 27, 36)
			BoxFiller.BorderSizePixel = 0
			BoxFiller.Position = UDim2.new(0.5, 0, 0.5, 0)
			BoxFiller.Size = UDim2.new(0, 10, 0, 10)
			Roundify(BoxFiller)

			FillerGradient.Name = 'ToggleGradient'
			FillerGradient.Parent = BoxFiller
			FillerGradient.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			FillerGradient.BackgroundTransparency = 1.000
			FillerGradient.BorderSizePixel = 0
			FillerGradient.Size = UDim2.new(1, 0, 1, 0)
			FillerGradient.ZIndex = 0
			Roundify(FillerGradient)
			Gradient(FillerGradient)

			ToggleGradient.Name = 'ToggleGradient'
			ToggleGradient.Parent = ToggleHolder
			ToggleGradient.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
			ToggleGradient.BackgroundTransparency = 1.000
			ToggleGradient.BorderSizePixel = 0
			ToggleGradient.Size = UDim2.new(1, 0, 1, 0)
			ToggleGradient.ZIndex = 0
			Roundify(ToggleGradient)
			Gradient(ToggleGradient)
			Border(ToggleGradient).Transparency = 1
			ToggleGradient.UIStroke.Color = Color3.new(1, 1, 1)
			Gradient(ToggleGradient.UIStroke)
			Glow(ToggleGradient).ImageTransparency = 1

			Toggle.MouseEnter:Connect(function()
				if Library.warning or (Library.popup and Library.popup.hovering) then return end
				QTween(ToggleGradient, 0.3, {BackgroundColor3 = Color3.new(1, 1, 1)})
				QTween(ToggleHolder, 0.3, {BackgroundColor3 = Color3.fromRGB(44, 44, 60)})
				QTween(BoxFiller, 0.3, {BackgroundColor3 = Color3.fromRGB(44, 44, 60)})
			end)

			Toggle.MouseLeave:Connect(function()
				QTween(ToggleGradient, 0.3, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)})
				QTween(ToggleHolder, 0.3, {BackgroundColor3 = Color3.fromRGB(27, 27, 36)})
				QTween(BoxFiller, 0.3, {BackgroundColor3 = Color3.fromRGB(27, 27, 36)})
				if not Options.state then
					QTween(ToggleBox, 0.3, {BackgroundColor3 = Color3.fromRGB(34, 34, 45)})
				end
			end)

			Toggle.MouseButton1Down:Connect(function()
				if Library.warning or (Library.popup and Library.popup.hovering) then return end
				QTween(ToggleGradient, 0.3, {BackgroundColor3 = Color3.fromRGB(150, 150, 150)})
				QTween(ToggleHolder, 0.3, {BackgroundColor3 = Color3.fromRGB(34, 34, 47)})
				QTween(BoxFiller, 0.3, {BackgroundColor3 = Color3.fromRGB(34, 34, 47)})
				if not Options.state then
					QTween(ToggleBox, 0.3, {BackgroundColor3 = Color3.fromRGB(32, 32, 43)})
				end
			end)

			Toggle.MouseButton1Up:Connect(function()
				QTween(ToggleGradient, 0.3, {BackgroundColor3 = Color3.new(1, 1, 1)})
				QTween(ToggleHolder, 0.3, {BackgroundColor3 = Color3.fromRGB(44, 44, 60)})
				QTween(BoxFiller, 0.3, {BackgroundColor3 = Color3.fromRGB(44, 44, 60)})
				if not Options.state then
					QTween(ToggleBox, 0.3, {BackgroundColor3 = Color3.fromRGB(34, 34, 45)})
				end
			end)

			Toggle.MouseButton1Click:Connect(function()
				if Library.warning or (Library.popup and Library.popup.hovering) then return end
				Options:SetState(not Options.state)
			end)

			function Options:SetState(state)
				state = typeof(state) == 'boolean' and state or false
				Library.flags[Options.flag] = state
				Options.state = state
				if Options.state then
					QTween(ToggleGradient, 0.5, {BackgroundTransparency = 0})
					QTween(ToggleBox, 0.5, {Position = UDim2.new(0, 27, 0, 2), BackgroundColor3 = Color3.new(1, 1, 1)})
					QTween(BoxFiller, 0.5, {Size = UDim2.new(0, 0, 0, 0)})
					QTween(ToggleGradient.UIStroke, 0.5, {Transparency = 0})
					QTween(ToggleGradient.Glow, 0.5, {ImageTransparency = 0})
					QTween(FillerGradient, 0.5, {BackgroundTransparency = 0})
				else
					QTween(ToggleGradient, 0.5, {BackgroundTransparency = 1})
					QTween(ToggleBox, 0.5, {Position = UDim2.new(0, 2, 0, 2), BackgroundColor3 = Color3.fromRGB(34, 34, 45)})
					QTween(BoxFiller, 0.5, {Size = UDim2.new(0, 10, 0, 10)})
					QTween(ToggleGradient.UIStroke, 0.5, {Transparency = 1})
					QTween(ToggleGradient.Glow, 0.5, {ImageTransparency = 1})
					QTween(FillerGradient, 0.5, {BackgroundTransparency = 1})
				end
				Options.callback(state)
			end

			Options:SetState(Options.state)

			Library.options[Options.flag] = Options
			return Options
		end

		function Options:AddBind(Options)
			Options = CheckTable(Options, {
				text = 'New Bind',
				key = 'None',
				nomouse = false,
				hold = false,
				callback = function() end,
				skipflag = false
			})
			Options.flag = typeof(Options.flag) == 'string' and Options.flag or Options.text
			if tablefind(Library.options, Options.flag) then
				repeat
					Options.flag = Options.flag .. '_'
				until not tablefind(Library.options, Options.flag)
			end
			Options.type = 'bind'
			Options.default = Options.key

			local Bind = Instance.new('TextButton')
			local BindText = Instance.new('TextLabel')
			local BindHolder = Instance.new('Frame')
			local KeyText = Instance.new('TextLabel')
			local BindGradient = Instance.new('Frame')

			Bind.Name = 'Bind'
			Bind.Parent = SectionHolder
			Bind.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Bind.BackgroundTransparency = 1.000
			Bind.Size = UDim2.new(1, 0, 0, 20)
			Bind.Font = Enum.Font.SourceSans
			Bind.Text = ''
			Bind.TextColor3 = Color3.fromRGB(0, 0, 0)
			Bind.TextSize = 14.000

			BindText.Name = 'BindText'
			BindText.Parent = Bind
			BindText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			BindText.BackgroundTransparency = 1.000
			BindText.Size = UDim2.new(1, 0, 1, 0)
			BindText.Font = Enum.Font.Nunito
			BindText.Text = Options.text
			BindText.TextColor3 = Color3.fromRGB(144, 144, 165)
			BindText.TextSize = 16.000
			BindText.TextXAlignment = Enum.TextXAlignment.Left

			BindHolder.Name = 'BindHolder'
			BindHolder.Parent = Bind
			BindHolder.AnchorPoint = Vector2.new(1, 0)
			BindHolder.BackgroundColor3 = Color3.fromRGB(27, 27, 36)
			BindHolder.BorderColor3 = Color3.fromRGB(44, 44, 60)
			BindHolder.Position = UDim2.new(1, 0, 0, 0)
			BindHolder.Size = UDim2.new(0, 76, 1, 0)
			Roundify(BindHolder)
			Border(BindHolder)

			KeyText.Name = 'KeyText'
			KeyText.Parent = BindHolder
			KeyText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			KeyText.BackgroundTransparency = 1.000
			KeyText.Size = UDim2.new(1, 0, 1, 0)
			KeyText.Font = Enum.Font.Code
			KeyText.Text = 'TEMP'
			KeyText.TextColor3 = Color3.fromRGB(144, 144, 165)
			KeyText.TextSize = 16.000
			KeyText.ClipsDescendants = true

			BindGradient.Name = 'BindGradient'
			BindGradient.Parent = BindHolder
			BindGradient.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			BindGradient.BackgroundTransparency = 1.000
			BindGradient.Size = UDim2.new(1, 0, 1, 0)
			BindGradient.ZIndex = 0
			Roundify(BindGradient)
			Border(BindGradient).Color = Color3.new(1, 1, 1)
			BindGradient.UIStroke.Transparency = 1
			Gradient(BindGradient.UIStroke)
			Glow(BindGradient)
			Gradient(BindGradient)

			KeyText:GetPropertyChangedSignal('Text'):Connect(function()
				QTween(BindHolder, 0.5, {Size = UDim2.new(0, GetTextSize(KeyText.Text, KeyText.TextSize, KeyText.Font).X + 10, 1, 0)})
			end)

			local Binding
			local Loop
			local Pressed

			Bind.MouseEnter:Connect(function()
				if Library.warning or (Library.popup and Library.popup.hovering) then return end
				QTween(BindHolder, 0.3, {BackgroundColor3 = Color3.fromRGB(44, 44, 60)})
			end)

			Bind.MouseLeave:Connect(function()
				QTween(BindHolder, 0.3, {BackgroundColor3 = Color3.fromRGB(27, 27, 36)})
			end)

			Bind.MouseButton1Down:Connect(function()
				if Library.warning or (Library.popup and Library.popup.hovering) then return end
				QTween(BindHolder, 0.3, {BackgroundColor3 = Color3.fromRGB(34, 34, 47)})
			end)

			Bind.MouseButton1Up:Connect(function()
				QTween(BindHolder, 0.3, {BackgroundColor3 = Color3.fromRGB(44, 44, 60)})
			end)

			Bind.MouseButton1Click:Connect(function()
				if Library.warning or (Library.popup and Library.popup.hovering) then return end
				Binding = true
				KeyText.Text = '[...]'
				QTween(BindGradient, 0.5, {BackgroundTransparency = 0})
				QTween(BindGradient.UIStroke, 0.5, {Transparency = 0})
				QTween(BindGradient.Glow, 0.5, {ImageTransparency = 0})
				QTween(KeyText, 0.5, {TextColor3 = Color3.new(1, 1, 1)})
			end)

			Library:AddConnection(InputService.InputBegan, function(input)
				if InputService:GetFocusedTextBox() then return end
				if Binding then
					local key = (table.find(WhitelistedMouseInputs, input.UserInputType) and not Options.nomouse) and input.UserInputType
					Options:SetKey(key or (not table.find(BlacklistedKeys, input.KeyCode)) and input.KeyCode)
				else
					if (input.KeyCode.Name == Options.key or input.UserInputType.Name == Options.key) then
						if Options.hold then
							Library.flags[Options.flag] = true
							if Loop then Loop:Disconnect(); Options.callback(true, 0) end
							Loop = RunService.RenderStepped:Connect(function(step)
								if not InputService:GetFocusedTextBox() then
									Options.callback(nil, step)
								end
							end)
						else
							if typeof(Library.flags[Options.flag]) == 'boolean' then
								Library.flags[Options.flag] = not Library.flags[Options.flag]
							else
								Library.flags[Options.flag] = true
							end
							Options.callback(Library.flags[Options.flag], 0)
						end
					end
				end
			end)

			Library:AddConnection(InputService.InputEnded, function(input)
				if Options.key ~= 'None' then
					if input.KeyCode.Name == Options.key or input.UserInputType.Name == Options.key then
						if Loop then
							Loop:Disconnect()
							Library.flags[Options.flag] = false
							Options.callback(true, 0)
						end
					end
				end
			end)

			function Options:SetKey(key)
				Binding = false
				if Loop then Loop:Disconnect(); Library.flags[Options.flag] = false; Options.callback(true, 0) end
				Options.key = (key and key.Name) or key or Options.key
				if Options.key == 'Backspace' then
					Options.key = 'None'
					KeyText.Text = 'None'
				else
					local a = Options.key
					if Options.key:match('Mouse') then
						a = Options.key:gsub('Button', '')
					end
					KeyText.Text = a
				end
				QTween(BindGradient, 0.5, {BackgroundTransparency = 1})
				QTween(BindGradient.UIStroke, 0.5, {Transparency = 1})
				QTween(BindGradient.Glow, 0.5, {ImageTransparency = 1})
				QTween(KeyText, 0.5, {TextColor3 = Color3.fromRGB(144, 144, 165)})
			end

			Options:SetKey()
			Library.options[Options.flag] = Options
			return Options
		end

		function Options:AddSlider(Options)
			Options = CheckTable(Options, {
				text = 'New Slider',
				min = 0,
				max = 100,
				float = 1,
				value = 50,
				suffix = '',
				callback = function() end,
				skipflag = false
			})
			Options.flag = typeof(Options.flag) == 'string' and Options.flag or Options.text
			if tablefind(Library.options, Options.flag) then
				repeat
					Options.flag = Options.flag .. '_'
				until not tablefind(Library.options, Options.flag)
			end
			Options.type = 'slider'
			Options.default = Options.value
			if Options.min < 0 then Options.min = 0 end

			local Slider = Instance.new('TextButton')
			local SliderText = Instance.new('TextLabel')
			local ValueBox = Instance.new('TextBox')
			local ValueBoxGradient = Instance.new('Frame')
			local SliderHolder = Instance.new('Frame')
			local Bar = Instance.new('Frame')
			local BarColor = Instance.new('Frame')
			local BarGradient = Instance.new('Frame')
			local CircleHolder = Instance.new('Frame')
			local Circle = Instance.new('Frame')
			local CircleGradient = Instance.new('Frame')

			Slider.Name = 'Slider'
			Slider.Parent = SectionHolder
			Slider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Slider.BackgroundTransparency = 1.000
			Slider.Size = UDim2.new(1, 0, 0, 25)
			Slider.Font = Enum.Font.SourceSans
			Slider.Text = ''
			Slider.TextColor3 = Color3.fromRGB(0, 0, 0)
			Slider.TextSize = 14.000

			SliderText.Name = 'SliderText'
			SliderText.Parent = Slider
			SliderText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			SliderText.BackgroundTransparency = 1.000
			SliderText.Size = UDim2.new(1, 0, 0, 15)
			SliderText.Font = Enum.Font.Nunito
			SliderText.Text = Options.text
			SliderText.TextColor3 = Color3.fromRGB(144, 144, 165)
			SliderText.TextSize = 16.000
			SliderText.TextXAlignment = Enum.TextXAlignment.Left

			ValueBox.Name = 'ValueBox'
			ValueBox.Parent = Slider
			ValueBox.AnchorPoint = Vector2.new(1, 0)
			ValueBox.BackgroundColor3 = Color3.fromRGB(27, 27, 36)
			ValueBox.BorderColor3 = Color3.fromRGB(44, 44, 60)
			ValueBox.Position = UDim2.new(1, 0, 0, 0)
			ValueBox.Size = UDim2.new(0, 50, 0, 15)
			ValueBox.Font = Enum.Font.Code
			ValueBox.PlaceholderColor3 = Color3.fromRGB(70, 70, 80)
			ValueBox.PlaceholderText = '#'
			ValueBox.Text = ''
			ValueBox.TextColor3 = Color3.fromRGB(144, 144, 165)
			ValueBox.TextSize = 16.000
			Roundify(ValueBox)
			Border(ValueBox)

			ValueBoxGradient.Name = 'ValueBoxGradient'
			ValueBoxGradient.Parent = ValueBox
			ValueBoxGradient.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ValueBoxGradient.BackgroundTransparency = 1.000
			ValueBoxGradient.Size = UDim2.new(1, 0, 1, 0)
			Roundify(ValueBoxGradient)
			Border(ValueBoxGradient).Color = Color3.new(1, 1, 1)
			ValueBoxGradient.UIStroke.Transparency = 1
			Gradient(ValueBoxGradient.UIStroke)

			SliderHolder.Name = 'SliderHolder'
			SliderHolder.Parent = Slider
			SliderHolder.AnchorPoint = Vector2.new(0, 1)
			SliderHolder.BackgroundColor3 = Color3.fromRGB(27, 27, 36)
			SliderHolder.BorderColor3 = Color3.fromRGB(44, 44, 60)
			SliderHolder.Position = UDim2.new(0, 0, 1, 0)
			SliderHolder.Size = UDim2.new(1, 0, 0, 6)
			Roundify(SliderHolder)
			Border(SliderHolder)

			Bar.Name = 'Bar'
			Bar.Parent = SliderHolder
			Bar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Bar.BackgroundTransparency = 1.000
			Bar.ClipsDescendants = true
			Bar.Size = UDim2.new(0.400000006, 0, 1, 0)

			BarColor.Name = 'BarColor'
			BarColor.Parent = Bar
			BarColor.BackgroundColor3 = Color3.fromRGB(34, 34, 45)
			BarColor.Size = UDim2.new(0, 197, 0, 6)
			Roundify(BarColor)

			BarGradient.Name = 'BarGradient'
			BarGradient.Parent = BarColor
			BarGradient.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			BarGradient.BackgroundTransparency = 1.000
			BarGradient.Size = UDim2.new(1, 0, 1, 0)
			Roundify(BarGradient)
			Gradient(BarGradient)

			CircleHolder.Name = 'CircleHolder'
			CircleHolder.Parent = SliderHolder
			CircleHolder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			CircleHolder.BackgroundTransparency = 1.000
			CircleHolder.Position = UDim2.new(0.400000006, -1, 0.5, 0)

			Circle.Name = 'Circle'
			Circle.Parent = CircleHolder
			Circle.AnchorPoint = Vector2.new(0.5, 0.5)
			Circle.BackgroundColor3 = Color3.fromRGB(34, 34, 45)
			Circle.BorderSizePixel = 0
			Roundify(Circle).CornerRadius = UDim.new(1, 0)

			CircleGradient.Name = 'CircleGradient'
			CircleGradient.Parent = Circle
			CircleGradient.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			CircleGradient.BackgroundTransparency = 1.000
			CircleGradient.BorderSizePixel = 0
			CircleGradient.Size = UDim2.new(1, 0, 1, 0)
			Roundify(CircleGradient).CornerRadius = UDim.new(1, 0)
			Gradient(CircleGradient)

			ValueBox:GetPropertyChangedSignal('Text'):Connect(function()
				STween(ValueBox, 0.1, {Size = UDim2.new(0, GetTextSize(ValueBox.Text, ValueBox.TextSize, ValueBox.Font).X + 10, 0, 15)})
			end)

			local Sliding
			local InContact

			Slider.MouseEnter:Connect(function()
				InContact = true
				if Library.warning or (Library.popup and Library.popup.hovering) then return end
				if Sliding then return end
				QTween(BarColor, 0.3, {BackgroundColor3 = Color3.fromRGB(44, 44, 60)})
				QTween(Circle, 0.3, {BackgroundColor3 = Color3.fromRGB(44, 44, 60), Size = UDim2.new(0, 10, 0, 10)})
			end)

			Slider.MouseLeave:Connect(function()
				InContact = false
				if Sliding then return end
				QTween(BarColor, 0.3, {BackgroundColor3 = Color3.fromRGB(34, 34, 45)})
				QTween(Circle, 0.3, {BackgroundColor3 = Color3.fromRGB(34, 34, 45), Size = UDim2.new(0, 0, 0, 0)})
			end)

			Slider.InputBegan:Connect(function(input)
				if Library.warning or (Library.popup and Library.popup.hovering) then return end
				if input.UserInputType == InputTypes.MouseButton1 then
					QTween(BarGradient, 0.3, {BackgroundTransparency = 0})
					QTween(Circle, 0.5, {Size = UDim2.new(0, 12, 0, 12)})
					QTween(CircleGradient, 0.5, {BackgroundTransparency = 0})
					Sliding = true
					Options:SetValue(Options.min + ((input.Position.X - SliderHolder.AbsolutePosition.X) / SliderHolder.AbsoluteSize.X) * (Options.max - Options.min))
				end
			end)

			Library:AddConnection(InputService.InputChanged, function(input)
				if input.UserInputType == InputTypes.MouseMovement and Sliding then
					Options:SetValue(Options.min + ((input.Position.X - SliderHolder.AbsolutePosition.X) / SliderHolder.AbsoluteSize.X) * (Options.max - Options.min))
				end
			end)

			Slider.InputEnded:Connect(function(input)
				if input.UserInputType == InputTypes.MouseButton1 then
					Sliding = false
					QTween(CircleGradient, 0.5, {BackgroundTransparency = 1})
					QTween(BarGradient, 0.3, {BackgroundTransparency = 1})
					if InContact then
						QTween(BarColor, 0.3, {BackgroundColor3 = Color3.fromRGB(44, 44, 60)})
						QTween(Circle, 0.3, {BackgroundColor3 = Color3.fromRGB(44, 44, 60), Size = UDim2.new(0, 10, 0, 10)})
					else
						QTween(BarColor, 0.3, {BackgroundColor3 = Color3.fromRGB(34, 34, 45)})
						QTween(Circle, 0.3, {BackgroundColor3 = Color3.fromRGB(34, 34, 45), Size = UDim2.new(0, 0, 0, 0)})
					end
				end
			end)

			local Hover
			local Typing

			ValueBox.MouseEnter:Connect(function()
				Hover = true
				if Library.warning or (Library.popup and Library.popup.hovering) then return end
				if Typing then return end
				QTween(ValueBox, 0.3, {BackgroundColor3 = Color3.fromRGB(44, 44, 60)})
			end)

			ValueBox.MouseLeave:Connect(function()
				Hover = false
				if Typing then return end
				QTween(ValueBox, 0.3, {BackgroundColor3 = Color3.fromRGB(27, 27, 36)})
			end)

			ValueBox.Focused:Connect(function()
				Typing = true
				QTween(ValueBoxGradient.UIStroke, 0.5, {Transparency = 0})
			end)

			ValueBox.FocusLost:Connect(function()
				Typing = false
				QTween(ValueBoxGradient.UIStroke, 0.5, {Transparency = 1})
				if Hover then
					QTween(ValueBox, 0.3, {BackgroundColor3 = Color3.fromRGB(44, 44, 60)})
				else
					QTween(ValueBox, 0.3, {BackgroundColor3 = Color3.fromRGB(27, 27, 36)})
				end
				Options:SetValue(tonumber(ValueBox.Text) or Options.value)
			end)

			function Options:SetValue(value)
				if not value then return end
				value = Round(value, Options.float)
				value = math.clamp(value, Options.min, Options.max)
				value = SetDecimal(value, GetDecimal(Options.float))
				value = tonumber(value)
				STween(Bar, 0.1, {Size = UDim2.new((value - Options.min) / (Options.max - Options.min), 0, 1, 0)})
				STween(CircleHolder, 0.1, {Position = UDim2.new((value - Options.min) / (Options.max - Options.min), -1, 0.5, 0)})
				Library.flags[Options.flag] = value
				Options.value = value
				ValueBox.Text = tostring(value) .. Options.suffix
				Options.callback(value)
			end

			Options:SetValue(Options.value)
			Library.options[Options.flag] = Options
			return Options
		end

		function Options:AddList(Options)
			Options = CheckTable(Options, {
				text = 'New List',
				values = {'No Values'},
				multiselect = false,
				max = 20,
				callback = function() end,
				skipflag = false
			})
			Options.flag = typeof(Options.flag) == 'string' and Options.flag or Options.text
			if tablefind(Library.options, Options.flag) then
				repeat
					Options.flag = Options.flag .. '_'
				until not tablefind(Library.options, Options.flag)
			end
			Options.type = 'list'
			Options.open = false
			Options.value = Options.multiselect and (typeof(Options.value) == 'table' and Options.value or {}) or tostring(Options.value or Options.values[1] or '')
			Options.labels = {}
			Options.hovering = false
			Options.default = Options.value
			if Options.multiselect then
				for _, v in next, Options.values do
					Options.value[v] = false
				end
			end

			local function getMultiText()
				local s = ''
				for _, value in next, Options.values do
					s = s .. (Options.value[value] and (tostring(value) .. ', ') or '')
				end
				return string.sub(s, 1, #s - 2)
			end

			local List = Instance.new('TextButton')
			local ListText = Instance.new('TextLabel')
			local ChoicesText = Instance.new('TextLabel')
			local OpenButton = Instance.new('Frame')
			local OpenIcon = Instance.new('ImageLabel')
			local OpenButtonGradient = Instance.new('Frame')

			List.Name = 'List'
			List.Parent = SectionHolder
			List.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			List.BackgroundTransparency = 1.000
			List.Size = UDim2.new(1, 0, 0, 25)
			List.Font = Enum.Font.SourceSans
			List.Text = ''
			List.TextColor3 = Color3.fromRGB(0, 0, 0)
			List.TextSize = 14.000

			ListText.Name = 'ListText'
			ListText.Parent = List
			ListText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ListText.BackgroundTransparency = 1.000
			ListText.Size = UDim2.new(1, 0, 1, 0)
			ListText.Font = Enum.Font.Nunito
			ListText.Text = Options.text
			ListText.TextColor3 = Color3.fromRGB(144, 144, 165)
			ListText.TextSize = 16.000
			ListText.TextXAlignment = Enum.TextXAlignment.Left
			ListText.TextYAlignment = Enum.TextYAlignment.Top

			ChoicesText.Name = 'ChoicesText'
			ChoicesText.Parent = List
			ChoicesText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ChoicesText.BackgroundTransparency = 1.000
			ChoicesText.Position = UDim2.new(0, 0, 0, 15)
			ChoicesText.Size = UDim2.new(1, -30, 0, 10)
			ChoicesText.Font = Enum.Font.Nunito
			ChoicesText.Text = 'TEMP'
			ChoicesText.TextColor3 = Color3.fromRGB(144, 144, 165)
			ChoicesText.TextSize = 12.000
			ChoicesText.TextXAlignment = Enum.TextXAlignment.Left

			OpenButton.Name = 'OpenButton'
			OpenButton.Parent = List
			OpenButton.AnchorPoint = Vector2.new(1, 0)
			OpenButton.BackgroundColor3 = Color3.fromRGB(27, 27, 36)
			OpenButton.BorderColor3 = Color3.fromRGB(44, 44, 60)
			OpenButton.Position = UDim2.new(1, 0, 0, 0)
			OpenButton.Size = UDim2.new(0, 25, 0, 25)
			Roundify(OpenButton)
			Border(OpenButton)

			OpenIcon.Name = 'OpenIcon'
			OpenIcon.Parent = OpenButton
			OpenIcon.AnchorPoint = Vector2.new(0.5, 0.5)
			OpenIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			OpenIcon.BackgroundTransparency = 1.000
			OpenIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
			OpenIcon.Size = UDim2.new(1, -4, 1, -4)
			OpenIcon.Image = 'rbxassetid://11421095840'
			OpenIcon.ImageColor3 = Color3.fromRGB(144, 144, 165)

			OpenButtonGradient.Name = 'OpenButtonGradient'
			OpenButtonGradient.Parent = OpenButton
			OpenButtonGradient.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
			OpenButtonGradient.BackgroundTransparency = 1.000
			OpenButtonGradient.Size = UDim2.new(1, 0, 1, 0)
			OpenButtonGradient.ZIndex = 0
			Roundify(OpenButtonGradient)
			Border(OpenButtonGradient).Color = Color3.new(1, 1, 1)
			OpenButtonGradient.UIStroke.Transparency = 1
			Gradient(OpenButtonGradient)
			Gradient(OpenButtonGradient.UIStroke)
			Glow(OpenButtonGradient).ImageTransparency = 1

			local ItemsInvis = Instance.new('Frame')
			local ItemsHolder = Instance.new('Frame')
			local ItemsList = Instance.new('ScrollingFrame')
			local ItemsListLayout = Instance.new('UIGridLayout')
			local ItemsListPadding = Instance.new('UIPadding')

			ItemsInvis.Name = 'ItemsInvis'
			ItemsInvis.Parent = Mainframe
			ItemsInvis.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ItemsInvis.BackgroundTransparency = 1.000
			ItemsInvis.Position = UDim2.new(0, 265, 0, 80)
			ItemsInvis.Size = UDim2.new(0, List.AbsoluteSize.X + 10, 0, 0)
			ItemsInvis.ZIndex = 2
			ItemsInvis.Visible = false

			ItemsHolder.Name = 'ItemsHolder'
			ItemsHolder.Parent = ItemsInvis
			ItemsHolder.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
			ItemsHolder.BorderColor3 = Color3.fromRGB(44, 44, 60)
			ItemsHolder.Size = UDim2.new(1, 0, 0, 0)
			Roundify(ItemsHolder)
			Border(ItemsHolder).Transparency = 1

			ItemsList.Name = 'ItemsList'
			ItemsList.Parent = ItemsHolder
			ItemsList.Active = true
			ItemsList.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ItemsList.BackgroundTransparency = 1.000
			ItemsList.BorderSizePixel = 0
			ItemsList.Size = UDim2.new(1, 0, 1, 0)
			ItemsList.BottomImage = ''
			ItemsList.CanvasSize = UDim2.new(0, 0, 0, 0)
			ItemsList.ScrollBarThickness = 2
			ItemsList.TopImage = ''

			ItemsListLayout.Name = 'ItemsListLayout'
			ItemsListLayout.Parent = ItemsList
			ItemsListLayout.FillDirection = Enum.FillDirection.Vertical
			ItemsListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			ItemsListLayout.CellPadding = UDim2.new(0, 0, 0, 0)
			ItemsListLayout.CellSize = UDim2.new(1, 0, 0, 18)

			ItemsListPadding.Name = 'ItemsListPadding'
			ItemsListPadding.Parent = ItemsList
			ItemsListPadding.PaddingTop = UDim.new(0, 5)
			ItemsListPadding.PaddingBottom = UDim.new(0, 5)

			ChoicesText:GetPropertyChangedSignal('Text'):Connect(function()
				if GetTextSize(ChoicesText.Text, ChoicesText.TextSize, ChoicesText.Font).X > ChoicesText.AbsoluteSize.X then
					local NewText = ChoicesText.Text .. '...'
					repeat
						NewText = NewText:sub(1, #NewText - 4) .. '...'
					until GetTextSize(NewText, ChoicesText.TextSize, ChoicesText.Font).X <= ChoicesText.AbsoluteSize.X
					ChoicesText.Text = NewText
				end
			end)

			ItemsHolder.InputBegan:Connect(function(input)
				if input.UserInputType == InputTypes.MouseMovement then
					Options.hovering = true
				end
			end)

			ItemsHolder.InputEnded:Connect(function(input)
				if input.UserInputType == InputTypes.MouseMovement then
					Options.hovering = false
				end
			end)

			local function UpdateListPos()
				ItemsInvis.Position = UDim2.new(0, Round(List.AbsolutePosition.X - Mainframe.AbsolutePosition.X) - 5, 0, Round(List.AbsolutePosition.Y - Mainframe.AbsolutePosition.Y) + List.AbsoluteSize.Y + 5)
			end

			Library:AddConnection(List:GetPropertyChangedSignal('AbsolutePosition'), UpdateListPos)
			UpdateListPos()

			Library:AddConnection(ItemsHolder:GetPropertyChangedSignal('AbsoluteSize'), function()
				if ItemsHolder.AbsoluteSize.Y > 0 then
					ItemsInvis.Visible = true
				else
					ItemsInvis.Visible = false
				end
			end)

			local valuecount = 0
			local function UpdateList()
				local Size = 10
				for _, v in pairs(ItemsList:GetChildren()) do
					if v:IsA('TextButton') then
						Size = Size + ItemsListLayout.CellSize.Y.Offset
					end
				end
				local HolderSize = valuecount > Options.max and (Options.max * ItemsListLayout.CellSize.Y.Offset) + 10 or Size
				ItemsInvis.Size = UDim2.new(0, List.AbsoluteSize.X + 10, 0, HolderSize)
				ItemsList.CanvasSize = UDim2.new(0, 0, 0, Size)
			end

			ItemsListLayout:GetPropertyChangedSignal('AbsoluteCellCount'):Connect(UpdateList)

			List.MouseEnter:Connect(function()
				if Library.warning or (Library.popup and Library.popup.hovering) then return end
				QTween(OpenButton, 0.3, {BackgroundColor3 = Color3.fromRGB(44, 44, 60)})
				QTween(OpenIcon, 0.3, {ImageColor3 = Color3.new(1, 1, 1)})
				QTween(OpenButtonGradient, 0.3, {BackgroundColor3 = Color3.new(1, 1, 1)})
			end)

			List.MouseLeave:Connect(function()
				QTween(OpenButton, 0.3, {BackgroundColor3 = Color3.fromRGB(27, 27, 36)})
				QTween(OpenButtonGradient, 0.3, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)})
				if Options.open then return end
				QTween(OpenIcon, 0.3, {ImageColor3 = Color3.fromRGB(144, 144, 165)})
			end)

			List.MouseButton1Down:Connect(function()
				if Library.warning or (Library.popup and Library.popup.hovering) then return end
				QTween(OpenButton, 0.3, {BackgroundColor3 = Color3.fromRGB(34, 34, 45)})
				QTween(OpenButtonGradient, 0.3, {BackgroundColor3 = Color3.fromRGB(150, 150, 150)})
			end)

			List.MouseButton1Up:Connect(function()
				QTween(OpenButton, 0.3, {BackgroundColor3 = Color3.fromRGB(44, 44, 60)})
				QTween(OpenButtonGradient, 0.3, {BackgroundColor3 = Color3.new(1, 1, 1)})
			end)

			List.MouseButton1Click:Connect(function()
				if Library.warning then return end
				if Library.popup and Library.popup ~= Options and Library.popup.hovering then return end
				if Library.popup == Options then Library.popup:Close(); return end
				if Library.popup and Library.popup.hovering == false then Library.popup:Close() end
				QTween(OpenIcon, 0.5, {Rotation = 180})
				QTween(OpenButtonGradient, 0.5, {BackgroundTransparency = 0})
				QTween(OpenButtonGradient.Glow, 0.5, {ImageTransparency = 0})
				QTween(OpenButtonGradient.UIStroke, 0.5, {Transparency = 0})
				QTween(ItemsList, 0.5, {ScrollBarImageTransparency = 0})
				QTween(ItemsHolder, 0.5, {Size = UDim2.new(1, 0, 1, 0)})
				QTween(ItemsHolder.UIStroke, 0.5, {Transparency = 0})
				Options.open = true
				Library.popup = Options
			end)

			local selected
			function Options:AddValue(value, state)
				if Options.labels[value] then return end
				state = typeof(state) == 'boolean' and state or false
				valuecount = valuecount + 1

				if not table.find(Options.values, value) then
					table.insert(Options.values, value)
				end
				if Options.multiselect then
					Options.value[value] = state
				end

				local Item = Instance.new('TextButton')
				local ItemText = Instance.new('TextLabel')

				Item.Name = 'Item'
				Item.Parent = ItemsList
				Item.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Item.BackgroundTransparency = 1.000
				Item.BorderColor3 = Color3.fromRGB(27, 42, 53)
				Item.Size = UDim2.new(0, 200, 0, 50)
				Item.Font = Enum.Font.SourceSans
				Item.Text = ''
				Item.TextColor3 = Color3.fromRGB(0, 0, 0)
				Item.TextSize = 14.000

				ItemText.Name = 'ItemText'
				ItemText.Parent = Item
				ItemText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				ItemText.BackgroundTransparency = 1.000
				ItemText.Position = UDim2.new(0, 5, 0, 0)
				ItemText.Size = UDim2.new(1, -15, 1, 0)
				ItemText.Font = Enum.Font.Nunito
				ItemText.Text = value
				ItemText.TextColor3 = Color3.fromRGB(144, 144, 165)
				ItemText.TextSize = 16.000
				ItemText.TextXAlignment = Enum.TextXAlignment.Left

				local ItemTextGradient = ItemText:Clone()
				ItemTextGradient.Name = 'ItemTextGradient'
				ItemTextGradient.Parent = ItemText
				ItemTextGradient.Size = UDim2.new(0, GetTextSize(ItemText.Text, ItemText.TextSize, ItemText.Font).X, 1, 0)
				ItemTextGradient.Position = UDim2.new(0, 0, 0, 0)
				ItemTextGradient.TextColor3 = Color3.new(1, 1, 1)
				ItemTextGradient.TextTransparency = 1
				Gradient(ItemTextGradient)

				Options.labels[value] = Item

				selected = selected or Options.value == value and Item

				Item.MouseEnter:Connect(function()
					QTween(ItemText, 0.3, {TextColor3 = Color3.new(1, 1, 1)})
				end)

				Item.MouseLeave:Connect(function()
					QTween(ItemText, 0.3, {TextColor3 = Color3.fromRGB(144, 144, 165)})
				end)

				Item.MouseButton1Down:Connect(function()
					QTween(ItemText, 0.3, {TextColor3 = Color3.fromRGB(200, 200, 200)})
				end)

				Item.MouseButton1Up:Connect(function()
					QTween(ItemText, 0.3, {TextColor3 = Color3.new(1, 1, 1)})
				end)

				Item.MouseButton1Click:Connect(function()
					if Options.multiselect then
						Options.value[value] = not Options.value[value]
						Options:SetValue(Options.value)
					else
						Options:SetValue(value)
						Options:Close()
					end
				end)
			end

			for i, v in pairs(Options.values) do
				Options:AddValue(tostring(typeof(i) == 'number' and v or i))
			end

			function Options:RemoveValue(value)
				local label = Options.labels[value]
				if label then
					label:Destroy()
					Options.labels[value] = nil
					valuecount = valuecount - 1
					if Options.multiselect then
						Options.values[value] = nil
						Options.value[value] = nil
						Options:SetValue(Options.value)
					else
						if Options.value == value then
							selected = nil
							Options:SetValue(Options.values[1] or '')
						end
						Options.values[value] = nil
					end
				end
			end

			function Options:SetValue(value)
				if Options.multiselect and typeof(value) ~= 'table' then
					value = {}
					for _, v in pairs(Options.values) do
						value[v] = false
					end
				end
				Options.value = typeof(value) == 'table' and value or tostring(table.find(Options.values, value) and value or Options.values[1])
				Library.flags[Options.flag] = Options.value
				ChoicesText.Text = Options.multiselect and getMultiText() or Options.value
				if Options.multiselect then
					for name, label in pairs(Options.labels) do
						if Options.value[name] then
							QTween(label.ItemText.ItemTextGradient, 0.3, {TextTransparency = 0})
							QTween(label.ItemText, 0.3, {TextTransparency = 1})
							QTween(label.ItemText, 0.3, {Position = UDim2.new(0, 10, 0, 0)})
						else
							QTween(label.ItemText.ItemTextGradient, 0.3, {TextTransparency = 1})
							QTween(label.ItemText, 0.3, {TextTransparency = 0})
							QTween(label.ItemText, 0.3, {Position = UDim2.new(0, 5, 0, 0)})
						end
					end
				else
					if selected then
						QTween(selected.ItemText.ItemTextGradient, 0.3, {TextTransparency = 1})
						QTween(selected.ItemText, 0.3, {TextTransparency = 0})
						QTween(selected.ItemText, 0.3, {Position = UDim2.new(0, 5, 0, 0)})
					end
					if Options.labels[Options.value] then
						selected = Options.labels[Options.value]
						QTween(selected.ItemText.ItemTextGradient, 0.3, {TextTransparency = 0})
						QTween(selected.ItemText, 0.3, {TextTransparency = 1})
						QTween(selected.ItemText, 0.3, {Position = UDim2.new(0, 10, 0, 0)})
					end
				end
				Options.callback(Options.value)
			end

			Options:SetValue(Options.value)

			function Options:Close()
				Library.popup = nil
				QTween(OpenIcon, 0.5, {Rotation = 0})
				QTween(OpenButtonGradient, 0.5, {BackgroundTransparency = 1})
				QTween(OpenButtonGradient.Glow, 0.5, {ImageTransparency = 1})
				QTween(OpenButtonGradient.UIStroke, 0.5, {Transparency = 1})
				QTween(ItemsList, 0.5, {ScrollBarImageTransparency = 1})
				QTween(ItemsHolder, 0.5, {Size = UDim2.new(1, 0, 0, 0)})
				QTween(ItemsHolder.UIStroke, 0.5, {Transparency = 1})
				Options.open = false
			end

			Library.options[Options.flag] = Options
			return Options
		end

		function Options:AddBox(Options)
			Options = CheckTable(Options, {
				text = 'New Box',
				value = '',
				clearonfocus = false,
				callbackonchanged = false,
				callback = function() end,
				skipflag = false
			})
			Options.flag = typeof(Options.flag) == 'string' and Options.flag or Options.text
			if tablefind(Library.options, Options.flag) then
				repeat
					Options.flag = Options.flag .. '_'
				until not tablefind(Library.options, Options.flag)
			end
			Options.type = 'box'
			Options.default = Options.value

			local Box = Instance.new('TextBox')
			local Constraint = Instance.new('UITextSizeConstraint')
			local BoxGradient = Instance.new('Frame')

			Box.Name = 'Box'
			Box.Parent = SectionHolder
			Box.BackgroundColor3 = Color3.fromRGB(27, 27, 36)
			Box.BorderColor3 = Color3.fromRGB(44, 44, 60)
			Box.Size = UDim2.new(1, 0, 0, 20)
			Box.ClearTextOnFocus = Options.clearonfocus
			Box.Font = Enum.Font.Nunito
			Box.PlaceholderColor3 = Color3.fromRGB(70, 70, 80)
			Box.PlaceholderText = Options.text
			Box.Text = 'Value'
			Box.TextColor3 = Color3.fromRGB(144, 144, 165)
			Box.TextScaled = true
			Box.TextSize = 16.000
			Box.TextWrapped = true
			Roundify(Box)
			Border(Box)

			Constraint.Name = 'Constraint'
			Constraint.Parent = Box
			Constraint.MaxTextSize = 16

			BoxGradient.Name = 'BoxGradient'
			BoxGradient.Parent = Box
			BoxGradient.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			BoxGradient.BackgroundTransparency = 1.000
			BoxGradient.Size = UDim2.new(1, 0, 1, 0)
			Roundify(BoxGradient)
			Glow(BoxGradient).ImageTransparency = 1
			Border(BoxGradient).Transparency = 1
			BoxGradient.UIStroke.Color = Color3.new(1, 1, 1)
			Gradient(BoxGradient.UIStroke)

			local Hover
			local Typing

			Box.MouseEnter:Connect(function()
				Hover = true
				if Library.warning or (Library.popup and Library.popup.hovering) then return end
				if Typing then return end
				QTween(Box, 0.3, {BackgroundColor3 = Color3.fromRGB(44, 44, 60)})
			end)

			Box.MouseLeave:Connect(function()
				Hover = false
				if Typing then return end
				QTween(Box, 0.3, {BackgroundColor3 = Color3.fromRGB(27, 27, 36)})
			end)

			Box.Focused:Connect(function()
				Typing = true
				QTween(BoxGradient.UIStroke, 0.3, {Transparency = 0})
				QTween(BoxGradient.Glow, 0.3, {ImageTransparency = 0})
			end)

			Box.FocusLost:Connect(function()
				Typing = false
				QTween(BoxGradient.UIStroke, 0.3, {Transparency = 1})
				QTween(BoxGradient.Glow, 0.3, {ImageTransparency = 1})
				if Hover then
					QTween(Box, 0.3, {BackgroundColor3 = Color3.fromRGB(44, 44, 60)})
				else
					QTween(Box, 0.3, {BackgroundColor3 = Color3.fromRGB(27, 27, 36)})
				end
				if not Options.callbackonchanged then
					Options:SetValue(Box.Text)
				end
			end)

			if Options.callbackonchanged then
				Box:GetPropertyChangedSignal('Text'):Connect(function()
					if Box.Text == Options.value then return end
					local value = Box.Text
					Library.flags[Options.flag] = value
					Options.value = value
					Options.callback(value)
				end)
			end

			function Options:SetValue(value)
				value = typeof(tostring(value)) == 'string' and tostring(value) or Options.value
				Library.flags[Options.flag] = value
				Options.value = value
				Box.Text = value
				Options.callback(value)
			end

			Options:SetValue(Options.value)

			Library.options[Options.flag] = Options
			return Options
		end

		function Options:AddColor(Options)
			Options = CheckTable(Options, {
				text = 'New Color Picker',
				color = Color3.new(1, 1, 1),
				rainbow = false,
				callback = function() end,
				skipflag = false
			})
			Options.flag = typeof(Options.flag) == 'string' and Options.flag or Options.text
			if tablefind(Library.options, Options.flag) then
				repeat
					Options.flag = Options.flag .. '_'
				until not tablefind(Library.options, Options.flag)
			end
			Options.type = 'color'
			Options.open = false
			Options.hovering = false
			Options.default = Options.color

			local ColorButton = Instance.new('TextButton')
			local ColorText = Instance.new('TextLabel')
			local Container = Instance.new('Frame')
			local PickerIcon = Instance.new('ImageLabel')
			local PreviewHolder = Instance.new('Frame')
			local Preview = Instance.new('Frame')

			ColorButton.Name = 'ColorButton'
			ColorButton.Parent = SectionHolder
			ColorButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ColorButton.BackgroundTransparency = 1.000
			ColorButton.Size = UDim2.new(1, 0, 0, 20)
			ColorButton.Font = Enum.Font.SourceSans
			ColorButton.Text = ''
			ColorButton.TextColor3 = Color3.fromRGB(0, 0, 0)
			ColorButton.TextSize = 14.000

			ColorText.Name = 'ColorText'
			ColorText.Parent = ColorButton
			ColorText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ColorText.BackgroundTransparency = 1.000
			ColorText.Size = UDim2.new(1, 0, 1, 0)
			ColorText.Font = Enum.Font.Nunito
			ColorText.Text = Options.text
			ColorText.TextColor3 = Color3.fromRGB(144, 144, 165)
			ColorText.TextSize = 16.000
			ColorText.TextXAlignment = Enum.TextXAlignment.Left

			Container.Name = 'Container'
			Container.Parent = ColorButton
			Container.AnchorPoint = Vector2.new(1, 0)
			Container.BackgroundColor3 = Color3.fromRGB(27, 27, 36)
			Container.BorderColor3 = Color3.fromRGB(44, 44, 60)
			Container.Position = UDim2.new(1, 0, 0, 0)
			Container.Size = UDim2.new(0, 25, 1, 0)
			Roundify(Container)
			Border(Container)

			PickerIcon.Name = 'PickerIcon'
			PickerIcon.Parent = Container
			PickerIcon.AnchorPoint = Vector2.new(1, 0)
			PickerIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			PickerIcon.BackgroundTransparency = 1.000
			PickerIcon.Position = UDim2.new(1, -2, 0, 2)
			PickerIcon.Size = UDim2.new(0, 16, 0, 16)
			PickerIcon.Image = 'rbxassetid://11419718822'
			PickerIcon.ImageColor3 = Color3.fromRGB(144, 144, 165)

			PreviewHolder.Name = 'PreviewHolder'
			PreviewHolder.Parent = Container
			PreviewHolder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			PreviewHolder.BackgroundTransparency = 1.000
			PreviewHolder.ClipsDescendants = true
			PreviewHolder.Size = UDim2.new(0, 5, 1, 0)

			Preview.Name = 'Preview'
			Preview.Parent = PreviewHolder
			Preview.BackgroundColor3 = Color3.fromRGB(255, 65, 65)
			Preview.Size = UDim2.new(4, 0, 1, 0)
			Roundify(Preview).CornerRadius = UDim.new(0, 7)

			local ColorWindow = Instance.new('Frame')
			local Hue = Instance.new('Frame')
			local HueGradient = Instance.new('UIGradient')
			local HueSlider = Instance.new('Frame')
			local SatVal = Instance.new('ImageLabel')
			local SatValSlider = Instance.new('Frame')
			local Visual = Instance.new('Frame')
			local RainbowColor = Instance.new('TextButton')
			local ResetColor = Instance.new('TextButton')
			local ValueBox = Instance.new('TextBox')
			local ValueBoxConstraint = Instance.new('UITextSizeConstraint')
			local HexBox = Instance.new('TextBox')
			local HexBoxConstraint = Instance.new('UITextSizeConstraint')

			ColorWindow.Name = 'ColorWindow'
			ColorWindow.Parent = Mainframe
			ColorWindow.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
			ColorWindow.BorderColor3 = Color3.fromRGB(44, 44, 60)
			ColorWindow.ClipsDescendants = true
			ColorWindow.Size = UDim2.new(0, 207, 0, 0)
			ColorWindow.ZIndex = 2
			ColorWindow.Visible = false
			Roundify(ColorWindow)
			Border(ColorWindow)

			Hue.Name = 'Hue'
			Hue.Parent = ColorWindow
			Hue.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Hue.BorderColor3 = Color3.fromRGB(44, 44, 60)
			Hue.Position = UDim2.new(0, 5, 0, 137)
			Hue.Size = UDim2.new(0, 127, 0, 20)
			Roundify(Hue)
			Border(Hue)

			HueGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)), ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255, 0, 255)), ColorSequenceKeypoint.new(0.32, Color3.fromRGB(0, 0, 255)), ColorSequenceKeypoint.new(0.49, Color3.fromRGB(0, 255, 255)), ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 255, 0)), ColorSequenceKeypoint.new(0.82, Color3.fromRGB(255, 255, 0)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0))}
			HueGradient.Name = 'HueGradient'
			HueGradient.Parent = Hue

			HueSlider.Name = 'HueSlider'
			HueSlider.Parent = Hue
			HueSlider.BackgroundColor3 = Color3.fromRGB(27, 27, 36)
			HueSlider.BorderSizePixel = 0
			HueSlider.Position = UDim2.new(0, 20, 0, 2)
			HueSlider.Size = UDim2.new(0, 2, 1, -4)

			SatVal.Name = 'SatVal'
			SatVal.Parent = ColorWindow
			SatVal.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
			SatVal.BorderColor3 = Color3.fromRGB(44, 44, 60)
			SatVal.ClipsDescendants = true
			SatVal.Position = UDim2.new(0, 5, 0, 5)
			SatVal.Size = UDim2.new(0, 127, 0, 127)
			SatVal.Image = 'rbxassetid://4155801252'
			Roundify(SatVal)
			Border(SatVal)

			SatValSlider.Name = 'SatValSlider'
			SatValSlider.Parent = SatVal
			SatValSlider.AnchorPoint = Vector2.new(0.5, 0.5)
			SatValSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			SatValSlider.BorderColor3 = Color3.fromRGB(0, 0, 0)
			SatValSlider.Position = UDim2.new(0, 50, 0, 50)
			SatValSlider.Size = UDim2.new(0, 4, 0, 4)
			Roundify(SatValSlider).CornerRadius = UDim.new(1, 0)
			Border(SatValSlider)

			Visual.Name = 'Visual'
			Visual.Parent = ColorWindow
			Visual.BackgroundColor3 = Color3.fromRGB(255, 65, 65)
			Visual.BorderColor3 = Color3.fromRGB(44, 44, 60)
			Visual.Position = UDim2.new(0, 137, 0, 5)
			Visual.Size = UDim2.new(0, 65, 0, 52)
			Roundify(Visual)
			Border(Visual)

			RainbowColor.Name = 'RainbowColor'
			RainbowColor.Parent = ColorWindow
			RainbowColor.BackgroundColor3 = Color3.fromRGB(27, 27, 36)
			RainbowColor.BorderColor3 = Color3.fromRGB(44, 44, 60)
			RainbowColor.Position = UDim2.new(0, 137, 0, 137)
			RainbowColor.Size = UDim2.new(0, 65, 0, 20)
			RainbowColor.AutoButtonColor = false
			RainbowColor.Font = Enum.Font.Nunito
			RainbowColor.Text = 'Rainbow'
			RainbowColor.TextColor3 = Color3.fromRGB(144, 144, 165)
			RainbowColor.TextSize = 16.000
			Roundify(RainbowColor)
			Border(RainbowColor)

			ResetColor.Name = 'ResetColor'
			ResetColor.Parent = ColorWindow
			ResetColor.BackgroundColor3 = Color3.fromRGB(27, 27, 36)
			ResetColor.BorderColor3 = Color3.fromRGB(44, 44, 60)
			ResetColor.Position = UDim2.new(0, 137, 0, 112)
			ResetColor.Size = UDim2.new(0, 65, 0, 20)
			ResetColor.AutoButtonColor = false
			ResetColor.Font = Enum.Font.Nunito
			ResetColor.Text = 'Reset'
			ResetColor.TextColor3 = Color3.fromRGB(144, 144, 165)
			ResetColor.TextSize = 16.000
			Roundify(ResetColor)
			Border(ResetColor)

			ValueBox.Name = 'ValueBox'
			ValueBox.Parent = ColorWindow
			ValueBox.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
			ValueBox.BorderColor3 = Color3.fromRGB(44, 44, 60)
			ValueBox.Position = UDim2.new(0, 137, 0, 62)
			ValueBox.Size = UDim2.new(0, 65, 0, 20)
			ValueBox.ClearTextOnFocus = false
			ValueBox.Font = Enum.Font.Code
			ValueBox.PlaceholderColor3 = Color3.fromRGB(70, 70, 80)
			ValueBox.PlaceholderText = 'R,G,B'
			ValueBox.Text = ''
			ValueBox.TextColor3 = Color3.fromRGB(144, 144, 165)
			ValueBox.TextScaled = true
			ValueBox.TextSize = 16.000
			ValueBox.TextWrapped = true
			Roundify(ValueBox)
			Border(ValueBox)

			ValueBoxConstraint.Name = 'ValueBoxConstraint'
			ValueBoxConstraint.Parent = ValueBox
			ValueBoxConstraint.MaxTextSize = 16

			HexBox.Name = 'HexBox'
			HexBox.Parent = ColorWindow
			HexBox.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
			HexBox.BorderColor3 = Color3.fromRGB(44, 44, 60)
			HexBox.Position = UDim2.new(0, 137, 0, 87)
			HexBox.Size = UDim2.new(0, 65, 0, 20)
			HexBox.ClearTextOnFocus = false
			HexBox.Font = Enum.Font.Code
			HexBox.PlaceholderColor3 = Color3.fromRGB(70, 70, 80)
			HexBox.PlaceholderText = 'HEX'
			HexBox.Text = ''
			HexBox.TextColor3 = Color3.fromRGB(144, 144, 165)
			HexBox.TextScaled = true
			HexBox.TextSize = 16.000
			HexBox.TextWrapped = true
			Roundify(HexBox)
			Border(HexBox)

			HexBoxConstraint.Name = 'HexBoxConstraint'
			HexBoxConstraint.Parent = HexBox
			HexBoxConstraint.MaxTextSize = 16

			ColorWindow.InputBegan:Connect(function(input)
				if input.UserInputType == InputTypes.MouseMovement then
					Options.hovering = true
				end
			end)

			ColorWindow.InputEnded:Connect(function(input)
				if input.UserInputType == InputTypes.MouseMovement then
					Options.hovering = false
				end
			end)

			Library:AddConnection(ColorWindow:GetPropertyChangedSignal('AbsoluteSize'), function()
				if ColorWindow.AbsoluteSize.Y == 0 then
					ColorWindow.Visible = false
				else
					ColorWindow.Visible = true
				end
			end)

			local function UpdateWindowPos()
				ColorWindow.Position = UDim2.new(0, Round(ColorButton.AbsolutePosition.X - Mainframe.AbsolutePosition.X - 5), 0, Round(ColorButton.AbsolutePosition.Y - Mainframe.AbsolutePosition.Y + ColorButton.AbsoluteSize.Y + 5))
			end

			Library:AddConnection(ColorButton:GetPropertyChangedSignal('AbsolutePosition'), UpdateWindowPos)
			UpdateWindowPos()

			local hue, sat, val = Color3.toHSV(Options.color)
			hue, sat, val = hue == 0 and 1 or hue, sat + 0.005, val - 0.005
			local editingHue
			local editingSatVal
			local currentColor = Options.color
			local rainbowEnabled
			local rainbowLoop

			local function clamp(nums)
				for i, v in pairs(nums) do
					nums[i] = math.clamp(v, 0, 1)
				end
				return table.unpack(nums)
			end

			local function color2text(color, hex)
				if hex then
					return '#' .. color:ToHex()
				else
					return SetDecimal(color.R * 255, 0) .. ', ' .. SetDecimal(color.G * 255, 0) .. ', ' .. SetDecimal(color.B * 255, 0)
				end
			end
			ValueBox.Text = color2text(Options.color)
			HexBox.Text = color2text(Options.color, true)

			local function buttonEffects(Button)
				local ButtonGradient = Instance.new('Frame')

				ButtonGradient.Name = 'ButtonGradient'
				ButtonGradient.Parent = Button
				ButtonGradient.BackgroundTransparency = 1
				ButtonGradient.BackgroundColor3 = Color3.new(1, 1, 1)
				ButtonGradient.Size = UDim2.new(1, 0, 1, 0)
				Roundify(ButtonGradient)
				Border(ButtonGradient).Color = Color3.new(1, 1, 1)
				ButtonGradient.UIStroke.Transparency = 1
				Gradient(ButtonGradient.UIStroke)
				Glow(ButtonGradient).ImageTransparency = 1

				Button.MouseEnter:Connect(function()
					QTween(Button, 0.3, {BackgroundColor3 = Color3.fromRGB(44, 44, 60)})
				end)

				Button.MouseLeave:Connect(function()
					QTween(Button, 0.3, {BackgroundColor3 = Color3.fromRGB(27, 27, 36)})
					QTween(ButtonGradient.UIStroke, 0.3, {Transparency = 1})
					QTween(ButtonGradient.Glow, 0.3, {ImageTransparency = 1})
				end)

				Button.MouseButton1Down:Connect(function()
					QTween(ButtonGradient.UIStroke, 0.3, {Transparency = 0})
					QTween(ButtonGradient.Glow, 0.3, {ImageTransparency = 0})
				end)

				Button.MouseButton1Up:Connect(function()
					QTween(ButtonGradient.UIStroke, 0.3, {Transparency = 1})
					QTween(ButtonGradient.Glow, 0.3, {ImageTransparency = 1})
				end)

				Button.MouseButton1Click:Connect(function()
					local Ripple = Instance.new('ImageLabel')

					Ripple.Name = 'Ripple'
					Ripple.Parent = Button
					Ripple.AnchorPoint = Vector2.new(0.5, 0)
					Ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					Ripple.BackgroundTransparency = 1.000
					Ripple.Position = UDim2.new(0.5, 0, 0, 0)
					Ripple.Size = UDim2.new(0, 0, 1, 0)
					Ripple.Image = 'rbxassetid://6814674798'
					Ripple.ImageTransparency = 0.500
					Roundify(Ripple)

					QTween(Ripple, 0.5, {ImageTransparency = 1, Size = UDim2.new(1, 0, 1, 0)})

					delay(0.5, function()
						Ripple:Destroy()
					end)
				end)
			end
			buttonEffects(RainbowColor)
			buttonEffects(ResetColor)

			function Options:SetColor(Color, Rainbow)
				if typeof(Rainbow) == 'boolean' then
					rainbowEnabled = Rainbow
					Options.rainbow = Rainbow
				end
				if typeof(Color) == 'table' then
					Color = Color3.new(Color[1], Color[2], Color[3])
				end
				Color = typeof(Color) == 'Color3' and Color or currentColor
				hue, sat, val = Color3.toHSV(Color)
				local waszero = false
				if sat == 0 then
					sat = 0.005
					waszero = true
				end
				hue, sat, val = clamp({hue, sat, val})
				hue = hue == 0 and 1 or hue
				Color = Color3.fromHSV(hue, sat, val)

				currentColor = Color
				Options.color = Color
				Library.flags[Options.flag] = Color

				if rainbowEnabled then
					if not rainbowLoop then
						rainbowLoop = RunService.Heartbeat:Connect(function()
							Options:SetColor(ChromaColor)
							RainbowColor.TextColor3 = ChromaColor
						end)
					end
				else
					if rainbowLoop then rainbowLoop:Disconnect(); rainbowLoop = nil end
					RainbowColor.TextColor3 = Color3.fromRGB(144, 144, 165)
				end

				STween(SatVal, 0.1, {BackgroundColor3 = Color3.fromHSV(hue, 1, 1)})
				STween(Visual, 0.1, {BackgroundColor3 = Color})
				STween(Preview, 0.1, {BackgroundColor3 = Color})
				if not waszero then
					STween(HueSlider, 0.1, {Position = UDim2.new(1 - hue, 0, 0, 2)})
				end
				STween(SatValSlider, 0.1, {Position = UDim2.new(sat, 0, 1 - val, 0)})

				ValueBox.Text = color2text(Color)
				HexBox.Text = color2text(Color, true)
				Options.callback(Color)
			end

			ColorButton.MouseEnter:Connect(function()
				if Library.warning or (Library.popup and Library.popup.hovering) then return end
				QTween(Container, 0.3, {BackgroundColor3 = Color3.fromRGB(44, 44, 60)})
			end)

			ColorButton.MouseLeave:Connect(function()
				QTween(Container, 0.3, {BackgroundColor3 = Color3.fromRGB(27, 27, 36)})
			end)

			ColorButton.MouseButton1Down:Connect(function()
				if Library.warning or (Library.popup and Library.popup.hovering) then return end
				QTween(Container, 0.3, {BackgroundColor3 = Color3.fromRGB(34, 34, 45)})
			end)

			ColorButton.MouseButton1Up:Connect(function()
				QTween(Container, 0.3, {BackgroundColor3 = Color3.fromRGB(44, 44, 60)})
			end)

			ColorButton.MouseButton1Click:Connect(function()
				if Library.popup and Library.popup ~= Options and Library.popup.hovering then return end
				if Library.popup == Options then Library.popup:Close(); return end
				if Library.popup and Library.popup.hovering == false then Library.popup:Close() end
				QTween(ColorWindow, 0.5, {Size = UDim2.new(0, 207, 0, 162)})
				Options.open = true
				Library.popup = Options
			end)

			ValueBox.FocusLost:Connect(function()
				local split = string.split(ValueBox.Text, ',')
				local r, g, b = tonumber(split[1]), tonumber(split[2]), tonumber(split[3])
				if not r or not g or not b or not Color3.fromRGB(r, g, b) then Options:SetColor(currentColor); return end
				Options:SetColor(Color3.fromRGB(r, g, b))
			end)

			HexBox.FocusLost:Connect(function()
				local hex = HexBox.Text
				local r, g, b = hex:match('#?(..)(..)(..)')
				if r and g and b then
					local color = Color3.fromRGB(tonumber('0x' .. r), tonumber('0x' .. g), tonumber('0x' .. b))
					return Options:SetColor(color)
				end

				r, g, b = Library.round(currentColor)
				HexBox.Text = string.format('#%02x%02x%02x', r, g, b)
			end)

			Hue.InputBegan:Connect(function(input)
				if input.UserInputType == InputTypes.MouseButton1 then
					editingHue = true
					local X = (Hue.AbsolutePosition.X + Hue.AbsoluteSize.X) - Hue.AbsolutePosition.X
					X = math.clamp((input.Position.X - Hue.AbsolutePosition.X) / X, 0, 0.995)
					Options:SetColor(Color3.fromHSV(1 - X, sat, val))
				end
			end)

			Library:AddConnection(InputService.InputChanged, function(input)
				if input.UserInputType == InputTypes.MouseMovement and editingHue then
					local X = (Hue.AbsolutePosition.X + Hue.AbsoluteSize.X) - Hue.AbsolutePosition.X
					X = math.clamp((input.Position.X - Hue.AbsolutePosition.X) / X, 0, 0.995)
					Options:SetColor(Color3.fromHSV(1 - X, sat, val))
				end
			end)

			Hue.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					editingHue = false
				end
			end)

			SatVal.InputBegan:Connect(function(input)
				if input.UserInputType == InputTypes.MouseButton1 then
					editingSatVal = true
					local X = (SatVal.AbsolutePosition.X + SatVal.AbsoluteSize.X) - SatVal.AbsolutePosition.X
					local Y = (SatVal.AbsolutePosition.Y + SatVal.AbsoluteSize.Y) - SatVal.AbsolutePosition.Y
					X = math.clamp((input.Position.X - SatVal.AbsolutePosition.X) / X, 0, 0.995)
					Y = math.clamp((input.Position.Y - SatVal.AbsolutePosition.Y) / Y, 0, 0.995)
					Options:SetColor(Color3.fromHSV(hue, X, 1 - Y))
				end
			end)

			Library:AddConnection(InputService.InputChanged, function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement and editingSatVal then
					local X = (SatVal.AbsolutePosition.X + SatVal.AbsoluteSize.X) - SatVal.AbsolutePosition.X
					local Y = (SatVal.AbsolutePosition.Y + SatVal.AbsoluteSize.Y) - SatVal.AbsolutePosition.Y
					X = math.clamp((input.Position.X - SatVal.AbsolutePosition.X) / X, 0, 0.995)
					Y = math.clamp((input.Position.Y - SatVal.AbsolutePosition.Y) / Y, 0, 0.995)
					Options:SetColor(Color3.fromHSV(hue, X, 1 - Y))
				end
			end)

			SatVal.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					editingSatVal = false
				end
			end)

			ResetColor.MouseButton1Click:Connect(function()
				Options:SetColor(Options.default)
			end)

			RainbowColor.MouseButton1Click:Connect(function()
				Options:SetColor(ChromaColor, not Options.rainbow)
			end)

			Options:SetColor(currentColor, Options.rainbow)

			function Options:Close()
				Library.popup = nil
				QTween(ColorWindow, 0.5, {Size = UDim2.new(0, 207, 0, 0)})
				Options.open = false
			end

			Library.options[Options.flag] = Options
			return Options
		end

		Tab.sections[Options.text] = Options
		return Options
	end

	Library.tabs[Text] = Tab
	return Tab
end

function Library:Settings(Options)
	Options = CheckTable(Options, {
		name = 'Ayarum v4.1',
		themecolor1 = Library.themecolor1,
		themecolor2 = Library.themecolor2,
		foldername = Library.foldername,
		fileext = Library.fileext,
		useconfigs = Library.useconfigs,
		autoload = Library.autoload
	})
	Title.Text = '<b>' .. Options.name .. '</b>'
	Library.themecolor1 = Options.themecolor1
	Library.themecolor2 = Options.themecolor2
	Library.foldername = Options.foldername
	Library.fileext = Options.fileext
	Library.autoload = Options.autoload
	Library.useconfigs = Options.useconfigs
	for _, v in pairs(Library.theme) do
		v.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Library.themecolor1), ColorSequenceKeypoint.new(1, Library.themecolor2)})
	end
end

function Library.round(num, bracket)
	if typeof(num) == 'Vector2' then
		return Vector2.new(Library.round(num.X), Library.round(num.Y))
	elseif typeof(num) == 'Vector3' then
		return Vector3.new(Library.round(num.X), Library.round(num.Y), Library.round(num.Z))
	elseif typeof(num) == 'Color3' then
		return Library.round(num.r * 255), Library.round(num.g * 255), Library.round(num.b * 255)
	else
		return num - num % (bracket or 1);
	end
end

local MouseIndicator = Drawing.new('Circle')
local MouseBorder = Drawing.new('Circle')

MouseIndicator.NumSides = 60
MouseIndicator.Radius = 2
MouseIndicator.Filled = true
MouseIndicator.Visible = true
MouseIndicator.Color = Color3.new(1, 1, 1)
MouseIndicator.ZIndex = 10

MouseBorder.NumSides = 60
MouseBorder.Radius = 3
MouseBorder.Filled = true
MouseBorder.Visible = true
MouseBorder.Color = Color3.new(0, 0, 0)
MouseBorder.ZIndex = 9

function Library:Unload()
	Library.fullloaded = false
	for _, v in pairs(Ayarumv4:GetChildren()) do
		if v.Name == 'Notification' then
			v.CanTween.Value = false
			QTween(v, 0.5, {Position = UDim2.new(1, v.Size.X.Offset + 5, 1, v.NotifPos.Value)}, true)
		end
	end
	if Library.warning then
		Library.warning:Close()
	end
	Library:Defaults()
	for _, c in next, Library.connections do
		c:Disconnect()
	end
	wait()
	Ayarumv4:Destroy()
	getgenv().ayarum = nil
	Library.loaded = false
	MouseIndicator:Remove()
	MouseBorder:Remove()
end

Library:AddConnection(RunService.RenderStepped, function()
	MouseBorder.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
	MouseIndicator.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
end)

function Library:Toggle(Bool)
	if not Library.fullloaded then return end
	if typeof(Bool) ~= 'boolean' then Bool = false end
	Library.open = Bool
	if Library.popup then
		Library.popup:Close()
	end
	Mainframe.Visible = Library.open
	MouseIndicator.Visible = Library.open
	MouseBorder.Visible = Library.open
end

function Library:Defaults()
	for _, option in next, Library.options do
		if option.type ~= 'button' and not option.skipflag then
			if option.type == 'toggle' then
				spawn(function()
					option:SetState(option.default)
				end)
			elseif option.type == 'color' then
				spawn(function()
					option:SetColor(option.default, false)
				end)
			elseif option.type == 'bind' then
				spawn(function()
					option:SetKey(option.default)
				end)
			else
				spawn(function()
					option:SetValue(option.default)
				end)
			end
		end
	end
	wait()
	Library.themecolor1 = Library.flags['Gradient Start Color']
	Library.themecolor2 = Library.flags['Gradient End Color']
	for _, v in pairs(Library.theme) do
		v.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Library.themecolor1), ColorSequenceKeypoint.new(1, Library.themecolor2)})
	end
end

function Library:LoadConfig(config)
	if table.find(Library:GetConfigs(), config) then
		local Read, Config = pcall(function() return game:GetService('HttpService'):JSONDecode(readfile(Library.foldername .. '/' .. config .. Library.fileext)) end)
		Config = Read and Config or {}
		for _, option in next, Library.options do
			if option.type ~= 'button' and option.flag and not option.skipflag then
				if option.type == 'toggle' then
					spawn(function()
						option:SetState(Config[option.flag] == 1)
					end)
				elseif option.type == 'color' then
					if Config[option.flag] then
						spawn(function()
							option:SetColor(Color3.new(Config[option.flag][1], Config[option.flag][2], Config[option.flag][3]), Config[option.flag][4])
						end)
					end
				elseif option.type == 'bind' then
					spawn(function()
						option:SetKey(Config[option.flag])
					end)
				else
					spawn(function()
						option:SetValue(Config[option.flag])
					end)
				end
			end
		end
		wait()
		Library.themecolor1 = Library.flags['Gradient Start Color']
		Library.themecolor2 = Library.flags['Gradient End Color']
		for _, v in pairs(Library.theme) do
			v.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Library.themecolor1), ColorSequenceKeypoint.new(1, Library.themecolor2)})
		end
	end
end

function Library:SaveConfig(config)
	local Config = {}
	if table.find(Library:GetConfigs(), config) then
		Config = game:GetService('HttpService'):JSONDecode(readfile(Library.foldername .. '/' .. config .. Library.fileext))
	end
	for _, option in next, Library.options do
		if option.type ~= 'button' and option.flag and not option.skipflag then
			if option.type == 'toggle' then
				Config[option.flag] = option.state and 1 or 0
			elseif option.type == 'color' then
				Config[option.flag] = {option.color.R, option.color.G, option.color.B, option.rainbow}
			elseif option.type == 'bind' then
				if option.key ~= 'None' then
					Config[option.flag] = option.key
				end
			else
				Config[option.flag] = option.value
			end
		end
	end
	writefile(Library.foldername .. '/' .. config .. Library.fileext, game:GetService('HttpService'):JSONEncode(Config))
end

function Library:GetConfigs()
	if not isfolder(Library.foldername) then
		if string.match(Library.foldername, '/') then
			local Folders = string.split(Library.foldername, '/')
			local str = ''
			for _, v in pairs(Folders) do
				str = str .. v .. '/'
				makefolder(str)
			end
		else
			makefolder(Library.foldername)
		end
		return {}
	end
	local files = {}
	local a = 0
	for _, v in next, listfiles(Library.foldername) do
		if v:sub(#v - #Library.fileext + 1, #v) == Library.fileext then
			a = a + 1
			v = v:gsub(Library.foldername .. '\\', '')
			v = v:gsub(Library.fileext, '')
			table.insert(files, a, v)
		end
	end
	return files
end

function Library:Notify(Message, Duration)
	Message = typeof(tostring(Message)) == 'string' and tostring(Message) or 'New Notification'
	if Message:gsub(' ', '') == '' then return end
	Duration = typeof(Duration) == 'number' and Duration or 5

	local Notification = Instance.new('Frame')
	local NotifIcon = Instance.new('ImageLabel')
	local NotifDetailHolder = Instance.new('Frame')
	local NotifDetail = Instance.new('Frame')
	local NotifText = Instance.new('TextLabel')
	local NotifPos = Instance.new('IntValue')
	local CanTween = Instance.new('BoolValue')

	Notification.Parent = Ayarumv4
	Notification.AnchorPoint = Vector2.new(1, 1)
	Notification.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
	Notification.BorderColor3 = Color3.fromRGB(44, 44, 60)
	Notification.Position = UDim2.new(1, -10, 1, -10)
	Notification.Size = UDim2.new(0, 162, 0, 50)
	Notification.ZIndex = 2
	Roundify(Notification)
	Glow(Notification, Color3.new(0, 0, 0))

	NotifIcon.Name = 'NotifIcon'
	NotifIcon.Parent = Notification
	NotifIcon.AnchorPoint = Vector2.new(0, 0.5)
	NotifIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	NotifIcon.BackgroundTransparency = 1.000
	NotifIcon.Position = UDim2.new(0, 8, 0.5, 0)
	NotifIcon.Size = UDim2.new(0, 24, 0, 24)
	NotifIcon.Image = 'rbxassetid://6034308946'
	Gradient(NotifIcon, 45)

	NotifDetailHolder.Name = 'NotifDetailHolder'
	NotifDetailHolder.Parent = Notification
	NotifDetailHolder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	NotifDetailHolder.BackgroundTransparency = 1.000
	NotifDetailHolder.ClipsDescendants = true
	NotifDetailHolder.Size = UDim2.new(0, 5, 1, 0)

	NotifDetail.Name = 'NotifDetail'
	NotifDetail.Parent = NotifDetailHolder
	NotifDetail.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	NotifDetail.BorderSizePixel = 0
	NotifDetail.Size = UDim2.new(0, 10, 1, 0)
	Roundify(NotifDetail)
	Gradient(NotifDetail, 90)

	NotifText.Name = 'NotifText'
	NotifText.Parent = Notification
	NotifText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	NotifText.BackgroundTransparency = 1.000
	NotifText.Position = UDim2.new(0, 32, 0, 0)
	NotifText.Size = UDim2.new(1, -32, 1, 0)
	NotifText.Font = Enum.Font.Nunito
	NotifText.RichText = true
	NotifText.Text = '<b>' .. Message .. '</b>'
	NotifText.TextColor3 = Color3.fromRGB(255, 255, 255)
	NotifText.TextSize = 18.000
	Gradient(NotifText)

	NotifPos.Name = 'NotifPos'
	NotifPos.Parent = Notification
	NotifPos.Value = -10

	CanTween.Name = 'CanTween'
	CanTween.Parent = Notification
	CanTween.Value = true

	Notification.Size = UDim2.new(0, NotifText.TextBounds.X + 47, 0, NotifText.TextBounds.Y + 10)
	Notification.Position = UDim2.new(1, Notification.AbsoluteSize.X + 5, 1, -10)

	for _, v in pairs(Ayarumv4:GetChildren()) do
		if v.Name == 'Notification' then
			v.NotifPos.Value = v.NotifPos.Value - (Notification.Size.Y.Offset + 10)
			if v.CanTween.Value then
				QTween(v, 0.5, {Position = UDim2.new(1, -10, 1, v.NotifPos.Value)})
			end
		end
	end
	Notification.Name = 'Notification'

	BTween(Notification, 0.5, {Position = UDim2.new(1, -10, 1, NotifPos.Value)})

	delay(Duration, function()
		CanTween.Value = false
		BTween(Notification, 0.5, {Position = UDim2.new(1, Notification.AbsoluteSize.X + 5, 1, NotifPos.Value)}, true)
		for _, v in pairs(Ayarumv4:GetChildren()) do
			if v.Name == 'Notification' then
				if v.NotifPos.Value < NotifPos.Value and v.CanTween.Value == true then
					v.NotifPos.Value = v.NotifPos.Value + (Notification.Size.Y.Offset + 10)
					QTween(v, 0.5, {Position = UDim2.new(1, -10, 1, v.NotifPos.Value)})
				end
			end
		end
		wait(0.5)
		Notification:Destroy()
	end)
end

function Library:AddLoadingBar(LoadingBarText)
	local LoadingGui = Instance.new('ScreenGui')
	local LoadingBar = Instance.new('Frame')
	local LoadingBarTitle = Instance.new('TextLabel')
	local BarHolder = Instance.new('Frame')
	local Bar = Instance.new('Frame')
	local LoadingInfo = Instance.new('TextLabel')

	LoadingGui.Name = 'LoadingGui'
	LoadingGui.Parent = RunService:IsStudio() and game.Players.LocalPlayer:WaitForChild('PlayerGui') or game.CoreGui
	LoadingGui.IgnoreGuiInset = true
	LoadingGui.DisplayOrder = 300
	LoadingGui.ResetOnSpawn = false
	LoadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	LoadingBar.Name = 'LoadingBar'
	LoadingBar.Parent = LoadingGui
	LoadingBar.AnchorPoint = Vector2.new(0.5, 0)
	LoadingBar.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
	LoadingBar.BorderColor3 = Color3.fromRGB(27, 42, 53)
	LoadingBar.Position = UDim2.new(0.5, 0, 0, -85)
	LoadingBar.Size = UDim2.new(0, 350, 0, 78)
	Roundify(LoadingBar)
	Glow(LoadingBar, Color3.new(0, 0, 0))

	LoadingBarTitle.Name = 'LoadingBarTitle'
	LoadingBarTitle.Parent = LoadingBar
	LoadingBarTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	LoadingBarTitle.BackgroundTransparency = 1.000
	LoadingBarTitle.Position = UDim2.new(0, 10, 0, 0)
	LoadingBarTitle.Size = UDim2.new(0, 152, 0, 25)
	LoadingBarTitle.Font = Enum.Font.Nunito
	LoadingBarTitle.RichText = true
	LoadingBarTitle.Text = '<b>Ayarum v4.1 - ' .. LoadingBarText .. '</b>'
	LoadingBarTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	LoadingBarTitle.TextSize = 20.000
	LoadingBarTitle.TextXAlignment = Enum.TextXAlignment.Left
	Gradient(LoadingBarTitle)

	BarHolder.Name = 'BarHolder'
	BarHolder.Parent = LoadingBar
	BarHolder.AnchorPoint = Vector2.new(0, 1)
	BarHolder.BackgroundColor3 = Color3.fromRGB(27, 27, 36)
	BarHolder.BorderColor3 = Color3.fromRGB(44, 44, 60)
	BarHolder.Position = UDim2.new(0, 10, 1, -10)
	BarHolder.Size = UDim2.new(1, -20, 0, 20)
	Roundify(BarHolder)
	Border(BarHolder)

	Bar.Name = 'Bar'
	Bar.Parent = BarHolder
	Bar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Bar.BackgroundTransparency = 1
	Bar.Size = UDim2.new(0, 0, 1, 0)
	Gradient(Bar)
	Roundify(Bar)
	Border(Bar).Color = Color3.new(1, 1, 1)
	Gradient(Bar.UIStroke)
	Glow(Bar, Color3.new(1, 1, 1)).ImageTransparency = 1
	Gradient(Bar.Glow)
	Bar.UIStroke.Enabled = false

	LoadingInfo.Name = 'LoadingInfo'
	LoadingInfo.Parent = LoadingBar
	LoadingInfo.AnchorPoint = Vector2.new(0.5, 0)
	LoadingInfo.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	LoadingInfo.BackgroundTransparency = 1.000
	LoadingInfo.Position = UDim2.new(0.5, 0, 0, 25)
	LoadingInfo.Size = UDim2.new(1, 0, 0, 18)
	LoadingInfo.Font = Enum.Font.Nunito
	LoadingInfo.Text = 'Initializing...'
	LoadingInfo.TextColor3 = Color3.fromRGB(144, 144, 165)
	LoadingInfo.TextSize = 18.000

	BTween(LoadingBar, 0.5, {Position = UDim2.new(0.5, 0, 0, 10)})
	wait(1)
	local Options = {}
	function Options:Update(Value, Max, Text)
		Bar.UIStroke.Enabled = true
		QTween(Bar, 0.5, {Size = UDim2.new(Value / Max, 0, 1, 0)})
		LoadingInfo.Text = Text
		if Value == Max then
			wait(0.5)
			QTween(Bar, 0.5, {BackgroundTransparency = 0})
			QTween(Bar.Glow, 0.5, {ImageTransparency = 0})
			wait(1.5)
			QTween(LoadingBar, 0.5, {Position = UDim2.new(0.5, 0, 0, -85)}, true)
			wait(0.5)
			LoadingGui:Destroy()
		end
	end
	return Options
end

function Library:AddWarning(Options)
	Options = CheckTable(Options, {
		text = 'New Warning'
	})

	local main
	local answer
	function Options:Show()
		if Library.warning then return end
		if Library.popup then Library.popup:Close() end
		if not main then
			main = Instance.new('TextButton')
			local WarningTitle = Instance.new('TextLabel')
			local WarningHolder = Instance.new('Frame')
			local Yes = Instance.new('TextButton')
			local No = Instance.new('TextButton')
			local WarningText = Instance.new('TextLabel')

			main.Name = 'Warning'
			main.Parent = Mainframe
			main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			main.BackgroundTransparency = 1.000
			main.ClipsDescendants = true
			main.Size = UDim2.new(1, 0, 1, 0)
			main.ZIndex = 3
			main.AutoButtonColor = false
			main.Font = Enum.Font.SourceSans
			main.Text = ''
			main.TextColor3 = Color3.fromRGB(0, 0, 0)
			main.TextSize = 14.000
			main.Visible = false
			Roundify(main)

			WarningTitle.Name = 'WarningTitle'
			WarningTitle.Parent = main
			WarningTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			WarningTitle.BackgroundTransparency = 1.000
			WarningTitle.Position = UDim2.new(0, 0, 0, -40)
			WarningTitle.Size = UDim2.new(1, 0, 0, 40)
			WarningTitle.Font = Enum.Font.Nunito
			WarningTitle.Text = 'Warning!'
			WarningTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
			WarningTitle.TextSize = 40.000

			WarningHolder.Name = 'WarningHolder'
			WarningHolder.Parent = main
			WarningHolder.AnchorPoint = Vector2.new(0.5, 0)
			WarningHolder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			WarningHolder.BackgroundTransparency = 1.000
			WarningHolder.Position = UDim2.new(0.5, 0, 1, 0)
			WarningHolder.Size = UDim2.new(1, 0, 0, 53)

			Yes.Name = 'Yes'
			Yes.Parent = WarningHolder
			Yes.AnchorPoint = Vector2.new(1, 1)
			Yes.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
			Yes.BackgroundTransparency = 0.900
			Yes.BorderColor3 = Color3.fromRGB(0, 255, 100)
			Yes.Position = UDim2.new(0.5, -10, 1, 0)
			Yes.Size = UDim2.new(0, 125, 0, 25)
			Yes.AutoButtonColor = false
			Yes.Font = Enum.Font.Nunito
			Yes.Text = 'Yes'
			Yes.TextColor3 = Color3.fromRGB(255, 255, 255)
			Yes.TextSize = 25.000
			Roundify(Yes)
			Border(Yes)
			Glow(Yes, Color3.fromRGB(0, 255, 100)).ImageTransparency = 1

			No.Name = 'No'
			No.Parent = WarningHolder
			No.AnchorPoint = Vector2.new(0, 1)
			No.BackgroundColor3 = Color3.fromRGB(255, 65, 65)
			No.BackgroundTransparency = 0.900
			No.BorderColor3 = Color3.fromRGB(255, 65, 65)
			No.Position = UDim2.new(0.5, 10, 1, 0)
			No.Size = UDim2.new(0, 125, 0, 25)
			No.AutoButtonColor = false
			No.Font = Enum.Font.Nunito
			No.Text = 'No'
			No.TextColor3 = Color3.fromRGB(255, 255, 255)
			No.TextSize = 25.000
			Roundify(No)
			Border(No)
			Glow(No, Color3.fromRGB(255, 65, 65)).ImageTransparency = 1

			WarningText.Name = 'WarningText'
			WarningText.Parent = WarningHolder
			WarningText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			WarningText.BackgroundTransparency = 1.000
			WarningText.BorderColor3 = Color3.fromRGB(27, 42, 53)
			WarningText.Size = UDim2.new(1, 0, 1, -35)
			WarningText.Font = Enum.Font.Nunito
			WarningText.TextColor3 = Color3.fromRGB(255, 255, 255)
			WarningText.TextSize = 18.000
            WarningText.RichText = true

			local function ButtonEffects(Button)
				Button.MouseEnter:Connect(function()
					QTween(Button, 0.3, {BackgroundTransparency = 0})
					QTween(Button.Glow, 0.3, {ImageTransparency = 0})
				end)

				Button.MouseLeave:Connect(function()
					QTween(Button, 0.3, {BackgroundTransparency = 0.9})
					QTween(Button.Glow, 0.3, {ImageTransparency = 0.9})
					QTween(Button.UIStroke, 0.3, {Transparency = 0})
				end)

				Button.MouseButton1Down:Connect(function()
					QTween(Button, 0.3, {BackgroundTransparency = 0.5})
					QTween(Button.UIStroke, 0.3, {Transparency = 0.5})
					QTween(Button.Glow, 0.3, {ImageTransparency = 0.5})
				end)

				Button.MouseButton1Up:Connect(function()
					QTween(Button, 0.3, {BackgroundTransparency = 0})
					QTween(Button.UIStroke, 0.3, {Transparency = 0})
					QTween(Button.Glow, 0.3, {ImageTransparency = 1})
				end)
			end

			ButtonEffects(Yes)
			ButtonEffects(No)

			Yes.MouseButton1Click:Connect(function()
				answer = true
			end)

			No.MouseButton1Click:Connect(function()
				answer = false
			end)
		end
		Library.warning = Options
		main.WarningHolder.WarningText.Text = Options.text
		main.WarningHolder.Size = UDim2.new(1, 0, 0, main.WarningHolder.WarningText.TextBounds.Y + 35)
		main.Visible = true
		QTween(main, 0.5, {BackgroundTransparency = 0.5})
		QTween(main.WarningTitle, 0.5, {Position = UDim2.new(0, 0, 0, 0)})
		QTween(main.WarningHolder, 0.5, {Position = UDim2.new(0.5, 0, 0.5, -(main.WarningHolder.AbsoluteSize.Y / 2))})

		repeat wait() until answer ~= nil
		local a = answer
		spawn(Options.Close)
		return a
	end

	function Options:Close()
		answer = nil
		Library.warning = nil
		if not main then return end
		QTween(main, 0.5, {BackgroundTransparency = 1})
		QTween(main.WarningTitle, 0.5, {Position = UDim2.new(0, 0, 0, -40)})
		QTween(main.WarningHolder, 0.5, {Position = UDim2.new(0.5, 0, 1, 0)})
		wait(0.5)
		main.Visible = false
	end

	return Options
end

function Library:Init()
	Library.loaded = true
	if RunService:IsStudio() then
		Ayarumv4.Parent = game.Players.LocalPlayer:WaitForChild('PlayerGui')
	else
		Ayarumv4.Parent = game.CoreGui
	end

	if Library.useconfigs and Library.autoload and isfile(Library.foldername .. '/' .. Library.autoload .. Library.fileext) then
		Library:LoadConfig(Library.autoload)
	end

	spawn(function()
		while Library and wait(1) do
			if Library.useconfigs then
				local Configs = Library:GetConfigs()
				for _, config in next, Configs do
					if not table.find(Library.options['Config List'].values, config) then
						Library.options['Config List']:AddValue(config)
					end
				end
				for _, config in next, Library.options['Config List'].values do
					if not table.find(Configs, config) then
						Library.options['Config List']:RemoveValue(config)
					end
				end
			end
		end
	end)

	for _, v in pairs(Library.tabs) do
		if v.first then
			v.Select()
		end
	end
	wait(0.5)

	local dragbar = DragBar
	local dragframe = Mainframe

	local dragInput
	local dragStart
	local startPos
	local candrag = true
	local dragging = false

	local function update(input)
		if candrag == true then
			local delta = input.Position - dragStart
			game:GetService('TweenService'):Create(dragframe, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}):Play()
		end
	end

	dragbar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if Library.popup and Library.popup.hovering == true then return end
			dragging = true
			dragStart = input.Position
			startPos = dragframe.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	dragbar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	InputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end)

	Library.fullloaded = true
	Library:Toggle(true)
end

return Library