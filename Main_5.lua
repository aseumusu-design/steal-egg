local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Setup Notifikasi
local message = Instance.new("Message", workspace)
message.Text = "FE Script Loaded"
task.delay(3, function() message:Destroy() end)

local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local root = char:WaitForChild("HumanoidRootPart")

local torsoName = (hum.RigType == Enum.HumanoidRigType.R15) and "UpperTorso" or "Torso"

-- Setup Part Dummy
local prt = Instance.new("Model", workspace)
local z1 = Instance.new("Part", prt)
z1.Name = "Torso"
z1.CanCollide = false
z1.Anchored = true

local z2 = Instance.new("Part", prt)
z2.Name = "Head"
z2.CanCollide = false
z2.Anchored = true

local z3 = Instance.new("Humanoid", prt)
z3.Name = "Humanoid"

z1.Position = Vector3.new(0, 9999, 0)
z2.Position = Vector3.new(0, 9991, 0)

LocalPlayer.Character = prt
task.wait(5)
LocalPlayer.Character = char
task.wait(1)

RunService.Stepped:Connect(function()
    if char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CanCollide = false
    end
end)

hum.HipHeight = 5
workspace.CurrentCamera.CameraSubject = root

-- Setup Limb Position / Torque
for _, v in pairs(char:GetChildren()) do
    if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
        local bp = Instance.new("BodyPosition", v)
        bp.MaxForce = Vector3.new(999999, 999999, 999999)
        bp.D = 300
        
        local bg = Instance.new("BodyGyro", v)
        bg.MaxTorque = Vector3.new(999999, 999999, 999999)

        task.spawn(function()
            while task.wait() do
                if bp and root then
                    bp.Position = root.Position + Vector3.new(0, 1.8 - 0.3, 0)
                end
            end
        end)
    end
end

-- Variables Fly
local flying = false
local speed = 0
local maxspeed = 120
local ctrl = {f = 0, b = 0, l = 0, r = 0}
local lastctrl = {f = 0, b = 0, l = 0, r = 0}

local bg, bv

local function startFly()
    local torso = char:FindFirstChild(torsoName) or root
    
    bg = Instance.new("BodyGyro", torso)
    bg.P = 9e4
    bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.cframe = torso.CFrame
    
    bv = Instance.new("BodyVelocity", torso)
    bv.velocity = Vector3.new(0, 0.1, 0)
    bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
    
    task.spawn(function()
        repeat task.wait()
            if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
                speed = math.min(speed + 0.2, maxspeed)
            elseif speed > 0 then
                speed = math.max(speed - 1, 0)
            end
            
            if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
                bv.velocity = ((workspace.CurrentCamera.CFrame.LookVector * (ctrl.f + ctrl.b)) + 
                              ((workspace.CurrentCamera.CFrame * CFrame.new(ctrl.l + ctrl.r, (ctrl.f + ctrl.b) * 0.2, 0).p) - 
                               workspace.CurrentCamera.CFrame.p)) * speed
                lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
            elseif speed ~= 0 then
                bv.velocity = ((workspace.CurrentCamera.CFrame.LookVector * (lastctrl.f + lastctrl.b)) + 
                              ((workspace.CurrentCamera.CFrame * CFrame.new(lastctrl.l + lastctrl.r, (lastctrl.f + lastctrl.b) * 0.2, 0).p) - 
                               workspace.CurrentCamera.CFrame.p)) * speed
            else
                bv.velocity = Vector3.new(0, 0.1, 0)
            end
            bg.cframe = workspace.CurrentCamera.CFrame
        until not flying
        
        ctrl = {f = 0, b = 0, l = 0, r = 0}
        lastctrl = {f = 0, b = 0, l = 0, r = 0}
        speed = 0
        if bg then bg:Destroy() end
        if bv then bv:Destroy() end
    end)
end

local function toggleFly()
    flying = not flying
    if flying then
        startFly()
    end
end

-- ====================
-- GUI ON / OFF BUTTON
-- ====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlyGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleFly"
toggleBtn.Size = UDim2.new(0, 110, 0, 45)
toggleBtn.Position = UDim2.new(0.8, 0, 0.2, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
toggleBtn.Text = "FLY: OFF"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 16
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = toggleBtn

toggleBtn.MouseButton1Click:Connect(function()
    toggleFly()
    if flying then
        toggleBtn.Text = "FLY: ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    else
        toggleBtn.Text = "FLY: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    end
end)

-- Kontrol Keyboard (PC)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.E then
        toggleBtn.MouseButton1Click:Fire()
    elseif input.KeyCode == Enum.KeyCode.W then ctrl.f = 1
    elseif input.KeyCode == Enum.KeyCode.S then ctrl.b = -1
    elseif input.KeyCode == Enum.KeyCode.A then ctrl.l = -1
    elseif input.KeyCode == Enum.KeyCode.D then ctrl.r = 1
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then ctrl.f = 0
    elseif input.KeyCode == Enum.KeyCode.S then ctrl.b = 0
    elseif input.KeyCode == Enum.KeyCode.A then ctrl.l = 0
    elseif input.KeyCode == Enum.KeyCode.D then ctrl.r = 0
    end
end)
