-- Grow a Garden 2 HUB - Key System GUI
-- Fixed version

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- CONFIGURATION
local API_KEY_LINK = "https://www.roblox.com.am/communities/114062597626/The-Jays"

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KeySystemGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 500, 0, 300)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Rounded corners
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

-- Stroke
local shadow = Instance.new("UIStroke")
shadow.Color = Color3.fromRGB(0, 0, 0)
shadow.Thickness = 2
shadow.Parent = mainFrame

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 0, 60)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 24
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "Grow a Garden 2 HUB"
titleLabel.BorderSizePixel = 0
titleLabel.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleLabel

-- Subtitle
local subtitleLabel = Instance.new("TextLabel")
subtitleLabel.Name = "Subtitle"
subtitleLabel.Size = UDim2.new(1, 0, 0, 25)
subtitleLabel.Position = UDim2.new(0, 0, 0, 60)
subtitleLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
subtitleLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
subtitleLabel.TextSize = 12
subtitleLabel.Font = Enum.Font.Gotham
subtitleLabel.Text = "Made by Insanity / Fixed by Grok"
subtitleLabel.BorderSizePixel = 0
subtitleLabel.Parent = mainFrame

-- Button Container
local buttonContainerFrame = Instance.new("Frame")
buttonContainerFrame.Name = "ButtonContainer"
buttonContainerFrame.Size = UDim2.new(1, -40, 0, 120)
buttonContainerFrame.Position = UDim2.new(0, 20, 0, 110)
buttonContainerFrame.BackgroundTransparency = 1
buttonContainerFrame.BorderSizePixel = 0
buttonContainerFrame.Parent = mainFrame

-- Check Key Button
local checkKeyButton = Instance.new("TextButton")
checkKeyButton.Name = "CheckKeyButton"
checkKeyButton.Size = UDim2.new(0.48, 0, 0, 60)
checkKeyButton.Position = UDim2.new(0, 0, 0, 0)
checkKeyButton.BackgroundColor3 = Color3.fromRGB(60, 130, 180)
checkKeyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
checkKeyButton.TextSize = 14
checkKeyButton.Font = Enum.Font.GothamBold
checkKeyButton.Text = "Check Key"
checkKeyButton.BorderSizePixel = 0
checkKeyButton.Parent = buttonContainerFrame

local checkKeyCorner = Instance.new("UICorner")
checkKeyCorner.CornerRadius = UDim.new(0, 8)
checkKeyCorner.Parent = checkKeyButton

-- Copy Link Button
local copyLinkButton = Instance.new("TextButton")
copyLinkButton.Name = "CopyLinkButton"
copyLinkButton.Size = UDim2.new(0.48, 0, 0, 60)
copyLinkButton.Position = UDim2.new(0.52, 0, 0, 0)
copyLinkButton.BackgroundColor3 = Color3.fromRGB(85, 170, 85)
copyLinkButton.TextColor3 = Color3.fromRGB(255, 255, 255)
copyLinkButton.TextSize = 14
copyLinkButton.Font = Enum.Font.GothamBold
copyLinkButton.Text = "Copy Link"
copyLinkButton.BorderSizePixel = 0
copyLinkButton.Parent = buttonContainerFrame

local copyLinkCorner = Instance.new("UICorner")
copyLinkCorner.CornerRadius = UDim.new(0, 8)
copyLinkCorner.Parent = copyLinkButton

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "Status"
statusLabel.Size = UDim2.new(1, -40, 0, 40)
statusLabel.Position = UDim2.new(0, 20, 0, 240)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.TextSize = 12
statusLabel.Font = Enum.Font.Gotham
statusLabel.Text = "Ready"
statusLabel.TextWrapped = true
statusLabel.Parent = mainFrame

-- Hover effect
local function setupButtonHover(button)
	local originalColor = button.BackgroundColor3
	button.MouseEnter:Connect(function()
		button.BackgroundColor3 = Color3.fromRGB(
			math.min(originalColor.R * 255 + 25, 255) / 255,
			math.min(originalColor.G * 255 + 25, 255) / 255,
			math.min(originalColor.B * 255 + 25, 255) / 255
		)
	end)
	button.MouseLeave:Connect(function()
		button.BackgroundColor3 = originalColor
	end)
end

setupButtonHover(checkKeyButton)
setupButtonHover(copyLinkButton)

-- Check Key
checkKeyButton.MouseButton1Click:Connect(function()
	statusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
	statusLabel.Text = "Key check feature - Connect your verification system here"
	task.wait(2.5)
	statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	statusLabel.Text = "Ready"
end)

-- Copy Link
copyLinkButton.MouseButton1Click:Connect(function()
	if setclipboard then
		setclipboard(API_KEY_LINK)
		statusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
		statusLabel.Text = "Link copied to clipboard!"
	else
		statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
		statusLabel.Text = "Clipboard not supported on this executor"
	end
	task.wait(2)
	statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	statusLabel.Text = "Ready"
end)

-- Close with ESC
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.Escape then
		screenGui:Destroy()
	end
end)

print("Grow a Garden 2 HUB - Key System loaded (Fixed)")
