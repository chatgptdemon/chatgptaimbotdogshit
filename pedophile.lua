-- Linoria + Lock-On Aimbot + Movement Hub (CLEAN + FIXED)

local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()

-- REQUIRED FOR LINORIA
local Toggles = getgenv().Toggles
local Options = getgenv().Options

-- ===== SERVICES =====
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local mouse = player:GetMouse()

-- ===== WINDOW =====
local Window = Library:CreateWindow({
	Title = 'Epstein Hub V2',
	Center = true,
	AutoShow = true,
})

-- ===== TABS =====
local Tabs = {
	Main = Window:AddTab('Main'),
	UI = Window:AddTab('UI Settings'),
}

local Group = Tabs.Main:AddLeftGroupbox('Little Saint James Armory')

-- ===== CHARACTER =====
local character, humanoid, hrp

local function onCharacter(char)
	character = char
	humanoid = char:WaitForChild("Humanoid")
	hrp = char:WaitForChild("HumanoidRootPart")
end

if player.Character then onCharacter(player.Character) end
player.CharacterAdded:Connect(onCharacter)

-- ===== AIMBOT SETTINGS =====
local AimbotEnabled = false
local LOCK_KEY = Enum.KeyCode.E

local locked = false
local targetHead = nil
local renderConn = nil

-- ===== MOVEMENT STATE =====
local InfiniteJumpEnabled = false
local ClickTPEnabled = false
local FlyEnabled = false
local NoclipEnabled = false

local WalkSpeedValue = 16
local JumpPowerValue = 50

-- ===== AIMBOT FUNCTIONS =====
local function clearLock()
	locked = false
	targetHead = nil

	if renderConn then
		renderConn:Disconnect()
		renderConn = nil
	end

	camera.CameraType = Enum.CameraType.Custom
end

local function lockToHead(head)
	clearLock()

	locked = true
	targetHead = head
	camera.CameraType = Enum.CameraType.Scriptable

	renderConn = RunService.RenderStepped:Connect(function()
		if not AimbotEnabled
			or not targetHead
			or not targetHead.Parent then
			clearLock()
			return
		end

		local hum = targetHead.Parent:FindFirstChildOfClass("Humanoid")
		if not hum or hum.Health <= 0 then
			clearLock()
			return
		end

		camera.CFrame = CFrame.new(
			camera.CFrame.Position,
			targetHead.Position
		)
	end)
end

-- ===== INPUT (AIMBOT + CLICK TP) =====
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end

	-- AIMBOT TOGGLE (E)
	if input.KeyCode == LOCK_KEY and AimbotEnabled then
		if locked then
			clearLock()
			return
		end

		local hit = mouse.Target
		if not hit then return end

		local model = hit:FindFirstAncestorOfClass("Model")
		if not model then return end

		local hum = model:FindFirstChildOfClass("Humanoid")
		local head = model:FindFirstChild("Head")

		if hum and head and hum.Health > 0 then
			lockToHead(head)
		end
	end

	-- CLICK TP (Right Click)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		if ClickTPEnabled and hrp then
			hrp.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
		end
	end
end)

-- ===== INFINITE JUMP =====
UserInputService.JumpRequest:Connect(function()
	if InfiniteJumpEnabled and humanoid and humanoid.Health > 0 then
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

-- ===== FLY =====
local flyVel, flyGyro

RunService.RenderStepped:Connect(function()
	if humanoid then
		humanoid.WalkSpeed = WalkSpeedValue
		humanoid.JumpPower = JumpPowerValue
	end

	if FlyEnabled and hrp then
		if not flyVel then
			flyVel = Instance.new("BodyVelocity", hrp)
			flyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)

			flyGyro = Instance.new("BodyGyro", hrp)
			flyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
		end

		local dir = Vector3.zero
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += camera.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= camera.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= camera.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += camera.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.yAxis end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.yAxis end

		flyVel.Velocity = dir * 80
		flyGyro.CFrame = camera.CFrame
	else
		if flyVel then flyVel:Destroy() flyVel = nil end
		if flyGyro then flyGyro:Destroy() flyGyro = nil end
	end
end)

-- ===== NOCLIP =====
RunService.Stepped:Connect(function()
	if not character then return end
	for _, v in ipairs(character:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CanCollide = not NoclipEnabled
		end
	end
end)

-- ===== UI CONTROLS =====
Group:AddToggle('Aimbot', {
	Text = 'Aimbot (E to lock)',
	Default = false,
	Callback = function(v)
		AimbotEnabled = v
		if not v then clearLock() end
	end
})

Group:AddToggle('InfJump', {
	Text = 'Infinite Jump',
	Default = false,
	Callback = function(v) InfiniteJumpEnabled = v end
})

Group:AddToggle('ClickTP', {
	Text = 'Click Teleport',
	Default = false,
	Callback = function(v) ClickTPEnabled = v end
})

Group:AddToggle('Fly', {
	Text = 'Fly',
	Default = false,
	Callback = function(v) FlyEnabled = v end
})

Group:AddToggle('Noclip', {
	Text = 'Noclip',
	Default = false,
	Callback = function(v) NoclipEnabled = v end
})

Group:AddSlider('WalkSpeed', {
	Text = 'WalkSpeed',
	Default = 16,
	Min = 16,
	Max = 500,
	Rounding = 0,
	Callback = function(v) WalkSpeedValue = v end
})

Group:AddSlider('JumpPower', {
	Text = 'JumpPower',
	Default = 50,
	Min = 0,
	Max = 500,
	Rounding = 0,
	Callback = function(v) JumpPowerValue = v end
})

-- ===== MENU KEY =====
local MenuGroup = Tabs.UI:AddLeftGroupbox('Menu')
MenuGroup:AddLabel('Menu Toggle'):AddKeyPicker('MenuKeybind', {
	Default = 'V',
	Text = 'Toggle Menu',
})

Library.ToggleKeybind = Options.MenuKeybind

-- ===== CLEANUP =====
Library:OnUnload(clearLock)
