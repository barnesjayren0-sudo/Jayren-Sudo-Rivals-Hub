-- JJS_main.lua
-- Moveset Checker
-- Created by Grok for Jayren Sudo Rivals Hub

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Simple Moveset Checker
local function checkMoveset()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    
    print("========== JJS Moveset Checker ==========")
    print("Player:", LocalPlayer.Name)
    
    -- Check common places for moveset data
    local possiblePlaces = {
        LocalPlayer:FindFirstChild("Moveset"),
        LocalPlayer:FindFirstChild("PlayerData"),
        LocalPlayer:FindFirstChild("Data"),
        character:FindFirstChild("Moveset"),
        ReplicatedStorage:FindFirstChild("Movesets"),
        ReplicatedStorage:FindFirstChild("Modules")
    }
    
    for _, place in pairs(possiblePlaces) do
        if place then
            print("Found:", place:GetFullName())
            for _, child in pairs(place:GetChildren()) do
                print("  -", child.Name, "(", child.ClassName, ")")
            end
        end
    end
    
    -- Check character tools / abilities
    print("\nCharacter Tools/Abilities:")
    for _, item in pairs(character:GetChildren()) do
        if item:IsA("Tool") or item:IsA("Folder") or item:IsA("LocalScript") or item:IsA("ModuleScript") then
            print("  -", item.Name, "(", item.ClassName, ")")
        end
    end
    
    -- Check Backpack
    print("\nBackpack:")
    for _, item in pairs(LocalPlayer.Backpack:GetChildren()) do
        print("  -", item.Name, "(", item.ClassName, ")")
    end
    
    print("=========================================")
end

-- Run checker
checkMoveset()

-- Also create a simple GUI button to re-check
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JJS_MovesetChecker"
ScreenGui.Parent = game:GetService("CoreGui")

local Button = Instance.new("TextButton")
Button.Size = UDim2.new(0, 180, 0, 40)
Button.Position = UDim2.new(0, 20, 0.5, -20)
Button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Button.TextColor3 = Color3.fromRGB(255, 255, 255)
Button.Text = "Check Moveset"
Button.Font = Enum.Font.GothamBold
Button.TextSize = 14
Button.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Button

Button.MouseButton1Click:Connect(function()
    checkMoveset()
end)

print("JJS Moveset Checker loaded! Click the button or check console (F9)")
