--[[
🏐 DEATH BALL ULTRA - VERSIÓN FUNCIONAL DIRECTA 🏐
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Variables globales
local Character = nil
local Humanoid = nil
local RootPart = nil
local Ball = nil
local GUI = nil
local ScriptEnabled = true

-- Configuración
local Config = {
    AutoParry = false,
    FollowBall = false,
    AIMovement = false,
    AutoSkill = false,
    ParryRange = 15,
    Speed = 16,
    LowGraphics = false,
    InfinityDash = false,
    OrbitBall = false,
    Keybinds = {
        ManualParry = Enum.KeyCode.F,
        ToggleGUI = Enum.KeyCode.RightShift,
        AutoParry = Enum.KeyCode.Q,
        FollowBall = Enum.KeyCode.E,
        SpeedToggle = Enum.KeyCode.G,
        AIMovement = Enum.KeyCode.R
    }
}

-- Función para actualizar referencias del personaje
local function UpdateCharacter()
    Character = LocalPlayer.Character
    if Character then
        Humanoid = Character:FindFirstChild("Humanoid")
        RootPart = Character:FindFirstChild("HumanoidRootPart")
    end
end

-- Función para encontrar la pelota
local function FindBall()
    local ballNames = {"Ball", "ball", "DeathBall", "FB", "FootballBall", "Sphere"}
    
    for _, name in pairs(ballNames) do
        local ball = Workspace:FindFirstChild(name)
        if ball and ball:IsA("BasePart") then
            return ball
        end
    end
    
    -- Buscar en carpetas
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

-- Función para hacer parry
local function ExecuteParry()
    -- Método 1: Remotes
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local name = string.lower(obj.Name)
            if name:find("parry") or name:find("deflect") or name:find("block") then
                pcall(function() obj:FireServer() end)
            end
        end
    end
    
    -- Método 2: Virtual Input
    pcall(function()
        local VirtualInputManager = game:GetService("VirtualInputManager")
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
        wait(0.01)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
    end)
end

-- Sistema de Auto Parry
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

-- Sistema de Follow Ball
local function FollowBallSystem()
    if not Config.FollowBall or not Ball or not Humanoid then return end
    
    local distance = (Ball.Position - RootPart.Position).Magnitude
    local optimalDistance = Config.ParryRange * 0.8
    
    if distance > optimalDistance then
        Humanoid:MoveTo(Ball.Position + (RootPart.Position - Ball.Position).Unit * optimalDistance)
    end
end

-- Sistema de AI Movement
local function AIMovementSystem()
    if not Config.AIMovement or not Ball or not Humanoid then return end
    
    local ballVelocity = Ball.Velocity
    local predictedPosition = Ball.Position + ballVelocity * 0.5
    local distance = (predictedPosition - RootPart.Position).Magnitude
    
    if distance > 30 then
        -- Acercarse si está muy lejos
        Humanoid:MoveTo(predictedPosition + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5)))
    elseif distance < 5 and ballVelocity.Magnitude > 20 then
        -- Alejarse si está muy cerca y la pelota es rápida
        local safePosition = RootPart.Position + (RootPart.Position - predictedPosition).Unit * 15
        Humanoid:MoveTo(safePosition)
    end
end

-- Sistema de velocidad
local function SpeedSystem()
    if Humanoid then
        Humanoid.WalkSpeed = Config.Speed
        if Config.InfinityDash then
            Humanoid.WalkSpeed = Config.Speed * 2
        end
    end
end

-- Sistema de Orbit
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
end

-- Crear GUI simple
local function CreateGUI()
    if GUI then GUI:Destroy() end
    
    GUI = Instance.new("ScreenGui")
    GUI.Name = "DeathBallGUI"
    GUI.Parent = PlayerGui
    
    local Frame = Instance.new("Frame")
    Frame.Parent = GUI
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Frame.BorderSizePixel = 2
    Frame.BorderColor3 = Color3.fromRGB(255, 0, 0)
    Frame.Position = UDim2.new(0.05, 0, 0.1, 0)
    Frame.Size = UDim2.new(0, 300, 0, 400)
    Frame.Active = true
    Frame.Draggable = true
    
    local Title = Instance.new("TextLabel")
    Title.Parent = Frame
    Title.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    Title.BorderSizePixel = 0
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "🏐 DEATH BALL ULTRA 🏐"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextScaled = true
    
    local function CreateToggle(name, yPos, configKey)
        local Toggle = Instance.new("TextButton")
        Toggle.Parent = Frame
        Toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        Toggle.BorderSizePixel = 1
        Toggle.BorderColor3 = Color3.fromRGB(100, 100, 100)
        Toggle.Position = UDim2.new(0.05, 0, 0, yPos)
        Toggle.Size = UDim2.new(0.9, 0, 0, 35)
        Toggle.Font = Enum.Font.Gotham
        Toggle.Text = name .. ": OFF"
        Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        Toggle.TextScaled = true
        
        Toggle.MouseButton1Click:Connect(function()
            Config[configKey] = not Config[configKey]
            Toggle.Text = name .. ": " .. (Config[configKey] and "ON" or "OFF")
            Toggle.BackgroundColor3 = Config[configKey] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 40, 40)
        end)
    end
    
    CreateToggle("Auto Parry", 50, "AutoParry")
    CreateToggle("Follow Ball", 90, "FollowBall")
    CreateToggle("AI Movement", 130, "AIMovement")
    CreateToggle("Auto Skill", 170, "AutoSkill")
    CreateToggle("Infinity Dash", 210, "InfinityDash")
    CreateToggle("Orbit Ball", 250, "OrbitBall")
    
    -- Botón de parry manual
    local ManualParryBtn = Instance.new("TextButton")
    ManualParryBtn.Parent = Frame
    ManualParryBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    ManualParryBtn.BorderSizePixel = 0
    ManualParryBtn.Position = UDim2.new(0.05, 0, 0, 300)
    ManualParryBtn.Size = UDim2.new(0.9, 0, 0, 40)
    ManualParryBtn.Font = Enum.Font.GothamBold
    ManualParryBtn.Text = "🏐 MANUAL PARRY"
    ManualParryBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ManualParryBtn.TextScaled = true
    
    ManualParryBtn.MouseButton1Click:Connect(function()
        ExecuteParry()
    end)
    
    -- Status
    local Status = Instance.new("TextLabel")
    Status.Parent = Frame
    Status.BackgroundTransparency = 1
    Status.Position = UDim2.new(0.05, 0, 0, 350)
    Status.Size = UDim2.new(0.9, 0, 0, 40)
    Status.Font = Enum.Font.Gotham
    Status.Text = "Status: " .. (Ball and "Ball Found ✅" or "Searching Ball...")
    Status.TextColor3 = Ball and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 0)
    Status.TextScaled = true
    
    -- Actualizar status cada segundo
    spawn(function()
        while GUI and GUI.Parent do
            wait(1)
            if Status and Status.Parent then
                Ball = FindBall()
                Status.Text = "Status: " .. (Ball and "Ball Found ✅" or "Searching Ball...")
                Status.TextColor3 = Ball and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 0)
            end
        end
    end)
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
        elseif keycode == Config.Keybinds.AIMovement then
            Config.AIMovement = not Config.AIMovement
            StarterGui:SetCore("SendNotification", {
                Title = "AI Movement",
                Text = Config.AIMovement and "🤖 ON" or "❌ OFF",
                Duration = 2
            })
        elseif keycode == Config.Keybinds.SpeedToggle then
            Config.Speed = Config.Speed == 16 and 50 or 16
            StarterGui:SetCore("SendNotification", {
                Title = "Speed",
                Text = "🚀 Speed: " .. Config.Speed,
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
    print("🚀 Inicializando Death Ball Ultra...")
    
    UpdateCharacter()
    Ball = FindBall()
    CreateGUI()
    SetupKeybinds()
    
    RunService.Heartbeat:Connect(MainLoop)
    
    LocalPlayer.CharacterAdded:Connect(function(newCharacter)
        wait(2)
        UpdateCharacter()
        Ball = FindBall()
    end)
    
    StarterGui:SetCore("SendNotification", {
        Title = "🏐 DEATH BALL ULTRA",
        Text = "✅ Script cargado!\n🎮 F=Parry | Q=Auto Parry | E=Follow Ball",
        Duration = 5
    })
    
    print("✅ Death Ball Ultra iniciado correctamente!")
    print("🎮 Controles: F=Parry | RightShift=GUI | Q=Auto Parry")
    print("🏐 Ball detectada:", Ball and Ball.Name or "Buscando...")
end

-- Ejecutar
Initialize()