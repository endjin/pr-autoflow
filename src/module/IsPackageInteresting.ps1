function IsPackageInteresting
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $PackageName,

        [string[]]
        $PackageNamePatterns = @()
    )

    $ErrorActionPreference = 'Stop'

    $matchFound = $false
    foreach ($f in $PackageNamePatterns) {
        if ($PackageName -ilike $f) {
            $matchFound = $true
            Write-Verbose ("Dependency '{0}' matched with parrern '{1}'" -f $PackageName, $PackageNamePatterns)
            break;
        }
    }

    $matchFound
}