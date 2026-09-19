--[[
  STEAL AN EGG v2 | Jayren Hub
  Base: who-is-eze / Vaehz fixed remotes
  Upgrades: rarity priority, tween move, anti-AFK, self GUI, safer loop

  loadstring(game:HttpGet("https://raw.githubusercontent.com/barnesjayren0-sudo/Jayren-Sudo-Rivals-Hub/main/scripts/StealAnEgg.lua"))()
]]

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VU = game:GetService("VirtualUser")
local SG = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local LP = Players.LocalPlayer

local CFG = {
	autoFarm = false,
	autoCollect = true,
	autoPlace = true,
	autoHatch = true,
	autoEquip = true,
	antiAFK = true,
	useTween = true,
	priorityRarest = true,
	chosenArea = "Automatic",
	tweenSpeed = 80,
}

local function note(t, m)
	pcall(function()
		SG:SetCore("SendNotification", { Title = t, Text = m, Duration = 3 })
	end)
end

-- Remotes (from fixed stealanegg)
local Net = game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Networking")
local StealEvent = Net:WaitForChild("RF/EggWorld/AskFieldEggCarry")
local PlaceEvent = Net:WaitForChild("RF/EggWorld/AskPlaceEgg")
local HatchEvent = Net:WaitForChild("RF/EggWorld/AskHatch")
local EquipEvent = Net:WaitForChild("RF/EggWorld/AskWearTool")
local CompleteHatchEvent = Net:WaitForChild("RF/EggWorld/AskFinishHatch")
local InventoryEvent = Net:WaitForChild("RE/EggWorld/OwnerShifted")

local SpeedVal = LP:WaitForChild("leaderstats"):WaitForChild("Speed")

local function getPlayerBase()
	for _, base in pairs(workspace:WaitForChild("Plots"):GetChildren()) do
		local ok, match = pcall(function()
			return base.PlotSign.PlayerPlotSign.Frame.PlayerIcon.Image:find(tostring(LP.UserId))
		end)
		if ok and match then
			return base
		end
	end
end

local PlayerBase = getPlayerBase()
local GuardAreas = workspace:WaitForChild("__OBJECTS"):WaitForChild("Areas"):WaitForChild("GuardAreas")
local SpawnedEggs = workspace:WaitForChild("AreaEggSlotsClient")

local PlacedEggs
for _, v in pairs(workspace:GetChildren()) do
	if v.Name == "PlacedEggRenders" then
		PlacedEggs = v
		break
	end
end

local Areas = {
	["Forest"] = { Speed = 0 },
	["Lake"] = { Speed = 900 },
	["Desert"] = { Speed = 10000 },
	["Jungle"] = { Speed = 40000 },
	["Snow"] = { Speed = 450000 },
	["Volcano"] = { Speed = 700000 },
	["Abyss Ocean"] = { Speed = 2500000 },
	["Prehistoric"] = { Speed = 17000000 },
	["Cosmic"] = { Speed = 700000000 },
	["Cherry Blossom"] = { Speed = 2500000000 },
	["Titan Temple"] = { Speed = 7000000000 },
	["Light Dark"] = { Speed = 20000000000 },
}

local RarityRank = {
	Secret = 100,
	Eternal = 90,
	Divine = 80,
	Cosmic = 70,
	Mythic = 60,
	Legendary = 50,
	Epic = 40,
	Rare = 30,
	Uncommon = 20,
	Common = 10,
}

local Waypoints = {
	SafeArea = Vector3.new(542, 71, -363),
}

local LastInventory
InventoryEvent.OnClientEvent:Connect(function(data)
	if data and data.OwnerUserId == LP.UserId then
		LastInventory = data.Records
	end
end)

local function getBestArea()
	local currentSpeed = SpeedVal.Value
	if CFG.chosenArea ~= "Automatic" then
		return CFG.chosenArea
	end
	local bestName, bestSpeed = nil, -1
	for name, data in pairs(Areas) do
		if data.Speed <= currentSpeed and data.Speed > bestSpeed then
			bestName = name
			bestSpeed = data.Speed
		end
	end
	return bestName or "Forest"
end

local function eggScore(egg)
	local score = 0
	local name = string.lower(egg.Name or "")
	for rarity, rank in pairs(RarityRank) do
		if name:find(string.lower(rarity)) then
			score = rank
			break
		end
	end
	-- attribute fallback
	pcall(function()
		local r = egg:GetAttribute("Rarity") or egg:GetAttribute("rarity")
		if r and RarityRank[tostring(r)] then
			score = math.max(score, RarityRank[tostring(r)])
		end
	end)
	return score
end

local function pickEgg(fromPos)
	local best, bestScore, bestDist = nil, -1, math.huge
	for _, v in pairs(SpawnedEggs:GetChildren()) do
		local pp = v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")
		if pp then
			local dist = (pp.Position - fromPos).Magnitude
			local score = eggScore(v)
			if CFG.priorityRarest then
				if score > bestScore or (score == bestScore and dist < bestDist) then
					bestScore = score
					bestDist = dist
					best = v
				end
			else
				if dist < bestDist then
					bestDist = dist
					best = v
				end
			end
		end
	end
	return best
end

local function moveTo(pos)
	local char = LP.Character
	if not char then return false end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hum or not hrp then return false end

	if CFG.useTween then
		local dist = (hrp.Position - pos).Magnitude
		local t = math.clamp(dist / math.max(CFG.tweenSpeed, 20), 0.15, 6)
		local tw = TweenService:Create(
			hrp,
			TweenInfo.new(t, Enum.EasingStyle.Linear),
			{ CFrame = CFrame.new(pos + Vector3.new(0, 3, 0)) }
		)
		tw:Play()
		tw.Completed:Wait()
		return true
	end

	-- walk fallback
	local deadline = tick() + 12
	while tick() < deadline do
		hum:MoveTo(pos)
		local done = hum.MoveToFinished:Wait()
		if done then return true end
		local flat = (Vector2.new(hrp.Position.X, hrp.Position.Z) - Vector2.new(pos.X, pos.Z)).Magnitude
		if flat <= 5 then return true end
	end
	return false
end

local noclipConn
local function setNoclip(on)
	if noclipConn then
		noclipConn:Disconnect()
		noclipConn = nil
	end
	if not on then return end
	noclipConn = RS.Stepped:Connect(function()
		local c = LP.Character
		if not c then return end
		for _, p in ipairs(c:GetDescendants()) do
			if p:IsA("BasePart") then
				p.CanCollide = false
			end
		end
	end)
end

LP.Idled:Connect(function()
	if not CFG.antiAFK then return end
	pcall(function()
		VU:CaptureController()
		VU:ClickButton2(Vector2.new())
	end)
end)

local function farmOnce()
	local char = LP.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hum or not hrp then return end

	setNoclip(true)

	if CFG.autoCollect then
		local areaName = getBestArea()
		local area = GuardAreas:FindFirstChild(areaName)
		moveTo(Waypoints.SafeArea)
		if area and area:FindFirstChild("Bounds") then
			moveTo(area.Bounds.Position)
		end

		local egg = pickEgg(hrp.Position)
		if egg then
			local pp = egg.PrimaryPart or egg:FindFirstChildWhichIsA("BasePart")
			if pp then
				moveTo(pp.Position)
				task.wait(0.25)
				pcall(function()
					StealEvent:InvokeServer({ Uid = egg.Name })
				end)
				note("Steal", egg.Name)
			end
		end
		moveTo(Waypoints.SafeArea)
	end

	if CFG.autoPlace and LastInventory and PlayerBase and PlayerBase:FindFirstChild("CenterPoint") then
		moveTo(PlayerBase.CenterPoint.Position)
		for uid, _ in pairs(LastInventory) do
			pcall(function()
				PlaceEvent:InvokeServer({
					Uid = uid,
					LocalCFrame = CFrame.new(
						math.random(-20, 20),
						-0.5,
						math.random(-25, 25)
					),
				})
			end)
			task.wait(0.05)
		end
	end

	if CFG.autoHatch and PlacedEggs then
		for _, v in pairs(PlacedEggs:GetChildren()) do
			local parts = string.split(v.Name, "_")
			if parts[1] == tostring(LP.UserId) and v.PrimaryPart then
				moveTo(v.PrimaryPart.Position)
				local ok, res = pcall(function()
					return HatchEvent:InvokeServer(parts[2])
				end)
				if ok and res then
					pcall(function()
						CompleteHatchEvent:InvokeServer(parts[2])
					end)
				end
				task.wait(0.1)
			end
		end
	end

	if CFG.autoEquip then
		pcall(function()
			EquipEvent:InvokeServer()
		end)
	end

	setNoclip(false)
end

task.spawn(function()
	while true do
		if CFG.autoFarm then
			pcall(farmOnce)
		end
		task.wait(0.35)
	end
end)

-- ===== Simple dark GUI =====
local Gui = Instance.new("ScreenGui")
Gui.Name = "JayStealEgg"
Gui.ResetOnSpawn = false
pcall(function()
	Gui.Parent = game:GetService("CoreGui")
end)
if not Gui.Parent then
	Gui.Parent = LP:WaitForChild("PlayerGui")
end

local Main = Instance.new("Frame", Gui)
Main.Size = UDim2.new(0, 280, 0, 360)
Main.Position = UDim2.new(0.5, -140, 0.5, -180)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, -40, 0, 36)
Title.Position = UDim2.new(0, 12, 0, 4)
Title.BackgroundTransparency = 1
Title.Text = "Steal an Egg v2"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextColor3 = Color3.fromRGB(100, 180, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left

local Close = Instance.new("TextButton", Main)
Close.Size = UDim2.new(0, 28, 0, 28)
Close.Position = UDim2.new(1, -34, 0, 6)
Close.BackgroundColor3 = Color3.fromRGB(50, 30, 35)
Close.Text = "X"
Close.TextColor3 = Color3.fromRGB(255, 120, 140)
Close.Font = Enum.Font.GothamBold
Close.TextSize = 14
Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 8)
Close.MouseButton1Click:Connect(function()
	CFG.autoFarm = false
	Gui:Destroy()
end)

local list = Instance.new("ScrollingFrame", Main)
list.Size = UDim2.new(1, -20, 1, -50)
list.Position = UDim2.new(0, 10, 0, 42)
list.BackgroundTransparency = 1
list.ScrollBarThickness = 4
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.CanvasSize = UDim2.new()
Instance.new("UIListLayout", list).Padding = UDim.new(0, 6)

local function addToggle(name, key, default)
	CFG[key] = default
	local row = Instance.new("Frame", list)
	row.Size = UDim2.new(1, 0, 0, 32)
	row.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
	Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
	local lab = Instance.new("TextLabel", row)
	lab.Size = UDim2.new(1, -60, 1, 0)
	lab.Position = UDim2.new(0, 10, 0, 0)
	lab.BackgroundTransparency = 1
	lab.Text = name
	lab.Font = Enum.Font.Gotham
	lab.TextSize = 13
	lab.TextColor3 = Color3.fromRGB(230, 230, 240)
	lab.TextXAlignment = Enum.TextXAlignment.Left
	local btn = Instance.new("TextButton", row)
	btn.Size = UDim2.new(0, 48, 0, 22)
	btn.Position = UDim2.new(1, -54, 0.5, -11)
	btn.BackgroundColor3 = default and Color3.fromRGB(60, 140, 80) or Color3.fromRGB(55, 55, 70)
	btn.Text = default and "ON" or "OFF"
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 11
	btn.TextColor3 = Color3.new(1, 1, 1)
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	btn.MouseButton1Click:Connect(function()
		CFG[key] = not CFG[key]
		btn.Text = CFG[key] and "ON" or "OFF"
		btn.BackgroundColor3 = CFG[key] and Color3.fromRGB(60, 140, 80) or Color3.fromRGB(55, 55, 70)
		if key == "autoFarm" then
			note("Farm", CFG.autoFarm and "STARTED" or "STOPPED")
		end
	end)
end

addToggle("Auto Farm (master)", "autoFarm", false)
addToggle("Auto Collect Eggs", "autoCollect", true)
addToggle("Priority Rarest", "priorityRarest", true)
addToggle("Tween Move", "useTween", true)
addToggle("Auto Place", "autoPlace", true)
addToggle("Auto Hatch", "autoHatch", true)
addToggle("Auto Equip", "autoEquip", true)
addToggle("Anti-AFK", "antiAFK", true)

-- Area dropdown as cycle button
do
	local areas = { "Automatic" }
	for _, a in pairs(GuardAreas:GetChildren()) do
		table.insert(areas, a.Name)
	end
	local idx = 1
	local row = Instance.new("TextButton", list)
	row.Size = UDim2.new(1, 0, 0, 32)
	row.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
	row.Text = "Area: Automatic"
	row.Font = Enum.Font.Gotham
	row.TextSize = 13
	row.TextColor3 = Color3.fromRGB(200, 220, 255)
	Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
	row.MouseButton1Click:Connect(function()
		idx = idx % #areas + 1
		CFG.chosenArea = areas[idx]
		row.Text = "Area: " .. areas[idx]
	end)
end

note("Steal an Egg v2", "GUI loaded — turn Auto Farm ON")
