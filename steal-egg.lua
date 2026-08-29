-- ================================================================
--  TAMBAHAN: EGG ACTIONS (Ambil, Steal, Place, Hatch, Drop)
--  Jalankan setelah script utama (Super Menu) berjalan.
-- ================================================================

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")

-- Fungsi bantu execute remote (sama seperti sebelumnya)
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

-- Cari window Orion yang sudah ada
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
    print("⚠️ Window Orion tidak ditemukan. Jalankan script utama terlebih dahulu.")
    return
end

-- Buat tab baru "Egg Actions" (Orion tidak punya API get tab, jadi kita buat tab baru)
-- Kita perlu akses ke OrionLib. Karena script utama sudah load OrionLib, kita pakai variabel global.
local OrionLib = OrionLib or loadstring(game:HttpGet("https://raw.githubusercontent.com/Marpiii/UiLib/refs/heads/main/source.lua"))()
-- Tapi karena window sudah ada, kita bisa buat tab dari window yang sudah ada.
-- Asumsikan window adalah objek dari Orion, kita panggil window:MakeTab
if window.MakeTab then
    local eggTab = window:MakeTab({ Name = "Egg Actions", Icon = "rbxassetid://7734056608" })
    local eggSec = eggTab:AddSection({ Name = "Manipulasi Telur" })

    -- Tombol Carry Egg
    eggSec:AddButton({
        Name = "Carry Egg (Ambil Telur)",
        Callback = function()
            executeRemote("ReplicatedStorage.Packages.Networking.RF/EggWorld/AskFieldEggCarry", {})
            print("✅ Mencoba mengambil telur")
        end
    })

    -- Tombol Steal Egg dari pemain terdekat
    eggSec:AddButton({
        Name = "Steal Egg from Nearest Player",
        Callback = function()
            local char = LP.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            local target = nil
            local minDist = math.huge
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LP then
                    local tChar = player.Character
                    if tChar and tChar:FindFirstChild("HumanoidRootPart") then
                        local dist = (tChar.HumanoidRootPart.Position - root.Position).Magnitude
                        if dist < minDist then
                            minDist = dist
                            target = player
                        end
                    end
                end
            end
            if target then
                executeRemote("ReplicatedStorage.Packages.Networking.RF/EggWorld/AskFieldEggCarry", {target})
                print("✅ Mencuri telur dari " .. target.Name)
            else
                print("⚠️ Tidak ada pemain di dekatmu")
            end
        end
    })

    -- Tombol Place Egg
    eggSec:AddButton({
        Name = "Place Egg (Tempatkan Telur)",
        Callback = function()
            executeRemote("ReplicatedStorage.Packages.Networking.RF/EggWorld/AskPlaceEgg", {})
            print("✅ Mencoba menempatkan telur")
        end
    })

    -- Tombol Hatch Egg
    eggSec:AddButton({
        Name = "Hatch Egg (Tetas Telur)",
        Callback = function()
            executeRemote("ReplicatedStorage.Packages.Networking.RF/EggWorld/AskHatch", {})
            print("✅ Mencoba menetaskan telur")
        end
    })

    -- Tombol Drop Egg
    eggSec:AddButton({
        Name = "Drop Egg (Jatuhkan Telur)",
        Callback = function()
            executeRemote("ReplicatedStorage.Packages.Networking.RF/EggWorld/AskFieldEggDrop", {})
            print("✅ Telur dijatuhkan")
        end
    })

    -- Tombol untuk mencuri dari semua pemain
    eggSec:AddButton({
        Name = "Steal from ALL Players",
        Callback = function()
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LP then
                    executeRemote("ReplicatedStorage.Packages.Networking.RF/EggWorld/AskFieldEggCarry", {player})
                    task.wait(0.1)
                end
            end
            print("✅ Mencoba mencuri dari semua pemain")
        end
    })

    print("✅ Tab 'Egg Actions' berhasil ditambahkan!")
else
    print("⚠️ Gagal membuat tab. Pastikan Orion berjalan.")
end
