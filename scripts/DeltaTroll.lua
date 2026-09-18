--[[
  DELTA TROLL v2 | keyless | Delta Executor
  loadstring(game:HttpGet("https://raw.githubusercontent.com/barnesjayren0-sudo/Jayren-Sudo-Rivals-Hub/main/scripts/DeltaTroll.lua"))()
]]
local P,RS,UIS,SG=game:GetService("Players"),game:GetService("RunService"),game:GetService("UserInputService"),game:GetService("StarterGui")
local LP,Mouse=P.LocalPlayer,LP:GetMouse()
local S={fly=false,noclip=false,ijump=false,inv=false,spd=16,jmp=50,sel=nil,fling=false,spam=false,anti=false}
local con,bv,bg={}
local function bind(c)con[#con+1]=c return c end
local function char()return LP.Character or LP.CharacterAdded:Wait()end
local function hrp(c)c=c or char()return c and c:FindFirstChild("HumanoidRootPart")end
local function hum(c)c=c or char()return c and c:FindFirstChildOfClass("Humanoid")end
local function note(t,m)pcall(function()SG:SetCore("SendNotification",{Title=t,Text=m,Duration=2})end)end

-- lines shown as the SELECTED player (bubble). FE cannot force their real chat.
local BAD={
"shut the fuck up","you're so trash","ez mid","cry more noob","skill issue idiot",
"ratio + L","get good loser","nobody asked","stfu","your mom","touch grass",
"absolute dogwater","delete the game","bot account","free kill","trash player"
}

local function bubbleOn(plr,text)
	if not plr or not plr.Character then return end
	local h=plr.Character:FindFirstChild("Head")or plr.Character:FindFirstChild("HumanoidRootPart")
	if not h then return end
	local old=h:FindFirstChild("TrollBubble")
	if old then old:Destroy()end
	local bb=Instance.new("BillboardGui")
	bb.Name="TrollBubble"
	bb.Size=UDim2.new(0,220,0,52)
	bb.StudsOffset=Vector3.new(0,3.2,0)
	bb.AlwaysOnTop=true
	bb.Parent=h
	local tl=Instance.new("TextLabel",bb)
	tl.Size=UDim2.new(1,0,1,0)
	tl.BackgroundColor3=Color3.fromRGB(255,255,255)
	tl.TextColor3=Color3.fromRGB(0,0,0)
	tl.Font=Enum.Font.GothamBold
	tl.TextScaled=true
	tl.Text=plr.DisplayName..": "..text
	Instance.new("UICorner",tl).CornerRadius=UDim.new(0,8)
	task.delay(4,function()if bb then bb:Destroy()end end)
end

local function targetSay()
	if not S.sel then note("Troll","Pick a player")return end
	local msg=BAD[math.random(1,#BAD)]
	bubbleOn(S.sel,msg)
end

local function spamTargetTalk(on)
	S.spam=on
	if not on then return end
	task.spawn(function()
		while S.spam do
			if S.sel then bubbleOn(S.sel,BAD[math.random(1,#BAD)])end
			task.wait(1.8)
		end
	end)
end

local function setFly(on)
	S.fly=on
	local h=hrp()if not h then return end
	if bv then bv:Destroy()bv=nil end
	if bg then bg:Destroy()bg=nil end
	if not on then return end
	bv=Instance.new("BodyVelocity")bv.MaxForce=Vector3.new(9e9,9e9,9e9)bv.Velocity=Vector3.zero bv.Parent=h
	bg=Instance.new("BodyGyro")bg.MaxTorque=Vector3.new(9e9,9e9,9e9)bg.P=9e4 bg.Parent=h
	bind(RS.RenderStepped:Connect(function()
		if not S.fly or not bv or not bv.Parent then return end
		local cam=workspace.CurrentCamera local d=Vector3.zero
		if UIS:IsKeyDown(Enum.KeyCode.W)then d+=cam.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.S)then d-=cam.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.A)then d-=cam.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.D)then d+=cam.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.Space)then d+=Vector3.yAxis end
		if UIS:IsKeyDown(Enum.KeyCode.LeftControl)then d-=Vector3.yAxis end
		local hu=hum()if hu and d.Magnitude<.1 then d=hu.MoveDirection end
		bv.Velocity=d.Magnitude>0 and d.Unit*(S.spd*2.2)or Vector3.zero
		bg.CFrame=cam.CFrame
	end))
end

bind(RS.Stepped:Connect(function()
	if not S.noclip then return end
	local c=LP.Character if not c then return end
	for _,p in ipairs(c:GetDescendants())do if p:IsA("BasePart")then p.CanCollide=false end end
end))
bind(UIS.JumpRequest:Connect(function()if S.ijump then local h=hum()if h then h:ChangeState(Enum.HumanoidStateType.Jumping)end end end))
local function applyStats()local h=hum()if h then h.WalkSpeed=S.spd pcall(function()h.JumpPower=S.jmp end)pcall(function()h.JumpHeight=S.jmp/7 end)end end

local function setInv(on)
	S.inv=on local c=char()if not c then return end
	for _,d in ipairs(c:GetDescendants())do
		if d:IsA("BasePart")or d:IsA("Decal")then d.Transparency=on and 1 or 0
		elseif d:IsA("Accessory")then local p=d:FindFirstChildWhichIsA("BasePart")if p then p.Transparency=on and 1 or 0 end end
	end
end

local function fling(plr)
	if not plr or not plr.Character then return end
	local t,h=plr.Character:FindFirstChild("HumanoidRootPart"),hrp()
	if not t or not h then return end
	S.fling=true
	local a=Instance.new("BodyAngularVelocity")a.MaxTorque=Vector3.new(9e9,9e9,9e9)a.AngularVelocity=Vector3.new(0,9e5,0)a.Parent=h
	local t0=tick()local cn
	cn=RS.Heartbeat:Connect(function()
		if tick()-t0>1.1 or not S.fling then a:Destroy()cn:Disconnect()S.fling=false return end
		h.CFrame=t.CFrame
	end)
end

local function massFling()
	task.spawn(function()
		for _,plr in ipairs(P:GetPlayers())do if plr~=LP then fling(plr)task.wait(1.2)end end
		note("Fling","done")
	end)
end

local function tp(plr)
	local t,h=plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart"),hrp()
	if t and h then h.CFrame=t.CFrame*CFrame.new(0,0,3)end
end

bind(RS.Heartbeat:Connect(function()
	if not S.anti then return end
	local h=hrp()if h and h.AssemblyLinearVelocity.Magnitude>140 then h.AssemblyLinearVelocity=Vector3.zero h.AssemblyAngularVelocity=Vector3.zero end
end))

local G=Instance.new("ScreenGui")G.Name="DT2"G.ResetOnSpawn=false G.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
pcall(function()G.Parent=game:GetService("CoreGui")end)if not G.Parent then G.Parent=LP:WaitForChild("PlayerGui")end

local M=Instance.new("Frame",G)M.Size=UDim2.new(0,300,0,380)M.Position=UDim2.new(.5,-150,.5,-190)
M.BackgroundColor3=Color3.fromRGB(14,14,20)M.BorderSizePixel=0 M.Active=true M.Draggable=true
Instance.new("UICorner",M).CornerRadius=UDim.new(0,10)
local stroke=Instance.new("UIStroke",M)stroke.Color=Color3.fromRGB(0,255,200)stroke.Thickness=1 stroke.Transparency=.4

local Title=Instance.new("TextLabel",M)Title.Size=UDim2.new(1,-40,0,28)Title.Position=UDim2.new(0,10,0,4)
Title.BackgroundTransparency=1 Title.Text="TROLL v2"Title.Font=Enum.Font.GothamBold Title.TextSize=14 Title.TextColor3=Color3.fromRGB(0,255,200)Title.TextXAlignment=Enum.TextXAlignment.Left

local XB=Instance.new("TextButton",M)XB.Size=UDim2.new(0,26,0,26)XB.Position=UDim2.new(1,-30,0,4)
XB.BackgroundColor3=Color3.fromRGB(50,20,25)XB.Text="X"XB.TextColor3=Color3.fromRGB(255,80,100)XB.Font=Enum.Font.GothamBold XB.TextSize=12
Instance.new("UICorner",XB).CornerRadius=UDim.new(0,6)

local tabs=Instance.new("Frame",M)tabs.Size=UDim2.new(1,-12,0,26)tabs.Position=UDim2.new(0,6,0,34)tabs.BackgroundTransparency=1
local tl=Instance.new("UIListLayout",tabs)tl.FillDirection=Enum.FillDirection.Horizontal tl.Padding=UDim.new(0,4)

local body=Instance.new("ScrollingFrame",M)body.Size=UDim2.new(1,-12,1,-68)body.Position=UDim2.new(0,6,0,64)
body.BackgroundColor3=Color3.fromRGB(20,20,28)body.BorderSizePixel=0 body.ScrollBarThickness=3
body.AutomaticCanvasSize=Enum.AutomaticSize.Y body.CanvasSize=UDim2.new()
Instance.new("UICorner",body).CornerRadius=UDim.new(0,8)
local pad=Instance.new("UIPadding",body)pad.PaddingTop=UDim.new(0,6)pad.PaddingBottom=UDim.new(0,6)pad.PaddingLeft=UDim.new(0,6)pad.PaddingRight=UDim.new(0,6)

local pages={}
local function page(n)
	local f=Instance.new("Frame",body)f.Size=UDim2.new(1,0,0,0)f.AutomaticSize=Enum.AutomaticSize.Y f.BackgroundTransparency=1 f.Visible=false
	Instance.new("UIListLayout",f).Padding=UDim.new(0,5)
	pages[n]=f return f
end
local function show(n)for k,v in pairs(pages)do v.Visible=k==n end end
local function tab(label,n)
	local b=Instance.new("TextButton",tabs)b.Size=UDim2.new(0,68,1,0)b.BackgroundColor3=Color3.fromRGB(28,32,42)
	b.Text=label b.Font=Enum.Font.GothamMedium b.TextSize=11 b.TextColor3=Color3.fromRGB(200,230,255)
	Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
	b.MouseButton1Click:Connect(function()show(n)end)
end

local pT,pM,pP,pX=page("T"),page("M"),page("P"),page("X")
tab("Troll","T")tab("Move","M")tab("Players","P")tab("Misc","X")show("T")

local function tog(parent,txt,cb)
	local r=Instance.new("Frame",parent)r.Size=UDim2.new(1,0,0,30)r.BackgroundColor3=Color3.fromRGB(28,30,40)
	Instance.new("UICorner",r).CornerRadius=UDim.new(0,6)
	local l=Instance.new("TextLabel",r)l.Size=UDim2.new(1,-58,1,0)l.Position=UDim2.new(0,8,0,0)l.BackgroundTransparency=1
	l.Text=txt l.Font=Enum.Font.Gotham l.TextSize=11 l.TextColor3=Color3.fromRGB(230,235,255)l.TextXAlignment=Enum.TextXAlignment.Left
	local on=false
	local b=Instance.new("TextButton",r)b.Size=UDim2.new(0,44,0,20)b.Position=UDim2.new(1,-50,.5,-10)
	b.BackgroundColor3=Color3.fromRGB(55,55,70)b.Text="OFF"b.Font=Enum.Font.GothamBold b.TextSize=10 b.TextColor3=Color3.new(1,1,1)
	Instance.new("UICorner",b).CornerRadius=UDim.new(0,5)
	b.MouseButton1Click:Connect(function()on=not on b.Text=on and"ON"or"OFF"b.BackgroundColor3=on and Color3.fromRGB(0,170,110)or Color3.fromRGB(55,55,70)cb(on)end)
end
local function btn(parent,txt,cb)
	local b=Instance.new("TextButton",parent)b.Size=UDim2.new(1,0,0,30)b.BackgroundColor3=Color3.fromRGB(0,100,115)
	b.Text=txt b.Font=Enum.Font.GothamMedium b.TextSize=11 b.TextColor3=Color3.fromRGB(220,255,255)
	Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)b.MouseButton1Click:Connect(cb)
end
local function sld(parent,txt,a,b,def,cb)
	local r=Instance.new("Frame",parent)r.Size=UDim2.new(1,0,0,44)r.BackgroundColor3=Color3.fromRGB(28,30,40)
	Instance.new("UICorner",r).CornerRadius=UDim.new(0,6)
	local l=Instance.new("TextLabel",r)l.Size=UDim2.new(1,-10,0,16)l.Position=UDim2.new(0,8,0,2)l.BackgroundTransparency=1
	l.Text=txt..": "..def l.Font=Enum.Font.Gotham l.TextSize=11 l.TextColor3=Color3.fromRGB(220,230,255)l.TextXAlignment=Enum.TextXAlignment.Left
	local bar=Instance.new("TextButton",r)bar.Size=UDim2.new(1,-16,0,8)bar.Position=UDim2.new(0,8,0,26)bar.BackgroundColor3=Color3.fromRGB(45,50,65)bar.Text=""bar.AutoButtonColor=false
	Instance.new("UICorner",bar).CornerRadius=UDim.new(0,3)
	local f=Instance.new("Frame",bar)f.Size=UDim2.new((def-a)/(b-a),0,1,0)f.BackgroundColor3=Color3.fromRGB(0,220,180)f.BorderSizePixel=0
	Instance.new("UICorner",f).CornerRadius=UDim.new(0,3)
	local hold=false
	local function up(x)
		local rel=math.clamp((x-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
		f.Size=UDim2.new(rel,0,1,0)local v=math.floor(a+(b-a)*rel)l.Text=txt..": "..v cb(v)
	end
	bar.MouseButton1Down:Connect(function()hold=true up(Mouse.X)end)
	bind(UIS.InputEnded:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then hold=false end end))
	bind(UIS.InputChanged:Connect(function(i)if hold then up(i.Position.X)end end))
end

btn(pT,"Target says bad word",targetSay)
tog(pT,"Spam target bubbles",spamTargetTalk)
btn(pT,"Fling selected",function()if S.sel then fling(S.sel)else note("Troll","select player")end end)
btn(pT,"Mass fling",massFling)
tog(pT,"Invisible",setInv)
btn(pT,"Bubbles on everyone",function()
	for _,plr in ipairs(P:GetPlayers())do if plr~=LP then bubbleOn(plr,BAD[math.random(1,#BAD)])end end
end)

tog(pM,"Fly",setFly)
tog(pM,"Noclip",function(v)S.noclip=v end)
tog(pM,"Inf Jump",function(v)S.ijump=v end)
sld(pM,"Speed",16,200,16,function(v)S.spd=v applyStats()end)
sld(pM,"Jump",50,200,50,function(v)S.jmp=v applyStats()end)

local pf=Instance.new("Frame",pP)pf.Size=UDim2.new(1,0,0,160)pf.BackgroundColor3=Color3.fromRGB(28,30,40)
Instance.new("UICorner",pf).CornerRadius=UDim.new(0,6)
local ps=Instance.new("ScrollingFrame",pf)ps.Size=UDim2.new(1,-8,1,-8)ps.Position=UDim2.new(0,4,0,4)
ps.BackgroundTransparency=1 ps.ScrollBarThickness=3 ps.AutomaticCanvasSize=Enum.AutomaticSize.Y ps.CanvasSize=UDim2.new()
Instance.new("UIListLayout",ps).Padding=UDim.new(0,3)

local function refresh()
	for _,c in ipairs(ps:GetChildren())do if c:IsA("TextButton")then c:Destroy()end end
	for _,plr in ipairs(P:GetPlayers())do
		if plr~=LP then
			local b=Instance.new("TextButton",ps)b.Size=UDim2.new(1,-2,0,24)
			b.BackgroundColor3=S.sel==plr and Color3.fromRGB(0,130,120)or Color3.fromRGB(36,40,52)
			b.Text=plr.DisplayName.." (@"..plr.Name..")"
			b.Font=Enum.Font.Gotham b.TextSize=11 b.TextColor3=Color3.fromRGB(230,240,255)
			Instance.new("UICorner",b).CornerRadius=UDim.new(0,5)
			b.MouseButton1Click:Connect(function()S.sel=plr refresh()note("Sel",plr.Name)end)
		end
	end
end
btn(pP,"Refresh",refresh)
btn(pP,"TP to selected",function()if S.sel then tp(S.sel)end end)
btn(pP,"Speak + fling",function()if S.sel then targetSay()task.wait(.15)fling(S.sel)end end)
refresh()
P.PlayerAdded:Connect(function()task.wait(.4)refresh()end)
P.PlayerRemoving:Connect(function()task.wait(.2)refresh()end)

tog(pX,"Anti-fling",function(v)S.anti=v end)
btn(pX,"Reset",function()local h=hum()if h then h.Health=0 end end)
local function kill()
	S.fly=false S.noclip=false S.ijump=false S.spam=false S.fling=false
	setFly(false)
	for _,c in ipairs(con)do pcall(function()c:Disconnect()end)end
	G:Destroy()
end
btn(pX,"DESTROY GUI",kill)
XB.MouseButton1Click:Connect(kill)

LP.CharacterAdded:Connect(function()task.wait(.8)applyStats()if S.inv then setInv(true)end end)
note("Troll v2","loaded")
