#!/bin/bash

# 🔍 GOBUSTER ULTIMATE SCANNER
# Búsqueda de directorios, subdominios, DNS y más con máxima personalización

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Variables globales
TARGET=""
SCAN_MODE=""
WORDLIST=""
EXTENSIONS=""
THREADS=""
TIMEOUT=""
OUTPUT_OPTIONS=""
STATUS_CODES=""
ADVANCED_OPTIONS=""
USER_AGENT=""
HEADERS=""

print_banner() {
    clear
    echo -e "${BLUE}"
    echo " ██████╗  ██████╗ ██████╗ ██╗   ██╗███████╗████████╗███████╗██████╗     ██╗   ██╗██╗  ████████╗██╗███╗   ███╗ █████╗ ████████╗███████╗"
    echo "██╔════╝ ██╔═══██╗██╔══██╗██║   ██║██╔════╝╚══██╔══╝██╔════╝██╔══██╗    ██║   ██║██║  ╚══██╔══╝██║████╗ ████║██╔══██╗╚══██╔══╝██╔════╝"
    echo "██║  ███╗██║   ██║██████╔╝██║   ██║███████╗   ██║   █████╗  ██████╔╝    ██║   ██║██║     ██║   ██║██╔████╔██║███████║   ██║   █████╗  "
    echo "██║   ██║██║   ██║██╔══██╗██║   ██║╚════██║   ██║   ██╔══╝  ██╔══██╗    ██║   ██║██║     ██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██╔══╝  "
    echo "╚██████╔╝╚██████╔╝██████╔╝╚██████╔╝███████║   ██║   ███████╗██║  ██║    ╚██████╔╝███████╗██║   ██║██║ ╚═╝ ██║██║  ██║   ██║   ███████╗"
    echo " ╚═════╝  ╚═════╝ ╚═════╝  ╚═════╝ ╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝     ╚═════╝ ╚══════╝╚═╝   ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚══════╝"
    echo -e "${NC}"
    echo -e "${CYAN}🔍 Gobuster Ultimate - Descubrimiento de Contenido Avanzado${NC}"
    echo -e "${YELLOW}⚠️  Solo usar en dominios propios o con autorización${NC}"
    echo ""
}

select_scan_mode() {
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}            ${YELLOW}MODO DE ESCANEO${NC}               ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    echo -e "${YELLOW}¿Qué tipo de escaneo quieres?${NC}"
    echo -e "  ${CYAN}1.${NC} 📁 Directorios/Archivos ${PURPLE}[dir]${NC}"
    echo -e "  ${CYAN}2.${NC} 🌐 Subdominios ${PURPLE}[dns]${NC}"
    echo -e "  ${CYAN}3.${NC} 🔍 Virtual Hosts ${PURPLE}[vhost]${NC}"
    echo -e "  ${CYAN}4.${NC} 🔑 S3 Buckets ${PURPLE}[s3]${NC}"
    echo -e "  ${CYAN}5.${NC} 🎯 Fuzzing de parámetros ${PURPLE}[fuzz]${NC}"
    echo -e "  ${CYAN}6.${NC} 🌍 Múltiples modos combinados"
    echo ""
    
    read -p "Selecciona modo (1-6): " mode_choice
    
    case $mode_choice in
        1)
            SCAN_MODE="dir"
            echo -e "${GREEN}✅ Modo: Directorios/Archivos${NC}"
            ;;
        2)
            SCAN_MODE="dns"
            echo -e "${GREEN}✅ Modo: Subdominios${NC}"
            ;;
        3)
            SCAN_MODE="vhost"
            echo -e "${GREEN}✅ Modo: Virtual Hosts${NC}"
            ;;
        4)
            SCAN_MODE="s3"
            echo -e "${GREEN}✅ Modo: S3 Buckets${NC}"
            ;;
        5)
            SCAN_MODE="fuzz"
            echo -e "${GREEN}✅ Modo: Fuzzing${NC}"
            ;;
        6)
            echo -e "${CYAN}💡 Ejecutará múltiples modos secuencialmente${NC}"
            SCAN_MODE="multi"
            echo -e "${GREEN}✅ Modo: Múltiple${NC}"
            ;;
        *)
            echo -e "${YELLOW}Usando modo directorio por defecto${NC}"
            SCAN_MODE="dir"
            ;;
    esac
}

select_target() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}            ${YELLOW}OBJETIVO DE ESCANEO${NC}            ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    case $SCAN_MODE in
        "dir"|"fuzz")
            echo -e "${YELLOW}Ingresa la URL objetivo:${NC}"
            echo -e "${CYAN}💡 Ejemplos:${NC}"
            echo -e "  • https://example.com"
            echo -e "  • http://192.168.1.100"
            echo -e "  • https://target.com/api"
            read -p "🎯 URL: " TARGET
            ;;
        "dns"|"vhost")
            echo -e "${YELLOW}Ingresa el dominio objetivo:${NC}"
            echo -e "${CYAN}💡 Ejemplos:${NC}"
            echo -e "  • example.com"
            echo -e "  • target.org"
            echo -e "  • company.net"
            read -p "🎯 Dominio: " TARGET
            ;;
        "s3")
            echo -e "${YELLOW}Ingresa palabras clave para S3:${NC}"
            echo -e "${CYAN}💡 Ejemplos:${NC}"
            echo -e "  • company"
            echo -e "  • project-name"
            echo -e "  • app-backups"
            read -p "🎯 Keywords: " TARGET
            ;;
        "multi")
            echo -e "${YELLOW}Ingresa el objetivo principal:${NC}"
            echo -e "${CYAN}💡 Formato: dominio.com (sin http)${NC}"
            read -p "🎯 Dominio base: " TARGET
            ;;
    esac
    
    if [[ -z "$TARGET" ]]; then
        echo -e "${RED}❌ Objetivo requerido${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✅ Objetivo: $TARGET${NC}"
}

select_wordlist() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}           ${YELLOW}SELECCIÓN WORDLIST${NC}             ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    echo -e "${YELLOW}Wordlists disponibles:${NC}"
    
    case $SCAN_MODE in
        "dir"|"fuzz")
            echo -e "  ${CYAN}1.${NC} DirBuster small (87K) ${PURPLE}[rápido]${NC}"
            echo -e "  ${CYAN}2.${NC} DirBuster medium (220K) ${PURPLE}[balance]${NC}"
            echo -e "  ${CYAN}3.${NC} DirBuster large (1M) ${PURPLE}[completo]${NC}"
            echo -e "  ${CYAN}4.${NC} SecLists common (4K) ${PURPLE}[básico]${NC}"
            echo -e "  ${CYAN}5.${NC} SecLists big (20K) ${PURPLE}[amplio]${NC}"
            echo -e "  ${CYAN}6.${NC} Web discovery (10K) ${PURPLE}[especializado]${NC}"
            echo -e "  ${CYAN}7.${NC} API endpoints (5K) ${PURPLE}[APIs]${NC}"
            echo -e "  ${CYAN}8.${NC} Raft large (63K) ${PURPLE}[raft]${NC}"
            echo -e "  ${CYAN}9.${NC} Custom wordlist"
            ;;
        "dns"|"vhost")
            echo -e "  ${CYAN}1.${NC} Subdomain top (1K) ${PURPLE}[básico]${NC}"
            echo -e "  ${CYAN}2.${NC} Subdomain common (5K) ${PURPLE}[común]${NC}"
            echo -e "  ${CYAN}3.${NC} Subdomain big (102K) ${PURPLE}[completo]${NC}"
            echo -e "  ${CYAN}4.${NC} DNS all (384K) ${PURPLE}[exhaustivo]${NC}"
            echo -e "  ${CYAN}5.${NC} Fierce subdomain (2K) ${PURPLE}[fierce]${NC}"
            echo -e "  ${CYAN}6.${NC} Custom subdomain list"
            ;;
        "s3")
            echo -e "  ${CYAN}1.${NC} S3 bucket names (1K) ${PURPLE}[común]${NC}"
            echo -e "  ${CYAN}2.${NC} S3 comprehensive (10K) ${PURPLE}[amplio]${NC}"
            echo -e "  ${CYAN}3.${NC} Custom S3 list"
            ;;
    esac
    echo ""
    
    read -p "Selecciona wordlist: " wordlist_choice
    
    case $SCAN_MODE in
        "dir"|"fuzz")
            case $wordlist_choice in
                1) WORDLIST="/usr/share/dirb/wordlists/small.txt" ;;
                2) WORDLIST="/usr/share/dirb/wordlists/common.txt" ;;
                3) WORDLIST="/usr/share/dirb/wordlists/big.txt" ;;
                4) WORDLIST="/usr/share/seclists/Discovery/Web-Content/common.txt" ;;
                5) WORDLIST="/usr/share/seclists/Discovery/Web-Content/big.txt" ;;
                6) WORDLIST="/usr/share/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt" ;;
                7) WORDLIST="/usr/share/seclists/Discovery/Web-Content/api/api-endpoints.txt" ;;
                8) WORDLIST="/usr/share/seclists/Discovery/Web-Content/raft-large-directories.txt" ;;
                9)
                    read -p "🎯 Ruta del wordlist personalizado: " WORDLIST
                    ;;
                *)
                    WORDLIST="/usr/share/dirb/wordlists/common.txt"
                    ;;
            esac
            ;;
        "dns"|"vhost")
            case $wordlist_choice in
                1) WORDLIST="/usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt" ;;
                2) WORDLIST="/usr/share/seclists/Discovery/DNS/subdomain.txt" ;;
                3) WORDLIST="/usr/share/seclists/Discovery/DNS/subdomains-top1million-110000.txt" ;;
                4) WORDLIST="/usr/share/seclists/Discovery/DNS/dns-Jhaddix.txt" ;;
                5) WORDLIST="/usr/share/seclists/Discovery/DNS/fierce-subdomain.txt" ;;
                6)
                    read -p "🎯 Ruta del wordlist de subdominios: " WORDLIST
                    ;;
                *)
                    WORDLIST="/usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt"
                    ;;
            esac
            ;;
        "s3")
            case $wordlist_choice in
                1) WORDLIST="/usr/share/seclists/Discovery/Web-Content/s3-buckets.txt" ;;
                2) WORDLIST="/usr/share/seclists/Miscellaneous/wordlist-common.txt" ;;
                3)
                    read -p "🎯 Ruta del wordlist S3: " WORDLIST
                    ;;
                *)
                    WORDLIST="/usr/share/seclists/Discovery/Web-Content/s3-buckets.txt"
                    ;;
            esac
            ;;
    esac
    
    # Verificar si el wordlist existe
    if [[ ! -f "$WORDLIST" ]]; then
        echo -e "${RED}❌ Wordlist no encontrado: $WORDLIST${NC}"
        echo -e "${YELLOW}💡 Creando wordlist básico...${NC}"
        
        # Crear wordlist básico
        cat > "/tmp/basic_wordlist.txt" << EOF
admin
api
test
dev
staging
backup
private
public
uploads
downloads
images
css
js
login
config
database
docs
help
support
blog
news
contact
about
services
products
search
index
home
dashboard
panel
control
manage
ajax
json
xml
rss
sitemap EOF
        WORDLIST="/tmp/basic_wordlist.txt"
        echo -e "${GREEN}✅ Wordlist básico creado${NC}"
    fi
    
    echo -e "${GREEN}✅ Wordlist: $WORDLIST${NC}"
}

select_extensions() {
    if [[ "$SCAN_MODE" == "dir" || "$SCAN_MODE" == "fuzz" ]]; then
        echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║${NC}           ${YELLOW}EXTENSIONES DE ARCHIVO${NC}          ${BLUE}║${NC}"
        echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
        
        echo -e "${YELLOW}¿Qué extensiones buscar?${NC}"
        echo -e "  ${CYAN}1.${NC} Sin extensiones ${PURPLE}[solo directorios]${NC}"
        echo -e "  ${CYAN}2.${NC} Web básico ${PURPLE}[php,html,htm]${NC}"
        echo -e "  ${CYAN}3.${NC} Web completo ${PURPLE}[php,html,htm,asp,aspx,jsp]${NC}"
        echo -e "  ${CYAN}4.${NC} Scripts ${PURPLE}[php,py,pl,sh,rb]${NC}"
        echo -e "  ${CYAN}5.${NC} Documentos ${PURPLE}[txt,pdf,doc,docx,xls,xlsx]${NC}"
        echo -e "  ${CYAN}6.${NC} Backups ${PURPLE}[bak,backup,old,orig,tmp]${NC}"
        echo -e "  ${CYAN}7.${NC} Configuración ${PURPLE}[conf,config,cfg,ini,xml]${NC}"
        echo -e "  ${CYAN}8.${NC} MEGA combo ${PURPLE}[todas las anteriores]${NC}"
        echo -e "  ${CYAN}9.${NC} Personalizado"
        echo ""
        
        read -p "Selecciona extensiones: " ext_choice
        
        case $ext_choice in
            1) EXTENSIONS="" ;;
            2) EXTENSIONS="-x php,html,htm" ;;
            3) EXTENSIONS="-x php,html,htm,asp,aspx,jsp" ;;
            4) EXTENSIONS="-x php,py,pl,sh,rb,cgi" ;;
            5) EXTENSIONS="-x txt,pdf,doc,docx,xls,xlsx" ;;
            6) EXTENSIONS="-x bak,backup,old,orig,tmp,swp" ;;
            7) EXTENSIONS="-x conf,config,cfg,ini,xml,yml,yaml" ;;
            8) EXTENSIONS="-x php,html,htm,asp,aspx,jsp,py,pl,sh,rb,txt,pdf,bak,backup,old,conf,config,cfg,ini,xml" ;;
            9)
                echo -e "${CYAN}💡 Formato: ext1,ext2,ext3 (sin puntos)${NC}"
                read -p "🎯 Extensiones personalizadas: " custom_ext
                EXTENSIONS="-x $custom_ext"
                ;;
            *)
                EXTENSIONS=""
                ;;
        esac
        
        echo -e "${GREEN}✅ Extensiones: ${EXTENSIONS:-ninguna}${NC}"
    fi
}

select_performance() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}           ${YELLOW}CONFIGURACIÓN PERFORMANCE${NC}       ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    echo -e "${YELLOW}Configuración de rendimiento:${NC}"
    echo -e "  ${CYAN}1.${NC} Conservador ${PURPLE}[10 threads, 30s timeout]${NC}"
    echo -e "  ${CYAN}2.${NC} Normal ${PURPLE}[25 threads, 20s timeout]${NC}"
    echo -e "  ${CYAN}3.${NC} Agresivo ${PURPLE}[50 threads, 10s timeout]${NC}"
    echo -e "  ${CYAN}4.${NC} Muy agresivo ${PURPLE}[100 threads, 5s timeout]${NC}"
    echo -e "  ${CYAN}5.${NC} Insano ${PURPLE}[200 threads, 3s timeout]${NC}"
    echo -e "  ${CYAN}6.${NC} Personalizado"
    echo ""
    
    read -p "Selecciona rendimiento: " perf_choice
    
    case $perf_choice in
        1)
            THREADS="-t 10"
            TIMEOUT="--timeout 30s"
            ;;
        2)
            THREADS="-t 25"
            TIMEOUT="--timeout 20s"
            ;;
        3)
            THREADS="-t 50"
            TIMEOUT="--timeout 10s"
            ;;
        4)
            THREADS="-t 100"
            TIMEOUT="--timeout 5s"
            ;;
        5)
            THREADS="-t 200"
            TIMEOUT="--timeout 3s"
            echo -e "${RED}⚠️ Configuración insana - puede saturar el servidor${NC}"
            ;;
        6)
            read -p "🎯 Número de threads (1-300): " thread_count
            read -p "🎯 Timeout en segundos: " timeout_val
            THREADS="-t ${thread_count:-25}"
            TIMEOUT="--timeout ${timeout_val:-10}s"
            ;;
        *)
            THREADS="-t 25"
            TIMEOUT="--timeout 10s"
            ;;
    esac
    
    echo -e "${GREEN}✅ Threads: $THREADS, Timeout: $TIMEOUT${NC}"
}

select_status_codes() {
    if [[ "$SCAN_MODE" == "dir" || "$SCAN_MODE" == "fuzz" ]]; then
        echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║${NC}           ${YELLOW}CÓDIGOS DE ESTADO HTTP${NC}          ${BLUE}║${NC}"
        echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
        
        echo -e "${YELLOW}¿Qué códigos mostrar?${NC}"
        echo -e "  ${CYAN}1.${NC} Solo 200 ${PURPLE}[exitosos]${NC}"
        echo -e "  ${CYAN}2.${NC} 200,301,302 ${PURPLE}[éxito + redirecciones]${NC}"
        echo -e "  ${CYAN}3.${NC} 200,204,301,302,307,403 ${PURPLE}[amplio]${NC}"
        echo -e "  ${CYAN}4.${NC} Todos menos 404 ${PURPLE}[excluir no encontrado]${NC}"
        echo -e "  ${CYAN}5.${NC} Solo errores 4xx,5xx ${PURPLE}[errores]${NC}"
        echo -e "  ${CYAN}6.${NC} Personalizado"
        echo ""
        
        read -p "Selecciona códigos: " status_choice
        
        case $status_choice in
            1) STATUS_CODES="-s 200" ;;
            2) STATUS_CODES="-s 200,301,302" ;;
            3) STATUS_CODES="-s 200,204,301,302,307,403" ;;
            4) STATUS_CODES="-b 404" ;;  # blacklist
            5) STATUS_CODES="-s 400,401,403,500,501,502,503" ;;
            6)
                echo -e "${YELLOW}Opciones:${NC}"
                echo -e "  ${CYAN}-s${NC} códigos: incluir solo estos"
                echo -e "  ${CYAN}-b${NC} códigos: excluir estos"
                read -p "🎯 Configuración (ej: -s 200,301 o -b 404,403): " STATUS_CODES
                ;;
            *)
                STATUS_CODES="-s 200,204,301,302,307,401,403"
                ;;
        esac
        
        echo -e "${GREEN}✅ Códigos de estado: $STATUS_CODES${NC}"
    fi
}

select_output_options() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}           ${YELLOW}OPCIONES DE SALIDA${NC}             ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    echo -e "${YELLOW}Configuración de salida:${NC}"
    echo -e "  ${CYAN}1.${NC} Solo pantalla ${PURPLE}[por defecto]${NC}"
    echo -e "  ${CYAN}2.${NC} Archivo de texto ${PURPLE}[-o archivo.txt]${NC}"
    echo -e "  ${CYAN}3.${NC} Progreso detallado ${PURPLE}[-v]${NC}"
    echo -e "  ${CYAN}4.${NC} Sin colores ${PURPLE}[--no-color]${NC}"
    echo -e "  ${CYAN}5.${NC} Solo URLs encontradas ${PURPLE}[-q]${NC}"
    echo -e "  ${CYAN}6.${NC} Con longitud de respuesta ${PURPLE}[-l]${NC}"
    echo -e "  ${CYAN}7.${NC} Combo completo ${PURPLE}[-v -l -o archivo]${NC}"
    echo ""
    
    read -p "Selecciona salida: " output_choice
    
    case $output_choice in
        1) OUTPUT_OPTIONS="" ;;
        2)
            read -p "🎯 Nombre del archivo: " filename
            OUTPUT_OPTIONS="-o ${filename:-gobuster_results.txt}"
            ;;
        3) OUTPUT_OPTIONS="-v" ;;
        4) OUTPUT_OPTIONS="--no-color" ;;
        5) OUTPUT_OPTIONS="-q" ;;
        6) OUTPUT_OPTIONS="-l" ;;
        7)
            read -p "🎯 Nombre del archivo: " filename
            OUTPUT_OPTIONS="-v -l -o ${filename:-gobuster_full_results.txt}"
            ;;
        *)
            OUTPUT_OPTIONS=""
            ;;
    esac
    
    echo -e "${GREEN}✅ Salida configurada${NC}"
}

select_advanced_options() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}          ${YELLOW}OPCIONES AVANZADAS${NC}             ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    echo -e "${YELLOW}Configuración avanzada:${NC}"
    echo -e "  ${CYAN}1.${NC} Sin opciones extra ${PURPLE}[por defecto]${NC}"
    echo -e "  ${CYAN}2.${NC} User-Agent personalizado"
    echo -e "  ${CYAN}3.${NC} Headers personalizados"
    echo -e "  ${CYAN}4.${NC} Proxy (Burp/ZAP)"
    echo -e "  ${CYAN}5.${NC} Autenticación HTTP"
    echo -e "  ${CYAN}6.${NC} Certificados SSL"
    echo -e "  ${CYAN}7.${NC} Wildcards DNS"
    echo -e "  ${CYAN}8.${NC} Combo personalizado"
    echo ""
    
    read -p "Selecciona avanzado: " advanced_choice
    
    case $advanced_choice in
        1) ADVANCED_OPTIONS="" ;;
        2)
            echo -e "${CYAN}💡 Ejemplos de User-Agent:${NC}"
            echo -e "  • Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
            echo -e "  • GoogleBot/2.1"
            echo -e "  • curl/7.68.0"
            read -p "🎯 User-Agent: " user_agent
            USER_AGENT="-a '$user_agent'"
            ;;
        3)
            echo -e "${CYAN}💡 Formato: 'Header1: Value1' 'Header2: Value2'${NC}"
            read -p "🎯 Headers (separados por espacio): " headers
            HEADERS="-H $headers"
            ;;
        4)
            read -p "🎯 Proxy URL (ej: http://127.0.0.1:8080): " proxy
            ADVANCED_OPTIONS="--proxy $proxy"
            ;;
        5)
            read -p "🎯 Username: " username
            read -s -p "🎯 Password: " password
            echo ""
            ADVANCED_OPTIONS="-U $username -P $password"
            ;;
        6)
            ADVANCED_OPTIONS="-k"  # ignorar certificados SSL
            echo -e "${YELLOW}⚠️ Ignorando verificación SSL${NC}"
            ;;
        7)
            if [[ "$SCAN_MODE" == "dns" ]]; then
                ADVANCED_OPTIONS="--wildcard"
                echo -e "${YELLOW}⚠️ Wildcard DNS habilitado${NC}"
            else
                echo -e "${RED}❌ Wildcard solo disponible para modo DNS${NC}"
            fi
            ;;
        8)
            echo -e "${CYAN}💡 Opciones disponibles:${NC}"
            echo -e "  • -k (ignorar SSL)"
            echo -e "  • --random-agent"
            echo -e "  • --delay 1s"
            echo -e "  • --no-progress"
            read -p "🎯 Opciones personalizadas: " ADVANCED_OPTIONS
            ;;
        *)
            ADVANCED_OPTIONS=""
            ;;
    esac
    
    echo -e "${GREEN}✅ Opciones avanzadas configuradas${NC}"
}

show_command_summary() {
    local full_command="gobuster $SCAN_MODE"
    
    case $SCAN_MODE in
        "dir"|"fuzz")
            full_command="$full_command -u $TARGET"
            ;;
        "dns"|"vhost")
            full_command="$full_command -d $TARGET"
            ;;
        "s3")
            full_command="$full_command -w $WORDLIST"
            ;;
    esac
    
    [[ -n "$WORDLIST" && "$SCAN_MODE" != "s3" ]] && full_command="$full_command -w $WORDLIST"
    [[ -n "$EXTENSIONS" ]] && full_command="$full_command $EXTENSIONS"
    [[ -n "$THREADS" ]] && full_command="$full_command $THREADS"
    [[ -n "$TIMEOUT" ]] && full_command="$full_command $TIMEOUT"
    [[ -n "$STATUS_CODES" ]] && full_command="$full_command $STATUS_CODES"
    [[ -n "$OUTPUT_OPTIONS" ]] && full_command="$full_command $OUTPUT_OPTIONS"
    [[ -n "$USER_AGENT" ]] && full_command="$full_command $USER_AGENT"
    [[ -n "$HEADERS" ]] && full_command="$full_command $HEADERS"
    [[ -n "$ADVANCED_OPTIONS" ]] && full_command="$full_command $ADVANCED_OPTIONS"
    
    echo -e "\n${BLUE}╔══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}                          ${YELLOW}RESUMEN DEL COMANDO${NC}                           ${BLUE}║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════════════╝${NC}"
    
    echo -e "\n${GREEN}📋 Comando generado:${NC}"
    echo -e "${CYAN}$full_command${NC}"
    
    echo -e "\n${YELLOW}📊 Configuración:${NC}"
    echo -e "  🎯 Modo: ${CYAN}$SCAN_MODE${NC}"
    echo -e "  🌐 Objetivo: ${CYAN}$TARGET${NC}"
    [[ -n "$WORDLIST" ]] && echo -e "  📚 Wordlist: ${CYAN}$WORDLIST${NC}"
    [[ -n "$EXTENSIONS" ]] && echo -e "  📄 Extensiones: ${CYAN}$EXTENSIONS${NC}"
    [[ -n "$THREADS" ]] && echo -e "  🧵 Threads: ${CYAN}$THREADS${NC}"
    [[ -n "$TIMEOUT" ]] && echo -e "  ⏱️ Timeout: ${CYAN}$TIMEOUT${NC}"
    [[ -n "$STATUS_CODES" ]] && echo -e "  📊 Códigos: ${CYAN}$STATUS_CODES${NC}"
    [[ -n "$ADVANCED_OPTIONS" ]] && echo -e "  ⚙️ Avanzado: ${CYAN}$ADVANCED_OPTIONS${NC}"
}

execute_scan() {
    case $SCAN_MODE in
        "multi")
            execute_multi_scan
            return $?
            ;;
        *)
            execute_single_scan
            return $?
            ;;
    esac
}

execute_single_scan() {
    local full_command="gobuster $SCAN_MODE"
    
    case $SCAN_MODE in
        "dir"|"fuzz")
            full_command="$full_command -u $TARGET"
            ;;
        "dns"|"vhost")
            full_command="$full_command -d $TARGET"
            ;;
        "s3")
            full_command="$full_command -w $WORDLIST"
            ;;
    esac
    
    [[ -n "$WORDLIST" && "$SCAN_MODE" != "s3" ]] && full_command="$full_command -w $WORDLIST"
    [[ -n "$EXTENSIONS" ]] && full_command="$full_command $EXTENSIONS"
    [[ -n "$THREADS" ]] && full_command="$full_command $THREADS"
    [[ -n "$TIMEOUT" ]] && full_command="$full_command $TIMEOUT"
    [[ -n "$STATUS_CODES" ]] && full_command="$full_command $STATUS_CODES"
    [[ -n "$OUTPUT_OPTIONS" ]] && full_command="$full_command $OUTPUT_OPTIONS"
    [[ -n "$USER_AGENT" ]] && full_command="$full_command $USER_AGENT"
    [[ -n "$HEADERS" ]] && full_command="$full_command $HEADERS"
    [[ -n "$ADVANCED_OPTIONS" ]] && full_command="$full_command $ADVANCED_OPTIONS"
    
    echo -e "\n${YELLOW}🚀 Ejecutando Gobuster...${NC}"
    echo -e "${CYAN}$full_command${NC}\n"
    
    eval "$full_command"
    
    local exit_code=$?
    
    if [[ $exit_code -eq 0 ]]; then
        echo -e "\n${GREEN}✅ Escaneo completado exitosamente${NC}"
    else
        echo -e "\n${RED}❌ Error en el escaneo (código: $exit_code)${NC}"
    fi
    
    return $exit_code
}

execute_multi_scan() {
    echo -e "${YELLOW}🚀 Ejecutando escaneo múltiple en $TARGET...${NC}\n"
    
    # Subdominio scan
    echo -e "${BLUE}1. Buscando subdominios...${NC}"
    gobuster dns -d "$TARGET" -w "/usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt" -o "${TARGET}_subdomains.txt"
    
    # Directory scan en dominio principal
    echo -e "\n${BLUE}2. Escaneando directorios en dominio principal...${NC}"
    gobuster dir -u "https://$TARGET" -w "/usr/share/dirb/wordlists/common.txt" -x php,html,htm -o "${TARGET}_directories.txt"
    
    # Vhost scan
    echo -e "\n${BLUE}3. Buscando virtual hosts...${NC}"
    gobuster vhost -u "https://$TARGET" -w "/usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt" -o "${TARGET}_vhosts.txt"
    
    echo -e "\n${GREEN}✅ Escaneo múltiple completado${NC}"
    echo -e "${CYAN}📁 Resultados guardados en:${NC}"
    echo -e "  • ${TARGET}_subdomains.txt"
    echo -e "  • ${TARGET}_directories.txt"
    echo -e "  • ${TARGET}_vhosts.txt"
}

quick_scans_menu() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}            ${YELLOW}ESCANEOS RÁPIDOS${NC}             ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    echo -e "${YELLOW}Escaneos preconfigurados:${NC}"
    echo -e "  ${CYAN}1.${NC} Directorios web básico ${PURPLE}[common.txt]${NC}"
    echo -e "  ${CYAN}2.${NC} Directorios + archivos PHP ${PURPLE}[con extensiones]${NC}"
    echo -e "  ${CYAN}3.${NC} Subdominios comunes ${PURPLE}[DNS]${NC}"
    echo -e "  ${CYAN}4.${NC} API endpoints ${PURPLE}[especializado]${NC}"
    echo -e "  ${CYAN}5.${NC} Backups y archivos sensibles ${PURPLE}[.bak,.old]${NC}"
    echo -e "  ${CYAN}6.${NC} S3 buckets ${PURPLE}[cloud storage]${NC}"
    echo -e "  ${CYAN}7.${NC} Escaneo completo multi-modo"
    echo -e "  ${CYAN}8.${NC} Volver al menú principal"
    echo ""
    
    read -p "Selecciona escaneo (1-8): " quick_choice
    
    case $quick_choice in
        1)
            read -p "🎯 URL objetivo (con http/https): " target_url
            gobuster dir -u "$target_url" -w /usr/share/dirb/wordlists/common.txt
            ;;
        2)
            read -p "🎯 URL objetivo: " target_url
            gobuster dir -u "$target_url" -w /usr/share/dirb/wordlists/common.txt -x php,html,htm,asp,aspx
            ;;
        3)
            read -p "🎯 Dominio objetivo: " target_domain
            gobuster dns -d "$target_domain" -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt
            ;;
        4)
            read -p "🎯 URL API: " target_url
            gobuster dir -u "$target_url" -w /usr/share/seclists/Discovery/Web-Content/api/api-endpoints.txt
            ;;
        5)
            read -p "🎯 URL objetivo: " target_url
            gobuster dir -u "$target_url" -w /usr/share/dirb/wordlists/common.txt -x bak,backup,old,orig,tmp,swp
            ;;
        6)
            read -p "🎯 Keywords para S3: " s3_keywords
            gobuster s3 -w /usr/share/seclists/Discovery/Web-Content/s3-buckets.txt
            ;;
        7)
            read -p "🎯 Dominio base: " target_domain
            TARGET="$target_domain"
            SCAN_MODE="multi"
            execute_multi_scan
            ;;
        8)
            return
            ;;
        *)
            echo -e "${RED}❌ Opción inválida${NC}"
            ;;
    esac
    
    echo ""
    read -p "Presiona Enter para continuar..."
}

main_menu() {
    while true; do
        print_banner
        
        echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║${NC}                           ${YELLOW}MENÚ PRINCIPAL${NC}                              ${BLUE}║${NC}"
        echo -e "${BLUE}╠══════════════════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}1.${NC}  🎯 Seleccionar Modo de Escaneo                                  ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}2.${NC}  🌐 Configurar Objetivo                                          ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}3.${NC}  📚 Seleccionar Wordlist                                         ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}4.${NC}  📄 Configurar Extensiones                                       ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}5.${NC}  🚀 Configurar Performance                                       ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}6.${NC}  📊 Configurar Códigos de Estado                                 ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}7.${NC}  📄 Configurar Salida                                            ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}8.${NC}  ⚙️  Configurar Opciones Avanzadas                               ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}9.${NC}  📋 Ver Resumen del Comando                                       ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}10.${NC} 🚀 Ejecutar Escaneo                                              ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}11.${NC} ⚡ Escaneos Rápidos                                              ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}0.${NC}  🚪 Salir                                                         ${BLUE}║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════════════╝${NC}"
        
        if [[ -n "$SCAN_MODE" && -n "$TARGET" ]]; then
            echo -e "\n${GREEN}📊 Estado:${NC} Modo: ${CYAN}$SCAN_MODE${NC}, Objetivo: ${CYAN}$TARGET${NC}"
        fi
        
        echo ""
        read -p "Selecciona una opción (0-11): " choice
        
        case $choice in
            1) select_scan_mode ;;
            2) select_target ;;
            3) select_wordlist ;;
            4) select_extensions ;;
            5) select_performance ;;
            6) select_status_codes ;;
            7) select_output_options ;;
            8) select_advanced_options ;;
            9) show_command_summary && read -p "Presiona Enter para continuar..." ;;
            10) 
                if [[ -z "$SCAN_MODE" || -z "$TARGET" ]]; then
                    echo -e "${RED}❌ Debes configurar modo y objetivo primero${NC}"
                    read -p "Presiona Enter para continuar..."
                else
                    execute_scan
                    read -p "Presiona Enter para continuar..."
                fi
                ;;
            11) quick_scans_menu ;;
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

# Verificar si gobuster está instalado
if ! command -v gobuster &> /dev/null; then
    echo -e "${RED}❌ Gobuster no está instalado${NC}"
    echo -e "${YELLOW}💡 Instala con: sudo apt install gobuster${NC}"
    exit 1
fi

# Ejecutar menú principal
main_menu