-- NovaLib: Full Version
-- Architecture: MyLib | Visuals: Orion | DX & Logic: Rayfield

local Library = {}

-- [[ Services Cache ]]
local services = {
    UIS = game:GetService("UserInputService"),
    TweenService = game:GetService("TweenService"),
    RunService = game:GetService("RunService"),
    CoreGui = game:GetService("CoreGui"),
    HttpService = game:GetService("HttpService")
}

-- [[ Orion-Inspired Theme ]]
Library.Theme = {
    Background = Color3.fromRGB(25, 25, 25),       -- Main Body (Orion Dark Gray)
    Accent = Color3.fromRGB(139, 0, 23),           -- Main Accent (Orion Crimson)
    Secondary = Color3.fromRGB(33, 33, 33),        -- Elements/Containers
    Text = Color3.fromRGB(255, 255, 255),          -- Primary Text
    TextDark = Color3.fromRGB(198, 198, 198),      -- Secondary Text
    Error = Color3.fromRGB(181, 1, 31),            -- Rayfield Failure State Red
    Success = Color3.fromRGB(0, 170, 0),
    Stroke = Color3.fromRGB(53, 53, 53)            -- Subtle Borders
}

-- [[ Utility: Instance Creator (From MyLib) ]]
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
    if properties.Parent then instance.Parent = properties.Parent end
    return instance
end

-- [[ Utility: Smooth Dragging ]]
local function MakeDraggable(dragPoint, frame)
    local dragging, dragInput, dragStart, startPos
    
    dragPoint.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    dragPoint.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    services.UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            local targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            services.TweenService:Create(frame, TweenInfo.new(0.15, Enum.EasingStyle.Cubic), {Position = targetPos}):Play()
        end
    end)
    
    services.UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- [[ Core Framework Initiation ]]
function Library:CreateWindow(Settings)
    Settings = Settings or {}
    local WindowName = Settings.Name or "Nova UI"
    local HideKey = Settings.HideKey or Enum.KeyCode.RightShift
    
    local Window = {
        Tabs = {},
        CurrentTab = nil,
        IsOpen = true
    }
    
    -- ScreenGui Setup
    local ScreenGui = UI:Create("ScreenGui", {
        Name = "NovaLib_" .. services.HttpService:GenerateGUID(false):sub(1,8),
        Parent = (services.RunService:IsStudio() and services.Players.LocalPlayer:WaitForChild("PlayerGui") or services.CoreGui),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    Window.Gui = ScreenGui
    
    -- Main Frame (Orion Aesthetics)
    local MainFrame = UI:Create("Frame", {
        Name = "Main",
        Size = UDim2.new(0, 550, 0, 350),
        Position = UDim2.new(0.5, -275, 0.5, -175),
        BackgroundColor3 = Library.Theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = ScreenGui
    })
    UI:Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = MainFrame })
    UI:Create("UIStroke", { Color = Library.Theme.Accent, Thickness = 2, Parent = MainFrame })
    
    -- Header
    local Header = UI:Create("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Library.Theme.Accent,
        Parent = MainFrame
    })
    UI:Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Header })
    UI:Create("Frame", { Size = UDim2.new(1, 0, 0, 6), Position = UDim2.new(0, 0, 1, -6), BackgroundColor3 = Library.Theme.Accent, BorderSizePixel = 0, Parent = Header })
    
    UI:Create("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        Text = WindowName,
        TextColor3 = Library.Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Header
    })
    
    MakeDraggable(Header, MainFrame)
    
    -- Tab Selection Sidebar
    local TabContainer = UI:Create("ScrollingFrame", {
        Name = "TabContainer",
        Size = UDim2.new(0, 130, 1, -50),
        Position = UDim2.new(0, 10, 0, 50),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        Parent = MainFrame
    })
    UI:Create("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder, Parent = TabContainer })
    
    -- Pages Container
    local PageContainer = UI:Create("Frame", {
        Name = "PageContainer",
        Size = UDim2.new(1, -155, 1, -60),
        Position = UDim2.new(0, 145, 0, 50),
        BackgroundColor3 = Library.Theme.Secondary,
        Parent = MainFrame
    })
    UI:Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = PageContainer })
    UI:Create("UIStroke", { Color = Library.Theme.Stroke, Thickness = 1, Parent = PageContainer })
    
    -- Toggle Visibility Logic
    services.UIS.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == HideKey then
            Window.IsOpen = not Window.IsOpen
            MainFrame.Visible = Window.IsOpen
        end
    end)
    
    -- [[ Rayfield UX: Dynamic Error Handler ]]
    local function HandleAction(element, uiStroke, originalColor, callback, ...)
        if not callback then return end
        local success, response = pcall(callback, ...)
        
        if not success then
            warn("[NovaLib] Callback Error: " .. tostring(response))
            services.TweenService:Create(element, TweenInfo.new(0.3), {BackgroundColor3 = Library.Theme.Error}):Play()
            if uiStroke then services.TweenService:Create(uiStroke, TweenInfo.new(0.3), {Color = Library.Theme.Error}):Play() end
            
            task.wait(1.5)
            
            services.TweenService:Create(element, TweenInfo.new(0.3), {BackgroundColor3 = originalColor}):Play()
            if uiStroke then services.TweenService:Create(uiStroke, TweenInfo.new(0.3), {Color = Library.Theme.Stroke}):Play() end
        end
    end

    -- [[ Tab Creation ]]
    function Window:CreateTab(TabSettings)
        local TabName = TabSettings.Name or "Tab"
        
        local TabBtn = UI:Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundColor3 = Library.Theme.Background,
            Text = "  " .. TabName,
            TextColor3 = Library.Theme.TextDark,
            Font = Enum.Font.GothamSemibold,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = TabContainer
        })
        UI:Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = TabBtn })
        local TabBtnStroke = UI:Create("UIStroke", { Color = Library.Theme.Background, Thickness = 1, Parent = TabBtn })
        
        local Page = UI:Create("ScrollingFrame", {
            Size = UDim2.new(1, -20, 1, -20),
            Position = UDim2.new(0, 10, 0, 10),
            BackgroundTransparency = 1,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Library.Theme.Accent,
            Visible = false,
            Parent = PageContainer
        })
        local PageLayout = UI:Create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = Page })
        
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 10)
        end)
        
        local Tab = { Elements = {} }
        
        local function ActivateTab()
            for _, otherPage in pairs(PageContainer:GetChildren()) do
                if otherPage:IsA("ScrollingFrame") then otherPage.Visible = false end
            end
            for _, otherBtn in pairs(TabContainer:GetChildren()) do
                if otherBtn:IsA("TextButton") then
                    services.TweenService:Create(otherBtn, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.Background, TextColor3 = Library.Theme.TextDark}):Play()
                    otherBtn:FindFirstChild("UIStroke").Color = Library.Theme.Background
                end
            end
            
            Page.Visible = true
            services.TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.Secondary, TextColor3 = Library.Theme.Text}):Play()
            TabBtnStroke.Color = Library.Theme.Stroke
            Window.CurrentTab = Tab
        end
        
        TabBtn.MouseButton1Click:Connect(ActivateTab)
        if #Window.Tabs == 0 then ActivateTab() end
        table.insert(Window.Tabs, Tab)
        
        -- [[ Element: Label ]]
        function Tab:CreateLabel(LabelSettings)
            local LabelText = LabelSettings.Name or "Label"
            local LabelFrame = UI:Create("Frame", { Size = UDim2.new(1, -5, 0, 35), BackgroundColor3 = Library.Theme.Background, Parent = Page })
            UI:Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = LabelFrame })
            UI:Create("UIStroke", { Color = Library.Theme.Stroke, Parent = LabelFrame })
            
            local Txt = UI:Create("TextLabel", { Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = LabelText, TextColor3 = Library.Theme.Text, Font = Enum.Font.Gotham, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = LabelFrame })
            return { Set = function(self, newText) Txt.Text = newText end }
        end

        -- [[ Element: Button ]]
        function Tab:CreateButton(BtnSettings)
            local BtnName = BtnSettings.Name or "Button"
            local Callback = BtnSettings.Callback or function() end
            
            local BtnFrame = UI:Create("TextButton", { Size = UDim2.new(1, -5, 0, 38), BackgroundColor3 = Library.Theme.Background, Text = "", AutoButtonColor = false, Parent = Page })
            UI:Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = BtnFrame })
            local Stroke = UI:Create("UIStroke", { Color = Library.Theme.Stroke, Parent = BtnFrame })
            UI:Create("TextLabel", { Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = BtnName, TextColor3 = Library.Theme.Text, Font = Enum.Font.GothamSemibold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = BtnFrame })
            
            BtnFrame.MouseEnter:Connect(function() services.TweenService:Create(BtnFrame, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.Secondary}):Play() end)
            BtnFrame.MouseLeave:Connect(function() services.TweenService:Create(BtnFrame, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.Background}):Play() end)
            BtnFrame.MouseButton1Click:Connect(function()
                services.TweenService:Create(BtnFrame, TweenInfo.new(0.1), {BackgroundColor3 = Library.Theme.Accent}):Play()
                task.wait(0.1)
                services.TweenService:Create(BtnFrame, TweenInfo.new(0.1), {BackgroundColor3 = Library.Theme.Secondary}):Play()
                HandleAction(BtnFrame, Stroke, Library.Theme.Background, Callback)
            end)
        end

        -- [[ Element: Toggle ]]
        function Tab:CreateToggle(ToggleSettings)
            local ToggleName = ToggleSettings.Name or "Toggle"
            local CurrentValue = ToggleSettings.CurrentValue or false
            local Callback = ToggleSettings.Callback or function() end
            
            local ToggleFrame = UI:Create("TextButton", { Size = UDim2.new(1, -5, 0, 38), BackgroundColor3 = Library.Theme.Background, Text = "", AutoButtonColor = false, Parent = Page })
            UI:Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = ToggleFrame })
            local Stroke = UI:Create("UIStroke", { Color = Library.Theme.Stroke, Parent = ToggleFrame })
            UI:Create("TextLabel", { Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = ToggleName, TextColor3 = Library.Theme.Text, Font = Enum.Font.GothamSemibold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = ToggleFrame })
            
            local SwitchOuter = UI:Create("Frame", { Size = UDim2.new(0, 40, 0, 20), Position = UDim2.new(1, -50, 0.5, -10), BackgroundColor3 = CurrentValue and Library.Theme.Accent or Library.Theme.Secondary, Parent = ToggleFrame })
            UI:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = SwitchOuter })
            UI:Create("UIStroke", { Color = Library.Theme.Stroke, Parent = SwitchOuter })
            local SwitchInner = UI:Create("Frame", { Size = UDim2.new(0, 16, 0, 16), Position = CurrentValue and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = Color3.fromRGB(255, 255, 255), Parent = SwitchOuter })
            UI:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = SwitchInner })
            
            local function UpdateVisuals()
                services.TweenService:Create(SwitchOuter, TweenInfo.new(0.2), {BackgroundColor3 = CurrentValue and Library.Theme.Accent or Library.Theme.Secondary}):Play()
                services.TweenService:Create(SwitchInner, TweenInfo.new(0.2), {Position = CurrentValue and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
            end
            
            ToggleFrame.MouseButton1Click:Connect(function()
                CurrentValue = not CurrentValue
                UpdateVisuals()
                HandleAction(ToggleFrame, Stroke, Library.Theme.Background, Callback, CurrentValue)
            end)
            
            return { Set = function(self, value) CurrentValue = value; UpdateVisuals(); pcall(Callback, CurrentValue) end }
        end

        -- [[ Element: Slider ]]
        function Tab:CreateSlider(SliderSettings)
            local SliderName = SliderSettings.Name or "Slider"
            local Min = SliderSettings.Range[1] or 0
            local Max = SliderSettings.Range[2] or 100
            local CurrentValue = SliderSettings.CurrentValue or Min
            local Callback = SliderSettings.Callback or function() end
            
            local SliderFrame = UI:Create("Frame", { Size = UDim2.new(1, -5, 0, 55), BackgroundColor3 = Library.Theme.Background, Parent = Page })
            UI:Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = SliderFrame })
            local Stroke = UI:Create("UIStroke", { Color = Library.Theme.Stroke, Parent = SliderFrame })
            
            UI:Create("TextLabel", { Size = UDim2.new(1, -20, 0, 25), Position = UDim2.new(0, 10, 0, 5), BackgroundTransparency = 1, Text = SliderName, TextColor3 = Library.Theme.Text, Font = Enum.Font.GothamSemibold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = SliderFrame })
            local ValueLabel = UI:Create("TextLabel", { Size = UDim2.new(0, 50, 0, 25), Position = UDim2.new(1, -60, 0, 5), BackgroundTransparency = 1, Text = tostring(CurrentValue), TextColor3 = Library.Theme.Accent, Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Right, Parent = SliderFrame })
            
            local BarBG = UI:Create("TextButton", { Size = UDim2.new(1, -20, 0, 6), Position = UDim2.new(0, 10, 1, -15), BackgroundColor3 = Library.Theme.Secondary, Text = "", AutoButtonColor = false, Parent = SliderFrame })
            UI:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = BarBG })
            local BarFill = UI:Create("Frame", { Size = UDim2.new((CurrentValue - Min) / (Max - Min), 0, 1, 0), BackgroundColor3 = Library.Theme.Accent, Parent = BarBG })
            UI:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = BarFill })
            
            local isDragging = false
            local function UpdateSlider(input)
                local pos = math.clamp((input.Position.X - BarBG.AbsolutePosition.X) / BarBG.AbsoluteSize.X, 0, 1)
                local val = math.floor(Min + ((Max - Min) * pos))
                if val ~= CurrentValue then
                    CurrentValue = val
                    ValueLabel.Text = tostring(val)
                    services.TweenService:Create(BarFill, TweenInfo.new(0.1), {Size = UDim2.new(pos, 0, 1, 0)}):Play()
                    HandleAction(SliderFrame, Stroke, Library.Theme.Background, Callback, CurrentValue)
                end
            end
            
            BarBG.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = true; UpdateSlider(input) end
            end)
            services.UIS.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = false end
            end)
            services.UIS.InputChanged:Connect(function(input)
                if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then UpdateSlider(input) end
            end)
            
            return { Set = function(self, value) value = math.clamp(value, Min, Max); CurrentValue = value; ValueLabel.Text = tostring(value); BarFill.Size = UDim2.new((value - Min) / (Max - Min), 0, 1, 0); pcall(Callback, CurrentValue) end }
        end

        -- [[ Element: TextBox ]]
        function Tab:CreateTextBox(TextBoxSettings)
            local BoxName = TextBoxSettings.Name or "TextBox"
            local Placeholder = TextBoxSettings.PlaceholderText or "Enter text..."
            local Callback = TextBoxSettings.Callback or function() end

            local BoxFrame = UI:Create("Frame", { Size = UDim2.new(1, -5, 0, 45), BackgroundColor3 = Library.Theme.Background, Parent = Page })
            UI:Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = BoxFrame })
            local Stroke = UI:Create("UIStroke", { Color = Library.Theme.Stroke, Parent = BoxFrame })
            
            UI:Create("TextLabel", { Size = UDim2.new(0.4, 0, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = BoxName, TextColor3 = Library.Theme.Text, Font = Enum.Font.GothamSemibold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = BoxFrame })
            
            local InputContainer = UI:Create("Frame", { Size = UDim2.new(0.5, -10, 0, 30), Position = UDim2.new(0.5, 0, 0.5, -15), BackgroundColor3 = Library.Theme.Secondary, Parent = BoxFrame })
            UI:Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = InputContainer })
            UI:Create("UIStroke", { Color = Library.Theme.Stroke, Parent = InputContainer })
            
            local InputBox = UI:Create("TextBox", { Size = UDim2.new(1, -10, 1, 0), Position = UDim2.new(0, 5, 0, 0), BackgroundTransparency = 1, Text = "", PlaceholderText = Placeholder, PlaceholderColor3 = Library.Theme.TextDark, TextColor3 = Library.Theme.Text, Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, Parent = InputContainer })
            
            InputBox.FocusLost:Connect(function(enterPressed)
                HandleAction(BoxFrame, Stroke, Library.Theme.Background, Callback, InputBox.Text)
                if TextBoxSettings.RemoveTextAfterFocusLost then InputBox.Text = "" end
            end)
            
            return { Set = function(self, text) InputBox.Text = text end }
        end

        -- [[ Element: Dropdown ]]
        function Tab:CreateDropdown(DropdownSettings)
            local DropName = DropdownSettings.Name or "Dropdown"
            local Options = DropdownSettings.Options or {}
            local CurrentOption = DropdownSettings.CurrentOption or Options[1] or ""
            local Callback = DropdownSettings.Callback or function() end
            
            local DropFrame = UI:Create("Frame", { Size = UDim2.new(1, -5, 0, 40), BackgroundColor3 = Library.Theme.Background, ClipsDescendants = true, Parent = Page })
            UI:Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = DropFrame })
            local Stroke = UI:Create("UIStroke", { Color = Library.Theme.Stroke, Parent = DropFrame })
            
            local DropBtn = UI:Create("TextButton", { Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, Parent = DropFrame })
            local TitleLabel = UI:Create("TextLabel", { Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = DropName .. ": " .. tostring(CurrentOption), TextColor3 = Library.Theme.Text, Font = Enum.Font.GothamSemibold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = DropBtn })
            local Arrow = UI:Create("TextLabel", { Size = UDim2.new(0, 20, 1, 0), Position = UDim2.new(1, -30, 0, 0), BackgroundTransparency = 1, Text = "▼", TextColor3 = Library.Theme.TextDark, Font = Enum.Font.GothamBold, TextSize = 12, Parent = DropBtn })
            
            local OptionContainer = UI:Create("Frame", { Size = UDim2.new(1, -20, 1, -45), Position = UDim2.new(0, 10, 0, 40), BackgroundTransparency = 1, Parent = DropFrame })
            local OptionLayout = UI:Create("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = OptionContainer })
            
            local isOpen = false
            local function ToggleDropdown()
                isOpen = not isOpen
                local targetHeight = isOpen and (45 + (#Options * 30)) or 40
                services.TweenService:Create(DropFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, -5, 0, targetHeight)}):Play()
                services.TweenService:Create(Arrow, TweenInfo.new(0.2), {Rotation = isOpen and 180 or 0}):Play()
            end
            
            DropBtn.MouseButton1Click:Connect(ToggleDropdown)
            
            local function PopulateOptions()
                for _, child in pairs(OptionContainer:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
                for i, option in ipairs(Options) do
                    local OptBtn = UI:Create("TextButton", { Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = Library.Theme.Secondary, Text = "  " .. option, TextColor3 = (option == CurrentOption) and Library.Theme.Accent or Library.Theme.TextDark, Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = i, Parent = OptionContainer })
                    UI:Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = OptBtn })
                    
                    OptBtn.MouseButton1Click:Connect(function()
                        CurrentOption = option
                        TitleLabel.Text = DropName .. ": " .. tostring(CurrentOption)
                        ToggleDropdown()
                        PopulateOptions()
                        HandleAction(DropFrame, Stroke, Library.Theme.Background, Callback, CurrentOption)
                    end)
                end
            end
            PopulateOptions()
            
            return {
                Refresh = function(self, newOptions)
                    Options = newOptions
                    PopulateOptions()
                    if isOpen then services.TweenService:Create(DropFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, -5, 0, 45 + (#Options * 30))}):Play() end
                end,
                Set = function(self, value)
                    CurrentOption = value
                    TitleLabel.Text = DropName .. ": " .. tostring(CurrentOption)
                    PopulateOptions()
                    pcall(Callback, CurrentOption)
                end
            }
        end

        -- [[ Element: Keybind ]]
        function Tab:CreateKeybind(KeybindSettings)
            local BindName = KeybindSettings.Name or "Keybind"
            local CurrentKey = KeybindSettings.CurrentKeybind or "None"
            local Callback = KeybindSettings.Callback or function() end
            local IsListening = false
            
            local BindFrame = UI:Create("Frame", { Size = UDim2.new(1, -5, 0, 40), BackgroundColor3 = Library.Theme.Background, Parent = Page })
            UI:Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = BindFrame })
            local Stroke = UI:Create("UIStroke", { Color = Library.Theme.Stroke, Parent = BindFrame })
            
            UI:Create("TextLabel", { Size = UDim2.new(0.6, 0, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = BindName, TextColor3 = Library.Theme.Text, Font = Enum.Font.GothamSemibold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = BindFrame })
            
            local BindBtn = UI:Create("TextButton", { Size = UDim2.new(0, 80, 0, 26), Position = UDim2.new(1, -90, 0.5, -13), BackgroundColor3 = Library.Theme.Secondary, Text = tostring(CurrentKey), TextColor3 = Library.Theme.Accent, Font = Enum.Font.GothamBold, TextSize = 13, Parent = BindFrame })
            UI:Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = BindBtn })
            UI:Create("UIStroke", { Color = Library.Theme.Stroke, Parent = BindBtn })
            
            BindBtn.MouseButton1Click:Connect(function()
                IsListening = true
                BindBtn.Text = "..."
                BindBtn.TextColor3 = Library.Theme.Text
            end)
            
            services.UIS.InputBegan:Connect(function(input, processed)
                if IsListening and input.UserInputType == Enum.UserInputType.Keyboard then
                    IsListening = false
                    CurrentKey = input.KeyCode.Name
                    BindBtn.Text = CurrentKey
                    BindBtn.TextColor3 = Library.Theme.Accent
                elseif not processed and input.KeyCode.Name == CurrentKey and not IsListening then
                    HandleAction(BindFrame, Stroke, Library.Theme.Background, Callback)
                end
            end)
            
            return { Set = function(self, newKey) CurrentKey = newKey; BindBtn.Text = tostring(newKey) end }
        end

        return Tab
    end
    
    return Window
end

return Library
