-- GeminiLib V6.4.2 - WITH COLLAPSIBLE SECTIONS
local GeminiLib = {}

-- Кэшированные сервисы для оптимизации
local services = {
    UIS = game:GetService("UserInputService"),
    TweenService = game:GetService("TweenService"),
    RunService = game:GetService("RunService"),
    CoreGui = game:GetService("CoreGui"),
    HttpService = game:GetService("HttpService"),
    Players = game:GetService("Players"),
    Stats = game:GetService("Stats")
}

function GeminiLib:Version()
    return "V6.4.2"
end

-- УНИВЕРСАЛЬНАЯ СИСТЕМА ТЕМ
GeminiLib.Themes = {
    Dark = {
        Name = "Dark",
        Main = Color3.fromRGB(30, 30, 35),
        Accent = Color3.fromRGB(80, 170, 255),
        Secondary = Color3.fromRGB(100, 180, 255),
        Text = Color3.fromRGB(230, 230, 235),
        TextSecondary = Color3.fromRGB(160, 160, 170),
        Section = Color3.fromRGB(40, 40, 45),
        Element = Color3.fromRGB(50, 50, 55),
        Border = Color3.fromRGB(70, 70, 80),
        Shadow = Color3.fromRGB(0, 0, 0),
        ShadowAlpha = 0.25,
        Success = Color3.fromRGB(70, 220, 130),
        Warning = Color3.fromRGB(255, 190, 50),
        Error = Color3.fromRGB(240, 90, 90)
    },
    Midnight = {
        Name = "Midnight",
        Main = Color3.fromRGB(20, 20, 30),
        Accent = Color3.fromRGB(150, 100, 255),
        Secondary = Color3.fromRGB(130, 90, 230),
        Text = Color3.fromRGB(230, 230, 240),
        TextSecondary = Color3.fromRGB(170, 170, 190),
        Section = Color3.fromRGB(30, 30, 45),
        Element = Color3.fromRGB(40, 40, 60),
        Border = Color3.fromRGB(90, 90, 130),
        Shadow = Color3.fromRGB(0, 0, 0),
        ShadowAlpha = 0.3,
        Success = Color3.fromRGB(80, 220, 160),
        Warning = Color3.fromRGB(255, 180, 60),
        Error = Color3.fromRGB(255, 100, 100)
    },
    Cyberpunk = {
        Name = "Cyberpunk",
        Main = Color3.fromRGB(10, 15, 25),
        Accent = Color3.fromRGB(0, 220, 220),
        Secondary = Color3.fromRGB(200, 0, 200),
        Text = Color3.fromRGB(240, 245, 255),
        TextSecondary = Color3.fromRGB(180, 190, 220),
        Section = Color3.fromRGB(20, 25, 40),
        Element = Color3.fromRGB(30, 35, 55),
        Border = Color3.fromRGB(0, 180, 180),
        Shadow = Color3.fromRGB(0, 100, 255),
        ShadowAlpha = 0.25,
        Success = Color3.fromRGB(0, 230, 180),
        Warning = Color3.fromRGB(255, 230, 0),
        Error = Color3.fromRGB(255, 70, 70)
    },
    NeonAbyss = {
        Name = "NeonAbyss",
        Main = Color3.fromRGB(10, 10, 15),
        Accent = Color3.fromRGB(0, 255, 150),
        Secondary = Color3.fromRGB(255, 0, 100),
        Text = Color3.fromRGB(240, 255, 250),
        TextSecondary = Color3.fromRGB(130, 150, 140),
        Section = Color3.fromRGB(20, 25, 30),
        Element = Color3.fromRGB(25, 35, 40),
        Border = Color3.fromRGB(0, 255, 150),
        Shadow = Color3.fromRGB(0, 255, 150),
        ShadowAlpha = 0.2
    },
    Rampage = {
        Name = "Rampage",
        Main = Color3.fromRGB(107, 0, 0),
        Accent = Color3.fromRGB(140, 0, 0),
        Secondary = Color3.fromRGB(92, 10, 10),
        Text = Color3.fromRGB(255, 240, 240),
        TextSecondary = Color3.fromRGB(135, 64, 64),
        Section = Color3.fromRGB(18, 10, 10),
        Element = Color3.fromRGB(25, 12, 12),
        Border = Color3.fromRGB(200, 20, 20),
        Shadow = Color3.fromRGB(150, 0, 0),
        ShadowAlpha = 0.4,
        Success = Color3.fromRGB(255, 70, 70),
        Warning = Color3.fromRGB(255, 140, 0),
        Error = Color3.fromRGB(255, 0, 0)
    }
}

-- КОНФИГУРАЦИЯ
GeminiLib.Config = {
    WindowWidth = 800,
    WindowHeight = 600,
    Roundness = 12,
    EnableShadows = true,
    DefaultTheme = "Cyberpunk",
    MaxDropdownHeight = 300,
    StatsUpdateInterval = 1
}

-- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
local function createShadow(parent, color, transparency, sizeMultiplier)
    if not GeminiLib.Config.EnableShadows then return end
    
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Image = "rbxassetid://5554237735"
    shadow.ImageColor3 = color
    shadow.ImageTransparency = transparency or 0.7
    
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceScale = 0.05
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.Size = UDim2.new(1, sizeMultiplier or 8, 1, sizeMultiplier or 8)
    shadow.Position = UDim2.new(0, -(sizeMultiplier or 8)/2, 0, -(sizeMultiplier or 8)/2)
    shadow.BackgroundTransparency = 1
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Parent = parent
    return shadow
end

-- Класс для управления UI элементами
local UI = {}
function UI:Create(class, properties)
    local instance = Instance.new(class)
    for prop, value in pairs(properties) do
        if prop ~= "Parent" then
            if type(value) == "table" and value.ClassName then
                self:Create(value.ClassName, value):SetParent(instance)
            else
                instance[prop] = value
            end
        end
    end
    if properties.Parent then
        instance.Parent = properties.Parent
    end
    return instance
end

-- Функция возвращает простой массив строк с названиями всех тем
function GeminiLib:GetThemesList()
    local list = {}
    for themeName, _ in pairs(GeminiLib.Themes) do
        table.insert(list, themeName)
    end
    return list
end

-- ОСНОВНАЯ ФУНКЦИЯ СОЗДАНИЯ ОКНА
function GeminiLib:CreateWindow(title, themeName)
    local theme = GeminiLib.Themes[themeName] or GeminiLib.Themes[GeminiLib.Config.DefaultTheme]
    title = title .. " | by nxs_Bounty"

    local WindowObj = {
        Tabs = {},
        CurrentTab = nil,
        Theme = theme,
        Elements = {},
        Settings = {},
        IsMinimized = false,
        OriginalSize = UDim2.new(0, GeminiLib.Config.WindowWidth, 0, GeminiLib.Config.WindowHeight),
        OriginalPosition = nil,
        StatsConnection = nil,
        HiddenElements = {}
    }
    WindowObj.Connections = {}
    WindowObj.OpenDropdowns = {}

    -- Создаем ScreenGui
    local ScreenGui = UI:Create("ScreenGui", {
        Name = "GeminiLib_" .. services.HttpService:GenerateGUID(false):sub(1, 8),
        Parent = services.CoreGui,
        ResetOnSpawn = false
    })
    WindowObj.ScreenGui = ScreenGui

    -- Главный контейнер
    local Main = UI:Create("Frame", {
        Size = WindowObj.OriginalSize,
        Position = UDim2.new(0.5, -GeminiLib.Config.WindowWidth/2, 0.5, -GeminiLib.Config.WindowHeight/2),
        BackgroundColor3 = theme.Main,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 10,
        Parent = ScreenGui
    })
    WindowObj.OriginalPosition = Main.Position
    
    UI:Create("UICorner", {
        CornerRadius = UDim.new(0, GeminiLib.Config.Roundness),
        Parent = Main
    })
    
    createShadow(Main, theme.Shadow, theme.ShadowAlpha, 15)

    -- Верхняя панель
    local TopBar = UI:Create("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, 55),
        BackgroundColor3 = theme.Section,
        BackgroundTransparency = 0.4,
        ZIndex = 12,
        Parent = Main
    })
    
    UI:Create("UICorner", {
        CornerRadius = UDim.new(0, GeminiLib.Config.Roundness),
        Parent = TopBar
    })
    
    -- Легкий градиент
    UI:Create("UIGradient", {
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, theme.Accent),
            ColorSequenceKeypoint.new(0.5, theme.Section),
            ColorSequenceKeypoint.new(1, theme.Section)
        },
        Transparency = NumberSequence.new(0.8),
        Rotation = 90,
        Parent = TopBar
    })
    
    -- [ПЛАВНЫЙ DRAG]
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        local targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        services.TweenService:Create(Main, TweenInfo.new(0.15, Enum.EasingStyle.Cubic), {Position = targetPos}):Play()
    end

    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)

    services.UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(input)
        end
    end)

    services.UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Заголовок с FPS и Ping
    local Title = UI:Create("TextLabel", {
        Name = "Title",
        Text = "  " .. title,
        Size = UDim2.new(1, -280, 1, 0),
        TextColor3 = theme.Text,
        Font = Enum.Font.GothamMedium,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        ZIndex = 13,
        Parent = TopBar
    })

    -- FPS и Ping индикаторы
    local StatsLabel = UI:Create("TextLabel", {
        Name = "StatsLabel",
        Text = "FPS: -- | Ping: --",
        Size = UDim2.new(0, 140, 1, 0),
        Position = UDim2.new(1, -200, 0, 0),
        TextColor3 = theme.TextSecondary,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
        BackgroundTransparency = 1,
        ZIndex = 13,
        Parent = TopBar
    })

    -- Функция обновления статистики
    local lastUpdate = 0
    local function updateStats()
        local now = tick()
        if now - lastUpdate < GeminiLib.Config.StatsUpdateInterval then return end
        lastUpdate = now
        
        local fps = math.floor(1 / services.RunService.RenderStepped:Wait())
        local ping = math.random(20, 80)
        
        StatsLabel.Text = string.format("FPS: %d | Ping: %dms", fps, ping)
        
        if fps < 30 then
            StatsLabel.TextColor3 = theme.Error
        elseif fps < 60 then
            StatsLabel.TextColor3 = theme.Warning
        else
            StatsLabel.TextColor3 = theme.Success
        end
    end
    
    -- Запускаем обновление статистики
    local function startStatsUpdate()
        if WindowObj.StatsConnection then
            WindowObj.StatsConnection:Disconnect()
        end
        
        WindowObj.StatsConnection = services.RunService.RenderStepped:Connect(updateStats)
    end
    
    local function stopStatsUpdate()
        if WindowObj.StatsConnection then
            WindowObj.StatsConnection:Disconnect()
            WindowObj.StatsConnection = nil
        end
    end
    
    startStatsUpdate()

    -- Кнопка закрытия
    local CloseBtn = UI:Create("ImageButton", {
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -36, 0.5, -14),
        Image = "rbxassetid://6031094678",
        ImageColor3 = theme.Text,
        BackgroundTransparency = 1,
        ZIndex = 13,
        Parent = TopBar
    })

    table.insert(WindowObj.Connections, CloseBtn.MouseEnter:Connect(function()
        services.TweenService:Create(CloseBtn, TweenInfo.new(0.15), {
            ImageColor3 = theme.Error,
            Rotation = 90,
            Size = UDim2.new(0, 30, 0, 30)
        }):Play()
    end))
    
    table.insert(WindowObj.Connections, CloseBtn.MouseLeave:Connect(function()
        services.TweenService:Create(CloseBtn, TweenInfo.new(0.15), {
            ImageColor3 = theme.Text,
            Rotation = 0,
            Size = UDim2.new(0, 28, 0, 28)
        }):Play()
    end))
    
    table.insert(WindowObj.Connections, CloseBtn.MouseButton1Click:Connect(function()
        WindowObj:Destroy()
    end))

    -- Боковая панель для вкладок
    local SideBar = UI:Create("Frame", {
        Name = "SideBar",
        Size = UDim2.new(0, 170, 1, -65),
        Position = UDim2.new(0, 10, 0, 55),
        BackgroundColor3 = theme.Section,
        BackgroundTransparency = 0.6,
        ZIndex = 12,
        Parent = Main
    })
    
    UI:Create("UICorner", {
        CornerRadius = UDim.new(0, GeminiLib.Config.Roundness - 2),
        Parent = SideBar
    })
    
    UI:Create("UIStroke", {
        Color = theme.Accent,
        Thickness = 1,
        Transparency = 0.5,
        Parent = SideBar
    })
    
    -- Прокручиваемая область для вкладок
    local TabScroll = UI:Create("ScrollingFrame", {
        Name = "TabScroll",
        Size = UDim2.new(1, -10, 1, -80),
        Position = UDim2.new(0, 5, 0, 5),
        BackgroundTransparency = 1,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = theme.Accent,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ZIndex = 13,
        Parent = SideBar
    })
    
    UI:Create("UIListLayout", {
        Padding = UDim.new(0, 6),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = TabScroll
    })

    -- Профиль пользователя
    local ProfileFrame = UI:Create("Frame", {
        Name = "ProfileFrame",
        Size = UDim2.new(1, -10, 0, 60),
        Position = UDim2.new(0, 5, 1, -65),
        BackgroundColor3 = theme.Element,
        BackgroundTransparency = 0.4,
        ZIndex = 14,
        Parent = SideBar
    })

    UI:Create("UICorner", {
        CornerRadius = UDim.new(0, 10),
        Parent = ProfileFrame
    })
    
    UI:Create("UIStroke", {
        Color = theme.Accent,
        Thickness = 1,
        Transparency = 0.6,
        Parent = ProfileFrame
    })

    -- Аватар
    local Avatar = UI:Create("ImageLabel", {
        Name = "Avatar",
        Size = UDim2.new(0, 40, 0, 40),
        Position = UDim2.new(0, 8, 0.5, -20),
        BackgroundColor3 = theme.Main,
        ZIndex = 15,
        Parent = ProfileFrame
    })
    
    UI:Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = Avatar
    })

    -- Загружаем аватар
    local userId = services.Players.LocalPlayer.UserId
    local success, content = pcall(function()
        return services.Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
    end)
    if success then
        Avatar.Image = content
    else
        Avatar.Image = "rbxassetid://0"
    end

    -- Имя пользователя
    local usernameLabel = UI:Create("TextLabel", {
        Name = "Username",
        Text = services.Players.LocalPlayer.Name,
        Size = UDim2.new(1, -55, 0, 20),
        Position = UDim2.new(0, 55, 0, 10),
        TextColor3 = theme.Text,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 15,
        Parent = ProfileFrame
    })

    -- Декоративная линия под ником
    local decorText = UI:Create("TextLabel", {
        Name = "Decor",
        Text = "⊹⊱•••《 ✮ 》•••⊰⊹",
        Position = UDim2.new(0, 0, 0, 30),
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        TextColor3 = theme.Accent,
        TextSize = 10,
        Font = Enum.Font.GothamBold,
        TextScaled = false,
        TextWrapped = true,
        ZIndex = 15,
        Parent = ProfileFrame
    })

    local function updateDecor()
        local nameLength = string.len(services.Players.LocalPlayer.Name)
        local dotsCount = math.min(math.max(3, math.floor(nameLength / 4)), 8)
        local dots = string.rep("•", dotsCount)
        decorText.Text = string.format("⊹⊱%s《 ✮ 》%s⊰⊹", dots, dots)
    end
    
    updateDecor()

    -- Контейнер для контента вкладок
    local ContentContainer = UI:Create("Frame", {
        Name = "ContentContainer",
        Size = UDim2.new(1, -190, 1, -65),
        Position = UDim2.new(0, 185, 0, 55),
        BackgroundColor3 = theme.Section,
        BackgroundTransparency = 0.7,
        ZIndex = 12,
        Parent = Main
    })
    
    UI:Create("UICorner", {
        CornerRadius = UDim.new(0, GeminiLib.Config.Roundness - 2),
        Parent = ContentContainer
    })
    
    UI:Create("UIStroke", {
        Color = theme.Accent,
        Thickness = 1,
        Transparency = 0.6,
        Parent = ContentContainer
    })

    -- ФУНКЦИЯ СОЗДАНИЯ ВКЛАДКИ
    function WindowObj:CreateTab(name, icon)
        local TabBtn = UI:Create("TextButton", {
            Name = "TabBtn_" .. name,
            Size = UDim2.new(1, 0, 0, 38),
            BackgroundColor3 = theme.Element,
            BackgroundTransparency = 0.6,
            Text = (icon or "📱") .. "  " .. name,
            TextColor3 = theme.TextSecondary,
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 14,
            LayoutOrder = #WindowObj.Tabs + 1,
            Parent = TabScroll
        })
        
        UI:Create("UIPadding", {
            PaddingLeft = UDim.new(0, 12),
            Parent = TabBtn
        })
        
        UI:Create("UICorner", {
            CornerRadius = UDim.new(0, 8),
            Parent = TabBtn
        })
        
        -- Страница вкладки
        local Page = UI:Create("ScrollingFrame", {
            Name = "Page_" .. name,
            Size = UDim2.new(1, -15, 1, -15),
            Position = UDim2.new(0, 7.5, 0, 7.5),
            BackgroundTransparency = 1,
            Visible = false,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = theme.Accent,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            ZIndex = 13,
            Parent = ContentContainer
        })
        
        UI:Create("UIListLayout", {
            Padding = UDim.new(0, 10),
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = Page
        })
        
        UI:Create("UIPadding", {
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            Parent = Page
        })
        
        -- Объект вкладки
        local Tab = {
            Name = name,
            Page = Page,
            Button = TabBtn,
            Elements = {},
            ElementCount = 0,
            Dropdowns = {}
        }

        -- Обновление размера страницы (CanvasSize)
        local function updatePageSize()
            local totalHeight = 0
            for _, child in pairs(Page:GetChildren()) do
                if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
                    if child:IsA("Frame") or child:IsA("TextButton") then
                        totalHeight = totalHeight + child.Size.Y.Offset + 10
                    end
                end
            end
            Page.CanvasSize = UDim2.new(0, 0, 0, totalHeight + 15)
        end
        
        Tab._refreshCanvas = updatePageSize

        -- Активация вкладки
        local function activateTab()
            for _, v in pairs(ContentContainer:GetChildren()) do
                if v:IsA("ScrollingFrame") then
                    v.Visible = false
                end
            end
            
            Page.Visible = true
            WindowObj.CurrentTab = TabBtn
            
            for _, btn in pairs(TabScroll:GetChildren()) do
                if btn:IsA("TextButton") and btn ~= TabBtn then
                    services.TweenService:Create(btn, TweenInfo.new(0.15), {
                        BackgroundTransparency = 0.6,
                        TextColor3 = theme.TextSecondary
                    }):Play()
                end
            end
            
            services.TweenService:Create(TabBtn, TweenInfo.new(0.15), {
                BackgroundTransparency = 0.3,
                TextColor3 = theme.Accent
            }):Play()
        end

        -- Анимации кнопки
        table.insert(WindowObj.Connections, TabBtn.MouseEnter:Connect(function()
            if TabBtn ~= WindowObj.CurrentTab then
                services.TweenService:Create(TabBtn, TweenInfo.new(0.15), {
                    BackgroundTransparency = 0.4,
                    TextColor3 = theme.Text
                }):Play()
            end
        end))
        
        table.insert(WindowObj.Connections, TabBtn.MouseLeave:Connect(function()
            if TabBtn ~= WindowObj.CurrentTab then
                services.TweenService:Create(TabBtn, TweenInfo.new(0.15), {
                    BackgroundTransparency = 0.6,
                    TextColor3 = theme.TextSecondary
                }):Play()
            end
        end))
        
        table.insert(WindowObj.Connections, TabBtn.MouseButton1Click:Connect(activateTab))

        -- ФУНКЦИЯ РАЗДЕЛИТЕЛЯ (на уровне вкладки)
        function Tab:Separator(text)
            Tab.ElementCount = Tab.ElementCount + 1
            
            local SeparatorFrame = UI:Create("Frame", {
                Size = UDim2.new(1, -16, 0, 30),
                BackgroundTransparency = 1,
                ZIndex = 14,
                LayoutOrder = Tab.ElementCount,
                Parent = Page
            })
            
            local Line = UI:Create("Frame", {
                Size = UDim2.new(1, 0, 0, 1),
                Position = UDim2.new(0, 0, 0.5, 0),
                BackgroundColor3 = theme.Accent,
                BackgroundTransparency = 0.5,
                ZIndex = 15,
                Parent = SeparatorFrame
            })
            
            if text then
                local TextLabel = UI:Create("TextLabel", {
                    Text = text,
                    Size = UDim2.new(0, 0, 0, 20),
                    Position = UDim2.new(0.5, 0, 0.5, -10),
                    BackgroundColor3 = theme.Section,
                    TextColor3 = theme.TextSecondary,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    ZIndex = 16,
                    Parent = SeparatorFrame
                })
                
                UI:Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = TextLabel
                })
            end
            
            table.insert(Tab.Elements, SeparatorFrame)
            table.insert(WindowObj.Elements, SeparatorFrame)
            updatePageSize()
            return SeparatorFrame
        end

        -- ФУНКЦИЯ ЛЕЙБЛА (на уровне вкладки)
        function Tab:Label(text, size)
            Tab.ElementCount = Tab.ElementCount + 1
            
            local fontSize = size or 13
            
            local LabelFrame = UI:Create("Frame", {
                Size = UDim2.new(1, -16, 0, 22),
                BackgroundTransparency = 1,
                ZIndex = 14,
                LayoutOrder = Tab.ElementCount,
                Parent = Page
            })
            
            UI:Create("TextLabel", {
                Text = text,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                TextColor3 = theme.Text,
                Font = Enum.Font.Gotham,
                TextSize = fontSize,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 15,
                Parent = LabelFrame
            })
            
            table.insert(Tab.Elements, LabelFrame)
            table.insert(WindowObj.Elements, LabelFrame)
            updatePageSize()
            return LabelFrame
        end

        -- ФУНКЦИЯ КНОПКИ (на уровне вкладки)
        function Tab:Button(text, callback, icon)
            Tab.ElementCount = Tab.ElementCount + 1
            
            local Btn = UI:Create("TextButton", {
                Size = UDim2.new(1, -16, 0, 36),
                BackgroundColor3 = theme.Element,
                BackgroundTransparency = 0.5,
                Text = (icon or "•") .. "  " .. text,
                TextColor3 = theme.Text,
                Font = Enum.Font.Gotham,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 14,
                LayoutOrder = Tab.ElementCount,
                Parent = Page
            })
            
            UI:Create("UIPadding", {
                PaddingLeft = UDim.new(0, 12),
                Parent = Btn
            })
            
            UI:Create("UICorner", {
                CornerRadius = UDim.new(0, 8),
                Parent = Btn
            })
            
            local btnStroke = UI:Create("UIStroke", {
                Color = theme.Accent,
                Thickness = 1,
                Transparency = 0.8,
                Parent = Btn
            })
            
            table.insert(WindowObj.Connections, Btn.MouseEnter:Connect(function()
                services.TweenService:Create(Btn, TweenInfo.new(0.15), {
                    BackgroundTransparency = 0.3,
                    Size = UDim2.new(1, -12, 0, 38)
                }):Play()
                services.TweenService:Create(btnStroke, TweenInfo.new(0.15), {
                    Transparency = 0.6
                }):Play()
            end))
            
            table.insert(WindowObj.Connections, Btn.MouseLeave:Connect(function()
                services.TweenService:Create(Btn, TweenInfo.new(0.15), {
                    BackgroundTransparency = 0.5,
                    Size = UDim2.new(1, -16, 0, 36)
                }):Play()
                services.TweenService:Create(btnStroke, TweenInfo.new(0.15), {
                    Transparency = 0.8
                }):Play()
            end))
            
            table.insert(WindowObj.Connections, Btn.MouseButton1Click:Connect(function()
                services.TweenService:Create(Btn, TweenInfo.new(0.1), {
                    BackgroundTransparency = 0.2,
                    Size = UDim2.new(1, -18, 0, 34)
                }):Play()
                task.wait(0.1)
                services.TweenService:Create(Btn, TweenInfo.new(0.1), {
                    BackgroundTransparency = 0.3,
                    Size = UDim2.new(1, -12, 0, 38)
                }):Play()
                
                if callback then
                    local success, err = pcall(callback)
                    if not success then
                        warn("Button callback error:", err)
                    end
                end
            end))
            
            table.insert(Tab.Elements, Btn)
            table.insert(WindowObj.Elements, Btn)
            updatePageSize()
            return Btn
        end

        -- ФУНКЦИЯ ПЕРЕКЛЮЧАТЕЛЯ (на уровне вкладки)
        function Tab:Toggle(text, default, callback)
            Tab.ElementCount = Tab.ElementCount + 1
            
            local state = default or false
            
            local ToggleFrame = UI:Create("TextButton", {
                Size = UDim2.new(1, -16, 0, 36),
                BackgroundColor3 = theme.Element,
                BackgroundTransparency = 0.5,
                Text = "  " .. text,
                TextColor3 = theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Enum.Font.Gotham,
                TextSize = 13,
                ZIndex = 14,
                LayoutOrder = Tab.ElementCount,
                Parent = Page
            })
            
            UI:Create("UICorner", {
                CornerRadius = UDim.new(0, 8),
                Parent = ToggleFrame
            })
            
            local frameStroke = UI:Create("UIStroke", {
                Color = theme.Accent,
                Thickness = 1,
                Transparency = 0.8,
                Parent = ToggleFrame
            })
            
            local SliderTrack = UI:Create("Frame", {
                Size = UDim2.new(0, 48, 0, 20),
                Position = UDim2.new(1, -60, 0.5, -10),
                BackgroundColor3 = state and theme.Accent or Color3.fromRGB(80, 80, 90),
                ZIndex = 15,
                Parent = ToggleFrame
            })
            
            UI:Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = SliderTrack
            })
            
            local SliderDot = UI:Create("Frame", {
                Size = UDim2.new(0, 16, 0, 16),
                Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                BackgroundColor3 = Color3.fromRGB(240, 240, 245),
                ZIndex = 16,
                Parent = SliderTrack
            })
            
            UI:Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = SliderDot
            })
            
            table.insert(WindowObj.Connections, ToggleFrame.MouseEnter:Connect(function()
                services.TweenService:Create(ToggleFrame, TweenInfo.new(0.15), {
                    BackgroundTransparency = 0.4,
                    Size = UDim2.new(1, -12, 0, 38)
                }):Play()
                services.TweenService:Create(frameStroke, TweenInfo.new(0.15), {
                    Transparency = 0.6
                }):Play()
            end))
            
            table.insert(WindowObj.Connections, ToggleFrame.MouseLeave:Connect(function()
                services.TweenService:Create(ToggleFrame, TweenInfo.new(0.15), {
                    BackgroundTransparency = 0.5,
                    Size = UDim2.new(1, -16, 0, 36)
                }):Play()
                services.TweenService:Create(frameStroke, TweenInfo.new(0.15), {
                    Transparency = 0.8
                }):Play()
            end))
            
            local function toggleState()
                state = not state
                
                if state then
                    services.TweenService:Create(SliderTrack, TweenInfo.new(0.15), {
                        BackgroundColor3 = theme.Accent
                    }):Play()
                    services.TweenService:Create(SliderDot, TweenInfo.new(0.15), {
                        Position = UDim2.new(1, -18, 0.5, -8)
                    }):Play()
                else
                    services.TweenService:Create(SliderTrack, TweenInfo.new(0.15), {
                        BackgroundColor3 = Color3.fromRGB(80, 80, 90)
                    }):Play()
                    services.TweenService:Create(SliderDot, TweenInfo.new(0.15), {
                        Position = UDim2.new(0, 2, 0.5, -8)
                    }):Play()
                end
                
                if callback then
                    local success, err = pcall(callback, state)
                    if not success then
                        warn("Toggle callback error:", err)
                    end
                end
            end
            
            table.insert(WindowObj.Connections, ToggleFrame.MouseButton1Click:Connect(toggleState))
            
            table.insert(Tab.Elements, ToggleFrame)
            table.insert(WindowObj.Elements, ToggleFrame)
            updatePageSize()
            
            return {
                Set = function(val)
                    if val ~= state then
                        state = val
                        if state then
                            SliderTrack.BackgroundColor3 = theme.Accent
                            SliderDot.Position = UDim2.new(1, -18, 0.5, -8)
                        else
                            SliderTrack.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
                            SliderDot.Position = UDim2.new(0, 2, 0.5, -8)
                        end
                    end
                end,
                Get = function() return state end
            }
        end

        -- ФУНКЦИЯ СЛАЙДЕРА (на уровне вкладки)
        function Tab:Slider(text, min, max, default, callback, showValue)
            Tab.ElementCount = Tab.ElementCount + 1
    
            local currentValue = default
            local isDragging = false
            
            local SliderFrame = UI:Create("TextButton", {
                Name = "Slider_" .. text,
                Size = UDim2.new(1, -16, 0, 60),
                BackgroundColor3 = theme.Element,
                BackgroundTransparency = 0.5,
                Text = "",
                AutoButtonColor = false,
                ZIndex = 14,
                LayoutOrder = Tab.ElementCount,
                Parent = Page
            })
            
            UI:Create("UICorner", {
                CornerRadius = UDim.new(0, 8),
                Parent = SliderFrame
            })
            
            local Label = UI:Create("TextLabel", {
                Text = "  " .. text .. (showValue and (": " .. default) or ""),
                Size = UDim2.new(1, 0, 0, 22),
                BackgroundTransparency = 1,
                TextColor3 = theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Enum.Font.Gotham,
                TextSize = 12,
                ZIndex = 15,
                Parent = SliderFrame
            })

            local ValueLabel = UI:Create("TextLabel", {
                Text = tostring(default),
                Size = UDim2.new(0, 36, 0, 22),
                Position = UDim2.new(1, -40, 0, 0),
                BackgroundTransparency = 1,
                TextColor3 = theme.Accent,
                Font = Enum.Font.GothamMedium,
                TextSize = 12,
                ZIndex = 15,
                Parent = SliderFrame
            })

            local Bar = UI:Create("Frame", {
                Size = UDim2.new(1, -28, 0, 5),
                Position = UDim2.new(0, 14, 1, -20),
                BackgroundColor3 = Color3.fromRGB(70, 70, 80),
                ZIndex = 15,
                Parent = SliderFrame
            })
            
            UI:Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = Bar
            })
            
            local Fill = UI:Create("Frame", {
                Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                BackgroundColor3 = theme.Accent,
                ZIndex = 16,
                Parent = Bar
            })
            
            UI:Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = Fill
            })
            
            local SliderDot = UI:Create("Frame", {
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7),
                BackgroundColor3 = Color3.fromRGB(240, 240, 245),
                ZIndex = 17,
                Parent = Bar
            })
            
            UI:Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = SliderDot
            })

            local function updateSlider(input)
                if not input then return end
                
                local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                local val = math.floor(min + (max - min) * pos)
                
                if val ~= currentValue then
                    currentValue = val
                    
                    Fill.Size = UDim2.new(pos, 0, 1, 0)
                    SliderDot.Position = UDim2.new(pos, -7, 0.5, -7)
                    ValueLabel.Text = tostring(val)
                    
                    if showValue then
                        Label.Text = "  " .. text .. ": " .. val
                    end
                    
                    if callback then
                        local success, err = pcall(callback, val)
                        if not success then
                            warn("Slider callback error:", err)
                        end
                    end
                end
            end

            table.insert(WindowObj.Connections, Bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    isDragging = true
                    updateSlider(input)
                    
                    local connection
                    connection = services.UIS.InputChanged:Connect(function(input)
                        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                            updateSlider(input)
                        end
                    end)
                    
                    table.insert(WindowObj.Connections, services.UIS.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            isDragging = false
                            if connection then
                                connection:Disconnect()
                            end
                        end
                    end))
                end
            end))
            
            table.insert(Tab.Elements, SliderFrame)
            table.insert(WindowObj.Elements, SliderFrame)
            updatePageSize()
            
            return {
                Set = function(val)
                    val = math.clamp(val, min, max)
                    currentValue = val
                    local pos = (val - min) / (max - min)
                    Fill.Size = UDim2.new(pos, 0, 1, 0)
                    SliderDot.Position = UDim2.new(pos, -7, 0.5, -7)
                    ValueLabel.Text = tostring(val)
                    if showValue then
                        Label.Text = "  " .. text .. ": " .. val
                    end
                end,
                Get = function()
                    return currentValue
                end
            }
        end

        -- ФУНКЦИЯ DROPDOWN (на уровне вкладки)
        function Tab:Dropdown(text, options, default, callback)
            Tab.ElementCount = Tab.ElementCount + 1
            
            local selected = default or options[1]
            local isOpen = false
            local dropdownContainer
            local dropdownOptions = {}
            
            local DropFrame = UI:Create("Frame", {
                Name = "Dropdown_" .. text,
                Size = UDim2.new(1, -16, 0, 36),
                BackgroundColor3 = theme.Element,
                BackgroundTransparency = 0.5,
                ZIndex = 14,
                LayoutOrder = Tab.ElementCount,
                Parent = Page
            })
            
            UI:Create("UICorner", {
                CornerRadius = UDim.new(0, 8),
                Parent = DropFrame
            })
            
            local frameStroke = UI:Create("UIStroke", {
                Color = theme.Accent,
                Thickness = 1,
                Transparency = 0.8,
                Parent = DropFrame
            })
            
            local DropBtn = UI:Create("TextButton", {
                Name = "DropBtn",
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundTransparency = 1,
                Text = "  " .. text .. ": " .. selected,
                TextColor3 = theme.Text,
                Font = Enum.Font.Gotham,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 15,
                Parent = DropFrame
            })
            
            local Arrow = UI:Create("TextLabel", {
                Text = "▼",
                Size = UDim2.new(0, 20, 1, 0),
                Position = UDim2.new(1, -25, 0, 0),
                BackgroundTransparency = 1,
                TextColor3 = theme.TextSecondary,
                Font = Enum.Font.GothamMedium,
                TextSize = 12,
                ZIndex = 15,
                Parent = DropFrame
            })
            
            local function refreshOptions()
                if dropdownContainer then
                    dropdownContainer:Destroy()
                    dropdownContainer = nil
                end
            end
            
            local function createDropdownContainer()
                refreshOptions()
                
                local dropAbsPos = DropFrame.AbsolutePosition
                local dropAbsSize = DropFrame.AbsoluteSize
                local viewportSize = workspace.CurrentCamera.ViewportSize
                
                dropdownContainer = UI:Create("Frame", {
                    Name = "DropdownContainer_" .. text,
                    BackgroundColor3 = theme.Element,
                    BackgroundTransparency = 0.1,
                    BorderSizePixel = 0,
                    ZIndex = 1000,
                    Parent = ScreenGui
                })
                
                local relativeX = dropAbsPos.X
                local relativeY = dropAbsPos.Y + dropAbsSize.Y + 5
                
                if relativeY + 180 > viewportSize.Y then
                    relativeY = dropAbsPos.Y - 180 - 5
                end
                
                relativeY = math.clamp(relativeY, 10, viewportSize.Y - 180 - 10)
                
                dropdownContainer.Position = UDim2.new(0, relativeX, 0, relativeY)
                dropdownContainer.Size = UDim2.new(0, dropAbsSize.X, 0, 0)
                
                UI:Create("UICorner", {
                    CornerRadius = UDim.new(0, 8),
                    Parent = dropdownContainer
                })
                
                UI:Create("UIStroke", {
                    Color = theme.Accent,
                    Thickness = 1,
                    Transparency = 0.5,
                    Parent = dropdownContainer
                })
                
                createShadow(dropdownContainer, theme.Shadow, 0.3, 6)
                
                local OptionsList = UI:Create("ScrollingFrame", {
                    Name = "OptionsList",
                    Size = UDim2.new(1, -8, 1, -8),
                    Position = UDim2.new(0, 4, 0, 4),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    ScrollBarThickness = 4,
                    ScrollBarImageColor3 = theme.Accent,
                    CanvasSize = UDim2.new(0, 0, 0, #options * 32),
                    ZIndex = 1001,
                    Parent = dropdownContainer
                })
                
                UI:Create("UIListLayout", {
                    Padding = UDim.new(0, 2),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = OptionsList
                })
                
                dropdownOptions = {}
                for i, option in ipairs(options) do
                    local OptionBtn = UI:Create("TextButton", {
                        Name = "Option_" .. option,
                        Size = UDim2.new(1, 0, 0, 28),
                        LayoutOrder = i,
                        BackgroundColor3 = theme.Element,
                        BackgroundTransparency = option == selected and 0.3 or 0.6,
                        Text = option,
                        TextColor3 = option == selected and theme.Accent or theme.TextSecondary,
                        Font = Enum.Font.Gotham,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex = 1002,
                        Parent = OptionsList
                    })
                    
                    UI:Create("UIPadding", {
                        PaddingLeft = UDim.new(0, 10),
                        Parent = OptionBtn
                    })
                    
                    UI:Create("UICorner", {
                        CornerRadius = UDim.new(0, 6),
                        Parent = OptionBtn
                    })
                    
                    table.insert(WindowObj.Connections, OptionBtn.MouseEnter:Connect(function()
                        if option ~= selected then
                            services.TweenService:Create(OptionBtn, TweenInfo.new(0.15), {
                                BackgroundTransparency = 0.4,
                                TextColor3 = theme.Text
                            }):Play()
                        end
                    end))
                    
                    table.insert(WindowObj.Connections, OptionBtn.MouseLeave:Connect(function()
                        if option ~= selected then
                            services.TweenService:Create(OptionBtn, TweenInfo.new(0.15), {
                                BackgroundTransparency = 0.6,
                                TextColor3 = theme.TextSecondary
                            }):Play()
                        end
                    end))
                    
                    table.insert(WindowObj.Connections, OptionBtn.MouseButton1Click:Connect(function()
                        selected = option
                        DropBtn.Text = "  " .. text .. ": " .. selected
                        
                        for _, btn in pairs(OptionsList:GetChildren()) do
                            if btn:IsA("TextButton") then
                                if btn.Text == selected then
                                    services.TweenService:Create(btn, TweenInfo.new(0.15), {
                                        BackgroundTransparency = 0.3,
                                        TextColor3 = theme.Accent
                                    }):Play()
                                else
                                    services.TweenService:Create(btn, TweenInfo.new(0.15), {
                                        BackgroundTransparency = 0.6,
                                        TextColor3 = theme.TextSecondary
                                    }):Play()
                                end
                            end
                        end
                        
                        if callback then
                            local success, err = pcall(callback, selected)
                            if not success then
                                warn("Dropdown callback error:", err)
                            end
                        end
                        
                        toggleDropdown()
                    end))
                    
                    table.insert(dropdownOptions, OptionBtn)
                end
            end
            
            local function toggleDropdown()
                isOpen = not isOpen
    
                if isOpen then
                    for _, otherDropdown in pairs(WindowObj.OpenDropdowns) do
                        if otherDropdown ~= DropFrame then
                            otherDropdown.Close()
                        end
                    end
                    
                    createDropdownContainer()
                    
                    dropdownContainer.Visible = true
                    services.TweenService:Create(dropdownContainer, TweenInfo.new(0.2), {
                        Size = UDim2.new(0, DropFrame.AbsoluteSize.X, 0, 180)
                    }):Play()
                    
                    services.TweenService:Create(Arrow, TweenInfo.new(0.2), {
                        Rotation = 180,
                        TextColor3 = theme.Accent
                    }):Play()
                    
                    services.TweenService:Create(DropFrame, TweenInfo.new(0.15), {
                        BackgroundTransparency = 0.2,
                        Size = UDim2.new(1, -12, 0, 38)
                    }):Play()
                    
                    services.TweenService:Create(frameStroke, TweenInfo.new(0.15), {
                        Transparency = 0.4
                    }):Play()
                    
                    WindowObj.OpenDropdowns[DropFrame] = {
                        Close = function()
                            if isOpen then
                                toggleDropdown()
                            end
                        end
                    }
                else
                    if dropdownContainer then
                        services.TweenService:Create(dropdownContainer, TweenInfo.new(0.2), {
                            Size = UDim2.new(0, DropFrame.AbsoluteSize.X, 0, 0)
                        }):Play()
                        
                        services.TweenService:Create(Arrow, TweenInfo.new(0.2), {
                            Rotation = 0,
                            TextColor3 = theme.TextSecondary
                        }):Play()
                        
                        services.TweenService:Create(DropFrame, TweenInfo.new(0.15), {
                            BackgroundTransparency = 0.5,
                            Size = UDim2.new(1, -16, 0, 36)
                        }):Play()
                        
                        services.TweenService:Create(frameStroke, TweenInfo.new(0.15), {
                            Transparency = 0.8
                        }):Play()
                        
                        task.wait(0.2)
                        dropdownContainer:Destroy()
                        dropdownContainer = nil
                    end
                    
                    WindowObj.OpenDropdowns[DropFrame] = nil
                end
            end
            
            table.insert(WindowObj.Connections, DropBtn.MouseEnter:Connect(function()
                if not isOpen then
                    services.TweenService:Create(DropFrame, TweenInfo.new(0.15), {
                        BackgroundTransparency = 0.4,
                        Size = UDim2.new(1, -12, 0, 38)
                    }):Play()
                    services.TweenService:Create(frameStroke, TweenInfo.new(0.15), {
                        Transparency = 0.6
                    }):Play()
                end
            end))
            
            table.insert(WindowObj.Connections, DropBtn.MouseLeave:Connect(function()
                if not isOpen then
                    services.TweenService:Create(DropFrame, TweenInfo.new(0.15), {
                        BackgroundTransparency = 0.5,
                        Size = UDim2.new(1, -16, 0, 36)
                    }):Play()
                    services.TweenService:Create(frameStroke, TweenInfo.new(0.15), {
                        Transparency = 0.8
                    }):Play()
                end
            end))
            
            table.insert(WindowObj.Connections, DropBtn.MouseButton1Click:Connect(toggleDropdown))
            
            local function closeOnClickOutside(input)
                if isOpen and input.UserInputType == Enum.UserInputType.MouseButton1 and dropdownContainer then
                    local mousePos = input.Position
                    local dropAbsPos = DropFrame.AbsolutePosition
                    local dropAbsSize = DropFrame.AbsoluteSize
                    local containerAbsPos = dropdownContainer.AbsolutePosition
                    local containerAbsSize = dropdownContainer.AbsoluteSize
                    
                    local clickedInsideDropdown = 
                        mousePos.X >= dropAbsPos.X and mousePos.X <= dropAbsPos.X + dropAbsSize.X and
                        mousePos.Y >= dropAbsPos.Y and mousePos.Y <= dropAbsPos.Y + dropAbsSize.Y
                    
                    local clickedInsideContainer = 
                        containerAbsPos and 
                        mousePos.X >= containerAbsPos.X and mousePos.X <= containerAbsPos.X + containerAbsSize.X and
                        mousePos.Y >= containerAbsPos.Y and mousePos.Y <= containerAbsPos.Y + containerAbsSize.Y
                    
                    if not clickedInsideDropdown and not clickedInsideContainer then
                        toggleDropdown()
                    end
                end
            end
            
            local closeConnection = services.UIS.InputBegan:Connect(closeOnClickOutside)
            table.insert(WindowObj.Connections, closeConnection)
            
            table.insert(Tab.Elements, DropFrame)
            table.insert(WindowObj.Elements, DropFrame)
            table.insert(Tab.Dropdowns, DropFrame)
            updatePageSize()
            
            local dropdownObj = {
                Set = function(value)
                    local found = false
                    for _, v in ipairs(options) do
                        if v == value then
                            found = true
                            break
                        end
                    end
                    
                    if found then
                        selected = value
                        DropBtn.Text = "  " .. text .. ": " .. value
                        
                        if callback then
                            pcall(callback, value)
                        end
                    else
                        warn("Dropdown: invalid value '" .. tostring(value) .. "'. Available:", options)
                    end
                end,
                Get = function()
                    return selected
                end,
                GetOptions = function()
                    return options
                end,
                AddOption = function(newOption)
                    local exists = false
                    for _, v in ipairs(options) do
                        if v == newOption then
                            exists = true
                            break
                        end
                    end
                    
                    if not exists then
                        table.insert(options, newOption)
                    end
                end,
                RemoveOption = function(optionToRemove)
                    for i, v in ipairs(options) do
                        if v == optionToRemove then
                            table.remove(options, i)
                            if selected == optionToRemove then
                                selected = options[1] or ""
                                DropBtn.Text = "  " .. text .. ": " .. selected
                            end
                            break
                        end
                    end
                end,
                Refresh = function()
                    refreshOptions()
                end,
                Destroy = function()
                    if closeConnection then
                        closeConnection:Disconnect()
                    end
                    if dropdownContainer then
                        dropdownContainer:Destroy()
                    end
                    DropFrame:Destroy()
                end
            }
            
            return dropdownObj
        end

        -- НОВЫЙ МЕТОД: СОЗДАНИЕ КОЛЛАПСИРУЕМОЙ СЕКЦИИ
        function Tab:CreateSection(name, defaultExpanded)
            defaultExpanded = (defaultExpanded == nil) or defaultExpanded
            
            Tab.ElementCount = Tab.ElementCount + 1
            local sectionOrder = Tab.ElementCount
            
            -- Основной контейнер секции
            local SectionFrame = UI:Create("Frame", {
                Name = "Section_" .. name,
                Size = UDim2.new(1, -16, 0, 0), -- высота будет меняться
                BackgroundColor3 = theme.Section,
                BackgroundTransparency = 0.3,
                ZIndex = 14,
                LayoutOrder = sectionOrder,
                Parent = Page
            })
            
            UI:Create("UICorner", {
                CornerRadius = UDim.new(0, GeminiLib.Config.Roundness - 2),
                Parent = SectionFrame
            })
            
            UI:Create("UIStroke", {
                Color = theme.Accent,
                Thickness = 1,
                Transparency = 0.6,
                Parent = SectionFrame
            })
            
            createShadow(SectionFrame, theme.Shadow, 0.2, 8)
            
            -- Заголовок секции (кнопка)
            local Header = UI:Create("TextButton", {
                Name = "Header",
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundColor3 = theme.Element,
                BackgroundTransparency = 0.5,
                Text = "  " .. name,
                TextColor3 = theme.Text,
                Font = Enum.Font.GothamMedium,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 15,
                Parent = SectionFrame
            })
            
            UI:Create("UICorner", {
                CornerRadius = UDim.new(0, 8),
                Parent = Header
            })
            
            -- Стрелка
            local Arrow = UI:Create("TextLabel", {
                Text = "▼",
                Size = UDim2.new(0, 20, 1, 0),
                Position = UDim2.new(1, -25, 0, 0),
                BackgroundTransparency = 1,
                TextColor3 = theme.TextSecondary,
                Font = Enum.Font.GothamMedium,
                TextSize = 14,
                ZIndex = 16,
                Parent = Header
            })
            
            -- Контейнер для содержимого
            local ContentContainer = UI:Create("Frame", {
                Name = "Content",
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundTransparency = 1,
                ClipsDescendants = true,
                ZIndex = 14,
                Parent = SectionFrame
            })
            
            UI:Create("UIListLayout", {
                Padding = UDim.new(0, 6),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = ContentContainer
            })
            
            UI:Create("UIPadding", {
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8),
                PaddingTop = UDim.new(0, 8),
                PaddingBottom = UDim.new(0, 8),
                Parent = ContentContainer
            })
            
            -- Локальные переменные для секции
            local sectionElements = {}
            local elementCount = 0
            local expanded = defaultExpanded
            
            -- Функция пересчёта высоты содержимого
            local function updateContentHeight()
                local totalHeight = 0
                for _, child in pairs(ContentContainer:GetChildren()) do
                    if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
                        if child:IsA("Frame") or child:IsA("TextButton") then
                            totalHeight = totalHeight + child.Size.Y.Offset + 6
                        end
                    end
                end
                -- Устанавливаем высоту контейнера
                ContentContainer.Size = UDim2.new(1, 0, 0, totalHeight)
                return totalHeight
            end
            
            -- Функция обновления размера всей секции
            local function updateSectionSize()
                local contentHeight = expanded and updateContentHeight() or 0
                SectionFrame.Size = UDim2.new(1, -16, 0, 40 + contentHeight)
                -- Обновляем CanvasSize таба
                if Tab._refreshCanvas then
                    Tab._refreshCanvas()
                end
            end
            
            -- Анимация поворота стрелки
            local function animateArrow(exp)
                local targetRotation = exp and 180 or 0
                services.TweenService:Create(Arrow, TweenInfo.new(0.2), {
                    Rotation = targetRotation,
                    TextColor3 = exp and theme.Accent or theme.TextSecondary
                }):Play()
            end
            
            -- Переключение состояния
            local function setExpanded(exp, skipAnim)
                expanded = exp
                if expanded then
                    ContentContainer.Visible = true
                    updateContentHeight()
                else
                    ContentContainer.Visible = false
                end
                updateSectionSize()
                if not skipAnim then
                    animateArrow(expanded)
                else
                    Arrow.Rotation = expanded and 180 or 0
                    Arrow.TextColor3 = expanded and theme.Accent or theme.TextSecondary
                end
            end
            
            -- Клик по заголовку
            table.insert(WindowObj.Connections, Header.MouseButton1Click:Connect(function()
                setExpanded(not expanded, false)
            end))
            
            -- Анимации заголовка
            table.insert(WindowObj.Connections, Header.MouseEnter:Connect(function()
                services.TweenService:Create(Header, TweenInfo.new(0.15), {
                    BackgroundTransparency = 0.3,
                    TextColor3 = theme.Accent
                }):Play()
            end))
            
            table.insert(WindowObj.Connections, Header.MouseLeave:Connect(function()
                services.TweenService:Create(Header, TweenInfo.new(0.15), {
                    BackgroundTransparency = 0.5,
                    TextColor3 = theme.Text
                }):Play()
            end))
            
            -- Объект секции с API, аналогичным Tab
            local Section = {}
            
            function Section:Separator(text)
                elementCount = elementCount + 1
                local sep = UI:Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundTransparency = 1,
                    LayoutOrder = elementCount,
                    Parent = ContentContainer
                })
                local line = UI:Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 1),
                    Position = UDim2.new(0, 0, 0.5, 0),
                    BackgroundColor3 = theme.Accent,
                    BackgroundTransparency = 0.5,
                    Parent = sep
                })
                if text then
                    local lab = UI:Create("TextLabel", {
                        Text = text,
                        Size = UDim2.new(0, 0, 0, 20),
                        Position = UDim2.new(0.5, 0, 0.5, -10),
                        BackgroundColor3 = theme.Section,
                        TextColor3 = theme.TextSecondary,
                        Font = Enum.Font.Gotham,
                        TextSize = 11,
                        Parent = sep
                    })
                    UI:Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = lab})
                end
                table.insert(sectionElements, sep)
                updateSectionSize()
                return sep
            end
            
            function Section:Label(text, size)
                elementCount = elementCount + 1
                local labFrame = UI:Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 22),
                    BackgroundTransparency = 1,
                    LayoutOrder = elementCount,
                    Parent = ContentContainer
                })
                UI:Create("TextLabel", {
                    Text = text,
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = size or 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = labFrame
                })
                table.insert(sectionElements, labFrame)
                updateSectionSize()
                return labFrame
            end
            
            function Section:Button(text, callback, icon)
                elementCount = elementCount + 1
                local btn = UI:Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 36),
                    BackgroundColor3 = theme.Element,
                    BackgroundTransparency = 0.5,
                    Text = (icon or "•") .. "  " .. text,
                    TextColor3 = theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    LayoutOrder = elementCount,
                    Parent = ContentContainer
                })
                UI:Create("UIPadding", {PaddingLeft = UDim.new(0, 12), Parent = btn})
                UI:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = btn})
                local stroke = UI:Create("UIStroke", {Color = theme.Accent, Thickness = 1, Transparency = 0.8, Parent = btn})
                
                table.insert(WindowObj.Connections, btn.MouseEnter:Connect(function()
                    services.TweenService:Create(btn, TweenInfo.new(0.15), {
                        BackgroundTransparency = 0.3,
                        Size = UDim2.new(1, -4, 0, 38)
                    }):Play()
                    services.TweenService:Create(stroke, TweenInfo.new(0.15), {Transparency = 0.6}):Play()
                end))
                table.insert(WindowObj.Connections, btn.MouseLeave:Connect(function()
                    services.TweenService:Create(btn, TweenInfo.new(0.15), {
                        BackgroundTransparency = 0.5,
                        Size = UDim2.new(1, 0, 0, 36)
                    }):Play()
                    services.TweenService:Create(stroke, TweenInfo.new(0.15), {Transparency = 0.8}):Play()
                end))
                table.insert(WindowObj.Connections, btn.MouseButton1Click:Connect(function()
                    services.TweenService:Create(btn, TweenInfo.new(0.1), {
                        BackgroundTransparency = 0.2,
                        Size = UDim2.new(1, -6, 0, 34)
                    }):Play()
                    task.wait(0.1)
                    services.TweenService:Create(btn, TweenInfo.new(0.1), {
                        BackgroundTransparency = 0.3,
                        Size = UDim2.new(1, -4, 0, 38)
                    }):Play()
                    if callback then pcall(callback) end
                end))
                table.insert(sectionElements, btn)
                updateSectionSize()
                return btn
            end
            
            function Section:Toggle(text, default, callback)
                elementCount = elementCount + 1
                local state = default or false
                local toggleFrame = UI:Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 36),
                    BackgroundColor3 = theme.Element,
                    BackgroundTransparency = 0.5,
                    Text = "  " .. text,
                    TextColor3 = theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Font = Enum.Font.Gotham,
                    TextSize = 13,
                    LayoutOrder = elementCount,
                    Parent = ContentContainer
                })
                UI:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = toggleFrame})
                local stroke = UI:Create("UIStroke", {Color = theme.Accent, Thickness = 1, Transparency = 0.8, Parent = toggleFrame})
                local track = UI:Create("Frame", {
                    Size = UDim2.new(0, 48, 0, 20),
                    Position = UDim2.new(1, -60, 0.5, -10),
                    BackgroundColor3 = state and theme.Accent or Color3.fromRGB(80, 80, 90),
                    Parent = toggleFrame
                })
                UI:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = track})
                local dot = UI:Create("Frame", {
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                    BackgroundColor3 = Color3.fromRGB(240, 240, 245),
                    Parent = track
                })
                UI:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = dot})
                
                local function toggle()
                    state = not state
                    services.TweenService:Create(track, TweenInfo.new(0.15), {
                        BackgroundColor3 = state and theme.Accent or Color3.fromRGB(80, 80, 90)
                    }):Play()
                    services.TweenService:Create(dot, TweenInfo.new(0.15), {
                        Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                    }):Play()
                    if callback then pcall(callback, state) end
                end
                
                table.insert(WindowObj.Connections, toggleFrame.MouseButton1Click:Connect(toggle))
                table.insert(WindowObj.Connections, toggleFrame.MouseEnter:Connect(function()
                    services.TweenService:Create(toggleFrame, TweenInfo.new(0.15), {
                        BackgroundTransparency = 0.4,
                        Size = UDim2.new(1, -4, 0, 38)
                    }):Play()
                    services.TweenService:Create(stroke, TweenInfo.new(0.15), {Transparency = 0.6}):Play()
                end))
                table.insert(WindowObj.Connections, toggleFrame.MouseLeave:Connect(function()
                    services.TweenService:Create(toggleFrame, TweenInfo.new(0.15), {
                        BackgroundTransparency = 0.5,
                        Size = UDim2.new(1, 0, 0, 36)
                    }):Play()
                    services.TweenService:Create(stroke, TweenInfo.new(0.15), {Transparency = 0.8}):Play()
                end))
                
                table.insert(sectionElements, toggleFrame)
                updateSectionSize()
                return {
                    Set = function(val)
                        if val ~= state then
                            state = val
                            track.BackgroundColor3 = state and theme.Accent or Color3.fromRGB(80, 80, 90)
                            dot.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                        end
                    end,
                    Get = function() return state end
                }
            end
            
            function Section:Slider(text, min, max, default, callback, showValue)
                elementCount = elementCount + 1
                local current = default
                local dragging = false
                local sliderFrame = UI:Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 60),
                    BackgroundColor3 = theme.Element,
                    BackgroundTransparency = 0.5,
                    Text = "",
                    AutoButtonColor = false,
                    LayoutOrder = elementCount,
                    Parent = ContentContainer
                })
                UI:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = sliderFrame})
                local label = UI:Create("TextLabel", {
                    Text = "  " .. text .. (showValue and (": " .. default) or ""),
                    Size = UDim2.new(1, 0, 0, 22),
                    BackgroundTransparency = 1,
                    TextColor3 = theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    Parent = sliderFrame
                })
                local valLabel = UI:Create("TextLabel", {
                    Text = tostring(default),
                    Size = UDim2.new(0, 36, 0, 22),
                    Position = UDim2.new(1, -40, 0, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = theme.Accent,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 12,
                    Parent = sliderFrame
                })
                local bar = UI:Create("Frame", {
                    Size = UDim2.new(1, -28, 0, 5),
                    Position = UDim2.new(0, 14, 1, -20),
                    BackgroundColor3 = Color3.fromRGB(70, 70, 80),
                    Parent = sliderFrame
                })
                UI:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = bar})
                local fill = UI:Create("Frame", {
                    Size = UDim2.new((default-min)/(max-min), 0, 1, 0),
                    BackgroundColor3 = theme.Accent,
                    Parent = bar
                })
                UI:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = fill})
                local dot = UI:Create("Frame", {
                    Size = UDim2.new(0, 14, 0, 14),
                    Position = UDim2.new((default-min)/(max-min), -7, 0.5, -7),
                    BackgroundColor3 = Color3.fromRGB(240, 240, 245),
                    Parent = bar
                })
                UI:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = dot})
                
                local function updateSlider(input)
                    if not input then return end
                    local pos = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                    local val = math.floor(min + (max-min)*pos)
                    if val ~= current then
                        current = val
                        fill.Size = UDim2.new(pos, 0, 1, 0)
                        dot.Position = UDim2.new(pos, -7, 0.5, -7)
                        valLabel.Text = tostring(val)
                        if showValue then label.Text = "  " .. text .. ": " .. val end
                        if callback then pcall(callback, val) end
                    end
                end
                
                table.insert(WindowObj.Connections, bar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        updateSlider(input)
                        local conn
                        conn = services.UIS.InputChanged:Connect(function(inp)
                            if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
                                updateSlider(inp)
                            end
                        end)
                        table.insert(WindowObj.Connections, services.UIS.InputEnded:Connect(function(inp)
                            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                                dragging = false
                                if conn then conn:Disconnect() end
                            end
                        end))
                    end
                end))
                table.insert(sectionElements, sliderFrame)
                updateSectionSize()
                return {
                    Set = function(val)
                        val = math.clamp(val, min, max)
                        current = val
                        local pos = (val-min)/(max-min)
                        fill.Size = UDim2.new(pos, 0, 1, 0)
                        dot.Position = UDim2.new(pos, -7, 0.5, -7)
                        valLabel.Text = tostring(val)
                        if showValue then label.Text = "  " .. text .. ": " .. val end
                    end,
                    Get = function() return current end
                }
            end
            
            function Section:Dropdown(text, options, default, callback)
                elementCount = elementCount + 1
                local selected = default or options[1]
                local isOpen = false
                local dropdownContainer
                local dropFrame = UI:Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 36),
                    BackgroundColor3 = theme.Element,
                    BackgroundTransparency = 0.5,
                    LayoutOrder = elementCount,
                    Parent = ContentContainer
                })
                UI:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = dropFrame})
                local stroke = UI:Create("UIStroke", {Color = theme.Accent, Thickness = 1, Transparency = 0.8, Parent = dropFrame})
                local dropBtn = UI:Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 36),
                    BackgroundTransparency = 1,
                    Text = "  " .. text .. ": " .. selected,
                    TextColor3 = theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = dropFrame
                })
                local arrow = UI:Create("TextLabel", {
                    Text = "▼",
                    Size = UDim2.new(0, 20, 1, 0),
                    Position = UDim2.new(1, -25, 0, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = theme.TextSecondary,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 12,
                    Parent = dropFrame
                })
                
                local function refreshContainer()
                    if dropdownContainer then dropdownContainer:Destroy() end
                end
                
                local function createContainer()
                    refreshContainer()
                    local absPos = dropFrame.AbsolutePosition
                    local absSize = dropFrame.AbsoluteSize
                    local vpSize = workspace.CurrentCamera.ViewportSize
                    dropdownContainer = UI:Create("Frame", {
                        BackgroundColor3 = theme.Element,
                        BackgroundTransparency = 0.1,
                        BorderSizePixel = 0,
                        ZIndex = 1000,
                        Parent = ScreenGui
                    })
                    local x = absPos.X
                    local y = absPos.Y + absSize.Y + 5
                    if y + 180 > vpSize.Y then y = absPos.Y - 180 - 5 end
                    y = math.clamp(y, 10, vpSize.Y - 180 - 10)
                    dropdownContainer.Position = UDim2.new(0, x, 0, y)
                    dropdownContainer.Size = UDim2.new(0, absSize.X, 0, 0)
                    UI:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = dropdownContainer})
                    UI:Create("UIStroke", {Color = theme.Accent, Thickness = 1, Transparency = 0.5, Parent = dropdownContainer})
                    createShadow(dropdownContainer, theme.Shadow, 0.3, 6)
                    local list = UI:Create("ScrollingFrame", {
                        Size = UDim2.new(1, -8, 1, -8),
                        Position = UDim2.new(0, 4, 0, 4),
                        BackgroundTransparency = 1,
                        ScrollBarThickness = 4,
                        ScrollBarImageColor3 = theme.Accent,
                        CanvasSize = UDim2.new(0, 0, 0, #options * 32),
                        Parent = dropdownContainer
                    })
                    UI:Create("UIListLayout", {Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, Parent = list})
                    for i, opt in ipairs(options) do
                        local optBtn = UI:Create("TextButton", {
                            Size = UDim2.new(1, 0, 0, 28),
                            LayoutOrder = i,
                            BackgroundColor3 = theme.Element,
                            BackgroundTransparency = opt == selected and 0.3 or 0.6,
                            Text = opt,
                            TextColor3 = opt == selected and theme.Accent or theme.TextSecondary,
                            Font = Enum.Font.Gotham,
                            TextSize = 12,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            Parent = list
                        })
                        UI:Create("UIPadding", {PaddingLeft = UDim.new(0, 10), Parent = optBtn})
                        UI:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = optBtn})
                        optBtn.MouseEnter:Connect(function()
                            if opt ~= selected then
                                services.TweenService:Create(optBtn, TweenInfo.new(0.15), {
                                    BackgroundTransparency = 0.4,
                                    TextColor3 = theme.Text
                                }):Play()
                            end
                        end)
                        optBtn.MouseLeave:Connect(function()
                            if opt ~= selected then
                                services.TweenService:Create(optBtn, TweenInfo.new(0.15), {
                                    BackgroundTransparency = 0.6,
                                    TextColor3 = theme.TextSecondary
                                }):Play()
                            end
                        end)
                        optBtn.MouseButton1Click:Connect(function()
                            selected = opt
                            dropBtn.Text = "  " .. text .. ": " .. selected
                            for _, btn in pairs(list:GetChildren()) do
                                if btn:IsA("TextButton") then
                                    services.TweenService:Create(btn, TweenInfo.new(0.15), {
                                        BackgroundTransparency = btn.Text == selected and 0.3 or 0.6,
                                        TextColor3 = btn.Text == selected and theme.Accent or theme.TextSecondary
                                    }):Play()
                                end
                            end
                            if callback then pcall(callback, selected) end
                            toggleDropdown()
                        end)
                    end
                end
                
                local function toggleDropdown()
                    isOpen = not isOpen
                    if isOpen then
                        for _, other in pairs(WindowObj.OpenDropdowns) do
                            if other ~= dropFrame then other.Close() end
                        end
                        createContainer()
                        dropdownContainer.Visible = true
                        services.TweenService:Create(dropdownContainer, TweenInfo.new(0.2), {
                            Size = UDim2.new(0, dropFrame.AbsoluteSize.X, 0, 180)
                        }):Play()
                        services.TweenService:Create(arrow, TweenInfo.new(0.2), {
                            Rotation = 180,
                            TextColor3 = theme.Accent
                        }):Play()
                        services.TweenService:Create(dropFrame, TweenInfo.new(0.15), {
                            BackgroundTransparency = 0.2,
                            Size = UDim2.new(1, -4, 0, 38)
                        }):Play()
                        services.TweenService:Create(stroke, TweenInfo.new(0.15), {Transparency = 0.4}):Play()
                        WindowObj.OpenDropdowns[dropFrame] = {Close = function() if isOpen then toggleDropdown() end end}
                    else
                        if dropdownContainer then
                            services.TweenService:Create(dropdownContainer, TweenInfo.new(0.2), {
                                Size = UDim2.new(0, dropFrame.AbsoluteSize.X, 0, 0)
                            }):Play()
                            services.TweenService:Create(arrow, TweenInfo.new(0.2), {
                                Rotation = 0,
                                TextColor3 = theme.TextSecondary
                            }):Play()
                            services.TweenService:Create(dropFrame, TweenInfo.new(0.15), {
                                BackgroundTransparency = 0.5,
                                Size = UDim2.new(1, 0, 0, 36)
                            }):Play()
                            services.TweenService:Create(stroke, TweenInfo.new(0.15), {Transparency = 0.8}):Play()
                            task.wait(0.2)
                            dropdownContainer:Destroy()
                            dropdownContainer = nil
                        end
                        WindowObj.OpenDropdowns[dropFrame] = nil
                    end
                end
                
                dropBtn.MouseButton1Click:Connect(toggleDropdown)
                dropBtn.MouseEnter:Connect(function()
                    if not isOpen then
                        services.TweenService:Create(dropFrame, TweenInfo.new(0.15), {
                            BackgroundTransparency = 0.4,
                            Size = UDim2.new(1, -4, 0, 38)
                        }):Play()
                        services.TweenService:Create(stroke, TweenInfo.new(0.15), {Transparency = 0.6}):Play()
                    end
                end)
                dropBtn.MouseLeave:Connect(function()
                    if not isOpen then
                        services.TweenService:Create(dropFrame, TweenInfo.new(0.15), {
                            BackgroundTransparency = 0.5,
                            Size = UDim2.new(1, 0, 0, 36)
                        }):Play()
                        services.TweenService:Create(stroke, TweenInfo.new(0.15), {Transparency = 0.8}):Play()
                    end
                end)
                
                local closeOutside = services.UIS.InputBegan:Connect(function(input)
                    if isOpen and input.UserInputType == Enum.UserInputType.MouseButton1 and dropdownContainer then
                        local mp = input.Position
                        local inDrop = (mp.X >= dropFrame.AbsolutePosition.X and mp.X <= dropFrame.AbsolutePosition.X + dropFrame.AbsoluteSize.X and
                                        mp.Y >= dropFrame.AbsolutePosition.Y and mp.Y <= dropFrame.AbsolutePosition.Y + dropFrame.AbsoluteSize.Y)
                        local inCont = dropdownContainer and (mp.X >= dropdownContainer.AbsolutePosition.X and mp.X <= dropdownContainer.AbsolutePosition.X + dropdownContainer.AbsoluteSize.X and
                                                              mp.Y >= dropdownContainer.AbsolutePosition.Y and mp.Y <= dropdownContainer.AbsolutePosition.Y + dropdownContainer.AbsoluteSize.Y)
                        if not inDrop and not inCont then toggleDropdown() end
                    end
                end)
                table.insert(WindowObj.Connections, closeOutside)
                table.insert(sectionElements, dropFrame)
                updateSectionSize()
                return {
                    Set = function(val)
                        if table.find(options, val) then
                            selected = val
                            dropBtn.Text = "  " .. text .. ": " .. selected
                            if callback then pcall(callback, selected) end
                        end
                    end,
                    Get = function() return selected end,
                    GetOptions = function() return options end,
                    AddOption = function(opt) if not table.find(options, opt) then table.insert(options, opt) end end,
                    RemoveOption = function(opt) for i,v in ipairs(options) do if v==opt then table.remove(options,i) if selected==opt then selected=options[1] or "" dropBtn.Text="  "..text..": "..selected end break end end end,
                    Refresh = refreshContainer,
                    Destroy = function() closeOutside:Disconnect() if dropdownContainer then dropdownContainer:Destroy() end dropFrame:Destroy() end
                }
            end
            
            -- Инициализация начального состояния
            setExpanded(expanded, true)
            
            -- Добавляем методы управления секцией
            Section.Expand = function() setExpanded(true, false) end
            Section.Collapse = function() setExpanded(false, false) end
            Section.Toggle = function() setExpanded(not expanded, false) end
            Section.IsExpanded = function() return expanded end
            Section.Destroy = function() SectionFrame:Destroy() end
            
            table.insert(Tab.Elements, SectionFrame)
            table.insert(WindowObj.Elements, SectionFrame)
            
            return Section
        end

        -- Обновление размера страницы при добавлении/удалении детей
        Page.ChildAdded:Connect(function()
            task.wait(0.01)
            updatePageSize()
        end)
        Page.ChildRemoved:Connect(function()
            task.wait(0.01)
            updatePageSize()
        end)

        task.spawn(function()
            task.wait(0.1)
            updatePageSize()
        end)

        -- Добавляем вкладку в список
        table.insert(WindowObj.Tabs, Tab)
        
        -- Активируем первую вкладку
        if #WindowObj.Tabs == 1 then
            activateTab()
        end

        return Tab
    end

    --#region ФУНКЦИЯ СМЕНЫ ТЕМЫ
    function WindowObj:ChangeTheme(newThemeName)
        local newTheme = GeminiLib.Themes[newThemeName]
        if not newTheme then return end
        
        WindowObj.Theme = newTheme
        
        Main.BackgroundColor3 = newTheme.Main
        if TopBar then TopBar.BackgroundColor3 = newTheme.Section end
        if Title then Title.TextColor3 = newTheme.Text end
        
        local ShadowFrame = Main:FindFirstChild("Shadow") or Main:FindFirstChild("DropShadow")
        if ShadowFrame and ShadowFrame:IsA("ImageLabel") then
            ShadowFrame.ImageColor3 = newTheme.Shadow
            ShadowFrame.ImageTransparency = 1 - (newTheme.ShadowAlpha or 0.4)
        end

        for _, element in pairs(WindowObj.Elements) do
            pcall(function()
                if element:IsA("TextButton") or element:IsA("TextLabel") or element:IsA("TextBox") then
                    if element.BackgroundTransparency < 1 then
                        element.BackgroundColor3 = newTheme.Element
                    end
                    element.TextColor3 = newTheme.Text
                end
                if element.Name == "SectionFrame" or element:FindFirstChild("UIListLayout") then
                    element.BackgroundColor3 = newTheme.Section
                end
                local stroke = element:FindFirstChildOfClass("UIStroke")
                if stroke then
                    stroke.Color = newTheme.Accent
                end
                local AccentPart = element:FindFirstChild("AccentPart") or element:FindFirstChild("Fill")
                if AccentPart then
                    if AccentPart:IsA("Frame") then
                        AccentPart.BackgroundColor3 = newTheme.Accent
                    elseif AccentPart:IsA("ImageLabel") then
                        AccentPart.ImageColor3 = newTheme.Accent
                    end
                end
                local SubText = element:FindFirstChild("SubText") or element:FindFirstChild("Description")
                if SubText and SubText:IsA("TextLabel") then
                    SubText.TextColor3 = newTheme.TextSecondary
                end
            end)
        end
    end

    -- ФУНКЦИЯ ПЛАВАЮЩЕЙ КНОПКИ
    function WindowObj:CreateFloatingButton()
        if WindowObj.FloatingButton then
            WindowObj.FloatingButton:Destroy()
        end
        
        local FloatingButton = Instance.new("TextButton")
        FloatingButton.Name = "FloatingToggleButton"
        FloatingButton.Size = UDim2.new(0, 50, 0, 50)
        FloatingButton.Position = UDim2.new(0.85, 0, 0.15, 0)
        FloatingButton.BackgroundColor3 = WindowObj.Theme.Main
        FloatingButton.Text = "🔅"
        FloatingButton.TextSize = 20
        FloatingButton.TextColor3 = WindowObj.Theme.Text
        FloatingButton.Font = Enum.Font.LuckiestGuy
        FloatingButton.Parent = ScreenGui
        
        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(0, 8)
        UICorner.Parent = FloatingButton
        
        local UIStroke = Instance.new("UIStroke")
        UIStroke.Color = WindowObj.Theme.Accent
        UIStroke.Thickness = 2
        UIStroke.Parent = FloatingButton
        
        local dragging, dragInput, dragStart, startPos
        local function update(input)
            local delta = input.Position - dragStart
            local newX = math.clamp(startPos.X.Offset + delta.X, 0, ScreenGui.AbsoluteSize.X - FloatingButton.AbsoluteSize.X)
            local newY = math.clamp(startPos.Y.Offset + delta.Y, 0, ScreenGui.AbsoluteSize.Y - FloatingButton.AbsoluteSize.Y)
            FloatingButton.Position = UDim2.new(0, newX, 0, newY)
        end
        
        FloatingButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = FloatingButton.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        
        FloatingButton.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
        
        services.UIS.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                update(input)
            end
        end)
        
        table.insert(WindowObj.Connections, FloatingButton.MouseButton1Click:Connect(function()
            WindowObj:ToggleVisibility()
        end))
        
        table.insert(WindowObj.Connections, FloatingButton.MouseEnter:Connect(function()
            services.TweenService:Create(FloatingButton, TweenInfo.new(0.15), {
                Size = UDim2.new(0, 55, 0, 55),
                BackgroundTransparency = 0.2
            }):Play()
        end))
        
        table.insert(WindowObj.Connections, FloatingButton.MouseLeave:Connect(function()
            services.TweenService:Create(FloatingButton, TweenInfo.new(0.15), {
                Size = UDim2.new(0, 50, 0, 50),
                BackgroundTransparency = 0
            }):Play()
        end))
        
        WindowObj.FloatingButton = FloatingButton
        return FloatingButton
    end

    function WindowObj:ToggleVisibility()
        if Main.Visible then
            services.TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Cubic), {
                Position = UDim2.new(0.5, -GeminiLib.Config.WindowWidth/2, 1.5, 0)
            }):Play()
            if WindowObj.FloatingButton then
                WindowObj.FloatingButton.Text = "🔅"
            end
            stopStatsUpdate()
            task.wait(0.3)
            Main.Visible = false
        else
            Main.Visible = true
            Main.Position = UDim2.new(0.5, -GeminiLib.Config.WindowWidth/2, 1.5, 0)
            services.TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Cubic), {
                Position = WindowObj.OriginalPosition or UDim2.new(0.5, -GeminiLib.Config.WindowWidth/2, 0.5, -GeminiLib.Config.WindowHeight/2)
            }):Play()
            if WindowObj.FloatingButton then
                WindowObj.FloatingButton.Text = "💠"
            end
            startStatsUpdate()
        end
    end

    function WindowObj:Destroy()
        stopStatsUpdate()
        for _, connection in pairs(WindowObj.Connections) do
            if connection then
                pcall(function() connection:Disconnect() end)
            end
        end
        for _, dropdown in pairs(WindowObj.OpenDropdowns) do
            if dropdown.Close then
                pcall(dropdown.Close)
            end
        end
        if WindowObj.FloatingButton then
            WindowObj.FloatingButton:Destroy()
        end
        ScreenGui:Destroy()
        for k in pairs(WindowObj) do
            WindowObj[k] = nil
        end
    end
    
    task.wait(0.1)
    WindowObj:CreateFloatingButton()

    return WindowObj
end

-- Функция создания уведомления
function GeminiLib:CreateNotification(notificationData)
    notificationData = notificationData or {}
    local title = notificationData.Title or "Notification"
    local text = notificationData.Text or "No text provided"
    local duration = notificationData.Duration or 5
    
    local NotificationsGui = game:GetService("CoreGui"):FindFirstChild("GeminiNotifications") 
        or Instance.new("ScreenGui")
    NotificationsGui.Name = "GeminiNotifications"
    NotificationsGui.Parent = game:GetService("CoreGui")
    NotificationsGui.ResetOnSpawn = false
    
    local notificationFrame = Instance.new("Frame")
    notificationFrame.Name = "Notification"
    notificationFrame.Size = UDim2.new(0, 300, 0, 80)
    notificationFrame.Position = UDim2.new(1, -320, 1, -100)
    notificationFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    notificationFrame.BorderSizePixel = 0
    
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 8)
    uiCorner.Parent = notificationFrame
    
    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = Color3.fromRGB(80, 170, 255)
    uiStroke.Thickness = 2
    uiStroke.Parent = notificationFrame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Text = title
    titleLabel.Size = UDim2.new(1, -20, 0, 25)
    titleLabel.Position = UDim2.new(0, 10, 0, 5)
    titleLabel.TextColor3 = Color3.fromRGB(230, 230, 235)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.BackgroundTransparency = 1
    titleLabel.Parent = notificationFrame
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "Text"
    textLabel.Text = text
    textLabel.Size = UDim2.new(1, -20, 0, 45)
    textLabel.Position = UDim2.new(0, 10, 0, 30)
    textLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextSize = 12
    textLabel.TextWrapped = true
    textLabel.BackgroundTransparency = 1
    textLabel.Parent = notificationFrame
    
    notificationFrame.Parent = NotificationsGui
    
    notificationFrame.Position = UDim2.new(1, 320, 1, -100)
    game:GetService("TweenService"):Create(notificationFrame, TweenInfo.new(0.3), {
        Position = UDim2.new(1, -320, 1, -100)
    }):Play()
    
    task.delay(duration, function()
        game:GetService("TweenService"):Create(notificationFrame, TweenInfo.new(0.3), {
            Position = UDim2.new(1, 320, 1, -100)
        }):Play()
        task.wait(0.3)
        notificationFrame:Destroy()
    end)
end

return GeminiLib
