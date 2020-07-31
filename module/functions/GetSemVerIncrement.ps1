function GetSemVerIncrement
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [System.Management.Automation.SemanticVersion]
        $FromVersion,

        [Parameter(Mandatory=$true)]
        [system.Management.Automation.SemanticVersion]
        $ToVersion
    )

    $ErrorActionPreference = 'Stop'

    if ($FromVersion -eq $ToVersion) {
        throw "The versions are the same"
    }

    $upgradeType = 'patch'

    if ($ToVersion.Major -gt $FromVersion.Major) {
        $upgradeType = 'major'
    }
    elseif ($ToVersion.Minor -gt $FromVersion.Minor) {
        $upgradeType = 'minor'
    }

    Write-Verbose ('SemVerIncrement: {0}' -f $upgradeType)
    $upgradeType
}