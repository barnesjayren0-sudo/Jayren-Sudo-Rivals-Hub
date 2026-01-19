-- Jayren Sudo Arsenal GUI v3.0 ULTIMATE - 2026 Draggable/Closable God Mode 🔥
-- Movable GUI (drag title), X Close/Minimize, Rayfield Tabs, Silent Aim Predict, ESP Tracers/Names, Inf Ammo/No Recoil, Kill Aura/Hitbox/Fly/Noclip/Speed, Anti-Kick/RAC Bypass
-- Right Shift Open | Q Toggle Aim | Fluxus Z VNG Optimized | From Enhanced Hub v2.5

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

getgenv().ArsenalV3 = {
    Aimbot = {Enabled = false, FOV = 100, Smooth = 0.05, Predict = true, Jitter = true, TeamCheck = true},
    ESP = {Enabled = true, Boxes = true, Tracers = true, Names = true, Distance = true},
    GunMods = {InfAmmo = true, NoRecoil = true, RapidFire = true},
    Player = {KillAura = false, Hitbox = false, Fly = false, Noclip = false, Speed = 16},
    GUI = {Visible = true}
}

-- Draggable/Closable Custom GUI (better than Rayfield for mobile/drag)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JayrenArsenalGUIv3"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 450, 0, 400)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -70, 1, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "⚡ Jayren Arsenal v3.0 Ultimate GUI ⚡"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextScaled = true
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 2.5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextScaled = true
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TitleBar

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -70, 0, 2.5)
MinimizeBtn.BackgroundColor3 =
