--[[
  STEAL AN EGG v7 | Jayren Hub
  EggState + Assets rarity (Cosmic Secret > Eternal > Divine)
  Corridor move | Rayfield Gen2 | fixed startFarm

  loadstring(game:HttpGet("https://cdn.jsdelivr.net/gh/barnesjayren0-sudo/Jayren-Sudo-Rivals-Hub@main/scripts/StealAnEgg.lua"))()
]]

local ok, Rayfield = pcall(function()
	return loadstring(game:HttpGet("https://sirius.menu/gen2"))()
end)
if not ok or not Rayfield then
	Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Player = Players.LocalPlayer
local Env = (getgenv and getgenv()) or _G

if Env.__SAE_V7_SHUTDOWN then pcall(Env.__SAE_V7_SHUTDOWN) end
if not game:IsLoaded() then game.Loaded:Wait() end

Env.SAE_AutoFarm = false
Env.SAE_Area = "Automatic"
Env.SAE_CosmicSecret = true
Env.SAE_Eternal = true
Env.SAE_Divine = true
Env.SAE_Priority = "Rarest"
Env.SAE_InstantTP = false

local CONFIG = {
	SafeArea = Vector3.new(542, 71, -363),
	MoveSpeed = 300,
	ArriveDistance = 1.5,
	GrabDelay = 0.55,
	ScanAttempts = 25,
	ScanDelay = 0.08,
	LoopDelay = 0.35,
	Priority = { cosmicsecret = 3, eternal = 2, divine = 1 },
}

local AreaReq = {
	Forest = 0, Lake = 900, Desert = 10000, Jungle = 40000, Snow = 450000,
	Volcano = 700000, ["Abyss Ocean"] = 2500000, Prehistoric = 17000000,
	Cosmic = 700000000, ["Cherry Blossom"] = 2500000000, ["Titan Temple"] = 7000000000,
	["Light Dark"] = 20000000000,
}

local function requirePath(root, ...)
	local cur = root
	for _, name in ipairs({...}) do
		if not cur then return nil end
		cur = cur:FindFirstChild(name) or cur:WaitForChild(name, 3)
	end
	if cur and cur:IsA("ModuleScript") then
		local s, r = pcall(require, cur)
		return s and r or nil
	end
end

local function findModule(name)
	for _, o in ipairs(RS:GetDescendants()) do
		if o:IsA("ModuleScript") and o.Name == name then
			local s, r = pcall(require, o)
			if s then return r end
		end
	end
end

local function pickFn(mod, ...)
	if type(mod) ~= "table" then return nil end
	for i = 1, select("#", ...) do
		local f = mod[select(i, ...)]
		if type(f) == "function" then return f end
	end
end

local EggState = requirePath(RS, "Client", "EggState") or findModule("EggState")
local AssetsData = requirePath(RS, "Data", "Assets") or findModule("Assets")
local SlotIdentity = requirePath(RS, "Shared", "Util", "AreaEggSlotIdentity") or findModule("AreaEggSlotIdentity")

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

local function findRemote(name)
	local net = RS:FindFirstChild("Packages") and RS.Packages:FindFirstChild("Networking")
	if net and net:FindFirstChild(name) then return net[name] end
	for _, o in ipairs(RS:GetDescendants()) do
		if (o:IsA("RemoteFunction") or o:IsA("RemoteEvent")) and o.Name == name then return o end
	end
end

local CarryRemote = findRemote("RF/EggWorld/AskFieldEggCarry")
local SnapshotRemote = findRemote("RF/EggWorld/AskFieldEggSnapshot")

local Carrying, SessionSteals, StatusText, LastTarget = false, 0, "Idle", "None"

if EggAPI.CarryChanged and type(EggAPI.CarryChanged.Connect) == "function" then
	EggAPI.CarryChanged:Connect(function(state)
		if type(state) == "table" then Carrying = state.IsCarrying == true end
	end)
end

local function unwrapSnapshot(v)
	if type(v) ~= "table" then return {} end
	return type(v.Records) == "table" and v.Records or v
end

local function requestSnapshot()
	if EggAPI.GetSnapshot then
		local s, snap = pcall(EggAPI.GetSnapshot)
		if s and type(snap) == "table" then
			local r = unwrapSnapshot(snap)
			if next(r) then return r end
		end
	end
	if EggAPI.RequestSnapshot then
		pcall(EggAPI.RequestSnapshot)
		task.wait(0.05)
		if EggAPI.GetSnapshot then
			local s, snap = pcall(EggAPI.GetSnapshot)
			if s and type(snap) == "table" then
				local r = unwrapSnapshot(snap)
				if next(r) then return r end
			end
		end
	end
	if SnapshotRemote and SnapshotRemote:IsA("RemoteFunction") then
		local s, snap = pcall(function() return SnapshotRemote:InvokeServer() end)
		if s and type(snap) == "table" then return unwrapSnapshot(snap) end
	end
	return {}
end

local function normalize(v)
	return tostring(v or ""):lower():gsub("[%s_%-]", "")
end

local function rarityFromCategory(cat)
	local dir = AssetsData and AssetsData.Directory
	if type(dir) ~= "table" or type(cat) ~= "string" then return nil end
	local e = dir[cat]
	if type(e) ~= "table" then return nil end
	local r = e.Rarity
	if type(r) == "table" then return r._id or r.DisplayName or r.Id end
	if r ~= nil then return tostring(r) end
end

local function recordIsTarget(record)
	if type(record) ~= "table" then return nil, 0 end
	local rarity = normalize(rarityFromCategory(record.AssetCategory) or record.Rarity or record.RarityName or "")
	local text = normalize(table.concat({
		tostring(record.AssetCategory or ""), tostring(record.DisplayName or ""),
		tostring(record.Rarity or ""), tostring(record.RarityName or ""),
	}, " "))
	local cat = normalize(record.AssetCategory)
	if Env.SAE_CosmicSecret and (
		rarity == "cosmicsecret" or (rarity:find("cosmic",1,true) and rarity:find("secret",1,true))
		or (text:find("cosmic",1,true) and text:find("secret",1,true))
		or (cat:find("cosmic",1,true) and cat:find("secret",1,true))
	) then return "cosmicsecret", 3 end
	if Env.SAE_Eternal and (rarity:find("eternal",1,true) or text:find("eternal",1,true) or cat:find("eternal",1,true)) then
		return "eternal", 2
	end
	if Env.SAE_Divine and (rarity:find("divine",1,true) or text:find("divine",1,true) or cat:find("divine",1,true)) then
		return "divine", 1
	end
	return nil, 0
end

local function getSpeed()
	local st = Player:FindFirstChild("leaderstats")
	local sp = st and st:FindFirstChild("Speed")
	return sp and tonumber(sp.Value) or 0
end

local function getArea()
	if Env.SAE_Area ~= "Automatic" then return Env.SAE_Area end
	local speed, best, bestR = getSpeed(), "Forest", 0
	for name, req in pairs(AreaReq) do
		if req <= speed and req >= bestR then best, bestR = name, req end
	end
	return best
end

local function getRoot()
	local c = Player.Character
	return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
	local c = Player.Character
	return c and c:FindFirstChildOfClass("Humanoid")
end

local function eggPos(inst)
	if not inst then return nil end
	if inst:IsA("BasePart") then return inst.Position end
	if inst:IsA("Model") then
		if inst.PrimaryPart then return inst.PrimaryPart.Position end
		local p = inst:FindFirstChildWhichIsA("BasePart", true)
		return p and p.Position
	end
end

local function getTarget()
	local folder = Workspace:FindFirstChild("AreaEggSlotsClient")
	if not folder then return nil end
	local records = requestSnapshot()
	local byUid = {}
	for _, rec in pairs(records) do
		if type(rec) == "table" and type(rec.Uid) == "string" then byUid[rec.Uid] = rec end
	end
	local root = getRoot()
	if not root then return nil end
	local best, bestP, bestD = nil, -1e9, 1e9
	for _, inst in ipairs(folder:GetChildren()) do
		local uid = inst.Name
		local rec = byUid[uid]
		local pos = eggPos(inst)
		if rec and pos then
			local tgt, pri = recordIsTarget(rec)
			if tgt then
				local d = (pos - root.Position).Magnitude
				if Env.SAE_Priority == "Nearest" then pri = 0 end
				if pri > bestP or (pri == bestP and d < bestD) then
					best = { Instance = inst, Record = rec, Position = pos, Target = tgt }
					bestP, bestD = pri, d
				end
			end
		end
	end
	return best
end

local function warpTo(cf)
	local hp = getRoot()
	if not hp or not cf then return end
	pcall(function()
		hp.AssemblyLinearVelocity = Vector3.zero
		hp.AssemblyAngularVelocity = Vector3.zero
		hp.CFrame = typeof(cf) == "CFrame" and cf or CFrame.new(cf)
	end)
end

local function moveTo(pos)
	local root = getRoot()
	if not root or typeof(pos) ~= "Vector3" then return false end
	if Env.SAE_InstantTP then
		warpTo(CFrame.new(pos + Vector3.new(0, 3, 0)))
		task.wait(0.2)
		return true
	end
	local hum = getHumanoid()
	if hum then
		hum:MoveTo(pos)
		local t0 = os.clock()
		while Env.SAE_AutoFarm and os.clock() - t0 < 8 do
			root = getRoot()
			if not root then return false end
			if (root.Position - pos).Magnitude <= CONFIG.ArriveDistance + 2 then return true end
			task.wait(0.05)
		end
	end
	local t0 = os.clock()
	while Env.SAE_AutoFarm and os.clock() - t0 < 12 do
		root = getRoot()
		if not root then return false end
		local delta = pos - root.Position
		if delta.Magnitude <= CONFIG.ArriveDistance then
			warpTo(CFrame.new(pos))
			return true
		end
		local dt = RunService.Heartbeat:Wait()
		if type(dt) ~= "number" or dt <= 0 then dt = 1/60 end
		local step = math.min(delta.Magnitude, CONFIG.MoveSpeed * dt)
		local nextP = root.Position + delta.Unit * step
		warpTo(CFrame.new(nextP))
	end
	return false
end

local function getSlotKey(record)
	if not record or not SlotAPI.IsFirstAreaUid or not SlotAPI.BuildSlotKey then return nil end
	local ok, first = pcall(SlotAPI.IsFirstAreaUid, record.Uid)
	if ok and first then
		local s, key = pcall(SlotAPI.BuildSlotKey, record.AreaId, record.NestId)
		if s then return key end
	end
end

local function tryCarry(target)
	if not target or not target.Record then return false end
	local uid, slotKey = target.Record.Uid, getSlotKey(target.Record)
	if EggAPI.Carry then
		local s = pcall(function() return EggAPI.Carry(uid, slotKey) end)
		if s and Carrying then return true end
		task.wait(0.15)
		if Carrying then return true end
	end
	if CarryRemote and CarryRemote:IsA("RemoteFunction") then
		pcall(function() return CarryRemote:InvokeServer(uid, slotKey) end)
		task.wait(0.12)
		if Carrying then return true end
		pcall(function() return CarryRemote:InvokeServer({ Uid = uid }) end)
		task.wait(0.12)
	end
	return Carrying
end

local NoclipConn, CollState = nil, {}

local function startNoclip()
	if NoclipConn then return end
	NoclipConn = RunService.Stepped:Connect(function()
		if not Env.SAE_AutoFarm or not Player.Character then return end
		for _, p in ipairs(Player.Character:GetDescendants()) do
			if p:IsA("BasePart") and p.CanCollide then
				CollState[p] = true
				p.CanCollide = false
			end
		end
	end)
end

local function stopNoclip()
	if NoclipConn then NoclipConn:Disconnect() NoclipConn = nil end
	for p in pairs(CollState) do
		if p and p.Parent then p.CanCollide = true end
	end
	table.clear(CollState)
end

local function farmOnce()
	if Carrying then StatusText = "Already carrying" return false end
	StatusText = "Scanning..."
	local target
	for _ = 1, CONFIG.ScanAttempts do
		if not Env.SAE_AutoFarm then return false end
		target = getTarget()
		if target then break end
		task.wait(CONFIG.ScanDelay)
	end
	if not target then StatusText = "Waiting for rare egg" return false end
	LastTarget = string.upper(target.Target)
	StatusText = "Going to " .. LastTarget
	moveTo(CONFIG.SafeArea)
	if not moveTo(target.Position) then StatusText = "Move failed" return false end
	task.wait(CONFIG.GrabDelay)
	StatusText = "Collecting " .. LastTarget
	tryCarry(target)
	task.wait(0.2)
	if Carrying then SessionSteals += 1 end
	StatusText = Carrying and ("Got " .. LastTarget) or "Collect failed"
	moveTo(CONFIG.SafeArea)
	return Carrying
end

local Running, Generation, Destroyed = false, 0, false

local function stopFarm()
	Env.SAE_AutoFarm = false
	Generation += 1
	Running = false
	stopNoclip()
end

local function startFarm()
	if Running then return end
	Running = true
	Env.SAE_AutoFarm = true
	Generation += 1
	local gen = Generation
	startNoclip()
	task.spawn(function()
		while not Destroyed and Running and Env.SAE_AutoFarm and Generation == gen do
			local ok, err = xpcall(farmOnce, debug.traceback)
			if not ok then
				warn("[SAE v7] " .. tostring(err))
				StatusText = "Recovered"
				task.wait(0.8)
			else
				task.wait(CONFIG.LoopDelay)
			end
		end
		if Generation == gen then Running = false stopNoclip() StatusText = "Stopped" end
	end)
end

local function shutdown()
	if Destroyed then return end
	Destroyed = true
	stopFarm()
	Env.__SAE_V7_SHUTDOWN = nil
	pcall(function() Rayfield:Destroy() end)
end
Env.__SAE_V7_SHUTDOWN = shutdown

local Window
if Rayfield.CreateWindow then
	local okW, w = pcall(function()
		return Rayfield:CreateWindow({
			name = "Egg Farm+  ·  Jayren",
			subtitle = "v7 EggState Rares",
			Name = "Egg Farm+  ·  Jayren",
			LoadingTitle = "Jayren Hub",
			LoadingSubtitle = "Steal an Egg v7",
			Theme = "Default",
			ToggleUIKeybind = "K",
			ConfigurationSaving = { Enabled = false },
			KeySystem = false,
		})
	end)
	Window = okW and w or Rayfield:CreateWindow({ Name = "Egg Farm+ · Jayren", LoadingTitle = "Jayren", LoadingSubtitle = "v7", Theme = "Default", KeySystem = false })
end

local Tab
if Window.CreateTab then
	local okT, t = pcall(function()
		return Window:CreateTab({ name = "Egg Farm", icon = "egg" })
	end)
	Tab = okT and t or Window:CreateTab("Farm", 4483362458)
end

local function addToggle(name, flag, def, cb)
	local args = { Name = name, name = name, CurrentValue = def, currentValue = def, Flag = flag, flag = flag, Callback = cb, callback = cb }
	pcall(function() Tab:CreateToggle(args) end)
end

local function addDropdown(name, opts, cur, cb)
	pcall(function()
		Tab:CreateDropdown({
			Name = name, name = name, Options = opts, options = opts,
			CurrentOption = { cur }, currentOption = { cur },
			Callback = cb, callback = cb,
		})
	end)
end

pcall(function() Tab:CreateSection("Main") end)
addToggle("Auto Farm Eggs", "SAE_AutoFarm", false, function(v)
	if v then StatusText = "Starting..." startFarm()
	else stopFarm() StatusText = "Stopped" end
end)
addToggle("Instant TP", "SAE_InstantTP", false, function(v) Env.SAE_InstantTP = v end)

local areas = { "Automatic" }
for n in pairs(AreaReq) do table.insert(areas, n) end
table.sort(areas)
addDropdown("Farm Area", areas, "Automatic", function(v)
	Env.SAE_Area = type(v) == "table" and (v[1] or "Automatic") or (v or "Automatic")
end)
addDropdown("Priority", { "Rarest", "Nearest" }, "Rarest", function(v)
	Env.SAE_Priority = type(v) == "table" and (v[1] or "Rarest") or (v or "Rarest")
end)

pcall(function() Tab:CreateSection("Rare Targets") end)
addToggle("Cosmic Secret", "SAE_CosmicSecret", true, function(v) Env.SAE_CosmicSecret = v end)
addToggle("Eternal", "SAE_Eternal", true, function(v) Env.SAE_Eternal = v end)
addToggle("Divine", "SAE_Divine", true, function(v) Env.SAE_Divine = v end)

pcall(function()
	Tab:CreateButton({ Name = "Stop Farm", name = "Stop Farm", Callback = stopFarm, callback = stopFarm })
end)

local StatusLabel
pcall(function()
	StatusLabel = Tab:CreateParagraph({
		Title = "Status", title = "Status",
		Content = "Idle", content = "Idle",
	end)
end)

task.spawn(function()
	while not Destroyed do
		task.wait(0.3)
		pcall(function()
			if StatusLabel and StatusLabel.Set then
				StatusLabel:Set({
					"Status: " .. tostring(StatusText),
					"Last: " .. tostring(LastTarget),
					"Steals: " .. tostring(SessionSteals),
				})
			end
		end)
	end
end)

pcall(function()
	Rayfield:Notify({ Title = "Jayren v7", Content = "EggState rare farm loaded", Duration = 5 })
end)
