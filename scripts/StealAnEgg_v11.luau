--// STEAL AN EGG v11 | Jayren Hub
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
Env.SAE_ExactRareOnly = true
Env.SAE_Priority = "Rarest"
Env.SAE_InstantTP = false
Env.SAE_TargetLock = true
Env.SAE_SmartScan = true

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
    MoveRetryCount = 2,
    RescanAfterMove = 4,
    TargetLockRadius = 20,
    StuckDistance = 2.5,
    StuckTimeout = 1.0,

    -- Higher number = higher priority
    -- Exact requested rarities: Cosmic → Secret → Eternal → Divine
    Priority = {
        cosmic = 4,
        secret = 3,
        eternal = 2,
        divine = 1,
    },

    RarityAliases = {
        cosmic = {"cosmic"},
        secret = {"secret"},
        eternal = {"eternal"},
        divine = {"divine"},
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

local function containsAny(haystack, needles)
    for _, needle in ipairs(needles) do
        if haystack:find(needle, 1, true) then
            return true
        end
    end
    return false
end

local function cleanRarity(value)
    local n = normalize(value)
    if n == "cosmic" then return "cosmic" end
    if n == "secret" then return "secret" end
    if n == "eternal" then return "eternal" end
    if n == "divine" then return "divine" end
    return nil
end

local function recordIsTarget(record)
    if type(record) ~= "table" then
        return nil, 0
    end

    -- Prefer the game's actual rarity field. This prevents an egg named
    -- something like "Secret Keeper" from being treated as Secret.
    local authoritative =
        rarityFromAssetCategory(record.AssetCategory)
        or record.Rarity
        or record.RarityName
        or record.EggRarity
        or record.Tier

    local exact = cleanRarity(authoritative)

    if exact == "cosmic" and Env.SAE_Cosmic then
        return "cosmic", CONFIG.Priority.cosmic
    elseif exact == "secret" and Env.SAE_Secret then
        return "secret", CONFIG.Priority.secret
    elseif exact == "eternal" and Env.SAE_Eternal then
        return "eternal", CONFIG.Priority.eternal
    elseif exact == "divine" and Env.SAE_Divine then
        return "divine", CONFIG.Priority.divine
    end

    -- Metadata fallback for games/versions where EggState does not expose
    -- a clean rarity field on the record.
    local candidates = {
        recordRarity(record),
        record.Rarity,
        record.RarityName,
        record.EggRarity,
        record.Tier,
    }

    for _, candidate in ipairs(candidates) do
        local exactFallback = cleanRarity(candidate)
        if exactFallback == "cosmic" and Env.SAE_Cosmic then
            return "cosmic", CONFIG.Priority.cosmic
        elseif exactFallback == "secret" and Env.SAE_Secret then
            return "secret", CONFIG.Priority.secret
        elseif exactFallback == "eternal" and Env.SAE_Eternal then
            return "eternal", CONFIG.Priority.eternal
        elseif exactFallback == "divine" and Env.SAE_Divine then
            return "divine", CONFIG.Priority.divine
        end
    end

    -- Last-resort category matching for versions that encode rarity in the
    -- asset category name (for example, "CosmicEgg").
    local category = normalize(record.AssetCategory)
    for _, pair in ipairs({
        {"cosmic", Env.SAE_Cosmic, CONFIG.Priority.cosmic},
        {"secret", Env.SAE_Secret, CONFIG.Priority.secret},
        {"eternal", Env.SAE_Eternal, CONFIG.Priority.eternal},
        {"divine", Env.SAE_Divine, CONFIG.Priority.divine},
    }) do
        local key, enabled, priority = pair[1], pair[2], pair[3]
        if enabled and containsAny(category, CONFIG.RarityAliases[key]) then
            return key, priority
        end
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

local AreaNameMap = {}

local function rebuildAreaNameMap()
    table.clear(AreaNameMap)

    if AreasData and type(AreasData.Directory) == "table" then
        for name, data in pairs(AreasData.Directory) do
            local display = type(data) == "table" and data.DisplayName or nil
            AreaNameMap[tostring(name)] = tostring(name)
            if display then
                AreaNameMap[tostring(display)] = tostring(name)
            end
        end
    end
end

rebuildAreaNameMap()

local function resolveAreaId(name)
    local raw = tostring(name or "Automatic")
    if raw == "Automatic" then
        return raw
    end

    if not AreaNameMap[raw] then
        rebuildAreaNameMap()
    end

    return AreaNameMap[raw] or raw
end

local function getArea()
    if Env.SAE_Area ~= "Automatic" then
        return resolveAreaId(Env.SAE_Area)
    end

    local speed = getSpeed()

    -- Prefer the actual area directory. Handles display names cleanly.
    if AreasData and type(AreasData.Directory) == "table" then
        local best = "Forest"
        local bestRequirement = 0

        for name, data in pairs(AreasData.Directory) do
            if type(data) == "table" then
                local requirement =
                    tonumber(data.Speed) or
                    tonumber(data.RequiredSpeed) or
                    tonumber(data.SpeedRequirement)

                if requirement and requirement <= speed and requirement >= bestRequirement then
                    best = tostring(name)
                    bestRequirement = requirement
                end
            end
        end

        return best
    end

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

local function modelRecord(instance, uid)
    if not instance then
        return nil
    end

    local data = {
        Uid = uid or instance.Name,
        State = "Slot",
    }

    -- Model-level metadata fallback for games/versions where EggState
    -- temporarily lags behind the visible egg.
    for _, key in ipairs({
        "AssetCategory",
        "AssetName",
        "DisplayName",
        "Rarity",
        "RarityName",
        "Tier",
        "EggRarity",
        "AreaId",
    }) do
        local value = instance:GetAttribute(key)
        if value ~= nil then
            data[key] = value
        end
    end

    for _, obj in ipairs(instance:GetDescendants()) do
        if obj:IsA("StringValue") then
            local n = normalize(obj.Name)
            if n == "rarity" or n == "rarityname" or n == "eggrarity" or n == "tier"
                or n == "assetcategory" or n == "displayname" then
                data[obj.Name] = obj.Value
            end
        elseif obj:IsA("TextLabel") or obj:IsA("TextButton") then
            local t = tostring(obj.Text or "")
            if t ~= "" then
                data.DisplayName = data.DisplayName or t
                data.AssetName = data.AssetName or t
            end
        end
    end

    return data
end

local function inArea(record, position, bounds)
    local chosen = getArea()

    if record.AreaId then
        return resolveAreaId(record.AreaId) == resolveAreaId(chosen)
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
-- CHARACTER
----------------------------------------------------------------

local function getHumanoid()
    local c = Player.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function getRoot()
    local c = Player.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

----------------------------------------------------------------
-- TARGET SELECTION
----------------------------------------------------------------

local function buildRecordMap(records)
    local byUid = {}

    for _, record in pairs(records) do
        if type(record) == "table" then
            local uid = record.Uid or record.UID or record.Id or record.ID
            if uid ~= nil then
                byUid[tostring(uid)] = record
            end
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

        if not record then
            local attrUid = instance:GetAttribute("Uid")
                or instance:GetAttribute("UID")

            if attrUid then
                uid = tostring(attrUid)
                record = byUid[uid]
            end
        end

        -- Visible-model fallback when the live record is momentarily unavailable.
        if not record then
            record = modelRecord(instance, uid)
        end

        local state = normalize(record and (record.State or record.Status or "Slot") or "")

        if record
            and position
            and (state == "slot" or state == "dropped" or state == "spawned")
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

    for moveAttempt = 1, CONFIG.MoveRetryCount + 1 do
        if not Env.SAE_AutoFarm then
            return false
        end

        local root = getRoot()
        if not root then
            return false
        end

        local humanoid = getHumanoid()
        local started = os.clock()
        local lastPosition = root.Position
        local lastProgress = os.clock()

        if humanoid and humanoid.Health > 0 then
            humanoid:MoveTo(position)
        end

        while Env.SAE_AutoFarm and os.clock() - started < CONFIG.MoveTimeout do
            root = getRoot()
            if not root then
                return false
            end

            local target = Vector3.new(
                position.X,
                groundedY(position.X, position.Z, position.Y),
                position.Z
            )

            local distance = (root.Position - target).Magnitude
            if distance <= CONFIG.ArriveDistance then
                root.CFrame = CFrame.new(target)
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
                return true
            end

            local progress = (root.Position - lastPosition).Magnitude
            if progress >= CONFIG.StuckDistance then
                lastPosition = root.Position
                lastProgress = os.clock()
            elseif os.clock() - lastProgress >= CONFIG.StuckTimeout then
                -- Reissue MoveTo before falling back to direct correction.
                if humanoid and humanoid.Health > 0 then
                    humanoid:MoveTo(target)
                end
                lastPosition = root.Position
                lastProgress = os.clock()
            end

            local dt = RunService.Heartbeat:Wait()
            if typeof(dt) ~= "number" or dt <= 0 then
                dt = 1 / 60
            end

            -- When ordinary movement stalls, use a smaller controlled step.
            local delta = target - root.Position
            local step = math.min(delta.Magnitude, CONFIG.MoveSpeed * 0.65 * dt)
            if step > 0 then
                local nextPosition = root.Position + delta.Unit * step
                nextPosition = Vector3.new(
                    nextPosition.X,
                    groundedY(nextPosition.X, nextPosition.Z, nextPosition.Y),
                    nextPosition.Z
                )

                local horizontal = Vector3.new(delta.X, 0, delta.Z)
                root.CFrame = horizontal.Magnitude > 0.05
                    and CFrame.lookAt(nextPosition, nextPosition + horizontal)
                    or CFrame.new(nextPosition)
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
            end
        end
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

local Carrying = false

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

    local uid = tostring(target.Record.Uid or target.Instance.Name)
    local slotKey = getSlotKey(target.Record)

    local function accepted(result)
        return result == true or (result ~= nil and result ~= false)
    end

    -- Preferred EggState API.
    if EggAPI.Carry then
        local success, result = pcall(function()
            return EggAPI.Carry(uid, slotKey)
        end)

        if success and accepted(result) then
            if waitForCarry(0.3) then
                return true
            end
        end

        if waitForCarry(0.12) then
            return true
        end
    end

    -- Remote fallback.
    if CarryRemote then
        if CarryRemote:IsA("RemoteFunction") then
            local success, result = pcall(function()
                return CarryRemote:InvokeServer(uid, slotKey)
            end)

            if success and accepted(result) then
                if waitForCarry(0.35) then
                    return true
                end
            end

            if waitForCarry(0.12) then
                return true
            end

            -- Legacy compatibility.
            success, result = pcall(function()
                return CarryRemote:InvokeServer({
                    Uid = uid
                })
            end)

            if success and accepted(result) then
                if waitForCarry(0.3) then
                    return true
                end
            end

            if waitForCarry(0.12) then
                return true
            end

        elseif CarryRemote:IsA("RemoteEvent") then
            local success = pcall(function()
                CarryRemote:FireServer(uid, slotKey)
            end)

            if success and waitForCarry(0.35) then
                return true
            end
        end
    end

    return Carrying
end
----------------------------------------------------------------
-- CARRY STATE
----------------------------------------------------------------

local SessionSteals = 0
local StatusText = "Idle"
local LastTarget = "None"

if EggAPI.CarryChanged and type(EggAPI.CarryChanged.Connect) == "function" then
    EggAPI.CarryChanged:Connect(function(state)
        if type(state) == "table" then
            Carrying = state.IsCarrying == true
        elseif type(state) == "boolean" then
            Carrying = state
        end
    end)
end

local function fallbackCarryState()
    return Carrying
end

----------------------------------------------------------------
-- FARM CYCLE
----------------------------------------------------------------

local LockedTarget

local function clearLockedTarget()
    LockedTarget = nil
end

local function getLockedTargetFresh()
    if not Env.SAE_TargetLock or not LockedTarget then
        return nil
    end

    local inst = LockedTarget.Instance
    if not inst or not inst.Parent then
        clearLockedTarget()
        return nil
    end

    local position = eggPosition(inst)
    if not position then
        clearLockedTarget()
        return nil
    end

    local root = getRoot()
    if root and (position - root.Position).Magnitude > CONFIG.TargetLockRadius then
        clearLockedTarget()
        return nil
    end

    local refreshed = getTarget()
    if refreshed and refreshed.Instance == inst and refreshed.Target == LockedTarget.Target then
        LockedTarget = refreshed
        return refreshed
    end

    return nil
end

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

    local target = getLockedTargetFresh()

    if not target then
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
    end

    if target and Env.SAE_TargetLock then
        LockedTarget = target
    end

    if not target then
        StatusText = "Waiting for Cosmic / Secret / Eternal / Divine"
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
        usedInstant = true
        StatusText = "Instant TP → " .. LastTarget

        root.CFrame = CFrame.new(target.Position + Vector3.new(0, 3, 0))
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        task.wait(0.15)
    else
        if not collectPath(target.Position) then
            StatusText = "Movement failed - retrying scan"
            return false
        end

        if not Env.SAE_AutoFarm then
            return false
        end
    end

    -- Re-scan several times. A rare egg can disappear/change while travelling.
    local finalTarget = target
    if Env.SAE_SmartScan then
        for _ = 1, CONFIG.RescanAfterMove do
            local fresh = getTarget()
            if fresh and fresh.Target == target.Target then
                local d = (fresh.Position - target.Position).Magnitude
                if d <= CONFIG.TargetLockRadius or fresh.Instance == target.Instance then
                    finalTarget = fresh
                    break
                end
            end
            task.wait(0.08)
        end
    end

    target = finalTarget
    if Env.SAE_TargetLock then
        LockedTarget = target
    end
    root = getRoot()

    if not root or not target.Instance or not target.Instance.Parent then
        clearLockedTarget()
        StatusText = "Target disappeared"
        if usedInstant then
            root = getRoot()
            if root then
                root.CFrame = savedCFrame
            end
        end
        return false
    end

    -- Make sure we're actually beside the final target after the refresh.
    local freshPosition = eggPosition(target.Instance)
    if freshPosition then
        if not usedInstant then
            moveToPosition(freshPosition)
        else
            root.CFrame = CFrame.new(freshPosition + Vector3.new(0, 3, 0))
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end
    end

    task.wait(CONFIG.GrabDelay)

    if not Env.SAE_AutoFarm then
        if usedInstant then
            root = getRoot()
            if root then root.CFrame = savedCFrame end
        end
        return false
    end

    StatusText = "Collecting " .. LastTarget

    local carried = false

    -- Two extra attempts handle replication delay without locking the farm.
    for attempt = 1, 3 do
        if not Env.SAE_AutoFarm or Carrying then
            break
        end

        carried = tryCarry(target)
        if carried or Carrying then
            break
        end

        task.wait(0.12 * attempt)

        local retryTarget = getTarget()
        if retryTarget and retryTarget.Target == target.Target then
            target = retryTarget
            local p = eggPosition(target.Instance)
            if p then
                if usedInstant then
                    root = getRoot()
                    if root then
                        root.CFrame = CFrame.new(p + Vector3.new(0, 3, 0))
                        root.AssemblyLinearVelocity = Vector3.zero
                    end
                else
                    moveToPosition(p)
                end
            end
        end
    end

    waitForCarry(0.4)

    if Carrying then
        SessionSteals += 1
        clearLockedTarget()
        StatusText = "Collected " .. LastTarget
    else
        if not (target and target.Instance and target.Instance.Parent) then
            clearLockedTarget()
        end
        StatusText = "Collect failed - rescanning"
    end

    task.wait(CONFIG.ReturnDelay)

    if usedInstant then
        root = getRoot()
        if root then
            root.CFrame = savedCFrame
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end
    else
        StatusText = "Returning"
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
    clearLockedTarget()

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
    local seen = { Automatic = true }

    if AreasData and type(AreasData.Directory) == "table" then
        for name, data in pairs(AreasData.Directory) do
            local display = tostring((type(data) == "table" and data.DisplayName) or name)
            if not seen[display] then
                table.insert(result, display)
                seen[display] = true
            end
        end
    else
        for name in pairs(AreaRequirements) do
            local display = tostring(name)
            if not seen[display] then
                table.insert(result, display)
                seen[display] = true
            end
        end
    end

    table.sort(result, function(a, b)
        if a == "Automatic" then return true end
        if b == "Automatic" then return false end
        return tostring(a) < tostring(b)
    end)

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
    name = "Target Lock",
    currentValue = true,
    flag = "SAE_TargetLock",
    callback = function(value)
        Env.SAE_TargetLock = value
        if not value then
            clearLockedTarget()
        end
    end,
})

Tab:CreateToggle({
    name = "Smart Scan",
    currentValue = true,
    flag = "SAE_SmartScan",
    callback = function(value)
        Env.SAE_SmartScan = value
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

Tab:CreateParagraph({
    title = "Target Mode",
    content = "Targets: Cosmic → Secret → Eternal → Divine. Target Lock + Smart Scan improve consistency.",
})

local StatusLabel = Tab:CreateParagraph({
    title = "Status",
    content = "Idle\nLast target: None\nSteals: 0",
})

Tab:CreateParagraph({
    title = "Detection",
    content = "Uses authoritative rarity data first, then safe metadata fallback. Smart Scan rechecks targets after movement.",
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

Tab:CreateButton({
    name = "Rescan Now",
    callback = function()
        clearLockedTarget()
        StatusText = "Manual rescan..."
        task.spawn(function()
            local target = getTarget()
            if target then
                LastTarget = string.upper(target.Target)
                StatusText = "Found " .. LastTarget
                if Env.SAE_TargetLock then
                    LockedTarget = target
                end
            else
                StatusText = "No Cosmic / Secret / Eternal / Divine found"
            end
        end)
    end,
})

-- Restart support after respawn.
Player.CharacterAdded:Connect(function()
    clearLockedTarget()
    task.wait(0.8)
    if Env.SAE_AutoFarm then
        startNoclip()
    end
end)

pcall(function()
    if EggFolder then
        EggFolder.ChildAdded:Connect(function()
            -- New eggs trigger the next fast scan automatically.
        end)
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
        Title = "Egg Farm+ v11",
        Content = "Cosmic → Secret → Eternal → Divine | Smart Scan enabled",
        Duration = 4,
    })
end)
