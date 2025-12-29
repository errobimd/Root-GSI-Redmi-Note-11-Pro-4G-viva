# MANUAL DE RESTAURACIÓN TOTAL - REDMI NOTE 11 PRO 4G (viva)

Este documento garantiza que puedas recuperar tu teléfono al estado original (MIUI Stock) y recuperar tus datos.

## 🟢 ESCENARIO A: Solo quieres recuperar tus fotos/docs
Si instalaste la GSI y todo funciona, pero quieres tus archivos de vuelta:
1. Conecta el móvil al PC.
2. Abre una terminal en la carpeta del proyecto.
3. Ejecuta: `.\Herramientas\platform-tools\adb.exe push "Backups\TU_CARPETA_BACKUP\*" /sdcard/`
4. Tus fotos, vídeos y descargas volverán a aparecer en tu galería.

## 🟡 ESCENARIO B: La GSI da errores y quieres volver a MIUI (Xiaomi Oficial)
Si el teléfono no arranca bien o no te gusta la GSI:
1. Descarga la **ROM Fastboot Oficial de Xiaomi** (Global o Europea para 'viva').
2. Extrae la ROM en tu PC.
3. Pon el móvil en modo **FASTBOOT** (Volumen Abajo + Encendido).
4. Ejecuta el archivo `flash_all.bat` de la carpeta de la ROM. 
5. **IMPORTANTE**: No uses el `flash_all_lock.bat` a menos que quieras bloquear el bootloader (no recomendado hasta estar seguro).
6. Una vez en MIUI, usa el **Paso A** para recuperar tus archivos.

## 🔴 ESCENARIO C: Sin señal de red o IMEI (Error Crítico)
Si después de mucho trastear pierdes la señal:
1. Necesitarás usar **MTK Client**.
2. Apaga el móvil.
3. Conéctalo al PC manteniendo pulsados los botones de volumen.
4. Usa los archivos de respaldo de particiones que generaremos para restaurar `nvram` y `nvdata`.

---
**Nota de Antigravity**: El 99% de las veces, flashear la ROM Oficial vía Fastboot soluciona cualquier problema. Los archivos que hemos copiado hoy en `Backups` completan ese 1% restante (tus datos personales).
