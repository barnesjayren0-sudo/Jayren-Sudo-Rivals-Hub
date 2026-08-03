-- Tapebrainrot.lua
-- Skip onboarding steps via SetOnboardingStep

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Events = ReplicatedStorage:WaitForChild("Events")
local SetOnboardingStep = Events:WaitForChild("SetOnboardingStep")

local function fireStep(step)
    pcall(function()
        SetOnboardingStep:FireServer(step)
    end)
end

-- Fire the steps you provided
fireStep(2)
task.wait(0.15)
fireStep(3)

print("[Tapebrainrot] Onboarding steps 2 and 3 fired.")

-- Optional: fire a wider range of steps if the game has more
-- Uncomment below if needed
--[[
for i = 1, 20 do
    fireStep(i)
    task.wait(0.1)
end
]]
