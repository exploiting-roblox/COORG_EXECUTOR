#!/bin/bash

# ⚡ HASHCAT ULTIMATE CRACKER
# Cracking masivo de contraseñas con hashcat - TODAS las modalidades
# Autor: X (sebastian.corao) 
# Fecha: $(date)

# 🔴 ADVERTENCIA LEGAL
echo "
██╗  ██╗ █████╗ ███████╗██╗  ██╗ ██████╗ █████╗ ████████╗
██║  ██║██╔══██╗██╔════╝██║  ██║██╔════╝██╔══██╗╚══██╔══╝
███████║███████║███████╗███████║██║     ███████║   ██║   
██╔══██║██╔══██║╚════██║██╔══██║██║     ██╔══██║   ██║   
██║  ██║██║  ██║███████║██║  ██║╚██████╗██║  ██║   ██║   
╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝   ╚═╝   
                                                         
⚡ ULTIMATE CRACKER - TODAS LAS MODALIDADES HASHCAT ⚡
"

echo "🔴 ADVERTENCIA LEGAL:"
echo "Este script es SOLO para pentesting autorizado y fines educativos."
echo "El uso no autorizado es ILEGAL. Úsalo bajo tu propia responsabilidad."
echo ""
read -p "¿Entiendes y aceptas? (s/N): " acepta
if [[ ! "$acepta" =~ ^[Ss]$ ]]; then
    echo "❌ Operación cancelada"
    exit 1
fi

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # Sin color

# Variables globales
WORKDIR="hashcat_results_$(date +%Y%m%d_%H%M%S)"
LOG_FILE="$WORKDIR/hashcat_ultimate.log"
HASHCAT_BIN=""
POTFILE=""
SESSION_NAME=""

# Función de limpieza
cleanup() {
    echo ""
    echo -e "${YELLOW}🧹 Limpiando sesiones de hashcat...${NC}"
    if [[ -n "$SESSION_NAME" ]]; then
        hashcat --session="$SESSION_NAME" --remove 2>/dev/null || true
    fi
    echo -e "${GREEN}✅ Limpieza completada${NC}"
}

# Configurar trap para limpieza
trap cleanup EXIT INT TERM

# Verificar herramientas
verificar_herramientas() {
    echo -e "${BLUE}🔍 Verificando herramientas...${NC}"
    
    # Verificar hashcat
    if command -v hashcat >/dev/null 2>&1; then
        HASHCAT_BIN="hashcat"
    elif [[ -f "/usr/bin/hashcat" ]]; then
        HASHCAT_BIN="/usr/bin/hashcat"
    elif [[ -f "/opt/hashcat/hashcat" ]]; then
        HASHCAT_BIN="/opt/hashcat/hashcat"
    else
        echo -e "${RED}❌ hashcat no encontrado${NC}"
        echo "Instalar con: apt install hashcat"
        exit 1
    fi
    
    echo -e "${GREEN}✅ hashcat encontrado: $HASHCAT_BIN${NC}"
    
    # Verificar GPU (opcional)
    if command -v nvidia-smi >/dev/null 2>&1; then
        echo -e "${GREEN}✅ GPU NVIDIA detectada${NC}"
        nvidia-smi --query-gpu=name,memory.total --format=csv,noheader 2>/dev/null || true
    elif command -v rocm-smi >/dev/null 2>&1; then
        echo -e "${GREEN}✅ GPU AMD detectada${NC}"
    else
        echo -e "${YELLOW}⚠️ No se detectó GPU - usaremos CPU${NC}"
    fi
    
    # Verificar otras herramientas útiles
    command -v john >/dev/null 2>&1 && echo -e "${GREEN}✅ john the ripper disponible${NC}"
    command -v hash-identifier >/dev/null 2>&1 && echo -e "${GREEN}✅ hash-identifier disponible${NC}"
    command -v hashid >/dev/null 2>&1 && echo -e "${GREEN}✅ hashid disponible${NC}"
    
    echo ""
}

# Configurar directorio de trabajo
configurar_directorio() {
    echo -e "${BLUE}📁 Configurando directorio de trabajo...${NC}"
    
    mkdir -p "$WORKDIR"/{hashes,wordlists,results,rules,masks}
    POTFILE="$WORKDIR/hashcat.potfile"
    
    echo -e "${GREEN}✅ Directorio creado: $WORKDIR${NC}"
    echo ""
}

# Identificar tipo de hash
identificar_hash() {
    echo -e "${PURPLE}🔍 IDENTIFICACIÓN DE HASH${NC}"
    echo ""
    echo "Métodos disponibles:"
    echo "1) Introducir hash para identificación automática"
    echo "2) Seleccionar tipo de hash manualmente"
    echo "3) Cargar archivo con hashes"
    echo "4) Volver al menú principal"
    echo ""
    
    read -p "Selecciona opción [1-4]: " opcion
    
    case $opcion in
        1)
            read -p "Introduce el hash: " hash_input
            echo ""
            echo -e "${CYAN}🔍 Analizando hash...${NC}"
            
            # Usar hashid si está disponible
            if command -v hashid >/dev/null 2>&1; then
                echo -e "${YELLOW}📊 Análisis con hashid:${NC}"
                hashid "$hash_input"
            fi
            
            # Usar hash-identifier si está disponible
            if command -v hash-identifier >/dev/null 2>&1; then
                echo -e "${YELLOW}📊 Análisis con hash-identifier:${NC}"
                echo "$hash_input" | hash-identifier
            fi
            
            # Análisis manual básico
            echo ""
            echo -e "${YELLOW}📊 Análisis manual básico:${NC}"
            length=${#hash_input}
            case $length in
                32) echo "Posible MD5 (32 caracteres)" ;;
                40) echo "Posible SHA1 (40 caracteres)" ;;
                64) echo "Posible SHA256 (64 caracteres)" ;;
                96) echo "Posible SHA384 (96 caracteres)" ;;
                128) echo "Posible SHA512 (128 caracteres)" ;;
                *) echo "Longitud: $length caracteres" ;;
            esac
            
            echo "$hash_input" > "$WORKDIR/hashes/target_hash.txt"
            echo -e "${GREEN}✅ Hash guardado en $WORKDIR/hashes/target_hash.txt${NC}"
            ;;
            
        2)
            mostrar_tipos_hash
            ;;
            
        3)
            read -p "Ruta del archivo con hashes: " hash_file
            if [[ -f "$hash_file" ]]; then
                cp "$hash_file" "$WORKDIR/hashes/"
                echo -e "${GREEN}✅ Archivo copiado a $WORKDIR/hashes/${NC}"
            else
                echo -e "${RED}❌ Archivo no encontrado${NC}"
            fi
            ;;
            
        4)
            return
            ;;
            
        *)
            echo -e "${RED}❌ Opción inválida${NC}"
            ;;
    esac
    
    echo ""
    read -p "Presiona Enter para continuar..."
}

# Mostrar tipos de hash comunes
mostrar_tipos_hash() {
    echo -e "${CYAN}📋 TIPOS DE HASH COMUNES EN HASHCAT${NC}"
    echo ""
    echo "=== HASHES BÁSICOS ==="
    echo "0     - MD5"
    echo "100   - SHA1"
    echo "1400  - SHA256"
    echo "1700  - SHA512"
    echo "3000  - LM"
    echo "1000  - NTLM"
    echo ""
    echo "=== SISTEMAS OPERATIVOS ==="
    echo "500   - md5crypt (Linux/Unix)"
    echo "1800  - sha512crypt (Linux/Unix)"
    echo "7400  - sha256crypt (Linux/Unix)"
    echo "1500  - descrypt (Unix)"
    echo ""
    echo "=== BASES DE DATOS ==="
    echo "12    - PostgreSQL"
    echo "131   - MSSQL(2000)"
    echo "132   - MSSQL(2005)"
    echo "1731  - MSSQL(2012/2014)"
    echo "200   - MySQL323"
    echo "300   - MySQL4.1/MySQL5"
    echo ""
    echo "=== APLICACIONES WEB ==="
    echo "400   - phpass"
    echo "2500  - WPA/WPA2"
    echo "16800 - WPA-PMKID-PBKDF2"
    echo "1800  - Drupal7"
    echo "400   - WordPress"
    echo "124   - Joomla"
    echo ""
    echo "=== ARCHIVOS ==="
    echo "11600 - 7-Zip"
    echo "13400 - KeePass 1"
    echo "13400 - KeePass 2"
    echo "9700  - MS Office ≤ 2003 MD5"
    echo "9800  - MS Office ≤ 2003 SHA1"
    echo "25300 - MS Office 2016"
    echo "10500 - PDF 1.4-1.6"
    echo ""
    echo "=== REDES ==="
    echo "5500  - NetNTLMv1"
    echo "5600  - NetNTLMv2"
    echo "23    - Skype"
    echo "2500  - WPA/WPA2"
    echo ""
    read -p "Presiona Enter para continuar..."
}

# Gestión de wordlists
gestionar_wordlists() {
    echo -e "${PURPLE}📚 GESTIÓN DE WORDLISTS${NC}"
    echo ""
    echo "Opciones:"
    echo "1) Usar wordlists del sistema (rockyou, etc.)"
    echo "2) Descargar wordlists populares"
    echo "3) Crear wordlist personalizada"
    echo "4) Combinar wordlists"
    echo "5) Generar wordlist con crunch"
    echo "6) Listar wordlists disponibles"
    echo "7) Volver al menú principal"
    echo ""
    
    read -p "Selecciona opción [1-7]: " opcion
    
    case $opcion in
        1)
            usar_wordlists_sistema
            ;;
        2)
            descargar_wordlists
            ;;
        3)
            crear_wordlist_personalizada
            ;;
        4)
            combinar_wordlists
            ;;
        5)
            generar_con_crunch
            ;;
        6)
            listar_wordlists
            ;;
        7)
            return
            ;;
        *)
            echo -e "${RED}❌ Opción inválida${NC}"
            ;;
    esac
    
    echo ""
    read -p "Presiona Enter para continuar..."
}

# Usar wordlists del sistema
usar_wordlists_sistema() {
    echo -e "${CYAN}🔍 Buscando wordlists del sistema...${NC}"
    
    # Ubicaciones comunes
    wordlist_paths=(
        "/usr/share/wordlists/rockyou.txt"
        "/usr/share/wordlists/rockyou.txt.gz"
        "/usr/share/seclists"
        "/usr/share/wordlists"
        "/opt/wordlists"
        "~/wordlists"
    )
    
    found_wordlists=()
    
    for path in "${wordlist_paths[@]}"; do
        if [[ -f "$path" ]] || [[ -d "$path" ]]; then
            found_wordlists+=("$path")
            echo -e "${GREEN}✅ Encontrado: $path${NC}"
        fi
    done
    
    if [[ ${#found_wordlists[@]} -eq 0 ]]; then
        echo -e "${YELLOW}⚠️ No se encontraron wordlists del sistema${NC}"
        echo "Instala con: apt install seclists"
        return
    fi
    
    # Descomprimir rockyou si está comprimido
    if [[ -f "/usr/share/wordlists/rockyou.txt.gz" ]] && [[ ! -f "/usr/share/wordlists/rockyou.txt" ]]; then
        echo -e "${YELLOW}📦 Descomprimiendo rockyou.txt...${NC}"
        sudo gunzip /usr/share/wordlists/rockyou.txt.gz 2>/dev/null || true
    fi
    
    # Copiar wordlists importantes
    if [[ -f "/usr/share/wordlists/rockyou.txt" ]]; then
        ln -sf "/usr/share/wordlists/rockyou.txt" "$WORKDIR/wordlists/rockyou.txt"
        echo -e "${GREEN}✅ rockyou.txt enlazado${NC}"
    fi
    
    if [[ -d "/usr/share/seclists" ]]; then
        ln -sf "/usr/share/seclists" "$WORKDIR/wordlists/seclists"
        echo -e "${GREEN}✅ SecLists enlazado${NC}"
    fi
}

# Descargar wordlists populares
descargar_wordlists() {
    echo -e "${CYAN}⬇️ DESCARGA DE WORDLISTS POPULARES${NC}"
    echo ""
    echo "Wordlists disponibles para descarga:"
    echo "1) Top 1000 passwords"
    echo "2) Common passwords extended"
    echo "3) Leaked passwords compilation"
    echo "4) Gaming passwords"
    echo "5) Spanish passwords"
    echo "6) Todas las anteriores"
    echo ""
    
    read -p "Selecciona [1-6]: " dl_option
    
    cd "$WORKDIR/wordlists"
    
    case $dl_option in
        1|6)
            echo -e "${YELLOW}📥 Descargando top 1000 passwords...${NC}"
            curl -s "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/Common-Credentials/10-million-password-list-top-1000.txt" -o top1000.txt 2>/dev/null || echo "Error descargando"
            ;;
    esac
    
    case $dl_option in
        2|6)
            echo -e "${YELLOW}📥 Descargando common passwords...${NC}"
            curl -s "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/Common-Credentials/10-million-password-list-top-10000.txt" -o common10k.txt 2>/dev/null || echo "Error descargando"
            ;;
    esac
    
    case $dl_option in
        3|6)
            echo -e "${YELLOW}📥 Descargando leaked passwords...${NC}"
            curl -s "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/Leaked-Databases/rockyou-75.txt" -o leaked.txt 2>/dev/null || echo "Error descargando"
            ;;
    esac
    
    case $dl_option in
        4|6)
            echo -e "${YELLOW}📥 Creando gaming passwords...${NC}"
            cat > gaming.txt << 'EOF'
password
123456
admin
root
gamer
player1
minecraft
roblox
steam
gaming
pro
noob
pwned
1234
qwerty
password123
admin123
123456789
welcome
letmein
dragon
monkey
master
shadow
superman
batman
pokemon
mario
sonic
zelda
warcraft
fortnite
pubg
csgo
dota
league
overwatch
destiny
halo
cod
fifa
nba
madden
xbox
playstation
nintendo
switch
pc
mobile
android
iphone
EOF
            ;;
    esac
    
    case $dl_option in
        5|6)
            echo -e "${YELLOW}📥 Creando Spanish passwords...${NC}"
            cat > spanish.txt << 'EOF'
contraseña
admin
administrador
usuario
invitado
clave
secreto
privado
seguro
acceso
entrada
bienvenido
hola
adios
gracias
por favor
si
no
casa
familia
amor
trabajo
escuela
universidad
Madrid
Barcelona
Valencia
España
mexico
argentina
colombia
chile
peru
123456
qwerty
asdfgh
zxcvbn
password
admin123
user123
test123
demo123
guest123
EOF
            ;;
    esac
    
    cd - >/dev/null
    echo -e "${GREEN}✅ Wordlists descargadas en $WORKDIR/wordlists/${NC}"
}

# Crear wordlist personalizada
crear_wordlist_personalizada() {
    echo -e "${CYAN}✏️ CREAR WORDLIST PERSONALIZADA${NC}"
    echo ""
    echo "Información objetivo (opcional - Enter para saltar):"
    read -p "Nombre/empresa: " target_name
    read -p "Año actual: " target_year
    read -p "Palabras clave (separadas por espacios): " keywords
    
    custom_file="$WORKDIR/wordlists/custom_$(date +%H%M%S).txt"
    
    echo -e "${YELLOW}📝 Generando wordlist personalizada...${NC}"
    
    # Base común
    cat > "$custom_file" << 'EOF'
123456
password
admin
root
guest
user
test
demo
welcome
login
access
secret
private
public
temp
default
master
super
power
strong
secure
EOF
    
    # Agregar información del objetivo
    if [[ -n "$target_name" ]]; then
        echo "$target_name" >> "$custom_file"
        echo "${target_name}123" >> "$custom_file"
        echo "${target_name}2024" >> "$custom_file"
        echo "${target_name}admin" >> "$custom_file"
        echo "admin${target_name}" >> "$custom_file"
    fi
    
    if [[ -n "$target_year" ]]; then
        echo "$target_year" >> "$custom_file"
        echo "password${target_year}" >> "$custom_file"
    fi
    
    if [[ -n "$keywords" ]]; then
        for keyword in $keywords; do
            echo "$keyword" >> "$custom_file"
            echo "${keyword}123" >> "$custom_file"
            echo "${keyword}admin" >> "$custom_file"
            echo "admin${keyword}" >> "$custom_file"
        done
    fi
    
    # Eliminar duplicados y ordenar
    sort "$custom_file" | uniq > "${custom_file}.tmp"
    mv "${custom_file}.tmp" "$custom_file"
    
    lines=$(wc -l < "$custom_file")
    echo -e "${GREEN}✅ Wordlist personalizada creada: $custom_file ($lines líneas)${NC}"
}

# Combinar wordlists
combinar_wordlists() {
    echo -e "${CYAN}🔗 COMBINAR WORDLISTS${NC}"
    echo ""
    
    cd "$WORKDIR/wordlists"
    available_lists=(*.txt)
    
    if [[ ${#available_lists[@]} -eq 0 ]]; then
        echo -e "${YELLOW}⚠️ No hay wordlists disponibles${NC}"
        return
    fi
    
    echo "Wordlists disponibles:"
    for i in "${!available_lists[@]}"; do
        size=$(wc -l < "${available_lists[$i]}" 2>/dev/null || echo "?")
        echo "$((i+1))) ${available_lists[$i]} ($size líneas)"
    done
    
    echo ""
    read -p "Introduce números separados por espacios (ej: 1 3 5): " selection
    
    combined_file="combined_$(date +%H%M%S).txt"
    
    for num in $selection; do
        index=$((num-1))
        if [[ $index -ge 0 ]] && [[ $index -lt ${#available_lists[@]} ]]; then
            echo -e "${YELLOW}📁 Añadiendo ${available_lists[$index]}...${NC}"
            cat "${available_lists[$index]}" >> "$combined_file"
        fi
    done
    
    # Eliminar duplicados
    echo -e "${YELLOW}🔄 Eliminando duplicados...${NC}"
    sort "$combined_file" | uniq > "${combined_file}.tmp"
    mv "${combined_file}.tmp" "$combined_file"
    
    final_lines=$(wc -l < "$combined_file")
    echo -e "${GREEN}✅ Wordlist combinada: $combined_file ($final_lines líneas)${NC}"
    
    cd - >/dev/null
}

# Generar con crunch
generar_con_crunch() {
    echo -e "${CYAN}🎲 GENERAR WORDLIST CON CRUNCH${NC}"
    
    if ! command -v crunch >/dev/null 2>&1; then
        echo -e "${RED}❌ crunch no encontrado${NC}"
        echo "Instalar con: apt install crunch"
        return
    fi
    
    echo ""
    echo "Configuración de crunch:"
    read -p "Longitud mínima: " min_len
    read -p "Longitud máxima: " max_len
    read -p "Charset (a=lowercase, A=uppercase, 1=digits, @=symbols) o custom: " charset
    read -p "Patrón específico (opcional, ej: @@@@1111): " pattern
    
    crunch_file="$WORKDIR/wordlists/crunch_${min_len}_${max_len}_$(date +%H%M%S).txt"
    
    echo -e "${YELLOW}🎲 Generando con crunch...${NC}"
    echo "Esto puede tardar según el tamaño..."
    
    if [[ -n "$pattern" ]]; then
        crunch "$min_len" "$max_len" -t "$pattern" -o "$crunch_file"
    else
        case "$charset" in
            "a") crunch "$min_len" "$max_len" abcdefghijklmnopqrstuvwxyz -o "$crunch_file" ;;
            "A") crunch "$min_len" "$max_len" ABCDEFGHIJKLMNOPQRSTUVWXYZ -o "$crunch_file" ;;
            "1") crunch "$min_len" "$max_len" 0123456789 -o "$crunch_file" ;;
            "aA") crunch "$min_len" "$max_len" abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ -o "$crunch_file" ;;
            "a1") crunch "$min_len" "$max_len" abcdefghijklmnopqrstuvwxyz0123456789 -o "$crunch_file" ;;
            "aA1") crunch "$min_len" "$max_len" abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 -o "$crunch_file" ;;
            *) crunch "$min_len" "$max_len" "$charset" -o "$crunch_file" ;;
        esac
    fi
    
    if [[ -f "$crunch_file" ]]; then
        lines=$(wc -l < "$crunch_file")
        size=$(du -h "$crunch_file" | cut -f1)
        echo -e "${GREEN}✅ Wordlist generada: $crunch_file ($lines líneas, $size)${NC}"
    fi
}

# Listar wordlists disponibles
listar_wordlists() {
    echo -e "${CYAN}📋 WORDLISTS DISPONIBLES${NC}"
    echo ""
    
    cd "$WORKDIR/wordlists"
    
    if ls *.txt >/dev/null 2>&1; then
        echo "=== WORDLISTS LOCALES ==="
        for wordlist in *.txt; do
            if [[ -f "$wordlist" ]]; then
                lines=$(wc -l < "$wordlist" 2>/dev/null || echo "?")
                size=$(du -h "$wordlist" 2>/dev/null | cut -f1 || echo "?")
                echo "📄 $wordlist ($lines líneas, $size)"
            fi
        done
    else
        echo "📄 No hay wordlists locales"
    fi
    
    echo ""
    echo "=== ENLACES SISTEMA ==="
    if [[ -L "rockyou.txt" ]]; then
        target=$(readlink "rockyou.txt")
        echo "🔗 rockyou.txt -> $target"
    fi
    
    if [[ -L "seclists" ]]; then
        target=$(readlink "seclists")
        echo "🔗 seclists -> $target"
    fi
    
    cd - >/dev/null
}

# Configuración de ataques
configurar_ataque() {
    echo -e "${PURPLE}⚔️ CONFIGURACIÓN DE ATAQUE${NC}"
    echo ""
    
    # Verificar archivos necesarios
    if ! ls "$WORKDIR/hashes"/*.txt >/dev/null 2>&1; then
        echo -e "${RED}❌ No hay archivos de hash en $WORKDIR/hashes/${NC}"
        echo "Primero identifica o carga hashes."
        return
    fi
    
    if ! ls "$WORKDIR/wordlists"/*.txt >/dev/null 2>&1; then
        echo -e "${RED}❌ No hay wordlists en $WORKDIR/wordlists/${NC}"
        echo "Primero gestiona wordlists."
        return
    fi
    
    echo "Tipos de ataque:"
    echo "1) 📖 Dictionary attack (wordlist simple)"
    echo "2) 🔄 Dictionary + Rules (mutaciones)"
    echo "3) 🎭 Mask attack (fuerza bruta con patrón)"
    echo "4) 🔀 Combinator attack (combinar wordlists)"
    echo "5) 🎲 Hybrid attack (wordlist + mask)"
    echo "6) 🔥 Multi-mode attack (todos los métodos)"
    echo "7) ⏱️ Ataque basado en tiempo"
    echo "8) 🎯 Ataque específico personalizado"
    echo ""
    
    read -p "Selecciona tipo de ataque [1-8]: " attack_type
    
    case $attack_type in
        1) dictionary_attack ;;
        2) dictionary_rules_attack ;;
        3) mask_attack ;;
        4) combinator_attack ;;
        5) hybrid_attack ;;
        6) multi_mode_attack ;;
        7) time_based_attack ;;
        8) custom_attack ;;
        *) echo -e "${RED}❌ Opción inválida${NC}" ;;
    esac
}

# Dictionary attack simple
dictionary_attack() {
    echo -e "${CYAN}📖 DICTIONARY ATTACK${NC}"
    echo ""
    
    # Seleccionar archivo de hashes
    select_hash_file
    if [[ -z "$selected_hash_file" ]]; then
        return
    fi
    
    # Seleccionar wordlist
    select_wordlist
    if [[ -z "$selected_wordlist" ]]; then
        return
    fi
    
    # Seleccionar tipo de hash
    read -p "Tipo de hash (ej: 0 para MD5, 1000 para NTLM): " hash_mode
    
    SESSION_NAME="dict_$(date +%H%M%S)"
    
    echo -e "${YELLOW}🚀 Iniciando dictionary attack...${NC}"
    echo "Hash file: $selected_hash_file"
    echo "Wordlist: $selected_wordlist"
    echo "Hash mode: $hash_mode"
    echo "Sesión: $SESSION_NAME"
    echo ""
    
    # Ejecutar hashcat
    $HASHCAT_BIN -m "$hash_mode" \
                  -a 0 \
                  --session="$SESSION_NAME" \
                  --potfile-path="$POTFILE" \
                  --outfile="$WORKDIR/results/cracked_$SESSION_NAME.txt" \
                  --outfile-format=2 \
                  --status \
                  --status-timer=10 \
                  "$selected_hash_file" \
                  "$selected_wordlist" \
                  2>&1 | tee -a "$LOG_FILE"
    
    mostrar_resultados "$SESSION_NAME"
}

# Dictionary + Rules attack
dictionary_rules_attack() {
    echo -e "${CYAN}🔄 DICTIONARY + RULES ATTACK${NC}"
    echo ""
    
    # Seleccionar archivo de hashes
    select_hash_file
    if [[ -z "$selected_hash_file" ]]; then
        return
    fi
    
    # Seleccionar wordlist
    select_wordlist
    if [[ -z "$selected_wordlist" ]]; then
        return
    fi
    
    # Seleccionar reglas
    select_rules
    
    read -p "Tipo de hash: " hash_mode
    
    SESSION_NAME="rules_$(date +%H%M%S)"
    
    echo -e "${YELLOW}🚀 Iniciando rules attack...${NC}"
    
    if [[ -n "$selected_rules" ]]; then
        $HASHCAT_BIN -m "$hash_mode" \
                      -a 0 \
                      -r "$selected_rules" \
                      --session="$SESSION_NAME" \
                      --potfile-path="$POTFILE" \
                      --outfile="$WORKDIR/results/cracked_$SESSION_NAME.txt" \
                      --outfile-format=2 \
                      --status \
                      --status-timer=10 \
                      "$selected_hash_file" \
                      "$selected_wordlist" \
                      2>&1 | tee -a "$LOG_FILE"
    else
        # Usar reglas básicas integradas
        $HASHCAT_BIN -m "$hash_mode" \
                      -a 0 \
                      -r /usr/share/hashcat/rules/best64.rule \
                      --session="$SESSION_NAME" \
                      --potfile-path="$POTFILE" \
                      --outfile="$WORKDIR/results/cracked_$SESSION_NAME.txt" \
                      --outfile-format=2 \
                      --status \
                      --status-timer=10 \
                      "$selected_hash_file" \
                      "$selected_wordlist" \
                      2>&1 | tee -a "$LOG_FILE"
    fi
    
    mostrar_resultados "$SESSION_NAME"
}

# Mask attack
mask_attack() {
    echo -e "${CYAN}🎭 MASK ATTACK${NC}"
    echo ""
    
    select_hash_file
    if [[ -z "$selected_hash_file" ]]; then
        return
    fi
    
    echo "Patrones de máscara comunes:"
    echo "?l = lowercase (a-z)"
    echo "?u = uppercase (A-Z)"
    echo "?d = digits (0-9)"
    echo "?s = symbols (!@#$...)"
    echo "?a = all (?l?u?d?s)"
    echo ""
    echo "Ejemplos:"
    echo "?d?d?d?d?d?d     = 6 dígitos"
    echo "?l?l?l?l?d?d     = 4 letras + 2 dígitos"
    echo "Password?d?d     = Password + 2 dígitos"
    echo "?u?l?l?l?l?d?d?d = 1 mayús + 4 minus + 3 dígitos"
    echo ""
    
    read -p "Introduce máscara: " mask
    read -p "Tipo de hash: " hash_mode
    
    SESSION_NAME="mask_$(date +%H%M%S)"
    
    echo -e "${YELLOW}🚀 Iniciando mask attack...${NC}"
    echo "Máscara: $mask"
    
    $HASHCAT_BIN -m "$hash_mode" \
                  -a 3 \
                  --session="$SESSION_NAME" \
                  --potfile-path="$POTFILE" \
                  --outfile="$WORKDIR/results/cracked_$SESSION_NAME.txt" \
                  --outfile-format=2 \
                  --status \
                  --status-timer=10 \
                  "$selected_hash_file" \
                  "$mask" \
                  2>&1 | tee -a "$LOG_FILE"
    
    mostrar_resultados "$SESSION_NAME"
}

# Combinator attack
combinator_attack() {
    echo -e "${CYAN}🔀 COMBINATOR ATTACK${NC}"
    echo ""
    
    select_hash_file
    if [[ -z "$selected_hash_file" ]]; then
        return
    fi
    
    echo "Selecciona primera wordlist:"
    select_wordlist
    wordlist1="$selected_wordlist"
    
    echo ""
    echo "Selecciona segunda wordlist:"
    select_wordlist
    wordlist2="$selected_wordlist"
    
    read -p "Tipo de hash: " hash_mode
    
    SESSION_NAME="combo_$(date +%H%M%S)"
    
    echo -e "${YELLOW}🚀 Iniciando combinator attack...${NC}"
    echo "Wordlist 1: $wordlist1"
    echo "Wordlist 2: $wordlist2"
    
    $HASHCAT_BIN -m "$hash_mode" \
                  -a 1 \
                  --session="$SESSION_NAME" \
                  --potfile-path="$POTFILE" \
                  --outfile="$WORKDIR/results/cracked_$SESSION_NAME.txt" \
                  --outfile-format=2 \
                  --status \
                  --status-timer=10 \
                  "$selected_hash_file" \
                  "$wordlist1" \
                  "$wordlist2" \
                  2>&1 | tee -a "$LOG_FILE"
    
    mostrar_resultados "$SESSION_NAME"
}

# Hybrid attack
hybrid_attack() {
    echo -e "${CYAN}🎲 HYBRID ATTACK${NC}"
    echo ""
    
    select_hash_file
    if [[ -z "$selected_hash_file" ]]; then
        return
    fi
    
    select_wordlist
    if [[ -z "$selected_wordlist" ]]; then
        return
    fi
    
    echo ""
    echo "Modo híbrido:"
    echo "6) Wordlist + Mask (ej: password + ?d?d)"
    echo "7) Mask + Wordlist (ej: ?d?d + password)"
    read -p "Selecciona modo [6-7]: " hybrid_mode
    
    read -p "Introduce máscara: " mask
    read -p "Tipo de hash: " hash_mode
    
    SESSION_NAME="hybrid_$(date +%H%M%S)"
    
    echo -e "${YELLOW}🚀 Iniciando hybrid attack...${NC}"
    
    $HASHCAT_BIN -m "$hash_mode" \
                  -a "$hybrid_mode" \
                  --session="$SESSION_NAME" \
                  --potfile-path="$POTFILE" \
                  --outfile="$WORKDIR/results/cracked_$SESSION_NAME.txt" \
                  --outfile-format=2 \
                  --status \
                  --status-timer=10 \
                  "$selected_hash_file" \
                  "$selected_wordlist" \
                  "$mask" \
                  2>&1 | tee -a "$LOG_FILE"
    
    mostrar_resultados "$SESSION_NAME"
}

# Multi-mode attack
multi_mode_attack() {
    echo -e "${CYAN}🔥 MULTI-MODE ATTACK${NC}"
    echo ""
    echo "Ejecutará múltiples ataques en secuencia:"
    echo "1. Dictionary attack rápido"
    echo "2. Dictionary + reglas básicas"
    echo "3. Mask attack con patrones comunes"
    echo "4. Combinator con wordlists top"
    echo ""
    
    select_hash_file
    if [[ -z "$selected_hash_file" ]]; then
        return
    fi
    
    read -p "Tipo de hash: " hash_mode
    read -p "¿Continuar con multi-mode attack? (s/N): " confirm
    
    if [[ ! "$confirm" =~ ^[Ss]$ ]]; then
        return
    fi
    
    SESSION_NAME="multi_$(date +%H%M%S)"
    
    echo -e "${YELLOW}🚀 Iniciando MULTI-MODE ATTACK...${NC}"
    echo "Esto puede tardar mucho tiempo..."
    echo ""
    
    # Fase 1: Dictionary rápido
    echo -e "${CYAN}Phase 1: Quick dictionary${NC}"
    if [[ -f "$WORKDIR/wordlists/top1000.txt" ]]; then
        $HASHCAT_BIN -m "$hash_mode" -a 0 \
                      --session="${SESSION_NAME}_p1" \
                      --potfile-path="$POTFILE" \
                      --outfile="$WORKDIR/results/cracked_${SESSION_NAME}_p1.txt" \
                      --outfile-format=2 \
                      "$selected_hash_file" \
                      "$WORKDIR/wordlists/top1000.txt" \
                      2>&1 | tee -a "$LOG_FILE"
    fi
    
    # Fase 2: Dictionary + reglas
    echo -e "${CYAN}Phase 2: Dictionary + rules${NC}"
    if [[ -f "$WORKDIR/wordlists/rockyou.txt" ]]; then
        $HASHCAT_BIN -m "$hash_mode" -a 0 \
                      -r /usr/share/hashcat/rules/best64.rule \
                      --session="${SESSION_NAME}_p2" \
                      --potfile-path="$POTFILE" \
                      --outfile="$WORKDIR/results/cracked_${SESSION_NAME}_p2.txt" \
                      --outfile-format=2 \
                      "$selected_hash_file" \
                      "$WORKDIR/wordlists/rockyou.txt" \
                      2>&1 | tee -a "$LOG_FILE"
    fi
    
    # Fase 3: Máscaras comunes
    echo -e "${CYAN}Phase 3: Common masks${NC}"
    common_masks=(
        "?d?d?d?d?d?d"
        "?d?d?d?d?d?d?d?d"
        "?l?l?l?l?d?d"
        "?u?l?l?l?l?d?d"
        "password?d?d"
        "admin?d?d?d"
    )
    
    for mask in "${common_masks[@]}"; do
        echo "Probando máscara: $mask"
        $HASHCAT_BIN -m "$hash_mode" -a 3 \
                      --session="${SESSION_NAME}_m_${mask//\?/_}" \
                      --potfile-path="$POTFILE" \
                      --outfile="$WORKDIR/results/cracked_${SESSION_NAME}_m.txt" \
                      --outfile-format=2 \
                      "$selected_hash_file" \
                      "$mask" \
                      2>&1 | tee -a "$LOG_FILE"
    done
    
    mostrar_resultados "$SESSION_NAME"
}

# Ataque basado en tiempo
time_based_attack() {
    echo -e "${CYAN}⏱️ TIME-BASED ATTACK${NC}"
    echo ""
    
    select_hash_file
    if [[ -z "$selected_hash_file" ]]; then
        return
    fi
    
    read -p "Tiempo límite en segundos (ej: 3600 = 1 hora): " time_limit
    read -p "Tipo de hash: " hash_mode
    
    SESSION_NAME="time_$(date +%H%M%S)"
    
    echo -e "${YELLOW}🚀 Iniciando ataque con límite de tiempo: $time_limit segundos${NC}"
    
    # Usar wordlist más grande disponible
    biggest_wordlist=$(ls -la "$WORKDIR/wordlists"/*.txt | sort -k5 -nr | head -1 | awk '{print $NF}')
    
    timeout "$time_limit" $HASHCAT_BIN -m "$hash_mode" \
                                        -a 0 \
                                        --session="$SESSION_NAME" \
                                        --potfile-path="$POTFILE" \
                                        --outfile="$WORKDIR/results/cracked_$SESSION_NAME.txt" \
                                        --outfile-format=2 \
                                        --status \
                                        --status-timer=30 \
                                        "$selected_hash_file" \
                                        "$biggest_wordlist" \
                                        2>&1 | tee -a "$LOG_FILE"
    
    mostrar_resultados "$SESSION_NAME"
}

# Ataque personalizado
custom_attack() {
    echo -e "${CYAN}🎯 ATAQUE PERSONALIZADO${NC}"
    echo ""
    
    select_hash_file
    if [[ -z "$selected_hash_file" ]]; then
        return
    fi
    
    echo "Parámetros personalizados:"
    read -p "Tipo de hash (-m): " hash_mode
    read -p "Modo de ataque (-a): " attack_mode
    read -p "Parámetros adicionales: " extra_params
    
    case $attack_mode in
        0)
            select_wordlist
            wordlist_params="$selected_wordlist"
            ;;
        1)
            echo "Combinator - selecciona dos wordlists:"
            select_wordlist
            wordlist1="$selected_wordlist"
            select_wordlist
            wordlist2="$selected_wordlist"
            wordlist_params="$wordlist1 $wordlist2"
            ;;
        3)
            read -p "Máscara: " mask
            wordlist_params="$mask"
            ;;
        6|7)
            select_wordlist
            read -p "Máscara: " mask
            wordlist_params="$selected_wordlist $mask"
            ;;
        *)
            echo "Modo personalizado"
            read -p "Parámetros de wordlist/mask: " wordlist_params
            ;;
    esac
    
    SESSION_NAME="custom_$(date +%H%M%S)"
    
    echo -e "${YELLOW}🚀 Iniciando ataque personalizado...${NC}"
    
    eval "$HASHCAT_BIN -m $hash_mode \
                       -a $attack_mode \
                       $extra_params \
                       --session='$SESSION_NAME' \
                       --potfile-path='$POTFILE' \
                       --outfile='$WORKDIR/results/cracked_$SESSION_NAME.txt' \
                       --outfile-format=2 \
                       --status \
                       --status-timer=10 \
                       '$selected_hash_file' \
                       $wordlist_params" \
                       2>&1 | tee -a "$LOG_FILE"
    
    mostrar_resultados "$SESSION_NAME"
}

# Seleccionar archivo de hash
select_hash_file() {
    echo "Archivos de hash disponibles:"
    
    cd "$WORKDIR/hashes"
    hash_files=(*.txt)
    
    if [[ ${#hash_files[@]} -eq 0 ]] || [[ ! -f "${hash_files[0]}" ]]; then
        echo -e "${RED}❌ No hay archivos de hash disponibles${NC}"
        selected_hash_file=""
        return
    fi
    
    for i in "${!hash_files[@]}"; do
        lines=$(wc -l < "${hash_files[$i]}" 2>/dev/null || echo "?")
        echo "$((i+1))) ${hash_files[$i]} ($lines hashes)"
    done
    
    read -p "Selecciona archivo [1-${#hash_files[@]}]: " selection
    
    if [[ "$selection" =~ ^[0-9]+$ ]] && [[ $selection -ge 1 ]] && [[ $selection -le ${#hash_files[@]} ]]; then
        index=$((selection-1))
        selected_hash_file="$WORKDIR/hashes/${hash_files[$index]}"
        echo -e "${GREEN}✅ Seleccionado: ${hash_files[$index]}${NC}"
    else
        echo -e "${RED}❌ Selección inválida${NC}"
        selected_hash_file=""
    fi
    
    cd - >/dev/null
}

# Seleccionar wordlist
select_wordlist() {
    echo "Wordlists disponibles:"
    
    cd "$WORKDIR/wordlists"
    wordlist_files=(*.txt)
    
    if [[ ${#wordlist_files[@]} -eq 0 ]] || [[ ! -f "${wordlist_files[0]}" ]]; then
        echo -e "${RED}❌ No hay wordlists disponibles${NC}"
        selected_wordlist=""
        return
    fi
    
    for i in "${!wordlist_files[@]}"; do
        lines=$(wc -l < "${wordlist_files[$i]}" 2>/dev/null || echo "?")
        size=$(du -h "${wordlist_files[$i]}" 2>/dev/null | cut -f1 || echo "?")
        echo "$((i+1))) ${wordlist_files[$i]} ($lines líneas, $size)"
    done
    
    read -p "Selecciona wordlist [1-${#wordlist_files[@]}]: " selection
    
    if [[ "$selection" =~ ^[0-9]+$ ]] && [[ $selection -ge 1 ]] && [[ $selection -le ${#wordlist_files[@]} ]]; then
        index=$((selection-1))
        selected_wordlist="$WORKDIR/wordlists/${wordlist_files[$index]}"
        echo -e "${GREEN}✅ Seleccionado: ${wordlist_files[$index]}${NC}"
    else
        echo -e "${RED}❌ Selección inválida${NC}"
        selected_wordlist=""
    fi
    
    cd - >/dev/null
}

# Seleccionar reglas
select_rules() {
    echo "Archivos de reglas disponibles:"
    
    # Buscar reglas del sistema
    rule_paths=(
        "/usr/share/hashcat/rules"
        "/opt/hashcat/rules"
        "$WORKDIR/rules"
    )
    
    found_rules=()
    
    for rule_path in "${rule_paths[@]}"; do
        if [[ -d "$rule_path" ]]; then
            while IFS= read -r -d '' rule_file; do
                found_rules+=("$rule_file")
            done < <(find "$rule_path" -name "*.rule" -type f -print0 2>/dev/null)
        fi
    done
    
    if [[ ${#found_rules[@]} -eq 0 ]]; then
        echo -e "${YELLOW}⚠️ No se encontraron archivos de reglas${NC}"
        echo "Usando reglas básicas predeterminadas"
        selected_rules=""
        return
    fi
    
    echo "0) Usar reglas básicas predeterminadas"
    for i in "${!found_rules[@]}"; do
        rule_name=$(basename "${found_rules[$i]}")
        echo "$((i+1))) $rule_name"
    done
    
    read -p "Selecciona reglas [0-${#found_rules[@]}]: " selection
    
    if [[ "$selection" == "0" ]]; then
        selected_rules=""
    elif [[ "$selection" =~ ^[0-9]+$ ]] && [[ $selection -ge 1 ]] && [[ $selection -le ${#found_rules[@]} ]]; then
        index=$((selection-1))
        selected_rules="${found_rules[$index]}"
        echo -e "${GREEN}✅ Seleccionado: $(basename "$selected_rules")${NC}"
    else
        echo -e "${RED}❌ Selección inválida${NC}"
        selected_rules=""
    fi
}

# Mostrar resultados
mostrar_resultados() {
    local session_name="$1"
    
    echo ""
    echo -e "${GREEN}🎉 RESULTADOS DEL ATAQUE${NC}"
    echo "=========================="
    
    # Mostrar contraseñas crackeadas del potfile
    if [[ -f "$POTFILE" ]]; then
        echo -e "${CYAN}💎 Contraseñas en potfile:${NC}"
        cat "$POTFILE" | while IFS=':' read -r hash password; do
            echo "Hash: $hash"
            echo "Password: $password"
            echo "---"
        done
        echo ""
    fi
    
    # Mostrar archivos de resultados
    if ls "$WORKDIR/results/cracked_${session_name}"*.txt >/dev/null 2>&1; then
        echo -e "${CYAN}📄 Archivos de resultados:${NC}"
        for result_file in "$WORKDIR/results/cracked_${session_name}"*.txt; do
            if [[ -f "$result_file" ]]; then
                lines=$(wc -l < "$result_file" 2>/dev/null || echo "0")
                echo "📁 $(basename "$result_file") ($lines crackeadas)"
                
                if [[ $lines -gt 0 ]]; then
                    echo "Contenido:"
                    cat "$result_file"
                    echo ""
                fi
            fi
        done
    fi
    
    # Mostrar estadísticas del log
    if [[ -f "$LOG_FILE" ]]; then
        echo -e "${CYAN}📊 Estadísticas del ataque:${NC}"
        echo "Log: $LOG_FILE"
        
        # Extraer información útil del log
        grep -i "recovered\|status\|speed\|temperature" "$LOG_FILE" | tail -10 || echo "Sin estadísticas disponibles"
    fi
    
    echo ""
    echo -e "${GREEN}✅ Análisis completo${NC}"
}

# Gestión de sesiones
gestionar_sesiones() {
    echo -e "${PURPLE}💾 GESTIÓN DE SESIONES HASHCAT${NC}"
    echo ""
    echo "Opciones:"
    echo "1) Listar sesiones activas"
    echo "2) Restaurar sesión interrumpida"
    echo "3) Eliminar sesión"
    echo "4) Limpiar todas las sesiones"
    echo "5) Ver información de sesión"
    echo "6) Volver al menú principal"
    echo ""
    
    read -p "Selecciona opción [1-6]: " opcion
    
    case $opcion in
        1)
            listar_sesiones
            ;;
        2)
            restaurar_sesion
            ;;
        3)
            eliminar_sesion
            ;;
        4)
            limpiar_sesiones
            ;;
        5)
            info_sesion
            ;;
        6)
            return
            ;;
        *)
            echo -e "${RED}❌ Opción inválida${NC}"
            ;;
    esac
    
    echo ""
    read -p "Presiona Enter para continuar..."
}

# Listar sesiones
listar_sesiones() {
    echo -e "${CYAN}📋 SESIONES HASHCAT${NC}"
    echo ""
    
    # Buscar archivos de sesión
    session_files=(~/.hashcat/sessions/*.session 2>/dev/null)
    
    if [[ ${#session_files[@]} -eq 0 ]] || [[ ! -f "${session_files[0]}" ]]; then
        echo "No hay sesiones guardadas"
        return
    fi
    
    echo "Sesiones encontradas:"
    for session_file in "${session_files[@]}"; do
        if [[ -f "$session_file" ]]; then
            session_name=$(basename "$session_file" .session)
            modified=$(stat -c %y "$session_file" 2>/dev/null | cut -d' ' -f1,2)
            echo "📄 $session_name ($modified)"
        fi
    done
}

# Restaurar sesión
restaurar_sesion() {
    echo -e "${CYAN}🔄 RESTAURAR SESIÓN${NC}"
    echo ""
    
    # Listar sesiones disponibles
    listar_sesiones
    echo ""
    
    read -p "Nombre de la sesión a restaurar: " session_name
    
    if [[ -f ~/.hashcat/sessions/"$session_name".session ]]; then
        echo -e "${YELLOW}🔄 Restaurando sesión $session_name...${NC}"
        $HASHCAT_BIN --session="$session_name" --restore
    else
        echo -e "${RED}❌ Sesión no encontrada${NC}"
    fi
}

# Análisis y reportes
generar_reporte() {
    echo -e "${PURPLE}📊 GENERAR REPORTE${NC}"
    echo ""
    
    report_file="$WORKDIR/hashcat_report_$(date +%Y%m%d_%H%M%S).html"
    
    echo -e "${YELLOW}📝 Generando reporte HTML...${NC}"
    
    cat > "$report_file" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Hashcat Ultimate - Reporte de Cracking</title>
    <meta charset="UTF-8">
    <style>
        body { font-family: 'Courier New', monospace; background: #1e1e1e; color: #00ff00; margin: 20px; }
        .header { text-align: center; border: 2px solid #00ff00; padding: 20px; margin-bottom: 20px; }
        .section { border: 1px solid #444; padding: 15px; margin: 10px 0; background: #2d2d2d; }
        .success { color: #00ff00; }
        .warning { color: #ffff00; }
        .error { color: #ff0000; }
        .info { color: #00ffff; }
        table { width: 100%; border-collapse: collapse; margin: 10px 0; }
        th, td { border: 1px solid #444; padding: 8px; text-align: left; }
        th { background: #333; }
        pre { background: #111; padding: 10px; overflow-x: auto; border: 1px solid #444; }
    </style>
</head>
<body>
    <div class="header">
        <h1>⚡ HASHCAT ULTIMATE CRACKER</h1>
        <h2>📊 Reporte de Análisis de Contraseñas</h2>
        <p>Generado: $(date)</p>
        <p>Directorio: $WORKDIR</p>
    </div>

    <div class="section">
        <h3>🎯 RESUMEN EJECUTIVO</h3>
        <table>
            <tr><th>Métrica</th><th>Valor</th></tr>
            <tr><td>Hashes procesados</td><td>$(find "$WORKDIR/hashes" -name "*.txt" -exec cat {} \; 2>/dev/null | wc -l)</td></tr>
            <tr><td>Wordlists utilizadas</td><td>$(ls "$WORKDIR/wordlists"/*.txt 2>/dev/null | wc -l)</td></tr>
            <tr><td>Contraseñas crackeadas</td><td>$(wc -l < "$POTFILE" 2>/dev/null || echo "0")</td></tr>
            <tr><td>Archivos de resultados</td><td>$(ls "$WORKDIR/results"/*.txt 2>/dev/null | wc -l)</td></tr>
        </table>
    </div>

    <div class="section">
        <h3>💎 CONTRASEÑAS CRACKEADAS</h3>
        <pre>$(cat "$POTFILE" 2>/dev/null || echo "No hay contraseñas crackeadas aún")</pre>
    </div>

    <div class="section">
        <h3>📁 ARCHIVOS DE HASH ANALIZADOS</h3>
        <table>
            <tr><th>Archivo</th><th>Hashes</th><th>Tamaño</th></tr>
EOF

    # Agregar información de archivos de hash
    if ls "$WORKDIR/hashes"/*.txt >/dev/null 2>&1; then
        for hash_file in "$WORKDIR/hashes"/*.txt; do
            lines=$(wc -l < "$hash_file" 2>/dev/null || echo "0")
            size=$(du -h "$hash_file" 2>/dev/null | cut -f1 || echo "0")
            echo "            <tr><td>$(basename "$hash_file")</td><td>$lines</td><td>$size</td></tr>" >> "$report_file"
        done
    fi

    cat >> "$report_file" << EOF
        </table>
    </div>

    <div class="section">
        <h3>📚 WORDLISTS UTILIZADAS</h3>
        <table>
            <tr><th>Wordlist</th><th>Líneas</th><th>Tamaño</th></tr>
EOF

    # Agregar información de wordlists
    if ls "$WORKDIR/wordlists"/*.txt >/dev/null 2>&1; then
        for wordlist in "$WORKDIR/wordlists"/*.txt; do
            lines=$(wc -l < "$wordlist" 2>/dev/null || echo "0")
            size=$(du -h "$wordlist" 2>/dev/null | cut -f1 || echo "0")
            echo "            <tr><td>$(basename "$wordlist")</td><td>$lines</td><td>$size</td></tr>" >> "$report_file"
        done
    fi

    cat >> "$report_file" << EOF
        </table>
    </div>

    <div class="section">
        <h3>🔄 ATAQUES EJECUTADOS</h3>
        <pre>$(find "$WORKDIR/results" -name "*.txt" -exec basename {} \; 2>/dev/null | sed 's/cracked_//g' | sed 's/.txt//g' | sort | uniq || echo "Sin ataques registrados")</pre>
    </div>

    <div class="section">
        <h3>📋 LOG DE ACTIVIDAD</h3>
        <pre>$(tail -50 "$LOG_FILE" 2>/dev/null || echo "Sin log disponible")</pre>
    </div>

    <div class="section">
        <h3>⚙️ CONFIGURACIÓN DEL SISTEMA</h3>
        <pre>
Hashcat: $HASHCAT_BIN
GPU: $(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -1 || echo "No detectada")
CPU: $(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)
RAM: $(free -h | grep "Mem:" | awk '{print $2}')
Sistema: $(uname -a)
        </pre>
    </div>

    <div class="section">
        <h3>🏆 RECOMENDACIONES</h3>
        <ul>
EOF

    # Agregar recomendaciones basadas en resultados
    cracked_count=$(wc -l < "$POTFILE" 2>/dev/null || echo "0")
    if [[ $cracked_count -eq 0 ]]; then
        echo "            <li class=\"warning\">⚠️ No se crackearon contraseñas. Considera usar wordlists más grandes o ataques de fuerza bruta.</li>" >> "$report_file"
        echo "            <li class=\"info\">💡 Prueba ataques híbridos o reglas más agresivas.</li>" >> "$report_file"
    else
        echo "            <li class=\"success\">✅ Se crackearon $cracked_count contraseñas exitosamente.</li>" >> "$report_file"
        echo "            <li class=\"info\">💡 Analiza los patrones de las contraseñas crackeadas para futuros ataques.</li>" >> "$report_file"
    fi

    cat >> "$report_file" << EOF
            <li class="info">🔧 Considera optimizar la configuración de GPU para mejor rendimiento.</li>
            <li class="info">📚 Mantén actualizadas las wordlists con nuevos leaks.</li>
            <li class="warning">⚖️ Asegúrate de tener autorización antes de usar estas herramientas.</li>
        </ul>
    </div>

    <div class="section">
        <h3>🔗 ARCHIVOS GENERADOS</h3>
        <ul>
            <li>📁 Directorio principal: <code>$WORKDIR</code></li>
            <li>🗃️ Potfile: <code>$POTFILE</code></li>
            <li>📜 Log: <code>$LOG_FILE</code></li>
            <li>📊 Reporte: <code>$report_file</code></li>
        </ul>
    </div>
</body>
</html>
EOF

    echo -e "${GREEN}✅ Reporte generado: $report_file${NC}"
    echo -e "${CYAN}📂 Abre el archivo en un navegador para ver el reporte completo${NC}"
}

# Menú principal
mostrar_menu() {
    clear
    echo "
██╗  ██╗ █████╗ ███████╗██╗  ██╗ ██████╗ █████╗ ████████╗
██║  ██║██╔══██╗██╔════╝██║  ██║██╔════╝██╔══██╗╚══██╔══╝
███████║███████║███████╗███████║██║     ███████║   ██║   
██╔══██║██╔══██║╚════██║██╔══██║██║     ██╔══██║   ██║   
██║  ██║██║  ██║███████║██║  ██║╚██████╗██║  ██║   ██║   
╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝   ╚═╝   
                                                         
⚡ ULTIMATE CRACKER - TODAS LAS MODALIDADES HASHCAT ⚡
"

    echo -e "${PURPLE}════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}🎯 MENÚ PRINCIPAL${NC}"
    echo -e "${PURPLE}════════════════════════════════════════════════${NC}"
    echo ""
    echo "1) 🔍 Identificar tipo de hash"
    echo "2) 📚 Gestionar wordlists"
    echo "3) ⚔️ Configurar ataque"
    echo "4) 💾 Gestionar sesiones"
    echo "5) 📊 Generar reporte"
    echo "6) 🔧 Ver configuración"
    echo "7) 🧹 Limpiar archivos temporales"
    echo "8) ❌ Salir"
    echo ""
    echo -e "${YELLOW}Directorio actual: $WORKDIR${NC}"
    echo -e "${GREEN}Potfile: $(wc -l < "$POTFILE" 2>/dev/null || echo "0") contraseñas crackeadas${NC}"
    echo ""
}

# Función principal
main() {
    echo -e "${BLUE}🔧 Inicializando Hashcat Ultimate Cracker...${NC}"
    
    verificar_herramientas
    configurar_directorio
    
    while true; do
        mostrar_menu
        read -p "Selecciona opción [1-8]: " opcion
        
        case $opcion in
            1)
                identificar_hash
                ;;
            2)
                gestionar_wordlists
                ;;
            3)
                configurar_ataque
                ;;
            4)
                gestionar_sesiones
                ;;
            5)
                generar_reporte
                ;;
            6)
                echo -e "${CYAN}⚙️ CONFIGURACIÓN ACTUAL${NC}"
                echo "Hashcat: $HASHCAT_BIN"
                echo "Directorio: $WORKDIR"
                echo "Potfile: $POTFILE"
                echo "GPU: $(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -1 || echo "No detectada")"
                read -p "Presiona Enter para continuar..."
                ;;
            7)
                echo -e "${YELLOW}🧹 Limpiando archivos temporales...${NC}"
                find "$WORKDIR" -name "*.tmp" -delete 2>/dev/null || true
                echo -e "${GREEN}✅ Limpieza completada${NC}"
                read -p "Presiona Enter para continuar..."
                ;;
            8)
                echo -e "${GREEN}👋 ¡Hasta luego!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}❌ Opción inválida${NC}"
                read -p "Presiona Enter para continuar..."
                ;;
        esac
    done
}

# Verificar permisos
if [[ $EUID -eq 0 ]]; then
    echo -e "${YELLOW}⚠️ Ejecutándose como root${NC}"
fi

# Ejecutar función principal
main "$@"