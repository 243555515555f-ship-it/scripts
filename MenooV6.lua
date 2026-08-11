-- Menoo Library V6 - FULLY OPTIMIZED & LAG-FIXED
local GeminiLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/243555515555f-ship-it/scripts/refs/heads/main/GeminiLib%20V6.lua"))()

-- Services & cached locals
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

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
    task.spawn(function()
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Система",
                Text = text,
                Duration = duration or 2
            })
        end)
    end)
end

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

----------------------------------------------------------------
-- PLAYER BYPASS (Optimized)
----------------------------------------------------------------

ConnectionManager:add("BypassLoop", RunService.Heartbeat:Connect(function()
    local hum = getPlayerHumanoid()
    if hum then
        if walkSpeedEnabled and hum.WalkSpeed ~= newWalkSpeed then
            hum.WalkSpeed = newWalkSpeed
        elseif not walkSpeedEnabled and hum.WalkSpeed ~= oldWalkSpeed then
            hum.WalkSpeed = oldWalkSpeed
        end
        if jumpPowerEnabled and hum.JumpPower ~= newJumpPower then
            hum.JumpPower = newJumpPower
        elseif not jumpPowerEnabled and hum.JumpPower ~= oldJumpPower then
            hum.JumpPower = oldJumpPower
        end
    end
end))

----------------------------------------------------------------
-- FLY SYSTEM
----------------------------------------------------------------

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
    if root then root.Anchored = false end

    local hum = getPlayerHumanoid()
    if hum then hum.PlatformStand = false end
end

----------------------------------------------------------------
-- NOCLIP (исправлено: отключаем коллизию у всех частей)
----------------------------------------------------------------

local noclipEnabled = false
local noclipConnection = nil

local function toggleNoclip(state)
    noclipEnabled = state

    if noclipEnabled then
        noclipConnection = RunService.Stepped:Connect(function()
            local char = player.Character
            if not char then return end

            -- Список частей для R6 и R15
            local partsToDisable = {
                "Head", "HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso",
                "LeftArm", "RightArm", "LeftLeg", "RightLeg"
            }

            for _, name in ipairs(partsToDisable) do
                local part = char:FindFirstChild(name)
                if part and part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
    end
end

----------------------------------------------------------------
-- GODMODE
----------------------------------------------------------------

local God = { Enabled = false, Conn = nil }
local function toggleGodmode(state)
    God.Enabled = state
    local hum = getPlayerHumanoid()
    if not hum then return end

    if God.Enabled then
        hum.MaxHealth = math.huge
        hum.Health = math.huge
    else
        hum.MaxHealth = 100
        hum.Health = 100
    end
end

----------------------------------------------------------------
-- INVISIBLE (улучшена защита, добавлен Force Reset)
----------------------------------------------------------------

local Invisible = {
    Enabled = false,
    Clone = nil,
    Original = nil,
    Loop = nil,
    BackupCFrame = nil
}

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

    char.Archivable = true
    local clone = char:Clone()
    clone.Name = "InvisPlayer"

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

    local anim = clone:FindFirstChild("Animate")
    if anim then anim.Disabled = true task.wait(0.05) anim.Disabled = false end

    Invisible.Loop = RunService.Heartbeat:Connect(function()
        pcall(function()
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = Invisible.BackupCFrame * CFrame.new(0, -500, 0)
                char.HumanoidRootPart.Velocity = Vector3.zero
            end

            if clone and clone:FindFirstChildOfClass("Humanoid") and char:FindFirstChildOfClass("Humanoid") then
                if char:FindFirstChildOfClass("Humanoid").Health <= 0 then
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
            local finalCFrame = clone:FindFirstChild("HumanoidRootPart") and clone.HumanoidRootPart.CFrame
            clone:Destroy()

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

-- Force Reset для Invisible (аварийное восстановление)
local function forceResetInvisible()
    pcall(function()
        if Invisible.Enabled then
            turnVisible()
        end
        -- Если что-то пошло не так, просто пересоздаём персонажа
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            player:LoadCharacter()
        end
        Notify("Invisible reset", 2)
    end)
end

----------------------------------------------------------------
-- ESP SYSTEM
----------------------------------------------------------------

local ESP_Settings = {
    Mode = "Team Mode",
    RainbowWave = false,
    MaxDistance = 1000,
    Colors = {
        Enemy = Color3.fromRGB(255, 65, 65),
        Team = Color3.fromRGB(65, 255, 130)
    }
}

local ESP_Storage = {
    Highlights = {},
    Names = {},
    Tracers = {},
    Boxes = {},
    HealthBars = {}
}

local GlobalRainbowColor = Color3.fromRGB(255, 255, 255)

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

local function removePlayerESP(plr)
    if ESP_Storage.Highlights[plr] then pcall(function() ESP_Storage.Highlights[plr]:Destroy() end) ESP_Storage.Highlights[plr] = nil end
    if ESP_Storage.Names[plr] then pcall(function() ESP_Storage.Names[plr]:Destroy() end) ESP_Storage.Names[plr] = nil end
    if ESP_Storage.Tracers[plr] then pcall(function() ESP_Storage.Tracers[plr]:Remove() end) ESP_Storage.Tracers[plr] = nil end
    if ESP_Storage.Boxes[plr] then pcall(function() ESP_Storage.Boxes[plr]:Remove() end) ESP_Storage.Boxes[plr] = nil end
    if ESP_Storage.HealthBars[plr] then pcall(function() ESP_Storage.HealthBars[plr]:Remove() end) ESP_Storage.HealthBars[plr] = nil end
end

local function clearCategory(key)
    for plr, obj in pairs(ESP_Storage[key]) do
        pcall(function() if obj.Remove then obj:Remove() else obj:Destroy() end end)
    end
    ESP_Storage[key] = {}
end

-- Добавляем недостающую опцию Distance (чтобы избежать ошибок)
local Options = { Highlight = false, Name = false, Tracer = false, Box = false, Health = false, Distance = false }

ConnectionManager:add("ESP_CoreLoop", RunService.RenderStepped:Connect(function()
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

        if not char or not root or not head or not hum or hum.Health <= 0 then
            removePlayerESP(plr)
            continue
        end

        local distance = (myRoot.Position - root.Position).Magnitude
        if distance > ESP_Settings.MaxDistance then
            removePlayerESP(plr)
            continue
        end

        local boxSize = Vector3.new(4, 6, 2)
        if hum.RigType == Enum.HumanoidRigType.R15 then
            local scaleH = char:FindFirstChild("BodyHeightScale") and char.BodyHeightScale.Value or 1
            local scaleW = char:FindFirstChild("BodyWidthScale") and char.BodyWidthScale.Value or 1
            boxSize = Vector3.new(4 * scaleW, 6 * scaleH, 2 * scaleW)
        end

        local topWorld = (root.CFrame * CFrame.new(0, boxSize.Y / 2, 0)).Position
        local bottomWorld = (root.CFrame * CFrame.new(0, -boxSize.Y / 2, 0)).Position

        local topPos, topOnScreen = Camera:WorldToViewportPoint(topWorld)
        local bottomPos, bottomOnScreen = Camera:WorldToViewportPoint(bottomWorld)

        local onScreen = topPos.Z > 0 or bottomPos.Z > 0
        if not onScreen then
            removePlayerESP(plr)
            continue
        end

        local height = math.abs(topPos.Y - bottomPos.Y)
        local width = height * (boxSize.X / boxSize.Y)

        local minY = math.min(topPos.Y, bottomPos.Y)
        local currentSubColor = getESPColor(plr)

        -- Highlight
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

        -- Name
        if Options.Name then
            local bGui = ESP_Storage.Names[plr]
            if not bGui or bGui.Parent ~= root then
                if bGui then pcall(function() bGui:Destroy() end) end
                bGui = Instance.new("BillboardGui")
                bGui.Name = "ESPNameGui"
                bGui.Adornee = root
                bGui.Size = UDim2.new(10, 0, 3, 0)
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

                bGui.Parent = root
                ESP_Storage.Names[plr] = bGui
            end

            bGui.StudsOffset = Vector3.new(0, (boxSize.Y / 2) + 0.6, 0)

            local label = bGui:FindFirstChild("NameLabel")
            if label then
                label.TextColor3 = currentSubColor
                if Options.Distance then
                    label.Text = string.format("%s [%.0f]", plr.Name, distance)
                else
                    label.Text = plr.Name
                end
            end
        end

        -- Tracers
        if Options.Tracer and bottomOnScreen then
            if not ESP_Storage.Tracers[plr] then
                local line = Drawing.new("Line")
                line.Thickness = 1.5
                line.Transparency = 0.8
                ESP_Storage.Tracers[plr] = line
            end
            local line = ESP_Storage.Tracers[plr]
            line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            line.To = Vector2.new(bottomPos.X, bottomPos.Y)
            line.Color = currentSubColor
            line.Visible = true
        else
            if ESP_Storage.Tracers[plr] then ESP_Storage.Tracers[plr].Visible = false end
        end

        -- Box
        if Options.Box and (topOnScreen or bottomOnScreen) then
            if not ESP_Storage.Boxes[plr] then
                local sq = Drawing.new("Square")
                sq.Thickness = 1.5
                sq.Filled = false
                sq.Transparency = 0.8
                ESP_Storage.Boxes[plr] = sq
            end
            local box = ESP_Storage.Boxes[plr]
            box.Size = Vector2.new(width, height)
            box.Position = Vector2.new(topPos.X - width / 2, minY)
            box.Color = currentSubColor
            box.Visible = true
        else
            if ESP_Storage.Boxes[plr] then ESP_Storage.Boxes[plr].Visible = false end
        end

        -- Health Bar
        if Options.Health and (topOnScreen or bottomOnScreen) then
            if not ESP_Storage.HealthBars[plr] then
                local bar = Drawing.new("Square")
                bar.Filled = true
                bar.Thickness = 1
                bar.Transparency = 0.7
                ESP_Storage.HealthBars[plr] = bar
            end
            local bar = ESP_Storage.HealthBars[plr]
            local hpPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)

            bar.Size = Vector2.new(4, height * hpPercent)
            bar.Position = Vector2.new(topPos.X - width / 2 - 6, minY + (height * (1 - hpPercent)))

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

    if not Options.Highlight then clearCategory("Highlights") end
    if not Options.Name then clearCategory("Names") end
    if not Options.Tracer then clearCategory("Tracers") end
    if not Options.Box then clearCategory("Boxes") end
    if not Options.Health then clearCategory("HealthBars") end
end))

-- Очистка при уходе игрока
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

local colorNames = {"Red", "Green", "Blue", "Yellow", "White", "Pink"}

----------------------------------------------------------------
-- XRAY
----------------------------------------------------------------

local xrayEnabled = false
local xrayParts = {}
local xrayConn = nil

local function updateXrayCache()
    xrayParts = {}
    local success, desc = pcall(Workspace.GetDescendants, Workspace)
    if not success then return end

    for i = 1, math.min(#desc, 1500) do
        local v = desc[i]
        if v:IsA("BasePart") then
            local parent = v.Parent
            if not (parent and parent:FindFirstChildWhichIsA("Humanoid")) then
                table.insert(xrayParts, v)
            end
        end
    end
end

-- freecam
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

-- SPIN
local spinSpeed = 10
local Spin = { Conn = nil }

-- INVISIBLE FLING
local walkflinging = false
local flingConnection = nil
local flingBodyVelocity = nil
local flingBodyAngularVelocity = nil
local flingBodyGyro = nil

local function toggleFlingPhysics(state)
    local root = getRootPart()
    if not root then return end

    if state then
        if not flingBodyAngularVelocity or not flingBodyAngularVelocity.Parent then
            flingBodyAngularVelocity = Instance.new("BodyAngularVelocity")
            flingBodyAngularVelocity.Name = "FlingAngular"
            flingBodyAngularVelocity.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            flingBodyAngularVelocity.AngularVelocity = Vector3.new(0, 999999, 0)
            flingBodyAngularVelocity.Parent = root
        end

        if not flingBodyVelocity or not flingBodyVelocity.Parent then
            flingBodyVelocity = Instance.new("BodyVelocity")
            flingBodyVelocity.Name = "FlingLinear"
            flingBodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
            flingBodyVelocity.Velocity = Vector3.new(0, 0, 0)
            flingBodyVelocity.Parent = root
        end

        if not flingBodyGyro or not flingBodyGyro.Parent then
            flingBodyGyro = Instance.new("BodyGyro")
            flingBodyGyro.Name = "FlingGyro"
            flingBodyGyro.MaxTorque = Vector3.new(math.huge, 0, math.huge)
            flingBodyGyro.CFrame = CFrame.new()
            flingBodyGyro.Parent = root
        end

        flingConnection = RunService.Heartbeat:Connect(function()
            if not walkflinging then
                if flingConnection then flingConnection:Disconnect() flingConnection = nil end
                return
            end

            local currentRoot = getRootPart()
            local hum = getPlayerHumanoid()

            if currentRoot and hum then
                if hum.MoveDirection.Magnitude > 0 then
                    currentRoot.AssemblyLinearVelocity = hum.MoveDirection * 15000
                else
                    currentRoot.AssemblyLinearVelocity = Vector3.new(15000, 0, 15000)
                end

                hum:ChangeState(Enum.HumanoidStateType.Physics)

                for _, part in ipairs(character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if flingConnection then flingConnection:Disconnect() flingConnection = nil end
        if flingBodyAngularVelocity then flingBodyAngularVelocity:Destroy() flingBodyAngularVelocity = nil end
        if flingBodyVelocity then flingBodyVelocity:Destroy() flingBodyVelocity = nil end
        if flingBodyGyro then flingBodyGyro:Destroy() flingBodyGyro = nil end

        local hum = getPlayerHumanoid()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
end

-- TELEPORT TOOLS
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

-- Ссылка на дропдаун для обновления списка
local playerDropdown = nil

local function RefreshPlayerList()
    local currentPlayers = GetPlayerNames()
    if playerDropdown and playerDropdown.Set then
        pcall(function()
            GeminiLib:updateDropdownOptions(playerDropdown, currentPlayers)
        end)
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
            if input.UserInputType == Enum.UserInputType.MouseButton1 and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                local mouse = player:GetMouse()
                local root = getRootPart()
                if root and mouse.Target then
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

----------------------------------------------------------------
-- MASTER FUNCTIONS
----------------------------------------------------------------
local GlobalMode = "Team Mode"
local GlobalRadius = 100

-- AIMBOT
local AIM_SETTINGS = {
    Enabled = false,
    Key = Enum.UserInputType.MouseButton2,
    Part = "Head",
    Smoothness = 0.4,
    ShowFOV = true,
    AggressiveMode = false,
    WallCheck = true,
    MaxDistance = 500
}

local isPressing = false
local fovCircle = nil

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

local function getClosestToMouse()
    local target = nil
    local dist = GlobalRadius
    local currentMode = GlobalMode

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == player then continue end

        if currentMode == "Team Mode" and player.Team and plr.Team then
            if plr.Team == player.Team then continue end
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

local function getClosestTargetAggressive()
    local bestTarget = nil
    local bestDistance = math.huge
    local cameraPos = Camera.CFrame.Position

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == player then continue end

        if GlobalMode == "Team Mode" and player.Team and plr.Team then
            if plr.Team == player.Team then continue end
        end

        local char = plr.Character
        if not char then continue end

        local targetPart = char:FindFirstChild(AIM_SETTINGS.Part) or char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not targetPart or not hum or hum.Health <= 0 then continue end

        local distance = (cameraPos - targetPart.Position).Magnitude
        if distance > AIM_SETTINGS.MaxDistance then continue end

        if AIM_SETTINGS.WallCheck then
            local ray = Ray.new(cameraPos, (targetPart.Position - cameraPos).Unit * distance)
            local hit = Workspace:FindPartOnRay(ray, player.Character)
            if hit and not hit:IsDescendantOf(char) then
                continue
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

RunService.RenderStepped:Connect(function()
    if not AIM_SETTINGS.AggressiveMode and fovCircle and fovCircle.Visible then
        fovCircle.Radius = GlobalRadius
        fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        fovCircle.Color = getColor(0.5)
    elseif AIM_SETTINGS.AggressiveMode and fovCircle then
        fovCircle.Visible = false
    end

    if not AIM_SETTINGS.Enabled or not isPressing then return end

    local targetPart = nil
    if AIM_SETTINGS.AggressiveMode then
        targetPart = getClosestTargetAggressive()
    else
        targetPart = getClosestToMouse()
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

----------------------------------------------------------------
-- TRIGGER BOT
----------------------------------------------------------------

local TriggerSettings = {
    Enabled = false,
    Mode = GlobalMode,
    Delay = 0,
    MaxDistance = 1000
}

local Mouse = player:GetMouse()

local function checkTarget(target)
    if not target or not target:IsDescendantOf(Workspace) then return nil end

    local characterModel = target:FindFirstAncestorOfClass("Model")
    if not characterModel then return nil end

    local humanoid = characterModel:FindFirstChildOfClass("Humanoid")
    local rootPart = characterModel:FindFirstChild("HumanoidRootPart")

    if not humanoid or not rootPart or humanoid.Health <= 0 then return nil end

    local targetPlr = Players:GetPlayerFromCharacter(characterModel)
    if not targetPlr or targetPlr == player then return nil end

    local distance = (Camera.CFrame.Position - rootPart.Position).Magnitude
    if distance > TriggerSettings.MaxDistance then return nil end

    if TriggerSettings.Mode == "Team Mode" and player.Team and targetPlr.Team then
        if targetPlr.Team == player.Team then
            return nil
        end
    end

    return characterModel
end

ConnectionManager:add("TriggerBot_Loop", RunService.RenderStepped:Connect(function()
    if not TriggerSettings.Enabled then return end

    local target = Mouse.Target
    local validCharacter = checkTarget(target)

    if validCharacter then
        if TriggerSettings.Delay > 0 then
            task.wait(TriggerSettings.Delay)
            if Mouse.Target ~= target or not checkTarget(target) then return end
        end

        if mouse1click then
            mouse1click()
        elseif mouse1press and mouse1release then
            mouse1press()
            task.wait(0.02)
            mouse1release()
        end
    end
end))

----------------------------------------------------------------
-- HITBOX EXPANDER
----------------------------------------------------------------

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

-- JERK OFF
function r15(plr)
    if plr.Character:FindFirstChildOfClass("Humanoid").RigType == Enum.HumanoidRigType.R15 then
        return true
    end
end

local function toggleJerk(state)
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
end

----------------------------------------------------------------
-- OTHER TOOLS
----------------------------------------------------------------

local antiAfkRunning = false

local function toggleAntiAfk(state)
    antiAfkRunning = state
    if state then
        task.spawn(function()
            while antiAfkRunning do
                task.wait(math.random(30, 60))
                if not antiAfkRunning then break end
                pcall(function()
                    local vu = game:GetService("VirtualUser")
                    vu:CaptureController()
                    vu:ClickButton2(Vector2.new())
                end)
            end
        end)
    end
end

local function fpsBoosterBasic()
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
end

local function fpsBoosterStrong()
    local startTime = tick()

    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    settings().PerformanceStats.Enabled = false

    local workspace = game:GetService("Workspace")
    local lighting = game:GetService("Lighting")

    for _, v in ipairs(workspace:GetDescendants()) do
        pcall(function()
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                v.Enabled = false
            elseif v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
                if v.Transparency < 1 then
                    v.Transparency = math.max(v.Transparency, 0.1)
                end
            end
        end)
    end

    lighting.GlobalShadows = false
    lighting.FogEnd = 100000
    lighting.Brightness = 1
    lighting.ClockTime = 12
    lighting.EnvironmentDiffuseScale = 0.2
    lighting.EnvironmentSpecularScale = 0.2

    for _, v in ipairs(lighting:GetDescendants()) do
        if v:IsA("PostEffect") or v:IsA("BloomEffect") or v:IsA("BlurEffect") or
           v:IsA("ColorCorrectionEffect") or v:IsA("DepthOfFieldEffect") or
           v:IsA("SunRaysEffect") then
            v.Enabled = false
        end
    end

    pcall(function()
        workspace.Terrain.WaterWaveSize = 0
        workspace.Terrain.WaterWaveSpeed = 0
        workspace.Terrain.WaterReflectance = 0
        workspace.Terrain.WaterTransparency = 1
    end)

    Notify("FPS Booster Activated ⚡\nКачество сильно снижено для максимального FPS", 4)

    print("FPS Booster applied in " .. string.format("%.2f", tick() - startTime) .. " seconds")
end

----------------------------------------------------------------
-- SETTINGS
----------------------------------------------------------------

function CopyGameLink()
    local placeId = game.PlaceId
    local jobId = game.JobId:split("?")[1]
    local gameLink = "https://www.roblox.com/games/" .. placeId .. "/" .. "?jobId=" .. jobId
    pcall(function() setclipboard(gameLink) end)
    Notify("Game link copied!", 2)
end

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
        task.wait(2)
        game:GetService("TeleportService"):Teleport(game.PlaceId, player)
    end
end)

----------------------------------------------------------------
-- INITIALIZATION
----------------------------------------------------------------

local Window = GeminiLib:CreateWindow("Osiris Script", "Minimal")

local BypassTab = Window:CreateTab("Bypass", "🛡")
local VisualsTab = Window:CreateTab("Visual Tools", "🎨")
local MasterFuncTab = Window:CreateTab("Master Functions", "⚙")
local OtherToolsTab = Window:CreateTab("Other Tools", "🔧")
local SettingsTab = Window:CreateTab("Settings", "⚙")

-- Groups
local PlayerGroup = BypassTab:CreateGroup("left", "Player Bypass Features", { icon = "♾️" })
local FlyGroup = BypassTab:CreateGroup("right", "Flight System", { icon = "✈" })
local NoclipGroup = BypassTab:CreateGroup("right", "Noclip System", { icon = "👻" })
local InvisibleGroup = BypassTab:CreateGroup("left", "Invisible System", { icon = "👤" })

local ESPGroup = VisualsTab:CreateGroup("left", "ESP Features", { icon = "👁" })
local XRAYGroup = VisualsTab:CreateGroup("right", "X-Ray Features", { icon = "🔍" })

local AimBotGroup = MasterFuncTab:CreateGroup("left", "AimBot Features", { icon = "🎯" })
local TriggerBotGroup = MasterFuncTab:CreateGroup("right", "Trigger Bot Features", { icon = "🎯" })
local HitboxGroup = MasterFuncTab:CreateGroup("left", "Hitbox Expander Features", { icon = "🧱" })

local MiscGroup = OtherToolsTab:CreateGroup("right", "Misc Visuals", { icon = "🎨" })
local ScriptsGroup = OtherToolsTab:CreateGroup("left", "Useful Scripts", { icon = "📜" })
local UtilsGroup = OtherToolsTab:CreateGroup("left", "Utility Tools", { icon = "🛠" })

local ClientGroup = SettingsTab:CreateGroup("right", "Client Settings", { icon = "⚙" })

-- Обработчик F5
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.F5 then
        Window:ToggleVisibility()
    end
end)

GeminiLib:CreateNotification({
    Title = "GUI Loaded",
    Text = "Press F5 to open/close.",
    Duration = 4
})

-- ==================== UI ЭЛЕМЕНТЫ ====================

-- PlayerGroup
PlayerGroup:Slider("WalkSpeed Bypass Value", 16, 200, oldWalkSpeed, function(value)
    newWalkSpeed = value
end, true)

PlayerGroup:Toggle("Enable WalkSpeed Bypass", false, function(state)
    walkSpeedEnabled = state
end)

PlayerGroup:Button("Jump Enable Bypass", function()
    local hum = getPlayerHumanoid()
    if hum then
        hum.UseJumpPower = true
        hum.AutoJumpEnabled = true
    end
end)

PlayerGroup:Slider("JumpPower Bypass Value", 50, 350, oldJumpPower, function(value)
    newJumpPower = value
end, true)

PlayerGroup:Toggle("JumpPower On/Off", false, function(state)
    jumpPowerEnabled = state
end)

PlayerGroup:Toggle("Godmode On/Off", false, function(state)
    toggleGodmode(state)
end)

-- FlyGroup
FlyGroup:Slider("Fly Speed", 20, 500, 80, function(v)
    Flight.Speed = v
end, true)

FlyGroup:Toggle("Enable Fly", false, function(state)
    if state then
        startBetterFly()
    else
        stopBetterFly()
    end
end)

-- NoclipGroup
NoclipGroup:Toggle("NoClip On/Off (may cause issues)", false, function(state)
    toggleNoclip(state)
end)

-- InvisibleGroup
InvisibleGroup:Toggle("Invisible On/Off", false, function(state)
    if state then
        local success, err = pcall(turnInvisible)
        if not success then
            warn("Invisible Error:", err)
            turnVisible()
        end
    else
        pcall(turnVisible)
    end
end)

-- Добавляем кнопку Force Reset
InvisibleGroup:Button("Force Reset Invisible", function()
    forceResetInvisible()
end)

-- ESPGroup
ESPGroup:Dropdown("ESP Preset", {"Off", "Box + Name", "Highlight + Name", "Box + Tracers", "Full"}, "Off", function(v)
    if v == "Off" then
        Options.Highlight = false; Options.Name = false; Options.Tracer = false
        Options.Box = false; Options.Health = false
    elseif v == "Box + Name" then
        Options.Highlight = false; Options.Name = true;  Options.Tracer = false
        Options.Box = true;       Options.Health = true
    elseif v == "Highlight + Name" then
        Options.Highlight = true; Options.Name = true;   Options.Tracer = true
        Options.Box = false;      Options.Health = false
    elseif v == "Box + Tracers" then
        Options.Highlight = false; Options.Name = false;  Options.Tracer = true
        Options.Box = true;        Options.Health = true
    elseif v == "Full" then
        Options.Highlight = true;  Options.Name = true;   Options.Tracer = true
        Options.Box = true;        Options.Health = true
    end
end)

ESPGroup:Toggle("Wave Rainbow Mode", false, function(state)
    ESP_Settings.RainbowWave = state
end)

ESPGroup:Slider("Max ESP Distance", 100, 1500, 200, function(value)
    ESP_Settings.MaxDistance = value
end, true)

ESPGroup:Dropdown("ESP Mode", {"Team Mode", "FFA Mode"}, "Team Mode", function(v)
    ESP_Settings.Mode = v
end)

local colorMap = {
    Red    = Color3.fromRGB(255, 65, 65),
    Green  = Color3.fromRGB(65, 255, 130),
    Blue   = Color3.fromRGB(80, 180, 255),
    Yellow = Color3.fromRGB(255, 240, 60),
    White  = Color3.fromRGB(255, 255, 255),
    Pink   = Color3.fromRGB(255, 100, 180)
}
local colorNames = {"Red", "Green", "Blue", "Yellow", "White", "Pink"}

ESPGroup:Dropdown("Enemy Color (or FFA)", colorNames, "Red", function(v)
    ESP_Settings.Colors.Enemy = colorMap[v]
end)

ESPGroup:Dropdown("Team Color", colorNames, "Green", function(v)
    ESP_Settings.Colors.Team = colorMap[v]
end)

-- XRAYGroup
XRAYGroup:Toggle("XRay On/Off", false, function(state)
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

XRAYGroup:Button("Refresh XRay Cache", function()
    if xrayEnabled then
        updateXrayCache()
        GeminiLib:CreateNotification({ Title = "XRay", Text = "Cache refreshed", Duration = 2 })
    end
end)

XRAYGroup:Toggle("Freecam (Camera Flight)", false, function(state)
    toggleFreecam(state)
end)

-- AimBotGroup
AimBotGroup:Slider("Global Aim Fov", 50, 600, 100, function(v)
    GlobalRadius = v
end, true)

AimBotGroup:Dropdown("Global Target Mode", {"Team Mode", "FFA Mode"}, "Team Mode", function(v)
    GlobalMode = v
end)

AimBotGroup:Toggle("Master Aim", false, function(state)
    AIM_SETTINGS.Enabled = state
    if fovCircle then
        fovCircle.Visible = state and AIM_SETTINGS.ShowFOV
    end
end)

AimBotGroup:Slider("Aim Smooth", 1, 5, 4, function(v)
    AIM_SETTINGS.Smoothness = v / 10
end, true)

AimBotGroup:Dropdown("Target Part", {"Head", "UpperTorso", "HumanoidRootPart"}, "Head", function(v)
    AIM_SETTINGS.Part = v
end)

AimBotGroup:Toggle("Aggressive Mode (360° + WallCheck)", false, function(state)
    AIM_SETTINGS.AggressiveMode = state
    if state then
        if fovCircle then fovCircle.Visible = false end
    else
        if fovCircle and AIM_SETTINGS.ShowFOV then fovCircle.Visible = true end
    end
end)

-- TriggerBotGroup
TriggerBotGroup:Toggle("Enable Trigger Bot", false, function(state)
    TriggerSettings.Enabled = state
end)

TriggerBotGroup:Slider("Trigger Delay (ms)", 0, 500, 0, function(value)
    TriggerSettings.Delay = value / 1000
end, true)

-- HitboxGroup
HitboxGroup:Slider("Hitbox Size", 15, 150, 20, function(value)
    BigHeadcfg.Scale = value
end, true)

HitboxGroup:Dropdown("Hitbox Mode", {"FFA Mode", "Team Mode"}, "Team Mode", function(value)
    BigHeadcfg.Mode = value
    if BigHeadcfg.Enabled then
        toggleHitbox(true)
    end
end)

HitboxGroup:Toggle("Hitbox Expander", false, function(state)
    toggleHitbox(state)
end)

-- Dropdown для выбора игрока (с динамическим обновлением)
local playerList = GetPlayerNames()
playerDropdown = HitboxGroup:Dropdown("Choose Player", playerList, playerList[1] or "None", function(selected)
    local target = Players:FindFirstChild(selected)
    teleportToPlayer(target)
end)

-- Обновление при изменении списка игроков
local function onPlayerListChanged()
    task.wait(0.5) -- небольшая задержка
    local playerList = GetPlayerNames()
    GeminiLib:updateDropdownOptions(playerDropdown, playerList)
end

Players.PlayerAdded:Connect(onPlayerListChanged)
Players.PlayerRemoving:Connect(onPlayerListChanged)

-- MiscGroup
MiscGroup:Slider("Spin Speed x100", 10, 100, 20, function(value)
    spinSpeed = value * 100
end, true)

MiscGroup:Toggle("Spin On/Off", false, function(state)
    if state then
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
        if Spin.Conn then Spin.Conn:Disconnect(); Spin.Conn = nil end
    end
end)

MiscGroup:Toggle("Invisible Fling", false, function(state)
    walkflinging = state
    toggleFlingPhysics(state)
end)

MiscGroup:Toggle("Ctrl + Click Teleport", false, function(state)
    toggleClickTP(state)
end)

MiscGroup:Toggle("Jerk", false, function(state)
    toggleJerk(state)
end)

-- UtilsGroup
UtilsGroup:Toggle("Anti-AFK", false, function(state)
    toggleAntiAfk(state)
end)

UtilsGroup:Button("FPS Booster", function()
    fpsBoosterBasic()
end)

UtilsGroup:Button("FPS Booster (Strong)", function()
    fpsBoosterStrong()
end)

-- ClientGroup
ClientGroup:Button("Copy Game Link", function()
    CopyGameLink()
end)

ClientGroup:Button("Rejoin Server", function()
    local ts = game:GetService("TeleportService")
    ts:Teleport(game.PlaceId, player)
end)

ClientGroup:Button("Server Hop", function()
    ServerHop()
end)

ClientGroup:Toggle("Auto Rejoin on Kick", false, function(state)
    autoRejoin = state
end)

ClientGroup:Button("Enable old console (PC only)", function()
    local success, str = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/console.lua", true)
    end)
    if success then
        local func, err = loadstring(str)
        if typeof(func) == "function" then
            pcall(func)
        end
    end
end)

ClientGroup:Button("Reset Character", function()
    if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
        player.Character.Humanoid.Health = 0
    end
end)

-- ScriptsGroup
ScriptsGroup:Button("Infinite Yield", function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
    GeminiLib:CreateNotification({ Title = "Script Loaded", Text = "Infinite Yield loaded", Duration = 2 })
end)

ScriptsGroup:Button("Real Dex V4", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/peyton2465/Dex/master/out.lua"))()
    GeminiLib:CreateNotification({ Title = "Script Loaded", Text = "Dex V4 loaded", Duration = 2 })
end)

-- Config system (заглушка)
local configName = "MyConfig"
UtilsGroup:Label("Config Name: " .. configName)

UtilsGroup:Button("Create Config", function()
    if configName == "" then
        GeminiLib:CreateNotification({ Title = "Error", Text = "Enter config name first", Duration = 3 })
        return
    end
    GeminiLib:CreateNotification({ Title = "Info", Text = "Config system not implemented in this library", Duration = 3 })
end)

UtilsGroup:Button("Save Config", function()
    GeminiLib:CreateNotification({ Title = "Info", Text = "Config system not implemented", Duration = 3 })
end)

UtilsGroup:Button("Load Config", function()
    GeminiLib:CreateNotification({ Title = "Info", Text = "Config system not implemented", Duration = 3 })
end)

UtilsGroup:Button("Delete Config", function()
    GeminiLib:CreateNotification({ Title = "Info", Text = "Config system not implemented", Duration = 3 })
end)

if not isfolder("OsirisCFGS") then
    makefolder("OsirisCFGS")
end
