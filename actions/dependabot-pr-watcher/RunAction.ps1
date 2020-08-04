#Requires -Modules @{ ModuleName='Endjin.PRAutoflow'; ModuleVersion='1.0.0' }

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [AllowNull()]
    [AllowEmptyCollection()]
    [JsonTransform()]
    [string[]]
    $Titles,

    [Parameter()]
    [ValidateSet('patch','minor','major')]
    [string]
    $MaxSemVerIncrement = 'minor',

    [Parameter(Mandatory = $true)]
    [AllowNull()]
    [AllowEmptyCollection()]
    [JsonTransform()]
    [string[]]
    $PackageWildCardExpressions = @()
)

$ErrorActionPreference = 'Stop'

try {
    $result = AnyInterestingPRs -Titles $Titles -MaxSemVerIncrement $MaxSemVerIncrement -PackageWildcardExpressions $PackageWildCardExpressions

    SetOutputVariable 'is_complete' $(!$result)
}
catch {
    $ErrorActionPreference = 'Continue'
    Write-Host "Error: $($_.Exception.Message)"
    Write-Warning $_.ScriptStackTrace
    Write-Error $_.Exception.Message
    exit 1
}