$ErrorActionPreference = 'Stop'
$pesterVer = '4.10.1'
[array]$existingModule = Get-Module -ListAvailable Pester
if (!$existingModule -or ($existingModule.Version -notcontains $pesterVer)) {
    Install-Module Pester -RequiredVersion $pesterVer -Force -Scope CurrentUser
}
Import-Module Pester
Invoke-Pester ./src