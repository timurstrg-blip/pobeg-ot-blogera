# Побег от Блогера — Roblox-версия

Хоррор-побег для Roblox: блогер-монстр гоняется за игроками через Pathfinding,
игроки собирают 5 лайков, открывают выход и сбегают. Раунды, таймер, стамина-рывок, скример.

## Шаг 0. Roblox Studio

1. Установи **Roblox Studio** (create.roblox.com → Start Creating).
2. Войди в свой аккаунт, создай **New → Baseplate**.

## Шаг 1. Скрипты — куда класть

| Файл | Куда в Studio |
|---|---|
| `Setup.server.lua` | `ServerScriptService` (правой кнопкой → Insert Object → Script, вставить код) |
| `GameManager.server.lua` | `ServerScriptService` → Script |
| `Likes.server.lua` | `ServerScriptService` → Script |
| `Blogger.server.lua` | **внутрь модели монстра** в `ServerStorage` (см. шаг 3) → Script |
| `ExitDoor.server.lua` | **внутрь модели `ExitDoor`** в `Workspace` (см. шаг 2) → Script |
| `Stamina.client.lua` | `StarterPlayer → StarterCharacterScripts` → **LocalScript** |
| `Effects.client.lua` | `StarterPlayer → StarterPlayerScripts` → **LocalScript** |

Как вставить: выбери место в окне Explorer → `+` → Script (сервер) или LocalScript (клиент) →
в открывшемся редакторе сотри шаблон и вставь код из файла.

## Шаг 2. Карта (точные имена важны!)

1. **LobbySpawn** — вкладка Home → Spawn. Назови `LobbySpawn`, в Properties поставь
   `Neutral = true`. Это единственная SpawnLocation на карте.
2. **PlayerSpawns** — Insert → Folder, назови `PlayerSpawns`. Внутрь добавь 6 Parts
   (Anchored = true, Transparency = 1, CanCollide = false), расставь по карте.
3. **LikeSpawns** — Folder `LikeSpawns` + 8–10 таких же невидимых Parts.
4. **ExitDoor** — Model с именем `ExitDoor`:
   - Part `Door` (размер ~8×10×1, красный);
   - Part `PromptPart` (Transparency = 1, CanCollide = false) рядом;
   - внутрь `PromptPart`: Insert → `ProximityPrompt`,
     `ActionText = "Сбежать"`, `MaxActivationDistance = 12`,
     `RequiresLineOfSight = false`, `HoldDuration = 1`;
   - скрипт `ExitDoor.server.lua` внутрь модели.
5. **WinPad** — Part (зелёный, Material = Neon) за дверью — зона побега.
6. **WinSpawn** — невидимый Part рядом — куда телепортирует сбежавших.
7. Стены, укрытия, декор — по вкусу. Проход для монстра везде шириной от 4.

## Шаг 3. Монстр и лайк

**Блогер:**
1. Вкладка Plugins → **Rig Builder** → R15 → Spawn.
2. Модель переименуй в `Blogger`, перетащи в `ServerStorage`.
3. Внутрь модели добавь Part `CatchZone`: Size (7,7,7), Transparency = 1,
   CanCollide = false, Massless = true.
4. Insert → `WeldConstraint`: Part0 = CatchZone, Part1 = HumanoidRootPart.
5. Внутрь модели вставь Script с кодом `Blogger.server.lua`.
6. Внешность — по желанию (Shirt, Pants, страшное лицо на Head).

**Лайк:**
1. Part в `ServerStorage` с именем `LikePickup`: Size (3,3,3), цвет розовый, Material = Neon.
2. Внутрь: Insert → `BillboardGui` (Size X=4, Y=4, AlwaysOnTop = true) →
   внутрь TextLabel с текстом сердечка, TextSize = 60.
3. По желанию: Insert → Sound (свой звук подбора из Toolbox).

## Шаг 4. Тест

Нажми **Play (F5)**. Для теста с погоней: вкладка Test → Clients and Servers →
Players = 2 → Start. Вторым игроком управляй в отдельном окне.

Если в Output красное предупреждение `GameManager: в Workspace нет ...` —
значит, объект с таким именем не создан (шаг 2).

## Шаг 5. Публикация и ссылка

1. File → **Publish to Roblox As…** → название → Create.
2. На сайте: create.roblox.com → Experiences → твоя игра → **Audience → Public → Save**.
3. Ссылка на игру будет вида `roblox.com/games/ТВОЙ-ID/название` — её и давай друзьям.

## Настройки

- Длительность раунда / ожидание: начало `GameManager.server.lua`.
- Число лайков для выхода: `REQUIRED_LIKES` в `ExitDoor.server.lua`
  (и текст сообщения в `GameManager.server.lua`).
- Скорость монстра: `BASE_SPEED` / `MAX_SPEED` в `Blogger.server.lua`.
- Звук скримера: вставь свой SoundId из Toolbox в `Effects.client.lua`.
