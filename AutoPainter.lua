-- Remaked some guy's Autopainter. Less CPU + Better AP

local color = Color3.fromRGB(255,255,255)
local userInputService = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local provincesFolder = Instance.new("Model")
provincesFolder.Name = "AutopainterProvinces"
provincesFolder.Parent = workspace
local highlight = Instance.new("Highlight")
highlight.FillColor = color
highlight.FillTransparency = 0.8
highlight.Parent = workspace
highlight.Adornee = provincesFolder
local UI = Instance.new("ScreenGui")
UI.Name = "PaintAdminPanel"
UI.ResetOnSpawn = false
UI.Parent = player.PlayerGui
local UIHolder = Instance.new("Frame",UI)
UIHolder.AnchorPoint = Vector2.new(0.5,0.5)
UIHolder.BackgroundTransparency = 1
UIHolder.Position = UDim2.new(0.5,0,0.5,0)
UIHolder.Size = UDim2.new(0,0,0,0)
local aspectratio = Instance.new("UIAspectRatioConstraint",UIHolder)
local mainFrame = Instance.new("Frame",UIHolder)
mainFrame.BackgroundColor3 = Color3.fromRGB(33,33,42)
mainFrame.AnchorPoint = Vector2.new(0.5,0.5)
mainFrame.Position = UDim2.new(0.5,0,0.5,0)
mainFrame.Size = UDim2.new(0.5,0,0.276,0)
mainFrame.Rotation = 359
local topBar = Instance.new("Frame",mainFrame)
topBar.BorderColor3 = Color3.fromRGB(0,0,0)
topBar.BackgroundColor3 = Color3.fromRGB(49,49,64)
topBar.Size = UDim2.new(1,0,0.14,0)
local pss = Instance.new("TextLabel",topBar)
pss.Text = "0 paint/second"
pss.AnchorPoint = Vector2.new(0,0.5)
pss.Size = UDim2.new(0.974,0,0.5,0)
pss.Position = UDim2.new(0,0,0.5,0)
pss.TextColor3 = Color3.fromRGB(255,255,255)
pss.BackgroundTransparency = 1
pss.TextScaled = true
pss.TextXAlignment = Enum.TextXAlignment.Right
local panelTitle = Instance.new("TextLabel",topBar)
panelTitle.AnchorPoint = Vector2.new(0,0.5)
panelTitle.BackgroundTransparency = 1
panelTitle.Position = UDim2.new(0.02,0,0.5,0)
panelTitle.Size = UDim2.new(1,0,0.5,0)
panelTitle.Text = '<b>Paint Admin Panel</b><font size="6"> PRO</font>'
panelTitle.RichText = true
panelTitle.TextScaled = true
panelTitle.TextColor3 = Color3.fromRGB(255,255,255)
panelTitle.TextXAlignment = Enum.TextXAlignment.Left

local scrollFrame = Instance.new("ScrollingFrame",mainFrame)
scrollFrame.BackgroundTransparency = 1
scrollFrame.Position = UDim2.new(0,0,0.14,0)
scrollFrame.Size = UDim2.new(1,0,0.86,0)
scrollFrame.ScrollBarThickness = 0

local listlayout = Instance.new("UIListLayout",scrollFrame)
listlayout.Padding = UDim.new(0,10)

local uipadding = Instance.new("UIPadding",scrollFrame)
uipadding.PaddingTop = UDim.new(0,10)
uipadding.PaddingLeft = UDim.new(0,10)
uipadding.PaddingRight = UDim.new(0,10)
uipadding.PaddingBottom = UDim.new(0,10)

local doneButton = Instance.new("TextButton",UI)
doneButton.Visible = false
doneButton.AnchorPoint = Vector2.new(0.5,0)
doneButton.BackgroundColor3 = Color3.fromRGB(0,247,159)
doneButton.Position = UDim2.new(0.5,0,0,0)
doneButton.Size = UDim2.new(0.3,0,0.1,0)
doneButton.TextColor3 = Color3.fromRGB(255,255,255)
doneButton.TextScaled = true
doneButton.Text = "Done"
doneButton.AutoButtonColor = false
doneButton.BorderSizePixel = 0

local whiteFrame = Instance.new("Frame",mainFrame)
whiteFrame.Size = UDim2.new(1,0,1,0)
whiteFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)

-- Sounds --

local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://4612386227"
sound.Parent = workspace

local changecolor = Instance.new("Sound")
changecolor.SoundId = "rbxassetid://4612383790"
changecolor.Parent = workspace

local sound2 = Instance.new("Sound")
sound2.SoundId = "rbxassetid://7486747911"
sound2.Parent = workspace
sound2.PlaybackSpeed = 2

local provinceSound = Instance.new("Sound")
provinceSound.SoundId = "rbxassetid://5694665239"
provinceSound.Parent = workspace

-- Variables --

local provinces = {}
local provincespersecond = 0
local pps = 0

local selectColorMode = false
local removeProvincesMode = false
local selectProvincesMode = false
local newpaint = false
local painting = true
local keepTerColor = false

-- NEW RGB MODE --

local rgbMode = false
local rgbIndex = 0

local dragging
local dragInput
local dragStart
local startPos

-- Paint engine --

local NORMAL_MAX = 50
local FAST_MAX = 200
local RATE_WINDOW = 0.5

local paintCount = 0
local paintResetTime = 0

-- Forward declarations --

local removeProvince
local clearAllProvinces
local selectAllProvinces
local selectAllButton
local rgbModeButton

local function getRGBColor(index)
	local goldenRatio = 0.618033988749895
	local hue = (index * goldenRatio) % 1
	local saturation = 0.78
	local value = 0.95

	return Color3.fromHSV(hue,saturation,value)
end

local function colorToHex(c)
	return string.format(
		"#%02X%02X%02X",
		math.floor(c.R * 255 + 0.5),
		math.floor(c.G * 255 + 0.5),
		math.floor(c.B * 255 + 0.5)
	)
end

local function getNextRGBColor()
	rgbIndex += 1
	return getRGBColor(rgbIndex)
end

local function startProvincePainter(info)
	task.spawn(function()

		local province = info.Province

		while province.Parent and info.Active do
			task.wait()

			if not painting then
				task.wait(0.1)
				continue
			end

			local character = player.Character

			if not character then
				task.wait(0.1)
				continue
			end

			local paintBucket = character:FindFirstChild("PaintBucket")

			if not paintBucket then
				task.wait(0.1)
				continue
			end

			-- Determine target color --

			local targetColor

			if rgbMode then
				targetColor = info.RGBColor
			elseif keepTerColor then
				targetColor = info.SavedColor or color
			else
				targetColor = color
			end

			if not targetColor then
				task.wait(0.1)
				continue
			end

			-- Already correct color --

			if province.Color == targetColor then
				task.wait(0.1)
				continue
			end

			-- Limit requests per province --

			if info.InFlight >= 2 then
				continue
			end

			-- Global rate limit --

			local now = tick()

			if now > paintResetTime then
				paintCount = 0
				paintResetTime = now + RATE_WINDOW
			end

			local currentMax = newpaint and FAST_MAX or NORMAL_MAX

			if paintCount >= currentMax then
				task.wait(0.05)
				continue
			end

			info.InFlight += 1
			paintCount += 1

			local args = {
				[1] = "PaintPart",
				[2] = {
					["Part"] = province,
					["Color"] = targetColor
				},
				[3] = "Peace"
			}

			task.spawn(function()

				local ok = pcall(function()
					local bucket = player.Character
						and player.Character:FindFirstChild("PaintBucket")

					if bucket then
						bucket.Remotes.ServerControls:InvokeServer(unpack(args))
					end
				end)

				info.InFlight -= 1

				if ok then
					provincespersecond += 1
				end
			end)
		end

		-- Cleanup if province disappears --

		if not province.Parent then
			removeProvince(province)
		end
	end)
end

-- Add province --

local function addProvince(province)

	-- Don't add duplicates --

	for _,info in ipairs(provinces) do
		if info.Province == province then
			return
		end
	end

	local clone = province:Clone()

	clone.Position -= Vector3.new(0,0.01,0)
	clone.Material = Enum.Material.Glass
	clone.Transparency = 1
	clone.Parent = provincesFolder

	-- Save original province color --

	local savedColor = province.Color

	-- Give this province its own RGB --

	local rgbColor = getNextRGBColor()

	local info = {
		Province = province,
		Highlight = clone,

		-- Original color
		SavedColor = savedColor,

		-- Individual RGB color
		RGBColor = rgbColor,

		InFlight = 0,
		Active = true
	}

	table.insert(provinces,info)

	startProvincePainter(info)

	provinceSound:Play()
end

-- Remove province --

removeProvince = function(province)

	for i = #provinces,1,-1 do

		local info = provinces[i]

		if info.Province == province then

			info.Active = false

			if info.Highlight then
				info.Highlight:Destroy()
			end

			table.remove(provinces,i)

			break
		end
	end

	-- If there are no provinces left, turn Select All off --

	if #provinces == 0 then
		if selectAllButton then

			tweenService:Create(
				selectAllButton.Parent,
				TweenInfo.new(0.1),
				{
					BackgroundColor3 = Color3.fromRGB(241,33,103)
				}
			):Play()

			tweenService:Create(
				selectAllButton,
				TweenInfo.new(0.1),
				{
					Position = UDim2.new(0,0,0,0),
					AnchorPoint = Vector2.new(0,0)
				}
			):Play()
		end
	end
end

-- Update Select All button --

local function updateSelectAllVisual(enabled)

	if not selectAllButton then
		return
	end

	if enabled then

		tweenService:Create(
			selectAllButton.Parent,
			TweenInfo.new(0.1),
			{
				BackgroundColor3 = Color3.fromRGB(53,227,153)
			}
		):Play()

		tweenService:Create(
			selectAllButton,
			TweenInfo.new(0.1),
			{
				Position = UDim2.new(1,0,0,0),
				AnchorPoint = Vector2.new(1,0)
			}
		):Play()

	else

		tweenService:Create(
			selectAllButton.Parent,
			TweenInfo.new(0.1),
			{
				BackgroundColor3 = Color3.fromRGB(241,33,103)
			}
		):Play()

		tweenService:Create(
			selectAllButton,
			TweenInfo.new(0.1),
			{
				Position = UDim2.new(0,0,0,0),
				AnchorPoint = Vector2.new(0,0)
			}
		):Play()
	end
end

-- Clear all --

clearAllProvinces = function()

	for _,info in ipairs(provinces) do

		info.Active = false

		if info.Highlight then
			info.Highlight:Destroy()
		end
	end

	provinces = {}

	-- Reset RGB index so next selection starts fresh --

	rgbIndex = 0

	updateSelectAllVisual(false)
end

-- Select every Province --

selectAllProvinces = function()

	-- Reset RGB sequence --

	rgbIndex = 0

	local provinceList = {}

	-- Collect provinces first --

	for _,instance in ipairs(workspace:GetDescendants()) do

		if instance:IsA("BasePart")
			and instance.Name == "Province"
			and not instance:IsDescendantOf(provincesFolder) then

			table.insert(provinceList,instance)
		end
	end

	table.sort(
		provinceList,
		function(a,b)
			return a:GetFullName() < b:GetFullName()
		end
	)

	-- Add all provinces --

	for _,province in ipairs(provinceList) do
		addProvince(province)
	end

	return #provinceList
end

-- UI Creation --

local function createNewOption(optionType,text,customText,enabled)

	local optionFrame = Instance.new("Frame",scrollFrame)

	optionFrame.BorderColor3 = Color3.fromRGB(0,0,0)
	optionFrame.BackgroundColor3 = Color3.fromRGB(49,49,64)
	optionFrame.Size = UDim2.new(1,0,0.075,0)

	local textlabel = Instance.new("TextLabel",optionFrame)

	textlabel.BackgroundTransparency = 1
	textlabel.Position = UDim2.new(0.02,0,0.2,0)
	textlabel.Size = UDim2.new(1,0,0.6,0)
	textlabel.TextScaled = true
	textlabel.Text = text
	textlabel.Font = Enum.Font.SourceSansBold
	textlabel.TextColor3 = Color3.fromRGB(255,255,255)
	textlabel.TextXAlignment = Enum.TextXAlignment.Left

	if optionType == "switch" then

		local switchFrame = Instance.new("Frame",optionFrame)

		switchFrame.BackgroundColor3 = Color3.fromRGB(241,33,103)
		switchFrame.Position = UDim2.new(0.865,0,0.125,0)
		switchFrame.Size = UDim2.new(0.125,0,0.75,0)
		switchFrame.BorderSizePixel = 0

		local switch = Instance.new("ImageButton",switchFrame)

		switch.AutoButtonColor = false
		switch.BorderSizePixel = 0
		switch.Size = UDim2.new(1,0,1,0)
		switch.BackgroundColor3 = Color3.fromRGB(255,255,255)

		local aspectRatio = Instance.new("UIAspectRatioConstraint",switch)

		if enabled then

			tweenService:Create(
				switch.Parent,
				TweenInfo.new(0.1),
				{
					BackgroundColor3 = Color3.fromRGB(53,227,153)
				}
			):Play()

			tweenService:Create(
				switch,
				TweenInfo.new(0.1),
				{
					Position = UDim2.new(1,0,0,0),
					AnchorPoint = Vector2.new(1,0)
				}
			):Play()
		end

		return switch

	elseif optionType == "color" then

		local colorButton = Instance.new("ImageButton",optionFrame)

		colorButton.Position = UDim2.new(0.928,0,0.125,0)
		colorButton.AutoButtonColor = false
		colorButton.Size = UDim2.new(0.062,0,0.75,0)

		return colorButton

	elseif optionType == "custom" then

		local button = Instance.new("ImageButton",optionFrame)

		button.BackgroundColor3 = Color3.fromRGB(100,100,100)
		button.Position = UDim2.new(0.865,0,0.125,0)
		button.Size = UDim2.new(0.125,0,0.75,0)
		button.AutoButtonColor = false

		local customLabel = Instance.new("TextLabel",button)

		customLabel.BackgroundTransparency = 1
		customLabel.Position = UDim2.new(0.5,0,0.5,0)
		customLabel.AnchorPoint = Vector2.new(0.5,0.5)
		customLabel.Size = UDim2.new(0.8,0,0.8,0)
		customLabel.Text = customText
		customLabel.TextScaled = true
		customLabel.Font = Enum.Font.SourceSansBold
		customLabel.TextColor3 = Color3.fromRGB(255,255,255)

		return button
	end
end

-- Dragging --

local function update(input)

	local delta = input.Position - dragStart

	mainFrame.Position = UDim2.new(
		startPos.X.Scale,
		startPos.X.Offset + delta.X,

		startPos.Y.Scale,
		startPos.Y.Offset + delta.Y
	)
end

-- Start --

wait(1)

sound:Play()

if userInputService.MouseEnabled == false then

	tweenService:Create(
		UIHolder,
		TweenInfo.new(0.5),
		{
			Size = UDim2.new(1.5,0,1.5,0)
		}
	):Play()

else

	tweenService:Create(
		UIHolder,
		TweenInfo.new(0.5),
		{
			Size = UDim2.new(0.75,0,0.75,0)
		}
	):Play()
end

tweenService:Create(
	mainFrame,
	TweenInfo.new(0.5),
	{
		Rotation = 0
	}
):Play()

tweenService:Create(
	whiteFrame,
	TweenInfo.new(4),
	{
		BackgroundTransparency = 1
	}
):Play()

-- Window dragging --

topBar.InputBegan:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position

		input.Changed:Connect(function()

			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

topBar.InputChanged:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then

		dragInput = input
	end
end)

userInputService.InputChanged:Connect(function(input)

	if input == dragInput and dragging then
		update(input)
	end
end)

-- Buttons --

local button2 = createNewOption(
	"color",
	"Country Color"
)

local button1 = createNewOption(
	"custom",
	"Protect Province",
	"Add"
)

local button5 = createNewOption(
	"custom",
	"Unprotect Province",
	"Remove"
)

local button3 = createNewOption(
	"custom",
	"Clear Provinces",
	"Clear"
)

-- SELECT ALL --

selectAllButton = createNewOption(
	"switch",
	"Select All Provinces",
	nil,
	false
)

-- RGB MODE --

rgbModeButton = createNewOption(
	"switch",
	"RGB Mode",
	nil,
	false
)

local togglePaintButton = createNewOption(
	"switch",
	"Toggle Paint",
	nil,
	true
)

local newPaintButton = createNewOption(
	"switch",
	"Fast Paint"
)

local territoryColorButton = createNewOption(
	"switch",
	"Keep Territory Color (NEW)"
)

local randomColorButton = createNewOption(
	"custom",
	"Randomize color (NEW)",
	"Change"
)

-- Mouse --

mouse.Button1Down:Connect(function()

	if mouse.Target
		and mouse.Target.Name == "Province" then

		if selectColorMode then

			color = mouse.Target.Color

			selectColorMode = false
			UIHolder.Visible = true

			button2.BackgroundColor3 = color

			changecolor:Play()
		end

		if selectProvincesMode then
			addProvince(mouse.Target)
		end

		if removeProvincesMode then
			removeProvince(mouse.Target)
		end
	end
end)

-- Country Color --

button2.BackgroundColor3 = color

button2.MouseButton1Down:Connect(function()

	UIHolder.Visible = false
	selectColorMode = true
end)

-- Protect --

button1.MouseButton1Down:Connect(function()

	UIHolder.Visible = false

	selectProvincesMode = true
	removeProvincesMode = false

	doneButton.Visible = true
end)

-- Done --

doneButton.MouseButton1Down:Connect(function()

	removeProvincesMode = false
	selectProvincesMode = false

	UIHolder.Visible = true
	doneButton.Visible = false
end)

-- Clear --

button3.MouseButton1Down:Connect(function()
	clearAllProvinces()
end)

-- Unprotect --

button5.MouseButton1Down:Connect(function()

	UIHolder.Visible = false

	selectProvincesMode = false
	removeProvincesMode = true

	doneButton.Visible = true
end)

-- SELECT ALL --

selectAllButton.MouseButton1Down:Connect(function()

	sound2:Play()

	if #provinces == 0 then

		local count = selectAllProvinces()

		if count > 0 then
			updateSelectAllVisual(true)
		end

	else

		clearAllProvinces()
	end
end)

-- RGB MODE --

rgbModeButton.MouseButton1Down:Connect(function()

	sound2:Play()

	rgbMode = not rgbMode

	if rgbMode then

		-- Give every currently selected province
		-- its own new RGB color.

		rgbIndex = 0

		for _,info in ipairs(provinces) do
			info.RGBColor = getNextRGBColor()
		end

		-- Green toggle --

		tweenService:Create(
			rgbModeButton.Parent,
			TweenInfo.new(0.1),
			{
				BackgroundColor3 = Color3.fromRGB(53,227,153)
			}
		):Play()

		tweenService:Create(
			rgbModeButton,
			TweenInfo.new(0.1),
			{
				Position = UDim2.new(1,0,0,0),
				AnchorPoint = Vector2.new(1,0)
			}
		):Play()

	else

		-- Red toggle --

		tweenService:Create(
			rgbModeButton.Parent,
			TweenInfo.new(0.1),
			{
				BackgroundColor3 = Color3.fromRGB(241,33,103)
			}
		):Play()

		tweenService:Create(
			rgbModeButton,
			TweenInfo.new(0.1),
			{
				Position = UDim2.new(0,0,0,0),
				AnchorPoint = Vector2.new(0,0)
			}
		):Play()
	end
end)

-- Toggle Paint --

togglePaintButton.MouseButton1Down:Connect(function()

	sound2:Play()

	painting = not painting

	if painting then

		tweenService:Create(
			togglePaintButton.Parent,
			TweenInfo.new(0.1),
			{
				BackgroundColor3 = Color3.fromRGB(53,227,153)
			}
		):Play()

		tweenService:Create(
			togglePaintButton,
			TweenInfo.new(0.1),
			{
				Position = UDim2.new(1,0,0,0),
				AnchorPoint = Vector2.new(1,0)
			}
		):Play()

	else

		tweenService:Create(
			togglePaintButton.Parent,
			TweenInfo.new(0.1),
			{
				BackgroundColor3 = Color3.fromRGB(241,33,103)
			}
		):Play()

		tweenService:Create(
			togglePaintButton,
			TweenInfo.new(0.1),
			{
				Position = UDim2.new(0,0,0,0),
				AnchorPoint = Vector2.new(0,0)
			}
		):Play()
	end
end)

-- Fast Paint --

newPaintButton.MouseButton1Down:Connect(function()

	sound2:Play()

	newpaint = not newpaint

	if newpaint then

		tweenService:Create(
			newPaintButton.Parent,
			TweenInfo.new(0.1),
			{
				BackgroundColor3 = Color3.fromRGB(53,227,153)
			}
		):Play()

		tweenService:Create(
			newPaintButton,
			TweenInfo.new(0.1),
			{
				Position = UDim2.new(1,0,0,0),
				AnchorPoint = Vector2.new(1,0)
			}
		):Play()

	else

		tweenService:Create(
			newPaintButton.Parent,
			TweenInfo.new(0.1),
			{
				BackgroundColor3 = Color3.fromRGB(241,33,103)
			}
		):Play()

		tweenService:Create(
			newPaintButton,
			TweenInfo.new(0.1),
			{
				Position = UDim2.new(0,0,0,0),
				AnchorPoint = Vector2.new(0,0)
			}
		):Play()
	end
end)

-- Keep Territory Color --

territoryColorButton.MouseButton1Down:Connect(function()

	sound2:Play()

	keepTerColor = not keepTerColor

	if keepTerColor then

		tweenService:Create(
			territoryColorButton.Parent,
			TweenInfo.new(0.1),
			{
				BackgroundColor3 = Color3.fromRGB(53,227,153)
			}
		):Play()

		tweenService:Create(
			territoryColorButton,
			TweenInfo.new(0.1),
			{
				Position = UDim2.new(1,0,0,0),
				AnchorPoint = Vector2.new(1,0)
			}
		):Play()

	else

		tweenService:Create(
			territoryColorButton.Parent,
			TweenInfo.new(0.1),
			{
				BackgroundColor3 = Color3.fromRGB(241,33,103)
			}
		):Play()

		tweenService:Create(
			territoryColorButton,
			TweenInfo.new(0.1),
			{
				Position = UDim2.new(0,0,0,0),
				AnchorPoint = Vector2.new(0,0)
			}
		):Play()
	end
end)

-- Random Color --

randomColorButton.MouseButton1Down:Connect(function()

	color = Color3.fromRGB(
		math.random(0,255),
		math.random(0,255),
		math.random(0,255)
	)

	button2.BackgroundColor3 = color

	changecolor:Play()
end)

-- Keybinds --

userInputService.InputBegan:Connect(function(input,isTyping)

	if isTyping then
		return
	end

	-- R = Random color --

	if input.KeyCode == Enum.KeyCode.R then

		color = Color3.fromRGB(
			math.random(0,255),
			math.random(0,255),
			math.random(0,255)
		)

		button2.BackgroundColor3 = color

		changecolor:Play()

	-- Q = Toggle painting --

	elseif input.KeyCode == Enum.KeyCode.Q then

		painting = not painting

		if painting then

			tweenService:Create(
				togglePaintButton.Parent,
				TweenInfo.new(0.1),
				{
					BackgroundColor3 = Color3.fromRGB(53,227,153)
				}
			):Play()

			tweenService:Create(
				togglePaintButton,
				TweenInfo.new(0.1),
				{
					Position = UDim2.new(1,0,0,0),
					AnchorPoint = Vector2.new(1,0)
				}
			):Play()

		else

			tweenService:Create(
				togglePaintButton.Parent,
				TweenInfo.new(0.1),
				{
					BackgroundColor3 = Color3.fromRGB(241,33,103)
				}
			):Play()

			tweenService:Create(
				togglePaintButton,
				TweenInfo.new(0.1),
				{
					Position = UDim2.new(0,0,0,0),
					AnchorPoint = Vector2.new(0,0)
				}
			):Play()
		end
	end
end)

-- PPS counter --

while task.wait(1) do

	pss.TextColor3 = Color3.fromRGB(80,255,123)

	if provincespersecond >= 50 then
		pss.TextColor3 = Color3.fromRGB(247,226,112)
	end

	if provincespersecond >= 100 then
		pss.TextColor3 = Color3.fromRGB(245,128,37)
	end

	if provincespersecond >= 300 then
		pss.TextColor3 = Color3.fromRGB(235,8,10)
	end

	if provincespersecond >= 1000 then
		pss.TextColor3 = Color3.fromRGB(235,0,120)
	end

	pss.Text = provincespersecond.." paint/second"

	pps = provincespersecond
	provincespersecond = 0
end
