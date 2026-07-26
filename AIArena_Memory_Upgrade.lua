-- Grok Hacker - Memory Only Infinite Upgrades (AIArena)

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({Name = "Grok AIArena Memory Hack"})

local Tab = Window:CreateTab("Memory Upgrades", 4483362458)

Tab:CreateToggle({
    Name = "Infinite Memory Upgrades Only",
    CurrentValue = false,
    Callback = function(Value)
        getgenv().AutoMemory = Value
        spawn(function()
            while getgenv().AutoMemory do
                game:GetService("ReplicatedStorage").AIArena.Remotes.BuyUpgrade:FireServer("Memory")
                game:GetService("ReplicatedStorage").AIArena.Remotes.BuyUpgrade:FireServer("memory")
                wait(0.2)
            end
        end)
    end,
})

Tab:CreateButton({
    Name = "Max Memory Once",
    Callback = function()
        local remote = game:GetService("ReplicatedStorage").AIArena.Remotes.BuyUpgrade
        for i = 1, 100 do
            remote:FireServer("Memory")
        end
    end,
})

print("✅ Memory Only Hack Loaded")
