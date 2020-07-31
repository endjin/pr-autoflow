Write-Host 'Loading profile...'

if ( !(Get-Module pr-autoflow)) {
    if ( !(Test-Path /tmp/module/pr-autoflow.psm1) ) {
        throw 'Unable to locate the pr-autoflow module - something went wrong!'
    }
    Import-Module /tmp/module/pr-autoflow.psd1 -DisableNameChecking
}
