-- Survive Flood for Brainrots - Full Rayfield Hack
-- Grok Hacker Edition

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "🔥 Grok Hacker - Survive Flood Brainrots",
    LoadingTitle = "Loading Brainrot Farm...",
    LoadingSubtitle = "by Grok",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "GrokHacks",
        FileName = "SurviveFloodConfig"
    }
})

local Tab = Window:CreateTab("Farm", 4483362458)

-- Settings
local Settings = {
    Farming = false,
    Speed = 0.4,
    TPHome = true
}

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local brainrotFold = workspace:WaitForChild("GameFolder"):WaitForChild("Brainrots")

-- Grab function (improved)
local function grabem(folder)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    for _, br in pairs(folder:GetChildren()) do
        if not Settings.Farming then break end
        if br:IsA("Model") and br.PrimaryPart then
            local prompt = br.PrimaryPart:FindFirstChildOfClass("ProximityPrompt")
            if prompt then
                -- Teleport to brainrot
                char:MoveTo(br.PrimaryPart.Position + Vector3.new(0, 3, 0))
                task.wait(Settings.Speed)
                
                -- Fire prompt
                fireproximityprompt(prompt)
                task.wait(0.2)

                -- Optional return home
                if Settings.TPHome then
                    char:MoveTo(Vector3.new(-2, 4, 13))
                    task.wait(0.35)
                end
            end
        end
    end
end

-- Main Farm Loop
local function startFarm()
    while Settings.Farming do
        pcall(function()
            grabem(brainrotFold:FindFirstChild("Infinity"))
            grabem(brainrotFold:FindFirstChild("Godly"))
            grabem(brainrotFold:FindFirstChild("Secret"))
            grabem(brainrotFold:FindFirstChild("Celestial"))
        end)
        task.wait(0.8)
    end
end

-- GUI Elements
Tab:CreateToggle({
    Name = "Auto Farm Brainrots",
    CurrentValue = false,
    Flag = "FarmToggle",
    Callback = function(Value)
        Settings.Farming = Value
        if Value then
            Rayfield:Notify({Title = "Farm Started", Content = "Grabbing all rarities!", Duration = 3})
            task.spawn(startFarm)
        else
            Rayfield:Notify({Title = "Farm Stopped", Content = "Stopped farming", Duration = 2})
        end
    end,
})

Tab:CreateSlider({
    Name = "Teleport Speed",
    Range = {0.1, 1.5},
    Increment = 0.05,
    CurrentValue = 0.4,
    Flag = "SpeedSlider",
    Callback = function(Value)
        Settings.Speed = Value
    end,
})

Tab:CreateToggle({
    Name = "Teleport Home After Grab",
    CurrentValue = true,
    Flag = "TPHome",
    Callback = function(Value)
        Settings.TPHome = Value
    end,
})

Tab:CreateButton({
    Name = "Grab All Once",
    Callback = function()
        task.spawn(function()
            grabem(brainrotFold:FindFirstChild("Infinity"))
            grabem(brainrotFold:FindFirstChild("Godly"))
            grabem(brainrotFold:FindFirstChild("Secret"))
            grabem(brainrotFold:FindFirstChild("Celestial"))
            Rayfield:Notify({Title = "Done", Content = "Grabbed all once!", Duration = 3})
        end)
    end,
})

Rayfield:LoadConfiguration()
print("✅ Survive Flood for Brainrots Hack Loaded!")
