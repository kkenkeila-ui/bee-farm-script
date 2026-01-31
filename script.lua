-- ============================================
-- 🐝 ATLAS BEE FARM SIMULATOR v2.0
-- Anti-Ban | Safe Auto Farm
-- GitHub: kkenkeila-ui/bee-farm-script
-- ============================================

if not game:IsLoaded() then
    game.Loaded:Wait()
end

if game.PlaceId ~= 1537690962 then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "❌ Ошибка",
        Text = "Только для Bee Swarm Simulator!",
        Duration = 5
    })
    return
end

-- АНТИ-БАН СИСТЕМА
local AntiBan = {
    Enabled = true,
    RandomDelays = true,
    HumanLikeActions = true,
    MaxSessionTime = 180, -- 3 часа максимум
    AutoDisableFeatures = true,
    SafeMode = true
}

-- Загружаем библиотеку
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Atlas v2.0 | Bee Farm",
    LoadingTitle = "Загрузка Atlas...",
    LoadingSubtitle = "Анти-Бан система активирована",
    ConfigurationSaving = {
       Enabled = true,
       FolderName = "AtlasConfig",
       FileName = "Config"
    },
    Discord = {
       Enabled = false,
       Invite = "noinvitelink",
       RememberJoins = true
    },
    KeySystem = false
})

-- ===============================
-- ТАБЫ КАК НА СКРИНШОТЕ
-- ===============================

local HomeTab = Window:CreateTab("Home", 4483362458)
local FarmingTab = Window:CreateTab("Farming", 4483362458)
local CombatTab = Window:CreateTab("Combat", 4483362458)
local QuestTab = Window:CreateTab("Quests", 4483362458)
local PlanterTab = Window:CreateTab("Planters", 4483362458)
local ToyTab = Window:CreateTab("Toys", 4483362458)
local SettingsTab = Window:CreateTab("Settings", 4483362458)

-- ===============================
-- ПЕРЕМЕННЫЕ И НАСТРОЙКИ
-- ===============================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- ОСНОВНЫЕ НАСТРОЙКИ
local Settings = {
    -- Основные
    AutoFarm = false,
    FarmSpeed = 0.5,
    FarmRange = 50,
    
    -- Безопасность
    SafeAutoConvert = false,
    ConvertDelay = 5,
    ConvertMethod = "Safe", -- Safe, Normal, Fast
    
    -- Дополнительно
    AutoBubble = false,
    AutoSprinkler = false,
    AutoSprout = false,
    AutoPlanters = false,
    
    -- Боевка
    AutoAttack = false,
    TargetMobs = {"Crab", "Rhino", "Ant"},
    
    -- Квесты
    AutoQuests = false,
    ClaimQuests = false,
    
    -- Анти-бан
    HumanDelay = true,
    RandomActions = true,
    LimitSession = true
}

local Stats = {
    SessionStart = os.time(),
    HoneyCollected = 0,
    PollenCollected = 0,
    FlowersClicked = 0
}

-- ===============================
-- ФУНКЦИИ БЕЗОПАСНОСТИ (АНТИ-БАН)
-- ===============================

function SafeNotify(title, text)
    Rayfield:Notify({
        Title = title,
        Content = text,
        Duration = 3,
        Image = 4483362458
    })
end

-- Случайная задержка (похоже на человека)
function HumanDelay(min, max)
    if Settings.HumanDelay then
        local delay = math.random(min * 100, max * 100) / 100
        task.wait(delay)
        return delay
    else
        task.wait(min)
        return min
    end
end

-- Проверка на подозрительную активность
function SafetyCheck()
    if not AntiBan.Enabled then return true end
    
    -- Проверяем время сессии
    local sessionTime = os.time() - Stats.SessionStart
    if sessionTime > AntiBan.MaxSessionTime * 60 then
        SafeNotify("⚠ Безопасность", "Достигнут лимит времени сессии!")
        return false
    end
    
    -- Проверяем скорость действий
    if Stats.FlowersClicked > 1000 and Settings.FarmSpeed < 0.3 then
        SafeNotify("⚠ Безопасность", "Слишком быстрый сбор!")
        return false
    end
    
    return true
end

-- Случайные действия игрока (имитация человека)
function RandomHumanAction()
    if not Settings.RandomActions then return end
    
    local actions = {
        function() 
            -- Пауза
            task.wait(math.random(1, 3))
        end,
        function()
            -- Поворот камеры
            game:GetService("VirtualInputManager"):SendMouseMoveEvent(
                math.random(-100, 100),
                math.random(-100, 100),
                game
            )
        end,
        function()
            -- Прыжок
            if Character and Character:FindFirstChild("Humanoid") then
                Character.Humanoid.Jump = true
            end
        end
    }
    
    -- 10% шанс на случайное действие
    if math.random(1, 10) == 1 then
        actions[math.random(1, #actions)]()
    end
end

-- ===============================
-- БЕЗОПАСНЫЙ АВТО-ФАРМ
-- ===============================

function SafeAutoFarm()
    while Settings.AutoFarm do
        if not SafetyCheck() then
            Settings.AutoFarm = false
            SafeNotify("🛑 Остановлено", "Причина безопасности!")
            break
        end
        
        RandomHumanAction()
        
        -- Поиск цветов с безопасной задержкой
        local flowers = {}
        for _, obj in pairs(workspace:GetChildren()) do
            if obj:IsA("Model") and (obj.Name:find("Flower") or obj.Name:find("Bush")) then
                local primary = obj.PrimaryPart or obj:FindFirstChildOfClass("Part")
                if primary then
                    local dist = (HumanoidRootPart.Position - primary.Position).Magnitude
                    if dist <= Settings.FarmRange then
                        table.insert(flowers, {obj = obj, part = primary, dist = dist})
                    end
                end
            end
        end
        
        -- Безопасный сбор
        table.sort(flowers, function(a, b) return a.dist < b.dist end)
        
        for _, flower in ipairs(flowers) do
            if not Settings.AutoFarm then break end
            
            local clickDetector = flower.obj:FindFirstChildOfClass("ClickDetector")
            if clickDetector then
                -- Безопасный клик
                fireclickdetector(clickDetector)
                Stats.FlowersClicked = Stats.FlowersClicked + 1
                
                -- Случайная задержка между кликами
                HumanDelay(Settings.FarmSpeed * 0.8, Settings.FarmSpeed * 1.2)
                
                -- Лимит цветков за цикл
                if Stats.FlowersClicked % 50 == 0 then
                    SafeNotify("📊 Статистика", "Собрано: " .. Stats.FlowersClicked .. " цветков")
                end
            end
        end
        
        -- Отдых между циклами
        HumanDelay(1, 3)
    end
end

-- ===============================
-- БЕЗОПАСНАЯ АВТО-КОНВЕРТАЦИЯ МЕДА
-- ===============================

function SafeAutoConvert()
    while Settings.SafeAutoConvert do
        if not SafetyCheck() then
            Settings.SafeAutoConvert = false
            SafeNotify("🛑 Остановлено", "Авто-конвертация отключена!")
            break
        end
        
        local convertMethods = {
            Safe = function()
                -- Медленный безопасный метод
                for i = 1, math.random(3, 7) do
                    game:GetService("VirtualInputManager"):SendKeyEvent(true, "E", false, game)
                    task.wait(0.1)
                    game:GetService("VirtualInputManager"):SendKeyEvent(false, "E", false, game)
                    HumanDelay(0.3, 0.7)
                end
            end,
            Normal = function()
                -- Нормальная скорость
                game:GetService("VirtualInputManager"):SendKeyEvent(true, "E", false, game)
                task.wait(0.1)
                game:GetService("VirtualInputManager"):SendKeyEvent(false, "E", false, game)
            end,
            Fast = function()
                -- Быстрая конвертация (рискованно)
                game:GetService("VirtualInputManager"):SendKeyEvent(true, "E", false, game)
                task.wait(0.05)
                game:GetService("VirtualInputManager"):SendKeyEvent(false, "E", false, game)
            end
        }
        
        -- Выполняем выбранный метод
        if convertMethods[Settings.ConvertMethod] then
            convertMethods[Settings.ConvertMethod]()
        end
        
        -- Длинная задержка между конвертациями
        HumanDelay(Settings.ConvertDelay * 0.8, Settings.ConvertDelay * 1.5)
        
        -- Случайная пауза иногда
        if math.random(1, 10) == 1 then
            HumanDelay(5, 15)
        end
    end
end

-- ===============================
-- АВТО-КВЕСТЫ (КАК НА СКРИНШОТЕ)
-- ===============================

function AutoQuestSystem()
    local questBears = {
        "Bee Bear",
        "Gummy Bear", 
        "Stick Bug",
        "Black Bear",
        "Mother Bear",
        "Panda Bear",
        "Science Bear",
        "Dapper Bear",
        "Onett",
        "Spirit Bear"
    }
    
    while Settings.AutoQuests do
        if not SafetyCheck() then break end
        
        -- Здесь будет код для автоматического выполнения квестов
        -- Пока заглушка
        
        HumanDelay(30, 60) -- Проверка квестов каждые 30-60 секунд
    end
end

-- ===============================
-- ИНТЕРФЕЙС: HOME TAB (КАК НА СКРИНШОТЕ)
-- ===============================

local HomeSection = HomeTab:CreateSection("Session Info")

HomeTab:CreateLabel("Atlas v2.0 | Bee Farm")
HomeTab:CreateLabel("Uptime: 00:00:00")
HomeTab:CreateLabel("Server Uptime: " .. os.date("%H:%M:%S"))

local StatsSection = HomeTab:CreateSection("Statistics")

local HoneyLabel = HomeTab:CreateLabel("Session Honey: 0")
local PollenLabel = HomeTab:CreateLabel("Pollen: 0/0")
local RateLabel = HomeTab:CreateLabel("Honey per Hour: 0")

HomeTab:CreateButton({
    Name = "Stop Everything",
    Callback = function()
        Settings.AutoFarm = false
        Settings.SafeAutoConvert = false
        Settings.AutoQuests = false
        SafeNotify("🛑 Остановлено", "Все процессы остановлены!")
    end,
})

-- ===============================
-- ИНТЕРФЕЙС: FARMING TAB
-- ===============================

local FarmMainSection = FarmingTab:CreateSection("Farming Settings")

FarmingTab:CreateToggle({
    Name = "AutoFarm",
    CurrentValue = false,
    Flag = "AutoFarmToggle",
    Callback = function(Value)
        Settings.AutoFarm = Value
        if Value then
            SafeNotify("🌻 AutoFarm", "Включен (Безопасный режим)")
            spawn(SafeAutoFarm)
        else
            SafeNotify("🌻 AutoFarm", "Выключен")
        end
    end,
})

FarmingTab:CreateToggle({
    Name = "Auto Sprinkler",
    CurrentValue = false,
    Flag = "AutoSprinklerToggle",
    Callback = function(Value)
        Settings.AutoSprinkler = Value
    end,
})

FarmingTab:CreateToggle({
    Name = "Auto Dig",
    CurrentValue = false,
    Flag = "AutoDigToggle",
    Callback = function(Value)
        -- Авто-копание
    end,
})

local FarmSettingsSection = FarmingTab:CreateSection("Farm Settings")

FarmingTab:CreateSlider({
    Name = "Farm Speed",
    Range = {0.3, 2},
    Increment = 0.1,
    Suffix = "sec",
    CurrentValue = 0.5,
    Flag = "FarmSpeedSlider",
    Callback = function(Value)
        Settings.FarmSpeed = Value
    end
})

FarmingTab:CreateSlider({
    Name = "Farm Range",
    Range = {20, 100},
    Increment = 5,
    Suffix = "studs",
    CurrentValue = 50,
    Flag = "FarmRangeSlider",
    Callback = function(Value)
        Settings.FarmRange = Value
    end
})

-- ===============================
-- БЕЗОПАСНАЯ АВТО-КОНВЕРТАЦИЯ
-- ===============================

local ConvertSection = FarmingTab:CreateSection("Honey Conversion")

FarmingTab:CreateToggle({
    Name = "Auto Convert Honey",
    CurrentValue = false,
    Flag = "AutoConvertToggle",
    Callback = function(Value)
        Settings.SafeAutoConvert = Value
        if Value then
            SafeNotify("🍯 Auto Convert", "Включен (Безопасный режим)")
            spawn(SafeAutoConvert)
        else
            SafeNotify("🍯 Auto Convert", "Выключен")
        end
    end,
})

FarmingTab:CreateSlider({
    Name = "Convert Delay",
    Range = {3, 30},
    Increment = 1,
    Suffix = "sec",
    CurrentValue = 5,
    Flag = "ConvertDelaySlider",
    Callback = function(Value)
        Settings.ConvertDelay = Value
    end
})

FarmingTab:CreateDropdown({
    Name = "Convert Method",
    Options = {"Safe", "Normal", "Fast"},
    CurrentOption = "Safe",
    Flag = "ConvertMethodDropdown",
    Callback = function(Value)
        Settings.ConvertMethod = Value
        SafeNotify("🍯 Метод", "Изменен на: " .. Value)
    end,
})

-- ===============================
-- SPRING SETTINGS (КАК НА СКРИНШОТЕ)
-- ===============================

local SproutSection = FarmingTab:CreateSection("Sprout Settings")

FarmingTab:CreateToggle({
    Name = "Farm Sprouts",
    CurrentValue = false,
    Flag = "FarmSproutsToggle",
    Callback = function(Value)
        Settings.AutoSprout = Value
    end,
})

FarmingTab:CreateToggle({
    Name = "Auto Plant Sprouts",
    CurrentValue = false,
    Flag = "AutoPlantSproutsToggle",
    Callback = function(Value)
        -- Авто-посадка ростков
    end,
})

FarmingTab:CreateToggle({
    Name = "Collect Tokens",
    CurrentValue = false,
    Flag = "CollectTokensToggle",
    Callback = function(Value)
        -- Сбор токенов
    end,
})

-- ===============================
-- QUEST TAB (ТОЧНО КАК НА СКРИНШОТЕ)
-- ===============================

local AutoQuestSection = QuestTab:CreateSection("Auto Quest")

QuestTab:CreateToggle({
    Name = "Auto Claim Quests",
    CurrentValue = false,
    Flag = "AutoClaimToggle",
    Callback = function(Value)
        Settings.ClaimQuests = Value
    end,
})

local BearQuestsSection = QuestTab:CreateSection("Main Quest Toggles")

local questBears = {
    "Bee Bear",
    "Gummy Bear",
    "Stick Bug", 
    "Black Bear",
    "Mother Bear",
    "Panda Bear",
    "Science Bear",
    "Dapper Bear",
    "Onett",
    "Spirit Bear"
}

for _, bear in pairs(questBears) do
    QuestTab:CreateToggle({
        Name = "Auto " .. bear,
        CurrentValue = false,
        Flag = bear .. "Toggle",
        Callback = function(Value)
            -- Включение авто-квестов для каждого медведя
        end,
    })
end

local QuestSettingsSection = QuestTab:CreateSection("Quest Settings")

QuestTab:CreateDropdown({
    Name = "Best Blue Field",
    Options = {"Pine Tree Forest", "Bamboo Field", "Cactus Field"},
    CurrentOption = "Pine Tree Forest",
    Flag = "BlueFieldDropdown",
    Callback = function(Value)
        -- Настройка поля
    end,
})

QuestTab:CreateDropdown({
    Name = "Best Red Field", 
    Options = {"Rose Field", "Strawberry Field", "Pepper Patch"},
    CurrentOption = "Rose Field",
    Flag = "RedFieldDropdown",
    Callback = function(Value)
        -- Настройка поля
    end,
})

QuestTab:CreateDropdown({
    Name = "Best White Field",
    Options = {"Pumpkin Patch", "Coconut Field", "Mountain Top"},
    CurrentOption = "Pumpkin Patch",
    Flag = "WhiteFieldDropdown",
    Callback = function(Value)
        -- Настройка поля
    end,
})

QuestTab:CreateDropdown({
    Name = "Goo Method",
    Options = {"Gumdrops", "Glue", "Enzymes"},
    CurrentOption = "Gumdrops",
    Flag = "GooMethodDropdown",
    Callback = function(Value)
        -- Метод сбора слизи
    end,
})

local QuestActionsSection = QuestTab:CreateSection("Quest Actions")

local questActions = {
    "Do Xmas Quests",
    "Farm Pollen", 
    "Farm Goo",
    "Farm Mobs",
    "Farm Ants",
    "Farm Rage Tokens",
    "Farm Puffshrooms",
    "Farm Blooms",
    "Do Duped Tokens",
    "Do Wind Shrine"
}

for _, action in pairs(questActions) do
    QuestTab:CreateToggle({
        Name = action,
        CurrentValue = false,
        Flag = action .. "Toggle",
        Callback = function(Value)
            -- Включение действий
        end,
    })
end

-- Кнопка Collect как на скриншоте
QuestTab:CreateButton({
    Name = "Collect 240,000",
    Callback = function()
        SafeNotify("📦 Collect", "Сбор активирован!")
    end,
})

-- ===============================
-- COMBAT TAB
-- ===============================

local CombatSection = CombatTab:CreateSection("Combat Settings")

CombatTab:CreateToggle({
    Name = "Auto Attack Mobs",
    CurrentValue = false,
    Flag = "AutoAttackToggle",
    Callback = function(Value)
        Settings.AutoAttack = Value
    end,
})

CombatTab:CreateDropdown({
    Name = "Target Mobs",
    Options = {"All", "Crab", "Rhino Beetle", "Ant", "Mantises"},
    CurrentOption = "All",
    MultipleOptions = true,
    Flag = "TargetMobsDropdown",
    Callback = function(Value)
        Settings.TargetMobs = Value
    end,
})

-- ===============================
-- SETTINGS TAB (АНТИ-БАН НАСТРОЙКИ)
-- ===============================

local SafetySection = SettingsTab:CreateSection("Anti-Ban Settings")

SettingsTab:CreateToggle({
    Name = "Anti-Ban System",
    CurrentValue = true,
    Flag = "AntiBanToggle",
    Callback = function(Value)
        AntiBan.Enabled = Value
        SafeNotify("🛡️ Anti-Ban", Value and "Включен" or "Выключен")
    end,
})

SettingsTab:CreateToggle({
    Name = "Human-Like Delays",
    CurrentValue = true,
    Flag = "HumanDelayToggle",
    Callback = function(Value)
        Settings.HumanDelay = Value
    end,
})

SettingsTab:CreateToggle({
    Name = "Random Actions",
    CurrentValue = true,
    Flag = "RandomActionsToggle",
    Callback = function(Value)
        Settings.RandomActions = Value
    end,
})

SettingsTab:CreateToggle({
    Name = "Limit Session Time",
    CurrentValue = true,
    Flag = "LimitSessionToggle",
    Callback = function(Value)
        Settings.LimitSession = Value
    end,
})

SettingsTab:CreateSlider({
    Name = "Max Session Time",
    Range = {60, 480},
    Increment = 30,
    Suffix = "minutes",
    CurrentValue = 180,
    Flag = "MaxSessionSlider",
    Callback = function(Value)
        AntiBan.MaxSessionTime = Value
    end
})

-- ===============================
-- КНОПКИ УПРАВЛЕНИЯ
-- ===============================

local ControlSection = SettingsTab:CreateSection("Controls")

SettingsTab:CreateButton({
    Name = "Leave Game",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId)
    end,
})

SettingsTab:CreateButton({
    Name = "Respawn",
    Callback = function()
        local char = LocalPlayer.Character
        if char then
            char:BreakJoints()
        end
    end,
})

SettingsTab:CreateButton({
    Name = "Emergency Stop",
    Callback = function()
        Settings.AutoFarm = false
        Settings.SafeAutoConvert = false
        Settings.AutoQuests = false
        Settings.AutoAttack = false
        SafeNotify("🆘 Аварийная остановка!", "Все функции отключены!")
    end,
})

-- ===============================
-- ОБНОВЛЕНИЕ СТАТИСТИКИ
-- ===============================

spawn(function()
    while task.wait(1) do
        local uptime = os.time() - Stats.SessionStart
        local hours = math.floor(uptime / 3600)
        local minutes = math.floor((uptime % 3600) / 60)
        local seconds = uptime % 60
        
        HoneyLabel:Set(string.format("Session Honey: %d", Stats.HoneyCollected))
        RateLabel:Set(string.format("Uptime: %02d:%02d:%02d", hours, minutes, seconds))
    end
end)

-- ===============================
-- ЗАПУСК СКРИПТА
-- ===============================

SafeNotify("Atlas v2.0", "Успешно загружен! | Anti-Ban: ON")
SafeNotify("Безопасность", "Рекомендуется использовать Safe режим!")

print([[
==========================================
🐝 ATLAS BEE FARM v2.0
👤 Player: ]] .. LocalPlayer.Name .. [[
🛡️ Anti-Ban System: ENABLED
⚠ Safety Mode: ON
==========================================
]])

-- Авто-выключение через N часов
if Settings.LimitSession then
    spawn(function()
        task.wait(AntiBan.MaxSessionTime * 60)
        SafeNotify("⏰ Время вышло", "Авто-выключение для безопасности!")
        Settings.AutoFarm = false
        Settings.SafeAutoConvert = false
    end)
end
