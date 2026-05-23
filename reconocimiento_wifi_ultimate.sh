#!/bin/bash

# 🔍 RECONOCIMIENTO ULTIMATE SCANNER
# Scan de redes WiFi, detección de clientes, análisis de tráfico y wardriving

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Variables globales
INTERFACE=""
TARGET_NETWORK=""
SCAN_TYPE=""
OUTPUT_DIR=""
SCAN_TIME=""
CHANNEL=""
FILTER=""

print_banner() {
    clear
    echo -e "${BLUE}"
    echo "██████╗ ███████╗ ██████╗ ██████╗ ███╗   ██╗ ██████╗  ██████╗██╗███╗   ███╗██╗███████╗███╗   ██╗████████╗ ██████╗ "
    echo "██╔══██╗██╔════╝██╔════╝██╔═══██╗████╗  ██║██╔═══██╗██╔════╝██║████╗ ████║██║██╔════╝████╗  ██║╚══██╔══╝██╔═══██╗"
    echo "██████╔╝█████╗  ██║     ██║   ██║██╔██╗ ██║██║   ██║██║     ██║██╔████╔██║██║█████╗  ██╔██╗ ██║   ██║   ██║   ██║"
    echo "██╔══██╗██╔══╝  ██║     ██║   ██║██║╚██╗██║██║   ██║██║     ██║██║╚██╔╝██║██║██╔══╝  ██║╚██╗██║   ██║   ██║   ██║"
    echo "██║  ██║███████╗╚██████╗╚██████╔╝██║ ╚████║╚██████╔╝╚██████╗██║██║ ╚═╝ ██║██║███████╗██║ ╚████║   ██║   ╚██████╔╝"
    echo "╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝  ╚═════╝╚═╝╚═╝     ╚═╝╚═╝╚══════╝╚═╝  ╚═══╝   ╚═╝    ╚═════╝ "
    echo -e "${NC}"
    echo -e "${CYAN}🔍 WiFi Reconocimiento Ultimate - Descubrimiento y Análisis${NC}"
    echo -e "${YELLOW}⚠️  Solo usar en redes propias o con autorización${NC}"
    echo ""
}

check_interface() {
    echo -e "${YELLOW}🔍 Detectando interfaces WiFi...${NC}"
    
    # Mostrar interfaces disponibles
    echo -e "${CYAN}📡 Interfaces disponibles:${NC}"
    iwconfig 2>/dev/null | grep -E "^[a-z]" | while read interface rest; do
        if [[ "$rest" == *"IEEE 802.11"* ]]; then
            echo -e "  • ${GREEN}$interface${NC} (WiFi)"
        fi
    done
    
    # Detectar interface principal
    main_interface=$(iwconfig 2>/dev/null | grep -E "^[a-z].*IEEE 802.11" | head -1 | cut -d' ' -f1)
    
    if [[ -n "$main_interface" ]]; then
        echo -e "${GREEN}✅ Interface principal detectada: $main_interface${NC}"
        INTERFACE="$main_interface"
    else
        echo -e "${RED}❌ No se detectaron interfaces WiFi${NC}"
        read -p "🎯 Ingresa interface manualmente: " INTERFACE
    fi
    
    # Verificar si está en modo monitor
    mode=$(iwconfig "$INTERFACE" 2>/dev/null | grep "Mode:" | awk '{print $4}' | cut -d':' -f2)
    if [[ "$mode" != "Monitor" ]]; then
        echo -e "${YELLOW}⚠️ Interface no está en modo monitor${NC}"
        read -p "¿Activar modo monitor? (y/N): " activate_monitor
        if [[ $activate_monitor == [yY] ]]; then
            sudo airmon-ng start "$INTERFACE" 2>/dev/null
            INTERFACE="${INTERFACE}mon"
        fi
    fi
    
    echo -e "${GREEN}✅ Interface configurada: $INTERFACE${NC}"
}

select_scan_type() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}         ${YELLOW}TIPO DE RECONOCIMIENTO${NC}          ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    echo -e "${YELLOW}¿Qué tipo de reconocimiento quieres?${NC}"
    echo -e "  ${CYAN}1.${NC} 📡 Scan de redes WiFi activas ${PURPLE}[airodump-ng + kismet]${NC}"
    echo -e "  ${CYAN}2.${NC} 👥 Detectar clientes conectados ${PURPLE}[airodump-ng]${NC}"
    echo -e "  ${CYAN}3.${NC} 📊 Detectar redes ocultas ${PURPLE}[kismet]${NC}"
    echo -e "  ${CYAN}4.${NC} 📈 Análisis de tráfico raw ${PURPLE}[wireshark]${NC}"
    echo -e "  ${CYAN}5.${NC} 🚗 Wardriving con GPS ${PURPLE}[kismet]${NC}"
    echo -e "  ${CYAN}6.${NC} 🔍 Reconocimiento completo ${PURPLE}[todos]${NC}"
    echo -e "  ${CYAN}7.${NC} ⚙️ Personalizado avanzado"
    echo ""
    
    read -p "Selecciona tipo (1-7): " scan_choice
    
    case $scan_choice in
        1)
            SCAN_TYPE="wifi_scan"
            echo -e "${GREEN}✅ Scan de redes WiFi activas${NC}"
            ;;
        2)
            SCAN_TYPE="client_detection"
            echo -e "${GREEN}✅ Detección de clientes conectados${NC}"
            select_target_network
            ;;
        3)
            SCAN_TYPE="hidden_networks"
            echo -e "${GREEN}✅ Detección de redes ocultas${NC}"
            ;;
        4)
            SCAN_TYPE="traffic_analysis"
            echo -e "${GREEN}✅ Análisis de tráfico raw${NC}"
            ;;
        5)
            SCAN_TYPE="wardriving"
            echo -e "${GREEN}✅ Wardriving con GPS${NC}"
            ;;
        6)
            SCAN_TYPE="complete_recon"
            echo -e "${GREEN}✅ Reconocimiento completo${NC}"
            ;;
        7)
            select_custom_scan
            ;;
        *)
            echo -e "${YELLOW}Usando scan WiFi por defecto${NC}"
            SCAN_TYPE="wifi_scan"
            ;;
    esac
}

select_target_network() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}          ${YELLOW}RED OBJETIVO (BSSID)${NC}           ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    echo -e "${YELLOW}¿Red específica a analizar?${NC}"
    echo -e "  ${CYAN}1.${NC} Escanear todas las redes ${PURPLE}[sin filtro]${NC}"
    echo -e "  ${CYAN}2.${NC} BSSID específico (ej: AA:BB:CC:DD:EE:FF)"
    echo -e "  ${CYAN}3.${NC} ESSID específico (nombre de red)"
    echo -e "  ${CYAN}4.${NC} Canal específico"
    echo -e "  ${CYAN}5.${NC} Rango de canales"
    echo ""
    
    read -p "Selecciona filtro (1-5): " filter_choice
    
    case $filter_choice in
        1)
            TARGET_NETWORK=""
            echo -e "${GREEN}✅ Sin filtro - todas las redes${NC}"
            ;;
        2)
            read -p "🎯 BSSID objetivo (AA:BB:CC:DD:EE:FF): " bssid
            TARGET_NETWORK="--bssid $bssid"
            echo -e "${GREEN}✅ BSSID objetivo: $bssid${NC}"
            ;;
        3)
            read -p "🎯 ESSID objetivo: " essid
            TARGET_NETWORK="--essid '$essid'"
            echo -e "${GREEN}✅ ESSID objetivo: $essid${NC}"
            ;;
        4)
            read -p "🎯 Canal (1-14): " channel
            CHANNEL="--channel $channel"
            echo -e "${GREEN}✅ Canal: $channel${NC}"
            ;;
        5)
            read -p "🎯 Rango de canales (ej: 1-11): " channel_range
            CHANNEL="--channel $channel_range"
            echo -e "${GREEN}✅ Rango: $channel_range${NC}"
            ;;
        *)
            TARGET_NETWORK=""
            ;;
    esac
}

select_custom_scan() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}         ${YELLOW}CONFIGURACIÓN AVANZADA${NC}         ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    echo -e "${YELLOW}Configuración personalizada:${NC}"
    
    # Tiempo de escaneo
    echo -e "\n${CYAN}⏱️ Tiempo de escaneo:${NC}"
    echo -e "  1. Rápido (30 segundos)"
    echo -e "  2. Normal (5 minutos)" 
    echo -e "  3. Largo (30 minutos)"
    echo -e "  4. Continuo (hasta parar manualmente)"
    echo -e "  5. Personalizado"
    read -p "Tiempo (1-5): " time_choice
    
    case $time_choice in
        1) SCAN_TIME="30" ;;
        2) SCAN_TIME="300" ;;
        3) SCAN_TIME="1800" ;;
        4) SCAN_TIME="0" ;;
        5) read -p "⏱️ Segundos: " SCAN_TIME ;;
        *) SCAN_TIME="300" ;;
    esac
    
    # Filtros avanzados
    echo -e "\n${CYAN}🔍 Filtros avanzados:${NC}"
    echo -e "  1. Sin filtros"
    echo -e "  2. Solo WEP"
    echo -e "  3. Solo WPA/WPA2"
    echo -e "  4. Solo redes abiertas"
    echo -e "  5. Solo 2.4GHz"
    echo -e "  6. Solo 5GHz"
    read -p "Filtro (1-6): " filter_choice
    
    case $filter_choice in
        1) FILTER="" ;;
        2) FILTER="--encrypt WEP" ;;
        3) FILTER="--encrypt WPA" ;;
        4) FILTER="--encrypt OPN" ;;
        5) FILTER="--band bg" ;;
        6) FILTER="--band a" ;;
        *) FILTER="" ;;
    esac
    
    SCAN_TYPE="custom"
    echo -e "${GREEN}✅ Configuración personalizada lista${NC}"
}

setup_output_directory() {
    OUTPUT_DIR="reconocimiento_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$OUTPUT_DIR"/{captures,logs,reports}
    
    echo -e "${GREEN}📁 Directorio creado: $OUTPUT_DIR${NC}"
    
    # Crear archivo de información
    cat > "$OUTPUT_DIR/scan_info.txt" << EOF
# Reconocimiento WiFi - $(date)
Interface: $INTERFACE
Tipo: $SCAN_TYPE
Target: $TARGET_NETWORK
Canal: $CHANNEL
Filtro: $FILTER
Tiempo: $SCAN_TIME segundos
EOF
}

execute_wifi_scan() {
    echo -e "\n${YELLOW}📡 Ejecutando scan de redes WiFi...${NC}"
    
    # Airodump-ng scan
    echo -e "${CYAN}🔍 Iniciando airodump-ng...${NC}"
    local airodump_cmd="airodump-ng $INTERFACE"
    [[ -n "$CHANNEL" ]] && airodump_cmd="$airodump_cmd $CHANNEL"
    [[ -n "$TARGET_NETWORK" ]] && airodump_cmd="$airodump_cmd $TARGET_NETWORK"
    airodump_cmd="$airodump_cmd --write $OUTPUT_DIR/captures/wifi_scan --output-format pcap,csv,kismet"
    
    echo -e "${BLUE}Comando: $airodump_cmd${NC}"
    
    if [[ "$SCAN_TIME" == "0" ]]; then
        echo -e "${YELLOW}⏳ Escaneo continuo - Presiona Ctrl+C para detener${NC}"
        eval "$airodump_cmd"
    else
        echo -e "${YELLOW}⏳ Escaneando por $SCAN_TIME segundos...${NC}"
        timeout "$SCAN_TIME" bash -c "$airodump_cmd" 2>/dev/null || true
    fi
    
    # Procesar resultados
    process_scan_results
}

execute_client_detection() {
    echo -e "\n${YELLOW}👥 Detectando clientes conectados...${NC}"
    
    if [[ -z "$TARGET_NETWORK" ]]; then
        echo -e "${RED}❌ Necesitas especificar una red objetivo${NC}"
        return 1
    fi
    
    local airodump_cmd="airodump-ng $INTERFACE $TARGET_NETWORK"
    [[ -n "$CHANNEL" ]] && airodump_cmd="$airodump_cmd $CHANNEL"
    airodump_cmd="$airodump_cmd --write $OUTPUT_DIR/captures/clients --output-format pcap,csv"
    
    echo -e "${BLUE}Comando: $airodump_cmd${NC}"
    echo -e "${YELLOW}⏳ Detectando clientes por $SCAN_TIME segundos...${NC}"
    
    if [[ "$SCAN_TIME" == "0" ]]; then
        eval "$airodump_cmd"
    else
        timeout "$SCAN_TIME" bash -c "$airodump_cmd" 2>/dev/null || true
    fi
    
    # Analizar clientes
    analyze_clients
}

execute_hidden_networks() {
    echo -e "\n${YELLOW}🔍 Buscando redes ocultas con kismet...${NC}"
    
    # Verificar si kismet está instalado
    if ! command -v kismet &> /dev/null; then
        echo -e "${RED}❌ Kismet no está instalado${NC}"
        echo -e "${YELLOW}💡 Instala con: sudo apt install kismet${NC}"
        return 1
    fi
    
    # Configurar kismet
    local kismet_conf="/tmp/kismet_temp.conf"
    cat > "$kismet_conf" << EOF
source=$INTERFACE
log_title=Hidden_Networks_Scan
logprefix=$OUTPUT_DIR/logs/kismet
quiet=true
EOF
    
    echo -e "${CYAN}🚀 Iniciando kismet...${NC}"
    
    if [[ "$SCAN_TIME" == "0" ]]; then
        sudo kismet -c "$kismet_conf" --daemonize
        echo -e "${YELLOW}Kismet ejecutándose en segundo plano${NC}"
        echo -e "${CYAN}💡 Para detener: sudo pkill kismet${NC}"
    else
        timeout "$SCAN_TIME" sudo kismet -c "$kismet_conf" 2>/dev/null || true
    fi
    
    # Procesar resultados de kismet
    process_kismet_results
}

execute_traffic_analysis() {
    echo -e "\n${YELLOW}📈 Iniciando análisis de tráfico...${NC}"
    
    local pcap_file="$OUTPUT_DIR/captures/traffic_$(date +%H%M%S).pcap"
    
    echo -e "${CYAN}📊 Capturando tráfico con wireshark/tcpdump...${NC}"
    
    local capture_cmd="tcpdump -i $INTERFACE -w $pcap_file"
    [[ -n "$FILTER" ]] && capture_cmd="$capture_cmd $FILTER"
    
    echo -e "${BLUE}Comando: $capture_cmd${NC}"
    
    if [[ "$SCAN_TIME" == "0" ]]; then
        echo -e "${YELLOW}⏳ Captura continua - Presiona Ctrl+C para detener${NC}"
        sudo $capture_cmd
    else
        echo -e "${YELLOW}⏳ Capturando por $SCAN_TIME segundos...${NC}"
        timeout "$SCAN_TIME" sudo $capture_cmd 2>/dev/null || true
    fi
    
    # Análisis básico del tráfico capturado
    analyze_traffic "$pcap_file"
}

execute_wardriving() {
    echo -e "\n${YELLOW}🚗 Iniciando wardriving con GPS...${NC}"
    
    # Verificar GPS
    if ! command -v gpsd &> /dev/null; then
        echo -e "${YELLOW}⚠️ GPS daemon no detectado${NC}"
        read -p "¿Continuar sin GPS? (y/N): " continue_nogps
        [[ $continue_nogps != [yY] ]] && return 1
    fi
    
    # Kismet wardriving
    local kismet_conf="/tmp/kismet_wardriving.conf"
    cat > "$kismet_conf" << EOF
source=$INTERFACE
gps=true
log_title=Wardriving_$(date +%Y%m%d_%H%M%S)
logprefix=$OUTPUT_DIR/logs/wardriving
quiet=false
EOF
    
    echo -e "${CYAN}📡 Kismet wardriving iniciado...${NC}"
    echo -e "${YELLOW}🚗 ¡Sal a conducir para recopilar datos!${NC}"
    
    if [[ "$SCAN_TIME" == "0" ]]; then
        sudo kismet -c "$kismet_conf"
    else
        timeout "$SCAN_TIME" sudo kismet -c "$kismet_conf" 2>/dev/null || true
    fi
    
    # Procesar datos de wardriving
    process_wardriving_results
}

execute_complete_recon() {
    echo -e "\n${YELLOW}🔍 Ejecutando reconocimiento completo...${NC}"
    
    echo -e "${BLUE}Fase 1: Scan de redes WiFi...${NC}"
    execute_wifi_scan
    sleep 5
    
    echo -e "\n${BLUE}Fase 2: Búsqueda de redes ocultas...${NC}"
    execute_hidden_networks
    sleep 5
    
    echo -e "\n${BLUE}Fase 3: Análisis de tráfico...${NC}"
    SCAN_TIME="300"  # 5 minutos para tráfico
    execute_traffic_analysis
    
    echo -e "\n${GREEN}✅ Reconocimiento completo terminado${NC}"
    generate_complete_report
}

process_scan_results() {
    echo -e "\n${CYAN}📊 Procesando resultados del scan...${NC}"
    
    # Buscar archivos CSV de airodump-ng
    local csv_files=$(find "$OUTPUT_DIR/captures" -name "*.csv" 2>/dev/null)
    
    if [[ -n "$csv_files" ]]; then
        for csv_file in $csv_files; do
            echo -e "${BLUE}📋 Procesando: $(basename "$csv_file")${NC}"
            
            # Contar redes encontradas
            local networks=$(grep -c "^[^,]*,[^,]*,[^,]*,[^,]*,[^,]*,[^,]*" "$csv_file" 2>/dev/null || echo "0")
            echo -e "  📡 Redes encontradas: ${GREEN}$networks${NC}"
            
            # Análisis por tipo de encriptación
            local wep_count=$(grep -c "WEP" "$csv_file" 2>/dev/null || echo "0")
            local wpa_count=$(grep -c "WPA" "$csv_file" 2>/dev/null || echo "0")
            local open_count=$(grep -c "OPN" "$csv_file" 2>/dev/null || echo "0")
            
            echo -e "  🔒 WEP: ${YELLOW}$wep_count${NC}, WPA: ${GREEN}$wpa_count${NC}, Abiertas: ${RED}$open_count${NC}"
            
            # Crear resumen
            {
                echo "=== RESUMEN DEL SCAN ==="
                echo "Fecha: $(date)"
                echo "Redes totales: $networks"
                echo "WEP: $wep_count"
                echo "WPA: $wpa_count" 
                echo "Abiertas: $open_count"
                echo ""
                echo "=== TOP 10 REDES POR SEÑAL ==="
                tail -n +2 "$csv_file" | sort -t',' -k9 -nr | head -10 | while IFS=',' read bssid essid channel privacy power beacons iv lan_ip id_length essid_visible; do
                    echo "$essid ($bssid) - Canal: $channel - Señal: $power dBm"
                done
            } > "$OUTPUT_DIR/reports/scan_summary.txt"
        done
    else
        echo -e "${YELLOW}⚠️ No se encontraron archivos CSV${NC}"
    fi
}

analyze_clients() {
    echo -e "\n${CYAN}👥 Analizando clientes detectados...${NC}"
    
    local csv_files=$(find "$OUTPUT_DIR/captures" -name "*clients*.csv" 2>/dev/null)
    
    if [[ -n "$csv_files" ]]; then
        for csv_file in $csv_files; do
            # Buscar sección de clientes en el CSV
            local clients_section=$(grep -n "Station MAC" "$csv_file" 2>/dev/null | head -1 | cut -d':' -f1)
            
            if [[ -n "$clients_section" ]]; then
                local client_count=$(tail -n +$((clients_section + 1)) "$csv_file" | grep -c "^[^,]*," 2>/dev/null || echo "0")
                echo -e "  👤 Clientes detectados: ${GREEN}$client_count${NC}"
                
                # Crear resumen de clientes
                {
                    echo "=== CLIENTES DETECTADOS ==="
                    echo "Fecha: $(date)"
                    echo "Total clientes: $client_count"
                    echo ""
                    echo "=== LISTA DE CLIENTES ==="
                    tail -n +$((clients_section + 1)) "$csv_file" | while IFS=',' read station_mac first_seen last_seen power packets bssid probes; do
                        [[ -n "$station_mac" ]] && echo "Cliente: $station_mac conectado a $bssid (Señal: $power dBm)"
                    done
                } > "$OUTPUT_DIR/reports/clients_summary.txt"
            else
                echo -e "${YELLOW}⚠️ No se detectaron clientes${NC}"
            fi
        done
    fi
}

process_kismet_results() {
    echo -e "\n${CYAN}🔍 Procesando resultados de kismet...${NC}"
    
    local kismet_logs=$(find "$OUTPUT_DIR/logs" -name "kismet*.log" 2>/dev/null)
    
    if [[ -n "$kismet_logs" ]]; then
        local hidden_networks=$(grep -c "hidden" $kismet_logs 2>/dev/null || echo "0")
        echo -e "  🔍 Posibles redes ocultas: ${YELLOW}$hidden_networks${NC}"
        
        # Crear resumen
        {
            echo "=== ANÁLISIS DE REDES OCULTAS ==="
            echo "Fecha: $(date)"
            echo "Posibles redes ocultas: $hidden_networks"
            echo ""
            grep "hidden\|SSID" $kismet_logs 2>/dev/null | head -20
        } > "$OUTPUT_DIR/reports/hidden_networks.txt"
    fi
}

analyze_traffic() {
    local pcap_file="$1"
    
    echo -e "\n${CYAN}📈 Analizando tráfico capturado...${NC}"
    
    if [[ -f "$pcap_file" ]]; then
        # Estadísticas básicas con tcpdump
        local packet_count=$(tcpdump -r "$pcap_file" 2>/dev/null | wc -l || echo "0")
        echo -e "  📦 Paquetes capturados: ${GREEN}$packet_count${NC}"
        
        # Análisis por protocolos
        {
            echo "=== ANÁLISIS DE TRÁFICO ==="
            echo "Fecha: $(date)"
            echo "Archivo: $pcap_file"
            echo "Total paquetes: $packet_count"
            echo ""
            echo "=== TOP PROTOCOLOS ==="
            tcpdump -r "$pcap_file" 2>/dev/null | awk '{print $3}' | sort | uniq -c | sort -nr | head -10
        } > "$OUTPUT_DIR/reports/traffic_analysis.txt"
    fi
}

process_wardriving_results() {
    echo -e "\n${CYAN}🚗 Procesando datos de wardriving...${NC}"
    
    local wardriving_logs=$(find "$OUTPUT_DIR/logs" -name "wardriving*" 2>/dev/null)
    
    if [[ -n "$wardriving_logs" ]]; then
        echo -e "  📍 Logs de wardriving generados en: $OUTPUT_DIR/logs/${NC}"
        echo -e "${YELLOW}💡 Usa kismet para visualizar los datos GPS${NC}"
    fi
}

generate_complete_report() {
    local report_file="$OUTPUT_DIR/reports/reconocimiento_completo_$(date +%Y%m%d_%H%M%S).html"
    
    cat > "$report_file" << EOF
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Reporte de Reconocimiento WiFi</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background: #0a0a0a; color: #00ff00; }
        .header { text-align: center; border-bottom: 2px solid #00ff00; padding-bottom: 20px; }
        .section { margin: 30px 0; padding: 20px; border: 1px solid #333; background: #111; }
        .stats { display: flex; justify-content: space-around; text-align: center; }
        .stat-box { padding: 15px; border: 1px solid #00ff00; margin: 5px; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🔍 REPORTE DE RECONOCIMIENTO WIFI</h1>
        <h2>Interface: $INTERFACE</h2>
        <p>Generado: $(date)</p>
    </div>

    <div class="section">
        <h2>📊 RESUMEN EJECUTIVO</h2>
        <div class="stats">
            <div class="stat-box">
                <h3>Reconocimiento</h3>
                <p>$SCAN_TYPE</p>
            </div>
        </div>
    </div>

    <div class="section">
        <h2>📁 ARCHIVOS GENERADOS</h2>
        <ul>
            <li>Capturas: $OUTPUT_DIR/captures/</li>
            <li>Logs: $OUTPUT_DIR/logs/</li>
            <li>Reportes: $OUTPUT_DIR/reports/</li>
        </ul>
    </div>
</body>
</html>
EOF
    
    echo -e "\n${GREEN}📋 Reporte generado: $report_file${NC}"
}

show_results_summary() {
    echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}                        ${YELLOW}RESUMEN DE RESULTADOS${NC}                          ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════════════════╝${NC}"
    
    echo -e "${CYAN}📁 Directorio del proyecto: $OUTPUT_DIR${NC}"
    
    # Mostrar estadísticas si existen
    if [[ -f "$OUTPUT_DIR/reports/scan_summary.txt" ]]; then
        echo -e "\n${GREEN}📊 Estadísticas del scan:${NC}"
        head -10 "$OUTPUT_DIR/reports/scan_summary.txt"
    fi
    
    if [[ -f "$OUTPUT_DIR/reports/clients_summary.txt" ]]; then
        echo -e "\n${GREEN}👥 Clientes detectados:${NC}"
        head -5 "$OUTPUT_DIR/reports/clients_summary.txt"
    fi
    
    echo -e "\n${CYAN}💡 Archivos generados:${NC}"
    find "$OUTPUT_DIR" -type f -name "*.csv" -o -name "*.pcap" -o -name "*.log" -o -name "*.txt" 2>/dev/null | while read file; do
        local size=$(du -h "$file" 2>/dev/null | cut -f1)
        echo -e "  📄 $(basename "$file") ($size)"
    done
}

main_menu() {
    while true; do
        print_banner
        
        echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║${NC}                         ${YELLOW}MENÚ PRINCIPAL${NC}                               ${BLUE}║${NC}"
        echo -e "${BLUE}╠══════════════════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}1.${NC}  🔧 Configurar Interface WiFi                                    ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}2.${NC}  📡 Scan de Redes WiFi Activas                                  ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}3.${NC}  👥 Detectar Clientes Conectados                                ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}4.${NC}  🔍 Detectar Redes Ocultas                                      ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}5.${NC}  📈 Análisis de Tráfico Raw                                     ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}6.${NC}  🚗 Wardriving con GPS                                           ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}7.${NC}  🎯 Reconocimiento Completo Automatizado                        ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}8.${NC}  📊 Ver Resumen de Resultados                                   ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}0.${NC}  🚪 Salir                                                        ${BLUE}║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════════════╝${NC}"
        
        if [[ -n "$INTERFACE" ]]; then
            echo -e "\n${GREEN}📡 Interface: $INTERFACE${NC}"
        fi
        
        echo ""
        read -p "Selecciona una opción (0-8): " choice
        
        case $choice in
            1) check_interface ;;
            2) 
                [[ -z "$INTERFACE" ]] && check_interface
                SCAN_TYPE="wifi_scan"
                select_target_network
                setup_output_directory
                execute_wifi_scan
                show_results_summary
                read -p "Presiona Enter para continuar..."
                ;;
            3)
                [[ -z "$INTERFACE" ]] && check_interface
                SCAN_TYPE="client_detection"
                select_target_network
                setup_output_directory
                execute_client_detection
                show_results_summary
                read -p "Presiona Enter para continuar..."
                ;;
            4)
                [[ -z "$INTERFACE" ]] && check_interface
                SCAN_TYPE="hidden_networks"
                setup_output_directory
                execute_hidden_networks
                show_results_summary
                read -p "Presiona Enter para continuar..."
                ;;
            5)
                [[ -z "$INTERFACE" ]] && check_interface
                SCAN_TYPE="traffic_analysis"
                select_custom_scan
                setup_output_directory
                execute_traffic_analysis
                show_results_summary
                read -p "Presiona Enter para continuar..."
                ;;
            6)
                [[ -z "$INTERFACE" ]] && check_interface
                SCAN_TYPE="wardriving"
                select_custom_scan
                setup_output_directory
                execute_wardriving
                show_results_summary
                read -p "Presiona Enter para continuar..."
                ;;
            7)
                [[ -z "$INTERFACE" ]] && check_interface
                SCAN_TYPE="complete_recon"
                setup_output_directory
                execute_complete_recon
                show_results_summary
                read -p "Presiona Enter para continuar..."
                ;;
            8)
                if [[ -n "$OUTPUT_DIR" ]]; then
                    show_results_summary
                else
                    echo -e "${YELLOW}⚠️ No hay resultados para mostrar${NC}"
                fi
                read -p "Presiona Enter para continuar..."
                ;;
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

# Verificar herramientas necesarias
missing_tools=()
for tool in aircrack-ng iwconfig; do
    if ! command -v "$tool" &> /dev/null; then
        missing_tools+=("$tool")
    fi
done

if [[ ${#missing_tools[@]} -gt 0 ]]; then
    echo -e "${RED}❌ Herramientas faltantes: ${missing_tools[*]}${NC}"
    echo -e "${YELLOW}💡 Instala con: sudo apt install aircrack-ng wireless-tools${NC}"
    exit 1
fi

# Verificar permisos de root
if [[ $EUID -ne 0 ]]; then
    echo -e "${YELLOW}⚠️ Algunos comandos requieren permisos de root${NC}"
    echo -e "${CYAN}💡 Recomendado ejecutar como: sudo $0${NC}"
fi

# Ejecutar menú principal
main_menu