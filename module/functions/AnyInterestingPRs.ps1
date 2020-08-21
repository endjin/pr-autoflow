function AnyInterestingPRs
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [AllowNull()]
        [AllowEmptyCollection()]
        [string[]]
        $Titles,

        [Parameter(Mandatory=$true)]
        [ValidateSet('patch','minor','major')]
        [string]
        $MaxSemVerIncrement,

        [Parameter()]
        [string[]]
        $PackageWildcardExpressions = @()
    )

    $ErrorActionPreference = 'Stop'

    Enum semver_upgrade_type {
        patch = 0
        minor = 1
        major = 2
    }
    $maxSemVerIncrementAsEnum = [semver_upgrade_type]$MaxSemVerIncrement

    $result = $false
    foreach ($prTitle in $Titles) {
        Write-Verbose ('Checking PR: {0}' -f $prTitle)
        
        # parse the PR title
        $packageName,$fromVersion,$toVersion,$folder = ParsePrTitle -Title $prTitle
        # For non-Dependabot PRs we won't get a parsed title back, but this is fine.  For normal user PRs
        # don't expect to have to wait for other related, in-flights PR to finish (like we do for Dependabot PRs)
        if (!$packageName) {
            break;
        }
        Write-Verbose ('Package: {0}' -f $packageName)

        # apply package filter
        $matchFound = IsPackageInteresting -PackageName $packageName -PackageWildcardExpressions $PackageWildcardExpressions
        Write-Verbose ('Match Found?: {0}' -f $matchFound)

        # derive upgrade type
        [semver_upgrade_type]$upgradeType = GetSemVerIncrement -FromVersion $fromVersion -ToVersion $toVersion

        if ($matchFound -and ($upgradeType -le $maxSemVerIncrementAsEnum)) {
            Write-Verbose 'Setting result to true'
            $result = $true
        }
    }

    Write-Verbose ('Result: {0}' -f $result)
    return $result
}