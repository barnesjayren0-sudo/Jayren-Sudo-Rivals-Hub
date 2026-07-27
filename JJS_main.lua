-- JJS_main.lua
-- Moveset Checker + Cooldown Off (Mobile)
-- Path: Players.LocalPlayer.PlayerScripts.Controllers.Moveset

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

-- ====================== COOLDOWN OFF ======================
local CooldownOff = false
local CooldownConnection = nil

local function toggleCooldownOff(state)
    CooldownOff = state

    if CooldownConnection then
        CooldownConnection:Disconnect()
        CooldownConnection = nil
    end

    if CooldownOff then
        -- Spam reset cooldowns
        CooldownConnection = game:GetService("RunService").Heartbeat:Connect(function()
            pcall(function()
                local reset = ReplicatedStorage:FindFirstChild("Keybind")
                if reset then
                    reset = reset:FindFirstChild("Creator")
                    if reset then
                        reset = reset:FindFirstChild("Reset Cooldowns")
                        if reset then
                            if reset:IsA("RemoteEvent") then
                                reset:FireServer()
                            elseif reset:IsA("BindableEvent") then
                                reset:Fire()
                            end
                        end
                    end
                end
            end)
        end)
        print("[JJS] Cooldown Off: ON")
    else
        print("[JJS] Cooldown Off: OFF")
    end
end

-- ====================== MOVESET CHECKER ======================
local function checkMoveset()
    local results = {}
    table.insert(results, "===== JJS Moveset Checker =====")
    table.insert(results, "Player: " .. LocalPlayer.Name)
    table.insert(results, "")

    local success, movesetFolder = pcall(function()
        return LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("Controllers"):WaitForChild("Moveset")
    end)

    if success and movesetFolder then
        table.insert(results, "Moveset Folder Found!")
        table.insert(results, "")
        table.insert(results, "Characters:")

        local children = movesetFolder:GetChildren()
        if #children == 0 then
            table.insert(results, "(Empty)")
        else
            for _, child in pairs(children) do
                table.insert(results, "• " .. child.Name)
                for _, sub in pairs(child:GetChildren()) do
                    table.insert(results, "    - " .. sub.Name)
                end
            end
        end
    else
        table.insert(results, "Could not find Moveset folder!")
    end

    table.insert(results, "")
    table.insert(results, "===============================")
    return table.concat(results, "\n")
end

-- ====================== MOBILE GUI ======================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JJS_Hub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- Open Button
local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.new(0, 130, 0, 45)
OpenButton.Position = UDim2.new(0, 15, 0.5, -22)
OpenButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
OpenButton.Text = "JJS Hub"
OpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenButton.Font = Enum.Font.GothamBold
OpenButton.TextSize = 16
OpenButton.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(0, 10)
OpenCorner.Parent = OpenButton

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0.9, 0, 0.75, 0)
MainFrame.Position = UDim2.new(0.05, 0, 0.12, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.Text = "JJS Hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 22
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = Title

-- Cooldown Toggle Button
local CooldownBtn = Instance.new("TextButton")
CooldownBtn.Size = UDim2.new(0.9, 0, 0, 50)
CooldownBtn.Position = UDim2.new(0.05, 0, 0, 70)
CooldownBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CooldownBtn.Text = "Cooldown Off: OFF"
CooldownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CooldownBtn.Font = Enum.Font.GothamBold
CooldownBtn.TextSize = 18
CooldownBtn.Parent = MainFrame

local CooldownCorner = Instance.new("UICorner")
CooldownCorner.CornerRadius = UDim.new(0, 8)
CooldownCorner.Parent = CooldownBtn

-- Check Moveset Button
local CheckBtn = Instance.new("TextButton")
CheckBtn.Size = UDim2.new(0.9, 0, 0, 50)
CheckBtn.Position = UDim2.new(0.05, 0, 0, 135)
CheckBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
CheckBtn.Text = "Check Moveset"
CheckBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CheckBtn.Font = Enum.Font.GothamBold
CheckBtn.TextSize = 18
CheckBtn.Parent = MainFrame

local CheckCorner = Instance.new("UICorner")
CheckCorner.CornerRadius = UDim.new(0, 8)
CheckCorner.Parent = CheckBtn

-- Results Scroll
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(0.9, 0, 0, 220)
ScrollFrame.Position = UDim2.new(0.05, 0, 0, 200)
ScrollFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.Parent = MainFrame

local ScrollCorner = Instance.new("UICorner")
ScrollCorner.CornerRadius = UDim.new(0, 8)
ScrollCorner.Parent = ScrollFrame

local ResultLabel = Instance.new("TextLabel")
ResultLabel.Size = UDim2.new(1, -10, 0, 0)
ResultLabel.Position = UDim2.new(0, 5, 0, 5)
ResultLabel.BackgroundTransparency = 1
ResultLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
ResultLabel.Font = Enum.Font.Gotham
ResultLabel.TextSize = 15
ResultLabel.TextXAlignment = Enum.TextXAlignment.Left
ResultLabel.TextYAlignment = Enum.TextYAlignment.Top
ResultLabel.TextWrapped = true
ResultLabel.Text = "Tap Check Moveset to scan..."
ResultLabel.Parent = ScrollFrame

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0.9, 0, 0, 45)
CloseBtn.Position = UDim2.new(0.05, 0, 1, -55)
CloseBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
CloseBtn.Text = "CLOSE"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

-- ====================== BUTTONS ======================
OpenButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    OpenButton.Visible = false
end)

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    OpenButton.Visible = true
end)

CooldownBtn.MouseButton1Click:Connect(function()
    local newState = not CooldownOff
    toggleCooldownOff(newState)

    if newState then
        CooldownBtn.Text = "Cooldown Off: ON"
        CooldownBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
    else
        CooldownBtn.Text = "Cooldown Off: OFF"
        CooldownBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)

CheckBtn.MouseButton1Click:Connect(function()
    local result = checkMoveset()
    ResultLabel.Text = result
    ResultLabel.Size = UDim2.new(1, -10, 0, ResultLabel.TextBounds.Y + 20)
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, ResultLabel.TextBounds.Y + 30)
end)

print("[JJS Hub] Loaded - Cooldown Off + Moveset Checker")
