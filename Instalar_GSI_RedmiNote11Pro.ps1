<#
.SYNOPSIS
    Asistente GSI Redmi Note 11 Pro 4G (viva) - v4.4.1 Safe Syntax
    Soporte para Mirrors y Redundancia.
#>

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "Redmi Installer v4.4.1"

# --- CONFIGURACION ---
$WorkDir = $PSScriptRoot
$ToolsDir = Join-Path $WorkDir "Herramientas"
$BackupDir = Join-Path $WorkDir "Backups"
$DownloadsDir = Join-Path $WorkDir "Descargas"
$RomsDir = Join-Path $WorkDir "ROMs"

$Urls = @{
    "ADB" = @("https://dl.google.com/android/repository/platform-tools-latest-windows.zip", "https://github.com/K-K-A-K/Treble_Experimentations/raw/master/platform-tools.zip")
    "Patcher" = @("https://github.com/R0rt1z2/mtk-bpf-patcher/archive/refs/heads/main.zip", "https://gitlab.com/R0rt1z2/mtk-bpf-patcher/-/archive/main/mtk-bpf-patcher-main.zip")
    "VBMeta" = @("https://github.com/K-K-A-K/Treble_Experimentations/raw/master/vbmeta.img", "https://raw.githubusercontent.com/phhusson/quack_device_generic/master/vbmeta.img")
}

function Draw-Header {
    Clear-Host
    Write-Host "========================== REDMI v4.4.1 ==========================" -ForegroundColor Cyan
}

function Log-Info { param($m) Write-Host " [i] $m" -ForegroundColor Gray }
function Log-Ok   { param($m) Write-Host " [V] $m" -ForegroundColor Green }
function Log-Warn { param($m) Write-Host " [!] $m" -ForegroundColor Yellow }
function Log-Err  { param($m) Write-Host " [X] $m" -ForegroundColor Red }

function Smart-Download {
    param($Key, $DestFile)
    $MirrorList = $Urls[$Key]
    $Success = $false
    foreach ($Url in $MirrorList) {
        Log-Info "Descargando $Key desde espejo..."
        try {
            Invoke-WebRequest -Uri $Url -OutFile $DestFile -TimeoutSec 20 -ErrorAction Stop
            if ((Get-Item $DestFile).Length -gt 100) { $Success = $true; break }
        } catch { Log-Warn "Error en mirror. Reintentando..." }
    }
    return $Success
}

function Install-Tools {
    Draw-Header
    mkdir $ToolsDir -Force | Out-Null
    mkdir $DownloadsDir -Force | Out-Null
    if (-not (Test-Path "$ToolsDir\platform-tools\fastboot.exe")) {
        if (Smart-Download "ADB" "$DownloadsDir\pt.zip") {
            Expand-Archive "$DownloadsDir\pt.zip" -Dest $ToolsDir -Force; Log-Ok "ADB listo"
        }
    }
    if (-not (Test-Path "$ToolsDir\mtk-bpf-patcher-main")) {
        if (Smart-Download "Patcher" "$DownloadsDir\patcher.zip") {
            Expand-Archive "$DownloadsDir\patcher.zip" -Dest $ToolsDir -Force; Log-Ok "Patcher listo"
        }
    }
    pip install mtkclient | Out-Null
    Read-Host "Enter para volver"
}

# --- LOOP MENU ---
while ($true) {
    Draw-Header
    Write-Host " 1. Instalar Herramientas (Redundancia)"
    Write-Host " 2. Descargar VBMeta Generico"
    Write-Host " 3. Simulacion Flash"
    Write-Host " 4. MODO REAL: Iniciar"
    Write-Host " Q. Salir"
    
    $Op = Read-Host "`nOpcion"
    
    if ($Op -eq "1") { Install-Tools }
    elseif ($Op -eq "2") { Smart-Download "VBMeta" "$WorkDir\vbmeta.img"; Log-Ok "VBMeta listo" }
    elseif ($Op -eq "3") { Write-Host "Simulando..."; Start-Sleep 1 }
    elseif ($Op -eq "Q") { break }
}
