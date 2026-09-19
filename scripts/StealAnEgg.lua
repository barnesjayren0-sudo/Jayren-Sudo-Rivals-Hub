--[[
  STEAL AN EGG v4 | Jayren Hub
  Core: who-is-eze / Vaehz walk + HipHeight (working path)
  Research upgrades from:
    - ValueHat: area coords, steal retries, egg UID filter
    - SyncHub: anti-AFK, rarity list
    - who-is-eze: original remotes + farm order

  loadstring(game:HttpGet("https://raw.githubusercontent.com/barnesjayren0-sudo/Jayren-Sudo-Rivals-Hub/main/scripts/StealAnEgg.lua"))()
]]

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/who-is-eze/stealanegg-fixed/refs/heads/main/vaehzlibCustom.lua"))()
local Window = Library:CreateWindow({ Title = "Steal an Egg v4", Accent = Color3.fromRGB(100, 160, 255) })

local FarmTab = Window:CreateTab({ Name = "Autofarms", Icon = "wheat" })
local CredTab = Window:CreateTab({ Name = "Credits", Icon = "circle-i" })

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

-- ValueHat-style area coords (fallback if Bounds missing)
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

-- ORIGINAL walk (who-is-eze) — do not replace with tween
local function walkTo(hum, pos)
	if not pos then return false end
	local hrp = hum.RootPart
	local tries = 0
	while tries < 40 do
		tries += 1
		hum:MoveTo(pos)
		local reached = hum.MoveToFinished:Wait()
		if reached then
			return true
		end
		if hrp and hrp.Parent then
			local flat = (Vector2.new(hrp.Position.X, hrp.Position.Z)
				- Vector2.new(pos.X, pos.Z)).Magnitude
			if flat <= 4 then
				return true
			end
		else
			return false
		end
	end
	return false
end

local function isValidEggModel(v)
	if not v:IsA("Model") then return false end
	if not v.PrimaryPart then return false end
	local n = v.Name
	-- ValueHat: real eggs use long / hex-like Uids
	if #n >= 10 or string.match(n, "%x%x%x%x%x+") then
		return true
	end
	return true -- keep loose; PrimaryPart already filters most junk
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
			local primaryPart = v.PrimaryPart
			local dist = (primaryPart.Position - root.Position).Magnitude
			if PriorityRarest then
				local score = eggScore(v)
				if score > bestScore or (score == bestScore and (not closestDist or dist < closestDist)) then
					bestScore = score
					closestDist = dist
					closestEgg = v
				end
			else
				if not closestDist or dist < closestDist then
					closestDist = dist
					closestEgg = v
				end
			end
		end
	end
	return closestEgg
end

-- ValueHat: retry steal remote a few times
local function trySteal(uid)
	local maxTries = StealRetries and 8 or 1
	for i = 1, maxTries do
		local ok, res = pcall(function()
			return StealEvent:InvokeServer({ Uid = uid })
		end)
		if ok and (res == true or res == "Success" or res == nil) then
			-- nil still common on success for some builds
			if res == true or res == "Success" then
				return true
			end
			-- if no explicit fail, treat first invoke as done when not retrying
			if not StealRetries then
				return true
			end
			if i >= 2 then
				return true
			end
		end
		task.wait(0.12)
	end
	-- still fire once more like original (don't block farm)
	pcall(function()
		StealEvent:InvokeServer({ Uid = uid })
	end)
	return false
end

Player.Idled:Connect(function()
	if not AntiAFK then return end
	pcall(function()
		VU:CaptureController()
		VU:ClickButton2(Vector2.new())
	end)
end)

FarmTab:CreateToggle({
	Name = "Auto Farm",
	Default = false,
	Callback = function(v)
		AutoFarm = v
		if AutoFarm then
			while AutoFarm do
				pcall(function()
					local NoclipParts = {}
					local Noclipping

					local Character = Player.Character
					if not Character then return end
					local Humanoid = Character:FindFirstChildOfClass("Humanoid")
					if not Humanoid then return end

					Noclipping = RunService.Stepped:Connect(function()
						if AutoFarm and Player.Character ~= nil then
							for _, child in pairs(Player.Character:GetDescendants()) do
								if child:IsA("BasePart") and child.CanCollide == true then
									child.CanCollide = false
									NoclipParts[child] = true
								end
							end
						end
					end)

					if FarmEggs then
						local bestAreaName = GetBestArea()
						local areaPos = getAreaPosition(bestAreaName)

						-- ORIGINAL hipheight + walk path
						Humanoid.HipHeight = 20
						task.wait(0.1)
						walkTo(Humanoid, Waypoints.SafeArea)
						Humanoid.HipHeight = 2
						task.wait(0.1)

						if areaPos then
							walkTo(Humanoid, areaPos)
						end

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

					task.wait(0.5)

					-- refresh plot each cycle (more reliable)
					local PlayerBase = findPlayerBase()
					if AutoPlace and LastInventory ~= nil and PlayerBase and PlayerBase:FindFirstChild("CenterPoint") then
						Humanoid.HipHeight = 20
						task.wait(0.1)
						walkTo(Humanoid, PlayerBase.CenterPoint.Position)

						for i, _ in pairs(LastInventory) do
							local randomArea = CFrame.new(
								math.random(-23, 23),
								-0.5001220703125,
								math.random(-29, 29),
								0, 0, 1, 0, 1, 0, -1, 0, 0
							)
							PlaceEvent:InvokeServer({
								Uid = i,
								LocalCFrame = randomArea,
							})
							task.wait()
						end
					end

					local PlacedEggs = findPlacedEggs()
					if AutoHatch and PlacedEggs then
						for _, v in pairs(PlacedEggs:GetChildren()) do
							local splitString = v.Name:split("_")
							if splitString[1] == tostring(Player.UserId) and v.PrimaryPart then
								Humanoid.HipHeight = 20
								task.wait(0.1)
								walkTo(Humanoid, v.PrimaryPart.Position)

								local res = HatchEvent:InvokeServer(splitString[2])
								if res then
									CompleteHatchEvent:InvokeServer(splitString[2])
								end
								task.wait(0.1)
							end
						end
					end

					if AutoEquip then
						EquipEvent:InvokeServer()
					end

					if Noclipping then
						Noclipping:Disconnect()
						Noclipping = nil
					end
					for part in pairs(NoclipParts) do
						if part and part.Parent then
							part.CanCollide = true
						end
					end
					NoclipParts = {}

					task.wait(1)
				end)
				task.wait()
			end
		end
	end,
})

FarmTab:CreateLabel("Settings")

FarmTab:CreateToggle({
	Name = "Auto Collect",
	Default = false,
	Callback = function(v)
		FarmEggs = v
	end,
})

FarmTab:CreateDropdown({
	Name = "Area",
	Options = AreasList,
	Multi = false,
	Callback = function(v)
		ChosenArea = v
	end,
})

FarmTab:CreateToggle({
	Name = "Auto Place",
	Default = false,
	Callback = function(v)
		AutoPlace = v
	end,
})

FarmTab:CreateToggle({
	Name = "Auto Hatch",
	Default = false,
	Callback = function(v)
		AutoHatch = v
	end,
})

FarmTab:CreateToggle({
	Name = "Auto Equip",
	Default = false,
	Callback = function(v)
		AutoEquip = v
	end,
})

FarmTab:CreateToggle({
	Name = "Priority Rarest Egg",
	Default = false,
	Callback = function(v)
		PriorityRarest = v
	end,
})

FarmTab:CreateToggle({
	Name = "Steal Retries",
	Default = true,
	Callback = function(v)
		StealRetries = v
	end,
})

FarmTab:CreateToggle({
	Name = "Anti-AFK",
	Default = true,
	Callback = function(v)
		AntiAFK = v
	end,
})

FarmTab:CreateToggle({
	Name = "Disable 3D Rendering",
	Default = false,
	Callback = function(v)
		RunService:Set3dRenderingEnabled(not v)
	end,
})

CredTab:CreateLabel("Script Credits")
CredTab:CreateLabel({
	Text = "Core: Vaehz / Eze fixed loop",
	Size = 18,
	Color = Color3.fromRGB(100, 160, 255),
})
CredTab:CreateLabel({
	Text = "Research: ValueHat coords+retry, SyncHub AFK",
	Size = 14,
	Color = Color3.fromRGB(200, 200, 210),
})
CredTab:CreateLabel({
	Text = "Jayren Hub v4",
	Size = 14,
	Color = Color3.fromRGB(180, 180, 190),
})

Library:Notify({
	Title = "Steal an Egg v4",
	Content = "Walk loop + steal retries + area coords",
	Duration = 5,
})
