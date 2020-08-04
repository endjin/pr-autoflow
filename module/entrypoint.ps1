[CmdletBinding()]
param(
    [Parameter(ValueFromRemainingArguments)] $additionalArgs
)

Write-Host 'Running entrypoint script'

if ( !(Get-Module pr-autoflow)) {
    if ( !(Test-Path /tmp/module/pr-autoflow.psm1) ) {
        throw 'Unable to locate the pr-autoflow module - something went wrong!'
    }
    Import-Module /tmp/module/Endjin.PRAutoflow.psd1 -DisableNameChecking
}

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