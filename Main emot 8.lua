-- Inisialisasi variabel global dasar jika belum ada
getgenv().VD = getgenv().VD or {}
VD.KILLER_InfFrenzy = true
VD.KILLER_InfLakeMist = true
VD.KILLER_InfPursuit = true

-- ==================== JEFF BYPASS ====================
getgenv().KYS_JeffCooldownBypassThread = nil 

function KYS_StartJeffCooldownBypass() 
    if getgenv().KYS_JeffCooldownBypassThread then return end 
    getgenv().KYS_JeffCooldownBypassThread = task.spawn(function() 
        local player = game:GetService("Players").LocalPlayer 
        while task.wait() do 
            if not VD.KILLER_InfFrenzy then break end 
            pcall(function() 
                local char = player.Character 
                if char and char:GetAttribute("Frenzy") ~= true then 
                    char:SetAttribute("Frenzy", true) 
                end 
            end) 
        end 
        getgenv().KYS_JeffCooldownBypassThread = nil 
    end) 
end 

function KYS_StopJeffCooldownBypass() 
    pcall(function() 
        local player = game:GetService("Players").LocalPlayer 
        local char = player.Character 
        if char and char:GetAttribute("Frenzy") == true then 
            char:SetAttribute("Frenzy", false) 
            local killer = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes"):FindFirstChild("Killers"):FindFirstChild("Killer") 
            if killer then 
                local deact = killer:FindFirstChild("Deactivatefromclient") 
                if deact then 
                    deact:FireServer() 
                end 
            end 
        end 
    end) 
end

-- ==================== SLASHER / JASON BYPASS ====================
getgenv().KYS_SlasherCooldownBypassThread = nil 

function KYS_StartSlasherCooldownBypass() 
    if getgenv().KYS_SlasherCooldownBypassThread then return end 
    
    -- BOOLEAN ARITHMETIC FAILSAFE FOR AWARDLOG 
    pcall(function() 
        local b = true 
        local mt = debug.getmetatable(b) 
        if not mt then mt = {} debug.setmetatable(b, mt) end 
        if setreadonly then setreadonly(mt, false) end 
        mt.__div = function() return 0 end 
        mt.__mul = function() return 0 end 
        mt.__add = function() return 0 end 
        mt.__sub = function() return 0 end 
        if setreadonly then setreadonly(mt, true) end 
    end) 

    getgenv().KYS_SlasherCooldownBypassThread = task.spawn(function() 
        local toggleFunc = nil 
        local pursuitHandler = nil 
        
        local function scanGCForSlasher() 
            pcall(function() 
                for _, v in pairs(getgc(true)) do 
                    if type(v) == "function" and islclosure(v) then 
                        local consts = debug.getconstants(v) 
                        local hasOffset, hasLinear, hasAction, hasTweenInfo = false, false, false, false 
                        local hasPursuit, hasWalkSpeed = false, false 
                        for _, c in pairs(consts) do 
                            if c == "Offset" then hasOffset = true end 
                            if c == "Linear" then hasLinear = true end 
                            if c == "action" then hasAction = true end 
                            if c == "TweenInfo" then hasTweenInfo = true end 
                            if c == "Pursuit" then hasPursuit = true end 
                            if c == "WalkSpeed" then hasWalkSpeed = true end 
                        end 
                        if hasOffset and hasLinear and hasAction and hasTweenInfo and not hasPursuit then 
                            toggleFunc = v 
                        end 
                        if hasPursuit and hasTweenInfo and hasAction and hasWalkSpeed then 
                            pursuitHandler = v 
                        end 
                    end 
                    if toggleFunc and pursuitHandler then break end 
                end 
            end) 
        end 

        scanGCForSlasher() 
        local lastScan = os.clock() 

        while task.wait(0.1) do 
            if not VD.KILLER_InfLakeMist and not VD.KILLER_InfPursuit then break end 
            if not (toggleFunc and pursuitHandler) then 
                if os.clock() - lastScan >= 2 then 
                    scanGCForSlasher() 
                    lastScan = os.clock() 
                end 
            end 
            if toggleFunc and VD.KILLER_InfLakeMist then 
                pcall(function() 
                    debug.setupvalue(toggleFunc, 6, false) -- LakeMist cooldown 
                    debug.setupvalue(toggleFunc, 10, false) -- Anti-spam 
                end) 
            end 
            if pursuitHandler and VD.KILLER_InfPursuit then 
                pcall(function() 
                    debug.setupvalue(pursuitHandler, 5, false) -- Anti-spam 
                    debug.setupvalue(pursuitHandler, 6, false) -- Pursuit cooldown 
                end) 
            end 
        end 
        getgenv().KYS_SlasherCooldownBypassThread = nil 
    end) 
end 

function KYS_StopSlasherCooldownBypass() 
    pcall(function() 
        local rs = game:GetService("ReplicatedStorage") 
        local jason = rs:FindFirstChild("Remotes") and rs.Remotes:FindFirstChild("Killers") and rs.Remotes.Killers:FindFirstChild("Jason") 
        if jason then 
            if not VD.KILLER_InfLakeMist then 
                local lm = jason:FindFirstChild("LakeMist") 
                if lm then lm:FireServer(false) end 
            end 
            if not VD.KILLER_InfPursuit then 
                local ps = jason:FindFirstChild("Pursuit") 
                if ps then ps:FireServer(false) end 
            end 
        end 
    end) 
end

-- Menjalankan bypass secara otomatis saat di-execute:
KYS_StartJeffCooldownBypass()
KYS_StartSlasherCooldownBypass()
print("[SUCCESS] Script Bypass Cooldown berhasil dijalankan!")
