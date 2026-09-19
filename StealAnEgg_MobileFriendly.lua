-- ============ STEAL AN EGG - MOBILE FRIENDLY AUTO FARM ============
-- Optimized for mobile devices with improved UI and farming logic
-- Features: Auto Collect, Auto Place, Auto Hatch, Area Selection

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/who-is-eze/stealanegg-fixed/refs/heads/main/vaehzlibCustom.lua"))()
local Window = Library:CreateWindow({ 
    Title = "Egg Farm Mobile", 
    Accent = Color3.fromRGB(100, 160, 255),
    Size = UDim2.new(0, 320, 0, 600) -- Optimized for mobile
})

local FarmTab = Window:CreateTab({ Name = "Farm", Icon = "wheat" })

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ============ STATE VARIABLES ============
getgenv().AutoFarm = false
getgenv().FarmEggs = true -- Default to true for mobile
getgenv().AutoPlace = true -- Default to true for mobile
getgenv().AutoHatch = true -- Default to true for mobile
getgenv().AutoEquip = false
getgenv().ChosenArea = "Automatic"
getgenv().FarmStatus = "Idle"
getgenv().FarmedCount = 0

-- ============ PLAYER & WORLD REFERENCES ============
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local SpeedVal = Player:WaitForChild("leaderstats"):WaitForChild("Speed")
local PlayerBase

for i, base in pairs(workspace.Plots:GetChildren()) do
    if base:FindFirstChild("PlotSign") and base.PlotSign:FindFirstChild("PlayerPlotSign") then
        local frame = base.PlotSign.PlayerPlotSign:FindFirstChild("Frame")
        if frame and frame:FindFirstChild("PlayerIcon") then
            if frame.PlayerIcon.Image:find(tostring(Player.UserId)) then
                PlayerBase = base
                break
            end
        end
    end
end

-- ============ GAME OBJECTS ============
local GuardAreas = workspace:WaitForChild("__OBJECTS"):WaitForChild("Areas"):WaitForChild("GuardAreas")
local SpawnedEggs = workspace:WaitForChild("AreaEggSlotsClient")
local PlacedEggs

for i, v in pairs(workspace:GetChildren()) do
    if v.Name == "PlacedEggRenders" and #v:GetChildren() >= 1 then
        PlacedEggs = v
        break
    end
end

-- ============ REMOTE EVENTS ============
local StealEvent = ReplicatedStorage.Packages.Networking["RF/EggWorld/AskFieldEggCarry"]
local PlaceEvent = ReplicatedStorage.Packages.Networking["RF/EggWorld/AskPlaceEgg"]
local HatchEvent = ReplicatedStorage.Packages.Networking["RF/EggWorld/AskHatch"]
local EquipEvent = ReplicatedStorage.Packages.Networking["RF/EggWorld/AskWearTool"]
local CompleteHatchEvent = ReplicatedStorage.Packages.Networking["RF/EggWorld/AskFinishHatch"]
local InventoryEvent = ReplicatedStorage.Packages.Networking["RE/EggWorld/OwnerShifted"]

-- ============ AREAS DATA ============
local Areas = {
    ["Forest"] = { Speed = 0 },
    ["Lake"] = { Speed = 900 },
    ["Desert"] = { Speed = 10000 },
    ["Jungle"] = { Speed = 40000 },
    ["Snow"] = { Speed = 450000 },
    ["Volcano"] = { Speed = 700000 },
    ["Abyss Ocean"] = { Speed = 2500000 },
    ["Prehistoric"] = { Speed = 17000000 },
    ["Cosmic"] = { Speed = 700000000 },
    ["Cherry Blossom"] = { Speed = 2500000000 },
    ["Titan Temple"] = { Speed = 7000000000 },
    ["Light Dark"] = { Speed = 20000000000 }
}

local AreasList = { "Automatic" }
for i, v in pairs(GuardAreas:GetChildren()) do
    table.insert(AreasList, v.Name)
end

-- ============ WAYPOINTS ============
local Waypoints = {
    SafeArea = Vector3.new(542, 71, -363)
}

-- ============ INVENTORY TRACKING ============
local LastInventory = {}

InventoryEvent.OnClientEvent:Connect(function(data)
    if data and data.OwnerUserId == Player.UserId and data.Records then
        LastInventory = data.Records
    end
end)

-- ============ HELPER FUNCTIONS ============
local function SetStatus(status)
    getgenv().FarmStatus = status
end

local function GetBestArea()
    local currentSpeed = SpeedVal.Value
    local bestName, bestSpeed = nil, -1

    if ChosenArea == "Automatic" then
        for name, data in pairs(Areas) do
            if data.Speed <= currentSpeed and data.Speed > bestSpeed then
                bestName = name
                bestSpeed = data.Speed
            end
        end
    else
        bestName = ChosenArea
    end

    return bestName or "Forest"
end

local function SafeWalkTo(hum, pos, timeout)
    timeout = timeout or 30
    local startTime = tick()
    local hrp = hum.RootPart
    
    if not hrp or not hrp.Parent then return false end

    while (tick() - startTime) < timeout do
        if not hum or not hum.Parent or not AutoFarm then
            return false
        end

        hum:MoveTo(pos)
        local reached = hum.MoveToFinished:Wait()

        if reached then
            return true
        end

        if hrp and hrp.Parent then
            local flat = (Vector2.new(hrp.Position.X, hrp.Position.Z) - Vector2.new(pos.X, pos.Z)).Magnitude
            if flat <= 5 then
                return true
            end
        end

        task.wait(0.1)
    end

    return false
end

local function EnableNoclip()
    if not Player.Character then return nil end
    
    local noclipping = RunService.Stepped:Connect(function()
        if AutoFarm and Player.Character then
            for _, child in pairs(Player.Character:GetDescendants()) do
                if child:IsA("BasePart") and child.CanCollide then
                    child.CanCollide = false
                end
            end
        end
    end)
    
    return noclipping
end

local function DisableNoclip(connection)
    if connection then
        connection:Disconnect()
    end
    
    if Player.Character then
        for _, child in pairs(Player.Character:GetDescendants()) do
            if child:IsA("BasePart") then
                child.CanCollide = true
            end
        end
    end
end

-- ============ FARMING LOGIC ============
local function CollectEgg()
    SetStatus("Collecting...")
    
    if not FarmEggs or not AutoFarm then return false end
    
    local bestArea = GuardAreas:FindFirstChild(GetBestArea())
    if not bestArea or not bestArea:FindFirstChild("Bounds") then
        return false
    end

    local humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end

    -- Navigate to area
    humanoid.HipHeight = 20
    task.wait(0.2)
    
    if not SafeWalkTo(humanoid, Waypoints.SafeArea, 20) then
        humanoid.HipHeight = 2
        return false
    end

    humanoid.HipHeight = 2
    task.wait(0.2)

    if not SafeWalkTo(humanoid, bestArea.Bounds.Position, 20) then
        return false
    end

    -- Find closest egg
    local closestEgg, closestDist = nil, math.huge

    for _, v in pairs(SpawnedEggs:GetChildren()) do
        local primaryPart = v:FindFirstChild("PrimaryPart") or (v:IsA("Model") and v.PrimaryPart)
        if primaryPart and primaryPart.Parent then
            local dist = (primaryPart.Position - Player.Character.HumanoidRootPart.Position).Magnitude
            if dist < closestDist then
                closestDist = dist
                closestEgg = v
            end
        end
    end

    if not closestEgg then
        return false
    end

    -- Walk to egg
    local eggPos = closestEgg:FindFirstChild("PrimaryPart") and closestEgg.PrimaryPart.Position or closestEgg.Position
    if not SafeWalkTo(humanoid, eggPos, 15) then
        return false
    end

    task.wait(0.3)

    -- Steal egg
    local success = pcall(function()
        StealEvent:InvokeServer({ Uid = closestEgg.Name })
    end)

    if success then
        getgenv().FarmedCount = getgenv().FarmedCount + 1
    end

    -- Return to safe area
    SafeWalkTo(humanoid, Waypoints.SafeArea, 20)

    return success
end

local function PlaceEggs()
    SetStatus("Placing...")
    
    if not AutoPlace or not AutoFarm or not LastInventory then return false end

    local humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid or not PlayerBase then return false end

    humanoid.HipHeight = 20
    task.wait(0.2)

    if not SafeWalkTo(humanoid, PlayerBase.CenterPoint.Position, 20) then
        humanoid.HipHeight = 2
        return false
    end

    humanoid.HipHeight = 2

    local placed = 0
    for i, v in pairs(LastInventory) do
        if not AutoFarm then break end

        local randomArea = CFrame.new(
            math.random(-23, 23), 
            -0.5, 
            math.random(-29, 29), 
            0, 0, 1, 0, 1, 0, -1, 0, 0
        )

        local success = pcall(function()
            PlaceEvent:InvokeServer({
                Uid = i,
                LocalCFrame = randomArea
            })
        end)

        if success then
            placed = placed + 1
        end

        task.wait(0.1)
    end

    return placed > 0
end

local function HatchEggs()
    SetStatus("Hatching...")
    
    if not AutoHatch or not AutoFarm or not PlacedEggs then return false end

    local humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end

    local hatched = 0

    for i, v in pairs(PlacedEggs:GetChildren()) do
        if not AutoFarm then break end

        local splitString = v.Name:split("_")
        if splitString[1] == tostring(Player.UserId) then
            humanoid.HipHeight = 20
            task.wait(0.1)

            local eggPos = v:FindFirstChild("PrimaryPart") and v.PrimaryPart.Position or v.Position
            if SafeWalkTo(humanoid, eggPos, 15) then
                local res = pcall(function()
                    return HatchEvent:InvokeServer(splitString[2])
                end)

                if res then
                    pcall(function()
                        CompleteHatchEvent:InvokeServer(splitString[2])
                    end)
                    hatched = hatched + 1
                end

                task.wait(0.2)
            end

            humanoid.HipHeight = 2
        end
    end

    return hatched > 0
end

local function EquipPets()
    SetStatus("Equipping...")
    
    if AutoEquip then
        pcall(function()
            EquipEvent:InvokeServer()
        end)
    end
end

-- ============ MAIN FARM LOOP ============
local function FarmLoop()
    while AutoFarm do
        pcall(function()
            local noclip = EnableNoclip()

            if FarmEggs then
                CollectEgg()
                task.wait(0.5)
            end

            if AutoPlace then
                PlaceEggs()
                task.wait(0.5)
            end

            if AutoHatch then
                HatchEggs()
                task.wait(0.5)
            end

            if AutoEquip then
                EquipPets()
            end

            DisableNoclip(noclip)

            SetStatus("Running...")
            task.wait(1)
        end)

        task.wait()
    end

    SetStatus("Stopped")
end

-- ============ CHARACTER RESPAWN HANDLING ============
Player.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
end)

-- ============ MOBILE UI - MAIN SECTION ============
FarmTab:CreateLabel("⚙️ FARM CONTROLS", 13)

FarmTab:CreateToggle({
    Name = "🌾 Auto Farm",
    Default = false,
    Callback = function(v)
        AutoFarm = v
        if v then
            SetStatus("Starting...")
            FarmLoop()
        else
            SetStatus("Stopped")
        end
    end
})

-- ============ MOBILE UI - STATUS SECTION ============
FarmTab:CreateLabel("📊 STATUS", 13)

local StatusLabel = FarmTab:CreateLabel("Status: Idle")
local CountLabel = FarmTab:CreateLabel("Eggs Farmed: 0")

-- Update status display every 0.5 seconds
spawn(function()
    while true do
        pcall(function()
            StatusLabel:Set("Status: " .. tostring(FarmStatus))
            CountLabel:Set("Eggs Farmed: " .. tostring(FarmedCount))
        end)
        task.wait(0.5)
    end
end)

-- ============ MOBILE UI - FARM SETTINGS ============
FarmTab:CreateLabel("🎯 FARM SETTINGS", 13)

FarmTab:CreateToggle({
    Name = "🥚 Auto Collect",
    Default = true,
    Callback = function(v)
        FarmEggs = v
    end
})

FarmTab:CreateToggle({
    Name = "📍 Auto Place",
    Default = true,
    Callback = function(v)
        AutoPlace = v
    end
})

FarmTab:CreateToggle({
    Name = "🐔 Auto Hatch",
    Default = true,
    Callback = function(v)
        AutoHatch = v
    end
})

FarmTab:CreateToggle({
    Name = "🎫 Auto Equip",
    Default = false,
    Callback = function(v)
        AutoEquip = v
    end
})

-- ============ MOBILE UI - AREA SELECTION ============
FarmTab:CreateLabel("🗺️ AREA SELECTION", 13)

FarmTab:CreateDropdown({
    Name = "Select Area",
    Options = AreasList,
    Multi = false,
    Callback = function(v)
        ChosenArea = v
    end
})

-- ============ MOBILE UI - INFO SECTION ============
FarmTab:CreateLabel("ℹ️ INFO", 13)

FarmTab:CreateLabel({
    Text = "💡 All features enabled by default for fast farming",
    Size = 13,
})

FarmTab:CreateLabel({
    Text = "📱 Optimized for mobile devices",
    Size = 13,
})

FarmTab:CreateLabel({
    Text = "⚠️ Don't close this script while farming",
    Size = 13,
})

-- ============ SCRIPT LOADED NOTIFICATION ============
Library:Notify({
    Title = "✅ Loaded",
    Content = "Egg Farm Ready! Toggle Auto Farm to start",
    Duration = 3
})

print("[EggFarm] Script loaded successfully!")
print("[EggFarm] Click Auto Farm to begin farming eggs")