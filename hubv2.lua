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
	Title = 'Epstein Hub V2 | EARLY ACCESS',
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
local infJump = false
local walkSpeed = 16
local espCache = {}

-- helpers
local function char()
	return plr.Character
end

local function hum()
	return char() and char():FindFirstChildOfClass("Humanoid")
end

local function root(m)
	return m:FindFirstChild("Head")
		or m:FindFirstChild("HumanoidRootPart")
end

-- infinite jump
UIS.JumpRequest:Connect(function()
	if infJump and hum() then
		hum():ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

-- walkspeed loop
RunService.Stepped:Connect(function()
	if hum() then
		hum().WalkSpeed = walkSpeed
	end
end)

-- click tp (right click)
mouse.Button2Down:Connect(function()
	if mouse.Hit and char() then
		local hrp = char():FindFirstChild("HumanoidRootPart")
		if hrp then
			hrp.CFrame = mouse.Hit + Vector3.new(0, 3, 0)
		end
	end
end)

-- esp
local function addEsp(m)
	if espCache[m] or not espOn then return end
	espCache[m] = true

	for _, p in ipairs(m:GetDescendants()) do
		if p:IsA("BasePart") then
			local b = Instance.new("BoxHandleAdornment")
			b.Size = p.Size
			b.Adornee = p
			b.Color3 = Color3.new(1, 0, 0)
			b.Transparency = 0.5
			b.AlwaysOnTop = true
			b.Parent = p
		end
	end
end

-- aimbot
local function getTarget()
	local best, dist = nil, math.huge
	local pos = cam.CFrame.Position
	local dir = cam.CFrame.LookVector

	for _, m in ipairs(Workspace:GetChildren()) do
		if m:IsA("Model") and m ~= char() then
			local h = m:FindFirstChildOfClass("Humanoid")
			local r = root(m)
			if h and r and h.Health > 0 then
				local diff = r.Position - pos
				local d = diff.Magnitude
				if d < 300 then
					local dot = dir:Dot(diff.Unit)
					if dot > 0.96 and d < dist then
						best = r
						dist = d
					end
				end
				addEsp(m)
			end
		end
	end

	return best
end

-- aim key
UIS.InputBegan:Connect(function(i, g)
	if g then return end
	if i.KeyCode == Enum.KeyCode.E then
		aimOn = not aimOn
	end
end)

RunService.RenderStepped:Connect(function()
	if not aimOn then return end
	local t = getTarget()
	if t then
		local p = cam.CFrame.Position
		cam.CFrame = cam.CFrame:Lerp(CFrame.new(p, t.Position), 0.18)
	end
end)

-- UI
Box:AddToggle('Aim', {
	Text = 'Aimbot (E)',
	Default = false,
	Callback = function(v)
		aimOn = v
	end
})

Box:AddToggle('ESP', {
	Text = 'ESP',
	Default = false,
	Callback = function(v)
		espOn = v
		if not v then
			espCache = {}
		end
	end
})

Box:AddToggle('Jump', {
	Text = 'Infinite Jump',
	Default = false,
	Callback = function(v)
		infJump = v
	end
})

Box:AddSlider('Speed', {
	Text = 'WalkSpeed',
	Default = 16,
	Min = 16,
	Max = 400,
	Rounding = 0,
	Callback = function(v)
		walkSpeed = v
	end
})

-- ui settings
local Menu = Tabs.UI:AddLeftGroupbox('Menu')
Menu:AddButton('Unload', function()
	Library:Unload()
end)

Menu:AddLabel('Menu key'):AddKeyPicker('MenuKey', {
	Default = 'End',
	NoUI = true
})

Library.ToggleKeybind = Options.MenuKey

-- managers
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKey' })
ThemeManager:SetFolder('EPHub')
SaveManager:SetFolder('EPHub/Configs')
SaveManager:BuildConfigSection(Tabs.UI)
ThemeManager:ApplyToTab(Tabs.UI)
SaveManager:LoadAutoloadConfig()
