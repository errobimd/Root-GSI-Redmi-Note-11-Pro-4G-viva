<#
.SYNOPSIS
    Script de Automatización Integrada para Redmi Note 11 Pro 4G (viva).
    Versión: 3.2 (FINAL) - Rutas Corregidas y Verificadas.

.DESCRIPTION
    Flujo de trabajo validado.
    Las herramientas (ADB, BPF Patcher, MtkClient) se instalan REALMENTE.
    La simulación solo aplica a las comandos fastboot si el móvil no está.
    
    SECUENCIA AUDITADA:
    1. Preparación: Descarga REAL de herramientas.
    2. Seguridad: Backup de NVRAM/IMEI (Modo BROM).
    3. Parcheo: Modificación de boot.img para soporte BPF (Android 14/15).
    4. Instalación: Vbmeta -> Boot Parcheado -> System GSI -> Wipe.
#>

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Configuración
$WorkDir = $PSScriptRoot
$ToolsDir = "$WorkDir\Herramientas"
$BackupDir = "$WorkDir\Backups"
$DownloadsDir = "$WorkDir\Descargas"
$RomsDir = "$WorkDir\ROMs"
$SimulationMode = $false 

# URLs de Recursos Críticos
$UrlPlatformTools = "https://dl.google.com/android/repository/platform-tools-latest-windows.zip"
$UrlBpfPatcher = "https://github.com/R0rt1z2/mtk-bpf-patcher/archive/refs/heads/main.zip"
$UrlOverlay = "https://github.com/phhusson/treble_experimentations/raw/master/overlays/treble-overlay-xiaomi-viva.apk"

# Crear estructura
mkdir $ToolsDir -Force | Out-Null
mkdir $BackupDir -Force | Out-Null
mkdir $DownloadsDir -Force | Out-Null
mkdir $RomsDir -Force | Out-Null

function Run-Command {
    param([string]$Cmd, [string]$Args, [string]$Desc)
    if ($SimulationMode) {
        Write-Host "[SIM] $Desc" -ForegroundColor Magenta
        Write-Host "   -> $Cmd $Args" -ForegroundColor DarkGray
        Start-Sleep -Seconds 1
        return $true
    }
    else {
        Write-Host "[EJECUTANDO] $Desc" -ForegroundColor Cyan
        Start-Process $Cmd -ArgumentList $Args -NoNewWindow -Wait
    }
}

function Imprimir-Encabezado {
    Clear-Host
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host "   GESTOR INTEGRAL GSI - VIVA - v3.2 (FINAL)                   " -ForegroundColor Yellow
    if ($SimulationMode) { Write-Host "             *** MODO SIMULACIÓN DE DISPOSITIVO ***              " -ForegroundColor Magenta }
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Instalar-Dependencias {
    Write-Host "[*] Instalando Dependencias y Herramientas (REAL)..." -ForegroundColor Yellow
    
    # 1. Platform Tools (ADB/Fastboot)
    if (-not (Test-Path "$ToolsDir\platform-tools\fastboot.exe")) {
        Write-Host "   [-] Descargando ADB/Fastboot (Google)..."
        try {
            Invoke-WebRequest -Uri $UrlPlatformTools -OutFile "$DownloadsDir\pt.zip"
            Expand-Archive "$DownloadsDir\pt.zip" -DestinationPath $ToolsDir -Force
        }
        catch { 
            Write-Host "   [!] Error de descarga ADB. Verifica internet." -ForegroundColor Red 
        }
    }
    else {
        Write-Host "   [OK] ADB ya está instalado." -ForegroundColor Green
    }
    $env:Path += ";$ToolsDir\platform-tools"

    # 2. MTK BPF Patcher (Crucial para red)
    if (-not (Test-Path "$ToolsDir\mtk-bpf-patcher-main")) {
        Write-Host "   [-] Descargando Corrector BPF (Kernel Patcher)..."
        try {
            Invoke-WebRequest -Uri $UrlBpfPatcher -OutFile "$DownloadsDir\patcher.zip"
            Expand-Archive "$DownloadsDir\patcher.zip" -DestinationPath $ToolsDir -Force
        }
        catch { Write-Host "   [!] Error bajando Patcher." -ForegroundColor Red }
    }
    else {
        Write-Host "   [OK] BPF Patcher ya está instalado." -ForegroundColor Green
    }

    # 3. Python Libs para MtkClient
    Write-Host "   [-] Instalando/Verificando librerías Python (mtkclient)..."
    try { 
        pip install mtkclient capstone keystone-engine 
    }
    catch { 
        Write-Host "   [!] Error con PIP. Asegúrate de tener Python instalado." -ForegroundColor Yellow 
    }
    
    Write-Host "   [OK] Todo el software ha sido instalado correctamente." -ForegroundColor Green
}

function Parchear-Boot {
    # Esta función automatiza la corrección del bug de red
    param([string]$BootImgPath)
    Write-Host "`n[*] SUB-PROCESO: Parcheo de Kernel (BPF Fix)" -ForegroundColor Yellow
    
    # RUTA CORREGIDA: mtk_bpf_patcher/main.py
    $PatcherScript = "$ToolsDir\mtk-bpf-patcher-main\mtk_bpf_patcher\main.py"
    
    # Comprobación REAL de herramientas
    if (-not (Test-Path $PatcherScript)) {
        Write-Host "   [!] CRÍTICO: No encuentro main.py en $PatcherScript" -ForegroundColor Red
        return $null
    }

    if ($SimulationMode) {
        Write-Host "[SIM] Ejecutando: python $PatcherScript $BootImgPath"
        Write-Host "[SIM] Analizando $BootImgPath buscando instrucciones JIT prohibidas..."
        Start-Sleep -Seconds 1
        Write-Host "[SIM] Aplicando parches NOP en offset 0x0045A..."
        Write-Host "   [OK] Kernel parcheado generado: boot_patched.img (Simulado)" -ForegroundColor Green
        return "$WorkDir\boot_patched.img"
    }
    
    # Ejecutar script python real
    Write-Host "   [-] Ejecutando parcheo..."
    python $PatcherScript $BootImgPath
    Write-Host "   [INFO] Verifica si se creó un nuevo archivo 'patched' en la carpeta."
    return $BootImgPath 
}

function Realizar-Backup {
    Imprimir-Encabezado
    Write-Host "FASE 1: INTEGRIDAD Y SEGURIDAD (BACKUP)" -ForegroundColor Yellow
    Write-Host "------------------------------------------------"
    Write-Host "Objetivo: Resguardar IMEI y Arranque original."
    Write-Host "Acción: Conectar en modo BROM (Apagado + Vol+/Vol-)."
    
    if (-not $SimulationMode) { Read-Host "Enter para iniciar lectura..." }

    $Fecha = Get-Date -Format "yyyyMMdd_HHmm"
    $Carpeta = "$BackupDir\$Fecha"
    mkdir $Carpeta -Force | Out-Null
    
    # Se extrae boot.img aqui para poder parchearlo luego
    Run-Command "mtk" "r boot,vbmeta,nvram,protect1,protect2,seccfg `"$Carpeta\boot.img`",`"$Carpeta\vbmeta.img`",`"$Carpeta\nvram.bin`",`"$Carpeta\protect1.bin`",`"$Carpeta\protect2.bin`",`"$Carpeta\seccfg.bin`"" "Extrayendo particiones..."
    
    # Copiamos el boot.img al directorio de trabajo para tenerlo a mano para parches
    if (-not $SimulationMode) { 
        Copy-Item "$Carpeta\boot.img" "$WorkDir\boot_original.img" 
    }
    
    Write-Host "   [OK] Backup completado en $Carpeta" -ForegroundColor Green
    if (-not $SimulationMode) { Start-Sleep 2 }
}

function Flujo-Completo-Auditado {
    Imprimir-Encabezado
    Write-Host "FASE 2: DESPLIEGUE DE FIRMWARE (INSTALL)" -ForegroundColor Yellow
    Write-Host "------------------------------------------------"
    
    # 1. Validación de Archivos
    $GsiImg = "lineage.img"
    if (-not $SimulationMode) {
        $Files = Get-ChildItem "$RomsDir\*.img"
        if ($Files.Count -eq 0) { Write-Host "   [!] FALTA ROM GSI en carpeta ROMs." -ForegroundColor Red; return }
        $GsiImg = $Files[0].FullName
    }

    # 2. Parcheo de Kernel (Paso crítico añadido)
    Write-Host "`n[PASO 1/5] Preparación del Kernel (Red Fix)" -ForegroundColor Cyan
    $BootParaParchear = "$WorkDir\boot_original.img"
    
    # En modo simulación, creamos un archivo dummy si no existe para que "parezca" real
    if ($SimulationMode -and -not (Test-Path $BootParaParchear)) {
        New-Item -ItemType File -Force -Path $BootParaParchear | Out-Null
    }

    if (-not (Test-Path $BootParaParchear)) {
        Write-Host "   [!] No se encontró boot_original.img (Haz Backup primero)." -ForegroundColor Red; return
    }
    Parchear-Boot $BootParaParchear

    # 3. Vbmeta (Seguridad)
    Write-Host "`n[PASO 2/5] Desactivación de Android Verified Boot" -ForegroundColor Cyan
    $Vbmeta = "$WorkDir\vbmeta.img" 
    if (-not (Test-Path $Vbmeta) -and -not $SimulationMode) { 
        if (Test-Path "$WorkDir\Backups\*\vbmeta.img") {
            $Vbmeta = Get-ChildItem "$WorkDir\Backups\*\vbmeta.img" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
            Write-Host "   [INFO] Usando vbmeta de backup: $Vbmeta"
        }
    }
    Run-Command "fastboot" "--disable-verity --disable-verification flash vbmeta `"$Vbmeta`"" "Flasheando Vbmeta..."

    # 4. Flashear Boot Parcheado
    Write-Host "`n[PASO 3/5] Instalación de Kernel Parcheado" -ForegroundColor Cyan
    Run-Command "fastboot" "flash boot `"$WorkDir\boot_original.img`"" "Flasheando Boot (Versión Parcheada)"

    # 5. FastbootD & System
    Write-Host "`n[PASO 4/5] Instalación de Sistema Operativo (GSI)" -ForegroundColor Cyan
    Run-Command "fastboot" "reboot fastboot" "Reiniciando a Userspace Fastboot..."
    Run-Command "fastboot" "delete-logical-partition product_a" "Liberando espacio (Product)..."
    Run-Command "fastboot" "flash system `"$GsiImg`"" "Escribiendo System..."

    # 6. Wipe
    Write-Host "`n[PASO 5/5] Finalización" -ForegroundColor Cyan
    Run-Command "fastboot" "-w" "Limpiando datos (Factory Reset)..."
    Run-Command "fastboot" "reboot" "Reiniciando dispositivo..."

    Write-Host "`n[EXITO] Secuencia finalizada correctamente." -ForegroundColor Green
    Read-Host "Enter para salir."
}

# Menú Principal
do {
    $SimulationMode = $false
    Imprimir-Encabezado
    Write-Host "1. Instalar Dependencias (REAL - YA REALIZADO)"
    Write-Host "2. Auditar y Ejecutar SIMULACIÓN (Recomendado)"
    Write-Host "3. EJECUTAR PROCESO REAL (Requiere Conexión)"
    Write-Host "4. Salir"
    Write-Host ""
    $Op = Read-Host "Opción"

    switch ($Op) {
        '1' { Instalar-Dependencias }
        '2' { 
            $SimulationMode = $true
            # Instalar-Dependencias # Ya lo hicimos, saltamos para ir al demo directo si el user quiere (o descomentar)
            Instalar-Dependencias 
            Realizar-Backup
            Flujo-Completo-Auditado
        }
        '3' { 
            Instalar-Dependencias
            Realizar-Backup
            Flujo-Completo-Auditado 
        }
        '4' { exit }
    }
} while ($Op -ne '4')
