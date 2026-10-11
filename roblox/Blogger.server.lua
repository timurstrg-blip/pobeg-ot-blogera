-- Blogger (положить ВНУТРЬ модели монстра в ServerStorage как обычный Script)
-- Модель: Rig Builder (R15) + Part "CatchZone" с WeldConstraint к HumanoidRootPart.
-- Гоняется за ближайшим игроком через PathfindingService, ускоряется со временем.

local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local monster = script.Parent
local humanoid = monster:WaitForChild("Humanoid")
local root = monster:WaitForChild("HumanoidRootPart")
local catchZone = monster:WaitForChild("CatchZone")

local state = ReplicatedStorage:WaitForChild("GameState")
local catchEvent = ReplicatedStorage:WaitForChild("CatchEvent")

local BASE_SPEED = 13
local MAX_SPEED = 22
local roundStart = os.clock()
local debounce = {}

humanoid.DisplayName = "БЛОГЕР"

local function isTarget(plr: Player): boolean
	if plr:GetAttribute("Escaped") then
		return false
	end
	if plr:GetAttribute("Spectator") then
		return false
	end
	local ch = plr.Character
	local h = ch and ch:FindFirstChildOfClass("Humanoid")
	return h ~= nil and h.Health > 0
end

local function nearest(): Player?
	local best: Player? = nil
	local bestDist = math.huge
	for _, plr in ipairs(Players:GetPlayers()) do
		if isTarget(plr) then
			local ch = plr.Character
			local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
			if hrp and hrp:IsA("BasePart") then
				local d = (hrp.Position - root.Position).Magnitude
				if d < bestDist then
					best, bestDist = plr, d
				end
			end
		end
	end
	return best
end

local function chase(hrp: BasePart)
	local path = PathfindingService:CreatePath({
		AgentRadius = 2,
		AgentHeight = 5,
		AgentCanJump = true,
	})
	local ok = pcall(function()
		path:ComputeAsync(root.Position, hrp.Position)
	end)
	if not ok or path.Status ~= Enum.PathStatus.Success then
		humanoid:MoveTo(hrp.Position)
		task.wait(0.4)
		return
	end
	local points = path:GetWaypoints()
	for i = 2, math.min(#points, 4) do
		if state.Value ~= "Playing" then
			break
		end
		local wp = points[i]
		humanoid:MoveTo(wp.Position)
		if wp.Action == Enum.PathWaypointAction.Jump then
			humanoid.Jump = true
		end
		humanoid.MoveToFinished:Wait()
	end
end

-- поимка: скример клиенту, через 0.7 сек игрок "умирает"
catchZone.Touched:Connect(function(hit)
	if state.Value ~= "Playing" then
		return
	end
	local characterModel = hit:FindFirstAncestorOfClass("Model")
	local plr = characterModel and Players:GetPlayerFromCharacter(characterModel)
	if not plr or not isTarget(plr) then
		return
	end
	local now = os.clock()
	if debounce[plr] and now - debounce[plr] < 2 then
		return
	end
	debounce[plr] = now
	catchEvent:FireClient(plr)
	task.wait(0.7)
	if state.Value ~= "Playing" then
		return
	end
	local ch = plr.Character
	local h = ch and ch:FindFirstChildOfClass("Humanoid")
	if h and h.Health > 0 then
		h.Health = 0
	end
end)

while monster.Parent do
	if state.Value == "Playing" then
		local target = nearest()
		local ch = target and target.Character
		local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
		if hrp and hrp:IsA("BasePart") then
			humanoid.WalkSpeed = math.min(MAX_SPEED, BASE_SPEED + (os.clock() - roundStart) * 0.04)
			if (hrp.Position - root.Position).Magnitude < 12 then
				humanoid:MoveTo(hrp.Position) -- вблизи бежит прямо
				task.wait(0.3)
			else
				chase(hrp)
			end
		else
			task.wait(0.5)
		end
	else
		roundStart = os.clock()
		table.clear(debounce)
		task.wait(0.5)
	end
end
