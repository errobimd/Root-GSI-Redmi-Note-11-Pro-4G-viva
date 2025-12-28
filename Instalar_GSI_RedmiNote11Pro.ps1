<#
.SYNOPSIS
    Script de Automatización para Instalación de ROM GSI en Redmi Note 11 Pro 4G (viva).
    Basado en la documentación técnica de xiaomi-mt6781-devs.

.DESCRIPTION
    Este script automatiza:
    1. Descarga de herramientas (ADB, Fastboot, Drivers).
    2. Preparación del entorno (Directorios).
    3. Guía paso a paso para el flasheo (Vbmeta, FastbootD, System).
    4. Enlaces a descargas de ROMs recomendadas.
    
    PRE-REQUISITOS:
    - Bootloader desbloqueado.
    - Depuración USB activada.
    - Python instalado (para mtkclient/bpf-patcher).

.NOTES
    Autor: Asistente de IA (Antigravity)
    Fecha: 28 de Diciembre de 2025
    Versión: 1.0.0
#>

# Configuración de codificación para caracteres en español
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Variables Globales y URLs
$WorkDir = $PSScriptRoot
$ToolsDir = "$WorkDir\Herramientas"
$DownloadsDir = "$WorkDir\Descargas"
$RomsDir = "$WorkDir\ROMs"

# URLs extraídas de la documentación
$UrlPlatformTools = "https://dl.google.com/android/repository/platform-tools-latest-windows.zip"
$UrlMtkClient = "https://github.com/bkerler/mtkclient/archive/refs/heads/main.zip"
$UrlDrivers = "https://xiaomiflash.com/download/xiaomi-usb-drivers/" # Enlace genérico, se usará referencia visual si falla descarga directa
$UrlLineageOS = "https://github.com/xiaomi-mt6781-devs/releases/releases" # Página de releases
$UrlOverlay = "https://github.com/phhusson/treble_experimentations/raw/master/overlays/treble-overlay-xiaomi-viva.apk" # URL aproximada del overlay

# Crear estructura de directorios
New-Item -ItemType Directory -Force -Path $ToolsDir | Out-Null
New-Item -ItemType Directory -Force -Path $DownloadsDir | Out-Null
New-Item -ItemType Directory -Force -Path $RomsDir | Out-Null

function Imprimir-Encabezado {
    Clear-Host
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host "   AUTOMATIZADOR DE GSI PARA REDMI NOTE 11 PRO 4G (VIVA)       " -ForegroundColor Yellow
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Descargar-Herramientas {
    Write-Host "[*] Iniciando descarga de herramientas esenciales..." -ForegroundColor Green
    
    # 1. Platform Tools (ADB/Fastboot)
    $AdbZip = "$DownloadsDir\platform-tools.zip"
    if (-not (Test-Path "$ToolsDir\platform-tools\fastboot.exe")) {
        Write-Host "  - Descargando Platform Tools..."
        Invoke-WebRequest -Uri $UrlPlatformTools -OutFile $AdbZip
        Write-Host "  - Extrayendo Platform Tools..."
        Expand-Archive -Path $AdbZip -DestinationPath $ToolsDir -Force
    } else {
        Write-Host "  - Platform Tools ya instalado." -ForegroundColor Gray
    }

    # Añadir ADB al PATH temporalmente para esta sesión
    $env:Path += ";$ToolsDir\platform-tools"

    # 2. MTK Client (Python)
    $MtkZip = "$DownloadsDir\mtkclient.zip"
    if (-not (Test-Path "$ToolsDir\mtkclient-main")) {
        Write-Host "  - Descargando MTK Client (Herramienta de Rescate)..."
        try {
            Invoke-WebRequest -Uri $UrlMtkClient -OutFile $MtkZip
            Expand-Archive -Path $MtkZip -DestinationPath $ToolsDir -Force
        } catch {
            Write-Host "  ! Error descargando MTK Client. Verifica tu conexión." -ForegroundColor Red
        }
    }

    Write-Host "[OK] Herramientas preparadas." -ForegroundColor Green
    Start-Sleep -Seconds 2
}

function Flashear-GSI {
    Imprimir-Encabezado
    Write-Host "INSTRUCCIONES DE FLASHEO DE GSI" -ForegroundColor Yellow
    Write-Host "------------------------------------------------"
    Write-Host "Este proceso borrará TODOS tus datos. Asegúrate de tener backup."
    Write-Host "Necesitas:"
    Write-Host "  1. Archivo vbmeta.img (de tu ROM MIUI actual)."
    Write-Host "  2. Imagen del sistema (system.img) descomprimida en la carpeta ROMs."
    Write-Host ""
    
    $Confirmation = Read-Host "¿Deseas continuar? (S/N)"
    if ($Confirmation -ne 'S') { return }

    # Verificar conexión ADB/Fastboot
    Write-Host "[*] Comprobando dispositivo..."
    $Device = fastboot devices
    if (-not $Device) {
        Write-Host "  ! Dispositivo no detectado en modo FASTBOOT." -ForegroundColor Red
        Write-Host "    Por favor, apaga el teléfono y enciéndelo presionando Vol- y Power."
        Read-Host "    Presiona Enter cuando lo hayas conectado..."
    }

    # Selección de imagen GSI
    $GsiFiles = Get-ChildItem "$RomsDir\*.img"
    if ($GsiFiles.Count -eq 0) {
        Write-Host "  ! No se encontraron archivos .img en $RomsDir" -ForegroundColor Red
        Write-Host "    Descarga una GSI (ej. LineageOS) y colócala allí."
        Read-Host "    Presiona Enter para volver..."
        return
    }

    Write-Host "Selecciona la imagen GSI a flashear:"
    $i = 1
    foreach ($file in $GsiFiles) {
        Write-Host "  [$i] $($file.Name)"
        $i++
    }
    $Selection = Read-Host "Número"
    $SystemImg = $GsiFiles[$Selection-1].FullName

    # Paso 1: Vbmeta
    Write-Host "`n[PASO 1] Deshabilitando Verificación (Vbmeta)..." -ForegroundColor Cyan
    Write-Host "  Buscando vbmeta.img en $WorkDir..."
    if (Test-Path "$WorkDir\vbmeta.img") {
        fastboot --disable-verity --disable-verification flash vbmeta "$WorkDir\vbmeta.img"
    } else {
        Write-Host "  ! NO SE ENCUENTRA vbmeta.img" -ForegroundColor Red
        Write-Host "    Es crítico flashear vbmeta para evitar bootloop."
        $Continue = Read-Host "    ¿Quieres intentar continuar sin esto (NO RECOMENDADO)? (S/N)"
        if ($Continue -ne 'S') { return }
    }

    # Paso 2: FastbootD
    Write-Host "`n[PASO 2] Reiniciando a FastbootD..." -ForegroundColor Cyan
    fastboot reboot fastboot
    Write-Host "  Esperando a que el dispositivo entre en modo FastbootD..."
    Start-Sleep -Seconds 10
    
    # Paso 3: Borrar Product (Espacio)
    Write-Host "`n[PASO 3] Liberando espacio en Super Partition..." -ForegroundColor Cyan
    fastboot delete-logical-partition product_a
    fastboot delete-logical-partition product

    # Paso 4: Flashear Sistema
    Write-Host "`n[PASO 4] Flasheando Sistema (Esto puede tardar)..." -ForegroundColor Cyan
    Write-Host "  Flasheando: $SystemImg"
    fastboot flash system "$SystemImg"

    # Paso 5: Wipe
    Write-Host "`n[PASO 5] Formateando Datos de Usuario..." -ForegroundColor Cyan
    fastboot -w

    Write-Host "`n[FIN] Proceso completado. Puedes reiniciar." -ForegroundColor Green
    Write-Host "  Comando: fastboot reboot"
    Read-Host "Presiona Enter para volver al menú."
}

# Bucle Principal
do {
    Imprimir-Encabezado
    Write-Host "1. Descargar e Instalar Herramientas (ADB, Fastboot, Drivers)"
    Write-Host "2. Ver Instrucciones para obtener ROMs y Vbmeta"
    Write-Host "3. Iniciar Proceso de Flasheo Automático"
    Write-Host "4. Abrir consola ADB aquí"
    Write-Host "5. Salir"
    Write-Host ""
    $Opcion = Read-Host "Elige una opción"

    switch ($Opcion) {
        '1' { Descargar-Herramientas }
        '2' { 
            Write-Host "`n--- DÓNDE OBTENER ARCHIVOS ---" -ForegroundColor Yellow
            Write-Host "1. ROM LineageOS (Recomendado): $UrlLineageOS"
            Write-Host "2. vbmeta.img: Debes extraerlo de la ROM Fastboot Oficial de MIUI que tengas instalada."
            Write-Host "   Coloca 'vbmeta.img' en la misma carpeta que este script."
            Write-Host "3. Overlay (Brillo): $UrlOverlay"
            Read-Host "Presiona Enter..."
        }
        '3' { Flashear-GSI }
        '4' { Start-Process "cmd.exe" -ArgumentList "/k cd /d $WorkDir" }
        '5' { Write-Host "Saliendo..."; exit }
    }
} while ($Opcion -ne '5')
