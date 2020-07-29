[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]
    $Title,

    [Parameter()]
    [string]
    $PackageWildCardExpressionsJsonArray = '[]',

    [Parameter()]
    [string[]]
    $PackageWildCardExpressions = @()
)

$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $PSCommandPath

try {
    if ( !(Get-Module dependabot-pr-parser)) {
        if ( !(Test-Path $here/module/dependabot-pr-parser.psm1) ) {
            throw 'Unable to locate the dependabot-pr-parser module - something went wrong!'
        }
        Import-Module $here/module/dependabot-pr-parser.psm1 -DisableNameChecking
    }

    # github actions can only pass strings, so this handles the JSON deserialization
    if ($PackageWildCardExpressionsJsonArray -ne '[]') {
        Write-Verbose "PackageWildCardExpressionsJsonArray: $PackageWildCardExpressionsJsonArray"
        $PackageWildCardExpressions = ConvertFrom-Json $PackageWildCardExpressionsJsonArray
    }

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