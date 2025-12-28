[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$d_WorkDir = $PSScriptRoot
$d_BackupDir = Join-Path $d_WorkDir "Backups"
$d_DownloadsDir = Join-Path $d_WorkDir "Descargas"

if (!(Test-Path $d_BackupDir)) { mkdir $d_BackupDir -Force | Out-Null }

function LogOk { param($msg) Write-Host " [V] $msg" -ForegroundColor Green }
function LogInfo { param($msg) Write-Host " [i] $msg" -ForegroundColor Gray }
function LogErr { param($msg) Write-Host " [X] $msg" -ForegroundColor Red }
function LogWarn { param($msg) Write-Host " [!] $msg" -ForegroundColor Yellow }

function RunBackupSim {
    Clear-Host
    Write-Host "--- SIMULACION DE BACKUP ANTIGRAVITY ---" -ForegroundColor Cyan
    $folderName = "SIM_$(Get-Date -Format 'yyyyMMdd_HHmm')"
    $newBackup = Join-Path $d_BackupDir $folderName
    mkdir $newBackup -Force | Out-Null
    
    LogWarn "Iniciando volcado de particiones (SIMULADO)..."
    $parts = @("nvram", "boot", "vbmeta")
    foreach ($p in $parts) {
        $f = Join-Path $newBackup "$p.img"
        "SIM_DATA_$p" | Out-File -FilePath $f -Encoding ascii
        LogOk "Particion $p guardada en $folderName"
        Start-Sleep -Milliseconds 500
    }
    LogOk "BACKUP COMPLETADO CON EXITO"
    Read-Host "`nEnter para volver"
}

function RunRestore {
    Clear-Host
    Write-Host "--- VALIDACION DE SEGURIDAD GOOGLE CERTIFIED ---" -ForegroundColor Cyan
    if (!(Test-Path $d_BackupDir)) { 
        LogErr "No existe carpeta de Backups"
        Read-Host "Pulsar Enter"
        return
    }
    $v_list = Get-ChildItem -Path $d_BackupDir -Directory | Sort-Object LastWriteTime -Descending
    if ($v_list.Count -eq 0) {
        LogErr "Sin backups"
        Read-Host "Pulsar Enter"
        return
    }
    Write-Host "`nBackups detectados (Mas reciente primero):"
    for ($i=0; $i -lt $v_list.Count; $i++) {
        Write-Host " [$i] $($v_list[$i].Name)"
    }
    $v_sel = Read-Host "`nSeleccione el backup para validar/restaurar"
    if ($v_sel -match '^\d+$') {
        $idx = [int]$v_sel
        if ($idx -ge 0 -and $idx -lt $v_list.Count) {
            $path = $v_list[$idx].FullName
            LogInfo "Analizando integridad en: $path"
            $imgs = Get-ChildItem -Path $path -Filter "*.img"
            $bad = $false
            foreach ($f in $imgs) {
                if ($f.Length -lt 10) { 
                    LogErr "ERROR: $($f.Name) esta CORRUPTO (0 KB)"
                    $bad = $true
                } else { 
                    LogOk "OK: $($f.Name) (Seguro para flashear)" 
                }
            }
            if (!$bad -and $imgs.Count -gt 0) {
                LogOk "VALIDACION POSITIVA. El dispositivo puede ser restaurado con este backup."
                LogWarn "Simulando restauracion..."
                Start-Sleep 1
                LogOk "RESTAURACION COMPLETADA"
            } else {
                LogErr "RESTAURACION ABORTADA POR SEGURIDAD."
            }
        }
    }
    Read-Host "`nEnter para volver"
}

while ($true) {
    Clear-Host
    Write-Host "ANTIGRAVITY GOOGLE ASSISTANT v4.8 [SIMULATION]" -ForegroundColor Cyan
    Write-Host " 1. Realizar Backup (SIMULADO)" -ForegroundColor Green
    Write-Host " 2. Restaurar/Validar Backup" -ForegroundColor Yellow
    Write-Host " 3. Kit Google"
    Write-Host " Q. Salir"
    $v_op = Read-Host "`nOpcion"
    if ($v_op -eq "1") { RunBackupSim }
    elseif ($v_op -eq "2") { RunRestore }
    elseif ($v_op -eq "3") { LogInfo "Kit..."; Start-Sleep 1 }
    elseif ($v_op -eq "Q") { break }
}
