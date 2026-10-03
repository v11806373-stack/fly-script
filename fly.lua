-- fly
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local lp = Players.LocalPlayer

local flying = false
local speed = 60
local bodyVel, bodyGyro

local gui = Instance.new("ScreenGui")
gui.Name = "fly"
gui.ResetOnSpawn = false
gui.Parent = lp:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 120)
frame.Position = UDim2.new(0, 50, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 28)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.Text = "fly"
title.TextColor3 = Color3.fromRGB(0, 255, 120)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = frame

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 28, 0, 28)
minBtn.Position = UDim2.new(1, -32, 0, 0)
minBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
minBtn.Text = "-"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 18
minBtn.BorderSizePixel = 0
minBtn.Parent = frame

local flyBtn = Instance.new("TextButton")
flyBtn.Size = UDim2.new(0, 180, 0, 30)
flyBtn.Position = UDim2.new(0, 20, 0, 38)
flyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
flyBtn.Text = "fly: off"
flyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
flyBtn.Font = Enum.Font.GothamBold
flyBtn.TextSize = 14
flyBtn.BorderSizePixel = 0
flyBtn.Parent = frame

local sliderBg = Instance.new("Frame")
sliderBg.Size = UDim2.new(0, 180, 0, 12)
sliderBg.Position = UDim2.new(0, 20, 0, 80)
sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
sliderBg.BorderSizePixel = 0
sliderBg.Parent = frame

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(speed / 200, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(0, 255, 120)
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderBg

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0, 180, 0, 20)
speedLabel.Position = UDim2.new(0, 20, 0, 96)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "speed: " .. speed
speedLabel.TextColor3 = Color3.fromRGB(0, 255, 120)
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 12
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = frame

local function stopFly()
    flying = false
    flyBtn.Text = "fly: off"
    flyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    if bodyVel then bodyVel:Destroy() bodyVel = nil end
    if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
    local char = lp.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Velocity = Vector3.zero
            hrp.RotVelocity = Vector3.zero
        end
    end
end

local function startFly()
    flying = true
    flyBtn.Text = "fly: on"
    flyBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 60)
    local char = lp.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp then return end
    if hum then hum.PlatformStand = true end
    bodyVel = Instance.new("BodyVelocity")
    bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVel.Velocity = Vector3.zero
    bodyVel.Parent = hrp
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.P = 30000  -- резкий поворот
    bodyGyro.D = 500
    bodyGyro.Parent = hrp
end

flyBtn.MouseButton1Click:Connect(function()
    if flying then stopFly() else startFly() end
end)

RunService.RenderStepped:Connect(function()
    if not flying then return end
    local char = lp.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not bodyVel or not bodyGyro or not hum then return end

    -- летим в сторону джойстика
    local move = hum.MoveDirection
    if move.Magnitude > 0 then
        move = move.Unit * speed
    else
        move = Vector3.zero
    end
    bodyVel.Velocity = move

    -- поворот вслед за камерой, включая верх-вниз
    bodyGyro.CFrame = workspace.CurrentCamera.CFrame
end)

local dragging = false
sliderBg.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
UIS.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        local mouseX = input.Position.X
        local bgAbs = sliderBg.AbsolutePosition.X
        local bgSize = sliderBg.AbsoluteSize.X
        local rel = math.clamp((mouseX - bgAbs) / bgSize, 0, 1)
        speed = math.floor(rel * 200)
        sliderFill.Size = UDim2.new(rel, 0, 1, 0)
        speedLabel.Text = "speed: " .. speed
    end
end)

local minimized = false
local circle = Instance.new("TextButton")
circle.Size = UDim2.new(0, 50, 0, 50)
circle.Position = UDim2.new(0, 50, 0, 50)
circle.BackgroundColor3 = Color3.fromRGB(0, 255, 120)
circle.Text = "F"
circle.TextColor3 = Color3.fromRGB(0, 0, 0)
circle.Font = Enum.Font.GothamBold
circle.TextSize = 20
circle.Visible = false
circle.Active = true
circle.Draggable = true
circle.Parent = gui

local circleCorner = Instance.new("UICorner")
circleCorner.CornerRadius = UDim.new(1, 0)
circleCorner.Parent = circle

minBtn.MouseButton1Click:Connect(function()
    if not minimized then
        frame.Visible = false
        circle.Visible = true
        minimized = true
    else
        frame.Visible = true
        circle.Visible = false
        minimized = false
    end
end)

circle.MouseButton1Click:Connect(function()
    frame.Visible = true
    circle.Visible = false
    minimized = false
end)
