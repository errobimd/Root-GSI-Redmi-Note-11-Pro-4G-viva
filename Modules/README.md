# Módulos de Antigravity Google Assistant

Este directorio contiene los módulos modulares del proyecto, organizados por funcionalidad.

## Estructura de Módulos

### 📝 UserProfile.psm1
**Gestión de Perfiles de Usuario**
- `Load-UserProfile`: Carga el perfil guardado del usuario
- `Save-UserProfile`: Guarda el progreso y preferencias del usuario

### 🔒 FileIntegrity.psm1
**Verificación de Integridad de Archivos**
- `Get-HashDatabase`: Carga la base de datos de hashes SHA256
- `Test-FileIntegrity`: Verifica la integridad de archivos críticos

### 📱 DeviceDetection.psm1
**Detección Automática de Dispositivo**
- `Get-ConnectedDevice`: Detecta y verifica el dispositivo conectado vía ADB

### ⬇️ DownloadAssistant.psm1
**Asistente de Descargas Automáticas**
- `Get-DownloadDatabase`: Carga la base de datos de URLs de descarga
- `Start-ToolDownload`: Descarga herramientas automáticamente

### 🔔 Notifications.psm1
**Notificaciones y Reportes**
- `Send-Notification`: Envía notificaciones de Windows
- `Export-HTMLReport`: Genera reportes HTML de la sesión

## Uso

Los módulos se importan automáticamente en el script principal:

```powershell
Import-Module "$PSScriptRoot\Modules\UserProfile.psm1"
Import-Module "$PSScriptRoot\Modules\FileIntegrity.psm1"
Import-Module "$PSScriptRoot\Modules\DeviceDetection.psm1"
Import-Module "$PSScriptRoot\Modules\DownloadAssistant.psm1"
Import-Module "$PSScriptRoot\Modules\Notifications.psm1"
```

## Beneficios de la Modularización

✅ **Mantenibilidad**: Código organizado y fácil de mantener
✅ **Reutilización**: Funciones reutilizables en otros proyectos
✅ **Testing**: Cada módulo se puede probar independientemente
✅ **Claridad**: Separación clara de responsabilidades
✅ **Escalabilidad**: Fácil añadir nuevas funcionalidades

---
**Antigravity Google Assistant v5.7 - Ultimate Edition**
