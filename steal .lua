-- [[ REMOTE + SCRIPT + UI EXTRACTOR v6 ]]
-- Output di-sort & dikelompokkan biar gampang dicari

local start = tick()
local all = game:GetDescendants()

local scripts = {}
local remotes = {}
local uis = {}
local modules = {}

-- Scan & kelompokkan
for _, obj in ipairs(all) do
    local class = obj.ClassName
    local path = obj:GetFullName()
    
    if class == "RemoteEvent" then
        table.insert(remotes, "[RemoteEvent] " .. path)
    elseif class == "RemoteFunction" then
        table.insert(remotes, "[RemoteFunction] " .. path)
    elseif class == "Script" then
        table.insert(scripts, "[Script] " .. path)
    elseif class == "LocalScript" then
        table.insert(scripts, "[LocalScript] " .. path)
    elseif class == "ModuleScript" then
        table.insert(modules, "[ModuleScript] " .. path)
    elseif class == "ScreenGui" or class == "BillboardGui" then
        table.insert(uis, "[" .. class .. "] " .. path)
    end
end

-- Bangun output terstruktur
local out = {}
table.insert(out, "========== REMOTE EVENTS & FUNCTIONS ==========")
table.insert(out, "Total: " .. #remotes)
table.insert(out, "")
for _, v in ipairs(remotes) do table.insert(out, v) end

table.insert(out, "")
table.insert(out, "========== SCRIPTS ==========")
table.insert(out, "Total: " .. #scripts)
table.insert(out, "")
for _, v in ipairs(scripts) do table.insert(out, v) end

table.insert(out, "")
table.insert(out, "========== MODULE SCRIPTS ==========")
table.insert(out, "Total: " .. #modules)
table.insert(out, "")
for _, v in ipairs(modules) do table.insert(out, v) end

table.insert(out, "")
table.insert(out, "========== UI (ScreenGui/Billboard) ==========")
table.insert(out, "Total: " .. #uis)
table.insert(out, "")
for _, v in ipairs(uis) do table.insert(out, v) end

-- Gabung
local final = table.concat(out, "\n")

-- Copy ke clipboard
local copied = false
if setclipboard then
    copied = pcall(setclipboard, final)
elseif toclipboard then
    copied = pcall(toclipboard, final)
end

-- Print hasil ke console (pasti muncul)
print("⚡ SELESAI! " .. string.format("%.2f", tick()-start) .. " detik")
print("📡 RemoteEvent/Function: " .. #remotes)
print("📜 Scripts: " .. #scripts)
print("📦 Modules: " .. #modules)
print("🖥️ UI: " .. #uis)

if copied then
    print("✅ SUDAH DI-COPY KE CLIPBOARD!")
else
    print("❌ Clipboard gagal")
end

-- Print semua remote langsung ke console (biar kamu yakin)
print("\n========== SEMUA REMOTE ==========")
for _, v in ipairs(remotes) do print(v) end
print("==================================")
