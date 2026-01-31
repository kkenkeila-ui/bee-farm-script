-- ============================================
-- 🐝 BEE SWARM SIMULATOR - ULTIMATE AUTO FARM
-- Created by [Ваше Имя]
-- ============================================

if not game:IsLoaded() then
    game.Loaded:Wait()
end

if game.PlaceId ~= 1537690962 then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Ошибка",
        Text = "Этот скрипт только для Bee Swarm Simulator!",
        Duration = 5
    })
    return
end

-- Подгружаем библиотеку для красивого интерфейса
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "🐝 Bee Farm Ultimate v3.0",
    LoadingTitle = "Загрузка...",
    LoadingSubtitle = "by Bee Master",
    ConfigurationSaving = {
       Enabled = true,
       FolderName = "BeeFarmConfig",
       FileName = "Config"
    },
    Discord = {
       Enabled = false,
       Invite = "noinvitelink",
       RememberJoins = true
    },
    KeySystem = false,
    KeySettings = {
       Title = "Введите ключ",
       Subtitle = "Key System",
       Note = "Ключ не требуется",
       FileName = "Key",
       SaveKey = true,
       GrabKeyFromSite = false,
       Key = {"Hello"}
    }
})

-- ===============================
-- ОСНОВНЫЕ ТАБЫ
-- ===============================

local MainTab = Window:CreateTab("🏠 Главная", 4483362458)
local AutoTab = Window:CreateTab("⚡ Авто-Фарм", 4483362458)
local TeleportTab = Window:CreateTab("📍 Телепорты", 4483362458)
local VisualTab = Window:CreateTab("👁 Визуалы", 4483362458)
local PlayerTab = Window:CreateTab("👤 Игрок", 4483362458)
local MiscTab = Window:CreateTab("⚙ Дополнительно", 4483362458)

-- ===============================
-- ПЕРЕМЕННЫЕ И НАСТРОЙКИ
-- ===============================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local RunService = game:GetService("RunService")

local Settings = {
    AutoFarm = false,
    FarmRange = 50,
    FarmSpeed = 0.5,
    AutoConvert = false,
    AutoBubble = false,
    AutoSprinkler = false,
    AutoWalk = false,
    ESP = false,
    NoClip = false,
    SpeedHack = false,
    JumpPower = false
}

local Connections = {}
local ESPObjects = {}

-- ===============================
-- ФУНКЦИИ
-- ===============================

function Notify(title, text, icon)
    Rayfield:Notify({
        Title = title,
        Content = text,
        Duration = 3,
        Image = icon or 4483362458
    })
end

function CollectFlowers()
    if not Settings.AutoFarm then return end
    
    local flowers = {}
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("Model") and (obj.Name:find("Flower") or obj.Name:find("Bush")) then
            local primary = obj.PrimaryPart or obj:FindFirstChild("Flower")
            if primary then
                local dist = (HumanoidRootPart.Position - primary.Position).Magnitude
                if dist <= Settings.FarmRange then
                    table.insert(flowers, {obj = obj, part = primary, dist = dist})
                end
            end
        end
    end
    
    table.sort(flowers, function(a, b) return a.dist < b.dist end)
    
    for _, flower in ipairs(flowers) do
        if not Settings.AutoFarm then break end
        
        local clickDetector = flower.obj:FindFirstChildOfClass("ClickDetector")
        if clickDetector then
            fireclickdetector(clickDetector)
        end
        
        if Settings.AutoWalk and flower.dist > 15 then
            local hum = Character:FindFirstChild("Humanoid")
            if hum then
                hum:MoveTo(flower.part.Position)
                task.wait(0.3)
            end
        end
        
        task.wait(Settings.FarmSpeed)
    end
end

function AutoConvertToHoney()
    while Settings.AutoConvert do
        task.wait(5)
        game:GetService("VirtualInputManager"):SendKeyEvent(true, "E", false, game)
        task.wait(0.1)
        game:GetService("VirtualInputManager"):SendKeyEvent(false, "E", false, game)
    end
end

function ToggleESP()
    for _, obj in pairs(ESPObjects) do
        if obj then
            obj:Remove()
        end
    end
    ESPObjects = {}
    
    if not Settings.ESP then return end
    
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("Model") and obj.Name:find("Flower") then
            local part = obj.PrimaryPart
            if part then
                local billboard = Instance.new("BillboardGui")
                local text = Instance.new("TextLabel")
                
                billboard.Name = "FlowerESP"
                billboard.Adornee = part
                billboard.Size = UDim2.new(0, 100, 0, 40)
                billboard.StudsOffset = Vector3.new(0, 3, 0)
                billboard.AlwaysOnTop = true
                billboard.MaxDistance = 200
                
                text.Size = UDim2.new(1, 0, 1, 0)
                text.BackgroundTransparency = 1
                text.Text = "🌸 Flower"
                text.TextColor3 = Color3.fromRGB(255, 182, 193)
                text.TextSize = 16
                text.Font = Enum.Font.GothamBold
                
                text.Parent = billboard
                billboard.Parent = part
                
                ESPObjects[obj] = billboard
            end
        end
    end
end

function TeleportTo(position)
    if Character and Character:FindFirstChild("HumanoidRootPart") then
        Character.HumanoidRootPart.CFrame = CFrame.new(position)
        Notify("Телепорт", "Успешно телепортирован!")
    end
end

-- ===============================
-- ИНТЕРФЕЙС - ГЛАВНАЯ ВКЛАДКА
-- ===============================

local MainSection = MainTab:CreateSection("Информация")

MainTab:CreateLabel("Добро пожаловать в Bee Farm Ultimate!")
MainTab:CreateLabel("Версия: 3.0 | Автор: Ваше Имя")
MainTab:CreateLabel("Статус: ✅ Работает")
MainTab:CreateLabel("Игрок: " .. LocalPlayer.Name)

local StatsSection = MainTab:CreateSection("Статистика")

local PollenLabel = MainTab:CreateLabel("Пыльца: Загрузка...")
local HoneyLabel = MainTab:CreateLabel("Мед: Загрузка...")
local BeesLabel = MainTab:CreateLabel("Пчелы: Загрузка...")

-- Обновление статистики
spawn(function()
    while task.wait(2) do
        -- Здесь можно добавить получение реальной статистики
        PollenLabel:Set("Пыльца: N/A")
        HoneyLabel:Set("Мед: N/A")
        BeesLabel:Set("Пчелы: N/A")
    end
end)

-- ===============================
-- ИНТЕРФЕЙС - АВТО-ФАРМ
-- ===============================

local FarmSection = AutoTab:CreateSection("Авто-Фарм")

local AutoFarmToggle = AutoTab:CreateToggle({
    Name = "Авто-Сбор Пыльцы",
    CurrentValue = false,
    Flag = "AutoFarmToggle",
    Callback = function(Value)
        Settings.AutoFarm = Value
        if Value then
            Notify("Авто-Фарм", "✅ Включен")
            while Settings.AutoFarm do
                CollectFlowers()
                task.wait()
            end
        else
            Notify("Авто-Фарм", "❌ Выключен")
        end
    end,
})

AutoTab:CreateSlider({
    Name = "Дистанция сбора",
    Range = {10, 100},
    Increment = 5,
    Suffix = "studs",
    CurrentValue = 50,
    Flag = "FarmRangeSlider",
    Callback = function(Value)
        Settings.FarmRange = Value
    end
})

AutoTab:CreateSlider({
    Name = "Скорость сбора",
    Range = {0.1, 2},
    Increment = 0.1,
    Suffix = "сек",
    CurrentValue = 0.5,
    Flag = "FarmSpeedSlider",
    Callback = function(Value)
        Settings.FarmSpeed = Value
    end
})

local ActionsSection = AutoTab:CreateSection("Авто-Действия")

AutoTab:CreateToggle({
    Name = "Авто-Конвертация в Мед",
    CurrentValue = false,
    Flag = "AutoConvertToggle",
    Callback = function(Value)
        Settings.AutoConvert = Value
        if Value then
            spawn(AutoConvertToHoney)
            Notify("Авто-Конвертация", "✅ Включена")
        end
    end,
})

AutoTab:CreateToggle({
    Name = "Авто-Пузыри",
    CurrentValue = false,
    Flag = "AutoBubbleToggle",
    Callback = function(Value)
        Settings.AutoBubble = Value
        if Value then
            Notify("Авто-Пузыри", "✅ Включены")
        end
    end,
})

AutoTab:CreateToggle({
    Name = "Авто-Ходьба к цветам",
    CurrentValue = false,
    Flag = "AutoWalkToggle",
    Callback = function(Value)
        Settings.AutoWalk = Value
    end,
})

-- ===============================
-- ИНТЕРФЕЙС - ТЕЛЕПОРТЫ
-- ===============================

local FieldSection = TeleportTab:CreateSection("Поля")

local fields = {
    ["🌻 Подсолнуховое поле"] = Vector3.new(-100, 4, -200),
    ["🌼 Одуванчиковое поле"] = Vector3.new(50, 4, -150),
    ["🌹 Розовое поле"] = Vector3.new(-200, 4, 50),
    ["🔵 Голубое поле"] = Vector3.new(150, 4, 100),
    ["🍯 Улей"] = Vector3.new(0, 10, 0),
    ["⛰ Гора"] = Vector3.new(0, 100, 300)
}

for name, position in pairs(fields) do
    TeleportTab:CreateButton({
        Name = name,
        Callback = function()
            TeleportTo(position)
        end,
    })
end

local BossSection = TeleportTab:CreateSection("Боссы")

TeleportTab:CreateButton({
    Name = "🐝 Пчелиная Королева",
    Callback = function()
        TeleportTo(Vector3.new(-300, 50, -300))
    end,
})

TeleportTab:CreateButton({
    Name = "🐻 Медвежонок",
    Callback = function()
        TeleportTo(Vector3.new(300, 10, 200))
    end,
})

-- ===============================
-- ИНТЕРФЕЙС - ВИЗУАЛЫ
-- ===============================

local VisualSection = VisualTab:CreateSection("ESP")

VisualTab:CreateToggle({
    Name = "ESP Цветков",
    CurrentValue = false,
    Flag = "ESPToggle",
    Callback = function(Value)
        Settings.ESP = Value
        ToggleESP()
        if Value then
            Notify("ESP", "✅ Включен")
        else
            Notify("ESP", "❌ Выключен")
        end
    end,
})

VisualTab:CreateToggle({
    Name = "ESP Игроков",
    CurrentValue = false,
    Flag = "PlayerESPToggle",
    Callback = function(Value)
        -- Код для ESP игроков
    end,
})

local EffectsSection = VisualTab:CreateSection("Эффекты")

VisualTab:CreateColorPicker({
    Name = "Цвет ESP",
    Color = Color3.fromRGB(255, 182, 193),
    Flag = "ESPColorPicker",
    Callback = function(Value)
        -- Изменить цвет ESP
    end
})

-- ===============================
-- ИНТЕРФЕЙС - ИГРОК
-- ===============================

local MovementSection = PlayerTab:CreateSection("Передвижение")

PlayerTab:CreateToggle({
    Name = "Спидхак",
    CurrentValue = false,
    Flag = "SpeedToggle",
    Callback = function(Value)
        Settings.SpeedHack = Value
        if Value then
            local hum = Character:FindFirstChild("Humanoid")
            if hum then
                hum.WalkSpeed = 50
            end
            Notify("Спидхак", "✅ Включен")
        else
            local hum = Character:FindFirstChild("Humanoid")
            if hum then
                hum.WalkSpeed = 16
            end
            Notify("Спидхак", "❌ Выключен")
        end
    end,
})

PlayerTab:CreateSlider({
    Name = "Скорость ходьбы",
    Range = {16, 200},
    Increment = 5,
    Suffix = "speed",
    CurrentValue = 16,
    Flag = "WalkSpeedSlider",
    Callback = function(Value)
        if Character:FindFirstChild("Humanoid") then
            Character.Humanoid.WalkSpeed = Value
        end
    end
})

PlayerTab:CreateSlider({
    Name = "Сила прыжка",
    Range = {50, 200},
    Increment = 10,
    Suffix = "power",
    CurrentValue = 50,
    Flag = "JumpPowerSlider",
    Callback = function(Value)
        if Character:FindFirstChild("Humanoid") then
            Character.Humanoid.JumpPower = Value
        end
    end
})

PlayerTab:CreateToggle({
    Name = "Ноклип",
    CurrentValue = false,
    Flag = "NoClipToggle",
    Callback = function(Value)
        Settings.NoClip = Value
        if Value then
            Notify("Ноклип", "✅ Включен")
        else
            Notify("Ноклип", "❌ Выключен")
        end
    end,
})

-- ===============================
-- ИНТЕРФЕЙС - ДОПОЛНИТЕЛЬНО
-- ===============================

local UtilitySection = MiscTab:CreateSection("Утилиты")

MiscTab:CreateButton({
    Name = "🔄 Перезагрузить персонажа",
    Callback = function()
        local char = LocalPlayer.Character
        if char then
            char:BreakJoints()
        end
    end,
})

MiscTab:CreateButton({
    Name = "🔗 Сменить сервер",
    Callback = function()
        local TeleportService = game:GetService("TeleportService")
        local HttpService = game:GetService("HttpService")
        
        local servers = HttpService:JSONDecode(game:HttpGet(
            "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        ))
        
        for _, server in pairs(servers.data) do
            if server.playing < server.maxPlayers then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id)
                break
            end
        end
    end,
})

MiscTab:CreateButton({
    Name = "🎮 Anti-AFK",
    Callback = function()
        local vu = game:GetService("VirtualUser")
        game:GetService("Players").LocalPlayer.Idled:connect(function()
            vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            wait(1)
            vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end)
        Notify("Anti-AFK", "✅ Активирован")
    end,
})

local ConfigSection = MiscTab:CreateSection("Настройки")

MiscTab:CreateKeybind({
    Name = "Открыть/Закрыть меню",
    CurrentKeybind = "RightControl",
    HoldToInteract = false,
    Flag = "MenuKeybind",
    Callback = function(Keybind)
        -- Rayfield сам обрабатывает
    end,
})

MiscTab:CreateButton({
    Name = "📋 Копировать Discord",
    Callback = function()
        setclipboard("discord.gg/example")
        Notify("Discord", "Ссылка скопирована в буфер!")
    end,
})

MiscTab:CreateButton({
    Name = "📋 Копировать ключ",
    Callback = function()
        setclipboard("BEEFARM2024")
        Notify("Ключ", "Ключ скопирован в буфер!")
    end,
})

-- ===============================
-- АВТО-ОБНОВЛЕНИЕ ESP
-- ===============================

spawn(function()
    while task.wait(2) do
        if Settings.ESP then
            ToggleESP()
        end
    end
end)

-- Ноклип
spawn(function()
    while task.wait(0.1) do
        if Settings.NoClip and Character then
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- ===============================
-- ЗАГРУЗКА И УВЕДОМЛЕНИЕ
-- ===============================

Notify("Bee Farm Ultimate", "✅ Скрипт успешно загружен!", 4483362458)
Notify("Управление", "Нажмите RightControl для открытия меню", 4483362458)

print([[
=====================================
🐝 Bee Farm Ultimate v3.0 загружен!
👤 Игрок: ]] .. LocalPlayer.Name .. [[
⏰ Время: ]] .. os.date("%H:%M:%S") .. [[
=====================================
]])
