--[[
    A2 HUB — UI Library (Roblox)
    Logo bubble : rbxassetid://126710436488213
    Info banner : rbxassetid://117118608066997
    Discord     : https://discord.gg/pbg6g79Hp
--]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LP = Players.LocalPlayer

local A2 = {}
A2.__index = A2

local BRAND      = "A2"
local LOGO_ID    = "rbxassetid://126710436488213"
local BANNER_ID  = "rbxassetid://117118608066997"
local DISCORD    = "https://discord.gg/pbg6g79Hp"

local THEME = {
    Bg        = Color3.fromRGB(18, 18, 22),
    Panel     = Color3.fromRGB(26, 26, 32),
    Panel2    = Color3.fromRGB(34, 34, 42),
    Stroke    = Color3.fromRGB(52, 52, 64),
    Accent    = Color3.fromRGB(120, 130, 255),
    Text      = Color3.fromRGB(238, 238, 245),
    SubText   = Color3.fromRGB(150, 150, 165),
    Good      = Color3.fromRGB(90, 210, 140),
    Bad       = Color3.fromRGB(235, 95, 105),
}

-- helpers -------------------------------------------------------------
local function new(class, props, children)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do o[k] = v end
    for _, c in ipairs(children or {}) do c.Parent = o end
    return o
end

local function corner(r, parent)
    return new("UICorner", { CornerRadius = UDim.new(0, r or 8), Parent = parent })
end

local function stroke(parent, color, t)
    return new("UIStroke", {
        Color = color or THEME.Stroke,
        Thickness = t or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })
end

local function tween(obj, props, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local function copyToClipboard(text)
    local fn = (setclipboard or toclipboard or (Clipboard and Clipboard.set) or writeclipboard)
    if fn then pcall(fn, text) return true end
    return false
end

local function draggable(frame, handle)
    handle = handle or frame
    local dragging, startPos, startInput
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging, startInput, startPos = true, i.Position, frame.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - startInput
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

-- root ---------------------------------------------------------------
local ScreenGui = new("ScreenGui", {
    Name = BRAND .. "_Hub",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
})
pcall(function() ScreenGui.Parent = (gethui and gethui()) or CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LP:WaitForChild("PlayerGui") end

-- notifications ------------------------------------------------------
local NotifHolder = new("Frame", {
    Name = "Notifications",
    BackgroundTransparency = 1,
    AnchorPoint = Vector2.new(1, 1),
    Position = UDim2.new(1, -16, 1, -16),
    Size = UDim2.new(0, 280, 1, -32),
    Parent = ScreenGui,
}, {
    new("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Padding = UDim.new(0, 8),
    }),
})

function A2:Notify(title, text, duration)
    duration = duration or 4
    local card = new("Frame", {
        BackgroundColor3 = THEME.Panel,
        Size = UDim2.new(1, 0, 0, 64),
        BackgroundTransparency = 1,
        Parent = NotifHolder,
    })
    corner(10, card); stroke(card)
    new("ImageLabel", {
        BackgroundTransparency = 1,
        Image = LOGO_ID,
        Position = UDim2.new(0, 10, 0, 10),
        Size = UDim2.new(0, 26, 0, 26),
        Parent = card,
    })
    new("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = BRAND .. " • " .. tostring(title),
        TextColor3 = THEME.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.new(0, 44, 0, 10),
        Size = UDim2.new(1, -54, 0, 16),
        Parent = card,
    })
    new("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = tostring(text or ""),
        TextColor3 = THEME.SubText,
        TextSize = 12,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Position = UDim2.new(0, 44, 0, 28),
        Size = UDim2.new(1, -54, 0, 30),
        Parent = card,
    })
    card.Position = UDim2.new(1, 40, 0, 0)
    tween(card, { BackgroundTransparency = 0 }, 0.2)
    task.delay(duration, function()
        tween(card, { BackgroundTransparency = 1 }, 0.2)
        task.wait(0.25)
        card:Destroy()
    end)
end

-- main window --------------------------------------------------------
local Main = new("Frame", {
    Name = "Main",
    BackgroundColor3 = THEME.Bg,
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(0, 560, 0, 380),
    ClipsDescendants = true,
    Parent = ScreenGui,
})
corner(12, Main); stroke(Main)

local TopBar = new("Frame", {
    BackgroundColor3 = THEME.Panel,
    Size = UDim2.new(1, 0, 0, 44),
    Parent = Main,
})
corner(12, TopBar)
new("Frame", { BackgroundColor3 = THEME.Panel, BorderSizePixel = 0, Position = UDim2.new(0, 0, 1, -12), Size = UDim2.new(1, 0, 0, 12), Parent = TopBar })

new("ImageLabel", {
    BackgroundTransparency = 1,
    Image = LOGO_ID,
    Position = UDim2.new(0, 12, 0, 9),
    Size = UDim2.new(0, 26, 0, 26),
    Parent = TopBar,
})
new("TextLabel", {
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    Text = BRAND .. " HUB",
    TextColor3 = THEME.Text,
    TextSize = 15,
    TextXAlignment = Enum.TextXAlignment.Left,
    Position = UDim2.new(0, 46, 0, 8),
    Size = UDim2.new(0, 200, 0, 14),
    Parent = TopBar,
})
new("TextLabel", {
    BackgroundTransparency = 1,
    Font = Enum.Font.Gotham,
    Text = "by " .. BRAND,
    TextColor3 = THEME.SubText,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
    Position = UDim2.new(0, 46, 0, 24),
    Size = UDim2.new(0, 200, 0, 12),
    Parent = TopBar,
})

local function topButton(txt, xOff, cb)
    local b = new("TextButton", {
        BackgroundColor3 = THEME.Panel2,
        Text = txt,
        Font = Enum.Font.GothamBold,
        TextColor3 = THEME.Text,
        TextSize = 14,
        AutoButtonColor = false,
        Position = UDim2.new(1, xOff, 0, 11),
        Size = UDim2.new(0, 22, 0, 22),
        Parent = TopBar,
    })
    corner(6, b); stroke(b)
    b.MouseButton1Click:Connect(cb)
    return b
end

draggable(Main, TopBar)

-- tabs ---------------------------------------------------------------
local TabBar = new("Frame", {
    BackgroundColor3 = THEME.Panel,
    Position = UDim2.new(0, 10, 0, 52),
    Size = UDim2.new(0, 140, 1, -62),
    Parent = Main,
})
corner(10, TabBar); stroke(TabBar)
new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = TabBar })
new("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), Parent = TabBar })

local Pages = new("Frame", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 160, 0, 52),
    Size = UDim2.new(1, -170, 1, -62),
    Parent = Main,
})

local tabs, current = {}, nil

function A2:Tab(name)
    local btn = new("TextButton", {
        BackgroundColor3 = THEME.Panel2,
        BackgroundTransparency = 1,
        Text = name,
        Font = Enum.Font.GothamMedium,
        TextColor3 = THEME.SubText,
        TextSize = 13,
        AutoButtonColor = false,
        Size = UDim2.new(1, 0, 0, 30),
        Parent = TabBar,
    })
    corner(7, btn)

    local page = new("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Visible = false,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = THEME.Accent,
        Parent = Pages,
    })
    new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = page })
    new("UIPadding", { PaddingRight = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), Parent = page })

    local function select()
        for _, t in ipairs(tabs) do
            t.page.Visible = false
            tween(t.btn, { BackgroundTransparency = 1, TextColor3 = THEME.SubText })
        end
        page.Visible = true
        tween(btn, { BackgroundTransparency = 0, TextColor3 = THEME.Text })
        current = page
    end
    btn.MouseButton1Click:Connect(select)
    table.insert(tabs, { btn = btn, page = page, select = select })
    if #tabs == 1 then select() end

    -- component api ---------------------------------------------------
    local T = {}

    local function row(h)
        local f = new("Frame", {
            BackgroundColor3 = THEME.Panel,
            Size = UDim2.new(1, 0, 0, h),
            Parent = page,
        })
        corner(9, f); stroke(f)
        return f
    end

    function T:Section(text)
        local l = new("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            Text = string.upper(text),
            TextColor3 = THEME.SubText,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1, 0, 0, 18),
            Parent = page,
        })
        return l
    end

    function T:Button(text, callback)
        local f = row(36)
        local b = new("TextButton", {
            BackgroundTransparency = 1,
            Text = text,
            Font = Enum.Font.GothamMedium,
            TextColor3 = THEME.Text,
            TextSize = 13,
            Size = UDim2.new(1, 0, 1, 0),
            Parent = f,
        })
        b.MouseButton1Click:Connect(function()
            tween(f, { BackgroundColor3 = THEME.Panel2 }, 0.1)
            task.delay(0.12, function() tween(f, { BackgroundColor3 = THEME.Panel }, 0.1) end)
            if callback then task.spawn(callback) end
        end)
        return f
    end

    function T:Toggle(text, default, callback)
        local f = row(36)
        local state = default and true or false
        new("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamMedium,
            Text = text,
            TextColor3 = THEME.Text,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            Position = UDim2.new(0, 12, 0, 0),
            Size = UDim2.new(1, -60, 1, 0),
            Parent = f,
        })
        local track = new("Frame", {
            BackgroundColor3 = state and THEME.Accent or THEME.Panel2,
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -12, 0.5, 0),
            Size = UDim2.new(0, 36, 0, 18),
            Parent = f,
        })
        corner(9, track); stroke(track)
        local knob = new("Frame", {
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
            Size = UDim2.new(0, 14, 0, 14),
            Parent = track,
        })
        corner(7, knob)
        local hit = new("TextButton", { BackgroundTransparency = 1, Text = "", Size = UDim2.new(1, 0, 1, 0), Parent = f })
        hit.MouseButton1Click:Connect(function()
            state = not state
            tween(track, { BackgroundColor3 = state and THEME.Accent or THEME.Panel2 })
            tween(knob, { Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7) })
            if callback then task.spawn(callback, state) end
        end)
        return { Set = function(_, v) if v ~= state then hit.MouseButton1Click:Fire() end end }
    end

    function T:Slider(text, min, max, default, callback)
        local f = row(52)
        local value = math.clamp(default or min, min, max)
        local label = new("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamMedium,
            Text = text .. "  •  " .. tostring(value),
            TextColor3 = THEME.Text,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            Position = UDim2.new(0, 12, 0, 8),
            Size = UDim2.new(1, -24, 0, 14),
            Parent = f,
        })
        local bar = new("Frame", {
            BackgroundColor3 = THEME.Panel2,
            Position = UDim2.new(0, 12, 0, 32),
            Size = UDim2.new(1, -24, 0, 8),
            Parent = f,
        })
        corner(4, bar)
        local fill = new("Frame", {
            BackgroundColor3 = THEME.Accent,
            Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
            Parent = bar,
        })
        corner(4, fill)

        local dragging = false
        local function set(x)
            local a = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            value = math.floor(min + (max - min) * a + 0.5)
            fill.Size = UDim2.new(a, 0, 1, 0)
            label.Text = text .. "  •  " .. tostring(value)
            if callback then task.spawn(callback, value) end
        end
        bar.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = true; set(i.Position.X)
            end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                set(i.Position.X)
            end
        end)
        return f
    end

    function T:Dropdown(text, options, callback)
        local f = row(36)
        local open, selected = false, nil
        local btn = new("TextButton", {
            BackgroundTransparency = 1,
            Text = "",
            Size = UDim2.new(1, 0, 0, 36),
            Parent = f,
        })
        local title = new("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamMedium,
            Text = text .. ": -",
            TextColor3 = THEME.Text,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            Position = UDim2.new(0, 12, 0, 0),
            Size = UDim2.new(1, -24, 0, 36),
            Parent = f,
        })
        local list = new("Frame", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 8, 0, 36),
            Size = UDim2.new(1, -16, 0, 0),
            Parent = f,
        })
        new("UIListLayout", { Padding = UDim.new(0, 4), Parent = list })
        for _, opt in ipairs(options or {}) do
            local o = new("TextButton", {
                BackgroundColor3 = THEME.Panel2,
                Text = tostring(opt),
                Font = Enum.Font.Gotham,
                TextColor3 = THEME.SubText,
                TextSize = 12,
                AutoButtonColor = false,
                Size = UDim2.new(1, 0, 0, 26),
                Parent = list,
            })
            corner(6, o)
            o.MouseButton1Click:Connect(function()
                selected = opt
                title.Text = text .. ": " .. tostring(opt)
                if callback then task.spawn(callback, opt) end
            end)
        end
        btn.MouseButton1Click:Connect(function()
            open = not open
            local h = open and (#(options or {}) * 30 + 8) or 0
            list.Size = UDim2.new(1, -16, 0, h)
            tween(f, { Size = UDim2.new(1, 0, 0, 36 + h) })
        end)
        return { Get = function() return selected end }
    end

    function T:Input(placeholder, callback)
        local f = row(36)
        local box = new("TextBox", {
            BackgroundTransparency = 1,
            PlaceholderText = placeholder,
            PlaceholderColor3 = THEME.SubText,
            Text = "",
            ClearTextOnFocus = false,
            Font = Enum.Font.Gotham,
            TextColor3 = THEME.Text,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            Position = UDim2.new(0, 12, 0, 0),
            Size = UDim2.new(1, -24, 1, 0),
            Parent = f,
        })
        box.FocusLost:Connect(function(enter)
            if enter and callback then task.spawn(callback, box.Text) end
        end)
        return box
    end

    function T:Label(text)
        local f = row(32)
        local l = new("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = text,
            TextColor3 = THEME.SubText,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Position = UDim2.new(0, 12, 0, 0),
            Size = UDim2.new(1, -24, 1, 0),
            Parent = f,
        })
        return { Set = function(_, v) l.Text = v end }
    end

    -- INFO BANNER + DISCORD LINK -------------------------------------
    function T:InfoBanner(desc)
        local f = new("Frame", {
            BackgroundColor3 = THEME.Panel,
            Size = UDim2.new(1, 0, 0, 116),
            Parent = page,
        })
        corner(10, f); stroke(f, THEME.Accent)

        new("ImageLabel", {
            BackgroundTransparency = 1,
            Image = BANNER_ID,
            ScaleType = Enum.ScaleType.Crop,
            Position = UDim2.new(0, 8, 0, 8),
            Size = UDim2.new(1, -16, 0, 62),
            Parent = f,
        }, { new("UICorner", { CornerRadius = UDim.new(0, 8) }) })

        new("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = desc or (BRAND .. " Hub — info & update"),
            TextColor3 = THEME.SubText,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            Position = UDim2.new(0, 12, 0, 72),
            Size = UDim2.new(1, -24, 0, 12),
            Parent = f,
        })

        local dc = new("TextButton", {
            BackgroundColor3 = Color3.fromRGB(88, 101, 242),
            Text = "🔗  Join Discord  •  " .. DISCORD,
            Font = Enum.Font.GothamBold,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 12,
            AutoButtonColor = false,
            Position = UDim2.new(0, 12, 0, 86),
            Size = UDim2.new(1, -24, 0, 22),
            Parent = f,
        })
        corner(6, dc)
        dc.MouseButton1Click:Connect(function()
            local ok = copyToClipboard(DISCORD)
            A2:Notify("Discord", ok and "Link disalin ke clipboard!" or DISCORD, 4)
        end)
        return f
    end

    return T
end

-- minimize / bubble --------------------------------------------------
local Bubble = new("ImageButton", {
    Name = "Bubble",
    BackgroundColor3 = THEME.Panel,
    Image = LOGO_ID,
    Visible = false,
    Position = UDim2.new(0, 20, 0.5, -26),
    Size = UDim2.new(0, 52, 0, 52),
    Parent = ScreenGui,
})
corner(26, Bubble); stroke(Bubble, THEME.Accent, 2)
draggable(Bubble)

local function setOpen(open)
    Main.Visible = open
    Bubble.Visible = not open
end

topButton("—", -68, function() setOpen(false) end)
topButton("×", -40, function()
    A2:Notify("Bye", "UI ditutup.", 3)
    task.wait(0.2)
    ScreenGui:Destroy()
end)

Bubble.MouseButton1Click:Connect(function() setOpen(true) end)
UserInputService.InputBegan:Connect(function(i, gpe)
    if gpe then return end
    if i.KeyCode == Enum.KeyCode.RightShift then setOpen(not Main.Visible) end
end)

-- ==== DEMO / DEFAULT MENU ==========================================
local Home = A2:Tab("Home")
Home:InfoBanner("Selamat datang di " .. BRAND .. " Hub — semua fitur lengkap di sini.")
Home:Section("Info")
Home:Label("Player: " .. LP.Name)
Home:Label("Toggle UI: Right Shift")
Home:Button("Copy Discord Link", function()
    copyToClipboard(DISCORD)
    A2:Notify("Discord", "Link disalin!", 3)
end)

local Main_ = A2:Tab("Main")
Main_:Section("Farm")
Main_:Toggle("Auto Farm", false, function(v) A2:Notify("Auto Farm", v and "ON" or "OFF", 2) end)
Main_:Toggle("Auto Collect", false, function(v) A2:Notify("Auto Collect", v and "ON" or "OFF", 2) end)
Main_:Slider("Farm Speed", 1, 10, 3, function(v) end)
Main_:Dropdown("Target", { "Nearest", "Strongest", "Random" }, function(v) end)

local PlayerTab = A2:Tab("Player")
PlayerTab:Section("Character")
PlayerTab:Slider("WalkSpeed", 16, 300, 16, function(v)
    local c = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if c then c.WalkSpeed = v end
end)
PlayerTab:Slider("JumpPower", 50, 300, 50, function(v)
    local c = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if c then c.UseJumpPower = true; c.JumpPower = v end
end)
PlayerTab:Toggle("Infinite Jump", false, function(v)
    getgenv().A2_InfJump = v
end)
UserInputService.JumpRequest:Connect(function()
    if getgenv().A2_InfJump then
        local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)
PlayerTab:Button("Reset Character", function()
    if LP.Character then LP.Character:BreakJoints() end
end)

local Teleport = A2:Tab("Teleport")
Teleport:Section("Quick Teleport")
Teleport:Input("Player name...", function(name)
    local target = Players:FindFirstChild(name)
    if target and target.Character and LP.Character then
        LP.Character:PivotTo(target.Character:GetPivot())
        A2:Notify("Teleport", "Ke " .. name, 3)
    else
        A2:Notify("Teleport", "Player tidak ditemukan", 3)
    end
end)
Teleport:Button("Save Position", function()
    if LP.Character then getgenv().A2_Saved = LP.Character:GetPivot() end
    A2:Notify("Teleport", "Posisi disimpan", 2)
end)
Teleport:Button("Load Position", function()
    if getgenv().A2_Saved and LP.Character then LP.Character:PivotTo(getgenv().A2_Saved) end
end)

local Visual = A2:Tab("Visual")
Visual:Section("Rendering")
Visual:Toggle("Fullbright", false, function(v)
    game.Lighting.Brightness = v and 3 or 1
    game.Lighting.ClockTime = v and 14 or 14
    game.Lighting.GlobalShadows = not v
    game.Lighting.FogEnd = v and 1e6 or 100000
end)
Visual:Dropdown("Graphics", { "Low", "Medium", "High" }, function(v) end)

local Settings = A2:Tab("Settings")
Settings:Section("UI")
Settings:Toggle("Show Notifications", true, function(v) NotifHolder.Visible = v end)
Settings:Button("Minimize", function() setOpen(false) end)
Settings:Button("Destroy UI", function() ScreenGui:Destroy() end)
Settings:Section("Credit")
Settings:Label("Made by " .. BRAND)
Settings:InfoBanner("Butuh bantuan? Join Discord " .. BRAND)

A2:Notify("Loaded", BRAND .. " Hub berhasil dimuat!", 4)

return A2
