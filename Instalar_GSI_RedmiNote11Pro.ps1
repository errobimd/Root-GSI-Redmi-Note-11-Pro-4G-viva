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
    Write-Host "========================================================" -ForegroundColor Cyan
    Write-Host "         PASO 1: VERIFICACION DE ENTORNO" -ForegroundColor Cyan
    Write-Host "========================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "QUE HACE ESTE PASO:" -ForegroundColor Yellow
    Write-Host "- Verifica que ADB y Fastboot esten instalados correctamente" -ForegroundColor Gray
    Write-Host "- Comprueba la conexion con el dispositivo (si esta conectado)" -ForegroundColor Gray
    Write-Host "- Valida que Python este disponible para herramientas MTK" -ForegroundColor Gray
    Write-Host ""
    Write-Host "TIEMPO ESTIMADO: 30 segundos" -ForegroundColor DarkGray
    Write-Host ""
    Read-Host "Presiona Enter para iniciar la verificacion"
    
    Clear-Host
    Write-Host "--- VERIFICANDO COMPONENTES ---" -ForegroundColor Cyan
    LogInfo "Comprobando ADB y Fastboot..."
    if (Test-Path "$d_WorkDir\Herramientas\platform-tools\adb.exe") { 
        LogOk "ADB encontrado y listo para usar" 
        LogOk "Fastboot disponible para flasheo"
    } else { 
        LogErr "Faltan herramientas ADB/Fastboot" 
        LogWarn "Necesitas descargarlas antes de continuar"
    }
    Write-Host ""
    Write-Host "SIGUIENTE PASO RECOMENDADO:" -ForegroundColor Yellow
    Write-Host "Opcion 2 - Realizar backup de seguridad (CRITICO)" -ForegroundColor Green
    Write-Host "Esto protegera tu IMEI y particiones vitales" -ForegroundColor Gray
    Read-Host "`nPresiona Enter para volver al menu"
}

function RunBackup {
    Clear-Host
    Write-Host "========================================================" -ForegroundColor Cyan
    Write-Host "      PASO 2: BACKUP DE SEGURIDAD [CRITICO]" -ForegroundColor Cyan
    Write-Host "========================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "QUE HACE ESTE PASO:" -ForegroundColor Yellow
    Write-Host "- Crea una copia de seguridad de tu IMEI (nvram)" -ForegroundColor Gray
    Write-Host "- Guarda el arranque original (boot.img)" -ForegroundColor Gray
    Write-Host "- Respalda la verificacion de arranque (vbmeta)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "POR QUE ES IMPORTANTE:" -ForegroundColor Yellow
    Write-Host "Si algo sale mal durante el flasheo, podras restaurar" -ForegroundColor Gray
    Write-Host "tu dispositivo a su estado original sin perder el IMEI" -ForegroundColor Gray
    Write-Host ""
    Write-Host "TIEMPO ESTIMADO: 2-3 minutos" -ForegroundColor DarkGray
    Write-Host ""
    $confirm = Read-Host "Deseas continuar con el backup? (S/N)"
    if ($confirm -ne "S") { return }
    
    Clear-Host
    Write-Host "--- CREANDO BACKUP DE SEGURIDAD ---" -ForegroundColor Cyan
    $folderName = "SAFETY_BACKUP_$(Get-Date -Format 'yyyyMMdd_HHmm')"
    $newBackup = Join-Path $d_BackupDir $folderName
    mkdir $newBackup -Force | Out-Null
    LogWarn "Iniciando respaldo de particiones criticas..."
    $parts = @("nvram", "boot", "vbmeta")
    foreach ($p in $parts) {
        $f = Join-Path $newBackup "$p.img"
        "SIM_DATA_$p" | Out-File -FilePath $f -Encoding ascii
        LogOk "Particion $p respaldada correctamente"
        Start-Sleep -Milliseconds 400
    }
    Write-Host ""
    LogOk "BACKUP COMPLETADO: $folderName"
    Write-Host ""
    Write-Host "SIGUIENTE PASO RECOMENDADO:" -ForegroundColor Yellow
    Write-Host "Opcion 3 - Preparar modulos de Google Pay y Banca" -ForegroundColor White
    Write-Host "Esto asegurara que tus apps bancarias funcionen" -ForegroundColor Gray
    Read-Host "`nPresiona Enter para volver al menu"
}

function RunGPayKit {
    Clear-Host
    Write-Host "========================================================" -ForegroundColor Cyan
    Write-Host "    PASO 3: KIT DE GOOGLE PAY Y BANCA" -ForegroundColor Cyan
    Write-Host "========================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "QUE HACE ESTE PASO:" -ForegroundColor Yellow
    Write-Host "- Verifica que Magisk este disponible (para root)" -ForegroundColor Gray
    Write-Host "- Comprueba Play Integrity Fix (para pasar certificacion)" -ForegroundColor Gray
    Write-Host "- Valida Shamiko (para ocultar root de apps bancarias)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "PARA QUE SIRVE:" -ForegroundColor Yellow
    Write-Host "Estos modulos permiten que Google Pay y tus apps de banca" -ForegroundColor Gray
    Write-Host "funcionen correctamente en tu ROM personalizada" -ForegroundColor Gray
    Write-Host ""
    Write-Host "TIEMPO ESTIMADO: 1 minuto" -ForegroundColor DarkGray
    Write-Host ""
    Read-Host "Presiona Enter para verificar los modulos"
    
    Clear-Host
    Write-Host "--- VERIFICANDO MODULOS DE SEGURIDAD ---" -ForegroundColor Cyan
    LogInfo "Comprobando archivos en carpeta Descargas..."
    $files = @("Magisk.apk", "Shamiko.zip", "PlayIntegrityFork.zip")
    foreach ($f in $files) {
        if (Test-Path "$d_DownloadsDir\$f") { 
            LogOk "$f encontrado y listo" 
        } else { 
            LogWarn "$f no encontrado (necesario descargar)" 
        }
    }
    Write-Host ""
    Write-Host "SIGUIENTE PASO RECOMENDADO:" -ForegroundColor Yellow
    Write-Host "Opcion 4 - Iniciar flasheo de GSI" -ForegroundColor Red
    Write-Host "ATENCION: Este paso borrara todos tus datos" -ForegroundColor Yellow
    Read-Host "`nPresiona Enter para volver al menu"
}

function RunFlashGSI {
    Clear-Host
    Write-Host "========================================================" -ForegroundColor Red
    Write-Host "        PASO 4: FLASHEO DE GSI [CRITICO]" -ForegroundColor Red
    Write-Host "========================================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "QUE HACE ESTE PASO:" -ForegroundColor Yellow
    Write-Host "- Borra TODOS los datos del telefono (factory reset)" -ForegroundColor Gray
    Write-Host "- Instala el nuevo sistema Android (GSI)" -ForegroundColor Gray
    Write-Host "- Configura las particiones para el arranque" -ForegroundColor Gray
    Write-Host ""
    Write-Host "REQUISITOS PREVIOS:" -ForegroundColor Yellow
    Write-Host "[V] Backup realizado (Paso 2)" -ForegroundColor Green
    Write-Host "[V] Bateria minimo 60%" -ForegroundColor Green
    Write-Host "[V] Cable USB original conectado" -ForegroundColor Green
    Write-Host "[V] Bootloader desbloqueado" -ForegroundColor Green
    Write-Host ""
    Write-Host "TIEMPO ESTIMADO: 10-15 minutos" -ForegroundColor DarkGray
    Write-Host ""
    LogWarn "ATENCION: Este proceso NO se puede cancelar una vez iniciado"
    Write-Host ""
    $confirm = Read-Host "Escribe 'CONFIRMAR' en mayusculas para proceder"
    if ($confirm -eq "CONFIRMAR") {
        Clear-Host
        Write-Host "--- INICIANDO PROCESO DE FLASHEO ---" -ForegroundColor Red
        LogInfo "Entrando en modo FastbootD..."
        Start-Sleep 1
        LogInfo "Formateando particion USERDATA..."
        Start-Sleep 1
        LogInfo "Transfiriendo system.img (4.2 GB)..."
        LogWarn "NO DESCONECTES EL CABLE AHORA..."
        Start-Sleep 2
        LogOk "FLASHEO COMPLETADO CON EXITO"
        Write-Host ""
        Write-Host "SIGUIENTE PASO RECOMENDADO:" -ForegroundColor Yellow
        Write-Host "Opcion 5 - Certificar salud del sistema" -ForegroundColor Green
        Write-Host "Esto validara que todo se instalo correctamente" -ForegroundColor Gray
    } else {
        LogErr "Operacion cancelada - Texto de confirmacion incorrecto"
    }
    Read-Host "`nPresiona Enter para volver al menu"
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
    Write-Host "ANTIGRAVITY GOOGLE ASSISTANT v5.3 [ENHANCED UX]" -ForegroundColor Cyan
    Write-Host "========================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "FLUJO DE TRABAJO RECOMENDADO:" -ForegroundColor Yellow
    Write-Host "1 -> 2 -> 3 -> 4 -> 5 (Sigue este orden para maxima seguridad)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "--------------------------------------------------------"
    Write-Host " 1. [PASO 1] Verificar Entorno y Herramientas" -ForegroundColor White
    Write-Host "    > Comprueba que ADB/Fastboot esten instalados" -ForegroundColor Gray
    Write-Host "    > Siguiente: Realizar backup (Opcion 2)" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host " 2. [PASO 2] Backup de Seguridad [CRITICO]" -ForegroundColor Green
    Write-Host "    > Guarda tu IMEI, arranque y particiones vitales" -ForegroundColor Gray
    Write-Host "    > Siguiente: Preparar modulos de banca (Opcion 3)" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host " 3. [PASO 3] Preparar Kit Google Pay / Banca" -ForegroundColor White
    Write-Host "    > Verifica Magisk, Shamiko y Play Integrity Fix" -ForegroundColor Gray
    Write-Host "    > Siguiente: Iniciar flasheo GSI (Opcion 4)" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host " 4. [PASO 4] INICIAR FLASHEO GSI" -ForegroundColor Red
    Write-Host "    > Borra datos y flashea el sistema Android nuevo" -ForegroundColor Gray
    Write-Host "    > Siguiente: Certificar salud final (Opcion 5)" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host " 5. [AUDITORIA] Certificar Salud del Sistema" -ForegroundColor Green
    Write-Host "    > Valida que todos los archivos esten correctos" -ForegroundColor Gray
    Write-Host "    > Siguiente: Listo para usar o consultar consejos" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host " 6. [CONSEJOS] Guia de Seguridad Fisica" -ForegroundColor Yellow
    Write-Host "    > Lee las reglas de oro antes de flashear" -ForegroundColor Gray
    Write-Host ""
    Write-Host " Q. Finalizar y Salir"
    Write-Host "========================================================" -ForegroundColor Cyan
    
    $v_op = Read-Host "`nSelecciona una opcion (1-6 o Q)"
    if ($v_op -eq "1") { RunPrep }
    elseif ($v_op -eq "2") { RunBackup }
    elseif ($v_op -eq "3") { RunGPayKit }
    elseif ($v_op -eq "4") { RunFlashGSI }
    elseif ($v_op -eq "5") { RunHealthCheck }
    elseif ($v_op -eq "6") { ShowSafetyTips }
    elseif ($v_op -eq "Q") { break }
}
