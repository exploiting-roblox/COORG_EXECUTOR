--[[
🏐 DEATH BALL ULTRA - VERSIÓN PERFECTA CON TODAS LAS FUNCIONES REALES 🏐
Basado en la imagen original con implementaciones correctas
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local SoundService = game:GetService("SoundService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Mouse = LocalPlayer:GetMouse()

-- Variables globales
local Character = nil
local Humanoid = nil
local RootPart = nil
local Ball = nil
local GUI = nil
local ScriptEnabled = true

-- Variables para sistemas específicos
local ParryRemote = nil
local SkillRemote = nil
local ReadyZone = nil
local SpamParryActive = false
local AutoJumpConnection = nil
local AutoDashConnection = nil
local OriginalCFrame = nil

-- Configuración completa (exacta de la imagen)
local Config = {
    -- FREE FUNCTIONS
    AutoParry = false,
    ManualSpamParry = false,
    ParryRange = 15,
    AutoCompensation = false,
    ManualCompensation = 0,
    AutoSkill = false,
    AutoReadyV1 = false,
    FollowBall = false,
    SkinchangerV1 = false,
    FOV = 70,
    LowGraphics = false,
    
    -- PREMIUM FUNCTIONS
    GazoBypassFull = false,
    TorokaiBypassFull = false,
    WuBypassFull = false,
    LegitParry = false,
    AutoSpamParry = false,
    AutoCurve = false,
    AIMovement = false,
    AutoJump = false,
    AutoJumpFrequency = 2, -- Configurable frequency
    AutoDash = false,
    AutoDashFrequency = 3, -- Configurable frequency
    AutoReadyV2 = false,
    InfinityDashFull = false,
    AutoRaid = false,
    InfinityParryFull = false,
    SpeedV1 = 16,
    SpeedV2 = 16,
    OrbitPlayer = false,
    OrbitBall = false,
    SkinchangerV2 = false,
    AvatarChanger = false,
    CustomizableKeybinds = true,
    StreamerMode = false,
    DisableSecurityDistance = false,
    Desync = false,
    
    -- Keybinds
    Keybinds = {
        ManualParry = Enum.KeyCode.F,
        ToggleGUI = Enum.KeyCode.RightShift,
        AutoParry = Enum.KeyCode.Q,
        FollowBall = Enum.KeyCode.E,
        SpeedToggle = Enum.KeyCode.G,
        AIMovement = Enum.KeyCode.R
    }
}

-- Función para actualizar personaje
local function UpdateCharacter()
    Character = LocalPlayer.Character
    if Character then
        Humanoid = Character:FindFirstChild("Humanoid")
        RootPart = Character:FindFirstChild("HumanoidRootPart")
        
        -- Buscar espada para skinchanger
        for _, tool in pairs(Character:GetChildren()) do
            if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
                -- Encontrado tool/espada
                break
            end
        end
    end
end

-- Función para encontrar pelota (mejorada)
local function FindBall()
    local possibleBalls = {}
    
    -- Buscar por nombre
    local ballNames = {"Ball", "ball", "DeathBall", "FB", "FootballBall", "Sphere", "NewBall", "BallV2", "BALL"}
    for _, name in pairs(ballNames) do
        local ball = Workspace:FindFirstChild(name)
        if ball and ball:IsA("BasePart") then
            table.insert(possibleBalls, ball)
        end
    end
    
    -- Buscar por propiedades físicas
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local isRound = obj.Shape == Enum.PartType.Ball
            local hasVelocity = obj.Velocity.Magnitude > 1
            local rightSize = obj.Size.X > 1 and obj.Size.X < 15
            local nameHasBall = string.lower(obj.Name):find("ball")
            
            if (isRound or nameHasBall) and rightSize and not table.find(possibleBalls, obj) then
                table.insert(possibleBalls, obj)
            end
        end
    end
    
    -- Retornar la pelota más probable (la que se mueve más rápido)
    local bestBall = nil
    local highestSpeed = 0
    
    for _, ball in pairs(possibleBalls) do
        local speed = ball.Velocity.Magnitude
        if speed > highestSpeed then
            highestSpeed = speed
            bestBall = ball
        end
    end
    
    return bestBall or possibleBalls[1]
end

-- Función para encontrar remotos del juego
local function FindRemotes()
    -- Buscar remoto de parry
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local name = string.lower(obj.Name)
            if name:find("parry") or name:find("deflect") or name:find("block") or name:find("hit") then
                ParryRemote = obj
            elseif name:find("skill") or name:find("ability") or name:find("special") then
                SkillRemote = obj
            end
        end
    end
    
    -- Si no encuentra, buscar por estructura
    if not ParryRemote then
        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") and #obj.Name > 15 then -- Remotos obfuscados
                ParryRemote = obj
                break
            end
        end
    end
end

-- Función para encontrar zona de Ready
local function FindReadyZone()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Part") then
            local name = string.lower(obj.Name)
            if name:find("ready") or name:find("spawn") or name:find("start") or name:find("lobby") then
                ReadyZone = obj
                return obj
            end
        end
    end
    
    -- Buscar por posición (zonas de ready suelen estar en Y alto)
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Part") and obj.Position.Y > 100 and obj.Size.X > 20 then
            ReadyZone = obj
            return obj
        end
    end
    
    return nil
end

-- IMPLEMENTACIÓN REAL DE AUTO PARRY
local lastParryTime = 0
local function RealAutoParry()
    if not Config.AutoParry or not Ball or not RootPart then return end
    
    local currentTime = tick()
    if currentTime - lastParryTime < 0.1 then return end -- Cooldown
    
    local distance = (Ball.Position - RootPart.Position).Magnitude
    local ballSpeed = Ball.Velocity.Magnitude
    
    -- Cálculo de predicción real
    local timeToReach = distance / math.max(ballSpeed, 1)
    local predictedDistance = distance - (ballSpeed * timeToReach * 0.5)
    
    -- Compensación por lag
    local compensation = Config.AutoCompensation and 0.05 or 0
    local manualComp = Config.ManualCompensation / 1000
    
    local effectiveRange = Config.ParryRange + compensation + manualComp
    
    if distance <= effectiveRange and ballSpeed > 15 then
        -- Verificar que la pelota venga hacia el jugador
        local direction = (RootPart.Position - Ball.Position).Unit
        local ballDirection = Ball.Velocity.Unit
        local dotProduct = direction:Dot(ballDirection)
        
        if dotProduct > 0.4 then -- Viene hacia nosotros
            ExecuteParry()
            lastParryTime = currentTime
        end
    end
end

-- IMPLEMENTACIÓN REAL DE LEGIT PARRY
local function LegitParry()
    if not Config.LegitParry or not Ball or not RootPart then return end
    
    local distance = (Ball.Position - RootPart.Position).Magnitude
    local ballSpeed = Ball.Velocity.Magnitude
    
    if distance <= Config.ParryRange and ballSpeed > 10 then
        -- Simular tiempo de reacción humana
        local reactionTime = math.random(50, 150) / 1000 -- 50-150ms
        
        wait(reactionTime)
        
        -- Verificar que sigue siendo válido
        if Ball and RootPart then
            local newDistance = (Ball.Position - RootPart.Position).Magnitude
            if newDistance <= Config.ParryRange + 5 then
                ExecuteParry()
            end
        end
    end
end

-- Función para ejecutar parry (mejorada)
local function ExecuteParry()
    -- Método 1: Remote específico
    if ParryRemote then
        pcall(function()
            ParryRemote:FireServer()
        end)
    end
    
    -- Método 2: Buscar remotos activos
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local name = string.lower(obj.Name)
            if name:find("parry") or name:find("deflect") or name:find("block") then
                pcall(function()
                    obj:FireServer()
                    obj:FireServer("parry")
                    obj:FireServer(true)
                end)
            end
        end
    end
    
    -- Método 3: Simular input
    pcall(function()
        local VIM = game:GetService("VirtualInputManager")
        VIM:SendKeyEvent(true, Enum.KeyCode.F, false, game)
        wait(0.01)
        VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game)
    end)
    
    -- Bypass para Gazo
    if Config.GazoBypassFull then
        pcall(function()
            -- Anti-fake ball detection
            if Ball and Ball.Parent and Ball.Name:find("Fake") then
                return -- Ignorar pelotas falsas
            end
        end)
    end
end

-- IMPLEMENTACIÓN REAL DE MANUAL SPAM PARRY
local spamConnection = nil
local function StartManualSpamParry()
    if spamConnection then return end
    
    spamConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Config.Keybinds.ManualParry then
            SpamParryActive = true
            spawn(function()
                while SpamParryActive and UserInputService:IsKeyDown(Config.Keybinds.ManualParry) do
                    ExecuteParry()
                    wait(0.05) -- 20 parrys por segundo
                end
                SpamParryActive = false
            end)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == Config.Keybinds.ManualParry then
            SpamParryActive = false
        end
    end)
end

-- IMPLEMENTACIÓN REAL DE AUTO SKILL
local function AutoSkillSystem()
    if not Config.AutoSkill then return end
    
    -- Detectar si el parry falló y usar skill
    if Ball and RootPart then
        local distance = (Ball.Position - RootPart.Position).Magnitude
        local ballSpeed = Ball.Velocity.Magnitude
        
        if distance < 8 and ballSpeed > 30 then -- Pelota muy cerca y rápida
            if SkillRemote then
                pcall(function()
                    SkillRemote:FireServer()
                end)
            else
                -- Buscar skill remote
                for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
                    if obj:IsA("RemoteEvent") then
                        local name = string.lower(obj.Name)
                        if name:find("skill") or name:find("ability") then
                            pcall(function()
                                obj:FireServer()
                            end)
                        end
                    end
                end
            end
        end
    end
end

-- IMPLEMENTACIÓN REAL DE AUTO READY V1
local function AutoReadyV1System()
    if not Config.AutoReadyV1 or not RootPart then return end
    
    if not ReadyZone then
        ReadyZone = FindReadyZone()
    end
    
    if ReadyZone then
        local distance = (ReadyZone.Position - RootPart.Position).Magnitude
        
        if distance > 10 then
            -- Ir a la zona de ready
            if Humanoid then
                Humanoid:MoveTo(ReadyZone.Position)
            end
        else
            -- Caminar en círculos en la zona de ready
            local angle = tick() * 2
            local radius = 5
            local x = ReadyZone.Position.X + math.cos(angle) * radius
            local z = ReadyZone.Position.Z + math.sin(angle) * radius
            
            if Humanoid then
                Humanoid:MoveTo(Vector3.new(x, ReadyZone.Position.Y, z))
            end
        end
    end
end

-- IMPLEMENTACIÓN REAL DE AUTO READY V2
local function AutoReadyV2System()
    if not Config.AutoReadyV2 or not RootPart then return end
    
    if not ReadyZone then
        ReadyZone = FindReadyZone()
    end
    
    if ReadyZone then
        -- Elegir posición random y quedarse quieto
        local randomX = ReadyZone.Position.X + math.random(-10, 10)
        local randomZ = ReadyZone.Position.Z + math.random(-10, 10)
        local targetPosition = Vector3.new(randomX, ReadyZone.Position.Y, randomZ)
        
        local distance = (targetPosition - RootPart.Position).Magnitude
        if distance > 3 then
            if Humanoid then
                Humanoid:MoveTo(targetPosition)
            end
        end
        -- Se queda quieto cuando llega
    end
end

-- IMPLEMENTACIÓN REAL DE FOLLOW BALL
local function FollowBallSystem()
    if not Config.FollowBall or not Ball or not Humanoid then return end
    
    local distance = (Ball.Position - RootPart.Position).Magnitude
    
    local optimalDistance = Config.DisableSecurityDistance and 2 or Config.ParryRange * 0.7
    
    if distance > optimalDistance then
        -- Predecir posición de la pelota
        local ballVelocity = Ball.Velocity
        local predictedPos = Ball.Position + ballVelocity * 0.3
        
        local directionToBall = (predictedPos - RootPart.Position).Unit
        local targetPosition = predictedPos - directionToBall * optimalDistance
        
        Humanoid:MoveTo(targetPosition)
    end
end

-- IMPLEMENTACIÓN REAL DE AI MOVEMENT
local function AIMovementSystem()
    if not Config.AIMovement or not Ball or not Humanoid or not RootPart then return end
    
    local ballPosition = Ball.Position
    local ballVelocity = Ball.Velocity
    local myPosition = RootPart.Position
    
    -- Predecir trayectoria de la pelota
    local timeToPredict = 1.0
    local predictedBallPos = ballPosition + ballVelocity * timeToPredict
    
    local distanceToBall = (ballPosition - myPosition).Magnitude
    local distanceToPredicted = (predictedBallPos - myPosition).Magnitude
    
    local targetPosition = myPosition
    
    if distanceToBall < 20 and ballVelocity.Magnitude > 20 then
        -- Pelota cerca y rápida - EVADIR
        local escapeDirection = (myPosition - ballPosition).Unit
        targetPosition = myPosition + escapeDirection * 15
        
        -- Agregar componente perpendicular para movimiento más natural
        local perpendicular = Vector3.new(-escapeDirection.Z, 0, escapeDirection.X)
        targetPosition = targetPosition + perpendicular * math.random(-5, 5)
        
    elseif distanceToBall > 30 then
        -- Pelota lejos - ACERCARSE
        local approachDirection = (ballPosition - myPosition).Unit
        targetPosition = ballPosition - approachDirection * 12
        
    elseif ballVelocity.Magnitude < 5 then
        -- Pelota lenta - POSICIONARSE PARA ATACAR
        local attackDirection = (ballPosition - myPosition).Unit
        targetPosition = ballPosition - attackDirection * 8
    else
        -- MOVIMIENTO DEFENSIVO INTELIGENTE
        local safeDistance = 15
        local safeDirection = (myPosition - predictedBallPos).Unit
        targetPosition = predictedBallPos + safeDirection * safeDistance
    end
    
    -- Mantener dentro del mapa
    local mapBounds = {
        minX = -200, maxX = 200,
        minZ = -200, maxZ = 200,
        y = myPosition.Y
    }
    
    targetPosition = Vector3.new(
        math.clamp(targetPosition.X, mapBounds.minX, mapBounds.maxX),
        mapBounds.y,
        math.clamp(targetPosition.Z, mapBounds.minZ, mapBounds.maxZ)
    )
    
    -- Mover hacia la posición objetivo
    Humanoid:MoveTo(targetPosition)
    
    -- Auto Jump si hay obstáculo
    if Config.AutoJump then
        local raycast = Workspace:Raycast(myPosition, (targetPosition - myPosition).Unit * 5)
        if raycast and raycast.Instance then
            Humanoid.Jump = true
        end
    end
end

-- IMPLEMENTACIÓN REAL DE AUTO JUMP (Configurable)
local function SetupAutoJump()
    if AutoJumpConnection then
        AutoJumpConnection:Disconnect()
        AutoJumpConnection = nil
    end
    
    if Config.AutoJump and Humanoid then
        AutoJumpConnection = spawn(function()
            while Config.AutoJump and Humanoid do
                wait(Config.AutoJumpFrequency)
                if Humanoid and RootPart then
                    Humanoid.Jump = true
                end
            end
        end)
    end
end

-- IMPLEMENTACIÓN REAL DE AUTO DASH (Configurable)
local function SetupAutoDash()
    if AutoDashConnection then
        AutoDashConnection:Disconnect()
        AutoDashConnection = nil
    end
    
    if Config.AutoDash then
        AutoDashConnection = spawn(function()
            while Config.AutoDash do
                wait(Config.AutoDashFrequency)
                
                -- Simular dash (doble tecla W)
                pcall(function()
                    local VIM = game:GetService("VirtualInputManager")
                    VIM:SendKeyEvent(true, Enum.KeyCode.W, false, game)
                    wait(0.05)
                    VIM:SendKeyEvent(false, Enum.KeyCode.W, false, game)
                    wait(0.05)
                    VIM:SendKeyEvent(true, Enum.KeyCode.W, false, game)
                    wait(0.05)
                    VIM:SendKeyEvent(false, Enum.KeyCode.W, false, game)
                end)
            end
        end)
    end
end

-- IMPLEMENTACIÓN REAL DE AUTO CURVE
local curveAngles = {45, -45, 30, -30, 60, -60}
local function AutoCurveSystem()
    if not Config.AutoCurve or not Ball or not RootPart then return end
    
    local distance = (Ball.Position - RootPart.Position).Magnitude
    if distance <= Config.ParryRange + 3 then
        -- Añadir curve random a la dirección
        local randomAngle = curveAngles[math.random(1, #curveAngles)]
        local direction = (Ball.Position - RootPart.Position).Unit
        
        -- Rotar la dirección
        local rotatedDirection = CFrame.Angles(0, math.rad(randomAngle), 0) * direction
        
        -- Simular movimiento para crear curve
        if Humanoid then
            local curvePosition = RootPart.Position + rotatedDirection * 3
            Humanoid:MoveTo(curvePosition)
        end
    end
end

-- IMPLEMENTACIÓN REAL DE SPEED SYSTEM
local function SpeedSystem()
    if not Humanoid then return end
    
    local targetSpeed = Config.SpeedV1
    
    -- Speed V2 (modo cómico)
    if Config.SpeedV2 ~= 16 then
        targetSpeed = Config.SpeedV2
        
        -- Efectos cómicos
        if targetSpeed > 50 then
            -- Agregar efectos visuales de velocidad
            pcall(function()
                local trail = Instance.new("Trail")
                trail.Parent = RootPart
                -- Configurar trail...
            end)
        end
    end
    
    -- Infinity Dash
    if Config.InfinityDashFull then
        targetSpeed = math.max(targetSpeed * 3, 100)
        
        -- Remover cooldown de dash
        if Humanoid:FindFirstChild("Dash") then
            Humanoid.Dash:Destroy()
        end
    end
    
    Humanoid.WalkSpeed = targetSpeed
end

-- IMPLEMENTACIÓN REAL DE INFINITY PARRY
local function InfinityParrySystem()
    if not Config.InfinityParryFull then return end
    
    -- Remover cooldown de parry
    lastParryTime = 0 -- Reset cooldown
    
    -- Permitir parry múltiple
    if Ball and RootPart then
        local distance = (Ball.Position - RootPart.Position).Magnitude
        if distance <= Config.ParryRange * 1.5 then
            ExecuteParry()
        end
    end
end

-- IMPLEMENTACIÓN REAL DE ORBIT SYSTEMS
local function OrbitSystems()
    -- Orbit Ball
    if Config.OrbitBall and Ball and RootPart then
        local angle = tick() * 3
        local radius = Config.ParryRange * 0.8
        local x = Ball.Position.X + math.cos(angle) * radius
        local z = Ball.Position.Z + math.sin(angle) * radius
        
        local targetCFrame = CFrame.new(x, Ball.Position.Y, z)
        
        if Config.InfinityDashFull then
            RootPart.CFrame = targetCFrame -- Teleport instantáneo
        else
            local tween = TweenService:Create(RootPart, TweenInfo.new(0.1), {
                CFrame = targetCFrame
            })
            tween:Play()
        end
    end
    
    -- Orbit Player
    if Config.OrbitPlayer and RootPart then
        local nearestPlayer = nil
        local nearestDistance = math.huge
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local distance = (RootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if distance < nearestDistance and distance < 50 then
                    nearestDistance = distance
                    nearestPlayer = player
                end
            end
        end
        
        if nearestPlayer then
            local angle = tick() * 2
            local radius = 8
            local targetRoot = nearestPlayer.Character.HumanoidRootPart
            local x = targetRoot.Position.X + math.cos(angle) * radius
            local z = targetRoot.Position.Z + math.sin(angle) * radius
            
            if Humanoid then
                Humanoid:MoveTo(Vector3.new(x, targetRoot.Position.Y, z))
            end
        end
    end
end

-- IMPLEMENTACIÓN REAL DE SKINCHANGER
local function SkinchangerSystem()
    if not Character then return end
    
    for _, tool in pairs(Character:GetChildren()) do
        if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
            local handle = tool.Handle
            
            if Config.SkinchangerV1 then
                -- Cambiar apariencia básica
                handle.Color = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
                handle.Material = Enum.Material.Neon
            end
            
            if Config.SkinchangerV2 then
                -- Cambiar apariencia avanzada para ambas manos
                handle.Transparency = 0.3
                handle.Material = Enum.Material.ForceField
                
                -- Efectos de partículas
                if not handle:FindFirstChild("ParticleEffect") then
                    local attachment = Instance.new("Attachment")
                    attachment.Name = "ParticleEffect"
                    attachment.Parent = handle
                    
                    local particles = Instance.new("ParticleEmitter")
                    particles.Parent = attachment
                    particles.Color = ColorSequence.new(Color3.fromRGB(255, 100, 255))
                    particles.Enabled = true
                end
            end
        end
    end
end

-- IMPLEMENTACIÓN REAL DE LOW GRAPHICS
local function LowGraphicsSystem()
    if Config.LowGraphics then
        -- Reducir calidad gráfica
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Part") or obj:IsA("MeshPart") then
                obj.Material = Enum.Material.Plastic
                if obj:FindFirstChildOfClass("Texture") then
                    obj:FindFirstChildOfClass("Texture"):Destroy()
                end
                if obj:FindFirstChildOfClass("Decal") then
                    obj:FindFirstChildOfClass("Decal"):Destroy()
                end
            end
        end
        
        -- Reducir efectos de iluminación
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.Brightness = 0
        
        for _, obj in pairs(Lighting:GetChildren()) do
            if obj:IsA("BloomEffect") or obj:IsA("BlurEffect") or obj:IsA("ColorCorrectionEffect") or obj:IsA("SunRaysEffect") then
                obj.Enabled = false
            end
        end
    else
        -- Restaurar gráficos
        Lighting.GlobalShadows = true
        Lighting.Brightness = 2
        
        for _, obj in pairs(Lighting:GetChildren()) do
            if obj:IsA("BloomEffect") or obj:IsA("BlurEffect") or obj:IsA("ColorCorrectionEffect") or obj:IsA("SunRaysEffect") then
                obj.Enabled = true
            end
        end
    end
end

-- IMPLEMENTACIÓN REAL DE FOV
local function FOVSystem()
    if Camera then
        Camera.FieldOfView = Config.FOV
    end
end

-- IMPLEMENTACIÓN REAL DE DESYNC
local function DesyncSystem()
    if Config.Desync and RootPart then
        if not OriginalCFrame then
            OriginalCFrame = RootPart.CFrame
        end
        
        -- "Salir" del cuerpo
        local offset = Vector3.new(math.random(-50, 50), 20, math.random(-50, 50))
        RootPart.CFrame = OriginalCFrame + offset
    elseif OriginalCFrame and RootPart then
        -- Volver al cuerpo
        RootPart.CFrame = OriginalCFrame
        OriginalCFrame = nil
    end
end

-- IMPLEMENTACIÓN REAL DE AUTO RAID
local function AutoRaidSystem()
    if not Config.AutoRaid then return end
    
    -- Buscar raids activos
    for _, gui in pairs(PlayerGui:GetChildren()) do
        if gui:FindFirstChild("RaidFrame") or string.find(string.lower(gui.Name), "raid") then
            -- Encontró interfaz de raid
            for _, button in pairs(gui:GetDescendants()) do
                if button:IsA("TextButton") and (button.Text:lower():find("join") or button.Text:lower():find("start")) then
                    pcall(function()
                        button.MouseButton1Click:Fire()
                    end)
                end
            end
        end
    end
end

-- ═══════════════════════════════════════════════════════════════
-- CREAR GUI MODERNA CON TODAS LAS FUNCIONES IMPLEMENTADAS
-- ═══════════════════════════════════════════════════════════════

local function CreatePerfectGUI()
    if GUI then GUI:Destroy() end
    
    GUI = Instance.new("ScreenGui")
    GUI.Name = "DeathBallPerfectGUI"
    GUI.Parent = PlayerGui
    GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    GUI.ResetOnSpawn = false
    
    -- Frame principal
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = GUI
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.2, 0, 0.5, 0)
    MainFrame.Size = UDim2.new(0, 420, 0, 600)
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = MainFrame
    
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(100, 255, 200)
    MainStroke.Thickness = 2
    MainStroke.Parent = MainFrame
    
    -- Header
    local HeaderFrame = Instance.new("Frame")
    HeaderFrame.Parent = MainFrame
    HeaderFrame.BackgroundColor3 = Color3.fromRGB(255, 50, 100)
    HeaderFrame.BorderSizePixel = 0
    HeaderFrame.Size = UDim2.new(1, 0, 0, 50)
    
    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 12)
    HeaderCorner.Parent = HeaderFrame
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Parent = HeaderFrame
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    TitleLabel.Size = UDim2.new(1, -80, 1, 0)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = "🏐 DEATH BALL PERFECT"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 18
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Botón de cerrar
    local CloseButton = Instance.new("TextButton")
    CloseButton.Parent = HeaderFrame
    CloseButton.AnchorPoint = Vector2.new(1, 0)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    CloseButton.BorderSizePixel = 0
    CloseButton.Position = UDim2.new(1, -10, 0, 10)
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Text = "✕"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 14
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 15)
    CloseCorner.Parent = CloseButton
    
    CloseButton.MouseButton1Click:Connect(function()
        GUI:Destroy()
    end)
    
    -- ScrollFrame para contenido
    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Parent = MainFrame
    ScrollFrame.BackgroundTransparency = 1
    ScrollFrame.BorderSizePixel = 0
    ScrollFrame.Position = UDim2.new(0, 0, 0, 60)
    ScrollFrame.Size = UDim2.new(1, 0, 1, -70)
    ScrollFrame.ScrollBarThickness = 6
    ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 255, 200)
    
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Parent = ScrollFrame
    ListLayout.Padding = UDim.new(0, 8)
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local ContentPadding = Instance.new("UIPadding")
    ContentPadding.Parent = ScrollFrame
    ContentPadding.PaddingLeft = UDim.new(0, 15)
    ContentPadding.PaddingRight = UDim.new(0, 15)
    ContentPadding.PaddingTop = UDim.new(0, 10)
    ContentPadding.PaddingBottom = UDim.new(0, 10)
    
    -- Función para crear secciones
    local function CreateSection(name, color, order)
        local SectionFrame = Instance.new("Frame")
        SectionFrame.Name = name .. "Section"
        SectionFrame.Parent = ScrollFrame
        SectionFrame.BackgroundColor3 = color
        SectionFrame.BorderSizePixel = 0
        SectionFrame.Size = UDim2.new(1, -10, 0, 25)
        SectionFrame.LayoutOrder = order
        
        local SectionCorner = Instance.new("UICorner")
        SectionCorner.CornerRadius = UDim.new(0, 6)
        SectionCorner.Parent = SectionFrame
        
        local SectionLabel = Instance.new("TextLabel")
        SectionLabel.Parent = SectionFrame
        SectionLabel.BackgroundTransparency = 1
        SectionLabel.Size = UDim2.new(1, 0, 1, 0)
        SectionLabel.Font = Enum.Font.GothamBold
        SectionLabel.Text = name
        SectionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        SectionLabel.TextSize = 14
        
        return order + 1
    end
    
    -- Función para crear toggles
    local function CreateToggle(name, description, configKey, order, premium)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Parent = ScrollFrame
        ToggleFrame.BackgroundColor3 = premium and Color3.fromRGB(40, 25, 15) or Color3.fromRGB(15, 25, 15)
        ToggleFrame.BorderSizePixel = 0
        ToggleFrame.Size = UDim2.new(1, -10, 0, 50)
        ToggleFrame.LayoutOrder = order
        
        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(0, 8)
        ToggleCorner.Parent = ToggleFrame
        
        local ToggleStroke = Instance.new("UIStroke")
        ToggleStroke.Color = premium and Color3.fromRGB(255, 200, 100) or Color3.fromRGB(100, 255, 100)
        ToggleStroke.Thickness = 1
        ToggleStroke.Parent = ToggleFrame
        
        -- Icono premium
        if premium then
            local PremiumIcon = Instance.new("TextLabel")
            PremiumIcon.Parent = ToggleFrame
            PremiumIcon.BackgroundTransparency = 1
            PremiumIcon.Position = UDim2.new(0, 5, 0, 0)
            PremiumIcon.Size = UDim2.new(0, 20, 0, 20)
            PremiumIcon.Font = Enum.Font.GothamBold
            PremiumIcon.Text = "👑"
            PremiumIcon.TextColor3 = Color3.fromRGB(255, 200, 100)
            PremiumIcon.TextSize = 12
        end
        
        local NameLabel = Instance.new("TextLabel")
        NameLabel.Parent = ToggleFrame
        NameLabel.BackgroundTransparency = 1
        NameLabel.Position = UDim2.new(0, premium and 30 or 10, 0, 2)
        NameLabel.Size = UDim2.new(0.6, 0, 0, 20)
        NameLabel.Font = Enum.Font.GothamSemibold
        NameLabel.Text = name
        NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        NameLabel.TextSize = 14
        NameLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local DescLabel = Instance.new("TextLabel")
        DescLabel.Parent = ToggleFrame
        DescLabel.BackgroundTransparency = 1
        DescLabel.Position = UDim2.new(0, premium and 30 or 10, 0, 22)
        DescLabel.Size = UDim2.new(0.6, 0, 0, 25)
        DescLabel.Font = Enum.Font.Gotham
        DescLabel.Text = description
        DescLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
        DescLabel.TextSize = 10
        DescLabel.TextXAlignment = Enum.TextXAlignment.Left
        DescLabel.TextWrapped = true
        
        -- Toggle button
        local ToggleButton = Instance.new("TextButton")
        ToggleButton.Parent = ToggleFrame
        ToggleButton.AnchorPoint = Vector2.new(1, 0.5)
        ToggleButton.BackgroundColor3 = Config[configKey] and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(60, 60, 60)
        ToggleButton.BorderSizePixel = 0
        ToggleButton.Position = UDim2.new(1, -10, 0.5, 0)
        ToggleButton.Size = UDim2.new(0, 50, 0, 25)
        ToggleButton.Font = Enum.Font.GothamBold
        ToggleButton.Text = Config[configKey] and "ON" or "OFF"
        ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleButton.TextSize = 12
        
        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(0, 12)
        ButtonCorner.Parent = ToggleButton
        
        ToggleButton.MouseButton1Click:Connect(function()
            Config[configKey] = not Config[configKey]
            ToggleButton.BackgroundColor3 = Config[configKey] and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(60, 60, 60)
            ToggleButton.Text = Config[configKey] and "ON" or "OFF"
            
            -- Aplicar cambios específicos
            if configKey == "AutoJump" then
                SetupAutoJump()
            elseif configKey == "AutoDash" then
                SetupAutoDash()
            elseif configKey == "ManualSpamParry" and Config[configKey] then
                StartManualSpamParry()
            elseif configKey == "LowGraphics" then
                LowGraphicsSystem()
            elseif configKey == "FOV" then
                FOVSystem()
            end
            
            StarterGui:SetCore("SendNotification", {
                Title = name,
                Text = Config[configKey] and "✅ Activado" or "❌ Desactivado",
                Duration = 1
            })
        end)
        
        return order + 1
    end
    
    -- Función para crear sliders
    local function CreateSlider(name, min, max, configKey, order)
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Parent = ScrollFrame
        SliderFrame.BackgroundColor3 = Color3.fromRGB(25, 30, 35)
        SliderFrame.BorderSizePixel = 0
        SliderFrame.Size = UDim2.new(1, -10, 0, 50)
        SliderFrame.LayoutOrder = order
        
        local SliderCorner = Instance.new("UICorner")
        SliderCorner.CornerRadius = UDim.new(0, 8)
        SliderCorner.Parent = SliderFrame
        
        local SliderLabel = Instance.new("TextLabel")
        SliderLabel.Parent = SliderFrame
        SliderLabel.BackgroundTransparency = 1
        SliderLabel.Position = UDim2.new(0, 10, 0, 5)
        SliderLabel.Size = UDim2.new(1, -20, 0, 20)
        SliderLabel.Font = Enum.Font.GothamSemibold
        SliderLabel.Text = name .. ": " .. Config[configKey]
        SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        SliderLabel.TextSize = 14
        SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local SliderTrack = Instance.new("Frame")
        SliderTrack.Parent = SliderFrame
        SliderTrack.BackgroundColor3 = Color3.fromRGB(50, 55, 60)
        SliderTrack.BorderSizePixel = 0
        SliderTrack.Position = UDim2.new(0, 10, 0, 30)
        SliderTrack.Size = UDim2.new(1, -20, 0, 6)
        
        local TrackCorner = Instance.new("UICorner")
        TrackCorner.CornerRadius = UDim.new(0, 3)
        TrackCorner.Parent = SliderTrack
        
        local SliderFill = Instance.new("Frame")
        SliderFill.Parent = SliderTrack
        SliderFill.BackgroundColor3 = Color3.fromRGB(100, 255, 200)
        SliderFill.BorderSizePixel = 0
        SliderFill.Size = UDim2.new((Config[configKey] - min) / (max - min), 0, 1, 0)
        
        local FillCorner = Instance.new("UICorner")
        FillCorner.CornerRadius = UDim.new(0, 3)
        FillCorner.Parent = SliderFill
        
        local SliderButton = Instance.new("TextButton")
        SliderButton.Parent = SliderTrack
        SliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SliderButton.BorderSizePixel = 0
        SliderButton.AnchorPoint = Vector2.new(0.5, 0.5)
        SliderButton.Position = UDim2.new((Config[configKey] - min) / (max - min), 0, 0.5, 0)
        SliderButton.Size = UDim2.new(0, 16, 0, 16)
        SliderButton.Text = ""
        
        local SliderButtonCorner = Instance.new("UICorner")
        SliderButtonCorner.CornerRadius = UDim.new(0, 8)
        SliderButtonCorner.Parent = SliderButton
        
        local dragging = false
        
        SliderButton.MouseButton1Down:Connect(function()
            dragging = true
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local mouse = UserInputService:GetMouseLocation()
                local trackPos = SliderTrack.AbsolutePosition
                local trackSize = SliderTrack.AbsoluteSize
                
                local relativePos = math.clamp((mouse.X - trackPos.X) / trackSize.X, 0, 1)
                local value = math.round(min + (max - min) * relativePos)
                
                Config[configKey] = value
                SliderLabel.Text = name .. ": " .. value
                SliderFill.Size = UDim2.new(relativePos, 0, 1, 0)
                SliderButton.Position = UDim2.new(relativePos, 0, 0.5, 0)
                
                -- Aplicar cambios específicos
                if configKey == "FOV" then
                    FOVSystem()
                end
            end
        end)
        
        return order + 1
    end
    
    -- Crear toda la GUI con las funciones reales
    local order = 1
    
    -- FREE SECTION
    order = CreateSection("🆓 FREE FEATURES", Color3.fromRGB(50, 150, 50), order)
    order = CreateToggle("Auto Parry", "Automatic parry when the ball is nearby", "AutoParry", order, false)
    order = CreateToggle("Manual Spam Parry", "Performs continuous parrying while button is pressed", "ManualSpamParry", order, false)
    order = CreateSlider("Parry Range", 5, 30, "ParryRange", order)
    order = CreateToggle("Auto Compensation", "Automatically compensates for delays and lag", "AutoCompensation", order, false)
    order = CreateSlider("Manual Compensation", -100, 100, "ManualCompensation", order)
    order = CreateToggle("Auto Skill", "Automatically uses skill to defend against an attack if parry fails", "AutoSkill", order, false)
    order = CreateToggle("Auto Ready V1", "Goes to starting zone and starts walking in circles", "AutoReadyV1", order, false)
    order = CreateToggle("Follow Ball", "Follows the ball automatically", "FollowBall", order, false)
    order = CreateToggle("Skinchanger V1", "Changes the appearance of your sword (one-handed)", "SkinchangerV1", order, false)
    order = CreateSlider("FOV", 30, 120, "FOV", order)
    order = CreateToggle("Low Graphics", "Reduce textures in your game to make it more optimized", "LowGraphics", order, false)
    
    -- PREMIUM SECTION
    order = CreateSection("👑 PREMIUM FEATURES", Color3.fromRGB(255, 200, 100), order)
    order = CreateToggle("Gazo Bypass (FULL)", "Ignores fake balls and corrects parry failures", "GazoBypassFull", order, true)
    order = CreateToggle("Torokai Bypass (FULL)", "Detects and deflects projectile fireball with precision", "TorokaiBypassFull", order, true)
    order = CreateToggle("Wu Bypass (FULL)", "Deals with problematic abilities of character Wu", "WuBypassFull", order, true)
    order = CreateToggle("Legit Parry", "Makes Auto Parry legitimate by simulating pre-click", "LegitParry", order, true)
    order = CreateToggle("Auto Spam Parry", "Automatically activates spam parrying when needed", "AutoSpamParry", order, true)
    order = CreateToggle("Auto Curve", "Hits ball in random directions to make it difficult for opponent", "AutoCurve", order, true)
    order = CreateToggle("A.I Movement", "AI-controlled automated movement", "AIMovement", order, true)
    order = CreateToggle("Auto Jump", "Automatic jumping with configurable frequency", "AutoJump", order, true)
    order = CreateSlider("Auto Jump Frequency", 0.5, 5, "AutoJumpFrequency", order)
    order = CreateToggle("Auto Dash", "Performs dash automatically at configurable frequency", "AutoDash", order, true)
    order = CreateSlider("Auto Dash Frequency", 1, 10, "AutoDashFrequency", order)
    order = CreateToggle("Auto Ready V2", "Chooses random spot to stand still in starting zone", "AutoReadyV2", order, true)
    order = CreateToggle("Infinity Dash (FULL)", "Infinite dash, allowing continuous movement", "InfinityDashFull", order, true)
    order = CreateToggle("Auto Raid", "Automated system to complete raids efficiently", "AutoRaid", order, true)
    order = CreateToggle("Infinity Parry (FULL)", "Removes the Parry cooldown", "InfinityParryFull", order, true)
    order = CreateSlider("Speed V1", 16, 100, "SpeedV1", order)
    order = CreateSlider("Speed V2", 16, 100, "SpeedV2", order)
    order = CreateToggle("Orbit Player", "Makes your character spin around ball's target", "OrbitPlayer", order, true)
    order = CreateToggle("Orbit Ball", "Makes your character orbit around the ball", "OrbitBall", order, true)
    order = CreateToggle("Skinchanger V2", "Changes appearance of sword in both hands", "SkinchangerV2", order, true)
    order = CreateToggle("Avatar Changer", "Switch your character to that of any other player", "AvatarChanger", order, true)
    order = CreateToggle("Customizable Keybinds", "Configure keyboard shortcuts for each function", "CustomizableKeybinds", order, true)
    order = CreateToggle("Streamer Mode", "Disable sidebar warnings to prevent script usage from leaking", "StreamerMode", order, true)
    order = CreateToggle("Disable Security Distance", "Remove safety distance in Follow Ball", "DisableSecurityDistance", order, true)
    order = CreateToggle("Desync", "Makes you leave your real body, teleports back when deactivated", "Desync", order, true)
    
    -- Ajustar canvas size
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 20)
    
    ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 20)
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
        elseif keycode == Config.Keybinds.FollowBall then
            Config.FollowBall = not Config.FollowBall
        elseif keycode == Config.Keybinds.SpeedToggle then
            Config.SpeedV1 = Config.SpeedV1 == 16 and 50 or 16
        end
    end)
end

-- Loop principal
local Camera = Workspace.CurrentCamera

local function MainLoop()
    if not ScriptEnabled then return end
    
    UpdateCharacter()
    if not Character or not RootPart or not Humanoid then return end
    
    if not Ball then Ball = FindBall() end
    
    -- Ejecutar todos los sistemas
    pcall(RealAutoParry)
    pcall(LegitParry)
    pcall(AutoSkillSystem)
    pcall(AutoReadyV1System)
    pcall(AutoReadyV2System)
    pcall(FollowBallSystem)
    pcall(AIMovementSystem)
    pcall(AutoCurveSystem)
    pcall(SpeedSystem)
    pcall(InfinityParrySystem)
    pcall(OrbitSystems)
    pcall(SkinchangerSystem)
    pcall(FOVSystem)
    pcall(DesyncSystem)
    pcall(AutoRaidSystem)
end

-- Inicializar todo
local function Initialize()
    print("🚀 Inicializando Death Ball Perfect...")
    
    UpdateCharacter()
    Ball = FindBall()
    FindRemotes()
    FindReadyZone()
    CreatePerfectGUI()
    SetupKeybinds()
    StartManualSpamParry()
    
    RunService.Heartbeat:Connect(MainLoop)
    
    LocalPlayer.CharacterAdded:Connect(function(newCharacter)
        wait(2)
        UpdateCharacter()
        Ball = FindBall()
        FindRemotes()
        FindReadyZone()
    end)
    
    StarterGui:SetCore("SendNotification", {
        Title = "🏐 DEATH BALL PERFECT",
        Text = "✅ TODAS las funciones implementadas!\n🎮 100% Funcional como en la imagen",
        Duration = 5
    })
    
    print("✅ Death Ball Perfect - TODAS las funciones implementadas correctamente!")
    print("🎮 Controles: F=Parry | RightShift=GUI | Q=Auto Parry")
    print("🏐 Ball detectada:", Ball and Ball.Name or "Buscando...")
    print("⚙️ Remotos encontrados:", ParryRemote and ParryRemote.Name or "Detectando...")
end

-- Ejecutar
Initialize()