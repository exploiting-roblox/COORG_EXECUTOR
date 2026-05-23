#!/bin/bash

# 🔍 NIKTO ULTIMATE SCANNER
# Escáner de vulnerabilidades web más completo con máxima personalización

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Variables globales
TARGET=""
SCAN_TYPE=""
PLUGINS=""
OUTPUT_FORMAT=""
EVASION=""
AUTHENTICATION=""
PERFORMANCE=""
ADVANCED_OPTIONS=""
CUSTOM_HEADERS=""
USER_AGENT=""

print_banner() {
    clear
    echo -e "${BLUE}"
    echo "███╗   ██╗██╗██╗  ██╗████████╗ ██████╗     ██╗   ██╗██╗  ████████╗██╗███╗   ███╗ █████╗ ████████╗███████╗"
    echo "████╗  ██║██║██║ ██╔╝╚══██╔══╝██╔═══██╗    ██║   ██║██║  ╚══██╔══╝██║████╗ ████║██╔══██╗╚══██╔══╝██╔════╝"
    echo "██╔██╗ ██║██║█████╔╝    ██║   ██║   ██║    ██║   ██║██║     ██║   ██║██╔████╔██║███████║   ██║   █████╗  "
    echo "██║╚██╗██║██║██╔═██╗    ██║   ██║   ██║    ██║   ██║██║     ██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██╔══╝  "
    echo "██║ ╚████║██║██║  ██╗   ██║   ╚██████╔╝    ╚██████╔╝███████╗██║   ██║██║ ╚═╝ ██║██║  ██║   ██║   ███████╗"
    echo "╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝   ╚═╝    ╚═════╝      ╚═════╝ ╚══════╝╚═╝   ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚══════╝"
    echo -e "${NC}"
    echo -e "${CYAN}🔍 Nikto Ultimate - Escáner de Vulnerabilidades Web Avanzado${NC}"
    echo -e "${YELLOW}⚠️  Solo usar en aplicaciones propias o con autorización${NC}"
    echo ""
}

select_target() {
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}            ${YELLOW}OBJETIVO DE ESCANEO${NC}            ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    echo -e "${YELLOW}¿Qué quieres escanear?${NC}"
    echo -e "  ${CYAN}1.${NC} URL específica ${PURPLE}[https://example.com]${NC}"
    echo -e "  ${CYAN}2.${NC} IP con puerto ${PURPLE}[192.168.1.100:8080]${NC}"
    echo -e "  ${CYAN}3.${NC} Archivo con múltiples objetivos"
    echo -e "  ${CYAN}4.${NC} Rango de puertos en IP ${PURPLE}[auto-discover]${NC}"
    echo -e "  ${CYAN}5.${NC} HTTPS con certificado específico"
    echo ""
    
    read -p "Selecciona tipo de objetivo (1-5): " target_choice
    
    case $target_choice in
        1)
            echo -e "${CYAN}💡 Ejemplos:${NC}"
            echo -e "  • https://example.com"
            echo -e "  • http://target.local:8080"
            echo -e "  • https://api.company.com/v1"
            read -p "🎯 URL objetivo: " TARGET
            ;;
        2)
            read -p "🎯 IP: " target_ip
            read -p "🎯 Puerto (Enter para 80): " target_port
            TARGET="$target_ip:${target_port:-80}"
            ;;
        3)
            read -p "🎯 Archivo con objetivos (uno por línea): " target_file
            if [[ ! -f "$target_file" ]]; then
                echo -e "${RED}❌ Archivo no encontrado${NC}"
                return 1
            fi
            TARGET="-host $target_file"
            ;;
        4)
            read -p "🎯 IP objetivo: " target_ip
            echo -e "${YELLOW}⚠️ Escaneará puertos comunes automáticamente${NC}"
            TARGET="-host $target_ip -port 80,443,8080,8443,8000,8888"
            ;;
        5)
            read -p "🎯 URL HTTPS: " https_url
            read -p "🎯 Certificado SSL específico (Enter para ignorar): " ssl_cert
            TARGET="$https_url"
            if [[ -n "$ssl_cert" ]]; then
                TARGET="$TARGET -ssl $ssl_cert"
            fi
            ;;
        *)
            echo -e "${RED}❌ Opción inválida${NC}"
            return 1
            ;;
    esac
    
    if [[ -z "$TARGET" ]]; then
        echo -e "${RED}❌ Objetivo requerido${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✅ Objetivo: $TARGET${NC}"
}

select_scan_type() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}            ${YELLOW}TIPO DE ESCANEO${NC}               ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    echo -e "${YELLOW}¿Qué tipo de análisis quieres?${NC}"
    echo -e "  ${CYAN}1.${NC} Escaneo básico ${PURPLE}[rápido]${NC}"
    echo -e "  ${CYAN}2.${NC} Escaneo completo ${PURPLE}[todos los tests]${NC}"
    echo -e "  ${CYAN}3.${NC} Solo vulnerabilidades críticas ${PURPLE}[high risk]${NC}"
    echo -e "  ${CYAN}4.${NC} Información del servidor ${PURPLE}[fingerprinting]${NC}"
    echo -e "  ${CYAN}5.${NC} Tests de configuración ${PURPLE}[misconfigs]${NC}"
    echo -e "  ${CYAN}6.${NC} Búsqueda de archivos sensibles ${PURPLE}[disclosure]${NC}"
    echo -e "  ${CYAN}7.${NC} Tests de autenticación ${PURPLE}[auth bypass]${NC}"
    echo -e "  ${CYAN}8.${NC} Inyecciones SQL/XSS ${PURPLE}[injection]${NC}"
    echo -e "  ${CYAN}9.${NC} Personalizado (selección manual)"
    echo ""
    
    read -p "Selecciona tipo (1-9): " scan_choice
    
    case $scan_choice in
        1) 
            SCAN_TYPE="-Tuning 1,2,3,5"
            echo -e "${GREEN}✅ Escaneo básico seleccionado${NC}"
            ;;
        2) 
            SCAN_TYPE=""
            echo -e "${GREEN}✅ Escaneo completo (todos los tests)${NC}"
            ;;
        3) 
            SCAN_TYPE="-Tuning 1,2,3,4,5,9"
            echo -e "${GREEN}✅ Solo vulnerabilidades críticas${NC}"
            ;;
        4) 
            SCAN_TYPE="-Tuning 0,1,2"
            echo -e "${GREEN}✅ Información del servidor${NC}"
            ;;
        5) 
            SCAN_TYPE="-Tuning 6,7,8"
            echo -e "${GREEN}✅ Tests de configuración${NC}"
            ;;
        6) 
            SCAN_TYPE="-Tuning 4,9"
            echo -e "${GREEN}✅ Archivos sensibles${NC}"
            ;;
        7) 
            SCAN_TYPE="-Tuning 3,7"
            echo -e "${GREEN}✅ Tests de autenticación${NC}"
            ;;
        8) 
            SCAN_TYPE="-Tuning 5,9"
            echo -e "${GREEN}✅ Inyecciones SQL/XSS${NC}"
            ;;
        9)
            echo -e "${CYAN}💡 Categorías de tuning:${NC}"
            echo -e "  • 0: File Upload"
            echo -e "  • 1: Interesting File / Seen in logs"
            echo -e "  • 2: Misconfiguration / Default File"
            echo -e "  • 3: Information Disclosure"
            echo -e "  • 4: Injection (XSS/Script/HTML)"
            echo -e "  • 5: Remote File Retrieval"
            echo -e "  • 6: Denial of Service"
            echo -e "  • 7: Remote File Retrieval - Server Wide"
            echo -e "  • 8: Command Execution - Remote Shell"
            echo -e "  • 9: SQL Injection"
            echo -e "  • a: Authentication Bypass"
            echo -e "  • b: Software Identification"
            echo -e "  • c: Remote Source Inclusion"
            echo ""
            read -p "🎯 Categorías (separadas por coma): " custom_tuning
            SCAN_TYPE="-Tuning $custom_tuning"
            ;;
        *)
            echo -e "${YELLOW}Usando escaneo básico por defecto${NC}"
            SCAN_TYPE="-Tuning 1,2,3,5"
            ;;
    esac
}

select_plugins() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}            ${YELLOW}PLUGINS ESPECÍFICOS${NC}            ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    echo -e "${YELLOW}¿Plugins adicionales?${NC}"
    echo -e "  ${CYAN}1.${NC} Sin plugins extra ${PURPLE}[por defecto]${NC}"
    echo -e "  ${CYAN}2.${NC} Tests SSL/TLS ${PURPLE}[ssl_tests]${NC}"
    echo -e "  ${CYAN}3.${NC} Headers de seguridad ${PURPLE}[headers]${NC}"
    echo -e "  ${CYAN}4.${NC} Tests de cookies ${PURPLE}[cookies]${NC}"
    echo -e "  ${CYAN}5.${NC} Detección CMS ${PURPLE}[cms_detection]${NC}"
    echo -e "  ${CYAN}6.${NC} Archivos de backup ${PURPLE}[backup_files]${NC}"
    echo -e "  ${CYAN}7.${NC} Directorios administrativos ${PURPLE}[admin_dirs]${NC}"
    echo -e "  ${CYAN}8.${NC} Tests de API ${PURPLE}[api_tests]${NC}"
    echo -e "  ${CYAN}9.${NC} Combo completo ${PURPLE}[todos]${NC}"
    echo -e "  ${CYAN}10.${NC} Lista personalizada"
    echo ""
    
    read -p "Selecciona plugins (1-10): " plugin_choice
    
    case $plugin_choice in
        1) PLUGINS="" ;;
        2) PLUGINS="-Plugins @@ALL" ;;  # Incluye tests SSL
        3) PLUGINS="-Plugins headers" ;;
        4) PLUGINS="-Plugins cookies" ;;
        5) PLUGINS="-Plugins @@DEFAULT" ;;
        6) PLUGINS="-Plugins backup_files" ;;
        7) PLUGINS="-Plugins admin_cgis" ;;
        8) PLUGINS="-Plugins api" ;;
        9) 
            PLUGINS="-Plugins @@ALL"
            echo -e "${YELLOW}⚠️ Combo completo - llevará más tiempo${NC}"
            ;;
        10)
            echo -e "${CYAN}💡 Plugins disponibles:${NC}"
            echo -e "  • @@ALL (todos los plugins)"
            echo -e "  • @@DEFAULT (plugins por defecto)"
            echo -e "  • ssl, headers, cookies, api"
            read -p "🎯 Plugins personalizados: " custom_plugins
            PLUGINS="-Plugins $custom_plugins"
            ;;
        *)
            PLUGINS=""
            ;;
    esac
    
    echo -e "${GREEN}✅ Plugins: ${PLUGINS:-por defecto}${NC}"
}

select_output_format() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}           ${YELLOW}FORMATO DE SALIDA${NC}              ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    echo -e "${YELLOW}¿Formato de reporte?${NC}"
    echo -e "  ${CYAN}1.${NC} Solo pantalla ${PURPLE}[por defecto]${NC}"
    echo -e "  ${CYAN}2.${NC} Texto plano ${PURPLE}[-Format txt]${NC}"
    echo -e "  ${CYAN}3.${NC} XML estructurado ${PURPLE}[-Format xml]${NC}"
    echo -e "  ${CYAN}4.${NC} HTML visual ${PURPLE}[-Format html]${NC}"
    echo -e "  ${CYAN}5.${NC} CSV para análisis ${PURPLE}[-Format csv]${NC}"
    echo -e "  ${CYAN}6.${NC} JSON para APIs ${PURPLE}[-Format json]${NC}"
    echo -e "  ${CYAN}7.${NC} Múltiples formatos"
    echo ""
    
    read -p "Selecciona formato (1-7): " format_choice
    
    case $format_choice in
        1) OUTPUT_FORMAT="" ;;
        2) 
            read -p "🎯 Archivo de salida: " filename
            OUTPUT_FORMAT="-Format txt -output ${filename:-nikto_results.txt}"
            ;;
        3) 
            read -p "🎯 Archivo XML: " filename
            OUTPUT_FORMAT="-Format xml -output ${filename:-nikto_results.xml}"
            ;;
        4) 
            read -p "🎯 Archivo HTML: " filename
            OUTPUT_FORMAT="-Format html -output ${filename:-nikto_results.html}"
            ;;
        5) 
            read -p "🎯 Archivo CSV: " filename
            OUTPUT_FORMAT="-Format csv -output ${filename:-nikto_results.csv}"
            ;;
        6) 
            read -p "🎯 Archivo JSON: " filename
            OUTPUT_FORMAT="-Format json -output ${filename:-nikto_results.json}"
            ;;
        7)
            read -p "🎯 Basename para archivos: " basename
            base=${basename:-nikto_results}
            OUTPUT_FORMAT="-Format txt,xml,html -output $base"
            echo -e "${YELLOW}📁 Se crearán: $base.txt, $base.xml, $base.html${NC}"
            ;;
        *)
            OUTPUT_FORMAT=""
            ;;
    esac
    
    echo -e "${GREEN}✅ Formato configurado${NC}"
}

select_evasion() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}         ${YELLOW}TÉCNICAS DE EVASIÓN${NC}            ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    echo -e "${YELLOW}¿Evasión de detección?${NC}"
    echo -e "  ${CYAN}1.${NC} Sin evasión ${PURPLE}[normal]${NC}"
    echo -e "  ${CYAN}2.${NC} Random User-Agent ${PURPLE}[-evasion 1]${NC}"
    echo -e "  ${CYAN}3.${NC} Modificar case ${PURPLE}[-evasion 2]${NC}"
    echo -e "  ${CYAN}4.${NC} Líneas en blanco ${PURPLE}[-evasion 3]${NC}"
    echo -e "  ${CYAN}5.${NC} Headers fake ${PURPLE}[-evasion 4]${NC}"
    echo -e "  ${CYAN}6.${NC} Método fake ${PURPLE}[-evasion 5]${NC}"
    echo -e "  ${CYAN}7.${NC} Combo evasión ${PURPLE}[-evasion 1,2,3,4]${NC}"
    echo -e "  ${CYAN}8.${NC} Personalizado"
    echo ""
    
    read -p "Selecciona evasión (1-8): " evasion_choice
    
    case $evasion_choice in
        1) EVASION="" ;;
        2) EVASION="-evasion 1" ;;
        3) EVASION="-evasion 2" ;;
        4) EVASION="-evasion 3" ;;
        5) EVASION="-evasion 4" ;;
        6) EVASION="-evasion 5" ;;
        7) 
            EVASION="-evasion 1,2,3,4"
            echo -e "${YELLOW}⚠️ Combo de evasión activado${NC}"
            ;;
        8)
            echo -e "${CYAN}💡 Técnicas disponibles:${NC}"
            echo -e "  • 1: Random User-Agent"
            echo -e "  • 2: Random modificaciones de case"
            echo -e "  • 3: Random líneas en blanco"
            echo -e "  • 4: Headers fake"
            echo -e "  • 5: Método HTTP fake"
            echo -e "  • 6: Tab como separador de request"
            echo -e "  • 7: URL encode"
            echo -e "  • 8: Usar premature URL ending"
            read -p "🎯 Técnicas (separadas por coma): " custom_evasion
            EVASION="-evasion $custom_evasion"
            ;;
        *)
            EVASION=""
            ;;
    esac
    
    echo -e "${GREEN}✅ Evasión: ${EVASION:-ninguna}${NC}"
}

select_authentication() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}           ${YELLOW}AUTENTICACIÓN${NC}                 ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    echo -e "${YELLOW}¿Requiere autenticación?${NC}"
    echo -e "  ${CYAN}1.${NC} Sin autenticación ${PURPLE}[por defecto]${NC}"
    echo -e "  ${CYAN}2.${NC} HTTP Basic Auth"
    echo -e "  ${CYAN}3.${NC} Cookies/Sesión"
    echo -e "  ${CYAN}4.${NC} Headers personalizados"
    echo -e "  ${CYAN}5.${NC} Certificado cliente SSL"
    echo ""
    
    read -p "Selecciona auth (1-5): " auth_choice
    
    case $auth_choice in
        1) AUTHENTICATION="" ;;
        2)
            read -p "🎯 Usuario: " username
            read -s -p "🎯 Contraseña: " password
            echo ""
            AUTHENTICATION="-id $username:$password"
            ;;
        3)
            echo -e "${CYAN}💡 Formato: 'cookie1=value1; cookie2=value2'${NC}"
            read -p "🎯 Cookies: " cookies
            AUTHENTICATION="-Cookies '$cookies'"
            ;;
        4)
            echo -e "${CYAN}💡 Formato: 'Header1: Value1' 'Header2: Value2'${NC}"
            read -p "🎯 Headers de auth: " auth_headers
            CUSTOM_HEADERS="$auth_headers"
            ;;
        5)
            read -p "🎯 Ruta del certificado: " cert_path
            read -p "🎯 Clave privada: " key_path
            AUTHENTICATION="-cert $cert_path -key $key_path"
            ;;
        *)
            AUTHENTICATION=""
            ;;
    esac
    
    echo -e "${GREEN}✅ Autenticación configurada${NC}"
}

select_performance() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}           ${YELLOW}RENDIMIENTO Y TIMING${NC}           ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    echo -e "${YELLOW}Configuración de velocidad:${NC}"
    echo -e "  ${CYAN}1.${NC} Muy lento ${PURPLE}[sigiloso]${NC}"
    echo -e "  ${CYAN}2.${NC} Lento ${PURPLE}[conservador]${NC}"
    echo -e "  ${CYAN}3.${NC} Normal ${PURPLE}[equilibrado]${NC}"
    echo -e "  ${CYAN}4.${NC} Rápido ${PURPLE}[agresivo]${NC}"
    echo -e "  ${CYAN}5.${NC} Muy rápido ${PURPLE}[insano]${NC}"
    echo -e "  ${CYAN}6.${NC} Personalizado"
    echo ""
    
    read -p "Selecciona velocidad (1-6): " perf_choice
    
    case $perf_choice in
        1) 
            PERFORMANCE="-Pause 5 -timeout 30"
            echo -e "${GREEN}✅ Muy lento (5s pausa, 30s timeout)${NC}"
            ;;
        2) 
            PERFORMANCE="-Pause 2 -timeout 20"
            echo -e "${GREEN}✅ Lento (2s pausa, 20s timeout)${NC}"
            ;;
        3) 
            PERFORMANCE="-timeout 10"
            echo -e "${GREEN}✅ Normal (10s timeout)${NC}"
            ;;
        4) 
            PERFORMANCE="-timeout 5"
            echo -e "${GREEN}✅ Rápido (5s timeout)${NC}"
            ;;
        5) 
            PERFORMANCE="-timeout 2"
            echo -e "${GREEN}✅ Muy rápido (2s timeout)${NC}"
            echo -e "${YELLOW}⚠️ Puede generar falsos negativos${NC}"
            ;;
        6)
            read -p "🎯 Pausa entre requests (segundos): " pause_time
            read -p "🎯 Timeout por request (segundos): " timeout_val
            PERFORMANCE=""
            [[ -n "$pause_time" && "$pause_time" != "0" ]] && PERFORMANCE="$PERFORMANCE -Pause $pause_time"
            [[ -n "$timeout_val" ]] && PERFORMANCE="$PERFORMANCE -timeout $timeout_val"
            ;;
        *)
            PERFORMANCE="-timeout 10"
            ;;
    esac
}

select_advanced_options() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}          ${YELLOW}OPCIONES AVANZADAS${NC}             ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    echo -e "${YELLOW}Configuración avanzada:${NC}"
    echo -e "  ${CYAN}1.${NC} Sin opciones extra ${PURPLE}[por defecto]${NC}"
    echo -e "  ${CYAN}2.${NC} User-Agent personalizado"
    echo -e "  ${CYAN}3.${NC} Proxy (Burp/ZAP)"
    echo -e "  ${CYAN}4.${NC} SSL sin verificación"
    echo -e "  ${CYAN}5.${NC} Follow redirects"
    echo -e "  ${CYAN}6.${NC} Máximo de redirects"
    echo -e "  ${CYAN}7.${NC} Verbose mode"
    echo -e "  ${CYAN}8.${NC} Combo personalizado"
    echo ""
    
    read -p "Selecciona avanzado (1-8): " advanced_choice
    
    case $advanced_choice in
        1) ADVANCED_OPTIONS="" ;;
        2)
            echo -e "${CYAN}💡 User-Agents comunes:${NC}"
            echo -e "  • Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/91.0.4472.124"
            echo -e "  • Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Safari/537.36"
            echo -e "  • GoogleBot/2.1"
            read -p "🎯 User-Agent: " user_agent_custom
            USER_AGENT="-useragent '$user_agent_custom'"
            ;;
        3)
            read -p "🎯 Proxy URL (ej: http://127.0.0.1:8080): " proxy_url
            ADVANCED_OPTIONS="-useproxy $proxy_url"
            ;;
        4)
            ADVANCED_OPTIONS="-nossl"
            echo -e "${YELLOW}⚠️ Verificación SSL deshabilitada${NC}"
            ;;
        5)
            ADVANCED_OPTIONS="-followredirects"
            echo -e "${GREEN}✅ Following redirects habilitado${NC}"
            ;;
        6)
            read -p "🎯 Máximo redirects: " max_redirects
            ADVANCED_OPTIONS="-maxredirects ${max_redirects:-5}"
            ;;
        7)
            ADVANCED_OPTIONS="-verbose"
            echo -e "${GREEN}✅ Modo verbose habilitado${NC}"
            ;;
        8)
            echo -e "${CYAN}💡 Opciones disponibles:${NC}"
            echo -e "  • -verbose (modo detallado)"
            echo -e "  • -nossl (sin verificación SSL)"
            echo -e "  • -followredirects"
            echo -e "  • -maxredirects N"
            echo -e "  • -vhost hostname"
            echo -e "  • -404code N"
            read -p "🎯 Opciones personalizadas: " ADVANCED_OPTIONS
            ;;
        *)
            ADVANCED_OPTIONS=""
            ;;
    esac
    
    echo -e "${GREEN}✅ Opciones avanzadas configuradas${NC}"
}

show_command_summary() {
    local full_command="nikto -h"
    
    # Procesar target
    if [[ "$TARGET" == *"-host"* ]]; then
        full_command="nikto $TARGET"
    else
        full_command="$full_command $TARGET"
    fi
    
    [[ -n "$SCAN_TYPE" ]] && full_command="$full_command $SCAN_TYPE"
    [[ -n "$PLUGINS" ]] && full_command="$full_command $PLUGINS"
    [[ -n "$OUTPUT_FORMAT" ]] && full_command="$full_command $OUTPUT_FORMAT"
    [[ -n "$EVASION" ]] && full_command="$full_command $EVASION"
    [[ -n "$AUTHENTICATION" ]] && full_command="$full_command $AUTHENTICATION"
    [[ -n "$PERFORMANCE" ]] && full_command="$full_command $PERFORMANCE"
    [[ -n "$USER_AGENT" ]] && full_command="$full_command $USER_AGENT"
    [[ -n "$ADVANCED_OPTIONS" ]] && full_command="$full_command $ADVANCED_OPTIONS"
    [[ -n "$CUSTOM_HEADERS" ]] && full_command="$full_command -header '$CUSTOM_HEADERS'"
    
    echo -e "\n${BLUE}╔══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}                          ${YELLOW}RESUMEN DEL COMANDO${NC}                           ${BLUE}║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════════════╝${NC}"
    
    echo -e "\n${GREEN}📋 Comando generado:${NC}"
    echo -e "${CYAN}$full_command${NC}"
    
    echo -e "\n${YELLOW}📊 Configuración:${NC}"
    echo -e "  🎯 Objetivo: ${CYAN}$TARGET${NC}"
    [[ -n "$SCAN_TYPE" ]] && echo -e "  🔍 Tipo: ${CYAN}$SCAN_TYPE${NC}"
    [[ -n "$PLUGINS" ]] && echo -e "  🔌 Plugins: ${CYAN}$PLUGINS${NC}"
    [[ -n "$OUTPUT_FORMAT" ]] && echo -e "  📄 Salida: ${CYAN}$OUTPUT_FORMAT${NC}"
    [[ -n "$EVASION" ]] && echo -e "  🥷 Evasión: ${CYAN}$EVASION${NC}"
    [[ -n "$AUTHENTICATION" ]] && echo -e "  🔐 Auth: ${CYAN}$AUTHENTICATION${NC}"
    [[ -n "$PERFORMANCE" ]] && echo -e "  🚀 Performance: ${CYAN}$PERFORMANCE${NC}"
    [[ -n "$ADVANCED_OPTIONS" ]] && echo -e "  ⚙️ Avanzado: ${CYAN}$ADVANCED_OPTIONS${NC}"
    
    echo -e "\n${PURPLE}🕒 Estimación de tiempo:${NC}"
    if [[ "$PERFORMANCE" == *"Pause 5"* ]]; then
        echo -e "  ⏱️ Muy lento - 30-60 minutos"
    elif [[ "$PERFORMANCE" == *"Pause 2"* ]]; then
        echo -e "  ⏱️ Lento - 15-30 minutos"
    elif [[ "$PERFORMANCE" == *"timeout 2"* ]]; then
        echo -e "  ⏱️ Muy rápido - 2-5 minutos"
    else
        echo -e "  ⏱️ Normal - 5-15 minutos"
    fi
}

execute_scan() {
    local full_command="nikto -h"
    
    # Procesar target
    if [[ "$TARGET" == *"-host"* ]]; then
        full_command="nikto $TARGET"
    else
        full_command="$full_command $TARGET"
    fi
    
    [[ -n "$SCAN_TYPE" ]] && full_command="$full_command $SCAN_TYPE"
    [[ -n "$PLUGINS" ]] && full_command="$full_command $PLUGINS"
    [[ -n "$OUTPUT_FORMAT" ]] && full_command="$full_command $OUTPUT_FORMAT"
    [[ -n "$EVASION" ]] && full_command="$full_command $EVASION"
    [[ -n "$AUTHENTICATION" ]] && full_command="$full_command $AUTHENTICATION"
    [[ -n "$PERFORMANCE" ]] && full_command="$full_command $PERFORMANCE"
    [[ -n "$USER_AGENT" ]] && full_command="$full_command $USER_AGENT"
    [[ -n "$ADVANCED_OPTIONS" ]] && full_command="$full_command $ADVANCED_OPTIONS"
    [[ -n "$CUSTOM_HEADERS" ]] && full_command="$full_command -header '$CUSTOM_HEADERS'"
    
    echo -e "\n${YELLOW}🚀 Ejecutando Nikto...${NC}"
    echo -e "${CYAN}$full_command${NC}\n"
    
    # Actualizar base de datos si es necesario
    echo -e "${BLUE}📡 Verificando base de datos de plugins...${NC}"
    nikto -update 2>/dev/null || echo -e "${YELLOW}⚠️ No se pudo actualizar (continuando)${NC}"
    
    echo ""
    eval "$full_command"
    
    local exit_code=$?
    
    if [[ $exit_code -eq 0 ]]; then
        echo -e "\n${GREEN}✅ Escaneo completado exitosamente${NC}"
        
        # Mostrar resumen si hay archivos de salida
        if [[ $OUTPUT_FORMAT == *"-output"* ]]; then
            echo -e "\n${BLUE}📊 Resumen de resultados:${NC}"
            local output_file=$(echo $OUTPUT_FORMAT | sed -n 's/.*-output \([^ ]*\).*/\1/p')
            if [[ -f "$output_file.txt" ]]; then
                local vuln_count=$(grep -c "OSVDB\|CVE\|+" "$output_file.txt" 2>/dev/null || echo "0")
                echo -e "  🔍 Vulnerabilidades encontradas: ${RED}$vuln_count${NC}"
            fi
        fi
    else
        echo -e "\n${RED}❌ Error en el escaneo (código: $exit_code)${NC}"
    fi
    
    return $exit_code
}

quick_scans_menu() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}            ${YELLOW}ESCANEOS RÁPIDOS${NC}             ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    
    echo -e "${YELLOW}Escaneos preconfigurados:${NC}"
    echo -e "  ${CYAN}1.${NC} Escaneo básico rápido ${PURPLE}[info + misconfig]${NC}"
    echo -e "  ${CYAN}2.${NC} Vulnerabilidades críticas ${PURPLE}[high risk]${NC}"
    echo -e "  ${CYAN}3.${NC} Headers de seguridad ${PURPLE}[headers]${NC}"
    echo -e "  ${CYAN}4.${NC} Tests SSL/TLS ${PURPLE}[ssl complete]${NC}"
    echo -e "  ${CYAN}5.${NC} Archivos sensibles ${PURPLE}[disclosure]${NC}"
    echo -e "  ${CYAN}6.${NC} Escaneo sigiloso ${PURPLE}[evasion]${NC}"
    echo -e "  ${CYAN}7.${NC} Escaneo completo ${PURPLE}[all tests]${NC}"
    echo -e "  ${CYAN}8.${NC} Volver al menú principal"
    echo ""
    
    read -p "Selecciona escaneo (1-8): " quick_choice
    
    case $quick_choice in
        1)
            read -p "🎯 URL objetivo: " target_url
            nikto -h "$target_url" -Tuning 1,2,3 -timeout 5
            ;;
        2)
            read -p "🎯 URL objetivo: " target_url
            nikto -h "$target_url" -Tuning 1,2,3,4,5,9 -Format txt -output "${target_url//[^a-zA-Z0-9]/_}_critical.txt"
            ;;
        3)
            read -p "🎯 URL objetivo: " target_url
            nikto -h "$target_url" -Plugins headers -verbose
            ;;
        4)
            read -p "🎯 URL HTTPS: " target_url
            nikto -h "$target_url" -Plugins @@ALL -ssl
            ;;
        5)
            read -p "🎯 URL objetivo: " target_url
            nikto -h "$target_url" -Tuning 4,9 -Format html -output "sensitive_files.html"
            ;;
        6)
            read -p "🎯 URL objetivo: " target_url
            nikto -h "$target_url" -evasion 1,2,3,4 -Pause 2 -timeout 20
            ;;
        7)
            read -p "🎯 URL objetivo: " target_url
            echo -e "${RED}⚠️ Escaneo completo - llevará 30-60 minutos${NC}"
            read -p "¿Continuar? (y/N): " confirm
            if [[ $confirm == [yY] ]]; then
                nikto -h "$target_url" -Plugins @@ALL -Format txt,html -output "complete_scan"
            fi
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
        echo -e "${BLUE}║${NC} ${CYAN}1.${NC}  🎯 Configurar Objetivo                                          ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}2.${NC}  🔍 Seleccionar Tipo de Escaneo                                 ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}3.${NC}  🔌 Configurar Plugins                                           ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}4.${NC}  📄 Configurar Formato de Salida                                ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}5.${NC}  🥷 Configurar Evasión                                           ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}6.${NC}  🔐 Configurar Autenticación                                     ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}7.${NC}  🚀 Configurar Performance                                       ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}8.${NC}  ⚙️  Configurar Opciones Avanzadas                               ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}9.${NC}  📋 Ver Resumen del Comando                                       ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}10.${NC} 🚀 Ejecutar Escaneo                                              ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}11.${NC} ⚡ Escaneos Rápidos                                              ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${CYAN}0.${NC}  🚪 Salir                                                         ${BLUE}║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════════════╝${NC}"
        
        if [[ -n "$TARGET" ]]; then
            echo -e "\n${GREEN}📊 Estado:${NC} Objetivo: ${CYAN}$TARGET${NC}"
        fi
        
        echo ""
        read -p "Selecciona una opción (0-11): " choice
        
        case $choice in
            1) select_target ;;
            2) select_scan_type ;;
            3) select_plugins ;;
            4) select_output_format ;;
            5) select_evasion ;;
            6) select_authentication ;;
            7) select_performance ;;
            8) select_advanced_options ;;
            9) show_command_summary && read -p "Presiona Enter para continuar..." ;;
            10) 
                if [[ -z "$TARGET" ]]; then
                    echo -e "${RED}❌ Debes configurar un objetivo primero${NC}"
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

# Verificar si nikto está instalado
if ! command -v nikto &> /dev/null; then
    echo -e "${RED}❌ Nikto no está instalado${NC}"
    echo -e "${YELLOW}💡 Instala con: sudo apt install nikto${NC}"
    exit 1
fi

# Ejecutar menú principal
main_menu