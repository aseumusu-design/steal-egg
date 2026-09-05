--[[
    Script: Auto No Cooldown Killer
    Target: ReplicatedStorage.Remotes.Killers.Killer.CooldownEvent
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local success, CooldownEvent = pcall(function()
    return ReplicatedStorage.Remotes.Killers.Killer.CooldownEvent
end)

if not success or not CooldownEvent then
    warn("CooldownEvent tidak ditemukan!")
    return
end

-- Notifikasi kecil (opsional, kalau executor support)
print("[INFO] No Cooldown Killer berhasil diaktifkan!")

-- Loop agar terus menerus memaksa cooldown menjadi 0
task.spawn(function()
    while true do
        pcall(function()
            firesignal(CooldownEvent.OnClientEvent, 0)
        end)
        task.wait(0.1) -- Jeda sepersekian detik agar tidak lag/crash
    end
end)
