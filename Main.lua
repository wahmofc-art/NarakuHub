--[[
    ╔═══════════════════════════════════════════════════╗
    ║                                                   ║
    ║        ███╗   ██╗ █████╗ ██████╗  █████╗         ║
    ║        ████╗  ██║██╔══██╗██╔══██╗██╔══██╗        ║
    ║        ██╔██╗ ██║███████║██████╔╝███████║        ║
    ║        ██║╚██╗██║██╔══██║██╔══██╗██╔══██║        ║
    ║        ██║ ╚████║██║  ██║██║  ██║██║  ██║        ║
    ║        ╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝        ║
    ║                                                   ║
    ║           NARAKU HUB v5.0 - FIXED                ║
    ║              Blox Fruits Edition                  ║
    ║                                                   ║
    ║   ✅ Speed Boost (Working)                        ║
    ║   ✅ Auto Farm (Auto Melee + Kill)                ║
    ║   ✅ Hitbox on Enemies                            ║
    ║   ✅ Infinite Jump                                ║
    ║   ✅ ESP Players                                  ║
    ║   ✅ Auto Click                                   ║
    ║   ✅ Permanent Close                              ║
    ╚═══════════════════════════════════════════════════╝
]]

-- ═══════════════════════════════════════════════════════
--                    SERVICES
-- ═══════════════════════════════════════════════════════
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

-- ═══════════════════════════════════════════════════════
--                    CONFIG
-- ═══════════════════════════════════════════════════════
local Config = {
    -- Speed
    SpeedBoost = false,
    SpeedValue = 120,
    SpeedMethod = "BodyVelocity", -- "BodyVelocity" أو "WalkSpeed"
    -- Auto Farm
    AutoFarm = false,
    AutoFarmRange = 500,
    AutoFarmFlyHeight = 15,
    AutoFarmSpeed = 8,
    -- Hitbox
    HitboxMax = false,
    HitboxSize = 20,
    HitboxRange = 200,
    -- Jump
    InfiniteJump = false,
    JumpPower = 50,
    -- Visual
    ESP = false,
    -- Auto Click
    AutoClick = false,
    AutoClickSpeed = 0.1,
}

-- ═══════════════════════════════════════════════════════
--                    CLEANUP
-- ═══════════════════════════════════════════════════════
local oldNames = {"NarakuHub", "NarakuHubV2", "NarakuHubV3", "NarakuHubV4", "NarakuHubV5"}
for _, name in pairs(oldNames) do
    local old = game.CoreGui:FindFirstChild(name)
    if old then old:Destroy() end
end

-- ═══════════════════════════════════════════════════════
--                    THEME
-- ═══════════════════════════════════════════════════════
local Theme = {
    Bg = Color3.fromRGB(10, 8, 18),
    Sec = Color3.fromRGB(20, 15, 32),
    Ter = Color3.fromRGB(32, 24, 50),
    Acc = Color3.fromRGB(160, 60, 255),
    Acc2 = Color3.fromRGB(255, 60, 180),
    Acc3 = Color3.fromRGB(80, 180, 255),
    Success = Color3.fromRGB(80, 230, 130),
    Danger = Color3.fromRGB(255, 60, 90),
    Text = Color3.fromRGB(240, 235, 255),
    Sub = Color3.fromRGB(150, 140, 180),
}

-- ═══════════════════════════════════════════════════════
--                    UI CREATION
-- ═══════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NarakuHubV5"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = game.CoreGui

-- Floating open button
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 60, 0, 60)
OpenBtn.Position = UDim2.new(0, 20, 0.5, -30)
OpenBtn.BackgroundColor3 = Theme.Acc
OpenBtn.Text = "奈"
OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenBtn.TextSize = 26
OpenBtn.Font = Enum.Font.GothamBlack
OpenBtn.AutoButtonColor = false
OpenBtn.Visible = false
OpenBtn.Parent = ScreenGui

local OC = Instance.new("UICorner")
OC.CornerRadius = UDim.new(1, 0)
OC.Parent = OpenBtn

local OS = Instance.new("UIStroke")
OS.Color = Color3.fromRGB(255, 255, 255)
OS.Thickness = 2
OS.Transparency = 0.3
OS.Parent = OpenBtn

-- Main frame
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 0, 0, 0)
Main.Position = UDim2.new(0.5, -300, 0.5, -270)
Main.BackgroundColor3 = Theme.Bg
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local MC = Instance.new("UICorner")
MC.CornerRadius = UDim.new(0, 16)
MC.Parent = Main

local MS = Instance.new("UIStroke")
MS.Color = Theme.Acc
MS.Thickness = 2
MS.Transparency = 0.2
MS.Parent = Main

local MG = Instance.new("UIGradient")
MG.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.Acc),
    ColorSequenceKeypoint.new(0.5, Theme.Acc2),
    ColorSequenceKeypoint.new(1, Theme.Acc3),
})
MG.Rotation = 45
MG.Parent = MS

Main:TweenSize(UDim2.new(0, 600, 0, 520), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.5, true)

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 65)
Header.BackgroundColor3 = Theme.Sec
Header.BorderSizePixel = 0
Header.Parent = Main

local HC = Instance.new("UICorner")
HC.CornerRadius = UDim.new(0, 16)
HC.Parent = Header

local HG = Instance.new("UIGradient")
HG.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.Acc),
    ColorSequenceKeypoint.new(0.5, Theme.Acc2),
    ColorSequenceKeypoint.new(1, Theme.Acc3),
})
HG.Rotation = 45
HG.Parent = Header

local HO = Instance.new("Frame")
HO.Size = UDim2.new(1, 0, 1, 0)
HO.BackgroundColor3 = Theme.Bg
HO.BackgroundTransparency = 0.35
HO.BorderSizePixel = 0
HO.Parent = Header

local HOC = Instance.new("UICorner")
HOC.CornerRadius = UDim.new(0, 16)
HOC.Parent = HO

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -180, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "奈  NARAKU HUB v5.0 奈"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 22
Title.Font = Enum.Font.GothamBlack
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Sub = Instance.new("TextLabel")
Sub.Size = UDim2.new(0, 240, 0, 20)
Sub.Position = UDim2.new(0, 22, 1, -22)
Sub.BackgroundTransparency = 1
Sub.Text = "FIXED • Speed + Farm + Hitbox"
Sub.TextColor3 = Color3.fromRGB(255, 255, 255)
Sub.TextTransparency = 0.4
Sub.TextSize = 11
Sub.Font = Enum.Font.GothamBold
Sub.TextXAlignment = Enum.TextXAlignment.Left
Sub.Parent = Header

-- Minimize
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 34, 0, 34)
MinBtn.Position = UDim2.new(1, -88, 0, 16)
MinBtn.BackgroundColor3 = Theme.Ter
MinBtn.Text = "—"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = 20
MinBtn.Font = Enum.Font.GothamBold
MinBtn.AutoButtonColor = false
MinBtn.Parent = Header

local MNC = Instance.new("UICorner")
MNC.CornerRadius = UDim.new(0, 8)
MNC.Parent = MinBtn

-- Close
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 34, 0, 34)
CloseBtn.Position = UDim2.new(1, -48, 0, 16)
CloseBtn.BackgroundColor3 = Theme.Danger
CloseBtn.Text = "✖"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = Header

local CC = Instance.new("UICorner")
CC.CornerRadius = UDim.new(0, 8)
CC.Parent = CloseBtn

-- Status bar
local StatusBar = Instance.new("Frame")
StatusBar.Size = UDim2.new(1, -20, 0, 28)
StatusBar.Position = UDim2.new(0, 10, 0, 72)
StatusBar.BackgroundColor3 = Theme.Ter
StatusBar.BorderSizePixel = 0
StatusBar.Parent = Main

local SBC = Instance.new("UICorner")
SBC.CornerRadius = UDim.new(0, 8)
SBC.Parent = StatusBar

local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.new(0, 8, 0, 8)
StatusDot.Position = UDim2.new(0, 12, 0.5, -4)
StatusDot.BackgroundColor3 = Theme.Success
StatusDot.BorderSizePixel = 0
StatusDot.Parent = StatusBar

local SDC = Instance.new("UICorner")
SDC.CornerRadius = UDim.new(1, 0)
SDC.Parent = StatusDot

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, -40, 1, 0)
StatusText.Position = UDim2.new(0, 28, 0, 0)
StatusText.BackgroundTransparency = 1
StatusText.Text = "Ready • v5.0 FIXED"
StatusText.TextColor3 = Theme.Text
StatusText.TextSize = 11
StatusText.Font = Enum.Font.GothamBold
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.Parent = StatusBar

-- Scroll frame
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -110)
Scroll.Position = UDim2.new(0, 10, 0, 105)
Scroll.BackgroundColor3 = Theme.Sec
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 6
Scroll.ScrollBarImageColor3 = Theme.Acc
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.Parent = Main

local SC = Instance.new("UICorner")
SC.CornerRadius = UDim.new(0, 12)
SC.Parent = Scroll

local SP = Instance.new("UIPadding")
SP.PaddingTop = UDim.new(0, 10)
SP.PaddingLeft = UDim.new(0, 10)
SP.PaddingRight = UDim.new(0, 10)
SP.PaddingBottom = UDim.new(0, 10)
SP.Parent = Scroll

local SL = Instance.new("UIListLayout")
SL.Padding = UDim.new(0, 8)
SL.SortOrder = Enum.SortOrder.LayoutOrder
SL.Parent = Scroll

-- ═══════════════════════════════════════════════════════
--                    HELPER FUNCTIONS
-- ═══════════════════════════════════════════════════════

local function CreateSection(text)
    local S = Instance.new("Frame")
    S.Size = UDim2.new(1, 0, 0, 35)
    S.BackgroundColor3 = Theme.Bg
    S.BackgroundTransparency = 0.5
    S.BorderSizePixel = 0
    S.Parent = Scroll

    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 8)
    C.Parent = S

    local L = Instance.new("Frame")
    L.Size = UDim2.new(0, 4, 0, 20)
    L.Position = UDim2.new(0, 10, 0.5, -10)
    L.BackgroundColor3 = Theme.Acc
    L.BorderSizePixel = 0
    L.Parent = S

    local LC = Instance.new("UICorner")
    LC.CornerRadius = UDim.new(1, 0)
    LC.Parent = L

    local T = Instance.new("TextLabel")
    T.Size = UDim2.new(1, -30, 1, 0)
    T.Position = UDim2.new(0, 22, 0, 0)
    T.BackgroundTransparency = 1
    T.Text = text
    T.TextColor3 = Theme.Text
    T.TextSize = 14
    T.Font = Enum.Font.GothamBlack
    T.TextXAlignment = Enum.TextXAlignment.Left
    T.Parent = S
end

local function CreateToggle(name, icon, default, callback)
    local B = Instance.new("TextButton")
    B.Size = UDim2.new(1, 0, 0, 50)
    B.BackgroundColor3 = Theme.Ter
    B.Text = ""
    B.AutoButtonColor = false
    B.Parent = Scroll

    local BC = Instance.new("UICorner")
    BC.CornerRadius = UDim.new(0, 10)
    BC.Parent = B

    local BS = Instance.new("UIStroke")
    BS.Color = Color3.fromRGB(60, 50, 90)
    BS.Thickness = 1
    BS.Parent = B

    local I = Instance.new("TextLabel")
    I.Size = UDim2.new(0, 45, 1, 0)
    I.Position = UDim2.new(0, 5, 0, 0)
    I.BackgroundTransparency = 1
    I.Text = icon
    I.TextSize = 24
    I.Font = Enum.Font.GothamBold
    I.Parent = B

    local N = Instance.new("TextLabel")
    N.Size = UDim2.new(1, -125, 1, 0)
    N.Position = UDim2.new(0, 50, 0, 0)
    N.BackgroundTransparency = 1
    N.Text = name
    N.TextColor3 = Theme.Text
    N.TextSize = 15
    N.Font = Enum.Font.GothamBold
    N.TextXAlignment = Enum.TextXAlignment.Left
    N.Parent = B

    local Sw = Instance.new("Frame")
    Sw.Size = UDim2.new(0, 52, 0, 28)
    Sw.Position = UDim2.new(1, -62, 0.5, -14)
    Sw.BackgroundColor3 = Color3.fromRGB(50, 45, 70)
    Sw.BorderSizePixel = 0
    Sw.Parent = B

    local SwC = Instance.new("UICorner")
    SwC.CornerRadius = UDim.new(1, 0)
    SwC.Parent = Sw

    local K = Instance.new("Frame")
    K.Size = UDim2.new(0, 22, 0, 22)
    K.Position = UDim2.new(0, 3, 0.5, -11)
    K.BackgroundColor3 = Color3.fromRGB(220, 215, 240)
    K.BorderSizePixel = 0
    K.Parent = Sw

    local KC = Instance.new("UICorner")
    KC.CornerRadius = UDim.new(1, 0)
    KC.Parent = K

    local state = default or false

    local function updateVisual()
        if state then
            TweenService:Create(Sw, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Acc}):Play()
            TweenService:Create(K, TweenInfo.new(0.2), {
                Position = UDim2.new(1, -25, 0.5, -11),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
            TweenService:Create(BS, TweenInfo.new(0.2), {Color = Theme.Acc}):Play()
        else
            TweenService:Create(Sw, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 45, 70)}):Play()
            TweenService:Create(K, TweenInfo.new(0.2), {
                Position = UDim2.new(0, 3, 0.5, -11),
                BackgroundColor3 = Color3.fromRGB(220, 215, 240)
            }):Play()
            TweenService:Create(BS, TweenInfo.new(0.2), {Color = Color3.fromRGB(60, 50, 90)}):Play()
        end
    end

    updateVisual()

    B.MouseButton1Click:Connect(function()
        state = not state
        updateVisual()
        if callback then pcall(callback, state) end
    end)
end

local function CreateSlider(name, min, max, default, callback)
    local C = Instance.new("Frame")
    C.Size = UDim2.new(1, 0, 0, 65)
    C.BackgroundColor3 = Theme.Ter
    C.BorderSizePixel = 0
    C.Parent = Scroll

    local CC = Instance.new("UICorner")
    CC.CornerRadius = UDim.new(0, 10)
    CC.Parent = C

    local CS = Instance.new("UIStroke")
    CS.Color = Color3.fromRGB(60, 50, 90)
    CS.Thickness = 1
    CS.Parent = C

    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(1, -20, 0, 25)
    L.Position = UDim2.new(0, 10, 0, 5)
    L.BackgroundTransparency = 1
    L.Text = name .. ": " .. default
    L.TextColor3 = Theme.Text
    L.TextSize = 14
    L.Font = Enum.Font.GothamBold
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.Parent = C

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, -20, 0, 10)
    Bar.Position = UDim2.new(0, 10, 1, -22)
    Bar.BackgroundColor3 = Color3.fromRGB(40, 35, 60)
    Bar.BorderSizePixel = 0
    Bar.Parent = C

    local BC = Instance.new("UICorner")
    BC.CornerRadius = UDim.new(1, 0)
    BC.Parent = Bar

    local F = Instance.new("Frame")
    F.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    F.BackgroundColor3 = Theme.Acc
    F.BorderSizePixel = 0
    F.Parent = Bar

    local FC = Instance.new("UICorner")
    FC.CornerRadius = UDim.new(1, 0)
    FC.Parent = F

    local val = default
    local drag = false

    local function upd(input)
        local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
        val = math.floor(min + (max - min) * pos)
        F.Size = UDim2.new(pos, 0, 1, 0)
        L.Text = name .. ": " .. val
        if callback then pcall(callback, val) end
    end

    Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            drag = true
            upd(input)
        end
    end)

    Bar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if drag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            upd(input)
        end
    end)
end

local function CreateButton(name, icon, callback)
    local B = Instance.new("TextButton")
    B.Size = UDim2.new(1, 0, 0, 45)
    B.BackgroundColor3 = Theme.Acc
    B.Text = ""
    B.AutoButtonColor = false
    B.Parent = Scroll

    local BC = Instance.new("UICorner")
    BC.CornerRadius = UDim.new(0, 10)
    BC.Parent = B

    local BG = Instance.new("UIGradient")
    BG.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.Acc),
        ColorSequenceKeypoint.new(1, Theme.Acc2),
    })
    BG.Rotation = 45
    BG.Parent = B

    local I = Instance.new("TextLabel")
    I.Size = UDim2.new(0, 45, 1, 0)
    I.Position = UDim2.new(0, 5, 0, 0)
    I.BackgroundTransparency = 1
    I.Text = icon
    I.TextSize = 22
    I.Font = Enum.Font.GothamBold
    I.Parent = B

    local N = Instance.new("TextLabel")
    N.Size = UDim2.new(1, -55, 1, 0)
    N.Position = UDim2.new(0, 50, 0, 0)
    N.BackgroundTransparency = 1
    N.Text = name
    N.TextColor3 = Color3.fromRGB(255, 255, 255)
    N.TextSize = 15
    N.Font = Enum.Font.GothamBold
    N.TextXAlignment = Enum.TextXAlignment.Left
    N.Parent = B

    B.MouseButton1Click:Connect(function()
        TweenService:Create(B, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Acc3}):Play()
        task.wait(0.1)
        TweenService:Create(B, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Acc}):Play()
        if callback then pcall(callback) end
    end)
end

-- ═══════════════════════════════════════════════════════
--                💨 SPEED BOOST (FIXED)
-- ═══════════════════════════════════════════════════════
CreateSection("💨  SPEED")

CreateToggle("Speed Boost", "💨", false, function(state)
    Config.SpeedBoost = state
    if not state then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 16 end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local bv = hrp:FindFirstChild("NarakuSpeed")
                if bv then bv:Destroy() end
            end
        end
    end
end)

CreateSlider("Speed Value", 16, 500, 120, function(val)
    Config.SpeedValue = val
end)

-- Speed loop - Using BodyVelocity (Blox Fruits compatible)
task.spawn(function()
    while task.wait(0.05) do
        if Config.SpeedBoost then
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                local hrp = char:FindFirstChild("HumanoidRootPart")
                
                if hum and hrp and hum.Health > 0 then
                    -- Set WalkSpeed
                    if hum.WalkSpeed ~= Config.SpeedValue then
                        hum.WalkSpeed = Config.SpeedValue
                    end
                    
                    -- BodyVelocity for real speed (bypasses anti-cheat)
                    local bv = hrp:FindFirstChild("NarakuSpeed")
                    if not bv then
                        bv = Instance.new("BodyVelocity")
                        bv.Name = "NarakuSpeed"
                        bv.MaxForce = Vector3.new(math.huge, 0, math.huge)
                        bv.P = 10000
                        bv.Parent = hrp
                    end
                    
                    local moveDir = hum.MoveDirection
                    if moveDir.Magnitude > 0 then
                        bv.Velocity = moveDir * Config.SpeedValue
                    else
                        bv.Velocity = Vector3.new(0, 0, 0)
                    end
                end
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════
--                🦘 INFINITE JUMP
-- ═══════════════════════════════════════════════════════
CreateSection("🦘  JUMP")

CreateToggle("Infinite Jump", "🦘", false, function(state)
    Config.InfiniteJump = state
end)

CreateSlider("Jump Power", 50, 500, 50, function(val)
    Config.JumpPower = val
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.JumpPower = val
            hum.UseJumpPower = true
        end
    end
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

-- ═══════════════════════════════════════════════════════
--                ⚔️ AUTO FARM (FIXED)
-- ═══════════════════════════════════════════════════════
CreateSection("⚔️  AUTO FARM")

CreateToggle("Auto Farm", "⚔️", false, function(state)
    Config.AutoFarm = state
    if not state then
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Velocity = Vector3.new(0, 0, 0)
                local bp = hrp:FindFirstChild("NarakuFly")
                if bp then bp:Destroy() end
            end
        end
    end
end)

CreateSlider("Farm Range", 100, 2000, 500, function(val)
    Config.AutoFarmRange = val
end)

CreateSlider("Fly Height", 5, 50, 15, function(val)
    Config.AutoFarmFlyHeight = val
end)

CreateSlider("Farm Speed", 1, 20, 8, function(val)
    Config.AutoFarmSpeed = val
end)

-- Equip Melee Tool automatically
local function EquipMelee()
    local char = LocalPlayer.Character
    if not char then return end
    
    -- Already has tool? Check if it's melee
    local currentTool = char:FindFirstChildOfClass("Tool")
    if currentTool then
        return currentTool
    end
    
    -- Find in backpack
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return nil end
    
    -- Priority: Melee first, then any tool
    local meleeKeywords = {"melee", "sword", "blade", "katana", "cutlass", "saber", "fist", "combat", "superhuman", "blackleg", "electro", "fishman"}
    
    -- Search melee first
    for _, tool in pairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local toolName = tool.Name:lower()
            local toolType = tostring(tool:GetAttribute("ToolType") or ""):lower()
            
            for _, kw in pairs(meleeKeywords) do
                if toolName:find(kw) or toolType:find(kw) then
                    pcall(function() tool.Parent = char end)
                    return tool
                end
            end
        end
    end
    
    -- Fallback: any tool
    for _, tool in pairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            pcall(function() tool.Parent = char end)
            return tool
        end
    end
    
    return nil
end

-- Get nearest enemy (mobs + bosses, not players)
local function GetNearestEnemy()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    
    local myPos = char.HumanoidRootPart.Position
    local nearest = nil
    local minDist = Config.AutoFarmRange
    
    -- Search workspace children
    for _, obj in pairs(Workspace:GetChildren()) do
        pcall(function()
            if obj:IsA("Model") then
                local hum = obj:FindFirstChildOfClass("Humanoid")
                local hrp = obj:FindFirstChild("HumanoidRootPart")
                
                if hum and hrp and hum.Health > 0 then
                    -- Ignore player characters
                    local isPlayer = Players:GetPlayerFromCharacter(obj)
                    if not isPlayer then
                        local dist = (hrp.Position - myPos).Magnitude
                        if dist < minDist then
                            minDist = dist
                            nearest = obj
                        end
                    end
                end
            end
        end)
    end
    
    return nearest
end

-- Main Auto Farm loop
task.spawn(function()
    while task.wait(0.05) do
        if Config.AutoFarm then
            local char = LocalPlayer.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildOfClass("Humanoid")
                
                if hrp and hum and hum.Health > 0 then
                    -- Auto equip melee
                    local tool = EquipMelee()
                    
                    local enemy = GetNearestEnemy()
                    
                    if enemy then
                        local eHrp = enemy:FindFirstChild("HumanoidRootPart")
                        local eHum = enemy:FindFirstChildOfClass("Humanoid")
                        
                        if eHrp and eHum and eHum.Health > 0 then
                            local dist = (eHrp.Position - hrp.Position).Magnitude
                            local targetPos = eHrp.Position + Vector3.new(0, Config.AutoFarmFlyHeight, 0)
                            
                            if dist > 6 then
                                -- Fly to enemy using BodyPosition (smooth)
                                local bp = hrp:FindFirstChild("NarakuFly")
                                if not bp then
                                    bp = Instance.new("BodyPosition")
                                    bp.Name = "NarakuFly"
                                    bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                                    bp.P = 20000
                                    bp.D = 1000
                                    bp.Parent = hrp
                                end
                                bp.Position = targetPos
                            else
                                -- Stop and attack
                                local bp = hrp:FindFirstChild("NarakuFly")
                                if bp then bp:Destroy() end
                                hrp.Velocity = Vector3.new(0, 0, 0)
                                hrp.CFrame = CFrame.new(hrp.Position, eHrp.Position)
                                
                                -- Activate tool
                                if tool then
                                    pcall(function() tool:Activate() end)
                                end
                                
                                -- Virtual click
                                pcall(function()
                                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                                end)
                                
                                -- Server-side hit (if available)
                                pcall(function()
                                    local combatRemote = ReplicatedStorage:FindFirstChild("Remotes")
                                    if combatRemote then
                                        -- Blox Fruits specific (may not exist)
                                    end
                                end)
                            end
                        end
                    else
                        -- No enemy: hover in place
                        local bp = hrp:FindFirstChild("NarakuFly")
                        if bp then bp:Destroy() end
                        hrp.Velocity = Vector3.new(0, 0, 0)
                    end
                end
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════
--                🎯 HITBOX ON ENEMIES
-- ═══════════════════════════════════════════════════════
CreateSection("🎯  HITBOX")

local HitboxTargets = {}

CreateToggle("Hitbox Max", "🎯", false, function(state)
    Config.HitboxMax = state
    if not state then
        for target, origSize in pairs(HitboxTargets) do
            pcall(function()
                if target and target.Parent then
                    target.Size = origSize
                    target.Transparency = 0
                    target.CanCollide = true
                end
            end)
        end
        HitboxTargets = {}
    end
end)

CreateSlider("Hitbox Size", 5, 50, 20, function(val)
    Config.HitboxSize = val
end)

CreateSlider("Hitbox Range", 50, 500, 200, function(val)
    Config.HitboxRange = val
end)

task.spawn(function()
    while task.wait(0.2) do
        if Config.HitboxMax then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local myPos = char.HumanoidRootPart.Position
                local size = Config.HitboxSize
                local range = Config.HitboxRange
                
                -- Mobs / NPCs
                for _, mob in pairs(Workspace:GetChildren()) do
                    pcall(function()
                        if mob:IsA("Model") and mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") then
                            local hrp = mob.HumanoidRootPart
                            local hum = mob.Humanoid
                            
                            if mob ~= char and hum.Health > 0 and not Players:GetPlayerFromCharacter(mob) then
                                local dist = (hrp.Position - myPos).Magnitude
                                if dist < range then
                                    if not HitboxTargets[hrp] then
                                        HitboxTargets[hrp] = hrp.Size
                                    end
                                    hrp.Size = Vector3.new(size, size, size)
                                    hrp.Transparency = 0.5
                                    hrp.CanCollide = false
                                elseif HitboxTargets[hrp] then
                                    hrp.Size = HitboxTargets[hrp]
                                    hrp.Transparency = 0
                                    hrp.CanCollide = true
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

-- ═══════════════════════════════════════════════════════
--                👁️ ESP
-- ═══════════════════════════════════════════════════════
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
    box.Color3 = Theme.Acc2
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
        if Config.ESP then createESP(plr) end
    end)
end)

Players.PlayerRemoving:Connect(function(plr)
    local esp = ESPFolder:FindFirstChild(plr.Name)
    if esp then esp:Destroy() end
end)

-- ═══════════════════════════════════════════════════════
--                🖱️ AUTO CLICK
-- ═══════════════════════════════════════════════════════
CreateSection("🖱️  AUTO CLICK")

CreateToggle("Auto Click", "🖱️", false, function(state)
    Config.AutoClick = state
end)

CreateSlider("Click Speed (ms)", 10, 500, 100, function(val)
    Config.AutoClickSpeed = val / 1000
end)

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

-- ═══════════════════════════════════════════════════════
--                🛠️ UTILITIES
-- ═══════════════════════════════════════════════════════
CreateSection("🛠️  UTILITIES")

CreateButton("Reset Character", "🔄", function()
    local char = LocalPlayer.Character
    if char then char:BreakJoints() end
end)

CreateButton("Rejoin Server", "🚪", function()
    pcall(function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end)
end)

-- ═══════════════════════════════════════════════════════
--                CHARACTER RESPAWN
-- ═══════════════════════════════════════════════════════
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = Config.SpeedBoost and Config.SpeedValue or 16
        hum.JumpPower = Config.JumpPower
    end
end)

-- ═══════════════════════════════════════════════════════
--                CONTROL BUTTONS
-- ═══════════════════════════════════════════════════════

-- Permanent Close
CloseBtn.MouseButton1Click:Connect(function()
    -- Stop everything
    for k, v in pairs(Config) do
        if type(v) == "boolean" then Config[k] = false end
    end
    
    -- Cleanup character
    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, child in pairs(hrp:GetChildren()) do
                if child:IsA("BodyVelocity") or child:IsA("BodyPosition") then
                    child:Destroy()
                end
            end
            hrp.Velocity = Vector3.new(0, 0, 0)
        end
    end
    
    -- Animate close
    Main:TweenSize(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Back, 0.3, true)
    task.wait(0.4)
    
    -- Destroy everything
    ScreenGui:Destroy()
    print("🔒 Naraku Hub v5.0 Closed")
end)

-- Minimize
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        Main:TweenSize(UDim2.new(0, 600, 0, 65), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
    else
        Main:TweenSize(UDim2.new(0, 600, 0, 520), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
    end
end)

-- Reopen from floating button
OpenBtn.MouseButton1Click:Connect(function()
    OpenBtn.Visible = false
    Main.Visible = true
    Main.Size = UDim2.new(0, 0, 0, 0)
    Main:TweenSize(UDim2.new(0, 600, 0, 520), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.5, true)
end)

-- RightShift toggle
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        if Main.Visible then
            Main.Visible = false
            OpenBtn.Visible = true
        else
            Main.Visible = true
            OpenBtn.Visible = false
        end
    end
end)

-- ═══════════════════════════════════════════════════════
--                WELCOME NOTIFICATION
-- ═══════════════════════════════════════════════════════
local Notify = Instance.new("Frame")
Notify.Size = UDim2.new(0, 380, 0, 90)
Notify.Position = UDim2.new(0.5, -190, 0, -120)
Notify.BackgroundColor3 = Theme.Sec
Notify.BorderSizePixel = 0
Notify.Parent = ScreenGui

local NC = Instance.new("UICorner")
NC.CornerRadius = UDim.new(0, 14)
NC.Parent = Notify

local NS = Instance.new("UIStroke")
NS.Color = Theme.Acc
NS.Thickness = 2
NS.Parent = Notify

local NG = Instance.new("UIGradient")
NG.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.Acc),
    ColorSequenceKeypoint.new(0.5, Theme.Acc2),
    ColorSequenceKeypoint.new(1, Theme.Acc3),
})
NG.Rotation = 45
NG.Parent = NS

local NI = Instance.new("TextLabel")
NI.Size = UDim2.new(0, 65, 1, 0)
NI.BackgroundTransparency = 1
NI.Text = "奈"
NI.TextColor3 = Theme.Acc
NI.TextSize = 34
NI.Font = Enum.Font.GothamBlack
NI.Parent = Notify

local NT = Instance.new("TextLabel")
NT.Size = UDim2.new(1, -75, 0, 32)
NT.Position = UDim2.new(0, 70, 0, 12)
NT.BackgroundTransparency = 1
NT.Text = "NARAKU HUB v5.0 FIXED"
NT.TextColor3 = Theme.Text
NT.TextSize = 16
NT.Font = Enum.Font.GothamBlack
NT.TextXAlignment = Enum.TextXAlignment.Left
NT.Parent = Notify

local NM = Instance.new("TextLabel")
NM.Size = UDim2.new(1, -75, 0, 25)
NM.Position = UDim2.new(0, 70, 0, 46)
NM.BackgroundTransparency = 1
NM.Text = "Speed ✓ | Farm ✓ | Hitbox ✓"
NM.TextColor3 = Theme.Success
NM.TextSize = 13
NM.Font = Enum.Font.GothamBold
NM.TextXAlignment = Enum.TextXAlignment.Left
NM.Parent = Notify

TweenService:Create(Notify, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Position = UDim2.new(0.5, -190, 0, 20)}):Play()
task.wait(4)
TweenService:Create(Notify, TweenInfo.new(0.5), {Position = UDim2.new(0.5, -190, 0, -120)}):Play()
task.wait(0.5)
Notify:Destroy()

-- ═══════════════════════════════════════════════════════
--                CONSOLE LOG
-- ═══════════════════════════════════════════════════════
print("╔════════════════════════════════════════════╗")
print("║   NARAKU HUB v5.0 FIXED - LOADED           ║")
print("║                                            ║")
print("║  ✅ Speed Boost (BodyVelocity method)      ║")
print("║  ✅ Auto Farm (Auto Melee + Kill)          ║")
print("║  ✅ Hitbox on Enemies                      ║")
print("║  ✅ Infinite Jump                          ║")
print("║  ✅ ESP Players                            ║")
print("║  ✅ Auto Click                             ║")
print("║  ✅ Permanent Close                        ║")
print("║                                            ║")
print("║  📌 RightShift = Toggle UI                ║")
print("╚════════════════════════════════════════════╝")
