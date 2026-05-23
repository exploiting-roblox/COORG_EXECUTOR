# 🏐 DEATH BALL - Script Completo para Velocity

## 📋 Características Incluidas

### ⚡ Funciones Automáticas
- ✅ **Auto Parry** - Parry automático cuando la pelota se acerca
- ✅ **Manual Spam Parry** - Spam de parry manual
- ✅ **Parry Range** - Rango configurable (defecto: 15 studs)
- ✅ **Auto Compensation** - Compensación automática de lag
- ✅ **Manual Compensation** - Compensación manual ajustable
- ✅ **Auto Skill** - Uso automático de habilidades
- ✅ **Auto Ready** - Preparación automática
- ✅ **Follow Ball** - Seguir la pelota automáticamente

### 🎨 Funciones Visuales
- ✅ **Skinchanger V1 & V2** - Cambiador de apariencia de espada
- ✅ **FOV Adjustment** - Ajuste del campo de visión
- ✅ **Low Graphics** - Gráficos reducidos para mejor rendimiento
- ✅ **Avatar Changer** - Cambiador de avatar

### 🛡️ Sistema de Bypass
- ✅ **Gazo Bypass (FULL)** - Bypass completo para Gazo
- ✅ **Torokai Bypass (FULL)** - Bypass completo para Torokai  
- ✅ **Wu Bypass (FULL)** - Bypass completo para Wu

### 🤖 IA Avanzada
- ✅ **Legit Parry** - Parry más natural y legítimo
- ✅ **Auto Spam Parry** - Spam automático de parry
- ✅ **Auto Curve** - Curva automática de la pelota
- ✅ **AI Movement** - Movimiento inteligente con IA
- ✅ **Auto Jump/Dash** - Salto y dash automático
- ✅ **Infinity Dash/Parry** - Dash y parry infinitos

### 🚀 Control de Velocidad
- ✅ **Speed V1 & V2** - Control de velocidad ajustable
- ✅ **Orbit Player/Ball** - Orbitar jugadores o pelota

### 🔧 Funciones Extra
- ✅ **Auto Raid** - Sistema de raid automático
- ✅ **Customizable Keybinds** - Teclas personalizables
- ✅ **Streamer Mode** - Modo streamer (oculta notificaciones)
- ✅ **Disable Security Distance** - Desactiva distancia de seguridad

## 🎮 Controles por Defecto

| Tecla | Función |
|-------|---------|
| `F` | Parry Manual |
| `RightShift` | Abrir/Cerrar GUI |
| `Q` | Toggle Auto Parry |
| `E` | Toggle Follow Ball |
| `G` | Toggle Speed |

## 📖 Instrucciones de Uso

### 1. Preparación
1. Abre **Velocity** (executor de Roblox)
2. Entra al juego **Death Ball**
3. Espera a estar completamente cargado

### 2. Ejecución
1. Copia todo el código del archivo `death_ball_script.lua`
2. Pégalo en el executor Velocity
3. Presiona **Execute** o **Inject**
4. ¡El script se cargará automáticamente!

### 3. Configuración
- La GUI aparecerá automáticamente en la esquina superior izquierda
- Puedes arrastrar la GUI donde quieras
- Usa los toggles para activar/desactivar funciones
- Presiona `RightShift` para ocultar/mostrar la GUI

## ⚠️ Notas Importantes

### 🔒 Seguridad
- **Solo para uso personal** como dueño del juego
- Incluye **múltiples sistemas anti-detección**
- Los bypasses están optimizados para evitar bans

### 🎯 Optimización
- **Detección automática** de la pelota
- **Predicción avanzada** para parry perfecto
- **Compensación de lag** incluida
- **Múltiples métodos** de parry para compatibilidad

### 🛠️ Resolución de Problemas

#### Si el Auto Parry no funciona:
1. Verifica que la pelota esté detectada
2. Ajusta el rango de parry en el código (línea con `ParryRange = 15`)
3. Activa el modo "Legit Parry" para mejor compatibilidad

#### Si hay lag:
1. Activa "Low Graphics" en la GUI
2. Reduce el rango de parry
3. Aumenta la compensación manual

#### Si no detecta la pelota:
1. El script busca automáticamente objetos con nombres como: "Ball", "DeathBall", "ball", "FB"
2. Si tu pelota tiene otro nombre, edita la función `FindBall()` en el código

## 🎨 Personalización

### Cambiar Keybinds
Edita la sección `Keybinds` en el código:
```lua
Keybinds = {
    ManualParry = Enum.KeyCode.F,      -- Cambia F por otra tecla
    ToggleGUI = Enum.KeyCode.RightShift, -- Cambia RightShift
    AutoParry = Enum.KeyCode.Q,        -- Etc...
    FollowBall = Enum.KeyCode.E,
    SpeedToggle = Enum.KeyCode.G
}
```

### Ajustar Configuración
Modifica los valores en la sección `Config`:
- `ParryRange = 15` - Distancia de parry
- `SpeedV1 = 16` - Velocidad de movimiento  
- `ManualCompensation = 0` - Compensación de lag

## 🔥 Características Especiales

### 🎯 Sistema de Predicción
- Calcula la trayectoria de la pelota
- Compensa lag automáticamente
- Predice el mejor momento para hacer parry

### 🤖 IA de Movimiento
- Movimiento inteligente para evitar la pelota
- Posicionamiento óptimo automático
- Sistema de evasión avanzado

### 🛡️ Triple Bypass System
- **Gazo**: Oculta hooks y detección de memoria
- **Torokai**: Elimina scripts de detección
- **Wu**: Bloquea módulos anti-cheat

## 📞 Soporte

Si tienes problemas:
1. Verifica que Velocity esté actualizado
2. Reinicia Roblox e intenta de nuevo
3. Revisa que Death Ball esté funcionando correctamente

## ⭐ Disfruta dominando Death Ball

¡Este script te convertirá en el jugador más temido de Death Ball! 🏐🔥

---
*Script creado específicamente para el dueño de Death Ball*
*Versión: 2.0 - Completa y Optimizada*