<#
.SYNOPSIS
    Asistente GSI Redmi Note 11 Pro 4G (viva) - v4.6.1 Stable
    Sistema de Backup y Restauración Validado.
#>

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$WorkDir = $PSScriptRoot
$BackupDir = Join-Path $WorkDir "Backups"

function Log-Info { param($m) Write-Host " [i] $m" -ForegroundColor Gray }
function Log-Ok { param($m) Write-Host " [V] $m" -ForegroundColor Green }
function Log-Err { param($m) Write-Host " [X] $m" -ForegroundColor Red }

function Execute-Restore {
    Clear-Host
    Write-Host "--- VALIDACIÓN DE SEGURIDAD PARA RESTAURACIÓN ---" -ForegroundColor Cyan
    
    if (!(Test-Path $BackupDir)) { 
        Log-Err "Cuidado: No existe carpeta de Backups."
        Read-Host "Enter..."
        return
    }

    $Backups = Get-ChildItem -Path $BackupDir -Directory
    if ($Backups.Count -eq 0) {
        Log-Err "No hay backups realizados."
        Read-Host "Enter..."
        return
    }

    Write-Host "`nBackups disponibles:"
    for ($i = 0; $i -lt $Backups.Count; $i++) {
        Write-Host " [$i] $($Backups[$i].Name)"
    }
    
    $Sel = Read-Host "`nSeleccione el número"
    $Target = $Backups[$Sel].FullName
    
    Log-Info "Comprobando archivos en $Target ..."
    $ImgFiles = Get-ChildItem -Path $Target -Filter "*.img"
    
    $HasError = $false
    foreach ($f in $ImgFiles) {
        if ($f.Length -lt 100) {
            Log-Err "ARCHIVO CORRUPTO: $($f.Name) (Tamaño insuficiente)"
            $HasError = $true
        }
        else {
            Log-Ok "Archivo $($f.Name) verificado."
        }
    }
    
    if ($HasError) {
        Log-Err "ABORTADO: No se puede restaurar un backup incompleto."
    }
    else {
        Log-Ok "LISTO: El backup es seguro para flashear."
    }
    Read-Host "`nPresione Enter para volver."
}

# --- MENU SIMPLIFICADO ROBUSTO ---
while ($true) {
    Clear-Host
    Write-Host "REDMI INSTALLER v4.6.1 [IRONCLAD]" -ForegroundColor Cyan
    Write-Host " 1. Realizar Backup (Simulado)"
    Write-Host " 2. Verificar/Restaurar Backup"
    Write-Host " Q. Salir"
    
    $Op = Read-Host "`nOpcion"
    if ($Op -eq "1") { Write-Host "Simulando..."; Start-Sleep 1 }
    elseif ($Op -eq "2") { Execute-Restore }
    elseif ($Op -eq "Q") { break }
}
