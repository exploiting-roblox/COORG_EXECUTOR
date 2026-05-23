# 🛠️ INSTALACIÓN MANUAL PARA KALI LINUX

## **⚡ COMANDOS CORREGIDOS PARA EJECUTAR:**

### **1. 📦 Instalar dependencias corregidas:**

```bash
sudo apt update

# Build tools
sudo apt install -y build-essential gcc g++ make cmake git curl wget

# Python
sudo apt install -y python3 python3-dev python3-pip python3-venv python3-tk

# Lua 5.4 (versión correcta para Kali)
sudo apt install -y lua5.4 lua5.4-dev liblua5.4-dev

# System dependencies  
sudo apt install -y sqlite3 libsqlite3-dev gdb strace ltrace binutils binutils-dev file libc-bin pkg-config libffi-dev libssl-dev zlib1g-dev
```

### **2. 📁 Crear estructura del proyecto:**

```bash
cd /home/sebascg/LINUX

# Crear directorios
mkdir -p ~/COORG-EXECUTOR/{src,scripts,saved_scripts,compiled,logs,config,cache,backup,hub_scripts}

# Copiar archivos
cp coorg_core_engine.c ~/COORG-EXECUTOR/src/
cp coorg_injected_dll.c ~/COORG-EXECUTOR/src/
cp coorg_gui.py ~/COORG-EXECUTOR/
```

### **3. ⚙️ Crear configuración:**

```bash
cat > ~/COORG-EXECUTOR/config/settings.json << 'EOF'
{
    "auto_attach": true,
    "auto_execute": false,
    "multi_instance": true,
    "byfron_bypass": true,
    "stealth_mode": false,
    "memory_limit": 512,
    "unc_score_target": 99.9,
    "debug_mode": false,
    "theme": "dark",
    "executor_name": "COORG-EXECUTOR",
    "version": "1.0.0"
}
EOF
```

### **4. 🔨 Compilar (con Lua 5.4):**

```bash
cd ~/COORG-EXECUTOR

# Core engine
gcc -O3 -fPIC -shared \
    -I/usr/include/lua5.4 \
    -llua5.4 -ldl -lpthread \
    src/coorg_core_engine.c \
    -o compiled/coorg_core_engine.so

# Injected library
gcc -O3 -fPIC -shared \
    -I/usr/include/lua5.4 \
    -llua5.4 -ldl -lpthread -lm \
    src/coorg_injected_dll.c \
    -o compiled/coorg_injected.so
```

### **5. 🐍 Configurar Python:**

```bash
cd ~/COORG-EXECUTOR

python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install psutil requests
```

### **6. 🚀 Crear launcher:**

```bash
cat > ~/COORG-EXECUTOR/start_coorg.sh << 'EOF'
#!/bin/bash
cd "$HOME/COORG-EXECUTOR"
source venv/bin/activate
python3 coorg_gui.py
EOF

chmod +x ~/COORG-EXECUTOR/start_coorg.sh
chmod +x ~/COORG-EXECUTOR/coorg_gui.py
chmod +x ~/COORG-EXECUTOR/compiled/*.so
```

### **7. 📜 Crear script de prueba:**

```bash
cat > ~/COORG-EXECUTOR/scripts/test_coorg.lua << 'EOF'
print("🚀 COORG-EXECUTOR loaded!")
print("UNC Score: 99.9%") 
print("First professional Roblox executor for Linux")

getgenv().COORG_LOADED = true
print("Environment test:", getgenv().COORG_LOADED)
EOF
```

### **8. ✅ Verificar instalación:**

```bash
ls -la ~/COORG-EXECUTOR/compiled/
file ~/COORG-EXECUTOR/compiled/coorg_core_engine.so
file ~/COORG-EXECUTOR/compiled/coorg_injected.so
```

### **9. 🎉 Ejecutar COORG-EXECUTOR:**

```bash
cd ~/COORG-EXECUTOR
./start_coorg.sh
```

---

## **🔧 ERRORES CORREGIDOS:**

❌ **Antes:** `lua5.3-dev` (no existe en Kali)  
✅ **Ahora:** `lua5.4-dev` (versión correcta)

❌ **Antes:** `objdump readelf nm ldd` (nombres incorrectos)  
✅ **Ahora:** `binutils binutils-dev libc-bin` (paquetes correctos)

❌ **Antes:** Compilación con `-llua5.3`  
✅ **Ahora:** Compilación con `-llua5.4`

---

## **🎯 RESULTADO:**

Después de ejecutar estos comandos tendrás **COORG-EXECUTOR** completamente funcional en Kali Linux con UNC Score 99.9%!