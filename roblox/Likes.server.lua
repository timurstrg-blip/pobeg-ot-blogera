-- Likes (положить в ServerScriptService как обычный Script)
-- Расставляет лайки по точкам из папки Workspace.LikeSpawns в каждом раунде.
-- Касание: +1 к leaderstats Likes, респаун через 20 сек.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")

local RESPAWN_DELAY = 20

local state = ReplicatedStorage:WaitForChild("GameState")
local template = ServerStorage:WaitForChild("LikePickup")
local spawns = Workspace:WaitForChild("LikeSpawns")

local byPoint = {}

local function spawnAt(point: BasePart)
	if byPoint[point] and byPoint[point].Parent then
		return -- тут уже есть лайк
	end
	local p = template:Clone()
	p.CFrame = point.CFrame + Vector3.new(0, 3, 0)
	p.Parent = Workspace
	byPoint[point] = p

	task.spawn(function()
		while p.Parent do
			p.CFrame = p.CFrame * CFrame.Angles(0, math.rad(5), 0)
			task.wait(0.05)
		end
	end)

	local taken = false
	p.Touched:Connect(function(hit)
		if taken or state.Value ~= "Playing" then
			return
		end
		local characterModel = hit:FindFirstAncestorOfClass("Model")
		local plr = characterModel and Players:GetPlayerFromCharacter(characterModel)
		if not plr then
			return
		end
		if plr:GetAttribute("Spectator") or plr:GetAttribute("Escaped") then
			return
		end
		taken = true
		byPoint[point] = nil
		local stats = plr:FindFirstChild("leaderstats")
		local likes = stats and stats:FindFirstChild("Likes")
		if likes then
			(likes :: IntValue).Value += 1
		end
		local s = p:FindFirstChildOfClass("Sound")
		if s then
			s.Parent = Workspace
			s:Play()
			Debris:AddItem(s, 3)
		end
		p:Destroy()
		task.delay(RESPAWN_DELAY, function()
			if state.Value == "Playing" and point.Parent then
				spawnAt(point)
			end
		end)
	end)
end

local function clearAll()
	for point, p in pairs(byPoint) do
		if p and p.Parent then
			p:Destroy()
		end
		byPoint[point] = nil
	end
end

state:GetPropertyChangedSignal("Value"):Connect(function()
	if state.Value == "Playing" then
		clearAll()
		for _, point in ipairs(spawns:GetChildren()) do
			if point:IsA("BasePart") then
				spawnAt(point)
			end
		end
	elseif state.Value == "Lobby" then
		clearAll()
	end
end)
