--[[
    Script: Universal Attribute & Cooldown Force Reset
    Jalankan via Executor Delta
]]

local Players = game:GetService("Players")
local player = Players.LocalPlayer

print("=== MENCOBA MEMPAKSA RESET COOLDOWN & ATRIBUT ===")

task.spawn(function()
    while true do
        task.wait(0.1)
        pcall(function()
            local char = player.Character
            if char then
                -- Menghapus atau mereset semua atribut yang mengandung kata cooldown/cd/ability
                for _, attr in ipairs(char:GetAttributes()) do
                    local lowerAttr = string.lower(attr)
                    if lowerAttr:find("cooldown") or lowerAttr:find("cd") or lowerAttr:find("ability") then
                        char:SetAttribute(attr, 0)
                    end
                end
            end
        end)
    end
end)
