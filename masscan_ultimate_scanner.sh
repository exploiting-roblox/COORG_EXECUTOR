#!/bin/bash

# 🚀 MASSCAN ULTIMATE SCANNER
# El escáner de puertos más rápido del mundo con máxima personalización

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Variables globales
TARGET=""
PORTS=""
RATE=""
OUTPUT_FORMAT=""
INTERFACE=""
ROUTER_MAC=""
EXCLUDE=""
RETRIES=""
TIMEOUT=""
ADVANCED_OPTIONS=""

print_banner() {
    clear
    echo -e "${BLUE}"
    echo "███╗   ███╗ █████╗ ███████╗███████╗ ██████╗ █████╗ ███╗   ██╗    ██╗   ██╗██╗  ████████╗██╗███╗   ███╗ █████╗ ████████╗███████╗"
    echo "████╗ ████║██╔══██╗██╔════╝██╔════╝██╔════╝██╔══██╗████╗  ██║    ██║   ██║██║  ╚══██╔══╝██║████╗ ████║██╔══██╗╚══██╔══╝██╔════╝"
    echo "██╔████╔██║███████║███████╗███████╗██║     ███████║██╔██╗ ██║    ██║   ██║██║     ██║   ██║██╔████╔██║███████║   ██║   █████╗  "
    echo "██║╚██╔╝██║██╔══██║╚════██║╚════██║██║     ██╔══██║██║╚██╗██║    ██║   ██║██║     ██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██╔══╝  "
    echo "██║ ╚═╝ ██║██║  ██║███████║███████║╚██████╗██║  ██║██║ ╚████║    ╚██████╔╝███████╗██║   ██║██║ ╚═╝ ██║██║  ██║   ██║   ███████╗"
    echo "╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═══╝     ╚═════╝ ╚══════╝╚═╝   ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚══════╝"
    echo -e "${NC}"
    echo -e "${CYAN}🚀 Masscan Ultimate - El Escáner Más Rápido del Mundo${NC}"
    echo -e "${YELLOW}⚠️  Solo usar en redes propias o con autorización${NC}"
    echo ""
}

detect_network_info() {
    echo -e "${YELLOW}🔍 Detectando información de red...${NC}"
    
    local_ip=$(ip route get 8.8.8.8 | awk '{print $7; exit}')
    gateway=$(ip route | awk '/default/ {print $3; exit}')
    interface=$(ip route get 8.8.8.8 | awk '{print $5; exit}')
    
    if [[ $local_ip =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)\. ]]; then
        network="${BASH_REMATCH[1]}.${BASH_REMATCH[2]}.${BASH_REMATCH[3]}.0/24"
    fi
    
    # Detectar MAC del router
    router_mac=$(arp -n | grep "$gateway" | awk '{print $3}' | head -1)
    
    echo -e "${GREEN}✅ Información detectada:${NC}"
    echo -e "  📱 Tu IP: ${CYAN}$local_ip${NC}"
    echo -e "  🌐 Gateway: ${CYAN}$gateway${NC}"
    echo -e "  🔌 Interface: ${CYAN}$interface${NC}"
    echo -e "  📍 Red sugerida: ${CYAN}$network${NC}"
    if [[ -n "$router_mac" ]]; then
        echo -e "  🏠 MAC Router: ${CYAN}$router_mac${NC}"
    fi
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
    echo -e "  ${CYAN}3.${NC} Rango CIDR (ej: 192.168.0.0/16)"
    echo -e "  ${CYAN}4.${NC} Múltiples redes (separadas por coma)"
    echo -e "  ${CYAN}5.${NC} Archivo con objetivos"
    echo -e "  ${CYAN}6.${NC} Internet completo (0.0.0.0/0) ${RED}[EXTREMO]${NC}"
    echo -e "  ${CYAN}7.${NC} Rangos personalizados (A.B.C.D-E.F.G.H)"
    echo ""
    
    read -p "Selecciona opción (1-7): " target_choice
    
    case $target_choice in
        1)
            read -p "🎯 Red (Enter para $network): " input_net
            TARGET=${input_net:-$network}
            ;;
        2)
            read -p "🎯 IP objetivo: " TARGET
            ;;
        3)
            echo -e "${CYAN}💡 Ejemplos: 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16${NC}"
            read -p "🎯 CIDR: " TARGET
            ;;
        4)
            echo -e "${CYAN}💡 Ejemplo: 192.168.1.0/24,10.0.0.0/24${NC}"
            read -p "🎯 Múltiples redes: " TARGET
            ;;
        5)
            read -p "🎯 Archivo con objetivos: " TARGET
            if [[ ! -f "$TARGET" ]]; then
                echo -e "${RED}❌ Archivo no encontrado${NC}"
                return 1
            fi
            TARGET="--include-file $TARGET"
            ;;
        6)
            echo -e "${RED}⚠️  ESCANEO DE INTERNET COMPLETO - EXTREMADAMENTE PELIGROSO${NC}"
            read -p "¿Estás ABSOLUTAMENTE seguro? (escribe 'SI ESTOY SEGURO'): " confirm
            if [[ "$confirm" == "SI ESTOY SEGURO" ]]; then
                TARGET="0.0.0.0/0"
            else
                echo -e "${YELLOW}Cancelado por seguridad${NC}"
                return 1
            fi
            ;;
        7)
            echo -e "${CYAN}💡 Ejemplo: 192.168.1.1-192.168.1.254${NC}"
            read -p "🎯 Rango personalizado: " TARGET
            ;;
        *)
            echo -e "${RED}❌ Opción inválida${NC}"
            return 1
            ;;
    esac
    
    echo -e "${GREEN}✅ Objetivo: $TARGET${NC}"
}

select_ports() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}          ${YELLOW}CONFIGURACIÓN DE PUERTOS${NC}        ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    echo -e "${YELLOW}¿Qué puertos escanear?${NC}"
    echo -e "  ${CYAN}1.${NC} Top 100 puertos ${PURPLE}[--top-ports 100]${NC}"
    echo -e "  ${CYAN}2.${NC} Top 1000 puertos ${PURPLE}[--top-ports 1000]${NC}"
    echo -e "  ${CYAN}3.${NC} Todos los puertos (1-65535) ${PURPLE}[-p1-65535]${NC}"
    echo -e "  ${CYAN}4.${NC} Puertos específicos ${PURPLE}[-p22,80,443]${NC}"
    echo -e "  ${CYAN}5.${NC} Rango de puertos ${PURPLE}[-p1-1000]${NC}"
    echo -e "  ${CYAN}6.${NC} Solo puertos web ${PURPLE}[-p80,443,8080,8443]${NC}"
    echo -e "  ${CYAN}7.${NC} Solo servicios comunes ${PURPLE}[-p21,22,23,25,53,80,110,143,443,993,995]${NC}"
    echo -e "  ${CYAN}8.${NC} Puertos de base de datos ${PURPLE}[-p1433,3306,5432,1521,27017]${NC}"
    echo -e "  ${CYAN}9.${NC} Puertos de administración ${PURPLE}[-p22,23,80,443,3389,5900]${NC}"
    echo -e "  ${CYAN}10.${NC} Personalizado avanzado"
    echo ""
    
    read -p "Selecciona opción (1-10): " port_choice
    
    case $port_choice in
        1) PORTS="--top-ports 100" ;;
        2) PORTS="--top-ports 1000" ;;
        3) 
            PORTS="-p1-65535"
            echo -e "${YELLOW}⚠️  Escaneo completo - será MUY lento${NC}"
            ;;
        4)
            echo -e "${CYAN}💡 Ejemplo: 22,80,443,8080${NC}"
            read -p "🎯 Puertos (separados por coma): " custom_ports
            PORTS="-p$custom_ports"
            ;;
        5)
            read -p "🎯 Rango (ej: 1-1000): " port_range
            PORTS="-p$port_range"
            ;;
        6) PORTS="-p80,443,8080,8443,8000,8888" ;;
        7) PORTS="-p21,22,23,25,53,80,110,143,443,993,995" ;;
        8) PORTS="-p1433,3306,5432,1521,27017,6379,11211" ;;
        9) PORTS="-p22,23,80,443,3389,5900,8080" ;;
        10)
            echo -e "${CYAN}💡 Opciones avanzadas:${NC}"
            echo -e "  • --top-ports N"
            echo -e "  • -pU:53,T:80 (UDP+TCP específicos)"
            echo -e "  • -p1-100,200-300 (múltiples rangos)"
            read -p "🎯 Configuración personalizada: " PORTS
            ;;
        *)
            echo -e "${YELLOW}Usando top 1000 por defecto${NC}"
            PORTS="--top-ports 1000"
            ;;
    esac
    
    echo -e "${GREEN}✅ Puertos: $PORTS${NC}"
}

select_rate() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}           ${YELLOW}VELOCIDAD DE ESCANEO${NC}           ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    echo -e "${YELLOW}¿Qué velocidad quieres?${NC}"
    echo -e "  ${CYAN}1.${NC} Ultra conservador ${PURPLE}[--rate 100]${NC}"
    echo -e "  ${CYAN}2.${NC} Conservador ${PURPLE}[--rate 1000]${NC}"
    echo -e "  ${CYAN}3.${NC} Normal ${PURPLE}[--rate 10000]${NC}"
    echo -e "  ${CYAN}4.${NC} Rápido ${PURPLE}[--rate 100000]${NC}"
    echo -e "  ${CYAN}5.${NC} Muy rápido ${PURPLE}[--rate 1000000]${NC}"
    echo -e "  ${CYAN}6.${NC} INSANO ${PURPLE}[--rate 10000000]${NC} ${RED}[PELIGROSO]${NC}"
    echo -e "  ${CYAN}7.${NC} Personalizada"
    echo ""
    
    echo -e "${BLUE}💡 Información de velocidades:${NC}"
    echo -e "  • 100 pps = Muy sigiloso, muy lento"
    echo -e "  • 1K pps = Sigiloso, lento"
    echo -e "  • 10K pps = Balance normal"
    echo -e "  • 100K pps = Rápido, detectable"
    echo -e "  • 1M pps = Muy rápido, muy detectable"
    echo -e "  • 10M pps = Insano, puede saturar red"
    echo ""
    
    read -p "Selecciona opción (1-7): " rate_choice
    
    case $rate_choice in
        1) RATE="--rate 100" ;;
        2) RATE="--rate 1000" ;;
        3) RATE="--rate 10000" ;;
        4) RATE="--rate 100000" ;;
        5) RATE="--rate 1000000" ;;
        6) 
            echo -e "${RED}⚠️  VELOCIDAD INSANA - Puede saturar la red${NC}"
            read -p "¿Continuar? (y/N): " confirm
            if [[ $confirm == [yY] ]]; then
                RATE="--rate 10000000"
            else
                RATE="--rate 100000"
                echo -e "${YELLOW}Usando velocidad rápida por seguridad${NC}"
            fi
            ;;
        7)
            echo -e "${CYAN}💡 Puedes usar sufijos: K (miles), M (millones)${NC}"
            read -p "🎯 Rate personalizado (ej: 50000 o 500K): " custom_rate
            RATE="--rate $custom_rate"
            ;;
        *)
            echo -e "${YELLOW}Usando velocidad normal por defecto${NC}"
            RATE="--rate 10000"
            ;;
    esac
    
    echo -e "${GREEN}✅ Velocidad: $RATE${NC}"
}

select_output() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}           ${YELLOW}FORMATO DE SALIDA${NC}              ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    echo -e "${YELLOW}¿Formato de salida?${NC}"
    echo -e "  ${CYAN}1.${NC} Solo pantalla ${PURPLE}[por defecto]${NC}"
    echo -e "  ${CYAN}2.${NC} Lista simple ${PURPLE}[-oL archivo]${NC}"
    echo -e "  ${CYAN}3.${NC} XML ${PURPLE}[-oX archivo]${NC}"
    echo -e "  ${CYAN}4.${NC} JSON ${PURPLE}[-oJ archivo]${NC}"
    echo -e "  ${CYAN}5.${NC} Binario ${PURPLE}[-oB archivo]${NC}"
    echo -e "  ${CYAN}6.${NC} Greppeable ${PURPLE}[-oG archivo]${NC}"
    echo -e "  ${CYAN}7.${NC} Múltiples formatos"
    echo ""
    
    read -p "Selecciona opción (1-7): " output_choice
    
    case $output_choice in
        1) OUTPUT_FORMAT="" ;;
        2) 
            read -p "🎯 Nombre archivo: " filename
            OUTPUT_FORMAT="-oL ${filename:-masscan_result.txt}"
            ;;
        3) 
            read -p "🎯 Nombre archivo XML: " filename
            OUTPUT_FORMAT="-oX ${filename:-masscan_result.xml}"
            ;;
        4) 
            read -p "🎯 Nombre archivo JSON: " filename
            OUTPUT_FORMAT="-oJ ${filename:-masscan_result.json}"
            ;;
        5) 
            read -p "🎯 Nombre archivo binario: " filename
            OUTPUT_FORMAT="-oB ${filename:-masscan_result.bin}"
            ;;
        6) 
            read -p "🎯 Nombre archivo greppeable: " filename
            OUTPUT_FORMAT="-oG ${filename:-masscan_result.gnmap}"
            ;;
        7)
            read -p "🎯 Basename para todos los formatos: " basename
            base=${basename:-masscan_result}
            OUTPUT_FORMAT="-oX $base.xml -oJ $base.json -oL $base.txt -oG $base.gnmap"
            ;;
        *)
            OUTPUT_FORMAT=""
            ;;
    esac
    
    echo -e "${GREEN}✅ Salida: $OUTPUT_FORMAT${NC}"
}

select_interface_options() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}         ${YELLOW}CONFIGURACIÓN AVANZADA${NC}          ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    echo -e "${YELLOW}Configuración de red:${NC}"
    echo -e "  ${CYAN}1.${NC} Autodetección ${PURPLE}[por defecto]${NC}"
    echo -e "  ${CYAN}2.${NC} Interface específica"
    echo -e "  ${CYAN}3.${NC} Router MAC específico"
    echo -e "  ${CYAN}4.${NC} Configuración completa manual"
    echo ""
    
    read -p "Selecciona opción (1-4): " interface_choice
    
    case $interface_choice in
        1) 
            INTERFACE=""
            ROUTER_MAC=""
            ;;
        2)
            echo -e "${CYAN}💡 Interfaces disponibles:${NC}"
            ip link show | grep -E "^[0-9]" | awk '{print $2}' | sed 's/://'
            read -p "🎯 Interface: " interface_name
            INTERFACE="--interface $interface_name"
            ;;
        3)
            read -p "🎯 MAC del router: " router_mac
            ROUTER_MAC="--router-mac $router_mac"
            ;;
        4)
            echo -e "${CYAN}💡 Interfaces disponibles:${NC}"
            ip link show | grep -E "^[0-9]" | awk '{print $2}' | sed 's/://'
            read -p "🎯 Interface: " interface_name
            read -p "🎯 MAC del router: " router_mac
            INTERFACE="--interface $interface_name"
            ROUTER_MAC="--router-mac $router_mac"
            ;;
        *)
            INTERFACE=""
            ROUTER_MAC=""
            ;;
    esac
    
    echo -e "${GREEN}✅ Interface: $INTERFACE $ROUTER_MAC${NC}"
}

select_advanced_options() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}          ${YELLOW}OPCIONES AVANZADAS${NC}             ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    echo -e "${YELLOW}Opciones adicionales:${NC}"
    echo -e "  ${CYAN}1.${NC} Sin opciones extra ${PURPLE}[por defecto]${NC}"
    echo -e "  ${CYAN}2.${NC} Excluir objetivos ${PURPLE}[--exclude ip1,ip2]${NC}"
    echo -e "  ${CYAN}3.${NC} Configurar reintentos ${PURPLE}[--retries N]${NC}"
    echo -e "  ${CYAN}4.${NC} Timeout personalizado ${PURPLE}[--connection-timeout N]${NC}"
    echo -e "  ${CYAN}5.${NC} Randomizar objetivos ${PURPLE}[--randomize-hosts]${NC}"
    echo -e "  ${CYAN}6.${NC} Modo sigiloso ${PURPLE}[--wait N]${NC}"
    echo -e "  ${CYAN}7.${NC} IPv6 ${PURPLE}[-6]${NC}"
    echo -e "  ${CYAN}8.${NC} Fragmentación ${PURPLE}[--fragment]${NC}"
    echo -e "  ${CYAN}9.${NC} Combo personalizado"
    echo ""
    
    read -p "Selecciona opción (1-9): " advanced_choice
    
    case $advanced_choice in
        1) ADVANCED_OPTIONS="" ;;
        2)
            read -p "🎯 IPs a excluir (separadas por coma): " exclude_ips
            EXCLUDE="--exclude $exclude_ips"
            ;;
        3)
            read -p "🎯 Número de reintentos (1-10): " retry_count
            RETRIES="--retries ${retry_count:-3}"
            ;;
        4)
            read -p "🎯 Timeout en segundos: " timeout_val
            TIMEOUT="--connection-timeout ${timeout_val:-5}"
            ;;
        5)
            ADVANCED_OPTIONS="--randomize-hosts"
            ;;
        6)
            read -p "🎯 Segundos de espera entre paquetes: " wait_time
            ADVANCED_OPTIONS="--wait ${wait_time:-1}"
            ;;
        7)
            ADVANCED_OPTIONS="-6"
            echo -e "${YELLOW}⚠️  IPv6 habilitado${NC}"
            ;;
        8)
            ADVANCED_OPTIONS="--fragment"
            echo -e "${YELLOW}⚠️  Fragmentación habilitada${NC}"
            ;;
        9)
            echo -e "${CYAN}💡 Opciones disponibles:${NC}"
            echo -e "  • --randomize-hosts"
            echo -e "  • --fragment"
            echo -e "  • --banners (capturar banners)"
            echo -e "  • --http-user-agent 'string'"
            echo -e "  • --heartbleed"
            read -p "🎯 Opciones personalizadas: " ADVANCED_OPTIONS
            ;;
        *)
            ADVANCED_OPTIONS=""
            ;;
    esac
    
    echo -e "${GREEN}✅ Opciones avanzadas configuradas${NC}"
}

show_command_summary() {
    local full_command="masscan"
    
    [[ -n "$TARGET" ]] && full_command="$full_command $TARGET"
    [[ -n "$PORTS" ]] && full_command="$full_command $PORTS"
    [[ -n "$RATE" ]] && full_command="$full_command $RATE"
    [[ -n "$OUTPUT_FORMAT" ]] && full_command="$full_command $OUTPUT_FORMAT"
    [[ -n "$INTERFACE" ]] && full_command="$full_command $INTERFACE"
    [[ -n "$ROUTER_MAC" ]] && full_command="$full_command $ROUTER_MAC"
    [[ -n "$EXCLUDE" ]] && full_command="$full_command $EXCLUDE"
    [[ -n "$RETRIES" ]] && full_command="$full_command $RETRIES"
    [[ -n "$TIMEOUT" ]] && full_command="$full_command $TIMEOUT"
    [[ -n "$ADVANCED_OPTIONS" ]] && full_command="$full_command $ADVANCED_OPTIONS"
    
    echo -e "\n${BLUE}╔══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}                          ${YELLOW}RESUMEN DEL COMANDO${NC}                           ${BLUE}║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════════════╝${NC}"
    
    echo -e "\n${GREEN}📋 Comando generado:${NC}"
    echo -e "${CYAN}$full_command${NC}"
    
    echo -e "\n${YELLOW}📊 Configuración:${NC}"
    [[ -n "$TARGET" ]] && echo -e "  🎯 Objetivo: ${CYAN}$TARGET${NC}"
    [[ -n "$PORTS" ]] && echo -e "  🚪 Puertos: ${CYAN}$PORTS${NC}"
    [[ -n "$RATE" ]] && echo -e "  🚀 Velocidad: ${CYAN}$RATE${NC}"
    [[ -n "$OUTPUT_FORMAT" ]] && echo -e "  📄 Salida: ${CYAN}$OUTPUT_FORMAT${NC}"
    [[ -n "$INTERFACE" ]] && echo -e "  🔌 Interface: ${CYAN}$INTERFACE${NC}"
    [[ -n "$ROUTER_MAC" ]] && echo -e "  🏠 Router MAC: ${CYAN}$ROUTER_MAC${NC}"
    [[ -n "$EXCLUDE" ]] && echo -e "  ❌ Excluir: ${CYAN}$EXCLUDE${NC}"
    [[ -n "$ADVANCED_OPTIONS" ]] && echo -e "  ⚙️ Avanzado: ${CYAN}$ADVANCED_OPTIONS${NC}"
}

execute_scan() {
    local full_command="masscan"
    
    [[ -n "$TARGET" ]] && full_command="$full_command $TARGET"
    [[ -n "$PORTS" ]] && full_command="$full_command $PORTS"
    [[ -n "$RATE" ]] && full_command="$full_command $RATE"
    [[ -n "$OUTPUT_FORMAT" ]] && full_command="$full_command $OUTPUT_FORMAT"
    [[ -n "$INTERFACE" ]] && full_command="$full_command $INTERFACE"
    [[ -n "$ROUTER_MAC" ]] && full_command="$full_command $ROUTER_MAC"
    [[ -n "$EXCLUDE" ]] && full_command="$full_command $EXCLUDE"
    [[ -n "$RETRIES" ]] && full_command="$full_command $RETRIES"
    [[ -n "$TIMEOUT" ]] && full_command="$full_command $TIMEOUT"
    [[ -n "$ADVANCED_OPTIONS" ]] && full_command="$full_command $ADVANCED_OPTIONS"
    
    echo -e "\n${YELLOW}🚀 Ejecutando Masscan...${NC}"
    echo -e "${CYAN}$full_command${NC}\n"
    
    # Masscan siempre necesita root
    if [[ $EUID -ne 0 ]]; then
        echo -e "${YELLOW}⚠️ Masscan requiere privilegios root${NC}"
        echo -e "${CYAN}💡 Ejecutando con sudo...${NC}\n"
        sudo bash -c "$full_command"
    else
        eval "$full_command"
    fi
    
    local exit_code=$?
    
    if [[ $exit_code -eq 0 ]]; then
        echo -e "\n${GREEN}✅ Escaneo completado exitosamente${NC}"
        
        # Mostrar estadísticas si hay archivo de salida
        if [[ $OUTPUT_FORMAT == *"-oL"* ]]; then
            local output_file=$(echo $OUTPUT_FORMAT | grep -o '\-oL [^ ]*' | cut -d' ' -f2)
            if [[ -f "$output_file" ]]; then
                local port_count=$(wc -l < "$output_file")
                echo -e "📊 Puertos encontrados: ${GREEN}$port_count${NC}"
            fi
        fi
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
    echo -e "  ${CYAN}1.${NC} Red local - top 1000 ${PURPLE}[velocidad normal]${NC}"
    echo -e "  ${CYAN}2.${NC} Red local - super rápido ${PURPLE}[1M pps]${NC}"
    echo -e "  ${CYAN}3.${NC} Solo servicios web ${PURPLE}[80,443,8080,8443]${NC}"
    echo -e "  ${CYAN}4.${NC} Top 100 - ultra rápido ${PURPLE}[10M pps]${NC}"
    echo -e "  ${CYAN}5.${NC} Escaneo sigiloso ${PURPLE}[100 pps]${NC}"
    echo -e "  ${CYAN}6.${NC} Todos los puertos ${PURPLE}[1-65535]${NC}"
    echo -e "  ${CYAN}7.${NC} Volver al menú principal"
    echo ""
    
    read -p "Selecciona escaneo (1-7): " quick_choice
    
    case $quick_choice in
        1)
            read -p "🎯 Red (Enter para $network): " target_net
            TARGET=${target_net:-$network}
            sudo masscan $TARGET --top-ports 1000 --rate 10000
            ;;
        2)
            read -p "🎯 Red (Enter para $network): " target_net
            TARGET=${target_net:-$network}
            sudo masscan $TARGET --top-ports 1000 --rate 1000000
            ;;
        3)
            read -p "🎯 Objetivo: " TARGET
            sudo masscan $TARGET -p80,443,8080,8443 --rate 100000
            ;;
        4)
            read -p "🎯 Objetivo: " TARGET
            sudo masscan $TARGET --top-ports 100 --rate 10000000
            ;;
        5)
            read -p "🎯 Objetivo: " TARGET
            sudo masscan $TARGET --top-ports 1000 --rate 100
            ;;
        6)
            read -p "🎯 Objetivo: " TARGET
            echo -e "${RED}⚠️ Esto llevará MUCHO tiempo${NC}"
            read -p "¿Continuar? (y/N): " confirm
            if [[ $confirm == [yY] ]]; then
                sudo masscan $TARGET -p1-65535 --rate 100000
            fi
            ;;
        7)
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
        echo -e "${BLUE}║${NC} ${CYAN}2.${NC}  🚪 Configurar Puertos                                            ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}3.${NC}  🚀 Configurar Velocidad                                          ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}4.${NC}  📄 Configurar Salida                                             ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}5.${NC}  🔌 Configurar Interface/Red                                      ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}6.${NC}  ⚙️  Configurar Opciones Avanzadas                                ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}7.${NC}  📋 Ver Resumen del Comando                                        ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}8.${NC}  🚀 Ejecutar Escaneo                                               ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}9.${NC}  ⚡ Escaneos Rápidos                                               ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}0.${NC}  🚪 Salir                                                          ${BLUE}║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════════════╝${NC}"
        
        if [[ -n "$TARGET" ]]; then
            echo -e "\n${GREEN}📊 Estado:${NC} Objetivo: ${CYAN}$TARGET${NC}"
        fi
        
        echo ""
        read -p "Selecciona una opción (0-9): " choice
        
        case $choice in
            1) select_target ;;
            2) select_ports ;;
            3) select_rate ;;
            4) select_output ;;
            5) select_interface_options ;;
            6) select_advanced_options ;;
            7) show_command_summary && read -p "Presiona Enter para continuar..." ;;
            8) 
                if [[ -z "$TARGET" ]]; then
                    echo -e "${RED}❌ Debes configurar un objetivo primero${NC}"
                    read -p "Presiona Enter para continuar..."
                else
                    execute_scan
                    read -p "Presiona Enter para continuar..."
                fi
                ;;
            9) quick_scans_menu ;;
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

# Verificar si masscan está instalado
if ! command -v masscan &> /dev/null; then
    echo -e "${RED}❌ Masscan no está instalado${NC}"
    echo -e "${YELLOW}💡 Instala con: sudo apt install masscan${NC}"
    exit 1
fi

# Ejecutar menú principal
main_menu