# MANUAL DE OPERACIÓN: Ironclad Edition (v4.6)
**Seguridad Extrema en Flasheo y Banca para Redmi Note 11 Pro 4G**

---

## 📋 Introducción
Este manual detalla el uso del asistente v4.6, diseñado para ser el método más seguro de instalación de GSI. Incluye protección contra "bricks" y un kit completo para aplicaciones financieras.

---

## 🛡️ Seguridad Anti-Brick (Nuevo en v4.6)
El script ahora incluye un sistema de auditoría de backups:
1.  **Validación de Archivos**: Antes de restaurar, el script verifica que los archivos `.img` no estén vacíos. Si un backup falló durante la creación, el sistema bloqueará la restauración para evitar dañar el móvil.
2.  **Particiones Críticas**: El sistema resguarda `nvram` (IMEI), `boot` (Arranque) y `vbmeta` (Seguridad).
3.  **Consejo**: Realiza un backup (Opción 2) inmediatamente antes de cualquier flasheo.

---

## 🏦 Cómo hacer que funcionen tus Apps de Banca
(Pasos simplificados para v4.6)

### **Paso 1: Preparación**
Usa la opción de **Kit de Banca** en el script para tener `Magisk.apk`, `PlayIntegrityFork.zip` y `Shamiko.zip` listos en tu carpeta `Descargas/`.

### **Paso 2: Instalación y Zygisk**
1. Instala `Magisk.apk`.
2. En Ajustes de Magisk, activa **Zygisk** y reinicia.

### **Paso 3: Módulos de Integridad**
1. Instala en este orden: `PlayIntegrityFork.zip` y luego `Shamiko.zip`.
2. Reinicia.

### **Paso 4: Configuración de Ocultación**
1. En Ajustes de Magisk -> **Configurar DenyList**, marca los bancos y los Servicios de Google.
2. **IMPORTANTE**: Mantén "Enforce DenyList" **DESACTIVADO** (Shamiko se encarga de esto de forma más inteligente).

### **Paso 5: Limpieza Final**
Borra datos de Google Play Store y Servicios de Google Play, y reinicia.

---

## ✅ Verificación final
Usa "Play Integrity API Checker". Si obtienes verde en `Basic` y `Device`, tus bancos funcionarán al 100%.

---
**Desarrollado por Antigravity AI - v4.6 Ironclad Guard**
