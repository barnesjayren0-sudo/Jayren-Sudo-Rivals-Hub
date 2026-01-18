-- Jayren Sudo Rivals Hub v1.8 STEALTH ULTIMATE - 2026 Fluxus Z VNG Anti-Kick God 🔥
-- Legit Smooth Lerp 0.08 + 100 FOV + Pixel ESP + Velocity Predict + Jitter Random + Kick Block

getgenv().HubConfig = {Enabled = false, FOV = 100, Smooth = 0.08, TeamCheck = true, Predict = true}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ULTIMATE Anti-Kick (blocks all kick methods + remote spy)
task.spawn(function()
    local mt = getrawmetamethod(game, "__namecall")
    local oldNamecall = mt
    hookmetamethod(game, "__namecall", function(self, ...)
        local args = {...}
        local method = getnamecallmethod()
        if (method == "Kick" or string.find(tostring(self), "Kick") or method == "FireServer" and string.find(args[1] or "", "kick")) then
            return -- Total block
        end
        return oldNamecall(self, ...)
    end)
end)

-- Q Toggle (double-tap safe)
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Q then
        getgenv().HubConfig.Enabled = not getgenv().HubConfig.Enabled
        print("Jayren v1.8 Stealth: " .. (getgenv().HubConfig.Enabled and "ON - Invisible God 🔥" or "OFF - Ghost"))
    end
end)

-- Pixel-Thin ESP (spawn delay + subtle)
task.wait(2) -- Anti-sniff delay
local espBoxes = {}
local function createESP(plr)
    if plr == LocalPlayer or getgenv().HubConfig.TeamCheck and plr.Team == LocalPlayer.Team then return end
    local box = Drawing.new("Square")
    box.Thickness = 1 -- Pixel thin
    box.Color = Color3.fromRGB(200, 50, 50) -- Faint red
    box.Filled = false
    box.Transparency = 0.95 -- Barely visible
    espBoxes[plr] = box
end
for _, plr in Players:GetPlayers() do createESP(plr) end
Players.PlayerAdded:Connect(createESP)

RunService.RenderStepped:Connect(function()
    for plr, box in pairs(espBoxes) do
        local char = plr.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local root = char.HumanoidRootPart
            local pos, visible = Camera:WorldToViewportPoint(root.Position)
            if visible then
                local size = 800 / pos.Z
                box.Size = Vector2.new(size * 0.7, size * 1.8)
                box.Position = Vector2.new(pos.X - size * 0.35, pos.Y - size * 0.9)
                box.Visible = getgenv().HubConfig.Enabled
            else
                box.Visible = false
            end
        else
            box.Visible = false
        end
    end
end)

-- INVISIBLE Silent Aim (lerp smooth + predict + jitter)
local oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    if getgenv().HubConfig.Enabled and self == workspace and getnamecallmethod() == "FindPartOnRayWithIgnoreList" then
        local closestHead = nil
        local minDist = getgenv().HubConfig.FOV
        for _, plr in Players:GetPlayers() do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                local head = plr.Character.Head
                local jitter = Vector3.new(math.random(-2,2)/100, math.random(-2,2)/100, 0) -- Human jitter
                local predictPos = head.Position + (head.Velocity * 0.1) + jitter
                local screenPos, onScreen = Camera:WorldToViewportPoint(predictPos)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    if dist < minDist then
                        minDist = dist
                        closestHead = predictPos
                    end
                end
            end
        end
        if closestHead then
            local smoothDir = Camera.CFrame:VectorToWorldSpace((Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Unit * getgenv().HubConfig.Smooth)
            args[1] = Ray.new(Camera.CFrame.Position, (closestHead - Camera.CFrame.Position).Unit * 8000 + smoothDir)
            return oldNamecall(self, unpack(args))
        end
    end
    return oldNamecall(self, ...)
end)

print("Jayren Stealth Hub v1.8 ULTIMATE Loaded - Q toggle | Legit smooth | Pixel ESP | FULL Anti-Kick 🔴 Fluxus Z VNG SLAY!")-- Jayren Sudo Rivals Hub v1.8 STEALTH ULTIMATE - 2026 Fluxus Z VNG Anti-Kick God 🔥
-- Legit Smooth Lerp 0.08 + 100 FOV + Pixel ESP + Velocity Predict + Jitter Random + Kick Block

getgenv().HubConfig = {Enabled = false, FOV = 100, Smooth = 0.08, TeamCheck = true, Predict = true}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ULTIMATE Anti-Kick (blocks all kick methods + remote spy)
task.spawn(function()
    local mt = getrawmetamethod(game, "__namecall")
    local oldNamecall = mt
    hookmetamethod(game, "__namecall", function(self, ...)
        local args = {...}
        local method = getnamecallmethod()
        if (method == "Kick" or string.find(tostring(self), "Kick") or method == "FireServer" and string.find(args[1] or "", "kick")) then
            return -- Total block
        end
        return oldNamecall(self, ...)
    end)
end)

-- Q Toggle (double-tap safe)
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Q then
        getgenv().HubConfig.Enabled = not getgenv().HubConfig.Enabled
        print("Jayren v1.8 Stealth: " .. (getgenv().HubConfig.Enabled and "ON - Invisible God 🔥" or "OFF - Ghost"))
    end
end)

-- Pixel-Thin ESP (spawn delay + subtle)
task.wait(2) -- Anti-sniff delay
local espBoxes = {}
local function createESP(plr)
    if plr == LocalPlayer or getgenv().HubConfig.TeamCheck and plr.Team == LocalPlayer.Team then return end
    local box = Drawing.new("Square")
    box.Thickness = 1 -- Pixel thin
    box.Color = Color3.fromRGB(200, 50, 50) -- Faint red
    box.Filled = false
    box.Transparency = 0.95 -- Barely visible
    espBoxes[plr] = box
end
for _, plr in Players:GetPlayers() do createESP(plr) end
Players.PlayerAdded:Connect(createESP)

RunService.RenderStepped:Connect(function()
    for plr, box in pairs(espBoxes) do
        local char = plr.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local root = char.HumanoidRootPart
            local pos, visible = Camera:WorldToViewportPoint(root.Position)
            if visible then
                local size = 800 / pos.Z
                box.Size = Vector2.new(size * 0.7, size * 1.8)
                box.Position = Vector2.new(pos.X - size * 0.35, pos.Y - size * 0.9)
                box.Visible = getgenv().HubConfig.Enabled
            else
                box.Visible = false
            end
        else
            box.Visible = false
        end
    end
end)

-- INVISIBLE Silent Aim (lerp smooth + predict + jitter)
local oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    if getgenv().HubConfig.Enabled and self == workspace and getnamecallmethod() == "FindPartOnRayWithIgnoreList" then
        local closestHead = nil
        local minDist = getgenv().HubConfig.FOV
        for _, plr in Players:GetPlayers() do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                local head = plr.Character.Head
                local jitter = Vector3.new(math.random(-2,2)/100, math.random(-2,2)/100, 0) -- Human jitter
                local predictPos = head.Position + (head.Velocity * 0.1) + jitter
                local screenPos, onScreen = Camera:WorldToViewportPoint(predictPos)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    if dist < minDist then
                        minDist = dist
                        closestHead = predictPos
                    end
                end
            end
        end
        if closestHead then
            local smoothDir = Camera.CFrame:VectorToWorldSpace((Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Unit * getgenv().HubConfig.Smooth)
            args[1] = Ray.new(Camera.CFrame.Position, (closestHead - Camera.CFrame.Position).Unit * 8000 + smoothDir)
            return oldNamecall(self, unpack(args))
        end
    end
    return oldNamecall(self, ...)
end)

print("Jayren Stealth Hub v1.8 ULTIMATE Loaded - Q toggle | Legit smooth | Pixel ESP | FULL Anti-Kick 🔴 Fluxus Z VNG SLAY!")-- Jayren Sudo Rivals Hub v1.8 STEALTH ULTIMATE - 2026 Fluxus Z VNG Anti-Kick God 🔥
-- Legit Smooth Lerp 0.08 + 100 FOV + Pixel ESP + Velocity Predict + Jitter Random + Kick Block

getgenv().HubConfig = {Enabled = false, FOV = 100, Smooth = 0.08, TeamCheck = true, Predict = true}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ULTIMATE Anti-Kick (blocks all kick methods + remote spy)
task.spawn(function()
    local mt = getrawmetamethod(game, "__namecall")
    local oldNamecall = mt
    hookmetamethod(game, "__namecall", function(self, ...)
        local args = {...}
        local method = getnamecallmethod()
        if (method == "Kick" or string.find(tostring(self), "Kick") or method == "FireServer" and string.find(args[1] or "", "kick")) then
            return -- Total block
        end
        return oldNamecall(self, ...)
    end)
end)

-- Q Toggle (double-tap safe)
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Q then
        getgenv().HubConfig.Enabled = not getgenv().HubConfig.Enabled
        print("Jayren v1.8 Stealth: " .. (getgenv().HubConfig.Enabled and "ON - Invisible God 🔥" or "OFF - Ghost"))
    end
end)

-- Pixel-Thin ESP (spawn delay + subtle)
task.wait(2) -- Anti-sniff delay
local espBoxes = {}
local function createESP(plr)
    if plr == LocalPlayer or getgenv().HubConfig.TeamCheck and plr.Team == LocalPlayer.Team then return end
    local box = Drawing.new("Square")
    box.Thickness = 1 -- Pixel thin
    box.Color = Color3.fromRGB(200, 50, 50) -- Faint red
    box.Filled = false
    box.Transparency = 0.95 -- Barely visible
    espBoxes[plr] = box
end
for _, plr in Players:GetPlayers() do createESP(plr) end
Players.PlayerAdded:Connect(createESP)

RunService.RenderStepped:Connect(function()
    for plr, box in pairs(espBoxes) do
        local char = plr.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local root = char.HumanoidRootPart
            local pos, visible = Camera:WorldToViewportPoint(root.Position)
            if visible then
                local size = 800 / pos.Z
                box.Size = Vector2.new(size * 0.7, size * 1.8)
                box.Position = Vector2.new(pos.X - size * 0.35, pos.Y - size * 0.9)
                box.Visible = getgenv().HubConfig.Enabled
            else
                box.Visible = false
            end
        else
            box.Visible = false
        end
    end
end)

-- INVISIBLE Silent Aim (lerp smooth + predict + jitter)
local oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    if getgenv().HubConfig.Enabled and self == workspace and getnamecallmethod() == "FindPartOnRayWithIgnoreList" then
        local closestHead = nil
        local minDist = getgenv().HubConfig.FOV
        for _, plr in Players:GetPlayers() do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                local head = plr.Character.Head
                local jitter = Vector3.new(math.random(-2,2)/100, math.random(-2,2)/100, 0) -- Human jitter
                local predictPos = head.Position + (head.Velocity * 0.1) + jitter
                local screenPos, onScreen = Camera:WorldToViewportPoint(predictPos)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    if dist < minDist then
                        minDist = dist
                        closestHead = predictPos
                    end
                end
            end
        end
        if closestHead then
            local smoothDir = Camera.CFrame:VectorToWorldSpace((Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Unit * getgenv().HubConfig.Smooth)
            args[1] = Ray.new(Camera.CFrame.Position, (closestHead - Camera.CFrame.Position).Unit * 8000 + smoothDir)
            return oldNamecall(self, unpack(args))
        end
    end
    return oldNamecall(self, ...)
end)

print("Jayren Stealth Hub v1.8 ULTIMATE Loaded - Q toggle | Legit smooth | Pixel ESP | FULL Anti-Kick 🔴 Fluxus Z VNG SLAY!")
