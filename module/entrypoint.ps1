[CmdletBinding()]
param(
    [Parameter(ValueFromRemainingArguments)] $additionalArgs
)

Write-Host 'Running entrypoint script'

if ( !(Get-Module Endjin.PRAutoflow -ListAvailable)) {
    throw 'Unable to locate the Endjin.PRAutoflow module - something went wrong!'
}
Import-Module Endjin.PRAutoflow -DisableNameChecking

# Convert array of parameters passed by Docker into hashtable we can splat
$htvars = @{}
$additionalArgs | ForEach-Object {
    if($_ -match '^-') {
        #New parameter
        $lastvar = $_ -replace '^-'
        $htvars[$lastvar] = $null
    } else {
        #Value
        $htvars[$lastvar] = $_
    }
}
Write-Host "Calling action with args:"
Write-Host ($htvars | fl | Out-String)
/tmp/RunAction.ps1 @htvars
exit $LASTEXITCODE