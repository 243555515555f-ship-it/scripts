--[[
    FusionUI Library
    Hybrid UI Library inspired by:
      • MyLib.lua (Architecture / Core)
      • Orion.lua (Visual Style / Animations)
      • Rayfield.lua (Developer Experience / API)

    Features:
      • Modern dark UI
      • Smooth tween animations
      • Easy Rayfield-like syntax
      • Runtime error state highlighting
      • Tabs / Buttons / Toggles / Sliders / Inputs
      • Notifications
      • Theme system
      • Lightweight and optimized

    Example:

    local Library = loadstring(game:HttpGet("YOUR_URL"))()

    local Window = Library:CreateWindow({
        Name = "FusionUI",
        Theme = "Cyber"
    })

    local Main = Window:CreateTab("Main", "rbxassetid://6031090990")

    Main:CreateButton({
        Name = "Print Hello",
        Callback = function()
            print("Hello")
        end
    })

    Main:CreateToggle({
        Name = "Auto Farm",
        CurrentValue = false,
        Callback = function(Value)
            print(Value)
        end
    })
]]

local FusionUI = {}
FusionUI.__index = FusionUI

--// SERVICES
local Services = {
    TweenService = game:GetService("TweenService"),
    UserInputService = game:GetService("UserInputService"),
    CoreGui = game:GetService("CoreGui"),
    Players = game:GetService("Players"),
    HttpService = game:GetService("HttpService"),
    RunService = game:GetService("RunService")
}

--// CONFIG
FusionUI.Config = {
    Width = 620,
    Height = 420,
    CornerRadius = 10,
    AnimationSpeed = 0.22,
    ToggleKey = Enum.KeyCode.RightControl
}

--// THEMES
FusionUI.Themes = {
    Dark = {
        Background = Color3.fromRGB(23,23,23),
        Secondary = Color3.fromRGB(30,30,30),
        Tertiary = Color3.fromRGB(37,37,37),
        Accent = Color3.fromRGB(0,170,255),
        Text = Color3.fromRGB(240,240,240),
        TextDim = Color3.fromRGB(170,170,170),
        Stroke = Color3.fromRGB(55,55,55),
        Success = Color3.fromRGB(70,200,120),
        Error = Color3.fromRGB(255,80,80)
    },

    Cyber = {
        Background = Color3.fromRGB(15,18,25),
        Secondary = Color3.fromRGB(22,25,35),
        Tertiary = Color3.fromRGB(30,35,48),
        Accent = Color3.fromRGB(0,255,170),
        Text = Color3.fromRGB(240,240,240),
        TextDim = Color3.fromRGB(150,170,180),
        Stroke = Color3.fromRGB(0,120,90),
        Success = Color3.fromRGB(0,255,140),
        Error = Color3.fromRGB(255,70,70)
    }
}

--// UTIL
local function Tween(Object, Properties, Time)
    return Services.TweenService:Create(
        Object,
        TweenInfo.new(Time or FusionUI.Config.AnimationSpeed, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        Properties
    )
end

local function Create(Class, Properties)
    local Object = Instance.new(Class)

    for Property, Value in pairs(Properties) do
        if Property ~= "Parent" then
            Object[Property] = Value
        end
    end

    Object.Parent = Properties.Parent
    return Object
end

local function Corner(Parent, Radius)
    return Create("UICorner", {
        CornerRadius = UDim.new(0, Radius or FusionUI.Config.CornerRadius),
        Parent = Parent
    })
end

local function Stroke(Parent, Color)
    return Create("UIStroke", {
        Color = Color,
        Thickness = 1,
        Transparency = 0.15,
        Parent = Parent
    })
end

local function SafeCallback(Element, Callback, Theme)
    local Success, ErrorMessage = pcall(Callback)

    if not Success then
        local Original = Element.BackgroundColor3

        Tween(Element, {
            BackgroundColor3 = Theme.Error
        }, 0.15):Play()

        warn("FusionUI Callback Error:", ErrorMessage)

        task.delay(1.2, function()
            Tween(Element, {
                BackgroundColor3 = Original
            }, 0.25):Play()
        end)
    end
end

--// NOTIFICATION
function FusionUI:Notify(Settings)
    local Notification = Create("Frame", {
        Size = UDim2.new(0, 0, 0, 60),
        Position = UDim2.new(1, -20, 1, -20),
        AnchorPoint = Vector2.new(1,1),
        BackgroundColor3 = self.Theme.Secondary,
        BorderSizePixel = 0,
        Parent = self.NotificationHolder
    })

    Corner(Notification)
    Stroke(Notification, self.Theme.Stroke)

    local Title = Create("TextLabel", {
        Size = UDim2.new(1,-20,0,24),
        Position = UDim2.new(0,10,0,6),
        BackgroundTransparency = 1,
        Text = Settings.Title or "Notification",
        Font = Enum.Font.GothamBold,
        TextColor3 = self.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Notification
    })

    local Description = Create("TextLabel", {
        Size = UDim2.new(1,-20,0,18),
        Position = UDim2.new(0,10,0,30),
        BackgroundTransparency = 1,
        Text = Settings.Content or "",
        Font = Enum.Font.Gotham,
        TextColor3 = self.Theme.TextDim,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Notification
    })

    Tween(Notification, {
        Size = UDim2.new(0, 280, 0, 60)
    }, 0.25):Play()

    task.delay(Settings.Duration or 4, function()
        Tween(Notification, {
            Size = UDim2.new(0,0,0,60),
            BackgroundTransparency = 1
        }, 0.25):Play()

        task.wait(0.25)
        Notification:Destroy()
    end)
end

--// WINDOW
function FusionUI:CreateWindow(Settings)
    Settings = Settings or {}

    local Theme = FusionUI.Themes[Settings.Theme or "Dark"]

    local Window = {
        Theme = Theme,
        Tabs = {},
        CurrentTab = nil
    }

    setmetatable(Window, FusionUI)

    local ScreenGui = Create("ScreenGui", {
        Name = "FusionUI_" .. Services.HttpService:GenerateGUID(false),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = Services.CoreGui
    })

    Window.ScreenGui = ScreenGui

    --// MAIN
    local Main = Create("Frame", {
        Size = UDim2.new(0, FusionUI.Config.Width, 0, FusionUI.Config.Height),
        Position = UDim2.new(0.5, -FusionUI.Config.Width/2, 0.5, -FusionUI.Config.Height/2),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Parent = ScreenGui
    })

    Corner(Main, 12)
    Stroke(Main, Theme.Stroke)

    Window.Main = Main

    --// SHADOW
    local Shadow = Create("ImageLabel", {
        Size = UDim2.new(1, 30, 1, 30),
        Position = UDim2.new(0,-15,0,-15),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6014261993",
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49,49,450,450),
        ZIndex = 0,
        Parent = Main
    })

    --// TOPBAR
    local Topbar = Create("Frame", {
        Size = UDim2.new(1,0,0,42),
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        Parent = Main
    })

    Corner(Topbar, 12)

    local Fix = Create("Frame", {
        Size = UDim2.new(1,0,0,12),
        Position = UDim2.new(0,0,1,-12),
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        Parent = Topbar
    })

    local Title = Create("TextLabel", {
        Size = UDim2.new(1,-80,1,0),
        Position = UDim2.new(0,15,0,0),
        BackgroundTransparency = 1,
        Text = Settings.Name or "FusionUI",
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Topbar
    })

    local Close = Create("TextButton", {
        Size = UDim2.new(0,26,0,26),
        Position = UDim2.new(1,-34,0.5,-13),
        BackgroundColor3 = Theme.Tertiary,
        BorderSizePixel = 0,
        Text = "×",
        Font = Enum.Font.GothamBold,
        TextColor3 = Theme.Text,
        TextSize = 18,
        Parent = Topbar
    })

    Corner(Close, 7)

    Close.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    --// SIDEBAR
    local Sidebar = Create("Frame", {
        Size = UDim2.new(0,160,1,-52),
        Position = UDim2.new(0,10,0,42),
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        Parent = Main
    })

    Corner(Sidebar)
    Stroke(Sidebar, Theme.Stroke)

    local TabHolder = Create("ScrollingFrame", {
        Size = UDim2.new(1,-10,1,-10),
        Position = UDim2.new(0,5,0,5),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(),
        Parent = Sidebar
    })

    local TabLayout = Create("UIListLayout", {
        Padding = UDim.new(0,6),
        Parent = TabHolder
    })

    TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabHolder.CanvasSize = UDim2.new(0,0,0,TabLayout.AbsoluteContentSize.Y + 10)
    end)

    --// CONTENT
    local Content = Create("Frame", {
        Size = UDim2.new(1,-180,1,-52),
        Position = UDim2.new(0,170,0,42),
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        Parent = Main
    })

    Corner(Content)
    Stroke(Content, Theme.Stroke)

    --// NOTIFICATIONS
    local NotificationHolder = Create("Frame", {
        Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1,
        Parent = ScreenGui
    })

    Window.NotificationHolder = NotificationHolder

    --// DRAGGING
    do
        local Dragging
        local DragStart
        local StartPos

        Topbar.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                Dragging = true
                DragStart = Input.Position
                StartPos = Main.Position
            end
        end)

        Services.UserInputService.InputChanged:Connect(function(Input)
            if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
                local Delta = Input.Position - DragStart

                Tween(Main, {
                    Position = UDim2.new(
                        StartPos.X.Scale,
                        StartPos.X.Offset + Delta.X,
                        StartPos.Y.Scale,
                        StartPos.Y.Offset + Delta.Y
                    )
                }, 0.05):Play()
            end
        end)

        Services.UserInputService.InputEnded:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                Dragging = false
            end
        end)
    end

    --// HIDE KEY
    Services.UserInputService.InputBegan:Connect(function(Input, GameProcessed)
        if GameProcessed then return end

        if Input.KeyCode == FusionUI.Config.ToggleKey then
            Main.Visible = not Main.Visible
        end
    end)

    --// TAB FUNCTION
    function Window:CreateTab(Name, Icon)
        local Tab = {}

        local TabButton = Create("TextButton", {
            Size = UDim2.new(1,0,0,36),
            BackgroundColor3 = Theme.Tertiary,
            BorderSizePixel = 0,
            Text = "",
            Parent = TabHolder
        })

        Corner(TabButton, 8)
        Stroke(TabButton, Theme.Stroke)

        local TabTitle = Create("TextLabel", {
            Size = UDim2.new(1,-10,1,0),
            Position = UDim2.new(0,10,0,0),
            BackgroundTransparency = 1,
            Text = Name,
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            TextColor3 = Theme.TextDim,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = TabButton
        })

        local Page = Create("ScrollingFrame", {
            Size = UDim2.new(1,-10,1,-10),
            Position = UDim2.new(0,5,0,5),
            BackgroundTransparency = 1,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Theme.Accent,
            Visible = false,
            CanvasSize = UDim2.new(),
            Parent = Content
        })

        local Layout = Create("UIListLayout", {
            Padding = UDim.new(0,8),
            Parent = Page
        })

        local Padding = Create("UIPadding", {
            PaddingTop = UDim.new(0,5),
            PaddingLeft = UDim.new(0,5),
            PaddingRight = UDim.new(0,5),
            Parent = Page
        })

        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y + 10)
        end)

        local function SelectTab()
            for _, Existing in pairs(Window.Tabs) do
                Existing.Page.Visible = false

                Tween(Existing.Button, {
                    BackgroundColor3 = Theme.Tertiary
                }):Play()

                Existing.Label.TextColor3 = Theme.TextDim
            end

            Page.Visible = true

            Tween(TabButton, {
                BackgroundColor3 = Theme.Accent
            }):Play()

            TabTitle.TextColor3 = Theme.Text
        end

        TabButton.MouseButton1Click:Connect(SelectTab)

        if not Window.CurrentTab then
            Window.CurrentTab = Tab
            task.spawn(SelectTab)
        end

        --// ELEMENT CREATOR
        local function CreateElementFrame(Height)
            local Holder = Create("Frame", {
                Size = UDim2.new(1,-4,0,Height),
                BackgroundColor3 = Theme.Tertiary,
                BorderSizePixel = 0,
                Parent = Page
            })

            Corner(Holder, 8)
            Stroke(Holder, Theme.Stroke)

            return Holder
        end

        --// BUTTON
        function Tab:CreateButton(Settings)
            Settings = Settings or {}

            local Frame = CreateElementFrame(42)

            local Button = Create("TextButton", {
                Size = UDim2.new(1,-12,1,-12),
                Position = UDim2.new(0,6,0,6),
                BackgroundColor3 = Theme.Accent,
                BorderSizePixel = 0,
                Text = Settings.Name or "Button",
                Font = Enum.Font.GothamMedium,
                TextSize = 13,
                TextColor3 = Theme.Text,
                Parent = Frame
            })

            Corner(Button, 7)

            Button.MouseEnter:Connect(function()
                Tween(Button, {
                    BackgroundTransparency = 0.15
                }):Play()
            end)

            Button.MouseLeave:Connect(function()
                Tween(Button, {
                    BackgroundTransparency = 0
                }):Play()
            end)

            Button.MouseButton1Click:Connect(function()
                SafeCallback(Button, Settings.Callback or function() end, Theme)
            end)
        end

        --// TOGGLE
        function Tab:CreateToggle(Settings)
            Settings = Settings or {}

            local Value = Settings.CurrentValue or false

            local Frame = CreateElementFrame(42)

            local Label = Create("TextLabel", {
                Size = UDim2.new(1,-70,1,0),
                Position = UDim2.new(0,12,0,0),
                BackgroundTransparency = 1,
                Text = Settings.Name or "Toggle",
                Font = Enum.Font.GothamMedium,
                TextSize = 13,
                TextColor3 = Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Frame
            })

            local Toggle = Create("Frame", {
                Size = UDim2.new(0,44,0,22),
                Position = UDim2.new(1,-56,0.5,-11),
                BackgroundColor3 = Theme.Secondary,
                BorderSizePixel = 0,
                Parent = Frame
            })

            Corner(Toggle, 20)
            Stroke(Toggle, Theme.Stroke)

            local Circle = Create("Frame", {
                Size = UDim2.new(0,18,0,18),
                Position = UDim2.new(0,2,0.5,-9),
                BackgroundColor3 = Theme.Text,
                BorderSizePixel = 0,
                Parent = Toggle
            })

            Corner(Circle, 20)

            local function Update()
                Tween(Toggle, {
                    BackgroundColor3 = Value and Theme.Accent or Theme.Secondary
                }):Play()

                Tween(Circle, {
                    Position = Value and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9)
                }):Play()
            end

            Update()

            local Click = Create("TextButton", {
                Size = UDim2.new(1,0,1,0),
                BackgroundTransparency = 1,
                Text = "",
                Parent = Frame
            })

            Click.MouseButton1Click:Connect(function()
                Value = not Value
                Update()

                SafeCallback(Frame, function()
                    (Settings.Callback or function() end)(Value)
                end, Theme)
            end)
        end

        --// SLIDER
        function Tab:CreateSlider(Settings)
            Settings = Settings or {}

            local Min = Settings.Range and Settings.Range[1] or 0
            local Max = Settings.Range and Settings.Range[2] or 100
            local Current = Settings.CurrentValue or Min

            local Dragging = false

            local Frame = CreateElementFrame(58)

            local Label = Create("TextLabel", {
                Size = UDim2.new(1,-20,0,18),
                Position = UDim2.new(0,10,0,8),
                BackgroundTransparency = 1,
                Text = (Settings.Name or "Slider") .. " : " .. tostring(Current),
                Font = Enum.Font.GothamMedium,
                TextSize = 13,
                TextColor3 = Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Frame
            })

            local Bar = Create("Frame", {
                Size = UDim2.new(1,-20,0,8),
                Position = UDim2.new(0,10,1,-18),
                BackgroundColor3 = Theme.Secondary,
                BorderSizePixel = 0,
                Parent = Frame
            })

            Corner(Bar, 10)

            local Fill = Create("Frame", {
                Size = UDim2.new((Current-Min)/(Max-Min),0,1,0),
                BackgroundColor3 = Theme.Accent,
                BorderSizePixel = 0,
                Parent = Bar
            })

            Corner(Fill, 10)

            local function Set(Value)
                Value = math.clamp(Value, Min, Max)
                Current = Value

                Label.Text = (Settings.Name or "Slider") .. " : " .. tostring(math.floor(Value))

                Tween(Fill, {
                    Size = UDim2.new((Value-Min)/(Max-Min),0,1,0)
                }, 0.05):Play()

                SafeCallback(Frame, function()
                    (Settings.Callback or function() end)(Value)
                end, Theme)
            end

            Bar.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Dragging = true
                end
            end)

            Services.UserInputService.InputEnded:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Dragging = false
                end
            end)

            Services.UserInputService.InputChanged:Connect(function(Input)
                if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
                    local Percent = math.clamp(
                        (Input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X,
                        0,
                        1
                    )

                    local Value = Min + ((Max - Min) * Percent)
                    Set(Value)
                end
            end)
        end

        --// INPUT
        function Tab:CreateInput(Settings)
            Settings = Settings or {}

            local Frame = CreateElementFrame(46)

            local Input = Create("TextBox", {
                Size = UDim2.new(1,-12,1,-12),
                Position = UDim2.new(0,6,0,6),
                BackgroundColor3 = Theme.Secondary,
                BorderSizePixel = 0,
                PlaceholderText = Settings.PlaceholderText or "Enter text...",
                Text = "",
                Font = Enum.Font.Gotham,
                TextSize = 13,
                TextColor3 = Theme.Text,
                PlaceholderColor3 = Theme.TextDim,
                ClearTextOnFocus = false,
                Parent = Frame
            })

            Corner(Input, 7)
            Stroke(Input, Theme.Stroke)

            Input.FocusLost:Connect(function()
                SafeCallback(Frame, function()
                    (Settings.Callback or function() end)(Input.Text)
                end, Theme)
            end)
        end

        --// LABEL
        function Tab:CreateLabel(Text)
            local Frame = CreateElementFrame(36)

            local Label = Create("TextLabel", {
                Size = UDim2.new(1,-12,1,0),
                Position = UDim2.new(0,12,0,0),
                BackgroundTransparency = 1,
                Text = Text or "Label",
                Font = Enum.Font.Gotham,
                TextSize = 13,
                TextColor3 = Theme.TextDim,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Frame
            })
        end

        Tab.Button = TabButton
        Tab.Page = Page
        Tab.Label = TabTitle

        table.insert(Window.Tabs, Tab)

        return Tab
    end

    return Window
end

return FusionUI
