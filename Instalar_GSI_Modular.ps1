# ============================================================
# ANTIGRAVITY GOOGLE ASSISTANT v5.7 - ULTIMATE EDITION
# Script Principal Modular
# ============================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Directorios
$d_WorkDir = $PSScriptRoot
$d_ModulesDir = Join-Path $d_WorkDir "Modules"
$d_BackupDir = Join-Path $d_WorkDir "Backups"
$d_DownloadsDir = Join-Path $d_WorkDir "Descargas"
$d_ReportsDir = Join-Path $d_WorkDir "Reportes"
$d_LogFile = Join-Path $d_WorkDir "antigravity_session.log"
$d_ProfileFile = Join-Path $d_WorkDir "user_profile.json"
$d_HashDB = Join-Path $d_WorkDir "file_hashes.db"
$d_DownloadDB = Join-Path $d_WorkDir "download_urls.db"

# Crear directorios si no existen
@($d_BackupDir, $d_DownloadsDir, $d_ReportsDir) | ForEach-Object {
    if (!(Test-Path $_)) { mkdir $_ -Force | Out-Null }
}

# ============================================================
# IMPORTAR MODULOS
# ============================================================

try {
    Import-Module "$d_ModulesDir\UserProfile.psm1" -Force
    Import-Module "$d_ModulesDir\FileIntegrity.psm1" -Force
    Import-Module "$d_ModulesDir\DeviceDetection.psm1" -Force
    Import-Module "$d_ModulesDir\DownloadAssistant.psm1" -Force
    Import-Module "$d_ModulesDir\Notifications.psm1" -Force
    Import-Module "$d_ModulesDir\BackupManager.psm1" -Force
    Import-Module "$d_ModulesDir\ArchiveManager.psm1" -Force
    Write-Host "[V] Modulos cargados correctamente" -ForegroundColor Green
}
catch {
    Write-Host "[X] Error al cargar modulos: $($_.Exception.Message)" -ForegroundColor Red
    Read-Host "Presiona Enter para salir"
    exit 1
}

# ============================================================
# VARIABLES GLOBALES
# ============================================================

$global:StepsCompleted = @{
    "Step1_Environment" = $false
    "Step2_Backup"      = $false
    "Step3_BankingKit"  = $false
    "Step4_Flash"       = $false
    "Step5_Audit"       = $false
}

$global:OperationMode = "DEMO"  # DEMO, GUIADO, EXPERTO
$global:DeviceVerified = $false
$global:LastBackupDate = ""

# ============================================================
# FUNCIONES DE LOGGING
# ============================================================

function Add-Log {
    param($msg)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp | $msg" | Out-File -FilePath $d_LogFile -Append -Encoding utf8
}

function LogOk { param($msg) Write-Host " [V] $msg" -ForegroundColor Green; Add-Log "OK: $msg" }
function LogInfo { param($msg) Write-Host " [i] $msg" -ForegroundColor Gray; Add-Log "INFO: $msg" }
function LogErr { param($msg) Write-Host " [X] $msg" -ForegroundColor Red; Add-Log "ERROR: $msg" }
function LogWarn { param($msg) Write-Host " [!] $msg" -ForegroundColor Yellow; Add-Log "WARN: $msg" }

# ============================================================
# FUNCIONES AUXILIARES
# ============================================================

function Show-Progress {
    Write-Host "`nPROGRESO DEL PROCESO:" -ForegroundColor Cyan
    $steps = @(
        @{Name = "1. Verificacion Entorno"; Key = "Step1_Environment" },
        @{Name = "2. Backup Seguridad"; Key = "Step2_Backup" },
        @{Name = "3. Kit Banca"; Key = "Step3_BankingKit" },
        @{Name = "4. Flasheo GSI"; Key = "Step4_Flash" },
        @{Name = "5. Auditoria Final"; Key = "Step5_Audit" }
    )
    
    foreach ($step in $steps) {
        $status = if ($global:StepsCompleted[$step.Key]) { "[V]" } else { "[ ]" }
        $color = if ($global:StepsCompleted[$step.Key]) { "Green" } else { "Gray" }
        Write-Host "  $status $($step.Name)" -ForegroundColor $color
    }
    Write-Host ""
}

function Test-Prerequisites {
    param([string]$CurrentStep)
    
    if ($global:OperationMode -eq "EXPERTO") {
        LogWarn "Modo Experto: Saltando validacion"
        return $true
    }
    
    if ($global:OperationMode -eq "DEMO") {
        return $true
    }
    
    # Validaciones para modo GUIADO
    switch ($CurrentStep) {
        "Step4_Flash" {
            if (!$global:StepsCompleted["Step2_Backup"]) {
                LogErr "BLOQUEADO: Debes realizar backup antes de flashear"
                Read-Host "Presiona Enter para volver"
                return $false
            }
        }
    }
    return $true
}

# ============================================================
# MENU PRINCIPAL
# ============================================================

function Show-MainMenu {
    Clear-Host
    
    $modeColor = switch ($global:OperationMode) {
        "DEMO" { "Magenta" }
        "GUIADO" { "Green" }
        "EXPERTO" { "Red" }
    }
    
    Write-Host "ANTIGRAVITY GOOGLE ASSISTANT v5.7 [ULTIMATE EDITION]" -ForegroundColor Cyan
    Write-Host "========================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "MODO ACTUAL: $($global:OperationMode)" -ForegroundColor $modeColor
    
    if ($global:OperationMode -eq "DEMO") {
        Write-Host "Modo DEMOSTRACION - No ejecuta operaciones reales" -ForegroundColor Magenta
    }
    elseif ($global:OperationMode -eq "GUIADO") {
        Write-Host "Modo GUIADO - Operaciones reales con validacion" -ForegroundColor Green
    }
    else {
        Write-Host "Modo EXPERTO - Sin validaciones (PELIGROSO)" -ForegroundColor Red
    }
    Write-Host ""
    
    Show-Progress
    
    Write-Host "MENU PRINCIPAL:" -ForegroundColor Yellow
    Write-Host " 1. Verificar Entorno" -ForegroundColor White
    Write-Host " 2. Backup de Seguridad" -ForegroundColor White
    Write-Host " 3. Kit Google Pay/Banca" -ForegroundColor White
    Write-Host " 4. Flashear GSI" -ForegroundColor Red
    Write-Host " 5. Auditoria Final" -ForegroundColor Green
    Write-Host " 6. Consejos de Seguridad" -ForegroundColor Yellow
    Write-Host " 7. Recuperacion de Emergencia" -ForegroundColor Red
    Write-Host " 8. Asistente de Descargas" -ForegroundColor Cyan
    Write-Host " 9. Generar Reporte HTML" -ForegroundColor Cyan
    Write-Host " M. Cambiar Modo" -ForegroundColor Magenta
    Write-Host " Q. Salir" -ForegroundColor Gray
    Write-Host "========================================================" -ForegroundColor Cyan
}

# ============================================================
# FUNCIONES DE PASOS (Simplificadas para demostración)
# ============================================================

function Step1-VerifyEnvironment {
    Clear-Host
    Write-Host "=== PASO 1: VERIFICACION DE ENTORNO ===" -ForegroundColor Cyan
    Write-Host ""
    
    LogInfo "Verificando herramientas..."
    
    # Usar módulo de detección de dispositivo
    $adbPath = Join-Path $d_WorkDir "Herramientas\platform-tools\adb.exe"
    if (Test-Path $adbPath) {
        LogOk "ADB encontrado"
        LogInfo "Detectando dispositivo conectado..."
        
        # Comprobacion de autorizacion
        $rawDevices = & $adbPath devices
        if ($rawDevices -match "unauthorized") {
            LogWarn "DISPOSITIVO NO AUTORIZADO"
            Write-Host " [!] REVISA TU MOVIL: Acepta el mensaje '¿Permitir depuracion USB?'" -ForegroundColor Yellow
            Write-Host " [i] Marca la casilla 'Permitir siempre' para evitar este aviso." -ForegroundColor Gray
            Write-Host ""
        }

        # Aviso sobre puertos USB
        Write-Host " [!] NOTA DE HARDWARE: Los puertos USB 3.0 (azules) pueden ser inestables." -ForegroundColor Yellow
        Write-Host " [i] Si falla la deteccion, usa un puerto USB 2.0 (negro)." -ForegroundColor Gray
        
        $device = Get-ConnectedDevice -AdbPath $adbPath
        if ($device -and !$device.Verified) {
            LogWarn "Dispositivo incorrecto detectado"
        }
    }
    else {
        LogWarn "ADB no encontrado"
    }
    
    $global:StepsCompleted["Step1_Environment"] = $true
    Save-UserProfile -ProfilePath $d_ProfileFile
    
    Read-Host "`nPresiona Enter para volver"
}

function Step2-CreateBackup {
    if (!(Test-Prerequisites "Step2_Backup")) { return }
    
    Clear-Host
    Write-Host "=== PASO 2: RESPALDO DE SEGURIDAD (ANTIGRAVITY) ===" -ForegroundColor Cyan
    Write-Host ""
    
    $adbPath = Join-Path $d_WorkDir "Herramientas\platform-tools\adb.exe"
    
    $success = Start-RealBackup -AdbPath $adbPath -BackupBaseDir $d_BackupDir -Mode $global:OperationMode
    
    if ($success) {
        $global:StepsCompleted["Step2_Backup"] = $true
        $global:LastBackupDate = Get-Date -Format "yyyy-MM-dd HH:mm"
        Save-UserProfile -ProfilePath $d_ProfileFile
        
        LogOk "El proceso de backup finalizó correctamente."
        Send-Notification -Title "Backup Exitoso" -Message "Se ha guardado una copia en la carpeta Backups."
    }
    else {
        LogErr "El backup ha fallado o fue cancelado."
    }
    
    Read-Host "`nPresiona Enter para volver"
}

function Step3-VerifyBankingKit {
    Clear-Host
    Write-Host "=== PASO 3: KIT GOOGLE PAY/BANCA ===" -ForegroundColor Cyan
    Write-Host ""
    
    $files = @(
        @{Name = "Magisk.apk"; DisplayName = "Magisk v27.0" },
        @{Name = "Shamiko.zip"; DisplayName = "Shamiko v1.0.1" },
        @{Name = "PlayIntegrityFork.zip"; DisplayName = "Play Integrity Fix" }
    )
    
    $allVerified = $true
    foreach ($fileInfo in $files) {
        $filePath = Join-Path $d_DownloadsDir $fileInfo.Name
        if (Test-Path $filePath) {
            LogOk "$($fileInfo.DisplayName) encontrado"
            # Usar módulo de integridad
            if (!(Test-FileIntegrity -FilePath $filePath -FileName $fileInfo.Name -HashDBPath $d_HashDB)) {
                $allVerified = $false
            }
        }
        else {
            LogWarn "$($fileInfo.DisplayName) no encontrado"
        }
    }
    
    if ($allVerified) {
        $global:StepsCompleted["Step3_BankingKit"] = $true
        Save-UserProfile -ProfilePath $d_ProfileFile
    }
    
    Read-Host "`nPresiona Enter para volver"
}

function Step8-DownloadAssistant {
    Clear-Host
    Write-Host "=== ASISTENTE DE DESCARGAS ===" -ForegroundColor Cyan
    Write-Host ""
    
    $downloadDB = Get-DownloadDatabase -DownloadDBPath $d_DownloadDB
    
    if ($downloadDB.Count -eq 0) {
        LogErr "No se pudo cargar base de datos de descargas"
        Read-Host "Presiona Enter para volver"
        return
    }
    
    Write-Host "Herramientas disponibles:" -ForegroundColor Yellow
    $index = 1
    $tools = @()
    foreach ($tool in $downloadDB.Keys) {
        $tools += $tool
        Write-Host "  $index. $($downloadDB[$tool]['Name'])" -ForegroundColor White
        $index++
    }
    Write-Host "  Q. Volver" -ForegroundColor Gray
    Write-Host ""
    
    $selection = Read-Host "Selecciona una opcion"
    if ($selection -ne "Q" -and [int]$selection -gt 0 -and [int]$selection -le $tools.Count) {
        $selectedTool = $tools[[int]$selection - 1]
        $toolInfo = $downloadDB[$selectedTool]
        $dest = Join-Path $d_DownloadsDir $toolInfo['FileName']
        if (Start-ToolDownload -ToolName $toolInfo['Name'] -Url $toolInfo['URL'] -Destination $dest) {
            # Si es un .xz, ofrecer extraccion
            if ($dest -like "*.xz") {
                $confirm = Read-Host "`n¿Deseas extraer el archivo .img ahora? (S/N)"
                if ($confirm -eq "S") {
                    Expand-XzArchive -FilePath $dest -DestinationDir $d_DownloadsDir
                }
            }
        }
    }
    
    Read-Host "`nPresiona Enter para volver"
}

function Step9-GenerateReport {
    Clear-Host
    Write-Host "=== GENERAR REPORTE HTML ===" -ForegroundColor Cyan
    Write-Host ""
    
    Export-HTMLReport -ReportsDir $d_ReportsDir -LogFile $d_LogFile -StepsCompleted $global:StepsCompleted -OperationMode $global:OperationMode -DeviceVerified $global:DeviceVerified
    
    Read-Host "`nPresiona Enter para volver"
}

function Toggle-Mode {
    Clear-Host
    Write-Host "=== CAMBIAR MODO DE OPERACION ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Modo actual: $($global:OperationMode)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. DEMO (Simulacion)" -ForegroundColor Magenta
    Write-Host "2. GUIADO (Real con validacion)" -ForegroundColor Green
    Write-Host "3. EXPERTO (Real sin validacion)" -ForegroundColor Red
    Write-Host ""
    
    $selection = Read-Host "Selecciona modo (1-3)"
    
    switch ($selection) {
        "1" { $global:OperationMode = "DEMO"; LogOk "Modo cambiado a DEMO" }
        "2" { 
            $confirm = Read-Host "ADVERTENCIA: Modo GUIADO ejecuta operaciones REALES. Confirma con 'SI'"
            if ($confirm -eq "SI") {
                $global:OperationMode = "GUIADO"
                LogOk "Modo cambiado a GUIADO"
            }
        }
        "3" { 
            $confirm = Read-Host "PELIGRO: Modo EXPERTO sin validaciones. Confirma con 'SI ESTOY SEGURO'"
            if ($confirm -eq "SI ESTOY SEGURO") {
                $global:OperationMode = "EXPERTO"
                LogOk "Modo cambiado a EXPERTO"
            }
        }
    }
    
    Start-Sleep -Seconds 2
}

# ============================================================
# BUCLE PRINCIPAL
# ============================================================

Add-Log "=== NUEVA SESION INICIADA ==="
Load-UserProfile -ProfilePath $d_ProfileFile

while ($true) {
    Show-MainMenu
    
    $option = Read-Host "`nSelecciona una opcion"
    
    switch ($option) {
        "1" { Step1-VerifyEnvironment }
        "2" { Step2-CreateBackup }
        "3" { Step3-VerifyBankingKit }
        "6" { Show-SafetyTips }
        "8" { Step8-DownloadAssistant }
        "9" { Step9-GenerateReport }
        "M" { Toggle-Mode }
        "Q" { 
            Save-UserProfile -ProfilePath $d_ProfileFile
            Add-Log "=== SESION FINALIZADA ==="
            Write-Host "`nPerfil guardado. Hasta pronto!" -ForegroundColor Green
            Start-Sleep -Seconds 2
            break
        }
    }
}
