--// ============================================
--//  VD FE INVISIBLE — FAKE CHARACTER SWAP
--//  Adaptasi dari script user + optimasi VD
--//  Toggle: INSERT
--// ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

--// Config
local INVIS_OFFSET = -50          -- Semakin negatif = semakin jauh di bawah
local TOGGLE_KEY = Enum.KeyCode.Insert
local isInvisible = false
local fakeCharacter = nil
local realCharacter = nil
local updateConnection = nil
local savedTools = {}

--// GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VD_FakeCharInvis"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 150)
mainFrame.Position = UDim2.new(0, 15, 0.5, -75)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 32)
title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
title.Text = "👻 VD FakeChar Invis"
title.TextColor3 = Color3.fromRGB(255, 80, 80)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.Parent = mainFrame

Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 22)
statusLabel.Position = UDim2.new(0.05, 0, 0.28, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: VISIBLE"
statusLabel.TextColor3 = Color3.fromRGB(0, 255, 80)
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 16
statusLabel.Parent = mainFrame

local methodLabel = Instance.new("TextLabel")
methodLabel.Size = UDim2.new(0.9, 0, 0, 18)
methodLabel.Position = UDim2.new(0.05, 0, 0.45, 0)
methodLabel.BackgroundTransparency = 1
methodLabel.Text = "Method: Fake Character Swap"
methodLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
methodLabel.Font = Enum.Font.Gotham
methodLabel.TextSize = 11
methodLabel.Parent = mainFrame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.9, 0, 0, 35)
toggleBtn.Position = UDim2.new(0.05, 0, 0.62, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
toggleBtn.Text = "Toggle Invisible [INSERT]"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 13
toggleBtn.Parent = mainFrame

Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

local warnLabel = Instance.new("TextLabel")
warnLabel.Size = UDim2.new(0.9, 0, 0, 25)
warnLabel.Position = UDim2.new(0.05, 0, 0.82, 0)
warnLabel.BackgroundTransparency = 1
warnLabel.Text = "⚠️ FakeChar = Client-Side Visual Only"
warnLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
warnLabel.Font = Enum.Font.Gotham
warnLabel.TextSize = 10
warnLabel.TextWrapped = true
warnLabel.Parent = mainFrame

--// ============================================
--//  HELPER FUNCTIONS
--// ============================================

local function disableLocalScripts(char)
    for _, obj in pairs(char:GetDescendants()) do
        if obj:IsA("LocalScript") then
            pcall(function() obj.Disabled = true end)
        end
    end
end

local function enableLocalScripts(char)
    for _, obj in pairs(char:GetDescendants()) do
        if obj:IsA("LocalScript") then
            pcall(function() obj.Disabled = false end)
        end
    end
end

local function setTransparency(char, trans)
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = trans
            part.CastShadow = false
        elseif part:IsA("Decal") or part:IsA("Texture") then
            part.Transparency = trans
        elseif part:IsA("BillboardGui") or part:IsA("SurfaceGui") then
            part.Enabled = (trans == 0)
        end
    end
end

local function destroyVisuals(char)
    -- Hancurkan accessories, clothing, face
    for _, obj in pairs(char:GetChildren()) do
        if obj:IsA("Accessory") then
            pcall(function() obj:Destroy() end)
        elseif obj:IsA("Clothing") or obj:IsA("ShirtGraphic") then
            pcall(function() obj:Destroy() end)
        end
    end
    -- Hancurkan decals di head
    local head = char:FindFirstChild("Head")
    if head then
        for _, obj in pairs(head:GetChildren()) do
            if obj:IsA("Decal") then
                pcall(function() obj:Destroy() end)
            end
        end
    end
end

--// ============================================
--//  CORE: FAKE CHARACTER SETUP
--// ============================================

local function setupFakeCharacter()
    local char = LocalPlayer.Character
    if not char then return nil end
    
    local hrp = char:WaitForChild("HumanoidRootPart", 3)
    local humanoid = char:WaitForChild("Humanoid", 3)
    if not hrp or not humanoid then return nil end
    
    -- Simpan tools ke backpack
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    for _, tool in pairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            table.insert(savedTools, tool)
            pcall(function() tool.Parent = backpack end)
        end
    end
    
    -- Clone karakter
    char.Archivable = true
    local fake = char:Clone()
    fake.Name = "FakeCharacter_VD"
    fake.Parent = Workspace
    
    -- Setup fake character
    destroyVisuals(fake) -- Hapus accessories/clothing dari fake
    disableLocalScripts(fake) -- Matiin local scripts di fake
    
    -- Set fake character transparan (1 = full invisible)
    for _, part in pairs(fake:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 1
            part.CanCollide = false
            part.CastShadow = false
        end
    end
    
    -- Pindahin fake character ke posisi asli
    local fakeHRP = fake:WaitForChild("HumanoidRootPart")
    fakeHRP.CFrame = hrp.CFrame
    
    return fake
end

--// ============================================
--//  TOGGLE INVISIBILITY
--// ============================================

local function enableInvisibility()
    realCharacter = LocalPlayer.Character
    if not realCharacter then
        warn("❌ Character belum spawn!")
        return false
    end
    
    local hrp = realCharacter:FindFirstChild("HumanoidRootPart")
    local humanoid = realCharacter:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then
        warn("❌ HRP/Humanoid tidak ditemukan!")
        return false
    end
    
    -- Setup fake character
    fakeCharacter = setupFakeCharacter()
    if not fakeCharacter then
        warn("❌ Gagal clone fake character!")
        return false
    end
    
    -- Simpan posisi
    local savedCFrame = hrp.CFrame
    
    -- Pindahin real character ke bawah (offset)
    hrp.CFrame = savedCFrame * CFrame.new(0, INVIS_OFFSET, 0)
    
    -- Swap character ke fake
    pcall(function()
        LocalPlayer.Character = fakeCharacter
    end)
    
    -- Camera ke fake character
    pcall(function()
        Workspace.CurrentCamera.CameraSubject = fakeCharacter:FindFirstChildOfClass("Humanoid")
    end)
    
    -- Matiin local scripts di real, nyalain di fake
    disableLocalScripts(realCharacter)
    enableLocalScripts(fakeCharacter)
    
    -- Loop: Real character ngikutin fake character
    updateConnection = RunService.Heartbeat:Connect(function()
        if not isInvisible then return end
        if not fakeCharacter or not fakeCharacter.Parent then return end
        if not realCharacter or not realCharacter.Parent then return end
        
        local fakeHRP = fakeCharacter:FindFirstChild("HumanoidRootPart")
        local realHRP = realCharacter:FindFirstChild("HumanoidRootPart")
        if not fakeHRP or not realHRP then return end
        
        -- Real character ngikutin fake tapi tetap di bawah
        realHRP.CFrame = fakeHRP.CFrame * CFrame.new(0, INVIS_OFFSET, 0)
        
        -- Sync humanoid states
        local fakeHum = fakeCharacter:FindFirstChildOfClass("Humanoid")
        local realHum = realCharacter:FindFirstChildOfClass("Humanoid")
        if fakeHum and realHum then
            realHum.WalkSpeed = fakeHum.WalkSpeed
            realHum.JumpPower = fakeHum.JumpPower
            realHum.PlatformStand = fakeHum.PlatformStand
        end
    end)
    
    return true
end

local function disableInvisibility()
    if updateConnection then
        updateConnection:Disconnect()
        updateConnection = nil
    end
    
    -- Swap balik ke real character
    if realCharacter and realCharacter.Parent then
        local realHRP = realCharacter:FindFirstChild("HumanoidRootPart")
        local fakeHRP = fakeCharacter and fakeCharacter:FindFirstChild("HumanoidRootPart")
        
        if realHRP and fakeHRP then
            realHRP.CFrame = fakeHRP.CFrame
        end
        
        pcall(function()
            LocalPlayer.Character = realCharacter
        end)
        
        pcall(function()
            Workspace.CurrentCamera.CameraSubject = realCharacter:FindFirstChildOfClass("Humanoid")
        end)
        
        enableLocalScripts(realCharacter)
    end
    
    -- Hancurkan fake character
    if fakeCharacter then
        pcall(function() fakeCharacter:Destroy() end)
        fakeCharacter = nil
    end
    
    -- Restore tools
    local char = LocalPlayer.Character
    if char then
        for _, tool in pairs(savedTools) do
            if tool and tool.Parent then
                pcall(function() tool.Parent = char end)
            end
        end
    end
    savedTools = {}
    
    isInvisible = false
    statusLabel.Text = "Status: VISIBLE"
    statusLabel.TextColor3 = Color3.fromRGB(0, 255, 80)
    toggleBtn.Text = "Toggle Invisible [INSERT]"
    toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    
    print("✅ Invisible dimatikan")
end

--// ============================================
--//  MAIN TOGGLE
--// ============================================

local function toggleInvisibility()
    if isInvisible then
        disableInvisibility()
        return
    end
    
    isInvisible = true
    statusLabel.Text = "Status: ACTIVATING..."
    statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    
    local success = enableInvisibility()
    
    if success then
        statusLabel.Text = "Status: INVISIBLE 👻"
        statusLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
        toggleBtn.Text = "MATIKAN INVISIBLE"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        print("✅ FakeChar Invisible: AKTIF")
        print("⚠️  PERINGATAN: Ini client-side visual only!")
        print("⚠️  Orang lain mungkin masih lihat karakter kamu!")
    else
        statusLabel.Text = "Status: GAGAL"
        statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        isInvisible = false
    end
end

--// ============================================
--//  EVENTS
--// ============================================

toggleBtn.MouseButton1Click:Connect(toggleInvisibility)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == TOGGLE_KEY and not gameProcessed then
        toggleInvisibility()
    end
end)

--// Handle respawn
LocalPlayer.CharacterAdded:Connect(function(newChar)
    if isInvisible then
        -- Matiin dulu, terus aktifkan ulang
        disableInvisibility()
        task.wait(1)
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

print("👻 VD FakeChar Invisible loaded!")
print("Tekan INSERT untuk toggle")
print("⚠️  DISCLAIMER: Metode ini CLIENT-SIDE visual only!")
print("⚠️  Orang lain MUNGKIN masih lihat karakter asli kamu!")
