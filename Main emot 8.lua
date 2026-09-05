--// ============================================
--//  VD INVISIBLE V4 — FIX SEMUA BUG
//   - Fix infinite respawn loop
//   - Fix jatuh ke void (mati terus)
//   - Fix nggak bisa gerak & nembak
//   - Toggle: INSERT
// ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local localPlayer = Players.LocalPlayer

local isInvisible = false
local fakeCharacter = nil
local realCharacter = nil
local syncConnection = nil
local charAddedConn = nil
local isToggling = false -- ANTI LOOP FLAG

--// GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VD_InvisV4_Fixed"
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
title.Text = "👻 VD Invis V4 (Fixed)"
title.TextColor3 = Color3.fromRGB(255, 80, 80)
title.Font = Enum.Font.GothamBold
textSize = 15
title.Parent = mainFrame

Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 22)
statusLabel.Position = UDim2.new(0.05, 0, 0.24, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: VISIBLE"
statusLabel.TextColor3 = Color3.fromRGB(0, 255, 80)
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 16
statusLabel.Parent = mainFrame

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(0.9, 0, 0, 18)
infoLabel.Position = UDim2.new(0.05, 0, 0.40, 0)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "Anti-Loop + Anti-Void + Full Control"
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
warnLabel.Text = "⚠️ JANGAN LARI KENCANG!\n⚠️ Kalau mati, matiin dulu sebelum respawn"
warnLabel.TextColor3 = Color3.fromRGB(255, 180, 0)
warnLabel.Font = Enum.Font.Gotham
warnLabel.TextSize = 10
warnLabel.TextWrapped = true
warnLabel.Parent = mainFrame

--// ============================================
--//  HELPER: HIDE / SHOW CHARACTER
--// ============================================

local function hideCharacter(char)
    for _, v in pairs(char:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Decal") or v:IsA("Texture") then
            v.Transparency = 1
            if v:IsA("BasePart") then v.CastShadow = false end
        elseif v:IsA("Accessory") then
            local h = v:FindFirstChild("Handle")
            if h then h.Transparency = 1; h.CastShadow = false end
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
            if h then h.Transparency = 0; h.CastShadow = true end
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
    if isToggling then return false end
    isToggling = true
    
    realCharacter = localPlayer.Character
    if not realCharacter then isToggling = false return false end
    
    local humanoid = realCharacter:FindFirstChildOfClass("Humanoid")
    local rootPart = realCharacter:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then isToggling = false return false end
    
    local savedCFrame = rootPart.CFrame
    
    --// 1. CLONE KARAKTER
    realCharacter.Archivable = true
    fakeCharacter = realCharacter:Clone()
    fakeCharacter.Name = "Fake_VD"
    fakeCharacter.Parent = Workspace
    
    --// 2. SETUP FAKE CHARACTER (ini yang bakal dikontrol)
    local fakeRoot = fakeCharacter:WaitForChild("HumanoidRootPart", 3)
    local fakeHum = fakeCharacter:FindFirstChildOfClass("Humanoid")
    if not fakeRoot or not fakeHum then
        fakeCharacter:Destroy()
        isToggling = false
        return false
    end
    
    fakeRoot.CFrame = savedCFrame
    fakeRoot.Velocity = Vector3.new(0, 0, 0)
    
    -- Fake: transparan 0.3 (kamu masih lihat diri sendiri sedikit)
    -- Kalau mau FULL invisible diri sendiri juga, ganti jadi 1
    for _, v in pairs(fakeCharacter:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Decal") then
            v.Transparency = 0.3 -- Kamu lihat diri sendiri transparan
        end
    end
    
    --// 3. PINDAHIN TOOLS KE FAKE (biar bisa nembak!)
    for _, tool in pairs(realCharacter:GetChildren()) do
        if tool:IsA("Tool") then
            tool.Parent = fakeCharacter
        end
    end
    local backpack = localPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                tool.Parent = fakeCharacter
            end
        end
    end
    
    --// 4. HIDE REAL CHARACTER
    hideCharacter(realCharacter)
    
    --// 5. PINDAHIN REAL KE POSISI AMAN (bukan void!)
    -- Pindah ke bawah tapi MASIH DI DALAM MAP (Y-20)
    -- Jangan ke Y-500 karena bakal jatuh mati!
    local safePos = savedCFrame.Position - Vector3.new(0, 20, 0)
    rootPart.CFrame = CFrame.new(safePos)
    rootPart.Velocity = Vector3.new(0, 0, 0)
    rootPart.Anchored = true -- ANCHOR biar nggak jatuh!
    
    --// 6. SWAP CHARACTER KE FAKE! (KUNCI BISA GERAK)
    localPlayer.Character = fakeCharacter
    Workspace.CurrentCamera.CameraSubject = fakeHum
    
    --// 7. SYNC LOOP: Real ngikutin Fake
    syncConnection = RunService.Heartbeat:Connect(function()
        if not isInvisible then return end
        if not fakeCharacter or not fakeCharacter.Parent then return end
        if not realCharacter or not realCharacter.Parent then return end
        
        local fRoot = fakeCharacter:FindFirstChild("HumanoidRootPart")
        local rRoot = realCharacter:FindFirstChild("HumanoidRootPart")
        local fHum = fakeCharacter:FindFirstChildOfClass("Humanoid")
        local rHum = realCharacter:FindFirstChildOfClass("Humanoid")
        
        if fRoot and rRoot then
            -- Real tetap di bawah fake, tapi anchored biar nggak jatuh
            rRoot.Anchored = true
            rRoot.CFrame = fRoot.CFrame - Vector3.new(0, 20, 0)
            rRoot.Velocity = Vector3.new(0, 0, 0)
        end
        
        -- Sync health & states
        if fHum and rHum then
            rHum.Health = fHum.Health
            rHum.MaxHealth = fHum.MaxHealth
            rHum.WalkSpeed = fHum.WalkSpeed
            rHum.JumpPower = fHum.JumpPower
        end
        
        -- Maintain hide
        for _, v in pairs(realCharacter:GetDescendants()) do
            if v:IsA("BasePart") and v.Transparency ~= 1 then
                v.Transparency = 1
            end
        end
    end)
    
    isToggling = false
    return true
end

--// ============================================
--//  CORE: DISABLE INVISIBILITY
--// ============================================

local function disableInvisibility()
    if isToggling then return end
    isToggling = true
    
    if syncConnection then
        syncConnection:Disconnect()
        syncConnection = nil
    end
    
    if fakeCharacter and realCharacter then
        local fakeRoot = fakeCharacter:FindFirstChild("HumanoidRootPart")
        local realRoot = realCharacter:FindFirstChild("HumanoidRootPart")
        
        -- Unanchor real dulu
        if realRoot then
            realRoot.Anchored = false
        end
        
        -- Pindahin tools balik
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
        
        -- Restore visual
        showCharacter(realCharacter)
    end
    
    if fakeCharacter then
        pcall(function() fakeCharacter:Destroy() end)
        fakeCharacter = nil
    end
    
    isInvisible = false
    isToggling = false
    
    statusLabel.Text = "Status: VISIBLE"
    statusLabel.TextColor3 = Color3.fromRGB(0, 255, 80)
    toggleBtn.Text = "Toggle Invisible [INSERT]"
    toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
end

--// ============================================
--//  TOGGLE (dengan ANTI-LOOP)
--// ============================================

local function toggleInvisibility()
    if isToggling then return end -- ANTI LOOP!
    
    if isInvisible then
        disableInvisibility()
    else
        local success = enableInvisibility()
        if success then
            isInvisible = true
            statusLabel.Text = "Status: INVISIBLE 👻"
            statusLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
            toggleBtn.Text = "MATIKAN INVISIBLE"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
            print("✅ VD Invis V4: AKTIF — Bisa gerak & nembak!")
        else
            statusLabel.Text = "Status: GAGAL"
            statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        end
    end
end

--// ============================================
--//  EVENTS (dengan ANTI-LOOP)
--// ============================================

toggleBtn.MouseButton1Click:Connect(toggleInvisibility)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.Insert and not gameProcessed then
        toggleInvisibility()
    end
end)

--// RESPawn handler — MATIIN DULU sebelum respawn!
charAddedConn = localPlayer.CharacterAdded:Connect(function(newChar)
    -- Kalau lagi invisible dan character baru spawn = matiin dulu
    if isInvisible and not isToggling then
        isInvisible = false -- Force mati
        if syncConnection then
            syncConnection:Disconnect()
            syncConnection = nil
        end
        if fakeCharacter then
            pcall(function() fakeCharacter:Destroy() end)
            fakeCharacter = nil
        end
        -- Tunggu load, terus aktifkan ulang kalau mau
        task.wait(1.5)
        -- JANGAN auto-toggle lagi! Biar user manual toggle
        statusLabel.Text = "Status: VISIBLE (Respawned)"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 80)
        toggleBtn.Text = "Toggle Invisible [INSERT]"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
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

print("👻 VD Invisible V4 (Fixed) loaded!")
print("Tekan INSERT untuk toggle")
print("✅ Fix: Anti-Loop + Anti-Void + Bisa Gerak & Nembak!")
