[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string[]]
    $Titles,

    [Parameter()]
    [string]
    $MaxUpdateType = 'minor',

    [Parameter()]
    [string]
    $PackageNamePatternsJsonArray = '[]',

    [Parameter()]
    [string[]]
    $PackageNamePatterns = @()
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
    if ($PackageNamePatternsJsonArray -ne '[]') {
        Write-Verbose "PackageNamePatternsJsonArray: $PackageNamePatternsJsonArray"
        $PackageNamePatterns = ConvertFrom-Json $PackageNamePatternsJsonArray
    }

    # TODO: call new module function


}
catch {
    $ErrorActionPreference = 'Continue'
    Write-Host "Error: $($_.Exception.Message)"
    Write-Warning $_.ScriptStackTrace
    Write-Error $_.Exception.Message
    exit 1
}