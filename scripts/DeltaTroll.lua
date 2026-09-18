--[[
  DELTA TROLL v6 | Premium dark UI | FE physics only | keyless
  loadstring(game:HttpGet("https://raw.githubusercontent.com/barnesjayren0-sudo/Jayren-Sudo-Rivals-Hub/main/scripts/DeltaTroll.lua"))()

  Local tools only. No websocket control of other clients.
  UI inspired by modern exploit hub style (dark + neon accent).
]]
local P=game:GetService("Players")
local RS=game:GetService("RunService")
local UIS=game:GetService("UserInputService")
local SG=game:GetService("StarterGui")
local VU=game:GetService("VirtualUser")
local TS=game:GetService("TweenService")
local LP=P.LocalPlayer
local Mouse=LP:GetMouse()

local ACCENT=Color3.fromRGB(140,80,255) -- purple neon hub style
local BG=Color3.fromRGB(14,12,20)
local CARD=Color3.fromRGB(22,20,32)
local MUTED=Color3.fromRGB(160,155,180)

local S={
	fly=false,noclip=false,ijump=false,inv=false,
	spd=22,jmp=60,sel=nil,
	fling=false,loopFling=false,walkFling=false,
	spam=false,anti=true,esp=true,orbit=false,sync=true,
	clickTP=false,spec=false,spin=false,antiAFK=true,
	rgb=false,tiny=false
}
local con,bv,bg,msgBox,spinBV,rgbCon={}
local PREFIX="DT6|"

local function bind(c)con[#con+1]=c return c end
local function char()return LP.Character or LP.CharacterAdded:Wait()end
local function hrp(c)c=c or char()return c and c:FindFirstChild("HumanoidRootPart")end
local function hum(c)c=c or char()return c and c:FindFirstChildOfClass("Humanoid")end
local function thrp(plr)return plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")end
local function note(t,m)pcall(function()SG:SetCore("SendNotification",{Title=t,Text=m,Duration=2})end)end

local BAD={"shut the fuck up","you're so trash","ez mid","cry more noob","skill issue idiot","ratio + L","get good loser","nobody asked","stfu","touch grass","absolute dogwater","delete the game","bot account","free kill","trash player","L + ratio","mid ahh","cope harder"}

-- bubbles + sync
local function bubbleOn(plr,text,secs)
	if not plr or not plr.Character then return end
	local h=plr.Character:FindFirstChild("Head")or thrp(plr)
	if not h then return end
	pcall(function()local o=h:FindFirstChild("TrollBubble")if o then o:Destroy()end end)
	local bb=Instance.new("BillboardGui")
	bb.Name="TrollBubble"bb.Size=UDim2.new(0,240,0,58)bb.StudsOffset=Vector3.new(0,3.4,0)
	bb.AlwaysOnTop=true bb.MaxDistance=500 bb.Parent=h
	local f=Instance.new("Frame",bb)f.Size=UDim2.new(1,0,1,0)f.BackgroundColor3=Color3.fromRGB(18,14,28)
	Instance.new("UICorner",f).CornerRadius=UDim.new(0,10)
	local s=Instance.new("UIStroke",f)s.Color=ACCENT s.Thickness=1.5
	local tl=Instance.new("TextLabel",f)
	tl.Size=UDim2.new(1,-10,1,-6)tl.Position=UDim2.new(0,5,0,3)tl.BackgroundTransparency=1
	tl.Text=plr.DisplayName..": "..tostring(text)
	tl.Font=Enum.Font.GothamBold tl.TextScaled=true tl.TextColor3=Color3.fromRGB(255,255,255)tl.TextWrapped=true
	task.delay(secs or 5,function()pcall(function()bb:Destroy()end)end)
end

local function chatSend(str)
	pcall(function()
		local tcs=game:GetService("TextChatService")
		local ch=tcs:FindFirstChild("TextChannels")and tcs.TextChannels:FindFirstChild("RBXGeneral")
		if ch then ch:SendAsync(str)return end
	end)
	pcall(function()
		local ev=game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
		if ev and ev:FindFirstChild("SayMessageRequest")then ev.SayMessageRequest:FireServer(str,"All")end
	end)
end

local function broadcastBubble(plr,text)
	if not plr then return end
	bubbleOn(plr,text,6)
	if S.sync then chatSend(PREFIX..tostring(plr.UserId).."|"..tostring(text):gsub("|","/"))end
end

local function handleIncoming(raw)
	if typeof(raw)~="string"or raw:sub(1,#PREFIX)~=PREFIX then return end
	local uidStr,msg=raw:sub(#PREFIX+1):match("^(%d+)|(.+)$")
	if not uidStr then return end
	local plr=P:GetPlayerByUserId(tonumber(uidStr))
	if plr then bubbleOn(plr,msg,6)end
end

pcall(function()
	local tcs=game:GetService("TextChatService")
	if tcs.MessageReceived then bind(tcs.MessageReceived:Connect(function(m)handleIncoming(m.Text)end))end
	task.spawn(function()
		local gen=tcs:FindFirstChild("TextChannels")and tcs.TextChannels:FindFirstChild("RBXGeneral")
		if gen and gen.MessageReceived then bind(gen.MessageReceived:Connect(function(m)handleIncoming(m.Text)end))end
	end)
end)
for _,plr in ipairs(P:GetPlayers())do bind(plr.Chatted:Connect(handleIncoming))end
P.PlayerAdded:Connect(function(plr)bind(plr.Chatted:Connect(handleIncoming))end)

-- IY fling
local function iyFling(targetPlr)
	local root=hrp()
	local c=char()
	if not root or not c or S.fling then return end
	S.fling=true
	for _,child in pairs(c:GetDescendants())do
		if child:IsA("BasePart")then
			pcall(function()child.CustomPhysicalProperties=PhysicalProperties.new(math.huge,0.3,0.5)end)
		end
	end
	local bang=Instance.new("BodyAngularVelocity")
	bang.Name="DT6_IY"bang.Parent=root
	bang.AngularVelocity=Vector3.new(0,99999,0)
	bang.MaxTorque=Vector3.new(0,math.huge,0)bang.P=math.huge
	for _,v in ipairs(c:GetChildren())do
		if v:IsA("BasePart")then
			v.CanCollide=false v.Massless=true
			pcall(function()v.AssemblyLinearVelocity=Vector3.zero end)
		end
	end
	if root then root.CanCollide=true root.Massless=false end
	local t0=tick()
	local cn
	cn=RS.Heartbeat:Connect(function()
		if tick()-t0>2.5 or not S.fling then
			pcall(function()bang:Destroy()end)
			if cn then cn:Disconnect()end
			S.fling=false
			return
		end
		local t=targetPlr and thrp(targetPlr)
		pcall(function()
			if t then root.CFrame=t.CFrame end
			if (tick()*5)%1<0.55 then bang.AngularVelocity=Vector3.new(0,99999,0)
			else bang.AngularVelocity=Vector3.zero end
		end)
	end)
end

local function setWalkFling(on)
	S.walkFling=on
	if not on then
		S.fling=false
		local r=hrp()
		if r then for _,v in ipairs(r:GetChildren())do if v.Name=="DT6_WF"then v:Destroy()end end end
		return
	end
	task.spawn(function()
		while S.walkFling do
			local root=hrp()
			local c=char()
			if root and c then
				if not root:FindFirstChild("DT6_WF")then
					for _,child in pairs(c:GetDescendants())do
						if child:IsA("BasePart")then
							pcall(function()child.CustomPhysicalProperties=PhysicalProperties.new(math.huge,0.3,0.5)end)
							if child~=root then child.CanCollide=false child.Massless=true end
						end
					end
					root.CanCollide=true root.Massless=false
					local bang=Instance.new("BodyAngularVelocity")
					bang.Name="DT6_WF"bang.Parent=root
					bang.MaxTorque=Vector3.new(0,math.huge,0)bang.P=math.huge
				end
				local bang=root:FindFirstChild("DT6_WF")
				if bang then
					if (tick()*5)%1<0.55 then bang.AngularVelocity=Vector3.new(0,99999,0)
					else bang.AngularVelocity=Vector3.zero end
				end
			end
			task.wait()
		end
	end)
end

local function loopFling(on)
	S.loopFling=on
	if not on then S.fling=false return end
	task.spawn(function()
		while S.loopFling do
			if S.sel then iyFling(S.sel)end
			task.wait(2.6)
		end
	end)
end

local function massFling()
	task.spawn(function()
		for _,plr in ipairs(P:GetPlayers())do
			if plr~=LP then iyFling(plr)task.wait(2.6)end
		end
		note("Fling","mass done")
	end)
end

-- movement
local function setFly(on)
	S.fly=on
	local h=hrp()if not h then return end
	if bv then bv:Destroy()bv=nil end
	if bg then bg:Destroy()bg=nil end
	if not on then return end
	bv=Instance.new("BodyVelocity")bv.MaxForce=Vector3.new(9e9,9e9,9e9)bv.Velocity=Vector3.zero bv.Parent=h
	bg=Instance.new("BodyGyro")bg.MaxTorque=Vector3.new(9e9,9e9,9e9)bg.P=5e4 bg.Parent=h
	bind(RS.RenderStepped:Connect(function()
		if not S.fly or not bv or not bv.Parent then return end
		local cam=workspace.CurrentCamera local d=Vector3.zero
		if UIS:IsKeyDown(Enum.KeyCode.W)then d+=cam.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.S)then d-=cam.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.A)then d-=cam.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.D)then d+=cam.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.Space)then d+=Vector3.yAxis end
		if UIS:IsKeyDown(Enum.KeyCode.LeftControl)then d-=Vector3.yAxis end
		local hu=hum()if hu and d.Magnitude<.05 then d=hu.MoveDirection end
		bv.Velocity=d.Magnitude>0 and d.Unit*(S.spd*2.6)or Vector3.zero
		bg.CFrame=cam.CFrame
	end))
end

bind(RS.Stepped:Connect(function()
	if not S.noclip or S.fling or S.walkFling then return end
	local c=LP.Character if not c then return end
	for _,p in ipairs(c:GetDescendants())do if p:IsA("BasePart")then p.CanCollide=false end end
end))

bind(UIS.JumpRequest:Connect(function()
	if S.ijump then local h=hum()if h then h:ChangeState(Enum.HumanoidStateType.Jumping)end end
end))

local function applyStats()
	local h=hum()if h then
		h.WalkSpeed=S.spd
		pcall(function()h.JumpPower=S.jmp end)
		pcall(function()h.JumpHeight=S.jmp/7 end)
	end
end

local function setInv(on)
	S.inv=on local c=char()if not c then return end
	for _,d in ipairs(c:GetDescendants())do
		if d:IsA("BasePart")or d:IsA("Decal")then d.Transparency=on and 1 or 0
		elseif d:IsA("Accessory")then local p=d:FindFirstChildWhichIsA("BasePart")if p then p.Transparency=on and 1 or 0 end end
	end
end

local function setSpin(on)
	S.spin=on
	local r=hrp()
	if spinBV then spinBV:Destroy()spinBV=nil end
	if not on or not r then return end
	spinBV=Instance.new("BodyAngularVelocity")
	spinBV.Name="DT6_Spin"spinBV.MaxTorque=Vector3.new(0,math.huge,0)
	spinBV.AngularVelocity=Vector3.new(0,15,0)spinBV.Parent=r
end

local function setRGB(on)
	S.rgb=on
	if rgbCon then rgbCon:Disconnect()rgbCon=nil end
	if not on then return end
	rgbCon=RS.Heartbeat:Connect(function()
		local c=LP.Character if not c then return end
		local t=tick()*2
		local col=Color3.fromHSV((t%5)/5,1,1)
		for _,p in ipairs(c:GetDescendants())do
			if p:IsA("BasePart")and p.Name~="HumanoidRootPart"then
				p.Color=col
			end
		end
	end)
end

local function setTiny(on)
	S.tiny=on
	local h=hum()
	if h then
		pcall(function()
			if on then h:ApplyDescriptionReset()
				-- local scale attempt (visual often local only)
				for _,p in ipairs(char():GetDescendants())do
					if p:IsA("BasePart")then p.Size=p.Size*0.5 end
				end
			end
		end)
	end
	note("Tiny",on and"local scale attempt"or"off - reset to undo")
end

local function tp(plr)local t,h=thrp(plr),hrp()if t and h then h.CFrame=t.CFrame*CFrame.new(0,0,3)end end

local function setSpectate(on)
	S.spec=on
	if not on then pcall(function()workspace.CurrentCamera.CameraSubject=hum()end)return end
	if S.sel and S.sel.Character then
		local h=S.sel.Character:FindFirstChildOfClass("Humanoid")
		if h then workspace.CurrentCamera.CameraSubject=h end
	end
end

bind(Mouse.Button1Down:Connect(function()
	if not S.clickTP then return end
	if UIS:IsKeyDown(Enum.KeyCode.LeftControl)or UIS.TouchEnabled then
		local h=hrp()
		if h and Mouse.Hit then h.CFrame=CFrame.new(Mouse.Hit.Position+Vector3.new(0,3,0))end
	end
end))

bind(LP.Idled:Connect(function()
	if not S.antiAFK then return end
	pcall(function()VU:CaptureController()VU:ClickButton2(Vector2.new())end)
end))

local function orbit(on)
	S.orbit=on
	if not on then return end
	task.spawn(function()
		local ang=0
		while S.orbit do
			local t,h=thrp(S.sel),hrp()
			if t and h then
				ang+=0.12
				h.CFrame=CFrame.new(t.Position)+Vector3.new(math.cos(ang)*6,2,math.sin(ang)*6)
			end
			task.wait()
		end
	end)
end

local function updateEsp()
	for _,plr in ipairs(P:GetPlayers())do
		if plr.Character then
			pcall(function()local o=plr.Character:FindFirstChild("DT_HL")if o then o:Destroy()end end)
			if S.esp and S.sel==plr then
				local hl=Instance.new("Highlight")
				hl.Name="DT_HL"hl.FillColor=ACCENT
				hl.OutlineColor=Color3.fromRGB(255,255,255)hl.FillTransparency=.55
				hl.Parent=plr.Character
			end
		end
	end
end

bind(RS.Heartbeat:Connect(function()
	if not S.anti or S.fling or S.walkFling then return end
	local h=hrp()
	if h and h.AssemblyLinearVelocity.Magnitude>180 then
		h.AssemblyLinearVelocity=Vector3.zero
		h.AssemblyAngularVelocity=Vector3.zero
	end
end))

local function customSay()
	if not S.sel then note("Troll","Select a player")return end
	broadcastBubble(S.sel,(msgBox and msgBox.Text~=""and msgBox.Text)or BAD[math.random(1,#BAD)])
end
local function targetSay()
	if not S.sel then note("Troll","Select a player")return end
	broadcastBubble(S.sel,BAD[math.random(1,#BAD)])
end
local function spamTarget(on)
	S.spam=on
	if not on then return end
	task.spawn(function()
		while S.spam do
			if S.sel then broadcastBubble(S.sel,(msgBox and msgBox.Text~=""and msgBox.Text)or BAD[math.random(1,#BAD)])end
			task.wait(2.2)
		end
	end)
end

-- ===== PREMIUM DARK UI =====
local G=Instance.new("ScreenGui")G.Name="DT6"G.ResetOnSpawn=false G.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
pcall(function()G.Parent=game:GetService("CoreGui")end)if not G.Parent then G.Parent=LP:WaitForChild("PlayerGui")end

local M=Instance.new("Frame",G)
M.Size=UDim2.new(0,320,0,460)M.Position=UDim2.new(.5,-160,.5,-230)
M.BackgroundColor3=BG M.BorderSizePixel=0 M.Active=true M.Draggable=true
Instance.new("UICorner",M).CornerRadius=UDim.new(0,14)
local stroke=Instance.new("UIStroke",M)stroke.Color=ACCENT stroke.Thickness=1.4 stroke.Transparency=.25

-- top bar
local top=Instance.new("Frame",M)
top.Size=UDim2.new(1,0,0,40)top.BackgroundColor3=Color3.fromRGB(18,16,28)top.BorderSizePixel=0
Instance.new("UICorner",top).CornerRadius=UDim.new(0,14)
local topFix=Instance.new("Frame",top)
topFix.Size=UDim2.new(1,0,0,14)topFix.Position=UDim2.new(0,0,1,-14)topFix.BackgroundColor3=Color3.fromRGB(18,16,28)topFix.BorderSizePixel=0

local Title=Instance.new("TextLabel",top)
Title.Size=UDim2.new(1,-50,1,0)Title.Position=UDim2.new(0,14,0,0)
Title.BackgroundTransparency=1 Title.Text="DELTA TROLL  v6"Title.Font=Enum.Font.GothamBold
Title.TextSize=15 Title.TextColor3=ACCENT Title.TextXAlignment=Enum.TextXAlignment.Left

local XB=Instance.new("TextButton",top)
XB.Size=UDim2.new(0,28,0,28)XB.Position=UDim2.new(1,-34,0,6)
XB.BackgroundColor3=Color3.fromRGB(50,20,35)XB.Text="×"XB.TextColor3=Color3.fromRGB(255,120,140)
XB.Font=Enum.Font.GothamBold XB.TextSize=16
Instance.new("UICorner",XB).CornerRadius=UDim.new(0,8)

-- tabs
local tabs=Instance.new("Frame",M)
tabs.Size=UDim2.new(1,-16,0,32)tabs.Position=UDim2.new(0,8,0,46)tabs.BackgroundTransparency=1
local tpad=Instance.new("UIListLayout",tabs)tpad.FillDirection=Enum.FillDirection.Horizontal tpad.Padding=UDim.new(0,5)

local body=Instance.new("ScrollingFrame",M)
body.Size=UDim2.new(1,-16,1,-90)body.Position=UDim2.new(0,8,0,84)
body.BackgroundColor3=CARD body.BorderSizePixel=0 body.ScrollBarThickness=3
body.ScrollBarImageColor3=ACCENT body.AutomaticCanvasSize=Enum.AutomaticSize.Y body.CanvasSize=UDim2.new()
Instance.new("UICorner",body).CornerRadius=UDim.new(0,10)
local pad=Instance.new("UIPadding",body)
pad.PaddingTop=UDim.new(0,8)pad.PaddingBottom=UDim.new(0,8)pad.PaddingLeft=UDim.new(0,8)pad.PaddingRight=UDim.new(0,8)

local pages={}
local function page(n)
	local f=Instance.new("Frame",body)
	f.Size=UDim2.new(1,0,0,0)f.AutomaticSize=Enum.AutomaticSize.Y f.BackgroundTransparency=1 f.Visible=false
	Instance.new("UIListLayout",f).Padding=UDim.new(0,6)
	pages[n]=f return f
end
local function show(n)for k,v in pairs(pages)do v.Visible=k==n end end
local tabBtns={}
local function tab(label,n)
	local b=Instance.new("TextButton",tabs)
	b.Size=UDim2.new(0,72,1,0)b.BackgroundColor3=Color3.fromRGB(28,24,40)
	b.Text=label b.Font=Enum.Font.GothamMedium b.TextSize=11 b.TextColor3=MUTED
	Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)
	tabBtns[n]=b
	b.MouseButton1Click:Connect(function()
		show(n)
		for k,btn in pairs(tabBtns)do
			btn.BackgroundColor3=k==n and ACCENT or Color3.fromRGB(28,24,40)
			btn.TextColor3=k==n and Color3.fromRGB(255,255,255)or MUTED
		end
	end)
end

local pT,pM,pP,pX=page("T"),page("M"),page("P"),page("X")
tab("Troll","T")tab("Move","M")tab("Players","P")tab("Misc","X")
show("T")
if tabBtns.T then tabBtns.T.BackgroundColor3=ACCENT tabBtns.T.TextColor3=Color3.fromRGB(255,255,255)end

local function tog(parent,txt,def,cb)
	local r=Instance.new("Frame",parent)
	r.Size=UDim2.new(1,0,0,32)r.BackgroundColor3=Color3.fromRGB(28,26,40)
	Instance.new("UICorner",r).CornerRadius=UDim.new(0,8)
	local l=Instance.new("TextLabel",r)
	l.Size=UDim2.new(1,-60,1,0)l.Position=UDim2.new(0,10,0,0)l.BackgroundTransparency=1
	l.Text=txt l.Font=Enum.Font.Gotham l.TextSize=12 l.TextColor3=Color3.fromRGB(235,230,255)l.TextXAlignment=Enum.TextXAlignment.Left
	local on=def or false
	local b=Instance.new("TextButton",r)
	b.Size=UDim2.new(0,46,0,22)b.Position=UDim2.new(1,-52,.5,-11)
	b.BackgroundColor3=on and ACCENT or Color3.fromRGB(50,48,65)
	b.Text=on and"ON"or"OFF"b.Font=Enum.Font.GothamBold b.TextSize=10 b.TextColor3=Color3.new(1,1,1)
	Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
	b.MouseButton1Click:Connect(function()
		on=not on b.Text=on and"ON"or"OFF"
		b.BackgroundColor3=on and ACCENT or Color3.fromRGB(50,48,65)
		cb(on)
	end)
end
local function btn(parent,txt,cb)
	local b=Instance.new("TextButton",parent)
	b.Size=UDim2.new(1,0,0,32)b.BackgroundColor3=Color3.fromRGB(55,40,90)
	b.Text=txt b.Font=Enum.Font.GothamMedium b.TextSize=12 b.TextColor3=Color3.fromRGB(240,235,255)
	Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)
	local st=Instance.new("UIStroke",b)st.Color=ACCENT st.Transparency=.5 st.Thickness=1
	b.MouseButton1Click:Connect(cb)
end
local function sld(parent,txt,a,b,def,cb)
	local r=Instance.new("Frame",parent)
	r.Size=UDim2.new(1,0,0,46)r.BackgroundColor3=Color3.fromRGB(28,26,40)
	Instance.new("UICorner",r).CornerRadius=UDim.new(0,8)
	local l=Instance.new("TextLabel",r)
	l.Size=UDim2.new(1,-10,0,16)l.Position=UDim2.new(0,10,0,4)l.BackgroundTransparency=1
	l.Text=txt..": "..def l.Font=Enum.Font.Gotham l.TextSize=11 l.TextColor3=MUTED l.TextXAlignment=Enum.TextXAlignment.Left
	local bar=Instance.new("TextButton",r)
	bar.Size=UDim2.new(1,-20,0,8)bar.Position=UDim2.new(0,10,0,28)
	bar.BackgroundColor3=Color3.fromRGB(40,38,55)bar.Text=""bar.AutoButtonColor=false
	Instance.new("UICorner",bar).CornerRadius=UDim.new(0,4)
	local f=Instance.new("Frame",bar)
	f.Size=UDim2.new((def-a)/(b-a),0,1,0)f.BackgroundColor3=ACCENT f.BorderSizePixel=0
	Instance.new("UICorner",f).CornerRadius=UDim.new(0,4)
	local hold=false
	local function up(x)
		local rel=math.clamp((x-bar.AbsolutePosition.X)/math.max(bar.AbsoluteSize.X,1),0,1)
		f.Size=UDim2.new(rel,0,1,0)
		local v=math.floor(a+(b-a)*rel)
		l.Text=txt..": "..v cb(v)
	end
	bar.MouseButton1Down:Connect(function()hold=true up(Mouse.X)end)
	bind(UIS.InputEnded:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then hold=false end
	end))
	bind(UIS.InputChanged:Connect(function(i)if hold then up(i.Position.X)end end))
end

-- Troll
local msgRow=Instance.new("Frame",pT)
msgRow.Size=UDim2.new(1,0,0,36)msgRow.BackgroundColor3=Color3.fromRGB(28,26,40)
Instance.new("UICorner",msgRow).CornerRadius=UDim.new(0,8)
msgBox=Instance.new("TextBox",msgRow)
msgBox.Size=UDim2.new(1,-12,1,-8)msgBox.Position=UDim2.new(0,6,0,4)
msgBox.BackgroundColor3=BG msgBox.Text=""msgBox.PlaceholderText="Custom bubble text..."
msgBox.Font=Enum.Font.Gotham msgBox.TextSize=12
msgBox.TextColor3=Color3.fromRGB(255,255,255)msgBox.PlaceholderColor3=MUTED
msgBox.ClearTextOnFocus=false
Instance.new("UICorner",msgBox).CornerRadius=UDim.new(0,6)

btn(pT,"Send bubble (SYNC)",customSay)
btn(pT,"Random bad bubble",targetSay)
tog(pT,"Spam bubbles",false,spamTarget)
tog(pT,"Sync to other DT users",true,function(v)S.sync=v end)
btn(pT,"IY Fling selected",function()if S.sel then iyFling(S.sel)else note("Troll","select player")end end)
tog(pT,"Loop fling selected",false,loopFling)
tog(pT,"Walk fling",false,setWalkFling)
btn(pT,"Mass fling",massFling)
tog(pT,"Orbit selected",false,orbit)
tog(pT,"Invisible",false,setInv)
tog(pT,"RGB body",false,setRGB)

-- Move
tog(pM,"Fly",false,setFly)
tog(pM,"Noclip",false,function(v)S.noclip=v end)
tog(pM,"Inf Jump",false,function(v)S.ijump=v end)
tog(pM,"Spin",false,setSpin)
tog(pM,"Click TP (Ctrl+Click)",false,function(v)S.clickTP=v end)
sld(pM,"Speed",16,220,22,function(v)S.spd=v applyStats()end)
sld(pM,"Jump",50,220,60,function(v)S.jmp=v applyStats()end)

-- Players
local pf=Instance.new("Frame",pP)
pf.Size=UDim2.new(1,0,0,175)pf.BackgroundColor3=Color3.fromRGB(28,26,40)
Instance.new("UICorner",pf).CornerRadius=UDim.new(0,8)
local ps=Instance.new("ScrollingFrame",pf)
ps.Size=UDim2.new(1,-8,1,-8)ps.Position=UDim2.new(0,4,0,4)
ps.BackgroundTransparency=1 ps.ScrollBarThickness=3 ps.ScrollBarImageColor3=ACCENT
ps.AutomaticCanvasSize=Enum.AutomaticSize.Y ps.CanvasSize=UDim2.new()
Instance.new("UIListLayout",ps).Padding=UDim.new(0,4)

local function refresh()
	for _,c in ipairs(ps:GetChildren())do if c:IsA("TextButton")then c:Destroy()end end
	for _,plr in ipairs(P:GetPlayers())do
		if plr~=LP then
			local b=Instance.new("TextButton",ps)
			b.Size=UDim2.new(1,-2,0,26)
			b.BackgroundColor3=S.sel==plr and ACCENT or Color3.fromRGB(36,34,50)
			b.Text=plr.DisplayName.." (@"..plr.Name..")"
			b.Font=Enum.Font.Gotham b.TextSize=11 b.TextColor3=Color3.fromRGB(240,235,255)
			Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
			b.MouseButton1Click:Connect(function()S.sel=plr refresh()updateEsp()note("Sel",plr.Name)end)
		end
	end
	updateEsp()
end
btn(pP,"Refresh list",refresh)
btn(pP,"TP to selected",function()if S.sel then tp(S.sel)end end)
btn(pP,"Bubble + fling",function()if S.sel then customSay()task.wait(.1)iyFling(S.sel)end end)
tog(pP,"Spectate selected",false,setSpectate)
tog(pP,"ESP selected",true,function(v)S.esp=v updateEsp()end)
refresh()
P.PlayerAdded:Connect(function()task.wait(.4)refresh()end)
P.PlayerRemoving:Connect(function()task.wait(.2)refresh()end)

-- Misc
tog(pX,"Anti-fling",true,function(v)S.anti=v end)
tog(pX,"Anti-AFK",true,function(v)S.antiAFK=v end)
btn(pX,"Reset character",function()local h=hum()if h then h.Health=0 end end)
local function kill()
	S.fly=false S.noclip=false S.ijump=false S.spam=false
	S.fling=false S.loopFling=false S.orbit=false S.walkFling=false S.spin=false S.spec=false S.rgb=false
	setFly(false)setWalkFling(false)setSpin(false)setSpectate(false)setRGB(false)
	for _,c in ipairs(con)do pcall(function()c:Disconnect()end)end
	if rgbCon then rgbCon:Disconnect()end
	G:Destroy()
end
btn(pX,"DESTROY GUI",kill)
XB.MouseButton1Click:Connect(kill)

LP.CharacterAdded:Connect(function()
	task.wait(.8)applyStats()
	if S.inv then setInv(true)end
	if S.fly then setFly(true)end
	if S.spin then setSpin(true)end
	if S.walkFling then setWalkFling(true)end
	if S.rgb then setRGB(true)end
end)

note("Delta Troll v6","Premium UI loaded")
