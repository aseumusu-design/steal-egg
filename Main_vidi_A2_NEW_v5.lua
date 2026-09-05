local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local anim = hum:FindFirstChildOfClass("Animator") or hum:WaitForChild("Animator")
local pack = plr:FindFirstChild("Backpack") or plr:WaitForChild("Backpack")

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

Notify("Script Made By Sa1", "My discord is: skondoooo92", 20)

local animation = Instance.new("Animation")
animation.Name = "aaa"
animation.Parent = workspace
animation.AnimationId = getmodel() == "R15" and "rbxassetid://908251653" or "rbxassetid://772842024"

local tool = Instance.new("Tool")
tool.Name = "Jerk"
tool.RequiresHandle = false
tool.Parent = pack

local doing = false
local animtrack = nil

local function stopAnimation()
    doing = false
    if animtrack then
        animtrack:Stop()
        animtrack:Destroy()
        animtrack = nil
    end
end

-- Toggle ON/OFF saat tool di-klik/dipakai
tool.Activated:Connect(function()
    if doing then
        stopAnimation()
    else
        doing = true
        if not animtrack then
            animtrack = anim:LoadAnimation(animation)
        end
        
        animtrack:Play()
        animtrack:AdjustSpeed(0.7)
        animtrack.TimePosition = 0.5

        task.spawn(function()
            while doing and animtrack do
                task.wait(0.1)
                if animtrack and animtrack.TimePosition >= 0.7 then
                    animtrack.TimePosition = 0.5
                end
            end
        end)
    end
end)

-- Otomatis OFF kalau tool dilepas atau karakter mati
tool.Unequipped:Connect(stopAnimation)
hum.Died:Connect(stopAnimation)
