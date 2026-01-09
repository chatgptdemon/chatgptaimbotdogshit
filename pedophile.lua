-- Linoria + Lock-On Aimbot + Infinite Jump + Click TP

local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()

-- ===== WINDOW =====
local Window = Library:CreateWindow({
	Title = 'Epstein Hub',
	Center = true,
	AutoShow = true,
})

-- ===== TABS =====
local Tabs = {
	Main = Window:AddTab('Main'),
	UI = Window:AddTab('UI Settings'),
}

local Group = Tabs.Main:AddLeftGroupbox('Little Saint James Armory')

-- ===== SERVICES =====
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local mouse = player:GetMouse()

-- ===== AIMBOT STATE =====
local AimbotEnabled = false
local locked = false
local targetHead
local renderConn
local diedConn

-- ===== MISC STATE =====
local InfiniteJumpEnabled = false
local ClickTPEnabled = false

-- ===== UTIL =====
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
		if not AimbotEnabled or not targetHead or not targetHead.Parent then
			unlock()
			return
		end

		camera.CFrame = CFrame.new(camera.CFrame.Position, targetHead.Position)
	end)
end

-- ===== INPUT HANDLER =====
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end

	-- RIGHT CLICK
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		local hit = mouse.Target
		if not hit then return end

		local character = player.Character
		local hrp = character and character:FindFirstChild("HumanoidRootPart")

		-- AIMBOT (HEAD PRIORITY)
		if AimbotEnabled and isFirstPerson() then
			local model = hit:FindFirstAncestorWhichIsA("Model")
			if model then
				local head = model:FindFirstChild("Head")
				if head and hit == head then
					if locked then
						unlock()
					else
						local humanoid = model:FindFirstChildOfClass("Humanoid")
						if not humanoid or humanoid.Health <= 0 then return end
						lockOn(head, humanoid)
					end
					return
				end
			end
		end

		-- CLICK TP (GROUND / PART)
		if ClickTPEnabled and hrp and hit:IsA("BasePart") then
			hrp.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
		end
	end
end)

-- ===== INFINITE JUMP =====
UserInputService.JumpRequest:Connect(function()
	if not InfiniteJumpEnabled then return end

	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

-- ===== UI TOGGLES =====
Group:AddToggle('Aim The Lil Ep Blick', {
	Text = 'Aim onto the Oppositions',
	Default = false,
	Callback = function(v)
		AimbotEnabled = v
		if not v then unlock() end
	end
})

Group:AddToggle('Jump over israel', {
	Text = 'Wama jump?',
	Default = false,
	Callback = function(v)
		InfiniteJumpEnabled = v
	end
})

Group:AddToggle('TP to Island', {
	Text = 'TP',
	Default = false,
	Tooltip = 'Right-click ground to teleport to island',
	Callback = function(v)
		ClickTPEnabled = v
	end
})

-- ===== UI KEYBIND =====
local MenuGroup = Tabs.UI:AddLeftGroupbox('Menu')

MenuGroup:AddLabel('Menu Toggle'):AddKeyPicker('MenuKeybind', {
	Default = 'V',
	Text = 'Toggle Menu',
})

Library.ToggleKeybind = Options.MenuKeybind

-- ===== CLEANUP =====
Library:OnUnload(function()
	unlock()
end)
