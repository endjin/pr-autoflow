$ErrorActionPreference = 'Stop'
$moduleInfo = Install-Module Endjin.PRAutoflow -Scope AllUsers -Force -PassThru
Copy-Item (Join-Path $moduleInfo.InstalledLocation 'entrypoint.ps1') /tmp