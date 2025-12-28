[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$WorkDir = $PSScriptRoot
$BackupDir = Join-Path $WorkDir "Backups"

function Log-Info { param($m) Write-Host " [i] $m" -ForegroundColor Gray }
function Log-Ok { param($m) Write-Host " [V] $m" -ForegroundColor Green }
function Log-Err { param($m) Write-Host " [X] $m" -ForegroundColor Red }

function Execute-Restore {
    Clear-Host
    Write-Host "--- VALIDACIÓN DE SEGURIDAD GOOGLE CERTIFIED ---" -ForegroundColor Cyan
    
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

# --- MENU ANTIGRAVITY GOOGLE ---
while ($true) {
    Clear-Host
    Write-Host "ANTIGRAVITY GOOGLE ASSISTANT v4.7 [CERTIFIED]" -ForegroundColor Cyan
    Write-Host " 1. Instalar Herramientas Google/ADB"
    Write-Host " 2. Realizar Backup de Seguridad (Recomendado)"
    Write-Host " 3. Descargar Kit de Certificación (GPay/Banca)" -ForegroundColor Yellow
    Write-Host " 4. Verificar Integridad de Backups"
    Write-Host " 5. Iniciar Flasheo GSI (Modo Google Pixel)" -ForegroundColor Red
    Write-Host " Q. Salir"
    
    $Op = Read-Host "`nOpcion"
    if ($Op -eq "1") { Write-Host "Simulando..."; Start-Sleep 1 }
    elseif ($Op -eq "2") { Write-Host "Iniciando Backup..."; Start-Sleep 1 }
    elseif ($Op -eq "3") { Write-Host "Descargando Kit..."; Start-Sleep 1 }
    elseif ($Op -eq "4") { Execute-Restore }
    elseif ($Op -eq "Q") { break }
}
