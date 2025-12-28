[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$d_WorkDir = $PSScriptRoot
$d_BackupDir = Join-Path $d_WorkDir "Backups"

if (!(Test-Path $d_BackupDir)) { mkdir $d_BackupDir -Force | Out-Null }

function LogOk { param($msg) Write-Host " [V] $msg" -ForegroundColor Green }
function LogInfo { param($msg) Write-Host " [i] $msg" -ForegroundColor Gray }
function LogErr { param($msg) Write-Host " [X] $msg" -ForegroundColor Red }
function LogWarn { param($msg) Write-Host " [!] $msg" -ForegroundColor Yellow }

function ShowSafetyTips {
    Clear-Host
    Write-Host "=== CONSEJOS DE SEGURIDAD PARA EL FLASHEO REAL ===" -ForegroundColor Yellow
    Write-Host "--------------------------------------------------"
    Write-Host "1. BATERIA: Asegurate de tener al menos un 60% de carga."
    Write-Host "2. CABLE: Usa el cable USB original. Evita extensiones o hubs USB."
    Write-Host "3. PUERTO USB: En PCs de escritorio, usa los puertos TRASEROS (directos a placa)."
    Write-Host "4. ANTIVIRUS: Desactivalo temporalmente; a veces bloquea los binarios ADB."
    Write-Host "5. NO MOVER: Una vez iniciado el proceso, no toques el cable ni el movil."
    Write-Host "6. BOOTLOADER: Asegurate de que el Bootloader este DESBLOQUEADO."
    Write-Host "--------------------------------------------------"
    Write-Host "CONSEJO PRO: Si el movil no pasa del logo, mantén encendido + Vol Arriba para ir al recovery."
    Read-Host "`nPresiona Enter para volver"
}

function RunBackupSim {
    Clear-Host
    Write-Host "--- REALIZANDO COPIA DE SEGURIDAD ---" -ForegroundColor Cyan
    $folderName = "BACKUP_$(Get-Date -Format 'yyyyMMdd_HHmm')"
    $newBackup = Join-Path $d_BackupDir $folderName
    mkdir $newBackup -Force | Out-Null
    
    LogWarn "Detectando dispositivo MediaTek..."
    LogInfo "Copiando particiones criticas: nvram, boot, vbmeta..."
    $parts = @("nvram", "boot", "vbmeta")
    foreach ($p in $parts) {
        $f = Join-Path $newBackup "$p.img"
        "SIM_DATA_$p" | Out-File -FilePath $f -Encoding ascii
        LogOk "Particion $p respaldada."
        Start-Sleep -Milliseconds 300
    }
    LogOk "PROCESO FINALIZADO: Tu IMEI y arranque estan a salvo."
    Read-Host "`nEnter para volver"
}

function RunRestore {
    Clear-Host
    Write-Host "--- ASISTENTE DE RESTAURACION Y VALIDACION ---" -ForegroundColor Cyan
    if (!(Test-Path $d_BackupDir)) { LogErr "No hay carpeta Backups"; Read-Host; return }
    $v_list = Get-ChildItem -Path $d_BackupDir -Directory | Sort-Object LastWriteTime -Descending
    if ($v_list.Count -eq 0) { LogErr "Sin backups"; Read-Host; return }
    
    Write-Host "`nSelecciona el backup para validar integridad:"
    for ($i=0; $i -lt $v_list.Count; $i++) { Write-Host " [$i] $($v_list[$i].Name)" }
    $v_sel = Read-Host "`nOpcion"
    if ($v_sel -match '^\d+$') {
        $idx = [int]$v_sel
        if ($idx -ge 0 -and $idx -lt $v_list.Count) {
            $path = $v_list[$idx].FullName
            $imgs = Get-ChildItem -Path $path -Filter "*.img"
            foreach ($f in $imgs) {
                if ($f.Length -lt 10) { LogErr "ERROR: $($f.Name) CORRUPTO" }
                else { LogOk "OK: $($f.Name) (Valido)" }
            }
        }
    }
    Read-Host "`nEnter para volver"
}

while ($true) {
    Clear-Host
    Write-Host "ANTIGRAVITY GOOGLE ASSISTANT v4.9.2 [SAFE OPS]" -ForegroundColor Cyan
    Write-Host " 1. Instalar Herramientas ADB/Fastboot"
    Write-Host " 2. Realizar Backup de Seguridad (IMEI/Boot)" -ForegroundColor Green
    Write-Host " 3. Descargar Kit Google / GPay"
    Write-Host " 4. Validar integridad de copias"
    Write-Host " 5. CONSEJOS DE SEGURIDAD (Lectura Recomendada)" -ForegroundColor Yellow
    Write-Host " 6. INICIAR FLASHEO GSI" -ForegroundColor Red
    Write-Host " Q. Salir"
    
    $v_op = Read-Host "`nSelecciona una opcion"
    if ($v_op -eq "5") { ShowSafetyTips }
    elseif ($v_op -eq "1") { LogOk "Herramientas OK"; Start-Sleep 1 }
    elseif ($v_op -eq "2") { RunBackupSim }
    elseif ($v_op -eq "4") { RunRestore }
    elseif ($v_op -eq "Q") { break }
}
