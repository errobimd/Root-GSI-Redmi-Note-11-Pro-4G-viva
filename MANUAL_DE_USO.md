# MANUAL DE OPERACIÓN: Redmi Note 11 Pro GSI Toolkit (v4.2)
**Herramienta de Automatización "Anti-Brick" para Xiaomi Redmi Note 11 Pro 4G (viva)**

---

## 📋 Introducción
Este script permite instalar ROMs Genéricas (GSI) basadas en Android 14/15 en tu dispositivo, solucionando automáticamente los problemas de compatibilidad (falta de red, brillo) y protegiendo tu teléfono con copias de seguridad profundas.

## 🚀 Cómo Iniciar
1.  Asegúrate de tener **Internet** (para descargar herramientas).
2.  Haz clic derecho en el archivo `Instalar_GSI_RedmiNote11Pro.ps1`.
3.  Selecciona **"Ejecutar con PowerShell"**.

---

## 🎮 Menú Principal: Explicación de Opciones

### **[1] Instalar Herramientas**
*   **Qué hace:** Descarga ADB, Fastboot, Drivers MTK y el Parcheador de Kernel automáticamente.
*   **Cuándo usar:** La primera vez que abras el script o si cambias de PC.

### **[2] Simulación FLASH GSI (Demo)**
*   **Qué hace:** Muestra una "película" de cómo se verá el proceso de flasheo. No toca tu teléfono.
*   **Cuándo usar:** Para familiarizarte con los mensajes y pasos antes de hacerlo de verdad.

### **[3] Simulación BACKUP TOTAL + RESTORE (Demo)**
*   **Qué hace:** Demuestra cómo el script guarda y recupera todo tu sistema en caso de desastre.
*   **Cuándo usar:** Para entender cómo funciona el sistema "Anti-Brick".

### **[4] Modo REAL: Flashear GSI** ⚠️
*   **Qué hace:** Instala la ROM real en tu teléfono. **BORRARÁ TUS DATOS.**
*   **Requisitos:** 
    *   Copia tu ROM GSI (`system.img`) a la carpeta `ROMs`.
    *   Teléfono conectado en modo BROM (Apagado, mantén Vol+ y Vol-).

### **[5] Modo REAL: Backup Completo** 🛡️
*   **Qué hace:** Guarda una copia exacta de tu IMEI, Arranque y Seguridad.
*   **Cuándo usar:** **SIEMPRE** antes de intentar cualquier modificación.

### **[6] Modo REAL: Restaurar Emergencia** 🚑
*   **Qué hace:** Si tu teléfono no arranca (Brick), usa esta opción para revivirlo usando un backup previo.
*   **Requisitos:** Haber hecho un backup con la Opción 5 anteriormente.

---

## 🔧 Glosario Técnico
*   **BROM:** Modo de bajo nivel de MediaTek. Se accede conectando el móvil apagado manteniendo los dos botones de volumen. Es necesario para los Backups profundos.
*   **FastbootD:** Modo especial de Fastboot necesario para flashear ROMs en dispositivos modernos con particiones dinámicas.
*   **BPF Fix:** Parche automático que aplica este script para que tengas Internet en Android 14+.

---
**Desarrollado por Antigravity AI - v4.2 Stable**
