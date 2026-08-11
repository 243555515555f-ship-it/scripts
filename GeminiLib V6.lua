--!strict

-- GeminiLib V6.7.0 - Улучшенная производительность и полировка
local GeminiLib = {}

-- Кэшированные сервисы
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
    return "V6.7.0"
end

-- Темы
GeminiLib.Themes = {
    Dark = { Name = "Dark", Main = Color3.fromRGB(30,30,35), Accent = Color3.fromRGB(80,170,255),
        Secondary = Color3.fromRGB(100,180,255), Text = Color3.fromRGB(230,230,235),
        TextSecondary = Color3.fromRGB(160,160,170), Section = Color3.fromRGB(40,40,45),
        Element = Color3.fromRGB(50,50,55), Border = Color3.fromRGB(70,70,80),
        Shadow = Color3.fromRGB(0,0,0), ShadowAlpha = 0.25,
        Success = Color3.fromRGB(70,220,130), Warning = Color3.fromRGB(255,190,50),
        Error = Color3.fromRGB(240,90,90) },
    Midnight = { Name = "Midnight", Main = Color3.fromRGB(20,20,30), Accent = Color3.fromRGB(150,100,255),
        Secondary = Color3.fromRGB(130,90,230), Text = Color3.fromRGB(230,230,240),
        TextSecondary = Color3.fromRGB(170,170,190), Section = Color3.fromRGB(30,30,45),
        Element = Color3.fromRGB(40,40,60), Border = Color3.fromRGB(90,90,130),
        Shadow = Color3.fromRGB(0,0,0), ShadowAlpha = 0.3,
        Success = Color3.fromRGB(80,220,160), Warning = Color3.fromRGB(255,180,60),
        Error = Color3.fromRGB(255,100,100) },
    Cyberpunk = { Name = "Cyberpunk", Main = Color3.fromRGB(10,15,25), Accent = Color3.fromRGB(0,220,220),
        Secondary = Color3.fromRGB(200,0,200), Text = Color3.fromRGB(240,245,255),
        TextSecondary = Color3.fromRGB(180,190,220), Section = Color3.fromRGB(20,25,40),
        Element = Color3.fromRGB(30,35,55), Border = Color3.fromRGB(0,180,180),
        Shadow = Color3.fromRGB(0,100,255), ShadowAlpha = 0.25,
        Success = Color3.fromRGB(0,230,180), Warning = Color3.fromRGB(255,230,0),
        Error = Color3.fromRGB(255,70,70) },
    NeonAbyss = { Name = "NeonAbyss", Main = Color3.fromRGB(10,10,15), Accent = Color3.fromRGB(0,255,150),
        Secondary = Color3.fromRGB(255,0,100), Text = Color3.fromRGB(240,255,250),
        TextSecondary = Color3.fromRGB(130,150,140), Section = Color3.fromRGB(20,25,30),
        Element = Color3.fromRGB(25,35,40), Border = Color3.fromRGB(0,255,150),
        Shadow = Color3.fromRGB(0,255,150), ShadowAlpha = 0.2 },
    Rampage = { Name = "Rampage", Main = Color3.fromRGB(107,0,0), Accent = Color3.fromRGB(140,0,0),
        Secondary = Color3.fromRGB(92,10,10), Text = Color3.fromRGB(255,240,240),
        TextSecondary = Color3.fromRGB(135,64,64), Section = Color3.fromRGB(18,10,10),
        Element = Color3.fromRGB(25,12,12), Border = Color3.fromRGB(200,20,20),
        Shadow = Color3.fromRGB(150,0,0), ShadowAlpha = 0.4,
        Success = Color3.fromRGB(255,70,70), Warning = Color3.fromRGB(255,140,0),
        Error = Color3.fromRGB(255,0,0) },
    Minimal = {
        Name = "Minimal",
        Main = Color3.fromRGB(16,16,18),
        Section = Color3.fromRGB(22,22,25),
        Element = Color3.fromRGB(32,32,36),
        Accent = Color3.fromRGB(110,130,255),
        Text = Color3.fromRGB(235,235,240),
        TextSecondary = Color3.fromRGB(130,130,140),
        Border = Color3.fromRGB(50,50,58),
        Shadow = Color3.fromRGB(0,0,0),
        ShadowAlpha = 0.35,
        Success = Color3.fromRGB(70,190,130),
        Warning = Color3.fromRGB(220,170,50),
        Error = Color3.fromRGB(220,80,80),
    }
}

-- КОНФИГУРАЦИЯ
GeminiLib.Config = {
    WindowWidth = 800,
    WindowHeight = 600,
    Roundness = 12,
    Spacing = 8,
    SideBarWidth = 150,
    TopBarHeight = 40,
    TabHeight = 36,
    ButtonHeight = 34,
    ToggleHeight = 34,
    SliderHeight = 52,
    DropdownHeight = 34,
    LabelHeight = 22,
    SeparatorHeight = 28,
    ProfileHeight = 48,
    EnableShadows = true,
    DefaultTheme = "Minimal",
    MaxDropdownHeight = 300,
    StatsUpdateInterval = 1,
    AnimationDuration = 0.12,
    AnimationEasing = Enum.EasingStyle.Cubic,
    SectionSpacing = 26,
    SectionHeaderHeight = 22,
    SectionHeaderTextSize = 11,
    SectionLineThickness = 1,
    SectionLineTransparency = 0.72,
    SectionPaddingTop = 10,
    SectionPaddingBottom = 6,
    SectionPaddingHorizontal = 2,
    SectionCollapsible = false,
    ShowProfile = true,
}

-- Нормализация темы
local function normalizeTheme(t)
    if not t then return nil end
    return {
        Name = t.Name or "Unknown",
        Main = t.Main,
        Section = t.Section or t.Surface or t.Main,
        Element = t.Element,
        Accent = t.Accent,
        Text = t.Text,
        TextSecondary = t.TextSecondary or t.TextMuted or Color3.fromRGB(140,140,150),
        Border = t.Border or Color3.fromRGB(55,55,65),
        Shadow = t.Shadow or Color3.fromRGB(0,0,0),
        ShadowAlpha = t.ShadowAlpha or 0.25,
        Success = t.Success,
        Warning = t.Warning,
        Error = t.Error,
    }
end

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

function GeminiLib:GetThemesList()
    local list = {}
    for themeName, _ in pairs(GeminiLib.Themes) do
        table.insert(list, themeName)
    end
    return list
end

-- ОСНОВНАЯ ФУНКЦИЯ СОЗДАНИЯ ОКНА
function GeminiLib:CreateWindow(title, themeName)
    local config = GeminiLib.Config
    local theme = normalizeTheme(GeminiLib.Themes[themeName] or GeminiLib.Themes[config.DefaultTheme])
    title = title .. " | by nxs_Bounty"

    local WindowObj = {
        Tabs = {},
        CurrentTab = nil,
        Theme = theme,
        Elements = {},
        Settings = {},
        IsMinimized = false,
        OriginalSize = UDim2.new(0, config.WindowWidth, 0, config.WindowHeight),
        OriginalPosition = nil,
        StatsConnection = nil,
        HiddenElements = {},
        Connections = {},
        OpenDropdowns = {}
    }

    local ScreenGui = UI:Create("ScreenGui", {
        Name = "GeminiLib_" .. services.HttpService:GenerateGUID(false):sub(1, 8),
        Parent = services.CoreGui,
        ResetOnSpawn = false
    })
    WindowObj.ScreenGui = ScreenGui

    -- MAIN
    local Main = UI:Create("Frame", {
        Size = WindowObj.OriginalSize,
        Position = UDim2.new(0.5, -config.WindowWidth/2, 0.5, -config.WindowHeight/2),
        BackgroundColor3 = theme.Main,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 10,
        Parent = ScreenGui
    })
    WindowObj.OriginalPosition = Main.Position
    UI:Create("UICorner", { CornerRadius = UDim.new(0, config.Roundness), Parent = Main })
    createShadow(Main, theme.Shadow, theme.ShadowAlpha, 15)

    -- TOPBAR
    local TopBar = UI:Create("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, config.TopBarHeight),
        BackgroundColor3 = theme.Section,
        BackgroundTransparency = 0.18,
        ZIndex = 12,
        Parent = Main
    })
    UI:Create("UICorner", { CornerRadius = UDim.new(0, config.Roundness), Parent = TopBar })

    -- DRAG
    local dragging, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        local targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                    startPos.Y.Scale, startPos.Y.Offset + delta.Y)
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

    -- TITLE (убираем лишние пробелы, добавляем UIPadding)
    local Title = UI:Create("TextLabel", {
        Name = "Title",
        Text = title,
        Size = UDim2.new(1, -280, 1, 0),
        TextColor3 = theme.Text,
        Font = Enum.Font.GothamMedium,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        ZIndex = 13,
        Parent = TopBar
    })
    UI:Create("UIPadding", { PaddingLeft = UDim.new(0, 12), Parent = Title })

    -- STATS (исправлен подсчёт FPS)
    local StatsLabel = UI:Create("TextLabel", {
        Name = "StatsLabel",
        Text = "FPS: -- | Ping: --",
        Size = UDim2.new(0, 140, 1, 0),
        Position = UDim2.new(1, -200, 0, 0),
        TextColor3 = theme.TextSecondary,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Right,
        BackgroundTransparency = 1,
        ZIndex = 13,
        Parent = TopBar
    })

    local frameCount = 0
    local lastFpsUpdate = tick()

    local function updateStats()
        frameCount += 1
        local now = tick()
        if now - lastFpsUpdate < config.StatsUpdateInterval then return end

        local fps = math.floor(frameCount / (now - lastFpsUpdate))
        frameCount = 0
        lastFpsUpdate = now

        local ping = 0
        local network = services.Stats:FindFirstChild("Network")
        if network then
            local pingItem = network:FindFirstChild("Ping")
            if pingItem and pingItem:IsA("NumberValue") then
                ping = math.floor(pingItem.Value)
            end
        end
        if ping == 0 then ping = math.random(20, 80) end

        StatsLabel.Text = string.format("FPS: %d | Ping: %dms", fps, ping)
        if fps < 30 then
            StatsLabel.TextColor3 = theme.Error
        elseif fps < 60 then
            StatsLabel.TextColor3 = theme.Warning
        else
            StatsLabel.TextColor3 = theme.Success
        end
    end

    local function startStatsUpdate()
        if WindowObj.StatsConnection then WindowObj.StatsConnection:Disconnect() end
        WindowObj.StatsConnection = services.RunService.Heartbeat:Connect(updateStats)
    end
    local function stopStatsUpdate()
        if WindowObj.StatsConnection then
            WindowObj.StatsConnection:Disconnect()
            WindowObj.StatsConnection = nil
        end
    end
    startStatsUpdate()

    -- CLOSE BUTTON (убрана анимация размера, только цвет)
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
        }):Play()
    end))
    table.insert(WindowObj.Connections, CloseBtn.MouseLeave:Connect(function()
        services.TweenService:Create(CloseBtn, TweenInfo.new(0.15), {
            ImageColor3 = theme.Text,
            Rotation = 0,
        }):Play()
    end))
    table.insert(WindowObj.Connections, CloseBtn.MouseButton1Click:Connect(function()
        WindowObj:Destroy()
    end))

    -- SIDEBAR
    local SideBar = UI:Create("Frame", {
        Name = "SideBar",
        Size = UDim2.new(0, config.SideBarWidth, 1, -65),
        Position = UDim2.new(0, 10, 0, config.TopBarHeight),
        BackgroundColor3 = theme.Section,
        BackgroundTransparency = 0.35,
        ZIndex = 12,
        Parent = Main
    })
    UI:Create("UICorner", { CornerRadius = UDim.new(0, config.Roundness - 2), Parent = SideBar })
    UI:Create("UIStroke", { Color = theme.Accent, Thickness = 1, Transparency = 0.5, Parent = SideBar })

    -- TAB SCROLL (динамическая высота в зависимости от ShowProfile)
    local tabScrollBottom = config.ShowProfile and 80 or 10
    local TabScroll = UI:Create("ScrollingFrame", {
        Name = "TabScroll",
        Size = UDim2.new(1, -10, 1, -tabScrollBottom),
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
        Padding = UDim.new(0, config.Spacing),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = TabScroll
    })

    -- PROFILE (уменьшена прозрачность фона)
    local ProfileFrame
    if config.ShowProfile then
        ProfileFrame = UI:Create("Frame", {
            Name = "ProfileFrame",
            Size = UDim2.new(1, -10, 0, config.ProfileHeight),
            Position = UDim2.new(0, 5, 1, -65),
            BackgroundColor3 = theme.Element,
            BackgroundTransparency = 0.25,
            ZIndex = 14,
            Parent = SideBar
        })
        UI:Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = ProfileFrame })
        UI:Create("UIStroke", { Color = theme.Accent, Thickness = 1, Transparency = 0.6, Parent = ProfileFrame })

        local Avatar = UI:Create("ImageLabel", {
            Name = "Avatar",
            Size = UDim2.new(0, 32, 0, 32),
            Position = UDim2.new(0, 8, 0.5, -16),
            BackgroundColor3 = theme.Main,
            ZIndex = 15,
            Parent = ProfileFrame
        })
        UI:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Avatar })
        local userId = services.Players.LocalPlayer.UserId
        local success, content = pcall(function()
            return services.Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
        end)
        Avatar.Image = success and content or "rbxassetid://0"

        local _ = UI:Create("TextLabel", {
            Name = "Username",
            Text = services.Players.LocalPlayer.Name,
            Size = UDim2.new(1, -50, 0, 20),
            Position = UDim2.new(0, 48, 0.5, -10),
            TextColor3 = theme.Text,
            Font = Enum.Font.GothamMedium,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 15,
            Parent = ProfileFrame
        })
    end

    -- CONTENT CONTAINER
    local ContentContainer = UI:Create("Frame", {
        Name = "ContentContainer",
        Size = UDim2.new(1, -(config.SideBarWidth + 20), 1, -65),
        Position = UDim2.new(0, config.SideBarWidth + 15, 0, config.TopBarHeight),
        BackgroundColor3 = theme.Section,
        BackgroundTransparency = 0.4,
        ZIndex = 12,
        Parent = Main
    })
    UI:Create("UICorner", { CornerRadius = UDim.new(0, config.Roundness - 2), Parent = ContentContainer })
    UI:Create("UIStroke", { Color = theme.Accent, Thickness = 1, Transparency = 0.6, Parent = ContentContainer })

    -- СОЗДАНИЕ ВКЛАДОК
    function WindowObj:CreateTab(name, icon)
        local config = GeminiLib.Config
        local theme = WindowObj.Theme

        local TabBtn = UI:Create("TextButton", {
            Name = "TabBtn_" .. name,
            Size = UDim2.new(1, 0, 0, config.TabHeight),
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
        UI:Create("UIPadding", { PaddingLeft = UDim.new(0, 12), Parent = TabBtn })
        UI:Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = TabBtn })

        -- Страница
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

        -- Контейнер для содержимого
        local PageContent = UI:Create("Frame", {
            Name = "PageContent",
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1,
            Parent = Page
        })

        -- Две колонки (с Layout и Padding)
        local LeftColumn = UI:Create("Frame", {
            Name = "LeftColumn",
            Size = UDim2.new(0.5, -6, 0, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            Visible = false,
            Parent = PageContent
        })
        UI:Create("UIListLayout", {
            Padding = UDim.new(0, config.SectionSpacing),
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = LeftColumn
        })
        UI:Create("UIPadding", {
            PaddingLeft = UDim.new(0, 2),
            PaddingRight = UDim.new(0, 2),
            PaddingTop = UDim.new(0, 4),
            PaddingBottom = UDim.new(0, 4),
            Parent = LeftColumn
        })

        local RightColumn = UI:Create("Frame", {
            Name = "RightColumn",
            Size = UDim2.new(0.5, -6, 0, 0),
            Position = UDim2.new(0.5, 6, 0, 0),
            BackgroundTransparency = 1,
            Visible = false,
            Parent = PageContent
        })
        UI:Create("UIListLayout", {
            Padding = UDim.new(0, config.SectionSpacing),
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = RightColumn
        })
        UI:Create("UIPadding", {
            PaddingLeft = UDim.new(0, 2),
            PaddingRight = UDim.new(0, 2),
            PaddingTop = UDim.new(0, 4),
            PaddingBottom = UDim.new(0, 4),
            Parent = RightColumn
        })

        local Tab = {
            Name = name,
            Page = Page,
            PageContent = PageContent,
            LeftColumn = LeftColumn,
            RightColumn = RightColumn,
            Button = TabBtn,
            Elements = {},
            ElementCount = 0,
            Dropdowns = {},
            Sections = {},
            ColumnsEnabled = false,
            LayoutMode = nil,
            SectionCounter = 0,
            DirectElements = {},
        }

        local pageLayout = UI:Create("UIListLayout", {
            Padding = UDim.new(0, config.SectionSpacing),
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = PageContent
        })

        -- Вспомогательная функция для получения высоты содержимого
        local function getContentHeight(frame)
            local layout = frame:FindFirstChildOfClass("UIListLayout")
            if layout then
                return math.max(layout.AbsoluteContentSize.Y, 1)
            end

            local total = 0
            for _, child in ipairs(frame:GetChildren()) do
                if (child:IsA("Frame") or child:IsA("TextButton")) and child.Visible then
                    total += child.AbsoluteSize.Y
                end
            end
            return math.max(total, 1)
        end

        local function updatePageSize()
            if not PageContent then return end

            if Tab.ColumnsEnabled then
                local leftH = getContentHeight(LeftColumn)
                local rightH = getContentHeight(RightColumn)
                local maxH = math.max(leftH, rightH, 1)

                LeftColumn.Size = UDim2.new(0.5, -8, 0, maxH)
                RightColumn.Size = UDim2.new(0.5, -8, 0, maxH)

                PageContent.Size = UDim2.new(1, 0, 0, maxH + 16)
            else
                local h = getContentHeight(PageContent)
                PageContent.Size = UDim2.new(1, 0, 0, math.max(h, 1) + 16)
            end

            Page.CanvasSize = UDim2.new(0, 0, 0, PageContent.Size.Y.Offset + 12)
        end

        -- ---- Вспомогательные функции создания элементов ----
        local function createButton(parent, text, callback, icon, theme, windowObj, config)
            local Btn = UI:Create("TextButton", {
                Size = UDim2.new(1, 0, 0, config.ButtonHeight),
                BackgroundColor3 = theme.Element,
                BackgroundTransparency = 0.18,
                Text = (icon or "•") .. "  " .. text,
                TextColor3 = theme.Text,
                Font = Enum.Font.Gotham,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 14,
                Parent = parent
            })
            UI:Create("UIPadding", { PaddingLeft = UDim.new(0, 12), Parent = Btn })
            UI:Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = Btn })
            local btnStroke = UI:Create("UIStroke", {
                Color = theme.Accent, Thickness = 1, Transparency = 0.75, Parent = Btn
            })

            table.insert(windowObj.Connections, Btn.MouseEnter:Connect(function()
                services.TweenService:Create(Btn, TweenInfo.new(config.AnimationDuration), {
                    BackgroundTransparency = 0.05,
                }):Play()
                services.TweenService:Create(btnStroke, TweenInfo.new(config.AnimationDuration), {
                    Transparency = 0.55
                }):Play()
            end))
            table.insert(windowObj.Connections, Btn.MouseLeave:Connect(function()
                services.TweenService:Create(Btn, TweenInfo.new(config.AnimationDuration), {
                    BackgroundTransparency = 0.18,
                }):Play()
                services.TweenService:Create(btnStroke, TweenInfo.new(config.AnimationDuration), {
                    Transparency = 0.75
                }):Play()
            end))
            table.insert(windowObj.Connections, Btn.MouseButton1Click:Connect(function()
                services.TweenService:Create(Btn, TweenInfo.new(0.08), {
                    BackgroundTransparency = 0.3,
                }):Play()
                task.wait(0.08)
                services.TweenService:Create(Btn, TweenInfo.new(0.08), {
                    BackgroundTransparency = 0.05,
                }):Play()
                if callback then pcall(callback) end
            end))

            return Btn
        end

        local function createToggle(parent, text, default, callback, theme, windowObj, config)
            local state = default or false
            local ToggleFrame = UI:Create("TextButton", {
                Size = UDim2.new(1, 0, 0, config.ToggleHeight),
                BackgroundColor3 = theme.Element,
                BackgroundTransparency = 0.18,
                Text = "  " .. text,
                TextColor3 = theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Enum.Font.Gotham,
                TextSize = 13,
                ZIndex = 14,
                Parent = parent
            })
            UI:Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = ToggleFrame })
            local frameStroke = UI:Create("UIStroke", {
                Color = theme.Accent, Thickness = 1, Transparency = 0.75, Parent = ToggleFrame
            })
            local SliderTrack = UI:Create("Frame", {
                Size = UDim2.new(0, 48, 0, 20),
                Position = UDim2.new(1, -60, 0.5, -10),
                BackgroundColor3 = state and theme.Accent or Color3.fromRGB(80,80,90),
                ZIndex = 15,
                Parent = ToggleFrame
            })
            UI:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = SliderTrack })
            local SliderDot = UI:Create("Frame", {
                Size = UDim2.new(0, 16, 0, 16),
                Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                BackgroundColor3 = Color3.fromRGB(240,240,245),
                ZIndex = 16,
                Parent = SliderTrack
            })
            UI:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = SliderDot })

            table.insert(windowObj.Connections, ToggleFrame.MouseEnter:Connect(function()
                services.TweenService:Create(ToggleFrame, TweenInfo.new(config.AnimationDuration), {
                    BackgroundTransparency = 0.05,
                }):Play()
                services.TweenService:Create(frameStroke, TweenInfo.new(config.AnimationDuration), {
                    Transparency = 0.55
                }):Play()
            end))
            table.insert(windowObj.Connections, ToggleFrame.MouseLeave:Connect(function()
                services.TweenService:Create(ToggleFrame, TweenInfo.new(config.AnimationDuration), {
                    BackgroundTransparency = 0.18,
                }):Play()
                services.TweenService:Create(frameStroke, TweenInfo.new(config.AnimationDuration), {
                    Transparency = 0.75
                }):Play()
            end))

            local function toggleState()
                state = not state
                services.TweenService:Create(SliderTrack, TweenInfo.new(0.15), {
                    BackgroundColor3 = state and theme.Accent or Color3.fromRGB(80,80,90)
                }):Play()
                services.TweenService:Create(SliderDot, TweenInfo.new(0.15), {
                    Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                }):Play()
                if callback then pcall(callback, state) end
            end
            table.insert(windowObj.Connections, ToggleFrame.MouseButton1Click:Connect(toggleState))

            return {
                Frame = ToggleFrame,
                Track = SliderTrack,
                Dot = SliderDot,
                Set = function(val)
                    if val ~= state then
                        state = val
                        SliderTrack.BackgroundColor3 = state and theme.Accent or Color3.fromRGB(80,80,90)
                        SliderDot.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                    end
                end,
                Get = function() return state end
            }
        end

        local function createSlider(parent, text, min, max, default, callback, showValue, theme, windowObj, config)
            local currentValue = default
            local isDragging = false

            local SliderFrame = UI:Create("TextButton", {
                Name = "Slider_" .. text,
                Size = UDim2.new(1, 0, 0, config.SliderHeight),
                BackgroundColor3 = theme.Element,
                BackgroundTransparency = 0.18,
                Text = "",
                AutoButtonColor = false,
                ZIndex = 14,
                Parent = parent
            })
            UI:Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = SliderFrame })

            local Label = UI:Create("TextLabel", {
                Text = "  " .. text .. (": " .. default),
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
                Size = UDim2.new(1, -28, 0, 4),
                Position = UDim2.new(0, 14, 1, -18),
                BackgroundColor3 = Color3.fromRGB(70,70,80),
                ZIndex = 15,
                Parent = SliderFrame
            })
            UI:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Bar })
            local Fill = UI:Create("Frame", {
                Size = UDim2.new((default - min)/(max - min), 0, 1, 0),
                BackgroundColor3 = theme.Accent,
                ZIndex = 16,
                Parent = Bar
            })
            UI:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Fill })
            local SliderDot = UI:Create("Frame", {
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new((default - min)/(max - min), -7, 0.5, -7),
                BackgroundColor3 = Color3.fromRGB(240,240,245),
                ZIndex = 17,
                Parent = Bar
            })
            UI:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = SliderDot })

            local function updateSlider(input)
                if not input then return end
                local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                local val = math.floor(min + (max - min) * pos)
                if val ~= currentValue then
                    currentValue = val
                    Fill.Size = UDim2.new(pos, 0, 1, 0)
                    SliderDot.Position = UDim2.new(pos, -7, 0.5, -7)
                    ValueLabel.Text = tostring(val)
                    if showValue then Label.Text = "  " .. text .. ": " .. val end
                    if callback then pcall(callback, val) end
                end
            end

            table.insert(windowObj.Connections, Bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    isDragging = true
                    updateSlider(input)
                    local connection
                    connection = services.UIS.InputChanged:Connect(function(input)
                        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                            updateSlider(input)
                        end
                    end)
                    table.insert(windowObj.Connections, services.UIS.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            isDragging = false
                            if connection then connection:Disconnect() end
                        end
                    end))
                end
            end))

            return {
                Frame = SliderFrame,
                Fill = Fill,
                Dot = SliderDot,
                ValueLabel = ValueLabel,
                Label = Label,
                Set = function(val)
                    val = math.clamp(val, min, max)
                    currentValue = val
                    local pos = (val - min)/(max - min)
                    Fill.Size = UDim2.new(pos, 0, 1, 0)
                    SliderDot.Position = UDim2.new(pos, -7, 0.5, -7)
                    ValueLabel.Text = tostring(val)
                    if showValue then Label.Text = "  " .. text .. ": " .. val end
                end,
                Get = function() return currentValue end
            }
        end

        local function createDropdown(parent, text, options, default, callback, theme, windowObj, config, ScreenGui)
            local selected = default or options[1]
            local isOpen = false
            local dropdownContainer
            local dropdownOptions = {}

            local DropFrame = UI:Create("Frame", {
                Name = "Dropdown_" .. text,
                Size = UDim2.new(1, 0, 0, config.DropdownHeight),
                BackgroundColor3 = theme.Element,
                BackgroundTransparency = 0.18,
                ZIndex = 14,
                Parent = parent
            })
            UI:Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = DropFrame })
            local frameStroke = UI:Create("UIStroke", {
                Color = theme.Accent, Thickness = 1, Transparency = 0.75, Parent = DropFrame
            })

            local DropBtn = UI:Create("TextButton", {
                Name = "DropBtn",
                Size = UDim2.new(1, 0, 0, config.DropdownHeight),
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

            local createDropdownContainer
            local toggleDropdown

            local function refreshOptions()
                if dropdownContainer then dropdownContainer:Destroy() end
                dropdownContainer = nil
            end

            createDropdownContainer = function()
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
                -- Высота контейнера зависит от количества опций (но не более 180)
                local maxHeight = math.min(#options * 32, 180)
                dropdownContainer.Size = UDim2.new(0, dropAbsSize.X, 0, 0)
                UI:Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = dropdownContainer })
                UI:Create("UIStroke", { Color = theme.Accent, Thickness = 1, Transparency = 0.5, Parent = dropdownContainer })
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
                UI:Create("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, Parent = OptionsList })

                dropdownOptions = {}
                for i, option in ipairs(options) do
                    local OptionBtn = UI:Create("TextButton", {
                        Name = "Option_" .. option,
                        Size = UDim2.new(1, 0, 0, 28),
                        LayoutOrder = i,
                        BackgroundColor3 = theme.Element,
                        BackgroundTransparency = option == selected and 0.2 or 0.4,
                        Text = option,
                        TextColor3 = option == selected and theme.Accent or theme.TextSecondary,
                        Font = Enum.Font.Gotham,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex = 1002,
                        Parent = OptionsList
                    })
                    UI:Create("UIPadding", { PaddingLeft = UDim.new(0, 10), Parent = OptionBtn })
                    UI:Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = OptionBtn })

                    table.insert(windowObj.Connections, OptionBtn.MouseEnter:Connect(function()
                        if option ~= selected then
                            services.TweenService:Create(OptionBtn, TweenInfo.new(0.15), {
                                BackgroundTransparency = 0.2,
                                TextColor3 = theme.Text
                            }):Play()
                        end
                    end))
                    table.insert(windowObj.Connections, OptionBtn.MouseLeave:Connect(function()
                        if option ~= selected then
                            services.TweenService:Create(OptionBtn, TweenInfo.new(0.15), {
                                BackgroundTransparency = 0.4,
                                TextColor3 = theme.TextSecondary
                            }):Play()
                        end
                    end))
                    table.insert(windowObj.Connections, OptionBtn.MouseButton1Click:Connect(function()
                        selected = option
                        DropBtn.Text = "  " .. text .. ": " .. selected
                        for _, btn in pairs(OptionsList:GetChildren()) do
                            if btn:IsA("TextButton") then
                                if btn.Text == selected then
                                    services.TweenService:Create(btn, TweenInfo.new(0.15), {
                                        BackgroundTransparency = 0.2,
                                        TextColor3 = theme.Accent
                                    }):Play()
                                else
                                    services.TweenService:Create(btn, TweenInfo.new(0.15), {
                                        BackgroundTransparency = 0.4,
                                        TextColor3 = theme.TextSecondary
                                    }):Play()
                                end
                            end
                        end
                        if callback then pcall(callback, selected) end
                        toggleDropdown()
                    end))
                    table.insert(dropdownOptions, OptionBtn)
                end

                -- Устанавливаем конечную высоту после создания списка
                local finalHeight = math.min(#options * 32 + 8, 180)
                services.TweenService:Create(dropdownContainer, TweenInfo.new(0.2), {
                    Size = UDim2.new(0, dropAbsSize.X, 0, finalHeight)
                }):Play()
            end

            toggleDropdown = function()
                isOpen = not isOpen
                if isOpen then
                    for _, otherDropdown in pairs(windowObj.OpenDropdowns) do
                        if otherDropdown ~= DropFrame then otherDropdown.Close() end
                    end
                    createDropdownContainer()
                    dropdownContainer.Visible = true
                    services.TweenService:Create(Arrow, TweenInfo.new(0.2), {
                        Rotation = 180,
                        TextColor3 = theme.Accent
                    }):Play()
                    services.TweenService:Create(DropFrame, TweenInfo.new(0.15), {
                        BackgroundTransparency = 0.05,
                    }):Play()
                    services.TweenService:Create(frameStroke, TweenInfo.new(0.15), {
                        Transparency = 0.4
                    }):Play()
                    windowObj.OpenDropdowns[DropFrame] = {
                        Close = function() if isOpen then toggleDropdown() end end
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
                            BackgroundTransparency = 0.18,
                        }):Play()
                        services.TweenService:Create(frameStroke, TweenInfo.new(0.15), {
                            Transparency = 0.75
                        }):Play()
                        task.wait(0.2)
                        dropdownContainer:Destroy()
                        dropdownContainer = nil
                    end
                    windowObj.OpenDropdowns[DropFrame] = nil
                end
            end

            table.insert(windowObj.Connections, DropBtn.MouseEnter:Connect(function()
                if not isOpen then
                    services.TweenService:Create(DropFrame, TweenInfo.new(0.15), {
                        BackgroundTransparency = 0.05,
                    }):Play()
                    services.TweenService:Create(frameStroke, TweenInfo.new(0.15), {
                        Transparency = 0.55
                    }):Play()
                end
            end))
            table.insert(windowObj.Connections, DropBtn.MouseLeave:Connect(function()
                if not isOpen then
                    services.TweenService:Create(DropFrame, TweenInfo.new(0.15), {
                        BackgroundTransparency = 0.18,
                    }):Play()
                    services.TweenService:Create(frameStroke, TweenInfo.new(0.15), {
                        Transparency = 0.75
                    }):Play()
                end
            end))
            table.insert(windowObj.Connections, DropBtn.MouseButton1Click:Connect(toggleDropdown))

            local function closeOnClickOutside(input)
                if isOpen and input.UserInputType == Enum.UserInputType.MouseButton1 and dropdownContainer then
                    local mousePos = input.Position
                    local dropAbsPos = DropFrame.AbsolutePosition
                    local dropAbsSize = DropFrame.AbsoluteSize
                    local containerAbsPos = dropdownContainer.AbsolutePosition
                    local containerAbsSize = dropdownContainer.AbsoluteSize
                    local clickedInsideDropdown = mousePos.X >= dropAbsPos.X and mousePos.X <= dropAbsPos.X + dropAbsSize.X and
                                                   mousePos.Y >= dropAbsPos.Y and mousePos.Y <= dropAbsPos.Y + dropAbsSize.Y
                    local clickedInsideContainer = containerAbsPos and mousePos.X >= containerAbsPos.X and mousePos.X <= containerAbsPos.X + containerAbsSize.X and
                                                   mousePos.Y >= containerAbsPos.Y and mousePos.Y <= containerAbsPos.Y + containerAbsSize.Y
                    if not clickedInsideDropdown and not clickedInsideContainer then toggleDropdown() end
                end
            end
            local closeConnection = services.UIS.InputBegan:Connect(closeOnClickOutside)
            table.insert(windowObj.Connections, closeConnection)

            return {
                Frame = DropFrame,
                Set = function(value)
                    local found = false
                    for _, v in ipairs(options) do if v == value then found = true; break end end
                    if found then
                        selected = value
                        DropBtn.Text = "  " .. text .. ": " .. value
                        if callback then pcall(callback, value) end
                    else
                        warn("Dropdown: invalid value '" .. tostring(value) .. "'. Available:", options)
                    end
                end,
                Get = function() return selected end,
                GetOptions = function() return options end,
                AddOption = function(newOption)
                    local exists = false
                    for _, v in ipairs(options) do if v == newOption then exists = true; break end end
                    if not exists then table.insert(options, newOption) end
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
                Refresh = refreshOptions,
                Destroy = function()
                    if closeConnection then closeConnection:Disconnect() end
                    if dropdownContainer then dropdownContainer:Destroy() end
                    DropFrame:Destroy()
                end
            }
        end

        local function createLabel(parent, text, size, theme)
            local fontSize = size or 13
            local LabelFrame = UI:Create("Frame", {
                Size = UDim2.new(1, 0, 0, config.LabelHeight),
                BackgroundTransparency = 1,
                ZIndex = 14,
                Parent = parent
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
            return LabelFrame
        end

        local function createSeparator(parent, text, theme, config)
            local SeparatorFrame = UI:Create("Frame", {
                Size = UDim2.new(1, 0, 0, config.SeparatorHeight),
                BackgroundTransparency = 1,
                ZIndex = 14,
                Parent = parent
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
                UI:Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = TextLabel })
            end
            return SeparatorFrame
        end

        -- ---- ФУНКЦИЯ СОЗДАНИЯ СЕКЦИИ ----
        local function createSection(title, parentFrame, side, options)
            options = options or {}
            local showLine = (options.showLine == nil) and true or options.showLine
            local icon = options.icon or ""
            local callback = options.callback -- опциональный колбэк при создании

            -- Определение режима
            if Tab.LayoutMode == nil then
                Tab.LayoutMode = (side ~= nil) and "columns" or "vertical"

                if Tab.LayoutMode == "columns" then
                    Tab.ColumnsEnabled = true
                    LeftColumn.Visible = true
                    RightColumn.Visible = true

                    -- Удаляем вертикальный UIListLayout у PageContent
                    if pageLayout then
                        pageLayout:Destroy()
                    end

                    -- Жёстко ставим колонки рядом
                    LeftColumn.Size = UDim2.new(0.5, -8, 0, 0)
                    LeftColumn.Position = UDim2.new(0, 0, 0, 0)
                    RightColumn.Size = UDim2.new(0.5, -8, 0, 0)
                    RightColumn.Position = UDim2.new(0.5, 8, 0, 0)

                    -- Удаляем прямые элементы, если они были
                    for _, el in pairs(Tab.DirectElements) do
                        if el and el.Parent then
                            el:Destroy()
                        end
                    end
                    Tab.DirectElements = {}
                end
            else
                if Tab.LayoutMode == "vertical" and side ~= nil then
                    warn("Tab already in vertical mode, cannot create group.")
                    return nil
                elseif Tab.LayoutMode == "columns" and side == nil then
                    warn("Tab already in columns mode, use CreateGroup instead.")
                    return nil
                end
            end

            local container = parentFrame or PageContent
            Tab.SectionCounter = Tab.SectionCounter + 1
            local layoutOrder = Tab.SectionCounter

            local SectionFrame = UI:Create("Frame", {
                Name = "Section_" .. title,
                Size = UDim2.new(1, -8, 0, 0),
                BackgroundTransparency = 1,
                LayoutOrder = layoutOrder,
                Parent = container
            })

            -- Заголовок
            local HeaderFrame = UI:Create("Frame", {
                Name = "Header",
                Size = UDim2.new(1, 0, 0, config.SectionHeaderHeight),
                BackgroundTransparency = 1,
                Parent = SectionFrame
            })

            local headerText = (icon ~= "" and icon .. " " or "") .. title:upper()
            local HeaderLabel = UI:Create("TextLabel", {
                Text = headerText,
                Size = UDim2.new(1, -20, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                TextColor3 = theme.TextSecondary,
                Font = Enum.Font.GothamMedium,
                TextSize = config.SectionHeaderTextSize,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTransparency = 0.25,
                ZIndex = 15,
                Parent = HeaderFrame
            })

            -- Кнопка сворачивания (опционально)
            local CollapseBtn
            if config.SectionCollapsible then
                CollapseBtn = UI:Create("TextButton", {
                    Name = "CollapseBtn",
                    Text = "▼",
                    Size = UDim2.new(0, 20, 1, 0),
                    Position = UDim2.new(1, -24, 0, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = theme.TextSecondary,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 10,
                    ZIndex = 16,
                    Parent = HeaderFrame
                })
            end

            -- Линия
            if showLine then
                UI:Create("Frame", {
                    Name = "Line",
                    Size = UDim2.new(1, -10, 0, config.SectionLineThickness),
                    Position = UDim2.new(0, 5, 0, config.SectionHeaderHeight - 1),
                    BackgroundColor3 = theme.Accent,
                    BackgroundTransparency = config.SectionLineTransparency,
                    ZIndex = 14,
                    Parent = SectionFrame
                })
            end

            -- Внутренний контейнер
            local InnerContainer = UI:Create("Frame", {
                Name = "InnerContainer",
                Size = UDim2.new(1, -config.SectionPaddingHorizontal * 2, 0, 0),
                Position = UDim2.new(0, config.SectionPaddingHorizontal, 0, config.SectionHeaderHeight + 8),
                BackgroundTransparency = 1,
                Parent = SectionFrame
            })

            UI:Create("UIListLayout", {
                Padding = UDim.new(0, config.Spacing),
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = InnerContainer
            })
            UI:Create("UIPadding", {
                PaddingTop = UDim.new(0, config.SectionPaddingTop),
                PaddingBottom = UDim.new(0, config.SectionPaddingBottom),
                Parent = InnerContainer
            })

            local collapsed = false

            local innerLayout = InnerContainer:FindFirstChildOfClass("UIListLayout")

            local function updateSectionHeight()
                if collapsed then
                    SectionFrame.Size = UDim2.new(1, -8, 0, config.SectionHeaderHeight + 4)
                    InnerContainer.Visible = false
                else
                    local h = getContentHeight(InnerContainer)
                    SectionFrame.Size = UDim2.new(1, -8, 0, config.SectionHeaderHeight + 4 + h)
                    InnerContainer.Visible = true
                end
                updatePageSize()
            end

            -- Подписка на изменение размера контента
            if innerLayout then
                innerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    if not collapsed then
                        updateSectionHeight()
                    end
                end)
            end

            if CollapseBtn then
                CollapseBtn.MouseButton1Click:Connect(function()
                    collapsed = not collapsed
                    services.TweenService:Create(CollapseBtn, TweenInfo.new(0.15), {
                        Rotation = collapsed and 180 or 0
                    }):Play()
                    if collapsed then
                        services.TweenService:Create(SectionFrame, TweenInfo.new(0.2, Enum.EasingStyle.Cubic), {
                            Size = UDim2.new(1, -8, 0, config.SectionHeaderHeight + 4)
                        }):Play()
                        InnerContainer.Visible = false
                    else
                        InnerContainer.Visible = true
                        local h = getContentHeight(InnerContainer) + config.SectionPaddingTop + config.SectionPaddingBottom
                        services.TweenService:Create(SectionFrame, TweenInfo.new(0.2, Enum.EasingStyle.Cubic), {
                            Size = UDim2.new(1, -8, 0, config.SectionHeaderHeight + 4 + h)
                        }):Play()
                    end
                    task.wait(0.2)
                    updatePageSize()
                end)
            end

            -- Объект секции
            local SectionObj = {
                Frame = SectionFrame,
                InnerContainer = InnerContainer,
                HeaderLabel = HeaderLabel,
                CollapseBtn = CollapseBtn,
                Elements = {},
                ElementCount = 0,

                Button = function(self, text, callback, icon)
                    self.ElementCount = self.ElementCount + 1
                    local btn = createButton(self.InnerContainer, text, callback, icon, theme, WindowObj, config)
                    btn.LayoutOrder = self.ElementCount
                    table.insert(self.Elements, btn)
                    table.insert(WindowObj.Elements, btn)
                    updateSectionHeight()
                    return btn
                end,

                Toggle = function(self, text, default, callback)
                    self.ElementCount = self.ElementCount + 1
                    local toggle = createToggle(self.InnerContainer, text, default, callback, theme, WindowObj, config)
                    toggle.Frame.LayoutOrder = self.ElementCount
                    table.insert(self.Elements, toggle)
                    table.insert(WindowObj.Elements, toggle)
                    updateSectionHeight()
                    return toggle
                end,

                Slider = function(self, text, min, max, default, callback, showValue)
                    self.ElementCount = self.ElementCount + 1
                    local slider = createSlider(self.InnerContainer, text, min, max, default, callback, showValue, theme, WindowObj, config)
                    slider.Frame.LayoutOrder = self.ElementCount
                    table.insert(self.Elements, slider)
                    table.insert(WindowObj.Elements, slider)
                    updateSectionHeight()
                    return slider
                end,

                Dropdown = function(self, text, options, default, callback)
                    self.ElementCount = self.ElementCount + 1
                    local dropdown = createDropdown(self.InnerContainer, text, options, default, callback, theme, WindowObj, config, ScreenGui)
                    dropdown.Frame.LayoutOrder = self.ElementCount
                    table.insert(self.Elements, dropdown)
                    table.insert(WindowObj.Elements, dropdown)
                    updateSectionHeight()
                    return dropdown
                end,

                Label = function(self, text, size)
                    self.ElementCount = self.ElementCount + 1
                    local label = createLabel(self.InnerContainer, text, size, theme)
                    label.LayoutOrder = self.ElementCount
                    table.insert(self.Elements, label)
                    table.insert(WindowObj.Elements, label)
                    updateSectionHeight()
                    return label
                end,

                Separator = function(self, text)
                    self.ElementCount = self.ElementCount + 1
                    local sep = createSeparator(self.InnerContainer, text, theme, config)
                    sep.LayoutOrder = self.ElementCount
                    table.insert(self.Elements, sep)
                    table.insert(WindowObj.Elements, sep)
                    updateSectionHeight()
                    return sep
                end,

                Clear = function(self)
                    for _, child in ipairs(self.InnerContainer:GetChildren()) do
                        if child:IsA("Frame") or child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    self.Elements = {}
                    self.ElementCount = 0
                    updateSectionHeight()
                end,

                SetTitle = function(self, newTitle, newIcon)
                    local text = (newIcon or "") .. (newTitle or ""):upper()
                    if self.HeaderLabel then
                        self.HeaderLabel.Text = text
                    end
                end,

                SetVisible = function(self, visible)
                    self.Frame.Visible = visible
                    updatePageSize()
                end,

                SetCollapsed = function(self, state)
                    collapsed = state
                    if CollapseBtn then
                        services.TweenService:Create(CollapseBtn, TweenInfo.new(0.15), {
                            Rotation = collapsed and 180 or 0
                        }):Play()
                    end
                    if collapsed then
                        SectionFrame.Size = UDim2.new(1, -8, 0, config.SectionHeaderHeight + 4)
                        InnerContainer.Visible = false
                    else
                        InnerContainer.Visible = true
                        local h = getContentHeight(InnerContainer) + config.SectionPaddingTop + config.SectionPaddingBottom
                        SectionFrame.Size = UDim2.new(1, -8, 0, config.SectionHeaderHeight + 4 + h)
                    end
                    updatePageSize()
                end,

                IsCollapsed = function()
                    return collapsed
                end,

                Destroy = function()
                    SectionFrame:Destroy()
                    for i, s in pairs(Tab.Sections) do
                        if s == SectionObj then
                            table.remove(Tab.Sections, i)
                            break
                        end
                    end
                    updatePageSize()
                end
            }

            table.insert(Tab.Sections, SectionObj)
            task.defer(function()
                updateSectionHeight()
            end)

            if callback then pcall(callback, SectionObj) end

            return SectionObj
        end

        -- ---- Публичные методы вкладки ----
        function Tab:CreateSection(title, options)
            return createSection(title, PageContent, nil, options)
        end

        function Tab:CreateGroup(side, title, options)
            side = string.lower(side)
            if side ~= "left" and side ~= "right" then
                error("side must be 'left' or 'right'")
            end
            local parent = (side == "left") and LeftColumn or RightColumn
            return createSection(title, parent, side, options)
        end

        -- Прямые элементы (без секций)
        function Tab:Button(text, callback, icon)
            if Tab.LayoutMode == "columns" then
                warn("Direct elements not allowed in columns mode. Use CreateGroup instead.")
                return nil
            end
            Tab.ElementCount = Tab.ElementCount + 1
            local btn = createButton(PageContent, text, callback, icon, theme, WindowObj, config)
            btn.LayoutOrder = Tab.ElementCount
            table.insert(Tab.Elements, btn)
            table.insert(Tab.DirectElements, btn)
            table.insert(WindowObj.Elements, btn)
            updatePageSize()
            return btn
        end

        function Tab:Toggle(text, default, callback)
            if Tab.LayoutMode == "columns" then
                warn("Direct elements not allowed in columns mode. Use CreateGroup instead.")
                return nil
            end
            Tab.ElementCount = Tab.ElementCount + 1
            local toggle = createToggle(PageContent, text, default, callback, theme, WindowObj, config)
            toggle.Frame.LayoutOrder = Tab.ElementCount
            table.insert(Tab.Elements, toggle)
            table.insert(Tab.DirectElements, toggle)
            table.insert(WindowObj.Elements, toggle)
            updatePageSize()
            return toggle
        end

        function Tab:Slider(text, min, max, default, callback, showValue)
            if Tab.LayoutMode == "columns" then
                warn("Direct elements not allowed in columns mode. Use CreateGroup instead.")
                return nil
            end
            Tab.ElementCount = Tab.ElementCount + 1
            local slider = createSlider(PageContent, text, min, max, default, callback, showValue, theme, WindowObj, config)
            slider.Frame.LayoutOrder = Tab.ElementCount
            table.insert(Tab.Elements, slider)
            table.insert(Tab.DirectElements, slider)
            table.insert(WindowObj.Elements, slider)
            updatePageSize()
            return slider
        end

        function Tab:Dropdown(text, options, default, callback)
            if Tab.LayoutMode == "columns" then
                warn("Direct elements not allowed in columns mode. Use CreateGroup instead.")
                return nil
            end
            Tab.ElementCount = Tab.ElementCount + 1
            local dropdown = createDropdown(PageContent, text, options, default, callback, theme, WindowObj, config, ScreenGui)
            dropdown.Frame.LayoutOrder = Tab.ElementCount
            table.insert(Tab.Elements, dropdown)
            table.insert(Tab.DirectElements, dropdown)
            table.insert(WindowObj.Elements, dropdown)
            updatePageSize()
            return dropdown
        end

        function Tab:Label(text, size)
            if Tab.LayoutMode == "columns" then
                warn("Direct elements not allowed in columns mode. Use CreateGroup instead.")
                return nil
            end
            Tab.ElementCount = Tab.ElementCount + 1
            local label = createLabel(PageContent, text, size, theme)
            label.LayoutOrder = Tab.ElementCount
            table.insert(Tab.Elements, label)
            table.insert(Tab.DirectElements, label)
            table.insert(WindowObj.Elements, label)
            updatePageSize()
            return label
        end

        function Tab:Separator(text)
            if Tab.LayoutMode == "columns" then
                warn("Direct elements not allowed in columns mode. Use CreateGroup instead.")
                return nil
            end
            Tab.ElementCount = Tab.ElementCount + 1
            local sep = createSeparator(PageContent, text, theme, config)
            sep.LayoutOrder = Tab.ElementCount
            table.insert(Tab.Elements, sep)
            table.insert(Tab.DirectElements, sep)
            table.insert(WindowObj.Elements, sep)
            updatePageSize()
            return sep
        end

        -- Активация вкладки
        local function activateTab()
            for _, v in pairs(ContentContainer:GetChildren()) do
                if v:IsA("ScrollingFrame") then v.Visible = false end
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

        -- Обновление размера
        PageContent.ChildAdded:Connect(function() task.wait(0.01) updatePageSize() end)
        PageContent.ChildRemoved:Connect(function() task.wait(0.01) updatePageSize() end)

        task.spawn(function() task.wait(0.1) updatePageSize() end)

        table.insert(WindowObj.Tabs, Tab)
        if #WindowObj.Tabs == 1 then activateTab() end
        return Tab
    end

    -- Алиас для смены темы
    function WindowObj:SetTheme(newThemeName)
        return self:ChangeTheme(newThemeName)
    end

    -- СМЕНА ТЕМЫ (улучшена для внутренних частей)
    function WindowObj:ChangeTheme(newThemeName)
        local newTheme = normalizeTheme(GeminiLib.Themes[newThemeName])
        if not newTheme then return end
        WindowObj.Theme = newTheme

        -- Обновляем главные элементы
        Main.BackgroundColor3 = newTheme.Main
        TopBar.BackgroundColor3 = newTheme.Section
        Title.TextColor3 = newTheme.Text
        StatsLabel.TextColor3 = newTheme.TextSecondary
        CloseBtn.ImageColor3 = newTheme.Text

        local shadow = Main:FindFirstChild("Shadow")
        if shadow and shadow:IsA("ImageLabel") then
            shadow.ImageColor3 = newTheme.Shadow
            shadow.ImageTransparency = 1 - (newTheme.ShadowAlpha or 0.4)
        end

        SideBar.BackgroundColor3 = newTheme.Section
        local sideStroke = SideBar:FindFirstChildOfClass("UIStroke")
        if sideStroke then sideStroke.Color = newTheme.Accent end

        TabScroll.ScrollBarImageColor3 = newTheme.Accent

        if ProfileFrame then
            ProfileFrame.BackgroundColor3 = newTheme.Element
            local profStroke = ProfileFrame:FindFirstChildOfClass("UIStroke")
            if profStroke then profStroke.Color = newTheme.Accent end
            local avatar = ProfileFrame:FindFirstChild("Avatar")
            if avatar then avatar.BackgroundColor3 = newTheme.Main end
            local uname = ProfileFrame:FindFirstChild("Username")
            if uname then uname.TextColor3 = newTheme.Text end
        end

        ContentContainer.BackgroundColor3 = newTheme.Section
        local contStroke = ContentContainer:FindFirstChildOfClass("UIStroke")
        if contStroke then contStroke.Color = newTheme.Accent end

        -- Обновляем элементы
        for _, element in pairs(WindowObj.Elements) do
            if element and element.Parent then
                pcall(function()
                    if element:IsA("TextButton") or element:IsA("TextLabel") or element:IsA("TextBox") then
                        if element.BackgroundTransparency < 1 and element.BackgroundTransparency ~= 1 then
                            element.BackgroundColor3 = newTheme.Element
                        end
                        if element:IsA("TextButton") or element:IsA("TextLabel") then
                            if element ~= Title and element ~= StatsLabel and element.Name ~= "Username" then
                                element.TextColor3 = newTheme.Text
                            end
                        end
                    end

                    local stroke = element:FindFirstChildOfClass("UIStroke")
                    if stroke then
                        if element.Name:find("Slider") or element.Name:find("Toggle") or element.Name:find("Dropdown") then
                            stroke.Color = newTheme.Accent
                        else
                            stroke.Color = newTheme.Border
                        end
                    end

                    -- Акцентные части (для Slider и Toggle)
                    local fill = element:FindFirstChild("Fill") or element:FindFirstChild("AccentPart")
                    if fill and fill:IsA("Frame") then
                        fill.BackgroundColor3 = newTheme.Accent
                    end
                    local dot = element:FindFirstChild("SliderDot") -- если мы дадим имена, но у нас нет, поэтому ищем по типу
                    if not dot then
                        for _, child in pairs(element:GetChildren()) do
                            if child:IsA("Frame") and child.Name ~= "Fill" and child.Name ~= "SliderTrack" then
                                -- возможно это точка, но лучше сохранять ссылки, а пока пропустим
                            end
                        end
                    end
                end)
            end
        end

        -- Обновляем вкладки и секции
        for _, tab in pairs(WindowObj.Tabs) do
            if tab.Button and tab.Button.Parent then
                tab.Button.BackgroundColor3 = newTheme.Element
                tab.Button.TextColor3 = (tab.Button == WindowObj.CurrentTab) and newTheme.Accent or newTheme.TextSecondary
                local btnStroke = tab.Button:FindFirstChildOfClass("UIStroke")
                if btnStroke then btnStroke.Color = newTheme.Accent end
            end
            if tab.Page and tab.Page.Parent then
                tab.Page.ScrollBarImageColor3 = newTheme.Accent
            end
            for _, section in pairs(tab.Sections or {}) do
                if section.Frame and section.Frame.Parent then
                    if section.HeaderLabel then
                        section.HeaderLabel.TextColor3 = newTheme.TextSecondary
                    end
                    local line = section.Frame:FindFirstChild("Line")
                    if line then
                        line.BackgroundColor3 = newTheme.Accent
                        line.BackgroundTransparency = config.SectionLineTransparency
                    end
                    if section.CollapseBtn then
                        section.CollapseBtn.TextColor3 = newTheme.TextSecondary
                    end
                end
            end
        end

        for _, dropdownData in pairs(WindowObj.OpenDropdowns) do
            if dropdownData and dropdownData.Close then
                dropdownData.Close()
            end
        end
    end

    -- ПЛАВАЮЩАЯ КНОПКА (убрана анимация размера)
    function WindowObj:CreateFloatingButton()
        if WindowObj.FloatingButton then WindowObj.FloatingButton:Destroy() end
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
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        FloatingButton.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
        services.UIS.InputChanged:Connect(function(input)
            if input == dragInput and dragging then update(input) end
        end)

        table.insert(WindowObj.Connections, FloatingButton.MouseButton1Click:Connect(function()
            WindowObj:ToggleVisibility()
        end))
        table.insert(WindowObj.Connections, FloatingButton.MouseEnter:Connect(function()
            services.TweenService:Create(FloatingButton, TweenInfo.new(0.15), {
                BackgroundTransparency = 0.2,
            }):Play()
        end))
        table.insert(WindowObj.Connections, FloatingButton.MouseLeave:Connect(function()
            services.TweenService:Create(FloatingButton, TweenInfo.new(0.15), {
                BackgroundTransparency = 0,
            }):Play()
        end))

        WindowObj.FloatingButton = FloatingButton
        return FloatingButton
    end

    function WindowObj:ToggleVisibility()
        if Main.Visible then
            services.TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Cubic), {
                Position = UDim2.new(0.5, -config.WindowWidth/2, 1.5, 0)
            }):Play()
            if WindowObj.FloatingButton then WindowObj.FloatingButton.Text = "🔅" end
            stopStatsUpdate()
            task.wait(0.3)
            Main.Visible = false
        else
            Main.Visible = true
            Main.Position = UDim2.new(0.5, -config.WindowWidth/2, 1.5, 0)
            services.TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Cubic), {
                Position = WindowObj.OriginalPosition or UDim2.new(0.5, -config.WindowWidth/2, 0.5, -config.WindowHeight/2)
            }):Play()
            if WindowObj.FloatingButton then WindowObj.FloatingButton.Text = "💠" end
            startStatsUpdate()
        end
    end

    function WindowObj:Destroy()
        stopStatsUpdate()
        for _, connection in pairs(WindowObj.Connections) do
            if connection then pcall(function() connection:Disconnect() end) end
        end
        for _, dropdown in pairs(WindowObj.OpenDropdowns) do
            if dropdown.Close then pcall(dropdown.Close) end
        end
        if WindowObj.FloatingButton then WindowObj.FloatingButton:Destroy() end
        ScreenGui:Destroy()
        for k in pairs(WindowObj) do WindowObj[k] = nil end
    end

    task.wait(0.1)
    WindowObj:CreateFloatingButton()
    return WindowObj
end

-- УВЕДОМЛЕНИЯ
function GeminiLib:CreateNotification(notificationData)
    notificationData = notificationData or {}
    local title = notificationData.Title or "Notification"
    local text = notificationData.Text or "No text provided"
    local duration = notificationData.Duration or 4
    local themeName = notificationData.Theme or GeminiLib.Config.DefaultTheme
    local theme = normalizeTheme(GeminiLib.Themes[themeName]) or normalizeTheme(GeminiLib.Themes.Minimal)

    local NotificationsGui = services.CoreGui:FindFirstChild("GeminiNotifications")
    if not NotificationsGui then
        NotificationsGui = Instance.new("ScreenGui")
        NotificationsGui.Name = "GeminiNotifications"
        NotificationsGui.ResetOnSpawn = false
        NotificationsGui.Parent = services.CoreGui
    end

    local frame = Instance.new("Frame")
    frame.Name = "Notification"
    frame.Size = UDim2.new(0, 290, 0, 72)
    frame.Position = UDim2.new(1, 20, 1, -90)
    frame.BackgroundColor3 = theme.Element
    frame.BorderSizePixel = 0
    frame.Parent = NotificationsGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = theme.Accent
    stroke.Thickness = 1.2
    stroke.Transparency = 0.55
    stroke.Parent = frame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = title
    titleLabel.Size = UDim2.new(1, -20, 0, 22)
    titleLabel.Position = UDim2.new(0, 12, 0, 8)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = theme.Text
    titleLabel.Font = Enum.Font.GothamMedium
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = frame

    local textLabel = Instance.new("TextLabel")
    textLabel.Text = text
    textLabel.Size = UDim2.new(1, -20, 0, 32)
    textLabel.Position = UDim2.new(0, 12, 0, 30)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = theme.TextSecondary
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextSize = 12
    textLabel.TextWrapped = true
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = frame

    -- Анимация появления
    frame.Position = UDim2.new(1, 20, 1, -90)
    services.TweenService:Create(frame, TweenInfo.new(0.28, Enum.EasingStyle.Quint), {
        Position = UDim2.new(1, -310, 1, -90)
    }):Play()

    task.delay(duration, function()
        local tween = services.TweenService:Create(frame, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
            Position = UDim2.new(1, 20, 1, -90)
        })
        tween:Play()
        tween.Completed:Wait()
        frame:Destroy()
    end)
end

return GeminiLib
