-- GameManager (положить в ServerScriptService как обычный Script)
-- Раунды: лобби -> игра -> финал. Спавн монстра, таймер, очки, победы.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local INTERMISSION = 15 -- секунд ожидания в лобби
local ROUND_TIME = 180 -- длительность раунда в секундах
local MIN_PLAYERS = 1
local MONSTER_NAME = "Blogger" -- имя модели монстра в ServerStorage

-- Проверка, что карта собрана (подсказки в Output, если что-то забыл)
for _, name in ipairs({ "LobbySpawn", "PlayerSpawns", "LikeSpawns", "WinPad", "WinSpawn" }) do
	if not Workspace:FindFirstChild(name) then
		warn("GameManager: в Workspace нет '" .. name .. "'. Смотри README, шаг 3!")
	end
end

local state = ReplicatedStorage:WaitForChild("GameState")
local timerVal = ReplicatedStorage:WaitForChild("GameTimer")
local notifyEvent = ReplicatedStorage:WaitForChild("NotifyEvent")

local lobbySpawn = Workspace:WaitForChild("LobbySpawn")
local spawnsFolder = Workspace:WaitForChild("PlayerSpawns")

local monster: Model? = nil

-- Очки и флаги игрока
Players.PlayerAdded:Connect(function(plr)
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"

	local likes = Instance.new("IntValue")
	likes.Name = "Likes"
	likes.Parent = stats

	local wins = Instance.new("IntValue")
	wins.Name = "Wins"
	wins.Parent = stats

	stats.Parent = plr
	plr:SetAttribute("Escaped", false)
	plr:SetAttribute("Spectator", false)

	plr.CharacterAdded:Connect(function(char)
		-- зашёл посреди раунда -> зритель в лобби
		if state.Value == "Playing" then
			plr:SetAttribute("Spectator", true)
		end
		local hum = char:WaitForChild("Humanoid")
		hum.Died:Connect(function()
			if state.Value == "Playing" and not plr:GetAttribute("Escaped") then
				plr:SetAttribute("Spectator", true)
				notifyEvent:FireAllClients("Попался в влог: " .. plr.DisplayName)
			end
		end)
	end)
end)

local function activePlayers(): { Player }
	local list = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		if not plr:GetAttribute("Spectator") and not plr:GetAttribute("Escaped") then
			local ch = plr.Character
			local h = ch and ch:FindFirstChildOfClass("Humanoid")
			if h and h.Health > 0 then
				table.insert(list, plr)
			end
		end
	end
	return list
end

local function anyoneEscaped(): boolean
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr:GetAttribute("Escaped") then
			return true
		end
	end
	return false
end

local function teleportRandomSpawn(plr: Player)
	local points = spawnsFolder:GetChildren()
	if #points == 0 then
		warn("GameManager: папка PlayerSpawns пустая!")
		return
	end
	local p = points[math.random(1, #points)]
	local ch = plr.Character
	if ch and p:IsA("BasePart") then
		ch:PivotTo(p.CFrame + Vector3.new(0, 4, 0))
	end
end

local function startRound()
	-- сброс игроков (пока state ещё не Playing, чтобы не стать зрителями)
	for _, plr in ipairs(Players:GetPlayers()) do
		plr:SetAttribute("Escaped", false)
		plr:SetAttribute("Spectator", false)
		local stats = plr:FindFirstChild("leaderstats")
		local likes = stats and stats:FindFirstChild("Likes")
		if likes then
			(likes :: IntValue).Value = 0
		end
		plr:LoadCharacter()
		teleportRandomSpawn(plr)
	end
	-- спавн монстра
	local template = ServerStorage:WaitForChild(MONSTER_NAME)
	if monster then
		monster:Destroy()
	end
	monster = template:Clone()
	monster.Parent = Workspace

	state.Value = "Playing"
	notifyEvent:FireAllClients("Блогер вышел в стрим! Собирай 5 лайков и беги к выходу!")
end

local function endRound(bloggerWon: boolean)
	state.Value = "End"
	if monster then
		monster:Destroy()
		monster = nil
	end
	if bloggerWon then
		notifyEvent:FireAllClients("Блогер заснял всех! Влог удался.")
	else
		notifyEvent:FireAllClients("Вы сбежали от блогера! Победа!")
		for _, plr in ipairs(Players:GetPlayers()) do
			local ch = plr.Character
			local h = ch and ch:FindFirstChildOfClass("Humanoid")
			if h and h.Health > 0 then
				local stats = plr:FindFirstChild("leaderstats")
				local wins = stats and stats:FindFirstChild("Wins")
				if wins then
					(wins :: IntValue).Value += 1
				end
			end
		end
	end
	task.wait(6)
	-- всех в лобби
	state.Value = "Lobby"
	for _, plr in ipairs(Players:GetPlayers()) do
		plr:SetAttribute("Escaped", false)
		plr:SetAttribute("Spectator", false)
		plr:LoadCharacter()
		local ch = plr.Character
		if ch then
			ch:PivotTo(lobbySpawn.CFrame + Vector3.new(0, 4, 0))
		end
	end
end

state.Value = "Lobby"

-- главный цикл
while true do
	while #Players:GetPlayers() < MIN_PLAYERS do
		timerVal.Value = 0
		task.wait(1)
	end
	for i = INTERMISSION, 1, -1 do
		if #Players:GetPlayers() < MIN_PLAYERS then
			break
		end
		timerVal.Value = i
		task.wait(1)
	end
	if #Players:GetPlayers() >= MIN_PLAYERS then
		startRound()
		local t = ROUND_TIME
		local finished = false
		while t > 0 and state.Value == "Playing" do
			timerVal.Value = t
			task.wait(1)
			t -= 1
			if #activePlayers() == 0 then
				endRound(not anyoneEscaped())
				finished = true
				break
			end
		end
		if not finished and state.Value == "Playing" then
			endRound(false) -- время вышло: выжившие победили
		end
	end
end
