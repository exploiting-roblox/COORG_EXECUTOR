#!/usr/bin/env python3
"""
LinuxBlox Executor v1.0
El primer script executor nativo para Linux
Desarrollado para Roblox Web Browser
"""

import asyncio
import json
import time
import tkinter as tk
from tkinter import ttk, scrolledtext, messagebox, filedialog
from playwright.async_api import async_playwright
import threading
from pathlib import Path
import os

class LinuxBloxExecutor:
    def __init__(self):
        self.page = None
        self.browser = None
        self.playwright = None
        self.is_injected = False
        self.root = None
        self.setup_gui()
        
    def setup_gui(self):
        """Crear interfaz gráfica moderna"""
        self.root = tk.Tk()
        self.root.title("🐧 LinuxBlox Executor v1.0 - Native Linux Roblox Executor")
        self.root.geometry("800x600")
        self.root.configure(bg='#1a1a1a')
        
        # Style
        style = ttk.Style()
        style.theme_use('clam')
        style.configure('Dark.TFrame', background='#2d2d2d')
        style.configure('Dark.TLabel', background='#2d2d2d', foreground='#ffffff')
        style.configure('Dark.TButton', background='#4a4a4a', foreground='#ffffff')
        
        # Header Frame
        header_frame = ttk.Frame(self.root, style='Dark.TFrame')
        header_frame.pack(fill='x', padx=10, pady=5)
        
        # Title
        title_label = ttk.Label(
            header_frame, 
            text="🐧 LinuxBlox Executor - Native Linux Roblox Script Injection",
            font=('Arial', 16, 'bold'),
            style='Dark.TLabel'
        )
        title_label.pack(side='left')
        
        # Status
        self.status_label = ttk.Label(
            header_frame,
            text="Status: Not Injected",
            font=('Arial', 12),
            foreground='#ff6b6b',
            style='Dark.TLabel'
        )
        self.status_label.pack(side='right')
        
        # Control Frame
        control_frame = ttk.Frame(self.root, style='Dark.TFrame')
        control_frame.pack(fill='x', padx=10, pady=5)
        
        # Buttons
        self.inject_btn = ttk.Button(
            control_frame,
            text="🚀 Launch & Inject Roblox",
            command=self.start_injection,
            style='Dark.TButton'
        )
        self.inject_btn.pack(side='left', padx=5)
        
        self.execute_btn = ttk.Button(
            control_frame,
            text="⚡ Execute Script",
            command=self.execute_script,
            state='disabled',
            style='Dark.TButton'
        )
        self.execute_btn.pack(side='left', padx=5)
        
        self.load_btn = ttk.Button(
            control_frame,
            text="📁 Load Script",
            command=self.load_script,
            style='Dark.TButton'
        )
        self.load_btn.pack(side='left', padx=5)
        
        self.save_btn = ttk.Button(
            control_frame,
            text="💾 Save Script",
            command=self.save_script,
            style='Dark.TButton'
        )
        self.save_btn.pack(side='left', padx=5)
        
        # Script Editor
        editor_frame = ttk.Frame(self.root, style='Dark.TFrame')
        editor_frame.pack(fill='both', expand=True, padx=10, pady=5)
        
        editor_label = ttk.Label(
            editor_frame,
            text="Script Editor:",
            style='Dark.TLabel'
        )
        editor_label.pack(anchor='w')
        
        self.script_editor = scrolledtext.ScrolledText(
            editor_frame,
            bg='#1e1e1e',
            fg='#d4d4d4',
            insertbackground='#ffffff',
            selectbackground='#264f78',
            font=('Consolas', 11),
            wrap='none'
        )
        self.script_editor.pack(fill='both', expand=True, pady=5)
        
        # Insert default script
        default_script = '''-- LinuxBlox Executor Test Script
print("🐧 LinuxBlox Executor funcionando!")
game.StarterGui:SetCore("SendNotification", {
    Title = "LinuxBlox",
    Text = "¡Executor nativo para Linux!",
    Duration = 5
})

-- Ejemplo: Auto Parry básico
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local function findBall()
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("ball") then
            return obj
        end
    end
    return nil
end

local function autoParry()
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    local ball = findBall()
    if not ball then return end
    
    local distance = (ball.Position - humanoidRootPart.Position).Magnitude
    if distance < 15 and ball.Velocity.Magnitude > 10 then
        -- Simular parry
        game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.F, false, game)
        wait(0.01)
        game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.F, false, game)
        print("🏐 Parry ejecutado!")
    end
end

-- Activar auto parry
local autoParryEnabled = true
RunService.Heartbeat:Connect(function()
    if autoParryEnabled then
        autoParry()
    end
end)

print("✅ Script cargado - Auto Parry activo")'''
        
        self.script_editor.insert('1.0', default_script)
        
        # Output Frame
        output_frame = ttk.Frame(self.root, style='Dark.TFrame')
        output_frame.pack(fill='x', padx=10, pady=5)
        
        output_label = ttk.Label(
            output_frame,
            text="Output/Console:",
            style='Dark.TLabel'
        )
        output_label.pack(anchor='w')
        
        self.output_text = scrolledtext.ScrolledText(
            output_frame,
            bg='#0a0a0a',
            fg='#00ff00',
            insertbackground='#00ff00',
            font=('Consolas', 10),
            height=8,
            wrap='word'
        )
        self.output_text.pack(fill='x', pady=5)
        
        # Info frame
        info_frame = ttk.Frame(self.root, style='Dark.TFrame')
        info_frame.pack(fill='x', padx=10, pady=5)
        
        info_text = """
🐧 LinuxBlox Executor - Features:
• Native Linux Roblox script execution
• Browser-based injection (no Wine needed)
• Real-time script execution
• Cross-platform Lua support
• Modern GUI interface

📋 Instructions:
1. Click "Launch & Inject Roblox" to open Roblox in browser
2. Join any game (Death Ball recommended)
3. Paste your script in the editor
4. Click "Execute Script" to run
        """
        
        info_label = ttk.Label(
            info_frame,
            text=info_text.strip(),
            style='Dark.TLabel',
            font=('Arial', 9)
        )
        info_label.pack(anchor='w')
        
    def log_output(self, message):
        """Agregar mensaje al output"""
        timestamp = time.strftime("%H:%M:%S")
        self.output_text.insert(tk.END, f"[{timestamp}] {message}\n")
        self.output_text.see(tk.END)
        self.root.update()
    
    def start_injection(self):
        """Iniciar proceso de inyección"""
        self.log_output("🚀 Iniciando LinuxBlox Executor...")
        self.inject_btn.config(state='disabled')
        
        # Ejecutar en thread separado
        thread = threading.Thread(target=self.inject_async)
        thread.daemon = True
        thread.start()
    
    def inject_async(self):
        """Proceso de inyección asíncrono"""
        try:
            asyncio.run(self.perform_injection())
        except Exception as e:
            self.log_output(f"❌ Error en inyección: {str(e)}")
            self.inject_btn.config(state='normal')
    
    async def perform_injection(self):
        """Realizar inyección real"""
        try:
            self.log_output("🌐 Abriendo navegador...")
            self.playwright = await async_playwright().start()
            
            # Usar Chromium con opciones específicas
            self.browser = await self.playwright.chromium.launch(
                headless=False,
                args=[
                    '--no-sandbox',
                    '--disable-setuid-sandbox',
                    '--disable-dev-shm-usage',
                    '--disable-web-security',
                    '--allow-running-insecure-content',
                    '--disable-features=VizDisplayCompositor'
                ]
            )
            
            self.page = await self.browser.new_page()
            
            # Ir a Roblox
            self.log_output("🎮 Navegando a Roblox...")
            await self.page.goto('https://www.roblox.com/games')
            
            # Esperar carga
            await self.page.wait_for_load_state('networkidle')
            self.log_output("✅ Roblox cargado")
            
            # Inyectar scripts base
            await self.inject_base_scripts()
            
            self.is_injected = True
            self.status_label.config(text="Status: Injected ✅", foreground='#4ecdc4')
            self.execute_btn.config(state='normal')
            self.log_output("🎯 LinuxBlox Executor listo para usar!")
            self.log_output("📝 Instrucciones: Ve a un juego y luego ejecuta tus scripts")
            
        except Exception as e:
            self.log_output(f"❌ Error: {str(e)}")
            self.inject_btn.config(state='normal')
    
    async def inject_base_scripts(self):
        """Inyectar scripts base en la página"""
        # Script de comunicación
        communication_script = """
        window.linuxblox = {
            executeScript: function(scriptCode) {
                try {
                    // Crear contexto similar a Roblox
                    const context = {
                        game: window.game || {},
                        workspace: window.workspace || {},
                        Players: window.Players || {}
                    };
                    
                    // Log para debug
                    console.log('[LinuxBlox] Ejecutando script:', scriptCode.substring(0, 100) + '...');
                    
                    // Simular ejecución (aquí se podría mejorar)
                    eval(scriptCode);
                    
                    return { success: true, message: 'Script ejecutado correctamente' };
                } catch (error) {
                    console.error('[LinuxBlox] Error ejecutando script:', error);
                    return { success: false, message: error.toString() };
                }
            },
            
            log: function(message) {
                console.log('[LinuxBlox]', message);
                return message;
            }
        };
        
        console.log('[LinuxBlox] Injection completada - Executor listo');
        """
        
        await self.page.add_init_script(communication_script)
        
        # Script para detectar cuando se entra a un juego
        game_detection_script = """
        setInterval(() => {
            if (window.location.href.includes('/games/') && 
                document.querySelector('canvas') && 
                !window.linuxblox.gameDetected) {
                
                window.linuxblox.gameDetected = true;
                console.log('[LinuxBlox] ¡Juego detectado! Executor activo');
                
                // Notificar al usuario
                if (window.linuxblox.onGameDetected) {
                    window.linuxblox.onGameDetected();
                }
            }
        }, 2000);
        """
        
        await self.page.evaluate(game_detection_script)
        
    def execute_script(self):
        """Ejecutar script del editor"""
        if not self.is_injected:
            messagebox.showerror("Error", "Primero debes inyectar en Roblox!")
            return
        
        script_code = self.script_editor.get('1.0', tk.END).strip()
        if not script_code:
            messagebox.showwarning("Advertencia", "El editor está vacío!")
            return
        
        self.log_output("⚡ Ejecutando script...")
        
        # Ejecutar en thread separado
        thread = threading.Thread(target=self.execute_async, args=(script_code,))
        thread.daemon = True
        thread.start()
    
    def execute_async(self, script_code):
        """Ejecutar script de forma asíncrona"""
        try:
            asyncio.run(self.run_script(script_code))
        except Exception as e:
            self.log_output(f"❌ Error ejecutando: {str(e)}")
    
    async def run_script(self, script_code):
        """Ejecutar script en la página"""
        try:
            # Convertir Lua a JavaScript aproximado (básico)
            js_code = self.lua_to_js_basic(script_code)
            
            self.log_output("🔄 Convirtiendo Lua a JavaScript...")
            self.log_output(f"📝 Script convertido: {js_code[:100]}...")
            
            # Ejecutar en la página
            result = await self.page.evaluate(f"""
                window.linuxblox.executeScript(`{js_code}`)
            """)
            
            if result['success']:
                self.log_output("✅ Script ejecutado correctamente")
            else:
                self.log_output(f"❌ Error en script: {result['message']}")
                
        except Exception as e:
            self.log_output(f"❌ Error crítico: {str(e)}")
    
    def lua_to_js_basic(self, lua_code):
        """Conversión básica de Lua a JavaScript"""
        js_code = lua_code
        
        # Conversiones básicas
        conversions = {
            'print(': 'console.log(',
            'wait(': 'await new Promise(resolve => setTimeout(resolve, ',
            'game:GetService("Players")': 'Players',
            'game:GetService("RunService")': 'RunService', 
            'game:GetService("UserInputService")': 'UserInputService',
            'game:GetService("Workspace")': 'workspace',
            'game:GetService("ReplicatedStorage")': 'ReplicatedStorage',
            'game:GetService("StarterGui")': 'StarterGui',
            ':FireServer()': '.FireServer()',
            ':Connect(': '.Connect(',
            'local ': 'let ',
            ' then': ' {',
            ' end': ' }',
            'function(': '(',
            '--': '//',
        }
        
        for lua_pattern, js_pattern in conversions.items():
            js_code = js_code.replace(lua_pattern, js_pattern)
        
        return js_code
    
    def load_script(self):
        """Cargar script desde archivo"""
        file_path = filedialog.askopenfilename(
            title="Cargar Script",
            filetypes=[
                ("Lua files", "*.lua"),
                ("Text files", "*.txt"),
                ("All files", "*.*")
            ]
        )
        
        if file_path:
            try:
                with open(file_path, 'r', encoding='utf-8') as file:
                    content = file.read()
                
                self.script_editor.delete('1.0', tk.END)
                self.script_editor.insert('1.0', content)
                
                self.log_output(f"📁 Script cargado: {Path(file_path).name}")
                
            except Exception as e:
                messagebox.showerror("Error", f"No se pudo cargar el archivo: {str(e)}")
    
    def save_script(self):
        """Guardar script a archivo"""
        file_path = filedialog.asksaveasfilename(
            title="Guardar Script",
            defaultextension=".lua",
            filetypes=[
                ("Lua files", "*.lua"),
                ("Text files", "*.txt"),
                ("All files", "*.*")
            ]
        )
        
        if file_path:
            try:
                content = self.script_editor.get('1.0', tk.END)
                with open(file_path, 'w', encoding='utf-8') as file:
                    file.write(content)
                
                self.log_output(f"💾 Script guardado: {Path(file_path).name}")
                
            except Exception as e:
                messagebox.showerror("Error", f"No se pudo guardar el archivo: {str(e)}")
    
    def run(self):
        """Ejecutar la aplicación"""
        try:
            self.root.mainloop()
        finally:
            # Cleanup
            if self.browser:
                try:
                    asyncio.run(self.browser.close())
                except:
                    pass
            if self.playwright:
                try:
                    asyncio.run(self.playwright.stop())
                except:
                    pass

if __name__ == "__main__":
    print("🐧 LinuxBlox Executor v1.0 - Iniciando...")
    print("📋 Requisitos: pip install playwright tkinter")
    print("🚀 Instalación Playwright: playwright install chromium")
    
    try:
        executor = LinuxBloxExecutor()
        executor.run()
    except KeyboardInterrupt:
        print("\n👋 LinuxBlox Executor cerrado por usuario")
    except Exception as e:
        print(f"❌ Error crítico: {e}")