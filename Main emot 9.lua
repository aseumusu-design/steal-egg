--[[
    Script: Floating Image UI Toggle No Cooldown (Custom Position)
    Platform: Delta Executor Mobile
]]

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

-- Hapus UI lama jika ada biar nggak numpuk
if CoreGui:FindFirstChild("KillerBypassUI") then
    CoreGui.KillerBypassUI:Destroy()
end

-- Membuat ScreenGui Utama
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KillerBypassUI"
screenGui.Parent = CoreGui
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Membuat Floating ImageButton dengan posisi sesuai koordinat kamu
local toggleButton = Instance.new("ImageButton")
toggleButton.Name = "ToggleButton"
toggleButton.Parent = screenGui
toggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggleButton.BorderColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.BorderSizePixel = 2
-- Posisi disesuaikan persis ke koordinat yang kamu berikan
toggleButton.Position = UDim2.new(0.789273262, 0, 0.78927356, 0)
toggleButton.Size = UDim2.new(0, 55, 0, 55)
toggleButton.Image = "rbxassetid://108114231850675" -- Asset ID gambar kamu
toggleButton.Active = true
toggleButton.Draggable = true -- Masih bisa digeser kalau mau disesuaikan lagi

-- Membuat sudut tombol jadi melengkung (UI Corner)
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 12)
uiCorner.Parent = toggleButton

-- Indikator Status Kecil di dalam Tombol (Merah = Mati, Hijau = Hidup)
local statusIndicator = Instance.new("Frame")
statusIndicator.Name = "StatusIndicator"
statusIndicator.Parent = toggleButton
statusIndicator.AnchorPoint = Vector2.new(1, 1)
statusIndicator.Position = UDim2.new(1, -4, 1, -4)
statusIndicator.Size = UDim2.new(0, 14, 0, 14)
statusIndicator.BackgroundColor3 = Color3.fromRGB(255, 60, 60) -- Merah (OFF)

local indicatorCorner = Instance.new("UICorner")
indicatorCorner.CornerRadius = UDim.new(1, 0)
indicatorCorner.Parent = statusIndicator

-- Status Aktif / Mati
getgenv().VD = getgenv().VD or {}
VD.KILLER_InfFrenzy = false
VD.KILLER_InfLakeMist = false
VD.KILLER_InfPursuit = false

local isEnabled = false

-- Fungsi Thread Jeff
local function startJeff()
    if getgenv().KYS_JeffCooldownBypassThread then return end
    getgenv().KYS_JeffCooldownBypassThread = task.spawn(function()
        while VD.KILLER_InfFrenzy do
            pcall(function()
                local char = player.Character
                if char and char:GetAttribute("Frenzy") ~= true then
                    char:SetAttribute("Frenzy", true)
                end
            end)
            task.wait()
        end
        getgenv().KYS_JeffCooldownBypassThread = nil
    end)
end

-- Fungsi Thread Slasher
local function startSlasher()
    if getgenv().KYS_SlasherCooldownBypassThread then return end
    
    -- Boolean Failsafe
    pcall(function()
        local b = true
        local mt = debug.getmetatable(b)
        if not mt then mt = {} debug.setmetatable(b, mt) end
        if setreadonly then setreadonly(mt, false) end
        mt.__div = function() return 0 end
        mt.__mul = function() return 0 end
        mt.__add = function() return 0 end
        mt.__sub = function() return 0 end
        if setreadonly then setreadonly(mt, true) end
    end)

    getgenv().KYS_SlasherCooldownBypassThread = task.spawn(function()
        local toggleFunc = nil
        local pursuitHandler = nil
        
        local function scanGC()
            pcall(function()
                for _, v in pairs(getgc(true)) do
                    if type(v) == "function" and islclosure(v) then
                        local consts = debug.getconstants(v)
                        local hasOffset, hasLinear, hasAction, hasTweenInfo = false, false, false, false
                        local hasPursuit, hasWalkSpeed = false, false
                        for _, c in pairs(consts) do
                            if c == "Offset" then hasOffset = true end
                            if c == "Linear" then hasLinear = true end
                            if c == "action" then hasAction = true end
                            if c == "TweenInfo" then hasTweenInfo = true end
                            if c == "Pursuit" then hasPursuit = true end
                            if c == "WalkSpeed" then hasWalkSpeed = true end
                        end
                        if hasOffset and hasLinear and hasAction and hasTweenInfo and not hasPursuit then
                            toggleFunc = v
                        end
                        if hasPursuit and hasTweenInfo and hasAction and hasWalkSpeed then
                            pursuitHandler = v
                        end
                    end
                    if toggleFunc and pursuitHandler then break end
                end
            end)
        end
        
        scanGC()
        local lastScan = os.clock()

        while VD.KILLER_InfLakeMist or VD.KILLER_InfPursuit do
            if not (toggleFunc and pursuitHandler) then
                if os.clock() - lastScan >= 2 then
                    scanGC()
                    lastScan = os.clock()
                end
            end
            if toggleFunc and VD.KILLER_InfLakeMist then
                pcall(function()
                    debug.setupvalue(toggleFunc, 6, false)
                    debug.setupvalue(toggleFunc, 10, false)
                end)
            end
            if pursuitHandler and VD.KILLER_InfPursuit then
                pcall(function()
                    debug.setupvalue(pursuitHandler, 5, false)
                    debug.setupvalue(pursuitHandler, 6, false)
                end)
            end
            task.wait(0.1)
        end
        getgenv().KYS_SlasherCooldownBypassThread = nil
    end)
end

-- Event Klik Tombol
toggleButton.MouseButton1Click:Connect(function()
    isEnabled = not isEnabled
    
    if isEnabled then
        -- Menyalakan Bypass
        VD.KILLER_InfFrenzy = true
        VD.KILLER_InfLakeMist = true
        VD.KILLER_InfPursuit = true
        
        startJeff()
        startSlasher()
        
        statusIndicator.BackgroundColor3 = Color3.fromRGB(60, 255, 60) -- Hijau (ON)
    else
        -- Mematikan Bypass
        VD.KILLER_InfFrenzy = false
        VD.KILLER_InfLakeMist = false
        VD.KILLER_InfPursuit = false
        
        statusIndicator.BackgroundColor3 = Color3.fromRGB(255, 60, 60) -- Merah (OFF)
    end
end)

print("[SUCCESS] Floating UI dengan Posisi Kustom Berhasil Dimuat!")
