-- lib
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

-- services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

-- player
local plr = Players.LocalPlayer
local cam = Workspace.CurrentCamera
local mouse = plr:GetMouse()

-- window
local Window = Library:CreateWindow({
	Title = 'Epstein Hub V2 | EARLY ACCESS 1.1 |',
	Center = true,
	AutoShow = true
})

local Tabs = {
	Main = Window:AddTab('Main'),
	UI = Window:AddTab('UI Settings')
}

local Box = Tabs.Main:AddLeftGroupbox('Main')

-- state
local aimOn = false
local espOn = false
local tracerOn = false
local tpOn = false
local noclip = false
local infJump = false
local walkSpeed = 16

local AIM_SMOOTH = 0.65 -- light smoothing, accurate

local espCache = {}
local tracers = {}

-- helpers
local function char()
	return plr.Character
end

local function hum()
	return char() and char():FindFirstChildOfClass("Humanoid")
end

-- R6 + R15 safe target part
local function getPart(model)
	return model:FindFirstChild("Head")
		or model:FindFirstChild("HumanoidRootPart")
		or model:FindFirstChild("UpperTorso")
end

-- team check (ONLY if teams exist)
local function sameTeam(model)
	local p = Players:GetPlayerFromCharacter(model)
	if not p then return false end

	if not plr.Team or not p.Team then
		return false
	end

	return p.Team == plr.Team
end

-------------------------------------------------
-- movement
-------------------------------------------------

-- infinite jump
UIS.JumpRequest:Connect(function()
	if infJump and hum() then
		hum():ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

-- walkspeed + noclip
RunService.Stepped:Connect(function()
	if hum() then
		hum().WalkSpeed = walkSpeed
	end

	if noclip and char() then
		for _, p in ipairs(char():GetDescendants()) do
			if p:IsA("BasePart") then
				p.CanCollide = false
			end
		end
	end
end)

-- click tp (right click)
mouse.Button2Down:Connect(function()
	if not tpOn then return end
	if mouse.Hit and char() then
		local hrp = char():FindFirstChild("HumanoidRootPart")
		if hrp then
			hrp.CFrame = mouse.Hit + Vector3.new(0, 3, 0)
		end
	end
end)

-------------------------------------------------
-- esp
-------------------------------------------------

local function addEsp(model)
	if espCache[model] then return end
	espCache[model] = true

	for _, p in ipairs(model:GetDescendants()) do
		if p:IsA("BasePart") then
			local box = Instance.new("BoxHandleAdornment")
			box.Name = "ESP"
			box.Adornee = p
			box.Size = p.Size
			box.Color3 = Color3.new(1, 0, 0)
			box.Transparency = 0.5
			box.AlwaysOnTop = true
			box.ZIndex = 5
			box.Parent = p
		end
	end
end

local function clearEsp()
	for m in pairs(espCache) do
		for _, d in ipairs(m:GetDescendants()) do
			if d:IsA("BoxHandleAdornment") then
				d:Destroy()
			end
		end
	end
	espCache = {}
end

-------------------------------------------------
-- tracers
-------------------------------------------------

local function addTracer(model, part)
	if tracers[model] then return end

	local a0 = Instance.new("Attachment")
	a0.Parent = cam

	local a1 = Instance.new("Attachment")
	a1.Parent = part

	local beam = Instance.new("Beam")
	beam.Attachment0 = a0
	beam.Attachment1 = a1
	beam.Width0 = 0.08
	beam.Width1 = 0.08
	beam.FaceCamera = true
	beam.LightInfluence = 0
	beam.Color = ColorSequence.new(Color3.new(1, 0, 0))
	beam.Transparency = NumberSequence.new(0.25)
	beam.Parent = cam

	tracers[model] = {beam, a0, a1}
end

local function clearTracers()
	for _, t in pairs(tracers) do
		for _, o in ipairs(t) do
			o:Destroy()
		end
	end
	tracers = {}
end

-------------------------------------------------
-- target scan
-------------------------------------------------

local function scanTargets(cb)
	for _, m in ipairs(Workspace:GetChildren()) do
		if m:IsA("Model") and m ~= char() then
			local h = m:FindFirstChildOfClass("Humanoid")
			if h and h.Health > 0 and not sameTeam(m) then
				local r = getPart(m)
				if r then
					cb(m, r)
				end
			end
		end
	end
end

-------------------------------------------------
-- esp + tracers loop (independent)
-------------------------------------------------

RunService.RenderStepped:Connect(function()
	if not espOn and not tracerOn then return end

	scanTargets(function(m, r)
		if espOn then
			addEsp(m)
		end

		if tracerOn then
			addTracer(m, r)
		end
	end)
end)

-------------------------------------------------
-- aimbot
-------------------------------------------------

local function getAimTarget()
	local best, bestDist = nil, math.huge
	local camPos = cam.CFrame.Position
	local camDir = cam.CFrame.LookVector

	scanTargets(function(_, r)
		local v = r.Position - camPos
		local d = v.Magnitude
		if d < 300 then
			local dot = camDir:Dot(v.Unit)
			if dot > 0.96 and d < bestDist then
				best = r
				bestDist = d
			end
		end
	end)

	return best
end

UIS.InputBegan:Connect(function(i, g)
	if g then return end
	if i.KeyCode == Enum.KeyCode.E then
		aimOn = not aimOn
	end
end)

RunService.RenderStepped:Connect(function()
	if not aimOn then return end

	local t = getAimTarget()
	if t then
		local p = cam.CFrame.Position
		cam.CFrame = cam.CFrame:Lerp(
			CFrame.new(p, t.Position),
			AIM_SMOOTH
		)
	end
end)

-------------------------------------------------
-- UI
-------------------------------------------------

Box:AddToggle('Aim', {
	Text = 'Aimbot (E)',
	Default = false,
	Callback = function(v) aimOn = v end
})

Box:AddToggle('ESP', {
	Text = 'ESP',
	Default = false,
	Callback = function(v)
		espOn = v
		if not v then clearEsp() end
	end
})

Box:AddToggle('Tracers', {
	Text = 'Tracers',
	Default = false,
	Callback = function(v)
		tracerOn = v
		if not v then clearTracers() end
	end
})

Box:AddToggle('TP', {
	Text = 'Click TP',
	Default = false,
	Callback = function(v) tpOn = v end
})

Box:AddToggle('Noclip', {
	Text = 'Noclip',
	Default = false,
	Callback = function(v) noclip = v end
})

Box:AddToggle('Jump', {
	Text = 'Infinite Jump',
	Default = false,
	Callback = function(v) infJump = v end
})

Box:AddSlider('Speed', {
	Text = 'WalkSpeed',
	Default = 16,
	Min = 16,
	Max = 400,
	Rounding = 0,
	Callback = function(v) walkSpeed = v end
})

-------------------------------------------------
-- UI settings
-------------------------------------------------

local Menu = Tabs.UI:AddLeftGroupbox('Menu')
Menu:AddButton('Unload', function()
	Library:Unload()
end)

Menu:AddLabel('Menu key'):AddKeyPicker('MenuKey', {
	Default = 'End',
	NoUI = true
})

Library.ToggleKeybind = Options.MenuKey

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKey' })
ThemeManager:SetFolder('EPHub')
SaveManager:SetFolder('EPHub/Configs')
SaveManager:BuildConfigSection(Tabs.UI)
ThemeManager:ApplyToTab(Tabs.UI)
SaveManager:LoadAutoloadConfig()
