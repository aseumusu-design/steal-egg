-- ==================== TAMBAHAN FARM TREADMILL ====================
-- Jalankan script ini SETELAH script utama (SuperMenu) berjalan.
-- Jika SuperMenu belum ada, script ini akan membuat GUI sendiri.

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")
local RS = game:GetService("ReplicatedStorage")

-- Fungsi bantu execute remote (sama seperti sebelumnya)
local function executeRemote(path, args)
    local obj = nil
    local function getObject(p)
        local parts = {}
        for part in string.gmatch(p, "[^%.]+") do table.insert(parts, part) end
        local cur = game
        for i, part in ipairs(parts) do
            if i == 1 and part == "ReplicatedStorage" then cur = RS
            elseif i == 1 and part == "Workspace" then cur = game:GetService("Workspace")
            elseif i == 1 and part == "Players" then cur = Players
            else
                local child = cur:FindFirstChild(part)
                if child then cur = child else return nil end
            end
        end
        return cur
    end
    obj = getObject(path)
    if not obj then warn("Remote tidak ditemukan: " .. path); return false end
    if obj:IsA("RemoteEvent") then
        pcall(function() obj:FireServer(unpack(args or {})) end)
        return true
    elseif obj:IsA("RemoteFunction") then
        pcall(function() obj:InvokeServer(unpack(args or {})) end)
        return true
    else
        return false
    end
end

-- Daftar remote Treadmill yang berguna untuk farm
local treadmillActions = {
    wearStill = "ReplicatedStorage.Packages.Networking.RF/Treadmill/AskWearStill",
    tierRaise = "ReplicatedStorage.Packages.Networking.RF/Treadmill/AskTierRaise",
    slowToggle = "ReplicatedStorage.Packages.Networking.RF/Treadmill/AskSlowToggle",
    clipFavour = "ReplicatedStorage.Packages.Networking.RF/Treadmill/AskClipFavour",
    postReply = "ReplicatedStorage.Packages.Networking.RF/Treadmill/AskPostReply",
    renderSnapshot = "ReplicatedStorage.Packages.Networking.RF/Treadmill/AskRenderSnapshot",
    replyCounts = "ReplicatedStorage.Packages.Networking.RF/Treadmill/AskReplyCounts",
    replyFavour = "ReplicatedStorage.Packages.Networking.RF/Treadmill/AskReplyFavour",
    replyPage = "ReplicatedStorage.Packages.Networking.RF/Treadmill/AskReplyPage",
    slowToggleSet = "ReplicatedStorage.Packages.Networking.RF/Treadmill/AskSlowToggleSet",
    favourSnapshot = "ReplicatedStorage.Packages.Networking.RF/Treadmill/AskFavourSnapshot",
    friendFavour = "ReplicatedStorage.Packages.Networking.RF/Treadmill/AskFriendFavourSnapshot",
    gaugeClip = "ReplicatedStorage.Packages.Networking.RF/Treadmill/GaugeClipLength",
    doff = "ReplicatedStorage.Packages.Networking.RF/Treadmill/AskDoff",
}

-- Cari GUI utama (SuperMenu) atau buat baru
local gui = PG:FindFirstChild("SuperMenu")
local mainFrame
local tabContainer

if gui then
    -- Cari frame utama (asumsi namanya "main" atau frame pertama)
    mainFrame = gui:FindFirstChild("main") or gui:FindFirstChildWhichIsA("Frame")
    if mainFrame then
        -- Cari tab container (biasanya frame yang berisi tabFrames)
        -- Kita akan menambahkan tab baru di akhir tab buttons
        local tabBtns = {}
        local tabFrames = {}
        -- Cari semua tombol tab dan frame tab
        for _, child in pairs(mainFrame:GetChildren()) do
            if child:IsA("TextButton") and child.Position.Y.Offset == 40 and child.Size.X.Offset < 150 then
                table.insert(tabBtns, child)
            end
            if child:IsA("Frame") and child.Position.Y.Offset == 75 and child.Size.Y.Scale > 0.5 then
                table.insert(tabFrames, child)
            end
        end
        -- Jika ada tab, tambahkan tombol baru
        if #tabBtns > 0 and #tabFrames > 0 then
            local newBtn = Instance.new("TextButton")
            newBtn.Size = UDim2.new(0, 130, 0, 28)
            newBtn.Position = UDim2.new(0, 20 + #tabBtns * 135, 0, 40)
            newBtn.BackgroundColor3 = Color3.fromRGB(50,50,70)
            newBtn.Text = "Treadmill"
            newBtn.TextColor3 = Color3.new(1,1,1)
            newBtn.TextSize = 11
            newBtn.Font = Enum.Font.GothamBold
            newBtn.Parent = mainFrame
            table.insert(tabBtns, newBtn)
            
            -- Buat frame untuk tab baru
            local newFrame = Instance.new("Frame")
            newFrame.Size = UDim2.new(1, -20, 1, -90)
            newFrame.Position = UDim2.new(0, 10, 0, 75)
            newFrame.BackgroundColor3 = Color3.fromRGB(15,15,25)
            newFrame.BorderSizePixel = 0
            newFrame.Parent = mainFrame
            newFrame.Visible = false
            table.insert(tabFrames, newFrame)
            
            -- Fungsi switch tab baru (gunakan yang sudah ada atau buat sendiri)
            local oldSwitch = nil
            -- Coba cari fungsi switch di tombol pertama
            local conn = tabBtns[1].MouseButton1Click:Connect(function() end)
            conn:Disconnect()
            -- Kita akan buat fungsi switch manual
            local function switchTab(index)
                for i, f in ipairs(tabFrames) do
                    f.Visible = (i == index)
                    tabBtns[i].BackgroundColor3 = (i == index) and Color3.fromRGB(80,80,120) or Color3.fromRGB(50,50,70)
                end
            end
            -- Hook semua tombol dengan fungsi switch
            for i, btn in ipairs(tabBtns) do
                btn.MouseButton1Click:Connect(function() switchTab(i) end)
            end
            -- Isi konten tab baru
            buildTreadmillTab(newFrame)
            -- Tampilkan tab pertama (agar tidak kosong)
            switchTab(1)
        else
            -- Jika tidak ada tab, buat GUI sendiri
            buildStandaloneGUI()
        end
    else
        buildStandaloneGUI()
    end
else
    buildStandaloneGUI()
end

-- Fungsi untuk membuat konten tab Treadmill
function buildTreadmillTab(parent)
    -- Tombol Start/Stop Auto Farm
    local farmRunning = false
    local farmThread = nil
    
    local farmBtn = Instance.new("TextButton")
    farmBtn.Size = UDim2.new(0, 200, 0, 30)
    farmBtn.Position = UDim2.new(0, 10, 0, 10)
    farmBtn.BackgroundColor3 = Color3.fromRGB(0,200,0)
    farmBtn.Text = "▶ Start Auto Farm"
    farmBtn.TextColor3 = Color3.new(1,1,1)
    farmBtn.TextSize = 14
    farmBtn.Font = Enum.Font.GothamBold
    farmBtn.Parent = parent
    
    local function farmLoop()
        while farmRunning do
            -- Panggil beberapa remote secara bergantian
            executeRemote(treadmillActions.wearStill, {})
            task.wait(0.5)
            executeRemote(treadmillActions.tierRaise, {})
            task.wait(0.5)
            executeRemote(treadmillActions.slowToggle, {})
            task.wait(0.5)
            executeRemote(treadmillActions.clipFavour, {})
            task.wait(1)
            -- Tambahkan aksi lain jika perlu
        end
    end
    
    farmBtn.MouseButton1Click:Connect(function()
        farmRunning = not farmRunning
        farmBtn.Text = farmRunning and "⏹ Stop Auto Farm" or "▶ Start Auto Farm"
        farmBtn.BackgroundColor3 = farmRunning and Color3.fromRGB(200,0,0) or Color3.fromRGB(0,200,0)
        if farmRunning then
            farmThread = task.spawn(farmLoop)
        else
            if farmThread then task.cancel(farmThread); farmThread = nil end
        end
    end)
    
    -- Tombol manual
    local y = 50
    local manualActions = {
        {"Wear Still", treadmillActions.wearStill},
        {"Tier Raise", treadmillActions.tierRaise},
        {"Slow Toggle", treadmillActions.slowToggle},
        {"Clip Favour", treadmillActions.clipFavour},
        {"Post Reply", treadmillActions.postReply},
        {"Render Snapshot", treadmillActions.renderSnapshot},
        {"Reply Counts", treadmillActions.replyCounts},
        {"Reply Favour", treadmillActions.replyFavour},
        {"Reply Page", treadmillActions.replyPage},
        {"Slow Toggle Set", treadmillActions.slowToggleSet},
        {"Favour Snapshot", treadmillActions.favourSnapshot},
        {"Friend Favour", treadmillActions.friendFavour},
        {"Gauge Clip", treadmillActions.gaugeClip},
        {"Doff", treadmillActions.doff},
    }
    
    for _, action in ipairs(manualActions) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 180, 0, 24)
        btn.Position = UDim2.new(0, 10, 0, y)
        btn.BackgroundColor3 = Color3.fromRGB(40,40,60)
        btn.Text = action[1]
        btn.TextColor3 = Color3.new(1,1,1)
        btn.TextSize = 11
        btn.Font = Enum.Font.GothamBold
        btn.Parent = parent
        btn.MouseButton1Click:Connect(function()
            executeRemote(action[2], {})
            print("✅ Manual: " .. action[1])
        end)
        y = y + 28
    end
end

-- Fungsi jika harus membuat GUI sendiri (fallback)
function buildStandaloneGUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "TreadmillFarmGUI"
    gui.ResetOnSpawn = false
    gui.Parent = PG
    
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 400, 0, 500)
    main.Position = UDim2.new(0.5, -200, 0.5, -250)
    main.BackgroundColor3 = Color3.fromRGB(20,20,30)
    main.BackgroundTransparency = 0.1
    main.BorderSizePixel = 0
    main.Parent = gui
    main.Active = true
    main.Draggable = true
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -40, 0, 30)
    title.Position = UDim2.new(0, 20, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = "🏃 Treadmill Farm"
    title.TextColor3 = Color3.new(1,1,1)
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = main
    
    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 30, 0, 30)
    close.Position = UDim2.new(1, -35, 0, 5)
    close.BackgroundColor3 = Color3.fromRGB(200,50,50)
    close.Text = "X"
    close.TextColor3 = Color3.new(1,1,1)
    close.TextSize = 14
    close.Font = Enum.Font.GothamBold
    close.Parent = main
    close.MouseButton1Click:Connect(function() gui:Destroy() end)
    
    -- Buat frame konten
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -20, 1, -50)
    content.Position = UDim2.new(0, 10, 0, 40)
    content.BackgroundColor3 = Color3.fromRGB(15,15,25)
    content.BorderSizePixel = 0
    content.Parent = main
    
    buildTreadmillTab(content)
end

print("✅ Treadmill Farm ditambahkan!")
print("📌 Cek tab 'Treadmill' di menu utama, atau buka GUI baru.")
