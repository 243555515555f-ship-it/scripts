--[[
    NovaUI - Modern UI Library for Roblox
    Merged from GeminiLib (Core), Orion (Visuals), and Rayfield (Features)
    Version: 1.0.0
--]]

local NovaUI = {}

--#region Services
local Services = {
    UIS = game:GetService("UserInputService"),
    TweenService = game:GetService("TweenService"),
    RunService = game:GetService("RunService"),
    CoreGui = game:GetService("CoreGui"),
    HttpService = game:GetService("HttpService"),
    Players = game:GetService("Players"),
    TextService = game:GetService("TextService")
}
--#endregion

--#region Themes (Orion Style)
NovaUI.Themes = {
    Dark = {
        Name = "Dark",
        Background = Color3.fromRGB(25, 25, 25),
        Topbar = Color3.fromRGB(34, 34, 34),
        TabBackground = Color3.fromRGB(80, 80, 80),
        TabSelected = Color3.fromRGB(210, 210, 210),
        TabText = Color3.fromRGB(240, 240, 240),
        TabSelectedText = Color3.fromRGB(50, 50, 50),
        Element = Color3.fromRGB(35, 35, 35),
        ElementHover = Color3.fromRGB(40, 40, 40),
        Accent = Color3.fromRGB(0, 146, 214),
        AccentHover = Color3.fromRGB(0, 170, 255),
        Success = Color3.fromRGB(70, 220, 130),
        Error = Color3.fromRGB(240, 90, 90),
        Text = Color3.fromRGB(240, 240, 240),
        TextSecondary = Color3.fromRGB(160, 160, 170),
        Border = Color3.fromRGB(50, 50, 50),
        Shadow = Color3.fromRGB(0, 0, 0)
    },
    Crimson = {
        Name = "Crimson",
        Background = Color3.fromRGB(20, 20, 25),
        Topbar = Color3.fromRGB(139, 0, 23),
        TabBackground = Color3.fromRGB(33, 33, 33),
        TabSelected = Color3.fromRGB(181, 1, 31),
        TabText = Color3.fromRGB(255, 255, 255),
        TabSelectedText = Color3.fromRGB(255, 255, 255),
        Element = Color3.fromRGB(30, 30, 35),
        ElementHover = Color3.fromRGB(35, 35, 40),
        Accent = Color3.fromRGB(181, 1, 31),
        AccentHover = Color3.fromRGB(200, 20, 40),
        Success = Color3.fromRGB(70, 220, 130),
        Error = Color3.fromRGB(240, 90, 90),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(180, 180, 190),
        Border = Color3.fromRGB(53, 53, 53),
        Shadow = Color3.fromRGB(0, 0, 0)
    },
    Cyber = {
        Name = "Cyber",
        Background = Color3.fromRGB(10, 15, 25),
        Topbar = Color3.fromRGB(20, 25, 40),
        TabBackground = Color3.fromRGB(15, 20, 35),
        TabSelected = Color3.fromRGB(0, 220, 220),
        TabText = Color3.fromRGB(180, 190, 220),
        TabSelectedText = Color3.fromRGB(10, 15, 25),
        Element = Color3.fromRGB(20, 25, 40),
        ElementHover = Color3.fromRGB(30, 35, 55),
        Accent = Color3.fromRGB(0, 220, 220),
        AccentHover = Color3.fromRGB(0, 240, 240),
        Success = Color3.fromRGB(0, 230, 180),
        Error = Color3.fromRGB(255, 70, 70),
        Text = Color3.fromRGB(240, 245, 255),
        TextSecondary = Color3.fromRGB(180, 190, 220),
        Border = Color3.fromRGB(0, 180, 180),
        Shadow = Color3.fromRGB(0, 0, 0)
    }
}

NovaUI.Config = {
    WindowWidth = 520,
    WindowHeight = 400,
    Roundness = 6,
    ShadowSize = 10,
    NotificationDuration = 5,
    DefaultTheme = "Dark"
}
--#endregion

--#region Utility Functions
local function CreateShadow(parent, color, transparency, offset)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Image = "rbxassetid://5554237735"
    shadow.ImageColor3 = color
    shadow.ImageTransparency = transparency or 0.7
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceScale = 0.05
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.Size = UDim2.new(1, offset or 8, 1, offset or 8)
    shadow.Position = UDim2.new(0, -(offset or 8)/2, 0, -(offset or 8)/2)
    shadow.BackgroundTransparency = 1
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Parent = parent
    return shadow
end

local function CreateRoundedCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or NovaUI.Config.Roundness)
    corner.Parent = parent
    return corner
end

local function CreateStroke(parent, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or NovaUI.Themes[NovaUI.Config.DefaultTheme].Border
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0
    stroke.Parent = parent
    return stroke
end

local function Animate(instance, properties, duration, style)
    Services.TweenService:Create(instance, TweenInfo.new(duration or 0.2, style or Enum.EasingStyle.Quint), properties):Play()
end

local function ShowErrorFeedback(element, originalColor, callback)
    Animate(element, {BackgroundColor3 = NovaUI.Themes[NovaUI.Config.DefaultTheme].Error}, 0.15)
    task.wait(0.15)
    Animate(element, {BackgroundColor3 = originalColor or NovaUI.Themes[NovaUI.Config.DefaultTheme].Element}, 0.15)
    if callback then pcall(callback) end
end
--#endregion

--#region NovaUI Core
function NovaUI:GetThemesList()
    local list = {}
    for name in pairs(self.Themes) do
        table.insert(list, name)
    end
    return list
end

function NovaUI:CreateWindow(title, themeName)
    local theme = self.Themes[themeName] or self.Themes[self.Config.DefaultTheme]
    local flags = {}
    local openDropdowns = {}
    local connections = {}
    
    -- Create GUI
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NovaUI_" .. Services.HttpService:GenerateGUID(false):sub(1, 8)
    ScreenGui.Parent = Services.CoreGui
    ScreenGui.ResetOnSpawn = false
    
    -- Main Window
    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, NovaUI.Config.WindowWidth, 0, NovaUI.Config.WindowHeight)
    Main.Position = UDim2.new(0.5, -NovaUI.Config.WindowWidth/2, 0.5, -NovaUI.Config.WindowHeight/2)
    Main.BackgroundColor3 = theme.Background
    Main.BackgroundTransparency = 0
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui
    
    CreateRoundedCorner(Main, NovaUI.Config.Roundness)
    CreateShadow(Main, theme.Shadow, 0.5, NovaUI.Config.ShadowSize)
    
    -- Topbar (Orion Style)
    local Topbar = Instance.new("Frame")
    Topbar.Size = UDim2.new(1, 0, 0, 45)
    Topbar.BackgroundColor3 = theme.Topbar
    Topbar.BorderSizePixel = 0
    Topbar.Parent = Main
    
    CreateRoundedCorner(Topbar, NovaUI.Config.Roundness)
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Text = title or "NovaUI"
    Title.Size = UDim2.new(1, -100, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = theme.Text
    Title.TextSize = 16
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Topbar
    
    -- Minimize Button
    local MinimizeBtn = Instance.new("ImageButton")
    MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    MinimizeBtn.Position = UDim2.new(1, -70, 0.5, -15)
    MinimizeBtn.Image = "rbxassetid://10137941941"
    MinimizeBtn.ImageColor3 = theme.Text
    MinimizeBtn.BackgroundTransparency = 1
    MinimizeBtn.Parent = Topbar
    
    -- Close Button
    local CloseBtn = Instance.new("ImageButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0.5, -15)
    CloseBtn.Image = "rbxassetid://4988112250"
    CloseBtn.ImageColor3 = theme.Text
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Parent = Topbar
    
    -- Tab Container (Orion Style Sidebar)
    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(0, 130, 1, -45)
    TabContainer.Position = UDim2.new(0, 0, 0, 45)
    TabContainer.BackgroundColor3 = theme.TabBackground
    TabContainer.BackgroundTransparency = 0.5
    TabContainer.BorderSizePixel = 0
    TabContainer.Parent = Main
    
    CreateRoundedCorner(TabContainer, NovaUI.Config.Roundness)
    
    -- Tab List
    local TabList = Instance.new("ScrollingFrame")
    TabList.Size = UDim2.new(1, -10, 1, -10)
    TabList.Position = UDim2.new(0, 5, 0, 5)
    TabList.BackgroundTransparency = 1
    TabList.BorderSizePixel = 0
    TabList.ScrollBarThickness = 2
    TabList.ScrollBarImageColor3 = theme.Accent
    TabList.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabList.Parent = TabContainer
    
    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Padding = UDim.new(0, 5)
    TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Parent = TabList
    
    -- Content Area
    local ContentArea = Instance.new("Frame")
    ContentArea.Size = UDim2.new(1, -140, 1, -55)
    ContentArea.Position = UDim2.new(0, 135, 0, 50)
    ContentArea.BackgroundColor3 = theme.Background
    ContentArea.BackgroundTransparency = 0.3
    ContentArea.BorderSizePixel = 0
    ContentArea.ClipsDescendants = true
    ContentArea.Parent = Main
    
    CreateRoundedCorner(ContentArea, NovaUI.Config.Roundness)
    CreateStroke(ContentArea, theme.Border, 1, 0.5)
    
    -- Pages Container
    local PagesContainer = Instance.new("Folder")
    PagesContainer.Name = "Pages"
    PagesContainer.Parent = ContentArea
    
    --#region Dragging Logic
    local dragging, dragStart, startPos
    Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)
    
    Services.UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    Services.UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    --#endregion
    
    --#region Minimize/Maximize Logic
    local isMinimized = false
    local originalSize = Main.Size
    
    MinimizeBtn.MouseButton1Click:Connect(function()
        if isMinimized then
            Animate(Main, {Size = originalSize}, 0.3)
            Animate(TabContainer, {Size = UDim2.new(0, 130, 1, -45)}, 0.3)
            Animate(ContentArea, {Size = UDim2.new(1, -140, 1, -55)}, 0.3)
            MinimizeBtn.Image = "rbxassetid://10137941941"
            isMinimized = false
        else
            Animate(Main, {Size = UDim2.new(0, originalSize.X.Offset, 0, 45)}, 0.3)
            Animate(TabContainer, {Size = UDim2.new(0, 0, 1, -45)}, 0.3)
            Animate(ContentArea, {Size = UDim2.new(1, 0, 1, -55)}, 0.3)
            MinimizeBtn.Image = "rbxassetid://11036884234"
            isMinimized = true
        end
    end)
    
    CloseBtn.MouseButton1Click:Connect(function()
        for _, conn in pairs(connections) do
            pcall(function() conn:Disconnect() end)
        end
        ScreenGui:Destroy()
    end)
    --#endregion
    
    --#region Window Object
    local Window = {
        CurrentTab = nil,
        Theme = theme,
        Pages = {},
        Flags = flags,
        ScreenGui = ScreenGui
    }
    
    -- Update Canvas Size
    local function updateTabListSize()
        local totalHeight = 0
        for _, child in pairs(TabList:GetChildren()) do
            if child:IsA("TextButton") then
                totalHeight = totalHeight + child.Size.Y.Offset + 5
            end
        end
        TabList.CanvasSize = UDim2.new(0, 0, 0, totalHeight + 10)
    end
    
    TabList.ChildAdded:Connect(updateTabListSize)
    TabList.ChildRemoved:Connect(updateTabListSize)
    --#endregion
    
    --#region Create Tab Function
    function Window:CreateTab(name, icon)
        local TabButton = Instance.new("TextButton")
        TabButton.Name = "Tab_" .. name
        TabButton.Size = UDim2.new(0, 110, 0, 35)
        TabButton.BackgroundColor3 = theme.TabBackground
        TabButton.BackgroundTransparency = 0.5
        TabButton.Text = (icon or "•") .. "  " .. name
        TabButton.TextColor3 = theme.TabText
        TabButton.TextSize = 13
        TabButton.Font = Enum.Font.GothamMedium
        TabButton.TextXAlignment = Enum.TextXAlignment.Left
        TabButton.AutoButtonColor = false
        TabButton.Parent = TabList
        
        CreateRoundedCorner(TabButton, 5)
        
        -- Page Container
        local Page = Instance.new("ScrollingFrame")
        Page.Name = "Page_" .. name
        Page.Size = UDim2.new(1, -15, 1, -15)
        Page.Position = UDim2.new(0, 7.5, 0, 7.5)
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.ScrollBarThickness = 4
        Page.ScrollBarImageColor3 = theme.Accent
        Page.Visible = false
        Page.Parent = PagesContainer
        
        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Padding = UDim.new(0, 8)
        PageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Parent = Page
        
        local Padding = Instance.new("UIPadding")
        Padding.PaddingTop = UDim.new(0, 8)
        Padding.PaddingBottom = UDim.new(0, 8)
        Padding.Parent = Page
        
        -- Update Canvas Size
        local function updatePageSize()
            local totalHeight = 0
            for _, child in pairs(Page:GetChildren()) do
                if child:IsA("Frame") and child.Name ~= "UIPadding" and child.Name ~= "UIListLayout" then
                    totalHeight = totalHeight + child.Size.Y.Offset + 8
                end
            end
            Page.CanvasSize = UDim2.new(0, 0, 0, totalHeight + 10)
        end
        
        Page.ChildAdded:Connect(updatePageSize)
        Page.ChildRemoved:Connect(updatePageSize)
        
        -- Tab Object
        local Tab = {
            Name = name,
            Page = Page,
            Button = TabButton,
            Elements = {}
        }
        
        -- Activate Tab Function
        local function activateTab()
            for _, page in pairs(PagesContainer:GetChildren()) do
                if page:IsA("ScrollingFrame") then
                    page.Visible = false
                end
            end
            Page.Visible = true
            
            for _, btn in pairs(TabList:GetChildren()) do
                if btn:IsA("TextButton") and btn ~= TabButton then
                    Animate(btn, {BackgroundTransparency = 0.5, TextColor3 = theme.TabText}, 0.15)
                end
            end
            
            Animate(TabButton, {BackgroundTransparency = 0, TextColor3 = theme.TabSelectedText}, 0.15)
            TabButton.BackgroundColor3 = theme.TabSelected
            Window.CurrentTab = TabButton
        end
        
        -- Hover Animations
        TabButton.MouseEnter:Connect(function()
            if TabButton ~= Window.CurrentTab then
                Animate(TabButton, {BackgroundTransparency = 0.3, TextColor3 = theme.Text}, 0.15)
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if TabButton ~= Window.CurrentTab then
                Animate(TabButton, {BackgroundTransparency = 0.5, TextColor3 = theme.TabText}, 0.15)
            end
        end)
        
        TabButton.MouseButton1Click:Connect(activateTab)
        
        -- Activate first tab automatically
        if #PagesContainer:GetChildren() == 1 then
            activateTab()
        end
        
        table.insert(Window.Pages, Tab)
        
        --#region Element Creation Functions
        function Tab:Label(text)
            local Element = Instance.new("Frame")
            Element.Size = UDim2.new(1, -16, 0, 30)
            Element.BackgroundTransparency = 1
            Element.Parent = Page
            updatePageSize()
            
            local Label = Instance.new("TextLabel")
            Label.Text = text
            Label.Size = UDim2.new(1, 0, 1, 0)
            Label.BackgroundTransparency = 1
            Label.TextColor3 = theme.Text
            Label.TextSize = 13
            Label.Font = Enum.Font.Gotham
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Element
            
            return Element
        end
        
        function Tab:Button(text, callback)
            local Element = Instance.new("TextButton")
            Element.Size = UDim2.new(1, -16, 0, 38)
            Element.BackgroundColor3 = theme.Element
            Element.BackgroundTransparency = 0.5
            Element.Text = "  " .. text
            Element.TextColor3 = theme.Text
            Element.TextSize = 13
            Element.Font = Enum.Font.Gotham
            Element.TextXAlignment = Enum.TextXAlignment.Left
            Element.AutoButtonColor = false
            Element.Parent = Page
            
            CreateRoundedCorner(Element, 6)
            local stroke = CreateStroke(Element, theme.Border, 1, 0.5)
            
            local originalColor = theme.Element
            
            Element.MouseEnter:Connect(function()
                Animate(Element, {BackgroundTransparency = 0.3, Size = UDim2.new(1, -12, 0, 40)}, 0.15)
                Animate(stroke, {Transparency = 0.2}, 0.15)
            end)
            
            Element.MouseLeave:Connect(function()
                Animate(Element, {BackgroundTransparency = 0.5, Size = UDim2.new(1, -16, 0, 38)}, 0.15)
                Animate(stroke, {Transparency = 0.5}, 0.15)
            end)
            
            Element.MouseButton1Click:Connect(function()
                Animate(Element, {BackgroundTransparency = 0.2, Size = UDim2.new(1, -18, 0, 36)}, 0.1)
                task.wait(0.1)
                Animate(Element, {BackgroundTransparency = 0.3, Size = UDim2.new(1, -12, 0, 40)}, 0.1)
                
                local success, err = pcall(callback)
                if not success then
                    ShowErrorFeedback(Element, originalColor)
                    warn("Button callback error:", err)
                end
            end)
            
            updatePageSize()
            return Element
        end
        
        function Tab:Toggle(text, default, callback)
            local state = default or false
            local Element = Instance.new("TextButton")
            Element.Size = UDim2.new(1, -16, 0, 42)
            Element.BackgroundColor3 = theme.Element
            Element.BackgroundTransparency = 0.5
            Element.Text = "  " .. text
            Element.TextColor3 = theme.Text
            Element.TextSize = 13
            Element.Font = Enum.Font.Gotham
            Element.TextXAlignment = Enum.TextXAlignment.Left
            Element.AutoButtonColor = false
            Element.Parent = Page
            
            CreateRoundedCorner(Element, 6)
            local stroke = CreateStroke(Element, theme.Border, 1, 0.5)
            
            -- Toggle Switch (Orion Style)
            local Switch = Instance.new("Frame")
            Switch.Size = UDim2.new(0, 40, 0, 22)
            Switch.Position = UDim2.new(1, -52, 0.5, -11)
            Switch.BackgroundColor3 = state and theme.Accent or theme.TabBackground
            Switch.BorderSizePixel = 0
            Switch.Parent = Element
            
            CreateRoundedCorner(Switch, 11)
            
            local Indicator = Instance.new("Frame")
            Indicator.Size = UDim2.new(0, 18, 0, 18)
            Indicator.Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
            Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Indicator.BorderSizePixel = 0
            Indicator.Parent = Switch
            
            CreateRoundedCorner(Indicator, 9)
            
            local function toggleState()
                state = not state
                if state then
                    Animate(Switch, {BackgroundColor3 = theme.Accent}, 0.15)
                    Animate(Indicator, {Position = UDim2.new(1, -20, 0.5, -9)}, 0.15)
                else
                    Animate(Switch, {BackgroundColor3 = theme.TabBackground}, 0.15)
                    Animate(Indicator, {Position = UDim2.new(0, 2, 0.5, -9)}, 0.15)
                end
                
                local success, err = pcall(callback, state)
                if not success then
                    ShowErrorFeedback(Element, theme.Element)
                    warn("Toggle callback error:", err)
                end
            end
            
            Element.MouseEnter:Connect(function()
                Animate(Element, {BackgroundTransparency = 0.3, Size = UDim2.new(1, -12, 0, 44)}, 0.15)
                Animate(stroke, {Transparency = 0.2}, 0.15)
            end)
            
            Element.MouseLeave:Connect(function()
                Animate(Element, {BackgroundTransparency = 0.5, Size = UDim2.new(1, -16, 0, 42)}, 0.15)
                Animate(stroke, {Transparency = 0.5}, 0.15)
            end)
            
            Element.MouseButton1Click:Connect(toggleState)
            
            updatePageSize()
            
            return {
                Set = function(val)
                    if val ~= state then
                        state = val
                        if state then
                            Switch.BackgroundColor3 = theme.Accent
                            Indicator.Position = UDim2.new(1, -20, 0.5, -9)
                        else
                            Switch.BackgroundColor3 = theme.TabBackground
                            Indicator.Position = UDim2.new(0, 2, 0.5, -9)
                        end
                    end
                end,
                Get = function() return state end
            }
        end
        
        function Tab:Slider(text, min, max, default, callback, suffix)
            local currentValue = default or min
            local Element = Instance.new("Frame")
            Element.Size = UDim2.new(1, -16, 0, 65)
            Element.BackgroundColor3 = theme.Element
            Element.BackgroundTransparency = 0.5
            Element.Parent = Page
            
            CreateRoundedCorner(Element, 6)
            local stroke = CreateStroke(Element, theme.Border, 1, 0.5)
            
            -- Title
            local Title = Instance.new("TextLabel")
            Title.Text = text
            Title.Size = UDim2.new(1, -10, 0, 25)
            Title.Position = UDim2.new(0, 10, 0, 0)
            Title.BackgroundTransparency = 1
            Title.TextColor3 = theme.Text
            Title.TextSize = 13
            Title.Font = Enum.Font.Gotham
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.Parent = Element
            
            -- Value Display
            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Text = tostring(currentValue) .. (suffix or "")
            ValueLabel.Size = UDim2.new(0, 60, 0, 25)
            ValueLabel.Position = UDim2.new(1, -70, 0, 0)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.TextColor3 = theme.Accent
            ValueLabel.TextSize = 13
            ValueLabel.Font = Enum.Font.GothamMedium
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValueLabel.Parent = Element
            
            -- Slider Track
            local Track = Instance.new("Frame")
            Track.Size = UDim2.new(1, -20, 0, 4)
            Track.Position = UDim2.new(0, 10, 1, -20)
            Track.BackgroundColor3 = theme.TabBackground
            Track.BorderSizePixel = 0
            Track.Parent = Element
            
            CreateRoundedCorner(Track, 2)
            
            -- Slider Fill
            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new((currentValue - min) / (max - min), 0, 1, 0)
            Fill.BackgroundColor3 = theme.Accent
            Fill.BorderSizePixel = 0
            Fill.Parent = Track
            
            CreateRoundedCorner(Fill, 2)
            
            -- Slider Dot
            local Dot = Instance.new("Frame")
            Dot.Size = UDim2.new(0, 14, 0, 14)
            Dot.Position = UDim2.new((currentValue - min) / (max - min), -7, 0.5, -7)
            Dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Dot.BorderSizePixel = 0
            Dot.Parent = Track
            
            CreateRoundedCorner(Dot, 7)
            
            local dragging = false
            local function updateSlider(input)
                if not input then return end
                local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                local val = math.floor(min + (max - min) * pos)
                if val ~= currentValue then
                    currentValue = val
                    Fill.Size = UDim2.new(pos, 0, 1, 0)
                    Dot.Position = UDim2.new(pos, -7, 0.5, -7)
                    ValueLabel.Text = tostring(val) .. (suffix or "")
                    local success, err = pcall(callback, val)
                    if not success then
                        ShowErrorFeedback(Element, theme.Element)
                        warn("Slider callback error:", err)
                    end
                end
            end
            
            Track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    updateSlider(input)
                    
                    local moveConn
                    moveConn = Services.UIS.InputChanged:Connect(function(input)
                        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                            updateSlider(input)
                        end
                    end)
                    
                    local releaseConn
                    releaseConn = Services.UIS.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            dragging = false
                            moveConn:Disconnect()
                            releaseConn:Disconnect()
                        end
                    end)
                end
            end)
            
            updatePageSize()
            
            return {
                Set = function(val)
                    val = math.clamp(val, min, max)
                    currentValue = val
                    local pos = (val - min) / (max - min)
                    Fill.Size = UDim2.new(pos, 0, 1, 0)
                    Dot.Position = UDim2.new(pos, -7, 0.5, -7)
                    ValueLabel.Text = tostring(val) .. (suffix or "")
                end,
                Get = function() return currentValue end
            }
        end
        
        function Tab:Dropdown(text, options, default, callback)
            local selected = default or options[1]
            local isOpen = false
            local dropdownContainer = nil
            
            local Element = Instance.new("Frame")
            Element.Size = UDim2.new(1, -16, 0, 42)
            Element.BackgroundColor3 = theme.Element
            Element.BackgroundTransparency = 0.5
            Element.Parent = Page
            
            CreateRoundedCorner(Element, 6)
            local stroke = CreateStroke(Element, theme.Border, 1, 0.5)
            
            -- Title Display
            local Title = Instance.new("TextLabel")
            Title.Text = text .. ": " .. selected
            Title.Size = UDim2.new(1, -50, 1, 0)
            Title.Position = UDim2.new(0, 10, 0, 0)
            Title.BackgroundTransparency = 1
            Title.TextColor3 = theme.Text
            Title.TextSize = 13
            Title.Font = Enum.Font.Gotham
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.Parent = Element
            
            -- Arrow
            local Arrow = Instance.new("TextLabel")
            Arrow.Text = "▼"
            Arrow.Size = UDim2.new(0, 30, 1, 0)
            Arrow.Position = UDim2.new(1, -40, 0, 0)
            Arrow.BackgroundTransparency = 1
            Arrow.TextColor3 = theme.TextSecondary
            Arrow.TextSize = 14
            Arrow.Font = Enum.Font.GothamBold
            Arrow.Parent = Element
            
            local function createDropdown()
                if dropdownContainer then
                    dropdownContainer:Destroy()
                    dropdownContainer = nil
                end
                
                local absPos = Element.AbsolutePosition
                local absSize = Element.AbsoluteSize
                
                dropdownContainer = Instance.new("Frame")
                dropdownContainer.BackgroundColor3 = theme.Element
                dropdownContainer.BorderSizePixel = 0
                dropdownContainer.ZIndex = 1000
                dropdownContainer.Parent = ScreenGui
                
                CreateRoundedCorner(dropdownContainer, 6)
                CreateStroke(dropdownContainer, theme.Accent, 1, 0.3)
                CreateShadow(dropdownContainer, theme.Shadow, 0.4, 6)
                
                dropdownContainer.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 2)
                dropdownContainer.Size = UDim2.new(0, absSize.X, 0, 0)
                
                local List = Instance.new("ScrollingFrame")
                List.Size = UDim2.new(1, -8, 1, -8)
                List.Position = UDim2.new(0, 4, 0, 4)
                List.BackgroundTransparency = 1
                List.BorderSizePixel = 0
                List.ScrollBarThickness = 3
                List.ScrollBarImageColor3 = theme.Accent
                List.Parent = dropdownContainer
                
                local ListLayout = Instance.new("UIListLayout")
                ListLayout.Padding = UDim.new(0, 2)
                ListLayout.Parent = List
                
                for i, option in ipairs(options) do
                    local OptionBtn = Instance.new("TextButton")
                    OptionBtn.Size = UDim2.new(1, 0, 0, 32)
                    OptionBtn.BackgroundColor3 = theme.Element
                    OptionBtn.BackgroundTransparency = 0.6
                    OptionBtn.Text = "  " .. option
                    OptionBtn.TextColor3 = (option == selected) and theme.Accent or theme.TextSecondary
                    OptionBtn.TextSize = 12
                    OptionBtn.Font = Enum.Font.Gotham
                    OptionBtn.TextXAlignment = Enum.TextXAlignment.Left
                    OptionBtn.AutoButtonColor = false
                    OptionBtn.Parent = List
                    
                    CreateRoundedCorner(OptionBtn, 4)
                    
                    OptionBtn.MouseEnter:Connect(function()
                        Animate(OptionBtn, {BackgroundTransparency = 0.4, TextColor3 = theme.Text}, 0.1)
                    end)
                    
                    OptionBtn.MouseLeave:Connect(function()
                        if option ~= selected then
                            Animate(OptionBtn, {BackgroundTransparency = 0.6, TextColor3 = theme.TextSecondary}, 0.1)
                        end
                    end)
                    
                    OptionBtn.MouseButton1Click:Connect(function()
                        selected = option
                        Title.Text = text .. ": " .. selected
                        
                        local success, err = pcall(callback, selected)
                        if not success then
                            ShowErrorFeedback(Element, theme.Element)
                            warn("Dropdown callback error:", err)
                        end
                        
                        toggleDropdown()
                    end)
                end
            end
            
            local function toggleDropdown()
                isOpen = not isOpen
                
                if isOpen then
                    for _, other in pairs(openDropdowns) do
                        if other ~= Element then
                            pcall(other.Close)
                        end
                    end
                    
                    createDropdown()
                    openDropdowns[Element] = {Close = toggleDropdown}
                    Animate(dropdownContainer, {Size = UDim2.new(0, Element.AbsoluteSize.X, 0, 180)}, 0.2)
                    Animate(Arrow, {Rotation = 180, TextColor3 = theme.Accent}, 0.2)
                else
                    if dropdownContainer then
                        Animate(dropdownContainer, {Size = UDim2.new(0, Element.AbsoluteSize.X, 0, 0)}, 0.2)
                        Animate(Arrow, {Rotation = 0, TextColor3 = theme.TextSecondary}, 0.2)
                        task.wait(0.2)
                        dropdownContainer:Destroy()
                        dropdownContainer = nil
                    end
                    openDropdowns[Element] = nil
                end
            end
            
            Element.MouseButton1Click:Connect(toggleDropdown)
            
            -- Close when clicking outside
            local function closeOnOutsideClick(input)
                if isOpen and input.UserInputType == Enum.UserInputType.MouseButton1 and dropdownContainer then
                    local mousePos = input.Position
                    local elementPos = Element.AbsolutePosition
                    local elementSize = Element.AbsoluteSize
                    local containerPos = dropdownContainer.AbsolutePosition
                    local containerSize = dropdownContainer.AbsoluteSize
                    
                    local insideElement = mousePos.X >= elementPos.X and mousePos.X <= elementPos.X + elementSize.X and
                                          mousePos.Y >= elementPos.Y and mousePos.Y <= elementPos.Y + elementSize.Y
                    local insideContainer = containerPos and mousePos.X >= containerPos.X and mousePos.X <= containerPos.X + containerSize.X and
                                            mousePos.Y >= containerPos.Y and mousePos.Y <= containerPos.Y + containerSize.Y
                    
                    if not insideElement and not insideContainer then
                        toggleDropdown()
                    end
                end
            end
            
            local clickConn = Services.UIS.InputBegan:Connect(closeOnOutsideClick)
            table.insert(connections, clickConn)
            
            updatePageSize()
            
            return {
                Set = function(value)
                    for _, v in ipairs(options) do
                        if v == value then
                            selected = value
                            Title.Text = text .. ": " .. selected
                            if callback then pcall(callback, selected) end
                            break
                        end
                    end
                end,
                Get = function() return selected end,
                GetOptions = function() return options end,
                AddOption = function(option)
                    table.insert(options, option)
                end,
                RemoveOption = function(option)
                    for i, v in ipairs(options) do
                        if v == option then
                            table.remove(options, i)
                            if selected == option then
                                selected = options[1] or ""
                                Title.Text = text .. ": " .. selected
                            end
                            break
                        end
                    end
                end
            }
        end
        
        function Tab:Textbox(text, placeholder, callback)
            local Element = Instance.new("Frame")
            Element.Size = UDim2.new(1, -16, 0, 50)
            Element.BackgroundColor3 = theme.Element
            Element.BackgroundTransparency = 0.5
            Element.Parent = Page
            
            CreateRoundedCorner(Element, 6)
            local stroke = CreateStroke(Element, theme.Border, 1, 0.5)
            
            local Title = Instance.new("TextLabel")
            Title.Text = text
            Title.Size = UDim2.new(1, -10, 0, 20)
            Title.Position = UDim2.new(0, 10, 0, 0)
            Title.BackgroundTransparency = 1
            Title.TextColor3 = theme.Text
            Title.TextSize = 12
            Title.Font = Enum.Font.Gotham
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.Parent = Element
            
            local InputBox = Instance.new("TextBox")
            InputBox.Size = UDim2.new(1, -20, 0, 25)
            InputBox.Position = UDim2.new(0, 10, 1, -30)
            InputBox.BackgroundColor3 = theme.TabBackground
            InputBox.PlaceholderText = placeholder or "Enter text..."
            InputBox.PlaceholderColor3 = theme.TextSecondary
            InputBox.TextColor3 = theme.Text
            InputBox.TextSize = 12
            InputBox.Font = Enum.Font.Gotham
            InputBox.Parent = Element
            
            CreateRoundedCorner(InputBox, 4)
            CreateStroke(InputBox, theme.Border, 1, 0.5)
            
            InputBox.FocusLost:Connect(function(enterPressed)
                if enterPressed and InputBox.Text ~= "" then
                    local success, err = pcall(callback, InputBox.Text)
                    if not success then
                        ShowErrorFeedback(Element, theme.Element)
                        warn("Textbox callback error:", err)
                    end
                    InputBox.Text = ""
                end
            end)
            
            updatePageSize()
            
            return {
                Set = function(text)
                    InputBox.Text = text
                end,
                Clear = function()
                    InputBox.Text = ""
                end
            }
        end
        
        function Tab:ColorPicker(text, default, callback)
            local color = default or Color3.fromRGB(255, 255, 255)
            local Element = Instance.new("Frame")
            Element.Size = UDim2.new(1, -16, 0, 42)
            Element.BackgroundColor3 = theme.Element
            Element.BackgroundTransparency = 0.5
            Element.Parent = Page
            
            CreateRoundedCorner(Element, 6)
            local stroke = CreateStroke(Element, theme.Border, 1, 0.5)
            
            local Title = Instance.new("TextLabel")
            Title.Text = text
            Title.Size = UDim2.new(1, -60, 1, 0)
            Title.Position = UDim2.new(0, 10, 0, 0)
            Title.BackgroundTransparency = 1
            Title.TextColor3 = theme.Text
            Title.TextSize = 13
            Title.Font = Enum.Font.Gotham
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.Parent = Element
            
            local ColorDisplay = Instance.new("Frame")
            ColorDisplay.Size = UDim2.new(0, 30, 0, 30)
            ColorDisplay.Position = UDim2.new(1, -45, 0.5, -15)
            ColorDisplay.BackgroundColor3 = color
            ColorDisplay.BorderSizePixel = 0
            ColorDisplay.Parent = Element
            
            CreateRoundedCorner(ColorDisplay, 4)
            CreateStroke(ColorDisplay, theme.Border, 1, 0.5)
            
            -- Simple color selection dialog
            local function showColorPicker()
                local picker = Instance.new("Frame")
                picker.Size = UDim2.new(0, 200, 0, 150)
                picker.BackgroundColor3 = theme.Element
                picker.BorderSizePixel = 0
                picker.Position = UDim2.new(0.5, -100, 0.5, -75)
                picker.Parent = ScreenGui
                
                CreateRoundedCorner(picker, 6)
                CreateStroke(picker, theme.Accent, 1, 0.3)
                CreateShadow(picker, theme.Shadow, 0.4, 6)
                
                local r, g, b = color.R * 255, color.G * 255, color.B * 255
                
                local function updatePreview()
                    ColorDisplay.BackgroundColor3 = Color3.fromRGB(r, g, b)
                end
                
                -- Simple RGB sliders
                local colors = {{"Red", r, 0, 255}, {"Green", g, 0, 255}, {"Blue", b, 0, 255}}
                local yPos = 10
                
                for _, col in ipairs(colors) do
                    local label = Instance.new("TextLabel")
                    label.Text = col[1]
                    label.Size = UDim2.new(0, 40, 0, 20)
                    label.Position = UDim2.new(0, 10, 0, yPos)
                    label.BackgroundTransparency = 1
                    label.TextColor3 = theme.Text
                    label.TextSize = 11
                    label.Font = Enum.Font.Gotham
                    label.Parent = picker
                    
                    local valueLabel = Instance.new("TextLabel")
                    valueLabel.Text = tostring(math.floor(col[2]))
                    valueLabel.Size = UDim2.new(0, 30, 0, 20)
                    valueLabel.Position = UDim2.new(0, 160, 0, yPos)
                    valueLabel.BackgroundTransparency = 1
                    valueLabel.TextColor3 = theme.Accent
                    valueLabel.TextSize = 11
                    valueLabel.Font = Enum.Font.GothamBold
                    valueLabel.Parent = picker
                    
                    local slider = Instance.new("Frame")
                    slider.Size = UDim2.new(0, 100, 0, 4)
                    slider.Position = UDim2.new(0, 55, 0, yPos + 8)
                    slider.BackgroundColor3 = theme.TabBackground
                    slider.BorderSizePixel = 0
                    slider.Parent = picker
                    
                    CreateRoundedCorner(slider, 2)
                    
                    local fill = Instance.new("Frame")
                    fill.Size = UDim2.new((col[2] - col[3]) / (col[4] - col[3]), 0, 1, 0)
                    fill.BackgroundColor3 = theme.Accent
                    fill.BorderSizePixel = 0
                    fill.Parent = slider
                    
                    CreateRoundedCorner(fill, 2)
                    
                    local dragging = false
                    slider.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            dragging = true
                            local pos = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
                            col[2] = math.floor(col[3] + (col[4] - col[3]) * pos)
                            fill.Size = UDim2.new(pos, 0, 1, 0)
                            valueLabel.Text = tostring(math.floor(col[2]))
                            updatePreview()
                            
                            local moveConn
                            moveConn = Services.UIS.InputChanged:Connect(function(input)
                                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                                    pos = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
                                    col[2] = math.floor(col[3] + (col[4] - col[3]) * pos)
                                    fill.Size = UDim2.new(pos, 0, 1, 0)
                                    valueLabel.Text = tostring(math.floor(col[2]))
                                    updatePreview()
                                end
                            end)
                            
                            local releaseConn
                            releaseConn = Services.UIS.InputEnded:Connect(function(input)
                                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                    dragging = false
                                    moveConn:Disconnect()
                                    releaseConn:Disconnect()
                                end
                            end)
                        end
                    end)
                    
                    yPos = yPos + 30
                end
                
                local confirmBtn = Instance.new("TextButton")
                confirmBtn.Text = "Apply"
                confirmBtn.Size = UDim2.new(0, 60, 0, 30)
                confirmBtn.Position = UDim2.new(0.5, -30, 1, -40)
                confirmBtn.BackgroundColor3 = theme.Accent
                confirmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                confirmBtn.TextSize = 12
                confirmBtn.Font = Enum.Font.GothamBold
                confirmBtn.Parent = picker
                
                CreateRoundedCorner(confirmBtn, 4)
                
                confirmBtn.MouseButton1Click:Connect(function()
                    color = Color3.fromRGB(r, g, b)
                    ColorDisplay.BackgroundColor3 = color
                    local success, err = pcall(callback, color)
                    if not success then
                        ShowErrorFeedback(Element, theme.Element)
                        warn("ColorPicker callback error:", err)
                    end
                    picker:Destroy()
                end)
                
                local cancelBtn = Instance.new("TextButton")
                cancelBtn.Text = "Cancel"
                cancelBtn.Size = UDim2.new(0, 60, 0, 30)
                cancelBtn.Position = UDim2.new(0.5, -90, 1, -40)
                cancelBtn.BackgroundColor3 = theme.TabBackground
                cancelBtn.TextColor3 = theme.Text
                cancelBtn.TextSize = 12
                cancelBtn.Font = Enum.Font.Gotham
                cancelBtn.Parent = picker
                
                CreateRoundedCorner(cancelBtn, 4)
                
                cancelBtn.MouseButton1Click:Connect(function()
                    picker:Destroy()
                end)
            end
            
            Element.MouseButton1Click:Connect(showColorPicker)
            updatePageSize()
            
            return {
                Set = function(newColor)
                    color = newColor
                    ColorDisplay.BackgroundColor3 = color
                end,
                Get = function() return color end
            }
        end
        
        function Tab:Keybind(text, default, callback, hold)
            local currentKey = default or Enum.KeyCode.X
            local isListening = false
            local Element = Instance.new("Frame")
            Element.Size = UDim2.new(1, -16, 0, 42)
            Element.BackgroundColor3 = theme.Element
            Element.BackgroundTransparency = 0.5
            Element.Parent = Page
            
            CreateRoundedCorner(Element, 6)
            local stroke = CreateStroke(Element, theme.Border, 1, 0.5)
            
            local Title = Instance.new("TextLabel")
            Title.Text = text
            Title.Size = UDim2.new(1, -110, 1, 0)
            Title.Position = UDim2.new(0, 10, 0, 0)
            Title.BackgroundTransparency = 1
            Title.TextColor3 = theme.Text
            Title.TextSize = 13
            Title.Font = Enum.Font.Gotham
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.Parent = Element
            
            local KeyDisplay = Instance.new("TextButton")
            KeyDisplay.Text = tostring(currentKey):gsub("Enum.KeyCode.", "")
            KeyDisplay.Size = UDim2.new(0, 80, 0, 30)
            KeyDisplay.Position = UDim2.new(1, -95, 0.5, -15)
            KeyDisplay.BackgroundColor3 = theme.Accent
            KeyDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
            KeyDisplay.TextSize = 12
            KeyDisplay.Font = Enum.Font.GothamBold
            KeyDisplay.AutoButtonColor = false
            KeyDisplay.Parent = Element
            
            CreateRoundedCorner(KeyDisplay, 4)
            
            local function startListening()
                isListening = true
                KeyDisplay.Text = "..."
                KeyDisplay.BackgroundColor3 = theme.AccentHover
                
                local connection
                connection = Services.UIS.InputBegan:Connect(function(input, processed)
                    if not processed and isListening then
                        if input.KeyCode ~= Enum.KeyCode.Unknown then
                            currentKey = input.KeyCode
                            KeyDisplay.Text = tostring(currentKey):gsub("Enum.KeyCode.", "")
                            isListening = false
                            KeyDisplay.BackgroundColor3 = theme.Accent
                            connection:Disconnect()
                        end
                    end
                end)
            end
            
            KeyDisplay.MouseButton1Click:Connect(startListening)
            
            -- Keybind execution
            local keyConnection
            keyConnection = Services.UIS.InputBegan:Connect(function(input, processed)
                if not processed and input.KeyCode == currentKey then
                    if hold then
                        local held = true
                        local releaseConn
                        releaseConn = input.Changed:Connect(function()
                            if input.UserInputState == Enum.UserInputState.End then
                                held = false
                                pcall(callback, false)
                                releaseConn:Disconnect()
                            end
                        end)
                        pcall(callback, true)
                    else
                        local success, err = pcall(callback)
                        if not success then
                            ShowErrorFeedback(Element, theme.Element)
                            warn("Keybind callback error:", err)
                        end
                    end
                end
            end)
            
            table.insert(connections, keyConnection)
            updatePageSize()
            
            return {
                Set = function(key)
                    currentKey = key
                    KeyDisplay.Text = tostring(currentKey):gsub("Enum.KeyCode.", "")
                end,
                Get = function() return currentKey end
            }
        end
        
        function Tab:Section(text)
            local Element = Instance.new("Frame")
            Element.Size = UDim2.new(1, -16, 0, 30)
            Element.BackgroundTransparency = 1
            Element.Parent = Page
            
            local Line = Instance.new("Frame")
            Line.Size = UDim2.new(1, 0, 0, 1)
            Line.Position = UDim2.new(0, 0, 0.5, 0)
            Line.BackgroundColor3 = theme.Border
            Line.BackgroundTransparency = 0.5
            Line.Parent = Element
            
            local Label = Instance.new("TextLabel")
            Label.Text = text
            Label.Size = UDim2.new(0, 0, 0, 20)
            Label.Position = UDim2.new(0.5, 0, 0.5, -10)
            Label.BackgroundColor3 = theme.Background
            Label.TextColor3 = theme.TextSecondary
            Label.TextSize = 11
            Label.Font = Enum.Font.Gotham
            Label.Parent = Element
            
            -- Auto-size label
            local textBounds = Services.TextService:GetTextSize(text, 11, Enum.Font.Gotham, Vector2.new(1000, 20))
            Label.Size = UDim2.new(0, textBounds.X + 20, 0, 20)
            Label.Position = UDim2.new(0.5, -(textBounds.X + 20)/2, 0.5, -10)
            
            CreateRoundedCorner(Label, 4)
            
            updatePageSize()
            return Element
        end
        
        function Tab:Paragraph(title, content)
            local Element = Instance.new("Frame")
            Element.Size = UDim2.new(1, -16, 0, 0)
            Element.BackgroundColor3 = theme.Element
            Element.BackgroundTransparency = 0.5
            Element.Parent = Page
            
            CreateRoundedCorner(Element, 6)
            local stroke = CreateStroke(Element, theme.Border, 1, 0.5)
            
            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Text = title
            TitleLabel.Size = UDim2.new(1, -20, 0, 25)
            TitleLabel.Position = UDim2.new(0, 10, 0, 5)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.TextColor3 = theme.Text
            TitleLabel.TextSize = 13
            TitleLabel.Font = Enum.Font.GothamBold
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.Parent = Element
            
            local ContentLabel = Instance.new("TextLabel")
            ContentLabel.Text = content
            ContentLabel.Size = UDim2.new(1, -20, 0, 0)
            ContentLabel.Position = UDim2.new(0, 10, 0, 30)
            ContentLabel.BackgroundTransparency = 1
            ContentLabel.TextColor3 = theme.TextSecondary
            ContentLabel.TextSize = 12
            ContentLabel.Font = Enum.Font.Gotham
            ContentLabel.TextXAlignment = Enum.TextXAlignment.Left
            ContentLabel.TextWrapped = true
            ContentLabel.TextYAlignment = Enum.TextYAlignment.Top
            ContentLabel.Parent = Element
            
            -- Calculate height based on content
            local textBounds = Services.TextService:GetTextSize(content, 12, Enum.Font.Gotham, Vector2.new(Element.AbsoluteSize.X - 20, 1000))
            Element.Size = UDim2.new(1, -16, 0, 30 + textBounds.Y + 15)
            ContentLabel.Size = UDim2.new(1, -20, 0, textBounds.Y)
            
            updatePageSize()
            return Element
        end
        
        --#endregion
        
        return Tab
    end
    
    --#region Notification System
    local NotificationsContainer = Instance.new("Frame")
    NotificationsContainer.Name = "Notifications"
    NotificationsContainer.Size = UDim2.new(0, 300, 1, 0)
    NotificationsContainer.Position = UDim2.new(1, -310, 0, 0)
    NotificationsContainer.BackgroundTransparency = 1
    NotificationsContainer.Parent = ScreenGui
    
    local NotificationList = Instance.new("UIListLayout")
    NotificationList.Padding = UDim.new(0, 8)
    NotificationList.VerticalAlignment = Enum.VerticalAlignment.Bottom
    NotificationList.SortOrder = Enum.SortOrder.LayoutOrder
    NotificationList.Parent = NotificationsContainer
    
    function NovaUI:Notify(notification)
        local notif = Instance.new("Frame")
        notif.Size = UDim2.new(1, -10, 0, 70)
        notif.BackgroundColor3 = theme.Element
        notif.BorderSizePixel = 0
        notif.Parent = NotificationsContainer
        
        CreateRoundedCorner(notif, 6)
        CreateStroke(notif, theme.Accent, 1, 0.3)
        CreateShadow(notif, theme.Shadow, 0.3, 6)
        
        local Title = Instance.new("TextLabel")
        Title.Text = notification.Title or "Notification"
        Title.Size = UDim2.new(1, -20, 0, 25)
        Title.Position = UDim2.new(0, 10, 0, 5)
        Title.BackgroundTransparency = 1
        Title.TextColor3 = theme.Text
        Title.TextSize = 14
        Title.Font = Enum.Font.GothamBold
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Parent = notif
        
        local Content = Instance.new("TextLabel")
        Content.Text = notification.Content or ""
        Content.Size = UDim2.new(1, -20, 0, 35)
        Content.Position = UDim2.new(0, 10, 0, 30)
        Content.BackgroundTransparency = 1
        Content.TextColor3 = theme.TextSecondary
        Content.TextSize = 12
        Content.Font = Enum.Font.Gotham
        Content.TextXAlignment = Enum.TextXAlignment.Left
        Content.TextWrapped = true
        Content.Parent = notif
        
        notif.Position = UDim2.new(0, 320, 0, 0)
        Animate(notif, {Position = UDim2.new(0, 0, 0, 0)}, 0.3)
        
        task.delay(notification.Duration or NovaUI.Config.NotificationDuration, function()
            Animate(notif, {Position = UDim2.new(0, 320, 0, 0)}, 0.3)
            task.wait(0.3)
            notif:Destroy()
        end)
    end
    --#endregion
    
    --#region Theme Management
    function Window:ChangeTheme(themeName)
        local newTheme = NovaUI.Themes[themeName]
        if not newTheme then return end
        
        self.Theme = newTheme
        
        Main.BackgroundColor3 = newTheme.Background
        Topbar.BackgroundColor3 = newTheme.Topbar
        TabContainer.BackgroundColor3 = newTheme.TabBackground
        
        for _, btn in pairs(TabList:GetChildren()) do
            if btn:IsA("TextButton") then
                if btn == self.CurrentTab then
                    btn.BackgroundColor3 = newTheme.TabSelected
                    btn.TextColor3 = newTheme.TabSelectedText
                else
                    btn.BackgroundColor3 = newTheme.TabBackground
                    btn.TextColor3 = newTheme.TabText
                end
            end
        end
        
        Title.TextColor3 = newTheme.Text
        MinimizeBtn.ImageColor3 = newTheme.Text
        CloseBtn.ImageColor3 = newTheme.Text
        
        for _, element in pairs(ContentArea:GetDescendants()) do
            if element:IsA("TextButton") and element.Parent ~= Topbar then
                if element:FindFirstChild("Switch") then
                    -- Toggle element
                    local switch = element:FindFirstChild("Switch")
                    if switch then
                        local indicator = switch:FindFirstChild("Indicator")
                        if switch.BackgroundColor3 == self.Theme.Accent then
                            switch.BackgroundColor3 = newTheme.Accent
                        end
                    end
                end
                element.BackgroundColor3 = newTheme.Element
                element.TextColor3 = newTheme.Text
            elseif element:IsA("Frame") and element ~= Main and element ~= Topbar and element ~= TabContainer and element ~= ContentArea then
                if element.BackgroundTransparency < 1 then
                    element.BackgroundColor3 = newTheme.Element
                end
            elseif element:IsA("TextLabel") then
                if element ~= Title then
                    element.TextColor3 = newTheme.Text
                end
            end
        end
    end
    
    function Window:Destroy()
        for _, conn in pairs(connections) do
            pcall(function() conn:Disconnect() end)
        end
        ScreenGui:Destroy()
    end
    --#endregion
    
    return Window
end
--#endregion

return NovaUI
