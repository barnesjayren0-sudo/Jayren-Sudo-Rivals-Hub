-- brainrot.lua
-- Rarity odds viewer + onboarding skip (Tape / Random Brainrot game)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Rarity table from BrainrotChanceDisplay
local RARITIES = {
    { Rarity = "Epic",       Chance = "70.0%" },
    { Rarity = "Legendary",  Chance = "23.0%" },
    { Rarity = "Mythical",   Chance = "5.0%" },
    { Rarity = "Secret",     Chance = "1.489%" },
    { Rarity = "Godly",      Chance = "0.4%" },
    { Rarity = "Exclusive",  Chance = "0.1%" },
    { Rarity = "Celestial",  Chance = "0.01%" },
    { Rarity = "Divine",     Chance = "0.001%" },
}

local function skipOnboarding()
    local ok, err = pcall(function()
        local Events = ReplicatedStorage:WaitForChild("Events", 5)
        if not Events then return end
        local SetOnboardingStep = Events:WaitForChild("SetOnboardingStep", 5)
        if not SetOnboardingStep then return end
        for step = 1, 15 do
            SetOnboardingStep:FireServer(step)
            task.wait(0.08)
        end
    end)
    if ok then
        print("[brainrot] Onboarding steps fired")
    else
        warn("[brainrot] Onboarding skip failed:", err)
    end
end

local function getProductId()
    local id = nil
    pcall(function()
        local Modules = ReplicatedStorage:WaitForChild("Modules", 3)
        local cfg = require(Modules:WaitForChild("ProductConfigurations"))
        if cfg and cfg.Products and cfg.Products.RandomBrainrot then
            id = cfg.Products.RandomBrainrot
        end
    end)
    return id
end

-- Load Rayfield
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Brainrot Hub",
    LoadingTitle = "Brainrot",
    LoadingSubtitle = "by Jays",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "BrainrotHub",
        FileName = "Config"
    },
    KeySystem = false,
})

local Main = Window:CreateTab("Main", 4483362458)
local Info = Window:CreateTab("Odds", 4483362458)

Main:CreateSection("Onboarding")

Main:CreateButton({
    Name = "Skip Onboarding",
    Callback = function()
        skipOnboarding()
        Rayfield:Notify({
            Title = "Brainrot",
            Content = "Onboarding steps sent",
            Duration = 3,
        })
    end,
})

Main:CreateSection("Random Brainrot")

Main:CreateParagraph({
    Title = "Note",
    Content = "Random Brainrot is a paid Robux product (MarketplaceService). This hub cannot unlock paid products for free."
})

Main:CreateButton({
    Name = "Show Product ID",
    Callback = function()
        local id = getProductId()
        Rayfield:Notify({
            Title = "Product ID",
            Content = id and tostring(id) or "Not found",
            Duration = 5,
        })
        print("[brainrot] RandomBrainrot ProductId:", id)
    end,
})

Main:CreateButton({
    Name = "Open Purchase Prompt",
    Callback = function()
        local id = getProductId()
        if id then
            pcall(function()
                game:GetService("MarketplaceService"):PromptProductPurchase(LocalPlayer, id)
            end)
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "Product ID not found",
                Duration = 3,
            })
        end
    end,
})

Info:CreateSection("Random Brainrot Chances")

local oddsText = {}
for _, row in ipairs(RARITIES) do
    table.insert(oddsText, row.Rarity .. " — " .. row.Chance)
end

Info:CreateParagraph({
    Title = "Drop Odds",
    Content = table.concat(oddsText, "\n")
})

for _, row in ipairs(RARITIES) do
    Info:CreateLabel(row.Rarity .. ": " .. row.Chance)
end

print("[brainrot.lua] Loaded")
