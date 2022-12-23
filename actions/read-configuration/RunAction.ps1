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

    # Output variable values cannot include newlines since switching to the GITHUB_OUTPUT mechanism
    Set-Output 'configJson' ($config | ConvertTo-Json -Compress)

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