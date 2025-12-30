# GUÍA DE SELECCIÓN DE GSI - REDMI NOTE 11 PRO 4G (viva)

## 📱 Opciones Disponibles

### OPCIÓN A: RisingOS v5.2.1-EOL ⭐ RECOMENDADA PARA PRINCIPIANTES
**Archivo**: `RisingOS_GSI.img.xz`
**Tamaño**: ~1.9 GB comprimido
**Fecha**: Septiembre 2024

#### ✅ Ventajas:
- GApps ya incluidas y certificadas por Google
- Proceso de flasheo simple (1 solo archivo)
- Apps bancarias funcionan sin configuración extra
- Muy estable y probada en dispositivos Treble
- Alta personalización (similar a Pixel Experience)

#### ⚠️ Desventajas:
- No es la versión más reciente (3 meses de antigüedad)
- Actualizaciones menos frecuentes

#### 📋 Pasos de Instalación:
1. Extraer el archivo `.img` del `.xz`
2. Reiniciar en modo Fastboot
3. Flashear: `fastboot flash system RisingOS_GSI.img`
4. Formatear datos: `fastboot -w`
5. Reiniciar: `fastboot reboot`
6. ✅ Listo - Apps de Google ya funcionan

---

### OPCIÓN B: crDroid 10.7 BETA ⭐ RECOMENDADA PARA AVANZADOS
**Archivos**: `crDroid_GSI.img.xz` + `NikGapps_Core_A14.zip`
**Tamaño**: ~1.3 GB (GSI) + ~300 MB (GApps)
**Fecha**: Diciembre 2024 (más reciente)

#### ✅ Ventajas:
- Versión más actualizada (Dic 2024)
- Basada en crDroid (muy personalizable)
- Actualizaciones más frecuentes
- Comunidad activa en XDA

#### ⚠️ Desventajas:
- Requiere flashear GApps por separado
- Configuración de Play Integrity necesaria
- Proceso más largo y complejo
- Mayor riesgo de errores si no sigues los pasos

#### 📋 Pasos de Instalación:
1. Extraer `crDroid_GSI.img` del `.xz`
2. Reiniciar en modo Fastboot
3. Flashear GSI: `fastboot flash system crDroid_GSI.img`
4. Formatear datos: `fastboot -w`
5. Reiniciar en **Recovery** (no en sistema)
6. Flashear NikGapps desde Recovery (TWRP/OrangeFox)
7. Limpiar caché/dalvik
8. Reiniciar
9. Instalar Magisk + Play Integrity Fix
10. ✅ Configurar apps bancarias

---

## 🤔 ¿Cuál Elegir?

### Elige RisingOS si:
- ✅ Es tu primer flasheo de GSI
- ✅ Quieres algo que funcione rápido
- ✅ Usas apps bancarias frecuentemente
- ✅ No quieres complicaciones

### Elige crDroid si:
- ✅ Tienes experiencia flasheando ROMs
- ✅ Quieres la versión más reciente
- ✅ No te importa dedicar 1-2 horas a configurar
- ✅ Quieres máxima personalización

---

## 🔄 Cambiar de una GSI a otra

Si instalas RisingOS y luego quieres probar crDroid (o viceversa):

1. **Hacer backup** de tus datos (el script ya lo hizo)
2. Reiniciar en Fastboot
3. Flashear la nueva GSI
4. Formatear datos: `fastboot -w`
5. Seguir los pasos específicos de cada ROM

**IMPORTANTE**: Siempre formatea datos (`fastboot -w`) al cambiar de GSI para evitar bootloops.

---

## 📦 Archivos Necesarios por Opción

### Para RisingOS:
- ✅ `RisingOS_GSI.img.xz` (ya descargando)
- ✅ Herramientas ADB/Fastboot (ya instaladas)

### Para crDroid:
- ⏳ `crDroid_GSI.img.xz` (disponible para descargar)
- ⏳ `NikGapps_Core_A14.zip` (disponible para descargar)
- ✅ Herramientas ADB/Fastboot (ya instaladas)
- ⚠️ Recovery personalizado (TWRP/OrangeFox) - **NECESARIO**

---

## 🛡️ Seguridad y Reversión

Ambas GSIs son reversibles. Si algo sale mal:
1. Consulta `GUIA_RESTAURACION.md`
2. Flashea la ROM oficial de Xiaomi (MIUI)
3. Restaura tus backups

**Nota de Antigravity**: Tus datos están seguros en la carpeta `Backups`. Puedes experimentar sin miedo.
