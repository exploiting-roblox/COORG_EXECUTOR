# 🐧 LinuxBlox Executor - El Primer Executor Nativo para Linux

## 🎯 **¿QUÉ ES LinuxBlox?**

**LinuxBlox Executor** es el **primer script executor** diseñado específicamente para **Linux**, permitiendo ejecutar scripts de Roblox sin necesidad de Windows, Wine, o VMs.

---

## 🔥 **CARACTERÍSTICAS ÚNICAS:**

### ✅ **100% Nativo Linux:**
- No requiere Wine ni máquinas virtuales
- Diseñado específicamente para distribuciones Linux
- Performance óptima en sistemas Unix

### 🌐 **Browser-Based Injection:**
- Utiliza Roblox Web en lugar de cliente desktop
- Inyección a través de Playwright/Chromium
- Compatible con cualquier juego de Roblox

### 🎨 **GUI Moderna:**
- Interfaz gráfica dark theme
- Editor de código integrado con syntax highlighting
- Console output en tiempo real
- Carga/guardado de scripts

### ⚡ **Motor de Conversión:**
- Convierte automáticamente Lua a JavaScript
- Mantiene compatibilidad con scripts existentes
- Soporte para APIs comunes de Roblox

---

## 🚀 **INSTALACIÓN RÁPIDA:**

### **📋 Opción 1 - Script Automático:**
```bash
# Descargar e instalar automáticamente
chmod +x install_linuxblox.sh
./install_linuxblox.sh
```

### **🔧 Opción 2 - Manual:**
```bash
# Instalar dependencias
sudo apt update
sudo apt install python3 python3-pip python3-tk

# Instalar Playwright
pip3 install playwright
python3 -m playwright install chromium

# Ejecutar LinuxBlox
python3 linuxblox_executor.py
```

---

## 🎮 **CÓMO USAR:**

### **📋 Pasos Básicos:**
1. **Ejecuta LinuxBlox Executor**
   ```bash
   python3 linuxblox_executor.py
   ```

2. **Launch & Inject**
   - Click en "🚀 Launch & Inject Roblox"
   - Se abrirá Chromium con Roblox Web
   - Espera la confirmación "Status: Injected ✅"

3. **Unirse a un Juego**
   - Ve a Death Ball (o cualquier juego)
   - Espera a que cargue completamente

4. **Ejecutar Scripts**
   - Pega tu script en el editor
   - Click en "⚡ Execute Script"
   - ¡El script se ejecutará en el juego!

---

## 🧪 **EJEMPLO DE USO CON DEATH BALL:**

### **📝 Script de Prueba:**
```lua
-- Script de Auto Parry para Death Ball
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

print("🐧 LinuxBlox Auto Parry iniciando...")

local function findBall()
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("ball") then
            return obj
        end
    end
    return nil
end

local function autoParry()
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    local ball = findBall()
    if not ball then return end
    
    local distance = (ball.Position - humanoidRootPart.Position).Magnitude
    if distance < 15 and ball.Velocity.Magnitude > 10 then
        -- Ejecutar parry
        game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.F, false, game)
        wait(0.01)
        game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.F, false, game)
        print("🏐 Parry ejecutado! Distancia:", distance)
    end
end

-- Activar auto parry
local autoParryEnabled = true
RunService.Heartbeat:Connect(function()
    if autoParryEnabled then
        autoParry()
    end
end)

game.StarterGui:SetCore("SendNotification", {
    Title = "LinuxBlox Auto Parry",
    Text = "✅ Auto Parry activo!",
    Duration = 3
})
```

---

## 🛠️ **ARQUITECTURA TÉCNICA:**

### **🌐 Browser Engine:**
- **Playwright** - Automatización de navegador
- **Chromium** - Engine de rendering
- **JavaScript Injection** - Ejecución de código

### **🔄 Conversion Engine:**
- **Lua Parser** - Análisis de sintaxis Lua
- **JavaScript Transpiler** - Conversión a JS
- **API Mapping** - Remap de APIs Roblox

### **🎨 GUI Framework:**
- **Tkinter** - Interfaz gráfica nativa
- **asyncio** - Operaciones asíncronas
- **Threading** - Multi-threading para responsividad

---

## 🔧 **CARACTERÍSTICAS AVANZADAS:**

### **💾 Gestión de Scripts:**
- Cargar/guardar scripts desde archivos
- Biblioteca de scripts predefinidos
- Historial de scripts ejecutados

### **🐛 Debugging:**
- Console output en tiempo real
- Error reporting detallado
- Logs de inyección y ejecución

### **⚙️ Configuración:**
- Settings persistentes
- Keybinds personalizables
- Themes de interfaz

---

## 🎯 **VENTAJAS SOBRE EXECUTORS DE WINDOWS:**

### ✅ **LinuxBlox (Linux):**
- ✅ **Nativo** - No emulación
- ✅ **Open Source** - Código transparente
- ✅ **Seguro** - Sin malware
- ✅ **Gratis** - Completamente libre
- ✅ **Actualizable** - Fácil de mantener
- ✅ **Cross-platform** - Funciona en muchos sistemas

### ❌ **Executors Windows:**
- ❌ **Cerrados** - Código oculto
- ❌ **Malware** - Muchos contienen virus
- ❌ **Pagos** - Synapse X, etc.
- ❌ **Detección** - Fácilmente detectables
- ❌ **Wine Issues** - Problemas en Linux

---

## 📊 **COMPATIBILIDAD:**

### **🐧 Sistemas Operativos:**
- ✅ Ubuntu 18.04+
- ✅ Debian 10+
- ✅ CentOS 7+
- ✅ Fedora 30+
- ✅ Arch Linux
- ✅ OpenSUSE
- ✅ Linux Mint

### **🎮 Juegos de Roblox:**
- ✅ Death Ball
- ✅ Blade Ball
- ✅ Arsenal
- ✅ Jailbreak
- ✅ Adopt Me
- ✅ Brookhaven RP
- ✅ Cualquier juego compatible con Roblox Web

---

## 🔮 **ROADMAP FUTURO:**

### **📈 Versión 1.1:**
- [ ] Syntax highlighting para Lua
- [ ] Auto-completion en editor
- [ ] Biblioteca de scripts integrada
- [ ] Themes personalizables

### **🚀 Versión 2.0:**
- [ ] Memory injection nativa
- [ ] Support para Roblox Desktop en Wine
- [ ] Plugin system
- [ ] Script marketplace

### **⭐ Versión 3.0:**
- [ ] Machine learning para detección automática
- [ ] Cloud sync de scripts
- [ ] Collaborative editing
- [ ] Mobile support (Android)

---

## 🤝 **CONTRIBUIR:**

### **🛠️ Desarrollo:**
```bash
# Fork el repositorio
git clone https://github.com/username/linuxblox-executor
cd linuxblox-executor

# Crear rama para feature
git checkout -b feature/nueva-funcionalidad

# Hacer cambios y commit
git commit -m "feat: nueva funcionalidad"

# Push y crear PR
git push origin feature/nueva-funcionalidad
```

### **🐛 Reportar Bugs:**
- Crea un issue en GitHub
- Incluye logs completos
- Especifica distribución Linux
- Proporciona pasos para reproducir

---

## 📜 **LICENCIA:**

**MIT License** - Libre para usar, modificar y distribuir.

---

## 🎊 **¡BIENVENIDO A LA ERA DE ROBLOX EN LINUX!**

**LinuxBlox Executor** marca el comienzo de una nueva era donde los usuarios de Linux pueden disfrutar de Roblox scripting sin limitaciones. ¡Es hora de que Linux tenga su propio executor!

**¿Listo para ser pionero en Roblox scripting en Linux?** 🐧🚀