# Script Automático de Backup Completo
# Versión simplificada sin confirmaciones

$workDir = "D:\Antigravity Google\GSI para Redmi nota 11 pro 4G (viva)"
$backupDir = Join-Path $workDir "Backups"
$adbPath = Join-Path $workDir "Herramientas\platform-tools\adb.exe"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  BACKUP AUTOMATICO COMPLETO" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Paso 1: Limpiar backups antiguos
Write-Host "[1/4] Limpiando backups antiguos..." -ForegroundColor Yellow

if (Test-Path $backupDir) {
    $oldBackups = Get-ChildItem $backupDir -Directory -ErrorAction SilentlyContinue
    if ($oldBackups) {
        foreach ($backup in $oldBackups) {
            Remove-Item $backup.FullName -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "  Eliminado: $($backup.Name)" -ForegroundColor Gray
        }
        Write-Host "  Backups antiguos eliminados`n" -ForegroundColor Green
    } else {
        Write-Host "  No hay backups antiguos`n" -ForegroundColor Gray
    }
}

# Paso 2: Crear nueva carpeta de backup
Write-Host "[2/4] Creando carpeta de backup..." -ForegroundColor Yellow

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$newBackupDir = Join-Path $backupDir "BACKUP_COMPLETO_$timestamp"
New-Item -Path $newBackupDir -ItemType Directory -Force | Out-Null
Write-Host "  Carpeta creada: BACKUP_COMPLETO_$timestamp`n" -ForegroundColor Green

# Paso 3: Verificar conexión ADB
Write-Host "[3/4] Verificando conexión ADB..." -ForegroundColor Yellow

$deviceCheck = & $adbPath devices 2>&1 | Select-String "device$"
if ($deviceCheck) {
    Write-Host "  Dispositivo conectado`n" -ForegroundColor Green
} else {
    Write-Host "  ERROR: No se detectó dispositivo" -ForegroundColor Red
    Write-Host "  Conecta el telefono y activa depuracion USB`n" -ForegroundColor Yellow
    exit 1
}

# Paso 4: Realizar backup
Write-Host "[4/4] Realizando backup (esto puede tardar varios minutos)..." -ForegroundColor Yellow
Write-Host ""

# 4.1: Backup de archivos personales
Write-Host "  [4.1] Backup de archivos personales..." -ForegroundColor Cyan

$folders = @("DCIM", "Pictures", "Download", "Documents", "WhatsApp")
foreach ($folder in $folders) {
    Write-Host "    - Copiando /$folder..." -ForegroundColor Gray
    & $adbPath pull "/sdcard/$folder" "$newBackupDir\" 2>&1 | Out-Null
}

Write-Host "  Archivos personales respaldados`n" -ForegroundColor Green

# 4.2: Inventario de aplicaciones
Write-Host "  [4.2] Creando inventario de aplicaciones..." -ForegroundColor Cyan

$apps = & $adbPath shell pm list packages -3 2>&1 | ForEach-Object { $_ -replace "package:", "" }
$appList = @{
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    TotalApps = $apps.Count
    Apps = $apps
}

$inventoryPath = Join-Path $newBackupDir "app_inventory.json"
$appList | ConvertTo-Json | Out-File -FilePath $inventoryPath -Encoding UTF8

Write-Host "  Inventario creado: $($apps.Count) aplicaciones`n" -ForegroundColor Green

# 4.3: Backup de sistema (opcional - puede requerir interacción)
Write-Host "  [4.3] Backup de sistema..." -ForegroundColor Cyan
Write-Host "    NOTA: Puede aparecer un mensaje en el telefono" -ForegroundColor Yellow
Write-Host "    Si aparece, acepta el backup SIN contraseña`n" -ForegroundColor Yellow

$systemBackupPath = Join-Path $newBackupDir "sistema.ab"
& $adbPath backup -all -apk -shared -system -f $systemBackupPath 2>&1 | Out-Null

if (Test-Path $systemBackupPath) {
    $sizeGB = [math]::Round((Get-Item $systemBackupPath).Length / 1GB, 2)
    Write-Host "  Backup de sistema completado: $sizeGB GB`n" -ForegroundColor Green
} else {
    Write-Host "  Backup de sistema omitido o cancelado`n" -ForegroundColor Yellow
}

# Resumen final
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  BACKUP COMPLETADO" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Cyan

$backupSize = [math]::Round((Get-ChildItem $newBackupDir -Recurse -File | Measure-Object -Property Length -Sum).Sum / 1GB, 2)
$fileCount = (Get-ChildItem $newBackupDir -Recurse -File).Count

Write-Host "Ubicacion: Backups\BACKUP_COMPLETO_$timestamp" -ForegroundColor White
Write-Host "Tamaño total: $backupSize GB" -ForegroundColor White
Write-Host "Archivos: $fileCount" -ForegroundColor White
Write-Host ""
