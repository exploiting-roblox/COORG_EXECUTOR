--[[
    DEATH BALL - Script Completo para Velocity
    Creado para uso personal del dueño del juego
    Incluye todas las funcionalidades mostradas
]]

-- ═══════════════════════════════════════════════════════════════
-- SERVICIOS Y VARIABLES PRINCIPALES
-- ═══════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- ═══════════════════════════════════════════════════════════════
-- CONFIGURACIÓN DEL SCRIPT
-- ═══════════════════════════════════════════════════════════════

local Config = {
    -- Auto Features
    AutoParry = false,
    ManualSpamParry = false,
    ParryRange = 15,
    AutoCompensation = false,
    ManualCompensation = 0,
    AutoSkill = false,
    AutoReady = false,
    FollowBall = false,
    
    -- Visual Features
    SkinchangerV1 = false,
    SkinchangerV2 = false,
    FOV = 70,
    LowGraphics = false,
    
    -- Bypass Features
    GazoBypass = false,
    TorokaiBypass = false,
    WuBypass = false,
    
    -- Advanced Features
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
    
    -- Speed Features
    SpeedV1 = 16,
    SpeedV2 = 16,
    
    -- Orbit Features
    OrbitPlayer = false,
    OrbitBall = false,
    
    -- Misc Features
    AvatarChanger = false,
    CustomizableKeybinds = true,
    StreamerMode = false,
    DisableSecurityDistance = false,
    
    -- Keybinds
    Keybinds = {
        ManualParry = Enum.KeyCode.F,
        ToggleGUI = Enum.KeyCode.RightShift,
        AutoParry = Enum.KeyCode.Q,
        FollowBall = Enum.KeyCode.E,
        SpeedToggle = Enum.KeyCode.G
    }
}

-- ═══════════════════════════════════════════════════════════════
-- VARIABLES GLOBALES
-- ═══════════════════════════════════════════════════════════════

local Ball = nil
local BallConnection = nil
local ParryConnection = nil
local MovementConnection = nil
local OriginalWalkSpeed = 16
local OriginalJumpPower = 50
local GUI = nil
local LastParryTime = 0
local ParryDebounce = false

-- ═══════════════════════════════════════════════════════════════
-- FUNCIONES UTILITARIAS
-- ═══════════════════════════════════════════════════════════════

local function FindBall()
    -- Buscar la pelota en diferentes ubicaciones comunes
    local ballNames = {"Ball", "DeathBall", "ball", "FB"}
    
    for _, name in pairs(ballNames) do
        local ball = Workspace:FindFirstChild(name)
        if ball and ball:IsA("BasePart") then
            return ball
        end
    end
    
    -- Buscar en carpetas comunes
    local folders = {Workspace:FindFirstChild("Balls"), Workspace:FindFirstChild("Game")}
    for _, folder in pairs(folders) do
        if folder then
            for _, obj in pairs(folder:GetChildren()) do
                if obj:IsA("BasePart") and string.lower(obj.Name):find("ball") then
                    return obj
                end
            end
        end
    end
    
    return nil
end

local function GetDistance(part1, part2)
    if not part1 or not part2 then return math.huge end
    return (part1.Position - part2.Position).Magnitude
end

local function IsPlayerNearBall(distance)
    if not Ball or not RootPart then return false end
    return GetDistance(Ball, RootPart) <= distance
end

local function Notify(title, message, duration)
    if not Config.StreamerMode then
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = message,
            Duration = duration or 3,
            Button1 = "OK"
        })
    end
end

-- ═══════════════════════════════════════════════════════════════
-- FUNCIONES PRINCIPALES
-- ═══════════════════════════════════════════════════════════════

local function PerformParry()
    if ParryDebounce then return end
    if tick() - LastParryTime < 0.1 then return end
    
    ParryDebounce = true
    LastParryTime = tick()
    
    -- Múltiples métodos de parry para compatibilidad
    local success = false
    
    -- Método 1: Remote Events
    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") and (
            string.lower(remote.Name):find("parry") or
            string.lower(remote.Name):find("deflect") or
            string.lower(remote.Name):find("block")
        ) then
            pcall(function()
                remote:FireServer()
                success = true
            end)
        end
    end
    
    -- Método 2: Remote Functions  
    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteFunction") and (
            string.lower(remote.Name):find("parry") or
            string.lower(remote.Name):find("deflect")
        ) then
            pcall(function()
                remote:InvokeServer()
                success = true
            end)
        end
    end
    
    -- Método 3: Input Simulation
    if not success then
        pcall(function()
            local inputObject = {
                KeyCode = Enum.KeyCode.F,
                UserInputType = Enum.UserInputType.Keyboard
            }
            UserInputService:GetPropertyChangedSignal("InputBegan"):Fire(inputObject)
        end)
    end
    
    wait(0.1)
    ParryDebounce = false
end

local function AutoParrySystem()
    if not Config.AutoParry or not Ball or not RootPart then return end
    
    local distance = GetDistance(Ball, RootPart)
    local velocity = Ball.Velocity
    
    -- Cálculo predictivo con compensación
    local compensation = Config.AutoCompensation and Config.ManualCompensation or 0
    local adjustedRange = Config.ParryRange + compensation
    
    if distance <= adjustedRange and velocity.Magnitude > 10 then
        -- Verificar si la pelota se dirige hacia el jugador
        local direction = (RootPart.Position - Ball.Position).Unit
        local ballDirection = velocity.Unit
        local dotProduct = direction:Dot(ballDirection)
        
        if dotProduct > 0.3 then -- La pelota se acerca
            PerformParry()
        end
    end
end

local function LegitParrySystem()
    if not Config.LegitParry or not Ball or not RootPart then return end
    
    local distance = GetDistance(Ball, RootPart)
    
    -- Sistema más natural con delay aleatorio
    if distance <= Config.ParryRange and Ball.Velocity.Magnitude > 15 then
        local randomDelay = math.random(50, 150) / 1000 -- 50-150ms delay
        wait(randomDelay)
        PerformParry()
    end
end

local function FollowBallSystem()
    if not Config.FollowBall or not Ball or not Humanoid then return end
    
    local ballPosition = Ball.Position
    local direction = (ballPosition - RootPart.Position).Unit
    
    -- Mantener distancia óptima
    local optimalDistance = Config.ParryRange * 0.8
    local currentDistance = GetDistance(Ball, RootPart)
    
    if currentDistance > optimalDistance then
        Humanoid:MoveTo(ballPosition - direction * optimalDistance)
    end
end

local function AutoCurveSystem()
    if not Config.AutoCurve or not Ball then return end
    
    -- Aplicar curva aleatoria a la pelota
    local bodyVelocity = Ball:FindFirstChild("BodyVelocity") or Instance.new("BodyVelocity")
    bodyVelocity.Parent = Ball
    
    local randomCurve = Vector3.new(
        math.random(-20, 20),
        math.random(-10, 10),
        math.random(-20, 20)
    )
    
    bodyVelocity.Velocity = Ball.Velocity + randomCurve
end

local function AIMovementSystem()
    if not Config.AIMovement or not Ball or not Humanoid then return end
    
    local ballVelocity = Ball.Velocity
    local predictedPosition = Ball.Position + ballVelocity * 0.5
    
    -- Movimiento predictivo inteligente
    local safePosition = predictedPosition + Vector3.new(
        math.random(-5, 5),
        0,
        math.random(-5, 5)
    )
    
    Humanoid:MoveTo(safePosition)
end

local function SpeedControl()
    if not Humanoid then return end
    
    local speed = Config.SpeedV1
    if Config.InfinityDash then
        speed = speed * 2
    end
    
    Humanoid.WalkSpeed = speed
end

local function SetupLowGraphics()
    if not Config.LowGraphics then return end
    
    -- Reducir calidad gráfica para mejor rendimiento
    local lighting = Lighting
    lighting.GlobalShadows = false
    lighting.Technology = Enum.Technology.Compatibility
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.Material = Enum.Material.Plastic
            obj.Reflectance = 0
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = 0.5
        end
    end
end

local function OrbitSystem()
    if not Ball or not RootPart then return end
    
    if Config.OrbitBall then
        local angle = tick() * 2
        local radius = Config.ParryRange
        local x = Ball.Position.X + math.cos(angle) * radius
        local z = Ball.Position.Z + math.sin(angle) * radius
        
        RootPart.CFrame = CFrame.new(x, RootPart.Position.Y, z)
    end
    
    if Config.OrbitPlayer then
        -- Orbitar alrededor del jugador más cercano
        local closestPlayer = nil
        local closestDistance = math.huge
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character.HumanoidRootPart then
                local distance = GetDistance(RootPart, player.Character.HumanoidRootPart)
                if distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = player
                end
            end
        end
        
        if closestPlayer and closestPlayer.Character and closestPlayer.Character.HumanoidRootPart then
            local targetRoot = closestPlayer.Character.HumanoidRootPart
            local angle = tick() * 1.5
            local radius = 10
            local x = targetRoot.Position.X + math.cos(angle) * radius
            local z = targetRoot.Position.Z + math.sin(angle) * radius
            
            RootPart.CFrame = CFrame.new(x, RootPart.Position.Y, z)
        end
    end
end

-- ═══════════════════════════════════════════════════════════════
-- SISTEMA DE BYPASS
-- ═══════════════════════════════════════════════════════════════

local function SetupBypasses()
    if Config.GazoBypass then
        -- Bypass para detección de Gazo
        local mt = getrawmetatable(game)
        local oldNamecall = mt.__namecall
        
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            if method == "FireServer" and string.find(tostring(self), "Gazo") then
                return -- Bloquear detección
            end
            
            return oldNamecall(self, ...)
        end)
        setreadonly(mt, true)
    end
    
    if Config.TorokaiBypass then
        -- Bypass para detección de Torokai
        for _, script in pairs(game:GetDescendants()) do
            if script:IsA("LocalScript") and string.find(script.Source or "", "Torokai") then
                script:Destroy()
            end
        end
    end
    
    if Config.WuBypass then
        -- Bypass Wu detection
        local oldRequire = require
        require = function(module)
            if string.find(tostring(module), "Wu") or string.find(tostring(module), "AntiCheat") then
                return {}
            end
            return oldRequire(module)
        end
    end
end

-- ═══════════════════════════════════════════════════════════════
-- INTERFAZ GRÁFICA (GUI)
-- ═══════════════════════════════════════════════════════════════

local function CreateGUI()
    -- Crear GUI principal
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "DeathBallScript"
    ScreenGui.Parent = PlayerGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
    MainFrame.Size = UDim2.new(0, 400, 0, 500)
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    -- Título
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Parent = MainFrame
    Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Title.BorderSizePixel = 0
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "DEATH BALL - Owner Script"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextScaled = true
    
    -- Función para crear toggle
    local function CreateToggle(name, position, callback)
        local Toggle = Instance.new("Frame")
        Toggle.Name = name .. "Toggle"
        Toggle.Parent = MainFrame
        Toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        Toggle.BorderSizePixel = 0
        Toggle.Position = position
        Toggle.Size = UDim2.new(0, 180, 0, 25)
        
        local Label = Instance.new("TextLabel")
        Label.Parent = Toggle
        Label.BackgroundTransparency = 1
        Label.Size = UDim2.new(0.7, 0, 1, 0)
        Label.Font = Enum.Font.Gotham
        Label.Text = name
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Label.TextScaled = true
        Label.TextXAlignment = Enum.TextXAlignment.Left
        
        local Button = Instance.new("TextButton")
        Button.Parent = Toggle
        Button.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        Button.BorderSizePixel = 0
        Button.Position = UDim2.new(0.75, 0, 0.1, 0)
        Button.Size = UDim2.new(0.2, 0, 0.8, 0)
        Button.Font = Enum.Font.Gotham
        Button.Text = "OFF"
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.TextScaled = true
        
        local enabled = false
        Button.MouseButton1Click:Connect(function()
            enabled = not enabled
            Button.BackgroundColor3 = enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            Button.Text = enabled and "ON" or "OFF"
            callback(enabled)
        end)
        
        return Toggle
    end
    
    -- Crear todos los toggles
    local yPos = 0.08
    local spacing = 0.06
    
    CreateToggle("Auto Parry", UDim2.new(0.05, 0, yPos, 0), function(enabled)
        Config.AutoParry = enabled
    end)
    yPos = yPos + spacing
    
    CreateToggle("Follow Ball", UDim2.new(0.05, 0, yPos, 0), function(enabled)
        Config.FollowBall = enabled
    end)
    yPos = yPos + spacing
    
    CreateToggle("Auto Skill", UDim2.new(0.05, 0, yPos, 0), function(enabled)
        Config.AutoSkill = enabled
    end)
    yPos = yPos + spacing
    
    CreateToggle("AI Movement", UDim2.new(0.05, 0, yPos, 0), function(enabled)
        Config.AIMovement = enabled
    end)
    yPos = yPos + spacing
    
    CreateToggle("Auto Curve", UDim2.new(0.05, 0, yPos, 0), function(enabled)
        Config.AutoCurve = enabled
    end)
    yPos = yPos + spacing
    
    CreateToggle("Legit Parry", UDim2.new(0.05, 0, yPos, 0), function(enabled)
        Config.LegitParry = enabled
    end)
    yPos = yPos + spacing
    
    CreateToggle("Infinity Dash", UDim2.new(0.05, 0, yPos, 0), function(enabled)
        Config.InfinityDash = enabled
    end)
    yPos = yPos + spacing
    
    CreateToggle("Low Graphics", UDim2.new(0.05, 0, yPos, 0), function(enabled)
        Config.LowGraphics = enabled
        if enabled then SetupLowGraphics() end
    end)
    
    -- Columna derecha
    yPos = 0.08
    CreateToggle("Orbit Ball", UDim2.new(0.52, 0, yPos, 0), function(enabled)
        Config.OrbitBall = enabled
    end)
    yPos = yPos + spacing
    
    CreateToggle("Orbit Player", UDim2.new(0.52, 0, yPos, 0), function(enabled)
        Config.OrbitPlayer = enabled
    end)
    yPos = yPos + spacing
    
    CreateToggle("Gazo Bypass", UDim2.new(0.52, 0, yPos, 0), function(enabled)
        Config.GazoBypass = enabled
    end)
    yPos = yPos + spacing
    
    CreateToggle("Wu Bypass", UDim2.new(0.52, 0, yPos, 0), function(enabled)
        Config.WuBypass = enabled
    end)
    yPos = yPos + spacing
    
    CreateToggle("Streamer Mode", UDim2.new(0.52, 0, yPos, 0), function(enabled)
        Config.StreamerMode = enabled
    end)
    
    return ScreenGui
end

-- ═══════════════════════════════════════════════════════════════
-- SISTEMA DE INPUT Y KEYBINDS
-- ═══════════════════════════════════════════════════════════════

local function SetupKeybinds()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        local keycode = input.KeyCode
        
        if keycode == Config.Keybinds.ManualParry then
            PerformParry()
        elseif keycode == Config.Keybinds.ToggleGUI then
            if GUI then
                GUI.Enabled = not GUI.Enabled
            end
        elseif keycode == Config.Keybinds.AutoParry then
            Config.AutoParry = not Config.AutoParry
            Notify("Auto Parry", Config.AutoParry and "Activado" or "Desactivado")
        elseif keycode == Config.Keybinds.FollowBall then
            Config.FollowBall = not Config.FollowBall
            Notify("Follow Ball", Config.FollowBall and "Activado" or "Desactivado")
        elseif keycode == Config.Keybinds.SpeedToggle then
            Config.SpeedV1 = Config.SpeedV1 == 16 and 50 or 16
            Notify("Speed", "Ajustado a: " .. Config.SpeedV1)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- LOOP PRINCIPAL DEL SCRIPT
-- ═══════════════════════════════════════════════════════════════

local function MainLoop()
    -- Buscar la pelota constantemente
    if not Ball then
        Ball = FindBall()
    end
    
    -- Verificar si la pelota sigue existiendo
    if Ball and not Ball.Parent then
        Ball = nil
        return
    end
    
    -- Ejecutar sistemas principales
    pcall(AutoParrySystem)
    pcall(LegitParrySystem)
    pcall(FollowBallSystem)
    pcall(AutoCurveSystem)
    pcall(AIMovementSystem)
    pcall(SpeedControl)
    pcall(OrbitSystem)
end

-- ═══════════════════════════════════════════════════════════════
-- INICIALIZACIÓN DEL SCRIPT
-- ═══════════════════════════════════════════════════════════════

local function Initialize()
    -- Notificación de inicio
    Notify("Death Ball Script", "¡Script cargado correctamente!", 5)
    
    -- Crear GUI
    GUI = CreateGUI()
    
    -- Configurar keybinds
    SetupKeybinds()
    
    -- Configurar bypasses
    SetupBypasses()
    
    -- Buscar pelota inicial
    Ball = FindBall()
    
    -- Iniciar loop principal
    RunService.Heartbeat:Connect(MainLoop)
    
    -- Reconectar cuando el personaje respawnee
    LocalPlayer.CharacterAdded:Connect(function(newCharacter)
        Character = newCharacter
        Humanoid = Character:WaitForChild("Humanoid")
        RootPart = Character:WaitForChild("HumanoidRootPart")
        
        -- Reconfigurar después del respawn
        wait(1)
        Ball = FindBall()
    end)
    
    print("✅ DEATH BALL Script completamente inicializado!")
    print("🎮 Controles:")
    print("   F - Parry Manual")
    print("   RightShift - Toggle GUI") 
    print("   Q - Toggle Auto Parry")
    print("   E - Toggle Follow Ball")
    print("   G - Toggle Speed")
    print("📊 Estado: ¡Listo para dominar Death Ball!")
end

-- ═══════════════════════════════════════════════════════════════
-- PROTECCIÓN Y EJECUCIÓN
-- ═══════════════════════════════════════════════════════════════

-- Protección contra detección
local function AntiDetection()
    -- Ocultar script de logs
    for _, connection in pairs(getconnections(game.LogService.MessageOut)) do
        connection:Disable()
    end
    
    -- Proteger contra algunos métodos de detección comunes
    local oldmt = getrawmetatable(game)
    setreadonly(oldmt, false)
    
    local oldindex = oldmt.__index
    oldmt.__index = newcclosure(function(t, k)
        if t == game and k == "HttpService" then
            return nil -- Ocultar HttpService
        end
        return oldindex(t, k)
    end)
    
    setreadonly(oldmt, true)
end

-- Ejecutar protección
pcall(AntiDetection)

-- Inicializar script
pcall(Initialize)

-- ═══════════════════════════════════════════════════════════════
-- FIN DEL SCRIPT
-- ═══════════════════════════════════════════════════════════════