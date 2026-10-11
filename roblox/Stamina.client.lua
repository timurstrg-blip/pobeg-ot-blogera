-- Stamina (положить в StarterPlayer > StarterCharacterScripts как LocalScript)
-- Shift = рывок (скорость 26 вместо 16), стамина тратится и восстанавливается.
-- На телефоне появляется кнопка бега.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local char = script.Parent
local humanoid = char:WaitForChild("Humanoid")
local plr = Players:GetPlayerFromCharacter(char)
local playerGui = plr:WaitForChild("PlayerGui")

local WALK_SPEED = 16
local RUN_SPEED = 26
local MAX_STAM = 100

local stamina = MAX_STAM
local wantRun = false

-- убрать старую панель после респауна
local old = playerGui:FindFirstChild("StaminaGui")
if old then
	old:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "StaminaGui"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local bg = Instance.new("Frame")
bg.Size = UDim2.new(0, 220, 0, 18)
bg.Position = UDim2.new(0.5, -110, 1, -70)
bg.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
bg.BorderSizePixel = 0
bg.Parent = gui

local bgCorner = Instance.new("UICorner")
bgCorner.CornerRadius = UDim.new(0, 9)
bgCorner.Parent = bg

local bar = Instance.new("Frame")
bar.Size = UDim2.new(1, 0, 1, 0)
bar.BackgroundColor3 = Color3.fromRGB(55, 224, 91)
bar.BorderSizePixel = 0
bar.Parent = bg

local barCorner = Instance.new("UICorner")
barCorner.CornerRadius = UDim.new(0, 9)
barCorner.Parent = bar

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0, 220, 0, 20)
label.Position = UDim2.new(0.5, -110, 1, -95)
label.BackgroundTransparency = 1
label.Text = "Shift — рывок"
label.TextColor3 = Color3.new(1, 1, 1)
label.Font = Enum.Font.GothamBold
label.TextSize = 13
label.Parent = gui

if UserInputService.TouchEnabled then
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 90, 0, 90)
	btn.Position = UDim2.new(1, -110, 1, -200)
	btn.Text = "Бег"
	btn.TextSize = 22
	btn.Font = Enum.Font.GothamBold
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.BackgroundColor3 = Color3.fromRGB(55, 224, 91)
	btn.BackgroundTransparency = 0.3
	btn.Parent = gui
	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(1, 0)
	btnCorner.Parent = btn
	btn.MouseButton1Down:Connect(function()
		wantRun = true
	end)
	btn.MouseButton1Up:Connect(function()
		wantRun = false
	end)
end

UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then
		return
	end
	if input.KeyCode == Enum.KeyCode.LeftShift then
		wantRun = true
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftShift then
		wantRun = false
	end
end)

RunService.Heartbeat:Connect(function(dt)
	local moving = humanoid.MoveDirection.Magnitude > 0.1
	if wantRun and moving and stamina > 1 then
		humanoid.WalkSpeed = RUN_SPEED
		stamina = math.max(0, stamina - 30 * dt)
	else
		humanoid.WalkSpeed = WALK_SPEED
		stamina = math.min(MAX_STAM, stamina + 18 * dt)
	end
	bar.Size = UDim2.new(stamina / MAX_STAM, 0, 1, 0)
end)
