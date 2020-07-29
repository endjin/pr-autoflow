[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, ParameterSetName = "Native")]
    [string[]]
    $Titles,

    [Parameter(Mandatory = $true, ParameterSetName = "Json")]
    [string]
    $TitlesAsJsonArray,

    [Parameter()]
    [string]
    $MaxUpdateType = 'minor',

    [Parameter(Mandatory = $true, ParameterSetName = "Json")]
    [string]
    $PackageWildCardExpressionsJsonArray,

    [Parameter(Mandatory = $true, ParameterSetName = "Native")]
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
    if ($PSCmdlet.ParameterSetName -eq "Json") {
        Write-Verbose "PackageWildCardExpressionsJsonArray: $PackageWildCardExpressionsJsonArray"
        $PackageWildCardExpressions = ConvertFrom-Json $PackageWildCardExpressionsJsonArray
        Write-Verbose "TitlesAsJsonArray: $TitlesAsJsonArray"
        $Titles = ConvertFrom-Json $TitlesAsJsonArray
    }

    $result = AnyInterestingPRs -Titles $Titles -MaxSemVerIncrement "minor" -PackageWildcardExpressions $PackageWildCardExpressions

    SetOutputVariable 'is_complete' $(!$result)
}
catch {
    $ErrorActionPreference = 'Continue'
    Write-Host "Error: $($_.Exception.Message)"
    Write-Warning $_.ScriptStackTrace
    Write-Error $_.Exception.Message
    exit 1
}