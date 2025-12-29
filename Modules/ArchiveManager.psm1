# ============================================================
# MODULO: ARCHIVE MANAGER
# Gestion de archivos comprimidos (.zip, .xz, .gz)
# ============================================================

function Expand-XzArchive {
    param(
        [string]$FilePath,
        [string]$DestinationDir
    )

    if (!(Test-Path $FilePath)) {
        Write-Host " [X] Archivo no encontrado: $FilePath" -ForegroundColor Red
        return $false
    }

    Write-Host "`n=== EXTRACCION DE ARCHIVO .XZ ===" -ForegroundColor Cyan
    Write-Host " [i] Archivo: $FilePath" -ForegroundColor Gray
    
    # Intentar usar tar.exe (incluido en Windows 10/11)
    try {
        Write-Host " [i] Utilizando herramienta 'tar' de Windows..." -ForegroundColor Gray
        # tar -xf file.xz -C destination
        & tar.exe -xf $FilePath -C $DestinationDir
        
        # Verificar si se extrajo un .img
        $extractedItems = Get-ChildItem -Path $DestinationDir | Where-Object { $_.LastWriteTime -gt (Get-Date).AddMinutes(-5) }
        if ($extractedItems) {
            Write-Host " [V] Extraccion completada exitosamente." -ForegroundColor Green
            return $true
        } else {
            Write-Host " [!] No se detectaron archivos nuevos extraidos." -ForegroundColor Yellow
            return $false
        }
    }
    catch {
        Write-Host " [X] Error al extraer: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Get-ArchiveInfo {
    param([string]$FilePath)
    
    if (Test-Path $FilePath) {
        $item = Get-Item $FilePath
        return @{
            Name = $item.Name
            SizeMB = [math]::Round($item.Length / 1MB, 2)
            Extension = $item.Extension
        }
    }
    return $null
}

Export-ModuleMember -Function Expand-XzArchive, Get-ArchiveInfo
