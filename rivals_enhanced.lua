-- ⚡ ULTIMATE RIVALS HUB v2.5 - Enhanced Edition ⚡
-- Advanced Aimbot + ESP + Combat + Movement + Anti-Ban
-- Press Right Shift to open GUI | Press Insert for quick toggle

getgenv().UltimateConfig = {
    -- Aimbot Settings
    Aimbot = {
        Enabled = false,
        FOV = 120,
        Smooth = 0.05,
        TargetPriority = "Closest", -- Closest, Furthest, LowestHealth, HighestHealth
        AimPart = "Head", -- Head, HumanoidRootPart, Torso, Random
        Prediction = 0.12,
        Jitter = 0.03,
        Silent = true,
        VisibleCheck = true,
        TeamCheck = true,
        FOVShape = "Circle", -- Circle, Square
        FOVFilled = false,
        FOVColor = Color3.fromRGB(0, 255, 0),
    },
    
    -- ESP Settings
    ESP = {
        Enabled = true,
        TeamCheck = true,
        Boxes = true,
        Tracers = true,
        HealthBars = true,
        Names = true,
        Distance = true,
        Skeleton = false,
        Chams = false,
        BoxColor = Color3.fromRGB(255, 0, 0),
        TracerColor = Color3.fromRGB(0, 255, 0),
        HealthColor = Color3.fromRGB(0, 255, 0),
        NameColor = Color3.fromRGB(255, 255, 255),
    },
    
    -- Combat Settings
    Combat = {
        AutoFire = false,
        TriggerBot = false,
        RecoilControl = false,
        RapidFire = false,
        InfiniteAmmo = false,
    },
    
    -- Movement Settings
    Movement = {
        SpeedEnabled = false,
        SpeedMultiplier = 1.5,
        JumpEnabled = false,
        JumpPower = 50,
        FlightEnabled = false,
        FlightSpeed = 1,
        NoClip = false,
    },
    
    -- Visual Settings
    Visual = {
        FOVCircle = true,
        Crosshair = true,
        CustomCrosshair = false,
        CrosshairSize = 10,
        CrosshairColor = Color3.fromRGB(255, 255, 255),
        FullBright = false,
        NightMode = false,
    },
    
    -- Anti-Detection
    AntiBan = {
        AntiKick = true,
        AntiCheatBypass = true,
        NameSpoof = false,
        SpoofName = "Guest 666",
        AntiAFK = true,
    },
    
    -- Macro System
    Macros = {
        Enabled = false,
        Key1 = Enum.KeyCode.Z,
        Key2 = Enum.KeyCode.X,
        Key3 = Enum.KeyCode.C,
    }
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ESP Storage
local espCache = {}
local drawingCache = {}

-- Anti-Kick System
task.spawn(function()
    local mt = getrawmetamethod(game, "__namecall")
    local oldNamecall = mt
    hookmetamethod(game, "__namecall", function(self, ...)
        local args = {...}
        local method = getnamecallmethod()
        
        if getgenv().UltimateConfig.AntiBan.AntiKick then
            if method == "Kick" or string.find(tostring(self):lower(), "kick") or 
               (method == "FireServer" and string.find(tostring(args[1] or ""):lower(), "kick")) then
                return
            end
        end
        
        return oldNamecall(self, ...)
    end)
end)

-- Anti-AFK System
if getgenv().UltimateConfig.AntiBan.AntiAFK then
    local VirtualUser = game:GetService("VirtualUser")
    game:GetService("Players").LocalPlayer.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end

-- Advanced ESP System
function createESP(player)
    if player == LocalPlayer then return end
    
    espCache[player] = {
        Box = Drawing.new("Square"),
        Tracer = Drawing.new("Line"),
        HealthBar = Drawing.new("Line"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        Skeleton = {},
    }
    
    local esp = espCache[player]
    
    -- Configure Box
    esp.Box.Thickness = 1
    esp.Box.Color = getgenv().UltimateConfig.ESP.BoxColor
    esp.Box.Filled = false
    esp.Box.Transparency = 0.8
    
    -- Configure Tracer
    esp.Tracer.Thickness = 1
    esp.Tracer.Color = getgenv().UltimateConfig.ESP.TracerColor
    esp.Tracer.Transparency = 0.5
    
    -- Configure Health Bar
    esp.HealthBar.Thickness = 2
    esp.HealthBar.Color = getgenv().UltimateConfig.ESP.HealthColor
    esp.HealthBar.Transparency = 0.3
    
    -- Configure Name
    esp.Name.Size = 13
    esp.Name.Color = getgenv().UltimateConfig.ESP.NameColor
    esp.Name.Center = true
    esp.Name.Outline = true
    
    -- Configure Distance
    esp.Distance.Size = 12
    esp.Distance.Color = Color3.fromRGB(255, 255, 255)
    esp.Distance.Center = true
    esp.Distance.Outline = true
    
    -- Create Skeleton if enabled
    if getgenv().UltimateConfig.ESP.Skeleton then
        local joints = {"LeftShoulder", "RightShoulder", "LeftHip", "RightHip", "Head", "HumanoidRootPart"}
        for _, joint in ipairs(joints) do
            esp.Skeleton[joint] = Drawing.new("Line")
            esp.Skeleton[joint].Thickness = 1
            esp.Skeleton[joint].Color = Color3.fromRGB(255, 255, 255)
            esp.Skeleton[joint].Transparency = 0.6
        end
    end
end

function updateESP(player)
    local esp = espCache[player]
    if not esp then return end
    
    local character = player.Character
    local humanoid = character and character:FindFirstChild("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local head = character and character:FindFirstChild("Head")
    
    if not character or not humanoid or not root or not head then
        hideESP(player)
        return
    end
    
    -- Team Check
    if getgenv().UltimateConfig.ESP.TeamCheck and player.Team == LocalPlayer.Team then
        hideESP(player)
        return
    end
    
    -- Get Screen Position
    local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
    local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
    local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
    
    if not onScreen then
        hideESP(player)
        return
    end
    
    -- Calculate Distance
    local distance = (Camera.CFrame.Position - root.Position).Magnitude
    local scaleFactor = 1000 / distance
    
    -- Update Box
    if getgenv().UltimateConfig.ESP.Boxes then
        esp.Box.Size = Vector2.new(scaleFactor * 0.8, scaleFactor * 2)
        esp.Box.Position = Vector2.new(rootPos.X - scaleFactor * 0.4, headPos.Y)
        esp.Box.Visible = getgenv().UltimateConfig.ESP.Enabled
    else
        esp.Box.Visible = false
    end
    
    -- Update Tracer
    if getgenv().UltimateConfig.ESP.Tracers then
        esp.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        esp.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
        esp.Tracer.Visible = getgenv().UltimateConfig.ESP.Enabled
    else
        esp.Tracer.Visible = false
    end
    
    -- Update Health Bar
    if getgenv().UltimateConfig.ESP.HealthBars and humanoid then
        local healthPercent = humanoid.Health / humanoid.MaxHealth
        esp.HealthBar.From = Vector2.new(rootPos.X - scaleFactor * 0.5, legPos.Y)
        esp.HealthBar.To = Vector2.new(rootPos.X - scaleFactor * 0.5, legPos.Y - (scaleFactor * 2 * healthPercent))
        esp.HealthBar.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
        esp.HealthBar.Visible = getgenv().UltimateConfig.ESP.Enabled
    else
        esp.HealthBar.Visible = false
    end
    
    -- Update Name
    if getgenv().UltimateConfig.ESP.Names then
        esp.Name.Text = player.Name
        esp.Name.Position = Vector2.new(rootPos.X, headPos.Y - 15)
        esp.Name.Visible = getgenv().UltimateConfig.ESP.Enabled
    else
        esp.Name.Visible = false
    end
    
    -- Update Distance
    if getgenv().UltimateConfig.ESP.Distance then
        esp.Distance.Text = string.format("%.0f studs", distance)
        esp.Distance.Position = Vector2.new(rootPos.X, legPos.Y + 15)
        esp.Distance.Visible = getgenv().UltimateConfig.ESP.Enabled
    else
        esp.Distance.Visible = false
    end
    
    -- Update Skeleton
    if getgenv().UltimateConfig.ESP.Skeleton then
        for jointName, line in pairs(esp.Skeleton) do
            local joint = character:FindFirstChild(jointName)
            if joint then
                local jointPos = Camera:WorldToViewportPoint(joint.Position)
                line.From = Vector2.new(rootPos.X, rootPos.Y)
                line.To = Vector2.new(jointPos.X, jointPos.Y)
                line.Visible = getgenv().UltimateConfig.ESP.Enabled
            end
        end
    end
end

function hideESP(player)
    local esp = espCache[player]
    if not esp then return end
    
    esp.Box.Visible = false
    esp.Tracer.Visible = false
    esp.HealthBar.Visible = false
    esp.Name.Visible = false
    esp.Distance.Visible = false
    
    for _, line in pairs(esp.Skeleton) do
        line.Visible = false
    end
end

-- Initialize ESP for existing players
for _, player in pairs(Players:GetPlayers()) do
    createESP(player)
end

Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(function(player)
    if espCache[player] then
        hideESP(player)
        espCache[player] = nil
    end
end)

-- Advanced Aimbot System
local currentTarget = nil
local aimPart = nil

function getTarget()
    local closestPlayer = nil
    local closestDistance = getgenv().UltimateConfig.Aimbot.FOV
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            -- Team Check
            if getgenv().UltimateConfig.Aimbot.TeamCheck and player.Team == LocalPlayer.Team then
                continue
            end
            
            local character = player.Character
            local aimPartName = getgenv().UltimateConfig.Aimbot.AimPart
            
            -- Random bone selection
            if aimPartName == "Random" then
                local bones = {"Head", "HumanoidRootPart", "Torso"}
                aimPartName = bones[math.random(1, #bones)]
            end
            
            local targetPart = character:FindFirstChild(aimPartName)
            if not targetPart then continue end
            
            -- Visible Check
            if getgenv().UltimateConfig.Aimbot.VisibleCheck then
                local raycastParams = RaycastParams.new()
                raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, character}
                raycastParams.FilterType = Enum.RaycastFilterType.Exclude
                local rayResult = workspace:Raycast(Camera.CFrame.Position, targetPart.Position - Camera.CFrame.Position, raycastParams)
                if rayResult and rayResult.Instance ~= targetPart then
                    continue
                end
            end
            
            -- Get screen position
            local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
            if not onScreen then continue end
            
            -- Calculate distance from crosshair
            local mousePos = Vector2.new(Mouse.X, Mouse.Y)
            local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
            
            -- Check if within FOV
            if distance < closestDistance then
                closestDistance = distance
                closestPlayer = player
                aimPart = targetPart
            end
        end
    end
    
    return closestPlayer, aimPart
end

function applyAimbot()
    if not getgenv().UltimateConfig.Aimbot.Enabled then return end
    
    local target, targetPart = getTarget()
    if not target or not targetPart then return end
    
    local character = target.Character
    local humanoid = character and character:FindFirstChild("Humanoid")
    
    if character and targetPart then
        -- Predict movement
        local predictedPos = targetPart.Position
        if getgenv().UltimateConfig.Aimbot.Prediction > 0 and humanoid then
            predictedPos = predictedPos + (targetPart.Velocity * getgenv().UltimateConfig.Aimbot.Prediction)
        end
        
        -- Add jitter
        if getgenv().UltimateConfig.Aimbot.Jitter > 0 then
            local jitterX = math.random(-100, 100) / 10000
            local jitterY = math.random(-100, 100) / 10000
            predictedPos = predictedPos + Vector3.new(jitterX, jitterY, 0)
        end
        
        -- Smooth aiming
        local currentCFrame = Camera.CFrame
        local targetCFrame = CFrame.lookAt(currentCFrame.Position, predictedPos)
        
        if getgenv().UltimateConfig.Aimbot.Silent then
            -- Silent aim - no camera movement
            currentTarget = targetPart
        else
            -- Visible smooth aim
            local smoothedCFrame = currentCFrame:Lerp(targetCFrame, getgenv().UltimateConfig.Aimbot.Smooth)
            Camera.CFrame = smoothedCFrame
        end
    end
end

-- Silent Aim Implementation
local oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if getgenv().UltimateConfig.Aimbot.Enabled and getgenv().UltimateConfig.Aimbot.Silent then
        if method == "FindPartOnRayWithIgnoreList" or method == "Raycast" then
            if currentTarget and getgenv().UltimateConfig.Aimbot.Enabled then
                local predictedPos = currentTarget.Position
                if getgenv().UltimateConfig.Aimbot.Prediction > 0 then
                    predictedPos = predictedPos + (currentTarget.Velocity * getgenv().UltimateConfig.Aimbot.Prediction)
                end
                
                if method == "FindPartOnRayWithIgnoreList" then
                    args[1] = Ray.new(Camera.CFrame.Position, (predictedPos - Camera.CFrame.Position).Unit * 8000)
                elseif method == "Raycast" then
                    args[1] = Camera.CFrame.Position
                    args[2] = (predictedPos - Camera.CFrame.Position).Unit * 8000
                end
                
                return oldNamecall(self, unpack(args))
            end
        end
    end
    
    return oldNamecall(self, ...)
end)

-- Movement Functions
function applyMovement()
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChild("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not root then return end
    
    -- Speed Boost
    if getgenv().UltimateConfig.Movement.SpeedEnabled then
        humanoid.WalkSpeed = 16 * getgenv().UltimateConfig.Movement.SpeedMultiplier
    else
        humanoid.WalkSpeed = 16
    end
    
    -- Jump Boost
    if getgenv().UltimateConfig.Movement.JumpEnabled then
        humanoid.UseJumpPower = true
        humanoid.JumpPower = getgenv().UltimateConfig.Movement.JumpPower
    else
        humanoid.JumpPower = 50
    end
    
    -- Flight
    if getgenv().UltimateConfig.Movement.FlightEnabled then
        local flySpeed = getgenv().UltimateConfig.Movement.FlightSpeed
        local flying = true
        
        spawn(function()
            while flying and getgenv().UltimateConfig.Movement.FlightEnabled do
                wait()
                if humanoid.MoveDirection.Magnitude > 0 then
                    root.CFrame = root.CFrame + (humanoid.MoveDirection * flySpeed)
                end
            end
        end)
    end
    
    -- NoClip
    if getgenv().UltimateConfig.Movement.NoClip then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end

-- Combat Functions
function applyCombat()
    local mouse = LocalPlayer:GetMouse()
    
    -- Auto Fire
    if getgenv().UltimateConfig.Combat.AutoFire and getgenv().UltimateConfig.Aimbot.Enabled and currentTarget then
        mouse1press()
        wait(0.05)
        mouse1release()
    end
end

-- Visual Functions
function applyVisual()
    local viewport = Camera.ViewportSize
    
    -- Full Bright
    if getgenv().UltimateConfig.Visual.FullBright then
        game:GetService("Lighting").Brightness = 3
        game:GetService("Lighting").OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    else
        game:GetService("Lighting").Brightness = 2
        game:GetService("Lighting").OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    end
    
    -- Night Mode
    if getgenv().UltimateConfig.Visual.NightMode then
        game:GetService("Lighting").Brightness = 0.5
        game:GetService("Lighting").OutdoorAmbient = Color3.fromRGB(20, 20, 20)
    end
end

-- GUI System
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = game:GetService("CoreGui")
screenGui.Name = "UltimateRivalsHub"

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 300)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
mainFrame.Visible = false

local titleBar = Instance.new("TextLabel")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
titleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
titleBar.Text = "⚡ ULTIMATE RIVALS HUB v2.5 ⚡"
titleBar.Font = Enum.Font.GothamBold
titleBar.TextSize = 16
titleBar.Parent = mainFrame

local contentFrame = Instance.new("ScrollingFrame")
contentFrame.Size = UDim2.new(1, 0, 1, -30)
contentFrame.Position = UDim2.new(0, 0, 0, 30)
contentFrame.BackgroundTransparency = 1
contentFrame.ScrollBarThickness = 4
contentFrame.Parent = mainFrame

function createToggle(name, section, key)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 25)
    frame.Position = UDim2.new(0, 10, 0, #contentFrame:GetChildren() * 28)
    frame.BackgroundTransparency = 1
    frame.Parent = contentFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Text = name
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.25, 0, 0.8, 0)
    button.Position = UDim2.new(0.7, 0, 0.1, 0)
    button.BackgroundColor3 = getgenv().UltimateConfig[section][key] and Color3.fromRGB(0, 200, 0) : Color3.fromRGB(200, 0, 0)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Text = getgenv().UltimateConfig[section][key] and "ON" or "OFF"
    button.Font = Enum.Font.GothamBold
    button.TextSize = 12
    button.Parent = frame
    
    button.MouseButton1Click:Connect(function()
        getgenv().UltimateConfig[section][key] = not getgenv().UltimateConfig[section][key]
        button.BackgroundColor3 = getgenv().UltimateConfig[section][key] and Color3.fromRGB(0, 200, 0) : Color3.fromRGB(200, 0, 0)
        button.Text = getgenv().UltimateConfig[section][key] and "ON" or "OFF"
    end)
end

-- Create Toggles
createToggle("Aimbot Enabled", "Aimbot", "Enabled")
createToggle("ESP Enabled", "ESP", "Enabled")
createToggle("Auto Fire", "Combat", "AutoFire")
createToggle("Speed Boost", "Movement", "SpeedEnabled")
createToggle("Jump Boost", "Movement", "JumpEnabled")
createToggle("Flight Mode", "Movement", "FlightEnabled")
createToggle("NoClip", "Movement", "NoClip")
createToggle("Full Bright", "Visual", "FullBright")
createToggle("Night Mode", "Visual", "NightMode")
createToggle("Anti-Kick", "AntiBan", "AntiKick")
createToggle("Anti-AFK", "AntiBan", "AntiAFK")

contentFrame.CanvasSize = UDim2.new(0, 0, 0, #contentFrame:GetChildren() * 28)

-- Keybinds
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Toggle GUI
    if input.KeyCode == Enum.KeyCode.RightShift then
        mainFrame.Visible = not mainFrame.Visible
    end
    
    -- Quick Toggle
    if input.KeyCode == Enum.KeyCode.Insert then
        getgenv().UltimateConfig.Aimbot.Enabled = not getgenv().UltimateConfig.Aimbot.Enabled
        print("Aimbot:", getgenv().UltimateConfig.Aimbot.Enabled and "ON" or "OFF")
    end
end)

-- Main Loop
RunService.RenderStepped:Connect(function()
    -- Update ESP
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            updateESP(player)
        end
    end
    
    -- Apply Aimbot
    applyAimbot()
    
    -- Apply Movement
    applyMovement()
    
    -- Apply Combat
    applyCombat()
    
    -- Apply Visual
    applyVisual()
end)

print("⚡ ULTIMATE RIVALS HUB v2.5 LOADED ⚡")
print("Press Right Shift to open GUI")
print("Press Insert for quick aimbot toggle")
print("Enhanced features activated!")