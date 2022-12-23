#Requires -Modules @{ ModuleName='Endjin.GitHubActions'; ModuleVersion='0.0' }

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]
    $ConfigFile
)

$ErrorActionPreference = 'Stop'
if ($Env:SYSTEM_DEBUG -eq 'true') {
    $VerbosePreference = 'Continue'
}

try {
    $configJson = Get-Content -Raw $ConfigFile
    $config =  $configJson | ConvertFrom-Json

    Set-Output 'configJson' $configJson

    $config.PSObject.Properties | ForEach-Object {
        Set-Output $_.Name $_.Value 
    }
}
catch {
    $ErrorActionPreference = 'Continue'
    Write-Host "Error: $($_.Exception.Message)"
    Write-Warning $_.ScriptStackTrace
    Write-Error $_.Exception.Message
    exit 1
}