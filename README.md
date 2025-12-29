# ANTIGRAVITY GOOGLE ASSISTANT v5.5 (Redmi Note 11 Pro 4G)
**Triple Mode System - Sistema de 3 Modos de Operación**

Este repositorio es el centro de control definitivo para transformar tu terminal MediaTek en una experiencia Google pura y certificada. Diseñado bajo estándares de seguridad forense para el chipset Helio G96.

## 🚀 Antigravity Google Experience
A diferencia de otros scripts, esta edición "Google" se enfoca en tres pilares:
1.  **Certificación GMS:** Herramientas para registrar tu dispositivo y usar Google Wallet/GPay.
2.  **Seguridad Anti-Brick:** Sistema de validación de integridad de backups que bloquea restauraciones corruptas.
3.  **Flujo Optimizado:** Menú estructurado por pasos lógicos (Preparación -> Backup -> Flasheo -> Auditoría).

## ✨ Novedades v5.5 - Triple Mode System

### 🎮 Sistema de 3 Modos de Operación (NUEVO)

El script ahora ofrece **3 modos claramente diferenciados** para adaptarse a diferentes niveles de experiencia:

#### 1️⃣ Modo DEMO (Por Defecto) 🔵
- **NO ejecuta operaciones reales**
- Ideal para aprender y practicar
- Muestra comandos pero no los ejecuta
- **SEGURO**: No puede dañar tu dispositivo
- Perfecto para entender el proceso antes de hacerlo real

#### 2️⃣ Modo GUIADO 🟢
- **EJECUTA operaciones REALES**
- Valida todos los prerequisitos
- No permite saltar pasos críticos
- Verifica batería (80% mínimo)
- Verifica espacio en disco (10 GB mínimo)
- Requiere backup antes de flashear
- **Recomendado para usuarios con experiencia**

#### 3️⃣ Modo EXPERTO 🔴
- **EJECUTA operaciones REALES**
- Permite saltar pasos
- Sin validaciones de seguridad
- **PELIGROSO**: Solo para usuarios avanzados
- Requiere confirmación explícita: "SI ESTOY SEGURO"

### 🔄 Cómo Cambiar de Modo

Presiona **M** en el menú principal para acceder al selector de modos:
```
M. Cambiar Modo de Operacion (DEMO/GUIADO/EXPERTO)
```

El sistema te mostrará:
- Modo actual
- Descripción detallada de cada modo
- Confirmaciones de seguridad para modos GUIADO y EXPERTO

### 🔍 Transparencia Técnica
- **Comandos visibles**: Cada paso muestra los comandos técnicos exactos
- **Modo claramente indicado**: El menú principal muestra el modo actual con color:
  - 🔵 DEMO = Magenta
  - 🟢 GUIADO = Verde
  - 🔴 EXPERTO = Rojo
- **Advertencias contextuales**: En pasos críticos, se muestra si se ejecutarán comandos reales

### 🎯 Sistema de Progreso Visual
- Indicador en tiempo real de qué pasos has completado
- Marcas visuales [V] para pasos completados, [ ] para pendientes
- Seguimiento del flujo de trabajo recomendado

### 🛡️ Validación Inteligente de Requisitos
- **Modo DEMO**: Sin validaciones (es solo demostración)
- **Modo GUIADO**: Validación estricta de todos los prerequisitos
- **Modo EXPERTO**: Sin validaciones (bajo tu responsabilidad)

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
- **Requisito mínimo 80%**: No permite flashear con batería baja (en modo GUIADO)
- **Fallback manual**: Si no puede detectar, solicita confirmación del usuario
- **Previene bricks**: Evita apagados durante el flasheo

### 🆘 Recuperación de Emergencia
- Opción dedicada (7) para situaciones de bootloop
- Guía paso a paso para entrar en modo BROM
- Lista de backups disponibles para restauración
- Instrucciones claras para usar mtkclient

## 📚 Comandos Técnicos Mostrados

El script muestra los comandos exactos que necesitas ejecutar en modo GUIADO o EXPERTO:

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
*   **Safe Operations (v5.5):** Guía de seguridad física integrada (checklist de carga, cables y conexiones).
*   **Kernel BPF Fix:** Parcheo automático del kernel (boot.img) para restaurar Internet en Android 14/15.
*   **Auditoría Forense:** Generación de certificados de salud (`CERTIFICADO_FINAL.txt`) para validar cada byte del sistema.
*   **Kit de Banca:** Todo lo necesario para Magisk, Shamiko y Play Integrity Fix pre-configurado.

## 📂 Estructura del Ecosistema
*   `Instalar_GSI_RedmiNote11Pro.ps1`: **Script Maestro v5.5**. El motor de todo el proceso.
*   `GOOGLE_EXPERIENCE.md`: Guía definitiva para pagos NFC y registro Google Service Framework.
*   `MANUAL_DE_USO.md`: Instrucciones paso a paso con "Reglas de Oro" de seguridad.
*   `certificador_salud.ps1`: Utilidad de auditoría técnica.
*   `antigravity_session.log`: Log de todas las operaciones (se crea automáticamente).

## 🛡️ Seguridad y Confianza
El proyecto incluye un sistema de **Auditoría Forense** que valida:
*   Integridad de binarios (ADB/Fastboot).
*   Presencia de módulos de seguridad bancaria.
*   Check de escritura de particiones críticas.
*   Nivel de batería antes de operaciones críticas (modo GUIADO).
*   Espacio en disco disponible.

## ⚠️ Disclaimer
El flasheo es un proceso de riesgo. Este asistente minimiza el error humano mediante validaciones automáticas, pero la responsabilidad final recae en el operador. **Sigue siempre las Reglas de Oro detalladas en el manual.**

## 📝 Changelog v5.5

### Añadido
- **Sistema de 3 Modos**: DEMO, GUIADO y EXPERTO claramente diferenciados
- **Selector de Modo (M)**: Interfaz dedicada para cambiar entre modos
- **Confirmaciones de Seguridad**: Diferentes niveles según el modo seleccionado
- **Indicador Visual de Modo**: Color dinámico según el modo actual
- **Advertencias Contextuales**: En pasos críticos se indica si se ejecutarán comandos reales
- Transparencia Técnica: Comandos visibles en cada paso
- Sistema de progreso visual con tracking de pasos completados
- Validación automática de prerequisitos (modo GUIADO)
- Sistema de logs persistente (`antigravity_session.log`)
- Verificación automática de espacio en disco
- Verificación automática de batería del dispositivo vía ADB
- Opción de Recuperación de Emergencia

### Mejorado
- **Claridad total sobre modos de operación**
- Descripciones más detalladas en cada paso
- Mejor feedback visual con colores contextuales
- Mensajes de error más claros y accionables
- Confirmaciones explícitas antes de operaciones destructivas

### Seguridad
- Modo DEMO por defecto (no puede dañar el dispositivo)
- Confirmación "SI" para modo GUIADO
- Confirmación "SI ESTOY SEGURO" para modo EXPERTO
- Bloqueo automático de flasheo sin backup previo (modo GUIADO)
- Requisito mínimo de 80% de batería para flasheo (modo GUIADO)
- Advertencia de espacio en disco insuficiente
- Log completo de todas las operaciones para auditoría

---
**Desarrollado por Antigravity AI - Triple Mode System v5.5**
