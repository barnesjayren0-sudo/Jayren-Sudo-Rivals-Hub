--// Steal An Egg - Research Upgraded Mobile Auto Farm
--// Luau
--// Main features: Auto Farm Eggs + strict rare-target collector
--// Targets: Cosmic Secret -> Eternal -> Divine
--// Live egg source: workspace.AreaEggSlotsClient
--// ReplicatedStorage.AssetModels is inspected only as an optional metadata/template source.

local ok, Rayfield = pcall(function()
    return loadstring(game:HttpGet("https://sirius.menu/gen2"))()
end)

if not ok or not Rayfield then
    error("Failed to load Rayfield.")
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer
local Env = getgenv()

Env.EggAutoFarm = false
Env.TargetRares = true
Env.EggArea = "Automatic"

local CONFIG = {
    MoveTimeout = 9,
    ArrivalDistance = 5,
    LoopDelay = 0.65,
    RetryDelay = 0.12,
    SafeArea = Vector3.new(542, 71, -363),

    TargetPriority = {
        ["cosmicsecret"] = 3,
        ["eternal"] = 2,
        ["divine"] = 1,
    },

    RarityNames = {
        common = true,
        uncommon = true,
        rare = true,
        epic = true,
        legendary = true,
        mythic = true,
        cosmic = true,
        secret = true,
        eternal = true,
        divine = true,
    }
}

local Window = Rayfield:CreateWindow({
    name = "Egg Farm+",
    subtitle = "Mobile Auto Farm",
    sidebarLayout = true,
})

local FarmTab = Window:CreateTab({
    name = "Egg Farm",
    icon = "egg",
})

----------------------------------------------------------------
-- AREA DATA
----------------------------------------------------------------

local Areas = {
    ["Forest"] = 0,
    ["Lake"] = 900,
    ["Desert"] = 10000,
    ["Jungle"] = 40000,
    ["Snow"] = 450000,
    ["Volcano"] = 700000,
    ["Abyss Ocean"] = 2500000,
    ["Prehistoric"] = 17000000,
    ["Cosmic"] = 700000000,
    ["Cherry Blossom"] = 2500000000,
    ["Titan Temple"] = 7000000000,
    ["Light Dark"] = 20000000000,
}

----------------------------------------------------------------
-- BASIC HELPERS
----------------------------------------------------------------

local function getCharacter()
    local character = Player.Character
    if not character or not character.Parent then
        return nil, nil, nil
    end

    return character,
        character:FindFirstChildOfClass("Humanoid"),
        character:FindFirstChild("HumanoidRootPart")
end

local function getSpeed()
    local leaderstats = Player:FindFirstChild("leaderstats")
    local speed = leaderstats and leaderstats:FindFirstChild("Speed")
    return speed and tonumber(speed.Value) or 0
end

local function getNetworking()
    local packages = ReplicatedStorage:FindFirstChild("Packages")
    return packages and packages:FindFirstChild("Networking")
end

local function getStealRemote()
    local networking = getNetworking()
    return networking and networking:FindFirstChild(
        "RF/EggWorld/AskFieldEggCarry"
    )
end

local function normalize(text)
    return tostring(text or "")
        :lower()
        :gsub("[%s_%-]", "")
end

local function flatDistance(a, b)
    return (
        Vector2.new(a.X, a.Z) - Vector2.new(b.X, b.Z)
    ).Magnitude
end

----------------------------------------------------------------
-- AREA SELECTION
----------------------------------------------------------------

local function getBestArea()
    if Env.EggArea ~= "Automatic" then
        return Env.EggArea
    end

    local speed = getSpeed()
    local best = "Forest"
    local bestRequirement = 0

    for name, requirement in pairs(Areas) do
        if requirement <= speed and requirement >= bestRequirement then
            best = name
            bestRequirement = requirement
        end
    end

    return best
end

local function getAreaBounds()
    local objects = workspace:FindFirstChild("__OBJECTS")
    local areas = objects and objects:FindFirstChild("Areas")
    local guardAreas = areas and areas:FindFirstChild("GuardAreas")
    local selected = guardAreas and guardAreas:FindFirstChild(getBestArea())
    local bounds = selected and selected:FindFirstChild("Bounds")

    if bounds and bounds:IsA("BasePart") then
        return bounds
    end

    return nil
end

----------------------------------------------------------------
-- MOVEMENT
----------------------------------------------------------------

local function walkTo(humanoid, position)
    if not humanoid or humanoid.Health <= 0 then
        return false
    end

    local root = humanoid.RootPart
    if not root then
        return false
    end

    local started = os.clock()

    while Env.EggAutoFarm
        and humanoid.Parent
        and humanoid.Health > 0 do

        if flatDistance(root.Position, position) <= CONFIG.ArrivalDistance then
            return true
        end

        if os.clock() - started >= CONFIG.MoveTimeout then
            return false
        end

        humanoid:MoveTo(position)
        task.wait(0.10)
    end

    return false
end

----------------------------------------------------------------
-- RARITY / TARGET DETECTION
----------------------------------------------------------------

local function getTextFields(instance)
    local fields = {}

    if not instance then
        return fields
    end

    local attrs = {
        "Rarity",
        "EggRarity",
        "Tier",
        "RarityName",
        "EggTier",
        "PetRarity",
        "PetName",
        "EggName",
        "Name",
    }

    for _, name in ipairs(attrs) do
        local value = instance:GetAttribute(name)
        if value ~= nil then
            table.insert(fields, tostring(value))
        end

        local child = instance:FindFirstChild(name)
        if child then
            if child:IsA("StringValue")
                or child:IsA("IntValue")
                or child:IsA("NumberValue") then
                table.insert(fields, tostring(child.Value))
            end
        end
    end

    return fields
end

local function collectText(instance)
    local text = {}

    for _, value in ipairs(getTextFields(instance)) do
        table.insert(text, value)
    end

    if instance and instance:IsA("Model") then
        table.insert(text, instance.Name)
    end

    if instance and instance.PrimaryPart then
        for _, value in ipairs(getTextFields(instance.PrimaryPart)) do
            table.insert(text, value)
        end
    end

    return table.concat(text, " | ")
end

local function hasWord(text, word)
    return normalize(text):find(normalize(word), 1, true) ~= nil
end

local function identifyTarget(egg)
    local blob = collectText(egg)
    local n = normalize(blob)

    -- "Cosmic Secret" is treated as a compound target so ordinary Cosmic
    -- eggs do not qualify. It can match "Cosmic Secret Egg", a Cosmic-zone
    -- Secret result, or a model/attribute that contains both words.
    if hasWord(n, "cosmic") and hasWord(n, "secret") then
        return "cosmicsecret", CONFIG.TargetPriority.cosmicsecret
    end

    if hasWord(n, "eternal") then
        return "eternal", CONFIG.TargetPriority.eternal
    end

    if hasWord(n, "divine") then
        return "divine", CONFIG.TargetPriority.divine
    end

    return nil, 0
end

local function getEggPart(egg)
    if not egg then
        return nil
    end

    if egg:IsA("Model") then
        if egg.PrimaryPart and egg.PrimaryPart:IsA("BasePart") then
            return egg.PrimaryPart
        end

        return egg:FindFirstChildWhichIsA("BasePart", true)
    end

    if egg:IsA("BasePart") then
        return egg
    end

    return nil
end

----------------------------------------------------------------
-- LIVE EGG SOURCE
----------------------------------------------------------------

local function getLiveEggs()
    -- The verified live source supplied by the user.
    local folder = workspace:FindFirstChild("AreaEggSlotsClient")

    if not folder then
        return {}
    end

    return folder:GetChildren()
end

local function getTemplateMetadata()
    -- AssetModels is kept as a fallback metadata/template source only.
    -- ReplicatedStorage models are not treated as stealable world instances.
    local folder = ReplicatedStorage:FindFirstChild("AssetModels")
    if not folder then
        return {}
    end

    local metadata = {}

    for _, item in ipairs(folder:GetDescendants()) do
        if item:IsA("Model") then
            local key = normalize(item.Name)
            if key ~= "" then
                metadata[key] = item.Name
            end
        end
    end

    return metadata
end

local TemplateMetadata = getTemplateMetadata()

----------------------------------------------------------------
-- TARGET SEARCH
----------------------------------------------------------------

local function findBestTarget(root)
    if not root then
        return nil
    end

    local bestEgg
    local bestPriority = -math.huge
    local bestDistance = math.huge

    for _, egg in ipairs(getLiveEggs()) do
        local part = getEggPart(egg)

        if part and part.Parent then
            local targetName, priority = identifyTarget(egg)

            if targetName and Env.TargetRares then
                local distance = (part.Position - root.Position).Magnitude

                if priority > bestPriority
                    or (priority == bestPriority and distance < bestDistance) then
                    bestEgg = egg
                    bestPriority = priority
                    bestDistance = distance
                end
            end
        end
    end

    -- When no target is found, return nil instead of falling back to normal
    -- eggs. This prevents the rare-only mode from stealing unwanted eggs.
    return bestEgg
end

----------------------------------------------------------------
-- NOCLIP
----------------------------------------------------------------

local NoclipConnection
local CollisionState = {}

local function startNoclip()
    if NoclipConnection then
        return
    end

    NoclipConnection = RunService.Stepped:Connect(function()
        if not Env.EggAutoFarm then
            return
        end

        local character = Player.Character
        if not character then
            return
        end

        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                if CollisionState[part] == nil then
                    CollisionState[part] = true
                end
                part.CanCollide = false
            end
        end
    end)
end

local function stopNoclip()
    if NoclipConnection then
        NoclipConnection:Disconnect()
        NoclipConnection = nil
    end

    for part, previous in pairs(CollisionState) do
        if part and part.Parent then
            part.CanCollide = previous
        end
    end

    table.clear(CollisionState)
end

----------------------------------------------------------------
-- COLLECT ONE TARGET
----------------------------------------------------------------

local function collectEgg()
    local _, humanoid, root = getCharacter()
    if not humanoid or not root then
        return false
    end

    local bounds = getAreaBounds()
    if not bounds then
        return false
    end

    local remote = getStealRemote()
    if not remote then
        return false
    end

    -- Return to the safe route first.
    humanoid.HipHeight = 20
    walkTo(humanoid, CONFIG.SafeArea)
    humanoid.HipHeight = 2

    if not Env.EggAutoFarm then
        return false
    end

    if not walkTo(humanoid, bounds.Position) then
        return false
    end

    local egg = findBestTarget(root)
    local part = getEggPart(egg)

    if not egg or not part then
        -- Do not touch ordinary eggs when rare-only mode is enabled.
        return false
    end

    local targetName = identifyTarget(egg)

    if not targetName then
        return false
    end

    if not walkTo(humanoid, part.Position) then
        return false
    end

    task.wait(CONFIG.RetryDelay)

    if not egg.Parent or not part.Parent then
        return false
    end

    local success = pcall(function()
        remote:InvokeServer({
            Uid = egg.Name
        })
    end)

    if success then
        walkTo(humanoid, CONFIG.SafeArea)
    end

    return success
end

----------------------------------------------------------------
-- FARM CONTROLLER
----------------------------------------------------------------

local Running = false
local Generation = 0

local function stopFarm()
    Env.EggAutoFarm = false
    Generation += 1
    Running = false

    stopNoclip()

    local _, humanoid = getCharacter()
    if humanoid then
        humanoid.HipHeight = 2
    end
end

local function startFarm()
    if Running then
        return
    end

    Running = true
    Env.EggAutoFarm = true
    Generation += 1

    local generation = Generation
    startNoclip()

    task.spawn(function()
        while Env.EggAutoFarm
            and Running
            and Generation == generation do

            local ok, err = xpcall(
                collectEgg,
                debug.traceback
            )

            if not ok then
                warn("[Egg Farm] " .. tostring(err))
                task.wait(0.8)
            else
                task.wait(CONFIG.LoopDelay)
            end
        end

        if Generation == generation then
            Running = false
            stopNoclip()

            local _, humanoid = getCharacter()
            if humanoid then
                humanoid.HipHeight = 2
            end
        end
    end)
end

Player.CharacterAdded:Connect(function()
    task.wait(1)

    if Env.EggAutoFarm then
        startNoclip()
    end
end)

----------------------------------------------------------------
-- RAYFIELD MOBILE UI
----------------------------------------------------------------

local areaOptions = {"Automatic"}
local areaNames = {}

for name in pairs(Areas) do
    table.insert(areaNames, name)
end

table.sort(areaNames, function(a, b)
    return Areas[a] < Areas[b]
end)

for _, name in ipairs(areaNames) do
    table.insert(areaOptions, name)
end

FarmTab:CreateSection("Farm Controls")

FarmTab:CreateToggle({
    name = "Auto Farm Eggs",
    currentValue = false,
    flag = "EggAutoFarm",
    callback = function(value)
        if value then
            startFarm()
        else
            stopFarm()
        end
    end,
})

FarmTab:CreateToggle({
    name = "Auto Collect Rarest",
    currentValue = true,
    flag = "TargetRares",
    callback = function(value)
        Env.TargetRares = value
    end,
})

FarmTab:CreateDropdown({
    name = "Farm Area",
    options = areaOptions,
    currentOption = {"Automatic"},
    flag = "EggArea",
    callback = function(value)
        if type(value) == "table" then
            Env.EggArea = value[1] or "Automatic"
        else
            Env.EggArea = value
        end
    end,
})

FarmTab:CreateParagraph({
    title = "Rare Targets",
    content = "Cosmic Secret > Eternal > Divine\nLive source: workspace.AreaEggSlotsClient",
})

FarmTab:CreateParagraph({
    title = "Mobile",
    content = "Rayfield Gen2 UI with a compact single-tab layout.",
})

pcall(function()
    Rayfield:Notify({
        Title = "Egg Farm+",
        Content = "Rayfield mobile UI loaded.",
        Duration = 3,
    })
end)

if TemplateMetadata and next(TemplateMetadata) then
    _G.StealAnEggAssetModelMetadata = TemplateMetadata
end
