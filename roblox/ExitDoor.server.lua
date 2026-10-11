-- ExitDoor (положить ВНУТРЬ модели ExitDoor в Workspace как обычный Script)
-- Модель: Part "Door" + Part "PromptPart" с ProximityPrompt внутри.
-- Этот же скрипт следит за WinPad: касание открытой двери = побег.
-- Число лайков должно совпадать с текстом в GameManager!

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local REQUIRED_LIKES = 5

local state = ReplicatedStorage:WaitForChild("GameState")
local notifyEvent = ReplicatedStorage:WaitForChild("NotifyEvent")

local doorModel = script.Parent
local door = doorModel:WaitForChild("Door")
local promptPart = doorModel:WaitForChild("PromptPart")
local prompt = promptPart:WaitForChild("ProximityPrompt")

local winPad = Workspace:WaitForChild("WinPad")
local winSpawn = Workspace:WaitForChild("WinSpawn")

local closedCF = door.CFrame
local isOpen = false

local function setOpen(v: boolean)
	isOpen = v
	door.CanCollide = not v
	door.Transparency = v and 0.7 or 0
	if v then
		door.CFrame = closedCF + Vector3.new(0, door.Size.Y + 0.5, 0)
	else
		door.CFrame = closedCF
	end
end

prompt.Triggered:Connect(function(plr)
	if state.Value ~= "Playing" then
		return
	end
	if isOpen then
		return
	end
	local stats = plr:FindFirstChild("leaderstats")
	local likes = stats and stats:FindFirstChild("Likes")
	local n = likes and (likes :: IntValue).Value or 0
	if n >= REQUIRED_LIKES then
		setOpen(true)
		notifyEvent:FireAllClients("Выход открыт! Беги в зелёную зону!")
	else
		notifyEvent:FireClient(plr, "Нужно лайков: " .. REQUIRED_LIKES .. ", у тебя: " .. n)
	end
end)

winPad.Touched:Connect(function(hit)
	if state.Value ~= "Playing" or not isOpen then
		return
	end
	local characterModel = hit:FindFirstAncestorOfClass("Model")
	local plr = characterModel and Players:GetPlayerFromCharacter(characterModel)
	if not plr then
		return
	end
	if plr:GetAttribute("Escaped") or plr:GetAttribute("Spectator") then
		return
	end
	plr:SetAttribute("Escaped", true)
	notifyEvent:FireAllClients(plr.DisplayName .. " сбежал от блогера!")
	local ch = plr.Character
	if ch then
		ch:PivotTo(winSpawn.CFrame + Vector3.new(0, 4, 0))
	end
end)

state:GetPropertyChangedSignal("Value"):Connect(function()
	if state.Value == "Playing" then
		setOpen(false)
	end
end)
