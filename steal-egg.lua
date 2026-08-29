-- [[ ALL-IN-ONE GAME EXTRACTOR v2.0 ]]
-- Auto scan & copy SEMUA: Scripts, UI, Remotes, Properties, Hierarchy
-- Support: setclipboard / toclipboard / writefile

local startTime = tick()

-- ===== CONFIG =====
local CONFIG = {
    MaxDepth = 999,           -- Kedalaman scan
    MaxScriptLength = 500000, -- Max karakter script (anti lag)
    IncludeSource = true,     -- Ambil source code Script/LocalScript/ModuleScript
    IncludeUI = true,         -- Ambil detail UI elements
    IncludeRemotes = true,    -- Ambil RemoteEvent/RemoteFunction
    IncludeProperties = true, -- Ambil key properties tiap instance
    OutputToClipboard = true,
    OutputToFile = true,      -- Save ke file juga (kalau executor support)
    FileName = "GameDump_" .. game.PlaceId .. "_" .. os.time() .. ".txt"
}

-- ===== SERVICES =====
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- ===== UTILS =====
local outputLines = {}
local function add(line)
    table.insert(outputLines, tostring(line))
end

local function safeGetProperty(obj, prop)
    local success, result = pcall(function()
        return obj[prop]
    end)
    if success then return result end
    return nil
end

-- ===== SCRIPT SOURCE EXTRACTOR =====
local function getScriptSource(script)
    if not CONFIG.IncludeSource then return nil end
    
    -- Method 1: getscriptbytecode (Synapse X, Krnl, dll)
    local success, bytecode = pcall(function()
        if getscriptbytecode then
            return getscriptbytecode(script)
        end
        return nil
    end)
    
    if success and bytecode and #bytecode > 0 then
        return "[BYTECODE] " .. tostring(#bytecode) .. " bytes (use decompiler)"
    end
    
    -- Method 2: getscriptclosure / getscriptsource (jika ada)
    local success2, source = pcall(function()
        if getscriptsource then
            return getscriptsource(script)
        end
        return nil
    end)
    
    if success2 and source and #source > 0 then
        return source
    end
    
    -- Method 3: Decompile (jika support)
    local success3, decompiled = pcall(function()
        if decompile then
            return decompile(script)
        end
        return nil
    end)
    
    if success3 and decompiled and #decompiled > 10 then
        return "-- [[ DECOMPILED ]] --\n" .. decompiled
    end
    
    return "[SOURCE UNAVAILABLE - Need better executor]"
end

-- ===== PROPERTY SCANNER =====
local importantProperties = {
    "Name", "ClassName", "Parent", "Position", "Size", "Text", "TextColor3", 
    "BackgroundColor3", "Image", "ImageColor3", "Visible", "Enabled", "Value",
    "CFrame", "Position", "Orientation", "BrickColor", "Material", "Transparency",
    "Reflectance", "CanCollide", "Anchored", "Massless", "Velocity", "Rotation",
    "OnServerEvent", "OnClientEvent", "OnServerInvoke", "OnClientInvoke",
    "TextSize", "Font", "TextScaled", "TextWrapped", "PlaceholderText",
    "MinValue", "MaxValue", "Value", "Color", "Brightness", "Range",
    "WalkSpeed", "JumpPower", "Health", "MaxHealth", "Team", "UserId",
    "AccountAge", "DisplayName", "CharacterAppearanceId"
}

local function getKeyProperties(obj)
    if not CONFIG.IncludeProperties then return {} end
    local props = {}
    for _, prop in ipairs(importantProperties) do
        local val = safeGetProperty(obj, prop)
        if val ~= nil then
            local strVal
            if typeof(val) == "CFrame" then
                strVal = string.format("CFrame.new(%s, %s, %s)", 
                    tostring(val.Position), tostring(val.LookVector), tostring(val.UpVector))
            elseif typeof(val) == "Vector3" then
                strVal = string.format("Vector3.new(%s)", tostring(val))
            elseif typeof(val) == "Color3" then
                strVal = string.format("Color3.fromRGB(%d, %d, %d)", 
                    math.floor(val.R * 255), math.floor(val.G * 255), math.floor(val.B * 255))
            elseif typeof(val) == "UDim2" then
                strVal = string.format("UDim2.new(%f, %d, %f, %d)", 
                    val.X.Scale, val.X.Offset, val.Y.Scale, val.Y.Offset)
            elseif typeof(val) == "EnumItem" then
                strVal = tostring(val)
            else
                strVal = tostring(val)
            end
            table.insert(props, prop .. " = " .. strVal)
        end
    end
    return props
end

-- ===== MAIN SCANNER =====
local scannedCount = 0
local scriptCount = 0
local remoteCount = 0
local uiCount = 0

local function scanInstance(obj, depth)
    if depth > CONFIG.MaxDepth then return end
    scannedCount = scannedCount + 1
    
    local indent = string.rep("  ", depth)
    local fullName = obj:GetFullName()
    local className = obj.ClassName
    
    -- Header instance
    add(string.format("%s[%s] %s", indent, className, obj.Name))
    
    -- Properties
    local props = getKeyProperties(obj)
    if #props > 0 then
        add(indent .. "  Properties:")
        for _, prop in ipairs(props) do
            add(indent .. "    " .. prop)
        end
    end
    
    -- Script Source
    if (className == "Script" or className == "LocalScript" or className == "ModuleScript") and CONFIG.IncludeSource then
        scriptCount = scriptCount + 1
        add(indent .. "  -- [[ SOURCE CODE ]] --")
        local source = getScriptSource(obj)
        if source then
            -- Truncate kalau terlalu panjang
            if #source > CONFIG.MaxScriptLength then
                source = source:sub(1, CONFIG.MaxScriptLength) .. "\n-- [TRUNCATED: too long] --"
            end
            -- Indent source code
            for line in source:gmatch("[^\r\n]+") do
                add(indent .. "  " .. line)
            end
        else
            add(indent .. "  [Could not retrieve source]")
        end
        add(indent .. "  -- [[ END SOURCE ]] --")
    end
    
    -- Remote Info
    if (className == "RemoteEvent" or className == "RemoteFunction") and CONFIG.IncludeRemotes then
        remoteCount = remoteCount + 1
        add(indent .. "  -- [[ REMOTE INFO ]] --")
        add(indent .. "  FullPath: " .. fullName)
        add(indent .. "  FireServer / InvokeServer available")
        add(indent .. "  -- [[ END REMOTE ]] --")
    end
    
    -- UI Info
    if (className:find("Gui") or className:find("Button") or className:find("Label") or 
        className:find("Frame") or className:find("Text") or className:find("Image") or
        className:find("Scrolling") or className:find("Slider") or className:find("Toggle")) 
        and CONFIG.IncludeUI then
        uiCount = uiCount + 1
    end
    
    -- Scan children
    local children = obj:GetChildren()
    if #children > 0 then
        add(indent .. "  Children (" .. #children .. "):")
        for _, child in ipairs(children) do
            scanInstance(child, depth + 1)
        end
    end
    
    add("") -- spacer
end

-- ===== EXECUTE SCAN =====
add("=" .. string.rep("=", 78))
add("  GAME FULL DUMP")
add("  PlaceId: " .. game.PlaceId)
add("  PlaceName: " .. (safeGetProperty(game, "Name") or "Unknown"))
add("  Time: " .. os.date("%Y-%m-%d %H:%M:%S"))
add("  Executor: " .. (identifyexecutor and identifyexecutor() or "Unknown"))
add("=" .. string.rep("=", 78))
add("")

-- Scan dari root services utama
local servicesToScan = {
    game:GetService("Workspace"),
    game:GetService("Players"),
    game:GetService("ReplicatedStorage"),
    game:GetService("ReplicatedFirst"),
    game:GetService("StarterGui"),
    game:GetService("StarterPack"),
    game:GetService("StarterPlayer"),
    game:GetService("Lighting"),
    game:GetService("SoundService"),
    game:GetService("Chat"),
    game:GetService("LocalizationService"),
    game:GetService("TestService"),
}

for _, service in ipairs(servicesToScan) do
    add("\n" .. string.rep("#", 80))
    add("# SCANNING: " .. service.Name)
    add(string.rep("#", 80) .. "\n")
    scanInstance(service, 0)
end

-- Summary
add("\n" .. string.rep("=", 80))
add("  SCAN COMPLETE")
add("  Total Instances Scanned: " .. scannedCount)
add("  Scripts Found: " .. scriptCount)
add("  Remotes Found: " .. remoteCount)
add("  UI Elements Found: " .. uiCount)
add("  Time Taken: " .. string.format("%.2f", tick() - startTime) .. "s")
add(string.rep("=", 80))

-- ===== OUTPUT =====
local finalOutput = table.concat(outputLines, "\n")
local totalLines = #outputLines

-- Output ke Clipboard
if CONFIG.OutputToClipboard then
    local clipSuccess = false
    
    if setclipboard then
        pcall(function()
            setclipboard(finalOutput)
            clipSuccess = true
        end)
    elseif toclipboard then
        pcall(function()
            toclipboard(finalOutput)
            clipSuccess = true
        end)
    end
    
    if clipSuccess then
        print("✅ [" .. totalLines .. " lines] Berhasil di-copy ke clipboard!")
    else
        print("⚠️ Clipboard tidak support di executor ini.")
    end
end

-- Output ke File (kalau support)
if CONFIG.OutputToFile then
    if writefile then
        pcall(function()
            writefile(CONFIG.FileName, finalOutput)
            print("✅ File tersimpan: " .. CONFIG.FileName)
        end)
    elseif saveinstance then
        -- Kalau executor support saveinstance (Synapse X style)
        print("ℹ️ Executor support saveinstance(), gunakan itu untuk full game save.")
    else
        print("⚠️ writefile() tidak tersedia.")
    end
end

-- Print summary ke console
print("========== GAME DUMP SUMMARY ==========")
print("Total Lines: " .. totalLines)
print("Instances: " .. scannedCount)
print("Scripts: " .. scriptCount)
print("Remotes: " .. remoteCount)
print("UI Elements: " .. uiCount)
print("=======================================")

-- Tampilkan preview di console (500 baris pertama)
print("\n========== PREVIEW (first 50 lines) ==========")
for i = 1, math.min(50, totalLines) do
    print(outputLines[i])
end
if totalLines > 50 then
    print("... dan " .. (totalLines - 50) .. " baris lagi ...")
end
