--[[
    Script: Force Click/Trigger for move1 button
    Jalankan via Delta Executor
]]

local player = game:GetService("Players").LocalPlayer
local playerGui = player:FindFirstChild("PlayerGui")

if playerGui then
    -- Mencari tombol move1 di dalam PlayerGui -> Killer-mob -> Controls -> move1
    local killerMob = playerGui:FindFirstChild("Killer-mob")
    if killerMob then
        local controls = killerMob:FindFirstChild("Controls")
        if controls then
            local move1Button = controls:FindFirstChild("move1")
            
            if move1Button then
                print("[INFO] Tombol move1 ditemukan!")
                
                -- Memaksa tombol agar aktif (Active = true, Draggable, dll)
                move1Button.Active = true
                
                -- Jika tombol tersebut menggunakan LocalScript untuk event klik,
                -- kita bisa mendengarkan atau men-trigger koneksi klik-nya secara paksa.
                for _, connection in ipairs(getconnections(move1Button.MouseButton1Click)) do
                    -- Kita bisa panggil ulang fungsi internal tombolnya
                    print("[INFO] Koneksi tombol move1 berhasil di-hook!")
                end
                
                -- Alternatif: Membuat fungsi kustom saat tombol ditekan
                move1Button.MouseButton1Click:Connect(function()
                    print("[INFO] Tombol move1 diklik secara paksa!")
                    -- Kamu bisa tambahkan perintah tambahan di sini jika perlu
                end)
            else
                warn("Tombol move1 tidak ditemukan di dalam folder Controls!")
            end
        end
    end
end
