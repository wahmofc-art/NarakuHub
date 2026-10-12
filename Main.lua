--[[
    ╔═══════════════════════════════════════════════╗
    ║          ███╗   ██╗ █████╗ ██████╗            ║
    ║          ████╗  ██║██╔══██╗██╔══██╗           ║
    ║          ██╔██╗ ██║███████║██████╔╝           ║
    ║          ██║╚██╗██║██╔══██║██╔══██╗           ║
    ║          ██║ ╚████║██║  ██║██║  ██║           ║
    ║          ╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝  ╚═╝           ║
    ║                                                ║
    ║       NARAKU HUB - MEGA v4.0                  ║
    ║                                                ║
    ║   ⚔️ Combat  |  💨 Movement  |  👁️ Visual     ║
    ║   🎣 Farm    |  🗺️ Teleport  |  🎁 Fruit      ║
    ╚═══════════════════════════════════════════════╝
]]

-- ════════ الخدمات ════════
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

-- ════════ الإعدادات ════════
local Config = {
    -- Movement
    SpeedBoost = false,
    SpeedValue = 100,
    InfiniteJump = false,
    -- Hitbox
    HitboxMax = false,
    HitboxSize = 15,
    HitboxRange = 150,
    -- Auto Farm
    AutoFarm = false,
    AutoFarmRange = 500,
    AutoFarmFlyHeight = 15,
    -- Auto Fish
    AutoFish = false,
    -- Auto Chest
    AutoChest = false,
    -- Auto Quest
    AutoQuest = false,
    -- ESP
    ESP = false,
    -- Auto Click
    AutoClick = false,
    AutoClickSpeed = 0.05,
    -- Fruit Sniper
    FruitSniper = false,
    FruitSniperRange = 1000,
}

-- ════════ حذف النسخ القديمة ════════
for _, name in pairs({"NarakuHubV3", "NarakuHubV4", "NarakuHub", "NarakuESP"}) do
    local old = game.CoreGui:FindFirstChild(name)
    if old then old:Destroy() end
end

-- ════════ الثيم ════════
local Theme = {
    Background = Color3.fromRGB(10, 8, 18),
    Secondary = Color3.fromRGB(20, 15, 32),
    Tertiary = Color3.fromRGB(32, 24, 50),
    Accent = Color3.fromRGB(160, 60, 255),
    Accent2 = Color3.fromRGB(255, 60, 180),
    Accent3 = Color3.fromRGB(80, 180, 255),
    Success = Color3.fromRGB(80, 230, 130),
    Danger = Color3.fromRGB(255, 60, 90),
    Warning = Color3.fromRGB(255, 180, 50),
    Text = Color3.fromRGB(240, 235, 255),
    Subtext = Color3.fromRGB(150, 140, 180),
}

-- ════════ إشعار ════════
local function Notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 3,
        })
    end)
end

-- ════════ الواجهة ════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NarakuHubV4"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = game.CoreGui

-- زر الفتح
local OpenButton = Instance.new("TextButton")
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

-- الإطار الرئيسي
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 0, 0, 0)
Main.Position = UDim2.new(0.5, -300, 0.5, -280)
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

Main:TweenSize(UDim2.new(0, 620, 0, 560), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.5, true)

-- Header
local Header = Instance.new("Frame")
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

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -180, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "奈  NARAKU HUB 奈"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 24
Title.Font = Enum.Font.GothamBlack
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(0, 220, 0, 20)
Subtitle.Position = UDim2.new(0, 22, 1, -22)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "MEGA Edition • v4.0"
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

-- شريط الحالة
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
StatusText.Text = "Ready • v4.0 MEGA • All Systems Online"
StatusText.TextColor3 = Theme.Text
StatusText.TextSize = 12
StatusText.Font = Enum.Font.GothamBold
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.Parent = StatusBar

task.spawn(function()
    while StatusDot.Parent do
        pcall(function()
            TweenService:Create(StatusDot, TweenInfo.new(0.8), {BackgroundColor3 = Theme.Success}):Play()
            task.wait(0.8)
            TweenService:Create(StatusDot, TweenInfo.new(0.8), {BackgroundColor3 = Color3.fromRGB(40, 120, 70)}):Play()
            task.wait(0.8)
        end)
    end
end)

-- ════════ Tab System ════════
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -20, 0, 38)
TabBar.Position = UDim2.new(0, 10, 0, 116)
TabBar.BackgroundColor3 = Theme.Secondary
TabBar.BorderSizePixel = 0
TabBar.Parent = Main

local TabBarCorner = Instance.new("UICorner")
TabBarCorner.CornerRadius = UDim.new(0, 10)
TabBarCorner.Parent = TabBar

local TabBarPadding = Instance.new("UIPadding")
TabBarPadding.PaddingLeft = UDim.new(0, 5)
TabBarPadding.PaddingRight = UDim.new(0, 5)
TabBarPadding.PaddingTop = UDim.new(0, 5)
TabBarPadding.PaddingBottom = UDim.new(0, 5)
TabBarPadding.Parent = TabBar

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 5)
TabLayout.Parent = TabBar

-- Content area
local ContentHolder = Instance.new("Frame")
ContentHolder.Size = UDim2.new(1, -20, 1, -175)
ContentHolder.Position = UDim2.new(0, 10, 0, 164)
ContentHolder.BackgroundColor3 = Theme.Secondary
ContentHolder.BorderSizePixel = 0
ContentHolder.Parent = Main

local ContentHolderCorner = Instance.new("UICorner")
ContentHolderCorner.CornerRadius = UDim.new(0, 12)
ContentHolderCorner.Parent = ContentHolder

-- Tab pages
local Tabs = {}
local CurrentTab = nil

local function CreateTab(tabName, icon)
    -- Tab button
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0, 88, 1, 0)
    TabBtn.BackgroundColor3 = Theme.Tertiary
    TabBtn.Text = icon .. " " .. tabName
    TabBtn.TextColor3 = Theme.Subtext
    TabBtn.TextSize = 12
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.AutoButtonColor = false
    TabBtn.Parent = TabBar
    
    local TabBtnCorner = Instance.new("UICorner")
    TabBtnCorner.CornerRadius = UDim.new(0, 8)
    TabBtnCorner.Parent = TabBtn
    
    -- Scroll for tab
    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Size = UDim2.new(1, 0, 1, 0)
    Scroll.BackgroundTransparency = 1
    Scroll.BorderSizePixel = 0
    Scroll.ScrollBarThickness = 6
    Scroll.ScrollBarImageColor3 = Theme.Accent
    Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Scroll.Visible = false
    Scroll.Parent = ContentHolder
    
    local ScrollPadding = Instance.new("UIPadding")
    ScrollPadding.PaddingTop = UDim.new(0, 10)
    ScrollPadding.PaddingLeft = UDim.new(0, 10)
    ScrollPadding.PaddingRight = UDim.new(0, 10)
    ScrollPadding.PaddingBottom = UDim.new(0, 10)
    ScrollPadding.Parent = Scroll
    
    local ScrollLayout = Instance.new("UIListLayout")
    ScrollLayout.Padding = UDim.new(0, 8)
    ScrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ScrollLayout.Parent = Scroll
    
    Tabs[tabName] = {Button = TabBtn, Scroll = Scroll}
    
    TabBtn.MouseButton1Click:Connect(function()
        -- Hide all
        for _, tab in pairs(Tabs) do
            tab.Scroll.Visible = false
            TweenService:Create(tab.Button, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Tertiary, TextColor3 = Theme.Subtext}):Play()
        end
        -- Show this
        Scroll.Visible = true
        TweenService:Create(TabBtn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Accent, TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        CurrentTab = tabName
    end)
    
    return Scroll, ScrollLayout
end

-- ════════ Helper Functions ════════

local function CreateSection(parent, layout, text)
    local Section = Instance.new("Frame")
    Section.Size = UDim2.new(1, 0, 0, 35)
    Section.BackgroundColor3 = Theme.Background
    Section.BackgroundTransparency = 0.5
    Section.BorderSizePixel = 0
    Section.Parent = parent

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

local function CreateToggle(parent, name, icon, default, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 50)
    Btn.BackgroundColor3 = Theme.Tertiary
    Btn.Text = ""
    Btn.AutoButtonColor = false
    Btn.Parent = parent

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
        if callback then pcall(callback, state) end
    end)

    return Btn
end

local function CreateSlider(parent, name, min, max, default, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 65)
    Container.BackgroundColor3 = Theme.Tertiary
    Container.BorderSizePixel = 0
    Container.Parent = parent

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

    local value = default
    local dragging = false

    local function update(input)
        local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
        value = math.floor(min + (max - min) * pos)
        Fill.Size = UDim2.new(pos, 0, 1, 0)
        Label.Text = name .. ": " .. value
        if callback then pcall(callback, value) end
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

local function CreateButton(parent, name, icon, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 45)
    Btn.BackgroundColor3 = Theme.Accent
    Btn.Text = ""
    Btn.AutoButtonColor = false
    Btn.Parent = parent

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
        if callback then pcall(callback) end
    end)
end

-- ════════ Create Tabs ════════
local CombatScroll = CreateTab("Combat", "⚔️")
local MovementScroll = CreateTab("Move", "💨")
local FarmScroll = CreateTab("Farm", "🎣")
local VisualScroll = CreateTab("Visual", "👁️")
local TPScroll = CreateTab("TP", "🗺️")
local MiscScroll = CreateTab("Misc", "🛠️")

-- Default tab
Tabs["Combat"].Scroll.Visible = true
TweenService:Create(Tabs["Combat"].Button, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Accent, TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()

-- ═══════════════════════════════════════════════
-- ⚔️ COMBAT TAB
-- ═══════════════════════════════════════════════
CreateSection(CombatScroll, nil, "🎯 HITBOX")

local HitboxTargets = {}

CreateToggle(CombatScroll, "Hitbox Max (Enemies)", "🎯", false, function(state)
    Config.HitboxMax = state
    if not state then
        for target, originalSize in pairs(HitboxTargets) do
            pcall(function()
                if target and target.Parent then
                    target.Size = originalSize
                    target.Transparency = 0
                    target.CanCollide = true
                    target.Massless = false
                end
            end)
        end
        HitboxTargets = {}
    end
end)

CreateSlider(CombatScroll, "Hitbox Size", 5, 50, 15, function(val)
    Config.HitboxSize = val
end)

CreateSlider(CombatScroll, "Hitbox Range", 50, 500, 150, function(val)
    Config.HitboxRange = val
end)

CreateSection(CombatScroll, nil, "🖱️ AUTO CLICK")

CreateToggle(CombatScroll, "Auto Click", "🖱️", false, function(state)
    Config.AutoClick = state
end)

CreateSlider(CombatScroll, "Click Speed (ms)", 10, 500, 50, function(val)
    Config.AutoClickSpeed = val / 1000
end)

-- Hitbox loop
task.spawn(function()
    while task.wait(0.15) do
        if Config.HitboxMax then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local myPos = char.HumanoidRootPart.Position
                local size = Config.HitboxSize
                local range = Config.HitboxRange
                
                for _, plr in pairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character then
                        local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                        local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                        if hrp and hum and hum.Health > 0 then
                            local dist = (hrp.Position - myPos).Magnitude
                            if dist < range then
                                if not HitboxTargets[hrp] then HitboxTargets[hrp] = hrp.Size end
                                hrp.Size = Vector3.new(size, size, size)
                                hrp.Transparency = 0.5
                                hrp.CanCollide = false
                                hrp.Massless = true
                            elseif HitboxTargets[hrp] then
                                hrp.Size = HitboxTargets[hrp]
                                hrp.Transparency = 0
                                hrp.CanCollide = true
                                hrp.Massless = false
                                HitboxTargets[hrp] = nil
                            end
                        end
                    end
                end
                
                for _, mob in pairs(Workspace:GetChildren()) do
                    pcall(function()
                        if mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") then
                            local hrp = mob.HumanoidRootPart
                            local hum = mob.Humanoid
                            if mob ~= char and hum.Health > 0 then
                                local dist = (hrp.Position - myPos).Magnitude
                                if dist < range then
                                    if not HitboxTargets[hrp] then HitboxTargets[hrp] = hrp.Size end
                                    hrp.Size = Vector3.new(size, size, size)
                                    hrp.Transparency = 0.5
                                    hrp.CanCollide = false
                                    hrp.Massless = true
                                elseif HitboxTargets[hrp] then
                                    hrp.Size = HitboxTargets[hrp]
                                    hrp.Transparency = 0
                                    hrp.CanCollide = true
                                    hrp.Massless = false
                                    HitboxTargets[hrp] = nil
                                end
                            end
                        end
                    end)
                end
            end
        end
    end
end)

-- Auto Click loop
task.spawn(function()
    while task.wait(Config.AutoClickSpeed) do
        if Config.AutoClick then
            pcall(function()
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            end)
        end
    end
end)

-- ═══════════════════════════════════════════════
-- 💨 MOVEMENT TAB
-- ═══════════════════════════════════════════════
CreateSection(MovementScroll, nil, "💨 SPEED")

CreateToggle(MovementScroll, "Speed Boost", "💨", false, function(state)
    Config.SpeedBoost = state
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = state and Config.SpeedValue or 16
        end
    end
end)

CreateSlider(MovementScroll, "Speed Value", 16, 500, 100, function(val)
    Config.SpeedValue = val
    if Config.SpeedBoost then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = val end
        end
    end
end)

CreateSection(MovementScroll, nil, "🦘 JUMP")

CreateToggle(MovementScroll, "Infinite Jump", "🦘", false, function(state)
    Config.InfiniteJump = state
end)

CreateSlider(MovementScroll, "Jump Power", 50, 500, 50, function(val)
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.JumpPower = val
            hum.UseJumpPower = true
        end
    end
end)

-- Speed loop
task.spawn(function()
    while task.wait(0.1) do
        if Config.SpeedBoost then
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.WalkSpeed ~= Config.SpeedValue then
                    hum.WalkSpeed = Config.SpeedValue
                end
            end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end
end)

-- ═══════════════════════════════════════════════
-- 🎣 FARM TAB
-- ═══════════════════════════════════════════════
CreateSection(FarmScroll, nil, "⚔️ AUTO FARM")

CreateToggle(FarmScroll, "Auto Farm (Kill)", "⚔️", false, function(state)
    Config.AutoFarm = state
end)

CreateSlider(FarmScroll, "Farm Range", 100, 2000, 500, function(val)
    Config.AutoFarmRange = val
end)

CreateSlider(FarmScroll, "Fly Height", 5, 60, 15, function(val)
    Config.AutoFarmFlyHeight = val
end)

CreateSection(FarmScroll, nil, "🎣 AUTO FISH")

CreateToggle(FarmScroll, "Auto Fish", "🎣", false, function(state)
    Config.AutoFish = state
end)

CreateSection(FarmScroll, nil, "💰 AUTO CHEST")

CreateToggle(FarmScroll, "Auto Chest", "💰", false, function(state)
    Config.AutoChest = state
end)

CreateSection(FarmScroll, nil, "🏃 AUTO QUEST")

CreateToggle(FarmScroll, "Auto Quest", "🏃", false, function(state)
    Config.AutoQuest = state
end)

-- ════════ AUTO FARM LOGIC ════════
local function GetNearestEnemy()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = char.HumanoidRootPart.Position
    local nearest = nil
    local minDist = Config.AutoFarmRange
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
                local hum = obj.Humanoid
                if obj.Name ~= LocalPlayer.Name and hum.Health > 0 then
                    local dist = (obj.HumanoidRootPart.Position - myPos).Magnitude
                    if dist < minDist then
                        minDist = dist
                        nearest = obj
                    end
                end
            end
        end)
    end
    return nearest
end

task.spawn(function()
    while task.wait(0.1) do
        if Config.AutoFarm then
            local char = LocalPlayer.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildOfClass("Humanoid")
                
                if hrp and hum and hum.Health > 0 then
                    local enemy = GetNearestEnemy()
                    
                    if enemy then
                        local enemyHrp = enemy:FindFirstChild("HumanoidRootPart")
                        local enemyHum = enemy:FindFirstChild("Humanoid")
                        
                        if enemyHrp and enemyHum and enemyHum.Health > 0 then
                            local dist = (enemyHrp.Position - hrp.Position).Magnitude
                            
                            if dist > 5 then
                                local targetPos = enemyHrp.Position + Vector3.new(0, Config.AutoFarmFlyHeight, 0)
                                local bp = hrp:FindFirstChildOfClass("BodyPosition") or Instance.new("BodyPosition", hrp)
                                bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                                bp.Position = targetPos
                                bp.P = 15000
                                bp.D = 500
                            else
                                hrp.Velocity = Vector3.new(0, 0, 0)
                                hrp.CFrame = CFrame.new(hrp.Position, enemyHrp.Position)
                                
                                local tool = char:FindFirstChildOfClass("Tool")
                                if tool then tool:Activate() end
                                
                                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                                task.wait(0.05)
                                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                            end
                        end
                    else
                        hrp.Velocity = Vector3.new(0, 0, 0)
                        local bp = hrp:FindFirstChildOfClass("BodyPosition")
                        if bp then bp:Destroy() end
                    end
                end
            end
        else
            local char = LocalPlayer.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local bp = hrp:FindFirstChildOfClass("BodyPosition")
                    if bp then bp:Destroy() end
                    hrp.Velocity = Vector3.new(0, 0, 0)
                end
            end
        end
    end
end)

-- ════════ AUTO FISH LOGIC ════════
-- يعمل بناءً على RemoteEvent للفishing
task.spawn(function()
    while task.wait(1) do
        if Config.AutoFish then
            pcall(function()
                local char = LocalPlayer.Character
                if not char then return end
                
                -- البحث عن Fishing Rod في الحقيبة
                local backpack = LocalPlayer:FindFirstChild("Backpack")
                local rod = backpack and (backpack:FindFirstChild("Fishing Rod") or backpack:FindFirstChild("FishingRod"))
                
                if rod then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        rod.Parent = char
                        task.wait(0.3)
                        
                        -- تشغيل السنارة
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                        task.wait(0.5)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                    end
                else
                    -- جرب RemoteEvent للصيد
                    local remote = ReplicatedStorage:FindFirstChild("Fishing", true)
                    if remote and remote:IsA("RemoteEvent") then
                        remote:FireServer()
                    end
                end
            end)
        end
    end
end)

-- ════════ AUTO CHEST LOGIC ════════
task.spawn(function()
    while task.wait(0.5) do
        if Config.AutoChest then
            pcall(function()
                local char = LocalPlayer.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                
                for _, chest in pairs(Workspace:GetChildren()) do
                    if chest:IsA("Model") and (chest.Name:lower():find("chest") or chest.Name:lower():find("treasure")) then
                        local chestPart = chest:FindFirstChildWhichIsA("BasePart") or chest:FindFirstChild("Handle")
                        if chestPart then
                            local dist = (chestPart.Position - char.HumanoidRootPart.Position).Magnitude
                            if dist < 100 then
                                char.HumanoidRootPart.CFrame = CFrame.new(chestPart.Position + Vector3.new(0, 3, 0))
                                task.wait(0.3)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ════════ AUTO QUEST LOGIC ════════
task.spawn(function()
    while task.wait(2) do
        if Config.AutoQuest then
            pcall(function()
                -- البحث عن NPC المهام في Workspace
                local char = LocalPlayer.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                
                for _, npc in pairs(Workspace:GetChildren()) do
                    if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and 
                       (npc.Name:lower():find("quest") or npc.Name:lower():find("mission")) then
                        local hrp = npc:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local dist = (hrp.Position - char.HumanoidRootPart.Position).Magnitude
                            if dist < 300 then
                                char.HumanoidRootPart.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 3, 5))
                                task.wait(0.5)
                                -- تفعيل الـ ProximityPrompt
                                for _, prompt in pairs(npc:GetDescendants()) do
                                    if prompt:IsA("ProximityPrompt") then
                                        pcall(function()
                                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                                            task.wait(0.1)
                                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                                        end)
                                    end
                                end
                                break
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ═══════════════════════════════════════════════
-- 👁️ VISUAL TAB
-- ═══════════════════════════════════════════════
CreateSection(VisualScroll, nil, "👁️ ESP")

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

CreateToggle(VisualScroll, "ESP Players", "👁️", false, function(state)
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
        if Config.ESP then createESP(plr) end
    end)
end)

Players.PlayerRemoving:Connect(function(plr)
    local esp = ESPFolder:FindFirstChild(plr.Name)
    if esp then esp:Destroy() end
end)

-- ═══════════════════════════════════════════════
-- 🗺️ TELEPORT TAB
-- ═══════════════════════════════════════════════
CreateSection(TPScroll, nil, "🏝️ ISLANDS")

local Islands = {
    {name = "Starter Island", icon = "🏠", pos = Vector3.new(0, 15, 0)},
    {name = "Marine Fort", icon = "⚓", pos = Vector3.new(-2840, 30, 4000)},
    {name = "Middle Town", icon = "🏘️", pos = Vector3.new(-655, 15, 1500)},
    {name = "Jungle", icon = "🌴", pos = Vector3.new(-1400, 15, 200)},
    {name = "Pirate Village", icon = "🏴‍☠️", pos = Vector3.new(-1100, 15, 3400)},
    {name = "Desert", icon = "🏜️", pos = Vector3.new(1050, 15, 2900)},
    {name = "Frozen Village", icon = "❄️", pos = Vector3.new(1275, 15, -1140)},
    {name = "Colosseum", icon = "🏛️", pos = Vector3.new(-1830, 15, -3250)},
    {name = "Skylands", icon = "☁️", pos = Vector3.new(-4850, 850, -2200)},
    {name = "Prison", icon = "🔒", pos = Vector3.new(5300, 15, 480)},
    {name = "Magma Village", icon = "🌋", pos = Vector3.new(-5300, 15, 8400)},
    {name = "Underwater City", icon = "🌊", pos = Vector3.new(6100, -25, -1950)},
    {name = "Fishman Island", icon = "🐟", pos = Vector3.new(61500, 200, -7150)},
    {name = "Kingdom of Rose", icon = "🌹", pos = Vector3.new(-390, 15, 6110)},
    {name = "Cursed Ship", icon = "👻", pos = Vector3.new(915, 130, 32700)},
    {name = "Ice Castle", icon = "🏰", pos = Vector3.new(5600, 30, -2000)},
    {name = "Forgotten Island", icon = "🗿", pos = Vector3.new(-3050, 350, -10000)},
}

for _, island in pairs(Islands) do
    CreateButton(TPScroll, island.name, island.icon, function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(island.pos + Vector3.new(0, 5, 0))
            Notify("Teleported", island.name, 2)
        end
    end)
end

-- ═══════════════════════════════════════════════
-- 🛠️ MISC TAB
-- ═══════════════════════════════════════════════
CreateSection(MiscScroll, nil, "🎁 FRUIT SNIPER")

CreateToggle(MiscScroll, "Fruit Sniper", "🎁", false, function(state)
    Config.FruitSniper = state
end)

CreateSlider(MiscScroll, "Sniper Range", 100, 3000, 1000, function(val)
    Config.FruitSniperRange = val
end)

CreateSection(MiscScroll, nil, "🛠️ UTILITIES")

CreateButton(MiscScroll, "Reset Character", "🔄", function()
    local char = LocalPlayer.Character
    if char then char:BreakJoints() end
end)

CreateButton(MiscScroll, "Rejoin Server", "🚪", function()
    pcall(function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end)
end)

CreateButton(MiscScroll, "Server Hop", "🌐", function()
    pcall(function()
        local TS = game:GetService("TeleportService")
        local servers = game:GetService("HttpService"):JSONDecode(
            game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
        )
        if servers and servers.data then
            for _, srv in pairs(servers.data) do
                if srv.playing < srv.maxPlayers and srv.id ~= game.JobId then
                    TS:TeleportToPlaceInstance(game.PlaceId, srv.id, LocalPlayer)
                    break
                end
            end
        end
    end)
end)

CreateSection(MiscScroll, nil, "📊 INFO")

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, 0, 0, 80)
InfoLabel.BackgroundColor3 = Theme.Tertiary
InfoLabel.BorderSizePixel = 0
InfoLabel.Text = "奈 Naraku Hub v4.0 MEGA\n\nDeveloped with ❤️\nRightShift = Toggle UI"
InfoLabel.TextColor3 = Theme.Text
InfoLabel.TextSize = 13
InfoLabel.Font = Enum.Font.GothamBold
InfoLabel.Parent = MiscScroll

local InfoLabelCorner = Instance.new("UICorner")
InfoLabelCorner.CornerRadius = UDim.new(0, 10)
InfoLabelCorner.Parent = InfoLabel

-- ════════ FRUIT SNIPER LOGIC ════════
task.spawn(function()
    while task.wait(1) do
        if Config.FruitSniper then
            pcall(function()
                local char = LocalPlayer.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                
                for _, obj in pairs(Workspace:GetChildren()) do
                    if obj:IsA("Tool") and obj:FindFirstChild("Handle") then
                        local name = obj.Name:lower()
                        -- فواكه Blox Fruits
                        local fruitKeywords = {"dragon", "leopard", "kitsune", "dough", "venom", "shadow", "buddha", "portal", "rumble", "gravity", "control", "spirit", "mammoth", "gas", "t-rex", "trex"}
                        for _, kw in pairs(fruitKeywords) do
                            if name:find(kw) then
                                local dist = (obj.Handle.Position - char.HumanoidRootPart.Position).Magnitude
                                if dist < Config.FruitSniperRange then
                                    char.HumanoidRootPart.CFrame = CFrame.new(obj.Handle.Position + Vector3.new(0, 3, 0))
                                    Notify("🎁 Fruit Found!", obj.Name, 3)
                                    task.wait(0.5)
                                end
                                break
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ═══════════════════════════════════════════════
-- إعادة التعيين عند الموت
-- ═══════════════════════════════════════════════
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = Config.SpeedBoost and Config.SpeedValue or 16
    end
end)

-- ═══════════════════════════════════════════════
-- أزرار التحكم
-- ═══════════════════════════════════════════════

CloseBtn.MouseButton1Click:Connect(function()
    -- إيقاف كل الميزات
    for k, v in pairs(Config) do
        if type(v) == "boolean" then Config[k] = false end
    end
    
    -- إزالة BodyPosition
    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bp = hrp:FindFirstChildOfClass("BodyPosition")
            if bp then bp:Destroy() end
            hrp.Velocity = Vector3.new(0, 0, 0)
        end
    end
    
    Main:TweenSize(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Back, 0.3, true)
    task.wait(0.4)
    ScreenGui:Destroy()
    print("🔒 Naraku Hub v4.0 Closed Permanently")
end)

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        Main:TweenSize(UDim2.new(0, 620, 0, 70), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
    else
        Main:TweenSize(UDim2.new(0, 620, 0, 560), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
    end
end)

OpenButton.MouseButton1Click:Connect(function()
    OpenButton.Visible = false
    Main.Visible = true
    Main.Size = UDim2.new(0, 0, 0, 0)
    Main:TweenSize(UDim2.new(0, 620, 0, 560), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.5, true)
end)

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
local Notify2 = Instance.new("Frame")
Notify2.Size = UDim2.new(0, 380, 0, 90)
Notify2.Position = UDim2.new(0.5, -190, 0, -120)
Notify2.BackgroundColor3 = Theme.Secondary
Notify2.BorderSizePixel = 0
Notify2.Parent = ScreenGui

local NotifyCorner = Instance.new("UICorner")
NotifyCorner.CornerRadius = UDim.new(0, 14)
NotifyCorner.Parent = Notify2

local NotifyStroke = Instance.new("UIStroke")
NotifyStroke.Color = Theme.Accent
NotifyStroke.Thickness = 2
NotifyStroke.Parent = Notify2

local NotifyGradient = Instance.new("UIGradient")
NotifyGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.Accent),
    ColorSequenceKeypoint.new(0.5, Theme.Accent2),
    ColorSequenceKeypoint.new(1, Theme.Accent3),
})
NotifyGradient.Rotation = 45
NotifyGradient.Parent = NotifyStroke

local NotifyIcon = Instance.new("TextLabel")
NotifyIcon.Size = UDim2.new(0, 65, 1, 0)
NotifyIcon.Position = UDim2.new(0, 0, 0, 0)
NotifyIcon.BackgroundTransparency = 1
NotifyIcon.Text = "奈"
NotifyIcon.TextColor3 = Theme.Accent
NotifyIcon.TextSize = 34
NotifyIcon.Font = Enum.Font.GothamBlack
NotifyIcon.Parent = Notify2

local NotifyTitle = Instance.new("TextLabel")
NotifyTitle.Size = UDim2.new(1, -75, 0, 32)
NotifyTitle.Position = UDim2.new(0, 70, 0, 12)
NotifyTitle.BackgroundTransparency = 1
NotifyTitle.Text = "NARAKU HUB v4.0 MEGA"
NotifyTitle.TextColor3 = Theme.Text
NotifyTitle.TextSize = 16
NotifyTitle.Font = Enum.Font.GothamBlack
NotifyTitle.TextXAlignment = Enum.TextXAlignment.Left
NotifyTitle.Parent = Notify2

local NotifyMsg = Instance.new("TextLabel")
NotifyMsg.Size = UDim2.new(1, -75, 0, 25)
NotifyMsg.Position = UDim2.new(0, 70, 0, 46)
NotifyMsg.BackgroundTransparency = 1
NotifyMsg.Text = "All 12 Features Loaded ✓"
NotifyMsg.TextColor3 = Theme.Success
NotifyMsg.TextSize = 13
NotifyMsg.Font = Enum.Font.GothamBold
NotifyMsg.TextXAlignment = Enum.TextXAlignment.Left
NotifyMsg.Parent = Notify2

TweenService:Create(Notify2, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Position = UDim2.new(0.5, -190, 0, 20)}):Play()
task.wait(4)
TweenService:Create(Notify2, TweenInfo.new(0.5), {Position = UDim2.new(0.5, -190, 0, -120)}):Play()
task.wait(0.5)
Notify2:Destroy()

-- ════════ Console ════════
print("╔════════════════════════════════════════════╗")
print("║   NARAKU HUB v4.0 MEGA EDITION LOADED      ║")
print("║                                            ║")
print("║   ⚔️ Combat:  Hitbox, Auto Click            ║")
print("║   💨 Move:    Speed, Inf Jump, Jump Power  ║")
print("║   🎣 Farm:    Auto Farm, Fish, Chest, Quest║")
print("║   👁️ Visual:  ESP Players                  ║")
print("║   🗺️ TP:      17 Islands                   ║")
print("║   🎁 Fruit:   Sniper                       ║")
print("║                                            ║")
print("║   📌 RightShift to toggle UI              ║")
print("╚════════════════════════════════════════════╝")
