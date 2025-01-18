local ContentProvider = game:GetService('ContentProvider')
local InputService = game:GetService('UserInputService')
local TweenService = game:GetService('TweenService')
local RunService = game:GetService('RunService')
local GuiService = game:GetService('GuiService')
local Mouse = game.Players.LocalPlayer:GetMouse()

local GuiInset = GuiService:GetGuiInset().Y

if game.CoreGui:FindFirstChild('TobBarApp') then
	GuiInset = 58
end

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

local function Border(Object, Color)
	local UIStroke = Instance.new('UIStroke')
	UIStroke.Name = 'UIStroke'
	UIStroke.Parent = Object
	if Object:IsA('TextLabel') then
		UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
		UIStroke.Color = Color
	else
		UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		UIStroke.Color = Object.BorderColor3
	end
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

local AyarumV5 = Instance.new('ScreenGui')
local Mainframe = Instance.new('Frame')
local TabButtons = Instance.new('Frame')
local TabButtonsHolder = Instance.new('Frame')
local TabButtonsLayout = Instance.new('UIListLayout')
local TabsTitle = Instance.new('TextLabel')
local Holder = Instance.new('Frame')
local MouseUnlock = Instance.new('TextButton')
local TitleHolder = Instance.new('Frame')
local Title = Instance.new('TextLabel')
local Darken = Instance.new('Frame')

AyarumV5.Name = 'Ayarum V5'
AyarumV5.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
AyarumV5.DisplayOrder = 200
AyarumV5.ResetOnSpawn = false
AyarumV5.IgnoreGuiInset = true

Mainframe.Name = 'Mainframe'
Mainframe.Parent = AyarumV5
Mainframe.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Mainframe.BorderColor3 = Color3.fromRGB(0, 0, 0)
Mainframe.BorderSizePixel = 0
Mainframe.Size = UDim2.new(0, 500, 1, 0)
Mainframe.Position = UDim2.new(0, 0, 0, 0)
Roundify(Mainframe)
Glow(Mainframe, Color3.new(0, 0, 0))

TabButtons.Name = 'TabButtons'
TabButtons.Parent = Mainframe
TabButtons.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
TabButtons.BorderColor3 = Color3.fromRGB(30, 30, 30)
TabButtons.BorderSizePixel = 1
TabButtons.Position = UDim2.new(0, -175, 0, 0)
TabButtons.Size = UDim2.new(0, 205, 1, 0)
TabButtons.ZIndex = 3
Roundify(TabButtons)
Border(TabButtons)

TabButtonsHolder.Name = 'TabButtonsHolder'
TabButtonsHolder.Parent = TabButtons
TabButtonsHolder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TabButtonsHolder.BackgroundTransparency = 1.000
TabButtonsHolder.BorderColor3 = Color3.fromRGB(0, 0, 0)
TabButtonsHolder.BorderSizePixel = 0
TabButtonsHolder.Position = UDim2.new(0, -15, 0, 40)
TabButtonsHolder.Size = UDim2.new(1, -25, 1, -50)

TabButtonsLayout.Name = 'TabButtonsLayout'
TabButtonsLayout.Parent = TabButtonsHolder
TabButtonsLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabButtonsLayout.Padding = UDim.new(0, 7)

TabsTitle.Name = 'TabsTitle'
TabsTitle.Parent = TabButtons
TabsTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TabsTitle.BackgroundTransparency = 1.000
TabsTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
TabsTitle.BorderSizePixel = 0
TabsTitle.Position = UDim2.new(0, -30, 0, 5)
TabsTitle.Size = UDim2.new(1, 0, 0, 25)
TabsTitle.Font = Enum.Font.Code
TabsTitle.RichText = true
TabsTitle.Text = '<b>Tabs</b>'
TabsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
TabsTitle.TextSize = 20.000

Holder.Name = 'Holder'
Holder.Parent = Mainframe
Holder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Holder.BackgroundTransparency = 1.000
Holder.BorderColor3 = Color3.fromRGB(0, 0, 0)
Holder.BorderSizePixel = 0
Holder.Position = UDim2.new(0, 30, 0, 40)
Holder.Size = UDim2.new(1, -30, 1, -40)
Holder.ClipsDescendants = true
Holder.ZIndex = 0

MouseUnlock.Name = 'MouseUnlock'
MouseUnlock.Parent = AyarumV5
MouseUnlock.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MouseUnlock.BackgroundTransparency = 1.000
MouseUnlock.BorderColor3 = Color3.fromRGB(0, 0, 0)
MouseUnlock.BorderSizePixel = 0
MouseUnlock.Modal = true
MouseUnlock.Font = Enum.Font.SourceSans
MouseUnlock.Text = ''
MouseUnlock.TextColor3 = Color3.fromRGB(0, 0, 0)
MouseUnlock.TextSize = 14.000

TitleHolder.Name = 'TitleHolder'
TitleHolder.Parent = Mainframe
TitleHolder.AnchorPoint = Vector2.new(0.5, 0)
TitleHolder.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
TitleHolder.BorderColor3 = Color3.fromRGB(30, 30, 30)
TitleHolder.BorderSizePixel = 1
TitleHolder.Position = UDim2.new(0.5, 15, 0, 5)
TitleHolder.Size = UDim2.new(1, -50, 0, 35)
Roundify(TitleHolder)
Border(TitleHolder)

Title.Name = 'Title'
Title.Parent = TitleHolder
Title.AnchorPoint = Vector2.new(0.5, 0)
Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1.000
Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
Title.BorderSizePixel = 0
Title.Position = UDim2.new(0.5, 0, 0, 0)
Title.Size = UDim2.new(1, 0, 1, 0)
Title.Font = Enum.Font.Code
Title.RichText = true
Title.Text = ''
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 26.000
Border(Title, Color3.new(0, 0, 0))
Gradient(Title)

Darken.Name = 'Darken'
Darken.Parent = Mainframe
Darken.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Darken.BackgroundTransparency = 1
Darken.BorderColor3 = Color3.fromRGB(0, 0, 0)
Darken.BorderSizePixel = 0
Darken.Size = UDim2.new(1, 0, 1, 0)
Darken.ZIndex = 1
Roundify(Darken)

Library:AddConnection(Title:GetPropertyChangedSignal('Text'), function()
	local SetText = Title.Text:gsub('<b>', ''):gsub('</b>', '')
	local Size = GetTextSize(SetText, Title.TextSize, Title.Font).X
	Title.Size = UDim2.new(0, Size, 1, 0)
end)
Title.Text = '<b>Ayarum v5.0</b>'

local TabsDisplayed = false
TabButtons.MouseEnter:Connect(function()
	if Library.warning then return end
	if Library.popup then Library.popup:Close() end
	TabsDisplayed = true
	QTween(TabButtons, 0.3, {Position = UDim2.new(0, -5, 0, 0)})
	QTween(TabButtonsHolder, 0.3, {Position = UDim2.new(0, 15, 0, 40)})
	QTween(TabsTitle, 0.3, {Position = UDim2.new(0, 0, 0, 5)})
	QTween(Darken, 0.3, {BackgroundTransparency = 0.6})
end)

TabButtons.MouseLeave:Connect(function()
	TabsDisplayed = false
	QTween(TabButtons, 0.3, {Position = UDim2.new(0, -175, 0, 0)})
	QTween(TabButtonsHolder, 0.3, {Position = UDim2.new(0, -15, 0, 40)})
	QTween(TabsTitle, 0.3, {Position = UDim2.new(0, -30, 0, 5)})
	QTween(Darken, 0.3, {BackgroundTransparency = 1})
end)

local SelectedTabButton
local SelectedTabPage
local HasTabBeenAdded = false
local ColumnWidth = 300
function Library:AddTab(Text)
	Text = typeof(Text) == 'string' and Text or 'New Tab'

	local Tab = {selected = false, sections = {}, first = not HasTabBeenAdded}
	HasTabBeenAdded = true

	local TabLayout = Instance.new('UIListLayout')
	local TabFrame = Instance.new('ScrollingFrame')
	local TabButton = Instance.new('TextButton')
	local TabButtonGradient = Instance.new('Frame')
	local TabButtonText = Instance.new('TextLabel')

	TabFrame.Name = 'TabFrame'
	TabFrame.Parent = Holder
	TabFrame.Active = true
	TabFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TabFrame.BackgroundTransparency = 1.000
	TabFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	TabFrame.BorderSizePixel = 0
	TabFrame.Size = UDim2.new(1, 0, 1, 0)
	TabFrame.BottomImage = ''
	TabFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	TabFrame.MidImage = ''
	TabFrame.ScrollBarThickness = 0
	TabFrame.TopImage = ''
	TabFrame.Visible = false

	TabLayout.Name = 'TabLayout'
	TabLayout.Parent = TabFrame
	TabLayout.FillDirection = Enum.FillDirection.Horizontal
	TabLayout.SortOrder = Enum.SortOrder.LayoutOrder

	TabButton.Name = 'TabButton'
	TabButton.Parent = TabButtonsHolder
	TabButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	TabButton.BorderColor3 = Color3.fromRGB(30, 30, 30)
	TabButton.Size = UDim2.new(1, 0, 0, 30)
	TabButton.AutoButtonColor = false
	TabButton.Font = Enum.Font.Code
	TabButton.Text = ''
	TabButton.TextColor3 = Color3.fromRGB(150, 150, 150)
	TabButton.TextSize = 16.000
	Roundify(TabButton)
	Border(TabButton)

	TabButtonGradient.Name = 'TabButtonGradient'
	TabButtonGradient.Parent = TabButton
	TabButtonGradient.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	TabButtonGradient.BackgroundTransparency = 1.000
	TabButtonGradient.BorderColor3 = Color3.fromRGB(255, 255, 255)
	TabButtonGradient.Size = UDim2.new(1, 0, 1, 0)
	TabButtonGradient.ZIndex = 0
	Roundify(TabButtonGradient)
	Border(TabButtonGradient).Color = Color3.new(1, 1, 1)
	TabButtonGradient.UIStroke.Transparency = 1
	Gradient(TabButtonGradient.UIStroke)
	Glow(TabButtonGradient).ImageTransparency = 1
	Gradient(TabButtonGradient)

	TabButtonText.Name = 'TabButtonText'
	TabButtonText.Parent = TabButton
	TabButtonText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TabButtonText.BackgroundTransparency = 1.000
	TabButtonText.BorderColor3 = Color3.fromRGB(0, 0, 0)
	TabButtonText.BorderSizePixel = 0
	TabButtonText.Size = UDim2.new(1, 0, 1, 0)
	TabButtonText.Font = Enum.Font.Code
	TabButtonText.Text = Text
	TabButtonText.TextColor3 = Color3.fromRGB(150, 150, 150)
	TabButtonText.TextSize = 16.000

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
				SectionSize = SectionSize + Section.SectionTitle.AbsoluteSize.Y + 15
				Section.Size = UDim2.new(1, 0, 0, SectionSize)
				ColumnSize = ColumnSize + SectionSize + Column.ColumnLayout.Padding.Offset
			end
			Column.Size = UDim2.new(0, ColumnWidth, 0, ColumnSize)
			if ColumnSize > BiggestColumn then
				BiggestColumn = ColumnSize
			end
		end
		TabFrame.Size = UDim2.new(0, ColumnWidth * (#TabFrame:GetChildren() - 1), 1, 0)
		TabFrame.CanvasSize = UDim2.new(0, 0, 0, BiggestColumn)
		if Library.selectedtab == Tab then
			if Library.open then
				BTween(Mainframe, Library.fullloaded and 0.3 or 0, {Size = UDim2.new(0, TabFrame.AbsoluteSize.X + 30, 1, 0)})
			else
				BTween(Mainframe, Library.fullloaded and 0.3 or 0, {Size = UDim2.new(0, TabFrame.AbsoluteSize.X + 30, 1, 0), Position = UDim2.new(0, -(TabFrame.AbsoluteSize.X + 60), 0, 0)})
			end
		end
	end

	function Tab:Select()
		if SelectedTabPage ~= TabFrame then
			if SelectedTabPage then SelectedTabPage.Visible = false end
			TabFrame.Visible = true
			SelectedTabPage = TabFrame
		end
		if SelectedTabButton ~= TabButton then
			if SelectedTabButton then
				QTween(SelectedTabButton.TabButtonGradient, 0.3, {BackgroundTransparency = 1})
				QTween(SelectedTabButton.TabButtonGradient.Glow, 0.3, {ImageTransparency = 1})
				QTween(SelectedTabButton.TabButtonGradient.UIStroke, 0.3, {Transparency = 1})
			end
			QTween(TabButtonGradient, 0.3, {BackgroundTransparency = 0})
			QTween(TabButtonGradient.Glow, 0.3, {ImageTransparency = 0})
			QTween(TabButtonGradient.UIStroke, 0.3, {Transparency = 0})
			SelectedTabButton = TabButton
		end
		if Library.popup then Library.popup:Close() end
		Library.selectedtab = Tab
		Update()
	end

	TabButton.MouseEnter:Connect(function()
		if Library.warning then return end
		QTween(TabButton, 0.3, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)})
		QTween(TabButtonGradient, 0.3, {BackgroundColor3 = Color3.new(1, 1, 1)})
		QTween(TabButtonText, 0.3, {TextColor3 = Color3.new(1, 1, 1)})
	end)

	TabButton.MouseLeave:Connect(function()
		QTween(TabButton, 0.3, {BackgroundColor3 = Color3.fromRGB(20, 20, 20)})
		QTween(TabButtonGradient, 0.3, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)})
		QTween(TabButtonText, 0.3, {TextColor3 = Color3.fromRGB(150, 150, 150)})
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
				ColCount += 1

				local ColumnFrame = Instance.new('Frame')
				local ColumnLayout = Instance.new('UIListLayout')
				local ColumnPadding = Instance.new('UIPadding')

				ColumnFrame.Name = 'Column'
				ColumnFrame.Parent = TabFrame
				ColumnFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				ColumnFrame.BackgroundTransparency = 1.000
				ColumnFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
				ColumnFrame.BorderSizePixel = 0
				ColumnFrame.Size = UDim2.new(0, ColumnWidth, 1, 0)
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
		Section.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
		Section.BorderColor3 = Color3.fromRGB(30, 30, 30)
		Section.Size = UDim2.new(1, 0, 0, 200)
		Roundify(Section)
		Border(Section)

		SectionTitle.Name = 'SectionTitle'
		SectionTitle.Parent = Section
		SectionTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		SectionTitle.BackgroundTransparency = 1.000
		SectionTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
		SectionTitle.BorderSizePixel = 0
		SectionTitle.Size = UDim2.new(1, 0, 0, 20)
		SectionTitle.Font = Enum.Font.Code
		SectionTitle.RichText = true
		SectionTitle.Text = '<b>' .. Options.text .. '</b>'
		SectionTitle.TextColor3 = Color3.fromRGB(150, 150, 150)
		SectionTitle.TextSize = 16.000

		SectionHolder.Name = 'SectionHolder'
		SectionHolder.Parent = Section
		SectionHolder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		SectionHolder.BackgroundTransparency = 1.000
		SectionHolder.BorderColor3 = Color3.fromRGB(0, 0, 0)
		SectionHolder.BorderSizePixel = 0
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
			Button.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
			Button.BorderColor3 = Color3.fromRGB(30, 30, 30)
			Button.Size = UDim2.new(1, 0, 0, GetTextSize(Options.text, 16, Enum.Font.Code).Y + 9)
			Button.AutoButtonColor = false
			Button.Font = Enum.Font.Code
			Button.Text = ' ' .. Options.text:gsub('\n', '\n ')
			Button.TextColor3 = Color3.fromRGB(150, 150, 150)
			Button.TextSize = 16.000
			Button.TextXAlignment = Enum.TextXAlignment.Left
			Roundify(Button)
			Border(Button)

			ButtonGradient.Name = 'ButtonGradient'
			ButtonGradient.Parent = Button
			ButtonGradient.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ButtonGradient.BackgroundTransparency = 1.000
			ButtonGradient.BorderColor3 = Color3.fromRGB(0, 0, 0)
			ButtonGradient.BorderSizePixel = 0
			ButtonGradient.Size = UDim2.new(1, 0, 1, 0)
			Roundify(ButtonGradient)
			Border(ButtonGradient).Color = Color3.new(1, 1, 1)
			ButtonGradient.UIStroke.Transparency = 1
			Gradient(ButtonGradient.UIStroke)
			Glow(ButtonGradient).ImageTransparency = 1

			Button.MouseEnter:Connect(function()
				if TabsDisplayed or Library.warning or (Library.popup and Library.popup.hovering) then return end
				QTween(Button, 0.3, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)})
			end)

			Button.MouseLeave:Connect(function()
				QTween(Button, 0.3, {BackgroundColor3 = Color3.fromRGB(20, 20, 20)})
				QTween(ButtonGradient.UIStroke, 0.3, {Transparency = 1})
				QTween(ButtonGradient.Glow, 0.3, {ImageTransparency = 1})
			end)

			Button.MouseButton1Down:Connect(function()
				if TabsDisplayed or Library.warning or (Library.popup and Library.popup.hovering) then return end
				QTween(ButtonGradient.UIStroke, 0.3, {Transparency = 0})
				QTween(ButtonGradient.Glow, 0.3, {ImageTransparency = 0})
			end)

			Button.MouseButton1Up:Connect(function()
				QTween(ButtonGradient.UIStroke, 0.3, {Transparency = 1})
				QTween(ButtonGradient.Glow, 0.3, {ImageTransparency = 1})
			end)

			Button.MouseButton1Click:Connect(function()
				if TabsDisplayed or Library.warning or (Library.popup and Library.popup.hovering) then return end

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

				task.delay(0.5, function()
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
			Label.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Label.BorderSizePixel = 0
			Label.Size = UDim2.new(0, 200, 0, 50)
			Label.Font = Enum.Font.Code
			Label.TextColor3 = Color3.fromRGB(150, 150, 150)
			Label.TextSize = 18.000
			Label.RichText = true

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
			Divider.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
			Divider.BorderSizePixel = 0
			Divider.Size = UDim2.new(1, SectionPadding.PaddingLeft.Offset + SectionPadding.PaddingRight.Offset, 0, 1)
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
			Toggle.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Toggle.BorderSizePixel = 0
			Toggle.Size = UDim2.new(1, 0, 0, 26)
			Toggle.Font = Enum.Font.SourceSans
			Toggle.Text = ''
			Toggle.TextColor3 = Color3.fromRGB(0, 0, 0)
			Toggle.TextSize = 14.000

			ToggleText.Name = 'ToggleText'
			ToggleText.Parent = Toggle
			ToggleText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ToggleText.BackgroundTransparency = 1.000
			ToggleText.BorderColor3 = Color3.fromRGB(0, 0, 0)
			ToggleText.BorderSizePixel = 0
			ToggleText.Size = UDim2.new(1, 0, 1, 0)
			ToggleText.Font = Enum.Font.Code
			ToggleText.Text = Options.text
			ToggleText.TextColor3 = Color3.fromRGB(150, 150, 150)
			ToggleText.TextSize = 16.000
			ToggleText.TextXAlignment = Enum.TextXAlignment.Left

			ToggleHolder.Name = 'ToggleHolder'
			ToggleHolder.Parent = Toggle
			ToggleHolder.AnchorPoint = Vector2.new(1, 0)
			ToggleHolder.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
			ToggleHolder.BorderColor3 = Color3.fromRGB(30, 30, 30)
			ToggleHolder.Position = UDim2.new(1, 0, 0, 0)
			ToggleHolder.Size = UDim2.new(0, 55, 0, 26)
			Roundify(ToggleHolder)
			Border(ToggleHolder)

			ToggleBox.Name = 'ToggleBox'
			ToggleBox.Parent = ToggleHolder
			ToggleBox.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
			ToggleBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
			ToggleBox.BorderSizePixel = 0
			ToggleBox.Position = UDim2.new(0, 2, 0, 2)
			ToggleBox.Size = UDim2.new(0, 22, 0, 22)
			Roundify(ToggleBox)

			BoxFiller.Name = 'BoxFiller'
			BoxFiller.Parent = ToggleBox
			BoxFiller.AnchorPoint = Vector2.new(0.5, 0.5)
			BoxFiller.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
			BoxFiller.BorderColor3 = Color3.fromRGB(0, 0, 0)
			BoxFiller.BorderSizePixel = 0
			BoxFiller.Position = UDim2.new(0.5, 0, 0.5, 0)
			BoxFiller.Size = UDim2.new(1, -8, 1, -8)
			Roundify(BoxFiller)

			FillerGradient.Name = 'FillerGradient'
			FillerGradient.Parent = BoxFiller
			FillerGradient.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			FillerGradient.BackgroundTransparency = 1.000
			FillerGradient.BorderColor3 = Color3.fromRGB(0, 0, 0)
			FillerGradient.BorderSizePixel = 0
			FillerGradient.Size = UDim2.new(1, 0, 1, 0)
			Roundify(FillerGradient)
			Gradient(FillerGradient)

			ToggleGradient.Name = 'ToggleGradient'
			ToggleGradient.Parent = ToggleHolder
			ToggleGradient.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
			ToggleGradient.BackgroundTransparency = 1.000
			ToggleGradient.BorderColor3 = Color3.fromRGB(0, 0, 0)
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
				if TabsDisplayed or Library.warning or (Library.popup and Library.popup.hovering) then return end
				QTween(ToggleGradient, 0.3, {BackgroundColor3 = Color3.new(1, 1, 1)})
				QTween(ToggleHolder, 0.3, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)})
				QTween(BoxFiller, 0.3, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)})
			end)

			Toggle.MouseLeave:Connect(function()
				QTween(ToggleGradient, 0.3, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)})
				QTween(ToggleHolder, 0.3, {BackgroundColor3 = Color3.fromRGB(20, 20, 20)})
				QTween(BoxFiller, 0.3, {BackgroundColor3 = Color3.fromRGB(20, 20, 20)})
				if not Options.state then
					QTween(ToggleBox, 0.3, {BackgroundColor3 = Color3.fromRGB(25, 25, 25)})
				end
			end)

			Toggle.MouseButton1Down:Connect(function()
				if TabsDisplayed or Library.warning or (Library.popup and Library.popup.hovering) then return end
				QTween(ToggleGradient, 0.3, {BackgroundColor3 = Color3.fromRGB(150, 150, 150)})
				QTween(ToggleHolder, 0.3, {BackgroundColor3 = Color3.fromRGB(25, 25, 25)})
				QTween(BoxFiller, 0.3, {BackgroundColor3 = Color3.fromRGB(25, 25, 25)})
				if not Options.state then
					QTween(ToggleBox, 0.3, {BackgroundColor3 = Color3.fromRGB(20, 20, 20)})
				end
			end)

			Toggle.MouseButton1Up:Connect(function()
				if TabsDisplayed or Library.warning or (Library.popup and Library.popup.hovering) then return end
				QTween(ToggleGradient, 0.3, {BackgroundColor3 = Color3.new(1, 1, 1)})
				QTween(ToggleHolder, 0.3, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)})
				QTween(BoxFiller, 0.3, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)})
				if not Options.state then
					QTween(ToggleBox, 0.3, {BackgroundColor3 = Color3.fromRGB(25, 25, 25)})
				end
			end)

			Toggle.MouseButton1Click:Connect(function()
				if TabsDisplayed or Library.warning or (Library.popup and Library.popup.hovering) then return end
				Options:SetState(not Options.state)
			end)

			function Options:SetState(state)
				state = typeof(state) == 'boolean' and state or false
				Library.flags[Options.flag] = state
				Options.state = state
				if Options.state then
					QTween(ToggleGradient, 0.3, {BackgroundTransparency = 0})
					QTween(ToggleBox, 0.3, {Position = UDim2.new(0, 31, 0, 2), BackgroundColor3 = Color3.new(1, 1, 1)})
					QTween(BoxFiller, 0.3, {Size = UDim2.new(0, 0, 0, 0)})
					QTween(ToggleGradient.UIStroke, 0.3, {Transparency = 0})
					QTween(ToggleGradient.Glow, 0.3, {ImageTransparency = 0})
					QTween(FillerGradient, 0.3, {BackgroundTransparency = 0})
				else
					QTween(ToggleGradient, 0.3, {BackgroundTransparency = 1})
					QTween(ToggleBox, 0.3, {Position = UDim2.new(0, 2, 0, 2), BackgroundColor3 = Color3.fromRGB(25, 25, 25)})
					QTween(BoxFiller, 0.3, {Size = UDim2.new(1, -8, 1, -8)})
					QTween(ToggleGradient.UIStroke, 0.3, {Transparency = 1})
					QTween(ToggleGradient.Glow, 0.3, {ImageTransparency = 1})
					QTween(FillerGradient, 0.3, {BackgroundTransparency = 1})
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
			Bind.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Bind.BorderSizePixel = 0
			Bind.Size = UDim2.new(1, 0, 0, 25)
			Bind.Font = Enum.Font.SourceSans
			Bind.Text = ''
			Bind.TextColor3 = Color3.fromRGB(0, 0, 0)
			Bind.TextSize = 14.000

			BindText.Name = 'BindText'
			BindText.Parent = Bind
			BindText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			BindText.BackgroundTransparency = 1.000
			BindText.BorderColor3 = Color3.fromRGB(0, 0, 0)
			BindText.BorderSizePixel = 0
			BindText.Size = UDim2.new(1, 0, 1, 0)
			BindText.Font = Enum.Font.Code
			BindText.Text = Options.text
			BindText.TextColor3 = Color3.fromRGB(150, 150, 150)
			BindText.TextSize = 16.000
			BindText.TextXAlignment = Enum.TextXAlignment.Left

			BindHolder.Name = 'BindHolder'
			BindHolder.Parent = Bind
			BindHolder.AnchorPoint = Vector2.new(1, 0)
			BindHolder.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
			BindHolder.BorderColor3 = Color3.fromRGB(30, 30, 30)
			BindHolder.Position = UDim2.new(1, 0, 0, 0)
			BindHolder.Size = UDim2.new(0, 76, 1, 0)
			Roundify(BindHolder)
			Border(BindHolder)

			KeyText.Name = 'KeyText'
			KeyText.Parent = BindHolder
			KeyText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			KeyText.BackgroundTransparency = 1.000
			KeyText.BorderColor3 = Color3.fromRGB(0, 0, 0)
			KeyText.BorderSizePixel = 0
			KeyText.Size = UDim2.new(1, 0, 1, 0)
			KeyText.Font = Enum.Font.Code
			KeyText.Text = 'KeyName'
			KeyText.TextColor3 = Color3.fromRGB(150, 150, 150)
			KeyText.TextSize = 16.000

			BindGradient.Name = 'BindGradient'
			BindGradient.Parent = BindHolder
			BindGradient.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			BindGradient.BackgroundTransparency = 1.000
			BindGradient.BorderColor3 = Color3.fromRGB(0, 0, 0)
			BindGradient.BorderSizePixel = 0
			BindGradient.Size = UDim2.new(1, 0, 1, 0)
			BindGradient.ZIndex = 0
			Roundify(BindGradient)
			Border(BindGradient).Color = Color3.new(1, 1, 1)
			BindGradient.UIStroke.Transparency = 1
			Gradient(BindGradient.UIStroke)
			Glow(BindGradient).ImageTransparency = 1
			Gradient(BindGradient)

			KeyText:GetPropertyChangedSignal('Text'):Connect(function()
				QTween(BindHolder, 0.3, {Size = UDim2.new(0, GetTextSize(KeyText.Text, KeyText.TextSize, KeyText.Font).X + 10, 1, 0)})
			end)

			local Binding
			local Loop
			local Pressed

			Bind.MouseEnter:Connect(function()
				if TabsDisplayed or Library.warning or (Library.popup and Library.popup.hovering) then return end
				QTween(BindHolder, 0.3, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)})
			end)

			Bind.MouseLeave:Connect(function()
				QTween(BindHolder, 0.3, {BackgroundColor3 = Color3.fromRGB(20, 20, 20)})
			end)

			Bind.MouseButton1Down:Connect(function()
				if TabsDisplayed or Library.warning or (Library.popup and Library.popup.hovering) then return end
				QTween(BindHolder, 0.3, {BackgroundColor3 = Color3.fromRGB(25, 25, 25)})
			end)

			Bind.MouseButton1Up:Connect(function()
				if TabsDisplayed or Library.warning or (Library.popup and Library.popup.hovering) then return end
				QTween(BindHolder, 0.3, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)})
			end)

			Bind.MouseButton1Click:Connect(function()
				if TabsDisplayed or Library.warning or (Library.popup and Library.popup.hovering) then return end
				Binding = true
				KeyText.Text = '[...]'
				QTween(BindGradient, 0.3, {BackgroundTransparency = 0})
				QTween(BindGradient.UIStroke, 0.3, {Transparency = 0})
				QTween(BindGradient.Glow, 0.3, {ImageTransparency = 0})
				QTween(KeyText, 0.3, {TextColor3 = Color3.new(1, 1, 1)})
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
				QTween(BindGradient, 0.3, {BackgroundTransparency = 1})
				QTween(BindGradient.UIStroke, 0.3, {Transparency = 1})
				QTween(BindGradient.Glow, 0.3, {ImageTransparency = 1})
				QTween(KeyText, 0.3, {TextColor3 = Color3.fromRGB(150, 150, 150)})
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
			Slider.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Slider.BorderSizePixel = 0
			Slider.Size = UDim2.new(1, 0, 0, 30)
			Slider.Font = Enum.Font.SourceSans
			Slider.Text = ''
			Slider.TextColor3 = Color3.fromRGB(0, 0, 0)
			Slider.TextSize = 14.000

			SliderText.Name = 'SliderText'
			SliderText.Parent = Slider
			SliderText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			SliderText.BackgroundTransparency = 1.000
			SliderText.BorderColor3 = Color3.fromRGB(0, 0, 0)
			SliderText.BorderSizePixel = 0
			SliderText.Size = UDim2.new(1, 0, 0, 20)
			SliderText.Font = Enum.Font.Code
			SliderText.Text = Options.text
			SliderText.TextColor3 = Color3.fromRGB(150, 150, 150)
			SliderText.TextSize = 16.000
			SliderText.TextXAlignment = Enum.TextXAlignment.Left

			ValueBox.Name = 'ValueBox'
			ValueBox.Parent = Slider
			ValueBox.AnchorPoint = Vector2.new(1, 0)
			ValueBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
			ValueBox.BorderColor3 = Color3.fromRGB(30, 30, 30)
			ValueBox.Position = UDim2.new(1, 0, 0, 0)
			ValueBox.Size = UDim2.new(0, 50, 0, 20)
			ValueBox.Font = Enum.Font.Code
			ValueBox.PlaceholderColor3 = Color3.fromRGB(80, 80, 80)
			ValueBox.PlaceholderText = '[Value]'
			ValueBox.Text = ''
			ValueBox.TextColor3 = Color3.fromRGB(150, 150, 150)
			ValueBox.TextSize = 16.000
			Roundify(ValueBox)
			Border(ValueBox)

			ValueBoxGradient.Name = 'ValueBoxGradient'
			ValueBoxGradient.Parent = ValueBox
			ValueBoxGradient.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ValueBoxGradient.BackgroundTransparency = 1.000
			ValueBoxGradient.BorderColor3 = Color3.fromRGB(0, 0, 0)
			ValueBoxGradient.BorderSizePixel = 0
			ValueBoxGradient.Size = UDim2.new(1, 0, 1, 0)
			Roundify(ValueBoxGradient)
			Border(ValueBoxGradient).Color = Color3.new(1, 1, 1)
			ValueBoxGradient.UIStroke.Transparency = 1
			Gradient(ValueBoxGradient.UIStroke)
			Glow(ValueBoxGradient).ImageTransparency = 1

			SliderHolder.Name = 'SliderHolder'
			SliderHolder.Parent = Slider
			SliderHolder.AnchorPoint = Vector2.new(0, 1)
			SliderHolder.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
			SliderHolder.BorderColor3 = Color3.fromRGB(30, 30, 30)
			SliderHolder.Position = UDim2.new(0, 0, 1, 0)
			SliderHolder.Size = UDim2.new(1, 0, 0, 6)
			Roundify(SliderHolder)
			Border(SliderHolder)

			Bar.Name = 'Bar'
			Bar.Parent = SliderHolder
			Bar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Bar.BackgroundTransparency = 1.000
			Bar.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Bar.BorderSizePixel = 0
			Bar.ClipsDescendants = true
			Bar.Size = UDim2.new(0.4, 0, 1, 0)

			BarColor.Name = 'BarColor'
			BarColor.Parent = Bar
			BarColor.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
			BarColor.BorderColor3 = Color3.fromRGB(0, 0, 0)
			BarColor.BorderSizePixel = 0
			BarColor.Size = UDim2.new(0, 202, 1, 0)
			Roundify(BarColor)

			BarGradient.Name = 'BarGradient'
			BarGradient.Parent = BarColor
			BarGradient.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			BarGradient.BackgroundTransparency = 1.000
			BarGradient.BorderColor3 = Color3.fromRGB(0, 0, 0)
			BarGradient.BorderSizePixel = 0
			BarGradient.Size = UDim2.new(1, 0, 1, 0)
			Roundify(BarGradient)
			Gradient(BarGradient)

			CircleHolder.Name = 'CircleHolder'
			CircleHolder.Parent = SliderHolder
			CircleHolder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			CircleHolder.BackgroundTransparency = 1.000
			CircleHolder.BorderColor3 = Color3.fromRGB(0, 0, 0)
			CircleHolder.BorderSizePixel = 0
			CircleHolder.Position = UDim2.new(0.4, -1, 0.5, 0)

			Circle.Name = 'Circle'
			Circle.Parent = CircleHolder
			Circle.AnchorPoint = Vector2.new(0.5, 0.5)
			Circle.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
			Circle.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Circle.BorderSizePixel = 0
			Circle.Size = UDim2.new(0, 4, 0, 4)
			Roundify(Circle).CornerRadius = UDim.new(1, 0)

			CircleGradient.Name = 'CircleGradient'
			CircleGradient.Parent = Circle
			CircleGradient.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			CircleGradient.BackgroundTransparency = 1.000
			CircleGradient.BorderColor3 = Color3.fromRGB(0, 0, 0)
			CircleGradient.BorderSizePixel = 0
			CircleGradient.Size = UDim2.new(1, 0, 1, 0)
			Roundify(CircleGradient).CornerRadius = UDim.new(1, 0)
			Gradient(CircleGradient)

			ValueBox:GetPropertyChangedSignal('Text'):Connect(function()
				if ValueBox.Text == '' then
					STween(ValueBox, 0.1, {Size = UDim2.new(0, GetTextSize('[Value]', ValueBox.TextSize, ValueBox.Font).X + 10, 0, 20)})
				else
					STween(ValueBox, 0.1, {Size = UDim2.new(0, GetTextSize(ValueBox.Text, ValueBox.TextSize, ValueBox.Font).X + 10, 0, 20)})
				end
			end)

			local Sliding
			local InContact

			Slider.MouseEnter:Connect(function()
				InContact = true
				if TabsDisplayed or Library.warning or (Library.popup and Library.popup.hovering) then return end
				if Sliding then return end
				QTween(BarColor, 0.3, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)})
				QTween(Circle, 0.3, {BackgroundColor3 = Color3.fromRGB(30, 30, 30), Size = UDim2.new(0, 10, 0, 10)})
			end)

			Slider.MouseLeave:Connect(function()
				InContact = false
				if Sliding then return end
				QTween(BarColor, 0.3, {BackgroundColor3 = Color3.fromRGB(25, 25, 25)})
				QTween(Circle, 0.3, {BackgroundColor3 = Color3.fromRGB(25, 25, 25), Size = UDim2.new(0, 0, 0, 0)})
			end)

			Slider.InputBegan:Connect(function(input)
				if TabsDisplayed or Library.warning or (Library.popup and Library.popup.hovering) then return end
				if input.UserInputType == InputTypes.MouseButton1 then
					QTween(BarGradient, 0.3, {BackgroundTransparency = 0})
					QTween(Circle, 0.3, {Size = UDim2.new(0, 12, 0, 12)})
					QTween(CircleGradient, 0.3, {BackgroundTransparency = 0})
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
					QTween(CircleGradient, 0.3, {BackgroundTransparency = 1})
					QTween(BarGradient, 0.3, {BackgroundTransparency = 1})
					if InContact then
						QTween(BarColor, 0.3, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)})
						QTween(Circle, 0.3, {BackgroundColor3 = Color3.fromRGB(30, 30, 30), Size = UDim2.new(0, 10, 0, 10)})
					else
						QTween(BarColor, 0.3, {BackgroundColor3 = Color3.fromRGB(25, 25, 25)})
						QTween(Circle, 0.3, {BackgroundColor3 = Color3.fromRGB(25, 25, 25), Size = UDim2.new(0, 0, 0, 0)})
					end
				end
			end)

			local Hover
			local Typing

			ValueBox.MouseEnter:Connect(function()
				Hover = true
				if TabsDisplayed or Library.warning or (Library.popup and Library.popup.hovering) then return end
				if Typing then return end
				QTween(ValueBox, 0.3, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)})
			end)

			ValueBox.MouseLeave:Connect(function()
				Hover = false
				if Typing then return end
				QTween(ValueBox, 0.3, {BackgroundColor3 = Color3.fromRGB(20, 20, 20)})
			end)

			ValueBox.Focused:Connect(function()
				Typing = true
				QTween(ValueBoxGradient.UIStroke, 0.3, {Transparency = 0})
				QTween(ValueBoxGradient.Glow, 0.3, {ImageTransparency = 0})
			end)

			ValueBox.FocusLost:Connect(function()
				Typing = false
				QTween(ValueBoxGradient.UIStroke, 0.3, {Transparency = 1})
				QTween(ValueBoxGradient.Glow, 0.3, {ImageTransparency = 1})
				if Hover then
					QTween(ValueBox, 0.3, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)})
				else
					QTween(ValueBox, 0.3, {BackgroundColor3 = Color3.fromRGB(20, 20, 20)})
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
			List.BorderColor3 = Color3.fromRGB(0, 0, 0)
			List.BorderSizePixel = 0
			List.Size = UDim2.new(1, 0, 0, 30)
			List.Font = Enum.Font.SourceSans
			List.Text = ''
			List.TextColor3 = Color3.fromRGB(0, 0, 0)
			List.TextSize = 14.000

			ListText.Name = 'ListText'
			ListText.Parent = List
			ListText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ListText.BackgroundTransparency = 1.000
			ListText.BorderColor3 = Color3.fromRGB(0, 0, 0)
			ListText.BorderSizePixel = 0
			ListText.Size = UDim2.new(1, 0, 1, 0)
			ListText.Font = Enum.Font.Code
			ListText.Text = Options.text
			ListText.TextColor3 = Color3.fromRGB(150, 150, 150)
			ListText.TextSize = 16.000
			ListText.TextXAlignment = Enum.TextXAlignment.Left
			ListText.TextYAlignment = Enum.TextYAlignment.Top

			ChoicesText.Name = 'ChoicesText'
			ChoicesText.Parent = List
			ChoicesText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ChoicesText.BackgroundTransparency = 1.000
			ChoicesText.BorderColor3 = Color3.fromRGB(0, 0, 0)
			ChoicesText.BorderSizePixel = 0
			ChoicesText.Position = UDim2.new(0, 0, 0, 15)
			ChoicesText.Size = UDim2.new(1, -30, 0, 15)
			ChoicesText.Font = Enum.Font.Code
			ChoicesText.Text = 'TEMP'
			ChoicesText.TextColor3 = Color3.fromRGB(150, 150, 150)
			ChoicesText.TextSize = 12.000
			ChoicesText.TextXAlignment = Enum.TextXAlignment.Left

			OpenButton.Name = 'OpenButton'
			OpenButton.Parent = List
			OpenButton.AnchorPoint = Vector2.new(1, 0)
			OpenButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
			OpenButton.BorderColor3 = Color3.fromRGB(30, 30, 30)
			OpenButton.Position = UDim2.new(1, 0, 0, 0)
			OpenButton.Size = UDim2.new(0, 30, 0, 30)
			Roundify(OpenButton)
			Border(OpenButton)

			OpenIcon.Name = 'OpenIcon'
			OpenIcon.Parent = OpenButton
			OpenIcon.AnchorPoint = Vector2.new(0.5, 0.5)
			OpenIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			OpenIcon.BackgroundTransparency = 1.000
			OpenIcon.BorderColor3 = Color3.fromRGB(0, 0, 0)
			OpenIcon.BorderSizePixel = 0
			OpenIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
			OpenIcon.Size = UDim2.new(1, -4, 1, -4)
			OpenIcon.Image = 'rbxassetid://11421095840'
			OpenIcon.ImageColor3 = Color3.fromRGB(150, 150, 150)

			OpenButtonGradient.Name = 'OpenButtonGradient'
			OpenButtonGradient.Parent = OpenButton
			OpenButtonGradient.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
			OpenButtonGradient.BackgroundTransparency = 1.000
			OpenButtonGradient.BorderColor3 = Color3.fromRGB(0, 0, 0)
			OpenButtonGradient.BorderSizePixel = 0
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
			ItemsInvis.BorderColor3 = Color3.fromRGB(0, 0, 0)
			ItemsInvis.BorderSizePixel = 0
			ItemsInvis.Position = UDim2.new(0, 280, 0, 40)
			ItemsInvis.Size = UDim2.new(0, List.AbsoluteSize.X, 0, 200)
			ItemsInvis.ZIndex = 2
			ItemsInvis.Visible = false

			ItemsHolder.Name = 'ItemsHolder'
			ItemsHolder.Parent = ItemsInvis
			ItemsHolder.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
			ItemsHolder.BorderColor3 = Color3.fromRGB(30, 30, 30)
			ItemsHolder.Size = UDim2.new(1, 0, 0, 0)
			Roundify(ItemsHolder)
			Border(ItemsHolder).Transparency = 1

			ItemsList.Name = 'ItemsList'
			ItemsList.Parent = ItemsHolder
			ItemsList.Active = true
			ItemsList.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ItemsList.BackgroundTransparency = 1.000
			ItemsList.BorderColor3 = Color3.fromRGB(0, 0, 0)
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
			ItemsListLayout.CellSize = UDim2.new(1, 0, 0, 20)

			ItemsListPadding.Name = 'ItemsListPadding'
			ItemsListPadding.Parent = ItemsList
			ItemsListPadding.PaddingBottom = UDim.new(0, 5)
			ItemsListPadding.PaddingTop = UDim.new(0, 5)

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

			local ListHovering = false
			List.MouseEnter:Connect(function()
				if TabsDisplayed or Library.warning or (Library.popup and Library.popup.hovering) then return end
				ListHovering = true
				QTween(OpenButton, 0.3, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)})
				QTween(OpenIcon, 0.3, {ImageColor3 = Color3.new(1, 1, 1)})
				QTween(OpenButtonGradient, 0.3, {BackgroundColor3 = Color3.new(1, 1, 1)})
			end)

			List.MouseLeave:Connect(function()
				ListHovering = false
				QTween(OpenButton, 0.3, {BackgroundColor3 = Color3.fromRGB(20, 20, 20)})
				QTween(OpenButtonGradient, 0.3, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)})
				if Options.open then return end
				QTween(OpenIcon, 0.3, {ImageColor3 = Color3.fromRGB(150, 150, 150)})
			end)

			List.MouseButton1Down:Connect(function()
				if TabsDisplayed or Library.warning or (Library.popup and Library.popup.hovering) then return end
				QTween(OpenButton, 0.3, {BackgroundColor3 = Color3.fromRGB(25, 25, 25)})
			end)

			List.MouseButton1Up:Connect(function()
				if TabsDisplayed or Library.warning or (Library.popup and Library.popup.hovering) then return end
				QTween(OpenButton, 0.3, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)})
				QTween(OpenButtonGradient, 0.3, {BackgroundColor3 = Color3.new(1, 1, 1)})
			end)

			List.MouseButton1Click:Connect(function()
				if Library.warning then return end
				if TabsDisplayed then return end
				if Library.popup and Library.popup ~= Options and Library.popup.hovering then return end
				if Library.popup == Options then Library.popup:Close(); return end
				if Library.popup and Library.popup.hovering == false then Library.popup:Close() end
				QTween(OpenIcon, 0.3, {Rotation = 180})
				QTween(OpenButtonGradient, 0.3, {BackgroundTransparency = 0})
				QTween(OpenButtonGradient.Glow, 0.3, {ImageTransparency = 0})
				QTween(OpenButtonGradient.UIStroke, 0.3, {Transparency = 0})
				QTween(ItemsList, 0.3, {ScrollBarImageTransparency = 0})
				QTween(ItemsHolder, 0.3, {Size = UDim2.new(1, 0, 1, 0)})
				QTween(ItemsHolder.UIStroke, 0.3, {Transparency = 0})
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
				local ItemTextGradient = Instance.new('TextLabel')

				Item.Name = 'Item'
				Item.Parent = ItemsList
				Item.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Item.BackgroundTransparency = 1.000
				Item.BorderColor3 = Color3.fromRGB(0, 0, 0)
				Item.BorderSizePixel = 0
				Item.Size = UDim2.new(0, 200, 0, 50)
				Item.Font = Enum.Font.SourceSans
				Item.Text = ''
				Item.TextColor3 = Color3.fromRGB(0, 0, 0)
				Item.TextSize = 14.000

				ItemText.Name = 'ItemText'
				ItemText.Parent = Item
				ItemText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				ItemText.BackgroundTransparency = 1.000
				ItemText.BorderColor3 = Color3.fromRGB(0, 0, 0)
				ItemText.BorderSizePixel = 0
				ItemText.Position = UDim2.new(0, 5, 0, 0)
				ItemText.Size = UDim2.new(1, -15, 1, 0)
				ItemText.Font = Enum.Font.Code
				ItemText.Text = value
				ItemText.TextColor3 = Color3.fromRGB(150, 150, 150)
				ItemText.TextSize = 16.000
				ItemText.TextXAlignment = Enum.TextXAlignment.Left

				ItemTextGradient.Name = 'ItemTextGradient'
				ItemTextGradient.Parent = ItemText
				ItemTextGradient.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				ItemTextGradient.BackgroundTransparency = 1.000
				ItemTextGradient.BorderColor3 = Color3.fromRGB(0, 0, 0)
				ItemTextGradient.BorderSizePixel = 0
				ItemTextGradient.Size = UDim2.new(0, 72, 1, 0)
				ItemTextGradient.Font = Enum.Font.Code
				ItemTextGradient.Text = value
				ItemTextGradient.TextColor3 = Color3.fromRGB(255, 255, 255)
				ItemTextGradient.TextSize = 16.000
				ItemTextGradient.TextTransparency = 1.000
				ItemTextGradient.TextXAlignment = Enum.TextXAlignment.Left
				Gradient(ItemTextGradient)

				Options.labels[value] = Item

				selected = selected or Options.value == value and Item

				Item.MouseEnter:Connect(function()
					QTween(ItemText, 0.3, {TextColor3 = Color3.new(1, 1, 1)})
				end)

				Item.MouseLeave:Connect(function()
					QTween(ItemText, 0.3, {TextColor3 = Color3.fromRGB(150, 150, 150)})
				end)

				Item.MouseButton1Down:Connect(function()
					QTween(ItemText, 0.3, {TextColor3 = Color3.fromRGB(200, 200, 200)})
				end)

				Item.MouseButton1Up:Connect(function()
					QTween(ItemText, 0.3, {TextColor3 = Color3.fromRGB(150, 150, 150)})
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
				QTween(OpenIcon, 0.3, {Rotation = 0})
				QTween(OpenButtonGradient, 0.3, {BackgroundTransparency = 1})
				QTween(OpenButtonGradient.Glow, 0.3, {ImageTransparency = 1})
				QTween(OpenButtonGradient.UIStroke, 0.3, {Transparency = 1})
				QTween(ItemsList, 0.3, {ScrollBarImageTransparency = 1})
				QTween(ItemsHolder, 0.3, {Size = UDim2.new(1, 0, 0, 0)})
				QTween(ItemsHolder.UIStroke, 0.3, {Transparency = 1})
				if not ListHovering then
					QTween(OpenIcon, 0.3, {ImageColor3 = Color3.fromRGB(150, 150, 150)})
				end
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
			Box.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
			Box.BorderColor3 = Color3.fromRGB(30, 30, 30)
			Box.Size = UDim2.new(1, 0, 0, 25)
			Box.ClearTextOnFocus = Options.clearonfocus
			Box.Font = Enum.Font.Code
			Box.PlaceholderColor3 = Color3.fromRGB(80, 80, 80)
			Box.PlaceholderText = Options.text
			Box.Text = Options.value
			Box.TextColor3 = Color3.fromRGB(150, 150, 150)
			Box.TextScaled = true
			Box.TextSize = 16.000
			Box.TextWrapped = true
			Roundify(Box)
			Border(Box)

			Constraint.Name = 'Constraint'
			Constraint.Parent = Box
			Constraint.MaxTextSize = 18

			BoxGradient.Name = 'BoxGradient'
			BoxGradient.Parent = Box
			BoxGradient.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			BoxGradient.BackgroundTransparency = 1.000
			BoxGradient.BorderColor3 = Color3.fromRGB(0, 0, 0)
			BoxGradient.BorderSizePixel = 0
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
				if TabsDisplayed or Library.warning or (Library.popup and Library.popup.hovering) then return end
				if Typing then return end
				QTween(Box, 0.3, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)})
			end)

			Box.MouseLeave:Connect(function()
				Hover = false
				if Typing then return end
				QTween(Box, 0.3, {BackgroundColor3 = Color3.fromRGB(20, 20, 20)})
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
					QTween(Box, 0.3, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)})
				else
					QTween(Box, 0.3, {BackgroundColor3 = Color3.fromRGB(20, 20, 20)})
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
			ColorButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
			ColorButton.BorderSizePixel = 0
			ColorButton.Size = UDim2.new(1, 0, 0, 26)
			ColorButton.Font = Enum.Font.SourceSans
			ColorButton.Text = ''
			ColorButton.TextColor3 = Color3.fromRGB(0, 0, 0)
			ColorButton.TextSize = 14.000

			ColorText.Name = 'ColorText'
			ColorText.Parent = ColorButton
			ColorText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ColorText.BackgroundTransparency = 1.000
			ColorText.BorderColor3 = Color3.fromRGB(0, 0, 0)
			ColorText.BorderSizePixel = 0
			ColorText.Size = UDim2.new(1, 0, 1, 0)
			ColorText.Font = Enum.Font.Code
			ColorText.Text = Options.text
			ColorText.TextColor3 = Color3.fromRGB(150, 150, 150)
			ColorText.TextSize = 16.000
			ColorText.TextXAlignment = Enum.TextXAlignment.Left

			Container.Name = 'Container'
			Container.Parent = ColorButton
			Container.AnchorPoint = Vector2.new(1, 0)
			Container.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
			Container.BorderColor3 = Color3.fromRGB(30, 30, 30)
			Container.BorderSizePixel = 0
			Container.Position = UDim2.new(1, 0, 0, 0)
			Container.Size = UDim2.new(0, 30, 1, 0)
			Roundify(Container)
			Border(Container)

			PickerIcon.Name = 'PickerIcon'
			PickerIcon.Parent = Container
			PickerIcon.AnchorPoint = Vector2.new(1, 0.5)
			PickerIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			PickerIcon.BackgroundTransparency = 1.000
			PickerIcon.BorderColor3 = Color3.fromRGB(0, 0, 0)
			PickerIcon.BorderSizePixel = 0
			PickerIcon.Position = UDim2.new(1, -2, 0.5, 0)
			PickerIcon.Size = UDim2.new(0, 18, 0, 18)
			PickerIcon.Image = 'rbxassetid://11419718822'
			PickerIcon.ImageColor3 = Color3.fromRGB(150, 150, 150)

			PreviewHolder.Name = 'PreviewHolder'
			PreviewHolder.Parent = Container
			PreviewHolder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			PreviewHolder.BackgroundTransparency = 1.000
			PreviewHolder.BorderColor3 = Color3.fromRGB(0, 0, 0)
			PreviewHolder.BorderSizePixel = 0
			PreviewHolder.ClipsDescendants = true
			PreviewHolder.Size = UDim2.new(0, 8, 1, 0)

			Preview.Name = 'Preview'
			Preview.Parent = PreviewHolder
			Preview.BackgroundColor3 = Color3.fromRGB(255, 65, 65)
			Preview.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Preview.BorderSizePixel = 0
			Preview.Size = UDim2.new(2, 0, 1, 0)
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
			ColorWindow.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
			ColorWindow.BorderColor3 = Color3.fromRGB(30, 30, 30)
			ColorWindow.ClipsDescendants = true
			ColorWindow.Position = UDim2.new(0, 280, 0, 250)
			ColorWindow.Size = UDim2.new(0, 207, 0, 0)
			ColorWindow.ZIndex = 2
			ColorWindow.Visible = false
			Roundify(ColorWindow)
			Border(ColorWindow)

			Hue.Name = 'Hue'
			Hue.Parent = ColorWindow
			Hue.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Hue.BorderColor3 = Color3.fromRGB(30, 30, 30)
			Hue.Position = UDim2.new(0, 5, 0, 137)
			Hue.Size = UDim2.new(0, 127, 0, 20)
			Roundify(Hue)
			Border(Hue)

			HueGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)), ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255, 0, 255)), ColorSequenceKeypoint.new(0.32, Color3.fromRGB(0, 0, 255)), ColorSequenceKeypoint.new(0.49, Color3.fromRGB(0, 255, 255)), ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 255, 0)), ColorSequenceKeypoint.new(0.82, Color3.fromRGB(255, 255, 0)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0))}
			HueGradient.Name = 'HueGradient'
			HueGradient.Parent = Hue

			HueSlider.Name = 'HueSlider'
			HueSlider.Parent = Hue
			HueSlider.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
			HueSlider.BorderColor3 = Color3.fromRGB(0, 0, 0)
			HueSlider.BorderSizePixel = 0
			HueSlider.Position = UDim2.new(0, 20, 0, 2)
			HueSlider.Size = UDim2.new(0, 2, 1, -4)

			SatVal.Name = 'SatVal'
			SatVal.Parent = ColorWindow
			SatVal.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
			SatVal.BorderColor3 = Color3.fromRGB(30, 30, 30)
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
			Visual.BorderColor3 = Color3.fromRGB(30, 30, 30)
			Visual.Position = UDim2.new(0, 137, 0, 5)
			Visual.Size = UDim2.new(0, 65, 0, 52)
			Roundify(Visual)
			Border(Visual)

			RainbowColor.Name = 'RainbowColor'
			RainbowColor.Parent = ColorWindow
			RainbowColor.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
			RainbowColor.BorderColor3 = Color3.fromRGB(30, 30, 30)
			RainbowColor.Position = UDim2.new(0, 137, 0, 137)
			RainbowColor.Size = UDim2.new(0, 65, 0, 20)
			RainbowColor.AutoButtonColor = false
			RainbowColor.Font = Enum.Font.Code
			RainbowColor.Text = 'Rainbow'
			RainbowColor.TextColor3 = Color3.fromRGB(150, 150, 150)
			RainbowColor.TextSize = 16.000
			Roundify(RainbowColor)
			Border(RainbowColor)

			ResetColor.Name = 'ResetColor'
			ResetColor.Parent = ColorWindow
			ResetColor.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
			ResetColor.BorderColor3 = Color3.fromRGB(30, 30, 30)
			ResetColor.Position = UDim2.new(0, 137, 0, 112)
			ResetColor.Size = UDim2.new(0, 65, 0, 20)
			ResetColor.AutoButtonColor = false
			ResetColor.Font = Enum.Font.Code
			ResetColor.Text = 'Reset'
			ResetColor.TextColor3 = Color3.fromRGB(150, 150, 150)
			ResetColor.TextSize = 16.000
			Roundify(ResetColor)
			Border(ResetColor)

			ValueBox.Name = 'ValueBox'
			ValueBox.Parent = ColorWindow
			ValueBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
			ValueBox.BorderColor3 = Color3.fromRGB(30, 30, 30)
			ValueBox.Position = UDim2.new(0, 137, 0, 62)
			ValueBox.Size = UDim2.new(0, 65, 0, 20)
			ValueBox.ClearTextOnFocus = false
			ValueBox.Font = Enum.Font.SourceSans
			ValueBox.PlaceholderColor3 = Color3.fromRGB(80, 80, 80)
			ValueBox.PlaceholderText = 'R,G,B'
			ValueBox.Text = ''
			ValueBox.TextColor3 = Color3.fromRGB(150, 150, 150)
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
			HexBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
			HexBox.BorderColor3 = Color3.fromRGB(30, 30, 30)
			HexBox.Position = UDim2.new(0, 137, 0, 87)
			HexBox.Size = UDim2.new(0, 65, 0, 20)
			HexBox.ClearTextOnFocus = false
			HexBox.Font = Enum.Font.SourceSans
			HexBox.PlaceholderColor3 = Color3.fromRGB(80, 80, 80)
			HexBox.PlaceholderText = 'HEX'
			HexBox.Text = ''
			HexBox.TextColor3 = Color3.fromRGB(150, 150, 150)
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
					QTween(Button, 0.3, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)})
				end)

				Button.MouseLeave:Connect(function()
					QTween(Button, 0.3, {BackgroundColor3 = Color3.fromRGB(20, 20, 20)})
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
							if ChromaColor then
								Options:SetColor(ChromaColor)
								RainbowColor.TextColor3 = ChromaColor
							end
						end)
					end
				else
					if rainbowLoop then rainbowLoop:Disconnect(); rainbowLoop = nil end
					RainbowColor.TextColor3 = Color3.fromRGB(150, 150, 150)
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
				if TabsDisplayed or Library.warning or (Library.popup and Library.popup.hovering) then return end
				QTween(Container, 0.3, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)})
			end)

			ColorButton.MouseLeave:Connect(function()
				QTween(Container, 0.3, {BackgroundColor3 = Color3.fromRGB(20, 20, 20)})
			end)

			ColorButton.MouseButton1Down:Connect(function()
				if TabsDisplayed or Library.warning or (Library.popup and Library.popup.hovering) then return end
				QTween(Container, 0.3, {BackgroundColor3 = Color3.fromRGB(25, 25, 25)})
			end)

			ColorButton.MouseButton1Up:Connect(function()
				if TabsDisplayed or Library.warning or (Library.popup and Library.popup.hovering) then return end
				QTween(Container, 0.3, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)})
			end)

			ColorButton.MouseButton1Click:Connect(function()
				if TabsDisplayed then return end
				if Library.popup and Library.popup ~= Options and Library.popup.hovering then return end
				if Library.popup == Options then Library.popup:Close(); return end
				if Library.popup and Library.popup.hovering == false then Library.popup:Close() end
				QTween(ColorWindow, 0.3, {Size = UDim2.new(0, 207, 0, 162)})
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
				QTween(ColorWindow, 0.3, {Size = UDim2.new(0, 207, 0, 0)})
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
		name = 'Ayarum',
		colorscheme = Library.colorscheme,
		themecolor1 = Library.themecolor1,
		themecolor2 = Library.themecolor2,
		foldername = Library.foldername,
		fileext = Library.fileext,
		useconfigs = Library.useconfigs,
		autoload = Library.autoload
	})
	Title.Text = '<b>' .. Options.name .. '</b>'
	Library.colorscheme = Options.colorscheme
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

Library:AddConnection(RunService.RenderStepped, function()
	MouseBorder.Position = Vector2.new(Mouse.X, Mouse.Y + GuiInset)
	MouseIndicator.Position = Vector2.new(Mouse.X, Mouse.Y + GuiInset)
	if Mainframe.AbsolutePosition.X == -(Mainframe.AbsoluteSize.X + 30) then
		Mainframe.Visible = false
	else
		Mainframe.Visible = true
	end
end)

function Library:Toggle(Bool)
	if not Library.fullloaded then return end
	if typeof(Bool) ~= 'boolean' then Bool = false end
	Library.open = Bool
	if Library.popup then
		Library.popup:Close()
	end
	if Library.open then
		QTween(Mainframe, 0.3, {Position = UDim2.new(0, 0, 0, 0)})
		MouseUnlock.Visible = true
	else
		QTween(Mainframe, 0.3, {Position = UDim2.new(0, -(Mainframe.AbsoluteSize.X + 30), 0, 0)})
		MouseUnlock.Visible = false
	end
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
	Library.themecolor1 = Library.flags['Gradient Start Color'] ~= nil and Library.flags['Gradient Start Color'] or Library.themecolor1
	Library.themecolor2 = Library.flags['Gradient End Color'] ~= nil and Library.flags['Gradient End Color'] or Library.themecolor2
	for _, v in pairs(Library.theme) do
		v.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Library.themecolor1), ColorSequenceKeypoint.new(1, Library.themecolor2)})
	end
end

function Library:LoadConfig(config)
	if table.find(Library:GetConfigs(), config) then
		local Read, Config = pcall(function() return game:GetService('HttpService'):JSONDecode(readfile(Library.foldername .. '/' .. config .. Library.fileext)) end)
		Config = Read and Config or {}
		for _, option in next, Library.options do
			if option.type ~= 'button' and option.flag and not option.skipflag and Config[option.flag] ~= nil then
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
			v = v:gsub(Library.foldername:gsub('/', '\\') .. '\\', '')
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

	Notification.Parent = AyarumV5
	Notification.AnchorPoint = Vector2.new(1, 1)
	Notification.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
	Notification.BorderColor3 = Color3.fromRGB(30, 30, 30)
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
	NotifText.Font = Enum.Font.Code
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

	for _, v in pairs(AyarumV5:GetChildren()) do
		if v.Name == 'Notification' then
			v.NotifPos.Value = v.NotifPos.Value - (Notification.Size.Y.Offset + 10)
			if v.CanTween.Value then
				QTween(v, 0.3, {Position = UDim2.new(1, -10, 1, v.NotifPos.Value)})
			end
		end
	end
	Notification.Name = 'Notification'

	BTween(Notification, 0.3, {Position = UDim2.new(1, -10, 1, NotifPos.Value)})

	delay(Duration, function()
		CanTween.Value = false
		BTween(Notification, 0.3, {Position = UDim2.new(1, Notification.AbsoluteSize.X + 5, 1, NotifPos.Value)}, true)
		for _, v in pairs(AyarumV5:GetChildren()) do
			if v.Name == 'Notification' then
				if v.NotifPos.Value < NotifPos.Value and v.CanTween.Value == true then
					v.NotifPos.Value = v.NotifPos.Value + (Notification.Size.Y.Offset + 10)
					QTween(v, 0.3, {Position = UDim2.new(1, -10, 1, v.NotifPos.Value)})
				end
			end
		end
		wait(0.5)
		Notification:Destroy()
	end)
end

local LoadingGui
function Library:AddLoadingBar(LoadingBarText)
	LoadingGui = Instance.new('ScreenGui')
	local LoadingBar = Instance.new('Frame')
	local LoadingBarTitle = Instance.new('TextLabel')
	local BarHolder = Instance.new('Frame')
	local Bar = Instance.new('Frame')
	local LoadingInfo = Instance.new('TextLabel')

	LoadingGui.Name = 'Loading Gui'
	LoadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	LoadingGui.Parent = game.CoreGui
	LoadingGui.DisplayOrder = 300
	LoadingGui.ResetOnSpawn = false
	LoadingGui.IgnoreGuiInset = true

	LoadingBar.Name = 'LoadingBar'
	LoadingBar.Parent = LoadingGui
	LoadingBar.AnchorPoint = Vector2.new(0.5, 0)
	LoadingBar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
	LoadingBar.BorderColor3 = Color3.fromRGB(0, 0, 0)
	LoadingBar.BorderSizePixel = 0
	LoadingBar.Position = UDim2.new(0.5, 0, 0, -115)
	LoadingBar.Size = UDim2.new(0, 350, 0, 85)
	LoadingBar.ZIndex = 3
	Roundify(LoadingBar)
	Glow(LoadingBar, Color3.new(0, 0, 0))

	LoadingBarTitle.Name = 'LoadingBarTitle'
	LoadingBarTitle.Parent = LoadingBar
	LoadingBarTitle.AnchorPoint = Vector2.new(0.5, 0)
	LoadingBarTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	LoadingBarTitle.BackgroundTransparency = 1.000
	LoadingBarTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
	LoadingBarTitle.BorderSizePixel = 0
	LoadingBarTitle.Position = UDim2.new(0.5, 0, 0, 0)
	LoadingBarTitle.Size = UDim2.new(1, 0, 0, 25)
	LoadingBarTitle.Font = Enum.Font.Code
	LoadingBarTitle.RichText = true
	LoadingBarTitle.Text = '<b>' .. LoadingBarText .. '</b>'
	LoadingBarTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	LoadingBarTitle.TextSize = 20.000
	LoadingBarTitle.Size = UDim2.new(0, LoadingBarTitle.TextBounds.X, 0, 25)
	Gradient(LoadingBarTitle)

	BarHolder.Name = 'BarHolder'
	BarHolder.Parent = LoadingBar
	BarHolder.AnchorPoint = Vector2.new(0, 1)
	BarHolder.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	BarHolder.BorderColor3 = Color3.fromRGB(30, 30, 30)
	BarHolder.Position = UDim2.new(0, 10, 1, -10)
	BarHolder.Size = UDim2.new(1, -20, 0, 25)
	Roundify(BarHolder)
	Border(BarHolder)

	Bar.Name = 'Bar'
	Bar.Parent = BarHolder
	Bar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Bar.BackgroundTransparency = 1.000
	Bar.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Bar.BorderSizePixel = 0
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
	LoadingInfo.BorderColor3 = Color3.fromRGB(0, 0, 0)
	LoadingInfo.BorderSizePixel = 0
	LoadingInfo.Position = UDim2.new(0.5, 0, 0, 25)
	LoadingInfo.Size = UDim2.new(1, 0, 0, 18)
	LoadingInfo.Font = Enum.Font.Code
	LoadingInfo.Text = 'Initializing...'
	LoadingInfo.TextColor3 = Color3.fromRGB(150, 150, 150)
	LoadingInfo.TextSize = 18.000

	BTween(LoadingBar, 0.3, {Position = UDim2.new(0.5, 0, 0, 10)})
	wait(0.3)
	local Options = {}
	function Options:Update(Value, Max, Text)
		Bar.UIStroke.Enabled = true
		QTween(Bar, 0.3, {Size = UDim2.new(Value / Max, 0, 1, 0)})
		LoadingInfo.Text = Text
		if Value == Max then
			wait(0.3)
			QTween(Bar, 0.3, {BackgroundTransparency = 0})
			QTween(Bar.Glow, 0.3, {ImageTransparency = 0})
			wait(1.5)
			QTween(LoadingBar, 0.3, {Position = UDim2.new(0.5, 0, 0, -115)}, true)
			wait(0.3)
			LoadingBar:Destroy()
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
			WarningTitle.Font = Enum.Font.Code
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
			Yes.Font = Enum.Font.Code
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
			No.Font = Enum.Font.Code
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
			WarningText.Font = Enum.Font.Code
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
		QTween(main, 0.3, {BackgroundTransparency = 0.5})
		QTween(main.WarningTitle, 0.3, {Position = UDim2.new(0, 0, 0, 0)})
		QTween(main.WarningHolder, 0.3, {Position = UDim2.new(0.5, 0, 0.5, -(main.WarningHolder.AbsoluteSize.Y / 2))})

		repeat wait() until answer ~= nil
		local a = answer
		spawn(Options.Close)
		return a
	end

	function Options:Close()
		answer = nil
		Library.warning = nil
		if not main then return end
		QTween(main, 0.3, {BackgroundTransparency = 1})
		QTween(main.WarningTitle, 0.3, {Position = UDim2.new(0, 0, 0, -40)})
		QTween(main.WarningHolder, 0.3, {Position = UDim2.new(0.5, 0, 1, 0)})
		wait(0.3)
		main.Visible = false
	end

	return Options
end

function Library:Init()
	Library.loaded = true
	for _, v in pairs(Library.tabs) do
		if v.first then
			v.Select()
		end
	end
	if RunService:IsStudio() then
		AyarumV5.Parent = game.Players.LocalPlayer:WaitForChild('PlayerGui')
	else
		AyarumV5.Parent = game.CoreGui
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
	wait(0.3)

	Library.fullloaded = true
	Library:Toggle(true)
end

function Library:Unload()
	if LoadingGui then LoadingGui:Destroy() end
	Library.fullloaded = false
	Library:Defaults()
	for _, c in next, Library.connections do
		c:Disconnect()
	end
	wait()
	AyarumV5:Destroy()
	getgenv().ayarum = nil
	Library.loaded = false
	MouseIndicator:Remove()
	MouseBorder:Remove()
end

return Library