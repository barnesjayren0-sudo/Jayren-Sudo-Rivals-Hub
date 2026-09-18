--[[
================================================================
  DELTA EXECUTOR — UNIVERSAL TROLL SCRIPT (KEYLESS)
================================================================
  HOW TO USE:
  1. Join any Roblox game
  2. Open Delta Executor
  3. Paste this entire script or use the loadstring
  4. Press Execute
  5. GUI appears (draggable). Tabs: Troll / Movement / Players / Misc
  6. Press DESTROY GUI in Misc to unload

  Mobile + PC friendly. Client-side only.
================================================================
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()

local State = {
    Flying = false,
    Noclip = false,
    InfJump = false,
    Invisible = false,
    Speed = 16,
    JumpPower = 50,
    Selected = nil,
    Flinging = false,
    MassFling = false,
    ChatSpam = false,
    DanceSpam = false,
    AntiFling = false,
}

local Connections = {}
local function bind(c) table.insert(Connections, c) return c end

local function getChar()
    return LP.Character or LP.CharacterAdded:Wait()
end

local function getHRP(char)
    char = char or getChar()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHum(char)
    char = char or getChar()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 3
        })
    end)
end

-- GUI
local Gui = Instance.new("ScreenGui")
Gui.Name = "DeltaTrollGUI"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() Gui.Parent = game:GetService("CoreGui") end)
if not Gui.Parent then Gui.Parent = LP:WaitForChild("PlayerGui") end

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 420, 0, 460)
Main.Position = UDim2.new(0.5, -210, 0.5, -230)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = Gui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(0, 220, 255)
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.35
MainStroke.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 0, 40)
Title.Position = UDim2.new(0, 14, 0, 6)
Title.BackgroundTransparency = 1
Title.Text = "DELTA TROLL  ·  KEYLESS"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextColor3 = Color3.fromRGB(0, 230, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -40, 0, 8)
CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 25)
CloseBtn.Text = "X"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 120)
CloseBtn.Parent = Main
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -20, 0, 34)
TabBar.Position = UDim2.new(0, 10, 0, 48)
TabBar.BackgroundTransparency = 1
TabBar.Parent = Main

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 6)
TabLayout.Parent = TabBar

local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -20, 1, -95)
Content.Position = UDim2.new(0, 10, 0, 90)
Content.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 4
Content.ScrollBarImageColor3 = Color3.fromRGB(0, 200, 255)
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
Content.Parent = Main
Instance.new("UICorner", Content).CornerRadius = UDim.new(0, 10)

local ContentPad = Instance.new("UIPadding")
ContentPad.PaddingTop = UDim.new(0, 8)
ContentPad.PaddingBottom = UDim.new(0, 8)
ContentPad.PaddingLeft = UDim.new(0, 8)
ContentPad.PaddingRight = UDim.new(0, 8)
ContentPad.Parent = Content

local Pages = {}
local function makePage(name)
    local p = Instance.new("Frame")
    p.Name = name
    p.Size = UDim2.new(1, 0, 0, 0)
    p.AutomaticSize = Enum.AutomaticSize.Y
    p.BackgroundTransparency = 1
    p.Visible = false
    p.Parent = Content
    local l = Instance.new("UIListLayout")
    l.Padding = UDim.new(0, 8)
    l.Parent = p
    Pages[name] = p
    return p
end

local function switchTab(name)
    for n, p in pairs(Pages) do
        p.Visible = (n == name)
    end
end

local function makeTab(label, pageName)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 92, 1, 0)
    b.BackgroundColor3 = Color3.fromRGB(32, 36, 48)
    b.Text = label
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 13
    b.TextColor3 = Color3.fromRGB(200, 220, 255)
    b.Parent = TabBar
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    b.MouseButton1Click:Connect(function()
        switchTab(pageName)
    end)
end

local pageTroll = makePage("Troll")
local pageMove = makePage("Movement")
local pagePlayers = makePage("Players")
local pageMisc = makePage("Misc")
makeTab("Troll", "Troll")
makeTab("Movement", "Movement")
makeTab("Players", "Players")
makeTab("Misc", "Misc")
switchTab("Troll")

local function addToggle(parent, text, default, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 36)
    row.BackgroundColor3 = Color3.fromRGB(30, 32, 42)
    row.Parent = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -70, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextColor3 = Color3.fromRGB(230, 235, 255)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local on = default
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 52, 0, 24)
    btn.Position = UDim2.new(1, -60, 0.5, -12)
    btn.BackgroundColor3 = on and Color3.fromRGB(0, 180, 120) or Color3.fromRGB(60, 60, 75)
    btn.Text = on and "ON" or "OFF"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Parent = row
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        on = not on
        btn.Text = on and "ON" or "OFF"
        btn.BackgroundColor3 = on and Color3.fromRGB(0, 180, 120) or Color3.fromRGB(60, 60, 75)
        callback(on)
    end)
end

local function addButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(0, 90, 120)
    btn.Text = text
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 13
    btn.TextColor3 = Color3.fromRGB(220, 250, 255)
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function addSlider(parent, text, minV, maxV, default, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 52)
    row.BackgroundColor3 = Color3.fromRGB(30, 32, 42)
    row.Parent = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -12, 0, 20)
    lbl.Position = UDim2.new(0, 12, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = text .. ": " .. tostring(default)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextColor3 = Color3.fromRGB(220, 230, 255)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local bar = Instance.new("TextButton")
    bar.Size = UDim2.new(1, -24, 0, 10)
    bar.Position = UDim2.new(0, 12, 0, 30)
    bar.BackgroundColor3 = Color3.fromRGB(50, 55, 70)
    bar.Text = ""
    bar.AutoButtonColor = false
    bar.Parent = row
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 4)

    local fill = Instance.new("Frame")
    local pct = (default - minV) / (maxV - minV)
    fill.Size = UDim2.new(pct, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    fill.BorderSizePixel = 0
    fill.Parent = bar
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)

    local sliding = false
    local function update(x)
        local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        local val = math.floor(minV + (maxV - minV) * rel)
        lbl.Text = text .. ": " .. tostring(val)
        callback(val)
    end
    bar.MouseButton1Down:Connect(function()
        sliding = true
        update(Mouse.X)
    end)
    bind(UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end))
    bind(UIS.InputChanged:Connect(function(i)
        if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            update(i.Position.X)
        end
    end))
end

-- Features
local flyBV, flyBG
local function setFly(on)
    State.Flying = on
    local hrp = getHRP()
    if not hrp then return end
    if flyBV then flyBV:Destroy() flyBV = nil end
    if flyBG then flyBG:Destroy() flyBG = nil end
    if not on then return end

    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    flyBV.Velocity = Vector3.zero
    flyBV.Parent = hrp

    flyBG = Instance.new("BodyGyro")
    flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyBG.P = 9e4
    flyBG.Parent = hrp

    bind(RunService.RenderStepped:Connect(function()
        if not State.Flying or not flyBV or not flyBV.Parent then return end
        local cam = workspace.CurrentCamera
        local dir = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.yAxis end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.yAxis end
        local hum = getHum()
        if hum and dir.Magnitude < 0.1 then dir = hum.MoveDirection end
        flyBV.Velocity = dir.Magnitude > 0 and dir.Unit * (State.Speed * 2) or Vector3.zero
        flyBG.CFrame = cam.CFrame
    end))
end

bind(RunService.Stepped:Connect(function()
    if not State.Noclip then return end
    local char = LP.Character
    if not char then return end
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide = false end
    end
end))

bind(UIS.JumpRequest:Connect(function()
    if State.InfJump then
        local hum = getHum()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end))

local function applyMovementStats()
    local hum = getHum()
    if not hum then return end
    hum.WalkSpeed = State.Speed
    pcall(function() hum.JumpPower = State.JumpPower end)
    pcall(function() hum.JumpHeight = State.JumpPower / 7 end)
end

local function setInvisible(on)
    State.Invisible = on
    local char = getChar()
    if not char then return end
    for _, d in ipairs(char:GetDescendants()) do
        if d:IsA("BasePart") or d:IsA("Decal") then
            d.Transparency = on and 1 or 0
        elseif d:IsA("Accessory") then
            local h = d:FindFirstChildWhichIsA("BasePart")
            if h then h.Transparency = on and 1 or 0 end
        end
    end
end

local function flingTarget(plr)
    if not plr or not plr.Character then return end
    local thrp = plr.Character:FindFirstChild("HumanoidRootPart")
    local hrp = getHRP()
    if not thrp or not hrp then return end
    State.Flinging = true
    local bv = Instance.new("BodyAngularVelocity")
    bv.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bv.AngularVelocity = Vector3.new(0, 9e5, 0)
    bv.Parent = hrp
    local start = tick()
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if tick() - start > 1.2 or not State.Flinging then
            if bv then bv:Destroy() end
            if conn then conn:Disconnect() end
            State.Flinging = false
            return
        end
        hrp.CFrame = thrp.CFrame
    end)
end

local function massFling()
    State.MassFling = true
    task.spawn(function()
        for _, plr in ipairs(Players:GetPlayers()) do
            if not State.MassFling then break end
            if plr ~= LP then
                flingTarget(plr)
                task.wait(1.3)
            end
        end
        State.MassFling = false
        notify("Fling", "Mass fling finished")
    end)
end

local function tpTo(plr)
    if not plr or not plr.Character then return end
    local thrp = plr.Character:FindFirstChild("HumanoidRootPart")
    local hrp = getHRP()
    if thrp and hrp then
        hrp.CFrame = thrp.CFrame * CFrame.new(0, 0, 3)
    end
end

local function bringPlayer(plr)
    if not plr or not plr.Character then return end
    local thrp = plr.Character:FindFirstChild("HumanoidRootPart")
    local hrp = getHRP()
    if not thrp or not hrp then return end
    local old = hrp.CFrame
    for _ = 1, 15 do
        hrp.CFrame = thrp.CFrame
        task.wait(0.05)
    end
    hrp.CFrame = old
end

local spamMessages = {
    "get trolled lmao",
    "delta on top",
    "skill issue",
    "gg ez",
    "why are you running",
    "caught in 4k",
}

local function setChatSpam(on)
    State.ChatSpam = on
    if not on then return end
    task.spawn(function()
        while State.ChatSpam do
            local msg = spamMessages[math.random(1, #spamMessages)]
            pcall(function()
                local chat = game:GetService("TextChatService")
                local channels = chat:FindFirstChild("TextChannels")
                local channel = channels and channels:FindFirstChild("RBXGeneral")
                if channel then channel:SendAsync(msg) end
            end)
            pcall(function() Players:Chat(msg) end)
            task.wait(2.5)
        end
    end)
end

local function setDanceSpam(on)
    State.DanceSpam = on
    if not on then return end
    task.spawn(function()
        while State.DanceSpam do
            local hum = getHum()
            if hum then
                local anim = Instance.new("Animation")
                anim.AnimationId = "rbxassetid://507771019"
                local track = hum:LoadAnimation(anim)
                track:Play()
                task.wait(2)
                track:Stop()
            end
            task.wait(0.3)
        end
    end)
end

bind(RunService.Heartbeat:Connect(function()
    if not State.AntiFling then return end
    local hrp = getHRP()
    if hrp and hrp.AssemblyLinearVelocity.Magnitude > 150 then
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
end))

local function giveTrollTool(name)
    local tool = Instance.new("Tool")
    tool.Name = name
    tool.RequiresHandle = true
    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(1, 1, 3)
    handle.Color = Color3.fromRGB(255, 50, 50)
    handle.Parent = tool
    tool.Parent = LP.Backpack

    if name == "Fling Hammer" then
        tool.Activated:Connect(function()
            if State.Selected then flingTarget(State.Selected) end
        end)
    elseif name == "TP Click" then
        tool.Activated:Connect(function()
            local hrp = getHRP()
            if hrp and Mouse.Hit then
                hrp.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0))
            end
        end)
    end
    notify("Tools", name .. " added")
end

addToggle(pageTroll, "Fling Selected", false, function(v)
    if v and State.Selected then flingTarget(State.Selected) end
end)
addButton(pageTroll, "Fling Selected Once", function()
    if State.Selected then flingTarget(State.Selected) else notify("Troll", "Select a player first") end
end)
addButton(pageTroll, "Mass Fling All", function() massFling() end)
addToggle(pageTroll, "Invisible (Local)", false, setInvisible)
addToggle(pageTroll, "Chat Spam", false, setChatSpam)
addToggle(pageTroll, "Dance Spam", false, setDanceSpam)
addButton(pageTroll, "Give Fling Hammer", function() giveTrollTool("Fling Hammer") end)
addButton(pageTroll, "Give TP Click Tool", function() giveTrollTool("TP Click") end)

addToggle(pageMove, "Fly", false, setFly)
addToggle(pageMove, "Noclip", false, function(v) State.Noclip = v end)
addToggle(pageMove, "Infinite Jump", false, function(v) State.InfJump = v end)
addSlider(pageMove, "WalkSpeed", 16, 200, 16, function(v)
    State.Speed = v
    applyMovementStats()
end)
addSlider(pageMove, "JumpPower", 50, 200, 50, function(v)
    State.JumpPower = v
    applyMovementStats()
end)

local PlayerFrame = Instance.new("Frame")
PlayerFrame.Size = UDim2.new(1, 0, 0, 200)
PlayerFrame.BackgroundColor3 = Color3.fromRGB(30, 32, 42)
PlayerFrame.Parent = pagePlayers
Instance.new("UICorner", PlayerFrame).CornerRadius = UDim.new(0, 8)

local PlayerScroll = Instance.new("ScrollingFrame")
PlayerScroll.Size = UDim2.new(1, -10, 1, -10)
PlayerScroll.Position = UDim2.new(0, 5, 0, 5)
PlayerScroll.BackgroundTransparency = 1
PlayerScroll.ScrollBarThickness = 4
PlayerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
PlayerScroll.Parent = PlayerFrame

local PlayerListLayout = Instance.new("UIListLayout")
PlayerListLayout.Padding = UDim.new(0, 4)
PlayerListLayout.Parent = PlayerScroll

local function refreshPlayers()
    for _, c in ipairs(PlayerScroll:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, -4, 0, 28)
            b.BackgroundColor3 = (State.Selected == plr) and Color3.fromRGB(0, 120, 140) or Color3.fromRGB(40, 44, 58)
            b.Text = plr.Name
            b.Font = Enum.Font.Gotham
            b.TextSize = 12
            b.TextColor3 = Color3.fromRGB(230, 240, 255)
            b.Parent = PlayerScroll
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
            b.MouseButton1Click:Connect(function()
                State.Selected = plr
                refreshPlayers()
                notify("Players", "Selected " .. plr.Name)
            end)
        end
    end
end

addButton(pagePlayers, "Refresh Player List", refreshPlayers)
addButton(pagePlayers, "Teleport to Selected", function()
    if State.Selected then tpTo(State.Selected) else notify("Players", "Select someone") end
end)
addButton(pagePlayers, "Bring Attempt (FE limited)", function()
    if State.Selected then bringPlayer(State.Selected) else notify("Players", "Select someone") end
end)
refreshPlayers()
Players.PlayerAdded:Connect(function() task.wait(0.5) refreshPlayers() end)
Players.PlayerRemoving:Connect(function() task.wait(0.2) refreshPlayers() end)

addToggle(pageMisc, "Anti-Fling", false, function(v) State.AntiFling = v end)
addButton(pageMisc, "Reset Character", function()
    local hum = getHum()
    if hum then hum.Health = 0 end
end)
addButton(pageMisc, "Reapply Speed/Jump", applyMovementStats)

local function destroyAll()
    State.Flying = false
    State.Noclip = false
    State.InfJump = false
    State.ChatSpam = false
    State.DanceSpam = false
    State.MassFling = false
    State.Flinging = false
    setFly(false)
    for _, c in ipairs(Connections) do pcall(function() c:Disconnect() end) end
    if Gui then Gui:Destroy() end
    notify("Troll", "GUI destroyed")
end

addButton(pageMisc, "DESTROY GUI / UNLOAD", destroyAll)
CloseBtn.MouseButton1Click:Connect(destroyAll)

LP.CharacterAdded:Connect(function()
    task.wait(1)
    applyMovementStats()
    if State.Invisible then setInvisible(true) end
end)

notify("Delta Troll", "Loaded — use tabs to troll")
