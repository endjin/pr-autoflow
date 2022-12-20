#Requires -Modules @{ ModuleName='Endjin.PRAutoflow'; ModuleVersion='0.0' }
#Requires -Modules @{ ModuleName='Endjin.GitHubActions'; ModuleVersion='0.0' }

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
$ProgressPreference = 'SilentlyContinue'
if ($Env:SYSTEM_DEBUG -eq 'true') {
    $VerbosePreference = 'Continue'
}

try {
    # parse the PR title
    $dependencyName,$fromVersion,$toVersion,$folder = ParsePrTitle -Title $Title

    # if no dependency name, it means we did not match the dependabot PR pattern
    if ($dependencyName) { 
        # set github action output variables
        Set-Output 'dependency_name' $dependencyName
        Set-Output 'version_from' $fromVersion
        Set-Output 'version_to' $toVersion
        Set-Output 'folder' $folder

        # does the dependency name match the wildcard pattern?
        $matchFound = IsPackageInteresting -PackageName $dependencyName -PackageWildCardExpressions $PackageWildCardExpressions
        Set-Output 'is_interesting_package' $matchFound

        $upgradeType = GetSemVerIncrement -FromVersion $fromVersion -ToVersion $toVersion
        Set-Output 'semver_increment' $upgradeType
    }
}
catch {
    $ErrorActionPreference = 'Continue'
    Write-Host "Error: $($_.Exception.Message)"
    Write-Warning $_.ScriptStackTrace
    Write-Error $_.Exception.Message
    exit 1
}