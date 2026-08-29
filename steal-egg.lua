-- [[ ANTI-FREEZE GAME EXTRACTOR v3.0 ]]
-- Ringan, nggak freeze HP. Fokus: Scripts, UI, Remotes only.
-- Skip: Workspace parts, meshes, unions (yang bikin lag)

local startTime = tick()

-- ===== CONFIG =====
local CONFIG = {
    MaxScriptLength = 100000,  -- Max karakter per script
    ScanBatchSize = 50,        -- Scan 50 item, istirahat, lanjut
    RestTime = 0.05,           -- Jeda 0.05 detik antar batch
    SkipWorkspace = true,      -- Skip workspace (paling berat)
    SkipPhysical = true,       -- Skip Part, Mesh, Union, dll
    OutputToClipboard = true,
    OutputToFile = true,
    FileName = "GameDump_Lite_" .. game.PlaceId .. "_" .. os.time() .. ".txt"
}

-- ===== SERVICES =====
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ===== OUTPUT =====
local outputLines = {}
local function add(line)
    table.insert(outputLines, tostring(line))
end

-- ===== SAFE GET =====
local function safeGet(obj, prop)
    local s,r = pcall(function() return obj[prop] end)
    return s and r or nil
end

-- ===== PHYSICAL SKIP LIST =====
local heavyClasses = {
    Part = true, MeshPart = true, UnionOperation = true, WedgePart = true,
    CornerWedgePart = true, TrussPart = true, VehicleSeat = true, Seat = true,
    SpawnLocation = true, Decal = true, Texture = true, ParticleEmitter = true,
    Trail = true, Beam = true, Fire = true, Smoke = true, Sparkles = true,
    Humanoid = true, Animator = true, AnimationController = true, BodyMover = true,
    Sound = true, Attachment = true, Constraint = true
}

-- ===== SCRIPT EXTRACTOR =====
local function getScriptSource(script)
    -- Method 1: getscriptsource
    if getscriptsource then
        local s,r = pcall(getscriptsource, script)
        if s and r and #r > 0 then return r end
    end
    
    -- Method 2: Decompile
    if decompile then
        local s,r = pcall(decompile, script)
        if s and r and #r > 10 then return "-- [[ DECOMPILED ]] --\n" .. r end
    end
    
    -- Method 3: Bytecode info
    if getscriptbytecode then
        local s,r = pcall(getscriptbytecode, script)
        if s and r and #r > 0 then 
            return "-- [[ BYTECODE: " .. tostring(#r) .. " bytes ]] --\n-- Gunakan decompiler external"
        end
    end
    
    return "-- [[ SOURCE TIDAK TERSEDIA ]] --"
end

-- ===== KEY PROPERTIES =====
local function getProps(obj)
    local props = {}
    local class = obj.ClassName
    
    -- UI Properties
    if class:find("Gui") or class:find("Text") or class:find("Button") or class:find("Label") or class:find("Frame") or class:find("Image") then
        local pos = safeGet(obj, "Position")
        local size = safeGet(obj, "Size")
        local text = safeGet(obj, "Text")
        local vis = safeGet(obj, "Visible")
        
        if pos then table.insert(props, "Position = UDim2.new("..string.format("%.3f",pos.X.Scale)..", "..pos.X.Offset..", "..string.format("%.3f",pos.Y.Scale)..", "..pos.Y.Offset..")") end
        if size then table.insert(props, "Size = UDim2.new("..string.format("%.3f",size.X.Scale)..", "..size.X.Offset..", "..string.format("%.3f",size.Y.Scale)..", "..size.Y.Offset..")") end
        if text then table.insert(props, "Text = \""..tostring(text):gsub("\"", "\\\""):sub(1,100).."\"") end
        if vis ~= nil then table.insert(props, "Visible = "..tostring(vis)) end
        
        local bg = safeGet(obj, "BackgroundColor3")
        if bg then table.insert(props, "BackgroundColor3 = Color3.fromRGB("..math.floor(bg.R*255)..", "..math.floor(bg.G*255)..", "..math.floor(bg.B*255)..")") end
        
        local tc = safeGet(obj, "TextColor3")
        if tc then table.insert(props, "TextColor3 = Color3.fromRGB("..math.floor(tc.R*255)..", "..math.floor(tc.G*255)..", "..math.floor(tc.B*255)..")") end
    end
    
    -- Remote Properties
    if class == "RemoteEvent" or class == "RemoteFunction" then
        table.insert(props, "FullPath = \"" .. obj:GetFullName() .. "\"")
    end
    
    -- Value Objects
    local val = safeGet(obj, "Value")
    if val ~= nil then
        table.insert(props, "Value = " .. tostring(val))
    end
    
    return props
end

-- ===== MAIN SCANNER (with throttling) =====
local scanned = 0
local scriptsFound = 0
local remotesFound = 0
local uiFound = 0
local skipped = 0

local queue = {}
local queueIndex = 1

-- Init queue dengan services penting
local services = {
    game:GetService("ReplicatedStorage"),
    game:GetService("StarterGui"),
    game:GetService("StarterPack"),
    game:GetService("StarterPlayer"),
    game:GetService("Players"),
    game:GetService("Lighting"),
    game:GetService("SoundService"),
    game:GetService("Chat"),
}

if not CONFIG.SkipWorkspace then
    table.insert(services, game:GetService("Workspace"))
end

-- Masukkan root children ke queue
for _, svc in ipairs(services) do
    table.insert(queue, {obj = svc, depth = 0})
    for _, child in ipairs(svc:GetChildren()) do
        table.insert(queue, {obj = child, depth = 1})
    end
end

-- Process queue in batches
add("=" .. string.rep("=", 76))
add("  ANTI-FREEZE GAME EXTRACTOR")
add("  PlaceId: " .. game.PlaceId)
add("  Time: " .. os.date("%Y-%m-%d %H:%M:%S"))
add("  Mode: Lite (Skip Physical Parts)")
add("=" .. string.rep("=", 76))
add("")

local function processBatch()
    local batchCount = 0
    
    while queueIndex <= #queue and batchCount < CONFIG.ScanBatchSize do
        local item = queue[queueIndex]
        queueIndex = queueIndex + 1
        batchCount = batchCount + 1
        
        local obj = item.obj
        local depth = item.depth
        local class = obj.ClassName
        
        -- Skip physical/heavy objects
        if CONFIG.SkipPhysical and heavyClasses[class] then
            skipped = skipped + 1
            continue
        end
        
        -- Skip workspace descendants (too heavy)
        if CONFIG.SkipWorkspace and depth > 0 then
            local full = obj:GetFullName()
            if full:sub(1, 9) == "Workspace" then
                skipped = skipped + 1
                continue
            end
        end
        
        scanned = scanned + 1
        local indent = string.rep("  ", depth)
        
        -- Header
        add(string.format("%s[%s] %s", indent, class, obj.Name))
        
        -- Properties
        local props = getProps(obj)
        if #props > 0 then
            for _, p in ipairs(props) do
                add(indent .. "  > " .. p)
            end
        end
        
        -- Script Source
        if class == "Script" or class == "LocalScript" or class == "ModuleScript" then
            scriptsFound = scriptsFound + 1
            add(indent .. "  -- SOURCE --")
            local src = getScriptSource(obj)
            if #src > CONFIG.MaxScriptLength then
                src = src:sub(1, CONFIG.MaxScriptLength) .. "\n-- [TRUNCATED] --"
            end
            for line in src:gmatch("[^\r\n]+") do
                add(indent .. "  " .. line)
            end
            add(indent .. "  -- END --")
        end
        
        -- Remote
        if class == "RemoteEvent" or class == "RemoteFunction" then
            remotesFound = remotesFound + 1
        end
        
        -- UI Counter
        if class:find("Gui") or class:find("Text") or class:find("Button") or class:find("Label") or class:find("Frame") then
            uiFound = uiFound + 1
        end
        
        -- Queue children (tapi jangan terlalu dalam)
        if depth < 8 then
            for _, child in ipairs(obj:GetChildren()) do
                table.insert(queue, {obj = child, depth = depth + 1})
            end
        end
    end
    
    -- Progress print
    print(string.format("⏳ Progress: %d/%d scanned | Scripts: %d | Remotes: %d | Skipped: %d", 
        scanned, #queue, scriptsFound, remotesFound, skipped))
    
    -- Continue or finish
    if queueIndex <= #queue then
        task.wait(CONFIG.RestTime)
        processBatch()
    else
        finishExtract()
    end
end

-- ===== FINISH =====
function finishExtract()
    add("")
    add(string.rep("=", 76))
    add("  SELESAI!")
    add("  Scanned: " .. scanned)
    add("  Scripts: " .. scriptsFound)
    add("  Remotes: " .. remotesFound)
    add("  UI Elements: " .. uiFound)
    add("  Skipped (heavy): " .. skipped)
    add("  Time: " .. string.format("%.2f", tick() - startTime) .. "s")
    add(string.rep("=", 76))
    
    local final = table.concat(outputLines, "\n")
    local totalLines = #outputLines
    
    -- Clipboard (chunked if too big)
    if CONFIG.OutputToClipboard then
        if #final > 900000 then
            print("⚠️ Output terlalu besar untuk clipboard, simpan ke file saja.")
        else
            local ok = false
            if setclipboard then
                ok = pcall(setclipboard, final)
            elseif toclipboard then
                ok = pcall(toclipboard, final)
            end
            if ok then print("✅ Copied to clipboard!") end
        end
    end
    
    -- File
    if CONFIG.OutputToFile and writefile then
        pcall(function()
            writefile(CONFIG.FileName, final)
            print("✅ Saved to file: " .. CONFIG.FileName)
        end)
    end
    
    print("\n========== SUMMARY ==========")
    print("Total Lines: " .. totalLines)
    print("Scripts: " .. scriptsFound)
    print("Remotes: " .. remotesFound)
    print("UI: " .. uiFound)
    print("Skipped: " .. skipped)
    print("=============================")
end

-- ===== START =====
print("🚀 Mulai scan (Lite Mode)...")
print("⏳ Jeda antar batch biar HP nggak freeze...")
processBatch()
