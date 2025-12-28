<#
.SYNOPSIS
    Script de Automatización Integrada para Redmi Note 11 Pro 4G (viva).
    Versión: 2.0 - Con BACKUP Y RESTAURACIÓN (Anti-Brick).

.DESCRIPTION
    Este script permite:
    1. Instalar GSI (LineageOS, etc.)
    2. REALIZAR BACKUP de particiones críticas (Boot, Vbmeta, NVRAM/IMEI).
    3. RESTAURAR el dispositivo en caso de fallo.
    4. Simular todo el proceso (Modo Demo).
    
    HERRAMIENTAS: Utiliza 'mtkclient' para backups profundos (Modo Brom).
#>

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Configuracion
$WorkDir = $PSScriptRoot
$ToolsDir = "$WorkDir\Herramientas"
$BackupDir = "$WorkDir\Backups"
$DownloadsDir = "$WorkDir\Descargas"
$RomsDir = "$WorkDir\ROMs"
$SimulationMode = $false 

# URLs
$UrlPlatformTools = "https://dl.google.com/android/repository/platform-tools-latest-windows.zip"
# mtkclient se gestiona por pip o git clone si falla pip

# Crear estructura
mkdir $ToolsDir -Force | Out-Null
mkdir $BackupDir -Force | Out-Null
mkdir $DownloadsDir -Force | Out-Null
mkdir $RomsDir -Force | Out-Null

function Run-Command {
    param([string]$Cmd, [string]$Args, [string]$Desc)
    
    if ($SimulationMode) {
        Write-Host "[SIMULACIÓN] $Desc" -ForegroundColor Magenta
        Write-Host "  -> Ejecutando: $Cmd $Args" -ForegroundColor DarkGray
        Start-Sleep -Seconds 2
        return $true
    }
    else {
        Write-Host "[REAL] $Desc" -ForegroundColor Cyan
        Start-Process $Cmd -ArgumentList $Args -NoNewWindow -Wait
    }
}

function Imprimir-Encabezado {
    Clear-Host
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host "   GESTOR INTEGRAL GSI - REDMI NOTE 11 PRO 4G (VIVA)           " -ForegroundColor Yellow
    if ($SimulationMode) {
        Write-Host "             *** MODO SIMULACIÓN ACTIVO ***                     " -ForegroundColor Magenta
    }
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Instalar-Dependencias {
    Write-Host "[*] Verificando dependencias..."
    if ($SimulationMode) { Write-Host "[SIM] Dependencias instaladas." -ForegroundColor Green; return }

    # Descargar Platform Tools
    if (-not (Test-Path "$ToolsDir\platform-tools\fastboot.exe")) {
        Write-Host "  - Descargando Platform Tools..."
        try {
            Invoke-WebRequest -Uri $UrlPlatformTools -OutFile "$DownloadsDir\pt.zip"
            Expand-Archive "$DownloadsDir\pt.zip" -DestinationPath $ToolsDir -Force
        }
        catch {
            Write-Host "  ! Error descargando ADB. Verifica tu internet." -ForegroundColor Red
        }
    }
    $env:Path += ";$ToolsDir\platform-tools"

    # mtkclient requiere Python + Librerías
    Write-Host "  - Para Backups se requiere Python y mtkclient instalado."
    Write-Host "    Intentando instalar via PIP..."
    try {
        pip install mtkclient
    }
    catch {
        Write-Host "  ! No se pudo instalar mtkclient. Asegúrate de tener Python instalado y en el PATH." -ForegroundColor Red
    }
}

function Realizar-Backup {
    Imprimir-Encabezado
    Write-Host "COPIA DE SEGURIDAD (BACKUP)" -ForegroundColor Yellow
    Write-Host "------------------------------------------------"
    Write-Host "Este proceso guardará tus particiones vitales (NVRAM, Boot, Vbmeta)."
    Write-Host "NECESARIO: Apaga el móvil. Mantén presionado Vol+ y Vol- mientras conectas el USB (Modo BROM)."
    Write-Host ""
    
    if (-not $SimulationMode) {
        Read-Host "Presiona Enter cuando estés listo para conectar el cable..."
    }

    $Fecha = Get-Date -Format "yyyyMMdd_HHmm"
    $CarpetaBackup = "$BackupDir\$Fecha"
    mkdir $CarpetaBackup -Force | Out-Null

    # Backup de Particiones Críticas (NVRAM es VITAL para IMEI)
    # Nota: El comando real de mtkclient se llama 'mtk' una vez instalado via pip, o 'python mtk.py' si es source.
    # Asumimos instalación por pip para simplificar.
    Run-Command "mtk" "r boot,vbmeta,dtbo,nvram,protect1,protect2,seccfg `"$CarpetaBackup\boot.img`",`"$CarpetaBackup\vbmeta.img`",`"$CarpetaBackup\dtbo.img`",`"$CarpetaBackup\nvram.bin`",`"$CarpetaBackup\protect1.bin`",`"$CarpetaBackup\protect2.bin`",`"$CarpetaBackup\seccfg.bin`"" "Leyendo particiones críticas..."

    Write-Host "`n[INFO] Backup guardado en: $CarpetaBackup" -ForegroundColor Green
    Read-Host "Presiona Enter para continuar"
}

function Restaurar-Sistema {
    Imprimir-Encabezado
    Write-Host "RESTAURACIÓN DE EMERGENCIA" -ForegroundColor Red
    Write-Host "------------------------------------------------"
    Write-Host "Esto restaurará las particiones desde una copia de seguridad."
    
    $Backups = Get-ChildItem $BackupDir
    if ($Backups.Count -eq 0) {
        Write-Host "No hay backups disponibles." -ForegroundColor Red; Start-Sleep 2; return
    }

    Write-Host "Selecciona backup a restaurar:"
    $i = 1; foreach ($b in $Backups) { Write-Host "[$i] $($b.Name)"; $i++ }
    $sel = 1
    if (-not $SimulationMode) { $sel = Read-Host "Opción" }
    
    if ($sel -le 0 -or $sel -gt $Backups.Count) { return }
    $TargetDir = $Backups[$sel - 1].FullName
    Write-Host "Restaurando desde: $TargetDir"

    # Restauración via mtkclient
    # ¡CUIDADO! nvram.bin contiene tus IMEIs.
    Run-Command "mtk" "w boot,vbmeta,dtbo,nvram,protect1,protect2,seccfg `"$TargetDir\boot.img`",`"$TargetDir\vbmeta.img`",`"$TargetDir\dtbo.img`",`"$TargetDir\nvram.bin`",`"$TargetDir\protect1.bin`",`"$TargetDir\protect2.bin`",`"$TargetDir\seccfg.bin`"" "Escribiendo particiones..."

    Write-Host "`n[OK] Sistema restaurado." -ForegroundColor Green
    Read-Host "Presiona Enter"
}

function Flashear-GSI {
    Imprimir-Encabezado
    Write-Host "INSTALACIÓN DE ROM GSI" -ForegroundColor Yellow
    
    # Oferta de Backup previo
    if (-not $SimulationMode) {
        $HacerBackup = Read-Host "¿Quieres hacer un BACKUP de seguridad antes? (Recomendado) [S/N]"
        if ($HacerBackup -eq 'S') { Realizar-Backup }
    }
    else {
        Write-Host "[SIMULACIÓN] Saltando backup previo por modo demo..."
    }

    # Proceso de Flasheo (Vbmeta -> Fastbootd -> System)
    Run-Command "fastboot" "devices" "Buscando dispositivo..."
    
    # 1. Vbmeta
    if (Test-Path "$WorkDir\vbmeta.img") {
        Run-Command "fastboot" "--disable-verity --disable-verification flash vbmeta vbmeta.img" "Parcheando vbmeta..."
    }
    else {
        if (-not $SimulationMode) { Write-Host "Falta vbmeta.img!" -ForegroundColor Red; Read-Host; return }
    }

    # 2. Reboot FastbootD
    Run-Command "fastboot" "reboot fastboot" "Entrando a FastbootD..."
    
    # 3. Limpieza
    Run-Command "fastboot" "delete-logical-partition product_a" "Borrando partición Product..."

    # 4. Flash System
    $GsiImg = "lineage.img" # Simplificado para el ejemplo
    if (-not $SimulationMode) { 
        $Files = Get-ChildItem "$RomsDir\*.img"; if ($Files) { $GsiImg = $Files[0].FullName } 
    }
    Run-Command "fastboot" "flash system `"$GsiImg`"" "Flasheando System ($GsiImg)..."

    # 5. Wipe
    Run-Command "fastboot" "-w" "Formateando datos de usuario..."
    Run-Command "fastboot" "reboot" "Reiniciando sistema..."

    Read-Host "Proceso finalizado. Enter para salir."
}

# Menú Principal
do {
    $SimulationMode = $false
    Imprimir-Encabezado
    Write-Host "1. Instalar Dependencias (Python/MtkClient/Drivers)"
    Write-Host "2. REALIZAR BACKUP (Anti-Brick)"
    Write-Host "3. Instalar GSI (Flasheo)"
    Write-Host "4. RESTAURAR desde Backup"
    Write-Host "5. SIMULACIÓN / DEMO (Recorrido completo)"
    Write-Host "6. Salir"
    Write-Host ""
    $Op = Read-Host "Opción"

    switch ($Op) {
        '1' { Instalar-Dependencias }
        '2' { Realizar-Backup }
        '3' { Flashear-GSI }
        '4' { Restaurar-Sistema }
        '5' { 
            $SimulationMode = $true; 
            if (-not (Test-Path "$RomsDir\dummy.img")) { New-Item -Force "$RomsDir\dummy.img" | Out-Null }
            Realizar-Backup; 
            Flashear-GSI 
        } 
        '6' { exit }
    }
} while ($Op -ne '6')
