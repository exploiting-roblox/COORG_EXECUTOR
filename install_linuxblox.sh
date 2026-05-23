#!/bin/bash

# LinuxBlox Executor - Installation Script
# Instala todas las dependencias necesarias para el primer executor nativo de Linux

echo "🐧 LinuxBlox Executor - Instalación Automática"
echo "================================================"

# Detectar distribución
if [ -f /etc/debian_version ]; then
    DISTRO="debian"
elif [ -f /etc/redhat-release ]; then
    DISTRO="redhat"
elif [ -f /etc/arch-release ]; then
    DISTRO="arch"
else
    DISTRO="unknown"
fi

echo "📋 Sistema detectado: $DISTRO"

# Función de instalación para Debian/Ubuntu
install_debian() {
    echo "📦 Instalando dependencias para Debian/Ubuntu..."
    
    sudo apt update
    sudo apt install -y python3 python3-pip python3-tk python3-dev
    
    echo "🔧 Instalando dependencias Python..."
    pip3 install --user playwright tkinter-modernui asyncio
    
    echo "🌐 Instalando navegadores Playwright..."
    python3 -m playwright install chromium
    
    # Dependencias adicionales para Chromium
    sudo apt install -y libnss3 libatk-bridge2.0-0 libdrm2 libxcomposite1 \
                       libxdamage1 libxrandr2 libgbm1 libgtk-3-0 libasound2
}

# Función de instalación para Red Hat/CentOS/Fedora
install_redhat() {
    echo "📦 Instalando dependencias para Red Hat/CentOS/Fedora..."
    
    sudo dnf install -y python3 python3-pip python3-tkinter python3-devel
    
    echo "🔧 Instalando dependencias Python..."
    pip3 install --user playwright asyncio
    
    echo "🌐 Instalando navegadores Playwright..."
    python3 -m playwright install chromium
    
    # Dependencias adicionales para Chromium
    sudo dnf install -y nss atk at-spi2-atk libdrm libxcomposite libxdamage \
                        libxrandr mesa-libgbm gtk3 alsa-lib
}

# Función de instalación para Arch Linux
install_arch() {
    echo "📦 Instalando dependencias para Arch Linux..."
    
    sudo pacman -S --noconfirm python python-pip tk
    
    echo "🔧 Instalando dependencias Python..."
    pip3 install --user playwright asyncio
    
    echo "🌐 Instalando navegadores Playwright..."
    python3 -m playwright install chromium
    
    # Dependencias adicionales para Chromium
    sudo pacman -S --noconfirm nss atk-bridge2 libdrm libxcomposite \
                               libxdamage libxrandr mesa gtk3 alsa-lib
}

# Instalación según distribución
case $DISTRO in
    "debian")
        install_debian
        ;;
    "redhat")
        install_redhat
        ;;
    "arch")
        install_arch
        ;;
    *)
        echo "❌ Distribución no soportada automáticamente"
        echo "📋 Instala manualmente: python3, pip3, tkinter, playwright"
        exit 1
        ;;
esac

# Crear directorio de scripts
echo "📁 Creando directorio de scripts..."
mkdir -p ~/LinuxBlox/scripts
mkdir -p ~/LinuxBlox/saved_scripts

# Hacer ejecutable
chmod +x ~/LinuxBlox/linuxblox_executor.py

echo ""
echo "✅ ¡Instalación completada!"
echo ""
echo "🚀 Para ejecutar LinuxBlox Executor:"
echo "   cd ~/LinuxBlox"
echo "   python3 linuxblox_executor.py"
echo ""
echo "📝 Características:"
echo "   • Primer executor nativo para Linux"
echo "   • Inyección browser-based (sin Wine)"
echo "   • GUI moderna con editor integrado"
echo "   • Soporte para scripts de Death Ball"
echo "   • Conversión automática Lua -> JavaScript"
echo ""
echo "🎮 Uso:"
echo "   1. Ejecuta LinuxBlox Executor"
echo "   2. Click en 'Launch & Inject Roblox'"
echo "   3. Ve a Death Ball en el navegador"
echo "   4. Ejecuta tus scripts"
echo ""