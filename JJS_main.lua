-- JJS_main.lua
-- Moveset Checker (Mobile Optimized)
-- Created by Grok for Jayren Sudo Rivals Hub

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

-- Mobile-friendly Moveset Checker
local function checkMoveset()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    
    local results = {}
    table.insert(results, "===== JJS Moveset Checker =====")
    table.insert(results, "Player: " .. LocalPlayer.Name)
    table.insert(results, "")
    
    -- Check common places for moveset data
    local possiblePlaces = {
        LocalPlayer:FindFirstChild("Moveset"),
        LocalPlayer:FindFirstChild("PlayerData"),
        LocalPlayer:FindFirstChild("Data"),
        character:FindFirstChild("Moveset"),
        ReplicatedStorage:FindFirstChild("Movesets"),
        ReplicatedStorage:FindFirstChild("Modules")
    }
    
    table.insert(results, "Found Folders:")
    for _, place in pairs(possiblePlaces) do
        if place then
            table.insert(results, "• " .. place.Name)
            for _, child in pairs(place:GetChildren()) do
                table.insert(results, "   - " .. child.Name)
            end
        end
    end
    
    table.insert(results, "")
    table.insert(results, "Character Items:")
    for _, item in pairs(character:GetChildren()) do
        if item:IsA("Tool") or item:IsA("Folder") or item:IsA("LocalScript") or item:IsA("ModuleScript") then
            table.insert(results, "• " .. item.Name)
        end
    end
    
    table.insert(results, "")
    table.insert(results, "Backpack:")
    for _, item in pairs(LocalPlayer.Backpack:GetChildren()) do
        table.insert(results, "• " .. item.Name)
    end
    
    table.insert(results, "===============================")
    
    return table.concat(results, "\n")
end

-- Create Mobile GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JJS_MovesetChecker"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- Main Frame (bigger for mobile)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0.9, 0, 0.7, 0)
MainFrame.Position = UDim2.new(0.05, 0, 0.15, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.Text = "JJS Moveset Checker"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = Title

-- Scrolling Frame for results (mobile friendly)
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -20, 1, -120)
ScrollFrame.Position = UDim2.new(0, 10, 0, 60)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ScrollBarThickness = 8
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.Parent = MainFrame

local ResultLabel = Instance.new("TextLabel")
ResultLabel.Size = UDim2.new(1, -10, 0, 0)
ResultLabel.BackgroundTransparency = 1
ResultLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
ResultLabel.Font = Enum.Font.Gotham
ResultLabel.TextSize = 16
ResultLabel.TextXAlignment = Enum.TextXAlignment.Left
ResultLabel.TextYAlignment = Enum.TextYAlignment.Top
ResultLabel.TextWrapped = true
ResultLabel.Text = "Click Check to scan your moveset..."
ResultLabel.Parent = ScrollFrame

-- Check Button (big for mobile)
local CheckButton = Instance.new("TextButton")
CheckButton.Size = UDim2.new(0.45, 0, 0, 45)
CheckButton.Position = UDim2.new(0.05, 0, 1, -55)
CheckButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
CheckButton.Text = "CHECK"
CheckButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CheckButton.Font = Enum.Font.GothamBold
CheckButton.TextSize = 18
CheckButton.Parent = MainFrame

local CheckCorner = Instance.new("UICorner")
CheckCorner.CornerRadius = UDim.new(0, 8)
CheckCorner.Parent = CheckButton

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0.45, 0, 0, 45)
CloseButton.Position = UDim2.new(0.5, 0, 1, -55)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.Text = "CLOSE"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 18
CloseButton.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseButton

-- Open Button (always visible on mobile)
local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.new(0, 140, 0, 45)
OpenButton.Position = UDim2.new(0, 15, 0.5, -22)
OpenButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
OpenButton.Text = "Moveset"
OpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenButton.Font = Enum.Font.GothamBold
OpenButton.TextSize = 16
OpenButton.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(0, 10)
OpenCorner.Parent = OpenButton

-- Button Functions
OpenButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    OpenButton.Visible = false
end)

CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    OpenButton.Visible = true
end)

CheckButton.MouseButton1Click:Connect(function()
    local result = checkMoveset()
    ResultLabel.Text = result
    ResultLabel.Size = UDim2.new(1, -10, 0, ResultLabel.TextBounds.Y + 20)
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, ResultLabel.TextBounds.Y + 30)
end)

print("JJS Moveset Checker (Mobile) loaded!")
