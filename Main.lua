--[=[
Grand Line Companion — واجهة مساعدة آمنة داخل Roblox Studio
طريقة الاستخدام: ضع هذا الملف كـ LocalScript داخل StarterPlayer > StarterPlayerScripts.
الواجهة تسجل أهدافك وخطة نقاطك وملاحظاتك محليًا طوال الجلسة فقط.
لا تغيّر خصائص اللعب، ولا تنفذ قتالًا أو زراعة آلية، ولا تستدعي RemoteEvents.
]=]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local GUI_NAME = "GrandLineCompanion"
local previous = playerGui:FindFirstChild(GUI_NAME)
if previous then
    previous:Destroy()
end

local Theme = {
    Background = Color3.fromRGB(14, 16, 25),
    Panel = Color3.fromRGB(23, 26, 39),
    Card = Color3.fromRGB(32, 36, 52),
    CardHover = Color3.fromRGB(41, 46, 66),
    Accent = Color3.fromRGB(116, 91, 255),
    AccentLight = Color3.fromRGB(160, 143, 255),
    Green = Color3.fromRGB(78, 205, 145),
    Red = Color3.fromRGB(244, 100, 115),
    Text = Color3.fromRGB(244, 245, 250),
    Muted = Color3.fromRGB(166, 172, 190),
    Track = Color3.fromRGB(49, 54, 73),
}

local function make(className, parent, properties)
    local object = Instance.new(className)
    for property, value in pairs(properties or {}) do
        object[property] = value
    end
    object.Parent = parent
    return object
end

local function addCorner(object, radius)
    make("UICorner", object, {CornerRadius = UDim.new(0, radius or 10)})
end

local function addStroke(object, color, thickness, transparency)
    return make("UIStroke", object, {
        Color = color or Theme.Track,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
    })
end

local function addLabel(parent, text, size, position, textSize, color, font)
    return make("TextLabel", parent, {
        BackgroundTransparency = 1,
        Text = text,
        Size = size,
        Position = position,
        TextColor3 = color or Theme.Text,
        TextSize = textSize or 14,
        Font = font or Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextWrapped = true,
    })
end

local screenGui = make("ScreenGui", playerGui, {
    Name = GUI_NAME,
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 20,
})

local main = make("Frame", screenGui, {
    Name = "Main",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(650, 510),
    BackgroundColor3 = Theme.Background,
    BorderSizePixel = 0,
})
addCorner(main, 16)
addStroke(main, Theme.Accent, 1.5, 0.2)

local uiScale = make("UIScale", main, {Scale = 1})

local header = make("Frame", main, {
    Name = "Header",
    Size = UDim2.new(1, 0, 0, 62),
    BackgroundColor3 = Theme.Panel,
    BorderSizePixel = 0,
})
addCorner(header, 16)

local headerFill = make("Frame", header, {
    Size = UDim2.new(1, 0, 0, 18),
    Position = UDim2.new(0, 0, 1, -18),
    BackgroundColor3 = Theme.Panel,
    BorderSizePixel = 0,
})

local title = addLabel(header, "GRAND LINE  •  رفيق المغامرة", UDim2.new(1, -150, 0, 27), UDim2.new(0, 18, 0, 8), 18, Theme.Text, Enum.Font.GothamBold)
title.Active = true
local subtitle = addLabel(header, "لوحة متابعة شخصية للجلسة", UDim2.new(1, -150, 0, 18), UDim2.new(0, 19, 0, 36), 11, Theme.Muted)
subtitle.Active = true

local minimizeButton = make("TextButton", header, {
    Name = "Minimize",
    Size = UDim2.fromOffset(34, 34),
    Position = UDim2.new(1, -88, 0, 14),
    BackgroundColor3 = Theme.Card,
    Text = "—",
    TextColor3 = Theme.Text,
    TextSize = 18,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = true,
})
addCorner(minimizeButton, 9)

local hideButton = make("TextButton", header, {
    Name = "Hide",
    Size = UDim2.fromOffset(34, 34),
    Position = UDim2.new(1, -46, 0, 14),
    BackgroundColor3 = Color3.fromRGB(91, 43, 58),
    Text = "×",
    TextColor3 = Theme.Text,
    TextSize = 22,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = true,
})
addCorner(hideButton, 9)

local body = make("Frame", main, {
    Name = "Body",
    Size = UDim2.new(1, -20, 1, -74),
    Position = UDim2.new(0, 10, 0, 68),
    BackgroundTransparency = 1,
})

local status = make("Frame", body, {
    Name = "Status",
    Size = UDim2.new(1, 0, 0, 30),
    BackgroundColor3 = Theme.Panel,
    BorderSizePixel = 0,
})
addCorner(status, 9)
local statusDot = make("Frame", status, {
    Size = UDim2.fromOffset(8, 8),
    Position = UDim2.new(0, 12, 0.5, -4),
    BackgroundColor3 = Theme.Green,
    BorderSizePixel = 0,
})
addCorner(statusDot, 8)
local statusText = addLabel(status, "جاهز • بياناتك تبقى على جهازك طوال الجلسة", UDim2.new(1, -34, 1, 0), UDim2.new(0, 27, 0, 0), 11, Theme.Muted)

local tabBar = make("Frame", body, {
    Name = "Tabs",
    Size = UDim2.new(1, 0, 0, 38),
    Position = UDim2.new(0, 0, 0, 38),
    BackgroundTransparency = 1,
})
local tabLayout = make("UIListLayout", tabBar, {
    FillDirection = Enum.FillDirection.Horizontal,
    HorizontalAlignment = Enum.HorizontalAlignment.Left,
    VerticalAlignment = Enum.VerticalAlignment.Center,
    Padding = UDim.new(0, 7),
    SortOrder = Enum.SortOrder.LayoutOrder,
})

local content = make("Frame", body, {
    Name = "Content",
    Size = UDim2.new(1, 0, 1, -102),
    Position = UDim2.new(0, 0, 0, 84),
    BackgroundColor3 = Theme.Panel,
    BorderSizePixel = 0,
    ClipsDescendants = true,
})
addCorner(content, 12)

local pages = {}
local tabButtons = {}
local tabCount = 0

local function createPage(name, caption)
    tabCount += 1
    local button = make("TextButton", tabBar, {
        Name = name .. "Tab",
        Size = UDim2.new(0.25, -6, 1, 0),
        BackgroundColor3 = Theme.Card,
        Text = caption,
        TextColor3 = Theme.Muted,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        LayoutOrder = tabCount,
    })
    addCorner(button, 9)

    local page = make("ScrollingFrame", content, {
        Name = name .. "Page",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Theme.AccentLight,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
    })
    make("UIPadding", page, {
        PaddingTop = UDim.new(0, 12),
        PaddingBottom = UDim.new(0, 12),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
    })
    make("UIListLayout", page, {
        Padding = UDim.new(0, 9),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    pages[name] = page
    tabButtons[name] = button
    button.Activated:Connect(function()
        for tabName, otherPage in pairs(pages) do
            otherPage.Visible = false
            tabButtons[tabName].BackgroundColor3 = Theme.Card
            tabButtons[tabName].TextColor3 = Theme.Muted
        end
        page.Visible = true
        button.BackgroundColor3 = Theme.Accent
        button.TextColor3 = Theme.Text
    end)
    return page
end

local function section(parent, text)
    local row = make("Frame", parent, {
        Size = UDim2.new(1, 0, 0, 27),
        BackgroundTransparency = 1,
    })
    addLabel(row, text, UDim2.new(1, 0, 1, 0), UDim2.new(0, 2, 0, 0), 14, Theme.AccentLight, Enum.Font.GothamBold)
    return row
end

local function card(parent, height)
    local frame = make("Frame", parent, {
        Size = UDim2.new(1, 0, 0, height),
        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0,
    })
    addCorner(frame, 11)
    return frame
end

local function actionButton(parent, text, position, size, color)
    local button = make("TextButton", parent, {
        Size = size,
        Position = position,
        BackgroundColor3 = color or Theme.Accent,
        Text = text,
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = true,
    })
    addCorner(button, 8)
    return button
end

local homePage = createPage("Home", "الرئيسية")
local goalsPage = createPage("Goals", "أهدافي")
local buildPage = createPage("Build", "خطة النقاط")
local notesPage = createPage("Notes", "ملاحظاتي")

-- الصفحة الرئيسية
section(homePage, "ملخص الجلسة")
local sessionCard = card(homePage, 78)
addLabel(sessionCard, "مدة الجلسة", UDim2.new(0.5, -18, 0, 20), UDim2.new(0, 14, 0, 12), 12, Theme.Muted)
local sessionValue = addLabel(sessionCard, "00:00:00", UDim2.new(0.5, -18, 0, 30), UDim2.new(0, 14, 0, 35), 20, Theme.Text, Enum.Font.GothamBold)
addLabel(sessionCard, "المستوى", UDim2.new(0.5, -18, 0, 20), UDim2.new(0.5, 2, 0, 12), 12, Theme.Muted)
local levelValue = addLabel(sessionCard, "—", UDim2.new(0.5, -18, 0, 30), UDim2.new(0.5, 2, 0, 35), 20, Theme.Text, Enum.Font.GothamBold)

section(homePage, "حالة الشخصية")
local healthCard = card(homePage, 66)
local healthText = addLabel(healthCard, "الصحة: —", UDim2.new(1, -28, 0, 22), UDim2.new(0, 14, 0, 7), 12, Theme.Text, Enum.Font.GothamBold)
local healthTrack = make("Frame", healthCard, {
    Size = UDim2.new(1, -28, 0, 12),
    Position = UDim2.new(0, 14, 0, 39),
    BackgroundColor3 = Theme.Track,
    BorderSizePixel = 0,
    ClipsDescendants = true,
})
addCorner(healthTrack, 8)
local healthFill = make("Frame", healthTrack, {
    Size = UDim2.new(0, 0, 1, 0),
    BackgroundColor3 = Theme.Green,
    BorderSizePixel = 0,
})
addCorner(healthFill, 8)

section(homePage, "تذكير")
local reminderCard = card(homePage, 76)
addLabel(reminderCard, "استخدم أهدافي وخطة النقاط لتسجيل خطتك يدويًا. هذه اللوحة لا تغيّر عالم اللعبة.", UDim2.new(1, -28, 1, -16), UDim2.new(0, 14, 0, 8), 13, Theme.Muted)

-- صفحة الأهداف: قائمة يحدّثها اللاعب يدويًا
section(goalsPage, "قائمة أهداف اليوم")
local goals = {
    {text = "اختيار الجزيرة أو المنطقة التالية"},
    {text = "تحديد المهمة التي أريد إنجازها"},
    {text = "مراجعة توزيع نقاطي قبل اللعب"},
    {text = "تسجيل غرض أبحث عنه"},
    {text = "أخذ استراحة بعد الجلسة"},
}
local completedGoals = {}
local progressLabel

local function refreshProgress()
    local done = 0
    for index = 1, #goals do
        if completedGoals[index] then
            done += 1
        end
    end
    if progressLabel then
        progressLabel.Text = string.format("الإنجاز: %d من %d", done, #goals)
    end
end

local progressCard = card(goalsPage, 44)
progressLabel = addLabel(progressCard, "الإنجاز: 0 من " .. #goals, UDim2.new(1, -24, 1, 0), UDim2.new(0, 12, 0, 0), 13, Theme.AccentLight, Enum.Font.GothamBold)
for index, goal in ipairs(goals) do
    local goalIndex = index
    local row = card(goalsPage, 48)
    local textLabel = addLabel(row, goal.text, UDim2.new(1, -82, 1, 0), UDim2.new(0, 14, 0, 0), 13, Theme.Text)
    textLabel.TextXAlignment = Enum.TextXAlignment.Right
    local check = actionButton(row, "○", UDim2.new(1, -56, 0.5, -16), UDim2.fromOffset(42, 32), Theme.Track)
    check.Activated:Connect(function()
        completedGoals[goalIndex] = not completedGoals[goalIndex]
        check.Text = completedGoals[goalIndex] and "✓" or "○"
        check.BackgroundColor3 = completedGoals[goalIndex] and Theme.Green or Theme.Track
        refreshProgress()
    end)
end

-- مخطط توزيع النقاط (ملاحظات شخصية فقط)
section(buildPage, "مخطط توزيعك الشخصي")
local planInfo = card(buildPage, 56)
addLabel(planInfo, "عدّل الأرقام لمقارنة خطتك يدويًا. القيم لا تُرسل إلى اللعبة.", UDim2.new(1, -24, 1, -8), UDim2.new(0, 12, 0, 4), 12, Theme.Muted)
local stats = {
    {name = "قتال قريب"},
    {name = "الدفاع"},
    {name = "السيف"},
    {name = "السلاح"},
    {name = "الفاكهة"},
}
local planValues = {}
local planValueLabels = {}
local totalLabel

local function refreshTotal()
    local total = 0
    for _, stat in ipairs(stats) do
        total += planValues[stat.name] or 0
    end
    if totalLabel then
        totalLabel.Text = "مجموع الخطة: " .. tostring(total) .. " نقطة"
    end
end

for _, stat in ipairs(stats) do
    local statName = stat.name
    planValues[statName] = 0
    local row = card(buildPage, 48)
    addLabel(row, statName, UDim2.new(0.36, -12, 1, 0), UDim2.new(0, 12, 0, 0), 13, Theme.Text, Enum.Font.GothamBold)
    local valueLabel = addLabel(row, "0", UDim2.new(0.25, 0, 1, 0), UDim2.new(0.42, 0, 0, 0), 14, Theme.AccentLight, Enum.Font.GothamBold)
    valueLabel.TextXAlignment = Enum.TextXAlignment.Center
    planValueLabels[statName] = valueLabel
    local minus = actionButton(row, "−", UDim2.new(1, -94, 0.5, -15), UDim2.fromOffset(36, 30), Theme.Track)
    local plus = actionButton(row, "+", UDim2.new(1, -48, 0.5, -15), UDim2.fromOffset(36, 30), Theme.Accent)
    local function change(amount)
        planValues[statName] = math.clamp(planValues[statName] + amount, 0, 1000000)
        valueLabel.Text = tostring(planValues[statName])
        refreshTotal()
    end
    minus.Activated:Connect(function() change(-1) end)
    plus.Activated:Connect(function() change(1) end)
end
local totalCard = card(buildPage, 44)
totalLabel = addLabel(totalCard, "مجموع الخطة: 0 نقطة", UDim2.new(1, -24, 1, 0), UDim2.new(0, 12, 0, 0), 13, Theme.AccentLight, Enum.Font.GothamBold)
refreshTotal()
local resetPlan = actionButton(buildPage, "إعادة تعيين الخطة", UDim2.new(), UDim2.new(1, 0, 0, 40), Theme.Track)
resetPlan.Activated:Connect(function()
    for _, stat in ipairs(stats) do
        planValues[stat.name] = 0
        planValueLabels[stat.name].Text = "0"
    end
    refreshTotal()
end)

-- صفحة الملاحظات
section(notesPage, "ملاحظاتك لهذه الجلسة")
local notesCard = card(notesPage, 205)
local notesBox = make("TextBox", notesCard, {
    Name = "NotesInput",
    Size = UDim2.new(1, -24, 1, -24),
    Position = UDim2.new(0, 12, 0, 12),
    BackgroundColor3 = Theme.Background,
    TextColor3 = Theme.Text,
    PlaceholderColor3 = Theme.Muted,
    PlaceholderText = "اكتب هدفك أو ملاحظاتك هنا…",
    Text = "",
    TextSize = 14,
    Font = Enum.Font.Gotham,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Right,
    TextYAlignment = Enum.TextYAlignment.Top,
    ClearTextOnFocus = false,
    MultiLine = true,
    BorderSizePixel = 0,
})
addCorner(notesBox, 9)
local notesStatus = addLabel(notesPage, "الملاحظات محفوظة في الواجهة حتى إغلاقها.", UDim2.new(1, 0, 0, 24), UDim2.new(), 11, Theme.Muted)

-- صفحة موحدة للإعدادات أسفل الملاحظات عبر أزرار بسيطة
local noteClear = actionButton(notesPage, "مسح الملاحظات", UDim2.new(), UDim2.new(1, 0, 0, 40), Theme.Track)
noteClear.Activated:Connect(function()
    notesBox.Text = ""
    notesStatus.Text = "تم مسح الملاحظات."
end)

local footer = addLabel(body, "RightShift لإظهار أو إخفاء اللوحة", UDim2.new(1, 0, 0, 16), UDim2.new(0, 0, 1, -16), 10, Theme.Muted)
footer.TextXAlignment = Enum.TextXAlignment.Center

-- زر عائم لإعادة فتح اللوحة
local reopen = make("TextButton", screenGui, {
    Name = "Reopen",
    Size = UDim2.fromOffset(48, 48),
    Position = UDim2.new(0, 18, 0.5, -24),
    BackgroundColor3 = Theme.Accent,
    Text = "GL",
    TextColor3 = Theme.Text,
    TextSize = 15,
    Font = Enum.Font.GothamBlack,
    Visible = false,
    AutoButtonColor = true,
})
addCorner(reopen, 24)
addStroke(reopen, Theme.AccentLight, 1, 0.15)

local minimized = false
local function setVisible(visible)
    main.Visible = visible
    reopen.Visible = not visible
end

hideButton.Activated:Connect(function()
    setVisible(false)
end)
reopen.Activated:Connect(function()
    setVisible(true)
end)

minimizeButton.Activated:Connect(function()
    minimized = not minimized
    body.Visible = not minimized
    minimizeButton.Text = minimized and "+" or "—"
    local targetHeight = minimized and 62 or 510
    TweenService:Create(main, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(650, targetHeight),
    }):Play()
end)

local globalConnections = {}
local function trackConnection(connection)
    table.insert(globalConnections, connection)
    return connection
end

trackConnection(UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        setVisible(not main.Visible)
    end
end))

-- سحب اللوحة من منطقة العنوان
local dragging = false
local dragInput
local dragStart
local startPosition
local function beginDrag(input)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end
    dragging = true
    dragStart = input.Position
    startPosition = main.Position
    input.Changed:Connect(function()
        if input.UserInputState == Enum.UserInputState.End then
            dragging = false
        end
    end)
end

title.InputBegan:Connect(beginDrag)
subtitle.InputBegan:Connect(beginDrag)
title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
subtitle.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
trackConnection(UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = (input.Position - dragStart) / uiScale.Scale
        main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end))

-- ضبط الحجم على الشاشات الصغيرة
local viewportConnection
local cameraConnection
local function updateScale()
    local camera = workspace.CurrentCamera
    if not camera then return end
    local viewport = camera.ViewportSize
    local widthScale = math.max(0.4, (viewport.X - 24) / 650)
    local heightScale = math.max(0.4, (viewport.Y - 24) / 510)
    uiScale.Scale = math.min(1, widthScale, heightScale)
end

local function bindCamera()
    if viewportConnection then viewportConnection:Disconnect() end
    local camera = workspace.CurrentCamera
    if camera then
        viewportConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
        updateScale()
    end
end
bindCamera()
cameraConnection = trackConnection(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindCamera))

-- اختيار الصفحة الرئيسية بعد اكتمال إنشاء الأزرار
if tabButtons.Home then
    pages.Home.Visible = true
    tabButtons.Home.BackgroundColor3 = Theme.Accent
    tabButtons.Home.TextColor3 = Theme.Text
end

-- تحديث معلومات القراءة فقط من شخصية اللاعب
local elapsedSeconds = 0
local function formatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local remaining = seconds % 60
    return string.format("%02d:%02d:%02d", hours, minutes, remaining)
end

local function readLevel()
    local leaderstats = player:FindFirstChild("leaderstats")
    local level = leaderstats and leaderstats:FindFirstChild("Level")
    if level and (level:IsA("IntValue") or level:IsA("NumberValue")) then
        return tostring(level.Value)
    end
    return "غير متاح"
end

task.spawn(function()
    while screenGui.Parent do
        task.wait(1)
        elapsedSeconds += 1
        sessionValue.Text = formatTime(elapsedSeconds)
        levelValue.Text = readLevel()

        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.MaxHealth > 0 then
            local ratio = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
            healthText.Text = string.format("الصحة: %d / %d", math.floor(humanoid.Health + 0.5), math.floor(humanoid.MaxHealth + 0.5))
            healthFill.Size = UDim2.new(ratio, 0, 1, 0)
            healthFill.BackgroundColor3 = ratio <= 0.25 and Theme.Red or Theme.Green
        else
            healthText.Text = "الصحة: غير متاحة"
            healthFill.Size = UDim2.new(0, 0, 1, 0)
        end
    end
end)

screenGui.Destroying:Connect(function()
    if viewportConnection then viewportConnection:Disconnect() end
    for _, connection in ipairs(globalConnections) do
        connection:Disconnect()
    end
end)
