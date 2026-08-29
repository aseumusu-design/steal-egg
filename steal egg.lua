-- ================================================================
--  TAMBAHAN: ESP TELUR + STEAL EGG
--  Menambahkan tombol "Steal Egg" dan ESP telur di UI Orion.
-- ================================================================

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local WS = game:GetService("Workspace")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Fungsi bantu execute remote
local function executeRemote(path, args)
    local obj = nil
    local function getObject(p)
        local parts = {}
        for part in string.gmatch(p, "[^%.]+") do table.insert(parts, part) end
        local cur = game
        for i, part in ipairs(parts) do
            if i == 1 and part == "ReplicatedStorage" then cur = RS
            elseif i == 1 and part == "Workspace" then cur = WS
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

-- ==================== CARI WINDOW ORION ====================
local window = nil
local function findOrionWindow()
    local coreGui = game:GetService("CoreGui")
    local marv = coreGui:FindFirstChild("MarV")
    if marv then
        for _, child in ipairs(marv:GetChildren()) do
            if child:IsA("Frame") and child.AbsoluteSize.X > 200 then
                window = child
                return
            end
        end
    end
end
findOrionWindow()
task.wait(0.5)
findOrionWindow()

if not window then
    -- Jika window tidak ditemukan, buat window baru
    local OrionLib = OrionLib or loadstring(game:HttpGet("https://raw.githubusercontent.com/Marpiii/UiLib/refs/heads/main/source.lua"))()
    window = OrionLib:MakeWindow({
        Name = "NO MERCY + EXTRA",
        HidePremium = false,
        SaveConfig = true,
        ConfigFolder = "NoMercyExtra",
        IntroEnabled = false,
        Icon = "rbxassetid://113381647185328",
    })
end

-- ==================== BUAT TAB UNTUK STEAL EGG ====================
local stealTab = window:MakeTab({ Name = "Steal Egg", Icon = "rbxassetid://7734056608", PremiumOnly = false })
local stealSec = stealTab:AddSection({ Name = "Aksi Mencuri Telur" })

-- Tombol untuk mencuri telur dari pemain terdekat
stealSec:AddButton({
    Name = "Steal Egg dari Pemain Terdekat",
    Callback = function()
        local char = LP.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        local targetPlayer = nil
        local minDist = math.huge
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LP then
                local tChar = player.Character
                if tChar and tChar:FindFirstChild("HumanoidRootPart") then
                    local dist = (tChar.HumanoidRootPart.Position - root.Position).Magnitude
                    if dist < minDist then
                        minDist = dist
                        targetPlayer = player
                    end
                end
            end
        end
        
        if targetPlayer then
            -- Coba remote untuk mencuri telur
            -- Beberapa kemungkinan remote:
            -- 1. AskFieldEggCarry (membawa telur dari pemain lain)
            -- 2. FieldEggCarry (event)
            -- 3. Mungkin ada remote khusus untuk steal
            local success = false
            -- Coba beberapa remote yang mungkin
            local remotesToTry = {
                "ReplicatedStorage.Packages.Networking.RF/EggWorld/AskFieldEggCarry",
                "ReplicatedStorage.Packages.Networking.RE/EggWorld/FieldEggCarry",
                "ReplicatedStorage.Packages.Networking.RF/EggWorld/AskWearTool",
            }
            for _, path in ipairs(remotesToTry) do
                local ok = executeRemote(path, {targetPlayer})
                if ok then
                    print("✅ Mencuri telur dari " .. targetPlayer.Name .. " menggunakan " .. path)
                    success = true
                    break
                end
            end
            if not success then
                print("⚠️ Gagal mencuri telur, coba remote lain.")
            end
        else
            print("⚠️ Tidak ada pemain di dekatmu.")
        end
    end
})

-- Tombol untuk mengambil semua telur dari semua pemain
stealSec:AddButton({
    Name = "Steal Egg dari SEMUA Pemain",
    Callback = function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LP then
                local success = executeRemote("ReplicatedStorage.Packages.Networking.RF/EggWorld/AskFieldEggCarry", {player})
                if success then
                    print("✅ Mencuri telur dari " .. player.Name)
                end
                task.wait(0.1)
            end
        end
    end
})

-- Tombol untuk menjatuhkan telur (jika perlu)
stealSec:AddButton({
    Name = "Drop Egg (Jatuhkan Telur)",
    Callback = function()
        executeRemote("ReplicatedStorage.Packages.Networking.RF/EggWorld/AskFieldEggDrop", {})
    end
})

-- ==================== TAMBAHKAN ESP TELUR DI TAB ESP ====================
-- Cari tab ESP yang sudah ada (dari script sebelumnya)
local espTab = nil
for _, tab in pairs(window.Tabs or {}) do
    if tab.Name == "ESP" then
        espTab = tab
        break
    end
end

if espTab then
    -- Tambahkan toggle khusus untuk ESP telur
    local espSec = espTab:AddSection({ Name = "ESP Telur" })
    local eggESPEnabled = false
    local eggESPLoop = nil
    
    espSec:AddToggle({
        Name = "ESP Telur (Highlight)",
        Default = false,
        Callback = function(v)
            eggESPEnabled = v
            if eggESPEnabled then
                if eggESPLoop then eggESPLoop:Disconnect() end
                eggESPLoop = RunService.RenderStepped:Connect(function()
                    for _, obj in pairs(WS:GetDescendants()) do
                        if obj:IsA("Model") and (obj.Name:lower():find("egg") or obj.Name:lower():find("telur")) then
                            if obj:FindFirstChild("HumanoidRootPart") then
                                local hrp = obj.HumanoidRootPart
                                local hl = Instance.new("Highlight")
                                -- Warna berdasarkan rarity
                                local rarity = "common"
                                if obj.Name:lower():find("legendary") then rarity = "legendary"
                                elseif obj.Name:lower():find("mythic") then rarity = "mythic"
                                elseif obj.Name:lower():find("secret") then rarity = "secret"
                                elseif obj.Name:lower():find("epic") then rarity = "epic"
                                elseif obj.Name:lower():find("rare") then rarity = "rare"
                                elseif obj.Name:lower():find("uncommon") then rarity = "uncommon"
                                end
                                local colors = {
                                    common = Color3.fromRGB(255,255,255),
                                    uncommon = Color3.fromRGB(0,255,0),
                                    rare = Color3.fromRGB(0,150,255),
                                    epic = Color3.fromRGB(200,0,255),
                                    legendary = Color3.fromRGB(255,150,0),
                                    mythic = Color3.fromRGB(255,0,0),
                                    secret = Color3.fromRGB(255,215,0),
                                }
                                hl.FillColor = colors[rarity] or Color3.fromRGB(255,255,255)
                                hl.OutlineColor = Color3.fromRGB(255,255,255)
                                hl.Adornee = hrp
                                hl.Parent = hrp
                                game:GetService("Debris"):AddItem(hl, 0.2)
                            end
                        end
                    end
                end)
            else
                if eggESPLoop then eggESPLoop:Disconnect(); eggESPLoop = nil end
            end
        end
    })
else
    -- Jika tab ESP tidak ada, buat tab baru
    local espTabNew = window:MakeTab({ Name = "ESP Telur", Icon = "rbxassetid://7733774602", PremiumOnly = false })
    local espSecNew = espTabNew:AddSection({ Name = "ESP Telur" })
    local eggESPEnabled = false
    local eggESPLoop = nil
    espSecNew:AddToggle({
        Name = "ESP Telur (Highlight)",
        Default = false,
        Callback = function(v)
            eggESPEnabled = v
            if eggESPEnabled then
                if eggESPLoop then eggESPLoop:Disconnect() end
                eggESPLoop = RunService.RenderStepped:Connect(function()
                    for _, obj in pairs(WS:GetDescendants()) do
                        if obj:IsA("Model") and (obj.Name:lower():find("egg") or obj.Name:lower():find("telur")) then
                            if obj:FindFirstChild("HumanoidRootPart") then
                                local hrp = obj.HumanoidRootPart
                                local hl = Instance.new("Highlight")
                                local rarity = "common"
                                if obj.Name:lower():find("legendary") then rarity = "legendary"
                                elseif obj.Name:lower():find("mythic") then rarity = "mythic"
                                elseif obj.Name:lower():find("secret") then rarity = "secret"
                                elseif obj.Name:lower():find("epic") then rarity = "epic"
                                elseif obj.Name:lower():find("rare") then rarity = "rare"
                                elseif obj.Name:lower():find("uncommon") then rarity = "uncommon"
                                end
                                local colors = {
                                    common = Color3.fromRGB(255,255,255),
                                    uncommon = Color3.fromRGB(0,255,0),
                                    rare = Color3.fromRGB(0,150,255),
                                    epic = Color3.fromRGB(200,0,255),
                                    legendary = Color3.fromRGB(255,150,0),
                                    mythic = Color3.fromRGB(255,0,0),
                                    secret = Color3.fromRGB(255,215,0),
                                }
                                hl.FillColor = colors[rarity] or Color3.fromRGB(255,255,255)
                                hl.OutlineColor = Color3.fromRGB(255,255,255)
                                hl.Adornee = hrp
                                hl.Parent = hrp
                                game:GetService("Debris"):AddItem(hl, 0.2)
                            end
                        end
                    end
                end)
            else
                if eggESPLoop then eggESPLoop:Disconnect(); eggESPLoop = nil end
            end
        end
    })
end

-- ==================== TAMBAHKAN VISUAL TETAP ====================
-- Jika tab Visual belum ada, tambahkan
local visTab = nil
for _, tab in pairs(window.Tabs or {}) do
    if tab.Name == "Visual" then
        visTab = tab
        break
    end
end
if not visTab then
    visTab = window:MakeTab({ Name = "Visual", Icon = "rbxassetid://7733774602", PremiumOnly = false })
    local visSec = visTab:AddSection({ Name = "Lighting" })
    visSec:AddToggle({
        Name = "Fullbright",
        Default = false,
        Callback = function(v)
            game:GetService("Lighting").Brightness = v and 1 or 2
        end
    })
    visSec:AddToggle({
        Name = "No Fog",
        Default = false,
        Callback = function(v)
            game:GetService("Lighting").FogEnd = v and 9999 or 100000
        end
    })
end

print("✅ Tambahan ESP Telur & Steal Egg berhasil ditambahkan!")
print("📌 Buka tab 'Steal Egg' untuk mencuri telur, atau tab 'ESP' untuk melihat telur.")
