# ============================================================
# MODULO: DETECCION DE DISPOSITIVO
# Deteccion automatica via ADB
# ============================================================

function Get-ConnectedDevice {
    param([string]$AdbPath)
    
    Write-Host " [i] Detectando dispositivo conectado..." -ForegroundColor Gray
    
    if (!(Test-Path $AdbPath)) {
        Write-Host " [!] ADB no encontrado - No se puede detectar dispositivo" -ForegroundColor Yellow
        return $null
    }
    
    try {
        $devices = & $AdbPath devices | Select-String -Pattern "device$"
        if (!$devices) {
            Write-Host " [!] No hay dispositivos conectados via ADB" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "CONSEJOS DE CONEXION:" -ForegroundColor Cyan
            Write-Host " 1. Verifica que la 'Depuracion USB' este activada en el movil." -ForegroundColor Gray
            Write-Host " 2. CAMBIA DE PUERTO: Los puertos USB 3.0 (azules/rojos) suelen fallar." -ForegroundColor Yellow
            Write-Host " 3. Usa un puerto USB 2.0 (negro) para mayor estabilidad." -ForegroundColor Green
            Write-Host " 4. Asegurate de que el cable sea el original o de alta calidad." -ForegroundColor Gray
            Write-Host ""
            return $null
        }
        
        $deviceModel = & $AdbPath shell getprop ro.product.device 2>$null
        $deviceName = & $AdbPath shell getprop ro.product.model 2>$null
        $androidVersion = & $AdbPath shell getprop ro.build.version.release 2>$null
        
        if ($deviceModel) {
            $deviceModel = $deviceModel.Trim()
            $deviceName = $deviceName.Trim()
            $androidVersion = $androidVersion.Trim()
            
            Write-Host ""
            Write-Host "DISPOSITIVO DETECTADO:" -ForegroundColor Cyan
            Write-Host "  Modelo: $deviceName" -ForegroundColor White
            Write-Host "  Codename: $deviceModel" -ForegroundColor White
            Write-Host "  Android: $androidVersion" -ForegroundColor White
            Write-Host ""
            
            if ($deviceModel -eq "viva") {
                Write-Host " [V] Dispositivo correcto: Redmi Note 11 Pro 4G (viva)" -ForegroundColor Green
                $global:DeviceVerified = $true
                return @{
                    Model    = $deviceModel
                    Name     = $deviceName
                    Android  = $androidVersion
                    Verified = $true
                }
            }
            else {
                Write-Host " [X] DISPOSITIVO INCORRECTO DETECTADO" -ForegroundColor Red
                Write-Host " [X] Este script es para Redmi Note 11 Pro 4G (viva)" -ForegroundColor Red
                Write-Host " [X] Tu dispositivo es: $deviceModel ($deviceName)" -ForegroundColor Red
                Write-Host " [!] Continuar puede BRICKEAR tu dispositivo" -ForegroundColor Yellow
                $global:DeviceVerified = $false
                return @{
                    Model    = $deviceModel
                    Name     = $deviceName
                    Android  = $androidVersion
                    Verified = $false
                }
            }
        }
    }
    catch {
        $errorMsg = $_.Exception.Message
        Write-Host " [!] Error al detectar dispositivo: $errorMsg" -ForegroundColor Yellow
        return $null
    }
    
    return $null
}

Export-ModuleMember -Function Get-ConnectedDevice
