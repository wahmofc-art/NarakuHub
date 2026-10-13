--[[
    ╔═══════════════════════════════════════════════╗
    ║      NARAKU - RIVALS v4.0 - REAL SILENT AIM   ║
    ║                                                ║
    ║   ✓ Silent Aim (Real)                         ║
    ║   ✓ Aimbot (Strong)                           ║
    ║   ✓ Hitbox Expander                           ║
    ║   ✓ ESP (Full)                                ║
    ║   ✓ FOV Circle                                ║
    ║   ✓ Infinite Jump                             ║
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

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ═══════════════════════════════════════════════════════
--                    CLEANUP
-- ═══════════════════════════════════════════════════════
for _, name in pairs({"NarakuRivals", "NarakuRivalsV1", "NarakuRivalsV2", "NarakuRivalsV3", "NarakuRivalsV4"}) do
    local old = game.CoreGui:FindFirstChild(name)
    if old then old:Destroy() end
end

-- ═══════════════════════════════════════════════════════
--                    CONFIG
-- ═══════════════════════════════════════════════════════
local Config = {
    -- AIMBOT
    Aimbot = true,
    AimbotKey = Enum.UserInputType.MouseButton2,
    AimbotMode = "Rage",
    AimbotLockPart = "Head",
    AimbotFOV = 500,
    AimbotSmoothness = 0.5,
    AimbotPrediction = true,
    AimbotWallCheck = false,
    AimbotTeamCheck = true,
    AimbotAutoFire = false,
    AimbotPriority = "Distance",
    
    -- SILENT AIM
    SilentAim = true,
    SilentAimFOV = 500,
    SilentAimHitchance = 100,
    SilentAimTargetPart = "Head",
    SilentAimPrediction = true,
    
    -- HITBOX
    HitboxExpander = false,
    HitboxSize = 20,
    HitboxRange = 500,
    
    -- FOV CIRCLE
    FOVCircle = true,
    FOVCircleRainbow = true,
    
    -- ESP
    ESP = true,
    ESPBox = true,
    ESPName = true,
    ESPDistance = true,
    ESPHealth = true,
    ESPTracer = true,
    
    -- MOVEMENT
    InfiniteJump = false,
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

local function isValidTarget(plr)
    if plr == LocalPlayer then return false end
    if not plr.Character or not plr.Character.Parent then return false end
    
    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
    local head = plr.Character:FindFirstChild("Head")
    local root = plr.Character:FindFirstChild("HumanoidRootPart")
    
    if not hum or not head or not root then return false end
    if hum.Health <= 0 then return false end
    
    if Config.AimbotTeamCheck then
        if plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team then
            return false
        end
    end
    
    return true
end

local function getClosestTarget(fov, partName)
    local closest = nil
    local closestValue = math.huge
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if isValidTarget(plr) then
            local targetPart = plr.Character:FindFirstChild(partName or "Head")
                or plr.Character:FindFirstChild("Head")
                or plr.Character:FindFirstChild("UpperTorso")
                or plr.Character:FindFirstChild("HumanoidRootPart")
            
            if targetPart then
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
                            closest = {plr = plr, part = targetPart}
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
    if not Config.AimbotPrediction and not Config.SilentAimPrediction then 
        return part.Position 
    end
    
    local ping = 0.1
    pcall(function()
        ping = LocalPlayer:GetNetworkPing() * 2
    end)
    
    local velocity = part.AssemblyLinearVelocity
    return part.Position + velocity * (ping + 0.05)
end

-- ═══════════════════════════════════════════════════════
--                    SILENT AIM (Real)
-- ═══════════════════════════════════════════════════════

-- Method 1: hookmetamethod (Best)
pcall(function()
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        if Config.SilentAim and (method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRayWithWhitelist") then
            if math.random(100) <= Config.SilentAimHitchance then
                local target = getClosestTarget(Config.SilentAimFOV, Config.SilentAimTargetPart)
                if target and target.part then
                    local predPos = getPredictedPosition(target.part)
                    local ray = args[1]
                    if typeof(ray) == "Ray" then
                        local origin = ray.Origin
                        local newDir = predPos - origin
                        args[1] = Ray.new(origin, newDir)
                    end
                end
            end
        end
        
        if Config.SilentAim and method == "Raycast" then
            if math.random(100) <= Config.SilentAimHitchance then
                local target = getClosestTarget(Config.SilentAimFOV, Config.SilentAimTargetPart)
                if target and target.part then
                    local predPos = getPredictedPosition(target.part)
                    local origin = args[1]
                    local direction = args[2]
                    
                    if typeof(origin) == "Vector3" and typeof(direction) == "Vector3" then
                        args[2] = (predPos - origin).Unit * direction.Magnitude
                    end
                end
            end
        end
        
        return oldNamecall(self, ...)
    end))
end)

-- Method 2: Hook __index for Mouse.Hit and Mouse.Target
pcall(function()
    local mt = getrawmetatable(game)
    local oldIndex = mt.__index
    setreadonly(mt, false)
    mt.__index = newcclosure(function(self, key)
        if Config.SilentAim and (key == "Hit" or key == "Target") then
            if typeof(self) == "Instance" and (self == Mouse or self.ClassName == "Mouse") then
                if math.random(100) <= Config.SilentAimHitchance then
                    local target = getClosestTarget(Config.SilentAimFOV, Config.SilentAimTargetPart)
                    if target and target.part then
                        if key == "Hit" then
                            return getPredictedPosition(target.part)
                        elseif key == "Target" then
                            return target.part
                        end
                    end
                end
            end
        end
        return oldIndex(self, key)
    end)
    setreadonly(mt, true)
end)

-- ═══════════════════════════════════════════════════════
--                    AIMBOT (Strong)
-- ═══════════════════════════════════════════════════════
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

RunService.RenderStepped:Connect(function(dt)
    if not Config.Aimbot then return end
    if not aimbotHolding then return end
    
    local target = getClosestTarget(Config.AimbotFOV, Config.AimbotLockPart)
    if not target or not target.part then return end
    
    local targetPos = getPredictedPosition(target.part)
    local camPos = Camera.CFrame.Position
    
    if Config.AimbotMode == "Rage" then
        Camera.CFrame = CFrame.new(camPos, targetPos)
    else
        local currentLook = Camera.CFrame.LookVector
        local targetLook = (targetPos - camPos).Unit
        local smoothFactor = math.clamp(Config.AimbotSmoothness, 0.01, 0.99)
        local newLook = currentLook:Lerp(targetLook, smoothFactor)
        Camera.CFrame = CFrame.new(camPos, camPos + newLook)
    end
    
    if Config.AimbotAutoFire then
        local tool = getChar() and getChar():FindFirstChildOfClass("Tool")
        if tool then 
            pcall(function() tool:Activate() end) 
        end
        pcall(function()
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end)
    end
end)

-- ═══════════════════════════════════════════════════════
--                    FOV CIRCLE
-- ═══════════════════════════════════════════════════════
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

-- ═══════════════════════════════════════════════════════
--                    HITBOX EXPANDER
-- ═══════════════════════════════════════════════════════
local HitboxTargets = {}
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
                                root.Transparency = 0.5
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

-- ═══════════════════════════════════════════════════════
--                    ESP
-- ═══════════════════════════════════════════════════════
local ESPs = {}
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

-- ═══════════════════════════════════════════════════════
--                    UI
-- ═══════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NarakuRivalsV4"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game.CoreGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 340, 0, 420)
Main.Position = UDim2.new(0.5, -170, 0.5, -210)
Main.BackgroundColor3 = Theme.Bg
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local MC = Instance.new("UICorner")
MC.CornerRadius = UDim.new(0, 14)
MC.Parent = Main

local MS = Instance.new("UIStroke")
MS.Color = Theme.Acc
MS.Thickness = 2
MS.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Theme.Sec
Title.BorderSizePixel = 0
Title.Text = "奈 NARAKU v4.0 奈"
Title.TextColor3 = Theme.Text
Title.TextSize = 18
Title.Font = Enum.Font.GothamBlack
Title.Parent = Main

local TC = Instance.new("UICorner")
TC.CornerRadius = UDim.new(0, 14)
TC.Parent = Title

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, -20, 0, 25)
InfoLabel.Position = UDim2.new(0, 10, 0, 50)
InfoLabel.BackgroundColor3 = Theme.Ter
InfoLabel.Text = "🎯 Hold Right Click = Aimbot"
InfoLabel.TextColor3 = Theme.Text
InfoLabel.TextSize = 12
InfoLabel.Font = Enum.Font.GothamBold
InfoLabel.Parent = Main

local IC = Instance.new("UICorner")
IC.CornerRadius = UDim.new(0, 6)
IC.Parent = InfoLabel

local function CreateToggle(yPos, name, default, callback)
    local B = Instance.new("TextButton")
    B.Size = UDim2.new(1, -20, 0, 42)
    B.Position = UDim2.new(0, 10, 0, yPos)
    B.BackgroundColor3 = Theme.Ter
    B.Text = name .. " : " .. (default and "ON" or "OFF")
    B.TextColor3 = default and Theme.Success or Theme.Danger
    B.TextSize = 13
    B.Font = Enum.Font.GothamBold
    B.AutoButtonColor = false
    B.Parent = Main
    
    local BC = Instance.new("UICorner")
    BC.CornerRadius = UDim.new(0, 8)
    BC.Parent = B
    
    local state = default
    B.MouseButton1Click:Connect(function()
        state = not state
        B.Text = name .. " : " .. (state and "ON" or "OFF")
        B.TextColor3 = state and Theme.Success or Theme.Danger
        if callback then pcall(callback, state) end
    end)
end

CreateToggle(85, "🎯 Aimbot", true, function(v) Config.Aimbot = v end)
CreateToggle(133, "👻 Silent Aim", true, function(v) Config.SilentAim = v end)
CreateToggle(181, "📦 Hitbox", false, function(v) Config.HitboxExpander = v end)
CreateToggle(229, "👁️ ESP", true, function(v) Config.ESP = v end)
CreateToggle(277, "⭕ FOV Circle", true, function(v) Config.FOVCircle = v end)
CreateToggle(325, "🦘 Inf Jump", false, function(v) Config.InfiniteJump = v end)

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(1, -20, 0, 38)
CloseBtn.Position = UDim2.new(0, 10, 1, -48)
CloseBtn.BackgroundColor3 = Theme.Danger
CloseBtn.Text = "✖ CLOSE"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = Main

local CC = Instance.new("UICorner")
CC.CornerRadius = UDim.new(0, 8)
CC.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    for k, v in pairs(Config) do
        if type(v) == "boolean" then Config[k] = false end
    end
    Main:TweenSize(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Back, 0.3, true)
    task.wait(0.4)
    ScreenGui:Destroy()
    print("🔒 Naraku Rivals v4.0 Closed")
end)

-- Minimize
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 34, 0, 34)
MinBtn.Position = UDim2.new(1, -48, 0, 6)
MinBtn.BackgroundColor3 = Theme.Ter
MinBtn.Text = "—"
MinBtn.TextColor3 = Theme.Text
MinBtn.TextSize = 18
MinBtn.Font = Enum.Font.GothamBold
MinBtn.AutoButtonColor = false
MinBtn.Parent = Main

local MNC = Instance.new("UICorner")
MNC.CornerRadius = UDim.new(0, 8)
MNC.Parent = MinBtn

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        Main:TweenSize(UDim2.new(0, 340, 0, 45), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
    else
        Main:TweenSize(UDim2.new(0, 340, 0, 420), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
    end
end)

-- RightShift Toggle
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        Main.Visible = not Main.Visible
    end
end)

-- ═══════════════════════════════════════════════════════
--                    CONSOLE
-- ═══════════════════════════════════════════════════════
print("╔════════════════════════════════════════════╗")
print("║   NARAKU RIVALS v4.0 - LOADED              ║")
print("║                                            ║")
print("║   ✓ Silent Aim (REAL)                      ║")
print("║   ✓ Aimbot (STRONG)                        ║")
print("║   ✓ Hitbox                                 ║")
print("║   ✓ ESP                                    ║")
print("║                                            ║")
print("║   🎯 Hold RIGHT CLICK = Aimbot             ║")
print("║   👻 Silent Aim = Automatic                ║")
print("║   📌 RightShift = Toggle UI                ║")
print("╚════════════════════════════════════════════╝")
