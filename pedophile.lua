-- Linoria + Lock-On Aimbot Example
-- GitHub-ready

--skid nation nigga

local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()

-- Window
local Window = Library:CreateWindow({
	Title = 'Aimbot Hood Rat',
	Center = true,
	AutoShow = true,
})

local Tab = Window:AddTab('Main')
local Group = Tab:AddLeftGroupbox('Combat')

-- ===== LOCK ON LOGIC =====

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local mouse = player:GetMouse()

local Enabled = false
local locked = false
local targetHead
local renderConn
local diedConn

local function isFirstPerson()
	return (camera.Focus.Position - camera.CFrame.Position).Magnitude < 1
end

local function unlock()
	locked = false
	targetHead = nil

	if renderConn then renderConn:Disconnect() renderConn = nil end
	if diedConn then diedConn:Disconnect() diedConn = nil end

	camera.CameraType = Enum.CameraType.Custom
end

local function lockOn(head, humanoid)
	locked = true
	targetHead = head
	camera.CameraType = Enum.CameraType.Scriptable

	if humanoid then
		diedConn = humanoid.Died:Connect(unlock)
	end

	renderConn = RunService.RenderStepped:Connect(function()
		if not Enabled or not targetHead or not targetHead.Parent then
			unlock()
			return
		end

		camera.CFrame = CFrame.new(
			camera.CFrame.Position,
			targetHead.Position
		)
	end)
end

UserInputService.InputBegan:Connect(function(input, gp)
	if gp or not Enabled then return end
	if input.UserInputType ~= Enum.UserInputType.MouseButton2 then return end
	if not isFirstPerson() then return end

	if locked then
		unlock()
		return
	end

	local hit = mouse.Target
	if not hit then return end

	local model = hit:FindFirstAncestorWhichIsA("Model")
	if not model then return end

	local head = model:FindFirstChild("Head")
	if not head then return end

	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.Health <= 0 then return end

	lockOn(head, humanoid)
end)

-- ===== UI TOGGLE =====

Group:AddToggle('LockOnAimbot', {
	Text = 'Lock-On Aimbot',
	Default = false,
	Tooltip = 'Right-click heads in first person',

	Callback = function(Value)
		Enabled = Value
		if not Value then
			unlock()
		end
	end
})

Library:OnUnload(function()
	unlock()
end)
