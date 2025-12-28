# MANUAL DE OPERACIÓN: Security & Banking Edition (v4.5)
**Solución para Apps de Banca y Certificación Google en Redmi Note 11 Pro 4G**

---

## 📋 Introducción
Las aplicaciones de bancos (BBVA, Santander, Bancopel, etc.) detectan si el teléfono tiene el bootloader desbloqueado o una ROM GSI. Este kit incluye las herramientas necesarias para ocultar estas modificaciones y permitir el uso normal de tus aplicaciones financieras.

---

## 🏦 Cómo hacer que funcionen tus Apps de Banca (5 Pasos)

### **Paso 1: Descargar el Kit de Seguridad**
En el script principal (`v4.5`), usa la **Opción 2: PREPARAR APPS DE BANCA**. Esto descargará en tu carpeta `Descargas/`:
*   `Magisk.apk`
*   `PlayIntegrityFix.zip`
*   `Shamiko.zip`

### **Paso 2: Instalación de Magisk**
Una vez tengas la ROM GSI funcionando:
1.  Pasa el archivo `Magisk.apk` a tu teléfono e instálalo.
2.  Abre Magisk, ve a ⚙️ (Ajustes) y activa la opción **Zygisk**.
3.  Reinicia el teléfono.

### **Paso 3: Instalar Módulos**
1.  En Magisk, ve a la pestaña **Módulos**.
2.  Pulsa "Instalar desde almacenamiento" y elige `PlayIntegrityFix.zip`.
3.  Repite el proceso para `Shamiko.zip`.
4.  Reinicia el teléfono.

### **Paso 4: Ocultar Magisk (DenyList)**
1.  Abre Magisk > ⚙️ Ajustes > **Configurar DenyList**.
2.  Pulsa los 3 puntos (arriba a la derecha) y marca "Mostrar apps de sistema".
3.  Busca y marca todas las casillas de:
    *   **Google Play Services** (especialmente `com.google.android.gms.unstable`).
    *   **Google Play Store**.
    *   **Tus aplicaciones de banco**.
4.  **⚠️ IMPORTANTE:** Asegúrate de que "Enforce DenyList" (Forzar DenyList) esté **APAGADO** si vas a usar Shamiko (Shamiko lo gestiona mejor).

### **Paso 5: Limpieza de Datos**
Ajustes del sistema > Aplicaciones > Ver todas:
1.  Busca **Google Play Store** -> Almacenamiento -> **Borrar Datos**.
2.  Busca **Google Play Services** -> Almacenamiento -> **Borrar Datos**.
3.  Reinicia por última vez.

---

## ✅ Verificación
Descarga la app **"YASNAC"** o **"Play Integrity API Checker"** de la Play Store. Deberías obtener un "PASS" en:
*   `Basic Integrity`
*   `Device Integrity`

Si ambos están en verde, tus apps de banco funcionarán perfectamente.

---
**Desarrollado por Antigravity AI - v4.5 Security Edition**
