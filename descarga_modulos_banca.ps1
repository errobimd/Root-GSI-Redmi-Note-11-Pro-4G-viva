[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$DownloadsDir = Join-Path $PSScriptRoot "Descargas"
if (!(Test-Path $DownloadsDir)) { mkdir $DownloadsDir -Force | Out-Null }

$UA = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"

$Urls = @{
    "PlayIntegrityFork" = "https://github.com/osm0sis/PlayIntegrityFork/releases/download/v16/PlayIntegrityFork-v16.zip"
    "Shamiko"           = "https://github.com/LSPosed/LSPosed.github.io/releases/download/shamiko-414/Shamiko-v1.2.5-414-release.zip"
}

Write-Host "Iniciando descarga de módulos de seguridad..." -ForegroundColor Cyan

foreach ($item in $Urls.GetEnumerator()) {
    $Name = $item.Key
    $Url = $item.Value
    $Dest = Join-Path $DownloadsDir "$Name.zip"
    
    Write-Host "Descargando $Name desde GitHub..."
    try {
        Invoke-WebRequest -Uri $Url -OutFile $Dest -UserAgent $UA -TimeoutSec 60 -ErrorAction Stop
        if ((Get-Item $Dest).Length -gt 1000) {
            Write-Host "[V] $Name guardado en Descargas/" -ForegroundColor Green
        }
    } catch {
        Write-Host "[X] Falló $Name : $($_.Exception.Message)" -ForegroundColor Red
    }
}
