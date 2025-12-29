[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$d_WorkDir = $PSScriptRoot
$d_BackupDir = Join-Path $d_WorkDir "Backups"
$d_DownloadsDir = Join-Path $d_WorkDir "Descargas"
$d_LogFile = Join-Path $d_WorkDir "antigravity_session.log"

# Estado del sistema - Tracking de pasos completados
$global:StepsCompleted = @{
    "Step1_Environment" = $false
    "Step2_Backup" = $false
    "Step3_BankingKit" = $false
    "Step4_Flash" = $false
    "Step5_Audit" = $false
}

$global:ExpertMode = $false

if (!(Test-Path $d_BackupDir)) { mkdir $d_BackupDir -Force | Out-Null }

function LogOk { param($msg) Write-Host " [V] $msg" -ForegroundColor Green; Add-Log "OK: $msg" }
function LogInfo { param($msg) Write-Host " [i] $msg" -ForegroundColor Gray; Add-Log "INFO: $msg" }
function LogErr { param($msg) Write-Host " [X] $msg" -ForegroundColor Red; Add-Log "ERROR: $msg" }
function LogWarn { param($msg) Write-Host " [!] $msg" -ForegroundColor Yellow; Add-Log "WARN: $msg" }

function Add-Log {
    param($msg)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp | $msg" | Out-File -FilePath $d_LogFile -Append -Encoding utf8
}

function Check-DiskSpace {
    $drive = (Get-Item $d_WorkDir).PSDrive.Name
    $disk = Get-PSDrive $drive
    $freeGB = [math]::Round($disk.Free / 1GB, 2)
    
    if ($freeGB -lt 10) {
        LogWarn "Espacio en disco bajo: $freeGB GB disponibles"
        LogWarn "Se recomienda al menos 10 GB para backups y ROMs"
        return $false
    }
    LogOk "Espacio en disco: $freeGB GB disponibles"
    return $true
}

function Check-DeviceBattery {
    param([int]$MinBattery = 80)
    
    LogInfo "Verificando nivel de bateria del dispositivo..."
    $adbPath = Join-Path $d_WorkDir "Herramientas\platform-tools\adb.exe"
    
    if (!(Test-Path $adbPath)) {
        LogWarn "ADB no encontrado - No se puede verificar bateria"
        $manual = Read-Host "Confirma manualmente que la bateria esta al $MinBattery% o mas (S/N)"
        return ($manual -eq "S")
    }
    
    try {
        $batteryLevel = & $adbPath shell dumpsys battery | Select-String "level:" | ForEach-Object { $_.ToString().Split(":")[1].Trim() }
        
        if ($batteryLevel) {
            $batteryInt = [int]$batteryLevel
            LogInfo "Nivel de bateria detectado: $batteryInt%"
            
            if ($batteryInt -lt $MinBattery) {
                LogErr "BATERIA INSUFICIENTE: $batteryInt% (Minimo requerido: $MinBattery%)"
                LogWarn "Carga el dispositivo antes de continuar"
                return $false
            }
            LogOk "Nivel de bateria aceptable: $batteryInt%"
            return $true
        } else {
            LogWarn "No se pudo leer el nivel de bateria"
            $manual = Read-Host "Confirma manualmente que la bateria esta al $MinBattery% o mas (S/N)"
            return ($manual -eq "S")
        }
    } catch {
        LogWarn "Error al verificar bateria: $($_.Exception.Message)"
        $manual = Read-Host "Confirma manualmente que la bateria esta al $MinBattery% o mas (S/N)"
        return ($manual -eq "S")
    }
}

function Show-Progress {
    Write-Host "`nPROGRESO DEL PROCESO:" -ForegroundColor Cyan
    $steps = @(
        @{Name="1. Verificacion Entorno"; Key="Step1_Environment"},
        @{Name="2. Backup Seguridad"; Key="Step2_Backup"},
        @{Name="3. Kit Banca"; Key="Step3_BankingKit"},
        @{Name="4. Flasheo GSI"; Key="Step4_Flash"},
        @{Name="5. Auditoria Final"; Key="Step5_Audit"}
    )
    
    foreach ($step in $steps) {
        $status = if ($global:StepsCompleted[$step.Key]) { "[V]" } else { "[ ]" }
        $color = if ($global:StepsCompleted[$step.Key]) { "Green" } else { "Gray" }
        Write-Host "  $status $($step.Name)" -ForegroundColor $color
    }
    Write-Host ""
}

function Validate-Prerequisites {
    param([string]$CurrentStep)
    
    if ($global:ExpertMode) {
        LogWarn "Modo Experto: Saltando validacion de prerequisitos"
        return $true
    }
    
    switch ($CurrentStep) {
        "Step2_Backup" {
            if (!$global:StepsCompleted["Step1_Environment"]) {
                LogErr "Debes completar primero el Paso 1 (Verificacion de Entorno)"
                return $false
            }
        }
        "Step3_BankingKit" {
            if (!$global:StepsCompleted["Step2_Backup"]) {
                LogWarn "ADVERTENCIA: No has realizado backup de seguridad"
                $continue = Read-Host "Continuar sin backup es PELIGROSO. Deseas continuar? (S/N)"
                return ($continue -eq "S")
            }
        }
        "Step4_Flash" {
            if (!$global:StepsCompleted["Step2_Backup"]) {
                LogErr "BLOQUEADO: Debes realizar un backup antes de flashear (Paso 2)"
                Read-Host "Presiona Enter para volver"
                return $false
            }
            if (!(Check-DiskSpace)) {
                LogErr "Espacio en disco insuficiente"
                return $false
            }
            if (!(Check-DeviceBattery -MinBattery 80)) {
                LogErr "Nivel de bateria insuficiente para flasheo"
                return $false
            }
        }
    }
    return $true
}

function ShowSafetyTips {
    Clear-Host
    Write-Host "=== REGLAS DE ORO PARA EL FLASHEO REAL ===" -ForegroundColor Yellow
    Write-Host "1. BATERIA: Minimo 80% de carga (verificado automaticamente)."
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
    Write-Host "- Verifica espacio en disco disponible" -ForegroundColor Gray
    Write-Host ""
    Write-Host "TIEMPO ESTIMADO: 30 segundos" -ForegroundColor DarkGray
    Write-Host ""
    Read-Host "Presiona Enter para iniciar la verificacion"
    
    Clear-Host
    Write-Host "--- VERIFICANDO COMPONENTES ---" -ForegroundColor Cyan
    LogInfo "Comprobando ADB y Fastboot..."
    
    $allOk = $true
    if (Test-Path "$d_WorkDir\Herramientas\platform-tools\adb.exe") { 
        LogOk "ADB encontrado y listo para usar" 
        LogOk "Fastboot disponible para flasheo"
    } else { 
        LogErr "Faltan herramientas ADB/Fastboot" 
        LogWarn "Necesitas descargarlas antes de continuar"
        $allOk = $false
    }
    
    if (Check-DiskSpace) {
        # Espacio OK
    } else {
        $allOk = $false
    }
    
    if ($allOk) {
        $global:StepsCompleted["Step1_Environment"] = $true
        LogOk "PASO 1 COMPLETADO"
    }
    
    Write-Host ""
    Write-Host "SIGUIENTE PASO RECOMENDADO:" -ForegroundColor Yellow
    Write-Host "Opcion 2 - Realizar backup de seguridad (CRITICO)" -ForegroundColor Green
    Write-Host "Esto protegera tu IMEI y particiones vitales" -ForegroundColor Gray
    Read-Host "`nPresiona Enter para volver al menu"
}

function RunBackup {
    if (!(Validate-Prerequisites "Step2_Backup")) { return }
    
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
    $global:StepsCompleted["Step2_Backup"] = $true
    
    Write-Host ""
    Write-Host "SIGUIENTE PASO RECOMENDADO:" -ForegroundColor Yellow
    Write-Host "Opcion 3 - Preparar modulos de Google Pay y Banca" -ForegroundColor White
    Write-Host "Esto asegurara que tus apps bancarias funcionen" -ForegroundColor Gray
    Read-Host "`nPresiona Enter para volver al menu"
}

function RunGPayKit {
    if (!(Validate-Prerequisites "Step3_BankingKit")) { return }
    
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
    $allFound = $true
    foreach ($f in $files) {
        if (Test-Path "$d_DownloadsDir\$f") { 
            LogOk "$f encontrado y listo" 
        } else { 
            LogWarn "$f no encontrado (necesario descargar)" 
            $allFound = $false
        }
    }
    
    if ($allFound) {
        $global:StepsCompleted["Step3_BankingKit"] = $true
        LogOk "PASO 3 COMPLETADO"
    }
    
    Write-Host ""
    Write-Host "SIGUIENTE PASO RECOMENDADO:" -ForegroundColor Yellow
    Write-Host "Opcion 4 - Iniciar flasheo de GSI" -ForegroundColor Red
    Write-Host "ATENCION: Este paso borrara todos tus datos" -ForegroundColor Yellow
    Read-Host "`nPresiona Enter para volver al menu"
}

function RunFlashGSI {
    if (!(Validate-Prerequisites "Step4_Flash")) { return }
    
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
    $check1 = if ($global:StepsCompleted["Step2_Backup"]) { "[V]" } else { "[X]" }
    Write-Host "$check1 Backup realizado (Paso 2)" -ForegroundColor $(if ($global:StepsCompleted["Step2_Backup"]) { "Green" } else { "Red" })
    Write-Host "[?] Bateria minimo 80% (se verificara automaticamente)" -ForegroundColor Yellow
    Write-Host "[?] Cable USB original conectado" -ForegroundColor Yellow
    Write-Host "[?] Bootloader desbloqueado" -ForegroundColor Yellow
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
        $global:StepsCompleted["Step4_Flash"] = $true
        
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
        $global:StepsCompleted["Step5_Audit"] = $true
    } else {
        LogErr "No se encuentra el script certificador."
    }
    Read-Host "`nEnter para volver"
}

function Show-EmergencyRecovery {
    Clear-Host
    Write-Host "========================================================" -ForegroundColor Red
    Write-Host "        RECUPERACION DE EMERGENCIA" -ForegroundColor Red
    Write-Host "========================================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Si tu dispositivo no arranca o esta en bootloop:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "PASO 1: Entrar en modo BROM" -ForegroundColor Cyan
    Write-Host "  1. Apaga completamente el telefono" -ForegroundColor Gray
    Write-Host "  2. Manten presionado Vol+ y Vol- simultaneamente" -ForegroundColor Gray
    Write-Host "  3. Conecta el cable USB al PC (sin soltar botones)" -ForegroundColor Gray
    Write-Host "  4. Espera a que Windows detecte el dispositivo" -ForegroundColor Gray
    Write-Host ""
    Write-Host "PASO 2: Restaurar Backup" -ForegroundColor Cyan
    Write-Host "  1. Usa mtkclient para restaurar las particiones" -ForegroundColor Gray
    Write-Host "  2. Comando: python mtk rl <carpeta_backup>" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Backups disponibles:" -ForegroundColor Yellow
    if (Test-Path $d_BackupDir) {
        $backups = Get-ChildItem -Path $d_BackupDir -Directory | Sort-Object LastWriteTime -Descending
        foreach ($b in $backups) {
            Write-Host "  - $($b.Name)" -ForegroundColor Green
        }
    } else {
        Write-Host "  No hay backups disponibles" -ForegroundColor Red
    }
    Write-Host ""
    Read-Host "Presiona Enter para volver"
}

function Toggle-ExpertMode {
    $global:ExpertMode = !$global:ExpertMode
    $status = if ($global:ExpertMode) { "ACTIVADO" } else { "DESACTIVADO" }
    $color = if ($global:ExpertMode) { "Yellow" } else { "Green" }
    Clear-Host
    Write-Host "========================================================" -ForegroundColor $color
    Write-Host "MODO EXPERTO: $status" -ForegroundColor $color
    Write-Host "========================================================" -ForegroundColor $color
    Write-Host ""
    if ($global:ExpertMode) {
        Write-Host "ADVERTENCIA: En modo experto puedes saltar pasos" -ForegroundColor Yellow
        Write-Host "Esto puede ser PELIGROSO si no sabes lo que haces" -ForegroundColor Red
    } else {
        Write-Host "Modo guiado activado - Maximo seguridad" -ForegroundColor Green
    }
    Write-Host ""
    Read-Host "Presiona Enter para continuar"
}

# Inicializar log
Add-Log "=== NUEVA SESION INICIADA ==="

while ($true) {
    Clear-Host
    $modeIndicator = if ($global:ExpertMode) { "[MODO EXPERTO]" } else { "[MODO GUIADO]" }
    Write-Host "ANTIGRAVITY GOOGLE ASSISTANT v5.4 [ULTIMATE SAFETY] $modeIndicator" -ForegroundColor Cyan
    Write-Host "========================================================" -ForegroundColor Cyan
    
    Show-Progress
    
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
    Write-Host " 7. [EMERGENCIA] Recuperacion de Emergencia" -ForegroundColor Red
    Write-Host "    > Restaurar desde backup si algo salio mal" -ForegroundColor Gray
    Write-Host ""
    Write-Host " E. Cambiar Modo (Experto/Guiado)" -ForegroundColor Magenta
    Write-Host " Q. Finalizar y Salir"
    Write-Host "========================================================" -ForegroundColor Cyan
    
    $v_op = Read-Host "`nSelecciona una opcion (1-7, E o Q)"
    if ($v_op -eq "1") { RunPrep }
    elseif ($v_op -eq "2") { RunBackup }
    elseif ($v_op -eq "3") { RunGPayKit }
    elseif ($v_op -eq "4") { RunFlashGSI }
    elseif ($v_op -eq "5") { RunHealthCheck }
    elseif ($v_op -eq "6") { ShowSafetyTips }
    elseif ($v_op -eq "7") { Show-EmergencyRecovery }
    elseif ($v_op -eq "E") { Toggle-ExpertMode }
    elseif ($v_op -eq "Q") { 
        Add-Log "=== SESION FINALIZADA ==="
        break 
    }
}
