#!/bin/bash

# 🔐 Analizador y Cracker de Handshakes WiFi
# Uso: ./handshake_analyzer.sh [archivo.cap]

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_banner() {
    echo -e "${BLUE}"
    echo "██╗  ██╗ █████╗ ███╗   ██╗██████╗ ███████╗██╗  ██╗ █████╗ ██╗  ██╗███████╗"
    echo "██║  ██║██╔══██╗████╗  ██║██╔══██╗██╔════╝██║  ██║██╔══██╗██║ ██╔╝██╔════╝"
    echo "███████║███████║██╔██╗ ██║██║  ██║███████╗███████║███████║█████╔╝ █████╗  "
    echo "██╔══██║██╔══██║██║╚██╗██║██║  ██║╚════██║██╔══██║██╔══██║██╔═██╗ ██╔══╝  "
    echo "██║  ██║██║  ██║██║ ╚████║██████╔╝███████║██║  ██║██║  ██║██║  ██╗███████╗"
    echo "╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝"
    echo -e "${NC}"
    echo -e "${YELLOW}🔐 Analizador y Cracker de Handshakes WiFi${NC}"
    echo ""
}

analyze_handshake() {
    local capfile=$1
    
    if [[ ! -f "$capfile" ]]; then
        echo -e "${RED}❌ Archivo $capfile no encontrado${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}📊 Analizando archivo: $capfile${NC}"
    echo ""
    
    # Verificar handshakes con aircrack-ng
    echo -e "${BLUE}🔍 Verificación con aircrack-ng:${NC}"
    aircrack-ng "$capfile"
    
    echo ""
    
    # Verificar con pyrit si está disponible
    if command -v pyrit &> /dev/null; then
        echo -e "${BLUE}🔍 Verificación con pyrit:${NC}"
        pyrit -r "$capfile" analyze
        echo ""
    fi
    
    # Información del archivo
    echo -e "${BLUE}📋 Información del archivo:${NC}"
    ls -lh "$capfile"
    echo ""
    
    # Extraer información con capinfos si está disponible
    if command -v capinfos &> /dev/null; then
        echo -e "${BLUE}📈 Estadísticas del archivo:${NC}"
        capinfos "$capfile"
        echo ""
    fi
}

convert_for_hashcat() {
    local capfile=$1
    local hccapx_file="${capfile%.*}.hccapx"
    local hash_file="${capfile%.*}.hash"
    
    echo -e "${YELLOW}🔄 Convirtiendo para hashcat...${NC}"
    
    # Método 1: cap2hccapx
    if command -v cap2hccapx &> /dev/null; then
        cap2hccapx "$capfile" "$hccapx_file"
        if [[ -f "$hccapx_file" ]]; then
            echo -e "${GREEN}✅ Archivo hccapx creado: $hccapx_file${NC}"
        fi
    fi
    
    # Método 2: hcxpcaptool para WPA22000
    if command -v hcxpcaptool &> /dev/null; then
        hcxpcaptool -o "$hash_file" "$capfile"
        if [[ -f "$hash_file" ]]; then
            echo -e "${GREEN}✅ Archivo hash creado: $hash_file${NC}"
        fi
    fi
    
    # Método 3: hcxpcapngtool si es pcapng
    if [[ "$capfile" == *.pcapng ]] && command -v hcxpcapngtool &> /dev/null; then
        hcxpcapngtool -o "$hash_file" "$capfile"
        if [[ -f "$hash_file" ]]; then
            echo -e "${GREEN}✅ Archivo hash (pcapng) creado: $hash_file${NC}"
        fi
    fi
}

crack_with_aircrack() {
    local capfile=$1
    local wordlist=$2
    
    echo -e "${YELLOW}🔓 Iniciando crack con aircrack-ng...${NC}"
    
    if [[ -z "$wordlist" ]]; then
        # Buscar wordlists comunes
        local wordlists=(
            "/usr/share/wordlists/rockyou.txt"
            "/usr/share/wordlists/dirb/common.txt"
            "/usr/share/seclists/Passwords/WiFi-WPA/probable-v2-wpa-top4800.txt"
        )
        
        for wl in "${wordlists[@]}"; do
            if [[ -f "$wl" ]]; then
                wordlist="$wl"
                echo -e "${BLUE}📚 Usando wordlist: $wordlist${NC}"
                break
            fi
        done
        
        if [[ -z "$wordlist" ]]; then
            echo -e "${RED}❌ No se encontró wordlist automáticamente${NC}"
            read -p "Ruta del wordlist: " wordlist
        fi
    fi
    
    if [[ ! -f "$wordlist" ]]; then
        echo -e "${RED}❌ Wordlist no encontrado: $wordlist${NC}"
        return 1
    fi
    
    # Ejecutar aircrack-ng
    aircrack-ng -w "$wordlist" "$capfile"
}

crack_with_hashcat() {
    local capfile=$1
    local wordlist=$2
    
    if ! command -v hashcat &> /dev/null; then
        echo -e "${RED}❌ hashcat no está instalado${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}🚀 Iniciando crack con hashcat...${NC}"
    
    # Convertir archivo
    convert_for_hashcat "$capfile"
    
    local hash_file="${capfile%.*}.hash"
    local hccapx_file="${capfile%.*}.hccapx"
    
    if [[ -z "$wordlist" ]]; then
        wordlist="/usr/share/wordlists/rockyou.txt"
    fi
    
    if [[ ! -f "$wordlist" ]]; then
        echo -e "${RED}❌ Wordlist no encontrado: $wordlist${NC}"
        return 1
    fi
    
    # Usar hash file si está disponible (WPA22000)
    if [[ -f "$hash_file" ]]; then
        echo -e "${BLUE}🔥 Crackeando con modo 22000 (WPA22000)...${NC}"
        hashcat -m 22000 "$hash_file" "$wordlist"
    elif [[ -f "$hccapx_file" ]]; then
        echo -e "${BLUE}🔥 Crackeando con modo 2500 (HCCAPX)...${NC}"
        hashcat -m 2500 "$hccapx_file" "$wordlist"
    else
        echo -e "${RED}❌ No se pudo convertir el archivo para hashcat${NC}"
        return 1
    fi
}

crack_with_john() {
    local capfile=$1
    local wordlist=$2
    
    if ! command -v john &> /dev/null; then
        echo -e "${RED}❌ john no está instalado${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}🔧 Iniciando crack con John the Ripper...${NC}"
    
    local john_file="${capfile%.*}.john"
    
    # Convertir con hcx2john si está disponible
    if command -v hcx2john &> /dev/null; then
        hcx2john "$capfile" > "$john_file"
    else
        # Usar aircrack2john si está disponible
        if command -v aircrack2john &> /dev/null; then
            aircrack2john "$capfile" > "$john_file"
        else
            echo -e "${RED}❌ No se encontró herramienta de conversión para john${NC}"
            return 1
        fi
    fi
    
    if [[ ! -s "$john_file" ]]; then
        echo -e "${RED}❌ Error al convertir archivo para john${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✅ Archivo convertido: $john_file${NC}"
    
    if [[ -z "$wordlist" ]]; then
        wordlist="/usr/share/wordlists/rockyou.txt"
    fi
    
    if [[ -f "$wordlist" ]]; then
        john --wordlist="$wordlist" "$john_file"
    else
        john "$john_file"
    fi
}

generate_wordlist() {
    local output_file=$1
    
    if [[ -z "$output_file" ]]; then
        output_file="custom_wordlist.txt"
    fi
    
    echo -e "${YELLOW}📝 Generando wordlist personalizada...${NC}"
    
    read -p "Longitud mínima (default: 8): " min_len
    read -p "Longitud máxima (default: 12): " max_len
    read -p "Caracteres a usar (default: abcdefghijklmnopqrstuvwxyz0123456789): " charset
    
    min_len=${min_len:-8}
    max_len=${max_len:-12}
    charset=${charset:-abcdefghijklmnopqrstuvwxyz0123456789}
    
    if command -v crunch &> /dev/null; then
        echo -e "${BLUE}🔨 Generando con crunch...${NC}"
        crunch $min_len $max_len $charset -o "$output_file"
        echo -e "${GREEN}✅ Wordlist generada: $output_file${NC}"
    else
        echo -e "${RED}❌ crunch no está instalado${NC}"
        echo "Instala con: sudo apt install crunch"
    fi
}

show_wordlists() {
    echo -e "${BLUE}📚 Wordlists disponibles:${NC}"
    echo ""
    
    local wordlist_paths=(
        "/usr/share/wordlists/"
        "/usr/share/seclists/Passwords/"
        "/opt/wordlists/"
    )
    
    for path in "${wordlist_paths[@]}"; do
        if [[ -d "$path" ]]; then
            echo -e "${YELLOW}📁 $path${NC}"
            find "$path" -name "*.txt" -o -name "*.lst" -o -name "*.dict" 2>/dev/null | head -10
            echo ""
        fi
    done
}

batch_analyze() {
    echo -e "${YELLOW}📂 Análisis en lote de archivos .cap/.pcap/.pcapng${NC}"
    
    local files=(*.cap *.pcap *.pcapng)
    local found_files=()
    
    # Verificar qué archivos existen
    for file in "${files[@]}"; do
        if [[ -f "$file" ]]; then
            found_files+=("$file")
        fi
    done
    
    if [[ ${#found_files[@]} -eq 0 ]]; then
        echo -e "${RED}❌ No se encontraron archivos de captura${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✅ Archivos encontrados: ${#found_files[@]}${NC}"
    
    for file in "${found_files[@]}"; do
        echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${YELLOW}📄 Analizando: $file${NC}"
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        analyze_handshake "$file"
    done
}

show_help() {
    echo -e "${BLUE}📚 Ayuda - Opciones disponibles:${NC}"
    echo ""
    echo -e "  ${YELLOW}1.${NC} Analizar handshake"
    echo -e "  ${YELLOW}2.${NC} Crack con aircrack-ng"
    echo -e "  ${YELLOW}3.${NC} Crack con hashcat"
    echo -e "  ${YELLOW}4.${NC} Crack con john"
    echo -e "  ${YELLOW}5.${NC} Generar wordlist"
    echo -e "  ${YELLOW}6.${NC} Mostrar wordlists"
    echo -e "  ${YELLOW}7.${NC} Análisis en lote"
    echo -e "  ${YELLOW}8.${NC} Esta ayuda"
    echo -e "  ${YELLOW}0.${NC} Salir"
    echo ""
    echo -e "${BLUE}Uso directo:${NC}"
    echo -e "  ${YELLOW}$0 archivo.cap${NC} - Analizar archivo específico"
}

# Función principal
main() {
    print_banner
    
    # Si se proporciona archivo como argumento
    if [[ -n "$1" ]]; then
        analyze_handshake "$1"
        return 0
    fi
    
    while true; do
        echo ""
        echo -e "${BLUE}╔═════════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║${NC}          ${YELLOW}ANALIZADOR HANDSHAKES${NC}          ${BLUE}║${NC}"
        echo -e "${BLUE}╠═════════════════════════════════════════╣${NC}"
        echo -e "${BLUE}║${NC} ${YELLOW}1.${NC} Analizar handshake               ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${YELLOW}2.${NC} Crack con aircrack-ng            ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${YELLOW}3.${NC} Crack con hashcat                ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${YELLOW}4.${NC} Crack con john                   ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${YELLOW}5.${NC} Generar wordlist                 ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${YELLOW}6.${NC} Mostrar wordlists                ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${YELLOW}7.${NC} Análisis en lote                 ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${YELLOW}8.${NC} Ayuda                            ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${YELLOW}0.${NC} Salir                            ${BLUE}║${NC}"
        echo -e "${BLUE}╚═════════════════════════════════════════╝${NC}"
        
        read -p "Selecciona una opción: " choice
        
        case $choice in
            1) 
                read -p "Archivo de captura: " capfile
                analyze_handshake "$capfile"
                ;;
            2) 
                read -p "Archivo de captura: " capfile
                read -p "Wordlist (Enter para auto): " wordlist
                crack_with_aircrack "$capfile" "$wordlist"
                ;;
            3)
                read -p "Archivo de captura: " capfile
                read -p "Wordlist (Enter para auto): " wordlist
                crack_with_hashcat "$capfile" "$wordlist"
                ;;
            4)
                read -p "Archivo de captura: " capfile
                read -p "Wordlist (Enter para auto): " wordlist
                crack_with_john "$capfile" "$wordlist"
                ;;
            5)
                read -p "Nombre del archivo de salida: " output_file
                generate_wordlist "$output_file"
                ;;
            6) show_wordlists ;;
            7) batch_analyze ;;
            8) show_help ;;
            0) echo -e "${GREEN}👋 ¡Hasta luego!${NC}"; break ;;
            *) echo -e "${RED}❌ Opción inválida${NC}" ;;
        esac
    done
}

# Ejecutar script principal
main "$@"