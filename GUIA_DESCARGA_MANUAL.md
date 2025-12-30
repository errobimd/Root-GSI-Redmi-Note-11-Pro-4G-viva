# GUÍA DE DESCARGA MANUAL - RisingOS GSI

## 📥 INSTRUCCIONES PASO A PASO

### ✅ PASO 1: Abrir la Página de Descarga
La página ya está abierta en tu navegador:
- **URL**: https://sourceforge.net/projects/risingos-official/files/5.x/GAPPS/GSI/

### ✅ PASO 2: Localizar el Archivo
Busca en la lista el archivo:
```
RisingOS-5.2.1-FINAL-STABLE-EOL-20240925-GAPPS-OFFICIAL-arm64_bgN.img.xz
```

**Características del archivo:**
- 📦 Tamaño: **1.9 GB**
- 📅 Fecha: **25 de septiembre de 2024**
- 🔐 MD5: `dd42b8030314689e10d3261de9372657`

### ✅ PASO 3: Iniciar la Descarga
1. **Haz clic** en el nombre del archivo
2. SourceForge iniciará la descarga automáticamente
3. Si no inicia, haz clic en el botón **"Download"**

### ✅ PASO 4: Guardar en la Ubicación Correcta
**IMPORTANTE**: Guarda el archivo en:
```
D:\Antigravity Google\GSI para Redmi nota 11 pro 4G (viva)\Descargas\
```

**Renombra el archivo a:**
```
RisingOS_GSI.img.xz
```

### ✅ PASO 5: Esperar a que Termine
- ⏱️ Tiempo estimado: **30-60 minutos** (depende de tu conexión)
- 📊 El navegador mostrará el progreso
- ✅ NO cierres el navegador hasta que termine

---

## 🔍 VERIFICACIÓN POST-DESCARGA

### Una vez completada la descarga:

1. **Verificar tamaño del archivo:**
```powershell
Get-Item "D:\Antigravity Google\GSI para Redmi nota 11 pro 4G (viva)\Descargas\RisingOS_GSI.img.xz" | Select-Object Name, @{N='MB';E={[math]::Round($_.Length/1MB,2)}}
```
Debe mostrar: **~1,900 MB**

2. **Verificar MD5 (IMPORTANTE):**
```powershell
Get-FileHash "D:\Antigravity Google\GSI para Redmi nota 11 pro 4G (viva)\Descargas\RisingOS_GSI.img.xz" -Algorithm MD5
```
Debe ser: `dd42b8030314689e10d3261de9372657`

3. **Si el MD5 coincide:**
   ✅ El archivo está **COMPLETO** y **SIN CORRUPCIÓN**

---

## ⚠️ PROBLEMAS COMUNES

### Si la descarga se interrumpe:
- ✅ Algunos navegadores permiten **reanudar** la descarga
- ✅ Chrome/Edge: Haz clic en "Reanudar" en la barra de descargas
- ❌ Si no se puede reanudar, elimina el archivo parcial y vuelve a descargar

### Si el archivo es muy pequeño (<100 MB):
- ❌ Es un archivo de redirección, NO el archivo real
- ✅ Vuelve a hacer clic en el enlace de descarga

### Si el MD5 NO coincide:
- ❌ El archivo está **CORRUPTO**
- ✅ Elimínalo y descarga de nuevo

---

## 🎯 PRÓXIMOS PASOS (DESPUÉS DE DESCARGAR)

1. ✅ Verificar MD5
2. ✅ Extraer el archivo `.img` del `.xz`
3. ✅ Ejecutar verificación pre-flasheo
4. ✅ Seguir el checklist de flasheo

---

## 📞 AVÍSAME CUANDO:

- ✅ La descarga haya terminado
- ✅ Hayas verificado el MD5
- ✅ Estés listo para extraer el archivo

**Entonces continuaremos con los siguientes pasos.**

---

**Nota**: Esta descarga manual es más confiable que BITS. 
El navegador maneja mejor las conexiones largas y permite reanudar.
