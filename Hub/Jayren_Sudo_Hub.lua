-- ======================================================
-- Jayren Sudo Hub | Grok Hacker Edition
-- All scripts fused into one Rayfield GUI
-- ======================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "🔥 Jayren Sudo Hub",
    LoadingTitle = "Loading Jayren Sudo Hub...",
    LoadingSubtitle = "by Grok Hacker",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "JayrenSudoHub",
        FileName = "Config"
    },
    Discord = {
        Enabled = false
    }
})

-- ======================================================
-- TAB 1: Survive Flood for Brainrots
-- ======================================================
local BrainrotTab = Window:CreateTab("Brainrots Farm", 4483362458)

local BrainrotSettings = {
    Farming = false,
    Speed = 0.4,
    TPHome = true
}

local function grabBrainrot(folder)
    local char = game.Players.LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    for _, br in pairs(folder:GetChildren()) do
        if not BrainrotSettings.Farming then break end
        if br:IsA("Model") and br.PrimaryPart then
            local prompt = br.PrimaryPart:FindFirstChildOfClass("ProximityPrompt")
            if prompt then
                char:MoveTo(br.PrimaryPart.Position + Vector3.new(0, 3, 0))
                task.wait(BrainrotSettings.Speed)
                fireproximityprompt(prompt)
                task.wait(0.2)
                if BrainrotSettings.TPHome then
                    char:MoveTo(Vector3.new(-2, 4, 13))
                    task.wait(0.35)
                end
            end
        end
    end
end

local function startBrainrotFarm()
    local brainrotFold = workspace:FindFirstChild("GameFolder") and workspace.GameFolder:FindFirstChild("Brainrots")
    if not brainrotFold then return end

    while BrainrotSettings.Farming do
        pcall(function()
            grabBrainrot(brainrotFold:FindFirstChild("Infinity"))
            grabBrainrot(brainrotFold:FindFirstChild("Godly"))
            grabBrainrot(brainrotFold:FindFirstChild("Secret"))
            grabBrainrot(brainrotFold:FindFirstChild("Celestial"))
        end)
        task.wait(0.8)
    end
end

BrainrotTab:CreateToggle({
    Name = "Auto Farm Brainrots",
    CurrentValue = false,
    Flag = "BrainrotFarm",
    Callback = function(Value)
        BrainrotSettings.Farming = Value
        if Value then
            Rayfield:Notify({Title = "Brainrot Farm", Content = "Started farming all rarities!", Duration = 3})
            task.spawn(startBrainrotFarm)
        else
            Rayfield:Notify({Title = "Brainrot Farm", Content = "Stopped", Duration = 2})
        end
    end,
})

BrainrotTab:CreateSlider({
    Name = "Teleport Speed",
    Range = {0.1, 1.5},
    Increment = 0.05,
    CurrentValue = 0.4,
    Flag = "BrainrotSpeed",
    Callback = function(Value)
        BrainrotSettings.Speed = Value
    end,
})

BrainrotTab:CreateToggle({
    Name = "Teleport Home After Grab",
    CurrentValue = true,
    Flag = "BrainrotTPHome",
    Callback = function(Value)
        BrainrotSettings.TPHome = Value
    end,
})

-- ======================================================
-- TAB 2: Click + Rebirth Fusion
-- ======================================================
local ClickTab = Window:CreateTab("Click + Rebirth", 4483362458)

local isClicking = false
local isRebirthing = false

ClickTab:CreateToggle({
    Name = "Infinite Auto Clicker",
    CurrentValue = false,
    Flag = "AutoClick",
    Callback = function(Value)
        isClicking = Value
        if Value then
            spawn(function()
                while isClicking do
                    pcall(function()
                        game:GetService("ReplicatedStorage").Remotes.Server.Click:FireServer()
                    end)
                    task.wait(0.01)
                end
            end)
            Rayfield:Notify({Title = "Clicker", Content = "Infinite clicking started", Duration = 3})
        end
    end,
})

ClickTab:CreateToggle({
    Name = "Force Rebirth Bypass",
    CurrentValue = false,
    Flag = "ForceRebirth",
    Callback = function(Value)
        isRebirthing = Value
        if Value then
            spawn(function()
                while isRebirthing do
                    pcall(function()
                        game:GetService("ReplicatedStorage").Remotes.Server.Rebirth:FireServer("Rebirth")
                    end)
                    task.wait(0.5)
                end
            end)
            Rayfield:Notify({Title = "Rebirth", Content = "Force rebirth active", Duration = 3})
        end
    end,
})

ClickTab:CreateButton({
    Name = "Single Force Rebirth",
    Callback = function()
        pcall(function()
            game:GetService("ReplicatedStorage").Remotes.Server.Rebirth:FireServer("Rebirth")
        end)
        Rayfield:Notify({Title = "Rebirth", Content = "Fired once", Duration = 2})
    end,
})

-- ======================================================
-- TAB 3: Strength Bypass
-- ======================================================
local StrengthTab = Window:CreateTab("Strength Bypass", 4483362458)

StrengthTab:CreateToggle({
    Name = "Force Max Strength + Rebirth",
    CurrentValue = false,
    Flag = "StrengthBypass",
    Callback = function(Value)
        if Value then
            spawn(function()
                while true do
                    pcall(function()
                        local replica = game:GetService("ReplicatedStorage").Client.DataClient:GetReplica()
                        if replica and replica.Data then
                            replica.Data.Strength = 999999999999
                        end
                        game:GetService("ReplicatedStorage").Remotes.Server.Rebirth:FireServer("Rebirth")
                    end)
                    task.wait(0.5)
                end
            end)
            Rayfield:Notify({Title = "Strength", Content = "Max strength + rebirth active", Duration = 3})
        end
    end,
})

StrengthTab:CreateButton({
    Name = "Set Insane Strength Once",
    Callback = function()
        pcall(function()
            local replica = game:GetService("ReplicatedStorage").Client.DataClient:GetReplica()
            if replica and replica.Data then
                replica.Data.Strength = 1e12
            end
        end)
        Rayfield:Notify({Title = "Strength", Content = "Insane strength set", Duration = 2})
    end,
})

-- ======================================================
-- TAB 4: AIArena Memory
-- ======================================================
local ArenaTab = Window:CreateTab("AIArena Memory", 4483362458)

ArenaTab:CreateToggle({
    Name = "Infinite Memory Upgrades",
    CurrentValue = false,
    Flag = "MemoryUpgrade",
    Callback = function(Value)
        getgenv().AutoMemory = Value
        if Value then
            spawn(function()
                while getgenv().AutoMemory do
                    pcall(function()
                        game:GetService("ReplicatedStorage").AIArena.Remotes.BuyUpgrade:FireServer("Memory")
                        game:GetService("ReplicatedStorage").AIArena.Remotes.BuyUpgrade:FireServer("memory")
                    end)
                    task.wait(0.2)
                end
            end)
            Rayfield:Notify({Title = "AIArena", Content = "Memory upgrades spamming", Duration = 3})
        end
    end,
})

ArenaTab:CreateButton({
    Name = "Max Memory 100x",
    Callback = function()
        pcall(function()
            local remote = game:GetService("ReplicatedStorage").AIArena.Remotes.BuyUpgrade
            for i = 1, 100 do
                remote:FireServer("Memory")
            end
        end)
        Rayfield:Notify({Title = "AIArena", Content = "100 Memory upgrades sent", Duration = 2})
    end,
})

-- ======================================================
-- TAB 5: Free Shop
-- ======================================================
local ShopTab = Window:CreateTab("Free Shop", 4483362458)

ShopTab:CreateToggle({
    Name = "Enable Free Purchases",
    CurrentValue = false,
    Flag = "FreeShop",
    Callback = function(Value)
        if Value then
            local MarketplaceService = game:GetService("MarketplaceService")
            local oldPrompt = MarketplaceService.PromptPurchase
            MarketplaceService.PromptPurchase = function(self, player, assetId, ...)
                print("Free purchase for: " .. tostring(assetId))
                MarketplaceService:FirePromptPurchaseFinished(player, assetId, true)
                return oldPrompt(self, player, assetId, ...)
            end

            local oldBundle = MarketplaceService.PromptBundlePurchase
            MarketplaceService.PromptBundlePurchase = function(self, player, bundleId, ...)
                print("Free bundle: " .. tostring(bundleId))
                MarketplaceService:FirePromptBundlePurchaseFinished(player, bundleId, true)
                return oldBundle(self, player, bundleId, ...)
            end

            Rayfield:Notify({Title = "Free Shop", Content = "Buy anything for free!", Duration = 4})
        end
    end,
})

-- ======================================================
-- Final
-- ======================================================
Rayfield:LoadConfiguration()
print("🔥 Jayren Sudo Hub fully loaded!")
Rayfield:Notify({Title = "Jayren Sudo Hub", Content = "All scripts ready. Select a tab!", Duration = 5})
