<#
    AUDITORÍA FINAL DE INTEGRIDAD - PROYECTO REDMI GSI
    Verificación de archivos, carpetas y descargas.
#>

$WorkDir = $PSScriptRoot
$ToolsDir = Join-Path $WorkDir "Herramientas"
$DownloadsDir = Join-Path $WorkDir "Descargas"
$RomsDir = Join-Path $WorkDir "ROMs"

function Log-Result {
    param($Name, $Success, $Details)
    $Color = if ($Success) { "Green" } else { "Red" }
    $Status = if ($Success) { "[V] OK" } else { "[X] ERROR" }
    Write-Host ("{0,-10} | {1,-20} | {2}" -f $Status, $Name, $Details) -ForegroundColor $Color
}

Write-Host "`n=== REPORTE DE INTEGRIDAD DEL SISTEMA ===" -ForegroundColor Cyan
Write-Host ("{0,-10} | {1,-20} | {2}" -f "ESTADO", "COMPONENTE", "DETALLES") -ForegroundColor Gray
Write-Host ("-" * 60) -ForegroundColor Gray

# 1. Verificar carpetas
$Folders = @("Herramientas", "Descargas", "ROMs", "Backups", "Recuperacion")
foreach ($f in $Folders) {
    if (Test-Path (Join-Path $WorkDir $f)) {
        Log-Result $f $true "Carpeta existente"
    } else {
        Log-Result $f $false "Carpeta ausente"
    }
}

# 2. Verificar archivos críticos
$Files = @{
    "Magisk APK"      = Join-Path $DownloadsDir "Magisk.apk"
    "Fastboot"        = Join-Path $ToolsDir "platform-tools\fastboot.exe"
    "ADB"             = Join-Path $ToolsDir "platform-tools\adb.exe"
    "Patcher Setup"   = Join-Path $ToolsDir "mtk-bpf-patcher-main\setup.py"
    "Script Maestro"  = Join-Path $WorkDir "Instalar_GSI_RedmiNote11Pro.ps1"
    "Manual de Uso"   = Join-Path $WorkDir "MANUAL_DE_USO.md"
    "Guía de Banca"   = Join-Path $WorkDir "GUIA_BANCA_SEGURIDAD.md"
}

foreach ($f in $Files.Keys) {
    $Path = $Files[$f]
    if (Test-Path $Path) {
        $Size = (Get-Item $Path).Length / 1KB
        Log-Result $f $true ("$( [math]::Round($Size, 2) ) KB")
    } else {
        Log-Result $f $false "No encontrado"
    }
}

Write-Host ("-" * 60) -ForegroundColor Gray
Write-Host "Auditoría finalizada." -ForegroundColor Cyan
