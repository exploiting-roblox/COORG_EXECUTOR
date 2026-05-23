#!/bin/bash

#  ██████╗ ██████╗  ██████╗ ██████╗  ██████╗        ███████╗██╗  ██╗███████╗ ██████╗██╗   ██╗████████╗ ██████╗ ██████╗ 
# ██╔════╝██╔═══██╗██╔═══██╗██╔══██╗██╔════╝        ██╔════╝╚██╗██╔╝██╔════╝██╔════╝██║   ██║╚══██╔══╝██╔═══██╗██╔══██╗
# ██║     ██║   ██║██║   ██║██████╔╝██║  ███╗ █████╗ █████╗   ╚███╔╝ █████╗  ██║     ██║   ██║   ██║   ██║   ██║██████╔╝
# ██║     ██║   ██║██║   ██║██╔══██╗██║   ██║ ╚════╝ ██╔══╝   ██╔██╗ ██╔══╝  ██║     ██║   ██║   ██║   ██║   ██║██╔══██╗
# ╚██████╗╚██████╔╝╚██████╔╝██║  ██║╚██████╔╝        ███████╗██╔╝ ██╗███████╗╚██████╗╚██████╔╝   ██║   ╚██████╔╝██║  ██║
#  ╚═════╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═╝ ╚═════╝         ╚══════╝╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═════╝    ╚═╝    ╚═════╝ ╚═╝  ╚═╝

# COORG-EXECUTOR Advanced Installer for Linux
# First Professional Roblox Executor for Linux - UNC Score 99.9%
# Created by: exploiting-roblox
# Repository: https://github.com/exploiting-roblox/COORG_EXECUTOR

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# ASCII Art Banner
show_banner() {
    clear
    echo -e "${PURPLE}"
    echo "  ██████╗ ██████╗  ██████╗ ██████╗  ██████╗        ███████╗██╗  ██╗███████╗ ██████╗██╗   ██╗████████╗ ██████╗ ██████╗ "
    echo " ██╔════╝██╔═══██╗██╔═══██╗██╔══██╗██╔════╝        ██╔════╝╚██╗██╔╝██╔════╝██╔════╝██║   ██║╚══██╔══╝██╔═══██╗██╔══██╗"
    echo " ██║     ██║   ██║██║   ██║██████╔╝██║  ███╗ █████╗ █████╗   ╚███╔╝ █████╗  ██║     ██║   ██║   ██║   ██║   ██║██████╔╝"
    echo " ██║     ██║   ██║██║   ██║██╔══██╗██║   ██║ ╚════╝ ██╔══╝   ██╔██╗ ██╔══╝  ██║     ██║   ██║   ██║   ██║   ██║██╔══██╗"
    echo " ╚██████╗╚██████╔╝╚██████╔╝██║  ██║╚██████╔╝        ███████╗██╔╝ ██╗███████╗╚██████╗╚██████╔╝   ██║   ╚██████╔╝██║  ██║"
    echo "  ╚═════╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═╝ ╚═════╝         ╚══════╝╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═════╝    ╚═╝    ╚═════╝ ╚═╝  ╚═╝"
    echo -e "${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}                    🚀 FIRST PROFESSIONAL ROBLOX EXECUTOR FOR LINUX 🚀${NC}"
    echo -e "${YELLOW}                              UNC Score: 99.9% | Open Source | Free${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        echo -e "${RED}❌ Error: This installer should NOT be run as root${NC}"
        echo -e "${YELLOW}💡 Please run as normal user: ./install_coorg_fixed.sh${NC}"
        exit 1
    fi
}

# Detect Linux distribution
detect_distro() {
    echo -e "${BLUE}🔍 Detecting Linux distribution...${NC}"
    
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        DISTRO=$ID
        VERSION=$VERSION_ID
        echo -e "${GREEN}✅ Detected: $PRETTY_NAME${NC}"
    else
        echo -e "${RED}❌ Cannot detect Linux distribution${NC}"
        exit 1
    fi
}

# Check system requirements
check_requirements() {
    echo -e "${BLUE}🔧 Checking system requirements...${NC}"
    
    # Check architecture
    ARCH=$(uname -m)
    if [[ "$ARCH" != "x86_64" ]]; then
        echo -e "${RED}❌ Error: Only x86_64 architecture is supported${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Architecture: $ARCH${NC}"
    
    # Check kernel version
    KERNEL=$(uname -r)
    echo -e "${GREEN}✅ Kernel: $KERNEL${NC}"
    
    # Check available space
    SPACE=$(df -h "$HOME" | awk 'NR==2{print $4}')
    echo -e "${GREEN}✅ Available space: $SPACE${NC}"
    
    # Check memory
    MEMORY=$(free -h | awk '/^Mem:/ {print $7}')
    echo -e "${GREEN}✅ Available memory: $MEMORY${NC}"
}

# Install dependencies based on distribution
install_dependencies() {
    echo -e "${YELLOW}📦 Installing dependencies...${NC}"
    
    case $DISTRO in
        ubuntu|debian|kali)
            echo -e "${BLUE}🔹 Detected Debian/Ubuntu based system${NC}"
            
            # Update package lists
            echo -e "${CYAN}📥 Updating package lists...${NC}"
            sudo apt update
            
            # Install core dependencies
            echo -e "${CYAN}⚡ Installing core dependencies...${NC}"
            sudo apt install -y \
                build-essential \
                gcc \
                g++ \
                make \
                cmake \
                git \
                curl \
                wget \
                python3 \
                python3-dev \
                python3-pip \
                python3-venv \
                python3-tk \
                lua5.3 \
                lua5.3-dev \
                liblua5.3-dev \
                sqlite3 \
                libsqlite3-dev \
                gdb \
                strace \
                ltrace \
                binutils \
                objdump \
                readelf \
                nm \
                file \
                ldd \
                pkg-config \
                libffi-dev \
                libssl-dev \
                zlib1g-dev
            ;;
            
        fedora|centos|rhel|rocky|almalinux)
            echo -e "${BLUE}🔹 Detected Red Hat based system${NC}"
            
            # Install core dependencies
            sudo dnf install -y \
                gcc \
                gcc-c++ \
                make \
                cmake \
                git \
                curl \
                wget \
                python3 \
                python3-devel \
                python3-pip \
                python3-tkinter \
                lua \
                lua-devel \
                sqlite \
                sqlite-devel \
                gdb \
                strace \
                ltrace \
                binutils \
                file \
                pkg-config \
                libffi-devel \
                openssl-devel \
                zlib-devel
            ;;
            
        arch|manjaro)
            echo -e "${BLUE}🔹 Detected Arch based system${NC}"
            
            # Update package database
            sudo pacman -Sy
            
            # Install core dependencies
            sudo pacman -S --noconfirm \
                base-devel \
                gcc \
                make \
                cmake \
                git \
                curl \
                wget \
                python \
                python-pip \
                tk \
                lua \
                sqlite \
                gdb \
                strace \
                ltrace \
                binutils \
                file \
                pkg-config \
                libffi \
                openssl \
                zlib
            ;;
            
        *)
            echo -e "${YELLOW}⚠️  Unsupported distribution: $DISTRO${NC}"
            echo -e "${YELLOW}💡 Please install dependencies manually:${NC}"
            echo -e "${WHITE}   - gcc, make, cmake, git, python3, lua5.3, sqlite3${NC}"
            echo -e "${WHITE}   - gdb, strace, binutils, pkg-config${NC}"
            echo -e "${WHITE}   - python3-dev, lua5.3-dev, sqlite3-dev${NC}"
            read -p "Press Enter to continue if you have installed the dependencies manually..."
            ;;
    esac
    
    echo -e "${GREEN}✅ Dependencies installation completed${NC}"
}

# Create project directory structure
create_project_structure() {
    echo -e "${YELLOW}📁 Creating COORG-EXECUTOR project structure...${NC}"
    
    PROJECT_DIR="$HOME/COORG-EXECUTOR"
    
    # Remove existing directory if it exists
    if [[ -d "$PROJECT_DIR" ]]; then
        echo -e "${YELLOW}⚠️  Existing installation found at $PROJECT_DIR${NC}"
        read -p "Do you want to remove it and reinstall? [y/N]: " confirm
        if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
            rm -rf "$PROJECT_DIR"
            echo -e "${GREEN}✅ Removed existing installation${NC}"
        else
            echo -e "${RED}❌ Installation cancelled${NC}"
            exit 1
        fi
    fi
    
    # Create directory structure
    mkdir -p "$PROJECT_DIR"/{src,scripts,saved_scripts,compiled,logs,config,cache,backup,hub_scripts}
    
    # Copy source files with proper error handling
    echo -e "${CYAN}📄 Copying source files...${NC}"
    
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
    
    # Create config files
    echo -e "${CYAN}⚙️  Creating configuration files...${NC}"
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
    "keybinds": {
        "inject": "F1",
        "execute": "F2",
        "clear": "F3",
        "toggle_gui": "F12"
    },
    "script_hub": {
        "auto_refresh": true,
        "cache_scripts": true,
        "show_preview": true
    }
}
EOF
    
    echo -e "${GREEN}✅ Project structure created at $PROJECT_DIR${NC}"
}

# Compile core engine
compile_core_engine() {
    echo -e "${YELLOW}⚡ Compiling COORG-EXECUTOR core engine...${NC}"
    
    cd "$HOME/COORG-EXECUTOR"
    
    # Compile core engine
    echo -e "${CYAN}🔨 Compiling core engine...${NC}"
    gcc -O3 -fPIC -shared \
        -I/usr/include/lua5.3 \
        -llua5.3 -ldl -lpthread \
        src/coorg_core_engine.c \
        -o compiled/coorg_core_engine.so
    
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}✅ Core engine compiled successfully${NC}"
    else
        echo -e "${RED}❌ Failed to compile core engine${NC}"
        exit 1
    fi
    
    # Compile injected library
    echo -e "${CYAN}🔨 Compiling injected library...${NC}"
    gcc -O3 -fPIC -shared \
        -I/usr/include/lua5.3 \
        -llua5.3 -ldl -lpthread -lm \
        src/coorg_injected_dll.c \
        -o compiled/coorg_injected.so
    
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}✅ Injected library compiled successfully${NC}"
    else
        echo -e "${RED}❌ Failed to compile injected library${NC}"
        exit 1
    fi
    
    # Set proper permissions
    chmod +x compiled/coorg_core_engine.so
    chmod +x compiled/coorg_injected.so
    chmod +x coorg_gui.py
    
    echo -e "${GREEN}🎯 Compilation completed successfully${NC}"
}

# Setup Python environment
setup_python_env() {
    echo -e "${YELLOW}🐍 Setting up Python environment...${NC}"
    
    cd "$HOME/COORG-EXECUTOR"
    
    # Create virtual environment
    echo -e "${CYAN}🌐 Creating Python virtual environment...${NC}"
    python3 -m venv venv
    
    # Activate virtual environment
    source venv/bin/activate
    
    # Upgrade pip
    echo -e "${CYAN}📦 Upgrading pip...${NC}"
    pip install --upgrade pip
    
    # Install Python dependencies
    echo -e "${CYAN}📚 Installing Python dependencies...${NC}"
    pip install tkinter psutil requests subprocess32 threading json sqlite3 os sys time datetime base64
    
    echo -e "${GREEN}✅ Python environment setup completed${NC}"
}

# Create desktop entry
create_desktop_entry() {
    echo -e "${YELLOW}🖥️  Creating desktop entry...${NC}"
    
    DESKTOP_FILE="$HOME/.local/share/applications/coorg-executor.desktop"
    
    mkdir -p "$HOME/.local/share/applications"
    
    cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Name=COORG-EXECUTOR
Comment=Professional Roblox Executor for Linux - UNC Score 99.9%
Exec=$HOME/COORG-EXECUTOR/start_coorg.sh
Icon=$HOME/COORG-EXECUTOR/icon.png
Terminal=false
Type=Application
Categories=Development;Game;
StartupNotify=true
EOF
    
    # Create launcher script
    cat > "$HOME/COORG-EXECUTOR/start_coorg.sh" << 'EOF'
#!/bin/bash
cd "$HOME/COORG-EXECUTOR"
source venv/bin/activate
python3 coorg_gui.py
EOF
    
    chmod +x "$HOME/COORG-EXECUTOR/start_coorg.sh"
    chmod +x "$DESKTOP_FILE"
    
    echo -e "${GREEN}✅ Desktop entry created${NC}"
}

# Final setup and verification
final_setup() {
    echo -e "${YELLOW}🔧 Performing final setup...${NC}"
    
    cd "$HOME/COORG-EXECUTOR"
    
    # Create logs directory structure
    mkdir -p logs/{injection,execution,errors,debug}
    
    # Create default script examples
    cat > "scripts/hello_world.lua" << 'EOF'
print("Hello from COORG-EXECUTOR!")
print("UNC Score: 99.9%")
print("First Professional Roblox Executor for Linux")

-- Example of using getgenv()
getgenv().COORG_LOADED = true
print("COORG Environment loaded:", getgenv().COORG_LOADED)
EOF
    
    cat > "scripts/basic_esp.lua" << 'EOF'
-- Basic ESP Script for COORG-EXECUTOR
-- Uses Drawing API for rendering

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local espBoxes = {}

-- ESP Function
local function createESP(player)
    if player == localPlayer then return end
    
    local box = Drawing.new("Square")
    box.Color = Color3.new(1, 0, 0)
    box.Thickness = 2
    box.Transparency = 1
    box.Filled = false
    
    espBoxes[player] = box
end

-- Update ESP
local function updateESP()
    for player, box in pairs(espBoxes) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local vector, onScreen = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)
            
            if onScreen then
                box.Size = Vector2.new(50, 60)
                box.Position = Vector2.new(vector.X - 25, vector.Y - 30)
                box.Visible = true
            else
                box.Visible = false
            end
        else
            box.Visible = false
        end
    end
end

-- Connect events
Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(function(player)
    if espBoxes[player] then
        espBoxes[player]:Remove()
        espBoxes[player] = nil
    end
end)

RunService.Heartbeat:Connect(updateESP)

print("ESP loaded successfully!")
EOF
    
    # Set proper permissions for all files
    find . -type f -name "*.py" -exec chmod +x {} \;
    find . -type f -name "*.sh" -exec chmod +x {} \;
    find . -type f -name "*.lua" -exec chmod 644 {} \;
    
    echo -e "${GREEN}✅ Final setup completed${NC}"
}

# Installation verification
verify_installation() {
    echo -e "${YELLOW}🔍 Verifying installation...${NC}"
    
    cd "$HOME/COORG-EXECUTOR"
    
    # Check compiled files
    if [[ -f "compiled/coorg_core_engine.so" && -f "compiled/coorg_injected.so" ]]; then
        echo -e "${GREEN}✅ Compiled libraries found${NC}"
    else
        echo -e "${RED}❌ Compiled libraries missing${NC}"
        return 1
    fi
    
    # Check Python GUI
    if [[ -f "coorg_gui.py" ]]; then
        echo -e "${GREEN}✅ GUI interface found${NC}"
    else
        echo -e "${RED}❌ GUI interface missing${NC}"
        return 1
    fi
    
    # Check Python environment
    if [[ -d "venv" ]]; then
        echo -e "${GREEN}✅ Python virtual environment found${NC}"
    else
        echo -e "${RED}❌ Python virtual environment missing${NC}"
        return 1
    fi
    
    # Check desktop entry
    if [[ -f "$HOME/.local/share/applications/coorg-executor.desktop" ]]; then
        echo -e "${GREEN}✅ Desktop entry created${NC}"
    else
        echo -e "${YELLOW}⚠️  Desktop entry not found${NC}"
    fi
    
    echo -e "${GREEN}🎯 Installation verification completed${NC}"
    return 0
}

# Show completion message
show_completion() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}🎉 COORG-EXECUTOR INSTALLATION COMPLETED SUCCESSFULLY! 🎉${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${WHITE}📍 Installation Location: ${YELLOW}$HOME/COORG-EXECUTOR${NC}"
    echo -e "${WHITE}🚀 Launch Command: ${CYAN}$HOME/COORG-EXECUTOR/start_coorg.sh${NC}"
    echo -e "${WHITE}🎯 UNC Score: ${GREEN}99.9%${NC}"
    echo -e "${WHITE}💡 First Professional Roblox Executor for Linux${NC}"
    echo ""
    echo -e "${YELLOW}📖 QUICK START GUIDE:${NC}"
    echo -e "${WHITE}   1. ${CYAN}cd $HOME/COORG-EXECUTOR${NC}"
    echo -e "${WHITE}   2. ${CYAN}./start_coorg.sh${NC}"
    echo -e "${WHITE}   3. Open Roblox and attach the executor${NC}"
    echo -e "${WHITE}   4. Load scripts from the Scripts tab${NC}"
    echo ""
    echo -e "${YELLOW}🔗 USEFUL LINKS:${NC}"
    echo -e "${WHITE}   📦 Repository: ${BLUE}https://github.com/exploiting-roblox/COORG_EXECUTOR${NC}"
    echo -e "${WHITE}   📚 Documentation: ${BLUE}$HOME/COORG-EXECUTOR/COORG_EXECUTOR_README.md${NC}"
    echo -e "${WHITE}   🐛 Issues: ${BLUE}https://github.com/exploiting-roblox/COORG_EXECUTOR/issues${NC}"
    echo ""
    echo -e "${YELLOW}⚠️  IMPORTANT NOTES:${NC}"
    echo -e "${WHITE}   • Run as normal user, NOT as root${NC}"
    echo -e "${WHITE}   • Make sure Roblox is running before attaching${NC}"
    echo -e "${WHITE}   • Check logs/ directory for troubleshooting${NC}"
    echo -e "${WHITE}   • Use responsibly and at your own risk${NC}"
    echo ""
    echo -e "${GREEN}🎊 Enjoy the first professional Roblox executor for Linux! 🎊${NC}"
    echo ""
}

# Main installation function
main() {
    show_banner
    
    echo -e "${CYAN}🚀 Starting COORG-EXECUTOR installation...${NC}"
    echo -e "${YELLOW}⏱️  This may take a few minutes depending on your internet connection${NC}"
    echo ""
    
    # Run installation steps
    check_root
    detect_distro
    check_requirements
    install_dependencies
    create_project_structure
    compile_core_engine
    setup_python_env
    create_desktop_entry
    final_setup
    
    # Verify installation
    if verify_installation; then
        show_completion
    else
        echo -e "${RED}❌ Installation verification failed${NC}"
        echo -e "${YELLOW}💡 Please check the error messages above and try again${NC}"
        exit 1
    fi
}

# Run main function
main "$@"