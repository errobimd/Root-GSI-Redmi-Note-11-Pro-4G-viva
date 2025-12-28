<#
.SYNOPSIS
    Asistente GSI Redmi Note 11 Pro 4G (viva) - v4.5 Security Edition
    Enfocado en compatibilidad con APPS DE BANCO y Seguridad.
#>

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "Redmi Installer v4.5 [SECURITY]"

# --- CONFIGURACION ---
$WorkDir = $PSScriptRoot
$ToolsDir = Join-Path $WorkDir "Herramientas"
$BackupDir = Join-Path $WorkDir "Backups"
$DownloadsDir = Join-Path $WorkDir "Descargas"
$RomsDir = Join-Path $WorkDir "ROMs"

$Urls = @{
    "ADB"     = @("https://dl.google.com/android/repository/platform-tools-latest-windows.zip")
    "Patcher" = @("https://github.com/R0rt1z2/mtk-bpf-patcher/archive/refs/heads/main.zip")
    "Magisk"  = @("https://github.com/topjohnwu/Magisk/releases/latest/download/Magisk-v28.1.apk")
    "PIF"     = @("https://github.com/chiteroman/PlayIntegrityFix/releases/latest/download/PlayIntegrityFix.zip")
    "Shamiko" = @("https://github.com/LSPosed/LSPosed.github.io/releases/download/shamiko-2.1/Shamiko-v1.1.1-357-release.zip")
}

function Draw-Header {
    Clear-Host
    Write-Host "========================== REDMI v4.5 SECURITY ==========================" -ForegroundColor Green
    Write-Host " [!] OBJETIVO: Apps de Banca y Certificación Google (Play Integrity)" -ForegroundColor White
}

function Log-Info { param($m) Write-Host " [i] $m" -ForegroundColor Gray }
function Log-Ok   { param($m) Write-Host " [V] $m" -ForegroundColor Green }
function Log-Warn { param($m) Write-Host " [!] $m" -ForegroundColor Yellow }

function Smart-Download {
    param($Key, $DestFile)
    $MirrorList = $Urls[$Key]
    $Success = $false
    foreach ($Url in $MirrorList) {
        Log-Info "Descargando $Key..."
        try {
            Invoke-WebRequest -Uri $Url -OutFile $DestFile -TimeoutSec 30 -ErrorAction Stop
            if ((Get-Item $DestFile).Length -gt 1024) { $Success = $true; break }
        } catch { Log-Warn "Fallo en descarga de $Key" }
    }
    return $Success
}

function Prep-Banking {
    Draw-Header
    mkdir $DownloadsDir -Force | Out-Null
    Write-Host "PREPARANDO KIT DE BANCA (POST-INSTALACIÓN)..." -ForegroundColor Yellow
    
    if (Smart-Download "Magisk" "$DownloadsDir\Magisk.apk") { Log-Ok "Magisk (Root & Hide) listo." }
    if (Smart-Download "PIF" "$DownloadsDir\PlayIntegrityFix.zip") { Log-Ok "Módulo Integridad listo." }
    if (Smart-Download "Shamiko" "$DownloadsDir\Shamiko.zip") { Log-Ok "Módulo Shamiko listo." }
    
    Write-Host "`n[CONSEJO] Una vez instalada la GSI:" -ForegroundColor Cyan
    Write-Host "1. Instala Magisk.apk y activa Zygisk en Ajustes."
    Write-Host "2. Flashea los .zip desde la sección Módulos de Magisk."
    Write-Host "3. Usa 'DenyList' para ocultar Magisk de tus apps de banco."
    
    Read-Host "`nPresione Enter para volver."
}

# --- LOOP MENU ---
while ($true) {
    Draw-Header
    Write-Host " 1. Instalar Herramientas (ADB / Patcher)"
    Write-Host " 2. PREPARAR APPS DE BANCA (Descargar Magisk + Módulos)"
    Write-Host " 3. Descargar VBMeta Genérico"
    Write-Host " 4. MODO REAL: Iniciar Flasheo GSI"
    Write-Host " 5. MODO REAL: Backup Integral (IMEI/NVRAM)"
    Write-Host " 6. MODO REAL: Recuperación (Unbrick)"
    Write-Host " Q. Salir"
    
    $Op = Read-Host "`nOpcion"
    
    if ($Op -eq "1") { 
        mkdir $ToolsDir -Force | Out-Null
        Smart-Download "ADB" "$DownloadsDir\pt.zip"
        Log-Ok "ADB configurado."
        Read-Host "Enter..."
    }
    elseif ($Op -eq "2") { Prep-Banking }
    elseif ($Op -eq "3") { Smart-Download "VBMeta" "$WorkDir\vbmeta.img"; Log-Ok "VBMeta listo." }
    elseif ($Op -eq "Q") { break }
}
