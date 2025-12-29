# ============================================================
# MODULO: PERFILES DE USUARIO
# Gestion de perfiles y persistencia de datos
# ============================================================

function Load-UserProfile {
    param([string]$ProfilePath)
    
    if (Test-Path $ProfilePath) {
        try {
            $userProfile = Get-Content $ProfilePath -Raw | ConvertFrom-Json
            $global:OperationMode = $userProfile.preferred_mode
            
            # Convertir completed_steps de PSCustomObject a Hashtable
            $global:StepsCompleted = @{}
            $userProfile.completed_steps.PSObject.Properties | ForEach-Object {
                $global:StepsCompleted[$_.Name] = $_.Value
            }
            
            Write-Host " [i] Perfil de usuario cargado correctamente" -ForegroundColor Gray
            return $userProfile
        }
        catch {
            Write-Host " [!] Error al cargar perfil, usando valores por defecto" -ForegroundColor Yellow
            return $null
        }
    }
    return $null
}

function Save-UserProfile {
    param([string]$ProfilePath)
    
    $userProfile = @{
        version = "5.7"
        preferred_mode = $global:OperationMode
        last_session = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        completed_steps = $global:StepsCompleted
        device_verified = $global:DeviceVerified
        last_backup_date = $global:LastBackupDate
    }
    
    $userProfile | ConvertTo-Json -Depth 10 | Out-File -FilePath $ProfilePath -Encoding utf8
    Write-Host " [i] Perfil de usuario guardado" -ForegroundColor Gray
}

function Reset-UserProfile {
    param([string]$ProfilePath)
    
    if (Test-Path $ProfilePath) {
        Remove-Item $ProfilePath -Force
        Write-Host " [V] Perfil de usuario reiniciado" -ForegroundColor Green
        return $true
    }
    return $false
}

function Get-UserStatistics {
    param([string]$ProfilePath)
    
    if (!(Test-Path $ProfilePath)) {
        Write-Host " [!] No hay perfil guardado" -ForegroundColor Yellow
        return $null
    }
    
    $userProfile = Get-Content $ProfilePath -Raw | ConvertFrom-Json
    
    $completedCount = ($userProfile.completed_steps.PSObject.Properties | Where-Object { $_.Value -eq $true }).Count
    $totalSteps = $userProfile.completed_steps.PSObject.Properties.Count
    $completionPercent = [math]::Round(($completedCount / $totalSteps) * 100, 2)
    
    return @{
        CompletedSteps = $completedCount
        TotalSteps = $totalSteps
        CompletionPercent = $completionPercent
        LastSession = $userProfile.last_session
        PreferredMode = $userProfile.preferred_mode
    }
}

Export-ModuleMember -Function Load-UserProfile, Save-UserProfile, Reset-UserProfile, Get-UserStatistics
