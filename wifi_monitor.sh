#!/bin/bash

# 👁️ Monitor de Seguridad WiFi - Detector de Ataques
# Uso: ./wifi_monitor.sh

INTERFACE="wlan0"
LOG_DIR="$HOME/wifi_security_logs"
ALERT_FILE="$LOG_DIR/alerts.log"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

print_banner() {
    echo -e "${BLUE}"
    echo "██╗    ██╗██╗███████╗██╗    ███╗   ███╗ ██████╗ ███╗   ██╗██╗████████╗ ██████╗ ██████╗ "
    echo "██║    ██║██║██╔════╝██║    ████╗ ████║██╔═══██╗████╗  ██║██║╚══██╔══╝██╔═══██╗██╔══██╗"
    echo "██║ █╗ ██║██║█████╗  ██║    ██╔████╔██║██║   ██║██╔██╗ ██║██║   ██║   ██║   ██║██████╔╝"
    echo "██║███╗██║██║██╔══╝  ██║    ██║╚██╔╝██║██║   ██║██║╚██╗██║██║   ██║   ██║   ██║██╔══██╗"
    echo "╚███╔███╔╝██║██║     ██║    ██║ ╚═╝ ██║╚██████╔╝██║ ╚████║██║   ██║   ╚██████╔╝██║  ██║"
    echo " ╚══╝╚══╝ ╚═╝╚═╝     ╚═╝    ╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝"
    echo -e "${NC}"
    echo -e "${YELLOW}👁️  Monitor de Seguridad WiFi - Detector de Ataques${NC}"
    echo -e "${RED}🛡️  Protege tu red detectando actividades sospechosas${NC}"
    echo ""
}

setup_logging() {
    mkdir -p "$LOG_DIR"
    touch "$ALERT_FILE"
    echo -e "${GREEN}📁 Directorio de logs: $LOG_DIR${NC}"
}

check_interface() {
    if ! iwconfig $INTERFACE &> /dev/null; then
        echo -e "${RED}❌ Interface $INTERFACE no encontrada${NC}"
        exit 1
    fi
    
    # Verificar si está en modo monitor
    if iwconfig $INTERFACE | grep -q "Mode:Monitor"; then
        echo -e "${GREEN}✅ Interface en modo monitor${NC}"
    else
        echo -e "${YELLOW}⚠️  Interface NO está en modo monitor${NC}"
        read -p "¿Activar modo monitor? (y/N): " activate
        if [[ $activate == [yY] ]]; then
            sudo airmon-ng check kill &> /dev/null
            sudo airmon-ng start $INTERFACE &> /dev/null
            echo -e "${GREEN}✅ Modo monitor activado${NC}"
        fi
    fi
}

log_alert() {
    local alert_type="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] [$alert_type] $message" >> "$ALERT_FILE"
    echo -e "${RED}🚨 ALERTA [$alert_type]: $message${NC}"
    
    # Notificación del sistema si está disponible
    if command -v notify-send &> /dev/null; then
        notify-send "WiFi Security Alert" "[$alert_type] $message"
    fi
}

detect_deauth_attacks() {
    echo -e "${YELLOW}🔍 Monitoreando ataques de deauth...${NC}"
    
    local capture_file="$LOG_DIR/deauth_monitor_$(date +%Y%m%d_%H%M%S).pcap"
    
    # Capturar tráfico y analizar en tiempo real
    sudo airodump-ng $INTERFACE --band abg -w "${capture_file%.*}" > /tmp/airodump_output.txt 2>&1 &
    local airodump_pid=$!
    
    # Monitor en tiempo real
    while true; do
        # Verificar deauth frames en la captura reciente
        if [[ -f "${capture_file%.*}-01.cap" ]]; then
            local deauth_count=$(tshark -r "${capture_file%.*}-01.cap" -Y "wlan.fc.type_subtype == 12" 2>/dev/null | wc -l)
            
            if [[ $deauth_count -gt 50 ]]; then
                log_alert "DEAUTH_FLOOD" "Detectado flood de deauth: $deauth_count frames"
            fi
        fi
        
        sleep 10
    done
    
    kill $airodump_pid 2>/dev/null
}

detect_evil_twins() {
    echo -e "${YELLOW}👹 Detectando Evil Twins...${NC}"
    
    declare -A known_networks
    local scan_file="$LOG_DIR/network_scan_$(date +%Y%m%d_%H%M%S).txt"
    
    while true; do
        # Escanear redes
        iwlist $INTERFACE scan | grep -E "(ESSID|Address|Channel)" > "$scan_file"
        
        # Analizar duplicados de SSID
        while IFS= read -r line; do
            if [[ $line == *"ESSID:"* ]]; then
                local ssid=$(echo "$line" | cut -d'"' -f2)
                if [[ -n "$ssid" && "$ssid" != "<hidden>" ]]; then
                    if [[ ${known_networks["$ssid"]} ]]; then
                        ((known_networks["$ssid"]++))
                        if [[ ${known_networks["$ssid"]} -gt 2 ]]; then
                            log_alert "EVIL_TWIN" "Posible Evil Twin detectado: $ssid (${known_networks[$ssid]} instancias)"
                        fi
                    else
                        known_networks["$ssid"]=1
                    fi
                fi
            fi
        done < "$scan_file"
        
        sleep 30
    done
}

detect_unusual_traffic() {
    echo -e "${YELLOW}📊 Monitoreando tráfico inusual...${NC}"
    
    local capture_file="$LOG_DIR/traffic_monitor_$(date +%Y%m%d_%H%M%S).pcap"
    local baseline_file="$LOG_DIR/traffic_baseline.txt"
    
    # Crear baseline si no existe
    if [[ ! -f "$baseline_file" ]]; then
        echo -e "${BLUE}📈 Creando baseline de tráfico normal...${NC}"
        timeout 60 sudo tcpdump -i $INTERFACE -c 1000 > "$baseline_file" 2>&1
    fi
    
    # Monitorear tráfico actual vs baseline
    while true; do
        timeout 30 sudo tcpdump -i $INTERFACE -c 500 > /tmp/current_traffic.txt 2>&1
        
        local baseline_packets=$(wc -l < "$baseline_file")
        local current_packets=$(wc -l < "/tmp/current_traffic.txt")
        
        # Calcular diferencia porcentual
        local diff=$((current_packets * 100 / baseline_packets))
        
        if [[ $diff -gt 300 ]]; then
            log_alert "TRAFFIC_SPIKE" "Pico de tráfico detectado: ${diff}% sobre baseline"
        elif [[ $diff -lt 20 ]]; then
            log_alert "TRAFFIC_DROP" "Caída significativa de tráfico: ${diff}% del baseline"
        fi
        
        sleep 60
    done
}

detect_wps_attacks() {
    echo -e "${YELLOW}🔓 Detectando ataques WPS...${NC}"
    
    local wps_log="$LOG_DIR/wps_monitor.log"
    declare -A wps_attempts
    
    while true; do
        # Monitorear intentos WPS
        wash -i $INTERFACE 2>/dev/null | while IFS= read -r line; do
            if [[ $line == *":"*":"*":"*":"*":"* ]]; then
                local bssid=$(echo "$line" | awk '{print $1}')
                local attempts=$(echo "$line" | awk '{print $5}')
                
                if [[ $attempts -gt 10 ]]; then
                    log_alert "WPS_BRUTE" "Posible brute force WPS: $bssid ($attempts intentos)"
                fi
            fi
        done
        
        sleep 45
    done
}

detect_probe_requests() {
    echo -e "${YELLOW}📡 Monitoreando probe requests sospechosos...${NC}"
    
    local probe_file="$LOG_DIR/probe_requests_$(date +%Y%m%d_%H%M%S).txt"
    declare -A probe_counts
    
    # Capturar probe requests
    sudo tshark -i $INTERFACE -Y "wlan.fc.type_subtype == 4" -T fields -e wlan.sa -e wlan_mgt.ssid 2>/dev/null | \
    while IFS=$'\t' read -r mac ssid; do
        if [[ -n "$mac" ]]; then
            ((probe_counts["$mac"]++))
            
            # Detectar probe floods
            if [[ ${probe_counts["$mac"]} -gt 100 ]]; then
                log_alert "PROBE_FLOOD" "Flood de probe requests desde $mac (${probe_counts[$mac]} requests)"
                probe_counts["$mac"]=0  # Reset counter
            fi
            
            # Detectar probe requests por SSIDs sensibles
            if [[ $ssid == *"FBI"* || $ssid == *"NSA"* || $ssid == *"Police"* ]]; then
                log_alert "SUSPICIOUS_PROBE" "Probe request sospechoso: $mac busca '$ssid'"
            fi
            
            echo "$(date '+%H:%M:%S') $mac -> $ssid" >> "$probe_file"
        fi
    done &
}

detect_beacon_floods() {
    echo -e "${YELLOW}📻 Detectando beacon floods...${NC}"
    
    local beacon_file="$LOG_DIR/beacon_analysis.txt"
    declare -A beacon_counts
    
    while true; do
        # Analizar beacons en ventana de tiempo
        local start_time=$(date +%s)
        
        sudo tshark -i $INTERFACE -a duration:30 -Y "wlan.fc.type_subtype == 8" -T fields -e wlan.sa -e wlan_mgt.ssid 2>/dev/null | \
        while IFS=$'\t' read -r mac ssid; do
            if [[ -n "$mac" ]]; then
                ((beacon_counts["$mac"]++))
            fi
        done
        
        # Verificar conteos anormales
        for mac in "${!beacon_counts[@]}"; do
            if [[ ${beacon_counts[$mac]} -gt 200 ]]; then
                log_alert "BEACON_FLOOD" "Flood de beacons desde $mac (${beacon_counts[$mac]} beacons en 30s)"
            fi
        done
        
        # Reset contadores
        unset beacon_counts
        declare -A beacon_counts
        
        sleep 30
    done
}

monitor_network_changes() {
    echo -e "${YELLOW}🔄 Monitoreando cambios en la red...${NC}"
    
    local networks_file="$LOG_DIR/known_networks.txt"
    local current_scan="/tmp/current_networks.txt"
    
    # Crear archivo inicial si no existe
    if [[ ! -f "$networks_file" ]]; then
        iwlist $INTERFACE scan | grep -E "ESSID" | sort > "$networks_file"
        echo -e "${BLUE}📋 Baseline de redes creado${NC}"
    fi
    
    while true; do
        iwlist $INTERFACE scan | grep -E "ESSID" | sort > "$current_scan"
        
        # Detectar redes nuevas
        local new_networks=$(comm -13 "$networks_file" "$current_scan")
        if [[ -n "$new_networks" ]]; then
            while IFS= read -r network; do
                local ssid=$(echo "$network" | cut -d'"' -f2)
                if [[ -n "$ssid" ]]; then
                    log_alert "NEW_NETWORK" "Nueva red detectada: $ssid"
                fi
            done <<< "$new_networks"
            
            # Actualizar baseline
            cat "$current_scan" > "$networks_file"
        fi
        
        # Detectar redes desaparecidas
        local missing_networks=$(comm -23 "$networks_file" "$current_scan")
        if [[ -n "$missing_networks" ]]; then
            while IFS= read -r network; do
                local ssid=$(echo "$network" | cut -d'"' -f2)
                if [[ -n "$ssid" ]]; then
                    log_alert "NETWORK_DOWN" "Red desaparecida: $ssid"
                fi
            done <<< "$missing_networks"
        fi
        
        sleep 60
    done
}

show_dashboard() {
    while true; do
        clear
        print_banner
        
        echo -e "${BLUE}📊 DASHBOARD DE SEGURIDAD WiFi${NC}"
        echo -e "${BLUE}=================================${NC}"
        echo ""
        
        echo -e "${YELLOW}📈 Estadísticas:${NC}"
        echo "• Interface: $INTERFACE"
        echo "• Logs: $LOG_DIR"
        echo "• Alertas totales: $(wc -l < "$ALERT_FILE" 2>/dev/null || echo 0)"
        echo "• Última alerta: $(tail -1 "$ALERT_FILE" 2>/dev/null || echo "Ninguna")"
        echo ""
        
        echo -e "${YELLOW}🔴 Últimas alertas (5):${NC}"
        tail -5 "$ALERT_FILE" 2>/dev/null || echo "No hay alertas recientes"
        echo ""
        
        echo -e "${YELLOW}📡 Redes activas:${NC}"
        iwlist $INTERFACE scan 2>/dev/null | grep -E "ESSID" | head -5
        echo ""
        
        echo -e "${BLUE}Presiona Ctrl+C para volver al menú${NC}"
        sleep 5
    done
}

generate_report() {
    local report_file="$LOG_DIR/security_report_$(date +%Y%m%d_%H%M%S).txt"
    
    echo -e "${YELLOW}📝 Generando reporte de seguridad...${NC}"
    
    {
        echo "REPORTE DE SEGURIDAD WiFi"
        echo "========================="
        echo "Fecha: $(date)"
        echo "Interface: $INTERFACE"
        echo ""
        
        echo "RESUMEN DE ALERTAS:"
        echo "==================="
        if [[ -f "$ALERT_FILE" ]]; then
            awk '{print $3}' "$ALERT_FILE" | sort | uniq -c | sort -nr
        else
            echo "No hay alertas registradas"
        fi
        echo ""
        
        echo "ALERTAS POR DÍA:"
        echo "================"
        if [[ -f "$ALERT_FILE" ]]; then
            awk '{print $1}' "$ALERT_FILE" | sort | uniq -c
        fi
        echo ""
        
        echo "ÚLTIMAS 20 ALERTAS:"
        echo "==================="
        tail -20 "$ALERT_FILE" 2>/dev/null || echo "No hay alertas"
        
    } > "$report_file"
    
    echo -e "${GREEN}✅ Reporte generado: $report_file${NC}"
    echo -e "${BLUE}📖 ¿Ver reporte? (y/N): ${NC}"
    read -r view_report
    
    if [[ $view_report == [yY] ]]; then
        less "$report_file"
    fi
}

# Función principal
main() {
    print_banner
    
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}❌ Este script necesita permisos de root${NC}"
        echo -e "Ejecuta con: ${YELLOW}sudo $0${NC}"
        exit 1
    fi
    
    setup_logging
    check_interface
    
    while true; do
        echo ""
        echo -e "${BLUE}╔═══════════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║${NC}           ${YELLOW}MONITOR DE SEGURIDAD${NC}           ${BLUE}║${NC}"
        echo -e "${BLUE}╠═══════════════════════════════════════════╣${NC}"
        echo -e "${BLUE}║${NC} ${YELLOW}1.${NC} Detectar ataques deauth            ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${YELLOW}2.${NC} Detectar Evil Twins                ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${YELLOW}3.${NC} Monitor tráfico inusual             ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${YELLOW}4.${NC} Detectar ataques WPS                ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${YELLOW}5.${NC} Monitor probe requests              ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${YELLOW}6.${NC} Detectar beacon floods              ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${YELLOW}7.${NC} Monitor cambios de red              ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${YELLOW}8.${NC} Dashboard en tiempo real            ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${YELLOW}9.${NC} Generar reporte                    ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${YELLOW}A.${NC} Monitoreo COMPLETO (automático)    ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${YELLOW}0.${NC} Salir                               ${BLUE}║${NC}"
        echo -e "${BLUE}╚═══════════════════════════════════════════╝${NC}"
        
        read -p "Selecciona una opción: " choice
        
        case $choice in
            1) detect_deauth_attacks ;;
            2) detect_evil_twins ;;
            3) detect_unusual_traffic ;;
            4) detect_wps_attacks ;;
            5) detect_probe_requests ;;
            6) detect_beacon_floods ;;
            7) monitor_network_changes ;;
            8) show_dashboard ;;
            9) generate_report ;;
            [aA])
                echo -e "${YELLOW}🤖 Iniciando monitoreo completo automático...${NC}"
                echo -e "${BLUE}Presiona Ctrl+C para detener${NC}"
                
                # Ejecutar múltiples detectores en paralelo
                detect_deauth_attacks &
                detect_evil_twins &
                detect_wps_attacks &
                detect_probe_requests &
                detect_beacon_floods &
                monitor_network_changes &
                
                # Mostrar dashboard
                show_dashboard
                ;;
            0) echo -e "${GREEN}👋 ¡Hasta luego!${NC}"; break ;;
            *) echo -e "${RED}❌ Opción inválida${NC}" ;;
        esac
    done
}

# Trap para cleanup
trap 'echo -e "\n${YELLOW}🛑 Deteniendo procesos...${NC}"; killall airodump-ng tshark tcpdump 2>/dev/null; exit 0' INT TERM

# Ejecutar script principal
main "$@"