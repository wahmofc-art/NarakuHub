--[[
    ╔═══════════════════════════════════════════════╗
    ║          NARAKU - RIVALS v3.0 FIXED           ║
    ║                                                ║
    ║   ✓ Aimbot (Fixed - Real Hits)                ║
    ║   ✓ Silent Aim (Fixed - 100% Hit)             ║
    ║   ✓ Hitbox Expander                           ║
    ║   ✓ ESP (Box/Name/Health/Distance/Tracer)     ║
    ║   ✓ Trigger Bot                               ║
    ║   ✓ FOV Circle                                ║
    ╚═══════════════════════════════════════════════╝
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
local Camera = Workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ═══════════════════════════════════════════════════════
--                    CLEANUP
-- ═══════════════════════════════════════════════════════
for _, name in pairs({"NarakuRivals", "NarakuRivalsV1", "NarakuRivalsV2", "NarakuRivalsV3"}) do
    local old = game.CoreGui:FindFirstChild(name)
    if old then old:Destroy() end
end

-- ═══════════════════════════════════════════════════════
--                    CONFIG
-- ═══════════════════════════════════════════════════════
local Config = {
    -- AIMBOT
    Aimbot = true,
    AimbotKey = Enum.UserInputType.MouseButton2, -- Right Click
    AimbotMode = "Rage",
    AimbotLockPart = "Head",
    AimbotFOV = 800,
    AimbotSmoothness = 0.35,
    AimbotPrediction = true,
    AimbotWallCheck = true,
    AimbotTeamCheck = true,
    AimbotMaxDistance = 0,
    AimbotAutoFire = false,
    AimbotPriority = "Distance",
    AimbotVisibleCheck = true,
    
    -- SILENT AIM
    SilentAim = true,
    SilentAimFOV = 800,
    SilentAimHitchance = 100,
    SilentAimTargetPart = "Head",
    SilentAimPrediction = true,
    
    -- HITBOX
    HitboxExpander = false,
    HitboxSize = 20,
    HitboxRange = 500,
    HitboxTransparency = 0.5,
    
    -- TRIGGER BOT
    TriggerBot = false,
    TriggerBotDelay = 50,
    
    -- FOV CIRCLE
    FOVCircle = true,
    FOVCircleSize = 800,
    FOVCircleRainbow = true,
    
    -- ESP
    ESP = true,
    ESPBox = true,
    ESPName = true,
    ESPDistance = true,
    ESPHealth = true,
    ESPTracer = true,
    ESPChams = false,
    
    -- MOVEMENT
    InfiniteJump = false,
    Fly = false,
    FlySpeed = 50,
    
    -- MISC
    FPSBoost = false,
}

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
--                    UTILITY
-- ═══════════════════════════════════════════════════════
local function getChar() return LocalPlayer.Character end
local function getHum()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end
local function getRoot()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

-- Check if player is valid target
local function isValidTarget(plr)
    if plr == LocalPlayer then return false end
    if not plr.Character then return false end
    if not plr.Character.Parent then return false end
    
    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
    local head = plr.Character:FindFirstChild("Head")
    local root = plr.Character:FindFirstChild("HumanoidRootPart")
    
    if not hum or not head or not root then return false end
    if hum.Health <= 0 then return false end
    
    -- Team check
    if Config.AimbotTeamCheck then
        if plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team then
            return false
        end
    end
    
    -- Distance check
    if Config.AimbotMaxDistance > 0 then
        local myRoot = getRoot()
        if myRoot then
            local dist = (myRoot.Position - root.Position).Magnitude
            if dist > Config.AimbotMaxDistance then return false end
        end
    end
    
    return true
end

-- Wall check
local function isVisible(targetPart)
    if not Config.AimbotWallCheck then return true end
    
    local myRoot = getRoot()
    if not myRoot then return false end
    
    local origin = Camera.CFrame.Position
    local target = targetPart.Position
    
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {getChar(), Camera, targetPart}
    
    local result = Workspace:Raycast(origin, target - origin, params)
    if result and result.Instance then
        local hitChar = result.Instance:FindFirstAncestorOfClass("Model")
        -- Check if hit is same character or ignore
        if hitChar and hitChar:FindFirstChildOfClass("Humanoid") then
            return hitChar == targetPart.Parent
        end
    end
    return true
end

-- Get closest target
local function getClosestTarget(fov)
    local closest = nil
    local closestValue = math.huge
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if isValidTarget(plr) then
            local targetPart = plr.Character:FindFirstChild(Config.AimbotLockPart)
                or plr.Character:FindFirstChild("Head")
            
            if targetPart then
                -- Visibility check
                if Config.AimbotVisibleCheck and not isVisible(targetPart) then
                    continue
                end
                
                local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local dist = (center - Vector2.new(pos.X, pos.Y)).Magnitude
                    if dist <= fov then
                        local value = dist
                        if Config.AimbotPriority == "Health" then
                            value = plr.Character:FindFirstChildOfClass("Humanoid").Health
                        end
                        if value < closestValue then
                            closestValue = value
                            closest = plr
                        end
                    end
                end
            end
        end
    end
    
    return closest
end

-- Prediction
local function getPredictedPosition(part)
    if not Config.AimbotPrediction then return part.Position end
    
    local ping = LocalPlayer:GetNetworkPing() * 2
    local velocity = part.AssemblyLinearVelocity
    local gravity = Workspace.Gravity
    
    -- Predict position with ping
    local predictedPos = part.Position + velocity * (ping + 0.05)
    
    return predictedPos
end

-- ═══════════════════════════════════════════════════════
--                    UI CREATION
-- ═══════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NarakuRivalsV3"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = game.CoreGui

-- Floating Open Button
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

local OBC = Instance.new("UICorner")
OBC.CornerRadius = UDim.new(1, 0)
OBC.Parent = OpenBtn

local OBS = Instance.new("UIStroke")
OBS.Color = Color3.fromRGB(255, 255, 255)
OBS.Thickness = 2
OBS.Transparency = 0.3
OBS.Parent = OpenBtn

-- Main Frame
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 0, 0, 0)
Main.Position = UDim2.new(0.5, -310, 0.5, -280)
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

Main:TweenSize(UDim2.new(0, 620, 0, 560), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.5, true)

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 70)
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
Title.Text = "奈  NARAKU - RIVALS v3.0 奈"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 22
Title.Font = Enum.Font.GothamBlack
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Sub = Instance.new("TextLabel")
Sub.Size = UDim2.new(0, 280, 0, 20)
Sub.Position = UDim2.new(0, 22, 1, -22)
Sub.BackgroundTransparency = 1
Sub.Text = "🎯 FIXED AIMBOT + SILENT AIM"
Sub.TextColor3 = Color3.fromRGB(80, 230, 130)
Sub.TextSize = 11
Sub.Font = Enum.Font.GothamBold
Sub.TextXAlignment = Enum.TextXAlignment.Left
Sub.Parent = Header

-- Minimize
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 34, 0, 34)
MinBtn.Position = UDim2.new(1, -88, 0, 18)
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
CloseBtn.Position = UDim2.new(1, -48, 0, 18)
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

-- Status Bar
local StatusBar = Instance.new("Frame")
StatusBar.Size = UDim2.new(1, -20, 0, 28)
StatusBar.Position = UDim2.new(0, 10, 0, 76)
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
StatusText.Text = "🎯 Hold Right Click to Aim"
StatusText.TextColor3 = Theme.Text
StatusText.TextSize = 11
StatusText.Font = Enum.Font.GothamBold
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.Parent = StatusBar

-- Tab Bar
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -20, 0, 36)
TabBar.Position = UDim2.new(0, 10, 0, 110)
TabBar.BackgroundColor3 = Theme.Sec
TabBar.BorderSizePixel = 0
TabBar.Parent = Main

local TBC = Instance.new("UICorner")
TBC.CornerRadius = UDim.new(0, 10)
TBC.Parent = TabBar

local TBP = Instance.new("UIPadding")
TBP.PaddingLeft = UDim.new(0, 5)
TBP.PaddingRight = UDim.new(0, 5)
TBP.PaddingTop = UDim.new(0, 4)
TBP.PaddingBottom = UDim.new(0, 4)
TBP.Parent = TabBar

local TBL = Instance.new("UIListLayout")
TBL.FillDirection = Enum.FillDirection.Horizontal
TBL.Padding = UDim.new(0, 4)
TBL.Parent = TabBar

-- Content
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -162)
Content.Position = UDim2.new(0, 10, 0, 152)
Content.BackgroundColor3 = Theme.Sec
Content.BorderSizePixel = 0
Content.Parent = Main

local ConC = Instance.new("UICorner")
ConC.CornerRadius = UDim.new(0, 12)
ConC.Parent = Content

-- Tab system
local Tabs = {}

local function CreateTab(name, icon)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0, 118, 1, 0)
    TabBtn.BackgroundColor3 = Theme.Ter
    TabBtn.Text = icon .. " " .. name
    TabBtn.TextColor3 = Theme.Sub
    TabBtn.TextSize = 12
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.AutoButtonColor = false
    TabBtn.Parent = TabBar
    
    local TabC = Instance.new("UICorner")
    TabC.CornerRadius = UDim.new(0, 8)
    TabC.Parent = TabBtn
    
    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Size = UDim2.new(1, 0, 1, 0)
    Scroll.BackgroundTransparency = 1
    Scroll.BorderSizePixel = 0
    Scroll.ScrollBarThickness = 6
    Scroll.ScrollBarImageColor3 = Theme.Acc
    Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Scroll.Visible = false
    Scroll.Parent = Content
    
    local ScrollPad = Instance.new("UIPadding")
    ScrollPad.PaddingTop = UDim.new(0, 10)
    ScrollPad.PaddingLeft = UDim.new(0, 10)
    ScrollPad.PaddingRight = UDim.new(0, 10)
    ScrollPad.PaddingBottom = UDim.new(0, 10)
    ScrollPad.Parent = Scroll
    
    local ScrollL = Instance.new("UIListLayout")
    ScrollL.Padding = UDim.new(0, 8)
    ScrollL.SortOrder = Enum.SortOrder.LayoutOrder
    ScrollL.Parent = Scroll
    
    Tabs[name] = {Button = TabBtn, Scroll = Scroll}
    
    TabBtn.MouseButton1Click:Connect(function()
        for _, tab in pairs(Tabs) do
            tab.Scroll.Visible = false
            TweenService:Create(tab.Button, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Ter, TextColor3 = Theme.Sub}):Play()
        end
        Scroll.Visible = true
        TweenService:Create(TabBtn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Acc, TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
    end)
    
    return Scroll
end

-- Helper UI
local function CreateSection(parent, text)
    local S = Instance.new("Frame")
    S.Size = UDim2.new(1, 0, 0, 32)
    S.BackgroundColor3 = Theme.Bg
    S.BackgroundTransparency = 0.5
    S.BorderSizePixel = 0
    S.Parent = parent
    
    local SC = Instance.new("UICorner")
    SC.CornerRadius = UDim.new(0, 8)
    SC.Parent = S
    
    local L = Instance.new("Frame")
    L.Size = UDim2.new(0, 4, 0, 18)
    L.Position = UDim2.new(0, 10, 0.5, -9)
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
    T.TextSize = 13
    T.Font = Enum.Font.GothamBlack
    T.TextXAlignment = Enum.TextXAlignment.Left
    T.Parent = S
end

local function CreateToggle(parent, name, icon, default, callback)
    local B = Instance.new("TextButton")
    B.Size = UDim2.new(1, 0, 0, 46)
    B.BackgroundColor3 = Theme.Ter
    B.Text = ""
    B.AutoButtonColor = false
    B.Parent = parent
    
    local BC = Instance.new("UICorner")
    BC.CornerRadius = UDim.new(0, 10)
    BC.Parent = B
    
    local BS = Instance.new("UIStroke")
    BS.Color = Color3.fromRGB(60, 50, 90)
    BS.Thickness = 1
    BS.Parent = B
    
    local I = Instance.new("TextLabel")
    I.Size = UDim2.new(0, 40, 1, 0)
    I.Position = UDim2.new(0, 5, 0, 0)
    I.BackgroundTransparency = 1
    I.Text = icon
    I.TextSize = 22
    I.Font = Enum.Font.GothamBold
    I.Parent = B
    
    local N = Instance.new("TextLabel")
    N.Size = UDim2.new(1, -120, 1, 0)
    N.Position = UDim2.new(0, 45, 0, 0)
    N.BackgroundTransparency = 1
    N.Text = name
    N.TextColor3 = Theme.Text
    N.TextSize = 14
    N.Font = Enum.Font.GothamBold
    N.TextXAlignment = Enum.TextXAlignment.Left
    N.Parent = B
    
    local Sw = Instance.new("Frame")
    Sw.Size = UDim2.new(0, 48, 0, 26)
    Sw.Position = UDim2.new(1, -58, 0.5, -13)
    Sw.BackgroundColor3 = Color3.fromRGB(50, 45, 70)
    Sw.BorderSizePixel = 0
    Sw.Parent = B
    
    local SwC = Instance.new("UICorner")
    SwC.CornerRadius = UDim.new(1, 0)
    SwC.Parent = Sw
    
    local K = Instance.new("Frame")
    K.Size = UDim2.new(0, 20, 0, 20)
    K.Position = UDim2.new(0, 3, 0.5, -10)
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
                Position = UDim2.new(1, -23, 0.5, -10),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
            TweenService:Create(BS, TweenInfo.new(0.2), {Color = Theme.Acc}):Play()
        else
            TweenService:Create(Sw, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 45, 70)}):Play()
            TweenService:Create(K, TweenInfo.new(0.2), {
                Position = UDim2.new(0, 3, 0.5, -10),
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

local function CreateSlider(parent, name, min, max, default, callback)
    local C = Instance.new("Frame")
    C.Size = UDim2.new(1, 0, 0, 60)
    C.BackgroundColor3 = Theme.Ter
    C.BorderSizePixel = 0
    C.Parent = parent
    
    local CC = Instance.new("UICorner")
    CC.CornerRadius = UDim.new(0, 10)
    CC.Parent = C
    
    local CS = Instance.new("UIStroke")
    CS.Color = Color3.fromRGB(60, 50, 90)
    CS.Thickness = 1
    CS.Parent = C
    
    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(1, -20, 0, 22)
    L.Position = UDim2.new(0, 10, 0, 5)
    L.BackgroundTransparency = 1
    L.Text = name .. ": " .. default
    L.TextColor3 = Theme.Text
    L.TextSize = 13
    L.Font = Enum.Font.GothamBold
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.Parent = C
    
    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, -20, 0, 10)
    Bar.Position = UDim2.new(0, 10, 1, -20)
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

local function CreateDropdown(parent, name, options, default, callback)
    local C = Instance.new("Frame")
    C.Size = UDim2.new(1, 0, 0, 45)
    C.BackgroundColor3 = Theme.Ter
    C.BorderSizePixel = 0
    C.Parent = parent
    
    local CC = Instance.new("UICorner")
    CC.CornerRadius = UDim.new(0, 10)
    CC.Parent = C
    
    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(0.5, 0, 1, 0)
    L.Position = UDim2.new(0, 10, 0, 0)
    L.BackgroundTransparency = 1
    L.Text = name
    L.TextColor3 = Theme.Text
    L.TextSize = 13
    L.Font = Enum.Font.GothamBold
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.Parent = C
    
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0.45, 0, 0, 32)
    Btn.Position = UDim2.new(0.53, 0, 0.5, -16)
    Btn.BackgroundColor3 = Theme.Acc
    Btn.Text = default
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextSize = 12
    Btn.Font = Enum.Font.GothamBold
    Btn.AutoButtonColor = false
    Btn.Parent = C
    
    local BtnC = Instance.new("UICorner")
    BtnC.CornerRadius = UDim.new(0, 6)
    BtnC.Parent = Btn
    
    local index = 1
    for i, v in ipairs(options) do
        if v == default then index = i break end
    end
    
    Btn.MouseButton1Click:Connect(function()
        index = index + 1
        if index > #options then index = 1 end
        local currentVal = options[index]
        Btn.Text = currentVal
        if callback then pcall(callback, currentVal) end
    end)
end

-- ═══════════════════════════════════════════════════════
--                    CREATE TABS
-- ═══════════════════════════════════════════════════════
local AimbotTab = CreateTab("Aimbot", "🎯")
local SilentTab = CreateTab("Silent", "👻")
local HitboxTab = CreateTab("Hitbox", "📦")
local ESPTab = CreateTab("ESP", "👁️")
local MoveTab = CreateTab("Move", "💨")
local MiscTab = CreateTab("Misc", "🛠️")

Tabs["Aimbot"].Scroll.Visible = true
TweenService:Create(Tabs["Aimbot"].Button, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Acc, TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()

-- ═══════════════════════════════════════════════════════
--                    🎯 AIMBOT TAB
-- ═══════════════════════════════════════════════════════
CreateSection(AimbotTab, "🎯 AIMBOT SETTINGS")

CreateToggle(AimbotTab, "Enable Aimbot", "🎯", true, function(v)
    Config.Aimbot = v
end)

CreateToggle(AimbotTab, "Auto Fire", "🔥", false, function(v)
    Config.AimbotAutoFire = v
end)

CreateToggle(AimbotTab, "Prediction", "🔮", true, function(v)
    Config.AimbotPrediction = v
end)

CreateToggle(AimbotTab, "Wall Check", "🧱", true, function(v)
    Config.AimbotWallCheck = v
end)

CreateToggle(AimbotTab, "Team Check", "👥", true, function(v)
    Config.AimbotTeamCheck = v
end)

CreateToggle(AimbotTab, "Visible Check", "👁️", true, function(v)
    Config.AimbotVisibleCheck = v
end)

CreateDropdown(AimbotTab, "Mode", {"Rage", "Legit"}, "Rage", function(v)
    Config.AimbotMode = v
end)

CreateDropdown(AimbotTab, "Lock Part", {"Head", "UpperTorso", "HumanoidRootPart"}, "Head", function(v)
    Config.AimbotLockPart = v
end)

CreateDropdown(AimbotTab, "Priority", {"Distance", "Health"}, "Distance", function(v)
    Config.AimbotPriority = v
end)

CreateSlider(AimbotTab, "FOV", 50, 1500, 800, function(v)
    Config.AimbotFOV = v
end)

CreateSlider(AimbotTab, "Smoothness", 1, 20, 7, function(v)
    Config.AimbotSmoothness = v / 20
end)

CreateSection(AimbotTab, "⚡ TRIGGER BOT")

CreateToggle(AimbotTab, "Enable Trigger Bot", "⚡", false, function(v)
    Config.TriggerBot = v
end)

CreateSlider(AimbotTab, "Trigger Delay (ms)", 0, 500, 50, function(v)
    Config.TriggerBotDelay = v
end)

-- ═══════════════════════════════════════════════════════
--                    👻 SILENT AIM TAB
-- ═══════════════════════════════════════════════════════
CreateSection(SilentTab, "👻 SILENT AIM")

CreateToggle(SilentTab, "Enable Silent Aim", "👻", true, function(v)
    Config.SilentAim = v
end)

CreateToggle(SilentTab, "Prediction", "🔮", true, function(v)
    Config.SilentAimPrediction = v
end)

CreateDropdown(SilentTab, "Target Part", {"Head", "UpperTorso", "HumanoidRootPart"}, "Head", function(v)
    Config.SilentAimTargetPart = v
end)

CreateSlider(SilentTab, "FOV", 50, 1500, 800, function(v)
    Config.SilentAimFOV = v
end)

CreateSlider(SilentTab, "Hitchance (%)", 0, 100, 100, function(v)
    Config.SilentAimHitchance = v
end)

-- ═══════════════════════════════════════════════════════
--                    📦 HITBOX TAB
-- ═══════════════════════════════════════════════════════
CreateSection(HitboxTab, "📦 HITBOX EXPANDER")

CreateToggle(HitboxTab, "Enable Hitbox", "📦", false, function(v)
    Config.HitboxExpander = v
    if not v then
        for target, orig in pairs(HitboxTargets) do
            pcall(function()
                if target and target.Parent then
                    target.Size = orig.size
                    target.Transparency = orig.transparency
                    target.CanCollide = orig.canCollide
                    target.Massless = orig.massless
                end
            end)
        end
        HitboxTargets = {}
    end
end)

CreateSlider(HitboxTab, "Size", 5, 50, 20, function(v)
    Config.HitboxSize = v
end)

CreateSlider(HitboxTab, "Range", 50, 1000, 500, function(v)
    Config.HitboxRange = v
end)

-- ═══════════════════════════════════════════════════════
--                    👁️ ESP TAB
-- ═══════════════════════════════════════════════════════
CreateSection(ESPTab, "👁️ ESP")

CreateToggle(ESPTab, "Enable ESP", "👁️", true, function(v)
    Config.ESP = v
    if not v then
        for plr, esp in pairs(ESPs) do
            pcall(function()
                if esp.box then esp.box:Remove() end
                if esp.name then esp.name:Remove() end
                if esp.health then esp.health:Remove() end
                if esp.dist then esp.dist:Remove() end
                if esp.tracer then esp.tracer:Remove() end
            end)
        end
        ESPs = {}
    end
end)

CreateToggle(ESPTab, "Box ESP", "📦", true, function(v)
    Config.ESPBox = v
end)

CreateToggle(ESPTab, "Name ESP", "📝", true, function(v)
    Config.ESPName = v
end)

CreateToggle(ESPTab, "Distance ESP", "📏", true, function(v)
    Config.ESPDistance = v
end)

CreateToggle(ESPTab, "Health ESP", "❤️", true, function(v)
    Config.ESPHealth = v
end)

CreateToggle(ESPTab, "Tracer ESP", "📡", true, function(v)
    Config.ESPTracer = v
end)

-- ═══════════════════════════════════════════════════════
--                    💨 MOVEMENT TAB
-- ═══════════════════════════════════════════════════════
CreateSection(MoveTab, "💨 MOVEMENT")

CreateToggle(MoveTab, "Infinite Jump", "🦘", false, function(v)
    Config.InfiniteJump = v
end)

CreateToggle(MoveTab, "Fly", "🕊️", false, function(v)
    Config.Fly = v
    if v then
        local root = getRoot()
        if root and not flyBV then
            flyBV = Instance.new("BodyVelocity")
            flyBV.Name = "NarakuFly"
            flyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            flyBV.Velocity = Vector3.zero
            flyBV.Parent = root
        end
    else
        if flyBV then flyBV:Destroy() flyBV = nil end
    end
end)

CreateSlider(MoveTab, "Fly Speed", 10, 300, 50, function(v)
    Config.FlySpeed = v
end)

-- ═══════════════════════════════════════════════════════
--                    🛠️ MISC TAB
-- ═══════════════════════════════════════════════════════
CreateSection(MiscTab, "🛠️ UTILITIES")

CreateToggle(MiscTab, "FPS Boost", "⚡", false, function(v)
    Config.FPSBoost = v
    if v then
        pcall(function()
            local l = game:GetService("Lighting")
            l.GlobalShadows = false
            l.FogEnd = 9e9
            l.Brightness = 2
        end)
    end
end)

-- ═══════════════════════════════════════════════════════
--                    ⚙️ CORE - FIXED AIMBOT
-- ═══════════════════════════════════════════════════════

-- Aimbot Key Hold Detection
local aimbotHolding = false

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Config.AimbotKey then
        aimbotHolding = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Config.AimbotKey then
        aimbotHolding = false
    end
end)

-- ✅ FIXED AIMBOT - Uses Camera.CFrame directly
RunService.RenderStepped:Connect(function(dt)
    if not Config.Aimbot then return end
    if not aimbotHolding then return end
    
    local target = getClosestTarget(Config.AimbotFOV)
    if not target or not target.Character then return end
    
    local targetPart = target.Character:FindFirstChild(Config.AimbotLockPart)
        or target.Character:FindFirstChild("Head")
    if not targetPart then return end
    
    -- Get predicted position
    local targetPos = getPredictedPosition(targetPart)
    
    if Config.AimbotMode == "Rage" then
        -- Direct lock
        local myPos = Camera.CFrame.Position
        local lookAt = CFrame.lookAt(myPos, targetPos)
        Camera.CFrame = lookAt
    else
        -- Smooth lock
        local currentLook = Camera.CFrame.LookVector
        local targetLook = (targetPos - Camera.CFrame.Position).Unit
        local smoothFactor = math.clamp(Config.AimbotSmoothness, 0.01, 0.5)
        local newLook = currentLook:Lerp(targetLook, smoothFactor)
        Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, Camera.CFrame.Position + newLook)
    end
    
    -- Auto fire
    if Config.AimbotAutoFire then
        local tool = getChar() and getChar():FindFirstChildOfClass("Tool")
        if tool then pcall(function() tool:Activate() end) end
    end
end)

-- ✅ FIXED SILENT AIM - Hooks Ray + Mouse.Hit
local originalNamecall
local originalIndex

pcall(function()
    local mt = getrawmetatable(game)
    if not mt then return end
    setreadonly(mt, false)
    
    originalNamecall = mt.__namecall
    originalIndex = mt.__index
    
    -- Hook __namecall
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        -- Silent Aim on Raycast
        if Config.SilentAim and (method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" or method == "Raycast") then
            if math.random(100) <= Config.SilentAimHitchance then
                local target = getClosestTarget(Config.SilentAimFOV)
                if target and target.Character then
                    local targetPart = target.Character:FindFirstChild(Config.SilentAimTargetPart)
                        or target.Character:FindFirstChild("Head")
                    if targetPart then
                        local targetPos = getPredictedPosition(targetPart)
                        
                        -- For Raycast (new API)
                        if method == "Raycast" then
                            local origin = args[1]
                            local direction = targetPos - origin
                            args[2] = direction
                        -- For FindPartOnRay (old API)
                        elseif method == "FindPartOnRay" then
                            local ray = args[1]
                            if ray then
                                local origin = ray.Origin
                                local newDir = targetPos - origin
                                args[1] = Ray.new(origin, newDir)
                            end
                        end
                    end
                end
            end
        end
        
        -- Silent Aim on Mouse.Hit
        if Config.SilentAim and method == "GetMouse" then
            -- Do nothing special, let it pass
        end
        
        return originalNamecall(self, unpack(args))
    end)
    
    -- Hook __index for Mouse.Hit
    mt.__index = newcclosure(function(self, key)
        if Config.SilentAim and key == "Hit" then
            if self == Mouse or (typeof(self) == "Instance" and self.ClassName == "Mouse") then
                if math.random(100) <= Config.SilentAimHitchance then
                    local target = getClosestTarget(Config.SilentAimFOV)
                    if target and target.Character then
                        local targetPart = target.Character:FindFirstChild(Config.SilentAimTargetPart)
                            or target.Character:FindFirstChild("Head")
                        if targetPart then
                            return getPredictedPosition(targetPart)
                        end
                    end
                end
            end
        end
        return originalIndex(self, key)
    end)
    
    setreadonly(mt, true)
end)

-- FOV Circle
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = true
fovCircle.Thickness = 2
fovCircle.Color = Color3.fromRGB(160, 60, 255)
fovCircle.Transparency = 1
fovCircle.NumSides = 64
fovCircle.Filled = false

RunService.RenderStepped:Connect(function()
    if Config.FOVCircle then
        fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        fovCircle.Radius = Config.AimbotFOV
        fovCircle.Visible = true
        if Config.FOVCircleRainbow then
            fovCircle.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
        end
    else
        fovCircle.Visible = false
    end
end)

-- Trigger Bot
local lastTrigger = 0
RunService.Heartbeat:Connect(function()
    if not Config.TriggerBot then return end
    if tick() - lastTrigger < Config.TriggerBotDelay / 1000 then return end
    
    local target = Mouse.Target
    if target and target.Parent then
        local hum = target.Parent:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then
            local plr = Players:GetPlayerFromCharacter(target.Parent)
            if plr and plr ~= LocalPlayer then
                lastTrigger = tick()
                local tool = getChar() and getChar():FindFirstChildOfClass("Tool")
                if tool then pcall(function() tool:Activate() end) end
            end
        end
    end
end)

-- Hitbox Expander
HitboxTargets = {}
task.spawn(function()
    while task.wait(0.15) do
        if Config.HitboxExpander then
            local myRoot = getRoot()
            if myRoot then
                local myPos = myRoot.Position
                
                for _, plr in pairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character then
                        local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                        local root = plr.Character:FindFirstChild("HumanoidRootPart")
                        
                        if hum and root and hum.Health > 0 then
                            local dist = (root.Position - myPos).Magnitude
                            
                            if dist < Config.HitboxRange then
                                if not HitboxTargets[root] then
                                    HitboxTargets[root] = {
                                        size = root.Size,
                                        transparency = root.Transparency,
                                        canCollide = root.CanCollide,
                                        massless = root.Massless,
                                    }
                                end
                                root.Size = Vector3.new(Config.HitboxSize, Config.HitboxSize, Config.HitboxSize)
                                root.Transparency = Config.HitboxTransparency
                                root.CanCollide = false
                                root.Massless = true
                            elseif HitboxTargets[root] then
                                root.Size = HitboxTargets[root].size
                                root.Transparency = HitboxTargets[root].transparency
                                root.CanCollide = HitboxTargets[root].canCollide
                                root.Massless = HitboxTargets[root].massless
                                HitboxTargets[root] = nil
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- ESP
ESPs = {}
task.spawn(function()
    while task.wait() do
        if Config.ESP then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                    local root = plr.Character:FindFirstChild("HumanoidRootPart")
                    
                    if hum and root then
                        if not ESPs[plr] then
                            local esp = {}
                            
                            if Config.ESPBox then
                                esp.box = Drawing.new("Square")
                                esp.box.Thickness = 1.5
                                esp.box.Color = Theme.Acc2
                                esp.box.Transparency = 1
                                esp.box.Filled = false
                            end
                            
                            esp.name = Drawing.new("Text")
                            esp.name.Size = 14
                            esp.name.Center = true
                            esp.name.Outline = true
                            esp.name.Color = Color3.fromRGB(255, 255, 255)
                            
                            if Config.ESPHealth then
                                esp.health = Drawing.new("Text")
                                esp.health.Size = 12
                                esp.health.Center = true
                                esp.health.Outline = true
                                esp.health.Color = Color3.fromRGB(80, 230, 130)
                            end
                            
                            if Config.ESPDistance then
                                esp.dist = Drawing.new("Text")
                                esp.dist.Size = 12
                                esp.dist.Center = true
                                esp.dist.Outline = true
                                esp.dist.Color = Color3.fromRGB(80, 180, 255)
                            end
                            
                            if Config.ESPTracer then
                                esp.tracer = Drawing.new("Line")
                                esp.tracer.Thickness = 1.5
                                esp.tracer.Color = Theme.Acc
                                esp.tracer.Transparency = 1
                            end
                            
                            ESPs[plr] = esp
                        end
                        
                        local esp = ESPs[plr]
                        local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                        
                        if onScreen and hum.Health > 0 then
                            if esp.box then
                                local minX, minY = math.huge, math.huge
                                local maxX, maxY = -math.huge, -math.huge
                                for _, part in pairs(plr.Character:GetChildren()) do
                                    if part:IsA("BasePart") then
                                        local corners = {
                                            part.CFrame * CFrame.new(part.Size.X/2, part.Size.Y/2, part.Size.Z/2),
                                            part.CFrame * CFrame.new(-part.Size.X/2, -part.Size.Y/2, -part.Size.Z/2),
                                            part.CFrame * CFrame.new(part.Size.X/2, -part.Size.Y/2, part.Size.Z/2),
                                            part.CFrame * CFrame.new(-part.Size.X/2, part.Size.Y/2, -part.Size.Z/2),
                                        }
                                        for _, corner in ipairs(corners) do
                                            local pos = Camera:WorldToViewportPoint(corner.Position)
                                            if pos.Z > 0 then
                                                minX = math.min(minX, pos.X)
                                                maxX = math.max(maxX, pos.X)
                                                minY = math.min(minY, pos.Y)
                                                maxY = math.max(maxY, pos.Y)
                                            end
                                        end
                                    end
                                end
                                if minX < math.huge then
                                    esp.box.Size = Vector2.new(maxX - minX, maxY - minY)
                                    esp.box.Position = Vector2.new(minX, minY)
                                    esp.box.Visible = true
                                end
                            end
                            
                            if esp.name then
                                esp.name.Text = plr.Name
                                esp.name.Position = Vector2.new(rootPos.X, rootPos.Y - 55)
                                esp.name.Visible = true
                            end
                            
                            if esp.health then
                                esp.health.Text = math.floor(hum.Health) .. " HP"
                                esp.health.Position = Vector2.new(rootPos.X, rootPos.Y - 38)
                                esp.health.Visible = true
                            end
                            
                            if esp.dist then
                                local myRoot = getRoot()
                                if myRoot then
                                    local d = math.floor((myRoot.Position - root.Position).Magnitude)
                                    esp.dist.Text = d .. " studs"
                                    esp.dist.Position = Vector2.new(rootPos.X, rootPos.Y - 22)
                                    esp.dist.Visible = true
                                end
                            end
                            
                            if esp.tracer then
                                esp.tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                                esp.tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                                esp.tracer.Visible = true
                            end
                        else
                            if esp.box then esp.box.Visible = false end
                            if esp.name then esp.name.Visible = false end
                            if esp.health then esp.health.Visible = false end
                            if esp.dist then esp.dist.Visible = false end
                            if esp.tracer then esp.tracer.Visible = false end
                        end
                    end
                end
            end
        end
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump then
        local hum = getHum()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- Fly Loop
local flyBV = nil
RunService.Heartbeat:Connect(function()
    if Config.Fly and flyBV and flyBV.Parent then
        local moveDir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir -= Vector3.new(0, 1, 0) end
        
        if moveDir.Magnitude > 0 then
            flyBV.Velocity = moveDir.Unit * Config.FlySpeed
        else
            flyBV.Velocity = Vector3.zero
        end
    end
end)

-- Character respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
end)

-- ═══════════════════════════════════════════════════════
--                    CONTROLS
-- ═══════════════════════════════════════════════════════

CloseBtn.MouseButton1Click:Connect(function()
    for k, v in pairs(Config) do
        if type(v) == "boolean" then Config[k] = false end
    end
    if flyBV then flyBV:Destroy() end
    Main:TweenSize(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Back, 0.3, true)
    task.wait(0.4)
    ScreenGui:Destroy()
    print("🔒 Naraku Rivals v3.0 Closed")
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

OpenBtn.MouseButton1Click:Connect(function()
    OpenBtn.Visible = false
    Main.Visible = true
    Main.Size = UDim2.new(0, 0, 0, 0)
    Main:TweenSize(UDim2.new(0, 620, 0, 560), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.5, true)
end)

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
--                    WELCOME
-- ═══════════════════════════════════════════════════════
local Notify = Instance.new("Frame")
Notify.Size = UDim2.new(0, 400, 0, 100)
Notify.Position = UDim2.new(0.5, -200, 0, -130)
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
NT.Position = UDim2.new(0, 70, 0, 15)
NT.BackgroundTransparency = 1
NT.Text = "NARAKU - RIVALS v3.0"
NT.TextColor3 = Theme.Text
NT.TextSize = 16
NT.Font = Enum.Font.GothamBlack
NT.TextXAlignment = Enum.TextXAlignment.Left
NT.Parent = Notify

local NM = Instance.new("TextLabel")
NM.Size = UDim2.new(1, -75, 0, 25)
NM.Position = UDim2.new(0, 70, 0, 50)
NM.BackgroundTransparency = 1
NM.Text = "🎯 Hold Right Click to Aim"
NM.TextColor3 = Theme.Success
NM.TextSize = 12
NM.Font = Enum.Font.GothamBold
NM.TextXAlignment = Enum.TextXAlignment.Left
NM.Parent = Notify

TweenService:Create(Notify, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Position = UDim2.new(0.5, -200, 0, 20)}):Play()
task.wait(5)
TweenService:Create(Notify, TweenInfo.new(0.5), {Position = UDim2.new(0.5, -200, 0, -130)}):Play()
task.wait(0.5)
Notify:Destroy()

-- ═══════════════════════════════════════════════════════
--                    CONSOLE
-- ═══════════════════════════════════════════════════════
print("╔════════════════════════════════════════════╗")
print("║   NARAKU - RIVALS v3.0 FIXED               ║")
print("║                                            ║")
print("║   ✓ Aimbot (Fixed - Real hits)             ║")
print("║   ✓ Silent Aim (Fixed - 100% Hit)          ║")
print("║   ✓ Hitbox Expander                        ║")
print("║   ✓ ESP (Box/Name/Health/Dist/Tracer)      ║")
print("║   ✓ Trigger Bot                            ║")
print("║   ✓ FOV Circle                             ║")
print("║                                            ║")
print("║   🎯 Hold RIGHT CLICK = Aimbot             ║")
print("║   👻 Silent Aim = Automatic                ║")
print("║   📌 RightShift = Toggle UI                ║")
print("╚════════════════════════════════════════════╝")
