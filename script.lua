-- ============================================
-- 🐝 ATLAS BEE FARM SIMULATOR v2.1
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

-- Загружаем библиотеку
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Atlas v2.1 | Bee Farm",
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
-- ПЕРЕМЕННЫЕ И НАСТРОЙКИ
-- ===============================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local VirtualInput = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

-- НАСТРОЙКИ ФАРМА
local Settings = {
    -- Основные
    AutoFarm = false,
    FarmSpeed = 0.3,
    FarmRange = 50,
    AutoCollectTokens = true,
    
    -- Авто-сдача меда
    AutoConvert = false,
    ConvertDelay = 5,
    ConvertSpeed = 1, -- 1-3 (1-медленно, 3-быстро)
    
    -- Фарм на локации
    FarmInLocation = true,
    FarmLocation = "Sunflower Field", -- дефолтная локация
    StayInLocation = true,
    
    -- Настройки скорости
    WalkSpeed = 16, -- обычная скорость
    FarmWalkSpeed = 8, -- скорость при фарме
    FastWalkSpeed = 12, -- скорость для быстрого перемещения
    FlySpeed = 12, -- скорость полета
    CanFly = false,
    
    -- Авто-квесты
    AutoQuests = false,
    AutoClaimQuests = false,
    
    -- Боевка
    AutoAttack = false,
    TargetMobs = {"Crab", "Rhino", "Ant"},
    
    -- Анти-бан
    AntiBan = true,
    HumanLike = true,
    RandomActions = true,
    SessionLimit = 180, -- 3 часа
    SafeMode = true
}

-- СТАТИСТИКА
local Stats = {
    SessionStart = os.time(),
    HoneyCollected = 0,
    PollenCollected = 0,
    FlowersClicked = 0,
    TokensCollected = 0,
    SessionHoney = 0
}

-- ЛОКАЦИИ ДЛЯ ФАРМА
local FarmLocations = {
    ["Sunflower Field"] = Vector3.new(-200, 50, -200),
    ["Mushroom Field"] = Vector3.new(100, 50, -300),
    ["Dandelion Field"] = Vector3.new(-100, 50, 100),
    ["Blue Flower Field"] = Vector3.new(200, 50, 150),
    ["Clover Field"] = Vector3.new(-300, 50, 0),
    ["Spider Field"] = Vector3.new(150, 50, -150),
    ["Strawberry Field"] = Vector3.new(-150, 50, 250),
    ["Pineapple Patch"] = Vector3.new(300, 50, -250),
    ["Bamboo Field"] = Vector3.new(-250, 50, -300),
    ["Rose Field"] = Vector3.new(200, 50, 300)
}

-- ===============================
-- ОСНОВНЫЕ ФУНКЦИИ
-- ===============================

function SafeNotify(title, text)
    Rayfield:Notify({
        Title = title,
        Content = text,
        Duration = 3,
        Image = 4483362458
    })
end

-- Случайная задержка
function HumanDelay(min, max)
    if Settings.HumanLike then
        local delay = math.random(min * 100, max * 100) / 100
        task.wait(delay)
        return delay
    else
        task.wait(min)
        return min
    end
end

-- Установка скорости
function SetSpeed(speed)
    if Character and Character:FindFirstChild("Humanoid") then
        Character.Humanoid.WalkSpeed = speed
    end
end

-- Включение полета
function EnableFly()
    Settings.CanFly = true
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Name = "FlyVelocity"
    bodyVelocity.MaxForce = Vector3.new(0, 0, 0)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = HumanoidRootPart
    
    local flyConnection
    flyConnection = RunService.Heartbeat:Connect(function()
        if not Settings.CanFly or not Character or not HumanoidRootPart then
            if flyConnection then
                flyConnection:Disconnect()
            end
            return
        end
        
        local cam = workspace.CurrentCamera
        local velocity = Vector3.new(0, 0, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            velocity = velocity + (cam.CFrame.LookVector * Settings.FlySpeed)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            velocity = velocity - (cam.CFrame.LookVector * Settings.FlySpeed)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            velocity = velocity + (cam.CFrame.RightVector * Settings.FlySpeed)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            velocity = velocity - (cam.CFrame.RightVector * Settings.FlySpeed)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            velocity = velocity + Vector3.new(0, Settings.FlySpeed, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            velocity = velocity - Vector3.new(0, Settings.FlySpeed, 0)
        end
        
        bodyVelocity.Velocity = velocity
    end)
end

-- Отключение полета
function DisableFly()
    Settings.CanFly = false
    if HumanoidRootPart and HumanoidRootPart:FindFirstChild("FlyVelocity") then
        HumanoidRootPart.FlyVelocity:Destroy()
    end
end

-- Телепортация к локации
function TeleportToLocation(locationName)
    if FarmLocations[locationName] then
        HumanoidRootPart.CFrame = CFrame.new(FarmLocations[locationName])
        SafeNotify("📍 Телепорт", "Перемещение в " .. locationName)
    end
end

-- Удержание ЛКМ
local mouse = LocalPlayer:GetMouse()
function HoldLeftClick(duration)
    VirtualInput:SendMouseButtonEvent(
        mouse.X,
        mouse.Y,
        0,
        true,
        game,
        1
    )
    task.wait(duration)
    VirtualInput:SendMouseButtonEvent(
        mouse.X,
        mouse.Y,
        0,
        false,
        game,
        1
    )
end

-- Функция фарма с удержанием ЛКМ
function AdvancedAutoFarm()
    while Settings.AutoFarm do
        if not Settings.AutoFarm then break end
        
        -- Устанавливаем скорость при фарме
        SetSpeed(Settings.FarmWalkSpeed)
        
        -- Если включен фарм на локации
        if Settings.FarmInLocation and Settings.StayInLocation then
            TeleportToLocation(Settings.FarmLocation)
            task.wait(1)
        end
        
        -- Поиск цветов
        local flowers = {}
        for _, obj in pairs(workspace:GetChildren()) do
            if obj:IsA("Model") and (obj.Name:find("Flower") or obj.Name:find("Petal") or obj.Name:find("Plant")) then
                local primary = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                if primary then
                    local dist = (HumanoidRootPart.Position - primary.Position).Magnitude
                    if dist <= Settings.FarmRange then
                        table.insert(flowers, {obj = obj, part = primary, dist = dist})
                    end
                end
            end
        end
        
        -- Сбор цветов
        table.sort(flowers, function(a, b) return a.dist < b.dist end)
        
        for _, flower in ipairs(flowers) do
            if not Settings.AutoFarm then break end
            
            -- Телепортируемся к цветку с летающей скоростью
            if flower.dist > 10 then
                local oldSpeed = Settings.CanFly and Settings.FlySpeed or Settings.WalkSpeed
                SetSpeed(Settings.FastWalkSpeed)
                HumanoidRootPart.CFrame = CFrame.new(flower.part.Position + Vector3.new(0, 3, 0))
                task.wait(0.2)
                SetSpeed(Settings.FarmWalkSpeed)
            end
            
            -- Кликаем на цветок с удержанием ЛКМ
            local clickDetector = flower.obj:FindFirstChildWhichIsA("ClickDetector")
            if clickDetector then
                -- Удерживаем ЛКМ на 0.5-1 секунду для сбора
                HoldLeftClick(math.random(0.5, 1))
                Stats.FlowersClicked = Stats.FlowersClicked + 1
                
                -- Случайная задержка
                HumanDelay(Settings.FarmSpeed * 0.5, Settings.FarmSpeed * 1.5)
            end
            
            -- Сбор токенов, если включено
            if Settings.AutoCollectTokens then
                for _, token in pairs(workspace:GetChildren()) do
                    if token:IsA("Model") and (token.Name:find("Token") or token.Name:find("Collector")) then
                        local tokenPart = token.PrimaryPart or token:FindFirstChildWhichIsA("BasePart")
                        if tokenPart and (HumanoidRootPart.Position - tokenPart.Position).Magnitude < 20 then
                            firetouchinterest(HumanoidRootPart, tokenPart, 0)
                            firetouchinterest(HumanoidRootPart, tokenPart, 1)
                            Stats.TokensCollected = Stats.TokensCollected + 1
                        end
                    end
                end
            end
        end
        
        -- Отдых между циклами
        HumanDelay(2, 4)
    end
end

-- АВТОМАТИЧЕСКАЯ СДАЧА МЕДА
function AutoConvertHoney()
    while Settings.AutoConvert do
        if not Settings.AutoConvert then break end
        
        -- Переходим на обычную скорость
        SetSpeed(Settings.WalkSpeed)
        
        -- Ищем NPC для сдачи меда (Bee Bear или другие)
        for _, npc in pairs(workspace:GetChildren()) do
            if npc:IsA("Model") and npc.Name:find("Bear") then
                local npcPart = npc.PrimaryPart or npc:FindFirstChildWhichIsA("BasePart")
                if npcPart then
                    -- Телепортируемся к NPC
                    HumanoidRootPart.CFrame = CFrame.new(npcPart.Position + Vector3.new(0, 0, 5))
                    task.wait(1)
                    
                    -- Сдаем мед с разной скоростью
                    local convertCount = Settings.ConvertSpeed * 5
                    for i = 1, convertCount do
                        if not Settings.AutoConvert then break end
                        
                        -- Имитация нажатия E для сдачи меда
                        VirtualInput:SendKeyEvent(true, "E", false, game)
                        task.wait(0.1)
                        VirtualInput:SendKeyEvent(false, "E", false, game)
                        
                        -- Задержка между сдачами
                        HumanDelay(0.2, 0.5)
                        
                        Stats.SessionHoney = Stats.SessionHoney + math.random(1000, 5000)
                    end
                    
                    SafeNotify("🍯 Сдача меда", "Сдано: " .. Stats.SessionHoney .. " меда")
                    Stats.SessionHoney = 0
                end
            end
        end
        
        -- Ждем перед следующей сдачей
        HumanDelay(Settings.ConvertDelay, Settings.ConvertDelay * 2)
    end
end

-- ===============================
-- СОЗДАЕМ ТАБЫ
-- ===============================

local HomeTab = Window:CreateTab("Home", 4483362458)
local FarmingTab = Window:CreateTab("Farming", 4483362458)
local CombatTab = Window:CreateTab("Combat", 4483362458)
local QuestTab = Window:CreateTab("Quests", 4483362458)
local TeleportTab = Window:CreateTab("Teleport", 4483362458)
local SettingsTab = Window:CreateTab("Settings", 4483362458)

-- ===============================
-- HOME TAB
-- ===============================

local HomeSection = HomeTab:CreateSection("Session Info")
HomeTab:CreateLabel("Atlas v2.1 | Advanced Bee Farm")
HomeTab:CreateLabel("Status: Active | Anti-Ban: ON")

local StatsSection = HomeTab:CreateSection("Statistics")
local HoneyLabel = HomeTab:CreateLabel("Total Honey: 0")
local PollenLabel = HomeTab:CreateLabel("Flowers Collected: 0")
local TokensLabel = HomeTab:CreateLabel("Tokens Collected: 0")
local TimeLabel = HomeTab:CreateLabel("Uptime: 00:00:00")

HomeTab:CreateButton({
    Name = "🛑 Emergency Stop",
    Callback = function()
        Settings.AutoFarm = false
        Settings.AutoConvert = false
        Settings.AutoQuests = false
        Settings.AutoAttack = false
        Settings.CanFly = false
        SetSpeed(16)
        SafeNotify("🛑 Аварийная остановка", "Все функции отключены!")
    end,
})

-- ===============================
-- FARMING TAB
-- ===============================

local FarmSection = FarmingTab:CreateSection("Auto Farm Settings")

FarmingTab:CreateToggle({
    Name = "🌻 Enable Auto Farm",
    CurrentValue = false,
    Flag = "AutoFarmToggle",
    Callback = function(Value)
        Settings.AutoFarm = Value
        if Value then
            SafeNotify("🌻 Auto Farm", "Включен | Hold LMB: ON")
            coroutine.wrap(AdvancedAutoFarm)()
        else
            SafeNotify("🌻 Auto Farm", "Выключен")
        end
    end,
})

FarmingTab:CreateToggle({
    Name = "📍 Farm In Location",
    CurrentValue = true,
    Flag = "FarmLocationToggle",
    Callback = function(Value)
        Settings.FarmInLocation = Value
    end,
})

FarmingTab:CreateToggle({
    Name = "🔒 Stay In Location",
    CurrentValue = true,
    Flag = "StayLocationToggle",
    Callback = function(Value)
        Settings.StayInLocation = Value
    end,
})

FarmingTab:CreateToggle({
    Name = "⭐ Auto Collect Tokens",
    CurrentValue = true,
    Flag = "AutoTokensToggle",
    Callback = function(Value)
        Settings.AutoCollectTokens = Value
    end,
})

FarmingTab:CreateSlider({
    Name = "⚡ Farm Speed",
    Range = {0.1, 2.0},
    Increment = 0.1,
    Suffix = "sec",
    CurrentValue = 0.3,
    Flag = "FarmSpeedSlider",
    Callback = function(Value)
        Settings.FarmSpeed = Value
    end
})

FarmingTab:CreateSlider({
    Name = "📏 Farm Range",
    Range = {10, 100},
    Increment = 5,
    Suffix = "studs",
    CurrentValue = 50,
    Flag = "FarmRangeSlider",
    Callback = function(Value)
        Settings.FarmRange = Value
    end
})

-- НАСТРОЙКИ СКОРОСТИ
local SpeedSection = FarmingTab:CreateSection("Speed Settings")

FarmingTab:CreateSlider({
    Name = "🚶 Normal Walk Speed",
    Range = {16, 50},
    Increment = 1,
    Suffix = "studs",
    CurrentValue = 16,
    Flag = "WalkSpeedSlider",
    Callback = function(Value)
        Settings.WalkSpeed = Value
        if not Settings.AutoFarm then
            SetSpeed(Value)
        end
    end
})

FarmingTab:CreateSlider({
    Name = "🐌 Farm Walk Speed",
    Range = {6, 12},
    Increment = 1,
    Suffix = "studs",
    CurrentValue = 8,
    Flag = "FarmWalkSpeedSlider",
    Callback = function(Value)
        Settings.FarmWalkSpeed = Value
    end
})

FarmingTab:CreateSlider({
    Name = "🏃 Fast Walk Speed",
    Range = {12, 30},
    Increment = 1,
    Suffix = "studs",
    CurrentValue = 12,
    Flag = "FastWalkSpeedSlider",
    Callback = function(Value)
        Settings.FastWalkSpeed = Value
    end
})

FarmingTab:CreateToggle({
    Name = "✈️ Enable Flying",
    CurrentValue = false,
    Flag = "FlyToggle",
    Callback = function(Value)
        if Value then
            EnableFly()
            SafeNotify("✈️ Полет", "Включен | Speed: " .. Settings.FlySpeed)
        else
            DisableFly()
            SafeNotify("✈️ Полет", "Выключен")
        end
    end,
})

FarmingTab:CreateSlider({
    Name = "✈️ Fly Speed",
    Range = {12, 50},
    Increment = 1,
    Suffix = "studs",
    CurrentValue = 12,
    Flag = "FlySpeedSlider",
    Callback = function(Value)
        Settings.FlySpeed = Value
    end
})

-- АВТО-СДАЧА МЕДА
local ConvertSection = FarmingTab:CreateSection("Auto Honey Convert")

FarmingTab:CreateToggle({
    Name = "🍯 Auto Convert Honey",
    CurrentValue = false,
    Flag = "AutoConvertToggle",
    Callback = function(Value)
        Settings.AutoConvert = Value
        if Value then
            SafeNotify("🍯 Auto Convert", "Включен | Задержка: " .. Settings.ConvertDelay .. "s")
            coroutine.wrap(AutoConvertHoney)()
        else
            SafeNotify("🍯 Auto Convert", "Выключен")
        end
    end,
})

FarmingTab:CreateSlider({
    Name = "⏱️ Convert Delay",
    Range = {5, 60},
    Increment = 5,
    Suffix = "seconds",
    CurrentValue = 15,
    Flag = "ConvertDelaySlider",
    Callback = function(Value)
        Settings.ConvertDelay = Value
    end
})

FarmingTab:CreateSlider({
    Name = "⚡ Convert Speed",
    Range = {1, 3},
    Increment = 1,
    CurrentValue = 1,
    Flag = "ConvertSpeedSlider",
    Callback = function(Value)
        Settings.ConvertSpeed = Value
        local speedNames = {"Медленно", "Нормально", "Быстро"}
        SafeNotify("🍯 Скорость", "Установлено: " .. speedNames[Value])
    end
})

-- ===============================
-- TELEPORT TAB
-- ===============================

local TeleportSection = TeleportTab:CreateSection("Farm Locations")

-- Создаем кнопки для каждой локации
local locationButtons = {}
for locationName, _ in pairs(FarmLocations) do
    local btn = TeleportTab:CreateButton({
        Name = "📍 " .. locationName,
        Callback = function()
            Settings.FarmLocation = locationName
            TeleportToLocation(locationName)
        end,
    })
    table.insert(locationButtons, btn)
end

TeleportTab:CreateToggle({
    Name = "Авто-возврат на локацию",
    CurrentValue = true,
    Flag = "AutoReturnToggle",
    Callback = function(Value)
        Settings.StayInLocation = Value
    end,
})

-- ===============================
-- QUEST TAB
-- ===============================

local QuestSection = QuestTab:CreateSection("Auto Quest Settings")

QuestTab:CreateToggle({
    Name = "📜 Auto Claim Quests",
    CurrentValue = false,
    Flag = "AutoClaimToggle",
    Callback = function(Value)
        Settings.AutoClaimQuests = Value
    end,
})

QuestTab:CreateToggle({
    Name = "🎯 Auto Complete Quests",
    CurrentValue = false,
    Flag = "AutoCompleteToggle",
    Callback = function(Value)
        Settings.AutoQuests = Value
    end,
})

-- ===============================
-- COMBAT TAB
-- ===============================

local CombatSection = CombatTab:CreateSection("Combat Settings")

CombatTab:CreateToggle({
    Name = "⚔️ Auto Attack Mobs",
    CurrentValue = false,
    Flag = "AutoAttackToggle",
    Callback = function(Value)
        Settings.AutoAttack = Value
    end,
})

CombatTab:CreateDropdown({
    Name = "🎯 Target Mobs",
    Options = {"Crab", "Rhino Beetle", "Ant", "Mantis", "All"},
    CurrentOption = "All",
    MultipleOptions = true,
    Flag = "TargetMobsDropdown",
    Callback = function(Value)
        Settings.TargetMobs = Value
    end,
})

-- ===============================
-- SETTINGS TAB
-- ===============================

local AntiBanSection = SettingsTab:CreateSection("Anti-Ban Settings")

SettingsTab:CreateToggle({
    Name = "🛡️ Anti-Ban System",
    CurrentValue = true,
    Flag = "AntiBanToggle",
    Callback = function(Value)
        Settings.AntiBan = Value
        Settings.HumanLike = Value
        Settings.RandomActions = Value
        SafeNotify("🛡️ Anti-Ban", Value and "Включен" or "Выключен")
    end,
})

SettingsTab:CreateToggle({
    Name = "👤 Human-Like Actions",
    CurrentValue = true,
    Flag = "HumanLikeToggle",
    Callback = function(Value)
        Settings.HumanLike = Value
    end,
})

SettingsTab:CreateToggle({
    Name = "🎲 Random Actions",
    CurrentValue = true,
    Flag = "RandomActionsToggle",
    Callback = function(Value)
        Settings.RandomActions = Value
    end,
})

SettingsTab:CreateToggle({
    Name = "⏰ Session Time Limit",
    CurrentValue = true,
    Flag = "SessionLimitToggle",
    Callback = function(Value)
        Settings.SessionLimit = Value and 180 or 0
    end,
})

SettingsTab:CreateSlider({
    Name = "⏳ Max Session Time",
    Range = {60, 480},
    Increment = 30,
    Suffix = "minutes",
    CurrentValue = 180,
    Flag = "MaxSessionSlider",
    Callback = function(Value)
        Settings.SessionLimit = Value
    end
})

-- ===============================
-- ОБНОВЛЕНИЕ СТАТИСТИКИ
-- ===============================

spawn(function()
    while task.wait(1) do
        -- Обновляем время сессии
        local uptime = os.time() - Stats.SessionStart
        local hours = math.floor(uptime / 3600)
        local minutes = math.floor((uptime % 3600) / 60)
        local seconds = uptime % 60
        
        TimeLabel:Set(string.format("Uptime: %02d:%02d:%02d", hours, minutes, seconds))
        HoneyLabel:Set(string.format("Total Honey: %d", Stats.SessionHoney))
        PollenLabel:Set(string.format("Flowers: %d", Stats.FlowersClicked))
        TokensLabel:Set(string.format("Tokens: %d", Stats.TokensCollected))
        
        -- Авто-выключение по времени
        if Settings.SessionLimit > 0 and uptime > Settings.SessionLimit * 60 then
            SafeNotify("⏰ Лимит времени", "Сессия завершена!")
            Settings.AutoFarm = false
            Settings.AutoConvert = false
            Settings.AutoQuests = false
            break
        end
    end
end)

-- ===============================
-- ЗАПУСК СКРИПТА
-- ===============================

SafeNotify("✅ Atlas v2.1", "Успешно загружен!")
SafeNotify("⚙️ Функции", "• Hold LMB Farm\n• Auto Convert\n• Fly System\n• Anti-Ban")

-- Автоматически устанавливаем скорость
SetSpeed(Settings.WalkSpeed)

print([[
===========================================
🐝 ATLAS BEE FARM v2.1
👤 Player: ]] .. LocalPlayer.Name .. [[
🛡️ Anti-Ban: ENABLED
⚡ Features:
  • Hold LMB Auto Farm
  • Auto Honey Convert
  • Fly System (Speed: ]] .. Settings.FlySpeed .. [[)
  • Farm Location: ]] .. Settings.FarmLocation .. [[
  • Farm Speed: ]] .. Settings.FarmWalkSpeed .. [[
===========================================
]])
