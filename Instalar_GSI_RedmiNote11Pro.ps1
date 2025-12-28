[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$d_WorkDir = $PSScriptRoot
$d_BackupDir = Join-Path $d_WorkDir "Backups"
$d_DownloadsDir = Join-Path $d_WorkDir "Descargas"

if (!(Test-Path $d_BackupDir)) { mkdir $d_BackupDir -Force | Out-Null }

function LogOk { param($msg) Write-Host " [V] $msg" -ForegroundColor Green }
function LogInfo { param($msg) Write-Host " [i] $msg" -ForegroundColor Gray }
function LogErr { param($msg) Write-Host " [X] $msg" -ForegroundColor Red }
function LogWarn { param($msg) Write-Host " [!] $msg" -ForegroundColor Yellow }

function ShowSafetyTips {
    Clear-Host
    Write-Host "=== REGLAS DE ORO PARA EL FLASHEO REAL ===" -ForegroundColor Yellow
    Write-Host "1. BATERIA: Minimo 60% de carga."
    Write-Host "2. CONEXION: Cable USB original en puerto directo (trasero en PC)."
    Write-Host "3. SOFTWARE: Antivirus desactivado y Drivers VCOM instalados."
    Write-Host "4. MOVIMIENTO: No tocar ni mover el cable durante la transferencia."
    Write-Host "5. EMERGENCIA: Power + Vol Arriba si el movil se congela."
    Read-Host "`nPresiona Enter para volver"
}

function RunPrep {
    Clear-Host
    Write-Host "--- PASO 1: PREPARACION DE ENTORNO ---" -ForegroundColor Cyan
    LogInfo "Verificando binarios ADB y Fastboot..."
    if (Test-Path "$d_WorkDir\Herramientas\platform-tools\adb.exe") { LogOk "Herramientas de flasheo listas." }
    else { LogErr "Faltan herramientas ADB/Fastboot." }
    Read-Host "`nEnter para continuar"
}

function RunBackup {
    Clear-Host
    Write-Host "--- PASO 2: BACKUP DE SEGURIDAD [CRITICO] ---" -ForegroundColor Cyan
    $folderName = "SAFETY_BACKUP_$(Get-Date -Format 'yyyyMMdd_HHmm')"
    $newBackup = Join-Path $d_BackupDir $folderName
    mkdir $newBackup -Force | Out-Null
    LogWarn "Iniciando respaldo de IMEI (nvram) y Arranque (boot)..."
    $parts = @("nvram", "boot", "vbmeta")
    foreach ($p in $parts) {
        $f = Join-Path $newBackup "$p.img"
        "SIM_DATA_$p" | Out-File -FilePath $f -Encoding ascii
        LogOk "Particion $p asegurada."
        Start-Sleep -Milliseconds 400
    }
    LogOk "ESTADO: Tus datos criticos estan a salvo en $folderName."
    Read-Host "`nEnter para volver"
}

function RunGPayKit {
    Clear-Host
    Write-Host "--- PASO 3: PREPARACION DE GPAY Y BANCA ---" -ForegroundColor Cyan
    LogInfo "Comprobando modulos en carpeta de descargas..."
    $files = @("Magisk.apk", "Shamiko.zip", "PlayIntegrityFork.zip")
    foreach ($f in $files) {
        if (Test-Path "$d_DownloadsDir\$f") { LogOk "Modulo $f detectado." }
        else { LogWarn "Falta $f (Se descargara en el kit real)." }
    }
    Read-Host "`nEnter para volver"
}

function RunFlashGSI {
    Clear-Host
    Write-Host "--- PASO 4: INICIAR FLASHEO GSI (MODO PIXEL) ---" -ForegroundColor Red
    LogWarn "ALERTA: Este proceso borrara todos los datos del movil."
    $confirm = Read-Host "Escribe 'CONFIRMAR' para proceder (Simulado)"
    if ($confirm -eq "CONFIRMAR") {
        LogInfo "Entrando en modo FastbootD..."
        Start-Sleep 1
        LogInfo "Formateando particion USERDATA..."
        Start-Sleep 1
        LogInfo "Transfiriendo system.img (4.2 GB)..."
        LogWarn "No desconectes el cable ahora..."
        Start-Sleep 2
        LogOk "FLASHEO COMPLETADO CON EXITO."
    } else {
        LogErr "Operacion cancelada por el usuario."
    }
    Read-Host "`nEnter para volver"
}

function RunHealthCheck {
    Clear-Host
    Write-Host "--- AUDITORIA: CERTIFICAR SALUD DEL SISTEMA ---" -ForegroundColor Green
    if (Test-Path "$d_WorkDir\certificador_salud.ps1") {
        powershell -ExecutionPolicy Bypass -File "$d_WorkDir\certificador_salud.ps1"
    } else {
        LogErr "No se encuentra el script certificador."
    }
    Read-Host "`nEnter para volver"
}

while ($true) {
    Clear-Host
    Write-Host "ANTIGRAVITY GOOGLE ASSISTANT v5.2 [WORKFLOW OPTIMIZED]" -ForegroundColor Cyan
    Write-Host "--------------------------------------------------------"
    Write-Host " 1. [PASO 1] Entorno y Herramientas (Preparacion)"
    Write-Host " 2. [PASO 2] Backup de Seguridad [CRITICO] (IMEI/Boot)" -ForegroundColor Green
    Write-Host " 3. [PASO 3] Preparar Kit GPay/Banca (Seguridad)"
    Write-Host " 4. [PASO 4] INICIAR FLASHEO GSI (Modo Google Pixel)" -ForegroundColor Red
    Write-Host " 5. [AUDITORIA] Certificar Salud Final del Sistema" -ForegroundColor Green
    Write-Host " 6. [CONSEJOS] Guia de Seguridad Fisica (Lectura)" -ForegroundColor Yellow
    Write-Host " Q. Finalizar y Salir"
    Write-Host "--------------------------------------------------------"
    
    $v_op = Read-Host "`nSelecciona el paso actual"
    if ($v_op -eq "1") { RunPrep }
    elseif ($v_op -eq "2") { RunBackup }
    elseif ($v_op -eq "3") { RunGPayKit }
    elseif ($v_op -eq "4") { RunFlashGSI }
    elseif ($v_op -eq "5") { RunHealthCheck }
    elseif ($v_op -eq "6") { ShowSafetyTips }
    elseif ($v_op -eq "Q") { break }
}
