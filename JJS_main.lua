-- JJS Hub v1.1
-- Cooldown Off | Auto Blocker | Auto Black Flash (Back) | Moveset Checker
-- Mobile Optimized

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- States
local CooldownOff = false
local AutoBlocker = false
local AutoBlackFlash = false

local CooldownConnection = nil
local BlockerConnection = nil
local BlackFlashConnection = nil
local lastDash = 0

-- ====================== HELPERS ======================
local function getKnitServices()
    local knit = ReplicatedStorage:FindFirstChild("Knit")
    if not knit then return nil end
    knit = knit:FindFirstChild("Knit")
    if not knit then return nil end
    return knit:FindFirstChild("Services")
end

local function fireRemote(pathTable)
    -- pathTable example: {"MovementService", "RE", "Dash"}
    pcall(function()
        local services = getKnitServices()
        if not services then return end

        local current = services
        for _, name in ipairs(pathTable) do
            current = current:FindFirstChild(name)
            if not current then return end
        end

        if current:IsA("RemoteEvent") then
            current:FireServer()
        elseif current:IsA("BindableEvent") then
            current:Fire()
        end
    end)
end

-- ====================== COOLDOWN OFF ======================
local function toggleCooldownOff(state)
    CooldownOff = state
    if CooldownConnection then
        CooldownConnection:Disconnect()
        CooldownConnection = nil
    end

    if CooldownOff then
        CooldownConnection = RunService.Heartbeat:Connect(function()
            pcall(function()
                local keybind = ReplicatedStorage:FindFirstChild("Keybind")
                if keybind then
                    local creator = keybind:FindFirstChild("Creator")
                    if creator then
                        local reset = creator:FindFirstChild("Reset Cooldowns")
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

-- ====================== AUTO BLACK FLASH (BACK) ======================
local function getNearestPlayer()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local nearest, shortest = nil, 55

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local thrp = player.Character:FindFirstChild("HumanoidRootPart")
            if thrp then
                local dist = (thrp.Position - hrp.Position).Magnitude
                if dist < shortest then
                    shortest = dist
                    nearest = player
                end
            end
        end
    end
    return nearest
end

local function doDash()
    fireRemote({"MovementService", "RE", "Dash"})
    fireRemote({"MovementService", "RE", "ResetDash"})
    fireRemote({"ItemService", "RE", "Dash"})
end

local function toggleBlackFlash(state)
    AutoBlackFlash = state
    if BlackFlashConnection then
        BlackFlashConnection:Disconnect()
        BlackFlashConnection = nil
    end

    if AutoBlackFlash then
        BlackFlashConnection = RunService.Heartbeat:Connect(function()
            if tick() - lastDash < 0.4 then return end

            local target = getNearestPlayer()
            if not target or not target.Character then return end

            local char = LocalPlayer.Character
            if not char then return end

            local myHRP = char:FindFirstChild("HumanoidRootPart")
            local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
            if not myHRP or not targetHRP then return end

            -- Position behind the target (their back)
            local backCF = targetHRP.CFrame * CFrame.new(0, 0, 3.5)
            myHRP.CFrame = CFrame.lookAt(backCF.Position, targetHRP.Position)

            doDash()
            lastDash = tick()
        end)
    end
end

-- ====================== MOVESET CHECKER ======================
local function checkMoveset()
    local lines = {
        "===== JJS Moveset Checker =====",
        "Player: " .. LocalPlayer.Name,
        ""
    }

    local success, folder = pcall(function()
        return LocalPlayer.PlayerScripts.Controllers.Moveset
    end)

    if success and folder then
        table.insert(lines, "Characters:")
        for _, child in ipairs(folder:GetChildren()) do
            table.insert(lines, "• " .. child.Name)
        end
    else
        table.insert(lines, "Moveset folder not found")
    end

    table.insert(lines, "===============================")
    return table.concat(lines, "\n")
end

-- ====================== GUI ======================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JJS_Hub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 125, 0, 42)
OpenBtn.Position = UDim2.new(0, 12, 0.5, -21)
OpenBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
OpenBtn.Text = "JJS Hub"
OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.TextSize = 15
OpenBtn.Parent = ScreenGui
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 10)

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0.88, 0, 0.82, 0)
Main.Position = UDim2.new(0.06, 0, 0.09, 0)
Main.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
Main.BorderSizePixel = 0
Main.Visible = false
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 48)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Text = "JJS Hub  v1.1"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.Parent = Main
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 14)

local function makeButton(text, yPos, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.9, 0, 0, 44)
    b.Position = UDim2.new(0.05, 0, 0, yPos)
    b.BackgroundColor3 = color
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 15
    b.Parent = Main
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 9)
    return b
end

local CooldownBtn   = makeButton("Cooldown Off: OFF", 60, Color3.fromRGB(180, 45, 45))
local BlockerBtn    = makeButton("Auto Blocker: OFF", 115, Color3.fromRGB(180, 45, 45))
local BlackFlashBtn = makeButton("Auto Black Flash: OFF", 170, Color3.fromRGB(180, 45, 45))
local CheckBtn      = makeButton("Check Moveset", 225, Color3.fromRGB(0, 130, 220))

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(0.9, 0, 0, 175)
Scroll.Position = UDim2.new(0.05, 0, 0, 280)
Scroll.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
Scroll.ScrollBarThickness = 5
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.Parent = Main
Instance.new("UICorner", Scroll).CornerRadius = UDim.new(0, 9)

local Result = Instance.new("TextLabel")
Result.Size = UDim2.new(1, -12, 0, 0)
Result.Position = UDim2.new(0, 6, 0, 6)
Result.BackgroundTransparency = 1
Result.TextColor3 = Color3.fromRGB(210, 210, 210)
Result.Font = Enum.Font.Gotham
Result.TextSize = 14
Result.TextXAlignment = Enum.TextXAlignment.Left
Result.TextYAlignment = Enum.TextYAlignment.Top
Result.TextWrapped = true
Result.Text = "Ready..."
Result.Parent = Scroll

local CloseBtn = makeButton("CLOSE", 0, Color3.fromRGB(70, 70, 70))
CloseBtn.Position = UDim2.new(0.05, 0, 1, -55)

-- ====================== EVENTS ======================
OpenBtn.MouseButton1Click:Connect(function()
    Main.Visible = true
    OpenBtn.Visible = false
end)

CloseBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
    OpenBtn.Visible = true
end)

local function updateToggle(btn, state, onText, offText)
    btn.Text = state and onText or offText
    btn.BackgroundColor3 = state and Color3.fromRGB(0, 170, 70) or Color3.fromRGB(180, 45, 45)
end

CooldownBtn.MouseButton1Click:Connect(function()
    toggleCooldownOff(not CooldownOff)
    updateToggle(CooldownBtn, CooldownOff, "Cooldown Off: ON", "Cooldown Off: OFF")
end)

BlockerBtn.MouseButton1Click:Connect(function()
    toggleAutoBlocker(not AutoBlocker)
    updateToggle(BlockerBtn, AutoBlocker, "Auto Blocker: ON", "Auto Blocker: OFF")
end)

BlackFlashBtn.MouseButton1Click:Connect(function()
    toggleBlackFlash(not AutoBlackFlash)
    updateToggle(BlackFlashBtn, AutoBlackFlash, "Auto Black Flash: ON", "Auto Black Flash: OFF")
end)

CheckBtn.MouseButton1Click:Connect(function()
    local text = checkMoveset()
    Result.Text = text
    Result.Size = UDim2.new(1, -12, 0, Result.TextBounds.Y + 15)
    Scroll.CanvasSize = UDim2.new(0, 0, 0, Result.TextBounds.Y + 25)
end)

print("[JJS Hub v1.1] Loaded successfully")
