-- Setup (положить в ServerScriptService как обычный Script)
-- Создаёт общие значения и события. Нужен, чтобы остальные скрипты работали.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function ensure(className, name, defaultValue)
	local obj = ReplicatedStorage:FindFirstChild(name)
	if not obj then
		obj = Instance.new(className)
		obj.Name = name
		if className == "StringValue" then
			obj.Value = defaultValue or ""
		elseif className == "IntValue" then
			obj.Value = defaultValue or 0
		end
		obj.Parent = ReplicatedStorage
	end
	return obj
end

ensure("StringValue", "GameState", "Lobby") -- "Lobby" | "Playing" | "End"
ensure("IntValue", "GameTimer", 0)
ensure("RemoteEvent", "NotifyEvent") -- сообщения игрокам (текст)
ensure("RemoteEvent", "CatchEvent") -- скример пойманному игроку
