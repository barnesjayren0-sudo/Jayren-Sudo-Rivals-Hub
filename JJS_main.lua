-- JJS_main.lua
-- Moveset Checker + Cooldown Off + Auto Blocker (Mobile)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
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
        CooldownConnection = RunService.Heartbeat:Connect(function()
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

-- ====================== AUTO BLOCKER ======================
local AutoBlocker = false
local BlockerConnection = nil

local function toggleAutoBlocker(state)
    AutoBlocker = state

    if BlockerConnection then
        BlockerConnection:Disconnect()
        BlockerConnection = nil
    end

    if AutoBlocker then
        -- Hide all other players
        BlockerConnection = RunService.Stepped:Connect(function()
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    player:SetAttribute("HidePlayer", true)
                    if player.Parent ~= nil then
                        player.Parent = nil
                    end
                end
            end
        end)
        print("[JJS] Auto Blocker: ON")
    else
        -- Restore players
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                player:SetAttribute("HidePlayer", false)
                if player.Parent == nil then
                    player.Parent = Players
                end
            end
        end
        print("[JJS] Auto Blocker: OFF")
    end
end

-- Also handle new players joining while AutoBlocker is on
Players.PlayerAdded:Connect(function(player)
    if AutoBlocker and player ~= LocalPlayer then
        player:SetAttribute("HidePlayer", true)
    end
end)

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

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0.9, 0, 0.8, 0)
MainFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.Text = "JJS Hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = Title

-- Cooldown Button
local CooldownBtn = Instance.new("TextButton")
CooldownBtn.Size = UDim2.new(0.9, 0, 0, 45)
CooldownBtn.Position = UDim2.new(0.05, 0, 0, 55)
CooldownBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CooldownBtn.Text = "Cooldown Off: OFF"
CooldownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CooldownBtn.Font = Enum.Font.GothamBold
CooldownBtn.TextSize = 16
CooldownBtn.Parent = MainFrame

local CooldownCorner = Instance.new("UICorner")
CooldownCorner.CornerRadius = UDim.new(0, 8)
CooldownCorner.Parent = CooldownBtn

-- Auto Blocker Button
local BlockerBtn = Instance.new("TextButton")
BlockerBtn.Size = UDim2.new(0.9, 0, 0, 45)
BlockerBtn.Position = UDim2.new(0.05, 0, 0, 110)
BlockerBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
BlockerBtn.Text = "Auto Blocker: OFF"
BlockerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
BlockerBtn.Font = Enum.Font.GothamBold
BlockerBtn.TextSize = 16
BlockerBtn.Parent = MainFrame

local BlockerCorner = Instance.new("UICorner")
BlockerCorner.CornerRadius = UDim.new(0, 8)
BlockerCorner.Parent = BlockerBtn

-- Check Moveset Button
local CheckBtn = Instance.new("TextButton")
CheckBtn.Size = UDim2.new(0.9, 0, 0, 45)
CheckBtn.Position = UDim2.new(0.05, 0, 0, 165)
CheckBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
CheckBtn.Text = "Check Moveset"
CheckBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CheckBtn.Font = Enum.Font.GothamBold
CheckBtn.TextSize = 16
CheckBtn.Parent = MainFrame

local CheckCorner = Instance.new("UICorner")
CheckCorner.CornerRadius = UDim.new(0, 8)
CheckCorner.Parent = CheckBtn

-- Results
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(0.9, 0, 0, 200)
ScrollFrame.Position = UDim2.new(0.05, 0, 0, 220)
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
ResultLabel.TextSize = 14
ResultLabel.TextXAlignment = Enum.TextXAlignment.Left
ResultLabel.TextYAlignment = Enum.TextYAlignment.Top
ResultLabel.TextWrapped = true
ResultLabel.Text = "Tap Check Moveset..."
ResultLabel.Parent = ScrollFrame

-- Close
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0.9, 0, 0, 40)
CloseBtn.Position = UDim2.new(0.05, 0, 1, -50)
CloseBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
CloseBtn.Text = "CLOSE"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 15
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

BlockerBtn.MouseButton1Click:Connect(function()
    local newState = not AutoBlocker
    toggleAutoBlocker(newState)
    if newState then
        BlockerBtn.Text = "Auto Blocker: ON"
        BlockerBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
    else
        BlockerBtn.Text = "Auto Blocker: OFF"
        BlockerBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)

CheckBtn.MouseButton1Click:Connect(function()
    local result = checkMoveset()
    ResultLabel.Text = result
    ResultLabel.Size = UDim2.new(1, -10, 0, ResultLabel.TextBounds.Y + 20)
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, ResultLabel.TextBounds.Y + 30)
end)

print("[JJS Hub] Loaded - Cooldown Off + Auto Blocker + Moveset Checker")
