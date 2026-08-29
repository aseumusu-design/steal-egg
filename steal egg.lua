-- ============================================================
--  DETEKTOR REMOTE + AUTO FARM CLAIM RARITY (UNIVERSAL)
--  Scan semua remote, copy path ke clipboard, dan auto-execute
-- ============================================================

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")
local RunService = game:GetService("RunService")

-- ========== 1. DETEKSI SEMUA REMOTE ==========
local allRemotes = {}
local remotePaths = {}

local function scanForRemotes(parent)
    for _, child in pairs(parent:GetChildren()) do
        if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
            local path = child:GetFullName()
            table.insert(allRemotes, child)
            table.insert(remotePaths, path)
        end
        scanForRemotes(child)
    end
end

-- Scan dari berbagai root
scanForRemotes(game)
scanForRemotes(RS)
scanForRemotes(WS)
scanForRemotes(Players)

print("Total remote ditemukan: " .. #remotePaths)

-- Copy ke clipboard
local function copyToClipboard(text)
    if setclipboard then
        pcall(setclipboard, text)
        print("✅ Clipboard berisi " .. #remotePaths .. " path remote.")
    elseif toclipboard then
        pcall(toclipboard, text)
        print("✅ Clipboard berisi " .. #remotePaths .. " path remote.")
    else
        print("⚠️ Clipboard tidak support, tapi daftar ada di console.")
    end
end

-- Gabungkan semua path dengan newline
local allPathsText = table.concat(remotePaths, "\n")
copyToClipboard(allPathsText)

-- Tampilkan di console (untuk jaga-jaga)
print("========== DAFTAR REMOTE ==========")
for i, p in ipairs(remotePaths) do
    print(i .. ". " .. p)
end
print("========== TOTAL: " .. #remotePaths .. " ==========")

-- ========== 2. AUTO FARM CLAIM RARITY ==========
-- Cari remote yang berisi kata kunci tertentu
local keywords = {"claim", "reward", "rarity", "egg", "pet", "collect", "redeem", "prize", "chest", "open"}
local targetRemotes = {}

for _, remote in ipairs(allRemotes) do
    local name = remote.Name:lower()
    local path = remote:GetFullName():lower()
    for _, kw in ipairs(keywords) do
        if name:find(kw) or path:find(kw) then
            table.insert(targetRemotes, remote)
            break
        end
    end
end

print("Remote untuk auto farm: " .. #targetRemotes .. " ditemukan.")

-- Fungsi untuk menjalankan remote (FireServer/InvokeServer)
local function fireRemote(remote)
    if remote:IsA("RemoteEvent") then
        pcall(remote.FireServer, remote)
    elseif remote:IsA("RemoteFunction") then
        pcall(remote.InvokeServer, remote)
    end
end

-- Auto farm loop (jalankan semua remote target dengan delay)
local farmRunning = false
local farmThread = nil

local function startAutoFarm()
    if farmRunning then return end
    farmRunning = true
    print("🔄 Auto Farm CLAIM RARITY dimulai...")
    farmThread = task.spawn(function()
        while farmRunning do
            for _, remote in ipairs(targetRemotes) do
                if not farmRunning then break end
                fireRemote(remote)
                task.wait(0.2)
            end
            task.wait(1)
        end
        print("⏹️ Auto Farm berhenti.")
    end)
end

local function stopAutoFarm()
    farmRunning = false
    if farmThread then
        task.cancel(farmThread)
        farmThread = nil
    end
    print("⏹️ Auto Farm dihentikan.")
end

-- ========== 3. GUI SIMPLE UNTUK KONTROL ==========
local function createGUI()
    local pg = LP:WaitForChild("PlayerGui")
    -- Hapus GUI lama jika ada
    local old = pg:FindFirstChild("RemoteAutoFarmGUI")
    if old then old:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "RemoteAutoFarmGUI"
    gui.ResetOnSpawn = false
    gui.Parent = pg

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 200)
    frame.Position = UDim2.new(0.5, -150, 0.5, -100)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0
    frame.Parent = gui
    frame.Active = true
    frame.Draggable = true

    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 30)
    title.Position = UDim2.new(0, 10, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = "🔥 AUTO FARM CLAIM"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame

    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 30, 0, 30)
    close.Position = UDim2.new(1, -35, 0, 5)
    close.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    close.Text = "X"
    close.TextColor3 = Color3.new(1, 1, 1)
    close.TextSize = 14
    close.Font = Enum.Font.GothamBold
    close.Parent = frame
    close.MouseButton1Click:Connect(function() gui:Destroy() end)

    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, -20, 0, 40)
    info.Position = UDim2.new(0, 10, 0, 40)
    info.BackgroundTransparency = 1
    info.Text = "Total remote terdeteksi: " .. #remotePaths .. "\nTarget auto farm: " .. #targetRemotes
    info.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    info.TextSize = 12
    info.Font = Enum.Font.Gotham
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.Parent = frame

    local btnStart = Instance.new("TextButton")
    btnStart.Size = UDim2.new(0, 120, 0, 36)
    btnStart.Position = UDim2.new(0, 20, 1, -50)
    btnStart.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    btnStart.Text = "▶ Start Farm"
    btnStart.TextColor3 = Color3.new(1, 1, 1)
    btnStart.TextSize = 14
    btnStart.Font = Enum.Font.GothamBold
    btnStart.Parent = frame
    Instance.new("UICorner", btnStart).CornerRadius = UDim.new(0, 6)
    btnStart.MouseButton1Click:Connect(function()
        startAutoFarm()
        btnStart.Text = "⏹ Stop"
        btnStart.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        btnStart.MouseButton1Click:Connect(function()
            stopAutoFarm()
            btnStart.Text = "▶ Start Farm"
            btnStart.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        end)
    end)

    local btnCopy = Instance.new("TextButton")
    btnCopy.Size = UDim2.new(0, 120, 0, 36)
    btnCopy.Position = UDim2.new(1, -140, 1, -50)
    btnCopy.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
    btnCopy.Text = "📋 Copy All"
    btnCopy.TextColor3 = Color3.new(1, 1, 1)
    btnCopy.TextSize = 14
    btnCopy.Font = Enum.Font.GothamBold
    btnCopy.Parent = frame
    Instance.new("UICorner", btnCopy).CornerRadius = UDim.new(0, 6)
    btnCopy.MouseButton1Click:Connect(function()
        copyToClipboard(allPathsText)
    end)
end

-- Jalankan GUI
task.spawn(createGUI)

print("=========================================")
print("✅ DETEKTOR + AUTO FARM AKTIF!")
print("📌 SEMUA path remote sudah di-copy ke clipboard.")
print("📌 GUI muncul di layar. Klik Start Farm untuk auto claim.")
print("📌 Total remote: " .. #remotePaths)
print("📌 Target auto farm: " .. #targetRemotes)
print("=========================================")
