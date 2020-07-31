#Requires -Modules @{ ModuleName='pr-autoflow'; ModuleVersion='1.0.0' }

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]
    $Title,

    [Parameter()]
    [AllowNull()]
    [AllowEmptyCollection()]
    [JsonTransform()]
    [string[]]
    $PackageWildCardExpressions = @()
)

$ErrorActionPreference = 'Stop'

try {
    # parse the PR title
    $dependencyName,$fromVersion,$toVersion,$folder = ParsePrTitle -Title $Title

    # set github action output variables
    SetOutputVariable 'dependency_name' $dependencyName
    SetOutputVariable 'version_from' $fromVersion
    SetOutputVariable 'version_to' $toVersion
    SetOutputVariable 'folder' $folder

    # is the dependency name match the wildcard pattern?
    $matchFound = IsPackageInteresting -PackageName $dependencyName -PackageWildCardExpressions $PackageWildCardExpressions
    SetOutputVariable 'is_interesting_package' $matchFound

    $upgradeType = GetSemVerIncrement -FromVersion $fromVersion -ToVersion $toVersion
    SetOutputVariable 'update_type' $upgradeType
}
catch {
    $ErrorActionPreference = 'Continue'
    Write-Host "Error: $($_.Exception.Message)"
    Write-Warning $_.ScriptStackTrace
    Write-Error $_.Exception.Message
    exit 1
}