-- stakanew's BHop Script
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

local stakanew_GUI = Instance.new("ScreenGui")
stakanew_GUI.Name = "stakanew_GUI"
stakanew_GUI.ResetOnSpawn = false
stakanew_GUI.Parent = stakanew_Player:WaitForChild("PlayerGui")

local stakanew_Watermark = Instance.new("TextLabel")
stakanew_Watermark.Name = "stakanew_Watermark"
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
stakanew_SpeedCounter.Name = "stakanew_SpeedCounter"
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
stakanew_SettingsButton.Name = "stakanew_SettingsButton"
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

local stakanew_SettingsPanel = Instance.new("Frame")
stakanew_SettingsPanel.Name = "stakanew_SettingsPanel"
stakanew_SettingsPanel.Size = UDim2.new(0, 300, 0, 450)
stakanew_SettingsPanel.Position = UDim2.new(0, 80, 0.5, -225)
stakanew_SettingsPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
stakanew_SettingsPanel.Visible = false
stakanew_SettingsPanel.Parent = stakanew_GUI

local stakanew_PanelCorner = Instance.new("UICorner")
stakanew_PanelCorner.CornerRadius = UDim.new(0, 10)
stakanew_PanelCorner.Parent = stakanew_SettingsPanel

local stakanew_PanelTitle = Instance.new("TextLabel")
stakanew_PanelTitle.Name = "stakanew_PanelTitle"
stakanew_PanelTitle.Size = UDim2.new(1, -50, 0, 40)
stakanew_PanelTitle.Position = UDim2.new(0, 10, 0, 0)
stakanew_PanelTitle.BackgroundTransparency = 1
stakanew_PanelTitle.Text = "Настройки"
stakanew_PanelTitle.Font = Enum.Font.SourceSansBold
stakanew_PanelTitle.TextSize = 20
stakanew_PanelTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
stakanew_PanelTitle.Parent = stakanew_SettingsPanel

local stakanew_CollapseButton = Instance.new("TextButton")
stakanew_CollapseButton.Name = "stakanew_CollapseButton"
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
stakanew_SettingsWatermark.Name = "stakanew_SettingsWatermark"
stakanew_SettingsWatermark.Size = UDim2.new(0, 100, 0, 15)
stakanew_SettingsWatermark.Position = UDim2.new(1, -105, 1, -20)
stakanew_SettingsWatermark.BackgroundTransparency = 1
stakanew_SettingsWatermark.Text = "by stakanew"
stakanew_SettingsWatermark.Font = Enum.Font.SourceSans
stakanew_SettingsWatermark.TextSize = 10
stakanew_SettingsWatermark.TextColor3 = Color3.fromRGB(150, 150, 150)
stakanew_SettingsWatermark.TextTransparency = 0.5
stakanew_SettingsWatermark.Parent = stakanew_SettingsPanel

local stakanew_Tabs = {}
local stakanew_TabButtons = {}

local function stakanew_CreateTab(name, xPos)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 80, 0, 30)
    button.Position = UDim2.new(0, xPos, 0, 45)
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.Text = name
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 14
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Parent = stakanew_SettingsPanel
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = button
    
    return button
end

stakanew_TabButtons["BHop"] = stakanew_CreateTab("BHop", 10)
stakanew_TabButtons["Visuals"] = stakanew_CreateTab("Visuals", 95)

local stakanew_TabContainers = {}

for _, tabName in ipairs({"BHop", "Visuals"}) do
    local container = Instance.new("ScrollingFrame")
    container.Size = UDim2.new(1, -20, 1, -90)
    container.Position = UDim2.new(0, 10, 0, 80)
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
end

for name, button in pairs(stakanew_TabButtons) do
    button.MouseButton1Click:Connect(function()
        stakanew_SwitchTab(name)
    end)
end

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
            elseif name == "Цвет круга" then
                stakanew_CircleColor = colorData[2]
            elseif name == "Цвет следа" then
                stakanew_TrailColor = colorData[2]
            end
        end)
    end
end

local bhopContainer = stakanew_TabContainers["BHop"]
bhopContainer.CanvasSize = UDim2.new(0, 0, 0, 450)

local stakanew_BHopToggle, stakanew_BHopLabel = stakanew_CreateToggle("BHop", stakanew_BHopEnabled, 10, bhopContainer)

local bhopSettings = {
    {name = "Скорость на земле", var = "GroundSpeed", min = 10, max = 50},
    {name = "Скорость в воздухе", var = "AirSpeed", min = 1, max = 20},
    {name = "Ускорение на земле", var = "GroundAccel", min = 10, max = 100},
    {name = "Ускорение в воздухе", var = "AirAccel", min = 100, max = 2000},
    {name = "Сила прыжка", var = "JumpPower", min = 10, max = 200},
    {name = "Гравитация", var = "Gravity", min = 50, max = 400},
}

for i, setting in ipairs(bhopSettings) do
    local yPos = 40 + (i - 1) * 55
    local currentValue
    
    if setting.var == "GroundSpeed" then
        currentValue = stakanew_GroundSpeed
    elseif setting.var == "AirSpeed" then
        currentValue = stakanew_AirSpeed
    elseif setting.var == "GroundAccel" then
        currentValue = stakanew_GroundAccel
    elseif setting.var == "AirAccel" then
        currentValue = stakanew_AirAccel
    elseif setting.var == "JumpPower" then
        currentValue = stakanew_JumpPower
    elseif setting.var == "Gravity" then
        currentValue = stakanew_Gravity
    end
    
    local slider, label = stakanew_CreateSlider(setting.name, currentValue, setting.min, setting.max, yPos, bhopContainer)
    
    slider.FocusLost:Connect(function()
        local value = tonumber(slider.Text)
        if value then
            value = math.clamp(value, setting.min, setting.max)
            
            if setting.var == "GroundSpeed" then
                stakanew_GroundSpeed = value
            elseif setting.var == "AirSpeed" then
                stakanew_AirSpeed = value
            elseif setting.var == "GroundAccel" then
                stakanew_GroundAccel = value
            elseif setting.var == "AirAccel" then
                stakanew_AirAccel = value
            elseif setting.var == "JumpPower" then
                stakanew_JumpPower = value
            elseif setting.var == "Gravity" then
                stakanew_Gravity = value
                workspace.Gravity = value
            end
            
            label.Text = setting.name .. ": " .. tostring(value)
            slider.Text = tostring(value)
        end
    end)
end

local visualsContainer = stakanew_TabContainers["Visuals"]
visualsContainer.CanvasSize = UDim2.new(0, 0, 0, 700)

local stakanew_JumpCircleToggle, stakanew_JumpCircleLabel = stakanew_CreateToggle("Круг при прыжке", stakanew_JumpCircleEnabled, 10, visualsContainer)
local stakanew_JumpCloneToggle, stakanew_JumpCloneLabel = stakanew_CreateToggle("Копия при прыжке", stakanew_JumpCloneEnabled, 40, visualsContainer)
local stakanew_TrailToggle, stakanew_TrailLabel = stakanew_CreateToggle("След за игроком", stakanew_TrailEnabled, 70, visualsContainer)

local circleSizeSlider, circleSizeLabel = stakanew_CreateSlider("Размер круга", stakanew_CircleSize, 1, 50, 100, visualsContainer)
circleSizeSlider.FocusLost:Connect(function()
    local value = tonumber(circleSizeSlider.Text)
    if value then
        stakanew_CircleSize = math.clamp(value, 1, 50)
        circleSizeLabel.Text = "Размер круга: " .. tostring(stakanew_CircleSize)
        circleSizeSlider.Text = tostring(stakanew_CircleSize)
    end
end)

local circleDurationSlider, circleDurationLabel = stakanew_CreateSlider("Длительность круга (сек)", stakanew_CircleDuration, 0.1, 2, 155, visualsContainer)
circleDurationSlider.FocusLost:Connect(function()
    local value = tonumber(circleDurationSlider.Text)
    if value then
        stakanew_CircleDuration = math.clamp(value, 0.1, 2)
        circleDurationLabel.Text = "Длительность круга (сек): " .. tostring(stakanew_CircleDuration)
        circleDurationSlider.Text = tostring(stakanew_CircleDuration)
    end
end)

local cloneTransparencySlider, cloneTransparencyLabel = stakanew_CreateSlider("Прозрачность копии", stakanew_CloneTransparency, -1, 1, 210, visualsContainer)
cloneTransparencySlider.FocusLost:Connect(function()
    local value = tonumber(cloneTransparencySlider.Text)
    if value then
        stakanew_CloneTransparency = math.clamp(value, -1, 1)
        cloneTransparencyLabel.Text = "Прозрачность копии: " .. tostring(stakanew_CloneTransparency)
        cloneTransparencySlider.Text = tostring(stakanew_CloneTransparency)
    end
end)

local cloneDurationSlider, cloneDurationLabel = stakanew_CreateSlider("Длительность копии (сек)", stakanew_CloneDuration, 0.5, 10, 265, visualsContainer)
cloneDurationSlider.FocusLost:Connect(function()
    local value = tonumber(cloneDurationSlider.Text)
    if value then
        stakanew_CloneDuration = math.clamp(value, 0.5, 10)
        cloneDurationLabel.Text = "Длительность копии (сек): " .. tostring(stakanew_CloneDuration)
        cloneDurationSlider.Text = tostring(stakanew_CloneDuration)
    end
end)

local trailSizeSlider, trailSizeLabel = stakanew_CreateSlider("Толщина следа", stakanew_TrailSize, 0.1, 3, 320, visualsContainer)
trailSizeSlider.FocusLost:Connect(function()
    local value = tonumber(trailSizeSlider.Text)
    if value then
        stakanew_TrailSize = math.clamp(value, 0.1, 3)
        trailSizeLabel.Text = "Толщина следа: " .. tostring(stakanew_TrailSize)
        trailSizeSlider.Text = tostring(stakanew_TrailSize)
    end
end)

local trailDurationSlider, trailDurationLabel = stakanew_CreateSlider("Длительность следа (сек)", stakanew_TrailDuration, 0.1, 2, 375, visualsContainer)
trailDurationSlider.FocusLost:Connect(function()
    local value = tonumber(trailDurationSlider.Text)
    if value then
        stakanew_TrailDuration = math.clamp(value, 0.1, 2)
        trailDurationLabel.Text = "Длительность следа (сек): " .. tostring(stakanew_TrailDuration)
        trailDurationSlider.Text = tostring(stakanew_TrailDuration)
    end
end)

stakanew_CreateColorPicker("Цвет копии", 430, visualsContainer)
stakanew_CreateColorPicker("Цвет круга", 490, visualsContainer)
stakanew_CreateColorPicker("Цвет следа", 550, visualsContainer)

stakanew_BHopToggle.MouseButton1Click:Connect(function()
    stakanew_BHopEnabled = not stakanew_BHopEnabled
    stakanew_BHopToggle.Text = stakanew_BHopEnabled and "ВКЛ" or "ВЫКЛ"
    stakanew_BHopToggle.BackgroundColor3 = stakanew_BHopEnabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    
    if stakanew_Humanoid then
        if stakanew_BHopEnabled then
            stakanew_Humanoid.AutoRotate = false
            stakanew_Humanoid.WalkSpeed = 0
            stakanew_Humanoid.JumpPower = 0
            stakanew_Humanoid.JumpHeight = 0
            stakanew_Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
        else
            stakanew_Humanoid.AutoRotate = true
            stakanew_Humanoid.WalkSpeed = 20
            stakanew_Humanoid.JumpPower = 50
            stakanew_Humanoid.JumpHeight = 7.2
            stakanew_Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
        end
    end
end)

stakanew_JumpCircleToggle.MouseButton1Click:Connect(function()
    stakanew_JumpCircleEnabled = not stakanew_JumpCircleEnabled
    stakanew_JumpCircleToggle.Text = stakanew_JumpCircleEnabled and "ВКЛ" or "ВЫКЛ"
    stakanew_JumpCircleToggle.BackgroundColor3 = stakanew_JumpCircleEnabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
end)

stakanew_JumpCloneToggle.MouseButton1Click:Connect(function()
    stakanew_JumpCloneEnabled = not stakanew_JumpCloneEnabled
    stakanew_JumpCloneToggle.Text = stakanew_JumpCloneEnabled and "ВКЛ" or "ВЫКЛ"
    stakanew_JumpCloneToggle.BackgroundColor3 = stakanew_JumpCloneEnabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
end)

stakanew_TrailToggle.MouseButton1Click:Connect(function()
    stakanew_TrailEnabled = not stakanew_TrailEnabled
    stakanew_TrailToggle.Text = stakanew_TrailEnabled and "ВКЛ" or "ВЫКЛ"
    stakanew_TrailToggle.BackgroundColor3 = stakanew_TrailEnabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
end)

local function stakanew_ToggleSettings()
    stakanew_SettingsOpen = not stakanew_SettingsOpen
    stakanew_SettingsPanel.Visible = stakanew_SettingsOpen
end

stakanew_SettingsButton.MouseButton1Click:Connect(stakanew_ToggleSettings)
stakanew_CollapseButton.MouseButton1Click:Connect(stakanew_ToggleSettings)

local function stakanew_CreateJumpCircle(position)
    local circle = Instance.new("Part")
    circle.Size = Vector3.new(1, 1, 1)
    circle.Position = position - Vector3.new(0, 3, 0)
    circle.Anchored = true
    circle.CanCollide = false
    circle.CanQuery = false
    circle.CanTouch = false
    circle.Material = Enum.Material.Neon
    circle.Color = stakanew_CircleColor
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
            clonePart.Color = stakanew_CloneColor
            clonePart.Transparency = stakanew_CloneTransparency
            clonePart.Parent = workspace
            
            if partName == "Head" then
                clonePart.Shape = Enum.PartType.Ball
            end
            
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
            end
            
            task.wait()
        end
        
        for _, part in pairs(parts) do
            part:Destroy()
        end
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
    trail.Color = stakanew_TrailColor
    trail.Transparency = 0.3
    trail.Parent = workspace
    
    task.spawn(function()
        local startTime = tick()
        local duration = stakanew_TrailDuration
        
        while tick() - startTime < duration do
            local progress = (tick() - startTime) / duration
            trail.Transparency = 0.3 + progress * 0.7
            task.wait()
        end
        
        trail:Destroy()
    end)
    
    stakanew_LastTrailPos = position
end

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

stakanew_UIS.InputBegan:Connect(function(input, gp)
	local kc = input.KeyCode
	if kc == Enum.KeyCode.Space then stakanew_JumpHeld = true return end
	if gp then return end
	if kc == Enum.KeyCode.W then stakanew_MoveForward = 1
	elseif kc == Enum.KeyCode.S then stakanew_MoveForward = -1
	elseif kc == Enum.KeyCode.A then stakanew_MoveRight = -1
	elseif kc == Enum.KeyCode.D then stakanew_MoveRight = 1 end
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
			
			if stakanew_JumpCircleEnabled then
				stakanew_CreateJumpCircle(stakanew_RootPart.Position)
			end
			if stakanew_JumpCloneEnabled then
				stakanew_CreateJumpClone(stakanew_Character)
			end
		end

		local wishDir = stakanew_GetWishDir()

		if stakanew_IsGrounded then
			stakanew_Velocity = stakanew_ApplyFriction(stakanew_Velocity, dt)
			if wishDir.Magnitude > 0 then
				stakanew_Velocity = stakanew_Accelerate(stakanew_Velocity, wishDir, stakanew_GroundSpeed, stakanew_GroundAccel, dt)
			end
		elseif wishDir.Magnitude > 0 then
			stakanew_Velocity = stakanew_Accelerate(stakanew_Velocity, wishDir, stakanew_AirSpeed, stakanew_AirAccel, dt)
			stakanew_Velocity = stakanew_ApplyAirControl(stakanew_Velocity, wishDir, dt)
		end

		stakanew_RootPart.AssemblyLinearVelocity = stakanew_Velocity

		local fv = stakanew_Flat(stakanew_Velocity)
		local currentSpeed = math.floor(fv.Magnitude * 10) / 10
		stakanew_SpeedCounter.Text = string.format("%.1f", currentSpeed)

		local look = stakanew_Flat(stakanew_Camera.CFrame.LookVector)
		if look.Magnitude > 0.01 then
			stakanew_RootPart.CFrame = CFrame.new(stakanew_RootPart.Position, stakanew_RootPart.Position + look)
		end
	else
		stakanew_Humanoid.AutoRotate = true
		
		local wasGrounded = stakanew_WasGrounded
		local isGrounded = stakanew_Grounded()
		
		if wasGrounded and not isGrounded and (tick() - stakanew_LastJumpTime > 0.5) then
			if stakanew_JumpCircleEnabled then
				stakanew_CreateJumpCircle(stakanew_RootPart.Position)
			end
			if stakanew_JumpCloneEnabled then
				stakanew_CreateJumpClone(stakanew_Character)
			end
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

	if stakanew_FirstPerson then
		stakanew_Player.CameraMode = Enum.CameraMode.LockFirstPerson
	else
		stakanew_Player.CameraMode = Enum.CameraMode.Classic
	end

	if stakanew_BHopEnabled then
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

	if stakanew_Connection then stakanew_Connection:Disconnect() end
	stakanew_Connection = stakanew_RunService.RenderStepped:Connect(stakanew_PhysicsStep)
end

if stakanew_Player.Character then stakanew_Setup(stakanew_Player.Character) end
stakanew_Player.CharacterAdded:Connect(stakanew_Setup)
print("stakanew's BHop Script загружен!")
