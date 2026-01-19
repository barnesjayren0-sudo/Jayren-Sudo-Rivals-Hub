-- Jayren Sudo Arsenal Ultimate Hub v2.5 - 2026 Fluxus Z VNG Undetected God 🔥
-- Silent Aim + ESP + Gun Mods + Kill Aura + Hitbox + Fly/Noclip + Anti-Kick/RAC Bypass
-- Right Shift GUI | Q Toggle | From Rivals Enhanced Blueprint

getgenv().ArsenalConfig = {
    Aimbot = {Enabled = false, FOV = 120, Smooth = 0.05, TargetPriority = "Closest", Predict = true},
    ESP = {Enabled = true, Boxes = true, Tracers = false, Names = true},
    GunMods = {InfAmmo = true, NoRecoil = true, RapidFire = true},
    Player = {KillAura = false, HitboxExpand = false, Fly = false, Noclip = false},
    AntiKick = true
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Rayfield UI Library (clean GUI)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Jayren Arsenal Ultimate v2.5 ⚡",
    LoadingTitle = "Breaching Arsenal Core...",
    LoadingSubtitle = "by shadow sudo Jayren",
    ConfigurationSaving = {Enabled = true, FolderName = "JayrenArsenal", FileName = "v2.5"}
})

-- Anti-Kick/RAC Bypass (blocks all kicks + remotes)
task.spawn(function()
    local oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local args = {...}
        local method = getnamecallmethod()
        if getgenv().ArsenalConfig.AntiKick and (method == "Kick" or string.find(tostring(self):lower(), "kick") or method == "FireServer" and string.find(args[1] or "", "kick")) then
            return
        end
        return oldNamecall(self, ...)
    end)
end)

-- Q Toggle Master
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Q then
        getgenv().ArsenalConfig.Aimbot.Enabled = not getgenv().ArsenalConfig.Aimbot.Enabled
        print("Jayren Arsenal: Aim " .. (getgenv().ArsenalConfig.Aimbot.Enabled and "ON 🔥" or "OFF"))
    end
end)

-- ESP (Boxes/Tracers/Names – Arsenal optimized)
local espObjects = {}
local function addESP(plr)
    if plr == LocalPlayer then return end
    local box = Drawing.new("Square"); box.Thickness = 2; box.Color = Color3.fromRGB(255, 0, 0); box.Filled = false; box.Transparency = 0.8
    local tracer = Drawing.new("Line"); tracer.Thickness = 1; tracer.Color = Color3.fromRGB(255, 0, 0); tracer.Transparency = 0.7
    local nameTag = Drawing.new("Text"); nameTag.Size = 16; nameTag.Color = Color3.fromRGB(255, 255, 255); nameTag.Outline = true
    espObjects[plr] = {box = box, tracer = tracer, name = nameTag}
end

for _, plr in Players:GetPlayers() do addESP(plr) end
Players.PlayerAdded:Connect(addESP)

RunService.RenderStepped:Connect(function()
    for plr, objs in pairs(espObjects) do
        local char = plr.Character
        if char and char:FindFirstChild("HumanoidRootPart") and getgenv().ArsenalConfig.ESP.Enabled then
            local root = char.HumanoidRootPart
            local pos, vis = Camera:WorldToViewportPoint(root.Position)
            if vis then
                -- Box
                if getgenv().ArsenalConfig.ESP.Boxes then
                    local size = (Camera:WorldToViewportPoint(root.Position - Vector3.new(0,3,0)).Y - Camera:WorldToViewportPoint(root.Position + Vector3.new(0,3,0)).Y) / 2
                    objs.box.Size = Vector2.new(size * 1.5, size * 2.5)
                    objs.box.Position = Vector2.new(pos.X - size * 0.75, pos.Y - size * 1.25)
                    objs.box.Visible = true
                else objs.box.Visible = false end
                -- Tracer
                if getgenv().ArsenalConfig.ESP.Tracers then
                    objs.tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    objs.tracer.To = Vector2.new(pos.X, pos.Y)
                    objs.tracer.Visible = true
                else objs.tracer.Visible = false end
                -- Name
                if getgenv().ArsenalConfig.ESP.Names then
                    objs.name.Text = plr.Name .. " [" .. math.floor((root.Position - Camera.CFrame.Position).Magnitude) .. "]"
                    objs.name.Position = Vector2.new(pos.X, pos.Y - 20)
                    objs.name.Visible = true
                else objs.name.Visible = false end
            else
                objs.box.Visible = objs.tracer.Visible = objs.name.Visible = false
            end
        else
            objs.box.Visible = objs.tracer.Visible = objs.name.Visible = false
        end
    end
end)

-- Silent Aim (Arsenal raycast hook + predict)
local oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    if getgenv().ArsenalConfig.Aimbot.Enabled and self == workspace and getnamecallmethod() == "FindPartOnRayWithIgnoreList" then
        local closest = nil
        local minDist = getgenv().ArsenalConfig.Aimbot.FOV
        for _, plr in Players:GetPlayers() do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                local head = plr.Character.Head
                local predict = head.Position + (head.Velocity * 0.1)
                local screen, onScreen = Camera:WorldToViewportPoint(predict)
                if onScreen then
                    local dist = (Vector2.new(screen.X, screen.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    if dist < minDist then minDist = dist; closest = predict end
                end
            end
        end
        if closest then
            local smooth = (closest - Camera.CFrame.Position).Unit * getgenv().ArsenalConfig.Aimbot.Smooth
            args[1] = Ray.new(Camera.CFrame.Position, (closest - Camera.CFrame.Position).Unit * 10000 + smooth)
            return oldNamecall(self, unpack(args))
        end
    end
    return oldNamecall(self, ...)
end)

-- Gun Mods (Inf Ammo/No Recoil/Rapid Fire – Arsenal weapons hook)
task.spawn(function()
    while task.wait() do
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool") then
            local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if getgenv().ArsenalConfig.GunMods.InfAmmo then tool.Ammo.Value = math.huge end
            if getgenv().ArsenalConfig.GunMods.NoRecoil then tool.Recoil.Value = 0 end
            if getgenv().ArsenalConfig.GunMods.RapidFire then tool.FireRate.Value = 0.01 end
        end
    end
end)

-- Kill Aura/Hitbox/Fly/Noclip (toggles)
-- Kill Aura
task.spawn(function()
    while task.wait(0.1) do
        if getgenv().ArsenalConfig.Player.KillAura and LocalPlayer.Character then
            for _, plr in Players:GetPlayers() do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") and (plr.Character.Head.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 20 then
                    fireclickdetector(plr.Character.Head:FindFirstChildOfClass("ClickDetector") or game:GetService("ReplicatedStorage").Remotes.Damage:FireServer(plr.Character.Head, 100)
                end
            end
        end
    end
end)

-- Hitbox Expander
task.spawn(function()
    while task.wait() do
        if getgenv().ArsenalConfig.Player.HitboxExpand then
            for _, plr in Players:GetPlayers() do
                if plr ~= LocalPlayer and plr.Character then
                    for _, part in plr.Character:GetChildren() do
                        if part:IsA("BasePart") then part.Size = part.Size * 2 end
                    end
                end
            end
        end
    end
end)

-- Fly/Noclip (basic)
local flying = false
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F and getgenv().ArsenalConfig.Player.Fly then
        flying = not flying
        local bg = Instance.new("BodyVelocity")
        bg.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bg.Velocity = Vector3.new(0,0,0)
        bg.Parent = LocalPlayer.Character.HumanoidRootPart
        while flying do
            bg.Velocity = Camera.CFrame.LookVector * 50 + Vector3.new(0,0,0)
            task.wait()
        end
        bg:Destroy()
    end
end)

-- GUI Tabs
local AimbotTab = Window:CreateTab("Aimbot", nil)
AimbotTab:CreateToggle({Name = "Enabled", CurrentValue = false, Callback = function(v) getgenv().ArsenalConfig.Aimbot.Enabled = v end})
AimbotTab:CreateSlider({Name = "FOV", Min = 50, Max = 500, Default = 120, Color = Color3.fromRGB(255,0,0), Callback = function(v) getgenv().ArsenalConfig.Aimbot.FOV = v end})
AimbotTab:CreateSlider({Name = "Smooth", Min = 0, Max = 1, Default = 0.05, Callback = function(v) getgenv().ArsenalConfig.Aimbot.Smooth = v end})

local ESPTab = Window:CreateTab("ESP", nil)
ESPTab:CreateToggle({Name = "Enabled", CurrentValue = true, Callback = function(v) getgenv().ArsenalConfig.ESP.Enabled = v end})
ESPTab:CreateToggle({Name = "Boxes", CurrentValue = true, Callback = function(v) getgenv().ArsenalConfig.ESP.Boxes = v end})
ESPTab:CreateToggle({Name = "Tracers", CurrentValue = false, Callback = function(v) getgenv().ArsenalConfig.ESP.Tracers = v end})

local GunTab = Window:CreateTab("Gun Mods", nil)
GunTab:CreateToggle({Name = "Inf Ammo", CurrentValue = true, Callback = function(v) getgenv().ArsenalConfig.GunMods.InfAmmo = v end})
GunTab:CreateToggle({Name = "No Recoil", CurrentValue = true, Callback = function(v) getgenv().ArsenalConfig.GunMods.NoRecoil = v end})
GunTab:CreateToggle({Name = "Rapid Fire", CurrentValue = true, Callback = function(v) getgenv().ArsenalConfig.GunMods.RapidFire = v end})

local PlayerTab = Window:CreateTab("Player", nil)
PlayerTab:CreateToggle({Name = "Kill Aura", CurrentValue = false, Callback = function(v) getgenv().ArsenalConfig.Player.KillAura = v end})
PlayerTab:CreateToggle({Name = "Hitbox Expand", CurrentValue = false, Callback = function(v) getgenv().ArsenalConfig.Player.HitboxExpand = v end})
PlayerTab:CreateToggle({Name = "Fly (F Key)", CurrentValue = false, Callback = function(v) getgenv().ArsenalConfig.Player.Fly = v end})
PlayerTab:CreateToggle({Name = "Noclip", CurrentValue = false, Callback = function(v) getgenv().ArsenalConfig.Player.Noclip = v end})

print("Jayren Arsenal Ultimate v2.5 Injected - Right Shift GUI | Q Aim Toggle | RAC Bypassed 🔴 Dominate Waves!")
Rayfield:Notify({Title = "Jayren Hub Loaded", Content = "Arsenal v2.5 - Private server slay!", Duration = 5})
