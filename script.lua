-- ============================================
-- 🐝 BEE SWARM SIMULATOR - PREMIUM SCRIPT
-- Version: 2.0 | Author: kkenkeila-ui
-- ============================================

-- Загружаем библиотеку Rayfield (очень красивая)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Создаем окно
local Window = Rayfield:CreateWindow({
    Name = "🐝 Bee Farm Premium",
    LoadingTitle = "Загрузка...",
    LoadingSubtitle = "by kkenkeila-ui",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "BeeFarm",
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
        Note = "Join Discord",
        FileName = "Key",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = {"BeeFarm123"}
    }
})

-- Вкладки
local MainTab = Window:CreateTab("🏠 Главная", 4483345998)
local AutoTab = Window:CreateTab("⚡ Авто-Фарм", 4483345998)
local TeleportTab = Window:CreateTab("📍 Телепорты", 4483345998)
local PlayerTab = Window:CreateTab("👤 Игрок", 4483345998)
local SettingsTab = Window:CreateTab("⚙ Настройки", 4483345998)

-- Настройки
local Settings = {
    AutoFarm = false,
    FarmRange = 50,
    FarmSpeed = 0.3,
    AutoConvert = false,
    AutoBubble = false,
    WalkSpeed = 16,
    JumpPower = 50
}

-- Функция уведомления
function Notify(title, text)
    Rayfield:Notify({
        Title = title,
        Content = text,
        Duration = 3,
        Image = 4483345998
    })
end

-- Главная вкладка
local InfoSection = MainTab:CreateSection("Информация")
MainTab:CreateLabel("🐝 Bee Farm Premium v2.0")
MainTab:CreateLabel("Автор: kkenkeila-ui")
MainTab:CreateLabel("GitHub: github.com/kkenkeila-ui")

-- Авто-фарм вкладка
local FarmSection = AutoTab:CreateSection("Основные настройки")

AutoTab:CreateToggle({
    Name = "Авто-Сбор Пыльцы",
    CurrentValue = false,
    Flag = "AutoFarmToggle",
    Callback = function(Value)
        Settings.AutoFarm = Value
        if Value then
            Notify("Авто-Фарм", "✅ Включен")
            while Settings.AutoFarm do
                -- Код сбора
                wait(Settings.FarmSpeed)
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
    Range = {0.1, 1},
    Increment = 0.1,
    Suffix = "сек",
    CurrentValue = 0.3,
    Flag = "FarmSpeedSlider",
    Callback = function(Value)
        Settings.FarmSpeed = Value
    end
})

-- Телепорты
local TeleportSection = TeleportTab:CreateSection("Локации")

TeleportTab:CreateButton({
    Name = "🌻 Подсолнуховое поле",
    Callback = function()
        game.Players.LocalPlayer.Character:MoveTo(Vector3.new(-100, 4, -200))
        Notify("Телепорт", "Телепортирован на поле")
    end,
})

TeleportTab:CreateButton({
    Name = "🍯 Улей",
    Callback = function()
        game.Players.LocalPlayer.Character:MoveTo(Vector3.new(0, 10, 0))
        Notify("Телепорт", "Телепортирован к улью")
    end,
})

TeleportTab:CreateButton({
    Name = "⛰ Гора",
    Callback = function()
        game.Players.LocalPlayer.Character:MoveTo(Vector3.new(0, 100, 300))
        Notify("Телепорт", "Телепортирован на гору")
    end,
})

-- Игрок
local PlayerSection = PlayerTab:CreateSection("Характеристики")

PlayerTab:CreateSlider({
    Name = "Скорость ходьбы",
    Range = {16, 100},
    Increment = 5,
    Suffix = "speed",
    CurrentValue = 16,
    Flag = "WalkSpeedSlider",
    Callback = function(Value)
        Settings.WalkSpeed = Value
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = Value
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
        Settings.JumpPower = Value
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.JumpPower = Value
        end
    end
})

-- Настройки
local ConfigSection = SettingsTab:CreateSection("Конфигурация")

SettingsTab:CreateKeybind({
    Name = "Клавиша меню",
    CurrentKeybind = "RightControl",
    HoldToInteract = false,
    Flag = "MenuKeybind",
    Callback = function(Keybind)
        -- Меню само откроется
    end,
})

SettingsTab:CreateButton({
    Name = "📋 Скопировать ссылку на скрипт",
    Callback = function()
        setclipboard("https://github.com/kkenkeila-ui/bee-farm-script")
        Notify("Ссылка", "Скопирована в буфер!")
    end,
})

SettingsTab:CreateButton({
    Name = "🔄 Обновить скрипт",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/kkenkeila-ui/bee-farm-script/main/script.lua"))()
    end,
})

-- Загрузка
Rayfield:Notify({
    Title = "🐝 Bee Farm Premium",
    Content = "Скрипт успешно загружен!",
    Duration = 5,
    Image = 4483345998
})

print([[
=======================================
🐝 Bee Farm Premium v2.0
👤 Автор: kkenkeila-ui
🌐 GitHub: github.com/kkenkeila-ui
✅ Загружен успешно!
=======================================
]])
