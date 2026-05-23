#!/bin/bash

# 🎯 ULTIMATE NMAP SCANNER CUSTOMIZABLE
# Máximo nivel de personalización para escaneos de red

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Variables globales para configuración
TARGET=""
SCAN_TYPE=""
PORT_SPEC=""
TIMING=""
HOST_DISCOVERY=""
SERVICE_DETECTION=""
OS_DETECTION=""
SCRIPT_SCAN=""
OUTPUT_OPTIONS=""
EVASION_OPTIONS=""
ADVANCED_OPTIONS=""
PERFORMANCE_OPTIONS=""

print_banner() {
    clear
    echo -e "${BLUE}"
    echo "███╗   ██╗███╗   ███╗ █████╗ ██████╗     ██╗   ██╗██╗  ████████╗██╗███╗   ███╗ █████╗ ████████╗███████╗"
    echo "████╗  ██║████╗ ████║██╔══██╗██╔══██╗    ██║   ██║██║  ╚══██╔══╝██║████╗ ████║██╔══██╗╚══██╔══╝██╔════╝"
    echo "██╔██╗ ██║██╔████╔██║███████║██████╔╝    ██║   ██║██║     ██║   ██║██╔████╔██║███████║   ██║   █████╗  "
    echo "██║╚██╗██║██║╚██╔╝██║██╔══██║██╔═══╝     ██║   ██║██║     ██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██╔══╝  "
    echo "██║ ╚████║██║ ╚═╝ ██║██║  ██║██║         ╚██████╔╝███████╗██║   ██║██║ ╚═╝ ██║██║  ██║   ██║   ███████╗"
    echo "╚═╝  ╚═══╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝          ╚═════╝ ╚══════╝╚═╝   ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚══════╝"
    echo -e "${NC}"
    echo -e "${CYAN}🎯 Ultimate Nmap Scanner - Máxima Personalización${NC}"
    echo -e "${YELLOW}⚠️  Solo usar en redes propias o con autorización${NC}"
    echo ""
}

detect_network_info() {
    echo -e "${YELLOW}🔍 Detectando información de red...${NC}"
    
    # Obtener IP local
    local_ip=$(ip route get 8.8.8.8 | awk '{print $7; exit}')
    
    # Obtener gateway
    gateway=$(ip route | awk '/default/ {print $3; exit}')
    
    # Obtener interface activa
    interface=$(ip route get 8.8.8.8 | awk '{print $5; exit}')
    
    # Calcular red
    if [[ $local_ip =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)\. ]]; then
        network="${BASH_REMATCH[1]}.${BASH_REMATCH[2]}.${BASH_REMATCH[3]}.0/24"
    fi
    
    echo -e "${GREEN}✅ Información detectada:${NC}"
    echo -e "  📱 Tu IP: ${CYAN}$local_ip${NC}"
    echo -e "  🌐 Gateway: ${CYAN}$gateway${NC}"
    echo -e "  🔌 Interface: ${CYAN}$interface${NC}"
    echo -e "  📍 Red sugerida: ${CYAN}$network${NC}"
    echo ""
}

select_target() {
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}            ${YELLOW}SELECCIÓN DE OBJETIVO${NC}           ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    detect_network_info
    
    echo -e "${YELLOW}¿Qué quieres escanear?${NC}"
    echo -e "  ${CYAN}1.${NC} Red completa (ej: 192.168.1.0/24)"
    echo -e "  ${CYAN}2.${NC} IP específica (ej: 192.168.1.1)"
    echo -e "  ${CYAN}3.${NC} Rango de IPs (ej: 192.168.1.1-100)"
    echo -e "  ${CYAN}4.${NC} Múltiples objetivos (ej: 192.168.1.1,192.168.1.5)"
    echo -e "  ${CYAN}5.${NC} Dominio/hostname (ej: example.com)"
    echo -e "  ${CYAN}6.${NC} Archivo con objetivos (ej: targets.txt)"
    echo ""
    
    read -p "Selecciona opción (1-6): " target_choice
    
    case $target_choice in
        1)
            echo -e "\n${CYAN}💡 Ejemplos de redes:${NC}"
            echo -e "  • ${network} (red detectada)"
            echo -e "  • 10.0.0.0/24"
            echo -e "  • 172.16.1.0/24"
            read -p "🎯 Ingresa la red: " TARGET
            ;;
        2)
            echo -e "\n${CYAN}💡 Ejemplos de IPs:${NC}"
            echo -e "  • ${gateway} (tu router)"
            echo -e "  • ${local_ip} (tu máquina)"
            read -p "🎯 Ingresa la IP: " TARGET
            ;;
        3)
            echo -e "\n${CYAN}💡 Ejemplos de rangos:${NC}"
            echo -e "  • 192.168.1.1-254"
            echo -e "  • 10.0.0.1-100"
            read -p "🎯 Ingresa el rango: " TARGET
            ;;
        4)
            echo -e "\n${CYAN}💡 Ejemplo:${NC} 192.168.1.1,192.168.1.5,192.168.1.10"
            read -p "🎯 Ingresa las IPs (separadas por coma): " TARGET
            ;;
        5)
            echo -e "\n${CYAN}💡 Ejemplos:${NC} google.com, example.org"
            read -p "🎯 Ingresa el dominio: " TARGET
            ;;
        6)
            echo -e "\n${CYAN}💡 Cada línea del archivo debe tener una IP/red${NC}"
            read -p "🎯 Ruta del archivo: " TARGET
            if [[ ! -f "$TARGET" ]]; then
                echo -e "${RED}❌ Archivo no encontrado${NC}"
                return 1
            fi
            TARGET="-iL $TARGET"
            ;;
        *)
            echo -e "${RED}❌ Opción inválida${NC}"
            return 1
            ;;
    esac
    
    echo -e "${GREEN}✅ Objetivo seleccionado: $TARGET${NC}"
}

select_host_discovery() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}         ${YELLOW}DESCUBRIMIENTO DE HOSTS${NC}          ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    echo -e "${YELLOW}¿Cómo quieres descubrir hosts?${NC}"
    echo -e "  ${CYAN}1.${NC} Ping normal (ICMP echo) - ${PURPLE}[por defecto]${NC}"
    echo -e "  ${CYAN}2.${NC} No ping - escanear directamente puertos ${PURPLE}[-Pn]${NC}"
    echo -e "  ${CYAN}3.${NC} Solo ping - no escanear puertos ${PURPLE}[-sn]${NC}"
    echo -e "  ${CYAN}4.${NC} TCP SYN ping ${PURPLE}[-PS]${NC}"
    echo -e "  ${CYAN}5.${NC} TCP ACK ping ${PURPLE}[-PA]${NC}"
    echo -e "  ${CYAN}6.${NC} UDP ping ${PURPLE}[-PU]${NC}"
    echo -e "  ${CYAN}7.${NC} SCTP INIT ping ${PURPLE}[-PY]${NC}"
    echo -e "  ${CYAN}8.${NC} IP Protocol ping ${PURPLE}[-PO]${NC}"
    echo -e "  ${CYAN}9.${NC} ARP ping (solo LAN) ${PURPLE}[-PR]${NC}"
    echo -e "  ${CYAN}10.${NC} Combinación personalizada"
    echo ""
    
    read -p "Selecciona opción (1-10): " discovery_choice
    
    case $discovery_choice in
        1) HOST_DISCOVERY="" ;;
        2) HOST_DISCOVERY="-Pn" ;;
        3) HOST_DISCOVERY="-sn" ;;
        4) 
            read -p "¿Puerto específico para TCP SYN ping? (Enter para 80): " syn_port
            HOST_DISCOVERY="-PS${syn_port:-80}"
            ;;
        5) 
            read -p "¿Puerto específico para TCP ACK ping? (Enter para 80): " ack_port
            HOST_DISCOVERY="-PA${ack_port:-80}"
            ;;
        6) 
            read -p "¿Puerto específico para UDP ping? (Enter para 53): " udp_port
            HOST_DISCOVERY="-PU${udp_port:-53}"
            ;;
        7) HOST_DISCOVERY="-PY" ;;
        8) HOST_DISCOVERY="-PO" ;;
        9) HOST_DISCOVERY="-PR" ;;
        10)
            echo -e "${CYAN}💡 Combina opciones (ej: -PS80,443 -PA22): ${NC}"
            read -p "🎯 Opciones personalizadas: " HOST_DISCOVERY
            ;;
        *)
            echo -e "${YELLOW}Usando ping normal por defecto${NC}"
            HOST_DISCOVERY=""
            ;;
    esac
    
    echo -e "${GREEN}✅ Descubrimiento: $HOST_DISCOVERY${NC}"
}

select_scan_type() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}            ${YELLOW}TIPO DE ESCANEO${NC}              ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    echo -e "${YELLOW}¿Qué tipo de escaneo quieres?${NC}"
    echo -e "  ${CYAN}1.${NC} TCP Connect scan ${PURPLE}[-sT]${NC} (compatibilidad máxima)"
    echo -e "  ${CYAN}2.${NC} TCP SYN scan ${PURPLE}[-sS]${NC} (sigiloso, requiere root)"
    echo -e "  ${CYAN}3.${NC} UDP scan ${PURPLE}[-sU]${NC} (servicios UDP)"
    echo -e "  ${CYAN}4.${NC} TCP ACK scan ${PURPLE}[-sA]${NC} (detectar firewalls)"
    echo -e "  ${CYAN}5.${NC} TCP Window scan ${PURPLE}[-sW]${NC} (como ACK pero diferente)"
    echo -e "  ${CYAN}6.${NC} TCP Maimon scan ${PURPLE}[-sM]${NC} (FIN+ACK)"
    echo -e "  ${CYAN}7.${NC} TCP FIN scan ${PURPLE}[-sF]${NC} (sigiloso, evade firewalls)"
    echo -e "  ${CYAN}8.${NC} TCP NULL scan ${PURPLE}[-sN]${NC} (sin flags TCP)"
    echo -e "  ${CYAN}9.${NC} TCP Xmas scan ${PURPLE}[-sX]${NC} (FIN+PSH+URG)"
    echo -e "  ${CYAN}10.${NC} SCTP INIT scan ${PURPLE}[-sY]${NC}"
    echo -e "  ${CYAN}11.${NC} SCTP COOKIE-ECHO scan ${PURPLE}[-sZ]${NC}"
    echo -e "  ${CYAN}12.${NC} IP Protocol scan ${PURPLE}[-sO]${NC}"
    echo -e "  ${CYAN}13.${NC} Idle scan ${PURPLE}[-sI]${NC} (ultra sigiloso, via zombie)"
    echo -e "  ${CYAN}14.${NC} Combinación personalizada"
    echo ""
    
    read -p "Selecciona opción (1-14): " scan_choice
    
    case $scan_choice in
        1) SCAN_TYPE="-sT" ;;
        2) SCAN_TYPE="-sS" ;;
        3) SCAN_TYPE="-sU" ;;
        4) SCAN_TYPE="-sA" ;;
        5) SCAN_TYPE="-sW" ;;
        6) SCAN_TYPE="-sM" ;;
        7) SCAN_TYPE="-sF" ;;
        8) SCAN_TYPE="-sN" ;;
        9) SCAN_TYPE="-sX" ;;
        10) SCAN_TYPE="-sY" ;;
        11) SCAN_TYPE="-sZ" ;;
        12) SCAN_TYPE="-sO" ;;
        13) 
            read -p "IP del zombie host: " zombie_ip
            SCAN_TYPE="-sI $zombie_ip"
            ;;
        14)
            echo -e "${CYAN}💡 Combina tipos (ej: -sS -sU para TCP+UDP): ${NC}"
            read -p "🎯 Tipos personalizados: " SCAN_TYPE
            ;;
        *)
            echo -e "${YELLOW}Usando TCP SYN scan por defecto${NC}"
            SCAN_TYPE="-sS"
            ;;
    esac
    
    echo -e "${GREEN}✅ Tipo de escaneo: $SCAN_TYPE${NC}"
}

select_ports() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}          ${YELLOW}ESPECIFICACIÓN DE PUERTOS${NC}        ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    echo -e "${YELLOW}¿Qué puertos quieres escanear?${NC}"
    echo -e "  ${CYAN}1.${NC} Top 1000 puertos ${PURPLE}[por defecto]${NC}"
    echo -e "  ${CYAN}2.${NC} Todos los puertos (1-65535) ${PURPLE}[-p-]${NC}"
    echo -e "  ${CYAN}3.${NC} Top 100 puertos más comunes ${PURPLE}[--top-ports 100]${NC}"
    echo -e "  ${CYAN}4.${NC} Top 200 puertos más comunes ${PURPLE}[--top-ports 200]${NC}"
    echo -e "  ${CYAN}5.${NC} Top 500 puertos más comunes ${PURPLE}[--top-ports 500]${NC}"
    echo -e "  ${CYAN}6.${NC} Escaneo rápido ${PURPLE}[-F]${NC} (100 puertos más comunes)"
    echo -e "  ${CYAN}7.${NC} Puertos específicos ${PURPLE}[-p puerto1,puerto2]${NC}"
    echo -e "  ${CYAN}8.${NC} Rango de puertos ${PURPLE}[-p 1-1000]${NC}"
    echo -e "  ${CYAN}9.${NC} Solo puertos TCP comunes ${PURPLE}[-p 21,22,23,25,53,80,110,443,993,995]${NC}"
    echo -e "  ${CYAN}10.${NC} Solo puertos web ${PURPLE}[-p 80,443,8080,8443]${NC}"
    echo -e "  ${CYAN}11.${NC} Personalizado avanzado"
    echo ""
    
    read -p "Selecciona opción (1-11): " port_choice
    
    case $port_choice in
        1) PORT_SPEC="" ;;
        2) PORT_SPEC="-p-" ;;
        3) PORT_SPEC="--top-ports 100" ;;
        4) PORT_SPEC="--top-ports 200" ;;
        5) PORT_SPEC="--top-ports 500" ;;
        6) PORT_SPEC="-F" ;;
        7) 
            echo -e "${CYAN}💡 Ejemplos: 80,443,22 o 21-25,80,443${NC}"
            read -p "🎯 Puertos específicos: " custom_ports
            PORT_SPEC="-p $custom_ports"
            ;;
        8)
            read -p "🎯 Rango (ej: 1-1000): " port_range
            PORT_SPEC="-p $port_range"
            ;;
        9) PORT_SPEC="-p 21,22,23,25,53,80,110,443,993,995" ;;
        10) PORT_SPEC="-p 80,443,8080,8443" ;;
        11)
            echo -e "${CYAN}💡 Opciones avanzadas:${NC}"
            echo -e "  • --top-ports N (top N puertos)"
            echo -e "  • -p U:53,T:80 (UDP 53, TCP 80)"
            echo -e "  • -p 1-100,200-300 (múltiples rangos)"
            read -p "🎯 Especificación personalizada: " PORT_SPEC
            ;;
        *)
            echo -e "${YELLOW}Usando top 1000 puertos por defecto${NC}"
            PORT_SPEC=""
            ;;
    esac
    
    echo -e "${GREEN}✅ Puertos: $PORT_SPEC${NC}"
}

select_timing() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}           ${YELLOW}TIMING Y RENDIMIENTO${NC}           ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    echo -e "${YELLOW}¿Qué velocidad/sigilo prefieres?${NC}"
    echo -e "  ${CYAN}1.${NC} Paranoico ${PURPLE}[-T0]${NC} (ultra sigiloso, muy lento)"
    echo -e "  ${CYAN}2.${NC} Sigiloso ${PURPLE}[-T1]${NC} (IDS evasion)"
    echo -e "  ${CYAN}3.${NC} Educado ${PURPLE}[-T2]${NC} (menos agresivo)"
    echo -e "  ${CYAN}4.${NC} Normal ${PURPLE}[-T3]${NC} (balance velocidad/sigilo)"
    echo -e "  ${CYAN}5.${NC} Agresivo ${PURPLE}[-T4]${NC} (más rápido)"
    echo -e "  ${CYAN}6.${NC} Insano ${PURPLE}[-T5]${NC} (máxima velocidad)"
    echo -e "  ${CYAN}7.${NC} Personalizado avanzado"
    echo ""
    
    read -p "Selecciona opción (1-7): " timing_choice
    
    case $timing_choice in
        1) TIMING="-T0" ;;
        2) TIMING="-T1" ;;
        3) TIMING="-T2" ;;
        4) TIMING="-T3" ;;
        5) TIMING="-T4" ;;
        6) TIMING="-T5" ;;
        7)
            echo -e "${CYAN}💡 Opciones personalizadas de timing:${NC}"
            echo -e "  • --min-hostgroup 1"
            echo -e "  • --max-hostgroup 100" 
            echo -e "  • --min-parallelism 1"
            echo -e "  • --max-parallelism 100"
            echo -e "  • --max-rtt-timeout 100ms"
            echo -e "  • --initial-rtt-timeout 100ms"
            echo -e "  • --max-retries 3"
            echo -e "  • --host-timeout 15m"
            echo -e "  • --scan-delay 1s"
            echo -e "  • --max-scan-delay 10s"
            read -p "🎯 Opciones de timing: " TIMING
            ;;
        *)
            echo -e "${YELLOW}Usando timing normal por defecto${NC}"
            TIMING="-T3"
            ;;
    esac
    
    echo -e "${GREEN}✅ Timing: $TIMING${NC}"
}

select_service_detection() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}        ${YELLOW}DETECCIÓN DE SERVICIOS${NC}           ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    echo -e "${YELLOW}¿Quieres detectar versiones de servicios?${NC}"
    echo -e "  ${CYAN}1.${NC} No detectar versiones ${PURPLE}[por defecto]${NC}"
    echo -e "  ${CYAN}2.${NC} Detección básica de versiones ${PURPLE}[-sV]${NC}"
    echo -e "  ${CYAN}3.${NC} Detección ligera ${PURPLE}[--version-light]${NC}"
    echo -e "  ${CYAN}4.${NC} Detección intensiva ${PURPLE}[--version-all]${NC}"
    echo -e "  ${CYAN}5.${NC} Solo si hay puerto abierto ${PURPLE}[-sV --version-trace]${NC}"
    echo -e "  ${CYAN}6.${NC} Personalizado"
    echo ""
    
    read -p "Selecciona opción (1-6): " service_choice
    
    case $service_choice in
        1) SERVICE_DETECTION="" ;;
        2) SERVICE_DETECTION="-sV" ;;
        3) SERVICE_DETECTION="-sV --version-light" ;;
        4) SERVICE_DETECTION="-sV --version-all" ;;
        5) SERVICE_DETECTION="-sV --version-trace" ;;
        6)
            echo -e "${CYAN}💡 Opciones disponibles:${NC}"
            echo -e "  • -sV (detección básica)"
            echo -e "  • --version-intensity N (0-9)"
            echo -e "  • --version-light (nivel 2)"
            echo -e "  • --version-all (nivel 9)"
            echo -e "  • --version-trace (debug)"
            read -p "🎯 Opciones personalizadas: " SERVICE_DETECTION
            ;;
        *)
            SERVICE_DETECTION=""
            ;;
    esac
    
    echo -e "${GREEN}✅ Detección de servicios: $SERVICE_DETECTION${NC}"
}

select_os_detection() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}         ${YELLOW}DETECCIÓN DE SISTEMA${NC}            ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    echo -e "${YELLOW}¿Detectar sistema operativo?${NC}"
    echo -e "  ${CYAN}1.${NC} No detectar ${PURPLE}[por defecto]${NC}"
    echo -e "  ${CYAN}2.${NC} Detección básica ${PURPLE}[-O]${NC}"
    echo -e "  ${CYAN}3.${NC} Agresiva ${PURPLE}[-O --osscan-guess]${NC}"
    echo -e "  ${CYAN}4.${NC} Límite de intentos ${PURPLE}[-O --osscan-limit]${NC}"
    echo -e "  ${CYAN}5.${NC} Sin límites ${PURPLE}[-O --max-os-tries 5]${NC}"
    echo ""
    
    read -p "Selecciona opción (1-5): " os_choice
    
    case $os_choice in
        1) OS_DETECTION="" ;;
        2) OS_DETECTION="-O" ;;
        3) OS_DETECTION="-O --osscan-guess" ;;
        4) OS_DETECTION="-O --osscan-limit" ;;
        5) OS_DETECTION="-O --max-os-tries 5" ;;
        *)
            OS_DETECTION=""
            ;;
    esac
    
    echo -e "${GREEN}✅ Detección de OS: $OS_DETECTION${NC}"
}

select_scripts() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}          ${YELLOW}SCRIPTS NSE (NMAP)${NC}              ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    echo -e "${YELLOW}¿Qué scripts quieres ejecutar?${NC}"
    echo -e "  ${CYAN}1.${NC} Sin scripts ${PURPLE}[por defecto]${NC}"
    echo -e "  ${CYAN}2.${NC} Scripts por defecto ${PURPLE}[-sC]${NC}"
    echo -e "  ${CYAN}3.${NC} 🔍 Buscar vulnerabilidades ${PURPLE}[--script vuln]${NC}"
    echo -e "  ${CYAN}4.${NC} 🔑 Fuerza bruta SSH ${PURPLE}[--script ssh-brute]${NC}"
    echo -e "  ${CYAN}5.${NC} 🌐 Fuerza bruta HTTP ${PURPLE}[--script http-brute]${NC}"
    echo -e "  ${CYAN}6.${NC} 📁 Fuerza bruta FTP ${PURPLE}[--script ftp-brute]${NC}"
    echo -e "  ${CYAN}7.${NC} 🏢 Vulnerabilidades SMB ${PURPLE}[--script smb-vuln*]${NC}"
    echo -e "  ${CYAN}8.${NC} 🔐 Métodos auth SSH ${PURPLE}[--script ssh-auth-methods]${NC}"
    echo -e "  ${CYAN}9.${NC} 💾 Fuerza bruta MySQL ${PURPLE}[--script mysql-brute]${NC}"
    echo -e "  ${CYAN}10.${NC} 📊 Información HTTP ${PURPLE}[--script http-enum]${NC}"
    echo -e "  ${CYAN}11.${NC} 🔥 COMBO VULNERABILIDADES (vuln+brute) ${PURPLE}[MEGA ATAQUE]${NC}"
    echo -e "  ${CYAN}12.${NC} 🎯 COMBO FUERZA BRUTA (ssh+http+ftp+mysql) ${PURPLE}[ALL BRUTE]${NC}"
    echo -e "  ${CYAN}13.${NC} 🏴‍☠️ COMBO SMB COMPLETO (enum+vuln+shares) ${PURPLE}[SMB TOTAL]${NC}"
    echo -e "  ${CYAN}14.${NC} 🌐 COMBO WEB COMPLETO (enum+vuln+brute+info) ${PURPLE}[WEB TOTAL]${NC}"
    echo -e "  ${CYAN}15.${NC} 🔓 COMBO AUTENTICACIÓN (auth-methods+brute) ${PURPLE}[AUTH TOTAL]${NC}"
    echo -e "  ${CYAN}16.${NC} 📡 Múltiples categorías personalizadas"
    echo -e "  ${CYAN}17.${NC} 🎪 Script específico avanzado"
    echo -e "  ${CYAN}18.${NC} 💀 MEGA COMBO AGRESIVO (TODO) ${RED}[PELIGROSO]${NC}"
    echo ""
    
    read -p "Selecciona opción (1-18): " script_choice
    
    case $script_choice in
        1) SCRIPT_SCAN="" ;;
        2) SCRIPT_SCAN="-sC" ;;
        3) SCRIPT_SCAN="--script vuln" ;;
        4) SCRIPT_SCAN="--script ssh-brute" ;;
        5) SCRIPT_SCAN="--script http-brute" ;;
        6) SCRIPT_SCAN="--script ftp-brute" ;;
        7) SCRIPT_SCAN="--script smb-vuln*" ;;
        8) SCRIPT_SCAN="--script ssh-auth-methods" ;;
        9) SCRIPT_SCAN="--script mysql-brute" ;;
        10) SCRIPT_SCAN="--script http-enum" ;;
        11) 
            SCRIPT_SCAN="--script vuln,ssh-brute,http-brute,ftp-brute,mysql-brute"
            echo -e "${RED}🔥 MEGA ATAQUE DE VULNERABILIDADES ACTIVADO${NC}"
            ;;
        12) 
            SCRIPT_SCAN="--script ssh-brute,http-brute,ftp-brute,mysql-brute"
            echo -e "${RED}🎯 COMBO FUERZA BRUTA COMPLETO ACTIVADO${NC}"
            ;;
        13) 
            SCRIPT_SCAN="--script smb-enum*,smb-vuln*,smb-shares,smb-os-discovery"
            echo -e "${RED}🏴‍☠️ COMBO SMB TOTAL ACTIVADO${NC}"
            ;;
        14) 
            SCRIPT_SCAN="--script http-enum,http-vuln*,http-brute,http-headers,http-title,http-methods"
            echo -e "${RED}🌐 COMBO WEB COMPLETO ACTIVADO${NC}"
            ;;
        15) 
            SCRIPT_SCAN="--script ssh-auth-methods,ftp-auth-methods,ssh-brute,ftp-brute,mysql-brute"
            echo -e "${RED}🔓 COMBO AUTENTICACIÓN TOTAL ACTIVADO${NC}"
            ;;
        16)
            echo -e "${CYAN}💡 Categorías disponibles:${NC}"
            echo -e "  • auth - autenticación"
            echo -e "  • broadcast - broadcast/multicast"
            echo -e "  • brute - fuerza bruta"
            echo -e "  • default - scripts por defecto"
            echo -e "  • discovery - descubrimiento"
            echo -e "  • dos - denial of service"
            echo -e "  • exploit - exploits"
            echo -e "  • external - servicios externos"
            echo -e "  • fuzzer - fuzzing"
            echo -e "  • intrusive - intrusivos"
            echo -e "  • malware - detección malware"
            echo -e "  • safe - seguros"
            echo -e "  • version - detección versiones"
            echo -e "  • vuln - vulnerabilidades"
            echo ""
            read -p "🎯 Categorías (separadas por coma): " categories
            SCRIPT_SCAN="--script $categories"
            ;;
        17)
            echo -e "${CYAN}💡 Scripts populares adicionales:${NC}"
            echo -e "  • http-title, http-headers, ssl-cert"
            echo -e "  • ftp-anon, smtp-enum-users, dns-brute"
            echo -e "  • smb-enum-shares, ssh2-enum-algos"
            echo -e "  • mysql-enum, oracle-enum-users"
            echo -e "  • vnc-brute, telnet-brute, pop3-brute"
            read -p "🎯 Script específico: " specific_script
            SCRIPT_SCAN="--script $specific_script"
            ;;
        18)
            SCRIPT_SCAN="--script vuln,auth,brute,discovery,exploit"
            echo -e "${RED}💀 MEGA COMBO AGRESIVO ACTIVADO - TODOS LOS ATAQUES${NC}"
            echo -e "${YELLOW}⚠️  ESTE COMBO ES EXTREMADAMENTE AGRESIVO${NC}"
            ;;
        *)
            SCRIPT_SCAN=""
            ;;
    esac
    
    # Preguntar por argumentos de script si se seleccionó alguno
    if [[ -n "$SCRIPT_SCAN" ]]; then
        echo ""
        read -p "¿Argumentos para los scripts? (Enter para ninguno): " script_args
        if [[ -n "$script_args" ]]; then
            SCRIPT_SCAN="$SCRIPT_SCAN --script-args $script_args"
        fi
    fi
    
    echo -e "${GREEN}✅ Scripts: $SCRIPT_SCAN${NC}"
}

select_output_options() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}           ${YELLOW}OPCIONES DE SALIDA${NC}             ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    echo -e "${YELLOW}¿Cómo quieres la salida?${NC}"
    echo -e "  ${CYAN}1.${NC} Solo pantalla ${PURPLE}[por defecto]${NC}"
    echo -e "  ${CYAN}2.${NC} Guardar en archivo normal ${PURPLE}[-oN archivo]${NC}"
    echo -e "  ${CYAN}3.${NC} Guardar en XML ${PURPLE}[-oX archivo]${NC}"
    echo -e "  ${CYAN}4.${NC} Guardar greppeable ${PURPLE}[-oG archivo]${NC}"
    echo -e "  ${CYAN}5.${NC} Guardar todos los formatos ${PURPLE}[-oA archivo]${NC}"
    echo -e "  ${CYAN}6.${NC} Verbose ${PURPLE}[-v]${NC}"
    echo -e "  ${CYAN}7.${NC} Extra verbose ${PURPLE}[-vv]${NC}"
    echo -e "  ${CYAN}8.${NC} Solo puertos abiertos ${PURPLE}[--open]${NC}"
    echo -e "  ${CYAN}9.${NC} Combo personalizado"
    echo ""
    
    read -p "Selecciona opción (1-9): " output_choice
    
    case $output_choice in
        1) OUTPUT_OPTIONS="" ;;
        2) 
            read -p "🎯 Nombre del archivo: " filename
            OUTPUT_OPTIONS="-oN ${filename:-scan_result}"
            ;;
        3) 
            read -p "🎯 Nombre del archivo XML: " filename
            OUTPUT_OPTIONS="-oX ${filename:-scan_result.xml}"
            ;;
        4) 
            read -p "🎯 Nombre del archivo greppeable: " filename
            OUTPUT_OPTIONS="-oG ${filename:-scan_result.gnmap}"
            ;;
        5) 
            read -p "🎯 Basename para archivos: " basename
            OUTPUT_OPTIONS="-oA ${basename:-scan_result}"
            ;;
        6) OUTPUT_OPTIONS="-v" ;;
        7) OUTPUT_OPTIONS="-vv" ;;
        8) OUTPUT_OPTIONS="--open" ;;
        9)
            echo -e "${CYAN}💡 Opciones disponibles:${NC}"
            echo -e "  • -v (verbose)"
            echo -e "  • -d (debug)"
            echo -e "  • --open (solo abiertos)"
            echo -e "  • --packet-trace (trace packets)"
            echo -e "  • --iflist (mostrar interfaces)"
            echo -e "  • -6 (IPv6)"
            read -p "🎯 Opciones combinadas: " OUTPUT_OPTIONS
            ;;
        *)
            OUTPUT_OPTIONS=""
            ;;
    esac
    
    echo -e "${GREEN}✅ Salida: $OUTPUT_OPTIONS${NC}"
}

select_evasion_options() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}          ${YELLOW}EVASIÓN Y FIREWALL${NC}             ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    echo -e "${YELLOW}¿Opciones de evasión?${NC}"
    echo -e "  ${CYAN}1.${NC} Sin evasión ${PURPLE}[por defecto]${NC}"
    echo -e "  ${CYAN}2.${NC} Fragmentar paquetes ${PURPLE}[-f]${NC}"
    echo -e "  ${CYAN}3.${NC} MTU específico ${PURPLE}[--mtu N]${NC}"
    echo -e "  ${CYAN}4.${NC} Decoy (señuelos) ${PURPLE}[-D decoy1,decoy2]${NC}"
    echo -e "  ${CYAN}5.${NC} IP spoofing ${PURPLE}[-S ip_falsa]${NC}"
    echo -e "  ${CYAN}6.${NC} Interface específica ${PURPLE}[-e interface]${NC}"
    echo -e "  ${CYAN}7.${NC} Puerto source específico ${PURPLE}[-g puerto]${NC}"
    echo -e "  ${CYAN}8.${NC} Data length ${PURPLE}[--data-length N]${NC}"
    echo -e "  ${CYAN}9.${NC} IP options ${PURPLE}[--ip-options]${NC}"
    echo -e "  ${CYAN}10.${NC} Randomizar hosts ${PURPLE}[--randomize-hosts]${NC}"
    echo -e "  ${CYAN}11.${NC} Combo evasión avanzada"
    echo ""
    
    read -p "Selecciona opción (1-11): " evasion_choice
    
    case $evasion_choice in
        1) EVASION_OPTIONS="" ;;
        2) EVASION_OPTIONS="-f" ;;
        3) 
            read -p "🎯 MTU size (ej: 24): " mtu_size
            EVASION_OPTIONS="--mtu ${mtu_size:-24}"
            ;;
        4) 
            echo -e "${CYAN}💡 Ejemplo: 192.168.1.1,192.168.1.2,ME${NC}"
            read -p "🎯 IPs señuelo (separadas por coma): " decoys
            EVASION_OPTIONS="-D $decoys"
            ;;
        5) 
            read -p "🎯 IP falsa: " fake_ip
            EVASION_OPTIONS="-S $fake_ip"
            ;;
        6) 
            read -p "🎯 Interface (ej: eth0): " interface
            EVASION_OPTIONS="-e $interface"
            ;;
        7) 
            read -p "🎯 Puerto source: " source_port
            EVASION_OPTIONS="-g $source_port"
            ;;
        8) 
            read -p "🎯 Data length: " data_length
            EVASION_OPTIONS="--data-length $data_length"
            ;;
        9) 
            echo -e "${CYAN}💡 Opciones: S (strict), L (loose), R (record), T (timestamp)${NC}"
            read -p "🎯 IP options: " ip_opts
            EVASION_OPTIONS="--ip-options $ip_opts"
            ;;
        10) EVASION_OPTIONS="--randomize-hosts" ;;
        11)
            echo -e "${CYAN}💡 Combo sugerido: fragmentación + decoys + randomización${NC}"
            read -p "🎯 IPs para decoys: " decoys
            EVASION_OPTIONS="-f -D $decoys --randomize-hosts"
            ;;
        *)
            EVASION_OPTIONS=""
            ;;
    esac
    
    echo -e "${GREEN}✅ Evasión: $EVASION_OPTIONS${NC}"
}

select_advanced_options() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}          ${YELLOW}OPCIONES AVANZADAS${NC}             ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    echo -e "${YELLOW}¿Opciones avanzadas adicionales?${NC}"
    echo -e "  ${CYAN}1.${NC} Sin opciones extra ${PURPLE}[por defecto]${NC}"
    echo -e "  ${CYAN}2.${NC} IPv6 ${PURPLE}[-6]${NC}"
    echo -e "  ${CYAN}3.${NC} Tratar como online ${PURPLE}[--reason]${NC}"
    echo -e "  ${CYAN}4.${NC} Resume scan ${PURPLE}[--resume archivo]${NC}"
    echo -e "  ${CYAN}5.${NC} Exclude targets ${PURPLE}[--exclude ip1,ip2]${NC}"
    echo -e "  ${CYAN}6.${NC} Exclude file ${PURPLE}[--excludefile archivo]${NC}"
    echo -e "  ${CYAN}7.${NC} Trace packets ${PURPLE}[--packet-trace]${NC}"
    echo -e "  ${CYAN}8.${NC} Debug level ${PURPLE}[-d nivel]${NC}"
    echo -e "  ${CYAN}9.${NC} Privileged mode ${PURPLE}[--privileged]${NC}"
    echo -e "  ${CYAN}10.${NC} Unprivileged mode ${PURPLE}[--unprivileged]${NC}"
    echo ""
    
    read -p "Selecciona opción (1-10): " advanced_choice
    
    case $advanced_choice in
        1) ADVANCED_OPTIONS="" ;;
        2) ADVANCED_OPTIONS="-6" ;;
        3) ADVANCED_OPTIONS="--reason" ;;
        4) 
            read -p "🎯 Archivo de resume: " resume_file
            ADVANCED_OPTIONS="--resume $resume_file"
            ;;
        5) 
            read -p "🎯 IPs a excluir (separadas por coma): " exclude_ips
            ADVANCED_OPTIONS="--exclude $exclude_ips"
            ;;
        6) 
            read -p "🎯 Archivo con IPs a excluir: " exclude_file
            ADVANCED_OPTIONS="--excludefile $exclude_file"
            ;;
        7) ADVANCED_OPTIONS="--packet-trace" ;;
        8) 
            read -p "🎯 Debug level (1-9): " debug_level
            ADVANCED_OPTIONS="-d${debug_level:-1}"
            ;;
        9) ADVANCED_OPTIONS="--privileged" ;;
        10) ADVANCED_OPTIONS="--unprivileged" ;;
        *)
            ADVANCED_OPTIONS=""
            ;;
    esac
    
    echo -e "${GREEN}✅ Avanzadas: $ADVANCED_OPTIONS${NC}"
}

show_command_summary() {
    local full_command="nmap"
    
    [[ -n "$HOST_DISCOVERY" ]] && full_command="$full_command $HOST_DISCOVERY"
    [[ -n "$SCAN_TYPE" ]] && full_command="$full_command $SCAN_TYPE"
    [[ -n "$PORT_SPEC" ]] && full_command="$full_command $PORT_SPEC"
    [[ -n "$TIMING" ]] && full_command="$full_command $TIMING"
    [[ -n "$SERVICE_DETECTION" ]] && full_command="$full_command $SERVICE_DETECTION"
    [[ -n "$OS_DETECTION" ]] && full_command="$full_command $OS_DETECTION"
    [[ -n "$SCRIPT_SCAN" ]] && full_command="$full_command $SCRIPT_SCAN"
    [[ -n "$OUTPUT_OPTIONS" ]] && full_command="$full_command $OUTPUT_OPTIONS"
    [[ -n "$EVASION_OPTIONS" ]] && full_command="$full_command $EVASION_OPTIONS"
    [[ -n "$ADVANCED_OPTIONS" ]] && full_command="$full_command $ADVANCED_OPTIONS"
    
    full_command="$full_command $TARGET"
    
    echo -e "\n${BLUE}╔══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}                          ${YELLOW}RESUMEN DEL COMANDO${NC}                           ${BLUE}║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════════════╝${NC}"
    
    echo -e "\n${GREEN}📋 Comando generado:${NC}"
    echo -e "${CYAN}$full_command${NC}"
    
    echo -e "\n${YELLOW}📊 Configuración seleccionada:${NC}"
    echo -e "  🎯 Objetivo: ${CYAN}$TARGET${NC}"
    [[ -n "$HOST_DISCOVERY" ]] && echo -e "  🔍 Host Discovery: ${CYAN}$HOST_DISCOVERY${NC}"
    [[ -n "$SCAN_TYPE" ]] && echo -e "  📡 Tipo Escaneo: ${CYAN}$SCAN_TYPE${NC}"
    [[ -n "$PORT_SPEC" ]] && echo -e "  🚪 Puertos: ${CYAN}$PORT_SPEC${NC}"
    [[ -n "$TIMING" ]] && echo -e "  ⏱️  Timing: ${CYAN}$TIMING${NC}"
    [[ -n "$SERVICE_DETECTION" ]] && echo -e "  🔧 Servicios: ${CYAN}$SERVICE_DETECTION${NC}"
    [[ -n "$OS_DETECTION" ]] && echo -e "  💻 OS Detection: ${CYAN}$OS_DETECTION${NC}"
    [[ -n "$SCRIPT_SCAN" ]] && echo -e "  📜 Scripts: ${CYAN}$SCRIPT_SCAN${NC}"
    [[ -n "$OUTPUT_OPTIONS" ]] && echo -e "  📄 Output: ${CYAN}$OUTPUT_OPTIONS${NC}"
    [[ -n "$EVASION_OPTIONS" ]] && echo -e "  🥷 Evasión: ${CYAN}$EVASION_OPTIONS${NC}"
    [[ -n "$ADVANCED_OPTIONS" ]] && echo -e "  ⚙️  Avanzadas: ${CYAN}$ADVANCED_OPTIONS${NC}"
    
    echo ""
    return 0
}

save_configuration() {
    local config_file="nmap_config_$(date +%Y%m%d_%H%M%S).conf"
    
    cat > "$config_file" << EOF
# Configuración Nmap Ultimate Scanner
# Generado: $(date)

TARGET="$TARGET"
HOST_DISCOVERY="$HOST_DISCOVERY"
SCAN_TYPE="$SCAN_TYPE"
PORT_SPEC="$PORT_SPEC"
TIMING="$TIMING"
SERVICE_DETECTION="$SERVICE_DETECTION"
OS_DETECTION="$OS_DETECTION"
SCRIPT_SCAN="$SCRIPT_SCAN"
OUTPUT_OPTIONS="$OUTPUT_OPTIONS"
EVASION_OPTIONS="$EVASION_OPTIONS"
ADVANCED_OPTIONS="$ADVANCED_OPTIONS"
EOF
    
    echo -e "${GREEN}💾 Configuración guardada en: $config_file${NC}"
}

load_configuration() {
    echo -e "${YELLOW}📁 Archivos de configuración disponibles:${NC}"
    ls -la nmap_config_*.conf 2>/dev/null || echo -e "${RED}No hay configuraciones guardadas${NC}"
    
    read -p "🎯 Archivo a cargar: " config_file
    
    if [[ -f "$config_file" ]]; then
        source "$config_file"
        echo -e "${GREEN}✅ Configuración cargada desde: $config_file${NC}"
        return 0
    else
        echo -e "${RED}❌ Archivo no encontrado${NC}"
        return 1
    fi
}

execute_scan() {
    local full_command="nmap"
    
    [[ -n "$HOST_DISCOVERY" ]] && full_command="$full_command $HOST_DISCOVERY"
    [[ -n "$SCAN_TYPE" ]] && full_command="$full_command $SCAN_TYPE"
    [[ -n "$PORT_SPEC" ]] && full_command="$full_command $PORT_SPEC"
    [[ -n "$TIMING" ]] && full_command="$full_command $TIMING"
    [[ -n "$SERVICE_DETECTION" ]] && full_command="$full_command $SERVICE_DETECTION"
    [[ -n "$OS_DETECTION" ]] && full_command="$full_command $OS_DETECTION"
    [[ -n "$SCRIPT_SCAN" ]] && full_command="$full_command $SCRIPT_SCAN"
    [[ -n "$OUTPUT_OPTIONS" ]] && full_command="$full_command $OUTPUT_OPTIONS"
    [[ -n "$EVASION_OPTIONS" ]] && full_command="$full_command $EVASION_OPTIONS"
    [[ -n "$ADVANCED_OPTIONS" ]] && full_command="$full_command $ADVANCED_OPTIONS"
    
    full_command="$full_command $TARGET"
    
    echo -e "\n${YELLOW}🚀 Ejecutando escaneo...${NC}"
    echo -e "${CYAN}$full_command${NC}\n"
    
    # Verificar si se necesitan privilegios root
    if [[ $SCAN_TYPE == *"-sS"* ]] || [[ $OS_DETECTION == *"-O"* ]] || [[ $EVASION_OPTIONS == *"-S"* ]]; then
        if [[ $EUID -ne 0 ]]; then
            echo -e "${YELLOW}⚠️  Este escaneo requiere privilegios root${NC}"
            echo -e "${CYAN}💡 Reejecutando con sudo...${NC}\n"
            sudo bash -c "$full_command"
        else
            eval "$full_command"
        fi
    else
        eval "$full_command"
    fi
    
    local exit_code=$?
    
    if [[ $exit_code -eq 0 ]]; then
        echo -e "\n${GREEN}✅ Escaneo completado exitosamente${NC}"
    else
        echo -e "\n${RED}❌ Error en el escaneo (código: $exit_code)${NC}"
    fi
    
    return $exit_code
}

quick_scans_menu() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}            ${YELLOW}ESCANEOS RÁPIDOS${NC}             ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    detect_network_info
    
    echo -e "${YELLOW}Escaneos preconfigurados:${NC}"
    echo -e "  ${CYAN}1.${NC} Ping Sweep - descubrir hosts ${PURPLE}[-sn]${NC}"
    echo -e "  ${CYAN}2.${NC} Escaneo rápido ${PURPLE}[-T4 -F]${NC}"
    echo -e "  ${CYAN}3.${NC} Top 1000 puertos ${PURPLE}[-T4]${NC}"
    echo -e "  ${CYAN}4.${NC} Escaneo completo ${PURPLE}[-T4 -A -v]${NC}"
    echo -e "  ${CYAN}5.${NC} Solo servicios web ${PURPLE}[-p 80,443 -sV]${NC}"
    echo -e "  ${CYAN}6.${NC} Buscar vulnerabilidades ${PURPLE}[--script vuln]${NC}"
    echo -e "  ${CYAN}7.${NC} UDP común ${PURPLE}[-sU -T4 --top-ports 20]${NC}"
    echo -e "  ${CYAN}8.${NC} Volver al menú principal"
    echo ""
    
    read -p "Selecciona escaneo (1-8): " quick_choice
    
    case $quick_choice in
        1)
            read -p "🎯 Red a escanear (Enter para $network): " target_net
            TARGET=${target_net:-$network}
            nmap -sn $TARGET
            ;;
        2)
            read -p "🎯 IP/Red a escanear: " TARGET
            nmap -T4 -F $TARGET
            ;;
        3)
            read -p "🎯 IP/Red a escanear: " TARGET
            nmap -T4 $TARGET
            ;;
        4)
            read -p "🎯 IP a escanear: " TARGET
            nmap -T4 -A -v $TARGET
            ;;
        5)
            read -p "🎯 IP/Red a escanear: " TARGET
            nmap -p 80,443 -sV $TARGET
            ;;
        6)
            read -p "🎯 IP a escanear: " TARGET
            nmap --script vuln $TARGET
            ;;
        7)
            read -p "🎯 IP/Red a escanear: " TARGET
            sudo nmap -sU -T4 --top-ports 20 $TARGET
            ;;
        8)
            return
            ;;
        *)
            echo -e "${RED}❌ Opción inválida${NC}"
            ;;
    esac
    
    echo ""
    read -p "Presiona Enter para continuar..."
}

main_menu() {
    while true; do
        print_banner
        
        echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║${NC}                           ${YELLOW}MENÚ PRINCIPAL${NC}                              ${BLUE}║${NC}"
        echo -e "${BLUE}╠══════════════════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}1.${NC}  🎯 Configurar Objetivo                                           ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}2.${NC}  🔍 Configurar Descubrimiento de Hosts                           ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}3.${NC}  📡 Configurar Tipo de Escaneo                                   ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}4.${NC}  🚪 Configurar Puertos                                            ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}5.${NC}  ⏱️  Configurar Timing                                            ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}6.${NC}  🔧 Configurar Detección de Servicios                            ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}7.${NC}  💻 Configurar Detección de SO                                    ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}8.${NC}  📜 Configurar Scripts NSE                                        ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}9.${NC}  📄 Configurar Opciones de Salida                                 ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}10.${NC} 🥷 Configurar Evasión y Firewall                                 ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}11.${NC} ⚙️  Configurar Opciones Avanzadas                                 ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}12.${NC} 📋 Ver Resumen del Comando                                        ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}13.${NC} 🚀 Ejecutar Escaneo                                               ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}14.${NC} 💾 Guardar Configuración                                          ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}15.${NC} 📁 Cargar Configuración                                           ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}16.${NC} ⚡ Escaneos Rápidos                                               ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}0.${NC}  🚪 Salir                                                          ${BLUE}║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════════════╝${NC}"
        
        if [[ -n "$TARGET" ]]; then
            echo -e "\n${GREEN}📊 Estado actual:${NC} Objetivo: ${CYAN}$TARGET${NC}"
        fi
        
        echo ""
        read -p "Selecciona una opción (0-16): " choice
        
        case $choice in
            1) select_target ;;
            2) select_host_discovery ;;
            3) select_scan_type ;;
            4) select_ports ;;
            5) select_timing ;;
            6) select_service_detection ;;
            7) select_os_detection ;;
            8) select_scripts ;;
            9) select_output_options ;;
            10) select_evasion_options ;;
            11) select_advanced_options ;;
            12) show_command_summary && read -p "Presiona Enter para continuar..." ;;
            13) 
                if [[ -z "$TARGET" ]]; then
                    echo -e "${RED}❌ Debes configurar un objetivo primero${NC}"
                    read -p "Presiona Enter para continuar..."
                else
                    execute_scan
                    read -p "Presiona Enter para continuar..."
                fi
                ;;
            14) save_configuration && read -p "Presiona Enter para continuar..." ;;
            15) load_configuration && read -p "Presiona Enter para continuar..." ;;
            16) quick_scans_menu ;;
            0) 
                echo -e "${GREEN}👋 ¡Hasta luego!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}❌ Opción inválida${NC}"
                sleep 1
                ;;
        esac
    done
}

# Verificar si nmap está instalado
if ! command -v nmap &> /dev/null; then
    echo -e "${RED}❌ Nmap no está instalado${NC}"
    echo -e "${YELLOW}💡 Instala con: sudo apt install nmap${NC}"
    exit 1
fi

# Ejecutar menú principal
main_menu