-- Grok Hacker - Strength + Rebirth Bypass (Based on Dex decompiles)

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({Name = "Grok Strength/Rebirth Bypass"})

local Tab = Window:CreateTab("Main", 4483362458)

Tab:CreateToggle({
    Name = "Infinite Auto Click",
    CurrentValue = false,
    Callback = function(v)
        getgenv().AutoClick = v
        spawn(function()
            while getgenv().AutoClick do
                game:GetService("ReplicatedStorage").Remotes.Server.Click:FireServer()
                wait(0.01)
            end
        end)
    end,
})

Tab:CreateToggle({
    Name = "Force Max Strength + Rebirth",
    CurrentValue = false,
    Callback = function(v)
        if v then
            spawn(function()
                while true do
                    local replica = game:GetService("ReplicatedStorage").Client.DataClient:GetReplica()
                    if replica and replica.Data then
                        replica.Data.Strength = 999999999999
                    end
                    game:GetService("ReplicatedStorage").Remotes.Server.Rebirth:FireServer("Rebirth")
                    wait(0.5)
                end
            end)
        end
    end,
})

Tab:CreateButton({
    Name = "Set Insane Strength Now",
    Callback = function()
        local replica = game:GetService("ReplicatedStorage").Client.DataClient:GetReplica()
        if replica and replica.Data then
            replica.Data.Strength = 1e12
        end
    end,
})

print("✅ Strength Bypass Loaded")
