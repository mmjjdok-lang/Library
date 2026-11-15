--[=[
    Project: Custom Desktop-Style UI Library for Luau / Delta
    Dimensions: 586x339 (Scalable/Container base)
    Theme: Deep Black, Sharp yet Smooth Edges, Blue Accents
]=]

local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

-- تحميل مكتبة الأيقونات الخارجية المطلوبة
local IconsLoaded, Icons = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/Icons/main/Main-v2.lua"))()
end)
if not IconsLoaded or not Icons then
    Icons = {}
end

local Library = {}
Library.Flags = {}

-- دالة مساعدة لإنشاء عناصر UI سريعة
local function Create(className, properties)
    local obj = Instance.new(className)
    for k, v in pairs(properties) do
        obj[k] = v
    end
    return obj
end

function Library:CreateWindow(config)
    config = config or {}
    local windowTitle = config.Title or "Voxeno Hub"
    local windowDesc = config.Description or "Advanced Script Utility"
    
    -- الحماية من التكرار القديم
    if CoreGui:FindFirstChild("CustomLibraryUI") then
        CoreGui.CustomLibraryUI:Destroy()
    end

    local ScreenGui = Create("ScreenGui", {
        Name = "CustomLibraryUI",
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })

    -- ==================== زر الحجب الخارجي (Open Button) ====================
    local OpenButton = Create("TextButton", {
        Name = "OpenButton",
        Parent = ScreenGui,
        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        BorderColor3 = Color3.fromRGB(40, 40, 40),
        BorderSizePixel = 1,
        Position = UDim2.new(0, 20, 0, 100),
        Size = UDim2.new(0, 50, 0, 50), -- حجم مقارب لزر دلتا
        AutoButtonColor = false,
        Font = Enum.Font.GothamBold,
        Text = "Open",
        TextColor3 = Color3.fromRGB(0, 122, 255),
        TextSize = 13,
        ZIndex = 999
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = OpenButton })
    Create("UIStroke", { Color = Color3.fromRGB(0, 122, 255), Thickness = 1, Parent = OpenButton })

    -- سحب زر Open بلمسة واحدة
    local draggingOpen, dragInputOpen, dragStartOpen, startPosOpen
    OpenButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingOpen = true
            dragStartOpen = input.Position
            startPosOpen = OpenButton.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    draggingOpen = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if draggingOpen and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStartOpen
            OpenButton.Position = UDim2.new(startPosOpen.X.Scale, startPosOpen.X.Offset + delta.X, startPosOpen.Y.Scale, startPosOpen.Y.Offset + delta.Y)
        end
    end)

    -- ==================== النافذة الرئيسية (586x339) ====================
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        BackgroundColor3 = Color3.fromRGB(12, 12, 12),
        BorderColor3 = Color3.fromRGB(30, 30, 30),
        BorderSizePixel = 1,
        Position = UDim2.new(0.5, -293, 0.5, -169),
        Size = UDim2.new(0, 586, 0, 339),
        Visible = true,
        ZIndex = 10
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = MainFrame })
    Create("UIStroke", { Color = Color3.fromRGB(45, 45, 45), Thickness = 1, Parent = MainFrame })

    -- زر Open يفتح ويغلق الوافذة
    OpenButton.MouseButton1Click:Connect(function()
        MainFrame.Visible = not MainFrame.Visible
    end)

    -- ==================== نظام السحب بلمسة واحدة (Single-Finger Isolation) ====================
    local dragging, dragInput, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            -- عزل اللمس: تأكد أن الإصبع الأول هو الذي يحرك النافذة فقط ولا يتأثر بتعدد اللمسات
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            -- سحب ثقيل نسبياً عبر تدرج الحركة
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- ==================== الشريط العلوي (Title & Config Menu) ====================
    local TopBar = Create("Frame", {
        Name = "TopBar",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 40),
        ZIndex = 11
    })

    local TitleLabel = Create("TextLabel", {
        Parent = TopBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 5),
        Size = UDim2.new(0, 300, 0, 18),
        Font = Enum.Font.GothamBold,
        Text = windowTitle,
        TextColor3 = Color3.fromRGB(240, 240, 240),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local DescLabel = Create("TextLabel", {
        Parent = TopBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 23),
        Size = UDim2.new(0, 300, 0, 12),
        Font = Enum.Font.Gotham,
        Text = windowDesc,
        TextColor3 = Color3.fromRGB(140, 140, 140),
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- ==================== قائمة الحفظ المنسدلة العلوية (Config Folders Dropdown) ====================
    local ConfigDropdownBtn = Create("TextButton", {
        Parent = TopBar,
        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        Position = UDim2.new(1, -150, 0, 8),
        Size = UDim2.new(0, 135, 0, 24),
        AutoButtonColor = false,
        Font = Enum.Font.Gotham,
        Text = "إعدادات الحفظ ▾",
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextSize = 11,
        ZIndex = 15
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = ConfigDropdownBtn })
    Create("UIStroke", { Color = Color3.fromRGB(50, 50, 50), Thickness = 1, Parent = ConfigDropdownBtn })

    local ConfigListFrame = Create("ScrollingFrame", {
        Parent = TopBar,
        BackgroundColor3 = Color3.fromRGB(15, 15, 15),
        BorderColor3 = Color3.fromRGB(40, 40, 40),
        Position = UDim2.new(1, -150, 0, 34),
        Size = UDim2.new(0, 135, 0, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Visible = false,
        ZIndex = 20
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = ConfigListFrame })
    Create("UIListLayout", { Parent = ConfigListFrame, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2) })

    local folders = {"Default_Folder", "Slot_A", "Slot_B", "Custom_Setup"}
    local configDropdownOpen = false

    ConfigDropdownBtn.MouseButton1Click:Connect(function()
        configDropdownOpen = not configDropdownOpen
        local targetSize = configDropdownOpen and UDim2.new(0, 135, 0, (#folders * 24) + 26) or UDim2.new(0, 135, 0, 0)
        ConfigListFrame.Visible = true
        TweenService:Create(ConfigListFrame, TweenInfo.new(0.2), {Size = targetSize}):Play()
        if not configDropdownOpen then
            task.delay(0.2, function()
                if not configDropdownOpen then ConfigListFrame.Visible = false end
            end)
        end
    end)

    -- زر إنشاء مجلد جديد ضمن القائمة العلوية
    local CreateFolderBtn = Create("TextButton", {
        Parent = ConfigListFrame,
        BackgroundColor3 = Color3.fromRGB(0, 122, 255),
        Size = UDim2.new(1, 0, 0, 22),
        Font = Enum.Font.GothamBold,
        Text = "+ إنشاء مجلد جديد",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 10,
        ZIndex = 21
    })

    CreateFolderBtn.MouseButton1Click:Connect(function()
        local newName = "Folder_" .. (#folders + 1)
        table.insert(folders, newName)
        
        local folderBtn = Create("TextButton", {
            Parent = ConfigListFrame,
            BackgroundColor3 = Color3.fromRGB(22, 22, 22),
            Size = UDim2.new(1, 0, 0, 22),
            Font = Enum.Font.Gotham,
            Text = newName,
            TextColor3 = Color3.fromRGB(180, 180, 180),
            TextSize = 10,
            ZIndex = 21
        })
        folderBtn.MouseButton1Click:Connect(function()
            ConfigDropdownBtn.Text = newName .. " ▾"
            -- هنا يتم استرجاع الإعدادات المحفوظة للمجلد
        end)
        ConfigListFrame.CanvasSize = UDim2.new(0, 0, 0, (#folders * 24) + 26)
        ConfigListFrame.Size = UDim2.new(0, 135, 0, (#folders * 24) + 26)
    end)

    for _, foldName in ipairs(folders) do
        local fBtn = Create("TextButton", {
            Parent = ConfigListFrame,
            BackgroundColor3 = Color3.fromRGB(22, 22, 22),
            Size = UDim2.new(1, 0, 0, 22),
            Font = Enum.Font.Gotham,
            Text = foldName,
            TextColor3 = Color3.fromRGB(180, 180, 180),
            TextSize = 10,
            ZIndex = 21
        })
        fBtn.MouseButton1Click:Connect(function()
            ConfigDropdownBtn.Text = foldName .. " ▾"
            configDropdownOpen = false
            TweenService:Create(ConfigListFrame, TweenInfo.new(0.2), {Size = UDim2.new(0, 135, 0, 0)}):Play()
            task.delay(0.2, function() ConfigListFrame.Visible = false end)
        end)
    end

    -- فاصل تحت الشريط العلوي
    Create("Frame", {
        Parent = MainFrame,
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 42),
        Size = UDim2.new(1, 0, 0, 1),
        ZIndex = 11
    })

    -- ==================== نظام التبويبات (Tabs System) ====================
    local TabContainer = Create("ScrollingFrame", {
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 50),
        Size = UDim2.new(0, 130, 0, 275),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 2,
        ZIndex = 12
    })
    Create("UIListLayout", { Parent = TabContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5) })

    local PagesContainer = Create("Frame", {
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 150, 0, 50),
        Size = UDim2.new(0, 426, 0, 275),
        ZIndex = 12
    })

    local TabsList = {}
    local firstTab = true

    local WindowLib = {}

    function WindowLib:CreateTab(tabName, iconName)
        local TabPage = Create("ScrollingFrame", {
            Parent = PagesContainer,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 3,
            Visible = false,
            ZIndex = 13
        })
        Create("UIListLayout", { Parent = TabPage, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6) })

        local TabBtn = Create("TextButton", {
            Parent = TabContainer,
            BackgroundColor3 = Color3.fromRGB(18, 18, 18),
            Size = UDim2.new(1, 0, 0, 32),
            AutoButtonColor = false,
            Font = Enum.Font.Gotham,
            Text = "   " .. tabName,
            TextColor3 = Color3.fromRGB(150, 150, 150),
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 13
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = TabBtn })

        -- جلب الأيقونة المتاحة من مكتبة GitHub الرابط
        if iconName and Icons[iconName] then
            local IconImage = Create("ImageLabel", {
                Parent = TabBtn,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 8, 0.5, -8),
                Size = UDim2.new(0, 16, 0, 16),
                Image = Icons[iconName],
                ImageColor3 = Color3.fromRGB(150, 150, 150),
                ZIndex = 14
            })
            TabBtn.Text = "        " .. tabName
        end

        if firstTab then
            firstTab = false
            TabPage.Visible = true
            TabBtn.BackgroundColor3 = Color3.fromRGB(0, 122, 255)
            TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end

        TabBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(TabsList) do
                t.Page.Visible = false
                TweenService:Create(t.Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(18, 18, 18)}):Play()
                t.Button.TextColor3 = Color3.fromRGB(150, 150, 150)
            end
            TabPage.Visible = true
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 122, 255)}):Play()
            TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end)

        table.insert(TabsList, {Button = TabBtn, Page = TabPage})

        local SectionLib = {}

        -- ==================== نظام Label ====================
        function SectionLib:AddLabel(text)
            local LabelFrame = Create("Frame", {
                Parent = TabPage,
                BackgroundColor3 = Color3.fromRGB(16, 16, 16),
                Size = UDim2.new(1, -5, 0, 26),
                ZIndex = 14
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = LabelFrame })
            
            local LText = Create("TextLabel", {
                Parent = LabelFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -20, 1, 0),
                Font = Enum.Font.GothamMedium,
                Text = text,
                TextColor3 = Color3.fromRGB(200, 200, 200),
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 15
            })
            TabPage.CanvasSize = UDim2.new(0, 0, 0, TabPage.UIListLayout.AbsoluteContentSize.Y + 30)
        end

        -- ==================== نظام Toggle ====================
        function SectionLib:AddToggle(configToggle)
            configToggle = configToggle or {}
            local tName = configToggle.Name or "Toggle"
            local tDesc = configToggle.Description or "Description"
            local tCallback = configToggle.Callback or function() end

            local ToggleFrame = Create("Frame", {
                Parent = TabPage,
                BackgroundColor3 = Color3.fromRGB(16, 16, 16),
                Size = UDim2.new(1, -5, 0, 38),
                ZIndex = 14
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = ToggleFrame })

            Create("TextLabel", {
                Parent = ToggleFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 4),
                Size = UDim2.new(0, 300, 0, 16),
                Font = Enum.Font.GothamBold,
                Text = tName,
                TextColor3 = Color3.fromRGB(230, 230, 230),
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 15
            })

            Create("TextLabel", {
                Parent = ToggleFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 20),
                Size = UDim2.new(0, 300, 0, 12),
                Font = Enum.Font.Gotham,
                Text = tDesc,
                TextColor3 = Color3.fromRGB(130, 130, 130),
                TextSize = 10,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 15
            })

            -- السويتش باللون الأزرق
            local SwitchBg = Create("Frame", {
                Parent = ToggleFrame,
                BackgroundColor3 = Color3.fromRGB(30, 30, 30),
                Position = UDim2.new(1, -45, 0.5, -10),
                Size = UDim2.new(0, 36, 0, 20),
                ZIndex = 15
            })
            Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = SwitchBg })

            local SwitchCircle = Create("Frame", {
                Parent = SwitchBg,
                BackgroundColor3 = Color3.fromRGB(200, 200, 200),
                Position = UDim2.new(0, 2, 0.5, -8),
                Size = UDim2.new(0, 16, 0, 16),
                ZIndex = 16
            })
            Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = SwitchCircle })

            local toggled = false
            local ToggleBtn = Create("TextButton", {
                Parent = ToggleFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = "",
                ZIndex = 17
            })

            ToggleBtn.MouseButton1Click:Connect(function()
                toggled = not toggled
                local targetPos = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                local targetColor = toggled and Color3.fromRGB(0, 122, 255) or Color3.fromRGB(30, 30, 30)
                
                TweenService:Create(SwitchCircle, TweenInfo.new(0.2), {Position = targetPos}):Play()
                TweenService:Create(SwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
                
                pcall(tCallback, toggled)
            end)

            TabPage.CanvasSize = UDim2.new(0, 0, 0, TabPage.UIListLayout.AbsoluteContentSize.Y + 30)
        end

        -- ==================== نظام Button ====================
        function SectionLib:AddButton(configBtn)
            configBtn = configBtn or {}
            local bName = configBtn.Name or "Button"
            local bDesc = configBtn.Description or "Description"
            local bCallback = configBtn.Callback or function() end

            local ButtonFrame = Create("TextButton", {
                Parent = TabPage,
                BackgroundColor3 = Color3.fromRGB(16, 16, 16),
                Size = UDim2.new(1, -5, 0, 38),
                AutoButtonColor = false,
                Text = "",
                ZIndex = 14
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = ButtonFrame })

            Create("TextLabel", {
                Parent = ButtonFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 4),
                Size = UDim2.new(0, 300, 0, 16),
                Font = Enum.Font.GothamBold,
                Text = bName,
                TextColor3 = Color3.fromRGB(230, 230, 230),
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 15
            })

            Create("TextLabel", {
                Parent = ButtonFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 20),
                Size = UDim2.new(0, 300, 0, 12),
                Font = Enum.Font.Gotham,
                Text = bDesc,
                TextColor3 = Color3.fromRGB(130, 130, 130),
                TextSize = 10,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 15
            })

            ButtonFrame.MouseButton1Click:Connect(function()
                pcall(bCallback)
            end)

            TabPage.CanvasSize = UDim2.new(0, 0, 0, TabPage.UIListLayout.AbsoluteContentSize.Y + 30)
        end

        -- ==================== نظام القائمة المنسدلة (Dropdown with Sub-Window Animation) ====================
        function SectionLib:AddDropdown(configDrop)
            configDrop = configDrop or {}
            local dName = configDrop.Name or "Dropdown"
            local options = configDrop.Options or {"Option 1", "Option 2"}
            local dCallback = configDrop.Callback or function() end

            local DropMain = Create("Frame", {
                Parent = TabPage,
                BackgroundColor3 = Color3.fromRGB(16, 16, 16),
                Size = UDim2.new(1, -5, 0, 34),
                ZIndex = 14
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = DropMain })

            local DropTitle = Create("TextLabel", {
                Parent = DropMain,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(0, 200, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = dName,
                TextColor3 = Color3.fromRGB(210, 210, 210),
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 15
            })

            local DropBtn = Create("TextButton", {
                Parent = DropMain,
                BackgroundColor3 = Color3.fromRGB(24, 24, 24),
                Position = UDim2.new(1, -120, 0.5, -12),
                Size = UDim2.new(0, 110, 0, 24),
                Font = Enum.Font.Gotham,
                Text = "اختر ▾",
                TextColor3 = Color3.fromRGB(180, 180, 180),
                TextSize = 10,
                ZIndex = 15
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = DropBtn })

            -- واجهة فرعية متحركة تظهر عند الضغط فوق زر القائمة المنسدلة
            local SubWindow = Create("Frame", {
                Parent = ScreenGui,
                BackgroundColor3 = Color3.fromRGB(18, 18, 18),
                BorderColor3 = Color3.fromRGB(0, 122, 255),
                BorderSizePixel = 1,
                Size = UDim2.new(0, 150, 0, 0), -- تبدأ بحجم 0 للأنيميشن
                Visible = false,
                ZIndex = 100
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = SubWindow })
            local SubList = Create("UIListLayout", { Parent = SubWindow, SortOrder = Enum.SortOrder.LayoutOrder })

            local isOpen = false
            DropBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                
                -- حساب موقع الزر لتظهر الواجهة الفرعية بدقة فوقه أو بجانبه
                local absPos = DropBtn.AbsolutePosition
                SubWindow.Position = UDim2.new(0, absPos.X - 40, 0, absPos.Y - (#options * 26) - 5)
                
                if isOpen then
                    SubWindow.Visible = true
                    TweenService:Create(SubWindow, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Size = UDim2.new(0, 150, 0, (#options * 26) + 6)
                    }):Play()
                else
                    TweenService:Create(SubWindow, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                        Size = UDim2.new(0, 150, 0, 0)
                    }):Play()
                    task.delay(0.2, function()
                        if not isOpen then SubWindow.Visible = false end
                    end)
                end
            end)

            for _, opt in ipairs(options) do
                local optBtn = Create("TextButton", {
                    Parent = SubWindow,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 26),
                    Font = Enum.Font.Gotham,
                    Text = opt,
                    TextColor3 = Color3.fromRGB(200, 200, 200),
                    TextSize = 11,
                    ZIndex = 101
                })
                optBtn.MouseButton1Click:Connect(function()
                    DropBtn.Text = opt .. " ▾"
                    isOpen = false
                    TweenService:Create(SubWindow, TweenInfo.new(0.2), {Size = UDim2.new(0, 150, 0, 0)}):Play()
                    task.delay(0.2, function() SubWindow.Visible = false end)
                    pcall(dCallback, opt)
                end)
            end

            TabPage.CanvasSize = UDim2.new(0, 0, 0, TabPage.UIListLayout.AbsoluteContentSize.Y + 30)
        end

        return SectionLib
    end

    -- ==================== نظام الإشعارات (Notify System) ====================
    function Library:Notify(configNotify)
        configNotify = configNotify or {}
        local nTitle = configNotify.Title or "إشعار"
        local nContent = configNotify.Content or "رسالة الشعار"
        local nDuration = configNotify.Duration or 3

        local NotifCard = Create("Frame", {
            Name = "NotificationCard",
            Parent = ScreenGui,
            BackgroundColor3 = Color3.fromRGB(15, 15, 15),
            BorderColor3 = Color3.fromRGB(0, 122, 255),
            BorderSizePixel = 1,
            Position = UDim2.new(1, -210, 1, 20), -- تبدأ من الأسفل يمين خارج الشاشة
            Size = UDim2.new(0, 200, 0, 55),
            ZIndex = 200
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = NotifCard })

        Create("TextLabel", {
            Parent = NotifCard,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 6),
            Size = UDim2.new(1, -15, 0, 16),
            Font = Enum.Font.GothamBold,
            Text = nTitle,
            TextColor3 = Color3.fromRGB(0, 122, 255),
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 201
        })

        Create("TextLabel", {
            Parent = NotifCard,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 24),
            Size = UDim2.new(1, -15, 0, 22),
            Font = Enum.Font.Gotham,
            Text = nContent,
            TextColor3 = Color3.fromRGB(200, 200, 200),
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            ZIndex = 201
        })

        -- انيميشن الدخول (أسفل اليمين)
        TweenService:Create(NotifCard, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(1, -210, 1, -70)
        }):Play()

        task.delay(nDuration, function()
            local tweenOut = TweenService:Create(NotifCard, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.new(1, -210, 1, 20)
            })
            tweenOut:Play()
            tweenOut.Completed:Connect(function()
                NotifCard:Destroy()
            end)
        end)
    end

    return WindowLib
end

return Library
