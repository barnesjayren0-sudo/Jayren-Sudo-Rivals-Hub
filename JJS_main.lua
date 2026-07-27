-- JJS_main.lua
-- Cooldown Off + Auto Blocker + Auto Black Flash + Moveset Checker (Mobile)

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
    else
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                player:SetAttribute("HidePlayer", false)
                if player.Parent == nil then
                    player.Parent = Players
                end
            end
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    if AutoBlocker and player ~= LocalPlayer then
        player:SetAttribute("HidePlayer", true)
    end
end)

-- ====================== AUTO BLACK FLASH ======================
local AutoBlackFlash = false
local BlackFlashConnection = nil

local function getNearestPlayer()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end

    local myPos = character.HumanoidRootPart.Position
    local nearest = nil
    local shortest = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (player.Character.HumanoidRootPart.Position - myPos).Magnitude
            if dist < shortest then
                shortest = dist
                nearest = player
            end
        end
    end
    return nearest, shortest
end

local function doDash()
    pcall(function()
        -- Try MovementService Dash
        local knit = ReplicatedStorage:FindFirstChild("Knit")
        if knit then
            knit = knit:FindFirstChild("Knit")
            if knit then
                local services = knit:FindFirstChild("Services")
                if services then
                    -- MovementService Dash
                    local move = services:FindFirstChild("MovementService")
                    if move then
                        local re = move:FindFirstChild("RE")
                        if re then
                            local dash = re:FindFirstChild("Dash")
                            if dash and dash:IsA("RemoteEvent") then
                                dash:FireServer()
                            end
                            local reset = re:FindFirstChild("ResetDash")
                            if reset and reset:IsA("RemoteEvent") then
                                reset:FireServer()
                            end
                        end
                    end

                    -- ItemService Dash
                    local item = services:FindFirstChild("ItemService")
                    if item then
                        local re = item:FindFirstChild("RE")
                        if re then
                            local dash = re:FindFirstChild("Dash")
                            if dash and dash:IsA("RemoteEvent") then
                                dash:FireServer()
                            end
                        end
                    end
                end
            end
        end
    end)
end

local function toggleBlackFlash(state)
    AutoBlackFlash = state
    if BlackFlashConnection then
        BlackFlashConnection:Disconnect()
        BlackFlashConnection = nil
    end

    if AutoBlackFlash then
        BlackFlashConnection = RunService.Heartbeat:Connect(function()
            local nearest, dist = getNearestPlayer()
            if nearest and dist and dist < 50 then
                -- Face the nearest player then dash
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") and nearest.Character and nearest.Character:FindFirstChild("HumanoidRootPart") then
                    local myHRP = char.HumanoidRootPart
                    local targetHRP = nearest.Character.HumanoidRootPart

                    -- Look at target
                    local direction = (targetHRP.Position - myHRP.Position).Unit
                    myHRP.CFrame = CFrame.lookAt(myHRP.Position, myHRP.Position + direction)

                    -- Dash
                    doDash()
                end
            end
        end)
        print("[JJS] Auto Black Flash: ON")
    else
        print("[JJS] Auto Black Flash: OFF")
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
        for _, child in pairs(movesetFolder:GetChildren()) do
            table.insert(results, "• " .. child.Name)
        end
    else
        table.insert(results, "Could not find Moveset folder!")
    end

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

Instance.new("UICorner", OpenButton).CornerRadius = UDim.new(0, 10)

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0.9, 0, 0.85, 0)
MainFrame.Position = UDim2.new(0.05, 0, 0.08, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.Text = "JJS Hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.Parent = MainFrame

Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 12)

-- Buttons
local function createBtn(text, y, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 42)
    btn.Position = UDim2.new(0.05, 0, 0, y)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 15
    btn.Parent = MainFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

local CooldownBtn = createBtn("Cooldown Off: OFF", 55, Color3.fromRGB(200, 50, 50))
local BlockerBtn = createBtn("Auto Blocker: OFF", 105, Color3.fromRGB(200, 50, 50))
local BlackFlashBtn = createBtn("Auto Black Flash: OFF", 155, Color3.fromRGB(200, 50, 50))
local CheckBtn = createBtn("Check Moveset", 205, Color3.fromRGB(0, 140, 255))

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(0.9, 0, 0, 180)
ScrollFrame.Position = UDim2.new(0.05, 0, 0, 260)
ScrollFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.Parent = MainFrame
Instance.new("UICorner", ScrollFrame).CornerRadius = UDim.new(0, 8)

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

local CloseBtn = createBtn("CLOSE", 0, Color3.fromRGB(80, 80, 80))
CloseBtn.Position = UDim2.new(0.05, 0, 1, -50)

-- ====================== BUTTON EVENTS ======================
OpenButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    OpenButton.Visible = false
end)

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    OpenButton.Visible = true
end)

CooldownBtn.MouseButton1Click:Connect(function()
    local s = not CooldownOff
    toggleCooldownOff(s)
    CooldownBtn.Text = s and "Cooldown Off: ON" or "Cooldown Off: OFF"
    CooldownBtn.BackgroundColor3 = s and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(200, 50, 50)
end)

BlockerBtn.MouseButton1Click:Connect(function()
    local s = not AutoBlocker
    toggleAutoBlocker(s)
    BlockerBtn.Text = s and "Auto Blocker: ON" or "Auto Blocker: OFF"
    BlockerBtn.BackgroundColor3 = s and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(200, 50, 50)
end)

BlackFlashBtn.MouseButton1Click:Connect(function()
    local s = not AutoBlackFlash
    toggleBlackFlash(s)
    BlackFlashBtn.Text = s and "Auto Black Flash: ON" or "Auto Black Flash: OFF"
    BlackFlashBtn.BackgroundColor3 = s and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(200, 50, 50)
end)

CheckBtn.MouseButton1Click:Connect(function()
    local result = checkMoveset()
    ResultLabel.Text = result
    ResultLabel.Size = UDim2.new(1, -10, 0, ResultLabel.TextBounds.Y + 20)
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, ResultLabel.TextBounds.Y + 30)
end)

print("[JJS Hub] Loaded - Cooldown Off | Auto Blocker | Auto Black Flash | Moveset")
