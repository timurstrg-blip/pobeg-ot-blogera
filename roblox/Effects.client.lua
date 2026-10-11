-- Effects (положить в StarterPlayer > StarterPlayerScripts как LocalScript)
-- Скример при поимке + всплывающие сообщения + таймер сверху.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local plr = Players.LocalPlayer
local playerGui = plr:WaitForChild("PlayerGui")

local catchEvent = ReplicatedStorage:WaitForChild("CatchEvent")
local notifyEvent = ReplicatedStorage:WaitForChild("NotifyEvent")
local state = ReplicatedStorage:WaitForChild("GameState")
local timerVal = ReplicatedStorage:WaitForChild("GameTimer")

local screen = Instance.new("ScreenGui")
screen.Name = "BloggerFx"
screen.ResetOnSpawn = false
screen.IgnoreGuiInset = true
screen.Parent = playerGui

-- таймер сверху
local top = Instance.new("TextLabel")
top.Size = UDim2.new(0, 400, 0, 36)
top.Position = UDim2.new(0.5, -200, 0, 12)
top.BackgroundColor3 = Color3.fromRGB(17, 23, 37)
top.BackgroundTransparency = 0.2
top.TextColor3 = Color3.new(1, 1, 1)
top.Font = Enum.Font.GothamBold
top.TextSize = 18
top.Parent = screen
local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 10)
topCorner.Parent = top

local function refreshTop()
	if state.Value == "Playing" then
		local t = timerVal.Value
		top.Text = "СТРИМ: осталось " .. string.format("%d:%02d", t // 60, t % 60)
	elseif state.Value == "Lobby" then
		top.Text = timerVal.Value > 0 and ("Старт через " .. timerVal.Value) or "Ждём игроков..."
	else
		top.Text = "Финал..."
	end
end
state:GetPropertyChangedSignal("Value"):Connect(refreshTop)
timerVal:GetPropertyChangedSignal("Value"):Connect(refreshTop)
refreshTop()

-- скример на весь экран
local scare = Instance.new("Frame")
scare.Size = UDim2.new(1, 0, 1, 0)
scare.BackgroundColor3 = Color3.fromRGB(140, 0, 20)
scare.Visible = false
scare.Parent = screen

local face = Instance.new("TextLabel")
face.Size = UDim2.new(1, 0, 1, 0)
face.BackgroundTransparency = 1
face.Text = "ПОПАЛСЯ!\nТЫ В ВЛОГЕ"
face.TextColor3 = Color3.new(1, 1, 1)
face.Font = Enum.Font.GothamBlack
face.TextSize = 60
face.Parent = scare

-- свой звук скримера: вставь SoundId из Toolbox (иначе без звука)
local scareSound = Instance.new("Sound")
scareSound.SoundId = ""
scareSound.Volume = 1
scareSound.Parent = screen

-- всплывающие сообщения снизу
local toast = Instance.new("TextLabel")
toast.Size = UDim2.new(0, 480, 0, 44)
toast.Position = UDim2.new(0.5, -240, 0, 80)
toast.BackgroundColor3 = Color3.fromRGB(17, 23, 37)
toast.BackgroundTransparency = 0.15
toast.TextColor3 = Color3.new(1, 1, 1)
toast.Font = Enum.Font.GothamBold
toast.TextSize = 18
toast.TextWrapped = true
toast.Visible = false
toast.Parent = screen
local toastCorner = Instance.new("UICorner")
toastCorner.CornerRadius = UDim.new(0, 12)
toastCorner.Parent = toast

catchEvent.OnClientEvent:Connect(function()
	scare.Visible = true
	if scareSound.SoundId ~= "" then
		scareSound:Play()
	end
	task.wait(1.2)
	scare.Visible = false
end)

notifyEvent.OnClientEvent:Connect(function(text)
	toast.Text = tostring(text)
	toast.Visible = true
	task.delay(3, function()
		toast.Visible = false
	end)
end)
