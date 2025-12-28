# Automatización de GSI para Redmi Note 11 Pro 4G (viva)

Este repositorio contiene un conjunto de herramientas automatizadas para instalar ROMs Genéricas del Sistema (GSI) en el dispositivo **Xiaomi Redmi Note 11 Pro 4G** (nombre en clave: *viva*), basado en el chipset MediaTek Helio G96.

## 🚀 Funcionalidades Principales

El script principal, `Instalar_GSI_RedmiNote11Pro.ps1`, ha sido diseñado para simplificar un proceso técnico complejo en un flujo de trabajo seguro y auditado:

1.  **Gestión de Dependencias (Auto-Install):**
    *   Descarga e instala automáticamente **ADB y Fastboot** (Platform Tools de Google).
    *   Instala y configura **Python** y las librerías necesarias (`mtkclient`, `capstone`, `keystone`).
    *   Descarga la herramienta crítica **mtk-bpf-patcher** para corregir problemas de red en Android 14/15.

2.  **Seguridad Anti-Brick (MTKClient):**
    *   Realiza copias de seguridad profundas (Raw Dump) de particiones vitales: `nvram` (IMEI), `boot`, `vbmeta`, `protect1/2`, `seccfg`.
    *   Permite la restauración completa del dispositivo a su estado anterior en caso de fallo, interactuando directamente con el modo BROM.

3.  **Corrección de Bugs Críticos:**
    *   **BPF Fix:** Aplica parches binarios al kernel (`boot.img`) automáticamente para solucionar la falta de conectividad en GSI modernas (debido al kernel legacy 4.14).
    *   **Overlay:** Facilita la descarga del overlay necesario para corregir el brillo de la pantalla.

4.  **Simulación (Modo Demo):**
    *   Permite a los usuarios visualizar todo el proceso de flasheo y parcheo sin conectar el dispositivo físico, ideal para aprendizaje y verificación.

## 📂 Estructura del Proyecto

*   `Instalar_GSI_RedmiNote11Pro.ps1`: **Script Maestro**. Ejecútalo con PowerShell.
*   `Herramientas/`: Directorio donde se instalan los binarios (ADB, Patcher, etc.).
*   `Descargas/`: Zona temporal para archivos bajados de internet.
*   `Backups/`: Almacén de seguridad para tus copias de `nvram` y `boot`.
*   `ROMs/`: Carpeta donde debes colocar tu imagen `system.img` (LineageOS, PixelExp, etc.).
*   `leer_docs.py`: Utilidad interna para extraer enlaces de la documentación original.

## 🛠️ Requisitos Previos

*   **PC con Windows 10/11** y PowerShell.
*   **Python 3.x** instalado y añadido al PATH.
*   **Cable USB** de buena calidad.
*   Dispositivo con **Bootloader Desbloqueado**.

## ⚠️ Advertencia

El flasheo de ROMs y la manipulación de particiones conllevan riesgos. Aunque este script incluye medidas de seguridad (Backups), el autor no se hace responsable de daños en el dispositivo. Sigue las instrucciones con cuidado.

## 🔗 Créditos y Referencias

*   **mtk-bpf-patcher:** [R0rt1z2](https://github.com/R0rt1z2/mtk-bpf-patcher)
*   **mtkclient:** [bkerler](https://github.com/bkerler/mtkclient)
*   **Documentación Base:** xiaomi-mt6781-devs
