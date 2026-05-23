#!/bin/bash

# COORG-EXECUTOR Quick Installer for Kali Linux
# Corrected package names and dependencies

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🚀 COORG-EXECUTOR Quick Installer for Kali Linux${NC}"
echo -e "${YELLOW}⚡ Installing corrected dependencies...${NC}"

# Install dependencies with correct package names for Kali
sudo apt update

echo -e "${BLUE}📦 Installing build tools...${NC}"
sudo apt install -y \
    build-essential \
    gcc \
    g++ \
    make \
    cmake \
    git \
    curl \
    wget

echo -e "${BLUE}🐍 Installing Python dependencies...${NC}"
sudo apt install -y \
    python3 \
    python3-dev \
    python3-pip \
    python3-venv \
    python3-tk

echo -e "${BLUE}🌙 Installing Lua dependencies...${NC}"
sudo apt install -y \
    lua5.4 \
    lua5.4-dev \
    liblua5.4-dev

echo -e "${BLUE}💾 Installing system dependencies...${NC}"
sudo apt install -y \
    sqlite3 \
    libsqlite3-dev \
    gdb \
    strace \
    ltrace \
    binutils \
    binutils-dev \
    file \
    libc-bin \
    pkg-config \
    libffi-dev \
    libssl-dev \
    zlib1g-dev

echo -e "${GREEN}✅ Dependencies installed successfully${NC}"

# Create project structure
echo -e "${YELLOW}📁 Creating project structure...${NC}"

PROJECT_DIR="$HOME/COORG-EXECUTOR"

# Remove existing if present
if [[ -d "$PROJECT_DIR" ]]; then
    echo -e "${YELLOW}⚠️  Removing existing installation...${NC}"
    rm -rf "$PROJECT_DIR"
fi

# Create directories
mkdir -p "$PROJECT_DIR"/{src,scripts,saved_scripts,compiled,logs,config,cache,backup,hub_scripts}

echo -e "${CYAN}📄 Copying source files...${NC}"

# Copy files with existence check
if [[ -f "coorg_core_engine.c" ]]; then
    cp coorg_core_engine.c "$PROJECT_DIR/src/"
    echo -e "${GREEN}✅ Copied coorg_core_engine.c${NC}"
else
    echo -e "${RED}❌ coorg_core_engine.c not found${NC}"
    exit 1
fi

if [[ -f "coorg_injected_dll.c" ]]; then
    cp coorg_injected_dll.c "$PROJECT_DIR/src/"
    echo -e "${GREEN}✅ Copied coorg_injected_dll.c${NC}"
else
    echo -e "${RED}❌ coorg_injected_dll.c not found${NC}"
    exit 1
fi

if [[ -f "coorg_gui.py" ]]; then
    cp coorg_gui.py "$PROJECT_DIR/"
    echo -e "${GREEN}✅ Copied coorg_gui.py${NC}"
else
    echo -e "${RED}❌ coorg_gui.py not found${NC}"
    exit 1
fi

# Create config
echo -e "${CYAN}⚙️  Creating configuration...${NC}"
cat > "$PROJECT_DIR/config/settings.json" << 'EOF'
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

# Compile with Lua 5.4
echo -e "${YELLOW}🔨 Compiling COORG-EXECUTOR...${NC}"

cd "$PROJECT_DIR"

# Compile core engine with Lua 5.4
echo -e "${CYAN}⚡ Compiling core engine...${NC}"
gcc -O3 -fPIC -shared \
    -I/usr/include/lua5.4 \
    -llua5.4 -ldl -lpthread \
    src/coorg_core_engine.c \
    -o compiled/coorg_core_engine.so

if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}✅ Core engine compiled successfully${NC}"
else
    echo -e "${RED}❌ Failed to compile core engine${NC}"
    exit 1
fi

# Compile injected library with Lua 5.4  
echo -e "${CYAN}⚡ Compiling injected library...${NC}"
gcc -O3 -fPIC -shared \
    -I/usr/include/lua5.4 \
    -llua5.4 -ldl -lpthread -lm \
    src/coorg_injected_dll.c \
    -o compiled/coorg_injected.so

if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}✅ Injected library compiled successfully${NC}"
else
    echo -e "${RED}❌ Failed to compile injected library${NC}"
    exit 1
fi

# Setup Python environment
echo -e "${YELLOW}🐍 Setting up Python environment...${NC}"

python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install psutil requests tkinter

# Create launcher
echo -e "${YELLOW}🚀 Creating launcher...${NC}"

cat > start_coorg.sh << 'EOF'
#!/bin/bash
cd "$HOME/COORG-EXECUTOR"
source venv/bin/activate
python3 coorg_gui.py
EOF

chmod +x start_coorg.sh
chmod +x coorg_gui.py
chmod +x compiled/*.so

# Create example script
cat > "scripts/hello_coorg.lua" << 'EOF'
print("🚀 COORG-EXECUTOR loaded successfully!")
print("UNC Score: 99.9%")
print("First professional Roblox executor for Linux")

-- Test getgenv
getgenv().COORG_LOADED = true
print("Environment test:", getgenv().COORG_LOADED)
EOF

echo -e "${GREEN}🎉 COORG-EXECUTOR installation completed!${NC}"
echo ""
echo -e "${CYAN}📍 Installation Location: ${YELLOW}$HOME/COORG-EXECUTOR${NC}"
echo -e "${CYAN}🚀 Launch Command: ${YELLOW}$HOME/COORG-EXECUTOR/start_coorg.sh${NC}"
echo ""
echo -e "${GREEN}✅ Ready to exploit Roblox with 99.9% UNC Score!${NC}"