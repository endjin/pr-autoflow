#Requires -Modules @{ ModuleName='Endjin.PRAutoflow'; ModuleVersion='0.0' }
#Requires -Modules @{ ModuleName='Endjin.GitHubActions'; ModuleVersion='0.0' }

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
$ProgressPreference = 'SilentlyContinue'
if ($Env:SYSTEM_DEBUG -eq 'true') {
    $VerbosePreference = 'Continue'
}

try {
    $result = AnyInterestingPRs -Titles $Titles -MaxSemVerIncrement $MaxSemVerIncrement -PackageWildcardExpressions $PackageWildCardExpressions

    Set-Output 'is_complete' $(!$result)
}
catch {
    $ErrorActionPreference = 'Continue'
    Write-Host "Error: $($_.Exception.Message)"
    Write-Warning $_.ScriptStackTrace
    Write-Error $_.Exception.Message
    exit 1
}