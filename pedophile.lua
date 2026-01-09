-- Linoria + Lock-On Aimbot + Movement Hub (NO THEMES)

local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()

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

-- ===== AIMBOT STATE =====
local AimbotEnabled = false
local LOCK_KEY = Enum.KeyCode.E

local locked = false
local targetHead
local renderConnection

local function clearLock()
	locked = false
	targetHead = nil

	if renderConnection then
		renderConnection:Disconnect()
		renderConnection = nil
	end

	camera.CameraType = Enum.CameraType.Custom
end

local function lockToHead(head)
	clearLock()

	targetHead = head
	locked = true
	camera.CameraType = Enum.CameraType.Scriptable

	renderConnection = RunService.RenderStepped:Connect(function()
		local char = targetHead and targetHead.Parent
		local hum = char and char:FindFirstChildOfClass("Humanoid")

		if not targetHead or not hum or hum.Health <= 0 then
			clearLock()
			return
		end

		camera.CFrame = CFrame.new(camera.CFrame.Position, targetHead.Position)
	end)
end

-- ===== AIMBOT INPUT =====
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode ~= LOCK_KEY then return end
	if not AimbotEnabled then return end

	if locked then
		clearLock()
		return
	end

	local target = mouse.Target
	if not target then return end

	local model = target:FindFirstAncestorOfClass("Model")
	if not model then return end

	local hum = model:FindFirstChildOfClass("Humanoid")
	local head = model:FindFirstChild("Head")

	if hum and head and hum.Health > 0 then
		lockToHead(head)
	end
end)

-- ===== MOVEMENT =====
local InfiniteJumpEnabled = false
local ClickTPEnabled = false
local FlyEnabled = false
local NoclipEnabled = false

local WalkSpeedValue = 16
local JumpPowerValue = 50

-- ===== CLICK TP =====
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.UserInputType ~= Enum.UserInputType.MouseButton2 then return end
	if ClickTPEnabled and hrp then
		hrp.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
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
	Text = 'Lock On (Press E)',
	Default = false,
	Callback = function(v)
		AimbotEnabled = v
		if not v then clearLock() end
	end
})

Group:AddToggle('InfJump', {
	Text = 'Erik Mode',
	Default = false,
	Callback = function(v) InfiniteJumpEnabled = v end
})

Group:AddToggle('ClickTP', {
	Text = 'teleport to LSJ island',
	Default = false,
	Callback = function(v) ClickTPEnabled = v end
})

Group:AddToggle('Fly', {
	Text = 'go to heaven',
	Default = false,
	Callback = function(v) FlyEnabled = v end
})

Group:AddToggle('Noclip', {
	Text = 'turn into emmetts dad',
	Default = false,
	Callback = function(v) NoclipEnabled = v end
})

Group:AddSlider('WalkSpeed', {
	Text = 'Marcus Power',
	Default = 16,
	Min = 16,
	Max = 500,
	Callback = function(v) WalkSpeedValue = v end
})

Group:AddSlider('Erik Power', {
	Text = 'Jump Power',
	Default = 50,
	Min = 0,
	Max = 500,
	Callback = function(v) JumpPowerValue = v end
})

-- ===== MENU KEY =====
local MenuGroup = Tabs.UI:AddLeftGroupbox('Menu')
MenuGroup:AddLabel('Menu Toggle'):AddKeyPicker('MenuKeybind', {
	Default = 'V',
	Text = 'Toggle Menu',
})

Library.ToggleKeybind = Options.MenuKeybind
Library:OnUnload(clearLock)
