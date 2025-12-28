<#
.SYNOPSIS
    Script de Automatización para Instalación de ROM GSI en Redmi Note 11 Pro 4G (viva).
    Versión con MODO SIMULACIÓN integrado.

.DESCRIPTION
    Automatiza y simula el flasheo de GSI.
    Incluye un modo 'Demo' para verificar el flujo sin dispositivo conectado.
#>

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Configuracion
$WorkDir = $PSScriptRoot
$ToolsDir = "$WorkDir\Herramientas"
$DownloadsDir = "$WorkDir\Descargas"
$RomsDir = "$WorkDir\ROMs"
$SimulationMode = $false # Por defecto desactivado

# URLs
$UrlPlatformTools = "https://dl.google.com/android/repository/platform-tools-latest-windows.zip"
$UrlMtkClient = "https://github.com/bkerler/mtkclient/archive/refs/heads/main.zip"
$UrlLineageOS = "https://github.com/xiaomi-mt6781-devs/releases/releases"
$UrlOverlay = "https://github.com/phhusson/treble_experimentations/raw/master/overlays/treble-overlay-xiaomi-viva.apk"

# Crear estructura
mkdir $ToolsDir -Force | Out-Null
mkdir $DownloadsDir -Force | Out-Null
mkdir $RomsDir -Force | Out-Null

function Run-Fastboot {
    param([string]$Arguments)
    
    if ($SimulationMode) {
        Write-Host "[SIMULACIÓN] Ejecutando: fastboot $Arguments" -ForegroundColor Magenta
        Start-Sleep -Seconds 2 # Simular tiempo de proceso
        return "SIMULADO_OK"
    }
    else {
        # Ejecutar comando real
        Start-Process "fastboot" -ArgumentList $Arguments -NoNewWindow -Wait
    }
}

function Imprimir-Encabezado {
    Clear-Host
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host "   AUTOMATIZADOR DE GSI PARA REDMI NOTE 11 PRO 4G (VIVA)       " -ForegroundColor Yellow
    if ($SimulationMode) {
        Write-Host "                  *** MODO SIMULACIÓN ACTIVO ***                " -ForegroundColor Magenta
    }
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Descargar-Herramientas {
    Write-Host "[*] Iniciando descarga de herramientas..." -ForegroundColor Green
    if ($SimulationMode) {
        Write-Host "[SIMULACIÓN] Descargando Platform Tools desde $UrlPlatformTools..." -ForegroundColor Magenta
        Start-Sleep -Seconds 1
        Write-Host "[SIMULACIÓN] Extrayendo archivos..." -ForegroundColor Magenta
        Start-Sleep -Seconds 1
        Write-Host "[OK] Herramientas simuladas listas." -ForegroundColor Green
        return
    }

    # Lógica real de descarga
    $AdbZip = "$DownloadsDir\platform-tools.zip"
    if (-not (Test-Path "$ToolsDir\platform-tools\fastboot.exe")) {
        Invoke-WebRequest -Uri $UrlPlatformTools -OutFile $AdbZip
        Expand-Archive -Path $AdbZip -DestinationPath $ToolsDir -Force
    }
    $env:Path += ";$ToolsDir\platform-tools"
    Write-Host "[OK] Herramientas preparadas." -ForegroundColor Green
}

function Flashear-GSI {
    Imprimir-Encabezado
    Write-Host "INSTRUCCIONES DE FLASHEO DE GSI" -ForegroundColor Yellow
    Write-Host "------------------------------------------------"
    Write-Host "Este proceso borrará TODOS tus datos. (Simulado: NO borrará nada)"
    
    # En simulación no pedimos vbmeta real, usamos nombres ficticios si no existen
    if (-not $SimulationMode) {
        $Confirmation = Read-Host "¿Deseas continuar? (S/N)"
        if ($Confirmation -ne 'S') { return }
    }
    else {
        Write-Host "[SIMULACIÓN] Auto-confirmando inicio de proceso..." -ForegroundColor Magenta
        Start-Sleep -Seconds 1
    }

    # Verificar dispositivo
    Write-Host "[*] Comprobando dispositivo..."
    if ($SimulationMode) {
        Write-Host "[SIMULACIÓN] Dispositivo 'Redmi Note 11 Pro' detectado (ID: VIVA123456)" -ForegroundColor Magenta
    }
    else {
        $Device = fastboot devices
        if (-not $Device) {
            Write-Host "  ! Dispositivo no detectado en modo FASTBOOT." -ForegroundColor Red
            return
        }
    }

    # Selección de imagen
    $SystemImg = "lineage-20.0-20231228-UNOFFICIAL-arm64_bgN.img"
    if (-not $SimulationMode) {
        # Lógica real de selección de archivo
        $GsiFiles = Get-ChildItem "$RomsDir\*.img"
        if ($GsiFiles.Count -eq 0) { 
            Write-Host "  ! No se encontraron archivos .img en $RomsDir" -ForegroundColor Red
            return
        }
        $SystemImg = $GsiFiles[0].FullName
    }
    else {
        Write-Host "[SIMULACIÓN] Usando imagen de ejemplo: $SystemImg" -ForegroundColor Magenta
    }

    # Paso 1: Vbmeta
    Write-Host "`n[PASO 1] Deshabilitando Verificación (Vbmeta)..." -ForegroundColor Cyan
    Run-Fastboot "--disable-verity --disable-verification flash vbmeta vbmeta.img"

    # Paso 2: FastbootD
    Write-Host "`n[PASO 2] Reiniciando a FastbootD..." -ForegroundColor Cyan
    Run-Fastboot "reboot fastboot"
    Write-Host "  Esperando a que el dispositivo entre en modo FastbootD..."
    Start-Sleep -Seconds 3

    # Paso 3: Borrar Product
    Write-Host "`n[PASO 3] Liberando espacio en Super Partition..." -ForegroundColor Cyan
    Run-Fastboot "delete-logical-partition product_a"

    # Paso 4: Flashear Sistema
    Write-Host "`n[PASO 4] Flasheando Sistema (Esto tardaría unos 5-10 mins)..." -ForegroundColor Cyan
    for ($i = 0; $i -le 100; $i += 20) {
        Write-Host "  [SIMULACIÓN] Flasheando... $i%"
        Start-Sleep -Milliseconds 500
    }
    Run-Fastboot "flash system $SystemImg"

    # Paso 5: Wipe
    Write-Host "`n[PASO 5] Formateando Datos de Usuario..." -ForegroundColor Cyan
    Run-Fastboot "-w"

    Write-Host "`n[FIN] Proceso completado exitosamente." -ForegroundColor Green
    Read-Host "Presiona Enter para volver."
}

# Menú Principal
do {
    $SimulationMode = $false # Resetear modo por defecto en cada vuelta
    Imprimir-Encabezado
    Write-Host "1. Descargar Herramientas"
    Write-Host "2. Flashear GSI (REAL - Requiere móvil)"
    Write-Host "3. Simular Todo el Proceso (Modo Demo)"
    Write-Host "4. Salir"
    Write-Host ""
    $Opcion = Read-Host "Elige una opción"

    switch ($Opcion) {
        '1' { Descargar-Herramientas }
        '2' { Flashear-GSI }
        '3' { 
            $SimulationMode = $true
            # Crear ficheros dummy para que la simulación no falle chequeos básicos de directorios
            if (-not (Test-Path "$RomsDir")) { mkdir $RomsDir }
            New-Item -ItemType File -Force -Path "$RomsDir\dummy_rom.img" | Out-Null
            Descargar-Herramientas
            Flashear-GSI 
        }
        '4' { exit }
    }
} while ($Opcion -ne '4')
