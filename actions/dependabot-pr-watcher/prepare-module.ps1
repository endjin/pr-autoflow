[CmdletBinding()]
param (
    [Parameter()]
    $AllowPreRelease = $false

)
$ErrorActionPreference = 'Stop'
$isReleaseBool = [bool]::Parse($AllowPreRelease)
$moduleInfo = Install-Module Endjin.PRAutoflow -Scope AllUsers `
                                               -AllowPrerelease:$isReleaseBool `
                                               -Force `
                                               -PassThru
Copy-Item (Join-Path $moduleInfo.InstalledLocation 'entrypoint.ps1') /tmp