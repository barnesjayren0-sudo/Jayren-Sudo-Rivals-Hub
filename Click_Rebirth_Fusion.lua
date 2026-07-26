-- Grok Hacker - Ultimate Click + Rebirth Fusion (Rayfield)
-- Auto Clicker + Force Rebirth Bypass

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "🔥 Grok Hacker - Click + Rebirth Fusion",
    LoadingTitle = "Loading Ultimate Farm...",
    LoadingSubtitle = "Delta Executor",
})

local MainTab = Window:CreateTab("Main Farm", 4483362458)

-- Auto Clicker
local isClicking = false
MainTab:CreateToggle({
    Name = "Infinite Click Loop",
    CurrentValue = false,
    Flag = "ClickToggle",
    Callback = function(Value)
        isClicking = Value
        if isClicking then
            spawn(function()
                while isClicking do
                    local Event = game:GetService("ReplicatedStorage").Remotes.Server.Click
                    Event:FireServer()
                    wait(0.01)
                end
            end)
            Rayfield:Notify({Title = "Clicker ON", Content = "Dropping 100+ clicks/sec", Duration = 3})
        else
            Rayfield:Notify({Title = "Clicker OFF", Content = "Stopped", Duration = 2})
        end
    end,
})

-- Force Rebirth
local isRebirthing = false
MainTab:CreateToggle({
    Name = "Force Infinite Rebirths (Bypass Requirements)",
    CurrentValue = false,
    Flag = "RebirthToggle",
    Callback = function(Value)
        isRebirthing = Value
        if isRebirthing then
            spawn(function()
                while isRebirthing do
                    local args = { "Rebirth" }
                    local rebirthRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Server"):WaitForChild("Rebirth")
                    rebirthRemote:FireServer(unpack(args))
                    wait(0.5)
                end
            end)
            Rayfield:Notify({Title = "Rebirth Bypass ON", Content = "Forcing rebirths regardless of reqs!", Duration = 4})
        else
            Rayfield:Notify({Title = "Rebirth OFF", Content = "Stopped", Duration = 2})
        end
    end,
})

MainTab:CreateButton({
    Name = "One-Time Force Rebirth",
    Callback = function()
        local args = { "Rebirth" }
        local rebirthRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Server"):WaitForChild("Rebirth")
        rebirthRemote:FireServer(unpack(args))
        Rayfield:Notify({Title = "Rebirth Fired", Content = "Single push sent", Duration = 2})
    end,
})

print("🔥 Grok Fusion Hack Loaded - Dominate now!")
