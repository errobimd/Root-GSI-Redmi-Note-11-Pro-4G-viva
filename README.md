# ANTIGRAVITY GOOGLE ASSISTANT v5.4.2 (Redmi Note 11 Pro 4G)
**Technical Transparency Edition - Automatización de Élite para GSI**

Este repositorio es el centro de control definitivo para transformar tu terminal MediaTek en una experiencia Google pura y certificada. Diseñado bajo estándares de seguridad forense para el chipset Helio G96.

## 🚀 Antigravity Google Experience
A diferencia de otros scripts, esta edición "Google" se enfoca en tres pilares:
1.  **Certificación GMS:** Herramientas para registrar tu dispositivo y usar Google Wallet/GPay.
2.  **Seguridad Anti-Brick:** Sistema de validación de integridad de backups que bloquea restauraciones corruptas.
3.  **Flujo Optimizado:** Menú estructurado por pasos lógicos (Preparación -> Backup -> Flasheo -> Auditoría).

## ✨ Novedades v5.4.2 - Technical Transparency Edition

### 🔍 Transparencia Técnica (NUEVO)
- **Comandos visibles**: Cada paso muestra los comandos técnicos exactos que se ejecutarían
- **Modo claramente indicado**: Distinción visual entre SIMULACIÓN y OPERACIÓN REAL
- **Educativo**: Aprende exactamente qué comandos usar para operaciones reales
- **Verificable**: Los usuarios avanzados pueden revisar los comandos antes de ejecutar

### 🎯 Sistema de Progreso Visual
- Indicador en tiempo real de qué pasos has completado
- Marcas visuales [V] para pasos completados, [ ] para pendientes
- Seguimiento del flujo de trabajo recomendado

### 🛡️ Validación Inteligente de Requisitos
- **Bloqueo automático**: No puedes flashear sin hacer backup primero
- **Advertencias contextuales**: El sistema te avisa si intentas saltar pasos críticos
- **Modo Guiado vs Experto**: Elige entre máxima seguridad o control total

### 📊 Sistema de Logs Persistente
- Archivo `antigravity_session.log` con todas las acciones realizadas
- Timestamps precisos para debugging
- Útil para soporte técnico si algo sale mal

### 💾 Verificación de Espacio en Disco
- Comprueba automáticamente que tienes al menos 10 GB libres
- Advertencia temprana antes de iniciar backups o descargas
- Previene fallos por falta de espacio

### 🔋 Verificación Automática de Batería
- **Detección automática vía ADB**: Lee el nivel de batería del dispositivo
- **Requisito mínimo 80%**: No permite flashear con batería baja
- **Fallback manual**: Si no puede detectar, solicita confirmación del usuario
- **Previene bricks**: Evita apagados durante el flasheo

### 🆘 Recuperación de Emergencia
- Opción dedicada (7) para situaciones de bootloop
- Guía paso a paso para entrar en modo BROM
- Lista de backups disponibles para restauración
- Instrucciones claras para usar mtkclient

## 📚 Modo de Operación: Demostración/Simulación

**IMPORTANTE**: Este script opera en modo **DEMOSTRACIÓN/SIMULACIÓN** por defecto:

- ✅ **Paso 1 (Verificación)**: Operación REAL - Verifica archivos y espacio en disco
- 🔵 **Paso 2 (Backup)**: SIMULACIÓN - Crea archivos de prueba, no conecta al dispositivo
- ✅ **Paso 3 (Kit Banca)**: Operación REAL - Verifica archivos en carpeta Descargas
- 🔵 **Paso 4 (Flasheo)**: SIMULACIÓN - Muestra comandos pero no flashea
- ✅ **Paso 5 (Auditoría)**: Operación REAL - Ejecuta script de certificación

### 🛠️ Para Operaciones Reales:

El script muestra los comandos técnicos exactos que necesitas ejecutar:

**Backup Real:**
```bash
python mtk r nvram,boot,vbmeta .\Backups\[fecha]
```

**Flasheo Real:**
```bash
adb reboot fastboot
fastboot reboot fastboot
fastboot erase userdata
fastboot flash system .\ROMs\system.img
fastboot -w
fastboot reboot
```

## 🛠️ Funcionalidades Maestras
*   **Safe Operations (v5.4):** Guía de seguridad física integrada (checklist de carga, cables y conexiones).
*   **Kernel BPF Fix:** Parcheo automático del kernel (boot.img) para restaurar Internet en Android 14/15.
*   **Auditoría Forense:** Generación de certificados de salud (`CERTIFICADO_FINAL.txt`) para validar cada byte del sistema.
*   **Kit de Banca:** Todo lo necesario para Magisk, Shamiko y Play Integrity Fix pre-configurado.

## 📂 Estructura del Ecosistema
*   `Instalar_GSI_RedmiNote11Pro.ps1`: **Script Maestro v5.4.2**. El motor de todo el proceso.
*   `GOOGLE_EXPERIENCE.md`: Guía definitiva para pagos NFC y registro Google Service Framework.
*   `MANUAL_DE_USO.md`: Instrucciones paso a paso con "Reglas de Oro" de seguridad.
*   `certificador_salud.ps1`: Utilidad de auditoría técnica.
*   `antigravity_session.log`: Log de todas las operaciones (se crea automáticamente).

## 🎮 Modos de Operación

### Modo Guiado (Por Defecto)
- Máxima seguridad
- Valida todos los prerequisitos
- No permite saltar pasos críticos
- Recomendado para usuarios sin experiencia

### Modo Experto (Opción E)
- Control total sobre el proceso
- Permite saltar pasos (bajo tu responsabilidad)
- Para usuarios avanzados que saben lo que hacen
- ⚠️ Puede ser peligroso si se usa incorrectamente

## 🛡️ Seguridad y Confianza
El proyecto incluye un sistema de **Auditoría Forense** que valida:
*   Integridad de binarios (ADB/Fastboot).
*   Presencia de módulos de seguridad bancaria.
*   Check de escritura de particiones críticas.
*   Nivel de batería antes de operaciones críticas.
*   Espacio en disco disponible.

## ⚠️ Disclaimer
El flasheo es un proceso de riesgo. Este asistente minimiza el error humano mediante validaciones automáticas, pero la responsabilidad final recae en el operador. **Sigue siempre las Reglas de Oro detalladas en el manual.**

## 📝 Changelog v5.4.2

### Añadido
- **Transparencia Técnica**: Comandos visibles en cada paso
- **Indicadores de Modo**: Distinción clara entre SIMULACIÓN y OPERACIÓN REAL
- **Nota en Menú Principal**: Advertencia sobre modo demostración
- Sistema de progreso visual con tracking de pasos completados
- Validación automática de prerequisitos antes de cada paso
- Sistema de logs persistente (`antigravity_session.log`)
- Verificación automática de espacio en disco
- Verificación automática de batería del dispositivo vía ADB
- Modo Experto vs Modo Guiado
- Opción de Recuperación de Emergencia

### Mejorado
- Descripciones más detalladas en cada paso
- Mejor feedback visual con colores contextuales
- Mensajes de error más claros y accionables
- Confirmaciones explícitas antes de operaciones destructivas
- **Claridad sobre simulación vs operaciones reales**

### Seguridad
- Bloqueo automático de flasheo sin backup previo
- Requisito mínimo de 80% de batería para flasheo
- Advertencia de espacio en disco insuficiente
- Log completo de todas las operaciones para auditoría

---
**Desarrollado por Antigravity AI - Technical Transparency Edition v5.4.2**
