--!strict
-- GlowBlurUI PRO v3.x (Roblox PlayerScript Full Version)
-- Работает как полнофункциональный UI в PlayerGui
-- Используй как LocalScript в StarterPlayerScripts

-- ========== SERVICES ==========
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ========== ICONS ==========
local Icons = {
    Settings = "rbxassetid://104919049969988",
    CloseICO = "rbxassetid://5577404210",
}

-- ========== CONFIG ==========
local Config = {
    ToggleKey = Enum.KeyCode.Insert,
    OverlayAlpha = 0.25,
    BlurSize = 22,
    OpenTime = 0.45,
    TabTimeOut = 0.18,
    TabTimeIn = 0.22,
    WindowSize = UDim2.fromOffset(640, 500),
    WindowBg = Color3.fromRGB(18, 18, 20),
    StrokeColor = Color3.fromRGB(70, 70, 78),
    Accent = Color3.fromRGB(125, 90, 255),
    AccentGlow = Color3.fromRGB(180, 120, 255),
    Primary = Color3.fromRGB(125, 90, 255),
    Secondary = Color3.fromRGB(100, 100, 120),
    Success = Color3.fromRGB(76, 175, 80),
    Danger = Color3.fromRGB(244, 67, 54),
    Info = Color3.fromRGB(33, 150, 243),
    Disabled = Color3.fromRGB(117, 117, 117),
    TitleSize = 16,
    HeaderSize = 13,
    BodySize = 12,
    SmallSize = 11,
    Padding = 12,
    GapSmall = 6,
    GapMedium = 10,
    GapLarge = 16,
    Anim = {
        Enabled = true,
        ToggleSpeed = 0.18,
        ToggleEasing = Enum.EasingStyle.Quad,
        ToggleDirection = Enum.EasingDirection.Out,
        ToggleBounce = false,
        SliderSpeed = 0.12,
        SliderEasing = Enum.EasingStyle.Quad,
        SliderDirection = Enum.EasingDirection.Out,
        ButtonPressSpeed = 0.08,
        DropdownSpeed = 0.15,
    },
    Snow = {
        Enabled = true,
        MaxParticles = 50,
    },
}

-- ========== CONFIG PERSISTENCE ==========
local function saveConfig()
    local data = {
        BlurEnabled = Config.BlurSize > 0,
        BlurSize = Config.BlurSize,
        OverlayEnabled = Config.OverlayAlpha > 0,
        OverlayAlpha = Config.OverlayAlpha,
        AnimEnabled = Config.Anim.Enabled,
        SnowEnabled = Config.Snow.Enabled,
        OpenTime = Config.OpenTime,
        TabTimeIn = Config.TabTimeIn,
        TabTimeOut = Config.TabTimeOut,
        ToggleAnimSpeed = Config.Anim.ToggleSpeed,
        SliderAnimSpeed = Config.Anim.SliderSpeed,
        ToggleKey = Config.ToggleKey.Name,
    }
    local json = HttpService:JSONEncode(data)
    if writefile then
        pcall(function() writefile("GlowBlurUI_Settings.json", json) end)
    end
    pcall(function() playerGui:SetAttribute("GlowBlurUI_Settings", json) end)
end

local function loadConfig()
    local json = nil
    if readfile then
        pcall(function() json = readfile("GlowBlurUI_Settings.json") end)
    end
    if not json then
        pcall(function() json = playerGui:GetAttribute("GlowBlurUI_Settings") end)
    end
    if typeof(json) == "string" and json ~= "" then
        local ok, data = pcall(function() return HttpService:JSONDecode(json) end)
        if ok and typeof(data) == "table" then
            Config.BlurSize = data.BlurSize or Config.BlurSize
            Config.OverlayAlpha = data.OverlayAlpha or Config.OverlayAlpha
            Config.OpenTime = data.OpenTime or Config.OpenTime
            Config.TabTimeIn = data.TabTimeIn or Config.TabTimeIn
            Config.TabTimeOut = data.TabTimeOut or Config.TabTimeOut
            if data.AnimEnabled ~= nil then Config.Anim.Enabled = data.AnimEnabled end
            if data.SnowEnabled ~= nil then Config.Snow.Enabled = data.SnowEnabled end
            Config.Anim.ToggleSpeed = data.ToggleAnimSpeed or Config.Anim.ToggleSpeed
            Config.Anim.SliderSpeed = data.SliderAnimSpeed or Config.Anim.SliderSpeed
            if typeof(data.ToggleKey) == "string" then
                local kc = Enum.KeyCode[data.ToggleKey]
                if kc then Config.ToggleKey = kc end
            end
        end
    end
end

loadConfig()

-- ========== LIFETIME MANAGEMENT ==========
local destroyed = false
local allConnections = {}
local allTweens = {}
local snowConnection = nil

local function Disconnect(conn)
    if conn then pcall(function() conn:Disconnect() end) end
end

local function DisconnectAll()
    for _, conn in ipairs(allConnections) do
        Disconnect(conn)
    end
    table.clear(allConnections)
end

local function CancelAllTweens()
    for _, t in ipairs(allTweens) do
        pcall(function() t:Cancel() end)
    end
    table.clear(allTweens)
end

-- ========== FORWARD DECLARATIONS ==========
local gui, overlay, blur, createdBlur, window, winStroke, accentLine, tabsFrame, content, topbar
local modalBlocker, settingsPopover, settingsBtn, closeBtn
local opened = false
local openTweens = {}
local tabOrder = 0
local currentPage = nil
local tabSwitching = false
local keybindListening = false
local activeDropdownClose = nil

-- ========== UTILITY FUNCTIONS ==========
local function GetInset()
    local inset = GuiService:GetGuiInset()
    return Vector2.new(inset.X, inset.Y)
end

local function GetMouse2D()
    return UserInputService:GetMouseLocation() - GetInset()
end

local function New(className, props, children)
    local inst = Instance.new(className)
    if props then
        for k, v in pairs(props) do
            inst[k] = v
        end
    end
    if children then
        for _, c in ipairs(children) do
            c.Parent = inst
        end
    end
    return inst
end

local function PlayTween(obj, info, goal)
    local t = TweenService:Create(obj, info, goal)
    t:Play()
    table.insert(allTweens, t)
    return t
end

local function PushLog(level, msg)
    print("[" .. tostring(level or "INFO") .. "] " .. tostring(msg or ""))
end

local function GetAnimInfo(speed, style, dir, bounce)
    if not Config.Anim.Enabled then
        return TweenInfo.new(0.001, style, dir)
    end
    local tweenStyle = style
    if bounce and style == Enum.EasingStyle.Quad then
        tweenStyle = Enum.EasingStyle.Elastic
    end
    return TweenInfo.new(speed, tweenStyle, dir)
end

local function getOpenTweenInfo()
    return TweenInfo.new(Config.OpenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
end

local function MarkNoWindowDrag(obj)
    if obj:IsA("GuiObject") then
        obj:SetAttribute("NoWindowDrag", true)
    end
end

local function IsNoWindowDrag(obj)
    return obj:GetAttribute("NoWindowDrag") or false
end

local function ClampWindowPosition(windowObj, maxX, maxY)
    local pos = windowObj.Position
    local size = windowObj.AbsoluteSize
    windowObj.Position = UDim2.new(
        pos.X.Scale,
        math.clamp(pos.X.Offset, -size.X, maxX),
        pos.Y.Scale,
        math.clamp(pos.Y.Offset, -size.Y, maxY)
    )
end

local function setMouseUnblock(enable)
    if enable then
        pcall(function() RunService:UnbindFromRenderStep("GlowBlurUI_MouseUnblock") end)
        RunService:BindToRenderStep("GlowBlurUI_MouseUnblock", Enum.RenderPriority.Camera.Value - 1, function()
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            UserInputService.MouseIconEnabled = true
        end)
    else
        pcall(function() RunService:UnbindFromRenderStep("GlowBlurUI_MouseUnblock") end)
    end
end

-- ========== STARTUP ==========
-- Root GUI
gui = New("ScreenGui", {
    Name = "GlowBlurUI",
    IgnoreGuiInset = true,
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = playerGui,
})

overlay = New("Frame", {
    Name = "BlackOverlay",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromScale(0, 0),
    BackgroundColor3 = Color3.new(0, 0, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Visible = false,
    Parent = gui,
})

-- Blur
blur = Lighting:FindFirstChildOfClass("BlurEffect")
createdBlur = false
if not blur then
    blur = Instance.new("BlurEffect")
    blur.Name = "GlowBlur"
    blur.Parent = Lighting
    createdBlur = true
end
blur.Enabled = true
blur.Size = 0

-- Window
window = New("Frame", {
    Name = "Window",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(0, 0),
    BackgroundColor3 = Config.WindowBg,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Visible = false,
    ClipsDescendants = true,
    Parent = gui,
})

New("UICorner", { CornerRadius = UDim.new(0, 12), Parent = window })

winStroke = New("UIStroke", {
    Color = Config.StrokeColor,
    Thickness = 2,
    Transparency = 1,
    Parent = window,
})

New("UIGradient", {
    Rotation = 45,
    Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Config.Accent),
        ColorSequenceKeypoint.new(0.5, Config.AccentGlow),
        ColorSequenceKeypoint.new(1, Config.Accent),
    },
    Parent = winStroke,
})

New("UIGradient", {
    Rotation = 90,
    Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(24, 24, 28)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 20, 24)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 16, 18)),
    },
    Parent = window,
})

-- Topbar
topbar = New("Frame", {
    Name = "Topbar",
    Size = UDim2.new(1, 0, 0, 48),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Parent = window,
})

New("TextLabel", {
    Name = "Title",
    BackgroundTransparency = 1,
    Position = UDim2.new(0, Config.Padding, 0, 0),
    Size = UDim2.new(1, -140, 1, 0),
    Font = Enum.Font.GothamBold,
    TextSize = Config.TitleSize,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
    TextStrokeTransparency = 0.5,
    Text = "Vibus",
    Parent = topbar,
})

settingsPopover = New("Frame", {
    Name = "SettingsPopover",
    BackgroundColor3 = Config.WindowBg,
    BorderSizePixel = 0,
    Size = UDim2.new(0, 240, 0, 0),
    Position = UDim2.new(1, -250, 0, 48),
    Visible = false,
    ClipsDescendants = true,
    Parent = topbar,
})

New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = settingsPopover })
New("UIStroke", { Color = Config.Accent, Thickness = 1, Transparency = 0.5, Parent = settingsPopover })

local settingsContent = New("Frame", {
    Name = "Content",
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 1, 0),
    Parent = settingsPopover,
})

New("UIPadding", {
    PaddingTop = UDim.new(0, 8),
    PaddingLeft = UDim.new(0, 8),
    PaddingRight = UDim.new(0, 8),
    PaddingBottom = UDim.new(0, 8),
    Parent = settingsContent,
})

New("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 6),
    Parent = settingsContent,
})

settingsBtn = New("ImageButton", {
    Name = "Settings",
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 24, 0, 24),
    Position = UDim2.new(1, -80, 0, 12),
    AutoButtonColor = false,
    Image = Icons.Settings,
    Parent = topbar,
})

closeBtn = New("ImageButton", {
    Name = "Close",
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 24, 0, 24),
    Position = UDim2.new(1, -40, 0, 12),
    AutoButtonColor = false,
    Image = Icons.CloseICO,
    Parent = topbar,
})

accentLine = New("Frame", {
    Name = "Accent",
    BackgroundColor3 = Config.Accent,
    BorderSizePixel = 0,
    Position = UDim2.new(0, 0, 0, 48),
    Size = UDim2.new(1, 0, 0, 2),
    BackgroundTransparency = 1,
    Parent = window,
})

New("UIStroke", { Color = Config.AccentGlow, Thickness = 3, Transparency = 1, Parent = accentLine })

-- Body
local body = New("Frame", {
    Name = "Body",
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 0, 0, 50),
    Size = UDim2.new(1, 0, 1, -50),
    Parent = window,
})

-- Tabs
tabsFrame = New("Frame", {
    Name = "Tabs",
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 160, 1, 0),
    Parent = body,
})

New("UIPadding", {
    PaddingTop = UDim.new(0, Config.Padding),
    PaddingLeft = UDim.new(0, Config.Padding),
    PaddingRight = UDim.new(0, Config.GapSmall),
    Parent = tabsFrame,
})

New("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, Config.GapSmall),
    Parent = tabsFrame,
})

-- Content
content = New("Frame", {
    Name = "Content",
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 160, 0, 0),
    Size = UDim2.new(1, -160, 1, 0),
    Parent = body,
})

New("UIPadding", {
    PaddingTop = UDim.new(0, Config.Padding),
    PaddingLeft = UDim.new(0, Config.Padding),
    PaddingRight = UDim.new(0, Config.Padding),
    PaddingBottom = UDim.new(0, Config.Padding),
    Parent = content,
})

-- Modal blocker
modalBlocker = New("TextButton", {
    Name = "ModalBlocker",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Text = "",
    AutoButtonColor = false,
    Visible = false,
    Modal = true,
    Active = true,
    Parent = gui,
})

modalBlocker.ZIndex = 1
window.ZIndex = 2

-- ========== TAB FUNCTIONS ==========
local function styleTabButton(btn, active)
    local stroke = btn:FindFirstChildOfClass("UIStroke")
    btn.TextTransparency = 0
    btn.TextColor3 = active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(230, 230, 235)
    local bg = active and Color3.fromRGB(40, 35, 50) or Color3.fromRGB(28, 28, 34)
    PlayTween(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundColor3 = bg,
    })
    if stroke then
        PlayTween(stroke, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Transparency = active and 0.05 or 0.65,
            Thickness = active and 2.5 or 1.5,
        })
    end
end

local function createPage()
    local page = New("ScrollingFrame", {
        Name = "Page",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 4,
        ScrollBarImageTransparency = 0.35,
        Visible = false,
        Parent = content,
    })

    local cg = New("CanvasGroup", {
        Name = "CanvasGroup",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        GroupTransparency = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Parent = page,
    })

    local list = New("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, Config.GapMedium),
        Parent = cg,
    })

    local function resizeCanvas()
        task.defer(function()
            page.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 8)
        end)
    end

    local resizeConn = list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(resizeCanvas)
    table.insert(allConnections, resizeConn)
    resizeCanvas()

    return page, cg
end

local function createTab(tabName, icon)
    assert(tabsFrame, "tabsFrame missing")
    tabOrder = tabOrder + 1
    local displayText = icon and icon .. " " .. tabName or tabName

    local btn = New("TextButton", {
        Name = "TabButton",
        Size = UDim2.new(1, 0, 0, 38),
        AutoButtonColor = false,
        Text = displayText,
        Font = Enum.Font.Gotham,
        TextSize = Config.BodySize,
        TextTransparency = 0,
        TextColor3 = Color3.fromRGB(230, 230, 235),
        BackgroundColor3 = Color3.fromRGB(28, 28, 34),
        BorderSizePixel = 0,
        LayoutOrder = tabOrder,
        Parent = tabsFrame,
    })

    New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = btn })
    local stroke = New("UIStroke", {
        Name = "Stroke",
        Color = Config.Accent,
        Thickness = 1.5,
        Transparency = 0.65,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = btn,
    })

    local scale = New("UIScale", { Scale = 1, Parent = btn })

    local page, canvasGroup = createPage()

    btn.MouseEnter:Connect(function()
        PlayTween(scale, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 1.04 })
        PlayTween(stroke, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Transparency = 0.25,
            Thickness = 2,
        })
    end)

    btn.MouseLeave:Connect(function()
        PlayTween(scale, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 1 })
        styleTabButton(btn, currentPage == page)
    end)

    btn.MouseButton1Down:Connect(function()
        PlayTween(scale, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 0.96 })
    end)

    btn.MouseButton1Up:Connect(function()
        PlayTween(scale, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 1.04 })
    end)

    local function select()
        if tabSwitching then return end
        if currentPage == page then return end
        tabSwitching = true

        if currentPage then
            local oldCg = currentPage:FindFirstChild("CanvasGroup")
            if oldCg then
                PlayTween(oldCg, TweenInfo.new(Config.TabTimeOut, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    GroupTransparency = 1,
                    Position = UDim2.new(-0.08, 0, 0, 0),
                })
            end

            local old = currentPage
            task.delay(Config.TabTimeOut, function()
                if old and old ~= page then
                    old.Visible = false
                end
            end)
        end

        for _, child in ipairs(tabsFrame:GetChildren()) do
            if child:IsA("TextButton") then
                styleTabButton(child, child == btn)
            end
        end

        page.Visible = true
        currentPage = page
        canvasGroup.Position = UDim2.new(0.08, 0, 0, 0)
        canvasGroup.GroupTransparency = 1

        local tIn = PlayTween(canvasGroup, TweenInfo.new(Config.TabTimeIn, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            GroupTransparency = 0,
            Position = UDim2.new(0, 0, 0, 0),
        })

        local conn
        conn = tIn.Completed:Connect(function()
            Disconnect(conn)
            tabSwitching = false
        end)
        table.insert(allConnections, conn)
    end

    btn.MouseButton1Click:Connect(select)
    styleTabButton(btn, false)

    if not currentPage and tabName == "Settings" then
        task.defer(select)
    end

    return {
        Button = btn,
        Page = page,
        Canvas = canvasGroup,
        Select = select,
    }
end

local function pageCanvas(page)
    local cg = page:FindFirstChild("CanvasGroup")
    assert(cg and cg:IsA("CanvasGroup"), "Page missing CanvasGroup")
    return cg
end

-- ========== WIDGET FUNCTIONS ==========
local function addHeader(page, text)
    local parent = pageCanvas(page)
    New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 24),
        Font = Enum.Font.GothamMedium,
        TextSize = Config.HeaderSize - 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = Config.Accent,
        TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
        TextStrokeTransparency = 0.6,
        Text = text,
        Parent = parent,
    })
end

local function addButton(page, text, callback, icon, priority)
    local parent = pageCanvas(page)
    priority = priority or "normal"
    local displayText = icon and icon .. " " .. text or text

    local holder = New("Frame", {
        BackgroundColor3 = Color3.fromRGB(28, 28, 34),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 40),
        Parent = parent,
    })

    New("UICorner", { CornerRadius = UDim.new(0, 0), Parent = holder })
    New("UIStroke", { Color = Color3.fromRGB(55, 59, 62), Thickness = 1, Parent = holder })

    MarkNoWindowDrag(holder)

    local button = New("TextButton", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        AutoButtonColor = false,
        Font = Enum.Font.Gotham,
        TextSize = Config.BodySize,
        TextTransparency = 0,
        TextColor3 = Color3.fromRGB(240, 240, 245),
        TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
        TextStrokeTransparency = 0.7,
        Text = displayText,
        Parent = holder,
    })

    MarkNoWindowDrag(button)

    local st = holder:FindFirstChildOfClass("UIStroke")
    local scale = New("UIScale", { Scale = 1, Parent = button })

    button.MouseEnter:Connect(function()
        PlayTween(st, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Color = Config.Accent,
            Transparency = 0.2,
        })
        PlayTween(button, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            TextColor3 = Color3.fromRGB(255, 255, 255),
        })
    end)

    button.MouseLeave:Connect(function()
        PlayTween(st, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Color = Color3.fromRGB(55, 55, 62),
            Transparency = 0,
        })
        PlayTween(button, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            TextColor3 = Color3.fromRGB(240, 240, 245),
        })
    end)

    button.MouseButton1Down:Connect(function()
        PlayTween(scale, TweenInfo.new(Config.Anim.ButtonPressSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Scale = 0.95,
        })
    end)

    button.MouseButton1Up:Connect(function()
        PlayTween(scale, TweenInfo.new(Config.Anim.ButtonPressSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Scale = 1,
        })
    end)

    button.MouseButton1Click:Connect(function()
        if callback then task.spawn(callback) end
    end)
end

local function addToggle(page, text, default, callback, icon)
    local parent = pageCanvas(page)
    local state = default and true or false

    local holder = New("Frame", {
        BackgroundColor3 = Color3.fromRGB(28, 28, 34),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 40),
        Parent = parent,
    })

    New("UICorner", { CornerRadius = UDim.new(0, 0), Parent = holder })
    New("UIStroke", { Color = Color3.fromRGB(55, 59, 62), Thickness = 1, Parent = holder })

    local displayText = icon and icon .. " " .. text or text

    New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, Config.Padding, 0, 0),
        Size = UDim2.new(1, -80, 1, 0),
        Font = Enum.Font.Gotham,
        TextSize = Config.BodySize,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = Color3.fromRGB(240, 240, 245),
        TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
        TextStrokeTransparency = 0.75,
        Text = displayText,
        Parent = holder,
    })

    local pill = New("TextButton", {
        AutoButtonColor = false,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 50, 0, 24),
        Position = UDim2.new(1, -62, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Text = "",
        Parent = holder,
    })

    MarkNoWindowDrag(pill)

    New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = pill })

    local dot = New("Frame", {
        BorderSizePixel = 0,
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, 2, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Parent = pill,
    })

    New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = dot })

    local glow = New("UIStroke", {
        Color = Config.AccentGlow,
        Thickness = 2,
        Transparency = 1,
        Parent = pill,
    })

    local function apply(noTween)
        local bg = state and Config.Success or Color3.fromRGB(80, 80, 90)
        local dotPos = state and UDim2.new(1, -22, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
        local glowTrans = state and 0.4 or 1

        if noTween or not Config.Anim.Enabled then
            pill.BackgroundColor3 = bg
            dot.Position = dotPos
            dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            glow.Transparency = glowTrans
        else
            PlayTween(pill, GetAnimInfo(Config.Anim.ToggleSpeed, Config.Anim.ToggleEasing, Config.Anim.ToggleDirection, Config.Anim.ToggleBounce), {
                BackgroundColor3 = bg,
            })
            PlayTween(dot, GetAnimInfo(Config.Anim.ToggleSpeed, Config.Anim.ToggleEasing, Config.Anim.ToggleDirection, Config.Anim.ToggleBounce), {
                Position = dotPos,
            })
            PlayTween(glow, GetAnimInfo(Config.Anim.ToggleSpeed, Config.Anim.ToggleEasing, Config.Anim.ToggleDirection), {
                Transparency = glowTrans,
            })
        end
    end

    pill.MouseButton1Click:Connect(function()
        state = not state
        apply(false)
        if callback then task.spawn(function() callback(state) end) end
    end)

    apply(true)

    return {
        Get = function() return state end,
        Set = function(v)
            state = v
            apply(false)
            if callback then task.spawn(function() callback(state) end) end
        end,
        Toggle = function()
            state = not state
            apply(false)
            if callback then task.spawn(function() callback(state) end) end
        end,
    }
end

local function addSlider(page, text, minVal, maxVal, defaultVal, callback, icon)
    local parent = pageCanvas(page)
    defaultVal = math.clamp(defaultVal, minVal, maxVal)
    local displayText = icon and icon .. " " .. text or text

    local holder = New("Frame", {
        BackgroundColor3 = Color3.fromRGB(28, 28, 34),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 56),
        Parent = parent,
    })

    New("UICorner", { CornerRadius = UDim.new(0, 0), Parent = holder })
    New("UIStroke", { Color = Color3.fromRGB(55, 59, 62), Thickness = 1, Parent = holder })

    MarkNoWindowDrag(holder)

    New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, Config.Padding, 0, 2),
        Size = UDim2.new(1, -80, 0, 20),
        Font = Enum.Font.Gotham,
        TextSize = Config.BodySize,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = Color3.fromRGB(240, 240, 245),
        TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
        TextStrokeTransparency = 0.75,
        Text = displayText,
        Parent = holder,
    })

    local valueLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -60, 0, 2),
        Size = UDim2.new(0, 50, 0, 20),
        Font = Enum.Font.GothamMedium,
        TextSize = Config.BodySize,
        TextXAlignment = Enum.TextXAlignment.Right,
        TextColor3 = Config.Accent,
        TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
        TextStrokeTransparency = 0.8,
        Text = tostring(math.floor(defaultVal)),
        Parent = holder,
    })

    local line = New("Frame", {
        BackgroundColor3 = Color3.fromRGB(50, 50, 60),
        BorderSizePixel = 0,
        Position = UDim2.new(0, Config.Padding, 0, 28),
        Size = UDim2.new(1, -Config.Padding * 2, 0, 5),
        Parent = holder,
    })

    New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = line })

    MarkNoWindowDrag(line)

    local fill = New("Frame", {
        BackgroundColor3 = Config.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 0, 1, 0),
        Parent = line,
    })

    New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })

    MarkNoWindowDrag(fill)

    local thumb = New("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = Color3.fromRGB(240, 240, 255),
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(16, 16),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Text = "",
        Parent = line,
    })

    New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = thumb })
    New("UIStroke", { Color = Config.AccentGlow, Thickness = 2, Transparency = 0.3, Parent = thumb })

    MarkNoWindowDrag(thumb)

    local value = defaultVal
    local stopDrag = nil

    local function setVisual(v)
        v = math.clamp(v, minVal, maxVal)
        local a = (v - minVal) / (maxVal - minVal)

        if Config.Anim.Enabled then
            PlayTween(fill, GetAnimInfo(Config.Anim.SliderSpeed, Config.Anim.SliderEasing, Config.Anim.SliderDirection), {
                Size = UDim2.new(a, 0, 1, 0),
            })
            PlayTween(thumb, GetAnimInfo(Config.Anim.SliderSpeed, Config.Anim.SliderEasing, Config.Anim.SliderDirection), {
                Position = UDim2.new(a, 0, 0.5, 0),
            })
        else
            fill.Size = UDim2.new(a, 0, 1, 0)
            thumb.Position = UDim2.new(a, 0, 0.5, 0)
        end

        valueLabel.Text = tostring(math.floor(v))
    end

    local function setFromX(xPos)
        local absPos = line.AbsolutePosition.X
        local absSize = line.AbsoluteSize.X

        if absSize == 0 then return end

        local rel = math.clamp((xPos - absPos) / absSize, 0, 1)
        value = minVal + (maxVal - minVal) * rel
        setVisual(value)

        if callback then task.spawn(function() callback(value) end) end
    end

    local function beginDrag(startPos2D)
        if stopDrag then stopDrag() end

        setFromX(startPos2D.X)

        stopDrag = (function()
            local function onMove(pos)
                local p2d = pos - GetInset()
                setFromX(p2d.X)
            end

            local function onEnd()
                stopDrag = nil
            end

            return function()
                onEnd()
            end
        end)()
    end

    thumb.MouseButton1Down:Connect(function()
        beginDrag(GetMouse2D())
    end)

    line.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            beginDrag(input.Position - GetInset())
        end
    end)

    fill.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local p = input.Position
            beginDrag(Vector2.new(p.X, p.Y) - GetInset())
        end
    end)

    holder.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local p = input.Position
            beginDrag(Vector2.new(p.X, p.Y) - GetInset())
        end
    end)

    setVisual(defaultVal)

    return {
        SetValue = function(v)
            value = math.clamp(v, minVal, maxVal)
            setVisual(value)
        end,
        GetValue = function() return value end,
    }
end

local function addKeybind(page, text, defaultKey, callback, icon)
    local parent = pageCanvas(page)
    local currentKey = defaultKey
    local displayText = icon and icon .. " " .. text or text

    local holder = New("Frame", {
        BackgroundColor3 = Color3.fromRGB(28, 28, 34),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 40),
        Parent = parent,
    })

    New("UICorner", { CornerRadius = UDim.new(0, 0), Parent = holder })
    New("UIStroke", { Color = Color3.fromRGB(55, 59, 62), Thickness = 1, Parent = holder })

    MarkNoWindowDrag(holder)

    New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, Config.Padding, 0, 0),
        Size = UDim2.new(1, -140, 1, 0),
        Font = Enum.Font.Gotham,
        TextSize = Config.BodySize,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = Color3.fromRGB(240, 240, 245),
        TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
        TextStrokeTransparency = 0.75,
        Text = displayText,
        Parent = holder,
    })

    local btn = New("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = Color3.fromRGB(35, 35, 45),
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -Config.Padding, 0.5, 0),
        Size = UDim2.new(0, 110, 0, 26),
        Font = Enum.Font.GothamMedium,
        TextSize = Config.SmallSize,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Text = currentKey.Name,
        Parent = holder,
    })

    New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = btn })
    New("UIStroke", { Color = Config.Accent, Thickness = 1, Transparency = 0.65, Parent = btn })

    MarkNoWindowDrag(btn)

    btn.MouseButton1Click:Connect(function()
        if keybindListening then return end
        keybindListening = true
        btn.Text = "Press key..."

        local conn
        conn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

            local key = input.KeyCode
            if key == Enum.KeyCode.Escape then
                btn.Text = currentKey.Name
                keybindListening = false
                Disconnect(conn)
                return
            end

            currentKey = key
            btn.Text = currentKey.Name
            keybindListening = false
            Disconnect(conn)

            if callback then task.spawn(function() callback(currentKey) end) end
        end)

        table.insert(allConnections, conn)
    end)

    return {
        Get = function() return currentKey end,
        Set = function(k)
            currentKey = k
            btn.Text = currentKey.Name
            if callback then task.spawn(function() callback(currentKey) end) end
        end,
    }
end

local function addDropdown(page, text, options, defaultValue, callback, icon)
    local parent = pageCanvas(page)
    assert(#options > 0, "addDropdown options is empty")

    local selected = defaultValue
    if selected == nil or not table.find(options, selected) then
        selected = options[1]
    end

    local displayText = icon and icon .. " " .. text or text

    local holder = New("Frame", {
        BackgroundColor3 = Color3.fromRGB(28, 28, 34),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 40),
        ClipsDescendants = true,
        Parent = parent,
    })

    New("UICorner", { CornerRadius = UDim.new(0, 0), Parent = holder })
    New("UIStroke", { Color = Color3.fromRGB(55, 59, 62), Thickness = 1, Parent = holder })

    MarkNoWindowDrag(holder)

    New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, Config.Padding, 0, 0),
        Size = UDim2.new(1, -140, 0, 40),
        Font = Enum.Font.Gotham,
        TextSize = Config.BodySize,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = Color3.fromRGB(240, 240, 245),
        TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
        TextStrokeTransparency = 0.75,
        Text = displayText,
        Parent = holder,
    })

    local valueBtn = New("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = Color3.fromRGB(35, 35, 45),
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -Config.Padding, 0, 20),
        Size = UDim2.new(0, 110, 0, 26),
        Font = Enum.Font.GothamMedium,
        TextSize = Config.SmallSize,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Text = selected,
        Parent = holder,
    })

    New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = valueBtn })
    New("UIStroke", { Color = Config.Accent, Thickness = 1, Transparency = 0.65, Parent = valueBtn })

    MarkNoWindowDrag(valueBtn)

    local arrow = New("TextLabel", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -Config.Padding - 6, 0, 20),
        Size = UDim2.new(0, 18, 0, 18),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = Color3.fromRGB(220, 220, 230),
        Text = "▼",
        Parent = holder,
    })

    local listWrap = New("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 40),
        Size = UDim2.new(1, 0, 0, 0),
        ClipsDescendants = true,
        Parent = holder,
    })

    MarkNoWindowDrag(listWrap)

    New("UIPadding", {
        PaddingLeft = UDim.new(0, Config.Padding),
        PaddingRight = UDim.new(0, Config.Padding),
        PaddingBottom = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 6),
        Parent = listWrap,
    })

    local list = New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = listWrap,
    })

    local ll = New("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6),
        Parent = list,
    })

    local openedLocal = false

    local function closeSelf()
        if not openedLocal then return end
        openedLocal = false
        arrow.Text = "▼"

        local t = Config.Anim.DropdownSpeed
        PlayTween(listWrap, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 0, 0),
        })
        PlayTween(holder, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 0, 40),
        })

        if activeDropdownClose == closeSelf then
            activeDropdownClose = nil
        end
    end

    local function openSelf()
        if openedLocal then return end
        openedLocal = true

        if activeDropdownClose and activeDropdownClose ~= closeSelf then
            activeDropdownClose()
        end

        activeDropdownClose = closeSelf
        arrow.Text = "▲"

        task.defer(function()
            local wanted = ll.AbsoluteContentSize.Y + 10 + 10
            wanted = math.clamp(wanted, 0, 180)

            local t = Config.Anim.DropdownSpeed
            PlayTween(listWrap, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(1, 0, 0, wanted),
            })
            PlayTween(holder, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(1, 0, 0, 40 + wanted),
            })
        end)
    end

    local function toggleOpen()
        if openedLocal then
            closeSelf()
        else
            openSelf()
        end
    end

    local function applySelection(v, fire)
        selected = v
        valueBtn.Text = v
        if fire and callback then task.spawn(function() callback(v) end) end
    end

    for i, opt in ipairs(options) do
        local b = New("TextButton", {
            AutoButtonColor = false,
            BackgroundColor3 = Color3.fromRGB(35, 35, 45),
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 28),
            Font = Enum.Font.Gotham,
            TextSize = Config.SmallSize,
            TextColor3 = Color3.fromRGB(240, 240, 245),
            Text = opt,
            LayoutOrder = i,
            Parent = list,
        })

        New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = b })
        New("UIStroke", { Color = Color3.fromRGB(55, 59, 62), Thickness = 1, Transparency = 0.4, Parent = b })

        MarkNoWindowDrag(b)

        b.MouseButton1Click:Connect(function()
            applySelection(opt, true)
            closeSelf()
        end)
    end

    valueBtn.MouseButton1Click:Connect(toggleOpen)

    holder.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            toggleOpen()
        end
    end)

    applySelection(selected, false)

    return {
        Get = function() return selected end,
        Set = function(v)
            if table.find(options, v) then
                applySelection(v, true)
            end
        end,
        Open = openSelf,
        Close = closeSelf,
    }
end

local function addLabel(page, text)
    local parent = pageCanvas(page)
    New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 24),
        Font = Enum.Font.Gotham,
        TextSize = Config.BodySize,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = Color3.fromRGB(200, 200, 210),
        Text = text,
        Parent = parent,
    })
end

-- ========== TOGGLE OPEN/CLOSE ==========
local function setOpen(show)
    if show and not opened then
        opened = true
        overlay.Visible = true
        window.Visible = true
        modalBlocker.Visible = true

        PlayTween(window, getOpenTweenInfo(), {
            Size = Config.WindowSize,
            BackgroundTransparency = 0,
        })

        PlayTween(overlay, getOpenTweenInfo(), {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = Config.OverlayAlpha,
        })

        PlayTween(winStroke, getOpenTweenInfo(), {
            Transparency = 0.05,
        })

        PlayTween(accentLine, getOpenTweenInfo(), {
            BackgroundTransparency = 0,
        })

        if Config.BlurSize > 0 then
            PlayTween(blur, getOpenTweenInfo(), { Size = Config.BlurSize })
        end

        setMouseUnblock(true)

    elseif not show and opened then
        opened = false

        PlayTween(window, getOpenTweenInfo(), {
            Size = UDim2.fromOffset(0, 0),
            BackgroundTransparency = 1,
        })

        PlayTween(overlay, getOpenTweenInfo(), {
            Size = UDim2.fromScale(0, 0),
            BackgroundTransparency = 1,
        })

        PlayTween(winStroke, getOpenTweenInfo(), {
            Transparency = 1,
        })

        PlayTween(accentLine, getOpenTweenInfo(), {
            BackgroundTransparency = 1,
        })

        PlayTween(blur, getOpenTweenInfo(), { Size = 0 })

        local conn
        conn = blur:GetPropertyChangedSignal("Size"):Connect(function()
            if blur.Size == 0 then
                overlay.Visible = false
                window.Visible = false
                modalBlocker.Visible = false
                Disconnect(conn)
            end
        end)
        table.insert(allConnections, conn)

        setMouseUnblock(false)
    end
end

-- ========== KEYBIND TOGGLE ==========
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Config.ToggleKey then
        setOpen(not opened)
    end
end)

-- ========== BUTTON HANDLERS ==========
closeBtn.MouseButton1Click:Connect(function()
    setOpen(false)
end)

settingsBtn.MouseButton1Click:Connect(function()
    settingsPopover.Visible = not settingsPopover.Visible
end)

-- ========== PUBLIC API ==========
local UI = {
    -- Functions
    CreateTab = createTab,
    AddHeader = addHeader,
    AddButton = addButton,
    AddToggle = addToggle,
    AddSlider = addSlider,
    AddKeybind = addKeybind,
    AddDropdown = addDropdown,
    AddLabel = addLabel,

    -- Config & API
    Config = Config,
    Icons = Icons,
    SaveConfig = saveConfig,
    LoadConfig = loadConfig,

    -- Control
    Open = function() setOpen(true) end,
    Close = function() setOpen(false) end,
    Toggle = function() setOpen(not opened) end,

    -- Status
    IsOpen = function() return opened end,
}

-- ========== CLEANUP (LocalScript Compatible) ==========
-- Cleanup при выходе из игры (для обычного выхода)
local function cleanup()
    CancelAllTweens()
    DisconnectAll()
    if snowConnection then Disconnect(snowConnection) end
    pcall(function() RunService:UnbindFromRenderStep("GlowBlurUI_MouseUnblock") end)
    if gui then pcall(function() gui:Destroy() end) end
    destroyed = true
end

-- Убрали game:BindToClose - не работает в LocalScript
-- Вместо этого используем события PlayerGui

-- Cleanup при разрушении PlayerGui (самый надёжный способ)
local playerGuiConn = playerGui.AncestryChanged:Connect(function()
    if not playerGui.Parent then
        cleanup()
    end
end)
table.insert(allConnections, playerGuiConn)

-- Альтернативный cleanup при respawn
local charRemoving = game.Players.LocalPlayer.CharacterRemoving:Connect(function()
    -- Не уничтожаем UI при респауне, только скрываем
    if opened then
        setOpen(false)
    end
end)
table.insert(allConnections, charRemoving)

-- Auto-open on startup
task.delay(0.5, function()
    setOpen(true)
end)

return UI

