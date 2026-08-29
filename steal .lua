-- [[ SUPER SAFE EXTRACTOR v4.0 ]]
-- Anti-crash, anti-freeze, dengan GUI fallback kalau clipboard gagal

print("🚀 Script dimulai...")

local startTime = tick()

-- ===== CEK EXECUTOR =====
print("🔍 Cek executor support...")

local hasSetClipboard = type(setclipboard) == "function"
local hasToClipboard = type(toclipboard) == "function"  
local hasWriteFile = type(writefile) == "function"
local hasDecompile = type(decompile) == "function"
local hasGetScriptSource = type(getscriptsource) == "function"
local hasGetBytecode = type(getscriptbytecode) == "function"

print("setclipboard: " .. tostring(hasSetClipboard))
print("writefile: " .. tostring(hasWriteFile))
print("decompile: " .. tostring(hasDecompile))

-- ===== CONFIG =====
local CONFIG = {
    MaxScriptLength = 50000,
    BatchSize = 30,
    RestTime = 0.08,
    SkipPhysical = true
}

-- ===== OUTPUT =====
local lines = {}
local function add(text)
    table.insert(lines, tostring(text))
end

-- ===== HEAVY CLASSES (yang bikin lag) =====
local heavy = {
    Part=true, MeshPart=true, UnionOperation=true, WedgePart=true,
    CornerWedgePart=true, TrussPart=true, VehicleSeat=true, Seat=true,
    SpawnLocation=true, Decal=true, Texture=true, ParticleEmitter=true,
    Trail=true, Beam=true, Fire=true, Smoke=true, Sparkles=true,
    Humanoid=true, Animator=true, AnimationController=true,
    Sound=true, Attachment=true
}

-- ===== SAFE GET =====
local function safe(obj, prop)
    local s,r = pcall(function() return obj[prop] end)
    if s then return r end
    return nil
end

-- ===== GET SCRIPT SOURCE =====
local function grabSource(scr)
    if hasGetScriptSource then
        local ok, src = pcall(getscriptsource, scr)
        if ok and src and #src > 0 then return src end
    end
    if hasDecompile then
        local ok, src = pcall(decompile, scr)
        if ok and src and #src > 10 then return "--[[DECOMPILED]]--\n" .. src end
    end
    if hasGetBytecode then
        local ok, bc = pcall(getscriptbytecode, scr)
        if ok and bc then return "--[[BYTECODE: " .. tostring(#bc) .. " bytes]]--" end
    end
    return "--[[SOURCE TIDAK TERSEDIA]]--"
end

-- ===== PROPERTIES =====
local function getProps(obj)
    local props = {}
    local class = obj.ClassName
    
    -- UI
    if class:find("Gui") or class:find("Text") or class:find("Button") or class:find("Label") or class:find("Frame") or class:find("Image") or class:find("Scrolling") then
        local pos = safe(obj, "Position")
        local size = safe(obj, "Size")
        local txt = safe(obj, "Text")
        local vis = safe(obj, "Visible")
        local bg = safe(obj, "BackgroundColor3")
        local tc = safe(obj, "TextColor3")
        
        if pos then table.insert(props, string.format('Position=UDim2.new(%.3f,%d,%.3f,%d)', pos.X.Scale,pos.X.Offset,pos.Y.Scale,pos.Y.Offset)) end
        if size then table.insert(props, string.format('Size=UDim2.new(%.3f,%d,%.3f,%d)', size.X.Scale,size.X.Offset,size.Y.Scale,size.Y.Offset)) end
        if txt then table.insert(props, 'Text="' .. tostring(txt):gsub('"','\\"'):sub(1,80) .. '"') end
        if vis ~= nil then table.insert(props, "Visible=" .. tostring(vis)) end
        if bg then table.insert(props, string.format("BackgroundColor3=Color3.fromRGB(%d,%d,%d)", bg.R*255, bg.G*255, bg.B*255)) end
        if tc then table.insert(props, string.format("TextColor3=Color3.fromRGB(%d,%d,%d)", tc.R*255, tc.G*255, tc.B*255)) end
    end
    
    -- Remote
    if class == "RemoteEvent" or class == "RemoteFunction" then
        table.insert(props, 'Path="' .. obj:GetFullName() .. '"')
    end
    
    -- Value
    local val = safe(obj, "Value")
    if val ~= nil then table.insert(props, "Value=" .. tostring(val)) end
    
    return props
end

-- ===== HEADER =====
add("========================================")
add("GAME EXTRACTOR - SUPER SAFE v4.0")
add("PlaceId: " .. tostring(game.PlaceId))
add("Game: " .. tostring(game.Name))
add("Time: " .. os.date("%Y-%m-%d %H:%M:%S"))
add("Executor: " .. (identifyexecutor and tostring(identifyexecutor()) or "Unknown"))
add("========================================")
add("")

-- ===== SCANNER =====
print("📁 Mulai scan...")

local scanned = 0
local scriptsFound = 0
local remotesFound = 0
local uiFound = 0
local skipped = 0

-- Queue system
local queue = {}
local function enqueue(obj, depth)
    if depth > 10 then return end
    table.insert(queue, {obj=obj, depth=depth})
end

-- Init services
local services = {
    game:GetService("ReplicatedStorage"),
    game:GetService("StarterGui"),
    game:GetService("StarterPack"),
    game:GetService("StarterPlayer"),
    game:GetService("Players"),
    game:GetService("Lighting"),
    game:GetService("SoundService"),
    game:GetService("Chat"),
    game:GetService("ReplicatedFirst")
}

for _, svc in ipairs(services) do
    enqueue(svc, 0)
    for _, c in ipairs(svc:GetChildren()) do
        enqueue(c, 1)
    end
end

-- Process
local idx = 1
while idx <= #queue do
    local batch = 0
    while idx <= #queue and batch < CONFIG.BatchSize do
        local item = queue[idx]
        idx = idx + 1
        batch = batch + 1
        
        local obj = item.obj
        local depth = item.depth
        local class = obj.ClassName
        
        -- SKIP PHYSICAL (pakai if, BUKAN continue!)
        local shouldSkip = false
        if CONFIG.SkipPhysical and heavy[class] then
            shouldSkip = true
            skipped = skipped + 1
        end
        
        if not shouldSkip then
            scanned = scanned + 1
            local indent = string.rep("  ", depth)
            
            add(indent .. "[" .. class .. "] " .. obj.Name)
            
            -- Properties
            local props = getProps(obj)
            for _, p in ipairs(props) do
                add(indent .. "  > " .. p)
            end
            
            -- Script Source
            if class == "Script" or class == "LocalScript" or class == "ModuleScript" then
                scriptsFound = scriptsFound + 1
                add(indent .. "  -- SOURCE START --")
                local src = grabSource(obj)
                if #src > CONFIG.MaxScriptLength then
                    src = src:sub(1, CONFIG.MaxScriptLength) .. "\n--[TRUNCATED]--"
                end
                for line in src:gmatch("[^\r\n]+") do
                    add(indent .. "  " .. line)
                end
                add(indent .. "  -- SOURCE END --")
            end
            
            -- Count
            if class == "RemoteEvent" or class == "RemoteFunction" then
                remotesFound = remotesFound + 1
            end
            if class:find("Gui") or class:find("Text") or class:find("Button") or class:find("Label") or class:find("Frame") then
                uiFound = uiFound + 1
            end
            
            -- Enqueue children
            local children = obj:GetChildren()
            for _, child in ipairs(children) do
                enqueue(child, depth + 1)
            end
        end
    end
    
    print(string.format("⏳ Progress: %d/%d | Scripts:%d | Remotes:%d | Skipped:%d", 
        idx, #queue, scriptsFound, remotesFound, skipped))
    
    if idx <= #queue then
        task.wait(CONFIG.RestTime)
    end
end

-- ===== FOOTER =====
add("")
add("========================================")
add("SELESAI!")
add("Scanned: " .. scanned)
add("Scripts: " .. scriptsFound)
add("Remotes: " .. remotesFound)
add("UI: " .. uiFound)
add("Skipped: " .. skipped)
add("Time: " .. string.format("%.2fs", tick()-startTime))
add("========================================")

local output = table.concat(lines, "\n")
local totalLines = #lines

print("\n✅ Scan selesai!")
print("Total baris: " .. totalLines)

-- ===== CLIPBOARD =====
local copied = false

if hasSetClipboard then
    local ok = pcall(setclipboard, output)
    if ok then 
        copied = true
        print("✅ Berhasil copy ke clipboard!")
    else
        print("❌ setclipboard error")
    end
elseif hasToClipboard then
    local ok = pcall(toclipboard, output)
    if ok then
        copied = true
        print("✅ Berhasil copy ke clipboard!")
    else
        print("❌ toclipboard error")
    end
else
    print("❌ Executor nggak support clipboard!")
end

-- ===== FILE =====
if hasWriteFile then
    local fname = "Extract_" .. game.PlaceId .. "_" .. os.time() .. ".txt"
    local ok = pcall(function() writefile(fname, output) end)
    if ok then
        print("✅ File tersimpan: " .. fname)
    else
        print("❌ Gagal writefile")
    end
end

-- ===== GUI FALLBACK (kalau clipboard gagal) =====
if not copied then
    print("⚠️ Clipboard gagal! Bikin GUI manual...")
    
    local plr = game:GetService("Players").LocalPlayer
    local pg = plr:WaitForChild("PlayerGui")
    
    -- Hapus GUI lama kalau ada
    local old = pg:FindFirstChild("ExtractorGUI")
    if old then old:Destroy() end
    
    local sg = Instance.new("ScreenGui")
    sg.Name = "ExtractorGUI"
    sg.ResetOnSpawn = false
    sg.Parent = pg
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 500, 0, 350)
    frame.Position = UDim2.new(0.5, -250, 0.5, -175)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    frame.BorderSizePixel = 0
    frame.Parent = sg
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Text = "📋 Extractor Output (Clipboard Gagal)"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.BackgroundTransparency = 1
    title.Parent = frame
    
    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, -20, 0, 25)
    info.Position = UDim2.new(0, 10, 0, 40)
    info.Text = "Scripts: " .. scriptsFound .. " | Remotes: " .. remotesFound .. " | UI: " .. uiFound .. " | Baris: " .. totalLines
    info.TextColor3 = Color3.fromRGB(200, 200, 200)
    info.TextSize = 14
    info.Font = Enum.Font.Gotham
    info.BackgroundTransparency = 1
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.Parent = frame
    
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -20, 0, 200)
    box.Position = UDim2.new(0, 10, 0, 70)
    box.Text = output
    box.TextColor3 = Color3.fromRGB(220, 220, 220)
    box.TextSize = 11
    box.Font = Enum.Font.Code
    box.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    box.ClearTextOnFocus = false
    box.MultiLine = true
    box.TextWrapped = false
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.TextYAlignment = Enum.TextYAlignment.Top
    box.Parent = frame
    
    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 6)
    boxCorner.Parent = box
    
    local btnCopy = Instance.new("TextButton")
    btnCopy.Size = UDim2.new(0, 150, 0, 35)
    btnCopy.Position = UDim2.new(0.5, -75, 1, -50)
    btnCopy.Text = "📋 Copy Semua"
    btnCopy.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnCopy.TextSize = 14
    btnCopy.Font = Enum.Font.GothamBold
    btnCopy.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    btnCopy.Parent = frame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btnCopy
    
    btnCopy.MouseButton1Click:Connect(function()
        if hasSetClipboard then
            pcall(setclipboard, box.Text)
            btnCopy.Text = "✅ Tersalin!"
            task.wait(1)
            btnCopy.Text = "📋 Copy Semua"
        else
            btnCopy.Text = "❌ Nggak Support"
            task.wait(1)
            btnCopy.Text = "📋 Copy Semua"
        end
    end)
    
    local btnClose = Instance.new("TextButton")
    btnClose.Size = UDim2.new(0, 30, 0, 30)
    btnClose.Position = UDim2.new(1, -35, 0, 5)
    btnClose.Text = "X"
    btnClose.TextColor3 = Color3.fromRGB(255, 100, 100)
    btnClose.TextSize = 16
    btnClose.Font = Enum.Font.GothamBold
    btnClose.BackgroundTransparency = 1
    btnClose.Parent = frame
    
    btnClose.MouseButton1Click:Connect(function()
        sg:Destroy()
    end)
    
    print("✅ GUI sudah muncul! Tekan 'Copy Semua' di layar.")
end

-- ===== PRINT PREVIEW =====
print("\n========== PREVIEW (50 baris pertama) ==========")
for i = 1, math.min(50, totalLines) do
    print(lines[i])
end
print("... dan " .. (totalLines - 50) .. " baris lagi ...")
print("=================================================")
