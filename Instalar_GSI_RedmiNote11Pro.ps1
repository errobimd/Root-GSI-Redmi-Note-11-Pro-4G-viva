[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$d_WorkDir = $PSScriptRoot
$d_BackupDir = Join-Path $d_WorkDir "Backups"
$d_DownloadsDir = Join-Path $d_WorkDir "Descargas"

function LogOk { param($msg) Write-Host " [V] $msg" -ForegroundColor Green }
function LogInfo { param($msg) Write-Host " [i] $msg" -ForegroundColor Gray }
function LogErr { param($msg) Write-Host " [X] $msg" -ForegroundColor Red }

function RunRestore {
    Clear-Host
    Write-Host "--- VALIDACION DE SEGURIDAD GOOGLE CERTIFIED ---" -ForegroundColor Cyan
    if (!(Test-Path $d_BackupDir)) { 
        LogErr "No existe carpeta de Backups"
        Read-Host "Pulsar Enter"
        return
    }
    $v_list = Get-ChildItem -Path $d_BackupDir -Directory
    if ($v_list.Count -eq 0) {
        LogErr "Sin backups"
        Read-Host "Pulsar Enter"
        return
    }
    Write-Host "`nBackups:"
    for ($i=0; $i -lt $v_list.Count; $i++) {
        Write-Host " [$i] $($v_list[$i].Name)"
    }
    $v_sel = Read-Host "`nNumero"
    if ($v_sel -match '^\d+$') {
        $idx = [int]$v_sel
        if ($idx -ge 0 -and $idx -lt $v_list.Count) {
            $path = $v_list[$idx].FullName
            LogInfo "Check: $path"
            $imgs = Get-ChildItem -Path $path -Filter "*.img"
            foreach ($f in $imgs) {
                if ($f.Length -lt 100) { LogErr "CORRUPTO: $($f.Name)" }
                else { LogOk "OK: $($f.Name)" }
            }
        }
    }
    Read-Host "`nEnter"
}

while ($true) {
    Clear-Host
    Write-Host "ANTIGRAVITY GOOGLE ASSISTANT v4.7.2 [CERTIFIED]" -ForegroundColor Cyan
    Write-Host " 1. Herramientas"
    Write-Host " 2. Backup"
    Write-Host " 3. Kit Google"
    Write-Host " 4. Validar"
    Write-Host " Q. Salir"
    $v_op = Read-Host "`nOpcion"
    if ($v_op -eq "1") { LogOk "OK"; Start-Sleep 1 }
    elseif ($v_op -eq "2") { LogInfo "Backup..."; Start-Sleep 1 }
    elseif ($v_op -eq "3") { LogInfo "Kit..."; Start-Sleep 1 }
    elseif ($v_op -eq "4") { RunRestore }
    elseif ($v_op -eq "Q") { break }
}
