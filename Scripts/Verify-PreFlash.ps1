# Script Interactivo de Verificación Pre-Flasheo
# Verifica automáticamente los requisitos del checklist

param(
    [switch]$AutoCheck
)

$workDir = "D:\Antigravity Google\GSI para Redmi nota 11 pro 4G (viva)"
$downloadDir = Join-Path $workDir "Descargas"
$backupDir = Join-Path $workDir "Backups"

Write-Host "`n═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "     VERIFICADOR AUTOMATICO PRE-FLASHEO                   " -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════`n" -ForegroundColor Cyan

$results = @{
    Passed = 0
    Failed = 0
    Warnings = 0
}

function Test-Item {
    param(
        [string]$Name,
        [scriptblock]$Test,
        [string]$SuccessMsg,
        [string]$FailMsg,
        [bool]$Critical = $true
    )
    
    Write-Host "Verificando: $Name..." -ForegroundColor Gray -NoNewline
    
    try {
        $result = & $Test
        if ($result) {
            Write-Host " OK" -ForegroundColor Green
            $script:results.Passed++
            if ($SuccessMsg) { Write-Host "  └─ $SuccessMsg" -ForegroundColor Gray }
            return $true
        } else {
            if ($Critical) {
                Write-Host " FALLO" -ForegroundColor Red
                $script:results.Failed++
            } else {
                Write-Host " ADVERTENCIA" -ForegroundColor Yellow
                $script:results.Warnings++
            }
            if ($FailMsg) { Write-Host "  └─ $FailMsg" -ForegroundColor $(if ($Critical) {"Red"} else {"Yellow"}) }
            return $false
        }
    } catch {
        Write-Host " ERROR" -ForegroundColor Red
        $script:results.Failed++
        Write-Host "  └─ $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

Write-Host "=== FASE 1: ARCHIVOS DESCARGADOS ===`n" -ForegroundColor Cyan

Test-Item "RisingOS GSI descargado" {
    $file = Join-Path $downloadDir "RisingOS_GSI.img.xz"
    if (Test-Path $file) {
        $sizeMB = [math]::Round((Get-Item $file).Length / 1MB, 2)
        return $sizeMB -ge 1800
    }
    return $false
} -SuccessMsg "Archivo encontrado y tamaño correcto" -FailMsg "Archivo no encontrado o tamaño incorrecto" -Critical $false

Test-Item "crDroid GSI descargado" {
    $file = Join-Path $downloadDir "crDroid_GSI.img.xz"
    if (Test-Path $file) {
        $sizeMB = [math]::Round((Get-Item $file).Length / 1MB, 2)
        return $sizeMB -ge 1250
    }
    return $false
} -SuccessMsg "Archivo encontrado y tamaño correcto" -FailMsg "Archivo no encontrado o tamaño incorrecto" -Critical $false

Test-Item "NikGapps descargado" {
    $file = Join-Path $downloadDir "NikGapps_Core_A14.zip"
    if (Test-Path $file) {
        $sizeMB = [math]::Round((Get-Item $file).Length / 1MB, 2)
        return $sizeMB -ge 250
    }
    return $false
} -SuccessMsg "Archivo encontrado y tamaño correcto" -FailMsg "Solo necesario si usas crDroid" -Critical $false

Write-Host "`n=== FASE 2: HERRAMIENTAS ===`n" -ForegroundColor Cyan

Test-Item "ADB/Fastboot instalado" {
    $adbPath = Join-Path $workDir "Herramientas\platform-tools\adb.exe"
    $fastbootPath = Join-Path $workDir "Herramientas\platform-tools\fastboot.exe"
    return (Test-Path $adbPath) -and (Test-Path $fastbootPath)
} -SuccessMsg "Herramientas encontradas" -FailMsg "CRITICO: Instala ADB/Fastboot primero"

Write-Host "`n=== FASE 3: BACKUPS ===`n" -ForegroundColor Cyan

Test-Item "Backups realizados" {
    if (Test-Path $backupDir) {
        $backups = Get-ChildItem $backupDir -Directory | Where-Object { $_.Name -like "*Backup*" }
        return $backups.Count -gt 0
    }
    return $false
} -SuccessMsg "Backups encontrados en carpeta Backups/" -FailMsg "CRITICO: Realiza backup antes de continuar"

Test-Item "Inventario de apps creado" {
    $inventoryFiles = Get-ChildItem $backupDir -Recurse -Filter "app_inventory.json"
    return $inventoryFiles.Count -gt 0
} -SuccessMsg "Inventario encontrado" -FailMsg "Opcional: Puedes continuar sin esto" -Critical $false

Write-Host "`n=== FASE 4: ESPACIO EN DISCO ===`n" -ForegroundColor Cyan

Test-Item "Espacio suficiente en disco" {
    $drive = Get-PSDrive -Name C
    $freeSpaceGB = [math]::Round($drive.Free / 1GB, 2)
    Write-Host "  └─ Espacio libre: $freeSpaceGB GB" -ForegroundColor Gray
    return $freeSpaceGB -ge 10
} -SuccessMsg "Espacio suficiente" -FailMsg "ADVERTENCIA: Libera espacio (mínimo 10 GB)" -Critical $false

Write-Host "`n=== RESUMEN FINAL ===`n" -ForegroundColor Cyan

Write-Host "Verificaciones pasadas: $($results.Passed)" -ForegroundColor Green
Write-Host "Advertencias: $($results.Warnings)" -ForegroundColor Yellow
Write-Host "Fallos críticos: $($results.Failed)" -ForegroundColor Red
Write-Host ""

if ($results.Failed -eq 0) {
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host "                                                           " -ForegroundColor Green
    Write-Host "     LISTO PARA FLASHEAR                                  " -ForegroundColor Green
    Write-Host "                                                           " -ForegroundColor Green
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host ""
    Write-Host "Consulta CHECKLIST_PRE_FLASHEO.md para los pasos finales" -ForegroundColor Cyan
} else {
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Red
    Write-Host "                                                           " -ForegroundColor Red
    Write-Host "     NO LISTO - CORRIGE LOS ERRORES PRIMERO              " -ForegroundColor Red
    Write-Host "                                                           " -ForegroundColor Red
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Red
    Write-Host ""
    Write-Host "Revisa los fallos críticos arriba y corrígelos antes de continuar" -ForegroundColor Yellow
}

Write-Host ""
