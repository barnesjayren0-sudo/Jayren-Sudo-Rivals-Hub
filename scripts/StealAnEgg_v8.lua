--// STEAL AN EGG v8 | Jayren Hub
--// Rayfield Gen2 + EggState / Assets rarity collector
--// Priority: Cosmic → Secret → Eternal → Divine
--// Default: corridor walk | Optional: Instant TP (Potato-style)
--// Fixed: Auto Farm toggle now correctly starts/stops the farm loop

local ok, Rayfield = pcall(function()
    return loadstring(game:HttpGet("https://sirius.menu/gen2"))()
end)

if not ok or not Rayfield then
    pcall(function()
        Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
    end)
end

if not Rayfield then
    error("Rayfield failed to load.")
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local Env = (getgenv and getgenv()) or _G

-- Prevent duplicate copies from stacking farm loops/connections.
if Env.__SAE_RAYFIELD_ULTRA_SHUTDOWN then
    pcall(Env.__SAE_RAYFIELD_ULTRA_SHUTDOWN)
end

if not game:IsLoaded() then
    game.Loaded:Wait()
end

Env.SAE_AutoFarm = false
Env.SAE_Area = "Automatic"
Env.SAE_Cosmic = true
Env.SAE_Secret = true
Env.SAE_Eternal = true
Env.SAE_Divine = true
Env.SAE_Priority = "Rarest"
Env.SAE_InstantTP = false

local CONFIG = {
    SafeArea = Vector3.new(542, 71, -363),
    MoveSpeed = 300,
    MoveTimeout = 14,
    ArriveDistance = 1.5,
    GrabDelay = 0.55,
    ScanDelay = 0.08,
    ScanAttempts = 25,
    ReturnDelay = 0.12,
    LoopDelay = 0.35,

    -- Higher number = higher priority
    -- Cosmic → Secret → Eternal → Divine
    Priority = {
        cosmic = 4,
        secret = 3,
        eternal = 2,
        divine = 1,
    },
}

local Window = Rayfield:CreateWindow({
    name = "Egg Farm+",
    subtitle = "Mobile Rare Egg Farm",
    sidebarLayout = true,
    scrollSize = 300,
})

local Tab = Window:CreateTab({
    name = "Egg Farm",
    icon = "egg",
})

----------------------------------------------------------------
-- MODULE HELPERS
----------------------------------------------------------------

local function requirePath(root, ...)
    local cur = root

    for _, name in ipairs({ ... }) do
        if not cur then
            return nil
        end

        local child = cur:FindFirstChild(name)
        if not child then
            child = cur:WaitForChild(name, 4)
        end

        cur = child
    end

    if not cur or not cur:IsA("ModuleScript") then
        return nil
    end

    local success, result = pcall(require, cur)
    return success and result or nil
end

local function findModule(name)
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("ModuleScript") and obj.Name == name then
            local success, result = pcall(require, obj)
            if success then
                return result
            end
        end
    end
end

local function pickFn(mod, ...)
    if type(mod) ~= "table" then
        return nil
    end

    for i = 1, select("#", ...) do
        local name = select(i, ...)
        local fn = mod[name]
        if type(fn) == "function" then
            return fn
        end
    end
end

local EggState =
    requirePath(ReplicatedStorage, "Client", "EggState") or
    findModule("EggState")

local AssetsData =
    requirePath(ReplicatedStorage, "Data", "Assets") or
    findModule("Assets")

local AreasData =
    requirePath(ReplicatedStorage, "Data", "Areas") or
    findModule("Areas")

local SlotIdentity =
    requirePath(ReplicatedStorage, "Shared", "Util", "AreaEggSlotIdentity") or
    findModule("AreaEggSlotIdentity")

local Save =
    requirePath(ReplicatedStorage, "Shared", "Save") or
    findModule("Save")

local EggTypes =
    requirePath(ReplicatedStorage, "Shared", "Types", "Eggs") or
    findModule("Eggs")

local EggAPI = {
    GetSnapshot = pickFn(EggState, "ReadFieldEggs", "GetAreaEggSnapshot"),
    RequestSnapshot = pickFn(EggState, "SyncFieldEggs", "RequestAreaEggSnapshot"),
    Carry = pickFn(EggState, "CarryFieldEgg", "RequestCarryAreaEgg"),
    CarryChanged = EggState and (EggState.CarryChanged or EggState.AreaEggCarryStateChanged),
}

local SlotAPI = {
    IsFirstAreaUid = pickFn(SlotIdentity, "LooksLikeFirstAreaUid", "IsFirstAreaUid"),
    BuildSlotKey = pickFn(SlotIdentity, "SlotKey", "BuildSlotKey"),
}

----------------------------------------------------------------
-- REMOTE FALLBACKS
----------------------------------------------------------------

local function findRemote(name)
    local packages = ReplicatedStorage:FindFirstChild("Packages")
    local networking = packages and packages:FindFirstChild("Networking")

    if networking then
        local direct = networking:FindFirstChild(name)
        if direct then
            return direct
        end
    end

    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if (obj:IsA("RemoteFunction") or obj:IsA("RemoteEvent"))
            and obj.Name == name then
            return obj
        end
    end
end

local CarryRemote = findRemote("RF/EggWorld/AskFieldEggCarry")
local SnapshotRemote = findRemote("RF/EggWorld/AskFieldEggSnapshot")

local function unwrapSnapshot(value)
    if type(value) ~= "table" then
        return {}
    end

    if type(value.Records) == "table" then
        return value.Records
    end

    return value
end

local function requestSnapshot()
    if EggAPI.GetSnapshot then
        local success, snapshot = pcall(EggAPI.GetSnapshot)

        if success and type(snapshot) == "table" then
            local records = unwrapSnapshot(snapshot)

            if next(records) ~= nil then
                return records
            end
        end
    end

    if EggAPI.RequestSnapshot then
        pcall(EggAPI.RequestSnapshot)
        task.wait(0.05)

        if EggAPI.GetSnapshot then
            local success, snapshot = pcall(EggAPI.GetSnapshot)

            if success and type(snapshot) == "table" then
                local records = unwrapSnapshot(snapshot)

                if next(records) ~= nil then
                    return records
                end
            end
        end
    end

    if SnapshotRemote and SnapshotRemote:IsA("RemoteFunction") then
        local success, snapshot = pcall(function()
            return SnapshotRemote:InvokeServer()
        end)

        if success and type(snapshot) == "table" then
            return unwrapSnapshot(snapshot)
        end
    end

    return {}
end

----------------------------------------------------------------
-- GAME DATA / RARITY
----------------------------------------------------------------

local function normalize(value)
    return tostring(value or "")
        :lower()
        :gsub("[%s_%-]", "")
end

local function assetDirectoryEntry(category)
    if type(category) ~= "string" then
        return nil
    end

    local directory = AssetsData and AssetsData.Directory
    if type(directory) ~= "table" then
        return nil
    end

    return directory[category]
end

local function rarityFromAssetCategory(category)
    local entry = assetDirectoryEntry(category)
    if type(entry) ~= "table" then
        return nil
    end

    local rarity = entry.Rarity

    if type(rarity) == "table" then
        return rarity._id or rarity.DisplayName or rarity.Id
    end

    if rarity ~= nil then
        return tostring(rarity)
    end

    return nil
end

local function displayNameFromAssetCategory(category)
    local entry = assetDirectoryEntry(category)

    if type(entry) == "table" and entry.DisplayName then
        return tostring(entry.DisplayName)
    end

    return tostring(category or "")
end

local function textFromObject(instance)
    if not instance then
        return ""
    end

    local parts = { tostring(instance.Name or "") }

    if instance:IsA("StringValue") then
        table.insert(parts, tostring(instance.Value))
    elseif instance:IsA("TextLabel") or instance:IsA("TextButton") then
        table.insert(parts, tostring(instance.Text))
    end

    for attribute, value in pairs(instance:GetAttributes()) do
        table.insert(parts, tostring(attribute))
        table.insert(parts, tostring(value))
    end

    return table.concat(parts, " ")
end

local function recordRarity(record)
    if type(record) ~= "table" then
        return ""
    end

    local resolved = rarityFromAssetCategory(record.AssetCategory)

    if resolved then
        return tostring(resolved)
    end

    for _, key in ipairs({
        "Rarity",
        "RarityName",
        "Tier",
        "EggRarity"
    }) do
        if record[key] ~= nil then
            return tostring(record[key])
        end
    end

    local displayName = displayNameFromAssetCategory(record.AssetCategory)

    if displayName ~= "" then
        return displayName
    end

    return ""
end

local function recordText(record)
    if type(record) ~= "table" then
        return ""
    end

    local fields = {
        record.AssetCategory,
        record.AssetName,
        record.DisplayName,
        record.Rarity,
        record.RarityName,
        record.Tier,
        record.EggRarity
    }

    local out = {}

    for _, value in ipairs(fields) do
        if value ~= nil then
            table.insert(out, tostring(value))
        end
    end

    local displayName = displayNameFromAssetCategory(record.AssetCategory)

    if displayName ~= "" then
        table.insert(out, displayName)
    end

    return table.concat(out, " ")
end

local function recordIsTarget(record)
    if type(record) ~= "table" then
        return nil, 0
    end

    local rarity = normalize(recordRarity(record))
    local text = normalize(recordText(record))
    local category = normalize(record.AssetCategory)

    -- Priority order: Cosmic → Secret → Eternal → Divine
    -- Cosmic checked first (includes "cosmicsecret" names as Cosmic tier)

    local isCosmic =
        Env.SAE_Cosmic and (
            rarity == "cosmic"
            or rarity == "cosmicsecret"
            or rarity:find("cosmic", 1, true) ~= nil
            or text:find("cosmic", 1, true) ~= nil
            or category:find("cosmic", 1, true) ~= nil
        )

    if isCosmic then
        return "cosmic", CONFIG.Priority.cosmic
    end

    local isSecret =
        Env.SAE_Secret and (
            rarity == "secret"
            or rarity:find("secret", 1, true) ~= nil
            or text:find("secret", 1, true) ~= nil
            or category:find("secret", 1, true) ~= nil
        )

    if isSecret then
        return "secret", CONFIG.Priority.secret
    end

    local isEternal =
        Env.SAE_Eternal and (
            rarity == "eternal"
            or rarity:find("eternal", 1, true) ~= nil
            or text:find("eternal", 1, true) ~= nil
            or category:find("eternal", 1, true) ~= nil
        )

    if isEternal then
        return "eternal", CONFIG.Priority.eternal
    end

    local isDivine =
        Env.SAE_Divine and (
            rarity == "divine"
            or rarity:find("divine", 1, true) ~= nil
            or text:find("divine", 1, true) ~= nil
            or category:find("divine", 1, true) ~= nil
        )

    if isDivine then
        return "divine", CONFIG.Priority.divine
    end

    return nil, 0
end

----------------------------------------------------------------
-- INVENTORY GUARD
----------------------------------------------------------------

local function inventoryFull()
    if not Save or type(Save) ~= "table" then
        return false
    end

    local inventory = Save.EggInventory

    if type(inventory) ~= "table" then
        return false
    end

    local count = 0

    for _ in pairs(inventory) do
        count += 1
    end

    local capacity = EggTypes and tonumber(EggTypes.MAX_INVENTORY)

    return capacity ~= nil and count >= capacity
end

----------------------------------------------------------------
-- AREA
----------------------------------------------------------------

local AreaRequirements = {
    Forest = 0,
    Lake = 900,
    Desert = 10000,
    Jungle = 40000,
    Snow = 450000,
    Volcano = 700000,
    ["Abyss Ocean"] = 2500000,
    Prehistoric = 17000000,
    Cosmic = 700000000,
    ["Cherry Blossom"] = 2500000000,
    ["Titan Temple"] = 7000000000,
    ["Light Dark"] = 20000000000,
}

local function getSpeed()
    local stats = Player:FindFirstChild("leaderstats")
    local speed = stats and stats:FindFirstChild("Speed")
    return speed and tonumber(speed.Value) or 0
end

local function getArea()
    if Env.SAE_Area ~= "Automatic" then
        return Env.SAE_Area
    end

    -- Prefer the game's Areas directory when available.
    if AreasData and type(AreasData.Directory) == "table" then
        local best = "Forest"
        local bestRequirement = 0
        local speed = getSpeed()

        for name, data in pairs(AreasData.Directory) do
            if type(data) == "table" then
                local requirement =
                    tonumber(data.Speed) or
                    tonumber(data.RequiredSpeed) or
                    tonumber(data.SpeedRequirement)

                if requirement and requirement <= speed and requirement >= bestRequirement then
                    best = data.DisplayName or name
                    bestRequirement = requirement
                end
            end
        end

        return best
    end

    local speed = getSpeed()
    local best = "Forest"
    local bestRequirement = 0

    for name, requirement in pairs(AreaRequirements) do
        if requirement <= speed and requirement >= bestRequirement then
            best = name
            bestRequirement = requirement
        end
    end

    return best
end

----------------------------------------------------------------
-- WORLD EGG OBJECTS
----------------------------------------------------------------

local EggFolder = workspace:FindFirstChild("AreaEggSlotsClient")

local function refreshEggFolder()
    EggFolder = workspace:FindFirstChild("AreaEggSlotsClient")
end

local function eggPart(instance)
    if not instance then
        return nil
    end

    if instance:IsA("BasePart") then
        return instance
    end

    if instance:IsA("Model") then
        if instance.PrimaryPart and instance.PrimaryPart:IsA("BasePart") then
            return instance.PrimaryPart
        end

        return instance:FindFirstChildWhichIsA("BasePart", true)
    end
end

local function eggPosition(instance)
    local part = eggPart(instance)

    if part then
        return part.Position
    end

    local success, pivot = pcall(function()
        return instance:GetPivot()
    end)

    return success and pivot.Position or nil
end

local function inArea(record, position, bounds)
    local chosen = getArea()

    if record.AreaId then
        return tostring(record.AreaId) == tostring(chosen)
    end

    if bounds and position then
        local localPosition = bounds.CFrame:PointToObjectSpace(position)
        local half = bounds.Size * 0.5 + Vector3.new(30, 30, 30)

        return math.abs(localPosition.X) <= half.X
            and math.abs(localPosition.Y) <= half.Y
            and math.abs(localPosition.Z) <= half.Z
    end

    return true
end

local function getAreaBounds()
    local objects = workspace:FindFirstChild("__OBJECTS")
    local areas = objects and objects:FindFirstChild("Areas")
    local guards = areas and areas:FindFirstChild("GuardAreas")
    local area = guards and guards:FindFirstChild(getArea())
    local bounds = area and area:FindFirstChild("Bounds")

    if bounds and bounds:IsA("BasePart") then
        return bounds
    end
end

----------------------------------------------------------------
-- TARGET SELECTION
----------------------------------------------------------------

local function buildRecordMap(records)
    local byUid = {}

    for _, record in pairs(records) do
        if type(record) == "table" and type(record.Uid) == "string" then
            byUid[record.Uid] = record
        end
    end

    return byUid
end

local function getTarget()
    refreshEggFolder()

    if not EggFolder then
        return nil
    end

    local records = requestSnapshot()
    local byUid = buildRecordMap(records)

    local bounds = getAreaBounds()
    local root = getRoot()

    if not root then
        return nil
    end

    local best
    local bestPriority = -math.huge
    local bestDistance = math.huge

    for _, instance in ipairs(EggFolder:GetChildren()) do
        local uid = instance.Name
        local record = byUid[uid]
        local position = eggPosition(instance)

        -- In some versions the model can expose its UID through an attribute.
        if not record then
            local attrUid = instance:GetAttribute("Uid")
                or instance:GetAttribute("UID")

            if attrUid then
                record = byUid[tostring(attrUid)]
                if record then
                    uid = tostring(attrUid)
                end
            end
        end

        if record
            and position
            and (tostring(record.State or "Slot") == "Slot"
                or tostring(record.State or "") == "Dropped")
            and inArea(record, position, bounds) then

            local target, priority = recordIsTarget(record)

            if target then
                local distance = (position - root.Position).Magnitude

                if Env.SAE_Priority == "Nearest" then
                    priority = 0
                end

                if priority > bestPriority
                    or (priority == bestPriority and distance < bestDistance) then

                    best = {
                        Instance = instance,
                        Record = record,
                        Position = position,
                        Target = target,
                        Priority = priority,
                        Distance = distance,
                    }

                    bestPriority = priority
                    bestDistance = distance
                end
            end
        end
    end

    return best
end

----------------------------------------------------------------
-- MOVEMENT
----------------------------------------------------------------

local function getHumanoid()
    local c = Player.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function getRoot()
    local c = Player.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getLaneZ()
    local objects = Workspace:FindFirstChild("__OBJECTS")
    local areas = objects and objects:FindFirstChild("Areas")
    local gameplayZ = areas and areas:FindFirstChild("GameplayZ")
    local separation = areas and areas:FindFirstChild("SeparationLine")

    if gameplayZ and gameplayZ:IsA("BasePart") then
        return gameplayZ.Position.Z
    end

    if separation and separation:IsA("BasePart") then
        return separation.Position.Z
    end

    return -365.5
end

local function getLaneY()
    local objects = Workspace:FindFirstChild("__OBJECTS")
    local areas = objects and objects:FindFirstChild("Areas")
    local gameplayZ = areas and areas:FindFirstChild("GameplayZ")

    if gameplayZ and gameplayZ:IsA("BasePart") then
        return gameplayZ.Position.Y + 3
    end

    local root = getRoot()
    return root and root.Position.Y or 70
end

local function groundedY(x, z, fallback)
    local root = getRoot()
    local humanoid = getHumanoid()

    local hip = humanoid and humanoid.HipHeight or 2
    local half = root and root.Size.Y * 0.5 or 1
    local laneY = getLaneY()

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {Player.Character}

    local hit = Workspace:Raycast(
        Vector3.new(x, laneY + 40, z),
        Vector3.new(0, -160, 0),
        params
    )

    if hit then
        return math.clamp(hit.Position.Y + hip + half, laneY - 2, laneY + 5)
    end

    return tonumber(fallback) or (laneY + 3)
end

local function moveToPosition(position)
    if typeof(position) ~= "Vector3" then
        return false
    end

    local root = getRoot()
    if not root then
        return false
    end

    local humanoid = getHumanoid()

    -- First attempt ordinary Roblox movement. This is less disruptive
    -- when the game navmesh/path is usable.
    if humanoid and humanoid.Health > 0 then
        local started = os.clock()

        humanoid:MoveTo(position)

        while Env.SAE_AutoFarm
            and humanoid.Parent
            and humanoid.Health > 0
            and os.clock() - started < 1.25 do

            root = getRoot()

            if not root then
                return false
            end

            local target = Vector3.new(
                position.X,
                groundedY(position.X, position.Z, position.Y),
                position.Z
            )

            if (root.Position - target).Magnitude <= CONFIG.ArriveDistance then
                return true
            end

            task.wait(0.05)
        end
    end

    -- Controlled fallback modeled after the reference corridor movement.
    local started = os.clock()

    while Env.SAE_AutoFarm do
        root = getRoot()

        if not root then
            return false
        end

        local target = Vector3.new(
            position.X,
            groundedY(position.X, position.Z, position.Y),
            position.Z
        )

        local delta = target - root.Position
        local distance = delta.Magnitude

        if distance <= CONFIG.ArriveDistance then
            root.CFrame = CFrame.new(target)
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
            return true
        end

        if os.clock() - started >= CONFIG.MoveTimeout then
            return false
        end

        local dt = RunService.Heartbeat:Wait()

        if typeof(dt) ~= "number" or dt <= 0 then
            dt = 1 / 60
        end

        local step = math.min(distance, CONFIG.MoveSpeed * dt)
        local nextPosition = root.Position + delta.Unit * step

        nextPosition = Vector3.new(
            nextPosition.X,
            groundedY(nextPosition.X, nextPosition.Z, nextPosition.Y),
            nextPosition.Z
        )

        local horizontal = Vector3.new(delta.X, 0, delta.Z)

        if horizontal.Magnitude > 0.05 then
            root.CFrame = CFrame.lookAt(
                nextPosition,
                nextPosition + horizontal
            )
        else
            root.CFrame = CFrame.new(nextPosition)
        end

        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end

    return false
end

local function collectPath(targetPosition)
    local root = getRoot()

    if not root then
        return false
    end

    local laneZ = getLaneZ()
    local laneY = getLaneY()

    local waypoints = {
        CONFIG.SafeArea,
        Vector3.new(root.Position.X, laneY, laneZ),
        Vector3.new(targetPosition.X, laneY, laneZ),
        targetPosition,
    }

    -- Keep the route compact by removing duplicate/nearly-equal points.
    local cleaned = {}

    for _, waypoint in ipairs(waypoints) do
        local previous = cleaned[#cleaned]

        if not previous
            or (previous - waypoint).Magnitude > CONFIG.ArriveDistance then
            table.insert(cleaned, waypoint)
        end
    end

    for _, waypoint in ipairs(cleaned) do
        if not Env.SAE_AutoFarm then
            return false
        end

        if not moveToPosition(waypoint) then
            return false
        end
    end

    return true
end

----------------------------------------------------------------
-- CARRY / STEAL
----------------------------------------------------------------

local function getSlotKey(record)
    if not record then
        return nil
    end

    local uid = record.Uid

    if SlotAPI.IsFirstAreaUid
        and SlotAPI.BuildSlotKey then

        local success, firstArea = pcall(
            SlotAPI.IsFirstAreaUid,
            uid
        )

        if success and firstArea then
            local ok, key = pcall(
                SlotAPI.BuildSlotKey,
                record.AreaId,
                record.NestId
            )

            if ok then
                return key
            end
        end
    end
end

local function waitForCarry(timeout)
    local started = os.clock()

    while os.clock() - started < (timeout or CONFIG.GrabDelay) do
        if Carrying then
            return true
        end
        task.wait(0.04)
    end

    return Carrying
end

local function tryCarry(target)
    if not target or not target.Record then
        return false
    end

    local uid = target.Record.Uid
    local slotKey = getSlotKey(target.Record)

    -- Preferred current game-side API.
    if EggAPI.Carry then
        local success, result = pcall(function()
            return EggAPI.Carry(uid, slotKey)
        end)

        if success and (result == true or result ~= nil) then
            return true
        end

        if waitForCarry(0.15) then
            return true
        end
    end

    if CarryRemote then
        if CarryRemote:IsA("RemoteFunction") then
            -- Preferred signature from the recovered EggState pipeline.
            local success, result = pcall(function()
                return CarryRemote:InvokeServer(uid, slotKey)
            end)

            if success and (result == true or result ~= nil) then
                return true
            end

            if waitForCarry(0.15) then
                return true
            end

            -- Compatibility fallback for older public scripts.
            success, result = pcall(function()
                return CarryRemote:InvokeServer({
                    Uid = uid
                })
            end)

            if success and (result == true or result ~= nil) then
                return true
            end

            if waitForCarry(0.15) then
                return true
            end

        elseif CarryRemote:IsA("RemoteEvent") then
            local success = pcall(function()
                CarryRemote:FireServer(uid, slotKey)
            end)

            if success then
                return waitForCarry(0.2)
            end
        end
    end

    return Carrying
end

----------------------------------------------------------------
-- CARRY STATE
----------------------------------------------------------------

local Carrying = false
local SessionSteals = 0
local StatusText = "Idle"
local LastTarget = "None"

if EggAPI.CarryChanged and type(EggAPI.CarryChanged.Connect) == "function" then
    EggAPI.CarryChanged:Connect(function(state)
        if type(state) == "table" then
            local now = state.IsCarrying == true

            Carrying = now
        end
    end)
end

local function fallbackCarryState()
    return Carrying
end

----------------------------------------------------------------
-- FARM CYCLE
----------------------------------------------------------------

local function farmOnce()
    if Carrying then
        StatusText = "Already carrying"
        return false
    end

    if inventoryFull() then
        StatusText = "Egg inventory full"
        return false
    end

    StatusText = "Scanning..."

    local target

    for _ = 1, CONFIG.ScanAttempts do
        if not Env.SAE_AutoFarm then
            return false
        end

        target = getTarget()

        if target then
            break
        end

        task.wait(CONFIG.ScanDelay)
    end

    if not target then
        StatusText = "Waiting for rare egg"
        return false
    end

    LastTarget = string.upper(target.Target)
    StatusText = "Going to " .. LastTarget

    local root = getRoot()
    if not root then
        StatusText = "No character"
        return false
    end

    local savedCFrame = root.CFrame
    local usedInstant = false

    if Env.SAE_InstantTP then
        -- Potato-style Instant TP: save → warp to egg → hold for replication → carry → return
        usedInstant = true
        StatusText = "Instant TP → " .. LastTarget

        local pos = target.Position
        root.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        task.wait(0.12) -- hold for server replication

        if not Env.SAE_AutoFarm then
            root.CFrame = savedCFrame
            return false
        end
    else
        -- Default corridor walk
        if not collectPath(target.Position) then
            StatusText = "Movement failed"
            return false
        end

        if not Env.SAE_AutoFarm then
            return false
        end
    end

    -- Re-read immediately before the grab so a stale/deleted model
    -- doesn't cause us to invoke the wrong UID.
    local freshTarget = getTarget()

    if freshTarget
        and freshTarget.Target == target.Target then
        target = freshTarget
    end

    if not target.Instance
        or not target.Instance.Parent then
        StatusText = "Target disappeared"
        if usedInstant then
            root.CFrame = savedCFrame
        end
        return false
    end

    if not usedInstant then
        local freshPosition = eggPosition(target.Instance)
        if freshPosition then
            moveToPosition(freshPosition)
        end
        task.wait(CONFIG.GrabDelay)
    else
        task.wait(0.08)
    end

    if not Env.SAE_AutoFarm then
        if usedInstant then
            root.CFrame = savedCFrame
        end
        return false
    end

    StatusText = "Collecting " .. LastTarget

    local carried = tryCarry(target)

    -- One more fresh scan handles the common case where the live slot
    -- changed between the first scan and the actual carry request.
    if not carried and not Carrying then
        task.wait(0.08)

        local retry = getTarget()

        if retry then
            carried = tryCarry(retry)
            if carried then
                LastTarget = string.upper(retry.Target)
            end
        end
    end

    waitForCarry(0.2)

    if Carrying then
        SessionSteals += 1
    end

    StatusText = Carrying
        and ("Collected " .. LastTarget)
        or "Collect failed"

    -- Return
    task.wait(CONFIG.ReturnDelay)
    StatusText = "Returning"

    if usedInstant then
        root = getRoot()
        if root then
            root.CFrame = savedCFrame
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end
    else
        moveToPosition(CONFIG.SafeArea)
    end

    return carried or Carrying
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
        if not Env.SAE_AutoFarm then
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

    for part, oldValue in pairs(CollisionState) do
        if part and part.Parent then
            part.CanCollide = oldValue
        end
    end

    table.clear(CollisionState)
end

----------------------------------------------------------------
-- CLEAN SHUTDOWN
----------------------------------------------------------------

local Destroyed = false

local function shutdown()
    if Destroyed then
        return
    end

    Destroyed = true
    Env.SAE_AutoFarm = false
    Env.__SAE_RAYFIELD_SHUTDOWN = nil
    Env.__SAE_RAYFIELD_ULTRA_SHUTDOWN = nil

    stopNoclip()

    local humanoid = getHumanoid()
    if humanoid then
        humanoid.HipHeight = 2
    end

    pcall(function()
        Rayfield:Destroy()
    end)
end

Env.__SAE_RAYFIELD_ULTRA_SHUTDOWN = shutdown

----------------------------------------------------------------
-- UI
----------------------------------------------------------------

local function areaOptions()
    local result = { "Automatic" }
    local names = {}

    if AreasData and type(AreasData.Directory) == "table" then
        for name, data in pairs(AreasData.Directory) do
            if type(data) == "table" then
                table.insert(names, data.DisplayName or name)
            else
                table.insert(names, name)
            end
        end
    else
        for name in pairs(AreaRequirements) do
            table.insert(names, name)
        end
    end

    table.sort(names, function(a, b)
        return tostring(a) < tostring(b)
    end)

    for _, name in ipairs(names) do
        if name ~= "Automatic" then
            table.insert(result, name)
        end
    end

    return result
end

Tab:CreateSection("Auto Farm")

-- Toggle is wired after startFarm/stopFarm are defined (see bottom of file)
local AutoFarmToggle

Tab:CreateSection("Rare Targets")

Tab:CreateToggle({
    name = "Cosmic",
    currentValue = true,
    flag = "SAE_Cosmic",
    callback = function(value)
        Env.SAE_Cosmic = value
    end,
})

Tab:CreateToggle({
    name = "Secret",
    currentValue = true,
    flag = "SAE_Secret",
    callback = function(value)
        Env.SAE_Secret = value
    end,
})

Tab:CreateToggle({
    name = "Eternal",
    currentValue = true,
    flag = "SAE_Eternal",
    callback = function(value)
        Env.SAE_Eternal = value
    end,
})

Tab:CreateToggle({
    name = "Divine",
    currentValue = true,
    flag = "SAE_Divine",
    callback = function(value)
        Env.SAE_Divine = value
    end,
})

Tab:CreateToggle({
    name = "Instant TP (Potato)",
    currentValue = false,
    flag = "SAE_InstantTP",
    callback = function(value)
        Env.SAE_InstantTP = value
    end,
})

Tab:CreateDropdown({
    name = "Farm Area",
    options = areaOptions(),
    currentOption = { "Automatic" },
    flag = "SAE_Area",
    callback = function(value)
        if type(value) == "table" then
            Env.SAE_Area = value[1] or "Automatic"
        else
            Env.SAE_Area = value or "Automatic"
        end
    end,
})

Tab:CreateDropdown({
    name = "Target Priority",
    options = { "Rarest", "Nearest" },
    currentOption = { "Rarest" },
    flag = "SAE_Priority",
    callback = function(value)
        if type(value) == "table" then
            Env.SAE_Priority = value[1] or "Rarest"
        else
            Env.SAE_Priority = value or "Rarest"
        end
    end,
})

local StatusLabel = Tab:CreateParagraph({
    title = "Status",
    content = "Idle\nLast target: None\nSteals: 0",
})

Tab:CreateParagraph({
    title = "Detection",
    content = "Uses EggState records + Assets rarity data for identity, and AreaEggSlotsClient only for live position.",
})

Tab:CreateParagraph({
    title = "Targets",
    content = "Cosmic → Secret → Eternal → Divine",
})

----------------------------------------------------------------
-- FARM WORKER
----------------------------------------------------------------

local Running = false
local Generation = 0

local function stopFarm()
    Env.SAE_AutoFarm = false
    Generation += 1
    Running = false
    stopNoclip()

    local humanoid = getHumanoid()
    if humanoid then
        humanoid.HipHeight = 2
    end

    StatusText = "Stopped"
end

local function startFarm()
    if Running then
        return
    end

    Running = true
    Env.SAE_AutoFarm = true
    Generation += 1

    local generation = Generation
    startNoclip()
    StatusText = "Starting..."

    task.spawn(function()
        while not Destroyed
            and Running
            and Env.SAE_AutoFarm
            and Generation == generation do

            local success, err = xpcall(
                farmOnce,
                debug.traceback
            )

            if not success then
                warn("[Steal An Egg] " .. tostring(err))
                StatusText = "Recovered from error"
                task.wait(0.8)
            else
                task.wait(CONFIG.LoopDelay)
            end
        end

        if Generation == generation then
            Running = false
            stopNoclip()
            StatusText = "Stopped"
        end
    end)
end

-- Wire Auto Farm toggle + Stop button now that startFarm/stopFarm exist
AutoFarmToggle = Tab:CreateToggle({
    name = "Auto Farm Eggs",
    currentValue = false,
    flag = "SAE_AutoFarm",
    callback = function(value)
        if value then
            startFarm()
        else
            stopFarm()
        end
    end,
})

Tab:CreateButton({
    name = "Stop Farm",
    callback = function()
        stopFarm()
        if AutoFarmToggle and AutoFarmToggle.Set then
            pcall(function() AutoFarmToggle:Set(false) end)
        end
    end,
})

-- Restart support after respawn.
Player.CharacterAdded:Connect(function()
    task.wait(0.8)
    if Env.SAE_AutoFarm then
        startNoclip()
    end
end)

-- Update the small status panel without needing extra UI elements.
task.spawn(function()
    while true do
        task.wait(0.25)

        pcall(function()
            StatusLabel:Set({
                "Status: " .. tostring(StatusText),
                "Last target: " .. tostring(LastTarget),
                "Steals: " .. tostring(SessionSteals),
            })
        end)
    end
end)

pcall(function()
    Rayfield:Notify({
        Title = "Egg Farm+ v8",
        Content = "Priority: Cosmic → Secret → Eternal → Divine",
        Duration = 4,
    })
end)
