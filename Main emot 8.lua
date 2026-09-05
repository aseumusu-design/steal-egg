--[[
    Script: Force Spam Skill / No Cooldown Killer
    Execute via Delta Mobile
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

-- Mencari path event cooldown secara spesifik
local success, CooldownEvent = pcall(function()
    return ReplicatedStorage.Remotes.Killers.Killer.CooldownEvent
end)

if not success or not CooldownEvent then
    warn("CooldownEvent tidak ditemukan!")
    return
end

print("=== SCRIPT NO COOLDOWN AKTIF ===")

-- Metode 1: Spam firesignal dengan berbagai variasi angka (0, -1, nil) secara cepat
task.spawn(function()
    while true do
        task.wait(0.05) -- Jeda sangat cepat agar tidak nge-crash game
        pcall(function()
            firesignal(CooldownEvent.OnClientEvent, 0)
            firesignal(CooldownEvent.OnClientEvent, -9999)
        end)
    end
end)

-- Metode 2: Cek apakah ada remote lain untuk aktivasi skill (biasanya ada SkillEvent / UseAbility)
local successRemote, ActionEvent = pcall(function()
    return ReplicatedStorage.Remotes.Killers.Killer.AbilityEvent -- atau sesuaikan jika ada event lain
end)

if successRemote and ActionEvent then
    print("Action event ditemukan!")
end
