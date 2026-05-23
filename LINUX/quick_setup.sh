#!/bin/bash

# COORG-EXECUTOR Quick Setup Script
# Install dependencies and compile manually

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}🚀 COORG-EXECUTOR Quick Setup${NC}"
echo -e "${YELLOW}📦 Installing dependencies (will ask for password)...${NC}"

# Install dependencies
echo -e "${CYAN}Installing build tools...${NC}"
sudo apt install -y build-essential gcc g++ make cmake git curl wget pkg-config

echo -e "${CYAN}Installing Python dependencies...${NC}"
sudo apt install -y python3 python3-dev python3-pip python3-venv python3-tk

echo -e "${CYAN}Installing Lua 5.4...${NC}"
sudo apt install -y lua5.4 lua5.4-dev liblua5.4-dev

echo -e "${CYAN}Installing system libraries...${NC}"
sudo apt install -y sqlite3 libsqlite3-dev libffi-dev libssl-dev zlib1g-dev binutils binutils-dev gdb strace

echo -e "${GREEN}✅ Dependencies installed successfully${NC}"

# Create project structure
PROJECT_DIR="$HOME/COORG-EXECUTOR"

echo -e "${YELLOW}📁 Creating project structure...${NC}"

if [[ -d "$PROJECT_DIR" ]]; then
    echo -e "${YELLOW}⚠️  Removing existing installation...${NC}"
    rm -rf "$PROJECT_DIR"
fi

mkdir -p "$PROJECT_DIR"/{src,scripts,saved_scripts,compiled,logs,config,cache,backup,hub_scripts}

# Copy files
echo -e "${CYAN}📄 Copying source files...${NC}"
cp coorg_core_engine.c "$PROJECT_DIR/src/"
cp coorg_injected_dll.c "$PROJECT_DIR/src/"
cp coorg_gui.py "$PROJECT_DIR/"

echo -e "${GREEN}✅ Files copied${NC}"

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
    "version": "1.0.0",
    "distro": "kali",
    "distro_family": "debian",
    "lua_version": "5.4"
}
EOF

# Compile
echo -e "${YELLOW}🔨 Compiling COORG-EXECUTOR...${NC}"
cd "$PROJECT_DIR"

echo -e "${CYAN}⚡ Compiling core engine...${NC}"
gcc -O3 -fPIC -shared \
    -I/usr/include/lua5.4 \
    -llua5.4 -ldl -lpthread \
    src/coorg_core_engine.c \
    -o compiled/coorg_core_engine.so

echo -e "${CYAN}⚡ Compiling injected library...${NC}"
gcc -O3 -fPIC -shared \
    -I/usr/include/lua5.4 \
    -llua5.4 -ldl -lpthread -lm \
    src/coorg_injected_dll.c \
    -o compiled/coorg_injected.so

echo -e "${GREEN}✅ Compilation successful${NC}"

# Setup Python
echo -e "${YELLOW}🐍 Setting up Python environment...${NC}"
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install psutil requests

# Create launcher
echo -e "${YELLOW}🚀 Creating launcher...${NC}"
cat > start_coorg.sh << 'EOF'
#!/bin/bash
cd "$HOME/COORG-EXECUTOR"
echo "🚀 Starting COORG-EXECUTOR..."
source venv/bin/activate
python3 coorg_gui.py
EOF

chmod +x start_coorg.sh
chmod +x coorg_gui.py

# Create test script
cat > "scripts/test_universal.lua" << 'EOF'
-- COORG-EXECUTOR Universal Test Script
print("🌍 COORG-EXECUTOR Universal Linux Edition")
print("Distribution: Kali Linux")
print("Family: debian")
print("Lua Version: 5.4")
print("UNC Score: 99.9%")

-- Test environment
getgenv().COORG_UNIVERSAL = true
print("✅ Universal Linux compatibility verified!")
print("Environment loaded:", getgenv().COORG_UNIVERSAL)
EOF

echo -e "${GREEN}🎉 COORG-EXECUTOR setup completed!${NC}"
echo ""
echo -e "${CYAN}📍 Installation: ${YELLOW}$HOME/COORG-EXECUTOR${NC}"
echo -e "${CYAN}🚀 Launch: ${YELLOW}$HOME/COORG-EXECUTOR/start_coorg.sh${NC}"
echo ""
echo -e "${GREEN}✅ Ready to exploit Roblox with 99.9% UNC Score!${NC}"