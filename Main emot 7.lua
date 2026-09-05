--// ============================================
--//  VD INVISIBLE V3 — FIXED GERAK & NEMBAK
//   Metode: Underground Clone + Character Swap
//   Real = di bawah (invisible) | Fake = dikontrol
//   Toggle: INSERT
// ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local localPlayer = Players.LocalPlayer

local isInvisible = false
local fakeCharacter = nil
local realCharacter = nil
local renderConnection = nil
local charAddedConnection = nil
local savedTools = {}

--// GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VD_InvisV3_Fixed"
screenGui.ResetOnSpawn = false
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 160)
mainFrame.Position = UDim2.new(0, 15, 0.5, -80)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 32)
title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
title.Text = "👻 VD Invis V3 (Fixed)"
title.TextColor3 = Color3.fromRGB(255, 80, 80)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.Parent = mainFrame

Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 22)
statusLabel.Position = UDim2.new(0.05, 0, 0.24, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: VISIBLE"
statusLabel.TextColor3 = Color3.fromRGB(0, 255, 80)
statusLabel.Font = Enum.Font.GothamBold
statusSize = 16
statusLabel.Parent = mainFrame

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(0.9, 0, 0, 18)
infoLabel.Position = UDim2.new(0.05, 0, 0.40, 0)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "Bisa gerak & nembak!"
infoLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 11
infoLabel.Parent = mainFrame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.9, 0, 0, 35)
toggleBtn.Position = UDim2.new(0.05, 0, 0.56, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
toggleBtn.Text = "Toggle Invisible [INSERT]"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 13
toggleBtn.Parent = mainFrame

Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

local warnLabel = Instance.new("TextLabel")
warnLabel.Size = UDim2.new(0.9, 0, 0, 35)
warnLabel.Position = UDim2.new(0.05, 0, 0.76, 0)
warnLabel.BackgroundTransparency = 1
warnLabel.Text = "⚠️ JANGAN LARI KENCANG!\n⚠️ Fake = Kontrol | Real = Hitbox (bawah)"
warnLabel.TextColor3 = Color3.fromRGB(255, 180, 0)
warnLabel.Font = Enum.Font.Gotham
warnLabel.TextSize = 10
warnLabel.TextWrapped = true
warnLabel.Parent = mainFrame

--// ============================================
--//  HELPER FUNCTIONS
--// ============================================

local function hideCharacter(char)
    for _, v in pairs(char:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Decal") or v:IsA("Texture") then
            v.Transparency = 1
            if v:IsA("BasePart") then
                v.CastShadow = false
            end
        elseif v:IsA("Accessory") then
            local h = v:FindFirstChild("Handle")
            if h then 
                h.Transparency = 1
                h.CastShadow = false
            end
        elseif v:IsA("BillboardGui") or v:IsA("SurfaceGui") then
            v.Enabled = false
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Enabled = false
        elseif v:IsA("Sound") then
            v.Volume = 0
        end
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        hum.NameDisplayDistance = 0
        hum.HealthDisplayDistance = 0
    end
end

local function showCharacter(char)
    for _, v in pairs(char:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Transparency = 0
            v.CastShadow = true
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v.Transparency = 0
        elseif v:IsA("Accessory") then
            local h = v:FindFirstChild("Handle")
            if h then 
                h.Transparency = 0
                h.CastShadow = true
            end
        elseif v:IsA("BillboardGui") or v:IsA("SurfaceGui") then
            v.Enabled = true
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Enabled = true
        elseif v:IsA("Sound") then
            v.Volume = 0.5
        end
    end
end

--// ============================================
--//  CORE: ENABLE INVISIBILITY
--// ============================================

local function enableInvisibility()
    realCharacter = localPlayer.Character
    if not realCharacter then return false end
    
    local humanoid = realCharacter:FindFirstChildOfClass("Humanoid")
    local rootPart = realCharacter:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return false end
    
    local savedCFrame = rootPart.CFrame
    
    --// 1. CLONE KARAKTER
    realCharacter.Archivable = true
    fakeCharacter = realCharacter:Clone()
    fakeCharacter.Name = "FakeCharacter_VD"
    fakeCharacter.Parent = Workspace
    
    --// 2. MATIKAN LOCAL SCRIPT DI REAL (biar nggak konflik)
    for _, v in pairs(realCharacter:GetDescendants()) do
        if v:IsA("LocalScript") then
            pcall(function() v.Disabled = true end)
        end
    end
    
    --// 3. JANGAN DISABLE LOCAL SCRIPT DI FAKE! 
    -- Biar script game VD (nembak, animasi, dll) tetep jalan di fake!
    
    --// 4. PINDAHIN TOOLS KE FAKE CHARACTER
    local backpack = localPlayer:FindFirstChild("Backpack")
    for _, tool in pairs(realCharacter:GetChildren()) do
        if tool:IsA("Tool") then
            tool.Parent = fakeCharacter
        end
    end
    -- Pindahin juga dari backpack ke fake (kalau ada)
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                tool.Parent = fakeCharacter
            end
        end
    end
    
    --// 5. HIDE REAL CHARACTER & PINDAH KE BAWAH
    hideCharacter(realCharacter)
    rootPart.CFrame = CFrame.new(savedCFrame.Position - Vector3.new(0, 500, 0))
    rootPart.Velocity = Vector3.new(0, 0, 0)
    
    --// 6. SETUP FAKE CHARACTER
    local fakeRoot = fakeCharacter:WaitForChild("HumanoidRootPart", 2)
    local fakeHum = fakeCharacter:FindFirstChildOfClass("Humanoid")
    if not fakeRoot or not fakeHum then
        fakeCharacter:Destroy()
        return false
    end
    
    fakeRoot.CFrame = savedCFrame
    fakeRoot.Velocity = Vector3.new(0, 0, 0)
    
    -- Fake character tetap visible (kamu lihat diri sendiri normal)
    -- Kalau mau diri sendiri juga invisible, ganti jadi hideCharacter(fakeCharacter)
    
    --// 7. SWAP CHARACTER KE FAKE! (INI KUNCI BISA GERAK & NEMBAK)
    localPlayer.Character = fakeCharacter
    Workspace.CurrentCamera.CameraSubject = fakeHum
    
    --// 8. SYNC LOOP: Real ngikutin Fake
    renderConnection = RunService.Heartbeat:Connect(function()
        if not isInvisible then return end
        if not fakeCharacter or not fakeCharacter.Parent then return end
        if not realCharacter or not realCharacter.Parent then return end
        
        local fRoot = fakeCharacter:FindFirstChild("HumanoidRootPart")
        local rRoot = realCharacter:FindFirstChild("HumanoidRootPart")
        local fHum = fakeCharacter:FindFirstChildOfClass("Humanoid")
        local rHum = realCharacter:FindFirstChildOfClass("Humanoid")
        
        if fRoot and rRoot then
            -- Real character ngikutin fake tapi di bawah
            rRoot.CFrame = fRoot.CFrame + Vector3.new(0, -500, 0)
            rRoot.Velocity = fRoot.Velocity
            rRoot.RotVelocity = fRoot.RotVelocity
        end
        
        -- Sync health (kalau fake kena damage, real juga)
        if fHum and rHum then
            rHum.Health = fHum.Health
            rHum.MaxHealth = fHum.MaxHealth
        end
        
        -- Pastikan real tetap hidden
        for _, v in pairs(realCharacter:GetDescendants()) do
            if v:IsA("BasePart") and v.Transparency ~= 1 then
                v.Transparency = 1
            end
        end
        
        -- Pastikan fake tetap visible (kalau mau lihat diri sendiri)
        -- Kalau mau diri sendiri juga invisible, comment bagian ini:
        --[[
        for _, v in pairs(fakeCharacter:GetDescendants()) do
            if v:IsA("BasePart") and v.Transparency ~= 0 then
                v.Transparency = 0
            end
        end
        --]]
    end)
    
    return true
end

--// ============================================
--//  CORE: DISABLE INVISIBILITY
--// ============================================

local function disableInvisibility()
    if renderConnection then
        renderConnection:Disconnect()
        renderConnection = nil
    end
    
    if fakeCharacter and realCharacter then
        local fakeRoot = fakeCharacter:FindFirstChild("HumanoidRootPart")
        local realRoot = realCharacter:FindFirstChild("HumanoidRootPart")
        
        -- Pindahin tools balik ke real
        for _, tool in pairs(fakeCharacter:GetChildren()) do
            if tool:IsA("Tool") then
                tool.Parent = realCharacter
            end
        end
        
        -- Teleport real ke posisi fake
        if realRoot and fakeRoot then
            realRoot.CFrame = fakeRoot.CFrame
        end
        
        -- Swap balik ke real
        pcall(function()
            localPlayer.Character = realCharacter
            Workspace.CurrentCamera.CameraSubject = realCharacter:FindFirstChildOfClass("Humanoid")
        end)
        
        -- Restore visual real
        showCharacter(realCharacter)
        
        -- Enable LocalScript di real
        for _, v in pairs(realCharacter:GetDescendants()) do
            if v:IsA("LocalScript") then
                pcall(function() v.Disabled = false end)
            end
        end
    end
    
    if fakeCharacter then
        pcall(function() fakeCharacter:Destroy() end)
        fakeCharacter = nil
    end
    
    isInvisible = false
    statusLabel.Text = "Status: VISIBLE"
    statusLabel.TextColor3 = Color3.fromRGB(0, 255, 80)
    toggleBtn.Text = "Toggle Invisible [INSERT]"
    toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
end

--// ============================================
--//  TOGGLE
--// ============================================

local function toggleInvisibility()
    if isInvisible then
        disableInvisibility()
        return
    end
    
    local success = enableInvisibility()
    if success then
        isInvisible = true
        statusLabel.Text = "Status: INVISIBLE 👻"
        statusLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
        toggleBtn.Text = "MATIKAN INVISIBLE"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        print("✅ VD Invis V3: AKTIF — Bisa gerak & nembak!")
    else
        statusLabel.Text = "Status: GAGAL"
        statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    end
end

--// ============================================
--//  EVENTS
--// ============================================

toggleBtn.MouseButton1Click:Connect(toggleInvisibility)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.Insert and not gameProcessed then
        toggleInvisibility()
    end
end)

--// Handle respawn
charAddedConnection = localPlayer.CharacterAdded:Connect(function(newChar)
    if isInvisible then
        -- Matiin dulu, tunggu load, aktifkan ulang
        disableInvisibility()
        task.wait(1.5)
        toggleInvisibility()
    end
end)

--// Drag GUI
local dragging, dragStart, startPos = false, nil, nil

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

print("👻 VD Invisible V3 (Fixed) loaded!")
print("Tekan INSERT untuk toggle")
print("✅ Sekarang BISA GERAK & NEMBAK!")
