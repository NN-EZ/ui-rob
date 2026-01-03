--!strict
--// Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--// ICONS
local Icons = {
	Settings = "⚙️",
	SettingsICO = "rbxassetid://104919049969988",
	Info = "ℹ️",
	Home = "🏠",
	Misc = "✨",
	Save = "💾",
	Close = "❌",
	CloseICO = "rbxassetid://5577404210",
	Check = "✔️",
	Warning = "⚠️",
	Arrow = "➡️",
}
--// BACKGROUND
local FOLDER = "Vibus"
local BG_FILE   = FOLDER .. "/bg.png"
local CFG_FILE   = FOLDER .. "/Vibus_Settings.json"
local BG_URL    = "https://media.discordapp.net/attachments/1456348568079302758/1456351732048203838/content.png?ex=69580cbe&is=6956bb3e&hm=93df3347b1ec5fb2dbe36a584fe52a56b1c1a6d3bb99592b962eba9a2c40cff5&=&format=webp&quality=lossless"
--"https://media.discordapp.net/attachments/1456296637277274373/1456300436909850654/cd118457-2b80-4295-91ff-8828cabb9851.png?ex=6957dcf8&is=69568b78&hm=4623e5fec4c196b98cd5c6d793afe76514c908094378352f958945947af8a78c&=&format=webp&quality=lossless&width=1382&height=922"
--"https://media.discordapp.net/attachments/1456348568079302758/1456348662018998363/fee38623-a264-45f3-bd07-a261ad992e4b.png?ex=695809e2&is=6956b862&hm=f96f660a4d0a5b336e24df53d4e2376d43f424a5771b477d65a07afd1784b2b5&=&format=webp&quality=lossless&width=1379&height=919" 
--"https://media.discordapp.net/attachments/1456296637277274373/1456300436909850654/cd118457-2b80-4295-91ff-8828cabb9851.png?ex=6957dcf8&is=69568b78&hm=4623e5fec4c196b98cd5c6d793afe76514c908094378352f958945947af8a78c&=&format=webp&quality=lossless&width=1382&height=922"
local hasFS = makefolder and isfolder and writefile and readfile and getcustomasset

if hasFS then
    pcall(function()
        if not isfolder(FOLDER) then
            makefolder(FOLDER)
        end
        if not isfile(BG_FILE) then
            local bytes = game:HttpGet(BG_URL)
            writefile(BG_FILE, bytes)
        end
    end)
end
--// CONFIG
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

--====================================================
-- CONFIG STORE (Persistence)
--====================================================
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

    if writefile and makefolder and isfolder then
        pcall(function()
            if not isfolder(FOLDER) then
                makefolder(FOLDER)
            end
            writefile(CFG_FILE, json)
        end)
    end

    pcall(function()
        playerGui:SetAttribute("Vibus_Settings", json)
    end)
end

local function loadConfig()
    local json: any = nil

    if readfile and isfolder and isfile then
        pcall(function()
            if isfolder(FOLDER) and isfile(CFG_FILE) then
                json = readfile(CFG_FILE)
            end
        end)
    end

    if not json then
        pcall(function()
            json = playerGui:GetAttribute("Vibus_Settings")
        end)
    end

    if type(json) == "string" and #json > 0 then
        local ok, data = pcall(function()
            return HttpService:JSONDecode(json)
        end)

        if ok and type(data) == "table" then
            Config.BlurSize = data.BlurSize or Config.BlurSize
            Config.OverlayAlpha = data.OverlayAlpha or Config.OverlayAlpha
            Config.OpenTime = data.OpenTime or Config.OpenTime
            Config.TabTimeIn = data.TabTimeIn or Config.TabTimeIn
            Config.TabTimeOut = data.TabTimeOut or Config.TabTimeOut

            if data.AnimEnabled ~= nil then
                Config.Anim.Enabled = data.AnimEnabled
            end

            if data.SnowEnabled ~= nil then
                Config.Snow.Enabled = data.SnowEnabled
            end

            Config.Anim.ToggleSpeed = data.ToggleAnimSpeed or Config.Anim.ToggleSpeed
            Config.Anim.SliderSpeed = data.SliderAnimSpeed or Config.Anim.SliderSpeed

            if type(data.ToggleKey) == "string" then
                local kc = Enum.KeyCode[data.ToggleKey]
                if kc then
                    Config.ToggleKey = kc
                end
            end
        end
    end
end


loadConfig()

--====================================================
-- Lifetime / cleanup
--====================================================
local destroyed = false
local allConnections: { RBXScriptConnection } = {}
local allTweens: { Tween } = {}
local snowConnection: RBXScriptConnection? = nil

local function Disconnect(conn: RBXScriptConnection?)
	if conn then
		pcall(function()
			conn:Disconnect()
		end)
	end
end

local function DisconnectAll()
	for _, conn in ipairs(allConnections) do
		Disconnect(conn)
	end
	table.clear(allConnections)
end

local function CancelAllTweens()
	for _, t in ipairs(allTweens) do
		pcall(function()
			t:Cancel()
		end)
	end
	table.clear(allTweens)
end

-- forward decl
local gui: ScreenGui? = nil
local overlay: Frame? = nil
local blur: BlurEffect? = nil
local createdBlur = false
local window: Frame? = nil
local winStroke: UIStroke? = nil
local accentLine: Frame? = nil
local tabsFrame: Frame? = nil
local content: Frame? = nil
local topbar: Frame? = nil
local modalBlocker: TextButton? = nil
local settingsPopover: Frame? = nil
local settingsBtn: ImageButton? = nil
local closeBtn: ImageButton? = nil

local opened = false
local openTweens: { Tween } = {}
local tabOrder = 0
local currentPage: ScrollingFrame? = nil
local tabSwitching = false

-- NEW (Keybind widget)
local keybindListening = false

-- NEW (Dropdown auto-close)
local activeDropdownClose: (() -> ())? = nil

local logFrame: Frame? = nil
local logList: Frame? = nil
local logLayout: UIListLayout? = nil
local logCounter = logCounter or 0
--====================================================
-- Utility
--====================================================

local function GetInset(): Vector2
	local inset = GuiService:GetGuiInset()
	return Vector2.new(inset.X, inset.Y)
end

local function GetMouse2D(): Vector2
	return UserInputService:GetMouseLocation() - GetInset()
end

local function New(className: string, props: { [string]: any }?, children: { Instance }?): Instance
	local inst = Instance.new(className)
	if props then
		for k, v in pairs(props) do
			(inst :: any)[k] = v
		end
	end
	if children then
		for _, c in ipairs(children) do
			c.Parent = inst
		end
	end
	return inst
end

local function PlayTween(obj: Instance, info: TweenInfo, goal: { [string]: any }): Tween
	local t = TweenService:Create(obj, info, goal)
	t:Play()
	table.insert(allTweens, t)
	return t
end

--====================================================
-- PushLog (MUST be after New() and PlayTween())
--====================================================
local function PushLog(level: string, msg: string)
	-- можно вызывать через UI.Log / UI.PushLog / getgenv().PushLog
	if not gui or not logFrame then
		-- GUI ещё не поднят (во время инициализации)
		-- хотя снаружи ты всё равно не вызовешь до return UI
		return
	end

	level = tostring(level or "INFO")
	msg = tostring(msg or "")

	-- консоль
	print(("[" .. level .. "] " .. msg))

	-- цвет по уровню
	local color = Color3.fromRGB(180, 180, 180)
	if level == "WARN" then
		color = Color3.fromRGB(255, 215, 90)
	elseif level == "ERROR" then
		color = Color3.fromRGB(255, 80, 80)
	end

	logCounter += 1
	local offsetY = logCounter * 25

	local prefix = "[" .. level .. "] "

	local line = New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(360, 18),
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 15 + math.random(-5, 5), 1, -25 - offsetY),
		AutomaticSize = Enum.AutomaticSize.None,
		Font = Enum.Font.Code,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextSize = 13,
		TextColor3 = color,
		TextTransparency = 1,
		Text = prefix .. msg,
		ZIndex = 950,
		Parent = logFrame,
	}) :: TextLabel

	-- 1) Появление
	PlayTween(line, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		TextTransparency = 0.45,
		Position = UDim2.new(0, 15 + math.random(-5, 5), 1, -45 - offsetY),
	})

	-- 2) Пик яркости
	task.delay(0.3, function()
		if not line or not line.Parent then return end
		PlayTween(line, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			TextTransparency = 0.05,
			Position = UDim2.new(0, 15 + math.random(-15, 15), 0.7, -120 - offsetY * 0.8),
		})
	end)

	-- 3) Улет + удаление
	task.delay(2.0, function()
		if not line or not line.Parent then return end
		PlayTween(line, TweenInfo.new(1.0, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			TextTransparency = 1,
			Position = UDim2.new(0, 15 + math.random(-25, 25), 0.2, -350 - offsetY),
		})
		task.delay(1.05, function()
			if line then line:Destroy() end
		end)
	end)

	if logCounter >= 10 then
		logCounter = 0
	end
end

local function CancelAll(list: { Tween })
	for _, t in ipairs(list) do
		pcall(function()
			t:Cancel()
		end)
	end
	table.clear(list)
end

local function GetAnimInfo(speed: number, style: Enum.EasingStyle, dir: Enum.EasingDirection, bounce: boolean?): TweenInfo
	if not Config.Anim.Enabled then
		return TweenInfo.new(0.001, style, dir)
	end
	local tweenStyle = style
	if bounce and style == Enum.EasingStyle.Quad then
		tweenStyle = Enum.EasingStyle.Elastic
	end
	return TweenInfo.new(speed, tweenStyle, dir)
end

local function getOpenTweenInfo(): TweenInfo
	return TweenInfo.new(Config.OpenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
end

local function StartDrag(onMove: (Vector2) -> (), onEnd: (() -> ())?): () -> ()
	local alive = true
	local conMove: RBXScriptConnection? = nil
	local conEnd: RBXScriptConnection? = nil

	conMove = UserInputService.InputChanged:Connect(function(input, gameProcessed)
		if not alive or gameProcessed then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			local p = input.Position
			onMove(Vector2.new(p.X, p.Y))
		end
	end)

	conEnd = UserInputService.InputEnded:Connect(function(input)
		if not alive then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			alive = false
			Disconnect(conMove)
			Disconnect(conEnd)
			if onEnd then
				onEnd()
			end
		end
	end)

	return function()
		alive = false
		Disconnect(conMove)
		Disconnect(conEnd)
	end
end

local function ClampWindowPosition(windowObj: Frame, maxX: number, maxY: number)
	local pos = windowObj.Position
	local size = windowObj.AbsoluteSize
	windowObj.Position = UDim2.new(
		pos.X.Scale,
		math.clamp(pos.X.Offset, -size.X, maxX),
		pos.Y.Scale,
		math.clamp(pos.Y.Offset, -size.Y, maxY)
	)
end

local function MarkNoWindowDrag(obj: Instance)
	if obj:IsA("GuiObject") then
		obj:SetAttribute("NoWindowDrag", true)
	end
end

local function IsNoWindowDrag(obj: Instance): boolean
	return obj:GetAttribute("NoWindowDrag") == true
end

--====================================================
-- Mouse unblock (Modal blocker + Restore)
--====================================================
local mouseSaved = false
local prevMouseBehavior: Enum.MouseBehavior = Enum.MouseBehavior.Default
local prevMouseIconEnabled: boolean = true

local function setMouseUnblock(enable: boolean)
	if enable then
		if not mouseSaved then
			mouseSaved = true
			prevMouseBehavior = UserInputService.MouseBehavior
			prevMouseIconEnabled = UserInputService.MouseIconEnabled
		end

		pcall(function()
			RunService:UnbindFromRenderStep("GlowBlurUI_MouseUnblock")
		end)

		RunService:BindToRenderStep("GlowBlurUI_MouseUnblock", Enum.RenderPriority.Camera.Value + 1, function()
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
			UserInputService.MouseIconEnabled = true
		end)
	else
		pcall(function()
			RunService:UnbindFromRenderStep("GlowBlurUI_MouseUnblock")
		end)

		if mouseSaved then
			UserInputService.MouseBehavior = prevMouseBehavior
			UserInputService.MouseIconEnabled = prevMouseIconEnabled
			mouseSaved = false
		end
	end
end

--====================================================
-- Exit (safe)
--====================================================
local function setOpen(show: boolean) end -- forward

local function Exit()
	if destroyed then
		return
	end
	destroyed = true

	pcall(function()
		setOpen(false)
	end)

	DisconnectAll()
	CancelAllTweens()

	if snowConnection then
		Disconnect(snowConnection)
		snowConnection = nil
	end

	pcall(function()
		RunService:UnbindFromRenderStep("GlowBlurUI_MouseUnblock")
	end)

	if blur then
		if createdBlur then
			pcall(function()
				blur:Destroy()
			end)
		else
			blur.Enabled = false
			blur.Size = 0
		end
		blur = nil
	end

	if gui then
		pcall(function()
			gui:Destroy()
		end)
		gui = nil
	end

	if getgenv and getgenv().UI then
		getgenv().UI = nil
	end
end

pcall(function()
	local env = (getgenv and getgenv()) or nil
	local ui = env and env.UI or nil
	if type(ui) == "table" and type(ui.Exit) == "function" then
		ui.Exit()
	end
end)

--====================================================
-- ROOT GUI
--====================================================
gui = New("ScreenGui", {
	Name = "GlowBlurUI",
	IgnoreGuiInset = true,
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	Parent = playerGui,
}) :: ScreenGui

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
}) :: Frame

blur = Lighting:FindFirstChild("GlowBlur") :: BlurEffect?
createdBlur = false
if not blur then
	blur = Instance.new("BlurEffect")
	blur.Name = "GlowBlur"
	blur.Parent = Lighting
	createdBlur = true
end
blur.Enabled = true
blur.Size = 0

--====================================================
-- SNOW SYSTEM (simple)
--====================================================
local function createSnowParticle(): Frame
	assert(overlay and gui, "overlay/gui missing")
	local sizePx = math.random(3, 7)
	return New("Frame", {
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(sizePx, sizePx),
		AnchorPoint = Vector2.new(0.5, 0.5),
		ZIndex = 0,
		Parent = overlay,
	}, {
		New("UICorner", { CornerRadius = UDim.new(1, 0) }),
	}) :: Frame
end

local function animateSnowParticle(frame: Frame)
	assert(gui, "gui missing")
	local screen = gui.AbsoluteSize
	local startX = math.random(0, math.max(1, screen.X))
	local startY = -30
	local endX = startX + math.random(-80, 80)
	local endY = screen.Y + 40

	frame.Position = UDim2.fromOffset(startX, startY)

	local duration = math.random(8, 14)
	local tween = PlayTween(frame, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
		Position = UDim2.fromOffset(endX, endY),
	})

	local conn: RBXScriptConnection? = nil
	conn = tween.Completed:Connect(function()
		Disconnect(conn)
		pcall(function()
			frame:Destroy()
		end)
	end)
	table.insert(allConnections, conn :: any)
end

local function startSnow()
	if not Config.Snow.Enabled then
		return
	end
	if not overlay then
		return
	end
	if snowConnection then
		Disconnect(snowConnection)
	end

	local particleCount = 0
	snowConnection = RunService.Heartbeat:Connect(function()
		if not overlay or not overlay.Visible then
			return
		end
		if particleCount < Config.Snow.MaxParticles then
			local particle = createSnowParticle()
			animateSnowParticle(particle)
			particleCount += 1
		else
			particleCount = Config.Snow.MaxParticles - 5
		end
	end)
end

local function stopSnow()
	if snowConnection then
		Disconnect(snowConnection)
		snowConnection = nil
	end
	if overlay then
		for _, child in ipairs(overlay:GetChildren()) do
			if child:IsA("Frame") then
				pcall(function()
					child:Destroy()
				end)
			end
		end
	end
end

--====================================================
-- WINDOW
--====================================================
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
}, {
	New("UICorner", { CornerRadius = UDim.new(0, 12) }),
}) :: Frame

local bgImage
if hasFS then
    local ok, asset = pcall(function()
        return getcustomasset(BG_FILE)
    end)

    if ok and asset then
        bgImage = New("ImageLabel", {
            Name = "BackgroundImage",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Image = asset,
            ScaleType = Enum.ScaleType.Stretch, 
            Size = UDim2.new(1, 0, 1, 0),      
            Position = UDim2.fromScale(0, 0),
            ZIndex = 0,
            ImageTransparency = 0.6,
            Parent = window,
        }, {
            New("UICorner", { CornerRadius = UDim.new(0, 12) }) 
        })
    end
end

window.ZIndex = 2
--topbar.ZIndex = 3
--body.ZIndex = 3

winStroke = New("UIStroke", {
	Color = Config.StrokeColor,
	Thickness = 2,
	Transparency = 1,
	Parent = window,
}, {
	New("UIGradient", {
		Rotation = 45,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Config.Accent),
			ColorSequenceKeypoint.new(0.5, Config.AccentGlow),
			ColorSequenceKeypoint.new(1, Config.Accent),
		}),
	}),
}) :: UIStroke

New("UIGradient", {
	Rotation = 90,
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(24, 24, 28)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 20, 24)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 16, 18)),
	}),
	Parent = window,
})

topbar = New("Frame", {
	Name = "Topbar",
	Size = UDim2.new(1, 0, 0, 48),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Parent = window,
}) :: Frame

titleHolder = New("Frame", {
    Name = "TitleHolder",
    BackgroundTransparency = 1,
    Position = UDim2.new(0, Config.Padding, 0, 0),
    Size = UDim2.new(1, -140, 1, 0),
    Parent = topbar,
}, {
    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 8), -- Отступ между текстом и ссылкой
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
})

New("TextLabel", {
    Name = "Title",
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    TextSize = Config.TitleSize,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
    TextStrokeTransparency = 0.5,
    Text = "Vibus🎄",
    AutomaticSize = Enum.AutomaticSize.XY,
    Parent = titleHolder,
})

local animBusy = false
local defaultText = "| Discord"
local copiedText  = "| Copied!"

local hoverTweenIn
local hoverTweenOut

local function tween(obj, info, props)
    local tw = TweenService:Create(obj, info, props)
    tw:Play()
    return tw
end

local fadeInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function smoothSwapText(btn, newText, newColor, showTime)
    if animBusy then return end
    animBusy = true
    tween(btn, fadeInfo, {
        TextTransparency = 1,
        TextStrokeTransparency = 1,
    }).Completed:Wait()
    btn.Text = newText
    if newColor then
        btn.TextColor3 = newColor
        btn.TextStrokeTransparency = 0.7
    end
    tween(btn, fadeInfo, {
        TextTransparency = 0,
        TextStrokeTransparency = btn.TextStrokeTransparency,
    }).Completed:Wait()
    task.wait(showTime or 1.2)
    tween(btn, fadeInfo, {
        TextTransparency = 1,
        TextStrokeTransparency = 1,
    }).Completed:Wait()
    btn.Text = defaultText
    btn.TextColor3 = Config.Accent
    btn.TextStrokeTransparency = 1
    tween(btn, fadeInfo, {
        TextTransparency = 0,
        TextStrokeTransparency = 1,
    }):Play()
    animBusy = false
end

local discordLink = New("TextButton", {
    Name = "DiscordLink",
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    TextSize = Config.TitleSize - 1,
    Text = "| Discord",
    TextXAlignment = Enum.TextXAlignment.Left,
    TextColor3 = Config.Accent,
    TextStrokeTransparency = 1,
    AutoButtonColor = false,
    AutomaticSize = Enum.AutomaticSize.XY,
    Parent = titleHolder,
})

discordLink.MouseButton1Click:Connect(function()
    setclipboard("https://discord.gg/vwBVrhnN4c")
    if typeof(PushLog) == "function" then
        PushLog("INFO", "Discord ссылка скопирована!")
    end
    smoothSwapText(discordLink, copiedText, Color3.fromRGB(80, 255, 120), 1.2)
end)

discordLink.MouseEnter:Connect(function()
    if animBusy then return end
    if hoverTweenOut then
        hoverTweenOut:Cancel()
    end
    hoverTweenIn = tween(discordLink, fadeInfo, {
        TextColor3 = Config.AccentGlow,
        TextStrokeTransparency = 0.7,
    })
end)

discordLink.MouseLeave:Connect(function()
    if animBusy then return end
    if hoverTweenIn then
        hoverTweenIn:Cancel()
    end
    hoverTweenOut = tween(discordLink, fadeInfo, {
        TextColor3 = Config.Accent,
        TextStrokeTransparency = 1,
    })
end)

settingsPopover = New("Frame", {
	Name = "SettingsPopover",
	BackgroundColor3 = Config.WindowBg,
	BorderSizePixel = 0,
	Size = UDim2.new(0, 240, 0, 0),
	Position = UDim2.new(1, -250, 0, 48),
	Visible = false,
	ClipsDescendants = true,
	Parent = topbar,
}, {
	New("UICorner", { CornerRadius = UDim.new(0, 8) }),
	New("UIStroke", { Color = Config.Accent, Thickness = 1, Transparency = 0.5 }),
}) :: Frame

New("Frame", {
	Name = "Content",
	BackgroundTransparency = 1,
	Size = UDim2.new(1, 0, 1, 0),
	Parent = settingsPopover,
}, {
	New("UIPadding", {
		PaddingTop = UDim.new(0, 8),
		PaddingLeft = UDim.new(0, 8),
		PaddingRight = UDim.new(0, 8),
		PaddingBottom = UDim.new(0, 8),
	}),
	New("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 6),
	}),
})

settingsBtn = New("ImageButton", {
	Name = "Settings",
	BackgroundTransparency = 1,
	Size = UDim2.new(0, 24, 0, 24),
	Position = UDim2.new(1, -80, 0, 12),
	AutoButtonColor = false,
	Image = Icons.SettingsICO,
	Parent = topbar,
}) :: ImageButton

closeBtn = New("ImageButton", {
	Name = "Close",
	BackgroundTransparency = 1,
	Size = UDim2.new(0, 24, 0, 24),
	Position = UDim2.new(1, -40, 0, 12),
	AutoButtonColor = false,
	Image = Icons.CloseICO,
	Parent = topbar,
}) :: ImageButton

accentLine = New("Frame", {
	Name = "Accent",
	BackgroundColor3 = Config.Accent,
	BorderSizePixel = 0,
	Position = UDim2.new(0, 0, 0, 48),
	Size = UDim2.new(1, 0, 0, 2),
	BackgroundTransparency = 1,
	Parent = window,
}) :: Frame

New("UIStroke", {
	Color = Config.AccentGlow,
	Thickness = 3,
	Transparency = 1,
	Parent = accentLine,
})

local body = New("Frame", {
	Name = "Body",
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 0, 0, 50),
	Size = UDim2.new(1, 0, 1, -50),
	Parent = window,
}) :: Frame

tabsFrame = New("Frame", {
	Name = "Tabs",
	BackgroundTransparency = 1,
	Size = UDim2.new(0, 160, 1, 0),
	Parent = body,
}, {
	New("UIPadding", {
		PaddingTop = UDim.new(0, Config.Padding),
		PaddingLeft = UDim.new(0, Config.Padding),
		PaddingRight = UDim.new(0, Config.GapSmall),
	}),
	New("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, Config.GapSmall),
	}),
}) :: Frame

content = New("Frame", {
	Name = "Content",
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 160, 0, 0),
	Size = UDim2.new(1, -160, 1, 0),
	Parent = body,
}, {
	New("UIPadding", {
		PaddingTop = UDim.new(0, Config.Padding),
		PaddingLeft = UDim.new(0, Config.Padding),
		PaddingRight = UDim.new(0, Config.Padding),
		PaddingBottom = UDim.new(0, Config.Padding),
	}),
}) :: Frame

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
}) :: TextButton
modalBlocker.ZIndex = 1
window.ZIndex = 200000000

--====================================================
-- TAB FUNCTIONS
--====================================================
local function styleTabButton(btn: TextButton, active: boolean)
	local stroke = btn:FindFirstChildOfClass("UIStroke") :: UIStroke?
	btn.TextTransparency = 0
	btn.TextColor3 = active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(230, 230, 235)
	local bg = active and Color3.fromRGB(40, 35, 50) or Color3.fromRGB(28, 28, 34)
	PlayTween(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = bg })
	if stroke then
		PlayTween(stroke, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = active and 0.05 or 0.65,
			Thickness = active and 2.5 or 1.5,
		})
	end
end

local function createPage(): (ScrollingFrame, CanvasGroup)
	assert(content, "content missing")

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
	}) :: ScrollingFrame

	local cg = New("CanvasGroup", {
		Name = "CanvasGroup",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		GroupTransparency = 0,
		Position = UDim2.new(0, 0, 0, 0),
		Parent = page,
	}) :: CanvasGroup

	local list = New("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, Config.GapMedium),
		Parent = cg,
	}) :: UIListLayout

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

local function createTab(tabName: string, icon: string?)
	assert(tabsFrame, "tabsFrame missing")

	tabOrder += 1
	local displayText = icon and (icon .. " " .. tabName) or tabName

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
	}) :: TextButton

	New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = btn })

	local stroke = New("UIStroke", {
		Name = "Stroke",
		Color = Config.Accent,
		Thickness = 1.5,
		Transparency = 0.65,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = btn,
	}) :: UIStroke

	local scale = New("UIScale", { Scale = 1, Parent = btn }) :: UIScale
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
		if tabSwitching then
			return
		end
		if currentPage == page then
			return
		end
		tabSwitching = true

		if currentPage then
			local oldCg = currentPage:FindFirstChild("CanvasGroup") :: CanvasGroup?
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

		local conn: RBXScriptConnection? = nil
		conn = tIn.Completed:Connect(function()
			Disconnect(conn)
			tabSwitching = false
		end)
		table.insert(allConnections, conn :: any)
	end

	btn.MouseButton1Click:Connect(select)
	styleTabButton(btn, false)

	if not currentPage and tabName ~= "Settings" then
		task.defer(select)
	end

	return {
		Button = btn,
		Page = page,
		Canvas = canvasGroup,
		Select = select,
	}
end

local function pageCanvas(page: ScrollingFrame): CanvasGroup
	local cg = page:FindFirstChild("CanvasGroup")
	assert(cg and cg:IsA("CanvasGroup"), "Page missing CanvasGroup")
	return cg
end

--==============================
-- LOG PANEL (bottom-left)
--==============================
logFrame = New("Frame", {
    Name = "LogPanel",
    BackgroundTransparency = 1, -- полностью прозрачный фон
    BorderSizePixel = 0,
    AnchorPoint = Vector2.new(0, 1),
    Position = UDim2.new(0, 10, 1, -10),
    Size = UDim2.fromOffset(0, 0),
    AutomaticSize = Enum.AutomaticSize.XY,
    Active = false, -- не блокируем клики
    ZIndex = 900,
    Parent = gui,
}) :: Frame

New("UIPadding", {
    PaddingLeft = UDim.new(0, 6),
    PaddingRight = UDim.new(0, 6),
    PaddingTop = UDim.new(0, 6),
    PaddingBottom = UDim.new(0, 6),
    Parent = logFrame,
})

logList = New("Frame", {
    Name = "List",
    BackgroundTransparency = 1,
    Size = UDim2.fromOffset(0, 0),
    AutomaticSize = Enum.AutomaticSize.XY,
    Parent = logFrame,
}) :: Frame

logLayout = New("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 2),
    HorizontalAlignment = Enum.HorizontalAlignment.Left,
    VerticalAlignment = Enum.VerticalAlignment.Bottom,
    Parent = logList,
}) :: UIListLayout

-- чтобы лог не разъезжался слишком широко/высоко
New("UISizeConstraint", {
    MaxSize = Vector2.new(700, 220),
    Parent = logFrame,
})

--====================================================
-- WIDGET FUNCTIONS
--====================================================
local function addHeader(page: ScrollingFrame, text: string)
	local parent = pageCanvas(page)
	New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 24),
		Font = Enum.Font.GothamMedium,
		TextSize = Config.HeaderSize + 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = Config.Accent,
		TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
		TextStrokeTransparency = 0.6,
		Text = text,
		Parent = parent,
	})
end

local function addButton(page: ScrollingFrame, text: string, callback: (() -> ())?, icon: string?, priority: string?)
	local parent = pageCanvas(page)
	priority = priority or "normal"

	local holder = New("Frame", {
		BackgroundColor3 = Color3.fromRGB(28, 28, 34),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 40),
		Parent = parent,
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 0) }),
		New("UIStroke", { Color = Color3.fromRGB(55, 59, 62), Thickness = 1 }),
	}) :: Frame

	local displayText = icon and (icon .. " " .. text) or text

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
	}) :: TextButton

	MarkNoWindowDrag(button)

	local st = holder:FindFirstChildOfClass("UIStroke") :: UIStroke
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
		PlayTween(scale, TweenInfo.new(Config.Anim.ButtonPressSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 0.95 })
	end)

	button.MouseButton1Up:Connect(function()
		PlayTween(scale, TweenInfo.new(Config.Anim.ButtonPressSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 1 })
	end)

	button.MouseButton1Click:Connect(function()
		if callback then
			task.spawn(callback)
		end
	end)
end

local function addToggle(page: ScrollingFrame, text: string, default: boolean, callback: ((boolean) -> ())?, icon: string?)
	local parent = pageCanvas(page)
	local state = default and true or false

	local holder = New("Frame", {
		BackgroundColor3 = Color3.fromRGB(28, 28, 34),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 40),
		Parent = parent,
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 0) }),
		New("UIStroke", { Color = Color3.fromRGB(55, 59, 62), Thickness = 1 }),
	}) :: Frame

	local displayText = icon and (icon .. " " .. text) or text

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
	}) :: TextButton
	MarkNoWindowDrag(pill)

	New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = pill })

	local dot = New("Frame", {
		BorderSizePixel = 0,
		Size = UDim2.new(0, 20, 0, 20),
		Position = UDim2.new(0, 2, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		Parent = pill,
	}) :: Frame
	New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = dot })

	local glow = New("UIStroke", {
		Color = Config.AccentGlow,
		Thickness = 2,
		Transparency = 1,
		Parent = pill,
	}) :: UIStroke

	local function apply(noTween: boolean)
		local bg = state and Config.Success or Color3.fromRGB(80, 80, 90)
		local dotPos = state and UDim2.new(1, -22, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
		local glowTrans = state and 0.4 or 1

		if noTween or not Config.Anim.Enabled then
			pill.BackgroundColor3 = bg
			dot.Position = dotPos
			dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			glow.Transparency = glowTrans
		else
			PlayTween(pill, GetAnimInfo(Config.Anim.ToggleSpeed, Config.Anim.ToggleEasing, Config.Anim.ToggleDirection, Config.Anim.ToggleBounce), { BackgroundColor3 = bg })
			PlayTween(dot, GetAnimInfo(Config.Anim.ToggleSpeed, Config.Anim.ToggleEasing, Config.Anim.ToggleDirection, Config.Anim.ToggleBounce), { Position = dotPos })
			PlayTween(glow, GetAnimInfo(Config.Anim.ToggleSpeed, Config.Anim.ToggleEasing, Config.Anim.ToggleDirection), { Transparency = glowTrans })
		end
	end

	pill.MouseButton1Click:Connect(function()
		state = not state
		apply(false)
		if callback then
			task.spawn(callback, state)
		end
	end)

	apply(true)

	return {
		Get = function(): boolean
			return state
		end,
		Set = function(v: boolean)
			state = v
			apply(false)
			if callback then
				task.spawn(callback, state)
			end
		end,
		Toggle = function()
			state = not state
			apply(false)
			if callback then
				task.spawn(callback, state)
			end
		end,
	}
end

local function addSlider(page: ScrollingFrame, text: string, minVal: number, maxVal: number, defaultVal: number, callback: ((number) -> ())?, icon: string?)
	local parent = pageCanvas(page)
	defaultVal = math.clamp(defaultVal, minVal, maxVal)
	local displayText = icon and (icon .. " " .. text) or text

	local holder = New("Frame", {
		BackgroundColor3 = Color3.fromRGB(28, 28, 34),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 56),
		Parent = parent,
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 0) }),
		New("UIStroke", { Color = Color3.fromRGB(55, 59, 62), Thickness = 1 }),
	}) :: Frame
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
	}) :: TextLabel

	local line = New("Frame", {
		BackgroundColor3 = Color3.fromRGB(50, 50, 60),
		BorderSizePixel = 0,
		Position = UDim2.new(0, Config.Padding, 0, 28),
		Size = UDim2.new(1, -Config.Padding * 2, 0, 5),
		Parent = holder,
	}, {
		New("UICorner", { CornerRadius = UDim.new(1, 0) }),
	}) :: Frame
	MarkNoWindowDrag(line)

	local fill = New("Frame", {
		BackgroundColor3 = Config.Accent,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 0, 1, 0),
		Parent = line,
	}, {
		New("UICorner", { CornerRadius = UDim.new(1, 0) }),
	}) :: Frame
	MarkNoWindowDrag(fill)

	local thumb = New("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = Color3.fromRGB(240, 240, 255),
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(16, 16),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Text = "",
		Parent = line,
	}, {
		New("UICorner", { CornerRadius = UDim.new(1, 0) }),
		New("UIStroke", { Color = Config.AccentGlow, Thickness = 2, Transparency = 0.3 }),
	}) :: TextButton
	MarkNoWindowDrag(thumb)

	local value = defaultVal
	local stopDrag: (() -> ())? = nil

	local function setVisual(v: number)
		v = math.clamp(v, minVal, maxVal)
		local a = (v - minVal) / (maxVal - minVal)

		if Config.Anim.Enabled then
			PlayTween(fill, GetAnimInfo(Config.Anim.SliderSpeed, Config.Anim.SliderEasing, Config.Anim.SliderDirection), { Size = UDim2.new(a, 0, 1, 0) })
			PlayTween(thumb, GetAnimInfo(Config.Anim.SliderSpeed, Config.Anim.SliderEasing, Config.Anim.SliderDirection), { Position = UDim2.new(a, 0, 0.5, 0) })
		else
			fill.Size = UDim2.new(a, 0, 1, 0)
			thumb.Position = UDim2.new(a, 0, 0.5, 0)
		end

		valueLabel.Text = tostring(math.floor(v))
	end

	local function setFromX(xPos: number)
		local absPos = line.AbsolutePosition.X
		local absSize = line.AbsoluteSize.X
		if absSize <= 0 then
			return
		end
		local rel = math.clamp((xPos - absPos) / absSize, 0, 1)
		value = minVal + (maxVal - minVal) * rel
		setVisual(value)
		if callback then
			task.spawn(callback, value)
		end
	end

	local function beginDrag(startPos2D: Vector2)
		if stopDrag then
			stopDrag()
		end
		setFromX(startPos2D.X)

		stopDrag = StartDrag(function(pos)
			local p2d = pos - GetInset()
			setFromX(p2d.X)
		end, function()
			stopDrag = nil
		end)
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
		SetValue = function(v: number)
			value = math.clamp(v, minVal, maxVal)
			setVisual(value)
		end,
		GetValue = function(): number
			return value
		end,
	}
end

--====================================================
-- Keybind widget
--====================================================
local function addKeybind(page: ScrollingFrame, text: string, defaultKey: Enum.KeyCode, callback: ((Enum.KeyCode) -> ())?, icon: string?)
	local parent = pageCanvas(page)
	local currentKey: Enum.KeyCode = defaultKey
	local displayText = icon and (icon .. " " .. text) or text

	local holder = New("Frame", {
		BackgroundColor3 = Color3.fromRGB(28, 28, 34),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 40),
		Parent = parent,
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 0) }),
		New("UIStroke", { Color = Color3.fromRGB(55, 59, 62), Thickness = 1 }),
	}) :: Frame
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
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 8) }),
		New("UIStroke", { Color = Config.Accent, Thickness = 1, Transparency = 0.65 }),
	}) :: TextButton
	MarkNoWindowDrag(btn)

	btn.MouseButton1Click:Connect(function()
		if keybindListening then
			return
		end
		keybindListening = true

		btn.Text = "Press key..."
		local conn: RBXScriptConnection? = nil

		conn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then
				return
			end
			if input.UserInputType ~= Enum.UserInputType.Keyboard then
				return
			end

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

			if callback then
				task.spawn(callback, currentKey)
			end
		end)

		table.insert(allConnections, conn :: any)
	end)

	return {
		Get = function(): Enum.KeyCode
			return currentKey
		end,
		Set = function(k: Enum.KeyCode)
			currentKey = k
			btn.Text = currentKey.Name
			if callback then
				task.spawn(callback, currentKey)
			end
		end,
	}
end

--====================================================
-- DropDown (single)
--====================================================
local function addDropdown(
	page: ScrollingFrame,
	text: string,
	options: { string },
	defaultValue: string?,
	callback: ((string) -> ())?,
	icon: string?
)
	local parent = pageCanvas(page)
	assert(#options > 0, "addDropdown: options is empty")

	local selected = defaultValue
	if selected == nil or not table.find(options, selected) then
		selected = options[1]
	end

	local displayText = icon and (icon .. " " .. text) or text

	local holder = New("Frame", {
		BackgroundColor3 = Color3.fromRGB(28, 28, 34),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 40),
		ClipsDescendants = true,
		Parent = parent,
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 0) }),
		New("UIStroke", { Color = Color3.fromRGB(55, 59, 62), Thickness = 1 }),
	}) :: Frame
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
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 8) }),
		New("UIStroke", { Color = Config.Accent, Thickness = 1, Transparency = 0.65 }),
	}) :: TextButton
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
	}) :: TextLabel

	local listWrap = New("ScrollingFrame", {
	    BackgroundTransparency = 1,
	    Position = UDim2.new(0, 0, 0, 40),
	    Size = UDim2.new(1, 0, 0, 0),
	    CanvasSize = UDim2.new(0, 0, 0, 0),  
	    ScrollBarThickness = 4,               
	    ScrollBarImageTransparency = 0.5,     
	    ClipsDescendants = true,
	    Parent = holder,
	})
	MarkNoWindowDrag(listWrap)


	local pad = New("UIPadding", {
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
	}) :: Frame

	local ll = New("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 6),
		Parent = list,
	}) :: UIListLayout

	local openedLocal = false

	local function closeSelf()
		if not openedLocal then
			return
		end
		openedLocal = false
		arrow.Text = "▼"

		local t = Config.Anim.DropdownSpeed
		PlayTween(listWrap, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 0, 0) })
		PlayTween(holder, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 0, 40) })

		if activeDropdownClose == closeSelf then
			activeDropdownClose = nil
		end
	end

	local function openSelf()
		if openedLocal then
			return
		end
		openedLocal = true

		if activeDropdownClose and activeDropdownClose ~= closeSelf then
			activeDropdownClose()
		end
		activeDropdownClose = closeSelf

		arrow.Text = "▲"

		task.defer(function()
			local wanted = ll.AbsoluteContentSize.Y + pad.PaddingTop.Offset + pad.PaddingBottom.Offset
			wanted = math.clamp(wanted, 0, 180)

			local t = Config.Anim.DropdownSpeed
			PlayTween(listWrap, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 0, wanted) })
			PlayTween(holder, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 0, 40 + wanted) })
		end)
	end

	local function toggleOpen()
		if openedLocal then
			closeSelf()
		else
			openSelf()
		end
	end

	local function applySelection(v: string, fire: boolean)
		selected = v
		valueBtn.Text = v
		if fire and callback then
			task.spawn(callback, v)
		end
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
		}, {
			New("UICorner", { CornerRadius = UDim.new(0, 8) }),
			New("UIStroke", { Color = Color3.fromRGB(55, 59, 62), Thickness = 1, Transparency = 0.4 }),
		}) :: TextButton
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
		Get = function(): string
			return selected
		end,
		Set = function(v: string)
			if table.find(options, v) then
				applySelection(v, true)
			end
		end,
		Open = openSelf,
		Close = closeSelf,
	}
end

--====================================================
-- MultiDropDown (multi)
--====================================================
local function addMultiDropdown(
	page: ScrollingFrame,
	text: string,
	options: { string },
	defaultSelected: { string }?,
	callback: (({ string }) -> ())?,
	icon: string?
)
	local parent = pageCanvas(page)
	assert(#options > 0, "addMultiDropdown: options is empty")

	local selectedMap: { [string]: boolean } = {}
	if defaultSelected then
		for _, v in ipairs(defaultSelected) do
			if table.find(options, v) then
				selectedMap[v] = true
			end
		end
	end

	local displayText = icon and (icon .. " " .. text) or text

	local holder = New("Frame", {
		BackgroundColor3 = Color3.fromRGB(28, 28, 34),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 40),
		ClipsDescendants = true,
		Parent = parent,
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 0) }),
		New("UIStroke", { Color = Color3.fromRGB(55, 59, 62), Thickness = 1 }),
	}) :: Frame
	MarkNoWindowDrag(holder)

	New("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, Config.Padding, 0, 0),
		Size = UDim2.new(1, -170, 0, 40),
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
		Size = UDim2.new(0, 140, 0, 26),
		Font = Enum.Font.GothamMedium,
		TextSize = Config.SmallSize,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Text = "0 selected",
		Parent = holder,
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 8) }),
		New("UIStroke", { Color = Config.Accent, Thickness = 1, Transparency = 0.65 }),
	}) :: TextButton
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
	}) :: TextLabel

	local listWrap = New("ScrollingFrame", {
	    BackgroundTransparency = 1,
	    Position = UDim2.new(0, 0, 0, 40),
	    Size = UDim2.new(1, 0, 0, 0),
	    CanvasSize = UDim2.new(0, 0, 0, 0),  
	    ScrollBarThickness = 4,               
	    ScrollBarImageTransparency = 0.5,     
	    ClipsDescendants = true,
	    Parent = holder,
	})
	MarkNoWindowDrag(listWrap)

	local pad = New("UIPadding", {
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
	}) :: Frame

	local ll = New("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 6),
		Parent = list,
	}) :: UIListLayout

	local openedLocal = false
	local itemButtons: { [string]: TextButton } = {}

	local function getSelectedList(): { string }
		local out: { string } = {}
		for _, opt in ipairs(options) do
			if selectedMap[opt] then
				table.insert(out, opt)
			end
		end
		return out
	end

	local function updateValueText()
		local count = 0
		for _, opt in ipairs(options) do
			if selectedMap[opt] then
				count += 1
			end
		end

		if count == 0 then
			valueBtn.Text = "None"
		elseif count == #options then
			valueBtn.Text = "All"
		else
			valueBtn.Text = tostring(count) .. " selected"
		end
	end

	local function paintItem(opt: string)
		local b = itemButtons[opt]
		if not b then
			return
		end

		local on = selectedMap[opt] == true
		local stroke = b:FindFirstChildOfClass("UIStroke") :: UIStroke?

		b.Text = (on and (" " .. opt) or ("   " .. opt))

		if on then
			PlayTween(b, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = Color3.fromRGB(45, 40, 60) })
			if stroke then
				PlayTween(stroke, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Color = Config.Accent, Transparency = 0.25 })
			end
		else
			PlayTween(b, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = Color3.fromRGB(35, 35, 45) })
			if stroke then
				PlayTween(stroke, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Color = Color3.fromRGB(55, 59, 62), Transparency = 0.4 })
			end
		end
	end

	local function fire()
		updateValueText()
		if callback then
			task.spawn(callback, getSelectedList())
		end
	end

	local function closeSelf()
		if not openedLocal then
			return
		end
		openedLocal = false
		arrow.Text = "▼"

		listWrap.CanvasPosition = Vector2.new(0, 0)
		
		local t = Config.Anim.DropdownSpeed
		PlayTween(listWrap, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 0, 0) })
		PlayTween(holder, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 0, 40) })

		if activeDropdownClose == closeSelf then
			activeDropdownClose = nil
		end
	end

	local function openSelf()
	    if openedLocal then
	        return
	    end
	    openedLocal = true
	
	    if activeDropdownClose and activeDropdownClose ~= closeSelf then
	        activeDropdownClose()
	    end
	    activeDropdownClose = closeSelf
	
	    arrow.Text = "▲"
	
	    task.defer(function()
	        local contentHeight = ll.AbsoluteContentSize.Y + pad.PaddingTop.Offset + pad.PaddingBottom.Offset
	        local maxHeight = 180 
	        local wanted = math.min(contentHeight, maxHeight) 

	        listWrap.CanvasSize = UDim2.new(0, 0, 0, ll.AbsoluteContentSize.Y)
	
	        local t = Config.Anim.DropdownSpeed
	        PlayTween(listWrap, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 0, wanted) })
	        PlayTween(holder, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 0, 40 + wanted) })
	    end)
	end
	local function toggleOpen()
		if openedLocal then
			closeSelf()
		else
			openSelf()
		end
	end

	-- helper row: Select All / Clear
	do
		local row = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 28), Parent = list }) :: Frame
		MarkNoWindowDrag(row)

		New("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 6),
			Parent = row,
		})

		local function smallBtn(caption: string, onClick: () -> ())
			local b = New("TextButton", {
				AutoButtonColor = false,
				BackgroundColor3 = Color3.fromRGB(35, 35, 45),
				BorderSizePixel = 0,
				Size = UDim2.new(0.5, -3, 0, 28),
				Font = Enum.Font.GothamMedium,
				TextSize = Config.SmallSize,
				TextColor3 = Color3.fromRGB(240, 240, 245),
				Text = caption,
				Parent = row,
			}, {
				New("UICorner", { CornerRadius = UDim.new(0, 8) }),
				New("UIStroke", { Color = Color3.fromRGB(55, 59, 62), Thickness = 1, Transparency = 0.4 }),
			}) :: TextButton
			MarkNoWindowDrag(b)
			b.MouseButton1Click:Connect(onClick)
		end

		smallBtn("Select all", function()
			for _, opt in ipairs(options) do
				selectedMap[opt] = true
				paintItem(opt)
			end
			fire()
		end)

		smallBtn("Clear", function()
			for _, opt in ipairs(options) do
				selectedMap[opt] = nil
				paintItem(opt)
			end
			fire()
		end)
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
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = opt,
			LayoutOrder = 100 + i,
			Parent = list,
		}, {
			New("UICorner", { CornerRadius = UDim.new(0, 8) }),
			New("UIStroke", { Color = Color3.fromRGB(55, 59, 62), Thickness = 1, Transparency = 0.4 }),
			New("UIPadding", { PaddingLeft = UDim.new(0, 10) }),
		}) :: TextButton
		MarkNoWindowDrag(b)

		itemButtons[opt] = b

		b.MouseButton1Click:Connect(function()
			selectedMap[opt] = not (selectedMap[opt] == true)
			paintItem(opt)
			fire()
		end)
	end

	updateValueText()
	for _, opt in ipairs(options) do
		paintItem(opt)
	end

	valueBtn.MouseButton1Click:Connect(toggleOpen)
	holder.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			toggleOpen()
		end
	end)

	return {
		Get = function(): { string }
			return getSelectedList()
		end,
		Set = function(listVals: { string })
			for _, opt in ipairs(options) do
				selectedMap[opt] = nil
			end
			for _, v in ipairs(listVals) do
				if table.find(options, v) then
					selectedMap[v] = true
				end
			end
			for _, opt in ipairs(options) do
				paintItem(opt)
			end
			fire()
		end,
		Has = function(v: string): boolean
			return selectedMap[v] == true
		end,
		Open = openSelf,
		Close = closeSelf,
	}
end

--====================================================
-- Label (RichText + SetColor + SetParts + Edit + Destroy + Bind)
--====================================================
local function addLabel(
	page: ScrollingFrame,
	text: string,
	color: Color3?,
	icon: string?,
	richText: boolean?
)
	local parent = pageCanvas(page)

	local holder = New("Frame", {
		BackgroundColor3 = Color3.fromRGB(28, 28, 34),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ClipsDescendants = true,
		Parent = parent,
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 0) }),
		New("UIStroke", { Color = Color3.fromRGB(55, 59, 62), Thickness = 1 }),
		New("UIPadding", {
			PaddingLeft = UDim.new(0, Config.Padding),
			PaddingRight = UDim.new(0, Config.Padding),
			PaddingTop = UDim.new(0, 10),
			PaddingBottom = UDim.new(0, 10),
		}),
	}) :: Frame
	MarkNoWindowDrag(holder)

	local displayText = icon and (icon .. " " .. text) or text

	local lbl = New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Font = Enum.Font.Gotham,
		TextSize = Config.BodySize,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		TextColor3 = color or Color3.fromRGB(240, 240, 245),
		TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
		TextStrokeTransparency = 0.75,
		RichText = (richText == true),
		Text = displayText,
		Parent = holder,
	}) :: TextLabel
	MarkNoWindowDrag(lbl)

	-- bind loop
	local bindAlive = false
	local bindThread: thread? = nil

	local function stopBind()
		bindAlive = false
		bindThread = nil
	end

	-- RichText helpers
	local function escapeRich(s: string): string
		s = string.gsub(s, "&", "&amp;")
		s = string.gsub(s, "<", "&lt;")
		s = string.gsub(s, ">", "&gt;")
		s = string.gsub(s, "\"", "&quot;")
		return s
	end

	local function rgbString(c: Color3): string
		local r = math.clamp(math.floor(c.R * 255 + 0.5), 0, 255)
		local g = math.clamp(math.floor(c.G * 255 + 0.5), 0, 255)
		local b = math.clamp(math.floor(c.B * 255 + 0.5), 0, 255)
		return ("rgb(%d,%d,%d)"):format(r, g, b)
	end

	local function setPlainText(t: string)
		lbl.RichText = false
		lbl.Text = t
	end

	local function setPlainColor(c: Color3)
		lbl.TextColor3 = c
	end

	-- parts: { {Text="HP: ", Color=...}, {Text="100", Color=...}, {Text=" / 200"} }
	local function setParts(parts: { [number]: { Text: string, Color: Color3? } })
		lbl.RichText = true
		local out = table.create(#parts)
		for i, part in ipairs(parts) do
			local t = escapeRich(part.Text or "")
			if part.Color then
				out[i] = ('<font color="%s">%s</font>'):format(rgbString(part.Color), t)
			else
				out[i] = t
			end
		end
		lbl.Text = table.concat(out, "")
	end

	local function setRichText(rt: string)
		lbl.RichText = true
		lbl.Text = rt
	end

	local api = {}

	function api.GetText(): string
		return lbl.Text
	end

	function api.SetText(t: string)
		setPlainText(t)
	end

	function api.SetColor(c: Color3)
		lbl.RichText = false
		setPlainColor(c)
	end

	function api.SetRichText(rt: string)
		setRichText(rt)
	end

	function api.SetParts(parts: { [number]: { Text: string, Color: Color3? } })
		setParts(parts)
	end

	function api.Unbind()
		stopBind()
	end

	function api.BindText(getText: () -> string, interval: number?)
		stopBind()
		bindAlive = true
		local dt = interval or 0.2
		bindThread = task.spawn(function()
			while bindAlive and holder.Parent do
				local ok, res = pcall(getText)
				if ok and type(res) == "string" then
					setPlainText(res)
				end
				task.wait(dt)
			end
		end)
	end

	function api.BindRichText(getRich: () -> string, interval: number?)
		stopBind()
		bindAlive = true
		local dt = interval or 0.2
		bindThread = task.spawn(function()
			while bindAlive and holder.Parent do
				local ok, res = pcall(getRich)
				if ok and type(res) == "string" then
					setRichText(res)
				end
				task.wait(dt)
			end
		end)
	end

	function api.BindParts(getParts: () -> { [number]: { Text: string, Color: Color3? } }, interval: number?)
		stopBind()
		bindAlive = true
		local dt = interval or 0.2
		bindThread = task.spawn(function()
			while bindAlive and holder.Parent do
				local ok, res = pcall(getParts)
				if ok and type(res) == "table" then
					setParts(res :: any)
				end
				task.wait(dt)
			end
		end)
	end

	function api.Destroy()
		stopBind()
		holder:Destroy()
	end

	return api
end

--====================================================
-- SETTINGS PAGE
--====================================================
local SettingsTabRef: { Button: TextButton, Page: ScrollingFrame, Canvas: CanvasGroup, Select: () -> () }? = nil

local function createSettingsPage()
	local settingsTab = createTab("Settings", Icons.Settings)
	local settingsPage = settingsTab.Page

	addHeader(settingsPage, "Appearance")
	addToggle(settingsPage, "Blur Effect", Config.BlurSize > 0, function(v)
		Config.BlurSize = v and 22 or 0
		if blur then
			blur.Size = Config.BlurSize
		end
		saveConfig()
	end)

	addSlider(settingsPage, "Blur Size", 0, 30, Config.BlurSize, function(v)
		Config.BlurSize = v
		if blur then
			blur.Size = v
		end
		saveConfig()
	end)

	addToggle(settingsPage, "Overlay", Config.OverlayAlpha > 0, function(v)
		Config.OverlayAlpha = v and 0.25 or 0
		saveConfig()
	end)

	addSlider(settingsPage, "Overlay Alpha", 0, 1, Config.OverlayAlpha, function(v)
		Config.OverlayAlpha = v
		saveConfig()
	end)

	addHeader(settingsPage, "Animation")
	addToggle(settingsPage, "Enable Animations", Config.Anim.Enabled, function(v)
		Config.Anim.Enabled = v
		saveConfig()
	end)

	addHeader(settingsPage, "Hotkeys")
	addKeybind(settingsPage, "Toggle UI key", Config.ToggleKey, function(key)
		Config.ToggleKey = key
		saveConfig()
	end)

	addHeader(settingsPage, "Рождество")
	addToggle(settingsPage, "Enable Snow", Config.Snow.Enabled, function(v)
		Config.Snow.Enabled = v
		if v then
			startSnow()
		else
			stopSnow()
		end
		saveConfig()
	end)

	settingsTab.Button.Visible = false
	settingsTab.Button.Active = false

	return settingsTab
end

SettingsTabRef = createSettingsPage()

settingsBtn.MouseButton1Click:Connect(function()
	if SettingsTabRef then
		SettingsTabRef.Select()
	end
end)

--====================================================
-- OPEN/CLOSE
--====================================================
function setOpen(show: boolean)
	opened = show
	CancelAll(openTweens)

	assert(overlay and window and winStroke and accentLine and modalBlocker and blur and settingsPopover, "core UI missing")

	setMouseUnblock(show)
	modalBlocker.Visible = show

	if show then
		overlay.Visible = true
		window.Visible = true
		modalBlocker.Active = false
		modalBlocker.Modal = false
		if Config.Snow.Enabled then
			startSnow()
		else
			stopSnow()
		end
	else
		modalBlocker.Active = true
		modalBlocker.Modal = true
		stopSnow()
		if activeDropdownClose then
			activeDropdownClose()
		end
	end

	local openInfo = getOpenTweenInfo()

	openTweens[1] = PlayTween(overlay, openInfo, {
		Size = show and UDim2.fromScale(1, 1) or UDim2.fromScale(0, 0),
		BackgroundTransparency = show and Config.OverlayAlpha or 1,
	})

	openTweens[2] = PlayTween(blur, openInfo, { Size = show and Config.BlurSize or 0 })

	openTweens[3] = PlayTween(window, openInfo, {
		Size = show and Config.WindowSize or UDim2.fromOffset(0, 0),
		BackgroundTransparency = show and 0 or 1,
	})

	openTweens[4] = PlayTween(winStroke, openInfo, { Transparency = show and 0 or 1 })
	openTweens[5] = PlayTween(accentLine, openInfo, { BackgroundTransparency = show and 0 or 1 })

	local tWin = openTweens[3]
	local conn: RBXScriptConnection? = nil
	conn = tWin.Completed:Connect(function()
		Disconnect(conn)
		if not opened then
			overlay.Visible = false
			window.Visible = false
			settingsPopover.Visible = false
		end
	end)
	table.insert(allConnections, conn :: any)
end

closeBtn.MouseButton1Click:Connect(function()
	setOpen(false)
end)

local toggleConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end
	if keybindListening then
		return
	end
	if input.KeyCode == Config.ToggleKey then
		setOpen(not opened)
	end
end)
table.insert(allConnections, toggleConn)

--====================================================
-- DRAG WINDOW (Topbar + Anywhere)
--====================================================
do
	assert(window and topbar and gui, "window/topbar/gui missing")

	local dragging = false
	local dragStart2D = Vector2.zero
	local startPos = window.Position
	local stop: (() -> ())? = nil

	local function beginWindowDrag(start2D: Vector2)
		if dragging then
			return
		end
		if UserInputService:GetFocusedTextBox() then
			return
		end

		dragging = true
		dragStart2D = start2D
		startPos = window.Position

		if stop then
			stop()
		end
		stop = StartDrag(function(pos: Vector2)
			if not dragging then
				return
			end
			local p2d = pos - GetInset()
			local delta = p2d - dragStart2D

			window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			ClampWindowPosition(window, gui.AbsoluteSize.X, gui.AbsoluteSize.Y)
		end, function()
			dragging = false
			stop = nil
		end)
	end

	local topbarConn = topbar.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		local p = input.Position
		beginWindowDrag(Vector2.new(p.X, p.Y) - GetInset())
	end)
	table.insert(allConnections, topbarConn :: any)

	local globalConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end
		if not opened then
			return
		end
		if keybindListening then
			return
		end

		-- auto close dropdown if clicked anywhere
		if activeDropdownClose and input.UserInputType == Enum.UserInputType.MouseButton1 then
			activeDropdownClose()
		end

		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		local p = input.Position
		local pos2D = Vector2.new(p.X, p.Y) - GetInset()

		local guis = playerGui:GetGuiObjectsAtPosition(pos2D.X, pos2D.Y)
		for _, g in ipairs(guis) do
			if g:IsDescendantOf(gui) then
				if not g:IsDescendantOf(window) then
					return
				end
				if g:IsA("GuiButton") or g:IsA("TextBox") or g:IsA("ScrollingFrame") then
					return
				end
				if IsNoWindowDrag(g) then
					return
				end

				beginWindowDrag(pos2D)
				return
			end
		end
	end)
	table.insert(allConnections, globalConn :: any)
end

--====================================================
-- UI.RESTART
--====================================================
local function Restart()
	Exit()
end

--====================================================
-- PUBLIC API
--====================================================
local UI = {
	CreateTab = createTab,

	AddHeader = addHeader,
	AddButton = addButton,
	AddToggle = addToggle,
	AddSlider = addSlider,
	AddKeybind = addKeybind,

	AddDropdown = addDropdown,
	AddMultiDropdown = addMultiDropdown,
	AddLabel = addLabel,

	Icons = Icons,
	Config = Config,

	Exit = Exit,
	Restart = Restart,

	Open = function()
		setOpen(true)
	end,
	Close = function()
		setOpen(false)
	end,
	Toggle = function()
		setOpen(not opened)
	end,

	SaveConfig = saveConfig,
	LoadConfig = loadConfig,

	Log = PushLog,
}

getgenv().UI = UI
getgenv().PushLog = PushLog
task.defer(function()
	UI.Open()
end)

return UI
















