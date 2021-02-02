[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]
    $ConfigFile
)

$ErrorActionPreference = 'Stop'

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