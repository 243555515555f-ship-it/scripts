-- Menoo GeminiLib V6 - FULLY OPTIMIZED & LAG-FIXED
local GeminiLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/243555515555f-ship-it/scripts/refs/heads/main/GeminiLib%20V6.lua"))()

-- Services & cached locals
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local character, humanoid, rootPart
local function refreshCharacterRefs()
    character = player.Character
    humanoid = character and character:FindFirstChildOfClass("Humanoid")
    rootPart = character and character:FindFirstChild("HumanoidRootPart")
end

refreshCharacterRefs()
player.CharacterAdded:Connect(function(newChar)
    task.wait(0.1)
    refreshCharacterRefs()
end)

local function getPlayerObject()
    return player.Character or Workspace:FindFirstChild(player.Name)
end

local function getRootPart()
    return rootPart or (getPlayerObject() and getPlayerObject():FindFirstChild("HumanoidRootPart"))
end

local function getPlayerHumanoid()
    return humanoid or (getPlayerObject() and getPlayerObject():FindFirstChildOfClass("Humanoid"))
end

local function Notify(text, duration)
    GeminiLib:CreateNotification({
        Title = "Menoo " .. GeminiLib:Version(),
        Text = text,
        Duration = duration or 5
    })
end

-- Window
local currentTheme = "VioletNebula"
local MenooWindow = GeminiLib:CreateWindow("Menoo", currentTheme)

local BypassTab = MenooWindow:CreateTab("Bypass", "🎅")
local VisualsTab = MenooWindow:CreateTab("Visual Tools", "🎇")
local MasterFuncTab = MenooWindow:CreateTab("Master Functions", "👽")

local BloxFruitsTab
if game.PlaceId == 2753915549 then
    BloxFruitsTab = MenooWindow:CreateTab("Blox Fruits Tab", "🎇")
end

local OtherToolsTab = MenooWindow:CreateTab("Other Tools", "🧑‍🎄")
local SettingsTab = MenooWindow:CreateTab("Settings", "🎇")
local CreditsTab = MenooWindow:CreateTab("Credits", "🎁")

-- Connection Manager (improved)
local ConnectionManager = {
    connections = {},
    add = function(self, name, conn)
        if self.connections[name] then
            pcall(function() self.connections[name]:Disconnect() end)
        end
        self.connections[name] = conn
    end,
    remove = function(self, name)
        if self.connections[name] then
            pcall(function() self.connections[name]:Disconnect() end)
            self.connections[name] = nil
        end
    end,
    cleanup = function(self)
        for _, conn in pairs(self.connections) do
            pcall(function() conn:Disconnect() end)
        end
        self.connections = {}
    end
}

local oldWalkSpeed = getPlayerHumanoid() and getPlayerHumanoid().WalkSpeed or 16
local oldJumpPower = getPlayerHumanoid() and getPlayerHumanoid().JumpPower or 50
local newWalkSpeed, newJumpPower = oldWalkSpeed, oldJumpPower
local walkSpeedEnabled, jumpPowerEnabled = false, false


--================================================================
-------------------Anti Kick & Anti Ban --------------------------
--================================================================
if player then
    local rawMetatable = getrawmetatable and getrawmetatable(game)
    if rawMetatable and setreadonly then
        setreadonly(rawMetatable, false)
        local oldIndex = rawMetatable.__index
        local oldNamecall = rawMetatable.__namecall
        
        rawMetatable.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if self == player and (method == "Kick" or method == "kick") then
                warn("[Menoo Anti-Kick]: Заблокирована попытка кика с сервера!")
                return nil -- Игнорируем вызов функции кика
            end
            return oldNamecall(self, ...)
        end)
        setreadonly(rawMetatable, true)
    end
end


----------------------------------------------------------------
-- PLAYER BYPASS (Optimized)
----------------------------------------------------------------
BypassTab:Label("Player Bypass Features ♾︎")

BypassTab:Slider("WalkSpeed Bypass Value", oldWalkSpeed, 200, oldWalkSpeed, function(value)
    newWalkSpeed = value
end, oldWalkSpeed)

BypassTab:Toggle("Enable WalkSpeed Bypass", false, function(state)
    walkSpeedEnabled = state
end)

BypassTab:Label("Jump Bypass Features ⛷")
BypassTab:Button("Jump Enable Bypass", function()
    local hum = getPlayerHumanoid()
    if hum then
        hum.UseJumpPower = true
        hum.AutoJumpEnabled = true
    end
end, "")

BypassTab:Slider("JumpPower Bypass Value", oldJumpPower, 350, oldJumpPower, function(value)
    newJumpPower = value
end, oldJumpPower)

BypassTab:Toggle("JumpPower On/Off", false, function(state)
    jumpPowerEnabled = state
end, "")

-- Main Bypass Loop
ConnectionManager:add("BypassLoop", RunService.Heartbeat:Connect(function()
    local hum = getPlayerHumanoid()
    if hum then
        if walkSpeedEnabled and hum.WalkSpeed ~= newWalkSpeed then
            hum.WalkSpeed = newWalkSpeed
        else
            -- Если отключаем, возвращаем к норме
            if not walkSpeedEnabled and hum.WalkSpeed ~= oldWalkSpeed then
                hum.WalkSpeed = oldWalkSpeed
            end
        end
        if jumpPowerEnabled and hum.JumpPower ~= newJumpPower then
            hum.JumpPower = newJumpPower
        else
            if not jumpPowerEnabled and hum.JumpPower ~= oldJumpPower then
                hum.JumpPower = oldJumpPower
            end
        end
    end
end))

----------------------------------------------------------------
-- noclip FLY SYSTEM (CFrame Optimized)
----------------------------------------------------------------
BypassTab:Label("Fly ✈")

local Flight = {
    Enabled = false,
    Speed = 60,
    Connection = nil,
    VerticalSpeed = 50
}

local KeyState = { W = 0, S = 0, A = 0, D = 0, Space = false, Ctrl = false }

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    local key = input.KeyCode
    if key == Enum.KeyCode.W then KeyState.W = 1
    elseif key == Enum.KeyCode.S then KeyState.S = 1
    elseif key == Enum.KeyCode.A then KeyState.A = 1
    elseif key == Enum.KeyCode.D then KeyState.D = 1
    elseif key == Enum.KeyCode.Space then KeyState.Space = true
    elseif key == Enum.KeyCode.LeftControl or key == Enum.KeyCode.RightControl then KeyState.Ctrl = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    local key = input.KeyCode
    if key == Enum.KeyCode.W then KeyState.W = 0
    elseif key == Enum.KeyCode.S then KeyState.S = 0
    elseif key == Enum.KeyCode.A then KeyState.A = 0
    elseif key == Enum.KeyCode.D then KeyState.D = 0
    elseif key == Enum.KeyCode.Space then KeyState.Space = false
    elseif key == Enum.KeyCode.LeftControl or key == Enum.KeyCode.RightControl then KeyState.Ctrl = false
    end
end)

local function updateFly(dt)
    if not Flight.Enabled then return end
    local root = getRootPart()
    if not root then return end

    local cam = Workspace.CurrentCamera
    local move = Vector3.new(
        KeyState.D - KeyState.A,
        (KeyState.Space and 1 or 0) - (KeyState.Ctrl and 1 or 0),
        KeyState.S - KeyState.W
    )

    if move.Magnitude > 0 then
        move = move.Unit
        local direction = cam.CFrame:VectorToWorldSpace(move)
        root.CFrame = root.CFrame + (direction * Flight.Speed * dt)
    end
end

local function startBetterFly()
    if Flight.Enabled then return end
    Flight.Enabled = true

    local root = getRootPart()
    if root then 
        root.Anchored = true 
        root.Velocity = Vector3.zero
    end

    local hum = getPlayerHumanoid()
    if hum then hum.PlatformStand = true end

    Flight.Connection = RunService.Heartbeat:Connect(updateFly)
end

local function stopBetterFly()
    Flight.Enabled = false
    if Flight.Connection then
        Flight.Connection:Disconnect()
        Flight.Connection = nil
    end

    local root = getRootPart()
    if root then 
        root.Anchored = false 
    end

    local hum = getPlayerHumanoid()
    if hum then hum.PlatformStand = false end
end

BypassTab:Slider("Fly Speed", 20, 500, 80, function(v) Flight.Speed = v end)
BypassTab:Toggle("Enable Fly", false, function(state)
    if state then
        startBetterFly()
    else
        stopBetterFly()
    end
end)
----------------------------------------------------------------
-- NOCLIP
----------------------------------------------------------------
local noclipEnabled = false
local noclipConnection = nil

local function toggleNoclip(state)
    noclipEnabled = state
    
    if noclipEnabled then
        -- Используем Heartbeat/Stepped для синхронизации с физическим движком
        noclipConnection = RunService.Stepped:Connect(function()
            local char = player.Character
            if not char then return end
            
            -- Вместо отключения коллизии ВСЕГО тела, отключаем только у ключевых частей
            -- Это не триггерит базовые проверки на "призрака"
            local upperTorso = char:FindFirstChild("UpperTorso")
            local lowerTorso = char:FindFirstChild("LowerTorso")
            local torso = char:FindFirstChild("Torso")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            
            if torso then torso.CanCollide = false end
            if upperTorso then upperTorso.CanCollide = false end
            if lowerTorso then lowerTorso.CanCollide = false end
            if hrp then hrp.CanCollide = false end
        end)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
    end
end

BypassTab:Toggle("NoClip On/Off", false, function(state)
    toggleNoclip(state)
end)

local God = { Enabled = false, Conn = nil }
BypassTab:Toggle("Godmode On/Off", false, function(state)
    local h = getPlayerHumanoid()
    if state then
        ConnectionManager:remove("God")
        ConnectionManager:add("God", h.HealthChanged:Connect(function(health)
            if health < 0.5 and h then
                h.Health = h.MaxHealth or 100
            end
        end))
    else
        ConnectionManager:remove("God")
        if h then h.Health = h.MaxHealth or 100 end
    end
end)

----------------------------------------------------------------
-- INVISIBLE (Kept with pcall safety)
----------------------------------------------------------------
local Invisible = {
    Enabled = false,
    Clone = nil,
    Original = nil,
    Loop = nil,
    BackupCFrame = nil
}

-- Компактная функция восстановления камеры
local function resetCamera(targetChar)
    local hum = targetChar:FindFirstChildOfClass("Humanoid")
    if hum then
        Camera.CameraSubject = hum
        Camera.CameraType = Enum.CameraType.Custom
    end
end

local function turnInvisible()
    if Invisible.Enabled then return end
    
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not char or not hrp then return end

    Invisible.Enabled = true
    Invisible.Original = char
    Invisible.BackupCFrame = hrp.CFrame

    -- Создаем локального клона (его видит ТОЛЬКО этот игрок)
    char.Archivable = true
    local clone = char:Clone()
    clone.Name = "InvisPlayer"
    
    -- Делаем клона полупрозрачным, чтобы понимать, что мы невидимы
    for _, part in ipairs(clone:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = (part.Name == "HumanoidRootPart") and 1 or 0.5
            part.CanCollide = false
        end
    end

    clone.Parent = Workspace
    Invisible.Clone = clone
    player.Character = clone
    resetCamera(clone)

    -- Перезапускаем анимации клона
    local anim = clone:FindFirstChild("Animate")
    if anim then anim.Disabled = true task.wait(0.05) anim.Disabled = false end

    -- "Прячем" оригинального персонажа от серверных проверок
    -- Вместо переноса в Lighting, мы просто опускаем его глубоко под землю локально
    -- Для сервера вы стоите на месте, а локально ваш настоящий хитбокс недосягаем
    Invisible.Loop = RunService.Heartbeat:Connect(function()
        pcall(function()
            if char and char:FindFirstChild("HumanoidRootPart") then
                -- Оставляем оригинал под землей, чтобы в него никто не попал
                char.HumanoidRootPart.CFrame = Invisible.BackupCFrame * CFrame.new(0, -500, 0)
                char.HumanoidRootPart.Velocity = Vector3.zero
            end
            
            -- Синхронизируем здоровье клона с оригиналом
            if clone and clone:FindFirstChildOfClass("Humanoid") and char:FindFirstChildOfClass("Humanoid") then
                if char:FindFirstChildOfClass("Humanoid").Health <= 0 then
                    -- Если оригинал умер, отключаем невидимость
                    pcall(function() Invisible.Loop:Disconnect() end)
                    Invisible.Enabled = false
                    player.Character = char
                    clone:Destroy()
                end
            end
        end)
    end)
end

local function turnVisible()
    if not Invisible.Enabled then return end
    Invisible.Enabled = false

    if Invisible.Loop then
        Invisible.Loop:Disconnect()
        Invisible.Loop = nil
    end

    local char = Invisible.Original
    local clone = Invisible.Clone

    pcall(function()
        if clone then
            -- Сохраняем позицию, где мы закончили бегать клоном
            local finalCFrame = clone:FindFirstChild("HumanoidRootPart") and clone.HumanoidRootPart.CFrame
            clone:Destroy()

            -- Возвращаем оригинального персонажа на место клона
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = finalCFrame or Invisible.BackupCFrame
                player.Character = char
                task.wait(0.05)
                resetCamera(char)
            end
        end
    end)
    
    Invisible.Original = nil
    Invisible.Clone = nil
end


-- Интеграция во вкладку UI
BypassTab:Toggle("Invisible On/Off", false, function(state)
    if state then
        local success, err = pcall(turnInvisible)
        if not success then warn("Invisible Error:", err) turnVisible() end
    else
        pcall(turnVisible)
    end
end)

local invisState = false
BypassTab:KeyBind("Keybind: ", Enum.KeyCode.F, function()
    invisState = not invisState
    if invisState then
        local success, err = pcall(turnInvisible)
        if not success then warn("Invisible Error:", err) turnVisible() end
    else
        pcall(turnVisible)
    end
end)

-- ====================================================================
--     ESP SYSTEM (Fully optimized with caching and safe cleanup)
-- ====================================================================

VisualsTab:Label("ESP Tools ☄")

-- ==================== НАСТРОЙКИ ESP ====================
local ESP_Settings = {
    Mode = "Team Mode", -- "Team Mode" или "FFA Mode"
    RainbowWave = false, -- Глобальная RGB волна
    MaxDistance = 1000, 
    Colors = {
        Enemy = Color3.fromRGB(255, 65, 65),
        Team = Color3.fromRGB(65, 255, 130)
    }
}

-- Хранилище Drawing-объектов и инстансов
local ESP_Storage = {
    Highlights = {},
    Names = {},
    Tracers = {},
    Boxes = {},
    HealthBars = {}
}

-- Переменная для текущего глобального цвета волны
local GlobalRainbowColor = Color3.fromRGB(255, 255, 255)

-- Вспомогательная функция определения цвета для игрока
local function getESPColor(plr)
    if ESP_Settings.RainbowWave then
        return GlobalRainbowColor
    end
    if ESP_Settings.Mode == "Team Mode" and player.Team and plr.Team then
        if plr.Team == player.Team then
            return ESP_Settings.Colors.Team
        end
    end
    return ESP_Settings.Colors.Enemy
end

-- Функция принудительной полной очистки объектов одного игрока
local function removePlayerESP(plr)
    if ESP_Storage.Highlights[plr] then pcall(function() ESP_Storage.Highlights[plr]:Destroy() end) ESP_Storage.Highlights[plr] = nil end
    if ESP_Storage.Names[plr] then pcall(function() ESP_Storage.Names[plr]:Destroy() end) ESP_Storage.Names[plr] = nil end
    if ESP_Storage.Tracers[plr] then pcall(function() ESP_Storage.Tracers[plr]:Remove() end) ESP_Storage.Tracers[plr] = nil end
    if ESP_Storage.Boxes[plr] then pcall(function() ESP_Storage.Boxes[plr]:Remove() end) ESP_Storage.Boxes[plr] = nil end
    if ESP_Storage.HealthBars[plr] then pcall(function() ESP_Storage.HealthBars[plr]:Remove() end) ESP_Storage.HealthBars[plr] = nil end
end

-- Очистка категорий при выключении тумблеров
local function clearCategory(key)
    for plr, obj in pairs(ESP_Storage[key]) do
        pcall(function() if obj.Remove then obj:Remove() else obj:Destroy() end end)
    end
    ESP_Storage[key] = {}
end

-- Состояния туглов
local Options = { Highlight = false, Name = false, Tracer = false, Box = false, Health = false }

-- ==================== ГЛАВНЫЙ ЦИКЛ РЕНДЕРА ====================
ConnectionManager:add("ESP_CoreLoop", RunService.RenderStepped:Connect(function()
    -- Обновление цвета волны
    if ESP_Settings.RainbowWave then
        local hue = (tick() * 0.25) % 1
        GlobalRainbowColor = Color3.fromHSV(hue, 1, 1)
    end

    local myRoot = getRootPart()
    if not myRoot then return end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == player then continue end
       
        local char = plr.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local head = char and char:FindFirstChild("Head")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
       
        -- Если игрок мёртв или нет важных частей — чистим и пропускаем
        if not char or not root or not head or not hum or hum.Health <= 0 then
            removePlayerESP(plr)
            continue
        end

        -- === НОВОЕ: ПРОВЕРКА ДИСТАНЦИИ ===
        local distance = (myRoot.Position - root.Position).Magnitude
        if distance > ESP_Settings.MaxDistance then
            removePlayerESP(plr)
            continue
        end

        local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
        local headPos = Camera:WorldToViewportPoint(head.Position)
        local currentSubColor = getESPColor(plr)
       
        -- 1. HIGHLIGHT ESP
        if Options.Highlight then
            local hl = ESP_Storage.Highlights[plr]
            if not hl or hl.Parent ~= char then
                if hl then pcall(function() hl:Destroy() end) end
                hl = Instance.new("Highlight")
                hl.Name = "ESPHighlight"
                hl.FillTransparency = 1
                hl.OutlineTransparency = 0
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Parent = char
                ESP_Storage.Highlights[plr] = hl
            end
            hl.OutlineColor = currentSubColor
        end
       
        -- 2. BILLBOARD NAME ESP
        if Options.Name then
            local bGui = ESP_Storage.Names[plr]
            if not bGui or bGui.Parent ~= head then
                if bGui then pcall(function() bGui:Destroy() end) end
               
                bGui = Instance.new("BillboardGui")
                bGui.Name = "ESPNameGui"
                bGui.Adornee = head
                bGui.Size = UDim2.new(10, 0, 3, 0)
                bGui.StudsOffset = Vector3.new(0, 3.5, 0)
                bGui.AlwaysOnTop = true
                bGui.MaxDistance = ESP_Settings.MaxDistance + 50
               
                local label = Instance.new("TextLabel")
                label.Name = "NameLabel"
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.Text = plr.Name
                label.TextScaled = true
                label.Font = Enum.Font.SourceSansBold
                label.TextStrokeTransparency = 0.2
                label.TextStrokeColor3 = Color3.new(0, 0, 0)
                label.Parent = bGui
               
                bGui.Parent = head
                ESP_Storage.Names[plr] = bGui
            end
           
            local label = bGui:FindFirstChild("NameLabel")
            if label then 
                label.TextColor3 = currentSubColor
                -- Опционально показываем дистанцию
                if Options.Distance then
                    label.Text = string.format("%s [%.0f]", plr.Name, distance)
                end
            end
        end
       
        -- 3. TRACERS ESP
        if Options.Tracer and onScreen then
            if not ESP_Storage.Tracers[plr] then
                local line = Drawing.new("Line")
                line.Thickness = 1.5
                line.Transparency = 0.8
                ESP_Storage.Tracers[plr] = line
            end
            local line = ESP_Storage.Tracers[plr]
            line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            line.To = Vector2.new(screenPos.X, screenPos.Y)
            line.Color = currentSubColor
            line.Visible = true
        else
            if ESP_Storage.Tracers[plr] then ESP_Storage.Tracers[plr].Visible = false end
        end
       
        -- 4. BOX ESP
        if Options.Box and onScreen and headPos.Z > 0 then
            if not ESP_Storage.Boxes[plr] then
                local sq = Drawing.new("Square")
                sq.Thickness = 1.5
                sq.Filled = false
                sq.Transparency = 0.8
                ESP_Storage.Boxes[plr] = sq
            end
           
            local box = ESP_Storage.Boxes[plr]
            local height = math.abs(screenPos.Y - headPos.Y) * 2.7
            local width = height * 0.65
           
            box.Size = Vector2.new(width, height)
            box.Position = Vector2.new(screenPos.X - width / 2, headPos.Y - (height * 0.22))
            box.Color = currentSubColor
            box.Visible = true
        else
            if ESP_Storage.Boxes[plr] then ESP_Storage.Boxes[plr].Visible = false end
        end
       
        -- 5. HEALTH BAR ESP
        if Options.Health and onScreen and headPos.Z > 0 then
            if not ESP_Storage.HealthBars[plr] then
                local bar = Drawing.new("Square")
                bar.Filled = true
                bar.Thickness = 1
                bar.Transparency = 0.7
                ESP_Storage.HealthBars[plr] = bar
            end
            local bar = ESP_Storage.HealthBars[plr]
            local height = math.abs(screenPos.Y - headPos.Y) * 1.6
            local hpPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
           
            bar.Size = Vector2.new(4, height * hpPercent)
            bar.Position = Vector2.new(screenPos.X - (height * 0.6) / 2 - 8, headPos.Y - 5 + (height * (1 - hpPercent)))
           
            if ESP_Settings.RainbowWave then
                bar.Color = GlobalRainbowColor
            else
                bar.Color = Color3.fromHSV(0.33 * hpPercent, 1, 1)
            end
            bar.Visible = true
        else
            if ESP_Storage.HealthBars[plr] then ESP_Storage.HealthBars[plr].Visible = false end
        end
    end

    -- Очистка отключённых категорий
    if not Options.Highlight then clearCategory("Highlights") end
    if not Options.Name then clearCategory("Names") end
    if not Options.Tracer then clearCategory("Tracers") end
    if not Options.Box then clearCategory("Boxes") end
    if not Options.Health then clearCategory("HealthBars") end
end))

-- ==================== ПОДПИСКИ НА СОБЫТИЯ ОЧИСТКИ ====================
local function trackPlayer(plr)
    plr.CharacterRemoving:Connect(function()
        removePlayerESP(plr)
    end)
end

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= player then trackPlayer(p) end
end
Players.PlayerAdded:Connect(trackPlayer)
Players.PlayerRemoving:Connect(removePlayerESP)

-- ==================== UI ЭЛЕМЕНТЫ УПРАВЛЕНИЯ ====================
VisualsTab:Dropdown("ESP Preset", {"Off", "Box + Name", "Highlight + Name", "Box + Tracers", "Full"}, "Off", function(v)
    if v == "Off" then
        Options.Highlight = false
        Options.Name = false
        Options.Tracer = false
        Options.Box = false
        Options.Health = false
    elseif v == "Box + Name" then
        Options.Highlight = false
        Options.Name = true
        Options.Tracer = false
        Options.Box = true
        Options.Health = true
    elseif v == "Highlight + Name" then
        Options.Highlight = true
        Options.Name = true
        Options.Tracer = true
        Options.Box = false
        Options.Health = false
    elseif v == "Box + Tracers" then
        Options.Highlight = false
        Options.Name = false
        Options.Tracer = true
        Options.Box = true
        Options.Health = true
    elseif v == "Full" then
        Options.Highlight = true
        Options.Name = true
        Options.Tracer = true
        Options.Box = true
        Options.Health = true
    end
end)

VisualsTab:Label("ESP Customization ⚙")

-- Глобальный переключатель перелива волной
VisualsTab:Toggle("Wave Rainbow Mode", false, function(state)
    ESP_Settings.RainbowWave = state
end)

VisualsTab:Slider("Max ESP Distance", 100, 1500, 200, function(value)
    ESP_Settings.MaxDistance = value
end)

VisualsTab:Dropdown("ESP Mode", {"Team Mode", "FFA Mode"}, "Team Mode", function(v)
    ESP_Settings.Mode = v
end)

local colorMap = {
    Red = Color3.fromRGB(255, 65, 65),
    Green = Color3.fromRGB(65, 255, 130),
    Blue = Color3.fromRGB(80, 180, 255),
    Yellow = Color3.fromRGB(255, 240, 60),
    White = Color3.fromRGB(255, 255, 255),
    Pink = Color3.fromRGB(255, 100, 180)
}
local colorNames = {"Red", "Green", "Blue", "Yellow", "White", "Pink"}

VisualsTab:Dropdown("Enemy Color (or FFA)", colorNames, "Red", function(v)
    ESP_Settings.Colors.Enemy = colorMap[v]
end)

VisualsTab:Dropdown("Team Color", colorNames, "Green", function(v)
    ESP_Settings.Colors.Team = colorMap[v]
end)
-- ==================== UI INTERFACE ====================

----------------------------------------------------------------
-- XRAY (Major fix - cache + limit)
----------------------------------------------------------------
VisualsTab:Label("XRay Tool ⛏")

local xrayEnabled = false
local xrayParts = {}
local xrayConn = nil

local function updateXrayCache()
    xrayParts = {}
    local success, desc = pcall(Workspace.GetDescendants, Workspace)
    if not success then return end

    for i = 1, math.min(#desc, 1500) do -- HARD LIMIT
        local v = desc[i]
        if v:IsA("BasePart") then
            local parent = v.Parent
            if not (parent and parent:FindFirstChildWhichIsA("Humanoid")) then
                table.insert(xrayParts, v)
            end
        end
    end
end

VisualsTab:Toggle("XRay On/Off", false, function(state)
    xrayEnabled = state
    if state then
        updateXrayCache()
        xrayConn = RunService.RenderStepped:Connect(function()
            for i = 1, #xrayParts do
                local p = xrayParts[i]
                if p and p.Parent then
                    pcall(function() p.LocalTransparencyModifier = 0.5 end)
                end
            end
        end)
    else
        if xrayConn then xrayConn:Disconnect() end
        for _, p in ipairs(xrayParts) do
            pcall(function() p.LocalTransparencyModifier = 0 end)
        end
    end
end)

VisualsTab:Button("Refresh XRay Cache", function()
    if xrayEnabled then
        updateXrayCache()
        Notify("XRay cache refreshed", 2)
    end
end)


-- freecam (camera flight)
local freecamEnabled = false
local freecamLoop = nil
local freecamCFrame = nil

local function toggleFreecam(state)
    freecamEnabled = state
    if freecamEnabled then
        freecamCFrame = Camera.CFrame
        Camera.CameraType = Enum.CameraType.Scriptable
        
        freecamLoop = RunService.RenderStepped:Connect(function(dt)
            local speed = 50
            local moveDir = Vector3.zero
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
            
            freecamCFrame = freecamCFrame + (moveDir * speed * dt)
            Camera.CFrame = freecamCFrame
        end)
    else
        if freecamLoop then freecamLoop:Disconnect() end
        Camera.CameraType = Enum.CameraType.Custom
        local hum = getPlayerHumanoid()
        if hum then Camera.CameraSubject = hum end
    end
end

-- Интеграция в UI:
VisualsTab:Toggle("Freecam (Camera Flight)", false, toggleFreecam)

VisualsTab:Label("More in future updates...")

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- GAME SPECIFIC TOOLS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
BypassTab:Label("Game Specific Tools ⸘")

-- SPIN
local spinSpeed = 10
local Spin = { Conn = nil }

BypassTab:Slider("Spin Speed x100", 10, 100, 20, function(value)
    spinSpeed = value * 100
end)
BypassTab:Toggle("Spin On/Off", false, function(State)
    if State then
        local p = getPlayerObject()
        if p then
            local rp = p:FindFirstChild("HumanoidRootPart")
            if rp then
                if Spin.Conn then Spin.Conn:Disconnect() end
                Spin.Conn = RunService.Heartbeat:Connect(function()
                    if rp and rp.Parent then
                        rp.CFrame = rp.CFrame * CFrame.Angles(0, math.rad(spinSpeed) * (1/60), 0)
                    end
                end)
            end
        end
    else
        if Spin.Conn then Spin.Conn:Disconnect() Spin.Conn = nil end
    end
end)

BypassTab:Separator()

-- INVISIBLE FLING
local walkflinging = false
local flingConnection = nil
local flingBodyVelocity = nil
local flingBodyAngularVelocity = nil

local function toggleFlingPhysics(state)
    local root = getRootPart()
    if not root then return end

    if state then
        -- Создаем бешеную угловую скорость (заставляет хитбокс крутиться на уровне физики)
        if not flingBodyAngularVelocity or not flingBodyAngularVelocity.Parent then
            flingBodyAngularVelocity = Instance.new("BodyAngularVelocity")
            flingBodyAngularVelocity.Name = "FlingAngular"
            flingBodyAngularVelocity.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            flingBodyAngularVelocity.AngularVelocity = Vector3.new(0, 999999, 0) -- Высокая скорость вращения по оси Y
            flingBodyAngularVelocity.Parent = root
        end

        -- Удерживаем персонажа от улетания в небо или падения
        if not flingBodyVelocity or not flingBodyVelocity.Parent then
            flingBodyVelocity = Instance.new("BodyVelocity")
            flingBodyVelocity.Name = "FlingLinear"
            flingBodyVelocity.MaxForce = Vector3.new(math.huge, 0, math.huge) -- Запрещаем изменять высоту (Y = 0)
            flingBodyVelocity.Velocity = Vector3.new(0, 0, 0)
            flingBodyVelocity.Parent = root
        end

        -- Основной цикл симуляции столкновений через Heartbeat
        flingConnection = RunService.Heartbeat:Connect(function()
            if not walkflinging then
                if flingConnection then flingConnection:Disconnect() flingConnection = nil end
                return
            end

            local currentRoot = getRootPart()
            local hum = getPlayerHumanoid()
            
            if currentRoot and hum then
                -- Устанавливаем огромную линейную скорость по бокам на долю секунды, чтобы сломать хитбокс врага при касании
                currentRoot.Velocity = Vector3.new(9999, 0, 9999)
                
                -- Маскируем движение для сервера (симулируем падение/вставание)
                hum:ChangeState(Enum.HumanoidStateType.Physics)
                
                -- Делаем так, чтобы детали не сталкивались с твоими аксессуарами
                for _, part in ipairs(character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        -- Полная очистка при выключении флинга
        if flingConnection then flingConnection:Disconnect() flingConnection = nil end
        if flingBodyAngularVelocity then flingBodyAngularVelocity:Destroy() flingBodyAngularVelocity = nil end
        if flingBodyVelocity then flingBodyVelocity:Destroy() flingBodyVelocity = nil end
        
        -- Возвращаем нормальное состояние Humanoid
        local hum = getPlayerHumanoid()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
end

BypassTab:Toggle("Invisible Fling", false, function(State)
    walkflinging = State
    toggleFlingPhysics(State)
end)

BypassTab:Separator()

-- TELEPORT TOOLS
BypassTab:Label("Teleport Tools ✈")

local function GetPlayerNames()
    local names = {}
    for _, player in pairs(Players:GetPlayers()) do
        table.insert(names, player.Name)
    end
    return names
end

local function teleportToPlayer(targetPlayer)
    local character = player.Character
    local targetCharacter = targetPlayer and targetPlayer.Character

    if character and targetCharacter then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        local targetRootPart = targetCharacter:FindFirstChild("HumanoidRootPart")

        if rootPart and targetRootPart then
            rootPart.CFrame = targetRootPart.CFrame + Vector3.new(0, 5, 0)
        end
    end
end

local playerList = GetPlayerNames()
local PlayerSelector = BypassTab:Dropdown("Choose Player", playerList, playerList[1] or "None", function(selected)
    local target = Players:FindFirstChild(selected)
    teleportToPlayer(target)
end)

local function RefreshPlayerList()
    local currentPlayers = GetPlayerNames()
    if PlayerSelector and PlayerSelector.Refresh then
        PlayerSelector:Refresh(currentPlayers)
    end
end

Players.PlayerAdded:Connect(function()
    task.wait(1)
    RefreshPlayerList()
end)
Players.PlayerRemoving:Connect(RefreshPlayerList)


-- Click Teleport
local clickTPEnabled = false
local tpKeyConnection = nil

local function toggleClickTP(state)
    clickTPEnabled = state
    if clickTPEnabled then
        tpKeyConnection = UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            -- Срабатывает при зажатом LeftControl + Клик левой кнопкой мыши
            if input.UserInputType == Enum.UserInputType.MouseButton1 and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                local mouse = player:GetMouse()
                local root = getRootPart()
                if root and mouse.Target then
                    -- Перемещаем чуть выше точки клика, чтобы не застрять в текстурах
                    root.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
                end
            end
        end)
    else
        if tpKeyConnection then
            tpKeyConnection:Disconnect()
            tpKeyConnection = nil
        end
    end
end

BypassTab:Toggle("Ctrl + Click Teleport", false, toggleClickTP)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- MASTER FUNCTIONS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
MasterFuncTab:Label("☢ Master Functions ☢")

local GlobalMode
MasterFuncTab:Dropdown("Global Target Mode", {"Team Mode", "FFA Mode"}, "Team Mode", function(v)
    GlobalMode = v
end)

local GlobalRadius = 100
MasterFuncTab:Slider("Global Aim Fov", 50, 600, 100, function(v)
    GlobalRadius = v
end)
MasterFuncTab:Separator()



-- AIMBOT
local AIM_SETTINGS = {
    Enabled = false,
    Key = Enum.UserInputType.MouseButton2,
    Part = "Head",
    Smoothness = 0.4,
    ShowFOV = true,
    AggressiveMode = false,
    WallCheck = true, -- only for aggressive
    MaxDistance = 500
}

local isPressing = false
local fovCircle = nil

-- Создание круга FOV (остается без изменений)
local function createFovCircle()
    if fovCircle then fovCircle:Remove() end
    fovCircle = Drawing.new("Circle")
    fovCircle.Thickness = 1
    fovCircle.NumSides = 64
    fovCircle.Filled = false
    fovCircle.Transparency = 1
    fovCircle.Visible = false
end

local function getColor(speed)
    local hue = (tick() * (speed or 0.5)) % 1
    return Color3.fromHSV(hue, 1, 1)
end

-- Поиск ближайшего игрока к курсору (остается без изменений)
local function getClosestToMouse()
    local target = nil
    local dist = GlobalRadius
    local currentMode = GlobalMode  -- локальная копия для скорости

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == player then continue end
        
        -- Отсев союзников в Team Mode
        if currentMode == "Team Mode" and player.Team and plr.Team then
            if plr.Team == player.Team then
                continue  -- пропускаем союзника
            end
        end
        
        local char = plr.Character
        if not char then continue end
        
        local part = char:FindFirstChild(AIM_SETTINGS.Part) or char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        
        if part and hum and hum.Health > 0 then
            local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen then
                local mouse = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                local magnitude = (Vector2.new(screenPos.X, screenPos.Y) - mouse).Magnitude
                if magnitude < dist then
                    target = part
                    dist = magnitude
                end
            end
        end
    end
    return target
end

-- Поиск ближайшего игрока с учётом стен и дистанции
local function getClosestTargetAggressive()
    local bestTarget = nil
    local bestDistance = math.huge
    local cameraPos = Camera.CFrame.Position

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == player then continue end

        -- Отсев союзников в Team Mode
        if GlobalMode == "Team Mode" and player.Team and plr.Team then
            if plr.Team == player.Team then continue end
        end

        local char = plr.Character
        if not char then continue end

        local targetPart = char:FindFirstChild(AIM_SETTINGS.Part) or char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not targetPart or not hum or hum.Health <= 0 then continue end

        -- Проверка дистанции
        local distance = (cameraPos - targetPart.Position).Magnitude
        if distance > AIM_SETTINGS.MaxDistance then continue end

        -- Проверка стен (Raycast)
        if AIM_SETTINGS.WallCheck then
            local ray = Ray.new(cameraPos, (targetPart.Position - cameraPos).Unit * distance)
            local hit, hitPos = Workspace:FindPartOnRay(ray, player.Character)
            if hit and not hit:IsDescendantOf(char) then
                continue -- стена блокирует
            end
        end

        if distance < bestDistance then
            bestDistance = distance
            bestTarget = targetPart
        end
    end
    return bestTarget
end

createFovCircle()

-- Отслеживание нажатия кнопки
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == AIM_SETTINGS.Key then
        isPressing = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == AIM_SETTINGS.Key then
        isPressing = false
    end
end)

-- Основной цикл RenderStepped
RunService.RenderStepped:Connect(function()
    -- Отрисовка FOV (только если не агрессивный режим)
    if not AIM_SETTINGS.AggressiveMode and fovCircle and fovCircle.Visible then
        fovCircle.Radius = GlobalRadius
        fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        fovCircle.Color = getColor(0.5)
    elseif AIM_SETTINGS.AggressiveMode and fovCircle then
        fovCircle.Visible = false -- скрываем круг в агрессивном режиме
    end

    if not AIM_SETTINGS.Enabled or not isPressing then return end

    local targetPart = nil
    if AIM_SETTINGS.AggressiveMode then
        targetPart = getClosestTargetAggressive()
    else
        targetPart = getClosestToMouse() -- ваша старая функция
    end

    if targetPart then
        local targetPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
        if onScreen then
            local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            local deltaX = targetPos.X - screenCenter.X
            local deltaY = targetPos.Y - screenCenter.Y
            local moveX = deltaX * AIM_SETTINGS.Smoothness
            local moveY = deltaY * AIM_SETTINGS.Smoothness
            if mousemoverel then
                mousemoverel(moveX, moveY)
            end
        end
    end
end)

MasterFuncTab:Toggle("Master Aim", false, function(state)
    AIM_SETTINGS.Enabled = state
    if fovCircle then
        fovCircle.Visible = state and AIM_SETTINGS.ShowFOV
    end
end)

MasterFuncTab:Slider("Aim Smooth", 1, 5, 4, function(v)
    AIM_SETTINGS.Smoothness = v / 10
end)

MasterFuncTab:Dropdown("Target Part", {"Head", "UpperTorso", "HumanoidRootPart"}, "Head", function(v)
    AIM_SETTINGS.Part = v
end)

MasterFuncTab:Toggle("Aggressive Mode (360° + WallCheck)", false, function(state)
    AIM_SETTINGS.AggressiveMode = state
    if state then
        -- В агрессивном режиме FOV не нужен
        if fovCircle then fovCircle.Visible = false end
    else
        if fovCircle and AIM_SETTINGS.ShowFOV then fovCircle.Visible = true end
    end
end)

MasterFuncTab:Separator()

----------------------------------------------------------------
MasterFuncTab:Label("Trigger Bot 🎯")

local TriggerSettings = {
    Enabled = false,
    Mode = GlobalMode, -- "Team Mode" или "FFA Mode"
    Delay = 0,          -- Задержка перед выстрелом в секундах
    MaxDistance = 1000  -- Максимальная дистанция работы триггербота
}

-- Кэшируем мышь локального игрока
local Mouse = player:GetMouse()

-- Функция проверки: является ли объект частью живого противника
local function checkTarget(target)
    if not target or not target:IsDescendantOf(Workspace) then return nil end
    
    -- Ищем модель персонажа (обычно в ней находится Humanoid)
    local characterModel = target:FindFirstAncestorOfClass("Model")
    if not characterModel then return nil end
    
    local humanoid = characterModel:FindFirstChildOfClass("Humanoid")
    local rootPart = characterModel:FindFirstChild("HumanoidRootPart")
    
    -- Если структуры персонажа нет или он мертв — игнорируем
    if not humanoid or not rootPart or humanoid.Health <= 0 then return nil end
    
    -- Проверяем, какому игроку принадлежит персонаж
    local targetPlr = Players:GetPlayerFromCharacter(characterModel)
    if not targetPlr or targetPlr == player then return nil end
    
    -- Проверка дистанции
    local distance = (Camera.CFrame.Position - rootPart.Position).Magnitude
    if distance > TriggerSettings.MaxDistance then return nil end
    
    -- Проверка режимов FFA / Team Mode
    if TriggerSettings.Mode == "Team Mode" and player.Team and targetPlr.Team then
        if targetPlr.Team == player.Team then
            return nil -- Союзник, не стреляем
        end
    end
    
    return characterModel
end

-- Основной цикл триггербота
ConnectionManager:add("TriggerBot_Loop", RunService.RenderStepped:Connect(function()
    if not TriggerSettings.Enabled then return end
    
    -- Получаем объект, на который сейчас наведен курсор/прицел мыши
    local target = Mouse.Target
    local validCharacter = checkTarget(target)
    
    if validCharacter then
        -- Если выставлена задержка, ждем перед выстрелом
        if TriggerSettings.Delay > 0 then
            task.wait(TriggerSettings.Delay)
            -- Перепроверяем цель после ожидания, вдруг прицел уже ушел
            if Mouse.Target ~= target or not checkTarget(target) then return end
        end
        
        -- Симуляция клика мыши (Выстрел)
        -- Используем стандартные функции виртуального ввода Roblox эксплоитов
        if mouse1click then
            mouse1click()
        elseif mouse1press and mouse1release then
            mouse1press()
            task.wait(0.02)
            mouse1release()
        end
    end
end))

-- ==================== UI ЭЛЕМЕНТЫ УПРАВЛЕНИЯ ====================
MasterFuncTab:Toggle("Enable Trigger Bot", false, function(state)
    TriggerSettings.Enabled = state
end)

MasterFuncTab:Separator()

----------------------------------------------------------------
-- Wallbang

-- ====================== WALLBANG / WALLSHOT ======================
local SmartWallbang = {
    Enabled = false,
    CachedParts = {},
    IsShooting = false,
    Connection = nil
}

local function cacheMapParts()
    SmartWallbang.CachedParts = {}
    local count = 0
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            -- Пропускаем персонажей и важные объекты
            if not obj:FindFirstAncestorWhichIsA("Model") or 
               not obj:FindFirstAncestorWhichIsA("Humanoid") then
                
                if obj.CanCollide == true then
                    table.insert(SmartWallbang.CachedParts, obj)
                    count += 1
                end
            end
        end
    end
    
    Notify("Wallbang Cache: " .. count .. " объектов сохранено", 4)
    print("[Wallbang] Cached " .. count .. " parts")
end

local function setAllCollide(state)
    for _, part in ipairs(SmartWallbang.CachedParts) do
        pcall(function()
            if part and part.Parent then
                part.CanCollide = state
            end
        end)
    end
end

local function startWallbang()
    if SmartWallbang.Connection then return end
    
    cacheMapParts() -- Кэшируем карту один раз
    
    SmartWallbang.Connection = RunService.RenderStepped:Connect(function()
        if not SmartWallbang.Enabled then return end
        
        local isCurrentlyShooting = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
        
        if isCurrentlyShooting and not SmartWallbang.IsShooting then
            -- Нажали ЛКМ → убираем коллизию
            SmartWallbang.IsShooting = true
            setAllCollide(false)
            
        elseif not isCurrentlyShooting and SmartWallbang.IsShooting then
            -- Отпустили ЛКМ → возвращаем коллизию
            SmartWallbang.IsShooting = false
            setAllCollide(true)
        end
    end)
end

local function stopWallbang()
    if SmartWallbang.Connection then
        SmartWallbang.Connection:Disconnect()
        SmartWallbang.Connection = nil
    end
    
    -- Возвращаем всё как было
    setAllCollide(true)
    SmartWallbang.IsShooting = false
end

SmartWallbang.Toggle = function(state)
    SmartWallbang.Enabled = state
    
    if state then
        startWallbang()
        Notify("🧠 Wallbang включён (Cache Mode)", 4)
    else
        stopWallbang()
        Notify("🧠 Wallbang отключён", 3)
    end
end

MasterFuncTab:Label("Wallbang / Wallshot")

MasterFuncTab:Toggle("Wallbang (Cache + CanCollide)", false, function(state)
    SmartWallbang.Toggle(state)
end)

----------------------------------------------------------------
-- HITBOX EXPANDER
BigHeadcfg = {
    Enabled = false,
    Scale = 20,
    Mode = "Team Mode"
}

local function resetAllHeads()
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("Head") then
            local head = p.Character.Head
            head.Size = Vector3.new(1.2, 1.2, 1.2)
            head.Transparency = 0
            head.CanCollide = true
        end
    end
end

local function toggleHitbox(state)
    BigHeadcfg.Enabled = state
    
    if ConnectionManager.connections.Hitbox then 
        ConnectionManager.connections.Hitbox:Disconnect() 
        ConnectionManager.connections.Hitbox = nil
    end
    resetAllHeads()

    if BigHeadcfg.Enabled then
        ConnectionManager.add(ConnectionManager, "Hitbox", RunService.RenderStepped:Connect(function()
            for _, p in pairs(Players:GetPlayers()) do
                if p.UserId ~= player.UserId and p.Character and p.Character:FindFirstChild("Head") then
                    local head = p.Character.Head
                    local isEnemy = true

                    if BigHeadcfg.Mode == "Team Mode" then
                        if player.Team and p.Team then
                            if p.Team == player.Team then isEnemy = false end
                        elseif player.TeamColor == p.TeamColor then
                            isEnemy = false
                        end
                    end

                    if isEnemy then
                        head.Size = Vector3.new(BigHeadcfg.Scale, BigHeadcfg.Scale, BigHeadcfg.Scale)
                        head.Transparency = 0.7
                        head.CanCollide = false
                        head.Massless = true
                    else
                        head.Size = Vector3.new(1.2, 1.2, 1.2)
                        head.Transparency = 0
                    end
                end
            end
        end))
    end
end

MasterFuncTab:Label("Hitbox Expander 🧠")
MasterFuncTab:Slider("Hitbox Size", 15, 150, 20, function(value)
    BigHeadcfg.Scale = value
end)

MasterFuncTab:Dropdown("Hitbox Mode", {"FFA Mode", "Team Mode"}, "Team Mode", function(value)
    BigHeadcfg.Mode = value
    if BigHeadcfg.Enabled then
        toggleHitbox(true)
    end
end)

MasterFuncTab:Toggle("Hitbox Expander", false, toggleHitbox)

MasterFuncTab:Separator()
-- JERK OFF ANIMATION (because why not)

function r15(plr)
	if plr.Character:FindFirstChildOfClass("Humanoid").RigType == Enum.HumanoidRigType.R15 then
		return true
	end
end

MasterFuncTab:Toggle("Jerk", false, function(state)
    if state then 
        local humanoid = player.Character:FindFirstChildWhichIsA("Humanoid")
        local backpack = player:FindFirstChildWhichIsA("Backpack")
        if not humanoid or not backpack then return end

        local tool = Instance.new("Tool")
        tool.Name = "Jerk Off"
        tool.ToolTip = "in the stripped club. straight up \"jorking it\" . and by \"it\" , haha, well. let's justr say. My peanits."
        tool.RequiresHandle = false
        tool.Parent = backpack

        local jorkin = false
        local track = nil

        local function stopTomfoolery()
            jorkin = false
            if track then
                track:Stop()
                track = nil
            end
        end

        tool.Equipped:Connect(function() jorkin = true end)
        tool.Unequipped:Connect(stopTomfoolery)
        humanoid.Died:Connect(stopTomfoolery)

        while task.wait() do
            if not jorkin then continue end

            local isR15 = r15(player)
            if not track then
                local anim = Instance.new("Animation")
                anim.AnimationId = not isR15 and "rbxassetid://72042024" or "rbxassetid://698251653"
                track = humanoid:LoadAnimation(anim)
            end

            track:Play()
            track:AdjustSpeed(isR15 and 0.7 or 0.65)
            track.TimePosition = 0.6
            task.wait(0.1)
            while track and track.TimePosition < (not isR15 and 0.65 or 0.7) do task.wait(0.1) end
            if track then
                track:Stop()
                track = nil
            end
        end
    else
        local backpack = player:FindFirstChildWhichIsA("Backpack")
        if backpack then
            local tool = backpack:FindFirstChild("Jerk Off")
            if tool then tool:Destroy() end
        end
    end
end)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Blox Fruits
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
if game.PlaceId == 2753915549 then
    BloxFruitsTab:Label("Blox Fruits Tools 🍉")

    local FruitNames = {"Fruit", "fruit", "Fruit", "Apple", "Banana", "Cherry"}

    local function CreateFruitESP(obj)
        if not obj:FindFirstChild("FruitESP") then
            local highlight = Instance.new("Highlight")
            highlight.Name = "FruitESP"
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.Parent = obj
            
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "FruitLabel"
            billboard.Size = UDim2.new(0, 200, 0, 50)
            billboard.Adornee = obj
            billboard.AlwaysOnTop = true
            billboard.Parent = obj
            
            local text = Instance.new("TextLabel")
            text.Size = UDim2.new(1, 0, 1, 0)
            text.BackgroundTransparency = 1
            text.TextColor3 = Color3.new(1, 1, 1)
            text.TextStrokeTransparency = 0
            text.TextSize = 18
            text.Text = "🍎 " .. obj.Name
            text.Font = Enum.Font.GothamBold
            text.Parent = billboard
        end
    end

    local function ScanAndHop()
        local foundFruits = {}
        
        for _, v in pairs(workspace:GetChildren()) do
            local isFruit = false
            for _, name in pairs(FruitNames) do
                if v.Name and v.Name:lower():find(name:lower()) then
                    isFruit = true
                    break
                end
            end
            
            if isFruit then
                table.insert(foundFruits, v)
                CreateFruitESP(v)
            end
        end

        if #foundFruits > 0 then
            local fruitList = ""
            for _, f in pairs(foundFruits) do
                fruitList = fruitList .. f.Name .. ", "
            end
            Notify("Found fruits: " .. fruitList, 5)
        else
            Notify("No fruits found. Server hopping...", 3)
            task.wait(2)
            
            local Http = game:GetService("HttpService")
            local TPS = game:GetService("TeleportService")
            local PlaceId = game.PlaceId
            local JobId = game.JobId

            local function Hop()
                local success, servers = pcall(function()
                    return Http:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
                end)
                
                if success then
                    for _, server in pairs(servers.data) do
                        if server.playing < server.maxPlayers and server.id ~= JobId then
                            TPS:TeleportToPlaceInstance(PlaceId, server.id)
                            return
                        end
                    end
                end
            end
            Hop()
        end
    end

    BloxFruitsTab:Button("Start Fruit Hunter", ScanAndHop)
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- OTHER TOOLS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
OtherToolsTab:Label("Other Useful Tools")

OtherToolsTab:Button("Infinite Yield", function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
    Notify("Infinite Yield loaded", 5)
end)

OtherToolsTab:Button("Real Dex V4", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/peyton2465/Dex/master/out.lua"))()
    Notify("Dex V4 loaded", 5)
end)

OtherToolsTab:Label("Utility")

OtherToolsTab:Toggle("Anti-AFK", true, function(state)
    if state then
        ConnectionManager:add("AntiAFK", task.spawn(function()
            Notify("Anti-AFK включён ✓", 3)

            while true do
                local waitoffset = math.random(30, 60) -- рандом между 30 и 60 секундами
                local clickoffset = math.random(0, 1) -- рандом до 1 секунды для кликов

                task.wait(waitoffset) -- каждые 45 секунд
                
                pcall(function()
                    local vu = game:GetService("VirtualUser")
                    local camera = Workspace.CurrentCamera
                    
                    -- Основной метод
                    vu:Button2Down(Vector2.new(0,0), camera.CFrame)
                    task.wait(clickoffset)
                    vu:Button2Up(Vector2.new(0,0), camera.CFrame)
                    
                    -- Дополнительный метод (на всякий случай)
                    game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 0, 2, true, camera, 1)
                    task.wait(clickoffset + 0.1)
                    game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 0, 2, false, camera, 1)
                end)
            end
        end))
    else
        ConnectionManager:remove("AntiAFK")
        Notify("Anti-AFK выключен", 3)
    end
end)

OtherToolsTab:Button("FPS Booster", function()
    pcall(function()
        settings().Rendering.QualityLevel = 1
        settings().PerformanceStats.Enabled = false
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") then
                v.Enabled = false
            end
        end
        Notify("FPS Booster Activated ⚡", 3)
    end)
end)

OtherToolsTab:Button("FPS Booster (Strong)", function()
    local startTime = tick()
    
    -- Основные настройки рендеринга
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01  -- Самое низкое качество
    settings().PerformanceStats.Enabled = false
    
    local workspace = game:GetService("Workspace")
    local lighting = game:GetService("Lighting")
    
    -- Отключаем тяжёлые эффекты
    for _, v in ipairs(workspace:GetDescendants()) do
        pcall(function()
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                v.Enabled = false
            elseif v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
                if v.Transparency < 1 then
                    v.Transparency = math.max(v.Transparency, 0.1) -- лёгкое улучшение
                end
            end
        end)
    end
    
    -- Настройки Lighting
    lighting.GlobalShadows = false
    lighting.FogEnd = 100000
    lighting.Brightness = 1
    lighting.ClockTime = 12
    lighting.EnvironmentDiffuseScale = 0.2
    lighting.EnvironmentSpecularScale = 0.2
    
    -- Отключаем пост-эффекты
    for _, v in ipairs(lighting:GetDescendants()) do
        if v:IsA("PostEffect") or v:IsA("BloomEffect") or v:IsA("BlurEffect") or 
           v:IsA("ColorCorrectionEffect") or v:IsA("DepthOfFieldEffect") or 
           v:IsA("SunRaysEffect") then
            v.Enabled = false
        end
    end
    
    -- Дополнительная оптимизация
    pcall(function() 
        workspace.Terrain.WaterWaveSize = 0
        workspace.Terrain.WaterWaveSpeed = 0
        workspace.Terrain.WaterReflectance = 0
        workspace.Terrain.WaterTransparency = 1
    end)
    
    Notify("FPS Booster Activated ⚡\nКачество сильно снижено для максимального FPS", 4)
    
    print("FPS Booster applied in " .. string.format("%.2f", tick() - startTime) .. " seconds")
end)

OtherToolsTab:Label("More tools will be added in future updates!")

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SETTINGS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SettingsTab:Label("Settings")

SettingsTab:Button("Copy Game Link", function()
    local placeId = game.PlaceId
    local jobId = game.JobId:split("?")[1]
    local gameLink = "https://www.roblox.com/games/" .. placeId .. "/" .. "?jobId=" .. jobId
    pcall(function() setclipboard(gameLink) end)
    Notify("Game link copied!", 2)
end)

SettingsTab:Button("Server Crash (may not work)", function()
    local ts = game:GetService("TeleportService")
    ts:TeleportToPlaceInstance(game.PlaceId, "0", player)
end)

SettingsTab:Label("Server Tools ⛧")

SettingsTab:Button("Rejoin Server", function()
    local ts = game:GetService("TeleportService")
    ts:Teleport(game.PlaceId, player)
end)

local function ServerHop()
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    local Api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
    
    local function GetServers(cursor)
        local url = Api .. (cursor and "&cursor=" .. cursor or "")
        local success, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(url))
        end)
        if success and result then return result end
        return nil
    end

    local servers = GetServers()
    if servers then
        for _, server in pairs(servers.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id)
                return
            end
        end
    end
    Notify("No suitable server found", 3)
end


local autoRejoin = false

game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
    if autoRejoin and child.Name == "ErrorPrompt" and child:FindFirstChild("MessageArea") then
        task.wait(2) -- Даем игре закрыть старую сессию
        game:GetService("TeleportService"):Teleport(game.PlaceId, player)
    end
end)


SettingsTab:Button("Server Hop", ServerHop)

-- Интеграция в UI:
SettingsTab:Toggle("Auto Rejoin on Kick", false, function(state)
    autoRejoin = state
end)

SettingsTab:Label("Client Tools ⚙")

SettingsTab:Button("Enable old console (PC only)", function()
    local _, str = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/console.lua", true)
    end)
    local s, e = loadstring(str)
    if typeof(s) == "function" then
        pcall(s)
    end
end)

SettingsTab:Button("Reset Character", function()
    if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
        player.Character.Humanoid.Health = 0
    end
end)

local allThemes = GeminiLib:GetThemesList()
SettingsTab:Dropdown("Current Theme", allThemes, currentTheme, function(value)
    MenooWindow:ChangeTheme(value)
end)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CREDITS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CreditsTab:Label("Menoo ".. GeminiLib:Version() .. " by ")
CreditsTab:Label("nxs_Bounty - Developer")
CreditsTab:Label("Thanks to all supporters and testers!")
CreditsTab:Label("")

CreditsTab:Button("Discord Server Invite", function()
    setclipboard("https://discord.gg/nxsBounty")
    Notify("Discord invite copied!", 2)
end)

CreditsTab:Button("Join Roblox Group", function()
    setclipboard("https://www.roblox.com/groups/15142097")
    Notify("Group link copied!", 2)
end)

CreditsTab:Label("")
CreditsTab:Label("Thanks for using Menoo V6! Enjoy your time!")

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- INITIALIZATION
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
task.wait(0.5)

if MenooWindow.CreateFloatingButton then
    MenooWindow:CreateFloatingButton()
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.F5 then
        if MenooWindow.ToggleVisibility then
            MenooWindow:ToggleVisibility()
        end
    end
end)

Notify("Menoo V6 Loaded Successfully! Press F5 to toggle menu", 5)
