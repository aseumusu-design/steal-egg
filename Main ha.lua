local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local anim = hum:FindFirstChildOfClass("Animator") or hum:WaitForChild("Animator")

if workspace:FindFirstChild("aaa") then
    workspace:FindFirstChild("aaa"):Destroy()
end

local function getmodel()
    return hum.RigType == Enum.HumanoidRigType.R15 and "R15" or "R6"
end

local function Notify(Title, Text, Duration)
    StarterGui:SetCore('SendNotification', {
        Title = Title,
        Text = Text or '',
        Duration = Duration
    })
end

Notify("Script Loaded", "Animasi Jerk Toggle ON/OFF Siap Dipakai!", 5)

-- Setup Animation
local animation = Instance.new("Animation")
animation.Name = "aaa"
animation.Parent = workspace
animation.AnimationId = getmodel() == "R15" and "rbxassetid://908251653" or "rbxassetid://772842024"

local isRunning = false
local animtrack = nil
local loopTask = nil

-- Fungsi Stop/OFF
local function stopJerk()
    isRunning = false
    if loopTask then
        task.cancel(loopTask)
        loopTask = nil
    end
    if animtrack then
        animtrack:Stop()
        animtrack:Destroy()
        animtrack = nil
    end
end

-- Fungsi Start/ON
local function startJerk()
    stopJerk()
    isRunning = true

    if not animtrack then
        animtrack = anim:LoadAnimation(animation)
    end

    animtrack:Play()
    animtrack:AdjustSpeed(0.8)

    -- Loop pergerakan tangan gesek ke bawah-atas
    loopTask = task.spawn(function()
        while isRunning and animtrack do
            animtrack.TimePosition = 0.5
            task.wait(0.12)
            if animtrack then
                animtrack.TimePosition = 0.7
            end
            task.wait(0.12)
        end
    end)
end

-- Toggle ON/OFF Function
local function toggleJerk()
    if isRunning then
        stopJerk()
    else
        startJerk()
    end
end

-- =========================================
-- GUI TOMBOL ON / OFF DI LAYAR (MOBILE & PC)
-- =========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "JerkGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = plr:WaitForChild("PlayerGui")

local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleBtn"
toggleBtn.Size = UDim2.new(0, 120, 0, 45)
toggleBtn.Position = UDim2.new(0.8, 0, 0.3, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
toggleBtn.Text = "JERK: OFF"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 16
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = toggleBtn

toggleBtn.MouseButton1Click:Connect(function()
    toggleJerk()
    if isRunning then
        toggleBtn.Text = "JERK: ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    else
        toggleBtn.Text = "JERK: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    end
end)

-- Otomatis OFF kalau karakter mati
hum.Died:Connect(function()
    stopJerk()
    toggleBtn.Text = "JERK: OFF"
    toggleBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
end)
