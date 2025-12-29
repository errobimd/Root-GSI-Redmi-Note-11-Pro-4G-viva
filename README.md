# ANTIGRAVITY GOOGLE ASSISTANT v5.6 (Redmi Note 11 Pro 4G)
**Smart Assistant Edition - IA Inteligente con Detección Automática**

Este repositorio es el centro de control definitivo para transformar tu terminal MediaTek en una experiencia Google pura y certificada. Diseñado bajo estándares de seguridad forense para el chipset Helio G96.

## 🚀 Antigravity Google Experience
A diferencia de otros scripts, esta edición "Google" se enfoca en tres pilares:
1.  **Certificación GMS:** Herramientas para registrar tu dispositivo y usar Google Wallet/GPay.
2.  **Seguridad Anti-Brick:** Sistema de validación de integridad de backups que bloquea restauraciones corruptas.
3.  **Flujo Optimizado:** Menú estructurado por pasos lógicos (Preparación -> Backup -> Flasheo -> Auditoría).

## ✨ Novedades v5.6 - Smart Assistant Edition

### 📝 1. Sistema de Perfiles de Usuario (NUEVO)

**Persistencia Inteligente:**
- 💾 Guarda automáticamente tu progreso en `user_profile.json`
- 🔄 Restaura tu modo preferido y pasos completados al reiniciar
- 📊 Tracking de última sesión y fecha de último backup
- ⚙️ Configuraciones personalizadas persistentes

**Qué se guarda:**
```json
{
  "preferred_mode": "GUIADO",
  "last_session": "2025-12-29 17:00:00",
  "completed_steps": ["Step1_Environment", "Step2_Backup"],
  "device_verified": true,
  "last_backup_date": "2025-12-29"
}
```

### 🔒 2. Verificación de Integridad de Archivos (NUEVO)

**Seguridad Criptográfica:**
- ✅ Validación SHA256 de todos los archivos críticos
- 🛡️ Detección de archivos corruptos o maliciosos
- 📊 Base de datos de hashes verificados (`file_hashes.db`)
- 🔍 Calcula y muestra hash para verificación manual si no hay referencia

**Archivos Verificados:**
- Magisk.apk
- Shamiko.zip
- PlayIntegrityFork.zip
- Platform Tools (ADB/Fastboot)

**Ejemplo de Salida:**
```
[V] Magisk v27.0 encontrado
  Verificando integridad... OK
[V] Magisk v27.0 - Integridad verificada
```

### 📱 3. Detección Automática de Dispositivo (NUEVO)

**Protección Anti-Brick:**
- 🔍 Detecta automáticamente el dispositivo conectado vía ADB
- ✅ Verifica que sea Redmi Note 11 Pro 4G (codename: viva)
- ⚠️ Bloquea operaciones si el dispositivo es incorrecto
- 📊 Muestra información completa del dispositivo

**Información Detectada:**
```
DISPOSITIVO DETECTADO:
  Modelo: Redmi Note 11 Pro 4G
  Codename: viva
  Android: 13

[V] Dispositivo correcto: Redmi Note 11 Pro 4G (viva)
```

**Protección:**
- Si detecta un dispositivo diferente, muestra advertencia crítica
- Requiere confirmación explícita para continuar
- Previene flasheos accidentales en dispositivos incompatibles

### 🎮 Sistema de 3 Modos de Operación

El script ofrece **3 modos claramente diferenciados**:

#### 1️⃣ Modo DEMO (Por Defecto) 🔵
- **NO ejecuta operaciones reales**
- Ideal para aprender y practicar
- Muestra comandos pero no los ejecuta
- **SEGURO**: No puede dañar tu dispositivo

#### 2️⃣ Modo GUIADO 🟢
- **EJECUTA operaciones REALES**
- Valida todos los prerequisitos
- Verifica dispositivo correcto
- Verifica batería (80% mínimo)
- Verifica espacio en disco (10 GB mínimo)
- Verifica integridad de archivos
- **Recomendado para usuarios con experiencia**

#### 3️⃣ Modo EXPERTO 🔴
- **EJECUTA operaciones REALES**
- Permite saltar pasos
- Sin validaciones de seguridad
- **PELIGROSO**: Solo para usuarios avanzados

### 🔄 Cómo Cambiar de Modo

Presiona **M** en el menú principal para acceder al selector de modos.

### 🔍 Transparencia Técnica
- **Comandos visibles**: Cada paso muestra los comandos técnicos exactos
- **Modo claramente indicado**: El menú principal muestra el modo actual con color
- **Advertencias contextuales**: En pasos críticos se indica si se ejecutarán comandos reales

### 🎯 Otras Características
- Sistema de progreso visual con tracking de pasos completados
- Validación inteligente de prerequisitos
- Sistema de logs persistente (`antigravity_session.log`)
- Verificación automática de espacio en disco
- Verificación automática de batería del dispositivo vía ADB
- Opción de Recuperación de Emergencia

## 📚 Comandos Técnicos Mostrados

El script muestra los comandos exactos que necesitas ejecutar:

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
*   **Safe Operations (v5.6):** Guía de seguridad física integrada.
*   **Kernel BPF Fix:** Parcheo automático del kernel (boot.img).
*   **Auditoría Forense:** Generación de certificados de salud.
*   **Kit de Banca:** Magisk, Shamiko y Play Integrity Fix pre-configurado.
*   **Detección de Dispositivo:** Verifica que sea el modelo correcto.
*   **Verificación de Integridad:** Valida archivos con SHA256.
*   **Perfiles de Usuario:** Guarda y restaura tu progreso.

## 📂 Estructura del Ecosistema
*   `Instalar_GSI_RedmiNote11Pro.ps1`: **Script Maestro v5.6**
*   `user_profile.json`: Perfil de usuario con progreso guardado
*   `file_hashes.db`: Base de datos de hashes SHA256
*   `antigravity_session.log`: Log de todas las operaciones
*   `GOOGLE_EXPERIENCE.md`: Guía para pagos NFC y certificación
*   `MANUAL_DE_USO.md`: Instrucciones paso a paso
*   `certificador_salud.ps1`: Utilidad de auditoría técnica

## 🛡️ Seguridad y Confianza

**Capas de Seguridad:**
1. 📱 **Detección de Dispositivo**: Verifica que sea el modelo correcto
2. 🔒 **Verificación de Integridad**: Valida archivos con SHA256
3. 🔋 **Verificación de Batería**: Mínimo 80% para flasheo
4. 💾 **Verificación de Espacio**: Mínimo 10 GB libres
5. ✅ **Validación de Prerequisitos**: No permite saltar pasos críticos (modo GUIADO)
6. 📝 **Logs Completos**: Auditoría de todas las operaciones
7. 💾 **Perfiles Persistentes**: Tracking de progreso

## ⚠️ Disclaimer
El flasheo es un proceso de riesgo. Este asistente minimiza el error humano mediante validaciones automáticas, pero la responsabilidad final recae en el operador. **Sigue siempre las Reglas de Oro detalladas en el manual.**

## 📝 Changelog v5.6

### Añadido
- 📝 **Sistema de Perfiles de Usuario**: Guarda y restaura progreso automáticamente
- 🔒 **Verificación de Integridad SHA256**: Valida archivos críticos
- 📱 **Detección Automática de Dispositivo**: Previene flasheos en dispositivos incorrectos
- 📊 Base de datos de hashes verificados (`file_hashes.db`)
- 💾 Archivo de perfil de usuario (`user_profile.json`)
- ✅ Guardado automático de progreso al completar cada paso
- 🔄 Carga automática de preferencias al iniciar

### Mejorado
- 🛡️ Seguridad mejorada con 3 capas adicionales de validación
- 📊 Mejor tracking de progreso del usuario
- 🔍 Feedback más detallado sobre estado de archivos
- ⚠️ Advertencias más claras sobre dispositivos incorrectos

### Seguridad
- 🚫 Bloqueo automático si el dispositivo no es "viva"
- 🔒 Detección de archivos corruptos o maliciosos
- 💾 Persistencia de configuraciones de seguridad
- 📝 Auditoría completa de todas las operaciones

---
**Desarrollado por Antigravity AI - Smart Assistant Edition v5.6**

**¿Te gusta el proyecto? Dale una ⭐ en GitHub!**
