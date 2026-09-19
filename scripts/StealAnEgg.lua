--[[
  STEAL AN EGG v6.1 | Jayren Hub
  GUI: Rayfield (clean / modern)
  Farm: Walk default | Instant TP (Potato) optional
  CACHE_BUST: 2026-09-19-v61

  loadstring(game:HttpGet("https://raw.githubusercontent.com/barnesjayren0-sudo/Jayren-Sudo-Rivals-Hub/main/scripts/StealAnEgg.lua"))()
]]

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
	Name = "Steal an Egg  ·  Jayren",
	LoadingTitle = "Jayren Hub",
	LoadingSubtitle = "Steal an Egg v6.1",
	Theme = "Default",
	ToggleUIKeybind = "K",
	ConfigurationSaving = {
		Enabled = true,
		FolderName = "JayrenHub",
		FileName = "StealAnEgg",
	},
	Discord = { Enabled = false },
	KeySystem = false,
})

local FarmTab = Window:CreateTab("Farm", 4483362458)
local SettingsTab = Window:CreateTab("Settings", 6034507494)
local InfoTab = Window:CreateTab("Info", 6031280882)

local RunService = game:GetService("RunService")
local VU = game:GetService("VirtualUser")

getgenv().FarmEggs = false
getgenv().AutoPlace = false
getgenv().AutoFarm = false
getgenv().AutoHatch = false
getgenv().AutoEquip = false
getgenv().PriorityRarest = false
getgenv().AntiAFK = true
getgenv().StealRetries = true
getgenv().InstantSteal = false
getgenv().TpHold = 0.35
getgenv().ChosenArea = "Automatic"

local Player = game:GetService("Players").LocalPlayer
local SpeedVal = Player:WaitForChild("leaderstats"):WaitForChild("Speed")

local GuardAreas = workspace:WaitForChild("__OBJECTS"):WaitForChild("Areas"):WaitForChild("GuardAreas")
local SpawnedEggs = workspace:WaitForChild("AreaEggSlotsClient")

local AreasList = { "Automatic" }
for _, v in pairs(GuardAreas:GetChildren()) do
	table.insert(AreasList, v.Name)
end

local Net = game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Networking")
local StealEvent = Net:WaitForChild("RF/EggWorld/AskFieldEggCarry")
local PlaceEvent = Net:WaitForChild("RF/EggWorld/AskPlaceEgg")
local HatchEvent = Net:WaitForChild("RF/EggWorld/AskHatch")
local EquipEvent = Net:WaitForChild("RF/EggWorld/AskWearTool")
local CompleteHatchEvent = Net:WaitForChild("RF/EggWorld/AskFinishHatch")
local InventoryEvent = Net:WaitForChild("RE/EggWorld/OwnerShifted")

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

local AreaCoords = {
	["Forest"] = Vector3.new(595, 71, -325),
	["Lake"] = Vector3.new(740, 71, -413),
	["Desert"] = Vector3.new(949, 71, -320),
	["Jungle"] = Vector3.new(1184, 71, -413),
	["Snow"] = Vector3.new(1490, 71, -316),
	["Volcano"] = Vector3.new(1883, 71, -405),
	["Abyss Ocean"] = Vector3.new(2280, 71, -329),
	["Prehistoric"] = Vector3.new(2804, 71, -395),
	["Cosmic"] = Vector3.new(3390, 71, -326),
	["Cherry Blossom"] = Vector3.new(4027, 71, -398),
	["Titan Temple"] = Vector3.new(4801, 71, -331),
}

local Waypoints = {
	SafeArea = Vector3.new(542, 71, -363),
}

local RarityRank = {
	Secret = 100, Eternal = 90, Divine = 80, Cosmic = 70, Mythic = 60,
	Legendary = 50, Epic = 40, Rare = 30, Uncommon = 20, Common = 10,
}

local LastInventory
InventoryEvent.OnClientEvent:Connect(function(data)
	if data and data.OwnerUserId == Player.UserId then
		LastInventory = data.Records
	end
end)

local function findPlayerBase()
	for _, base in pairs(workspace.Plots:GetChildren()) do
		local ok, match = pcall(function()
			return base.PlotSign.PlayerPlotSign.Frame.PlayerIcon.Image:find(tostring(Player.UserId))
		end)
		if ok and match then
			return base
		end
	end
end

local function findPlacedEggs()
	for _, v in pairs(workspace:GetChildren()) do
		if v.Name == "PlacedEggRenders" then
			return v
		end
	end
end

local function GetBestArea()
	local currentSpeed = SpeedVal.Value
	local bestName, bestSpeed = nil, -1
	if ChosenArea == "Automatic" then
		for name, data in pairs(Areas) do
			if data.Speed <= currentSpeed and data.Speed > bestSpeed then
				bestName = name
				bestSpeed = data.Speed
			end
		end
	else
		bestName = ChosenArea
	end
	return bestName
end

local function getAreaPosition(areaName)
	local area = areaName and GuardAreas:FindFirstChild(areaName)
	if area and area:FindFirstChild("Bounds") then
		return area.Bounds.Position
	end
	if areaName and AreaCoords[areaName] then
		return AreaCoords[areaName]
	end
	return nil
end

local function walkTo(hum, pos)
	if not pos then return false end
	local hrp = hum.RootPart
	local tries = 0
	while tries < 40 do
		tries += 1
		hum:MoveTo(pos)
		local reached = hum.MoveToFinished:Wait()
		if reached then return true end
		if hrp and hrp.Parent then
			local flat = (Vector2.new(hrp.Position.X, hrp.Position.Z) - Vector2.new(pos.X, pos.Z)).Magnitude
			if flat <= 4 then return true end
		else
			return false
		end
	end
	return false
end

local function warpTo(hp, cf)
	if not hp or not cf then return end
	pcall(function()
		hp.AssemblyLinearVelocity = Vector3.zero
		hp.AssemblyAngularVelocity = Vector3.zero
		hp.CFrame = cf
	end)
end

local function isValidEggModel(v)
	return v:IsA("Model") and v.PrimaryPart ~= nil
end

local function eggScore(egg)
	local score = 0
	local n = string.lower(tostring(egg.Name))
	for rarity, rank in pairs(RarityRank) do
		if n:find(string.lower(rarity)) then
			score = rank
			break
		end
	end
	pcall(function()
		local r = egg:GetAttribute("Rarity") or egg:GetAttribute("rarity")
		if r and RarityRank[tostring(r)] then
			score = math.max(score, RarityRank[tostring(r)])
		end
	end)
	return score
end

local function pickEgg(char)
	local closestEgg, closestDist, bestScore = nil, nil, -1
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return nil end
	for _, v in pairs(SpawnedEggs:GetChildren()) do
		if isValidEggModel(v) then
			local dist = (v.PrimaryPart.Position - root.Position).Magnitude
			if PriorityRarest then
				local score = eggScore(v)
				if score > bestScore or (score == bestScore and (not closestDist or dist < closestDist)) then
					bestScore, closestDist, closestEgg = score, dist, v
				end
			elseif not closestDist or dist < closestDist then
				closestDist, closestEgg = dist, v
			end
		end
	end
	return closestEgg
end

local function pickEggNear(char, nearPos)
	if not nearPos then return pickEgg(char) end
	local closestEgg, closestDist, bestScore = nil, nil, -1
	for _, v in pairs(SpawnedEggs:GetChildren()) do
		if isValidEggModel(v) then
			local dist = (v.PrimaryPart.Position - nearPos).Magnitude
			if dist > 250 then continue end
			if PriorityRarest then
				local score = eggScore(v)
				if score > bestScore or (score == bestScore and (not closestDist or dist < closestDist)) then
					bestScore, closestDist, closestEgg = score, dist, v
				end
			elseif not closestDist or dist < closestDist then
				closestDist, closestEgg = dist, v
			end
		end
	end
	return closestEgg or pickEgg(char)
end

local function trySteal(uid)
	local maxTries = StealRetries and 8 or 1
	for i = 1, maxTries do
		local ok, res = pcall(function()
			return StealEvent:InvokeServer({ Uid = uid })
		end)
		if ok and (res == true or res == "Success") then return true end
		if ok and res == nil and i >= 2 then return true end
		if not StealRetries then return ok end
		task.wait(0.12)
	end
	pcall(function() StealEvent:InvokeServer({ Uid = uid }) end)
	return false
end

local function instantStealEgg(egg)
	local char = Player.Character
	if not char or not egg or not egg.PrimaryPart then return false end
	local hp = char:FindFirstChild("HumanoidRootPart")
	if not hp then return false end

	local saved = hp.CFrame
	local eggCf = egg.PrimaryPart.CFrame + Vector3.new(0, 3, 0)
	local hold = tonumber(TpHold) or 0.35
	local uid = egg.Name

	for attempt = 1, 3 do
		warpTo(hp, eggCf)
		task.wait(hold + (attempt - 1) * 0.2)
		if trySteal(uid) then
			warpTo(hp, saved)
			return true
		end
		task.wait(0.1)
	end
	warpTo(hp, saved)
	return false
end

Player.Idled:Connect(function()
	if not AntiAFK then return end
	pcall(function()
		VU:CaptureController()
		VU:ClickButton2(Vector2.new())
	end)
end)

local function farmCycle()
	local NoclipParts = {}
	local Noclipping

	local Character = Player.Character
	if not Character then return end
	local Humanoid = Character:FindFirstChildOfClass("Humanoid")
	if not Humanoid then return end
	local hrp = Character:FindFirstChild("HumanoidRootPart")

	Noclipping = RunService.Stepped:Connect(function()
		if AutoFarm and Player.Character then
			for _, child in pairs(Player.Character:GetDescendants()) do
				if child:IsA("BasePart") and child.CanCollide then
					child.CanCollide = false
					NoclipParts[child] = true
				end
			end
		end
	end)

	if FarmEggs then
		local bestAreaName = GetBestArea()
		local areaPos = getAreaPosition(bestAreaName)

		if InstantSteal then
			if areaPos and hrp then
				warpTo(hrp, CFrame.new(areaPos + Vector3.new(0, 3, 0)))
				task.wait(0.15)
			end
			local egg = pickEggNear(Character, areaPos)
			if egg then instantStealEgg(egg) end
			if hrp then
				warpTo(hrp, CFrame.new(Waypoints.SafeArea + Vector3.new(0, 3, 0)))
			end
		else
			Humanoid.HipHeight = 20
			task.wait(0.1)
			walkTo(Humanoid, Waypoints.SafeArea)
			Humanoid.HipHeight = 2
			task.wait(0.1)
			if areaPos then walkTo(Humanoid, areaPos) end
			local closestEgg = pickEgg(Character)
			if closestEgg and closestEgg.PrimaryPart then
				walkTo(Humanoid, closestEgg.PrimaryPart.Position)
				task.wait(0.5)
				walkTo(Humanoid, closestEgg.PrimaryPart.Position)
				task.wait()
				trySteal(closestEgg.Name)
			end
			walkTo(Humanoid, Waypoints.SafeArea)
		end
	end

	task.wait(0.5)

	local PlayerBase = findPlayerBase()
	if AutoPlace and LastInventory and PlayerBase and PlayerBase:FindFirstChild("CenterPoint") then
		if InstantSteal and hrp then
			warpTo(hrp, PlayerBase.CenterPoint.CFrame + Vector3.new(0, 2, 0))
			task.wait(0.2)
		else
			Humanoid.HipHeight = 20
			task.wait(0.1)
			walkTo(Humanoid, PlayerBase.CenterPoint.Position)
		end
		for i, _ in pairs(LastInventory) do
			PlaceEvent:InvokeServer({
				Uid = i,
				LocalCFrame = CFrame.new(
					math.random(-23, 23), -0.5001220703125, math.random(-29, 29),
					0, 0, 1, 0, 1, 0, -1, 0, 0
				),
			})
			task.wait()
		end
	end

	local PlacedEggs = findPlacedEggs()
	if AutoHatch and PlacedEggs then
		for _, v in pairs(PlacedEggs:GetChildren()) do
			local splitString = v.Name:split("_")
			if splitString[1] == tostring(Player.UserId) and v.PrimaryPart then
				if InstantSteal and hrp then
					warpTo(hrp, v.PrimaryPart.CFrame + Vector3.new(0, 2, 0))
					task.wait(0.15)
				else
					Humanoid.HipHeight = 20
					task.wait(0.1)
					walkTo(Humanoid, v.PrimaryPart.Position)
				end
				local res = HatchEvent:InvokeServer(splitString[2])
				if res then CompleteHatchEvent:InvokeServer(splitString[2]) end
				task.wait(0.1)
			end
		end
	end

	if AutoEquip then EquipEvent:InvokeServer() end

	if Noclipping then Noclipping:Disconnect() end
	for part in pairs(NoclipParts) do
		if part and part.Parent then part.CanCollide = true end
	end
end

-- ===== Rayfield UI =====

FarmTab:CreateSection("Main")

FarmTab:CreateToggle({
	Name = "Auto Farm",
	CurrentValue = false,
	Flag = "AutoFarm",
	Callback = function(Value)
		AutoFarm = Value
		if Value then
			Rayfield:Notify({ Title = "Farm", Content = "Auto Farm started", Duration = 3 })
			task.spawn(function()
				while AutoFarm do
					pcall(farmCycle)
					task.wait()
				end
			end)
		else
			Rayfield:Notify({ Title = "Farm", Content = "Auto Farm stopped", Duration = 3 })
		end
	end,
})

FarmTab:CreateToggle({
	Name = "Auto Collect Eggs",
	CurrentValue = false,
	Flag = "AutoCollect",
	Callback = function(Value)
		FarmEggs = Value
	end,
})

FarmTab:CreateToggle({
	Name = "Instant Steal (TP)",
	CurrentValue = false,
	Flag = "InstantSteal",
	Callback = function(Value)
		InstantSteal = Value
		Rayfield:Notify({
			Title = "Movement",
			Content = Value and "TP mode (hold + return)" or "Walk mode (safer)",
			Duration = 3,
		})
	end,
})

FarmTab:CreateDropdown({
	Name = "Target Area",
	Options = AreasList,
	CurrentOption = { "Automatic" },
	MultipleOptions = false,
	Flag = "Area",
	Callback = function(Option)
		if type(Option) == "table" then
			ChosenArea = Option[1] or "Automatic"
		else
			ChosenArea = Option or "Automatic"
		end
	end,
})

FarmTab:CreateSection("After Steal")

FarmTab:CreateToggle({
	Name = "Auto Place",
	CurrentValue = false,
	Flag = "AutoPlace",
	Callback = function(Value)
		AutoPlace = Value
	end,
})

FarmTab:CreateToggle({
	Name = "Auto Hatch",
	CurrentValue = false,
	Flag = "AutoHatch",
	Callback = function(Value)
		AutoHatch = Value
	end,
})

FarmTab:CreateToggle({
	Name = "Auto Equip Best",
	CurrentValue = false,
	Flag = "AutoEquip",
	Callback = function(Value)
		AutoEquip = Value
	end,
})

SettingsTab:CreateSection("Steal Options")

SettingsTab:CreateToggle({
	Name = "Priority Rarest Egg",
	CurrentValue = false,
	Flag = "PriorityRarest",
	Callback = function(Value)
		PriorityRarest = Value
	end,
})

SettingsTab:CreateToggle({
	Name = "Steal Retries",
	CurrentValue = true,
	Flag = "StealRetries",
	Callback = function(Value)
		StealRetries = Value
	end,
})

SettingsTab:CreateSlider({
	Name = "TP Hold (seconds)",
	Range = { 0.15, 1.0 },
	Increment = 0.05,
	Suffix = "s",
	CurrentValue = 0.35,
	Flag = "TpHold",
	Callback = function(Value)
		TpHold = Value
	end,
})

SettingsTab:CreateSection("Client")

SettingsTab:CreateToggle({
	Name = "Anti-AFK",
	CurrentValue = true,
	Flag = "AntiAFK",
	Callback = function(Value)
		AntiAFK = Value
	end,
})

SettingsTab:CreateToggle({
	Name = "Disable 3D Rendering",
	CurrentValue = false,
	Flag = "No3D",
	Callback = function(Value)
		RunService:Set3dRenderingEnabled(not Value)
	end,
})

SettingsTab:CreateButton({
	Name = "Destroy UI",
	Callback = function()
		AutoFarm = false
		Rayfield:Destroy()
	end,
})

InfoTab:CreateSection("About")
InfoTab:CreateParagraph({
	Title = "Steal an Egg v6.1",
	Content = "Walk = safer (default). Instant Steal = Potato TP (save → egg → hold → carry → return). Toggle UI with K.",
})
InfoTab:CreateParagraph({
	Title = "Credits",
	Content = "Walk core: Vaehz / Eze · Instant pattern: Potato · GUI: Rayfield · Hub: Jayren",
})

Rayfield:Notify({
	Title = "Jayren Hub",
	Content = "Steal an Egg v6.1 loaded · Press K to toggle UI",
	Duration = 6,
})
