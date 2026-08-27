-- stakanew's BHop Script + Fly + FOV + Instant Strafe (Full Sidebar)
-- Защита от повторной загрузки
if shared.__stakanew_bhop_loaded then
    return
end
shared.__stakanew_bhop_loaded = true

local stakanew_FirstPerson = false
local stakanew_NoAnimations = true
local stakanew_MaxSpeed = 999999
local stakanew_GroundSpeed = 20
local stakanew_AirSpeed = 5
local stakanew_GroundAccel = 50
local stakanew_AirAccel = 800
local stakanew_Friction = 5
local stakanew_AirControl = 0
local stakanew_JumpPower = 50
local stakanew_Gravity = 196.2

local stakanew_BHopEnabled = true
local stakanew_JumpCircleEnabled = false
local stakanew_JumpCloneEnabled = false
local stakanew_TrailEnabled = false
local stakanew_CloneColor = Color3.fromRGB(255, 0, 255)
local stakanew_CircleColor = Color3.fromRGB(255, 255, 255)
local stakanew_TrailColor = Color3.fromRGB(0, 255, 255)
local stakanew_CloneTransparency = 0
local stakanew_CloneDuration = 1
local stakanew_TrailSize = 0.5
local stakanew_TrailDuration = 0.3
local stakanew_TrailInterval = 0.02
local stakanew_CircleSize = 10
local stakanew_CircleDuration = 0.5
local stakanew_LastTrailPos = nil

local stakanew_HatEnabled = false
local stakanew_HatRadius = 2
local stakanew_HatHeight = 4
local stakanew_HatTransparency = 0.3
local stakanew_HatOffsetY = 3
local stakanew_HatSpinSpeed = 0.8
local stakanew_HatColor = Color3.fromRGB(255, 200, 50)

local stakanew_RGBClone = false
local stakanew_RGBCircle = false
local stakanew_RGBTrail = false
local stakanew_RGBHat = false

local stakanew_SpinbotEnabled = false
local stakanew_SpinbotSpeed = 5
local stakanew_Language = "RU"

local stakanew_FlyEnabled = false
local stakanew_FlySpeed = 45
local stakanew_FlyMaxVert = 70
local stakanew_FlyAccel = 25
local stakanew_FlyVertSpeed = 0
local stakanew_FlyDamp = 0.9
local stakanew_FlyNoise = 5
local stakanew_FlyPacketLoss = 0.02

local stakanew_FOVEnabled = false
local stakanew_FOV = 70

local stakanew_InstantStrafe = false
local stakanew_InstantStrafePower = 1

local stakanew_Players = game:GetService("Players")
local stakanew_RunService = game:GetService("RunService")
local stakanew_UIS = game:GetService("UserInputService")
local stakanew_TweenService = game:GetService("TweenService")

local stakanew_Player = stakanew_Players.LocalPlayer
local stakanew_Camera = workspace.CurrentCamera
local stakanew_Character, stakanew_Humanoid, stakanew_RootPart
local stakanew_Velocity = Vector3.new(0, 0, 0)
local stakanew_IsGrounded = false
local stakanew_JumpHeld, stakanew_WishJump = false, false
local stakanew_MoveForward, stakanew_MoveRight = 0, 0
local stakanew_SettingsOpen = false
local stakanew_JumpCooldown = 0
local stakanew_LastTrailTime = 0
local stakanew_WasGrounded = true
local stakanew_LastJumpTime = 0

-- Функции шляпы (ConeHandleAdornment)
local stakanew_HatCone = nil

function stakanew_CreateHat()
    stakanew_RemoveHat()
    if not stakanew_Character or not stakanew_Character:FindFirstChild("Head") then return end
    local head = stakanew_Character:FindFirstChild("Head")

    stakanew_HatCone = Instance.new("ConeHandleAdornment")
    stakanew_HatCone.Name = "ConeHat"
    stakanew_HatCone.Radius = stakanew_HatRadius
    stakanew_HatCone.Height = stakanew_HatHeight
    stakanew_HatCone.Color3 = stakanew_HatColor
    stakanew_HatCone.Transparency = stakanew_HatTransparency
    stakanew_HatCone.AlwaysOnTop = true
    stakanew_HatCone.ZIndex = 10
    stakanew_HatCone.Adornee = head
    stakanew_HatCone.Parent = head

    stakanew_HatCone.CFrame = CFrame.new(0, stakanew_HatOffsetY, 0) * CFrame.Angles(math.rad(90), 0, 0)

    task.spawn(function()
        local angle = 0
        while stakanew_HatCone and stakanew_HatCone.Parent do
            if stakanew_RGBHat then
                stakanew_HatCone.Color3 = stakanew_GetRainbowColor()
            end
            angle = angle + stakanew_HatSpinSpeed * 0.1
            stakanew_HatCone.CFrame = CFrame.new(0, stakanew_HatOffsetY, 0) * CFrame.Angles(math.rad(90), 0, angle)
            task.wait()
        end
    end)
end

function stakanew_RemoveHat()
    if stakanew_HatCone then
        stakanew_HatCone:Destroy()
        stakanew_HatCone = nil
    end
end

local stakanew_ConfigButtons = {}
local groundSpeedSlider, airSpeedSlider, groundAccelSlider, airAccelSlider
local jumpPowerSlider, gravitySlider, circleSizeSlider, circleDurationSlider
local cloneTransparencySlider, cloneDurationSlider, trailSizeSlider, trailDurationSlider
local spinSpeedSlider
local hatRadiusSlider, hatHeightSlider, hatTransparencySlider, hatOffsetSlider, hatSpinSpeedSlider
local flySpeedSlider, flyMaxVertSlider, flyAccelSlider
local fovSlider, instantStrafePowerSlider

-- HSV
local function stakanew_HSVtoRGB(h, s, v)
    local c = v * s
    local x = c * (1 - math.abs((h / 60) % 2 - 1))
    local m = v - c
    local r, g, b
    if h < 60 then r, g, b = c, x, 0
    elseif h < 120 then r, g, b = x, c, 0
    elseif h < 180 then r, g, b = 0, c, x
    elseif h < 240 then r, g, b = 0, x, c
    elseif h < 300 then r, g, b = x, 0, c
    else r, g, b = c, 0, x end
    return Color3.new(r + m, g + m, b + m)
end

local function stakanew_GetRainbowColor()
    local hue = (tick() * 120) % 360
    return stakanew_HSVtoRGB(hue, 1, 1)
end

-- GUI
local stakanew_GUI = Instance.new("ScreenGui")
stakanew_GUI.Name = "stakanew_GUI"
stakanew_GUI.ResetOnSpawn = false
stakanew_GUI.Parent = stakanew_Player:WaitForChild("PlayerGui")

local stakanew_Watermark = Instance.new("TextLabel")
stakanew_Watermark.Size = UDim2.new(0, 150, 0, 20)
stakanew_Watermark.Position = UDim2.new(1, -160, 1, -30)
stakanew_Watermark.BackgroundTransparency = 1
stakanew_Watermark.TextColor3 = Color3.fromRGB(255, 255, 255)
stakanew_Watermark.Text = "by stakanew"
stakanew_Watermark.Font = Enum.Font.SourceSans
stakanew_Watermark.TextSize = 14
stakanew_Watermark.TextStrokeTransparency = 0.5
stakanew_Watermark.TextTransparency = 0.3
stakanew_Watermark.Parent = stakanew_GUI

local stakanew_SpeedCounter = Instance.new("TextLabel")
stakanew_SpeedCounter.Size = UDim2.new(0, 200, 0, 40)
stakanew_SpeedCounter.Position = UDim2.new(0.5, -100, 0.55, 0)
stakanew_SpeedCounter.BackgroundTransparency = 1
stakanew_SpeedCounter.TextColor3 = Color3.fromRGB(255, 255, 255)
stakanew_SpeedCounter.Text = "0.0"
stakanew_SpeedCounter.Font = Enum.Font.SourceSansBold
stakanew_SpeedCounter.TextSize = 20
stakanew_SpeedCounter.TextStrokeTransparency = 0
stakanew_SpeedCounter.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
stakanew_SpeedCounter.Parent = stakanew_GUI

local stakanew_SettingsButton = Instance.new("TextButton")
stakanew_SettingsButton.Size = UDim2.new(0, 50, 0, 50)
stakanew_SettingsButton.Position = UDim2.new(0.5, -25, 0.5, -25)
stakanew_SettingsButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
stakanew_SettingsButton.BackgroundTransparency = 1
stakanew_SettingsButton.Text = "S"
stakanew_SettingsButton.Font = Enum.Font.SourceSansBold
stakanew_SettingsButton.TextSize = 24
stakanew_SettingsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
stakanew_SettingsButton.TextTransparency = 1
stakanew_SettingsButton.Parent = stakanew_GUI

local stakanew_Corner = Instance.new("UICorner")
stakanew_Corner.CornerRadius = UDim.new(1, 0)
stakanew_Corner.Parent = stakanew_SettingsButton

task.spawn(function()
    task.wait(0.5)
    local fadeIn = TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local buttonFade = stakanew_TweenService:Create(stakanew_SettingsButton, fadeIn, {
        BackgroundTransparency = 0.3,
        TextTransparency = 0
    })
    buttonFade:Play()
    task.wait(0.8)
    local moveLeft = TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local buttonMove = stakanew_TweenService:Create(stakanew_SettingsButton, moveLeft, {
        Position = UDim2.new(0, 20, 0.5, -25)
    })
    buttonMove:Play()
end)

-- Панель настроек
local stakanew_SettingsPanel = Instance.new("Frame")
stakanew_SettingsPanel.Size = UDim2.new(0, 400, 0, 500)
stakanew_SettingsPanel.Position = UDim2.new(0, 80, 0.5, -250)
stakanew_SettingsPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
stakanew_SettingsPanel.Visible = false
stakanew_SettingsPanel.Parent = stakanew_GUI

local stakanew_PanelCorner = Instance.new("UICorner")
stakanew_PanelCorner.CornerRadius = UDim.new(0, 10)
stakanew_PanelCorner.Parent = stakanew_SettingsPanel

local stakanew_PanelTitle = Instance.new("TextLabel")
stakanew_PanelTitle.Size = UDim2.new(1, -50, 0, 40)
stakanew_PanelTitle.Position = UDim2.new(0, 10, 0, 0)
stakanew_PanelTitle.BackgroundTransparency = 1
stakanew_PanelTitle.Text = "Настройки"
stakanew_PanelTitle.Font = Enum.Font.SourceSansBold
stakanew_PanelTitle.TextSize = 20
stakanew_PanelTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
stakanew_PanelTitle.Parent = stakanew_SettingsPanel

local stakanew_CollapseButton = Instance.new("TextButton")
stakanew_CollapseButton.Size = UDim2.new(0, 30, 0, 30)
stakanew_CollapseButton.Position = UDim2.new(1, -35, 0, 5)
stakanew_CollapseButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
stakanew_CollapseButton.Text = "×"
stakanew_CollapseButton.Font = Enum.Font.SourceSansBold
stakanew_CollapseButton.TextSize = 18
stakanew_CollapseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
stakanew_CollapseButton.Parent = stakanew_SettingsPanel

local stakanew_CollapseCorner = Instance.new("UICorner")
stakanew_CollapseCorner.CornerRadius = UDim.new(0, 5)
stakanew_CollapseCorner.Parent = stakanew_CollapseButton

local stakanew_SettingsWatermark = Instance.new("TextLabel")
stakanew_SettingsWatermark.Size = UDim2.new(0, 100, 0, 15)
stakanew_SettingsWatermark.Position = UDim2.new(1, -105, 1, -20)
stakanew_SettingsWatermark.BackgroundTransparency = 1
stakanew_SettingsWatermark.Text = "by stakanew"
stakanew_SettingsWatermark.Font = Enum.Font.SourceSans
stakanew_SettingsWatermark.TextSize = 10
stakanew_SettingsWatermark.TextColor3 = Color3.fromRGB(150, 150, 150)
stakanew_SettingsWatermark.TextTransparency = 0.5
stakanew_SettingsWatermark.Parent = stakanew_SettingsPanel

-- Боковая панель вкладок
local stakanew_TabButtonsFrame = Instance.new("Frame")
stakanew_TabButtonsFrame.Size = UDim2.new(0, 100, 1, -90)
stakanew_TabButtonsFrame.Position = UDim2.new(0, 10, 0, 80)
stakanew_TabButtonsFrame.BackgroundTransparency = 1
stakanew_TabButtonsFrame.Parent = stakanew_SettingsPanel

local stakanew_TabButtons = {}
local stakanew_TabContainers = {}

local function stakanew_CreateTab(name, yPos)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 80, 0, 30)
    button.Position = UDim2.new(0, 10, 0, yPos)
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.Text = name
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 14
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Parent = stakanew_TabButtonsFrame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = button
    return button
end

stakanew_TabButtons["BHop"] = stakanew_CreateTab("BHop", 0)
stakanew_TabButtons["Visuals"] = stakanew_CreateTab("Visuals", 40)
stakanew_TabButtons["Fly"] = stakanew_CreateTab("Fly", 80)
stakanew_TabButtons["Screen"] = stakanew_CreateTab("Screen", 120)
stakanew_TabButtons["Config"] = stakanew_CreateTab("Config", 160)
stakanew_TabButtons["Settings"] = stakanew_CreateTab("Settings", 200)

for _, tabName in ipairs({"BHop", "Visuals", "Fly", "Screen", "Config", "Settings"}) do
    local container = Instance.new("ScrollingFrame")
    container.Size = UDim2.new(1, -130, 1, -90)
    container.Position = UDim2.new(0, 120, 0, 80)
    container.BackgroundTransparency = 1
    container.Visible = (tabName == "BHop")
    container.Parent = stakanew_SettingsPanel
    container.CanvasSize = UDim2.new(0, 0, 0, 600)
    container.ScrollBarThickness = 5
    container.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    stakanew_TabContainers[tabName] = container
end

local function stakanew_SwitchTab(tabName)
    for name, container in pairs(stakanew_TabContainers) do
        container.Visible = (name == tabName)
    end
    for name, button in pairs(stakanew_TabButtons) do
        if name == tabName then
            button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        else
            button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        end
    end
    if tabName == "Config" then
        stakanew_RefreshConfigList()
    end
end

for name, button in pairs(stakanew_TabButtons) do
    button.MouseButton1Click:Connect(function()
        stakanew_SwitchTab(name)
    end)
end

-- Функции создания элементов
local function stakanew_CreateToggle(name, default, yPos, parent)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 180, 0, 20)
    label.Position = UDim2.new(0, 10, 0, yPos)
    label.BackgroundTransparency = 1
    label.Text = name
    label.Font = Enum.Font.SourceSans
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Parent = parent

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 50, 0, 25)
    toggle.Position = UDim2.new(1, -60, 0, yPos)
    toggle.BackgroundColor3 = default and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    toggle.Text = default and "ВКЛ" or "ВЫКЛ"
    toggle.Font = Enum.Font.SourceSansBold
    toggle.TextSize = 12
    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = toggle
    return toggle, label
end

local function stakanew_CreateSlider(name, value, min, max, yPos, parent)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 10, 0, yPos)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. tostring(value)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Parent = parent

    local slider = Instance.new("TextBox")
    slider.Size = UDim2.new(1, -20, 0, 30)
    slider.Position = UDim2.new(0, 10, 0, yPos + 25)
    slider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    slider.Text = tostring(value)
    slider.Font = Enum.Font.SourceSans
    slider.TextSize = 14
    slider.TextColor3 = Color3.fromRGB(255, 255, 255)
    slider.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = slider
    return slider, label
end

local function stakanew_CreateColorPicker(name, yPos, parent)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 180, 0, 20)
    label.Position = UDim2.new(0, 10, 0, yPos)
    label.BackgroundTransparency = 1
    label.Text = name
    label.Font = Enum.Font.SourceSans
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Parent = parent

    local colors = {
        {"Красный", Color3.fromRGB(255, 0, 0)},
        {"Зеленый", Color3.fromRGB(0, 255, 0)},
        {"Синий", Color3.fromRGB(0, 0, 255)},
        {"Желтый", Color3.fromRGB(255, 255, 0)},
        {"Розовый", Color3.fromRGB(255, 0, 255)},
        {"Белый", Color3.fromRGB(255, 255, 255)},
        {"Черный", Color3.fromRGB(0, 0, 0)},
        {"Оранж", Color3.fromRGB(255, 165, 0)},
    }

    for i, colorData in ipairs(colors) do
        local colorButton = Instance.new("TextButton")
        colorButton.Size = UDim2.new(0, 25, 0, 25)
        colorButton.Position = UDim2.new(0, 10 + ((i - 1) % 7) * 30, 0, yPos + 25 + math.floor((i - 1) / 7) * 30)
        colorButton.BackgroundColor3 = colorData[2]
        colorButton.Text = ""
        colorButton.Parent = parent
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 5)
        corner.Parent = colorButton
        colorButton.MouseButton1Click:Connect(function()
            if name == "Цвет копии" then
                stakanew_CloneColor = colorData[2]
                stakanew_RGBClone = false
            elseif name == "Цвет круга" then
                stakanew_CircleColor = colorData[2]
                stakanew_RGBCircle = false
            elseif name == "Цвет следа" then
                stakanew_TrailColor = colorData[2]
                stakanew_RGBTrail = false
            elseif name == "Цвет шляпы" then
                stakanew_HatColor = colorData[2]
                stakanew_RGBHat = false
                if stakanew_HatEnabled then
                    stakanew_CreateHat()
                end
            end
        end)
    end
end

-- ==================== BHop вкладка ====================
local bhopContainer = stakanew_TabContainers["BHop"]
bhopContainer.CanvasSize = UDim2.new(0, 0, 0, 800)

local stakanew_BHopToggle, stakanew_BHopLabel = stakanew_CreateToggle("BHop", stakanew_BHopEnabled, 10, bhopContainer)
local stakanew_NoAnimationsToggle, stakanew_NoAnimationsLabel = stakanew_CreateToggle("Отключить анимации", stakanew_NoAnimations, 40, bhopContainer)
local stakanew_SpinbotToggle, stakanew_SpinbotLabel = stakanew_CreateToggle("Spinbot", stakanew_SpinbotEnabled, 70, bhopContainer)
local stakanew_InstantStrafeToggle, stakanew_InstantStrafeLabel = stakanew_CreateToggle("Мгновенный стрейф", stakanew_InstantStrafe, 100, bhopContainer)
instantStrafePowerSlider, _ = stakanew_CreateSlider("Сила стрейфа", stakanew_InstantStrafePower, 0, 1, 130, bhopContainer)

-- Функция применения состояния движения
local function stakanew_ApplyMovementState()
    if not stakanew_Humanoid then return end
    if stakanew_FlyEnabled then
        stakanew_Humanoid.WalkSpeed = 0
        stakanew_Humanoid.JumpPower = 0
        stakanew_Humanoid.JumpHeight = 0
        stakanew_Humanoid.AutoRotate = false
        stakanew_Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
    elseif stakanew_BHopEnabled then
        stakanew_Humanoid.WalkSpeed = 0
        stakanew_Humanoid.JumpPower = 0
        stakanew_Humanoid.JumpHeight = 0
        stakanew_Humanoid.AutoRotate = false
        stakanew_Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
    else
        stakanew_Humanoid.WalkSpeed = 20
        stakanew_Humanoid.JumpPower = 50
        stakanew_Humanoid.JumpHeight = 7.2
        stakanew_Humanoid.AutoRotate = true
        stakanew_Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
    end
end

stakanew_BHopToggle.MouseButton1Click:Connect(function()
    stakanew_BHopEnabled = not stakanew_BHopEnabled
    if stakanew_BHopEnabled then
        stakanew_FlyEnabled = false
        stakanew_FlyVertSpeed = 0
        if stakanew_RootPart then
            stakanew_RootPart.AssemblyLinearVelocity = Vector3.zero
        end
    end
    stakanew_ApplyMovementState()
    stakanew_UpdateGUI()
end)

stakanew_InstantStrafeToggle.MouseButton1Click:Connect(function()
    stakanew_InstantStrafe = not stakanew_InstantStrafe
    stakanew_InstantStrafeToggle.Text = stakanew_InstantStrafe and "ВКЛ" or "ВЫКЛ"
    stakanew_InstantStrafeToggle.BackgroundColor3 = stakanew_InstantStrafe and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
end)

instantStrafePowerSlider.FocusLost:Connect(function()
    local v = tonumber(instantStrafePowerSlider.Text)
    if v then
        stakanew_InstantStrafePower = math.clamp(v, 0, 1)
        instantStrafePowerSlider.Text = tostring(stakanew_InstantStrafePower)
    end
end)

-- Функции анимаций
local stakanew_OriginalAnimate = nil
local function stakanew_DisableAnimations(char)
    if not stakanew_NoAnimations then return end
    task.spawn(function()
        local animate = char:FindFirstChild("Animate")
        if not animate then
            animate = char:WaitForChild("Animate", 5)
        end
        if animate then
            stakanew_OriginalAnimate = animate
            animate.Disabled = true
        end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
                track:Stop(0)
            end
        end
    end)
end

local function stakanew_RestoreAnimations(char)
    if stakanew_NoAnimations then return end
    if not char then return end
    if stakanew_OriginalAnimate then
        stakanew_OriginalAnimate.Disabled = false
        stakanew_OriginalAnimate = nil
    end
end

stakanew_NoAnimationsToggle.MouseButton1Click:Connect(function()
    stakanew_NoAnimations = not stakanew_NoAnimations
    stakanew_NoAnimationsToggle.Text = stakanew_NoAnimations and "ВКЛ" or "ВЫКЛ"
    stakanew_NoAnimationsToggle.BackgroundColor3 = stakanew_NoAnimations and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    if stakanew_Character then
        if stakanew_NoAnimations then
            stakanew_DisableAnimations(stakanew_Character)
        else
            stakanew_RestoreAnimations(stakanew_Character)
        end
    end
end)

stakanew_SpinbotToggle.MouseButton1Click:Connect(function()
    stakanew_SpinbotEnabled = not stakanew_SpinbotEnabled
    stakanew_SpinbotToggle.Text = stakanew_SpinbotEnabled and "ВКЛ" or "ВЫКЛ"
    stakanew_SpinbotToggle.BackgroundColor3 = stakanew_SpinbotEnabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
end)

-- BHop настройки
local bhopSettings = {
    {name = "Скорость на земле", var = "GroundSpeed", min = 10, max = 50},
    {name = "Скорость в воздухе", var = "AirSpeed", min = 1, max = 20},
    {name = "Ускорение на земле", var = "GroundAccel", min = 10, max = 100},
    {name = "Ускорение в воздухе", var = "AirAccel", min = 100, max = 2000},
    {name = "Сила прыжка", var = "JumpPower", min = 10, max = 200},
    {name = "Гравитация", var = "Gravity", min = 50, max = 400},
}

local yPosStart = 185
for i, setting in ipairs(bhopSettings) do
    local yPos = yPosStart + (i - 1) * 55
    local currentValue
    if setting.var == "GroundSpeed" then currentValue = stakanew_GroundSpeed
    elseif setting.var == "AirSpeed" then currentValue = stakanew_AirSpeed
    elseif setting.var == "GroundAccel" then currentValue = stakanew_GroundAccel
    elseif setting.var == "AirAccel" then currentValue = stakanew_AirAccel
    elseif setting.var == "JumpPower" then currentValue = stakanew_JumpPower
    elseif setting.var == "Gravity" then currentValue = stakanew_Gravity end

    local slider, label = stakanew_CreateSlider(setting.name, currentValue, setting.min, setting.max, yPos, bhopContainer)
    if setting.var == "GroundSpeed" then groundSpeedSlider = slider
    elseif setting.var == "AirSpeed" then airSpeedSlider = slider
    elseif setting.var == "GroundAccel" then groundAccelSlider = slider
    elseif setting.var == "AirAccel" then airAccelSlider = slider
    elseif setting.var == "JumpPower" then jumpPowerSlider = slider
    elseif setting.var == "Gravity" then gravitySlider = slider end

    slider.FocusLost:Connect(function()
        local value = tonumber(slider.Text)
        if value then
            value = math.clamp(value, setting.min, setting.max)
            if setting.var == "GroundSpeed" then stakanew_GroundSpeed = value
            elseif setting.var == "AirSpeed" then stakanew_AirSpeed = value
            elseif setting.var == "GroundAccel" then stakanew_GroundAccel = value
            elseif setting.var == "AirAccel" then stakanew_AirAccel = value
            elseif setting.var == "JumpPower" then stakanew_JumpPower = value
            elseif setting.var == "Gravity" then
                stakanew_Gravity = value
                workspace.Gravity = value
            end
            label.Text = setting.name .. ": " .. tostring(value)
            slider.Text = tostring(value)
        end
    end)
end

spinSpeedSlider, _ = stakanew_CreateSlider("Скорость Spinbot", stakanew_SpinbotSpeed, 1, 20, yPosStart + #bhopSettings * 55, bhopContainer)
spinSpeedSlider.FocusLost:Connect(function()
    local v = tonumber(spinSpeedSlider.Text)
    if v then
        stakanew_SpinbotSpeed = math.clamp(v, 1, 20)
        spinSpeedSlider.Text = tostring(stakanew_SpinbotSpeed)
    end
end)

-- ==================== Visuals вкладка ====================
local visualsContainer = stakanew_TabContainers["Visuals"]
visualsContainer.CanvasSize = UDim2.new(0, 0, 0, 1200)

local stakanew_JumpCircleToggle, stakanew_JumpCircleLabel = stakanew_CreateToggle("Круг при прыжке", stakanew_JumpCircleEnabled, 10, visualsContainer)
local stakanew_JumpCloneToggle, stakanew_JumpCloneLabel = stakanew_CreateToggle("Копия при прыжке", stakanew_JumpCloneEnabled, 40, visualsContainer)
local stakanew_TrailToggle, stakanew_TrailLabel = stakanew_CreateToggle("След за игроком", stakanew_TrailEnabled, 70, visualsContainer)
local stakanew_HatToggle, stakanew_HatLabel = stakanew_CreateToggle("Шляпа", stakanew_HatEnabled, 100, visualsContainer)

local stakanew_RGBCloneToggle, stakanew_RGBCloneLabel = stakanew_CreateToggle("RGB копия", stakanew_RGBClone, 130, visualsContainer)
local stakanew_RGBCircleToggle, stakanew_RGBCircleLabel = stakanew_CreateToggle("RGB круг", stakanew_RGBCircle, 160, visualsContainer)
local stakanew_RGBTrailToggle, stakanew_RGBTrailLabel = stakanew_CreateToggle("RGB след", stakanew_RGBTrail, 190, visualsContainer)
local stakanew_RGBHatToggle, stakanew_RGBHatLabel = stakanew_CreateToggle("RGB шляпа", stakanew_RGBHat, 220, visualsContainer)

circleSizeSlider, _ = stakanew_CreateSlider("Размер круга", stakanew_CircleSize, 1, 50, 250, visualsContainer)
circleDurationSlider, _ = stakanew_CreateSlider("Длительность круга (сек)", stakanew_CircleDuration, 0.1, 2, 305, visualsContainer)
cloneTransparencySlider, _ = stakanew_CreateSlider("Прозрачность копии", stakanew_CloneTransparency, -1, 1, 360, visualsContainer)
cloneDurationSlider, _ = stakanew_CreateSlider("Длительность копии (сек)", stakanew_CloneDuration, 0.5, 10, 415, visualsContainer)
trailSizeSlider, _ = stakanew_CreateSlider("Толщина следа", stakanew_TrailSize, 0.1, 3, 470, visualsContainer)
trailDurationSlider, _ = stakanew_CreateSlider("Длительность следа (сек)", stakanew_TrailDuration, 0.1, 2, 525, visualsContainer)

hatRadiusSlider, _ = stakanew_CreateSlider("Радиус шляпы", stakanew_HatRadius, 0.5, 5, 580, visualsContainer)
hatHeightSlider, _ = stakanew_CreateSlider("Высота шляпы", stakanew_HatHeight, 1, 10, 635, visualsContainer)
hatTransparencySlider, _ = stakanew_CreateSlider("Прозрачность шляпы", stakanew_HatTransparency, 0, 1, 690, visualsContainer)
hatOffsetSlider, _ = stakanew_CreateSlider("Высота над головой", stakanew_HatOffsetY, 0, 10, 745, visualsContainer)
hatSpinSpeedSlider, _ = stakanew_CreateSlider("Скорость вращения", stakanew_HatSpinSpeed, 0, 5, 800, visualsContainer)

stakanew_CreateColorPicker("Цвет копии", 855, visualsContainer)
stakanew_CreateColorPicker("Цвет круга", 915, visualsContainer)
stakanew_CreateColorPicker("Цвет следа", 975, visualsContainer)
stakanew_CreateColorPicker("Цвет шляпы", 1035, visualsContainer)

-- Обработчики (сокращены, но рабочие)
stakanew_JumpCircleToggle.MouseButton1Click:Connect(function()
    stakanew_JumpCircleEnabled = not stakanew_JumpCircleEnabled
    stakanew_JumpCircleToggle.Text = stakanew_JumpCircleEnabled and "ВКЛ" or "ВЫКЛ"
    stakanew_JumpCircleToggle.BackgroundColor3 = stakanew_JumpCircleEnabled and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0)
end)
stakanew_JumpCloneToggle.MouseButton1Click:Connect(function()
    stakanew_JumpCloneEnabled = not stakanew_JumpCloneEnabled
    stakanew_JumpCloneToggle.Text = stakanew_JumpCloneEnabled and "ВКЛ" or "ВЫКЛ"
    stakanew_JumpCloneToggle.BackgroundColor3 = stakanew_JumpCloneEnabled and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0)
end)
stakanew_TrailToggle.MouseButton1Click:Connect(function()
    stakanew_TrailEnabled = not stakanew_TrailEnabled
    stakanew_TrailToggle.Text = stakanew_TrailEnabled and "ВКЛ" or "ВЫКЛ"
    stakanew_TrailToggle.BackgroundColor3 = stakanew_TrailEnabled and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0)
end)
stakanew_HatToggle.MouseButton1Click:Connect(function()
    stakanew_HatEnabled = not stakanew_HatEnabled
    stakanew_HatToggle.Text = stakanew_HatEnabled and "ВКЛ" or "ВЫКЛ"
    stakanew_HatToggle.BackgroundColor3 = stakanew_HatEnabled and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0)
    if stakanew_Character then
        if stakanew_HatEnabled then stakanew_CreateHat() else stakanew_RemoveHat() end
    end
end)

stakanew_RGBCloneToggle.MouseButton1Click:Connect(function()
    stakanew_RGBClone = not stakanew_RGBClone
    stakanew_RGBCloneToggle.Text = stakanew_RGBClone and "ВКЛ" or "ВЫКЛ"
    stakanew_RGBCloneToggle.BackgroundColor3 = stakanew_RGBClone and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0)
end)
stakanew_RGBCircleToggle.MouseButton1Click:Connect(function()
    stakanew_RGBCircle = not stakanew_RGBCircle
    stakanew_RGBCircleToggle.Text = stakanew_RGBCircle and "ВКЛ" or "ВЫКЛ"
    stakanew_RGBCircleToggle.BackgroundColor3 = stakanew_RGBCircle and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0)
end)
stakanew_RGBTrailToggle.MouseButton1Click:Connect(function()
    stakanew_RGBTrail = not stakanew_RGBTrail
    stakanew_RGBTrailToggle.Text = stakanew_RGBTrail and "ВКЛ" or "ВЫКЛ"
    stakanew_RGBTrailToggle.BackgroundColor3 = stakanew_RGBTrail and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0)
end)
stakanew_RGBHatToggle.MouseButton1Click:Connect(function()
    stakanew_RGBHat = not stakanew_RGBHat
    stakanew_RGBHatToggle.Text = stakanew_RGBHat and "ВКЛ" or "ВЫКЛ"
    stakanew_RGBHatToggle.BackgroundColor3 = stakanew_RGBHat and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0)
    if stakanew_HatEnabled then stakanew_CreateHat() end
end)

circleSizeSlider.FocusLost:Connect(function() local v=tonumber(circleSizeSlider.Text); if v then stakanew_CircleSize=math.clamp(v,1,50); circleSizeSlider.Text=tostring(stakanew_CircleSize) end end)
circleDurationSlider.FocusLost:Connect(function() local v=tonumber(circleDurationSlider.Text); if v then stakanew_CircleDuration=math.clamp(v,0.1,2); circleDurationSlider.Text=tostring(stakanew_CircleDuration) end end)
cloneTransparencySlider.FocusLost:Connect(function() local v=tonumber(cloneTransparencySlider.Text); if v then stakanew_CloneTransparency=math.clamp(v,-1,1); cloneTransparencySlider.Text=tostring(stakanew_CloneTransparency) end end)
cloneDurationSlider.FocusLost:Connect(function() local v=tonumber(cloneDurationSlider.Text); if v then stakanew_CloneDuration=math.clamp(v,0.5,10); cloneDurationSlider.Text=tostring(stakanew_CloneDuration) end end)
trailSizeSlider.FocusLost:Connect(function() local v=tonumber(trailSizeSlider.Text); if v then stakanew_TrailSize=math.clamp(v,0.1,3); trailSizeSlider.Text=tostring(stakanew_TrailSize) end end)
trailDurationSlider.FocusLost:Connect(function() local v=tonumber(trailDurationSlider.Text); if v then stakanew_TrailDuration=math.clamp(v,0.1,2); trailDurationSlider.Text=tostring(stakanew_TrailDuration) end end)
hatRadiusSlider.FocusLost:Connect(function() local v=tonumber(hatRadiusSlider.Text); if v then stakanew_HatRadius=math.clamp(v,0.5,5); hatRadiusSlider.Text=tostring(stakanew_HatRadius); if stakanew_HatEnabled then stakanew_CreateHat() end end end)
hatHeightSlider.FocusLost:Connect(function() local v=tonumber(hatHeightSlider.Text); if v then stakanew_HatHeight=math.clamp(v,1,10); hatHeightSlider.Text=tostring(stakanew_HatHeight); if stakanew_HatEnabled then stakanew_CreateHat() end end end)
hatTransparencySlider.FocusLost:Connect(function() local v=tonumber(hatTransparencySlider.Text); if v then stakanew_HatTransparency=math.clamp(v,0,1); hatTransparencySlider.Text=tostring(stakanew_HatTransparency); if stakanew_HatEnabled then stakanew_CreateHat() end end end)
hatOffsetSlider.FocusLost:Connect(function() local v=tonumber(hatOffsetSlider.Text); if v then stakanew_HatOffsetY=math.clamp(v,0,10); hatOffsetSlider.Text=tostring(stakanew_HatOffsetY); if stakanew_HatEnabled then stakanew_CreateHat() end end end)
hatSpinSpeedSlider.FocusLost:Connect(function() local v=tonumber(hatSpinSpeedSlider.Text); if v then stakanew_HatSpinSpeed=math.clamp(v,0,5); hatSpinSpeedSlider.Text=tostring(stakanew_HatSpinSpeed); if stakanew_HatEnabled then stakanew_CreateHat() end end end)

-- ==================== Fly вкладка ====================
local flyContainer = stakanew_TabContainers["Fly"]
flyContainer.CanvasSize = UDim2.new(0, 0, 0, 300)
local stakanew_FlyToggle, stakanew_FlyLabel = stakanew_CreateToggle("Fly (F)", stakanew_FlyEnabled, 10, flyContainer)
flySpeedSlider, _ = stakanew_CreateSlider("Скорость полёта", stakanew_FlySpeed, 1, 200, 40, flyContainer)
flyMaxVertSlider, _ = stakanew_CreateSlider("Макс. верт. скорость", stakanew_FlyMaxVert, 10, 200, 95, flyContainer)
flyAccelSlider, _ = stakanew_CreateSlider("Ускорение", stakanew_FlyAccel, 5, 100, 150, flyContainer)

stakanew_FlyToggle.MouseButton1Click:Connect(function()
    stakanew_FlyEnabled = not stakanew_FlyEnabled
    if stakanew_FlyEnabled then
        stakanew_BHopEnabled = false
        stakanew_FlyVertSpeed = 0
        if stakanew_RootPart then stakanew_RootPart.AssemblyLinearVelocity = Vector3.zero end
    else
        stakanew_BHopEnabled = true
        if stakanew_RootPart then stakanew_RootPart.AssemblyLinearVelocity = Vector3.zero end
    end
    stakanew_ApplyMovementState()
    stakanew_UpdateGUI()
end)
flySpeedSlider.FocusLost:Connect(function() local v=tonumber(flySpeedSlider.Text); if v then stakanew_FlySpeed=math.clamp(v,1,200); flySpeedSlider.Text=tostring(stakanew_FlySpeed) end end)
flyMaxVertSlider.FocusLost:Connect(function() local v=tonumber(flyMaxVertSlider.Text); if v then stakanew_FlyMaxVert=math.clamp(v,10,200); flyMaxVertSlider.Text=tostring(stakanew_FlyMaxVert) end end)
flyAccelSlider.FocusLost:Connect(function() local v=tonumber(flyAccelSlider.Text); if v then stakanew_FlyAccel=math.clamp(v,5,100); flyAccelSlider.Text=tostring(stakanew_FlyAccel) end end)

-- ==================== Screen вкладка ====================
local screenContainer = stakanew_TabContainers["Screen"]
screenContainer.CanvasSize = UDim2.new(0, 0, 0, 200)
local stakanew_FOVToggle, stakanew_FOVLabel = stakanew_CreateToggle("Растянуть экран (FOV)", stakanew_FOVEnabled, 10, screenContainer)
fovSlider, _ = stakanew_CreateSlider("FOV", stakanew_FOV, 30, 120, 40, screenContainer)
stakanew_FOVToggle.MouseButton1Click:Connect(function()
    stakanew_FOVEnabled = not stakanew_FOVEnabled
    stakanew_FOVToggle.Text = stakanew_FOVEnabled and "ВКЛ" or "ВЫКЛ"
    stakanew_FOVToggle.BackgroundColor3 = stakanew_FOVEnabled and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0)
    if stakanew_FOVEnabled then stakanew_Camera.FieldOfView = stakanew_FOV else stakanew_Camera.FieldOfView = 70 end
end)
fovSlider.FocusLost:Connect(function() local v=tonumber(fovSlider.Text); if v then stakanew_FOV=math.clamp(v,30,120); fovSlider.Text=tostring(stakanew_FOV); if stakanew_FOVEnabled then stakanew_Camera.FieldOfView=stakanew_FOV end end end)

-- ==================== Config вкладка ====================
local configContainer = stakanew_TabContainers["Config"]
configContainer.CanvasSize = UDim2.new(0, 0, 0, 500)
local configNameInput = Instance.new("TextBox")
configNameInput.Size = UDim2.new(1, -20, 0, 30)
configNameInput.Position = UDim2.new(0, 10, 0, 10)
configNameInput.PlaceholderText = "Название конфига"
configNameInput.Text = ""
configNameInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
configNameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
configNameInput.Font = Enum.Font.SourceSans
configNameInput.TextSize = 14
configNameInput.Parent = configContainer
local saveConfigButton = Instance.new("TextButton")
saveConfigButton.Size = UDim2.new(0, 120, 0, 25)
saveConfigButton.Position = UDim2.new(0, 10, 0, 45)
saveConfigButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
saveConfigButton.Text = "Сохранить"
saveConfigButton.Font = Enum.Font.SourceSansBold
saveConfigButton.TextSize = 14
saveConfigButton.TextColor3 = Color3.fromRGB(255, 255, 255)
saveConfigButton.Parent = configContainer
local saveCorner = Instance.new("UICorner")
saveCorner.CornerRadius = UDim.new(0, 5)
saveCorner.Parent = saveConfigButton
saveConfigButton.MouseButton1Click:Connect(function()
    local name = configNameInput.Text
    if name and name ~= "" then stakanew_SaveConfig(name) end
end)
local configListLabel = Instance.new("TextLabel")
configListLabel.Size = UDim2.new(1, -20, 0, 20)
configListLabel.Position = UDim2.new(0, 10, 0, 80)
configListLabel.BackgroundTransparency = 1
configListLabel.Text = "Сохранённые конфиги:"
configListLabel.Font = Enum.Font.SourceSansBold
configListLabel.TextSize = 14
configListLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
configListLabel.Parent = configContainer

function stakanew_SaveConfig(name)
    pcall(function() makefolder("stakanew_bhop_configs") end)
    local config = {
        GroundSpeed = stakanew_GroundSpeed, AirSpeed = stakanew_AirSpeed,
        GroundAccel = stakanew_GroundAccel, AirAccel = stakanew_AirAccel,
        JumpPower = stakanew_JumpPower, Gravity = stakanew_Gravity,
        BHopEnabled = stakanew_BHopEnabled, JumpCircleEnabled = stakanew_JumpCircleEnabled,
        JumpCloneEnabled = stakanew_JumpCloneEnabled, TrailEnabled = stakanew_TrailEnabled,
        CloneColor = {stakanew_CloneColor.R, stakanew_CloneColor.G, stakanew_CloneColor.B},
        CircleColor = {stakanew_CircleColor.R, stakanew_CircleColor.G, stakanew_CircleColor.B},
        TrailColor = {stakanew_TrailColor.R, stakanew_TrailColor.G, stakanew_TrailColor.B},
        CloneTransparency = stakanew_CloneTransparency, CloneDuration = stakanew_CloneDuration,
        TrailSize = stakanew_TrailSize, TrailDuration = stakanew_TrailDuration,
        TrailInterval = stakanew_TrailInterval, CircleSize = stakanew_CircleSize,
        CircleDuration = stakanew_CircleDuration, NoAnimations = stakanew_NoAnimations,
        HatEnabled = stakanew_HatEnabled, HatRadius = stakanew_HatRadius,
        HatHeight = stakanew_HatHeight, HatTransparency = stakanew_HatTransparency,
        HatOffsetY = stakanew_HatOffsetY, HatSpinSpeed = stakanew_HatSpinSpeed,
        HatColor = {stakanew_HatColor.R, stakanew_HatColor.G, stakanew_HatColor.B},
        RGBClone = stakanew_RGBClone, RGBCircle = stakanew_RGBCircle,
        RGBTrail = stakanew_RGBTrail, RGBHat = stakanew_RGBHat,
        SpinbotEnabled = stakanew_SpinbotEnabled, SpinbotSpeed = stakanew_SpinbotSpeed,
        Language = stakanew_Language, FlyEnabled = stakanew_FlyEnabled,
        FlySpeed = stakanew_FlySpeed, FlyMaxVert = stakanew_FlyMaxVert, FlyAccel = stakanew_FlyAccel,
        FOVEnabled = stakanew_FOVEnabled, FOV = stakanew_FOV,
        InstantStrafe = stakanew_InstantStrafe, InstantStrafePower = stakanew_InstantStrafePower,
    }
    local json = game:GetService("HttpService"):JSONEncode(config)
    local filePath = "stakanew_bhop_configs/" .. name .. ".json"
    pcall(function() writefile(filePath, json) end)
    print("Конфиг сохранён: " .. name)
    stakanew_RefreshConfigList()
end

function stakanew_LoadConfig(name)
    local success, data = pcall(function() return readfile("stakanew_bhop_configs/" .. name .. ".json") end)
    if success and data then
        local ok, config = pcall(function() return game:GetService("HttpService"):JSONDecode(data) end)
        if ok and config then
            stakanew_GroundSpeed = tonumber(config.GroundSpeed) or stakanew_GroundSpeed
            stakanew_AirSpeed = tonumber(config.AirSpeed) or stakanew_AirSpeed
            stakanew_GroundAccel = tonumber(config.GroundAccel) or stakanew_GroundAccel
            stakanew_AirAccel = tonumber(config.AirAccel) or stakanew_AirAccel
            stakanew_JumpPower = tonumber(config.JumpPower) or stakanew_JumpPower
            stakanew_Gravity = tonumber(config.Gravity) or stakanew_Gravity
            stakanew_BHopEnabled = config.BHopEnabled ~= nil and config.BHopEnabled or stakanew_BHopEnabled
            stakanew_JumpCircleEnabled = config.JumpCircleEnabled ~= nil and config.JumpCircleEnabled or stakanew_JumpCircleEnabled
            stakanew_JumpCloneEnabled = config.JumpCloneEnabled ~= nil and config.JumpCloneEnabled or stakanew_JumpCloneEnabled
            stakanew_TrailEnabled = config.TrailEnabled ~= nil and config.TrailEnabled or stakanew_TrailEnabled
            if config.CloneColor then stakanew_CloneColor = Color3.new(config.CloneColor[1], config.CloneColor[2], config.CloneColor[3]) end
            if config.CircleColor then stakanew_CircleColor = Color3.new(config.CircleColor[1], config.CircleColor[2], config.CircleColor[3]) end
            if config.TrailColor then stakanew_TrailColor = Color3.new(config.TrailColor[1], config.TrailColor[2], config.TrailColor[3]) end
            stakanew_CloneTransparency = tonumber(config.CloneTransparency) or stakanew_CloneTransparency
            stakanew_CloneDuration = tonumber(config.CloneDuration) or stakanew_CloneDuration
            stakanew_TrailSize = tonumber(config.TrailSize) or stakanew_TrailSize
            stakanew_TrailDuration = tonumber(config.TrailDuration) or stakanew_TrailDuration
            stakanew_TrailInterval = tonumber(config.TrailInterval) or stakanew_TrailInterval
            stakanew_CircleSize = tonumber(config.CircleSize) or stakanew_CircleSize
            stakanew_CircleDuration = tonumber(config.CircleDuration) or stakanew_CircleDuration
            stakanew_NoAnimations = config.NoAnimations ~= nil and config.NoAnimations or stakanew_NoAnimations
            stakanew_HatEnabled = config.HatEnabled ~= nil and config.HatEnabled or stakanew_HatEnabled
            stakanew_HatRadius = tonumber(config.HatRadius) or stakanew_HatRadius
            stakanew_HatHeight = tonumber(config.HatHeight) or stakanew_HatHeight
            stakanew_HatTransparency = tonumber(config.HatTransparency) or stakanew_HatTransparency
            stakanew_HatOffsetY = tonumber(config.HatOffsetY) or stakanew_HatOffsetY
            stakanew_HatSpinSpeed = tonumber(config.HatSpinSpeed) or stakanew_HatSpinSpeed
            if config.HatColor then stakanew_HatColor = Color3.new(config.HatColor[1], config.HatColor[2], config.HatColor[3]) end
            stakanew_RGBClone = config.RGBClone ~= nil and config.RGBClone or stakanew_RGBClone
            stakanew_RGBCircle = config.RGBCircle ~= nil and config.RGBCircle or stakanew_RGBCircle
            stakanew_RGBTrail = config.RGBTrail ~= nil and config.RGBTrail or stakanew_RGBTrail
            stakanew_RGBHat = config.RGBHat ~= nil and config.RGBHat or stakanew_RGBHat
            stakanew_SpinbotEnabled = config.SpinbotEnabled ~= nil and config.SpinbotEnabled or stakanew_SpinbotEnabled
            stakanew_SpinbotSpeed = tonumber(config.SpinbotSpeed) or stakanew_SpinbotSpeed
            stakanew_Language = config.Language or stakanew_Language
            stakanew_FlyEnabled = config.FlyEnabled ~= nil and config.FlyEnabled or stakanew_FlyEnabled
            stakanew_FlySpeed = tonumber(config.FlySpeed) or stakanew_FlySpeed
            stakanew_FlyMaxVert = tonumber(config.FlyMaxVert) or stakanew_FlyMaxVert
            stakanew_FlyAccel = tonumber(config.FlyAccel) or stakanew_FlyAccel
            stakanew_FOVEnabled = config.FOVEnabled ~= nil and config.FOVEnabled or stakanew_FOVEnabled
            stakanew_FOV = tonumber(config.FOV) or stakanew_FOV
            stakanew_InstantStrafe = config.InstantStrafe ~= nil and config.InstantStrafe or stakanew_InstantStrafe
            stakanew_InstantStrafePower = tonumber(config.InstantStrafePower) or stakanew_InstantStrafePower

            stakanew_UpdateGUI()
            stakanew_ApplyMovementState()
            workspace.Gravity = stakanew_Gravity
            if stakanew_HatEnabled then stakanew_CreateHat() else stakanew_RemoveHat() end
            if stakanew_FOVEnabled then stakanew_Camera.FieldOfView = stakanew_FOV else stakanew_Camera.FieldOfView = 70 end
        end
    end
end

function stakanew_DeleteConfig(name)
    pcall(function() delfile("stakanew_bhop_configs/" .. name .. ".json") end)
    stakanew_RefreshConfigList()
end

function stakanew_RefreshConfigList()
    for _, btn in pairs(stakanew_ConfigButtons) do
        if btn and btn.Parent then btn:Destroy() end
    end
    stakanew_ConfigButtons = {}
    local files = {}
    local success, result = pcall(function() return listfiles("stakanew_bhop_configs") end)
    if success then files = result or {}
    else
        pcall(function() makefolder("stakanew_bhop_configs") end)
        local success2, result2 = pcall(function() return listfiles("stakanew_bhop_configs") end)
        if success2 then files = result2 or {} end
    end
    local y = 110
    for _, file in ipairs(files) do
        local name = file:match("([^/\\]+)%.json$")
        if name then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -20, 0, 25)
            btn.Position = UDim2.new(0, 10, 0, y)
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            btn.Text = name
            btn.Font = Enum.Font.SourceSansBold
            btn.TextSize = 14
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Parent = configContainer
            local delBtn = Instance.new("TextButton")
            delBtn.Size = UDim2.new(0, 25, 0, 25)
            delBtn.Position = UDim2.new(1, -35, 0, y)
            delBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
            delBtn.Text = "X"
            delBtn.Font = Enum.Font.SourceSansBold
            delBtn.TextSize = 12
            delBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            delBtn.Parent = configContainer
            btn.MouseButton1Click:Connect(function() stakanew_LoadConfig(name) end)
            delBtn.MouseButton1Click:Connect(function() stakanew_DeleteConfig(name) end)
            table.insert(stakanew_ConfigButtons, btn)
            table.insert(stakanew_ConfigButtons, delBtn)
            y = y + 30
        end
    end
end

-- ==================== Settings вкладка ====================
local settingsContainer = stakanew_TabContainers["Settings"]
settingsContainer.CanvasSize = UDim2.new(0, 0, 0, 300)
local langLabel = Instance.new("TextLabel")
langLabel.Size = UDim2.new(0, 180, 0, 20)
langLabel.Position = UDim2.new(0, 10, 0, 10)
langLabel.BackgroundTransparency = 1
langLabel.Text = "Язык / Language"
langLabel.Font = Enum.Font.SourceSansBold
langLabel.TextSize = 14
langLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
langLabel.Parent = settingsContainer
local btnRU = Instance.new("TextButton")
btnRU.Size = UDim2.new(0, 50, 0, 25)
btnRU.Position = UDim2.new(0, 10, 0, 35)
btnRU.BackgroundColor3 = stakanew_Language == "RU" and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
btnRU.Text = "RU"
btnRU.Font = Enum.Font.SourceSansBold
btnRU.TextSize = 14
btnRU.TextColor3 = Color3.fromRGB(255, 255, 255)
btnRU.Parent = settingsContainer
local btnEN = Instance.new("TextButton")
btnEN.Size = UDim2.new(0, 50, 0, 25)
btnEN.Position = UDim2.new(0, 70, 0, 35)
btnEN.BackgroundColor3 = stakanew_Language == "EN" and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
btnEN.Text = "EN"
btnEN.Font = Enum.Font.SourceSansBold
btnEN.TextSize = 14
btnEN.TextColor3 = Color3.fromRGB(255, 255, 255)
btnEN.Parent = settingsContainer
local resetButton = Instance.new("TextButton")
resetButton.Size = UDim2.new(1, -20, 0, 30)
resetButton.Position = UDim2.new(0, 10, 0, 80)
resetButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
resetButton.Text = "Сбросить все конфиги"
resetButton.Font = Enum.Font.SourceSansBold
resetButton.TextSize = 14
resetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
resetButton.Parent = settingsContainer
resetButton.MouseButton1Click:Connect(function()
    local files = {}
    pcall(function() files = listfiles("stakanew_bhop_configs") end)
    for _, file in ipairs(files) do pcall(function() delfile(file) end) end
    stakanew_RefreshConfigList()
end)

local function stakanew_ApplyLanguage()
    if stakanew_Language == "RU" then
        stakanew_PanelTitle.Text = "Настройки"
        stakanew_TabButtons["BHop"].Text = "BHop"
        stakanew_TabButtons["Visuals"].Text = "Визуал"
        stakanew_TabButtons["Fly"].Text = "Fly"
        stakanew_TabButtons["Screen"].Text = "Экран"
        stakanew_TabButtons["Config"].Text = "Конфиг"
        stakanew_TabButtons["Settings"].Text = "Настройки"
    else
        stakanew_PanelTitle.Text = "Settings"
        stakanew_TabButtons["BHop"].Text = "BHop"
        stakanew_TabButtons["Visuals"].Text = "Visuals"
        stakanew_TabButtons["Fly"].Text = "Fly"
        stakanew_TabButtons["Screen"].Text = "Screen"
        stakanew_TabButtons["Config"].Text = "Config"
        stakanew_TabButtons["Settings"].Text = "Settings"
    end
end
btnRU.MouseButton1Click:Connect(function() stakanew_Language = "RU"; btnRU.BackgroundColor3 = Color3.fromRGB(0, 150, 0); btnEN.BackgroundColor3 = Color3.fromRGB(50, 50, 50); stakanew_ApplyLanguage() end)
btnEN.MouseButton1Click:Connect(function() stakanew_Language = "EN"; btnEN.BackgroundColor3 = Color3.fromRGB(0, 150, 0); btnRU.BackgroundColor3 = Color3.fromRGB(50, 50, 50); stakanew_ApplyLanguage() end)

-- Инициализация
pcall(function() makefolder("stakanew_bhop_configs") end)
pcall(stakanew_RefreshConfigList)
stakanew_ApplyLanguage()

-- Обновление GUI
function stakanew_UpdateGUI()
    stakanew_BHopToggle.Text = stakanew_BHopEnabled and "ВКЛ" or "ВЫКЛ"
    stakanew_BHopToggle.BackgroundColor3 = stakanew_BHopEnabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    stakanew_NoAnimationsToggle.Text = stakanew_NoAnimations and "ВКЛ" or "ВЫКЛ"
    stakanew_NoAnimationsToggle.BackgroundColor3 = stakanew_NoAnimations and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    stakanew_SpinbotToggle.Text = stakanew_SpinbotEnabled and "ВКЛ" or "ВЫКЛ"
    stakanew_SpinbotToggle.BackgroundColor3 = stakanew_SpinbotEnabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    stakanew_InstantStrafeToggle.Text = stakanew_InstantStrafe and "ВКЛ" or "ВЫКЛ"
    stakanew_InstantStrafeToggle.BackgroundColor3 = stakanew_InstantStrafe and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    stakanew_JumpCircleToggle.Text = stakanew_JumpCircleEnabled and "ВКЛ" or "ВЫКЛ"
    stakanew_JumpCircleToggle.BackgroundColor3 = stakanew_JumpCircleEnabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    stakanew_JumpCloneToggle.Text = stakanew_JumpCloneEnabled and "ВКЛ" or "ВЫКЛ"
    stakanew_JumpCloneToggle.BackgroundColor3 = stakanew_JumpCloneEnabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    stakanew_TrailToggle.Text = stakanew_TrailEnabled and "ВКЛ" or "ВЫКЛ"
    stakanew_TrailToggle.BackgroundColor3 = stakanew_TrailEnabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    stakanew_HatToggle.Text = stakanew_HatEnabled and "ВКЛ" or "ВЫКЛ"
    stakanew_HatToggle.BackgroundColor3 = stakanew_HatEnabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    stakanew_FlyToggle.Text = stakanew_FlyEnabled and "ВКЛ" or "ВЫКЛ"
    stakanew_FlyToggle.BackgroundColor3 = stakanew_FlyEnabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    stakanew_FOVToggle.Text = stakanew_FOVEnabled and "ВКЛ" or "ВЫКЛ"
    stakanew_FOVToggle.BackgroundColor3 = stakanew_FOVEnabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)

    stakanew_RGBCloneToggle.Text = stakanew_RGBClone and "ВКЛ" or "ВЫКЛ"
    stakanew_RGBCloneToggle.BackgroundColor3 = stakanew_RGBClone and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    stakanew_RGBCircleToggle.Text = stakanew_RGBCircle and "ВКЛ" or "ВЫКЛ"
    stakanew_RGBCircleToggle.BackgroundColor3 = stakanew_RGBCircle and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    stakanew_RGBTrailToggle.Text = stakanew_RGBTrail and "ВКЛ" or "ВЫКЛ"
    stakanew_RGBTrailToggle.BackgroundColor3 = stakanew_RGBTrail and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    stakanew_RGBHatToggle.Text = stakanew_RGBHat and "ВКЛ" or "ВЫКЛ"
    stakanew_RGBHatToggle.BackgroundColor3 = stakanew_RGBHat and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)

    if groundSpeedSlider then groundSpeedSlider.Text = tostring(stakanew_GroundSpeed) end
    if airSpeedSlider then airSpeedSlider.Text = tostring(stakanew_AirSpeed) end
    if groundAccelSlider then groundAccelSlider.Text = tostring(stakanew_GroundAccel) end
    if airAccelSlider then airAccelSlider.Text = tostring(stakanew_AirAccel) end
    if jumpPowerSlider then jumpPowerSlider.Text = tostring(stakanew_JumpPower) end
    if gravitySlider then gravitySlider.Text = tostring(stakanew_Gravity) end
    if circleSizeSlider then circleSizeSlider.Text = tostring(stakanew_CircleSize) end
    if circleDurationSlider then circleDurationSlider.Text = tostring(stakanew_CircleDuration) end
    if cloneTransparencySlider then cloneTransparencySlider.Text = tostring(stakanew_CloneTransparency) end
    if cloneDurationSlider then cloneDurationSlider.Text = tostring(stakanew_CloneDuration) end
    if trailSizeSlider then trailSizeSlider.Text = tostring(stakanew_TrailSize) end
    if trailDurationSlider then trailDurationSlider.Text = tostring(stakanew_TrailDuration) end
    if spinSpeedSlider then spinSpeedSlider.Text = tostring(stakanew_SpinbotSpeed) end
    if hatRadiusSlider then hatRadiusSlider.Text = tostring(stakanew_HatRadius) end
    if hatHeightSlider then hatHeightSlider.Text = tostring(stakanew_HatHeight) end
    if hatTransparencySlider then hatTransparencySlider.Text = tostring(stakanew_HatTransparency) end
    if hatOffsetSlider then hatOffsetSlider.Text = tostring(stakanew_HatOffsetY) end
    if hatSpinSpeedSlider then hatSpinSpeedSlider.Text = tostring(stakanew_HatSpinSpeed) end
    if flySpeedSlider then flySpeedSlider.Text = tostring(stakanew_FlySpeed) end
    if flyMaxVertSlider then flyMaxVertSlider.Text = tostring(stakanew_FlyMaxVert) end
    if flyAccelSlider then flyAccelSlider.Text = tostring(stakanew_FlyAccel) end
    if fovSlider then fovSlider.Text = tostring(stakanew_FOV) end
    if instantStrafePowerSlider then instantStrafePowerSlider.Text = tostring(stakanew_InstantStrafePower) end
end

-- Открытие меню
local function stakanew_ToggleSettings()
    stakanew_SettingsOpen = not stakanew_SettingsOpen
    stakanew_SettingsPanel.Visible = stakanew_SettingsOpen
end
stakanew_SettingsButton.MouseButton1Click:Connect(stakanew_ToggleSettings)
stakanew_CollapseButton.MouseButton1Click:Connect(stakanew_ToggleSettings)

-- Визуальные функции
local function stakanew_CreateJumpCircle(position)
    local circle = Instance.new("Part")
    circle.Size = Vector3.new(1, 1, 1)
    circle.Position = position - Vector3.new(0, 3, 0)
    circle.Anchored = true
    circle.CanCollide = false
    circle.CanQuery = false
    circle.CanTouch = false
    circle.Material = Enum.Material.Neon
    circle.Color = stakanew_RGBCircle and stakanew_GetRainbowColor() or stakanew_CircleColor
    circle.Transparency = 0.3
    local mesh = Instance.new("CylinderMesh")
    mesh.Scale = Vector3.new(1, 0.05, 1)
    mesh.Parent = circle
    circle.Parent = workspace
    task.spawn(function()
        local startTime = tick()
        local duration = stakanew_CircleDuration
        while tick() - startTime < duration do
            local progress = (tick() - startTime) / duration
            mesh.Scale = Vector3.new(1 + progress * stakanew_CircleSize, 0.05, 1 + progress * stakanew_CircleSize)
            circle.Transparency = 0.3 + progress * 0.7
            if stakanew_RGBCircle then circle.Color = stakanew_GetRainbowColor() end
            task.wait()
        end
        circle:Destroy()
    end)
end

local function stakanew_CreateJumpClone(character)
    local parts = {}
    for _, partName in ipairs({"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}) do
        local part = character:FindFirstChild(partName)
        if part then
            local clonePart = Instance.new("Part")
            clonePart.Size = part.Size
            clonePart.CFrame = part.CFrame
            clonePart.Anchored = true
            clonePart.CanCollide = false
            clonePart.CanQuery = false
            clonePart.CanTouch = false
            clonePart.Material = Enum.Material.ForceField
            clonePart.Color = stakanew_RGBClone and stakanew_GetRainbowColor() or stakanew_CloneColor
            clonePart.Transparency = stakanew_CloneTransparency
            clonePart.Parent = workspace
            if partName == "Head" then clonePart.Shape = Enum.PartType.Ball end
            table.insert(parts, clonePart)
        end
    end
    task.spawn(function()
        local startTime = tick()
        local duration = stakanew_CloneDuration
        while tick() - startTime < duration do
            local progress = (tick() - startTime) / duration
            for _, part in pairs(parts) do
                part.Transparency = stakanew_CloneTransparency + (1 - stakanew_CloneTransparency) * progress
                if stakanew_RGBClone then part.Color = stakanew_GetRainbowColor() end
            end
            task.wait()
        end
        for _, part in pairs(parts) do part:Destroy() end
    end)
end

local function stakanew_CreateTrail(position, previousPosition)
    if not previousPosition then
        stakanew_LastTrailPos = position
        return
    end
    local distance = (position - previousPosition).Magnitude
    if distance < 0.1 then return end
    local trail = Instance.new("Part")
    trail.Shape = Enum.PartType.Block
    trail.Size = Vector3.new(stakanew_TrailSize, stakanew_TrailSize, distance)
    trail.CFrame = CFrame.lookAt((position + previousPosition) / 2, position)
    trail.Anchored = true
    trail.CanCollide = false
    trail.CanQuery = false
    trail.CanTouch = false
    trail.Material = Enum.Material.Neon
    trail.Color = stakanew_RGBTrail and stakanew_GetRainbowColor() or stakanew_TrailColor
    trail.Transparency = 0.3
    trail.Parent = workspace
    task.spawn(function()
        local startTime = tick()
        local duration = stakanew_TrailDuration
        while tick() - startTime < duration do
            local progress = (tick() - startTime) / duration
            trail.Transparency = 0.3 + progress * 0.7
            if stakanew_RGBTrail then trail.Color = stakanew_GetRainbowColor() end
            task.wait()
        end
        trail:Destroy()
    end)
    stakanew_LastTrailPos = position
end

-- Физика
local function stakanew_Flat(v)
    return Vector3.new(v.X, 0, v.Z)
end

local function stakanew_Accelerate(vel, wishDir, wishSpeed, accel, dt)
    local addSpeed = wishSpeed - vel:Dot(wishDir)
    if addSpeed <= 0 then return vel end
    local accelSpeed = math.min(accel * wishSpeed * dt, addSpeed)
    return vel + wishDir * accelSpeed
end

local function stakanew_ApplyFriction(vel, dt)
    local speed = stakanew_Flat(vel).Magnitude
    if speed < 0.1 then return Vector3.new(0, vel.Y, 0) end
    local drop = math.max(speed, stakanew_GroundSpeed) * stakanew_Friction * dt
    local scale = math.max(speed - drop, 0) / speed
    return Vector3.new(vel.X * scale, vel.Y, vel.Z * scale)
end

local function stakanew_ApplyAirControl(vel, wishDir, dt)
    if stakanew_AirControl == 0 or stakanew_MoveRight ~= 0 then return vel end
    local fv = stakanew_Flat(vel)
    local speed = fv.Magnitude
    if speed < 0.1 then return vel end
    local dot = fv.Unit:Dot(wishDir)
    if dot <= 0 then return vel end
    local k = stakanew_AirControl * dot * dot * dt * 32
    local adj = (fv * (1 - k) + wishDir * (speed * k)).Unit * speed
    return Vector3.new(adj.X, vel.Y, adj.Z)
end

local function stakanew_InstantStrafeFunction(vel, wishDir, power)
    local flatVel = stakanew_Flat(vel)
    local speed = flatVel.Magnitude
    if speed < 1 then return vel end
    local wishFlat = stakanew_Flat(wishDir)
    if wishFlat.Magnitude < 0.01 then return vel end
    wishFlat = wishFlat.Unit
    local newFlat = wishFlat * speed
    local finalFlat = flatVel:Lerp(newFlat, power)
    return Vector3.new(finalFlat.X, vel.Y, finalFlat.Z)
end

stakanew_UIS.InputBegan:Connect(function(input, gp)
    local kc = input.KeyCode
    if kc == Enum.KeyCode.Space then stakanew_JumpHeld = true return end
    if gp then return end
    if kc == Enum.KeyCode.W then stakanew_MoveForward = 1
    elseif kc == Enum.KeyCode.S then stakanew_MoveForward = -1
    elseif kc == Enum.KeyCode.A then stakanew_MoveRight = -1
    elseif kc == Enum.KeyCode.D then stakanew_MoveRight = 1
    elseif kc == Enum.KeyCode.F then
        stakanew_FlyEnabled = not stakanew_FlyEnabled
        if stakanew_FlyEnabled then
            stakanew_BHopEnabled = false
            stakanew_FlyVertSpeed = 0
            if stakanew_RootPart then stakanew_RootPart.AssemblyLinearVelocity = Vector3.zero end
        else
            stakanew_BHopEnabled = true
            if stakanew_RootPart then stakanew_RootPart.AssemblyLinearVelocity = Vector3.zero end
        end
        stakanew_ApplyMovementState()
        stakanew_UpdateGUI()
    end
end)

stakanew_UIS.InputEnded:Connect(function(input)
    local kc = input.KeyCode
    if kc == Enum.KeyCode.W and stakanew_MoveForward == 1 then stakanew_MoveForward = 0
    elseif kc == Enum.KeyCode.S and stakanew_MoveForward == -1 then stakanew_MoveForward = 0
    elseif kc == Enum.KeyCode.A and stakanew_MoveRight == -1 then stakanew_MoveRight = 0
    elseif kc == Enum.KeyCode.D and stakanew_MoveRight == 1 then stakanew_MoveRight = 0
    elseif kc == Enum.KeyCode.Space then stakanew_JumpHeld = false end
end)

local stakanew_RayParams = RaycastParams.new()
stakanew_RayParams.FilterType = Enum.RaycastFilterType.Exclude

local function stakanew_Grounded()
    if not stakanew_RootPart then return false end
    stakanew_RayParams.FilterDescendantsInstances = {stakanew_Character}
    return workspace:Raycast(stakanew_RootPart.Position, Vector3.new(0, -3.5, 0), stakanew_RayParams) ~= nil
end

local function stakanew_GetWishDir()
    if stakanew_MoveForward == 0 and stakanew_MoveRight == 0 then return Vector3.zero end
    local cf = stakanew_Camera.CFrame
    local dir = stakanew_Flat(cf.LookVector).Unit * stakanew_MoveForward + stakanew_Flat(cf.RightVector).Unit * stakanew_MoveRight
    return dir.Magnitude > 0 and dir.Unit or Vector3.zero
end

local function stakanew_PhysicsStep(dt)
    if not stakanew_RootPart or not stakanew_Humanoid or stakanew_Humanoid.Health <= 0 then 
        stakanew_SpeedCounter.Text = "0.0"
        return 
    end

    if stakanew_FOVEnabled then
        stakanew_Camera.FieldOfView = stakanew_FOV
    else
        stakanew_Camera.FieldOfView = 70
    end

    if stakanew_FlyEnabled then
        local camForward = stakanew_Camera.CFrame.LookVector
        local camRight = stakanew_Camera.CFrame.RightVector
        local moveDir = Vector3.zero
        if stakanew_UIS:IsKeyDown(Enum.KeyCode.W) then moveDir += camForward end
        if stakanew_UIS:IsKeyDown(Enum.KeyCode.S) then moveDir -= camForward end
        if stakanew_UIS:IsKeyDown(Enum.KeyCode.A) then moveDir -= camRight end
        if stakanew_UIS:IsKeyDown(Enum.KeyCode.D) then moveDir += camRight end
        if moveDir.Magnitude > 0 then moveDir = Vector3.new(moveDir.X, 0, moveDir.Z).Unit end
        if stakanew_UIS:IsKeyDown(Enum.KeyCode.Space) then
            stakanew_FlyVertSpeed = math.min(stakanew_FlyVertSpeed + stakanew_FlyAccel * dt * 60, stakanew_FlyMaxVert)
        elseif stakanew_UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
            stakanew_FlyVertSpeed = math.max(stakanew_FlyVertSpeed - stakanew_FlyAccel * dt * 60, -stakanew_FlyMaxVert)
        else
            stakanew_FlyVertSpeed = stakanew_FlyVertSpeed * stakanew_FlyDamp
        end
        local targetVel = moveDir * stakanew_FlySpeed + Vector3.new(0, stakanew_FlyVertSpeed, 0)
        local currentVel = stakanew_RootPart.AssemblyLinearVelocity
        local diff = targetVel - currentVel
        local maxChange = stakanew_FlyAccel * dt * 60
        if diff.Magnitude > maxChange then diff = diff.Unit * maxChange end
        local noise = Vector3.new(
            math.random(-20, 20) / 100,
            math.random(-20, 20) / 100,
            math.random(-20, 20) / 100
        ) * dt * stakanew_FlyNoise
        local newVel = currentVel + diff + noise
        stakanew_RootPart.AssemblyLinearVelocity = newVel
        if moveDir.Magnitude > 0.1 then
            local targetCF = CFrame.lookAt(stakanew_RootPart.Position, stakanew_RootPart.Position + moveDir)
            stakanew_RootPart.CFrame = stakanew_RootPart.CFrame:Lerp(targetCF, math.min(1, dt * 15))
        else
            local flatCam = CFrame.new(stakanew_RootPart.Position, stakanew_RootPart.Position + Vector3.new(camForward.X, 0, camForward.Z))
            stakanew_RootPart.CFrame = stakanew_RootPart.CFrame:Lerp(flatCam, math.min(1, dt * 10))
        end
        if math.random() < stakanew_FlyPacketLoss then
            stakanew_RootPart.AssemblyLinearVelocity = stakanew_RootPart.AssemblyLinearVelocity * 0.95
        end
        local fv = stakanew_Flat(stakanew_RootPart.AssemblyLinearVelocity)
        local currentSpeed = math.floor(fv.Magnitude * 10) / 10
        stakanew_SpeedCounter.Text = string.format("%.1f", currentSpeed)
        return
    end

    if stakanew_SpinbotEnabled and stakanew_RootPart then
        stakanew_RootPart.CFrame = stakanew_RootPart.CFrame * CFrame.Angles(0, math.rad(stakanew_SpinbotSpeed * 2), 0)
    end

    if stakanew_BHopEnabled then
        stakanew_Humanoid.WalkSpeed = 0
        stakanew_Humanoid.JumpPower = 0
        stakanew_Humanoid.JumpHeight = 0
        stakanew_Humanoid.AutoRotate = false

        stakanew_IsGrounded = stakanew_Grounded()
        stakanew_Velocity = Vector3.new(stakanew_Velocity.X, stakanew_RootPart.AssemblyLinearVelocity.Y, stakanew_Velocity.Z)
        stakanew_WishJump = stakanew_JumpHeld
        stakanew_JumpCooldown = math.max(0, stakanew_JumpCooldown - dt)

        if stakanew_IsGrounded and stakanew_WishJump and stakanew_JumpCooldown == 0 then
            stakanew_Velocity = Vector3.new(stakanew_Velocity.X, stakanew_JumpPower, stakanew_Velocity.Z)
            stakanew_IsGrounded = false
            stakanew_JumpCooldown = 0.1
            if stakanew_JumpCircleEnabled then stakanew_CreateJumpCircle(stakanew_RootPart.Position) end
            if stakanew_JumpCloneEnabled then stakanew_CreateJumpClone(stakanew_Character) end
        end

        local wishDir = stakanew_GetWishDir()

        if stakanew_IsGrounded then
            stakanew_Velocity = stakanew_ApplyFriction(stakanew_Velocity, dt)
            if wishDir.Magnitude > 0 then
                stakanew_Velocity = stakanew_Accelerate(stakanew_Velocity, wishDir, stakanew_GroundSpeed, stakanew_GroundAccel, dt)
            end
        elseif wishDir.Magnitude > 0 then
            if stakanew_InstantStrafe then
                stakanew_Velocity = stakanew_InstantStrafeFunction(stakanew_Velocity, wishDir, stakanew_InstantStrafePower)
            else
                stakanew_Velocity = stakanew_Accelerate(stakanew_Velocity, wishDir, stakanew_AirSpeed, stakanew_AirAccel, dt)
                stakanew_Velocity = stakanew_ApplyAirControl(stakanew_Velocity, wishDir, dt)
            end
        end

        stakanew_RootPart.AssemblyLinearVelocity = stakanew_Velocity

        local fv = stakanew_Flat(stakanew_Velocity)
        local currentSpeed = math.floor(fv.Magnitude * 10) / 10
        stakanew_SpeedCounter.Text = string.format("%.1f", currentSpeed)

        if not stakanew_SpinbotEnabled then
            local look = stakanew_Flat(stakanew_Camera.CFrame.LookVector)
            if look.Magnitude > 0.01 then
                stakanew_RootPart.CFrame = CFrame.new(stakanew_RootPart.Position, stakanew_RootPart.Position + look)
            end
        end
    else
        stakanew_Humanoid.AutoRotate = true
        local wasGrounded = stakanew_WasGrounded
        local isGrounded = stakanew_Grounded()
        if wasGrounded and not isGrounded and (tick() - stakanew_LastJumpTime > 0.5) then
            if stakanew_JumpCircleEnabled then stakanew_CreateJumpCircle(stakanew_RootPart.Position) end
            if stakanew_JumpCloneEnabled then stakanew_CreateJumpClone(stakanew_Character) end
            stakanew_LastJumpTime = tick()
        end
        stakanew_WasGrounded = isGrounded
        local fv = stakanew_Flat(stakanew_RootPart.Velocity)
        local currentSpeed = math.floor(fv.Magnitude * 10) / 10
        stakanew_SpeedCounter.Text = string.format("%.1f", currentSpeed)
    end

    if stakanew_TrailEnabled and (stakanew_RootPart.Velocity.Magnitude > 5) then
        local currentTime = tick()
        if currentTime - stakanew_LastTrailTime > stakanew_TrailInterval then
            if stakanew_LastTrailPos then
                stakanew_CreateTrail(stakanew_RootPart.Position, stakanew_LastTrailPos)
            else
                stakanew_LastTrailPos = stakanew_RootPart.Position
            end
            stakanew_LastTrailTime = currentTime
        end
    end
end

local stakanew_Connection
local function stakanew_Setup(char)
    stakanew_Character = char
    stakanew_Humanoid = char:WaitForChild("Humanoid")
    stakanew_RootPart = char:WaitForChild("HumanoidRootPart")
    stakanew_Velocity = Vector3.zero
    stakanew_IsGrounded = false
    stakanew_JumpHeld, stakanew_WishJump = false, false
    stakanew_MoveForward, stakanew_MoveRight = 0, 0
    stakanew_WasGrounded = true
    stakanew_LastJumpTime = 0
    stakanew_LastTrailPos = nil

    task.wait()
    workspace.Gravity = stakanew_Gravity

    if stakanew_NoAnimations then stakanew_DisableAnimations(char) end

    if stakanew_FirstPerson then
        stakanew_Player.CameraMode = Enum.CameraMode.LockFirstPerson
    else
        stakanew_Player.CameraMode = Enum.CameraMode.Classic
    end

    stakanew_ApplyMovementState()

    if stakanew_HatEnabled then stakanew_CreateHat() end

    if stakanew_FOVEnabled then stakanew_Camera.FieldOfView = stakanew_FOV else stakanew_Camera.FieldOfView = 70 end

    if stakanew_Connection then stakanew_Connection:Disconnect() end
    stakanew_Connection = stakanew_RunService.RenderStepped:Connect(stakanew_PhysicsStep)
end

if stakanew_Player.Character then stakanew_Setup(stakanew_Player.Character) end
stakanew_Player.CharacterAdded:Connect(stakanew_Setup)
print("stakanew's BHop + Fly + FOV + Instant Strafe Script загружен!")
