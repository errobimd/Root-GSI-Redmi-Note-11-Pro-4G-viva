# ============================================================
# MODULO: GESTION DE BACKUPS (REAL)
# Manejo de copias de seguridad con progreso
# ============================================================

function Start-RealBackup {
    param(
        [string]$AdbPath,
        [string]$BackupBaseDir,
        [string]$Mode
    )

    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $folderName = if ($Mode -eq "DEMO") { "DEMO_Backup_$timestamp" } else { "REAL_Backup_$timestamp" }
    $targetDir = Join-Path $BackupBaseDir $folderName
    
    if (!(Test-Path $targetDir)) { mkdir $targetDir -Force | Out-Null }

    Write-Host "`n=== INICIANDO BACKUP: $Mode ===" -ForegroundColor Cyan
    Write-Host "Destino: $targetDir" -ForegroundColor Gray
    Write-Host ""

    if ($Mode -eq "DEMO") {
        # Simulacion con barra de progreso
        $steps = 10
        for ($i = 1; $i -le $steps; $i++) {
            $percent = ($i / $steps) * 100
            Write-Progress -Activity "Simulando Backup DEMO" -Status "Copiando datos ficticios..." -PercentComplete $percent
            Start-Sleep -Milliseconds 500
        }
        Write-Host " [V] Backup DEMO completado (Simulado)" -ForegroundColor Magenta
        return $true
    }

    # --- RESPALDO REAL VIA ADB ---
    try {
        # Lista de carpetas criticas a respaldar
        $sources = @(
            "/sdcard/DCIM",
            "/sdcard/Pictures", 
            "/sdcard/Download",
            "/sdcard/Documents",
            "/sdcard/WhatsApp"
        )

        Write-Host " [i] Analizando tamaño de datos en el dispositivo..." -ForegroundColor Gray
        
        $totalFiles = 0
        $currentFile = 0

        # Primero contamos archivos para la barra de progreso (estimacion rapida)
        foreach ($source in $sources) {
            $count = & $AdbPath shell "find $source -type f 2>/dev/null | wc -l"
            if ($count -match "\d+") { $totalFiles += [int]$count }
        }

        if ($totalFiles -eq 0) {
            Write-Host " [!] No se encontraron archivos en las rutas estandar. Intentando backup general..." -ForegroundColor Yellow
            & $AdbPath backup -all -f "$targetDir\full_backup.ab"
            Write-Host " [i] Sigue las instrucciones en la pantalla de tu movil..." -ForegroundColor Cyan
            return $true
        }

        Write-Host " [i] Total de archivos detectados: $totalFiles" -ForegroundColor White
        Write-Host " [i] Iniciando transferencia... (Esto puede tardar varios minutos)" -ForegroundColor Yellow

        foreach ($source in $sources) {
            $folderName = Split-Path $source -Leaf
            $destPath = Join-Path $targetDir $folderName
            if (!(Test-Path $destPath)) { mkdir $destPath -Force | Out-Null }

            # Ejecutamos adb pull
            # Nota: adb pull no da progreso nativo facil de capturar en PS sin herramientas extra, 
            # pero podemos simular la barra mientras el proceso corre o usar un bucle por carpeta.
            Write-Host " -> Respaldando $folderName..." -ForegroundColor Gray
            & $AdbPath pull $source $targetDir
        }

        Write-Host "`n [V] BACKUP REAL COMPLETADO EXITOSAMENTE" -ForegroundColor Green
        Write-Host " [i] Ubicacion: $targetDir" -ForegroundColor White
        
        # Iniciar verificación automática
        $isValid = Test-BackupReliability -AdbPath $AdbPath -LocalDir $targetDir -Sources $sources
        return $isValid
    }
    catch {
        Write-Host " [X] Error durante el backup real: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Test-BackupReliability {
    param(
        [string]$AdbPath,
        [string]$LocalDir,
        [array]$Sources
    )

    Write-Host "`n=== VERIFICANDO FIABILIDAD DEL BACKUP ===" -ForegroundColor Cyan
    Write-Host " [i] Comprobando integridad de la transferencia..." -ForegroundColor Gray

    $localFiles = Get-ChildItem -Path $LocalDir -Recurse -File
    $localCount = $localFiles.Count
    $zeroByteFiles = $localFiles | Where-Object { $_.Length -eq 0 }

    Write-Host " [i] Archivos en PC: $localCount" -ForegroundColor White

    # 1. Verificar archivos de 0 bytes
    if ($zeroByteFiles.Count -gt 0) {
        Write-Host " [!] ADVERTENCIA: Se han detectado $($zeroByteFiles.Count) archivos vacios (0 bytes)." -ForegroundColor Yellow
        $allOk = $false
    }
    else {
        Write-Host " [V] No hay archivos corruptos de 0 bytes." -ForegroundColor Green
        $allOk = $true
    }

    # 2. Verificación aleatoria de tamaño (Muestreo)
    Write-Host " [i] Realizando muestreo de integridad..." -ForegroundColor Gray
    $sampleFiles = $localFiles | Get-Random -Count (if ($localCount -gt 10) { 10 } else { $localCount })
    
    foreach ($file in $sampleFiles) {
        $relativePath = $file.FullName.Replace($LocalDir, "").Replace("\", "/")
        $devicePath = "/sdcard" + $relativePath # Asumiendo que las fuentes cuelgan de /sdcard
        
        # Obtener tamaño en dispositivo
        $deviceSizeRaw = & $AdbPath shell "ls -l '$devicePath' 2>/dev/null"
        if ($deviceSizeRaw -match "\s+(\d+)\s+\d{4}-\d{2}-\d{2}") {
            $deviceSize = [long]$matches[1]
            if ($deviceSize -eq $file.Length) {
                Write-Host "  [OK] $($file.Name) - Tamaño coincide" -ForegroundColor Gray
            }
            else {
                Write-Host "  [!] $($file.Name) - DISCREPANCIA DE TAMAÑO" -ForegroundColor Red
                $allOk = $false
            }
        }
    }

    if ($allOk) {
        Write-Host "`n [V] VERIFICACION COMPLETADA: La copia es fiable." -ForegroundColor Green
        return $true
    }
    else {
        Write-Host "`n [X] VERIFICACION FALLIDA: Algunos archivos podrian estar incompletos." -ForegroundColor Red
        return $false
    }
}

function Start-FullSystemBackup {
    param(
        [string]$AdbPath,
        [string]$BackupBaseDir
    )

    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $targetFile = Join-Path $BackupBaseDir "SISTEMA_COMPLETO_Backup_$timestamp.ab"

    Write-Host "`n=== INICIANDO BACKUP COMPLETO DE SISTEMA ===" -ForegroundColor Cyan
    Write-Host "Destino: $targetFile" -ForegroundColor Gray
    Write-Host ""
    Write-Host " [!] ATENCION: Mira la pantalla de tu movil ahora." -ForegroundColor Yellow
    Write-Host " [i] Debes autorizar el respaldo y poner una contraseÃ±a si lo deseas." -ForegroundColor White
    Write-Host " [i] NO desconectes el cable hasta que la terminal termine." -ForegroundColor Red
    Write-Host ""

    # Comando de backup completo de apps y datos de sistema
    & $AdbPath backup -all -f $targetFile

    if (Test-Path $targetFile) {
        $size = (Get-Item $targetFile).Length / 1MB
        Write-Host " [V] Backup de sistema finalizado." -ForegroundColor Green
        Write-Host " [i] TamaÃ±o del archivo: {0:N2} MB" -f $size
        return $true
    } else {
        Write-Host " [X] El archivo de backup no se ha generado." -ForegroundColor Red
        return $false
    }
}

function Get-AppInventory {
    param([string]$AdbPath)

    Write-Host "`n [i] Obteniendo inventario de aplicaciones instaladas..." -ForegroundColor Gray
    
    # Listar aplicaciones de usuario (pista: -3 es para apps de terceros)
    $appsRaw = & $AdbPath shell "pm list packages -3"
    $appList = @()

    foreach ($line in $appsRaw) {
        if ($line -match "package:(.+)") {
            $appList += $matches[1].Trim()
        }
    }

    Write-Host " [V] Se han detectado $($appList.Count) aplicaciones de usuario." -ForegroundColor Green
    return $appList
}

function Save-AppInventory {
    param(
        [array]$AppList,
        [string]$BackupDir
    )

    $inventoryFile = Join-Path $BackupDir "app_inventory.json"
    $inventoryData = @{
        Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        AppCount = $AppList.Count
        Packages = $AppList
    }

    $inventoryData | ConvertTo-Json | Out-File -FilePath $inventoryFile -Encoding utf8
    Write-Host " [i] Inventario guardado en: $inventoryFile" -ForegroundColor Cyan
}

Export-ModuleMember -Function Start-RealBackup, Test-BackupReliability, Start-FullSystemBackup, Get-AppInventory, Save-AppInventory
