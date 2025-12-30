# ✅ CHECKLIST PRE-FLASHEO - REDMI NOTE 11 PRO 4G (viva)
# Verificación completa antes de flashear GSI

## 🎯 OBJETIVO
Este checklist asegura que tienes TODO listo antes de flashear la GSI.
**NO CONTINÚES** hasta que todos los ítems estén marcados como ✅

---

## 📋 FASE 1: VERIFICACIÓN DE ARCHIVOS

### Archivos GSI Descargados
- [ ] **RisingOS_GSI.img.xz** (~1.9 GB)
  - Ubicación: `Descargas/RisingOS_GSI.img.xz`
  - Verificar MD5: `dd42b8030314689e10d3261de9372657`
  
- [ ] **crDroid_GSI.img.xz** (~1.3 GB)
  - Ubicación: `Descargas/crDroid_GSI.img.xz`
  
- [ ] **NikGapps_Core_A14.zip** (~300 MB)
  - Ubicación: `Descargas/NikGapps_Core_A14.zip`
  - Solo necesario si usas crDroid

### Archivos Extraídos
- [ ] **RisingOS_GSI.img** (extraído del .xz)
  - Tamaño esperado: ~5 GB
  
- [ ] **crDroid_GSI.img** (extraído del .xz)
  - Tamaño esperado: ~4 GB

### Herramientas Necesarias
- [ ] **ADB/Fastboot** instalado
  - Verificar: `fastboot --version`
  - Ubicación: `Herramientas/platform-tools/`

- [ ] **Drivers USB** instalados
  - El dispositivo debe ser reconocido en Fastboot

---

## 📋 FASE 2: BACKUPS COMPLETADOS

### Datos Personales
- [ ] **Fotos y vídeos** respaldados
  - Carpeta: `Backups/REAL_Backup_YYYYMMDD_HHMMSS/DCIM`
  
- [ ] **WhatsApp** respaldado
  - Carpeta: `Backups/REAL_Backup_YYYYMMDD_HHMMSS/WhatsApp`
  
- [ ] **Documentos** respaldados
  - Carpeta: `Backups/REAL_Backup_YYYYMMDD_HHMMSS/Download`

### Sistema
- [ ] **Backup de sistema completo** (.ab)
  - Archivo: `Backups/SISTEMA_COMPLETO_Backup_*.ab`
  
- [ ] **Inventario de aplicaciones**
  - Archivo: `Backups/app_inventory.json`

### Verificación de Backups
- [ ] **Archivos NO corruptos** (0 bytes)
  - Ejecutar verificación de integridad
  
- [ ] **Backup accesible** desde otro dispositivo
  - Copiar `Backups/` a disco externo o nube

---

## 📋 FASE 3: PREPARACIÓN DEL DISPOSITIVO

### Bootloader
- [ ] **Bootloader DESBLOQUEADO**
  - ⚠️ CRÍTICO: Sin esto NO puedes flashear
  - Verificar en Fastboot: debe decir "UNLOCKED"

### Batería
- [ ] **Carga ≥ 70%**
  - ⚠️ El dispositivo NO debe apagarse durante el flasheo
  - Conectar cargador durante el proceso

### Conexión
- [ ] **Cable USB de CALIDAD**
  - Preferiblemente el cable original
  - Evitar cables baratos o dañados

- [ ] **Puerto USB 2.0** (negro)
  - ⚠️ Los puertos USB 3.0 (azules) pueden fallar
  - Probar conexión: `adb devices`

---

## 📋 FASE 4: CONOCIMIENTO Y PREPARACIÓN

### Documentación Leída
- [ ] **GUIA_SELECCION_GSI.md** leída
  - Sabes cuál GSI vas a flashear (RisingOS o crDroid)
  
- [ ] **GUIA_RESTAURACION.md** leída
  - Sabes cómo recuperar el dispositivo si algo falla

### Comandos Preparados
- [ ] **Comandos de flasheo** listos
  - Para RisingOS o crDroid según tu elección
  
- [ ] **ROM oficial de Xiaomi** descargada (opcional pero recomendado)
  - Plan B si algo sale mal

---

## 📋 FASE 5: ENTORNO DE TRABAJO

### Espacio en Disco
- [ ] **≥ 10 GB libres** en disco C:
  - Para archivos temporales y extracciones

### Tiempo Disponible
- [ ] **1-2 horas libres**
  - RisingOS: ~30-45 min
  - crDroid: ~1-2 horas (incluye flasheo de GApps)

### Interrupciones
- [ ] **Sin interrupciones** garantizadas
  - Apagar notificaciones
  - Avisar a familiares/compañeros

---

## 📋 FASE 6: VERIFICACIÓN FINAL

### Antes de Empezar
- [ ] **Dispositivo en modo Fastboot**
  - Apagar → Volumen Abajo + Encendido
  - Pantalla debe mostrar "FASTBOOT"

- [ ] **Conexión verificada**
  - Ejecutar: `fastboot devices`
  - Debe mostrar el número de serie

- [ ] **Decisión tomada**
  - ¿RisingOS (simple) o crDroid (avanzado)?

### Confirmación Mental
- [ ] **Entiendo que esto borrará todos mis datos**
  - `fastboot -w` formatea el dispositivo
  
- [ ] **Tengo un plan B**
  - ROM oficial de Xiaomi lista para flashear
  
- [ ] **Estoy preparado para posibles problemas**
  - Bootloop, falta de señal, etc.

---

## 🚀 CUANDO TODOS LOS ÍTEMS ESTÉN MARCADOS

### Para RisingOS (Opción Simple):
```bash
# 1. Flashear GSI
fastboot flash system Descargas\RisingOS_GSI.img

# 2. Formatear datos
fastboot -w

# 3. Reiniciar
fastboot reboot
```

### Para crDroid (Opción Avanzada):
```bash
# 1. Flashear GSI
fastboot flash system Descargas\crDroid_GSI.img

# 2. Formatear datos
fastboot -w

# 3. Reiniciar en Recovery
fastboot reboot recovery

# 4. En Recovery (TWRP/OrangeFox):
#    - Flashear NikGapps_Core_A14.zip
#    - Limpiar caché/dalvik
#    - Reiniciar
```

---

## ⚠️ ADVERTENCIAS FINALES

### NO HAGAS ESTO:
- ❌ Flashear sin backup
- ❌ Desconectar el cable durante el flasheo
- ❌ Apagar el PC o el móvil durante el proceso
- ❌ Usar puertos USB 3.0 (azules)
- ❌ Flashear con batería baja (<50%)

### SÍ HAZLO:
- ✅ Leer TODA la documentación antes
- ✅ Tener paciencia (el primer arranque tarda 5-10 min)
- ✅ Seguir los pasos EXACTAMENTE como están escritos
- ✅ Consultar GUIA_RESTAURACION.md si algo falla

---

## 📞 SOPORTE DE EMERGENCIA

Si algo sale mal:
1. **NO ENTRES EN PÁNICO**
2. Consulta `GUIA_RESTAURACION.md`
3. Flashea la ROM oficial de Xiaomi
4. Restaura tus backups

---

**Nota de Antigravity**: Este checklist es tu red de seguridad. 
Tómate tu tiempo para verificar cada punto. ¡Buena suerte! 🚀
