--[[
    ╔═══════════════════════════════════════════════╗
    ║          ███╗   ██╗ █████╗ ██████╗            ║
    ║          ████╗  ██║██╔══██╗██╔══██╗           ║
    ║          ██╔██╗ ██║███████║██████╔╝           ║
    ║          ██║╚██╗██║██╔══██║██╔══██╗           ║
    ║          ██║ ╚████║██║  ██║██║  ██║           ║
    ║          ╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝  ╚═╝           ║
    ║                                                ║
    ║          NARAKU HUB - BLOX FRUITS             ║
    ║                Version 2.0                     ║
    ║                                                ║
    ║   Features:                                    ║
    ║   ✓ Infinite Jump  ✓ Speed Hack               ║
    ║   ✓ Hitbox Max     ✓ Auto Farm                ║
    ║   ✓ ESP            ✓ Auto Click               ║
    ║   ✓ Jump Power     ✓ Full Custom UI           ║
    ╚═══════════════════════════════════════════════╝
]]

-- ════════ الخدمات ════════
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- ════════ الإعدادات ════════
local Config = {
    InfiniteJump = false,
    SpeedBoost = false,
    SpeedValue = 100,
    HitboxMax = false,
    HitboxSize = 20,
    AutoFarm = false,
    ESP = false,
    AutoClick = false,
}

-- ════════ حذف النسخ القديمة ════════
if game.CoreGui:FindFirstChild("NarakuHub") then
    game.CoreGui.NarakuHub:Destroy()
end

-- ════════ إعدادات الألوان (Naraku Theme - بنفسجي داكن) ════════
local Theme = {
    Background = Color3.fromRGB(12, 8, 20),
    Secondary = Color3.fromRGB(22, 16, 35),
    Tertiary = Color3.fromRGB(35, 25, 55),
    Accent = Color3.fromRGB(160, 60, 255),
    Accent2 = Color3.fromRGB(255, 60, 180),
    Accent3 = Color3.fromRGB(80, 180, 255),
    Success = Color3.fromRGB(80, 230, 130),
    Danger = Color3.fromRGB(255, 60, 90),
    Text = Color3.fromRGB(240, 235, 255),
    Subtext = Color3.fromRGB(150, 140, 180),
}

-- ════════ إنشاء الواجهة الرئيسية ════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NarakuHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = game.CoreGui

-- ════════ زر الفتح العائم ════════
local OpenButton = Instance.new("TextButton")
OpenButton.Name = "OpenButton"
OpenButton.Size = UDim2.new(0, 60, 0, 60)
OpenButton.Position = UDim2.new(0, 20, 0.5, -30)
OpenButton.BackgroundColor3 = Theme.Accent
OpenButton.Text = "奈"
OpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenButton.TextSize = 26
OpenButton.Font = Enum.Font.GothamBlack
OpenButton.AutoButtonColor = false
OpenButton.Visible = false
OpenButton.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(1, 0)
OpenCorner.Parent = OpenButton

local OpenStroke = Instance.new("UIStroke")
OpenStroke.Color = Color3.fromRGB(255, 255, 255)
OpenStroke.Thickness = 2
OpenStroke.Transparency = 0.3
OpenStroke.Parent = OpenButton

local OpenGradient = Instance.new("UIGradient")
OpenGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.Accent),
    ColorSequenceKeypoint.new(1, Theme.Accent2),
})
OpenGradient.Rotation = 45
OpenGradient.Parent = OpenButton

-- نبض للزر العائم
task.spawn(function()
    while OpenButton.Parent do
        pcall(function()
            TweenService:Create(OpenStroke, TweenInfo.new(1), {Transparency = 0.8}):Play()
            task.wait(1)
            TweenService:Create(OpenStroke, TweenInfo.new(1), {Transparency = 0.3}):Play()
            task.wait(1)
        end)
    end
end)

-- ════════ الإطار الرئيسي ════════
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 0, 0, 0)
Main.Position = UDim2.new(0.5, -280, 0.5, -250)
Main.BackgroundColor3 = Theme.Background
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 16)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Theme.Accent
MainStroke.Thickness = 2
MainStroke.Transparency = 0.2
MainStroke.Parent = Main

local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.Accent),
    ColorSequenceKeypoint.new(0.5, Theme.Accent2),
    ColorSequenceKeypoint.new(1, Theme.Accent3),
})
MainGradient.Rotation = 45
MainGradient.Parent = MainStroke

-- حركة الظهور
Main:TweenSize(UDim2.new(0, 560, 0, 500), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.5, true)

-- ════════ العنوان ════════
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 70)
Header.BackgroundColor3 = Theme.Secondary
Header.BorderSizePixel = 0
Header.Parent = Main

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 16)
HeaderCorner.Parent = Header

local HeaderGradient = Instance.new("UIGradient")
HeaderGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.Accent),
    ColorSequenceKeypoint.new(0.5, Theme.Accent2),
    ColorSequenceKeypoint.new(1, Theme.Accent3),
})
HeaderGradient.Rotation = 45
HeaderGradient.Parent = Header

local HeaderOverlay = Instance.new("Frame")
HeaderOverlay.Size = UDim2.new(1, 0, 1, 0)
HeaderOverlay.BackgroundColor3 = Theme.Background
HeaderOverlay.BackgroundTransparency = 0.35
HeaderOverlay.BorderSizePixel = 0
HeaderOverlay.Parent = Header

local HeaderOverlayCorner = Instance.new("UICorner")
HeaderOverlayCorner.CornerRadius = UDim.new(0, 16)
HeaderOverlayCorner.Parent = HeaderOverlay

-- اسم الهب
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -140, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "奈  NARAKU HUB 奈"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 24
Title.Font = Enum.Font.GothamBlack
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

-- النص الفرعي
local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(0, 200, 0, 20)
Subtitle.Position = UDim2.new(0, 22, 1, -22)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Blox Fruits • v2.0 • Premium"
Subtitle.TextColor3 = Color3.fromRGB(255, 255, 255)
Subtitle.TextTransparency = 0.4
Subtitle.TextSize = 12
Subtitle.Font = Enum.Font.GothamBold
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = Header

-- زر التصغير
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 34, 0, 34)
MinBtn.Position = UDim2.new(1, -88, 0, 18)
MinBtn.BackgroundColor3 = Theme.Tertiary
MinBtn.Text = "—"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = 20
MinBtn.Font = Enum.Font.GothamBold
MinBtn.AutoButtonColor = false
MinBtn.Parent = Header

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 8)
MinCorner.Parent = MinBtn

-- زر الإغلاق
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 34, 0, 34)
CloseBtn.Position = UDim2.new(1, -48, 0, 18)
CloseBtn.BackgroundColor3 = Theme.Danger
CloseBtn.Text = "✖"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

-- ════════ شريط الحالة ════════
local StatusBar = Instance.new("Frame")
StatusBar.Size = UDim2.new(1, -20, 0, 30)
StatusBar.Position = UDim2.new(0, 10, 0, 78)
StatusBar.BackgroundColor3 = Theme.Tertiary
StatusBar.BorderSizePixel = 0
StatusBar.Parent = Main

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 8)
StatusCorner.Parent = StatusBar

local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.new(0, 8, 0, 8)
StatusDot.Position = UDim2.new(0, 12, 0.5, -4)
StatusDot.BackgroundColor3 = Theme.Success
StatusDot.BorderSizePixel = 0
StatusDot.Parent = StatusBar

local StatusDotCorner = Instance.new("UICorner")
StatusDotCorner.CornerRadius = UDim.new(1, 0)
StatusDotCorner.Parent = StatusDot

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, -40, 1, 0)
StatusText.Position = UDim2.new(0, 28, 0, 0)
StatusText.BackgroundTransparency = 1
StatusText.Text = "Naraku Hub Loaded Successfully"
StatusText.TextColor3 = Theme.Text
StatusText.TextSize = 12
StatusText.Font = Enum.Font.GothamBold
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.Parent = StatusBar

-- نبض النقطة
task.spawn(function()
    while StatusDot.Parent do
        pcall(function()
            TweenService:Create(StatusDot, TweenInfo.new(0.8), {BackgroundColor3 = Color3.fromRGB(80, 230, 130)}):Play()
            task.wait(0.8)
            TweenService:Create(StatusDot, TweenInfo.new(0.8), {BackgroundColor3 = Color3.fromRGB(40, 120, 70)}):Play()
            task.wait(0.8)
        end)
    end
end)

-- ════════ المحتوى القابل للتمرير ════════
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -20, 1, -125)
ScrollFrame.Position = UDim2.new(0, 10, 0, 115)
ScrollFrame.BackgroundColor3 = Theme.Secondary
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.ScrollBarImageColor3 = Theme.Accent
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollFrame.Parent = Main

local ScrollCorner = Instance.new("UICorner")
ScrollCorner.CornerRadius = UDim.new(0, 12)
ScrollCorner.Parent = ScrollFrame

local ScrollPadding = Instance.new("UIPadding")
ScrollPadding.PaddingTop = UDim.new(0, 10)
ScrollPadding.PaddingLeft = UDim.new(0, 10)
ScrollPadding.PaddingRight = UDim.new(0, 10)
ScrollPadding.PaddingBottom = UDim.new(0, 10)
ScrollPadding.Parent = ScrollFrame

local ScrollLayout = Instance.new("UIListLayout")
ScrollLayout.Padding = UDim.new(0, 8)
ScrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
ScrollLayout.Parent = ScrollFrame

-- ════════ دوال مساعدة ════════

-- دالة إنشاء عنوان قسم
local function CreateSection(text)
    local Section = Instance.new("Frame")
    Section.Size = UDim2.new(1, 0, 0, 35)
    Section.BackgroundColor3 = Theme.Background
    Section.BackgroundTransparency = 0.5
    Section.BorderSizePixel = 0
    Section.Parent = ScrollFrame
    
    local SectionCorner = Instance.new("UICorner")
    SectionCorner.CornerRadius = UDim.new(0, 8)
    SectionCorner.Parent = Section
    
    local Line = Instance.new("Frame")
    Line.Size = UDim2.new(0, 4, 0, 20)
    Line.Position = UDim2.new(0, 10, 0.5, -10)
    Line.BackgroundColor3 = Theme.Accent
    Line.BorderSizePixel = 0
    Line.Parent = Section
    
    local LineCorner = Instance.new("UICorner")
    LineCorner.CornerRadius = UDim.new(1, 0)
    LineCorner.Parent = Line
    
    local SectionLabel = Instance.new("TextLabel")
    SectionLabel.Size = UDim2.new(1, -30, 1, 0)
    SectionLabel.Position = UDim2.new(0, 22, 0, 0)
    SectionLabel.BackgroundTransparency = 1
    SectionLabel.Text = text
    SectionLabel.TextColor3 = Theme.Text
    SectionLabel.TextSize = 14
    SectionLabel.Font = Enum.Font.GothamBlack
    SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
    SectionLabel.Parent = Section
    
    return Section
end

-- دالة إنشاء زر تبديل
local function CreateToggle(name, icon, default, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 50)
    Btn.BackgroundColor3 = Theme.Tertiary
    Btn.Text = ""
    Btn.AutoButtonColor = false
    Btn.Parent = ScrollFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 10)
    BtnCorner.Parent = Btn
    
    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Color = Color3.fromRGB(60, 50, 90)
    BtnStroke.Thickness = 1
    BtnStroke.Parent = Btn
    
    local IconLabel = Instance.new("TextLabel")
    IconLabel.Size = UDim2.new(0, 45, 1, 0)
    IconLabel.Position = UDim2.new(0, 5, 0, 0)
    IconLabel.BackgroundTransparency = 1
    IconLabel.Text = icon
    IconLabel.TextSize = 24
    IconLabel.Font = Enum.Font.GothamBold
    IconLabel.Parent = Btn
    
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(1, -125, 1, 0)
    NameLabel.Position = UDim2.new(0, 50, 0, 0)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = name
    NameLabel.TextColor3 = Theme.Text
    NameLabel.TextSize = 15
    NameLabel.Font = Enum.Font.GothamBold
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.Parent = Btn
    
    -- مفتاح التبديل
    local Switch = Instance.new("Frame")
    Switch.Size = UDim2.new(0, 52, 0, 28)
    Switch.Position = UDim2.new(1, -62, 0.5, -14)
    Switch.BackgroundColor3 = Color3.fromRGB(50, 45, 70)
    Switch.BorderSizePixel = 0
    Switch.Parent = Btn
    
    local SwitchCorner = Instance.new("UICorner")
    SwitchCorner.CornerRadius = UDim.new(1, 0)
    SwitchCorner.Parent = Switch
    
    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 22, 0, 22)
    Knob.Position = UDim2.new(0, 3, 0.5, -11)
    Knob.BackgroundColor3 = Color3.fromRGB(220, 215, 240)
    Knob.BorderSizePixel = 0
    Knob.Parent = Switch
    
    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = Knob
    
    local state = default or false
    
    local function updateVisual()
        if state then
            TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent}):Play()
            TweenService:Create(Knob, TweenInfo.new(0.2), {
                Position = UDim2.new(1, -25, 0.5, -11),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
            TweenService:Create(BtnStroke, TweenInfo.new(0.2), {Color = Theme.Accent}):Play()
        else
            TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 45, 70)}):Play()
            TweenService:Create(Knob, TweenInfo.new(0.2), {
                Position = UDim2.new(0, 3, 0.5, -11),
                BackgroundColor3 = Color3.fromRGB(220, 215, 240)
            }):Play()
            TweenService:Create(BtnStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(60, 50, 90)}):Play()
        end
    end
    
    updateVisual()
    
    Btn.MouseButton1Click:Connect(function()
        state = not state
        updateVisual()
        if callback then
            pcall(callback, state)
        end
    end)
    
    return Btn
end

-- دالة إنشاء شريط تمرير
local function CreateSlider(name, min, max, default, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 65)
    Container.BackgroundColor3 = Theme.Tertiary
    Container.BorderSizePixel = 0
    Container.Parent = ScrollFrame
    
    local ContainerCorner = Instance.new("UICorner")
    ContainerCorner.CornerRadius = UDim.new(0, 10)
    ContainerCorner.Parent = Container
    
    local ContainerStroke = Instance.new("UIStroke")
    ContainerStroke.Color = Color3.fromRGB(60, 50, 90)
    ContainerStroke.Thickness = 1
    ContainerStroke.Parent = Container
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 0, 25)
    Label.Position = UDim2.new(0, 10, 0, 5)
    Label.BackgroundTransparency = 1
    Label.Text = name .. ": " .. default
    Label.TextColor3 = Theme.Text
    Label.TextSize = 14
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container
    
    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, -20, 0, 10)
    Bar.Position = UDim2.new(0, 10, 1, -22)
    Bar.BackgroundColor3 = Color3.fromRGB(40, 35, 60)
    Bar.BorderSizePixel = 0
    Bar.Parent = Container
    
    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(1, 0)
    BarCorner.Parent = Bar
    
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Theme.Accent
    Fill.BorderSizePixel = 0
    Fill.Parent = Bar
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = Fill
    
    local FillGradient = Instance.new("UIGradient")
    FillGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.Accent),
        ColorSequenceKeypoint.new(1, Theme.Accent2),
    })
    FillGradient.Parent = Fill
    
    local value = default
    local dragging = false
    
    local function update(input)
        local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
        value = math.floor(min + (max - min) * pos)
        Fill.Size = UDim2.new(pos, 0, 1, 0)
        Label.Text = name .. ": " .. value
        if callback then
            pcall(callback, value)
        end
    end
    
    Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input)
        end
    end)
    
    Bar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
end

-- دالة إنشاء زر عادي
local function CreateButton(name, icon, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 45)
    Btn.BackgroundColor3 = Theme.Accent
    Btn.Text = ""
    Btn.AutoButtonColor = false
    Btn.Parent = ScrollFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 10)
    BtnCorner.Parent = Btn
    
    local BtnGradient = Instance.new("UIGradient")
    BtnGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.Accent),
        ColorSequenceKeypoint.new(1, Theme.Accent2),
    })
    BtnGradient.Rotation = 45
    BtnGradient.Parent = Btn
    
    local IconLabel = Instance.new("TextLabel")
    IconLabel.Size = UDim2.new(0, 45, 1, 0)
    IconLabel.Position = UDim2.new(0, 5, 0, 0)
    IconLabel.BackgroundTransparency = 1
    IconLabel.Text = icon
    IconLabel.TextSize = 22
    IconLabel.Font = Enum.Font.GothamBold
    IconLabel.Parent = Btn
    
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(1, -55, 1, 0)
    NameLabel.Position = UDim2.new(0, 50, 0, 0)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = name
    NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameLabel.TextSize = 15
    NameLabel.Font = Enum.Font.GothamBold
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.Parent = Btn
    
    Btn.MouseButton1Click:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Accent3}):Play()
        task.wait(0.1)
        TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Accent}):Play()
        if callback then
            pcall(callback)
        end
    end)
    
    return Btn
end

-- ════════ الميزات الفعلية ════════

-- قسم القتال
CreateSection("⚔️  COMBAT")

-- الميزة 1: القفز اللانهائي
CreateToggle("Infinite Jump", "🦘", false, function(state)
    Config.InfiniteJump = state
end)

UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

-- الميزة 2: توسيع الهيتبوكس
CreateToggle("Hitbox Max", "🎯", false, function(state)
    Config.HitboxMax = state
    local char = LocalPlayer.Character
    if not char then return end
    
    if state then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Size = Vector3.new(Config.HitboxSize, Config.HitboxSize, Config.HitboxSize)
                part.Transparency = 0.6
                part.CanCollide = false
                part.Massless = true
            end
        end
    else
        char:BreakJoints()
    end
end)

-- الميزة 3: Auto Farm
CreateToggle("Auto Farm", "⚔️", false, function(state)
    Config.AutoFarm = state
end)

task.spawn(function()
    while task.wait(0.3) do
        if Config.AutoFarm then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local closest = nil
                local dist = math.huge
                for _, mob in pairs(Workspace:GetChildren()) do
                    pcall(function()
                        if mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") then
                            if mob.Name ~= LocalPlayer.Name then
                                local d = (mob.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
                                if d < dist and d < 500 then
                                    dist = d
                                    closest = mob
                                end
                            end
                        end
                    end)
                end
                if closest then
                    local target = closest.HumanoidRootPart
                    char.HumanoidRootPart.CFrame = target.CFrame * CFrame.new(0, 0, 3)
                end
            end
        end
    end
end)

-- الميزة 4: Auto Click
CreateToggle("Auto Click", "🖱️", false, function(state)
    Config.AutoClick = state
end)

task.spawn(function()
    while task.wait(0.05) do
        if Config.AutoClick then
            pcall(function()
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            end)
        end
    end
end)

-- قسم الرؤية
CreateSection("👁️  VISUAL")

local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "NarakuESP"
ESPFolder.Parent = ScreenGui

local function createESP(plr)
    if plr == LocalPlayer then return end
    if ESPFolder:FindFirstChild(plr.Name) then return end
    
    local char = plr.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local box = Instance.new("BoxHandleAdornment")
    box.Name = plr.Name
    box.Adornee = hrp
    box.AlwaysOnTop = true
    box.ZIndex = 5
    box.Size = Vector3.new(4, 6, 4)
    box.Transparency = 0.5
    box.Color3 = Theme.Accent2
    box.Parent = ESPFolder
end

CreateToggle("ESP Players", "👁️", false, function(state)
    Config.ESP = state
    if state then
        for _, plr in pairs(Players:GetPlayers()) do
            createESP(plr)
        end
    else
        ESPFolder:ClearAllChildren()
    end
end)

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        task.wait(1)
        if Config.ESP then
            createESP(plr)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(plr)
    local esp = ESPFolder:FindFirstChild(plr.Name)
    if esp then esp:Destroy() end
end)

-- قسم الحركة
CreateSection("💨  MOVEMENT")

-- الميزة 5: السرعة
CreateToggle("Speed Boost", "💨", false, function(state)
    Config.SpeedBoost = state
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = state and Config.SpeedValue or 16
        end
    end
end)

CreateSlider("Speed Value", 16, 500, 100, function(val)
    Config.SpeedValue = val
    if Config.SpeedBoost then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = val
            end
        end
    end
end)

-- الميزة 6: Jump Power
CreateSlider("Jump Power", 50, 500, 50, function(val)
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.JumpPower = val
            hum.UseJumpPower = true
        end
    end
end)

-- قسم الأدوات
CreateSection("🛠️  UTILITIES")

-- زر إعادة تعيين
CreateButton("Reset Character", "🔄", function()
    local char = LocalPlayer.Character
    if char then
        char:BreakJoints()
    end
end)

-- زر نسخ Discord
CreateButton("Join Naraku Discord", "💬", function()
    pcall(function()
        if setclipboard then
            setclipboard("https://discord.gg/naraku")
        end
    end)
end)

-- ════════ إعادة التعيين عند الموت ════════
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = Config.SpeedBoost and Config.SpeedValue or 16
    end
end)

-- ════════ أزرار التحكم ════════

-- إغلاق
CloseBtn.MouseButton1Click:Connect(function()
    Main:TweenSize(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Back, 0.3, true)
    task.wait(0.3)
    Main.Visible = false
    OpenButton.Visible = true
end)

-- تصغير
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        Main:TweenSize(UDim2.new(0, 560, 0, 70), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
    else
        Main:TweenSize(UDim2.new(0, 560, 0, 500), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
    end
end)

-- فتح من الزر العائم
OpenButton.MouseButton1Click:Connect(function()
    OpenButton.Visible = false
    Main.Visible = true
    Main.Size = UDim2.new(0, 0, 0, 0)
    Main:TweenSize(UDim2.new(0, 560, 0, 500), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.5, true)
end)

-- ════════ اختصار لوحة المفاتيح ════════
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        if Main.Visible then
            Main.Visible = false
            OpenButton.Visible = true
        else
            Main.Visible = true
            OpenButton.Visible = false
        end
    end
end)

-- ════════ إشعار الترحيب ════════
local Notify = Instance.new("Frame")
Notify.Size = UDim2.new(0, 340, 0, 80)
Notify.Position = UDim2.new(0.5, -170, 0, -120)
Notify.BackgroundColor3 = Theme.Secondary
Notify.BorderSizePixel = 0
Notify.Parent = ScreenGui

local NotifyCorner = Instance.new("UICorner")
NotifyCorner.CornerRadius = UDim.new(0, 14)
NotifyCorner.Parent = Notify

local NotifyStroke = Instance.new("UIStroke")
NotifyStroke.Color = Theme.Accent
NotifyStroke.Thickness = 2
NotifyStroke.Parent = Notify

local NotifyGradient = Instance.new("UIGradient")
NotifyGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.Accent),
    ColorSequenceKeypoint.new(0.5, Theme.Accent2),
    ColorSequenceKeypoint.new(1, Theme.Accent3),
})
NotifyGradient.Rotation = 45
NotifyGradient.Parent = NotifyStroke

-- أيقونة
local NotifyIcon = Instance.new("TextLabel")
NotifyIcon.Size = UDim2.new(0, 60, 1, 0)
NotifyIcon.Position = UDim2.new(0, 0, 0, 0)
NotifyIcon.BackgroundTransparency = 1
NotifyIcon.Text = "奈"
NotifyIcon.TextColor3 = Theme.Accent
NotifyIcon.TextSize = 32
NotifyIcon.Font = Enum.Font.GothamBlack
NotifyIcon.Parent = Notify

local NotifyTitle = Instance.new("TextLabel")
NotifyTitle.Size = UDim2.new(1, -70, 0, 30)
NotifyTitle.Position = UDim2.new(0, 65, 0, 10)
NotifyTitle.BackgroundTransparency = 1
NotifyTitle.Text = "NARAKU HUB LOADED"
NotifyTitle.TextColor3 = Theme.Text
NotifyTitle.TextSize = 16
NotifyTitle.Font = Enum.Font.GothamBlack
NotifyTitle.TextXAlignment = Enum.TextXAlignment.Left
NotifyTitle.Parent = Notify

local NotifyMsg = Instance.new("TextLabel")
NotifyMsg.Size = UDim2.new(1, -70, 0, 25)
NotifyMsg.Position = UDim2.new(0, 65, 0, 38)
NotifyMsg.BackgroundTransparency = 1
NotifyMsg.Text = "Press RightShift to toggle UI"
NotifyMsg.TextColor3 = Theme.Subtext
NotifyMsg.TextSize = 12
NotifyMsg.Font = Enum.Font.Gotham
NotifyMsg.TextXAlignment = Enum.TextXAlignment.Left
NotifyMsg.Parent = Notify

TweenService:Create(Notify, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Position = UDim2.new(0.5, -170, 0, 20)}):Play()
task.wait(3.5)
TweenService:Create(Notify, TweenInfo.new(0.5), {Position = UDim2.new(0.5, -170, 0, -120)}):Play()
task.wait(0.5)
Notify:Destroy()

-- ════════ رسالة الكونسول ════════
print("╔════════════════════════════════════════╗")
print("║                                        ║")
print("║        NARAKU HUB v2.0 LOADED         ║")
print("║         Blox Fruits Edition            ║")
print("║                                        ║")
print("║  ✓ Infinite Jump    ✓ Speed Hack      ║")
print("║  ✓ Hitbox Max       ✓ Auto Farm       ║")
print("║  ✓ ESP Players      ✓ Auto Click      ║")
print("║                                        ║")
print("║  📌 Press RightShift to toggle UI     ║")
print("║                                        ║")
print("╚════════════════════════════════════════╝")
