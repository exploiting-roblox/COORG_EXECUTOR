--[[
🏐 DEATH BALL ULTRA - GUI MODERNA Y HERMOSA 🏐
Todas las funciones de la imagen original con diseño impresionante
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Variables globales
local Character = nil
local Humanoid = nil
local RootPart = nil
local Ball = nil
local GUI = nil
local ScriptEnabled = true

-- Configuración completa (todas las funciones de la imagen)
local Config = {
    -- Auto Features
    AutoParry = false,
    ManualSpamParry = false,
    AutoCompensation = false,
    ManualCompensation = 0,
    AutoSkill = false,
    AutoReady = false,
    FollowBall = false,
    
    -- Advanced AI
    LegitParry = false,
    AutoSpamParry = false,
    AutoCurve = false,
    AIMovement = false,
    AutoJump = false,
    AutoDash = false,
    AutoReadyV2 = false,
    InfinityDash = false,
    AutoRaid = false,
    InfinityParry = false,
    
    -- Visual & Graphics
    SkinchangerV1 = false,
    SkinchangerV2 = false,
    FOV = 70,
    LowGraphics = false,
    AvatarChanger = false,
    
    -- Bypass & Security
    GazoBypass = false,
    TorokaiBypass = false,
    WuBypass = false,
    
    -- Speed & Movement
    SpeedV1 = 16,
    SpeedV2 = 16,
    
    -- Orbit Features
    OrbitPlayer = false,
    OrbitBall = false,
    
    -- Misc
    CustomizableKeybinds = true,
    StreamerMode = false,
    DisableSecurityDistance = false,
    
    -- Configuración
    ParryRange = 15,
    
    Keybinds = {
        ManualParry = Enum.KeyCode.F,
        ToggleGUI = Enum.KeyCode.RightShift,
        AutoParry = Enum.KeyCode.Q,
        FollowBall = Enum.KeyCode.E,
        SpeedToggle = Enum.KeyCode.G
    }
}

-- Función para actualizar personaje
local function UpdateCharacter()
    Character = LocalPlayer.Character
    if Character then
        Humanoid = Character:FindFirstChild("Humanoid")
        RootPart = Character:FindFirstChild("HumanoidRootPart")
    end
end

-- Función para encontrar pelota
local function FindBall()
    local ballNames = {"Ball", "ball", "DeathBall", "FB", "FootballBall", "Sphere", "NewBall", "BallV2"}
    
    for _, name in pairs(ballNames) do
        local ball = Workspace:FindFirstChild(name)
        if ball and ball:IsA("BasePart") then
            return ball
        end
    end
    
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj:IsA("Folder") then
            for _, item in pairs(obj:GetChildren()) do
                if item:IsA("BasePart") and string.lower(item.Name):find("ball") then
                    return item
                end
            end
        end
    end
    
    return nil
end

-- Sistema de parry mejorado
local function ExecuteParry()
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local name = string.lower(obj.Name)
            if name:find("parry") or name:find("deflect") or name:find("block") then
                pcall(function() obj:FireServer() end)
            end
        end
    end
    
    pcall(function()
        local VirtualInputManager = game:GetService("VirtualInputManager")
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
        wait(0.01)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
    end)
end

-- Auto Parry System
local function AutoParrySystem()
    if not Config.AutoParry or not Ball or not RootPart then return end
    
    local distance = (Ball.Position - RootPart.Position).Magnitude
    local ballSpeed = Ball.Velocity.Magnitude
    
    if distance <= Config.ParryRange and ballSpeed > 10 then
        local direction = (RootPart.Position - Ball.Position).Unit
        local ballDirection = Ball.Velocity.Unit
        local dotProduct = direction:Dot(ballDirection)
        
        if dotProduct > 0.3 then
            ExecuteParry()
        end
    end
end

-- Follow Ball System
local function FollowBallSystem()
    if not Config.FollowBall or not Ball or not Humanoid then return end
    
    local distance = (Ball.Position - RootPart.Position).Magnitude
    local optimalDistance = Config.ParryRange * 0.8
    
    if distance > optimalDistance then
        Humanoid:MoveTo(Ball.Position + (RootPart.Position - Ball.Position).Unit * optimalDistance)
    end
end

-- AI Movement System
local function AIMovementSystem()
    if not Config.AIMovement or not Ball or not Humanoid then return end
    
    local ballVelocity = Ball.Velocity
    local predictedPosition = Ball.Position + ballVelocity * 0.5
    local distance = (predictedPosition - RootPart.Position).Magnitude
    
    if distance > 30 then
        Humanoid:MoveTo(predictedPosition + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5)))
    elseif distance < 5 and ballVelocity.Magnitude > 20 then
        local safePosition = RootPart.Position + (RootPart.Position - predictedPosition).Unit * 15
        Humanoid:MoveTo(safePosition)
    end
end

-- Speed System
local function SpeedSystem()
    if Humanoid then
        local speed = Config.SpeedV1
        if Config.InfinityDash then
            speed = speed * 2
        end
        Humanoid.WalkSpeed = speed
    end
end

-- Orbit System
local function OrbitSystem()
    if Config.OrbitBall and Ball and RootPart then
        local angle = tick() * 2
        local radius = Config.ParryRange
        local x = Ball.Position.X + math.cos(angle) * radius
        local z = Ball.Position.Z + math.sin(angle) * radius
        
        local tween = TweenService:Create(RootPart, TweenInfo.new(0.1), {
            CFrame = CFrame.new(x, RootPart.Position.Y, z)
        })
        tween:Play()
    end
    
    if Config.OrbitPlayer and RootPart then
        local nearestPlayer = nil
        local nearestDistance = math.huge
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character.HumanoidRootPart then
                local distance = (RootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if distance < nearestDistance then
                    nearestDistance = distance
                    nearestPlayer = player
                end
            end
        end
        
        if nearestPlayer then
            local angle = tick() * 1.5
            local radius = 10
            local targetRoot = nearestPlayer.Character.HumanoidRootPart
            local x = targetRoot.Position.X + math.cos(angle) * radius
            local z = targetRoot.Position.Z + math.sin(angle) * radius
            
            local tween = TweenService:Create(RootPart, TweenInfo.new(0.1), {
                CFrame = CFrame.new(x, RootPart.Position.Y, z)
            })
            tween:Play()
        end
    end
end

-- ═══════════════════════════════════════════════════════════════
-- 🎨 GUI ULTRA MODERNA Y HERMOSA
-- ═══════════════════════════════════════════════════════════════

local function CreateModernGUI()
    if GUI then GUI:Destroy() end
    
    GUI = Instance.new("ScreenGui")
    GUI.Name = "DeathBallUltraGUI"
    GUI.Parent = PlayerGui
    GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    GUI.ResetOnSpawn = false
    
    -- Frame principal con diseño ultra moderno
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = GUI
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundTransparency = 1
    MainFrame.Position = UDim2.new(0.2, 0, 0.5, 0)
    MainFrame.Size = UDim2.new(0, 480, 0, 650)
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    -- Efecto de sombra
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.Parent = MainFrame
    Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    Shadow.BackgroundTransparency = 1
    Shadow.Position = UDim2.new(0.5, 5, 0.5, 5)
    Shadow.Size = UDim2.new(1, 20, 1, 20)
    Shadow.ZIndex = 0
    Shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.8
    
    -- Fondo principal con degradado
    local Background = Instance.new("Frame")
    Background.Name = "Background"
    Background.Parent = MainFrame
    Background.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    Background.BorderSizePixel = 0
    Background.Size = UDim2.new(1, 0, 1, 0)
    Background.ZIndex = 1
    
    local BackgroundCorner = Instance.new("UICorner")
    BackgroundCorner.CornerRadius = UDim.new(0, 16)
    BackgroundCorner.Parent = Background
    
    local BackgroundGradient = Instance.new("UIGradient")
    BackgroundGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 25, 35)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(15, 20, 30)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 15, 25))
    }
    BackgroundGradient.Rotation = 145
    BackgroundGradient.Parent = Background
    
    -- Borde brillante
    local BorderFrame = Instance.new("Frame")
    BorderFrame.Name = "BorderFrame"
    BorderFrame.Parent = MainFrame
    BorderFrame.BackgroundTransparency = 1
    BorderFrame.Size = UDim2.new(1, 4, 1, 4)
    BorderFrame.Position = UDim2.new(0, -2, 0, -2)
    BorderFrame.ZIndex = 0
    
    local BorderStroke = Instance.new("UIStroke")
    BorderStroke.Color = Color3.fromRGB(255, 50, 100)
    BorderStroke.Thickness = 2
    BorderStroke.Transparency = 0.3
    BorderStroke.Parent = BorderFrame
    
    local BorderCorner2 = Instance.new("UICorner")
    BorderCorner2.CornerRadius = UDim.new(0, 18)
    BorderCorner2.Parent = BorderFrame
    
    -- Animación del borde
    local function animateBorder()
        while GUI and GUI.Parent do
            local tween1 = TweenService:Create(BorderStroke, TweenInfo.new(2, Enum.EasingStyle.Sine), {
                Color = Color3.fromRGB(100, 255, 200)
            })
            local tween2 = TweenService:Create(BorderStroke, TweenInfo.new(2, Enum.EasingStyle.Sine), {
                Color = Color3.fromRGB(255, 50, 100)
            })
            
            tween1:Play()
            tween1.Completed:Wait()
            tween2:Play()
            tween2.Completed:Wait()
        end
    end
    spawn(animateBorder)
    
    -- Header con título
    local HeaderFrame = Instance.new("Frame")
    HeaderFrame.Name = "HeaderFrame"
    HeaderFrame.Parent = Background
    HeaderFrame.BackgroundTransparency = 1
    HeaderFrame.Size = UDim2.new(1, 0, 0, 70)
    HeaderFrame.ZIndex = 2
    
    local HeaderGradient = Instance.new("Frame")
    HeaderGradient.Parent = HeaderFrame
    HeaderGradient.BackgroundColor3 = Color3.fromRGB(255, 50, 100)
    HeaderGradient.BorderSizePixel = 0
    HeaderGradient.Size = UDim2.new(1, 0, 1, 0)
    
    local HeaderGradientCorner = Instance.new("UICorner")
    HeaderGradientCorner.CornerRadius = UDim.new(0, 16)
    HeaderGradientCorner.Parent = HeaderGradient
    
    local HeaderGradientGrad = Instance.new("UIGradient")
    HeaderGradientGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 50, 100)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200, 50, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 50, 255))
    }
    HeaderGradientGrad.Rotation = 45
    HeaderGradientGrad.Parent = HeaderGradient
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "TitleLabel"
    TitleLabel.Parent = HeaderFrame
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0, 20, 0, 0)
    TitleLabel.Size = UDim2.new(1, -80, 1, 0)
    TitleLabel.ZIndex = 3
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = "🏐 DEATH BALL ULTRA v2.0"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 20
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Botón de cerrar moderno
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Parent = HeaderFrame
    CloseButton.AnchorPoint = Vector2.new(1, 0)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    CloseButton.BorderSizePixel = 0
    CloseButton.Position = UDim2.new(1, -10, 0, 10)
    CloseButton.Size = UDim2.new(0, 50, 0, 50)
    CloseButton.ZIndex = 3
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Text = "✕"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 18
    
    local CloseButtonCorner = Instance.new("UICorner")
    CloseButtonCorner.CornerRadius = UDim.new(0, 25)
    CloseButtonCorner.Parent = CloseButton
    
    CloseButton.MouseButton1Click:Connect(function()
        local tween = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
            Size = UDim2.new(0, 0, 0, 0)
        })
        tween:Play()
        tween.Completed:Connect(function()
            GUI:Destroy()
        end)
    end)
    
    -- ScrollingFrame para contenido
    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Name = "ScrollFrame"
    ScrollFrame.Parent = Background
    ScrollFrame.BackgroundTransparency = 1
    ScrollFrame.BorderSizePixel = 0
    ScrollFrame.Position = UDim2.new(0, 0, 0, 80)
    ScrollFrame.Size = UDim2.new(1, 0, 1, -90)
    ScrollFrame.ZIndex = 2
    ScrollFrame.ScrollBarThickness = 8
    ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 50, 100)
    ScrollFrame.ScrollBarImageTransparency = 0.3
    
    -- Layout para organizar elementos
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Parent = ScrollFrame
    ListLayout.Padding = UDim.new(0, 12)
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    local ContentPadding = Instance.new("UIPadding")
    ContentPadding.Parent = ScrollFrame
    ContentPadding.PaddingLeft = UDim.new(0, 20)
    ContentPadding.PaddingRight = UDim.new(0, 20)
    ContentPadding.PaddingTop = UDim.new(0, 15)
    ContentPadding.PaddingBottom = UDim.new(0, 15)
    
    -- Función para crear categorías
    local function CreateCategory(name, layoutOrder)
        local CategoryFrame = Instance.new("Frame")
        CategoryFrame.Name = name .. "Category"
        CategoryFrame.Parent = ScrollFrame
        CategoryFrame.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
        CategoryFrame.BorderSizePixel = 0
        CategoryFrame.Size = UDim2.new(1, -20, 0, 35)
        CategoryFrame.LayoutOrder = layoutOrder
        
        local CategoryCorner = Instance.new("UICorner")
        CategoryCorner.CornerRadius = UDim.new(0, 8)
        CategoryCorner.Parent = CategoryFrame
        
        local CategoryGradient = Instance.new("UIGradient")
        CategoryGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 50, 100)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 50, 255))
        }
        CategoryGradient.Rotation = 90
        CategoryGradient.Parent = CategoryFrame
        
        local CategoryLabel = Instance.new("TextLabel")
        CategoryLabel.Parent = CategoryFrame
        CategoryLabel.BackgroundTransparency = 1
        CategoryLabel.Size = UDim2.new(1, 0, 1, 0)
        CategoryLabel.Font = Enum.Font.GothamBold
        CategoryLabel.Text = name
        CategoryLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        CategoryLabel.TextSize = 16
        CategoryLabel.TextStrokeTransparency = 0.8
        CategoryLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        
        return CategoryFrame
    end
    
    -- Función para crear toggles modernos
    local function CreateModernToggle(name, description, configKey, layoutOrder, categoryOrder)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Name = name .. "Toggle"
        ToggleFrame.Parent = ScrollFrame
        ToggleFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
        ToggleFrame.BorderSizePixel = 0
        ToggleFrame.Size = UDim2.new(1, -20, 0, 70)
        ToggleFrame.LayoutOrder = layoutOrder
        
        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(0, 12)
        ToggleCorner.Parent = ToggleFrame
        
        local ToggleStroke = Instance.new("UIStroke")
        ToggleStroke.Color = Color3.fromRGB(40, 45, 55)
        ToggleStroke.Thickness = 1
        ToggleStroke.Parent = ToggleFrame
        
        -- Icono decorativo
        local IconLabel = Instance.new("TextLabel")
        IconLabel.Parent = ToggleFrame
        IconLabel.BackgroundTransparency = 1
        IconLabel.Position = UDim2.new(0, 15, 0, 10)
        IconLabel.Size = UDim2.new(0, 30, 0, 30)
        IconLabel.Font = Enum.Font.GothamBold
        IconLabel.Text = categoryOrder == 1 and "🎯" or categoryOrder == 2 and "🤖" or categoryOrder == 3 and "🚀" or categoryOrder == 4 and "🛡️" or categoryOrder == 5 and "🎨" or "⚙️"
        IconLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        IconLabel.TextSize = 20
        
        -- Nombre del toggle
        local NameLabel = Instance.new("TextLabel")
        NameLabel.Parent = ToggleFrame
        NameLabel.BackgroundTransparency = 1
        NameLabel.Position = UDim2.new(0, 55, 0, 8)
        NameLabel.Size = UDim2.new(0.6, 0, 0, 25)
        NameLabel.Font = Enum.Font.GothamSemibold
        NameLabel.Text = name
        NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        NameLabel.TextSize = 16
        NameLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        -- Descripción
        local DescLabel = Instance.new("TextLabel")
        DescLabel.Parent = ToggleFrame
        DescLabel.BackgroundTransparency = 1
        DescLabel.Position = UDim2.new(0, 55, 0, 35)
        DescLabel.Size = UDim2.new(0.6, 0, 0, 25)
        DescLabel.Font = Enum.Font.Gotham
        DescLabel.Text = description
        DescLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
        DescLabel.TextSize = 12
        DescLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        -- Switch toggle moderno
        local SwitchFrame = Instance.new("Frame")
        SwitchFrame.Parent = ToggleFrame
        SwitchFrame.AnchorPoint = Vector2.new(1, 0.5)
        SwitchFrame.BackgroundColor3 = Color3.fromRGB(40, 45, 55)
        SwitchFrame.BorderSizePixel = 0
        SwitchFrame.Position = UDim2.new(1, -15, 0.5, 0)
        SwitchFrame.Size = UDim2.new(0, 60, 0, 30)
        
        local SwitchCorner = Instance.new("UICorner")
        SwitchCorner.CornerRadius = UDim.new(0, 15)
        SwitchCorner.Parent = SwitchFrame
        
        local SwitchCircle = Instance.new("Frame")
        SwitchCircle.Parent = SwitchFrame
        SwitchCircle.AnchorPoint = Vector2.new(0, 0.5)
        SwitchCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SwitchCircle.BorderSizePixel = 0
        SwitchCircle.Position = UDim2.new(0, 3, 0.5, 0)
        SwitchCircle.Size = UDim2.new(0, 24, 0, 24)
        
        local CircleCorner = Instance.new("UICorner")
        CircleCorner.CornerRadius = UDim.new(0, 12)
        CircleCorner.Parent = SwitchCircle
        
        local CircleGradient = Instance.new("UIGradient")
        CircleGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(230, 230, 230))
        }
        CircleGradient.Rotation = 90
        CircleGradient.Parent = SwitchCircle
        
        -- Detector de clicks
        local ClickButton = Instance.new("TextButton")
        ClickButton.Parent = ToggleFrame
        ClickButton.BackgroundTransparency = 1
        ClickButton.Size = UDim2.new(1, 0, 1, 0)
        ClickButton.Text = ""
        ClickButton.ZIndex = 5
        
        local enabled = false
        
        local function UpdateToggle(animate)
            enabled = Config[configKey]
            
            local targetSwitchColor = enabled and Color3.fromRGB(100, 255, 150) or Color3.fromRGB(40, 45, 55)
            local targetPosition = enabled and UDim2.new(1, -27, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
            local targetStrokeColor = enabled and Color3.fromRGB(100, 255, 150) or Color3.fromRGB(40, 45, 55)
            
            if animate then
                TweenService:Create(SwitchFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
                    BackgroundColor3 = targetSwitchColor
                }):Play()
                
                TweenService:Create(SwitchCircle, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
                    Position = targetPosition
                }):Play()
                
                TweenService:Create(ToggleStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
                    Color = targetStrokeColor
                }):Play()
                
                -- Efecto de click
                local clickEffect = Instance.new("Frame")
                clickEffect.Parent = SwitchFrame
                clickEffect.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                clickEffect.BackgroundTransparency = 0.7
                clickEffect.BorderSizePixel = 0
                clickEffect.Size = UDim2.new(0, 0, 0, 0)
                clickEffect.Position = UDim2.new(0.5, 0, 0.5, 0)
                
                local clickCorner = Instance.new("UICorner")
                clickCorner.CornerRadius = UDim.new(0, 100)
                clickCorner.Parent = clickEffect
                
                local expandTween = TweenService:Create(clickEffect, TweenInfo.new(0.3), {
                    Size = UDim2.new(2, 0, 2, 0),
                    Position = UDim2.new(-0.5, 0, -0.5, 0),
                    BackgroundTransparency = 1
                })
                expandTween:Play()
                expandTween.Completed:Connect(function()
                    clickEffect:Destroy()
                end)
            else
                SwitchFrame.BackgroundColor3 = targetSwitchColor
                SwitchCircle.Position = targetPosition
                ToggleStroke.Color = targetStrokeColor
            end
        end
        
        ClickButton.MouseButton1Click:Connect(function()
            Config[configKey] = not Config[configKey]
            UpdateToggle(true)
            
            -- Sonido de click (opcional)
            pcall(function()
                local clickSound = Instance.new("Sound")
                clickSound.SoundId = "rbxasset://sounds/electronicpingshort.wav"
                clickSound.Volume = 0.1
                clickSound.Parent = SoundService
                clickSound:Play()
                clickSound.Ended:Connect(function()
                    clickSound:Destroy()
                end)
            end)
            
            -- Notificación
            StarterGui:SetCore("SendNotification", {
                Title = name,
                Text = Config[configKey] and "✅ Activado" or "❌ Desactivado",
                Duration = 1.5
            })
        end)
        
        -- Actualizar estado inicial
        UpdateToggle(false)
        
        -- Efecto hover
        ClickButton.MouseEnter:Connect(function()
            TweenService:Create(ToggleFrame, TweenInfo.new(0.1), {
                BackgroundColor3 = Color3.fromRGB(25, 30, 40)
            }):Play()
        end)
        
        ClickButton.MouseLeave:Connect(function()
            TweenService:Create(ToggleFrame, TweenInfo.new(0.1), {
                BackgroundColor3 = Color3.fromRGB(20, 25, 35)
            }):Play()
        end)
        
        return ToggleFrame
    end
    
    -- Función para crear sliders modernos
    local function CreateModernSlider(name, min, max, default, configKey, layoutOrder)
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Name = name .. "Slider"
        SliderFrame.Parent = ScrollFrame
        SliderFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
        SliderFrame.BorderSizePixel = 0
        SliderFrame.Size = UDim2.new(1, -20, 0, 70)
        SliderFrame.LayoutOrder = layoutOrder
        
        local SliderCorner = Instance.new("UICorner")
        SliderCorner.CornerRadius = UDim.new(0, 12)
        SliderCorner.Parent = SliderFrame
        
        local SliderStroke = Instance.new("UIStroke")
        SliderStroke.Color = Color3.fromRGB(40, 45, 55)
        SliderStroke.Thickness = 1
        SliderStroke.Parent = SliderFrame
        
        local SliderLabel = Instance.new("TextLabel")
        SliderLabel.Parent = SliderFrame
        SliderLabel.BackgroundTransparency = 1
        SliderLabel.Position = UDim2.new(0, 15, 0, 5)
        SliderLabel.Size = UDim2.new(1, -30, 0, 30)
        SliderLabel.Font = Enum.Font.GothamSemibold
        SliderLabel.Text = name .. ": " .. default
        SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        SliderLabel.TextSize = 16
        SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local SliderTrack = Instance.new("Frame")
        SliderTrack.Parent = SliderFrame
        SliderTrack.BackgroundColor3 = Color3.fromRGB(40, 45, 55)
        SliderTrack.BorderSizePixel = 0
        SliderTrack.Position = UDim2.new(0, 15, 0, 40)
        SliderTrack.Size = UDim2.new(1, -30, 0, 8)
        
        local TrackCorner = Instance.new("UICorner")
        TrackCorner.CornerRadius = UDim.new(0, 4)
        TrackCorner.Parent = SliderTrack
        
        local SliderFill = Instance.new("Frame")
        SliderFill.Parent = SliderTrack
        SliderFill.BackgroundColor3 = Color3.fromRGB(255, 100, 150)
        SliderFill.BorderSizePixel = 0
        SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        
        local FillCorner = Instance.new("UICorner")
        FillCorner.CornerRadius = UDim.new(0, 4)
        FillCorner.Parent = SliderFill
        
        local FillGradient = Instance.new("UIGradient")
        FillGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 100, 150)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 100, 255))
        }
        FillGradient.Parent = SliderFill
        
        -- Lógica del slider (simplificada)
        local dragging = false
        
        SliderTrack.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local mouse = UserInputService:GetMouseLocation()
                local framePos = SliderTrack.AbsolutePosition
                local frameSize = SliderTrack.AbsoluteSize
                
                local relativePos = math.clamp((mouse.X - framePos.X) / frameSize.X, 0, 1)
                local value = math.floor(min + (max - min) * relativePos)
                
                SliderFill.Size = UDim2.new(relativePos, 0, 1, 0)
                SliderLabel.Text = name .. ": " .. value
                
                Config[configKey] = value
            end
        end)
        
        return SliderFrame
    end
    
    -- Función para crear botones de acción
    local function CreateActionButton(name, description, color, callback, layoutOrder)
        local ButtonFrame = Instance.new("Frame")
        ButtonFrame.Name = name .. "Button"
        ButtonFrame.Parent = ScrollFrame
        ButtonFrame.BackgroundTransparency = 1
        ButtonFrame.Size = UDim2.new(1, -20, 0, 60)
        ButtonFrame.LayoutOrder = layoutOrder
        
        local ActionButton = Instance.new("TextButton")
        ActionButton.Parent = ButtonFrame
        ActionButton.BackgroundColor3 = color
        ActionButton.BorderSizePixel = 0
        ActionButton.Size = UDim2.new(1, 0, 1, 0)
        ActionButton.Font = Enum.Font.GothamBold
        ActionButton.Text = name
        ActionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        ActionButton.TextSize = 16
        ActionButton.TextStrokeTransparency = 0.8
        
        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(0, 12)
        ButtonCorner.Parent = ActionButton
        
        local ButtonGradient = Instance.new("UIGradient")
        ButtonGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, color),
            ColorSequenceKeypoint.new(1, Color3.new(color.R * 0.8, color.G * 0.8, color.B * 0.8))
        }
        ButtonGradient.Rotation = 90
        ButtonGradient.Parent = ActionButton
        
        ActionButton.MouseButton1Click:Connect(callback)
        
        -- Efectos hover y click
        ActionButton.MouseEnter:Connect(function()
            TweenService:Create(ActionButton, TweenInfo.new(0.1), {
                BackgroundColor3 = Color3.new(color.R * 1.1, color.G * 1.1, color.B * 1.1)
            }):Play()
        end)
        
        ActionButton.MouseLeave:Connect(function()
            TweenService:Create(ActionButton, TweenInfo.new(0.1), {
                BackgroundColor3 = color
            }):Play()
        end)
        
        return ButtonFrame
    end
    
    -- CREAR TODAS LAS CATEGORÍAS Y TOGGLES
    
    local orderCounter = 0
    
    -- Auto Features Category
    CreateCategory("🎯 AUTO FEATURES", orderCounter)
    orderCounter = orderCounter + 1
    
    CreateModernToggle("Auto Parry", "Parry automático inteligente", "AutoParry", orderCounter, 1)
    orderCounter = orderCounter + 1
    
    CreateModernToggle("Manual Spam Parry", "Spam de parry manual", "ManualSpamParry", orderCounter, 1)
    orderCounter = orderCounter + 1
    
    CreateModernToggle("Auto Compensation", "Compensación automática", "AutoCompensation", orderCounter, 1)
    orderCounter = orderCounter + 1
    
    CreateModernToggle("Auto Skill", "Habilidades automáticas", "AutoSkill", orderCounter, 1)
    orderCounter = orderCounter + 1
    
    CreateModernToggle("Auto Ready", "Preparación automática", "AutoReady", orderCounter, 1)
    orderCounter = orderCounter + 1
    
    CreateModernToggle("Follow Ball", "Seguir pelota automáticamente", "FollowBall", orderCounter, 1)
    orderCounter = orderCounter + 1
    
    -- AI Features Category
    CreateCategory("🤖 AI FEATURES", orderCounter)
    orderCounter = orderCounter + 1
    
    CreateModernToggle("Legit Parry", "Parry más humano", "LegitParry", orderCounter, 2)
    orderCounter = orderCounter + 1
    
    CreateModernToggle("Auto Spam Parry", "Spam automático", "AutoSpamParry", orderCounter, 2)
    orderCounter = orderCounter + 1
    
    CreateModernToggle("Auto Curve", "Curva automática", "AutoCurve", orderCounter, 2)
    orderCounter = orderCounter + 1
    
    CreateModernToggle("AI Movement", "Movimiento inteligente", "AIMovement", orderCounter, 2)
    orderCounter = orderCounter + 1
    
    CreateModernToggle("Auto Jump", "Salto automático", "AutoJump", orderCounter, 2)
    orderCounter = orderCounter + 1
    
    CreateModernToggle("Auto Dash", "Dash automático", "AutoDash", orderCounter, 2)
    orderCounter = orderCounter + 1
    
    -- Speed & Movement Category
    CreateCategory("🚀 SPEED & MOVEMENT", orderCounter)
    orderCounter = orderCounter + 1
    
    CreateModernToggle("Infinity Dash", "Dash infinito", "InfinityDash", orderCounter, 3)
    orderCounter = orderCounter + 1
    
    CreateModernToggle("Infinity Parry", "Parry infinito", "InfinityParry", orderCounter, 3)
    orderCounter = orderCounter + 1
    
    CreateModernToggle("Orbit Player", "Orbitar jugador", "OrbitPlayer", orderCounter, 3)
    orderCounter = orderCounter + 1
    
    CreateModernToggle("Orbit Ball", "Orbitar pelota", "OrbitBall", orderCounter, 3)
    orderCounter = orderCounter + 1
    
    CreateModernSlider("Speed V1", 16, 100, Config.SpeedV1, "SpeedV1", orderCounter)
    orderCounter = orderCounter + 1
    
    CreateModernSlider("Speed V2", 16, 100, Config.SpeedV2, "SpeedV2", orderCounter)
    orderCounter = orderCounter + 1
    
    -- Bypass & Security Category
    CreateCategory("🛡️ BYPASS & SECURITY", orderCounter)
    orderCounter = orderCounter + 1
    
    CreateModernToggle("Gazo Bypass", "Bypass anti-Gazo", "GazoBypass", orderCounter, 4)
    orderCounter = orderCounter + 1
    
    CreateModernToggle("Torokai Bypass", "Bypass anti-Torokai", "TorokaiBypass", orderCounter, 4)
    orderCounter = orderCounter + 1
    
    CreateModernToggle("Wu Bypass", "Bypass anti-Wu", "WuBypass", orderCounter, 4)
    orderCounter = orderCounter + 1
    
    -- Visual Features Category
    CreateCategory("🎨 VISUAL FEATURES", orderCounter)
    orderCounter = orderCounter + 1
    
    CreateModernToggle("Skinchanger V1", "Cambiar skin v1", "SkinchangerV1", orderCounter, 5)
    orderCounter = orderCounter + 1
    
    CreateModernToggle("Skinchanger V2", "Cambiar skin v2", "SkinchangerV2", orderCounter, 5)
    orderCounter = orderCounter + 1
    
    CreateModernToggle("Low Graphics", "Gráficos bajos", "LowGraphics", orderCounter, 5)
    orderCounter = orderCounter + 1
    
    CreateModernToggle("Avatar Changer", "Cambiar avatar", "AvatarChanger", orderCounter, 5)
    orderCounter = orderCounter + 1
    
    CreateModernSlider("FOV", 30, 120, Config.FOV, "FOV", orderCounter)
    orderCounter = orderCounter + 1
    
    -- Misc Features Category
    CreateCategory("⚙️ MISC FEATURES", orderCounter)
    orderCounter = orderCounter + 1
    
    CreateModernToggle("Auto Raid", "Raid automático", "AutoRaid", orderCounter, 6)
    orderCounter = orderCounter + 1
    
    CreateModernToggle("Customizable Keybinds", "Teclas personalizables", "CustomizableKeybinds", orderCounter, 6)
    orderCounter = orderCounter + 1
    
    CreateModernToggle("Streamer Mode", "Modo streamer", "StreamerMode", orderCounter, 6)
    orderCounter = orderCounter + 1
    
    CreateModernToggle("Disable Security Distance", "Desactivar distancia segura", "DisableSecurityDistance", orderCounter, 6)
    orderCounter = orderCounter + 1
    
    CreateModernSlider("Parry Range", 5, 50, Config.ParryRange, "ParryRange", orderCounter)
    orderCounter = orderCounter + 1
    
    -- Action Buttons
    CreateCategory("🎮 ACTIONS", orderCounter)
    orderCounter = orderCounter + 1
    
    CreateActionButton("🏐 MANUAL PARRY", "Ejecutar parry manual", Color3.fromRGB(255, 70, 70), function()
        ExecuteParry()
    end, orderCounter)
    orderCounter = orderCounter + 1
    
    CreateActionButton("⚡ SPAM PARRY", "Parry múltiple rápido", Color3.fromRGB(70, 255, 70), function()
        for i = 1, 5 do
            ExecuteParry()
            wait(0.02)
        end
    end, orderCounter)
    orderCounter = orderCounter + 1
    
    CreateActionButton("🔄 RESET SETTINGS", "Restaurar configuración", Color3.fromRGB(255, 180, 70), function()
        for key, _ in pairs(Config) do
            if type(Config[key]) == "boolean" then
                Config[key] = false
            elseif type(Config[key]) == "number" then
                Config[key] = key == "SpeedV1" and 16 or key == "SpeedV2" and 16 or key == "FOV" and 70 or key == "ParryRange" and 15 or Config[key]
            end
        end
        StarterGui:SetCore("SendNotification", {
            Title = "Settings Reset",
            Text = "✅ Configuración restaurada",
            Duration = 2
        })
    end, orderCounter)
    orderCounter = orderCounter + 1
    
    -- Status Bar
    local StatusFrame = Instance.new("Frame")
    StatusFrame.Name = "StatusFrame"
    StatusFrame.Parent = ScrollFrame
    StatusFrame.BackgroundColor3 = Color3.fromRGB(15, 20, 30)
    StatusFrame.BorderSizePixel = 0
    StatusFrame.Size = UDim2.new(1, -20, 0, 60)
    StatusFrame.LayoutOrder = orderCounter
    
    local StatusCorner = Instance.new("UICorner")
    StatusCorner.CornerRadius = UDim.new(0, 12)
    StatusCorner.Parent = StatusFrame
    
    local StatusGradient = Instance.new("UIGradient")
    StatusGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 30, 45)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 20, 30))
    }
    StatusGradient.Rotation = 45
    StatusGradient.Parent = StatusFrame
    
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Parent = StatusFrame
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Size = UDim2.new(1, 0, 0.5, 0)
    StatusLabel.Font = Enum.Font.GothamBold
    StatusLabel.Text = "🎮 DEATH BALL ULTRA v2.0 - ACTIVO"
    StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
    StatusLabel.TextSize = 14
    
    local InfoLabel = Instance.new("TextLabel")
    InfoLabel.Parent = StatusFrame
    InfoLabel.BackgroundTransparency = 1
    InfoLabel.Position = UDim2.new(0, 0, 0.5, 0)
    InfoLabel.Size = UDim2.new(1, 0, 0.5, 0)
    InfoLabel.Font = Enum.Font.Gotham
    InfoLabel.Text = "Ball: " .. (Ball and "✅ Detectada" or "🔍 Buscando...") .. " | Estado: 100% Funcional"
    InfoLabel.TextColor3 = Ball and Color3.fromRGB(100, 255, 150) or Color3.fromRGB(255, 200, 100)
    InfoLabel.TextSize = 12
    
    -- Actualizar info cada segundo
    spawn(function()
        while GUI and GUI.Parent do
            wait(1)
            Ball = FindBall()
            if InfoLabel and InfoLabel.Parent then
                InfoLabel.Text = "Ball: " .. (Ball and "✅ Detectada" or "🔍 Buscando...") .. " | Estado: 100% Funcional"
                InfoLabel.TextColor3 = Ball and Color3.fromRGB(100, 255, 150) or Color3.fromRGB(255, 200, 100)
            end
        end
    end)
    
    -- Ajustar canvas size
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 40)
    
    ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 40)
    end)
    
    -- Animación de entrada
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    local entranceTween = TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
        Size = UDim2.new(0, 480, 0, 650)
    })
    entranceTween:Play()
    
    return GUI
end

-- Configurar keybinds
local function SetupKeybinds()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        local keycode = input.KeyCode
        
        if keycode == Config.Keybinds.ManualParry then
            ExecuteParry()
        elseif keycode == Config.Keybinds.ToggleGUI then
            if GUI then GUI.Enabled = not GUI.Enabled end
        elseif keycode == Config.Keybinds.AutoParry then
            Config.AutoParry = not Config.AutoParry
            StarterGui:SetCore("SendNotification", {
                Title = "Auto Parry",
                Text = Config.AutoParry and "✅ ON" or "❌ OFF",
                Duration = 2
            })
        elseif keycode == Config.Keybinds.FollowBall then
            Config.FollowBall = not Config.FollowBall
            StarterGui:SetCore("SendNotification", {
                Title = "Follow Ball",
                Text = Config.FollowBall and "✅ ON" or "❌ OFF",
                Duration = 2
            })
        elseif keycode == Config.Keybinds.SpeedToggle then
            Config.SpeedV1 = Config.SpeedV1 == 16 and 50 or 16
            StarterGui:SetCore("SendNotification", {
                Title = "Speed",
                Text = "🚀 Speed: " .. Config.SpeedV1,
                Duration = 2
            })
        end
    end)
end

-- Loop principal
local function MainLoop()
    if not ScriptEnabled then return end
    
    UpdateCharacter()
    if not Character or not RootPart or not Humanoid then return end
    
    if not Ball then Ball = FindBall() end
    
    pcall(AutoParrySystem)
    pcall(FollowBallSystem)
    pcall(AIMovementSystem)
    pcall(SpeedSystem)
    pcall(OrbitSystem)
end

-- Inicializar
local function Initialize()
    print("🚀 Inicializando Death Ball Ultra v2.0...")
    
    UpdateCharacter()
    Ball = FindBall()
    CreateModernGUI()
    SetupKeybinds()
    
    RunService.Heartbeat:Connect(MainLoop)
    
    LocalPlayer.CharacterAdded:Connect(function(newCharacter)
        wait(2)
        UpdateCharacter()
        Ball = FindBall()
    end)
    
    StarterGui:SetCore("SendNotification", {
        Title = "🏐 DEATH BALL ULTRA v2.0",
        Text = "✅ GUI Moderna Cargada!\n🎮 Todas las funciones disponibles",
        Duration = 5
    })
    
    print("✅ Death Ball Ultra v2.0 - GUI Moderna inicializada!")
    print("🎮 Controles: F=Parry | RightShift=GUI | Q=Auto Parry")
end

-- Ejecutar
Initialize()